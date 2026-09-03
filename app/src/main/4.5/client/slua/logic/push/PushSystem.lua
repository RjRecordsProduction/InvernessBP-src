local PushSystem = {
  isLaunchedByNotification = nil,
  isLaunchedByFCM = nil,
  FCMExtraDataString = nil,
  FCMNotificationID = nil,
  LocalNotificationID = nil,
  isLaunchedByLocal = nil
}
function PushSystem:OnInitialize()
  PushSystem.__super.OnInitialize(self)
  self:UpdateFirebaseConsent()
end
function PushSystem:OnLogOut()
  self:ResetLaunchedByNotification()
end
function PushSystem:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self:ResetLaunchedByNotification()
  end
end
function PushSystem:CheckNotificationJumpTo(bFromHome)
  local curStatus = GameStatus.GetGameStatus()
  if curStatus ~= GameStatus.Lobby and not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "PushSystem:JumpByNotification return of curStatus = " .. tostring(curStatus))
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "PushSystem:JumpByNotification return of IsInXMission = true")
    self:ResetLaunchedByNotification()
    return
  end
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  local bEnterMainCityLoading = Lobby_Main_City_Enter.bEnterMainCityLoading
  log(bWriteLog and "PushSystem:JumpByNotification bEnterMainCityLoading = " .. tostring(bEnterMainCityLoading))
  if bEnterMainCityLoading then
    log(bWriteLog and "PushSystem:JumpByNotification return of EnterMainCityLoading")
    self:ResetLaunchedByNotification()
    return
  end
  if bFromHome then
    self:ResetLaunchedByNotification(true)
  end
  if not self:IsLaunchedByNotification() then
    log(bWriteLog and "PushSystem:CheckNotificationJumpTo return of IsLaunchedByNotification = false")
    return
  end
  self:_JumpByNotification()
end
function PushSystem:_JumpByNotification()
  log(bWriteLog and "PushSystem:_JumpByNotification isLaunchedByFCM=" .. tostring(self.isLaunchedByFCM) .. ",FCMExtraDataString=" .. tostring(self.FCMExtraDataString) .. ", isLaunchedByLocal=" .. tostring(self.isLaunchedByLocal) .. ",LocalNotificationID=" .. tostring(self.LocalNotificationID))
  if self.isLaunchedByFCM and self.FCMExtraDataString and self.FCMExtraDataString ~= "" then
    self:AddTimerOnce(0.3, function()
      local Logic_Offline_Invite = require("client.slua.logic.teamup.logic_offline_invite")
      local bOfflineAwake = Logic_Offline_Invite.IsOfflineInviteAwake(self.FCMExtraDataString)
      if bOfflineAwake then
        log(bWriteLog and "PushSystem:_JumpByNotification JoinInFcmTeam")
        Logic_Offline_Invite.JoinInFcmTeam(self.FCMExtraDataString)
      else
        local StringUtil = require("common.string_util")
        local params = StringUtil.ParseURLParams(self.FCMExtraDataString)
        local url = params.link_url
        if url and url ~= "" then
          GlobalData.JumpUrl(url)
        end
      end
      self:ClearAndReportNotification(true)
    end)
  end
  if self.isLaunchedByLocal and self.LocalNotificationID and self.LocalNotificationID ~= "" then
    local logic_community = require("client.slua.logic.community.logic_community")
    if logic_community.IsLaunchedByClubMatchNotification(self.LocalNotificationID) then
      log(bWriteLog and "PushSystem:_JumpByNotification IsLaunchedByClubMatchNotification")
      self:AddTimerOnce(0.3, function()
        local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
        if Lobby_Main_City_Enter.bEnterMainCityLoading then
          log(bWriteLog and "PushSystem:_JumpByNotification 1")
          self:ClearAndReportNotification(false)
        else
          log(bWriteLog and "PushSystem:_JumpByNotification 2")
          UIManager.ForceBackToLobby()
          GlobalData.JumpUrl("game://?module=" .. BP_ENUM_MODULE_ESPORT)
          self:ClearAndReportNotification(true)
        end
      end)
    else
      local LocalPushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LocalPushSystem)
      LocalPushSystem:GetLocalPushCfgReq(function()
        local cfg = LocalPushSystem:GetPushCfgByID(tonumber(self.LocalNotificationID))
        log(bWriteLog and "PushSystem:_JumpByNotification GetLocalPushCfgRsp")
        log_tree("PushSystem._JumpByNotification cfg:", cfg)
        if cfg and cfg.jump_url and cfg.jump_url ~= "" then
          self:AddTimerOnce(0.3, function()
            local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
            if Lobby_Main_City_Enter.bEnterMainCityLoading then
              log(bWriteLog and "PushSystem:_JumpByNotification 3")
              self:ClearAndReportNotification(false)
            else
              log(bWriteLog and "PushSystem:_JumpByNotification 4")
              UIManager.ForceBackToLobby()
              GlobalData.JumpUrl(cfg.jump_url)
              self:ClearAndReportNotification(true)
            end
          end)
        end
      end)
    end
  end
end
function PushSystem:IsLaunchedByNotification()
  if self.isLaunchedByNotification == nil then
    self.isLaunchedByFCM = false
    self.FCMExtraDataString = ""
    self.FCMNotificationID = ""
    local firebaseHelper = import("FirebaseHelper").GetInstance()
    local isAwakedByNotification = firebaseHelper:IsNotificationLaunchApp()
    log(bWriteLog and "PushSystem:IsLaunchedByNotificationNew isAwakedByNotification=" .. tostring(isAwakedByNotification))
    if isAwakedByNotification then
      self.FCMExtraDataString = firebaseHelper:GetNotificationLaunchAppExtraData("notification_content")
      self.FCMNotificationID = firebaseHelper:GetNotificationLaunchAppExtraData("notification_id")
      if nil ~= self.FCMExtraDataString and "" ~= self.FCMExtraDataString then
        log(bWriteLog and "PushSystem:IsLaunchedByNotificationNew FCMExtraDataString=" .. tostring(self.FCMExtraDataString) .. ", FCMNotificationID=" .. tostring(self.FCMNotificationID))
        self.isLaunchedByFCM = true
      end
      firebaseHelper:ConsumeNotificationLaunchApp()
    end
    self.isLaunchedByLocal = false
    self.LocalNotificationID = ""
    local isLaunchedByLocalNotification = Client.IsLaunchedByLocalNotification()
    log(bWriteLog and "PushSystem:IsLaunchedByNotificationNew IsLaunchedByLocalNotification=" .. tostring(isLaunchedByLocalNotification))
    if isLaunchedByLocalNotification then
      self.LocalNotificationID = Client.GetLaunchLocalNotificationID()
      if nil ~= self.LocalNotificationID and "" ~= self.LocalNotificationID then
        log(bWriteLog and "PushSystem:IsLaunchedByNotificationNew LocalNotificationID=" .. self.LocalNotificationID)
        self.isLaunchedByLocal = true
      end
      Client.ConsumeLocalNotificationLaunchApp()
    end
    self.isLaunchedByNotification = self.isLaunchedByFCM or self.isLaunchedByLocal
  end
  log(bWriteLog and "PushSystem:IsLaunchedByNotificationNew isLaunchedByNotification=" .. tostring(self.isLaunchedByNotification) .. ", isLaunchedByFCM=" .. tostring(self.isLaunchedByFCM) .. ", isLaunchedByLocal=" .. tostring(self.isLaunchedByLocal))
  return self.isLaunchedByNotification
end
function PushSystem:ResetLaunchedByNotification(bReInit)
  if bReInit then
    self.isLaunchedByNotification = nil
  else
    self.isLaunchedByNotification = false
  end
end
function PushSystem:ClearAndReportNotification(bReport)
  log(bWriteLog and "PushSystem:ClearAndReportNotification isLaunchedByFCM=" .. tostring(self.isLaunchedByFCM) .. ",isLaunchedByLocal=" .. tostring(self.isLaunchedByLocal) .. " bReport = " .. tostring(bReport))
  if self.isLaunchedByFCM then
    Client.ClearNotifications()
    if bReport then
      local eventParam = {}
      table.insert(eventParam, self.FCMNotificationID)
      Client.GEMReportSubEvent(GameFrontendHUD, "FCMNotification", "isAwakedByNotification", eventParam)
      local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
      BasicDataTLogReport:ReportImmediate(TLogEventDefine.FCMNotification, 1, tostring(self.FCMNotificationID))
    end
  end
  if self.isLaunchedByLocal then
    Client.ClearNotifications()
    if bReport then
      local eventParam = {}
      table.insert(eventParam, self.LocalNotificationID)
      Client.GEMReportSubEvent(GameFrontendHUD, "FCMNotification", "LaunchedByLocalNotification", eventParam)
      log(bWriteLog and "PushSystem:ClearAndReportNotification notificationID: " .. self.LocalNotificationID)
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.FCMNotification, 2, tostring(self.LocalNotificationID))
    end
  end
  self:ResetLaunchedByNotification()
end
function PushSystem:OnApplicationEnterBackground()
  local LocalPushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LocalPushSystem)
  LocalPushSystem:OnApplicationEnterBackground()
  local FCMPushSystem = require("client.slua.logic.push.logic_fcm_push")
  FCMPushSystem.OnApplicationEnterBackground()
end
function PushSystem:OnApplicationEnterForeground()
  local LocalPushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LocalPushSystem)
  LocalPushSystem:OnApplicationEnterForeground()
  local FCMPushSystem = require("client.slua.logic.push.logic_fcm_push")
  FCMPushSystem.OnApplicationEnterForeground()
end
function PushSystem:UpdateFirebaseConsent()
  local configDefaultValue = 256
  local FirebaseConsentSwitcher = HDmpveRemote.HDmpveRemoteConfigGetInt("FirebaseConsentSwitcher", configDefaultValue)
  if FirebaseConsentSwitcher ~= configDefaultValue then
    local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
    local SW_AD_STORAGE = 1
    local SW_ANALYTICS_STORAGE = 2
    local SW_AD_USER_DATA = 4
    local SW_AD_PERSONALIZATION = 8
    local ConsentTable = {}
    ConsentTable[SDKMacros.FirebaseMacro.ConsentType.AD_STORAGE] = SDKMacros.FirebaseMacro.ConsentValue.GRANTED
    ConsentTable[SDKMacros.FirebaseMacro.ConsentType.ANALYTICS_STORAGE] = SDKMacros.FirebaseMacro.ConsentValue.GRANTED
    ConsentTable[SDKMacros.FirebaseMacro.ConsentType.AD_USER_DATA] = SDKMacros.FirebaseMacro.ConsentValue.GRANTED
    ConsentTable[SDKMacros.FirebaseMacro.ConsentType.AD_PERSONALIZATION] = SDKMacros.FirebaseMacro.ConsentValue.GRANTED
    if FirebaseConsentSwitcher & SW_AD_STORAGE == 0 then
      ConsentTable[SDKMacros.FirebaseMacro.ConsentType.AD_STORAGE] = SDKMacros.FirebaseMacro.ConsentValue.DENIED
    end
    if FirebaseConsentSwitcher & SW_ANALYTICS_STORAGE == 0 then
      ConsentTable[SDKMacros.FirebaseMacro.ConsentType.ANALYTICS_STORAGE] = SDKMacros.FirebaseMacro.ConsentValue.DENIED
    end
    if FirebaseConsentSwitcher & SW_AD_USER_DATA == 0 then
      ConsentTable[SDKMacros.FirebaseMacro.ConsentType.AD_USER_DATA] = SDKMacros.FirebaseMacro.ConsentValue.DENIED
    end
    if FirebaseConsentSwitcher & SW_AD_PERSONALIZATION == 0 then
      ConsentTable[SDKMacros.FirebaseMacro.ConsentType.AD_PERSONALIZATION] = SDKMacros.FirebaseMacro.ConsentValue.DENIED
    end
    log_tree(bWriteLog and "PushSystem:UpdateFirebaseConsent ConsentTable", ConsentTable)
    local firebaseHelper = import("FirebaseHelper").GetInstance()
    firebaseHelper:SetConsent(ConsentTable)
  else
    log(bWriteLog and "PushSystem:UpdateFirebaseConsent is not change")
  end
  local AdjustEEASwitcherDefaultValue = 6
  local AdjustEEASwitcher = HDmpveRemote.HDmpveRemoteConfigGetInt("AdjustEEASwitcher", AdjustEEASwitcherDefaultValue)
  local SW_ADJUST_EEA = 1
  local SW_ADJUST_PERSONALIZATION = 2
  local SW_ADJUST_USER_DATA = 4
  local adjustIsEEA = 0 < AdjustEEASwitcher & SW_ADJUST_EEA and 1 or 0
  local adjustAdPersonalization = 0 < AdjustEEASwitcher & SW_ADJUST_PERSONALIZATION and 1 or 0
  local adjustAdUserData = 0 < AdjustEEASwitcher & SW_ADJUST_USER_DATA and 1 or 0
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  log(bWriteLog and string.format("IMSDKHelperInstance:SetupAdjustDMA: %d, %d, %d", adjustIsEEA, adjustAdPersonalization, adjustAdUserData))
  IMSDKHelperInstance:SetupAdjustDMA(adjustIsEEA, adjustAdPersonalization, adjustAdUserData)
end
function PushSystem:IsLaunchedByFCM()
  return self.isLaunchedByFCM
end
function PushSystem:IsLaunchedByLocal()
  return self.isLaunchedByLocal
end
function PushSystem:GetNotificationID()
  if self.isLaunchedByFCM then
    return self.FCMNotificationID
  elseif self.isLaunchedByLocal then
    return self.LocalNotificationID
  else
    return ""
  end
end
function PushSystem:GetFCMId()
  if self.isLaunchedByFCM and self.FCMNotificationID then
    return self.FCMNotificationID
  end
  return 0
end
function PushSystem:GetFCMMsgType()
  if self.isLaunchedByFCM and self.FCMExtraDataString then
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(self.FCMExtraDataString)
    return params and params.msg_type or 0
  end
  return 0
end
function PushSystem:GetLocalPushId()
  if self.isLaunchedByLocal and self.LocalNotificationID then
    local LocalPushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LocalPushSystem)
    return LocalPushSystem:CalculatePushId(self.LocalNotificationID)
  end
  return 0
end
function PushSystem:GetLocalPushType()
  if self.isLaunchedByLocal and self.LocalNotificationID then
    local LocalPushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LocalPushSystem)
    return LocalPushSystem:CalculatePushType(self.LocalNotificationID)
  end
  return 0
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CPushSystem = class(CModuleBase, nil, PushSystem)
return CPushSystem