--[[
	   ____      _  _      ___    ___       ____      ___      ___     __     ____      _  _          _        ___     _  _       ____
	  F ___J    FJ  LJ    F _ ", F _ ",    F ___J    F __".   F __".   FJ    F __ ]    F L L]        /.\      F __".  FJ  L]     F___ J
	 J |___:    J \/ F   J `-' |J `-'(|   J |___:   J (___|  J (___|  J  L  J |--| L  J   \| L      //_\\    J |--\ LJ |  | L    `-__| L
	 | _____|   /    \   |  __/F|  _  L   | _____|  J\___ \  J\___ \  |  |  | |  | |  | |\   |     / ___ \   | |  J |J J  F L     |__  (
	 F L____:  /  /\  \  F |__/ F |_\  L  F L____: .--___) \.--___) \ F  J  F L__J J  F L\\  J    / L___J \  F L__J |J\ \/ /F  .-____] J
	J________LJ__//\\__LJ__|   J__| \\__LJ________LJ\______JJ\______JJ____LJ\______/FJ__L \\__L  J__L   J__LJ______/F \\__//   J\______/F
	|________||__/  \__||__L   |__|  J__||________| J______F J______F|____| J______F |__L  J__|  |__L   J__||______F   \__/     J______F

	::Expression 3 Base::
	
	Need an easier way to send net messages, so i thought why not just make a crazy complicated system capable of sending huge amounts of data with me needing to do all this net message ahdnaling.
	thats where i got the idea to use templates. We dont need this, but its cool.
]]

AddCSLuaFile();

--[[
	Util
]]

EXPR_LIB.net_templates = {}

--[[
	Templates
]]

function EXPR_LIB.AddNetTemplate(name, template, reciever)
	if reciever then util.AddNetworkString(name); end

	EXPR_LIB.net_templates[name] = string.Explode("," template);


	if reciever then
		EXPR_LIB.net_templates[name].reciever = reciever;

		net.Receive( "Expression." .. name, reciever );
	end
end

--[[
	Send to and from using Templates.
]]

function ENT:SendNetMessage( player, name, ...)
	
	if ( pcall(Net.Start, "Expression." .. name ) ) then
		-- This is more an attempt to ward of the termination message.

		net.WriteEntity(self);

		net.WriteEntity(player);

		self:SendNetWithTemplate(name, ...);

		if self.context and self.context.inExe then
			self.context:AddNetUsage(bytes);
		end

		local bytes = net.BytesWritten();

		if CLIENT then
			net.SendToServer();

		elseif IsValid(player) then
			net.Send(player);

		else
			net.Broadcast();
		end

		return bytes;
	end

	return 0;
end

function ENT:SendNetWithTemplate(name, ...)
	local template = EXPR_LIB.net_templates[name];

	if not template; then return; end

	local values = { ... };

	for i = 1, #template do
		local t = template[i];
		local v = values[i];

		if t == "n" then
			net.WriteUInt(v, 64); --Why? because lua ints are doubles, doubles are 64.
								  --Shut up, I am trying to be smart here, I think.
		elseif t == "s" then
			net.WriteString(v);

		elseif t == "b" then
			net.WriteBit(v);

		elseif t == "v" then
			net.WriteVector(v);

		elseif t == "a" then
			net.WriteAngle(v);

		elseif t == "e" then
			net.WriteEntity(v);

		elseif t == "t" then
			net.WriteTable(v);

		elseif t == "..." then
			net.WriteTable({ unpack(t, i + 1) });

			break;

		else
			self:SendNetWithTemplate(t, unpack(t, i))

		end
	end
end

function ENT:ReceiveNetWithTemplate(name)
	local template = EXPR_LIB.net_templates[name];

	if not template; then return; end

	local values = { };

	for i = 1, #template do
		local t = template[i];

		if t == "n" then
			values[i] = net.ReadUInt(64); 

		elseif t == "s" then
			values[i] = net.ReadString();

		elseif t == "b" then
			values[i] = net.ReadBit() == 1;

		elseif t == "v" then
			values[i] = net.ReadVector();

		elseif t == "a" then
			values[i] = net.ReadAngle();

		elseif t == "e" then
			values[i] = net.ReadEntity();

		elseif t == "t" then
			values[i] = net.ReadTable();

		elseif t == "..." then
			values[i] = net.ReadTable({ unpack(t, i + 1) });

			break;

		else
			values[i] = self:ReceiveNetWithTemplate(t);

		end
	end

	return values;
end

--[[
	Golem/Chat Message Owner
]]

function ENT:SendToOwner(chat, ...)
	return self:SendToPlayersChat(self.player, chat, ...);
end

function ENT:SendToPlayer(player, chat ...)
	if (SERVER or LocalPlayer() ~= player) then
		return self:SendNetMessage( player, "SendMessage", chat, ...);
	else
		chat.AddText(...);
		return 0;
	end
end

EXPR_LIB.AddNetTemplate("SendMessage", "b,...", function(len, from)

	local entity = net.Readentity();

	local player = net.ReadPlayer();

	if ( IsValid(entity) and entity.ReceiveNetWithTemplate ) then

		local result = entity:ReceiveNetWithTemplate("SendMessage");

		if not (player == entity.player) then
			if ( not self.context ) or ( not self.context:HasPerm(player, "SendMessage") ) then
				return;
			end
		end

		if SERVER then
			entity:SendNetMessage( player, "SendMessage", true, ...);
		elseif net.ReadBit() == 1 then
			chat.AddText( unpack(result) );
		else
			Golem.Print( unpack(result) );
		end
	end
end);

--[[
	
]]

