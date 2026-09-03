local IMSDKLoginFlowChcker = {bRegistEvents = false}
function IMSDKLoginFlowChcker:RegistEvents()
  log(bWriteLog and "IMSDKLoginFlowChcker:RegistEvents")
  if self:IsLoginFolwChekerEnable() == false then
    log(bWriteLog and "IMSDKLoginFlowChcker:RegistEvents not enable")
    return
  end
  local gameInstance = slua.getGameInstance()
  gameInstance:ExecuteCMD("r.SkipMSDKLoginCommandStat", 1)
  if IMSDKLoginFlowChcker.bRegistEvents then
    log(bWriteLog and "IMSDKLoginFlowChcker:RegistEvents already")
    return
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  IMSDKHelperInstance.OnLoginCommandDelegate:Clear()
  IMSDKHelperInstance.OnLoginCommandDelegate:Add(function(command, extra)
    log(bWriteLog and "IMSDKLoginFlowChcker.OnLoginCommandDelegate: " .. command)
    self:OnLoginCommand(command, extra)
  end)
  IMSDKLoginFlowChcker.bRegistEvents = true
end
function IMSDKLoginFlowChcker:IsLoginFolwChekerEnable()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local platName = Client.GetDevicePlatformName()
  if platName == DevicePlatformNameMacros.Android then
    log(bWriteLog and "IMSDKLoginFlowChcker:IsLoginFolwChekerEnable android")
    return false
  end
  local DeviceType = Client.GetPhoneType()
  if not string.find(string.lower(DeviceType), "ipad") then
    log(bWriteLog and "IMSDKLoginFlowChcker:IsLoginFolwChekerEnable not ipad")
    return false
  end
  local enableLoginFlowChecker = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableLoginFlowChecker", true)
  if enableLoginFlowChecker == false then
    log(bWriteLog and "IMSDKLoginFlowChcker:IsLoginFolwChekerEnable false")
    return false
  end
  return true
end
function IMSDKLoginFlowChcker:OnLoginCommand(command, extra)
  log(bWriteLog and "IMSDKLoginFlowChcker.OnLoginCommand: " .. command .. ", " .. extra)
  if (command == "1" or command == "2") and GameStatus.GetGameStatus() ~= GameStatus.Login then
    local data = string.format("%s+%s", command, extra)
    self:ReportLoginCheckEvent(data)
  end
  if (command == "3" or command == "4") and not GameStatus.IsInLobbyOrMainCity() then
    local data = string.format("%s+%s", command, extra)
    self:ReportLoginCheckEvent(data)
  end
end
function IMSDKLoginFlowChcker:ReportLoginCheckEvent(data)
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local ParamTable = {}
  table.insert(ParamTable, "1")
  table.insert(ParamTable, IMSDKHelperInstance:getOpenID())
  table.insert(ParamTable, data)
  Client.GEMReportSubEvent(GameFrontendHUD, "GRomeLinkEvent", "LoginCommandFlow", ParamTable)
end
return IMSDKLoginFlowChcker