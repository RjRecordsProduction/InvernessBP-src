local IMSDKSystem = {timer = nil}
function IMSDKSystem.StartIMSDKTimer(IMSDKOperType)
  log(bWriteLog and "StartIMSDKTimer IMSDKOperType\239\188\154" .. tostring(IMSDKOperType))
  logic_connection_waiting:Show(1)
  local time_ticker = require("common.time_ticker")
  if IMSDKSystem.timer ~= nil then
    log(bWriteLog and "StartIMSDKTimer StopIMSDKTimer RemoveTimer IMSDKSystem.timer")
    time_ticker.RemoveTimer(IMSDKSystem.timer)
    IMSDKSystem.timer = nil
  end
  if IMSDKOperType == 1 then
    local Login_UIBP = UIManager.GetUI(UIManager.UI_Config.Login_UIBP)
    if Login_UIBP then
      Login_UIBP:HideLoginButtons()
    else
      log(bWriteLog and "Login_UIBP.HideButtonsWhenAutoLogin, version_update is not showing?")
    end
    IMSDKSystem.timer = time_ticker.AddTimerOnce(16, IMSDKSystem.IMSDKLoginTimeOut)
  elseif IMSDKOperType == 2 then
    IMSDKSystem.timer = time_ticker.AddTimerOnce(16, IMSDKSystem.IMSDKLoginTimeOut)
  elseif IMSDKOperType == 3 then
    IMSDKSystem.timer = time_ticker.AddTimerOnce(16, IMSDKSystem.IMSDKBindTimeOut)
  elseif BP_Share_Platform == BP_ENUM_PLAYFORM_BGBG then
    IMSDKSystem.timer = time_ticker.AddTimerOnce(60, IMSDKSystem.IMSDKShareTimeOut)
  else
    IMSDKSystem.timer = time_ticker.AddTimerOnce(6, IMSDKSystem.IMSDKShareTimeOut)
  end
end
function IMSDKSystem.StopIMSDKTimer()
  log(bWriteLog and "StopIMSDKTimer")
  logic_connection_waiting:Hide(1)
  if IMSDKSystem.timer ~= nil then
    log(bWriteLog and "StopIMSDKTimer RemoveTimer IMSDKSystem.timer")
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(IMSDKSystem.timer)
    IMSDKSystem.timer = nil
  end
end
function IMSDKSystem.IMSDKLoginTimeOut()
  log(bWriteLog and "IMSDKSystem.IMSDKLoginTimeOut")
  Client.ClearChannelID(NetInterface)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:ShowButtonsAfterLoginFailed()
  local HDmpveChannelID = Client.GetLoginChannel(NetInterface)
  if HDmpveChannelID == 40 then
    log(bWriteLog and "IMSDKSystem.IMSDKLoginTimeOut 40")
    local logic_login_event = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_login_event)
    logic_login_event:ShowLoginFailNotice(LocUtil.GetLocalizeResStr(4188))
  end
end
function IMSDKSystem.IMSDKBindTimeOut()
  log(bWriteLog and "IMSDKSystem.IMSDKBindTimeOut")
  logic_connection_waiting:Hide(1)
  local SettingSystem = require("client.logic.setting.logic_setting")
  if SettingSystem.NBindChannel == 2 then
    ShowNotice(4048)
  end
end
function IMSDKSystem.IMSDKShareTimeOut()
  log(bWriteLog and "IMSDKShareTimeOut")
  logic_connection_waiting:Hide(1)
end
function IMSDKSystem.SetBindBySDK(bindViaSdk)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsCEVersion() then
    bindViaSdk = false
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local bindViaSdkStr = bindViaSdk and "true" or "false"
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local platName = Client.GetDevicePlatformName()
  if platName == DevicePlatformNameMacros.IOS then
    bindViaSdkStr = bindViaSdk and "1" or "0"
  end
  local configTableToUpdate = {IMSDK_BIND_MODIFY_API_BY_SDK = bindViaSdkStr}
  IMSDKHelperInstance:SetMSDKConfig(configTableToUpdate, false)
end
return IMSDKSystem