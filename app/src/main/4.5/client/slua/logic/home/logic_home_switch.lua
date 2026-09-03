local logic_home_switch = {
  lobbyRightMode = ENUM_LobbyRightMode.None,
  isShowLobbyRightMode = false,
  rightModeNewbieData = {},
  Enum_RightModeNewbieGuideKey = {
    UnSet = 1,
    FirstSetMode = 2,
    FirstSetXmission = 4,
    InvalidModel = 8,
    FirstInXmission = 22
  }
}
function logic_home_switch:InitRightModeData()
  log(bWriteLog and "logic_home_switch:InitRightModeData.")
  self.isShowLobbyRightMode = FuncUtil.GetHDmpveRemoteConfig("GEnableLobbyRightScreen", true)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local bGuest = IMSDKHelperInstance:IsEqualCurLoginPlatform(ShareSource.Guest)
  ClientSendBAReport(TLogEventDefine.RightScreenEnable, 0, tostring(self.isShowLobbyRightMode))
  self:AutoSwitchRightMode()
  self:UpdateLobbyRightMode()
end
function logic_home_switch:AutoSwitchRightMode()
  local LogicUGCHall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  self.enableAutoSwitchRightMode = LogicUGCHall:CheckIsOpen()
  local convience_mode_settings = DataMgr.roleData and DataMgr.roleData.convience_mode_settings
  convience_mode_settings = convience_mode_settings or {}
  local DataMgrHandler = require("client.network.Protocol.DataMgrHandler")
  if self.enableAutoSwitchRightMode then
    if convience_mode_settings.rightMode == ENUM_LobbyRightMode.UGCHall then
      return
    end
    if convience_mode_settings.rightMode == ENUM_LobbyRightMode.XMission then
      return
    end
    convience_mode_settings.oldRightMode = convience_mode_settings.rightMode or ENUM_LobbyRightMode.None
    convience_mode_settings.rightMode = ENUM_LobbyRightMode.UGCHall
    log(bWriteLog and string.format("logic_home_switch:AutoSwitchRightMode switch rightMode to wow from %s", convience_mode_settings.oldRightMode))
    DataMgrHandler.send_save_convenient_mode_req(convience_mode_settings)
  else
    local changed = false
    if convience_mode_settings.oldRightMode then
      convience_mode_settings.rightMode = convience_mode_settings.oldRightMode
      convience_mode_settings.oldRightMode = nil
      changed = true
    end
    if convience_mode_settings.rightMode == ENUM_LobbyRightMode.UGCHall then
      convience_mode_settings.rightMode = ENUM_LobbyRightMode.None
      changed = true
    end
    if changed then
      log(bWriteLog and string.format("logic_home_switch:AutoSwitchRightMode switch rightMode back to %s", convience_mode_settings.rightMode))
      DataMgrHandler.send_save_convenient_mode_req(convience_mode_settings)
    end
  end
end
function logic_home_switch:UpdateLobbyRightMode()
  if self.isShowLobbyRightMode then
    local LobbyAssetPreloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LobbyAssetPreloader)
    LobbyAssetPreloader:PreloadLobbyRightAsset()
    local convience_mode_settings = DataMgr.roleData and DataMgr.roleData.convience_mode_settings
    if convience_mode_settings == nil or convience_mode_settings.rightMode == nil then
      self.lobbyRightMode = ENUM_LobbyRightMode.None
    else
      self.lobbyRightMode = convience_mode_settings.rightMode
    end
    local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
    if not LogicPufferBundle.IsFitLobbyResDownloaded() then
      self.lobbyRightMode = ENUM_LobbyRightMode.UGCHall
    end
  end
  self.rightModeNewbieData = {}
  log(bWriteLog and "logic_home_switch:UpdateLobbyRightMode. isShowLobbyRightMode = " .. tostring(self.isShowLobbyRightMode))
  log(bWriteLog and "logic_home_switch:UpdateLobbyRightMode. lobbyRightMode = " .. tostring(self.lobbyRightMode))
end
function logic_home_switch:SetRightModeNewbie(key, start)
  self.rightModeNewbieData[key] = start
end
function logic_home_switch:IsInRightModeNewbie(key)
  return self.rightModeNewbieData[key] == true
end
function logic_home_switch:UpdateRightModeNewbie(activeKey)
  if self:IsInRightModeNewbie(activeKey) then
    log(bWriteLog and string.format("logic_home_switch:UpdateRightModeNewbie. activeKey=%s", tostring(activeKey)))
    self:HideLobbySwitchNewbieUI()
    self:SetRightModeNewbie(activeKey, false)
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_RIGHT_MODE, activeKey, 1)
  end
end
function logic_home_switch:OnSwitchToPageStart(_, _, toPage)
  log(bWriteLog and "logic_home_switch:OnSwitchToPageStart toPage = " .. toPage)
  local LobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  local match_new_entry = LobbyMain:GetChildUI(UIManager.UI_Config.match_new_entry)
  local isHomeSwitchOpen = self:CheckHomeSwitchOpen()
  local entryVisible = true
  if toPage == ENUM_LobbyPageType.Mid then
    entryVisible = true
  elseif isHomeSwitchOpen and toPage == ENUM_LobbyPageType.Left then
    entryVisible = not isHomeSwitchOpen
  elseif toPage == ENUM_LobbyPageType.Right then
    self:UpdateRightModeNewbie(self.Enum_RightModeNewbieGuideKey.UnSet)
    entryVisible = false
  end
  if match_new_entry then
    if entryVisible then
      match_new_entry:SelfHitTestInvisible()
    else
      match_new_entry:Collapsed()
    end
  end
  if toPage ~= ENUM_LobbyPageType.Mid then
    self:HideLobbySwitchNewbieUI()
  end
end
function logic_home_switch:HideLobbySwitchNewbieUI()
  local Lobby_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  local Lobby_Main_Switch_UIBP = Lobby_Main_UIBP:GetChildUI(UIManager.UI_Config.Lobby_Main_Switch_UIBP)
  if Lobby_Main_Switch_UIBP then
    Lobby_Main_Switch_UIBP:HideNewbieUI()
  end
end
function logic_home_switch:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, self.OnSwitchToPageStart, self)
end
function logic_home_switch:CheckHomeSwitchOpen(isShowTips, isLobbyEntry)
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  if not isLobbyEntry and not LogicPufferBundle.IsFitLobbyResDownloaded() then
    log(bWriteLog and "logic_home_switch:CheckHomeSwitchOpen FitLobbyRes not downloaded")
    return false
  end
  if not DataMgr.roleData or not DataMgr.roleData.manor_switch then
    return false
  end
  log_tree(bWriteLog and "logic_home_switch:CheckHomeSwitchOpen manor_switch", DataMgr.roleData.manor_switch)
  local switchCode = DataMgr.roleData.manor_switch.open_code
  if switchCode ~= 0 and switchCode ~= 19810053 and switchCode ~= 100150049 and isShowTips then
    ShowNotice(switchCode)
  end
  return switchCode == 0 or switchCode == 19810053
end
function logic_home_switch:CheckHomeLimit(isShowTips)
  if not DataMgr.roleData or not DataMgr.roleData.manor_switch then
    return true
  end
  log_tree(bWriteLog and "logic_home_switch:CheckHomeLimit manor_switch", DataMgr.roleData.manor_switch)
  local lvLimit = DataMgr.roleData.manor_switch.open_level
  local isLimit = false
  local switchCode = DataMgr.roleData.manor_switch.open_code
  if switchCode == 100150049 then
    isLimit = true
    if isShowTips then
      ShowNotice(100150049)
    end
    return isLimit
  end
  if lvLimit > DataMgr.roleData.level then
    isLimit = true
  end
  if isLimit and isShowTips then
    ShowNotice(LocUtil.LocalizeResFormat(6573, lvLimit))
  end
  return isLimit
end
function logic_home_switch:CheckHomeRankSwitchOpen()
  return self:CheckHomeSwitchOpen() and LobbySystem.CheckOpen(BP_ENUM_MODULE_PLANPH_HOME_RANK)
end
function logic_home_switch:CheckHomeStoreSwitchOpen(isShowTips)
  local Test_Config = require("GameLua.Mod.SocialIsland.GamePlay.Config.Test_Config")
  if Test_Config.bOpenSimulate then
    return Test_Config.HomeStoreSwitchOpen
  end
  local ret = not self:CheckHomeLimit(isShowTips) and self:CheckHomeSwitchOpen(isShowTips) and LobbySystem.CheckOpen(BP_ENUM_MODULE_PLANPH_HOME_STORE)
  if ret then
    local version_util = require("client.common.version_util")
    local versionNum = version_util.GetCurVersionNumber()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if Client and Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE and versionNum <= 3400 then
      ret = false
    end
  end
  return ret
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_home_switch = class(CModuleBase, nil, logic_home_switch)
return Clogic_home_switch