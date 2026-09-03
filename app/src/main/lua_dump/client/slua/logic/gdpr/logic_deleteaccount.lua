local LogicDeleteAccount = {}
local IOSDeleteHandler = require("client.network.Protocol.IOSDeleteHandler")
local AOSDeleteHandler = require("client.network.Protocol.AOSDeleteHandler")
local NDeleteTime = 10
function LogicDeleteAccount.CanShowDeleteAccount()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    log(bWriteLog and "  : DevicePlatformNameMacros.IOS")
    if LobbySystem.CheckOpen(BP_ENUM_SWITCH_IOS_DELETE) then
      log(bWriteLog and "  : BP_ENUM_SWITCH_IOS_DELETE")
      return true
    end
  end
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    log(bWriteLog and "[HZA]: DevicePlatformNameMacros.Android")
    if LobbySystem.CheckOpen(BP_ENUM_SWITCH_AOS_DELETE) then
      log(bWriteLog and "[HZA]: BP_ENUM_SWITCH_AOS_DELETE open")
      return true
    end
  end
  if not PublishRegionMacros.IsJapanOrKorea() then
    local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
    if GdprSystem.IsGdpr() then
      return true
    end
  elseif LogicDeleteAccount.KRCanDeleteAccount() then
    return true
  end
  return false
end
function LogicDeleteAccount.AskForDeleteAccount()
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsQRCodeLogin() then
    log(bWriteLog and "LogicDeleteAccount.AskForDeleteAccount IsQRCodeLogin")
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  if GdprSystem.IsGdpr() or LogicDeleteAccount.KRCanDeleteAccount() then
    GdprSystem.AskForDeleteAccount()
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    LogicDeleteAccount.AOSAskForDeleteAccount()
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    LogicDeleteAccount.IOSAskForDeleteAccount()
  end
end
function LogicDeleteAccount.KRCanDeleteAccount()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  local result = PublishRegionMacros.IsJapanOrKorea() and SettingUtil.KRJPDelAccountSwitch and SettingUtil.KRJPDelAccountLeftTime >= 0
  log(bWriteLog and "  :SettingUtil.KRJPDelAccountLeftTime" .. tostring(SettingUtil.KRJPDelAccountLeftTime))
  return result
end
function LogicDeleteAccount.IOSAskForDeleteAccount()
  log(bWriteLog and "  : LogicDeleteAccount.IOSAskForDeleteAccount")
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strDelTips = LocUtil.GetLocalizeResStr(4379)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local timeSecond = 604800
  if login_module.commonSwitch.IOSDelAccountTime ~= nil then
    timeSecond = login_module.commonSwitch.IOSDelAccountTime
    log(bWriteLog and "  LoginSystem.commonSwitch.IOSDelAccountTime, timeSecond = " .. timeSecond)
  end
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.GLOBAL and strRegion ~= PublishRegionMacros.FIT then
    local day = timeSecond / 86400
    strDelTips = LocUtil.LocalizeResFormat(4707, math.floor(day))
  end
  GdprSystem.ShowSettingNoticeBox(1, LocUtil.GetLocalizeResStr(101001), strDelTips, LocUtil.GetLocalizeResStr(4113), LocUtil.GetLocalizeResStr(4112), LogicDeleteAccount.IOSShowConfirmDelete, nil, nil, NDeleteTime)
end
function LogicDeleteAccount.IOSCancelDelete()
  log(bWriteLog and "  : IOSCancelDelete")
  if DataMgr.roleData.ios_acc_del_ts then
    IOSDeleteHandler.send_ios_cancle_del_account_req()
  end
end
function LogicDeleteAccount.IOSShowConfirmDelete()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local timeSecond = 604800
  if login_module.commonSwitch.IOSDelAccountTime ~= nil then
    timeSecond = login_module.commonSwitch.IOSDelAccountTime
    log(bWriteLog and "  SettingGDPRUI:IOSDelAccountTime, timeSecond = " .. timeSecond)
  end
  local TimeUtil = require("client.common.time_util")
  local timeStr = TimeUtil.FormatCountDownTime_D_or_HMS(timeSecond, 1)
  local msg = LocUtil.LocalizeResFormat(4487, timeStr) .. "\n" .. LocUtil.GetLocalizeResStr(42638)
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  GdprSystem.ShowSettingNoticeBox(0, LocUtil.GetLocalizeResStr(101001), msg, LocUtil.GetLocalizeResStr(4114), LocUtil.GetLocalizeResStr(4112), LogicDeleteAccount.DeleteAccount, nil)
end
function LogicDeleteAccount.DeleteAccount()
  log(bWriteLog and "  : LogicDeleteAccount.DeleteAccount")
  if LobbySystem.isInLobby == true and LobbySystem.isCanDeleteOp == true then
    IOSDeleteHandler.send_ios_del_account_req()
  end
end
function LogicDeleteAccount.HandleError(err)
  if err ~= 0 then
    ShowNotice(err)
    return true
  end
  return false
end
function LogicDeleteAccount.DeleteAccountRsp(err)
  if LogicDeleteAccount.HandleError(err) then
    return
  end
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  GdprSystem.CloseAllGDPRUI()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:sendLogout()
  logic_connection_waiting:Hide(1)
  login_module:backLogin()
end
function LogicDeleteAccount.CancelDeleteAccountRsp(err)
  if LogicDeleteAccount.HandleError(err) then
    return
  end
  DataMgr.roleData.ios_acc_del_ts = 0
end
function LogicDeleteAccount.IsIosDeleting()
  local TimeUtil = require("client.common.time_util")
  local leftTime = DataMgr.roleData.ios_acc_del_ts - TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "  :DataMgr.roleData.ios_acc_del_ts" .. tostring(DataMgr.roleData.ios_acc_del_ts))
  log(bWriteLog and "  :TimeUtil.GetServerTimeInSec()" .. tostring(TimeUtil.GetServerTimeInSec()))
  return 0 < leftTime
end
function LogicDeleteAccount.AOSAskForDeleteAccount()
  log(bWriteLog and "  : LogicDeleteAccount.AOSAskForDeleteAccount")
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  local strDelTips = LocUtil.GetLocalizeResStr(4379)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local timeSecond = 604800
  if login_module.commonSwitch.AOSDelAccountTime ~= nil then
    timeSecond = login_module.commonSwitch.AOSDelAccountTime
    log(bWriteLog and "  LoginSystem.commonSwitch.AOSDelAccountTime, timeSecond = " .. timeSecond)
  end
  local day = timeSecond / 86400
  strDelTips = LocUtil.LocalizeResFormat(4707, math.floor(day))
  GdprSystem.ShowSettingNoticeBox(1, LocUtil.GetLocalizeResStr(101001), strDelTips, LocUtil.GetLocalizeResStr(4113), LocUtil.GetLocalizeResStr(4112), LogicDeleteAccount.AOSShowConfirmDelete, nil, nil, NDeleteTime)
end
function LogicDeleteAccount.AOSCancelDelete()
  log(bWriteLog and "  : AOSCancelDelete")
  if DataMgr.roleData.aos_acc_del_ts then
    AOSDeleteHandler.send_aos_cancle_del_account_req()
  end
end
function LogicDeleteAccount.AOSShowConfirmDelete()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local timeSecond = 604800
  if login_module.commonSwitch.AOSDelAccountTime ~= nil then
    timeSecond = login_module.commonSwitch.AOSDelAccountTime
    log(bWriteLog and "  SettingGDPRUI:AOSDelAccountTime, timeSecond = " .. timeSecond)
  end
  local TimeUtil = require("client.common.time_util")
  local timeStr = TimeUtil.FormatCountDownTime_D_or_HMS(timeSecond, 1)
  local msg = LocUtil.LocalizeResFormat(4487, timeStr) .. "\n" .. LocUtil.GetLocalizeResStr(43135)
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  GdprSystem.ShowSettingNoticeBox(0, LocUtil.GetLocalizeResStr(101001), msg, LocUtil.GetLocalizeResStr(4114), LocUtil.GetLocalizeResStr(4112), LogicDeleteAccount.AOSDeleteAccount, nil)
end
function LogicDeleteAccount.AOSDeleteAccount()
  log(bWriteLog and "  : LogicDeleteAccount.AOSDeleteAccount")
  if LobbySystem.isInLobby == true and LobbySystem.isCanDeleteOp == true then
    AOSDeleteHandler.send_aos_del_account_req()
  end
end
function LogicDeleteAccount.AOSDeleteAccountRsp(err)
  if LogicDeleteAccount.HandleError(err) then
    return
  end
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  GdprSystem.CloseAllGDPRUI()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:sendLogout()
  logic_connection_waiting:Hide(1)
  login_module:backLogin()
end
function LogicDeleteAccount.AOSCancelDeleteAccountRsp(err)
  if LogicDeleteAccount.HandleError(err) then
    return
  end
  DataMgr.roleData.aos_acc_del_ts = 0
end
function LogicDeleteAccount.IsAosDeleting()
  local TimeUtil = require("client.common.time_util")
  local leftTime = DataMgr.roleData.aos_acc_del_ts - TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "  :DataMgr.roleData.aos_acc_del_ts" .. tostring(DataMgr.roleData.aos_acc_del_ts))
  log(bWriteLog and "  :TimeUtil.GetServerTimeInSec()" .. tostring(TimeUtil.GetServerTimeInSec()))
  return 0 < leftTime
end
return LogicDeleteAccount