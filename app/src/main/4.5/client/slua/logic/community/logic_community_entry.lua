local logic_community = require("client.slua.logic.community.logic_community_def")
function logic_community.GetShowEntry()
  local open = LobbySystem.roleData.shequn_button_switch
  log(bWriteLog and "logic_community.GetShowEntry open = " .. tostring(open))
  if open == nil or open == 0 then
    return false
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return false
  end
  return true
end
function logic_community.GetShowEntryRedDot()
  if logic_community.GetShowEntry() == false then
    return false
  end
  local bNewbie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_SOCIAL_LOBBY, 10)
  if bNewbie then
    return true
  end
  if logic_community.IsShowVersionUpdateRedDot() then
    log(bWriteLog and "[v_wllwu] logic_community.GetShowEntryRedDot return IsShowVersionUpdateRedDot ")
    return true
  end
  local CommunityHandler = require("client.network.Protocol.CommunityHandler")
  if CommunityHandler.bGetServerData == false then
    return false
  end
  if CommunityHandler.red_type ~= nil and (CommunityHandler.red_type == 0 or CommunityHandler.red_type == 106) then
    return false
  end
  return true
end
function logic_community.ClubCheckAgeGate(bShowAgeGatePopup)
  local check_switch = LobbySystem.roleData.shequn_agegate_switch
  local agegate_state = DataMgr.minor_cert_status
  local logic_compliance = require("client.slua.logic.gdpr.logic_compliance")
  local agegate_switch = logic_compliance.CanUseAgeGate()
  local logic_gdpr = require("client.slua.logic.gdpr.logic_gdpr")
  local gdpr_user_type = 1
  if DataMgr.roleData.eugdpr then
    gdpr_user_type = DataMgr.roleData.eugdpr.user_type
  else
    log(bWriteLog and "[janesjiang][Club] ClubCheckAgeGate eugdpr is nil")
  end
  log(bWriteLog and string.format("[janesjiang][Club] ClubCheckAgeGate shequn_agegate_switch = %s, agegate_switch = %s, agegate_state = %s, gdpr_user_type = %s", tostring(check_switch), tostring(agegate_switch), tostring(agegate_state), tostring(gdpr_user_type)))
  if check_switch == nil or check_switch == 0 then
    return true
  end
  if agegate_state == logic_compliance.Enum_Minor_Cert_Status.Finish then
    return true
  end
  if gdpr_user_type ~= 0 and logic_gdpr.IsEUGDPRUser(gdpr_user_type) and logic_gdpr.CanAccessClub(gdpr_user_type) then
    return true
  end
  if agegate_switch then
    if bShowAgeGatePopup then
      ShowNotice(37284)
      logic_compliance.bForceCert = false
      local gdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
      gdprSystem.ShowAgeGatePage()
    end
  elseif bShowAgeGatePopup then
    ShowNotice(34155)
  end
  return false
end
function logic_community.LuanchMeemoFunction(url, skipCheckAddWidget)
  if logic_community.ClubCheckAgeGate(true) == false then
    return false
  end
  log(bWriteLog and string.format("logic_community.LuanchMeemoFunction. url=%s, skipCheckAddWidget=%s", tostring(url), tostring(skipCheckAddWidget)))
  local bp_pluginBPLibrary = import("bp_pluginBPLibrary")
  local StringUtil = require("common.string_util")
  local platformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  log(bWriteLog and "logic_community.LuanchMeemoFunction. stringStart = " .. tostring(StringUtil.Starts(url, "/add_widget_guide")))
  log(bWriteLog and "logic_community.LuanchMeemoFunction. platformName == DevicePlatformNameMacros.Android = " .. tostring(platformName == DevicePlatformNameMacros.Android))
  log(bWriteLog and "logic_community.LuanchMeemoFunction. bp_pluginBPLibrary.requestInstallWidget = " .. tostring(bp_pluginBPLibrary.bp_pluginRequestInstallWidget))
  if not skipCheckAddWidget and StringUtil.Starts(url, "/add_widget_guide") then
    log(bWriteLog and "logic_community.LuanchMeemoFunction. requestInstallWidget")
    local params = StringUtil.ParseURLParams(url)
    if not params.skipCheckAddWidget then
      local game_scene = params.game_scene or ""
      local type = tostring(params.type)
      local ret = -1
      local installWidgetCalled = false
      if platformName == DevicePlatformNameMacros.Android and bp_pluginBPLibrary.bp_pluginRequestInstallWidget then
        local widgetType = 0
        if string.find(game_scene, "PK") then
          widgetType = 1
        elseif type == "1" then
          widgetType = 1
        elseif type == "3" then
          widgetType = 3
        elseif type == "4" then
          widgetType = 4
        end
        if game_scene == "HomePK" then
          widgetType = 2
        end
        local authInfo = "?" .. logic_community.GetRoleInfoUrlParam(game_scene, true) .. "&type=" .. tostring(widgetType) .. "&from_scene=1"
        log(bWriteLog and "logic_community.LuanchMeemoFunction. authInfo = " .. tostring(authInfo))
        ret = bp_pluginBPLibrary.bp_pluginRequestInstallWidget(widgetType, authInfo)
        log(bWriteLog and "logic_community.LuanchMeemoFunction. ret = " .. tostring(ret))
        installWidgetCalled = true
        if ret ~= -1 then
          logic_community.launchMeemoFunctionUrl = url
          if widgetType == 0 then
            logic_community.launchMeemoFunctionWidgetType = ActivityDesktopToolType.Friend
          elseif widgetType == 1 then
            logic_community.launchMeemoFunctionWidgetType = ActivityDesktopToolType.Popularity_PK
          elseif widgetType == 3 then
            logic_community.launchMeemoFunctionWidgetType = ActivityDesktopToolType.SeasonRecord
          elseif widgetType == 4 then
            logic_community.launchMeemoFunctionWidgetType = ActivityDesktopToolType.Commercial
          end
          local time_ticker = require("common.time_ticker")
          time_ticker.AddTimerOnce(4, function()
            log(bWriteLog and "logic_community.LuanchMeemoFunction. timer check")
            logic_community.CheckDesktopTools()
          end)
        end
      end
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      local TLogReasonStr = json.encode({
        game_scene = game_scene,
        type = type,
              })
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.OneKeyAddWidget, ret, TLogReasonStr)
      if installWidgetCalled then
        return true
      end
    else
      log(bWriteLog and "logic_community.LuanchMeemoFunction. param skip")
    end
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() ~= PublishRegionMacros.BLUEHOLE then
    local CommunityHandler = require("client.network.Protocol.CommunityHandler")
    if CommunityHandler then
      CommunityHandler.send_jump_to_club()
    end
  end
  bp_pluginBPLibrary.bp_pluginLaunchMeemoFunction(url)
  return true
end
function logic_community.CheckCanPass(uid)
  local info
  if uid == DataMgr.roleData.uid then
    info = DataMgr.roleData
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    info = logic_profile:GetLocalProfile(uid)
  end
  if info == nil then
    log(bWriteLog and "logic_community.CheckCanPass info == nil:" .. tostring(uid))
    return false
  end
  local shequn_gray_regions = LobbySystem.roleData.shequn_gray_regions
  if shequn_gray_regions == nil then
    log(bWriteLog and "logic_community.CheckCanPass shequn_gray_regions == nil:" .. tostring(uid))
    return false
  end
  local accountregion = FuncUtil.GetAccountRegionForBP()
  if accountregion == nil then
    log(bWriteLog and "logic_community.CheckCanPass accountregion == nil:" .. tostring(uid))
    return false
  end
  if shequn_gray_regions[accountregion] == nil then
    log(bWriteLog and "logic_community.CheckCanPass shequn_gray_regions[accountregion] == nil  accountregion:" .. tostring(accountregion) .. tostring(uid))
    return false
  end
  return true
end
function logic_community.CheckItemCanShare(itemid)
  local validItemType = false
  local iteminfo = CDataTable.GetTableData("Item", itemid)
  log(bWriteLog and "[janesjiang][Club] itemId " .. tostring(itemid))
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if iteminfo then
    local itemType = iteminfo.ItemType
    validItemType = ModelDisplayTypeHelper.IsWeapon(itemType) or itemType == 4 or itemType == 5 or itemType == 9
    log(bWriteLog and "[janesjiang][Club] ItemType " .. tostring(itemType))
  end
  return validItemType
end
function logic_community.OnLogin()
  log(bWriteLog and "logic_community.OnLogin ")
  local shequn_reddot = LobbySystem.roleData.shequn_reddot
  if shequn_reddot ~= nil then
    local CommunityHandler = require("client.network.Protocol.CommunityHandler")
    CommunityHandler.on_idip_notify_reddot_info(shequn_reddot)
  end
  local shequn_gray_regions = LobbySystem.roleData.shequn_gray_regions
  if shequn_gray_regions then
    log_tree("shequn_gray_regions = ", shequn_gray_regions)
  end
end
function logic_community.OnQuitCommunityH5(eventType, eventID, vars)
  log(bWriteLog and "logic_community.OnQuitCommunityH5 eventType:" .. tostring(eventType) .. " eventID:" .. tostring(eventID))
  logic_community.ChangeLobbyBGMForIOSOnly(true)
  local UIBP = UIManager.GetUI(UIManager.UI_Config.Social_Person_Space_UIBP)
  if UIBP and UIBP:IsShow() then
    UIManager.AndroidBackToUI(UIManager.UI_Config.Social_Person_Space_UIBP.keyName)
    UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    UIBP:ReInitByUidStack()
  end
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  AdjustSystem:ClearAdjustDeepLink()
end
function logic_community.IsInLobbyEntrance()
  local logic_lobby_system_extension = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_system_extension)
  local serverData = logic_lobby_system_extension:GetServerData()
  if serverData == nil then
    return false
  end
  for k, v in pairs(serverData) do
    if v == logic_community.systemId then
      return true
    end
  end
  return false
end
function logic_community.GetVersionUpdateInfo()
  log(bWriteLog and "[v_wllwu] logic_community.GetVersionUpdateInfo")
  if not logic_community.versionUpdateInfo then
    log(bWriteLog and "[v_wllwu] logic_community.GetVersionUpdateInfo get data from cache ")
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    logic_community.versionUpdateInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eClubVersionUpdateRecord)
  end
  log_tree(bWriteLog and "[v_wllwu] logic_community.GetVersionUpdateInfo return data:", logic_community.versionUpdateInfo)
  return logic_community.versionUpdateInfo
end
function logic_community.IsNeedReqVersionUpdateInfo()
  if logic_community.GetShowEntry() == false then
    return false
  end
  logic_community.GetVersionUpdateInfo()
  local info = logic_community.versionUpdateInfo
  if not (info and info.versionId) or not info.show then
    log(bWriteLog and "[v_wllwu] logic_community.IsNeedReqVersionUpdateInfo return true 1")
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local reqTime = info.requestTime or 0
  if not TimeUtil.IsSameDay(curTime, reqTime) then
    log(bWriteLog and "[v_wllwu] logic_community.IsNeedReqVersionUpdateInfo return true 2")
    return true
  end
  log(bWriteLog and "[v_wllwu] logic_community.IsNeedReqVersionUpdateInfo return false")
  return false
end
function logic_community.UpdateVersionUpdateRedDotRecord()
  log(bWriteLog and "[v_wllwu] logic_community.UpdateVersionUpdateRedDotRecord")
  if not logic_community.versionUpdateInfo or not logic_community.versionUpdateInfo.versionId then
    log(bWriteLog and "[v_wllwu] logic_community.UpdateVersionUpdateRedDotRecord error ")
  end
  logic_community.versionUpdateInfo.lastShowVersion = logic_community.versionUpdateInfo.versionId
  log_tree(bWriteLog and "[v_wllwu] logic_community.UpdateVersionUpdateRedDotRecord, data = ", logic_community.versionUpdateInfo)
  logic_community.UpdateVersionUpdateLocalCache()
end
function logic_community.UpdateVersionUpdateLocalCache()
  log(bWriteLog and "[v_wllwu] logic_community.UpdateVersionUpdateLocalCache")
  if not logic_community.versionUpdateInfo then
    log(bWriteLog and "[v_wllwu] logic_community.UpdateVersionUpdateLocalCache return, data is nil")
    return
  end
  log_tree(bWriteLog and "[v_wllwu] logic_community.UpdateVersionUpdateLocalCache, data = ", logic_community.versionUpdateInfo)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(logic_community.versionUpdateInfo, PlayerPrefsSystem.ePlayerPrefsType.eClubVersionUpdateRecord)
end
function logic_community.IsShowVersionUpdateRedDot()
  log(bWriteLog and "[v_wllwu] logic_community.IsShowVersionUpdateRedDot")
  local updateInfo = logic_community.versionUpdateInfo
  if not updateInfo then
    log(bWriteLog and "[v_wllwu] logic_community.IsShowVersionUpdateRedDot false, versionUpdateInfo is nil ")
    return
  end
  if not updateInfo.show or updateInfo.show == 0 then
    log(bWriteLog and "[v_wllwu] logic_community.IsShowVersionUpdateRedDot false, show = " .. tostring(updateInfo.show))
    return
  end
  local updateVersion = updateInfo.versionId or ""
  local lastShowVersion = updateInfo.lastShowVersion or ""
  if updateVersion == lastShowVersion then
    log(bWriteLog and "[v_wllwu] logic_community.IsShowVersionUpdateRedDot false, updateVersion = " .. tostring(updateVersion) .. " lastShowVersion = " .. tostring(lastShowVersion))
    return
  end
  local currentVersion = Client.GetAppVersion()
  local version_util = require("client.common.version_util")
  if updateVersion ~= "" and version_util.LowerVersion(currentVersion, updateVersion) then
    log(bWriteLog and "[v_wllwu] logic_community.IsShowVersionUpdateRedDot false, version not match, updateVersion = " .. tostring(updateVersion) .. " currentVersion = " .. tostring(currentVersion))
    return
  end
  return true
end