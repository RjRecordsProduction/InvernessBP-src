local logic_activity_util = {}
function logic_activity_util.GetTypeOfSpinDiscountTicket()
  return ActivityType.DISCOUNT_TICKET, 2
end
local TableUtil = require("common.table_util")
function logic_activity_util.GetActivityData(activityType, condType)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local TimeUtil = require("client.common.time_util")
  local timeStamp = TimeUtil.GetServerTimeInSec()
  for activityId, activityData in pairs(activityDataTable) do
    if activityType and activityData.cfg and activityData.cfg.type == activityType then
      for index, award in pairs(activityData.cfg.award) do
        local condArray = StrSplit(award.cond, ",")
        if tonumber(condArray[1]) == condType then
          local status = TableUtil.GetTableValue(activityData.data, "award", index, "status")
          if status ~= 1 then
            log(bWriteLog and "logic_activity_util.GetActivityData.status = " .. tostring(status))
          elseif timeStamp < (TableUtil.GetTableValue(activityData, "cfg", "start_time") or timeStamp) or timeStamp > (TableUtil.GetTableValue(activityData, "cfg", "end_time") or timeStamp) then
            log(bWriteLog and "logic_activity_util.GetActivityData.unvalid time")
          else
            return activityData, index
          end
        end
      end
    end
  end
end
function logic_activity_util.GetActivityAwardIndex(activityType, condType)
  local activityData, awardIndex = logic_activity_util.GetActivityData(activityType, condType)
  return awardIndex
end
function logic_activity_util.GetActivityCornerDotPath(activityType, condType)
  local activityData = logic_activity_util.GetActivityData(activityType, condType)
  local imgPath = TableUtil.GetTableValue(activityData, "cfg", "activity_image_link")
  if imgPath and string.len(imgPath) > 0 then
    return imgPath
  end
  return "/Game/UMG/Texture/Atlas/LobbyUI/Frames/Lobby_giftbox_tip_png.Lobby_giftbox_tip_png"
end
function logic_activity_util.GetActivityCfgByModule(moduleId)
  local giftConfig = ActivityGiftConfig[moduleId]
  if giftConfig then
    for _, activityInfo in pairs(giftConfig) do
      local activityType = activityInfo[1]
      local condType = activityInfo[2]
      if logic_activity_util.GetActivityAwardIndex(activityType, condType) then
        return activityType, condType
      end
    end
  end
end
function logic_activity_util.GetActDataFromMap(activityType, condType)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetActivityMap()
  for activityId, activityData in pairs(activityDataTable) do
    if activityData.Type and activityData.Type == activityType then
      local condArray = StrSplit(activityData.Condition, ",")
      if 1 <= #condArray and tonumber(condArray[1]) == condType then
        return activityData, activityId
      end
    end
  end
end
function logic_activity_util.GetActivityDesktopToolType(installType)
  local bp_pluginBPLibrary = import("bp_pluginBPLibrary")
  local type = ActivityDesktopToolType.None
  installType = installType or bp_pluginBPLibrary.bp_pluginGetInstalledWidgetType()
  log(bWriteLog and string.format("logic_activity_util.GetActivityDesktopToolType. installType=%s", tostring(installType)))
  if not installType or installType < 0 then
    return type
  end
  if installType & 7 ~= 0 then
    type = type | ActivityDesktopToolType.Friend
  end
  if installType & 8 ~= 0 then
    type = type | ActivityDesktopToolType.Popularity_PK
  end
  if installType & 16 ~= 0 then
    type = type | ActivityDesktopToolType.SeasonRecord
  end
  if installType & 32 ~= 0 then
    type = type | ActivityDesktopToolType.Commercial
  end
  return type
end
function logic_activity_util.CheckTeamQuickDesktopNeedShow()
  log_format("logic_activity_util.CheckTeamQuickDesktopNeedShow.")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() or PublishRegionMacros.IsBLUEHOLE() then
    log_format("logic_activity_util.CheckTeamQuickDesktopNeedShow. is Japan or Korea or Bluehole version, return false")
    return false
  end
  local logic_community = require("client.slua.logic.community.logic_community")
  if not logic_community.GetShowEntry() then
    log_format("logic_activity_util.CheckTeamQuickDesktopNeedShow. not logic_community.GetShowEntry(), return false")
    return false
  end
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.GLOBAL and strRegion ~= PublishRegionMacros.FIT then
    log_format("logic_activity_util.CheckTeamQuickDesktopNeedShow. not GLOBAL or FIT, return false")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFrienDeskTopTooldGuide) or {}
  log_tree(bWriteLog and "logic_activity_util.CheckTeamQuickDesktopNeedShow saveData", saveData)
  if saveData.teamQuickDesktopShow then
    log_format("logic_activity_util.CheckTeamQuickDesktopNeedShow. already guide, return false")
    return false
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local teams = logic_flash_match_team:getMyTeams()
  if not teams or #teams == 0 then
    log_format("logic_activity_util.CheckTeamQuickDesktopNeedShow. no team, return false")
    return false
  end
  local desktopToolType = logic_activity_util.GetActivityDesktopToolType()
  return desktopToolType & ActivityDesktopToolType.Friend == 0
end
function logic_activity_util.RecordTeamQuickDesktopShow()
  log_format("logic_activity_util.RecordTeamQuickDesktopShow.")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFrienDeskTopTooldGuide) or {}
  saveData.teamQuickDesktopShow = true
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eFrienDeskTopTooldGuide)
end
function logic_activity_util.HandleClickTeamQuickDesktop()
  log_format("logic_activity_util.HandleClickTeamQuickDesktop.")
  local url = "game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Fadd_widget_guide%3F%26type%3D0%26game_scene%3DSquadListWidget%26from_scene%3D1"
  GlobalData.JumpUrl(url)
  logic_activity_util.RecordTeamQuickDesktopShow()
end
return logic_activity_util