local LogFilter = {bLogTreeEnable = false}
_G.bWriteLog = false
function LogFilter.SetWriteLog(bEnable)
  _G.bWriteLog = bEnable
end
function LogFilter.SetLogTreeEnable(bEnable)
  LogFilter.bLogTreeEnable = bEnable
end
if Client and not Client.IsDevelopment() then
  LogFilter.SetWriteLog(false)
else
  LogFilter.SetWriteLog(true)
end
if _G.IsEditor then
  LogFilter.SetLogTreeEnable(false)
else
  LogFilter.SetLogTreeEnable(true)
end
if _G.IsEnableMockGameSvr then
  LogFilter.SetLogTreeEnable(true)
end
return LogFilter