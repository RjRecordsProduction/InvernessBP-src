local logic_assembly_activity_utils = {}
function logic_assembly_activity_utils.isInstallSocialApp()
  local channel = Client.GetLoginChannel(NetInterface)
  log(bWriteLog and string.format("logic_assembly_activity_utils.isInstallSocialApp, channel:%s", channel))
  if channel == BP_ENUM_PLAYFORM_BGBGByiTOP then
    return Client.IsInstallBgBgByiTOP(NetInterface)
  elseif channel == BP_ENUM_PLAYFORM_WX then
    return Client.IsInstallWX(NetInterface)
  elseif channel == BP_ENUM_PLAYFORM_VK then
    return Client.IsInstallVK(NetInterface)
  elseif channel == BP_ENUM_PLAYFORM_LINE then
    return Client.IsInstallLine(NetInterface)
  elseif channel == BP_ENUM_PLAYFORM_TWITTER then
    return Client.IsInstallTwitter(NetInterface)
  elseif channel == BP_ENUM_PLAYFORM_BGBG then
    return Client.IsInstallFaceBook(NetInterface) and Client.IsInstallMessenger(NetInterface)
  end
  return true
end
function logic_assembly_activity_utils.CheckMessengerOffline(player)
  local IsFBAndPlatFriend = function()
    local IMSDKHelper = import("IMSDKHelper")
    local IMSDKHelperInstance = IMSDKHelper.GetInstance()
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local platform = IMSDKHelperInstance:GetCurLoginPlatform()
    log(bWriteLog and "logic_assembly_activity_utils.CheckMessengerOffline " .. platform)
    if platform == ShareSource.Messenger or platform == ShareSource.Facebook then
      if LogicFriend.IsPlatFriend(player.uid) then
        log(bWriteLog and "logic_assembly_activity_utils:CheckMessengerOffline is plat friend" .. ":" .. tostring(player.uid))
        return true
      elseif Client.IsDevelopment() then
        ShowNotice("not platFriend")
      end
    end
    return false
  end
  local Logic_Offline_Invite = require("client.slua.logic.teamup.logic_offline_invite")
  return Logic_Offline_Invite.JudgeUseFcmOrMessagener(IsFBAndPlatFriend(), player.uid) == Logic_Offline_Invite.E_Invite_Type.Messagener
end
function logic_assembly_activity_utils.IsShowGuideWindows()
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bHaveLockedFeature = level_unlock_util:HaveLockedFeature()
  log(bWriteLog and "logic_assembly_activity_utils.IsShowGuideWindows bHaveLockedFeature = " .. tostring(bHaveLockedFeature))
  if bHaveLockedFeature then
    return false
  end
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsPHomeMode() then
    log(bWriteLog and "logic_assembly_activity_utils.IsShowGuideWindows PHomeMode")
    return false
  end
  local common_config = require("client.slua.common.common_config")
  if common_config:IsBlockingPopupTip() then
    log(bWriteLog and "logic_assembly_activity_utils.IsShowGuideWindows UI responsiveness testing")
    return false
  end
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_ASSEMBLY_ACTIVITY_SLAP) then
    log(bWriteLog and "[v_wllwu] logic_assembly_activity_utils.IsShowGuideWindows, return false because of switch is closed")
    return false
  end
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  if not AssemblyActivitySystem.HasActivity() then
    log(bWriteLog and "logic_assembly_activity_utils.IsShowGuideWindows not assembly activity")
    return false
  end
  if not AssemblyActivitySystem.AssemblyCfg then
    log(bWriteLog and "logic_assembly_activity_utils.IsShowGuideWindows not AssemblyCfg")
    return
  end
  if not AssemblyActivitySystem.AssemblyCfg.rejoiner_exchange_cfg then
    log(bWriteLog and "logic_assembly_activity_utils.IsShowGuideWindows not rejoiner_exchange_cfg")
    return false
  end
  local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
  local bEverydayTaskGuide = logic_ugc_newbie_guide:HasDailyOrRPAward()
  if bEverydayTaskGuide then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAssemblyGuideShow) or {}
  if not next(saveData) or not saveData[DataMgr.roleData.uid] then
    return true
  end
  local CompareVersion = function(cur, last)
    cur = string.StrReplace(cur, ".", "", 2)
    last = string.StrReplace(last, ".", "", 2)
    return tonumber(cur) - tonumber(last) >= 20
  end
  local version_util = require("client.common.version_util")
  local lastVersion = saveData[DataMgr.roleData.uid]
  local curVersion = version_util.ExcludeTheBuildNumber(Client.GetAppVersion())
  log(bWriteLog and string.format("logic_assembly_activity_utils.IsShowGuideWindows, lastVersion:%s", lastVersion))
  log(bWriteLog and string.format("logic_assembly_activity_utils.IsShowGuideWindows, curVersion:%s", curVersion))
  if not lastVersion or not curVersion then
    log(bWriteLog and "logic_assembly_activity_utils.IsShowGuideWindows error version")
    return false
  end
  return CompareVersion(curVersion, lastVersion)
end
function logic_assembly_activity_utils.IsNewActivity()
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  if AssemblyActivitySystem.AssemblyEndTime == 0 then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAssemblyLastActInfo) or {}
  if not next(saveData) or not saveData[DataMgr.roleData.uid] then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local lastActEndTime = saveData[DataMgr.roleData.uid].endTime
  local curTime = TimeUtil.GetServerTimeInSec()
  return lastActEndTime < curTime
end
function logic_assembly_activity_utils.GetAssemblyBoxInfo()
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  if not AssemblyActivitySystem.HasActivity() then
    log(bWriteLog and "logic_assembly_activity_utils.GetAssemblyBoxInfo not assembly activity")
    return
  end
  local activityData = AssemblyActivitySystem.GetActivityData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerDataByID(activityData and activityData.ID)
  return activityDataTable and activityDataTable.cfg and activityDataTable.cfg.assemb_box_info
end
function logic_assembly_activity_utils:GetCoinExpireHour()
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  if not AssemblyActivitySystem.HasActivity() then
    log(bWriteLog and "logic_assembly_activity_utils.GetCoinExpireHour not assembly activity")
    return 0
  end
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  if AssemblyActivitySystem.AssemblyEndTime == 0 then
    return 0
  end
  local TimeUtil = require("client.common.time_util")
  local dif = AssemblyActivitySystem.AssemblyEndTime - TimeUtil.GetServerTimeInSec()
  local hours = math.ceil(dif / 3600)
  return hours
end
local ENUM_RECALL_PLAYER_TYPE = {MyInvite = 1, OtherOldFriend = 2}
function logic_assembly_activity_utils.GetCoinNumByUID(uid, type)
  log(bWriteLog and string.format("logic_assembly_activity_utils.GetCoinNumByUID, uid:%s", uid))
  log(bWriteLog and string.format("logic_assembly_activity_utils.GetCoinNumByUID, type:%s", type))
  local coinNum = 0
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  local scoreConfig = AssemblyActivitySystem.GetScoreConfig()
  log_tree(bWriteLog and "logic_assembly_activity_utils.GetCoinNumByUID scoreConfig", scoreConfig)
  if not scoreConfig then
    log(bWriteLog and "logic_assembly_activity_utils.GetCoinNumByUID. not scoreConfig")
    return coinNum
  end
  if not logic_assembly_activity_utils.IsUsingTeamUpYearsCfg() then
    log(bWriteLog and string.format("logic_assembly_activity_utils.GetCoinNumByUID, strCode:%s", 1))
    if type == ENUM_RECALL_PLAYER_TYPE.MyInvite then
      coinNum = scoreConfig.battle_with_rejoiner_award
    elseif type == ENUM_RECALL_PLAYER_TYPE.OtherOldFriend then
      coinNum = scoreConfig.battle_with_non_rejoiner_award
    end
  else
    log(bWriteLog and string.format("logic_assembly_activity_utils.GetCoinNumByUID, strCode:%s", 2))
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    if profile then
      log(bWriteLog and string.format("logic_assembly_activity_utils.GetCoinNumByUID, strCode:%s", 3))
      local planID = scoreConfig.plan_id
      local team_score_plan_cfg = AssemblyActivitySystem.AssemblyCfg.team_score_plan_cfg
      if not team_score_plan_cfg then
        log(bWriteLog and "logic_assembly_activity_utils.GetCoinNumByUID. not team_score_plan_cfg")
        return coinNum
      end
      local years = 0
      if profile.register_years then
        years = profile.register_years
      elseif not profile.registertime then
        years = 0
      else
        local TimeUtil = require("client.common.time_util")
        local curTime = TimeUtil.GetServerTimeInSec()
        local time = profile.registertime
        local day = math.floor((curTime - time) / 86400 + 1)
        local Year = 365
        years = math.floor(day / Year + 0.5)
      end
      log(bWriteLog and string.format("logic_assembly_activity_utils.GetCoinNumByUID, years:%s", years))
      local cfg = team_score_plan_cfg[planID][years]
      if not cfg then
        log(bWriteLog and "logic_assembly_activity_utils.GetCoinNumByUID. not cfg")
        return coinNum
      end
      if type == ENUM_RECALL_PLAYER_TYPE.MyInvite then
        coinNum = cfg.rejoiner_score
      elseif type == ENUM_RECALL_PLAYER_TYPE.OtherOldFriend then
        coinNum = cfg.non_rejoiner_score
      end
    end
  end
  log(bWriteLog and string.format("logic_assembly_activity_utils.GetCoinNumByUID, coinNum:%s", coinNum))
  return coinNum
end
function logic_assembly_activity_utils.IsUsingTeamUpYearsCfg()
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  local scoreConfig = AssemblyActivitySystem.GetScoreConfig()
  if not scoreConfig then
    log(bWriteLog and "logic_assembly_activity_utils.IsUsingTeamUpYearsCfg return of not scoreConfig")
    return false
  end
  if not scoreConfig.plan_id then
    log(bWriteLog and "logic_assembly_activity_utils.IsUsingTeamUpYearsCfg return of not scoreConfig.plan_id")
    return
  end
  if scoreConfig.plan_id <= 0 then
    log(bWriteLog and "logic_assembly_activity_utils.IsUsingTeamUpYearsCfg return of scoreConfig.plan_id <= 0")
    return false
  end
  return true
end
function logic_assembly_activity_utils.GetTeamUpCoinRange(type)
  log(bWriteLog and string.format("logic_assembly_activity_utils.GetTeamUpCoinRange, type:%s", type))
  local min, max = 0, 0
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  local scoreConfig = AssemblyActivitySystem.GetScoreConfig()
  if not scoreConfig then
    return min, max
  end
  local planID = scoreConfig.plan_id
  local team_score_plan_cfg = AssemblyActivitySystem.AssemblyCfg.team_score_plan_cfg
  if not team_score_plan_cfg then
    return min, max
  end
  if not team_score_plan_cfg[planID] then
    return min, max
  end
  local maxYears = #team_score_plan_cfg[planID]
  local minCfg = team_score_plan_cfg[planID][0]
  local maxCfg = team_score_plan_cfg[planID][maxYears]
  if type == ENUM_RECALL_PLAYER_TYPE.MyInvite then
    min, max = minCfg.rejoiner_score, maxCfg.rejoiner_score
  elseif type == ENUM_RECALL_PLAYER_TYPE.OtherOldFriend then
    min, max = minCfg.non_rejoiner_score, maxCfg.non_rejoiner_score
  end
  log(bWriteLog and string.format("logic_assembly_activity_utils.GetTeamUpCoinRange, min:%s max:%s", min, max))
  return min, max
end
return logic_assembly_activity_utils