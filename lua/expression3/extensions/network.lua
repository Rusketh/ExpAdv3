--[[
	   ____      _  _      ___    ___       ____      ___      ___     __     ____      _  _          _        ___     _  _       ____
	  F ___J    FJ  LJ    F _ ", F _ ",    F ___J    F __".   F __".   FJ    F __ ]    F L L]        /.\      F __".  FJ  L]     F___ J
	 J |___:    J \/ F   J `-' |J `-'(|   J |___:   J (___|  J (___|  J  L  J |--| L  J   \| L      //_\\    J |--\ LJ |  | L    `-__| L
	 | _____|   /    \   |  __/F|  _  L   | _____|  J\___ \  J\___ \  |  |  | |  | |  | |\   |     / ___ \   | |  J |J J  F L     |__  (
	 F L____:  /  /\  \  F |__/ F |_\  L  F L____: .--___) \.--___) \ F  J  F L__J J  F L\\  J    / L___J \  F L__J |J\ \/ /F  .-____] J
	J________LJ__//\\__LJ__|   J__| \\__LJ________LJ\______JJ\______JJ____LJ\______/FJ__L \\__L  J__L   J__LJ______/F \\__//   J\______/F
	|________||__/  \__||__L   |__|  J__||________| J______F J______F|____| J______F |__L  J__|  |__L   J__||______F   \__/     J______F

	::Network Extension::
]]

if true then return; end --File disabled.

local extension = EXPR_LIB.RegisterExtension("network");

--[[

]]


extension:SetSharedState();

extension:RegisterLibrary("net");

extension:RegisterFunction("net", "start", "s", "", 0, function(context, name)
	context.data.usermessage_buffer = {};
	context.data.usermessage_message = name;
end, false);

--[[
	Write
]]

local function write(context, value)
	local b = context.data.usermessage_buffer;

	b[#b + 1] = value;
end

extension:RegisterFunction("net", "writeAngle", "a", "", 0, write, true);

extension:RegisterFunction("net", "writeBool", "b", "", 0, write, true);

extension:RegisterFunction("net", "writeColor", "c", "", 0, write, true);

extension:RegisterFunction("net", "writeEntity", "e", "", 0, write, true);

extension:RegisterFunction("net", "writeInt", "n", "", 0, write, true);

extension:RegisterFunction("net", "writeString", "s", "", 0, write, true);

extension:RegisterFunction("net", "writeTable", "t", "", 0, write, true);

extension:RegisterFunction("net", "writeVector", "v", "", 0, write, true);

--[[
	Read
]]

extension:RegisterFunction("net", "readAngle", "", "a", 1, function(context)
	local buffer = context.data.usermessage_readBuffer;

	if not buffer then return end;

	local i = context.data.usermessage_read or 0;

	local value = buffer[i];

	if ( not IsAngle(value) ) then
		return;
	end

	context.data.usermessage_read = i + 1;

	return value;

end, false);

extension:RegisterFunction("net", "readBool", "", "b", 1, function(context)
	local buffer = context.data.usermessage_readBuffer;

	if not buffer then return end;

	local i = context.data.usermessage_read or 0;

	local value = buffer[i];

	if ( not isbool(value) ) then
		return;
	end


	context.data.usermessage_read = i + 1;

	return value;

end, false);

extension:RegisterFunction("net", "readColor", "", "c", 1,  function(context)
	local buffer = context.data.usermessage_readBuffer;

	if not buffer then return end;

	local i = context.data.usermessage_read or 0;

	local value = buffer[i];

	if ( not IsColor(value) ) then
		return;
	end


	context.data.usermessage_read = i + 1;

	return value;

end, false);

extension:RegisterFunction("net", "readEntity", "", "e", 1, function(context)
	local buffer = context.data.usermessage_readBuffer;

	if not buffer then return end;

	local i = context.data.usermessage_read or 0;

	local value = buffer[i];

	if ( not IsEntity(value) ) then
		return;
	end

	context.data.usermessage_read = i + 1;

	return value;

end, false);

extension:RegisterFunction("net", "readInt", "n", "n", 1, function(context)
	local buffer = context.data.usermessage_readBuffer;

	if not buffer then return end;

	local i = context.data.usermessage_read or 0;

	local value = buffer[i];

	if ( not isnumber(value) ) then
		return;
	end

	context.data.usermessage_read = i + 1;

	return value;

end, false);

extension:RegisterFunction("net", "readString", "", "s", 1, function(context)
	local buffer = context.data.usermessage_readBuffer;

	if not buffer then return end;

	local i = context.data.usermessage_read or 0;

	local value = buffer[i];

	if ( not isstring(value) ) then
		return;
	end

	context.data.usermessage_read = i + 1;

	return value;

end, false);

extension:RegisterFunction("net", "readTable", "", "t", 1, function(context)
	local buffer = context.data.usermessage_readBuffer;

	if not buffer then return end;

	local i = context.data.usermessage_read or 0;

	local value = buffer[i];

	if ( not istable(value) ) then
		return;
	end

	context.data.usermessage_read = i + 1;

	return value;

end, false);

extension:RegisterFunction("net", "readVector", "", "v", 1, function(context)
	local buffer = context.data.usermessage_readBuffer;

	if not buffer then return end;

	local i = context.data.usermessage_read or 0;

	local value = buffer[i];

	if ( not IsVector(value) ) then
		return;
	end


	context.data.usermessage_read = i + 1;

	return value;

end, false);


--[[
	Send
]]

extension:SetSharedState();

function _sendToPlayer(context, player, name, data)
	context.entity:SendNetMessage("UserMessage", player, name, data);
end

function _sendToServer(context, name, data)
	context.entity:SendNetMessage("UserMessage", name, data);
end

function _sendToAll(context, name, data)
	context.entity:SendNetMessage("UserMessage", name, data);
end

extension:RegisterFunction("net", "send", "p", "", 0, function (context)
	context:AddNetUsage( net.BytesWritten() );
	
	local data = context.data.usermessage_buffer;
	local name = context.data.usermessage_message;

	if not data then return; end

	context:QueuePostExe(_sendToPlayer, true, player, name, data);

end, false);

extension:SetClientState();

extension:RegisterFunction("net", "sendToServer", "p", "", 0, function (context)
	context:AddNetUsage( net.BytesWritten() );
	
	local data = context.data.usermessage_buffer;
	local name = context.data.usermessage_message;

	if not data then return; end

	context:QueuePostExe(_sendToServer, true, name, data);

end, false);

extension:SetServerState();

extension:RegisterFunction("net", "broadcast", "p", "", 0, function (context)
	context:AddNetUsage( net.BytesWritten() );
	
	local data = context.data.usermessage_buffer;
	local name = context.data.usermessage_message;

	if not data then return; end

	context:QueuePostExe(_sendToServer, true, name, data);
end, false);


--[[
	REVEIVE
]]

extension:RegisterFunction("net", "recive", "s,f", "", 0, function (context, name, cb)
	if not context.net_hooks then context.net_hooks = {}; end
	net_hooks[name] = cb;
end, false);

EXPR_LIB.AddNetTemplate("UserMessage", "b,...", function(len, from)

	local entity = net.Readentity();

	local player = net.ReadPlayer();

	if ( IsValid(entity) and entity.ReceiveNetWithTemplate ) then

		local result = entity:ReceiveNetWithTemplate("UserMessage");

		if SERVER and IsValid(player) then
			entity:SendNetMessage( player, "UserMessage", true, unpack(result) );
		elseif entity.context then
			if not context.entity.net_hooks then return; end
			
			local context = entity.context;
			local cb = context.entity.net_hooks[result[1]];
			if cb == nil then return; end

			context.data.usermessage_readBuffer = result[2];
			context.data.usermessage_read = 0; 

			entity:Invoke("net<" .. result[2] .. ">", "", 0, cb);
		end
	end
end);

extension:EnableExtension();
