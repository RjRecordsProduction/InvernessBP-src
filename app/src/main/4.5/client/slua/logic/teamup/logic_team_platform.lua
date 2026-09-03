local TeamPlatformSystem = {
  publishOption = nil,
  filterOption = nil,
  recruitInfo = nil,
  ableToEnter = nil,
  abletoEnterErrorCode = 0,
  bGraySwitch = true,
  bVoiceGraySwitch = true,
  lastRequireCreditTimeStamp = -1,
  self_kd = 0,
  isKdValueUpdated = nil,
  nLastSearchTeamTime = 0,
  C_RefreshButtonTime = 3,
  IdleAutoSearchTime = 3,
  nPlatformType = 1,
  bTPlanGraySwitch = true,
  tPlanPublishOption = nil,
  tPlanFilterOption = nil,
  lastSearchTime = 0,
  subModeGroupToModeMap = nil,
  lastSearchTeamLists = nil,
  nLastSearchTime = 0,
  isOpenRecruitUI = nil,
  publishRecruitMsgFrom = nil,
  publishRecruitConscribe = nil,
  isLoginReqGetKdValue = nil,
  lastUpdateKdValueTime = 0,
  CONST_SEARCHIDLE_MINCOUNT = 1,
  CONST_SEARCHIDLE_MAXCOUNT = 6
}
local C_SearchIntervalTime = 3
local C_TPLAN_TAB_ID = 15
local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
local E_PlatformType = TeamPlatform_Macro.Enum_PlatformType
local E_PublishRecruitMsgFromType = TeamPlatform_Macro.Enum_PublishRecruitMsgFromType
local E_RecruitSyncReason = TeamPlatform_Macro.Enum_RecruitSyncReason
local C_CoolDownGetCredit = 3
local C_UpdateKdValue = 30
function TeamPlatformSystem.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    TeamPlatformSystem.recruitInfo = nil
  elseif nextState == GameStatus.Login then
    TeamPlatformSystem.ClearData()
  end
  if nextState == GameStatus.Lobby then
    TeamPlatformSystem.isNeedRequestKdData = true
    EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CREDIT_SYNC, TeamPlatformSystem.CheckAccessValidation)
  elseif not GameStatus.IsInLobbyOrMainCity() then
    EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CREDIT_SYNC, TeamPlatformSystem.CheckAccessValidation)
  end
end
function TeamPlatformSystem.ClearData()
  TeamPlatformSystem.filterOption = nil
  TeamPlatformSystem.publishOption = nil
  TeamPlatformSystem.recruitInfo = nil
  TeamPlatformSystem.lastRequireCreditTimeStamp = -1
  TeamPlatformSystem.tPlanPublishOption = nil
  TeamPlatformSystem.tPlanFilterOption = nil
  TeamPlatformSystem.subModeGroupToModeMap = nil
  TeamPlatformSystem.lastSearchTeamLists = nil
  TeamPlatformSystem.nLastSearchTime = 0
  TeamPlatformSystem.isKdValueUpdated = nil
  TeamPlatformSystem.isLoginReqGetKdValue = nil
  TeamPlatformSystem.lastUpdateKdValueTime = 0
  TeamPlatformSystem.isNeedRequestKdData = nil
end
function TeamPlatformSystem.InitGraySwitch(team_consribe_switch, team_consribe_voice_switch, team_consribe_tplan_switch)
  TeamPlatformSystem.bGraySwitch = team_consribe_switch and team_consribe_switch == 1 or false
  TeamPlatformSystem.bVoiceGraySwitch = team_consribe_voice_switch and team_consribe_voice_switch == 1 or false
  TeamPlatformSystem.bTPlanGraySwitch = team_consribe_tplan_switch and team_consribe_tplan_switch == 1 or false
end
function TeamPlatformSystem.IsOpen(platformType)
  platformType = platformType or E_PlatformType.Normal
  local switchID, graySwitch
  if platformType == E_PlatformType.TPlan then
    switchID = BP_ENUM_TEAM_PLATFORM_TPLAN_SWITCH
    graySwitch = TeamPlatformSystem.bTPlanGraySwitch
  elseif platformType == E_PlatformType.WoW then
    switchID = BP_ENUM_SWITCH_WOW_TEAM_PLATFORM
    graySwitch = TeamPlatformSystem.bTPlanGraySwitch
  else
    switchID = BP_ENUM_TEAM_PLATFORM_SWITCH
    graySwitch = TeamPlatformSystem.bGraySwitch
  end
  if not LobbySystem.CheckOpen(switchID) then
    return false
  end
  if not graySwitch then
    return false
  end
  return true
end
local _UpdatePublishOption = function(option)
  if not option then
    return
  end
  local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
  local sel_mode = LogicTxMissionMatch.GetSelModel()
  if not sel_mode then
    return
  end
  log(bWriteLog and "[v_wllwu] UpdatePublishOption, sel_mode is:" .. tostring(sel_mode))
  local mapModeInfo = CDataTable.GetTableData("TxMissionMapMode", sel_mode)
  if not mapModeInfo then
    return
  end
  option.nMatchID = mapModeInfo.MainModeID
  option.nViewID = mapModeInfo.ModeID
  option.nModeID = mapModeInfo.ModeID
  option.nTabID = mapModeInfo.MapID
end
local GetTPlanInitModeOption = function(option, filterType)
  local defaultConfig
  local TxMissionMapMode = CDataTable.GetTable("TxMissionMapMode")
  for _, config in pairs(TxMissionMapMode) do
    if config.IsDefault == 1 then
      defaultConfig = config
      break
    end
  end
  if not defaultConfig then
    log_error("[edward][logic_team_platform] GetTPlanInitModeOption, no default mode, config is error!!!!!")
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  option.nPlayerNum = TeamUpNewSystem.GetDefaultMaxTeamNum()
  option.nPerspective = ENUM_PerspectiveType.TPP
  option.bMemberCanInvite = false
  option.nTabID = defaultConfig.MapID
  if filterType == TeamPlatform_Macro.Enum_FilterType.Publish then
    option.nMatchID = defaultConfig.MainModeID
    option.nViewID = defaultConfig.ModeID
    option.nModeID = defaultConfig.ModeID
    _UpdatePublishOption(option)
  else
    local modeInfoArray = {}
    local modeInfo = {
      nMatchID = defaultConfig.MainModeID,
      nViewID = defaultConfig.ModeID,
      nModeID = defaultConfig.ModeID
    }
    table.insert(modeInfoArray, modeInfo)
    option.modeInfo = modeInfoArray
  end
  log_tree(bWriteLog and "[v_wllwu][logic_team_platform] GetTPlanInitModeOption, option:", option)
end
local GetInitTPlanOption = function(filterType)
  local option = {
    nMinSegment = 0,
    nKD = 0,
    nPloy = 5,
    send_to_room_channel = false
  }
  GetTPlanInitModeOption(option, filterType)
  local logic_team_platform_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_new)
  option.nZoneID = logic_team_platform_new:GetZoneID()
  local saveData = logic_team_platform_new:GetSendRecruitCondition() or {}
  option.nMinWorth = saveData.nMinWorth or 0
  option.bOpenSameLanguage = saveData.bOpenSameLanguage or false
  option.nSelectMicType = saveData.nSelectMicType or ENUM_RECRUIT_OPENMIC.ARBITRARILY
  if option.nSelectMicType == ENUM_RECRUIT_OPENMIC.HAVETO then
    log(bWriteLog and "[v_wllwu] logic_team_platform:GetInitTPlanOption" .. tostring(option.nSelectMicType))
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    if not logic_chat_voice:CheckChatPrivacyAcceptStatus() then
      log(bWriteLog and "[v_wllwu] TeamPlatformSystem GetInitTPlanOption reset SelectMicType because of Privacy ")
      option.nSelectMicType = ENUM_RECRUIT_OPENMIC.ARBITRARILY
    end
  end
  return option
end
function TeamPlatformSystem.GetRecruitInfo()
  return TeamPlatformSystem.recruitInfo and TeamPlatformSystem.recruitInfo.conscribe
end
function TeamPlatformSystem.ClearRecruitInfo()
  log(bWriteLog and "[edward][logic_team_platform] TeamPlatformSystem.ClearRecruitInfo")
  TeamPlatformSystem.recruitInfo = nil
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.teamInfo then
    TeamUpNewSystem.teamInfo.publish_conscribe = nil
  end
end
function TeamPlatformSystem.IsInRecruit()
  if TeamPlatformSystem.GetRecruitInfo() then
    log(bWriteLog and "[edward][logic_team_platform] TeamPlatformSystem.IsInRecruit 1")
    return true
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.publish_conscribe then
    log(bWriteLog and "[edward][logic_team_platform] TeamPlatformSystem.IsInRecruit 2")
    return true
  end
  return false
end
function TeamPlatformSystem.IsIdle()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamPlatformSystem.IsInRecruit() and TeamUpNewSystem.GetTeamNum() == 1 then
    return true
  end
  return false
end
function TeamPlatformSystem.IsFull()
  if not TeamPlatformSystem.IsInRecruit() then
    return false
  end
  local teamPublishOption = TeamPlatformSystem.GetTeamPublishOption()
  local teamMaxNum = teamPublishOption and teamPublishOption.nPlayerNum or 4
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() == teamMaxNum then
    return true
  end
  return false
end
function TeamPlatformSystem.GetPublishOption()
  local logic_team_platform_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_new)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "[v_wllwu] TeamPlatformSystem.GetPublishOption InXMission")
    if not TeamPlatformSystem.tPlanPublishOption then
      TeamPlatformSystem.tPlanPublishOption = GetInitTPlanOption(TeamPlatform_Macro.Enum_FilterType.Publish)
    else
      TeamPlatformSystem.tPlanPublishOption.nZoneID = logic_team_platform_new:GetZoneID()
      _UpdatePublishOption(TeamPlatformSystem.tPlanPublishOption)
    end
    TeamPlatformSystem.ResetWorthValue(TeamPlatformSystem.tPlanPublishOption)
    return TeamPlatformSystem.tPlanPublishOption
  else
    return logic_team_platform_new:GetPublishOption()
  end
end
local _GetPlayerNumAndPerspective = function(teamInfo, nMactchID)
  if not teamInfo then
    return
  end
  for perspectiveType, list in pairs(teamInfo) do
    for playerNum, matchID in pairs(list) do
      if matchID == nMactchID then
        return playerNum, perspectiveType
      end
    end
  end
  return nil
end
function TeamPlatformSystem.GetTeamPublishOption()
  if not TeamPlatformSystem.recruitInfo or not TeamPlatformSystem.recruitInfo.conscribe then
    log(bWriteLog and "[edward][logic_team_platform] TeamPlatformSystem.GetTeamPublishOption, recruitInfo is nil")
    return nil
  end
  local conscribe = TeamPlatformSystem.recruitInfo.conscribe
  local option = {
    nMatchID = conscribe.mode,
    nModeID = conscribe.sub_mode_group,
    nZoneID = conscribe.zone,
    bOpenSameLanguage = conscribe.is_same_first_lang == 1,
    lang = conscribe.lang,
    nPloy = conscribe.play_style,
    nMinSegment = conscribe.segment_level,
    nSelectMicType = conscribe.mic_open,
    bMemberCanInvite = conscribe.member_voice_invite and conscribe.member_voice_invite == 1 or false,
    nMinWorth = conscribe.worth or -1,
    nKD = conscribe.kd or 0,
    taskId = conscribe.taskId or 0
  }
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    local TxMissionMapMode = CDataTable.GetTableData("TxMissionMapMode", option.nModeID)
    option.nTabID = TxMissionMapMode and TxMissionMapMode.MapID
    option.nViewID = option.nModeID
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    option.nPlayerNum = TeamUpNewSystem.GetDefaultMaxTeamNum()
    option.nPerspective = ENUM_PerspectiveType.TPP
  else
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local viewId = conscribe.view
    local modeInfo = logic_mode_selection:GetSubviewInfoBySubviewID(viewId)
    if not modeInfo then
      log_warning("[v_wllwu][logic_team_platform] TeamPlatformSystem.GetTeamPublishOption, recruit mode is error, mode = " .. tostring(viewId))
      return nil
    end
    local tabList = logic_mode_selection:GetMenuListByViewID(viewId)
    if not tabList or #tabList <= 0 then
      log_warning("[v_wllwu][logic_team_platform] TeamPlatformSystem.GetTeamPublishOption, tabID is error, mode = " .. tostring(viewId))
      return nil
    end
    local teamInfo = modeInfo.options.team_type
    local nPlayerNum, nPerspectiveType = _GetPlayerNumAndPerspective(teamInfo, conscribe.mode)
    if not nPlayerNum or not nPerspectiveType then
      log_warning("[v_wllwu][logic_team_platform] TeamPlatformSystem.GetTeamPublishOption, nPlayerNum is error, mode = " .. tostring(viewId))
      return
    end
    option.nTabID = tabList[1]
    option.nViewID = viewId
    option.    option.nPerspective = nPerspectiveType
  end
  return option
end
function TeamPlatformSystem.GetFilterOption(isReset)
  local logic_team_platform_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_new)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    if not TeamPlatformSystem.tPlanFilterOption then
      TeamPlatformSystem.tPlanFilterOption = GetInitTPlanOption(TeamPlatform_Macro.Enum_FilterType.Filter)
    elseif isReset then
      TeamPlatformSystem.tPlanFilterOption = GetInitTPlanOption(TeamPlatform_Macro.Enum_FilterType.Filter)
      TeamPlatformSystem.tPlanFilterOption.nSelectMicType = ENUM_RECRUIT_OPENMIC.ARBITRARILY
      TeamPlatformSystem.tPlanFilterOption.bOpenSameLanguage = false
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_FILTER_CONDITOIN_CHANGED)
    end
    TeamPlatformSystem.ResetWorthValue(TeamPlatformSystem.tPlanFilterOption)
    TeamPlatformSystem.tPlanFilterOption.nZoneID = logic_team_platform_new:GetZoneID()
    return TeamPlatformSystem.tPlanFilterOption
  else
    return logic_team_platform_new:GetFilterOption(isReset)
  end
end
function TeamPlatformSystem.ResetWorthValue(option)
  if not TeamPlatformSystem.needRefreshData then
    return
  end
  log(bWriteLog and "[v_wllwu] TeamPlatformSystem.ResetWorthValue enter")
  if not option or not option.nMinWorth then
    log(bWriteLog and "[v_wllwu] TeamPlatformSystem.ResetWorthValue error")
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local selfWorth = LogicTxMissionMain.GetWorth()
  if selfWorth < option.nMinWorth then
    log(bWriteLog and "[v_wllwu] TeamPlatformSystem:GetInitTPlanOption reset worth: " .. tostring(selfWorth) .. " option.nMinWorth = " .. tostring(option.nMinWorth))
    option.nMinWorth = 0
  end
  TeamPlatformSystem.needRefreshData = nil
end
function TeamPlatformSystem.CheckPublishOption(option)
  if not option or not option.nViewID then
    return false
  end
  return true
end
function TeamPlatformSystem.CheckFilterOption(option)
  if not (option and option.modeInfo) or #option.modeInfo == 0 then
    return false
  end
  return true
end
local _GetModeIDBySubModeGroupID = function(subModeGroupID)
  if not TeamPlatformSystem.subModeGroupToModeMap then
    TeamPlatformSystem.subModeGroupToModeMap = {}
  end
  if not TeamPlatformSystem.subModeGroupToModeMap[subModeGroupID] then
    local subModeCoinfig = CDataTable.GetTableData("TxMissionMapMode", subModeGroupID)
    if subModeCoinfig and subModeCoinfig.MainModeID then
      TeamPlatformSystem.subModeGroupToModeMap[subModeGroupID] = subModeCoinfig.MainModeID
    else
      log_error(bWriteLog and "[v_wllwu] TeamPlatformSystem _GetModeIDBySubModeGroupID error " .. tostring(subModeGroupID))
    end
  end
  return TeamPlatformSystem.subModeGroupToModeMap[subModeGroupID]
end
function TeamPlatformSystem.SaveTPlanPublishOption(option)
  option.nMatchID = _GetModeIDBySubModeGroupID(option.nViewID)
  option.nModeID = option.nViewID
  TeamPlatformSystem.tPlanPublishOption = option
end
function TeamPlatformSystem.SaveTPlanFilterOption(option)
  if not option.modeInfo then
    log_error(bWriteLog and "[v_wllwu] TeamPlatformSystem.SaveTPlanFilterOption error")
    return
  end
  for i, v in ipairs(option.modeInfo) do
    v.nMatchID = _GetModeIDBySubModeGroupID(v.nViewID)
    v.nModeID = v.nViewID
  end
  local TableUtil = require("common.table_util")
  TeamPlatformSystem.tPlanFilterOption = TableUtil.CopyTable(option)
end
function TeamPlatformSystem.CheckValidPersonalCredit()
  if TeamPlatformSystem.NeedToRequirePersonalCredit() then
    TeamPlatformSystem.ReqGetEntryStatus()
    return false
  elseif not TeamPlatformSystem.ableToEnter then
    local text = LocUtil.LocalizeResFormat(TeamPlatformSystem.abletoEnterErrorCode)
    ShowNotice(text)
    return false
  end
  return true
end
function TeamPlatformSystem.IsCanEnter()
  return TeamPlatformSystem and TeamPlatformSystem.ableToEnter
end
function TeamPlatformSystem.GetErrorCode()
  return TeamPlatformSystem.abletoEnterErrorCode
end
function TeamPlatformSystem.ReqGetEntryStatus(isJustGetKd)
  log(bWriteLog and "[v_wllwu] TeamPlatformSystem.ReqGetEntryStatus, isJustGetKd = " .. tostring(isJustGetKd))
  TeamPlatformSystem.isLoginReqGetKdValue = isJustGetKd
  local TimeUtil = require("client.common.time_util")
  TeamPlatformSystem.lastRequireCreditTimeStamp = TimeUtil.GetServerTimeInSec()
  local ConscribeHandler = require("client.network.Protocol.ConscribeHandler")
  ConscribeHandler.send_get_team_conscribe_entry_status_req()
end
function TeamPlatformSystem.NeedToRequirePersonalCredit()
  local TimeUtil = require("client.common.time_util")
  if TimeUtil.GetServerTimeInSec() - TeamPlatformSystem.lastRequireCreditTimeStamp >= C_CoolDownGetCredit or TeamPlatformSystem.ableToEnter == nil then
    return true
  end
  return false
end
function TeamPlatformSystem.CheckAccessValidation()
  if not TeamPlatformSystem.ableToEnter then
    if TeamPlatformSystem.abletoEnterErrorCode == 100220026 then
      local logic_access_restriction = require("client.logic.common.logic_access_restriction")
      local tips = logic_access_restriction.GetPopTips(logic_access_restriction.EAccessType.TeamPlatform)
      if tips then
        ShowNotice(tips)
      else
        ShowNotice(logic_access_restriction.EAccessType.TeamPlatform)
      end
    else
      if TeamPlatformSystem.abletoEnterErrorCode == 100220031 then
        ShowNotice(7568)
        return
      end
      local text = LocUtil.LocalizeResFormat(TeamPlatformSystem.abletoEnterErrorCode)
      ShowNotice(text)
    end
    return
  end
  local Opentype
  log(bWriteLog and "TeamPlatformSystem.CheckAccessValidation TeamPlatformSystem.nPlatformType " .. TeamPlatformSystem.nPlatformType)
  if TeamPlatformSystem.nPlatformType == TeamPlatform_Macro.Enum_PlatformType.WoW then
    Opentype = 3
  elseif TeamPlatformSystem.nPlatformType == TeamPlatform_Macro.Enum_PlatformType.Peak then
    Opentype = TeamPlatform_Macro.Enum_PlatformType.Peak
  else
    Opentype = 1
  end
  TeamPlatformSystem.EnterTeamPlatFormUI(Opentype)
end
function TeamPlatformSystem.CheckCanShow()
  if not TeamPlatformSystem.IsOpen(TeamPlatformSystem.nPlatformType) then
    ShowNotice(116009)
    return false
  end
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  if MentorSystem.mentor_prematch_state then
    ShowNotice(110017)
    return
  end
  return TeamPlatformSystem.CanRecruit(TeamPlatformSystem.nPlatformType, true)
end
function TeamPlatformSystem.CanRecruit(nPlatformType, bCheckShow)
  if not nPlatformType then
    nPlatformType = E_PlatformType.Normal
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission() then
      nPlatformType = E_PlatformType.TPlan
    end
    if not TeamPlatformSystem.IsOpen(nPlatformType) then
      ShowNotice(116009)
      return false
    end
  elseif nPlatformType == E_PlatformType.WoW and not TeamPlatformSystem.IsOpen(nPlatformType) then
    ShowNotice(116009)
    return false
  end
  log(bWriteLog and "[v_wllwu] TeamPlatformSystem.CanRecruit, nPlatformType = " .. tostring(nPlatformType))
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if not MatchSystem.CanInviteInBan() then
    return false
  end
  if LobbySystem.isInMatch then
    ShowNotice(110017)
    return false
  end
  local logic_access_restriction = require("client.logic.common.logic_access_restriction")
  if not logic_access_restriction.CheckAccessAndPopTips(logic_access_restriction.EAccessType.TeamPlatform) then
    return false
  end
  local levelLimit = TeamPlatformSystem.GetLevelLimit()
  if levelLimit > DataMgr.roleData.level then
    ShowNotice(LocUtil.LocalizeResFormat(34394, levelLimit))
    return false
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if not LogicTxMissionMain.IsInXMission() then
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
    log(bWriteLog and "LogicUGCMatch:GetMatchModID " .. LogicUGCMatch:GetMatchModID())
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local curTeamNum = TeamUpNewSystem.GetTeamNum()
  if curTeamNum <= 1 then
    return true
  end
  if TeamUpNewSystem.IsTeamLeader() then
    local isInRecruit = TeamPlatformSystem.IsInRecruit()
    if not bCheckShow or not isInRecruit then
      return not TeamPlatformSystem.IsTeamFull()
    end
  elseif not bCheckShow then
    ShowNotice(500062)
    return false
  end
  return true
end
function TeamPlatformSystem.GetLevelLimit()
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    return -1
  end
  local levelLimit = DataMgr.GetSystemConfig("TeamPlatformLevelLimit")
  levelLimit = tonumber(levelLimit) or 0
  log(bWriteLog and "[v_wllwu] TeamPlatformSystem.GetLevelLimit:" .. tostring(levelLimit))
  return levelLimit
end
function TeamPlatformSystem.IsTeamFull()
  local teamNum = 4
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  if not LogicTxMissionMain.IsInXMission() then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local filterInfo = logic_mode_selection:GetFilterInfo()
    if filterInfo then
      teamNum = filterInfo.teamNum
    end
    if LogicUGCMulti.bIsBundleMatch then
      teamNum = LogicUGCMulti:GetMaxTeamSize()
    end
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local curTeamNum = TeamUpNewSystem.GetTeamNum()
  log(bWriteLog and "[v_wllwu] TeamPlatformSystem.CanRecruit, teamNum = " .. tostring(teamNum) .. " curTeamNum = " .. tostring(curTeamNum))
  if teamNum ~= nil and 1 < curTeamNum and teamNum <= curTeamNum then
    local title = LocUtil.GetLocalizeResStr(101001)
    local msg = LocUtil.GetLocalizeResStr(10322)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, msg)
    return true
  end
  return false
end
function TeamPlatformSystem.CheckRequestKdValueUpdate()
  log(bWriteLog and "[v_wllwu] TeamPlatformSystem.CheckKdValueUpdate()")
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if nowTime - TeamPlatformSystem.lastUpdateKdValueTime < C_UpdateKdValue then
    return
  end
  if nowTime - TeamPlatformSystem.lastRequireCreditTimeStamp < 2 then
    return
  end
  TeamPlatformSystem.ReqGetEntryStatus(true)
end
function TeamPlatformSystem.ShowUI(platformType, isSendRecruitDirectly, tab)
  local lastType = TeamPlatformSystem.nPlatformType
  TeamPlatformSystem.nPlatformType = platformType or E_PlatformType.Normal
  if lastType ~= TeamPlatformSystem.nPlatformType then
    TeamPlatformSystem.lastSearchTeamLists = nil
  end
  if not TeamPlatformSystem.CheckCanShow() then
    TeamPlatformSystem:CloseTabUI()
    return
  end
  TeamPlatformSystem.isOpenRecruitUI = isSendRecruitDirectly
  TeamPlatformSystem.needRefreshData = true
  log(bWriteLog and "TeamPlatformSystem.ShowUI self.nPlatformType " .. tostring(TeamPlatformSystem.nPlatformType))
  if TeamPlatformSystem.nPlatformType == E_PlatformType.WoW or TeamPlatformSystem.nPlatformType == E_PlatformType.WoWHall then
    TeamPlatformSystem.EnterTeamPlatFormUI(TeamPlatformSystem.nPlatformType)
    return
  else
    TeamPlatformSystem.EnterTeamPlatFormUI(platformType, tab)
  end
  if not TeamPlatformSystem.CheckValidPersonalCredit() then
    return
  end
end
function TeamPlatformSystem:CloseTabUI()
  if UIManager.IsUIShow(UIManager.UI_Config.TeamPlatform_Tab) then
    UIManager.CloseUI(UIManager.UI_Config.TeamPlatform_Tab)
  end
end
function TeamPlatformSystem.OpenTeamPlatformUI(platformType, tab)
  log(bWriteLog and "TeamPlatformSystem.OpenTeamPlatformUI platformType " .. tostring(platformType))
  local isInRecruit = TeamPlatformSystem.IsInRecruit()
  if isInRecruit then
    local logic_lobby_my_team = require("client.slua.logic.teamup.logic_lobby_my_team")
    if platformType == E_PlatformType.WoW then
      if TeamPlatformSystem.recruitInfo and TeamPlatformSystem.recruitInfo.conscribe.view == 20002 then
        logic_lobby_my_team.CheckAndOpenWOWMyTeamUI()
      else
        TeamPlatformSystem.ShowWoWTeamPlatformMainUI()
      end
    elseif platformType == E_PlatformType.WoWHall then
      TeamPlatformSystem.ShowWoWHallPlatformMainUI()
    elseif platformType == E_PlatformType.Peak then
      if not TeamPlatformSystem.recruitInfo then
        TeamPlatformSystem.ShowPeakTeamPlatformMainUI()
        return
      end
      local viewID = TeamPlatformSystem.recruitInfo.conscribe.view
      local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
      local isPeakGame = logic_mode_selection:IsPeakGameViewID(viewID)
      if TeamPlatformSystem.recruitInfo and isPeakGame then
        logic_lobby_my_team.CheckAndOpenPeakMyTeamUI()
      else
        TeamPlatformSystem.ShowPeakTeamPlatformMainUI()
      end
    elseif platformType == E_PlatformType.Normal then
      if TeamPlatformSystem.recruitInfo and TeamPlatformSystem.recruitInfo.conscribe.view ~= 20002 then
        logic_lobby_my_team.CheckAndOpenMyTeamUI()
      else
        TeamPlatformSystem.ShowTeamPlatformMainUI()
      end
    else
      TeamPlatformSystem.ShowTeamPlatformMainUI()
    end
  else
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission() then
      TeamPlatformSystem.ShowXMissionTeamPlatformMainUI()
    elseif platformType == E_PlatformType.WoW then
      TeamPlatformSystem.ShowWoWTeamPlatformMainUI()
    elseif platformType == E_PlatformType.WoWHall then
      TeamPlatformSystem.ShowWoWHallPlatformMainUI()
    elseif platformType == E_PlatformType.Peak then
      TeamPlatformSystem.ShowPeakTeamPlatformMainUI()
    elseif platformType == E_PlatformType.None then
      TeamPlatformSystem.ShowMainUIByTab(tab)
    else
      TeamPlatformSystem.ShowTeamPlatformMainUI()
    end
  end
end
function TeamPlatformSystem.EnterTeamPlatFormUI(platformType, tab)
  if not TeamPlatformSystem.isOpenRecruitUI then
    TeamPlatformSystem.OpenTeamPlatformUI(platformType, tab)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission() then
      TeamPlatformSystem.UpdatePublishRecruitMsgFrom(E_PublishRecruitMsgFromType.TPlanLobbyEntrance)
      UIManager.ShowUI(UIManager.UI_Config.TPlan_TeamPlatform_Recruit_UIBP)
    else
      TeamPlatformSystem.UpdatePublishRecruitMsgFrom(E_PublishRecruitMsgFromType.LobbyEntrance)
      UIManager.ShowUI(UIManager.UI_Config.TeamPlatform_Recruit_UIBP)
    end
  else
    TeamPlatformSystem.OpenTeamPlatformUI(platformType)
  end
end
function TeamPlatformSystem.ShowMainUIByTab(tab)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ShowUI(tab)
end
function TeamPlatformSystem.ShowTeamPlatformMainUI()
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ShowUI(TeamUpNewSystem.E_UI_TYPE.TeamPlatformMain)
end
function TeamPlatformSystem.ShowWoWTeamPlatformMainUI()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ShowUI(TeamUpNewSystem.E_UI_TYPE.WoWTeamPlatformMain)
end
function TeamPlatformSystem.ShowWoWHallPlatformMainUI()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ShowUI(TeamUpNewSystem.E_UI_TYPE.WowHallUI)
end
function TeamPlatformSystem.ShowWoWRoomPlatformMainUI()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ShowUI(TeamUpNewSystem.E_UI_TYPE.WowRoomUI)
end
function TeamPlatformSystem.ShowPeakTeamPlatformMainUI()
  log(bWriteLog and "[v_wllwu] TeamPlatformSystem.ShowPeakTeamPlatformMainUI")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ShowUI(TeamUpNewSystem.E_UI_TYPE.PeakTeamPlatformMain)
end
function TeamPlatformSystem.CheckShowTeamPlatformMainUI()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  return TeamUpNewSystem.CheckUI(TeamUpNewSystem.E_UI_TYPE.TeamPlatformMain)
end
function TeamPlatformSystem.ShowLobbyMyTeamUI()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ShowUI(TeamUpNewSystem.E_UI_TYPE.LobbyMyTeamUI)
end
function TeamPlatformSystem.ShowWOWLobbyMyTeamUI()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ShowUI(TeamUpNewSystem.E_UI_TYPE.WOWLobbyMyTeamUI)
end
function TeamPlatformSystem.ShowPeakLobbyMyTeamUI()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ShowUI(TeamUpNewSystem.E_UI_TYPE.PeakLobbyMyTeamUI)
end
function TeamPlatformSystem.CheckShowLobbyMyTeamUI()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  return TeamUpNewSystem.CheckUI(TeamUpNewSystem.E_UI_TYPE.LobbyMyTeamUI)
end
function TeamPlatformSystem.CheckShowWOWLobbyMyTeamUI()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  return TeamUpNewSystem.CheckUI(TeamUpNewSystem.E_UI_TYPE.WOWLobbyMyTeamUI)
end
function TeamPlatformSystem.CheckShowPeakLobbyMyTeamUI()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  return TeamUpNewSystem.CheckUI(TeamUpNewSystem.E_UI_TYPE.PeakLobbyMyTeamUI)
end
function TeamPlatformSystem.ShowLobbyMyXMissionTeamUI()
  UIManager.ShowUI(UIManager.UI_Config.TPlan_TeamPlatform_MyTeam_UIBP)
end
function TeamPlatformSystem.CheckShowLobbyMyXMissionTeamUI()
  return UIManager.IsUIShow(UIManager.UI_Config.TPlan_TeamPlatform_MyTeam_UIBP)
end
function TeamPlatformSystem.ShowXMissionTeamPlatformMainUI()
  UIManager.ShowUI(UIManager.UI_Config.TPlan_TeamPlatform_UIBP)
end
function TeamPlatformSystem.CheckShowXMissionTeamPlatformMainUI()
  return UIManager.IsUIShow(UIManager.UI_Config.TPlan_TeamPlatform_UIBP)
end
function TeamPlatformSystem.CloseTeamPlatFormLinkUI()
  if UIManager.IsUIShow(UIManager.UI_Config.TeamPlatform_Recruit_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.TeamPlatform_Recruit_UIBP)
  end
  if UIManager.IsUIShow(UIManager.UI_Config.TeamPlatForm_Member_Detail_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.TeamPlatForm_Member_Detail_UIBP)
  end
end
function TeamPlatformSystem.CloseTPlanTeamPlatFormLinkUI()
  if UIManager.IsUIShow(UIManager.UI_Config.TPlan_TeamPlatform_Recruit_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.TPlan_TeamPlatform_Recruit_UIBP)
  end
  if UIManager.IsUIShow(UIManager.UI_Config.TeamPlatForm_Member_Detail_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.TeamPlatForm_Member_Detail_UIBP)
  end
end
function TeamPlatformSystem.ToFilterCondition()
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if not LogicTxMissionMain.IsInXMission() then
    local logic_team_platform_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_new)
    return logic_team_platform_new:ToFilterCondition()
  end
  local option = TeamPlatformSystem.GetFilterOption()
  local condition = {
    mode_list = {},
    lang = option.bOpenSameLanguage and 1 or 0,
    zone = option.nZoneID,
    segment_level = option.nMinSegment,
    mic_open = option.nSelectMicType,
    play_style = option.nPloy,
    kd = option.nKD,
    worth = option.nMinWorth
  }
  for i, v in ipairs(option.modeInfo) do
    local info = {
      [1] = v.nMatchID,
      [2] = v.nModeID
    }
    table.insert(condition.mode_list, info)
  end
  return condition
end
function TeamPlatformSystem.GetChatFilterCondition(isQuickJoin)
  local option = TeamPlatformSystem.GetPublishOption()
  log_tree(bWriteLog and "[v_wllwu] TeamPlatformSystem.GetChatFilterCondition ", option)
  local condition = {
    lang = option.bOpenSameLanguage and 1 or 0,
    zone = option.nZoneID,
    segment_level = option.nMinSegment,
    mic_open = option.nSelectMicType,
    play_style = option.nPloy,
    kd = option.nKD,
    worth = option.nMinWorth,
    perspective = option.nPerspective,
    playerNum = option.nPlayerNum
  }
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    condition.tab_id = C_TPLAN_TAB_ID
    condition.from = E_PublishRecruitMsgFromType.TPlanChat
  else
    condition.tab_id = option.nTabID
    condition.from = E_PublishRecruitMsgFromType.Chat
    local logic_team_platform_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_new)
    if not logic_team_platform_new:IsClassicRank(option.nTabID) then
      log(bWriteLog and "[v_wllwu] TeamPlatformSystem.GetChatFilterCondition reset segment_level")
      condition.segment_level = 0
    end
  end
  local logic_chat_filter_language = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_filter_language)
  condition.filter_langs = logic_chat_filter_language:GetCurSelectLanguageData()
  if not isQuickJoin then
    local info = {
      [1] = option.nMatchID,
      [2] = option.nViewID
    }
    condition.mode_list = {info}
  end
  return condition
end
function TeamPlatformSystem.SearchTeam(search_reason, is_use_cache)
  log(bWriteLog and "god test registerSuc SearchTeam " .. tostring(TeamPlatformSystem.registerSuc))
  if TeamPlatformSystem.IsIdle() and not TeamPlatformSystem.registerSuc then
    TeamPlatformSystem.RegisterIn()
  end
  local condition = TeamPlatformSystem.ToFilterCondition()
  local logic_team_platform_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_data)
  condition.filter_langs = logic_team_platform_data:GetProtoLangData()
  local logic_team_platform_utils = require("client.slua.logic.teamup.logic_team_platform_utils")
  condition.zone_list = logic_team_platform_utils.GetZoneList()
  local ConscribeHandler = require("client.network.Protocol.ConscribeHandler")
  ConscribeHandler.send_search_team_conscribe_req(condition, search_reason or 0)
  local TimeUtil = require("client.common.time_util")
  local curServerTime = TimeUtil.GetServerTimeInSec()
  TeamPlatformSystem.nLastSearchTeamTime = curServerTime
  log(bWriteLog and "[v_wllwu] TeamPlatformSystem.SearchTeam curServerTime is " .. tostring(curServerTime))
  if not is_use_cache then
    TeamPlatformSystem.nLastSearchTime = curServerTime
    return
  end
  if curServerTime - TeamPlatformSystem.nLastSearchTime < C_SearchIntervalTime then
    log(bWriteLog and "[v_wllwu] TeamPlatformSystem.SearchTeam lower 3, nLastSearchTime is " .. tostring(TeamPlatformSystem.nLastSearchTime))
    TeamPlatformSystem.HandleRequestTimeLimitError()
  end
  TeamPlatformSystem.nLastSearchTime = curServerTime
end
function TeamPlatformSystem.GetPublishCondition()
  local option = TeamPlatformSystem.GetPublishOption()
  local condition = {
    mode = option.nMatchID,
    sub_mode_group = option.nModeID,
    lang = option.bOpenSameLanguage and 1 or 0,
    zone = option.nZoneID,
    segment_level = option.nMinSegment,
    mic_open = option.nSelectMicType,
    play_style = option.nPloy,
    member_voice_invite = option.bMemberCanInvite and 1 or 0,
    kd = option.nKD,
    worth = option.nMinWorth,
    send_to_recruit_channel = true,
    tab_id = C_TPLAN_TAB_ID,
    from = TeamPlatformSystem.publishRecruitMsgFrom,
    hunted_rating = option.hunted_rating
  }
  return condition
end
function TeamPlatformSystem.UpdatePublishRecruitMsgFrom(from)
  if not from then
    return
  end
  TeamPlatformSystem.publishRecruitMsgFrom = from
end
function TeamPlatformSystem.GetPublishRecruitMsgFrom()
  return TeamPlatformSystem.publishRecruitMsgFrom
end
function TeamPlatformSystem.UpdatePublishRecruitConscribe(conscribe)
  if not conscribe then
    return
  end
  TeamPlatformSystem.publishRecruitConscribe = conscribe
  log(bWriteLog and "TeamPlatformSystem.UpdatePublishRecruitConscribe")
end
function TeamPlatformSystem.GetPublishRecruitConscribe()
  return TeamPlatformSystem.publishRecruitConscribe
end
function TeamPlatformSystem.RecruitTeam()
  local condition = TeamPlatformSystem.GetPublishCondition()
  local ConscribeHandler = require("client.network.Protocol.ConscribeHandler")
  ConscribeHandler.send_publish_team_conscribe_req(condition)
end
function TeamPlatformSystem.SendTaskRecruit(taskId, isRp, channel)
  local condition
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if not LogicTxMissionMain.IsInXMission() then
    local logic_team_platform_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_new)
    condition = logic_team_platform_new:GetPublishCondition()
  else
    condition = TeamPlatformSystem.GetPublishCondition()
  end
  condition.  condition.  condition.send_to_corps_channel = channel and channel.send_to_corps_channel
  condition.send_to_room_channel = channel and channel.send_to_room_channel
  local ConscribeHandler = require("client.network.Protocol.ConscribeHandler")
  ConscribeHandler.send_publish_team_conscribe_req(condition)
end
function TeamPlatformSystem.RegisterIn()
  local condition = TeamPlatformSystem.ToFilterCondition()
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    condition.from = E_PublishRecruitMsgFromType.TPlanTeamPlatForm
  elseif TeamPlatformSystem.nPlatformType == TeamPlatform_Macro.Enum_PlatformType.WoW then
    condition.from = E_PublishRecruitMsgFromType.WoWTeamPlatForm
  else
    condition.from = E_PublishRecruitMsgFromType.TeamPlatForm
  end
  local logic_team_platform_proto = require("client.slua.logic.teamup.logic_team_platform_proto")
  logic_team_platform_proto.send_register_idle_player_req(condition)
end
function TeamPlatformSystem.GetTeamPlatformInfo()
  local ConscribeHandler = require("client.network.Protocol.ConscribeHandler")
  ConscribeHandler.send_team_conscribe_info_req()
end
function TeamPlatformSystem.OnTeamConscribeSync(team_id, conscribe, reason)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamPlatformSystem.UpdatePublishRecruitConscribe(conscribe)
  local tempConscribe = conscribe or {}
  local mic_open = tempConscribe.mic_open
  if TeamUpNewSystem.teamInfo then
    TeamUpNewSystem.teamInfo.publish_conscribe = mic_open
  end
  log_tree("god test conscribe ", conscribe)
  log(bWriteLog and "[edward][logic_team_platform] TeamPlatformSystem.OnTeamConscribeSync reason = " .. tostring(reason))
  if reason == E_RecruitSyncReason.Timeout then
    TeamPlatformSystem.ClearRecruitInfo()
    ShowNotice(10318)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_RECRUIT_TIMEOUT)
  elseif reason == E_RecruitSyncReason.Cancel or reason == E_RecruitSyncReason.GameStart or reason == E_RecruitSyncReason.ChangeLeader or reason == E_RecruitSyncReason.TeamDismiss then
    local isOldLeader = false
    if TeamPlatformSystem.recruitInfo and TeamPlatformSystem.recruitInfo.conscribe and TeamPlatformSystem.recruitInfo.conscribe.leader == TeamUpNewSystem.GetSelfUID() then
      isOldLeader = true
    end
    TeamPlatformSystem.ClearRecruitInfo()
    if not TeamUpNewSystem.IsTeamLeader() or TeamUpNewSystem.GetTeamNum() == 1 then
      if reason == E_RecruitSyncReason.Cancel then
        if not isOldLeader then
          ShowNotice(10317)
        elseif TeamUpNewSystem.teamInfo then
          TeamUpNewSystem.teamInfo.id = 0
        end
      elseif reason == E_RecruitSyncReason.TeamDismiss or reason == E_RecruitSyncReason.ChangeLeader then
        if not isOldLeader then
          ShowNotice(11081)
        elseif reason == E_RecruitSyncReason.TeamDismiss and TeamUpNewSystem.teamInfo then
          TeamUpNewSystem.teamInfo.id = 0
        end
      end
    end
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_RECRUIT_CANCEL)
    if reason == E_RecruitSyncReason.ChangeLeader or reason == E_RecruitSyncReason.TeamDismiss then
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_CLOSE_MY_TEAM)
    end
    if reason == E_RecruitSyncReason.Cancel then
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_CANCEL)
    end
    local logic_lobby_my_team = require("client.slua.logic.teamup.logic_lobby_my_team")
    logic_lobby_my_team.ResetCancelRecruitTime()
  elseif reason == E_RecruitSyncReason.QuitTeam then
  else
    if not conscribe then
      TeamPlatformSystem.recruitInfo = nil
      return
    end
    if not TeamPlatformSystem.recruitInfo then
      TeamPlatformSystem.recruitInfo = {}
    end
    TeamPlatformSystem.recruitInfo.    TeamPlatformSystem.recruitInfo.    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_RECRUIT_UPDATE)
    if reason == E_RecruitSyncReason.Publish then
      if not TeamUpNewSystem.IsTeamLeader() then
        ShowNotice(10316)
      end
    elseif reason == E_RecruitSyncReason.Modify then
      if not TeamUpNewSystem.IsTeamLeader() then
        ShowNotice(10320)
      end
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_RECRUIT_MODIFY)
    end
    if reason == E_RecruitSyncReason.Publish or reason == E_RecruitSyncReason.JoinTeam then
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_RECRUIT_PUBLISH, reason, conscribe.mode, conscribe.view)
    end
  end
end
function TeamPlatformSystem.ClearLastSearchTeamList()
  log(bWriteLog and "[v_wllwu]  TeamPlatformSystem.ClearLastSearchTeamList")
  TeamPlatformSystem.lastSearchTeamLists = nil
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_CLEAR_CACHE_LIST)
end
function TeamPlatformSystem.OnSearchTeamConscribeRes(res, conscribes)
  TeamPlatformSystem.lastSearchTeamLists = conscribes
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_REFRESH_LIST, conscribes, true)
end
function TeamPlatformSystem.OnBatchGetTeamConscribesRes(res, conscribes)
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_REFRESH_LIST, conscribes, false)
end
function TeamPlatformSystem.HandleRequestTimeLimitError()
  if TeamPlatformSystem.lastSearchTeamLists then
    log_tree(bWriteLog and "TeamPlatformSystem.HandleRequestTimeLimitError lastSearchTeamLists is ", TeamPlatformSystem.lastSearchTeamLists)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_REFRESH_LIST, TeamPlatformSystem.lastSearchTeamLists, true, true)
  end
end
function TeamPlatformSystem.OnPublishTeamConscribeRes()
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_REFRESH_SUCCESS)
end
function TeamPlatformSystem.AddFriend(uid)
  if "" == uid then
    return
  end
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  logic_friend_apply:add_inner_friend_req(uid, "", BP_ENUM_ADD_FRIEND_FROM_TEAMFLATFORM, 41)
end
function TeamPlatformSystem.CheckPersonalCredit(err_code, kd)
  if err_code == 0 then
    TeamPlatformSystem.ableToEnter = true
    log(bWriteLog and "TeamPlatformSystem.ableToEnter = true")
    TeamPlatformSystem.UpdateSelfKdValue(kd)
  else
    TeamPlatformSystem.ableToEnter = false
  end
  TeamPlatformSystem.abletoEnterErrorCode = err_code
  log(bWriteLog and "[   " .. TeamPlatformSystem.abletoEnterErrorCode)
  if TeamPlatformSystem.isLoginReqGetKdValue then
    log(bWriteLog and "[v_wllwu] TeamPlatformSystem.CheckPersonalCredit isLoginReqGetKdValue")
    return
  end
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CREDIT_SYNC)
end
function TeamPlatformSystem.UpdateSelfKdValue(kd)
  TeamPlatformSystem.self_kd = kd or 0
  TeamPlatformSystem.isKdValueUpdated = true
  local TimeUtil = require("client.common.time_util")
  TeamPlatformSystem.lastUpdateKdValueTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "[v_wllwu] TeamPlatformSystem.UpdateSelfKdValue kd:" .. tostring(kd) .. " time = " .. tostring(TeamPlatformSystem.lastUpdateKdValueTime))
end
function TeamPlatformSystem.on_voice_feedback_update_notify(voice_feedback)
  DataMgr.roleData.  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  if profile then
    profile.  else
    log(bWriteLog and "profile is empty")
  end
end
function TeamPlatformSystem.SendRequestKdValue()
  if not TeamPlatformSystem.isNeedRequestKdData then
    log(bWriteLog and "[v_wllwu] TeamPlatformSystem.SendRequestKdValue return")
    return
  end
  log(bWriteLog and "[v_wllwu] TeamPlatformSystem.SendRequestKdValue enter")
  TeamPlatformSystem.isNeedRequestKdData = nil
  TeamPlatformSystem.CheckRequestKdValueUpdate()
end
return TeamPlatformSystem