local common = {}
local slua_CallCombinationArgs = slua.CallCombinationArgs
function common.CallCombinationArgs(func, args, ...)
  local argsCount = args.n
  if argsCount == 0 then
    return func(...)
  elseif argsCount == 1 then
    return func(args[1], ...)
  else
    return slua_CallCombinationArgs(func, args, ...)
  end
end
return common