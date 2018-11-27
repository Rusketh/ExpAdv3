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
	if reciever and SERVER then util.AddNetworkString("Expression3." .. name); end

	EXPR_LIB.net_templates[name] = string.Explode(",", template);


	if reciever then
		EXPR_LIB.net_templates[name].reciever = reciever;

		net.Receive( "Expression3." .. name, reciever );
	end
end

--[[
	Send to and from using Templates.
]]

function ENT:SendNetMessage( player, name, ...)
	
	net.Start( "Expression3." .. name );

	print("net message started");

	net.WriteEntity(self);

	net.WriteEntity(player);

	self:SendNetWithTemplate(name, ...);

	local bytes = net.BytesWritten();

	if self.context and self.context.inExe then
		self.context:AddNetUsage(bytes);
	end

	if CLIENT then
		print("Sent to server")
		net.SendToServer();

	elseif IsValid(player) then
		print("Sent to player: ", player)
		net.Send(player);

	else
		print("Broadcasted")
		net.Broadcast();
	end

	return bytes;
end

function ENT:SendNetWithTemplate(name, ...)
	local template = EXPR_LIB.net_templates[name];

	if not template then return; end

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
			net.WriteTable({ unpack(values, i) });

			break;

		else
			self:SendNetWithTemplate(t, unpack(v, i))

		end
	end
end

function ENT:ReceiveNetWithTemplate(name)
	local template = EXPR_LIB.net_templates[name];

	if not template then return; end

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
			for _, v in pairs( net.ReadTable() ) do
				values[#values + 1] = v;
			end

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

function ENT:SendToOwner(tochat, ...)
	return self:SendToPlayer(self.player, tochat, ...);
end

function ENT:SendToPlayer(player, tochat, ...)
	print("SENDTOPLAYER: ", player, tochat, ...)

	if (SERVER or LocalPlayer() ~= player) then
		return self:SendNetMessage( player, "SendMessage", chat, ...);
	elseif ( tochat ) then
		chat.AddText(...);
	else
		Golem.Print(...);
	end
	
	return 0;
end

EXPR_LIB.AddNetTemplate("SendMessage", "b,...", function(len, from)

	local entity = net.ReadEntity();

	local player = net.ReadEntity();

	if ( IsValid(entity) and entity.ReceiveNetWithTemplate ) then

		local result = entity:ReceiveNetWithTemplate("SendMessage");

		PrintTable(result);

		--[[if not player == entity:GetOwner() then
			print("Player is not entity player")
			if ( not entity.context ) or ( not entity.context:HasPerm(player, "SendMessage") ) then
				print("entity does not have player permission")
				return;
			end
		end]]

		if SERVER then
			entity:SendNetMessage( player, "SendMessage", unpack(result) );
		elseif net.ReadBit() == 1 then
			chat.AddText( unpack(result) );
		else
			Golem.Print( unpack(result) );
		end
	end
end);

--[[
	Golem Logger
]]

function ENT:WriteToLogger(...)
	local log, logger = {...}, self.Logger;

	if (not logger) then
		self.Logger = log;
		return;
	end

	for i = 1, #log do
		logger[#logger + 1] = log[i];
	end
end

function ENT:FlushLogger()
	if (self.Logger and #self.Logger > 0) then
		self:SendToOwner(false, unpack(self.Logger));
		self.Logger = nil;
	end
end

--[[
	Uploading
]]

--[[
Current one is good enogh for now, once finished this might be better.
Nope, i need this now.

if SERVER then
	function ENT:RequestUpload(player)
		timer.simple(0.5, function()
			if IsValid(self) then self:SendNetMessage(player, "RequestUpload"); end
		end);
	end
end

EXPR_LIB.AddNetTemplate("RequestUpload", "", function(len, from)
	local entity = net.ReadEntity();

	local player = net.ReadEntity();

	if ( IsValid(entity) and entity.SubmitToServer ) then
		entity:SubmitToServer( Golem.GetCode() );
	end
end);

if CLIENT then

	function ENT:SubmitToServer(script)
		if (not script or script == "") then
			chat.AddText(Color(255, 0, 0), "Can not upload blank script to server.");
			return;
		end

		local ok, result = self:ValidateCode(script, nil);

		if not ok then
			self:HandelThrown(result);
			return;
		end

		local files = { };

		for _, file_path in pairs(result.directives.includes) do
			files[file_path] = file.Read("golem/" .. file_path .. ".txt", "DATA");
		end

		self:SendNetMessage(nil, "UploadScript", script, files);
	end

end

EXPR_LIB.AddNetTemplate("UploadScript", "s,t", function(len, from)
	local entity = net.ReadEntity();

	local player = net.ReadEntity();

	if ( IsValid(entity) and entity.SubmitUpload ) then
		local result = self:ReceiveNetWithTemplate("UploadScript");
		local code, files = result[1], result[2];
		entity:SubmitUpload(code, files, from);
	end
end);

if SERVER then

	function ENT:SubmitUpload(code, files, from)
		self.player = from;

	end

end]]