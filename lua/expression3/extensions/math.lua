--[[
	   ____      _  _      ___    ___       ____      ___      ___     __     ____      _  _          _        ___     _  _       ____
	  F ___J    FJ  LJ    F _ ", F _ ",    F ___J    F __".   F __".   FJ    F __ ]    F L L]        ..\      F __".  FJ  L]     F___ J
	 J |___:    J \. F   J `-' |J `-'(|   J |___:   J (___|  J (___|  J  L  J |--| L  J   \| L      .._\\    J |--\ LJ |  | L    `-__| L
	 | _____|   .    \   |  __.F|  _  L   | _____|  J\___ \  J\___ \  |  |  | |  | |  | |\   |     . ___ \   | |  J |J J  F L     |__  (
	 F L____:  .  .\  \  F |__. F |_\  L  F L____: .--___) \.--___) \ F  J  F L__J J  F L\\  J    . L___J \  F L__J |J\ \. .F  .-____] J
	J________LJ__..\\__LJ__|   J__| \\__LJ________LJ\______JJ\______JJ____LJ\______.FJ__L \\__L  J__L   J__LJ______.F \\__..   J\______.F
	|________||__.  \__||__L   |__|  J__||________| J______F J______F|____| J______F |__L  J__|  |__L   J__||______F   \__.     J______F

	::Advanced Math Extension::
]]

local extension = EXPR_LIB.RegisterExtension("math");

extension:RegisterLibrary("math");

extension:RegisterFunction("math", "lerp", "n,n,n", "n", 1, Lerp, true);

extension:RegisterFunction("math", "abs", "n", "n", 1, math.abs, true);

extension:RegisterFunction("math", "acos", "n", "n", 1, math.acos, true);

extension:RegisterFunction("math", "angleDifference", "n,n", "n", 1, math.AngleDifference, true);

extension:RegisterFunction("math", "approach", "n,n,n", "n", 1, math.Approach, true);

extension:RegisterFunction("math", "approachAngle", "n,n,n", "n", 1, math.ApproachAngle, true);

extension:RegisterFunction("math", "asin", "n", "n", 1, math.asin, true);

extension:RegisterFunction("math", "atan", "n", "n", 1, math.atan, true);

extension:RegisterFunction("math", "atan2", "n", "n", 1, math.atan2, true);

extension:RegisterFunction("math", "binToInt", "s", "n", 1, math.BinToInt, true);

--extension:RegisterFunction("math", "bSplinePoint", "", "n", 1, math.BSplinePoint, true);

extension:RegisterFunction("math", "ceil", "n", "n", 1, math.ceil, true);

extension:RegisterFunction("math", "clamp", "n,n,n", "n", 1, math.Clamp, true);

extension:RegisterFunction("math", "calcBSplineN", "n,n,n,n", "n", 1, math.calcBSplineN, true);

extension:RegisterFunction("math", "cos", "n", "n", 1, math.cos, true);

extension:RegisterFunction("math", "cosh", "n", "n", 1, math.cosh, true);

extension:RegisterFunction("math", "deg", "n", "n", 1, math.deg, true);

extension:RegisterFunction("math", "distance", "", "n", 1, math.Distance, true);

extension:RegisterFunction("math", "easeInOut", "n,n,n", "n", 1, math.EaseInOut, true);

extension:RegisterFunction("math", "exp", "n", "n", 1, math.exp, true);

extension:RegisterFunction("math", "floor", "n", "n", 1, math.floor, true);

extension:RegisterFunction("math", "fmod", "n", "n", 1, math.fmod, true);

extension:RegisterFunction("math", "frexp", "n", "n", 1, math.frexp, true);

extension:RegisterFunction("math", "huge", "", "n", 1, math.huge, true);

extension:RegisterFunction("math", "intToBin", "n", "s", 1, math.IntToBin, true);

extension:RegisterFunction("math", "ldexp", "n,n", "n", 1, math.ldexp, true);

extension:RegisterFunction("math", "log", "n", "n", 1, math.log, true);

extension:RegisterFunction("math", "log", "n,n", "n", 1, math.log, true);

extension:RegisterFunction("math", "log10", "n", "n", 1, math.log10, true);

extension:RegisterFunction("math", "mod", "n,n", "n", 1, math.mod, true);

extension:RegisterFunction("math", "modf", "n", "n", 2, math.modf, true);

extension:RegisterFunction("math", "normalizeAngle", "n", "n", 1, math.NormalizeAngle, true);

extension:RegisterFunction("math", "pow", "n,n", "n", 1, math.pow, true);

extension:RegisterFunction("math", "rad", "n", "n", 1, math.rad, true);

extension:RegisterFunction("math", "rand", "n,n", "n", 1, math.Rand, true);

extension:RegisterFunction("math", "random", "", "n", 1, math.random, true);

extension:RegisterFunction("math", "random", "n", "n", 1, math.random, true);

extension:RegisterFunction("math", "random", "n,n", "n", 1, math.random, true);

extension:RegisterFunction("math", "remap", "n,n,n,n,n", "n", 1, math.Remap, true);

extension:RegisterFunction("math", "round", "n", "n", 1, math.Round, true);

extension:RegisterFunction("math", "round", "n,n", "n", 1, math.Round, true);

extension:RegisterFunction("math", "sin", "n", "n", 1, math.sin, true);

extension:RegisterFunction("math", "sinh", "n", "n", 1, math.sinh, true);

extension:RegisterFunction("math", "sqrt", "n", "n", 1, math.sqrt, true);

extension:RegisterFunction("math", "tan", "n", "n", 1, math.tan, true);

extension:RegisterFunction("math", "tanh", "n", "n", 1, math.tanh, true);

extension:RegisterFunction("math", "timeFraction", "n,n,n", "n", 1, math.TimeFraction, true);

extension:RegisterFunction("math", "truncate", "n", "n", 1, math.truncate);

extension:RegisterFunction("math", "truncate", "n,n", "n", 1, math.truncate);



--[[for i = 2, 10 do
	local args = string.rep("n", i, ",");

	extension:RegisterFunction("math", "max", args, "n", 1, math.max, true);

	extension:RegisterFunction("math", "min", args, "n", 1, math.min, true);
end]]

extension:RegisterFunction("math", "max", "n,...", "n", 1, math.max, true);

extension:RegisterFunction("math", "min", "n,...", "n", 1, math.min, true);

extension:EnableExtension();
