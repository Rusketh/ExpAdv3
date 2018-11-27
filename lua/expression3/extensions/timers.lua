--[[
	   ____      _  _      ___    ___       ____      ___      ___     __     ____      _  _          _        ___     _  _       ____
	  F ___J    FJ  LJ    F _ ", F _ ",    F ___J    F __".   F __".   FJ    F __ ]    F L L]        /.\      F __".  FJ  L]     F___ J
	 J |___:    J \/ F   J `-' |J `-'(|   J |___:   J (___|  J (___|  J  L  J |--| L  J   \| L      //_\\    J |--\ LJ |  | L    `-__| L
	 | _____|   /    \   |  __/F|  _  L   | _____|  J\___ \  J\___ \  |  |  | |  | |  | |\   |     / ___ \   | |  J |J J  F L     |__  (
	 F L____:  /  /\  \  F |__/ F |_\  L  F L____: .--___) \.--___) \ F  J  F L__J J  F L\\  J    / L___J \  F L__J |J\ \/ /F  .-____] J
	J________LJ__//\\__LJ__|   J__| \\__LJ________LJ\______JJ\______JJ____LJ\______/FJ__L \\__L  J__L   J__LJ______/F \\__//   J\______/F
	|________||__/  \__||__L   |__|  J__||________| J______F J______F|____| J______F |__L  J__|  |__L   J__||______F   \__/     J______F

	::Timers/Time::
]]

--[[

]]

local extension = EXPR_LIB.RegisterExtension("time");

extension:RegisterLibrary("timer");

--[[
	Create timer
]]

local function createTimer(context, name, duration, repitions, callback, ...)
	local timer = { };

	local timers = context.data.timers;

	name = name or #timers + 1;

	timer.name = name;
	timer.duration = duration;
	timer.repitions = repitions or 1;
	timer.callback = callback;
	timer.args = { ... };

	timer.counter = 0;
	timer.paused = false;
	timer.nextTime = CurTime() + duration;

	timers[name] = timer;
end

extension:RegisterFunction("timer", "create", "s,n,n,f,...", "", 0, createTimer, false);

extension:RegisterFunction("timer", "simple", "n,f,...", "", 0, function(context, duration, callback, ...)
	createTimer(context, nil, duration, 1, callback, ...);
end, false);

--[[
	Timer Control
]]

extension:RegisterFunction("timer", "remove", "s", "", 0, function(context, name)
	context.data.timers[name] = nil;
end, false);

extension:RegisterFunction("timer", "pause", "s", "", 0, function(context, name)
	local timer = context.data.timers[name];
	if timer then timer.paused = true; end
end, false);

extension:RegisterFunction("timer", "resume", "s", "", 0, function(context, name)
	local timer = context.data.timers[name];
	if timer then timer.paused = false; end
end, false);

extension:RegisterFunction("timer", "reset", "s,n,n", "", 0, function(context, name, duration, repitions)
	local timer = context.data.timers[name];

	if timer then
		timer.counter = 0;
		timer.duration = duration;
		timer.repitions = repitions;
		timer.nextTime = CurTime() + duration;
	end
end, false);

extension:RegisterFunction("timer", "reset", "s", "", 0, function(context, name)
	local timer = context.data.timers[name];

	if timer then
		timer.counter = 0;
		timer.nextTime = CurTime() + timer.duration;
	end
end, false);

--[[
	Hooks
]]

hook.Add("Expression3.Entity.BuildSandbox", "Expression3.Timers", function(entity, context, enviroment)
	context.data.timers = {};
end);

hook.Add("Think", "Expression3.Timers", function()
	
	local now = CurTime();

	for _, context in pairs( EXPR_LIB.GetAll() ) do

		local entity = context.entity;

		if context.status and IsValid(entity) then
			
			local i = 0;
			local max = 100;
			local expired = { };
			local timers = context.data.timers;

			for name, timer in pairs( timers ) do

				i = i + 1;

				if i > max then
					break;
				end

				if not timer.paused then

					if timer.nextTime <= now then

						if timer.repitions > 0 then
							timer.counter = timer.counter + 1;
						end

						local ok, result = entity:Invoke("Timer." .. name, "*", 0, timer.callback, unpack(timer.args));

						if (not ok) or (timer.repitions > 0 and timer.counter >= timer.repitions) then
							expired[#expired + 1] = name;
						else
							timer.nextTime = CurTime() + timer.duration;
						end
					end	

				end

			end

			for i = 1, #expired do
				table.remove(timers, expired[i]);
			end

		end

	end

end);

extension:EnableExtension();
