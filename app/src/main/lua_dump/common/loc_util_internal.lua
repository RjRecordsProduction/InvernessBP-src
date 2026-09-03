local LocUtil_Internal = {}
function LocUtil_Internal.FormatStrByStr(strFormat, ...)
  if select("#", ...) <= 0 then
    return strFormat
  end
  local IsNewStyle = string.find(strFormat, "{0}")
  local res = strFormat
  if IsNewStyle then
    local arg = table.pack(...)
    local IntlHelper = import("IntlHelper")
    res = IntlHelper.FormatLocalizeStrByStr(strFormat, arg)
  else
    res = string.format(strFormat, ...)
  end
  return res
end
function LocUtil_Internal.ReformatIndex(strFormat)
  local index = 0
  return string.gsub(strFormat, "{%d+}", function(args)
    args = string.format("{%d}", index)
    index = index + 1
    return args
  end)
end
return LocUtil_Internal