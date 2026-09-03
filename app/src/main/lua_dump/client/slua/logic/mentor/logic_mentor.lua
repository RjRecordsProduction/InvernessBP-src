local EQualification = {
  None = 0,
  Mentee = 1,
  Mentor = 2,
  All = 3
}
local EGuideType = {
  MentorLoginLobbyTips = 1,
  MentorEmotion = 2,
  MenteeEmotion = 3,
  MentorOpenTips = 4,
  SegmentSlowEmotion = 5,
  SegmentSmallEmotion = 6
}
local EIdentity = {
  None = 0,
  Mentee = 1,
  Mentor = 2
}
local EWaitingStatus = {None = 0, Wait = 1}
local ETaskRefreshType = {
  Daily = 1,
  Weekly = 2,
  Mentor = 3
}
local MinSegNum = 104
local C_InitMatchIDFourTPP = 103
local C_InitMatchIDTwoTPP = 102
local C_InitMatchIDOneTPP = 101
local C_InitMatchIDFourFPP = 403
local C_InitMatchIDTwoFPP = 402
local C_InitMatchIDOneFPP = 401
local C_DefaultViewVersion = "3.9.0"
local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
local C_InitPerspective = ENUM_PerspectiveType.TPP
local C_InitPlayerNum = 4
local C_DefaultDeclarationID = 21
local MentorSystem = {
  EQualification = EQualification,
  EIdentity = EIdentity,
  EWaitingStatus = EWaitingStatus,
  EGuideType = EGuideType,
  mentor_recommends = {},
  mentor_data = {},
  voice_enable = false,
  sub_modes = {},
  is_open_voice = true,
  is_same_language = true,
  is_same_ploy = true,
  qualification = EQualification.None,
  identity = EIdentity.None,
  waiting_status = EWaitingStatus.None,
  combat_info = nil,
  system_status = -1,
  ban_notice = nil,
  leave_ban_time = nil,
  changed_tasks = nil,
  base_pos = {
    58,
    -360.0,
    -14440
  },
  matchOptionData = nil,
  award_common_status = false,
  award_permanent_status = false,
  award_mentor_status = false,
  have_level_award = false,
  emotion_type = {
    mentor = 1,
    mentee = 2,
    SegmentSlow = 5,
    SegmentSmall = 6
  },
  mentor_info = nil,
  mentor_login_lobby_tips = false,
  can_show_mentor_waiting_tips = false,
  mentor_team_requesting = {},
  mentor_team_waiting = false,
  mentor_team_waiting_handle = nil,
  mentor_team_waiting_time = 0,
  mentor_prematch_state_handle = nil,
  mentor_prematch_state_time = 0,
  mentor_team_respond_lobby = 0,
  LastRecommendTime = {},
  LastGetRecommendTime = 0,
  set_mentor_identity_req_id = 0,
  set_mentor_identity_req_cb = {},
  recommend_req_from = {
    FromMode = 1,
    FromRefresh = 2,
    FromOpen = 3,
    FromMentorChatChannel = 4
  },
  cur_recommend_req_from = 1,
  mentor_error = 0,
  mentee_error = 0,
  predictive_time = nil,
  bIsChangeMatchOption = false,
  LastMentorStatusReqTime = 0,
  MentorStatusReqInterval = 10,
  MentorStatusRspCallback = nil,
  battle_info_callback = nil,
  LastPredictiveWaitTimeReqTime = 0,
  AutoStartSearch = false,
  mentor_prematch_state = false,
  combat_info_sum_score = 75,
  can_show_waiting_long_tips = true,
  show_waiting_long_tips_handle = nil,
  awardRangeData = nil
}
function MentorSystem.init()
end
function MentorSystem.mentor_register_req()
  if DataMgr.roleData.credit < 60 then
    ShowNotice(9665)
    return
  end
  MentorSystem.bIsChangeMatchOption = false
  if not MentorSystem.matchOptionData then
    MentorSystem.LoadMatchOption()
  end
  log(bWriteLog and "[edward][logic_mentor] MentorSystem.mentor_register_req, mic state = " .. tostring(MentorSystem.matchOptionData.bIsOpenMic))
  local selectViewIDs = MentorSystem.matchOptionData.viewIDs
  selectViewIDs = {}
  for k, v in pairs(MentorSystem.matchOptionData.viewIDList or {}) do
    if v then
      table.insert(selectViewIDs, k)
    end
  end
  local multiSelectParam = {}
  local config = {}
  if MentorSystem.matchOptionData.nPerspective == ENUM_PerspectiveType.TPP then
    if MentorSystem.matchOptionData.nPlayerNumList[2] then
      local TableUtil = require("common.table_util")
      config[C_InitMatchIDTwoTPP] = TableUtil.CopyTable(selectViewIDs)
    end
    if MentorSystem.matchOptionData.nPlayerNumList[4] then
      local TableUtil = require("common.table_util")
      config[C_InitMatchIDFourTPP] = TableUtil.CopyTable(selectViewIDs)
    end
  else
    if MentorSystem.matchOptionData.nPlayerNumList[2] then
      local TableUtil = require("common.table_util")
      config[C_InitMatchIDTwoFPP] = TableUtil.CopyTable(selectViewIDs)
    end
    if MentorSystem.matchOptionData.nPlayerNumList[4] then
      local TableUtil = require("common.table_util")
      config[C_InitMatchIDFourFPP] = TableUtil.CopyTable(selectViewIDs)
    end
  end
  multiSelectParam[MentorSystem.matchOptionData.nZoneID] = config
  log_tree("[ZH]multiSelectParam", multiSelectParam)
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  MentorHandler.send_mentor_register_req(nil, MentorSystem.matchOptionData.bIsOpenMic, multiSelectParam)
end
function MentorSystem.mentor_register_rsp(err_code)
  if err_code == 0 then
    if MentorSystem.bIsChangeMatchOption then
      ShowNotice(8984)
      EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_UPDATE_MATCH_OPTION)
    end
    ShowNotice(9680)
  else
    log(bWriteLog and "mentor_register_rsp:" .. tostring(err_code))
    ShowNotice(err_code)
  end
  MentorSystem.bIsChangeMatchOption = false
end
function MentorSystem.mentor_unregister_req()
  log(bWriteLog and "mentor_unregister_req")
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  MentorHandler.send_mentor_unregister_req()
end
function MentorSystem.mentor_unregister_rsp()
  log(bWriteLog and "mentor_unregister_rsp")
  ShowNotice(9681)
end
function MentorSystem.start_get_mentor_status_req()
  MentorSystem.get_mentor_status_req()
end
function MentorSystem.get_mentor_status_req(Callback)
  log(bWriteLog and "get_mentor_status_req")
  local TimeUtil = require("client.common.time_util")
  if TimeUtil.GetServerTimeInSec() - MentorSystem.LastMentorStatusReqTime >= MentorSystem.MentorStatusReqInterval then
    MentorSystem.MentorStatusRsp    local MentorHandler = require("client.network.Protocol.MentorHandler")
    MentorHandler.send_get_mentor_status_req()
  elseif Callback then
    Callback()
  end
end
function MentorSystem.get_mentor_status_rsp(err_code, mentee_error, mentor_error, ban_notice, leave_ban_time)
  log(bWriteLog and "get_mentor_status_rsp:" .. tostring(err_code) .. ",mentor_error," .. tostring(mentee_error) .. ",mentor_error:" .. tostring(mentor_error) .. ",ban_notice:" .. tostring(ban_notice) .. ",leave_ban_time:" .. tostring(leave_ban_time))
  if err_code == 100080015 then
    MentorSystem.system_status = 1
  elseif err_code == 100080016 then
    MentorSystem.system_status = 2
  elseif err_code == 100080014 then
    MentorSystem.system_status = 3
  elseif err_code == 100080039 then
    MentorSystem.system_status = 4
  elseif err_code == 0 then
    MentorSystem.system_status = 0
  elseif err_code == 100080041 then
    ShowNotice(LocUtil.LocalizeResFormat(200000094, ""))
    return
  elseif err_code == 100000004 then
    ShowNotice(err_code)
  end
  MentorSystem.  MentorSystem.  MentorSystem.  MentorSystem.  local TimeUtil = require("client.common.time_util")
  MentorSystem.LastMentorStatusReqTime = TimeUtil.GetServerTimeInSec()
  if MentorSystem.MentorStatusRspCallback then
    MentorSystem.MentorStatusRspCallback()
    MentorSystem.MentorStatusRspCallback = nil
  end
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_STATUS_NOTIFY)
end
function MentorSystem.OpenIdentitySelect()
  MentorSystem.get_role_combat_info_req(function()
    UIManager.ShowUI(UIManager.UI_Config.mentor_identity_select, MentorSystem.identity == EIdentity.None)
  end)
end
function MentorSystem.JumpToMentor(_, _, jump_args)
  log(bWriteLog and "MentorSystem.JumpToMentor")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  if not LobbySystem.CheckOpen(94001) or Client.IsEmulator() then
    ShowNotice(8943)
    return
  end
  if UIManager.IsUIShow(UIManager.UI_Config.ui_room_waiting) then
    ShowNotice(9678)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInLargeTeam() then
    ShowNotice(27571)
    return false
  end
  if not MentorSystem.IsInTargetMode(true) then
    return
  end
  if MentorSystem.system_status == -1 then
    ShowNotice(8941)
  elseif MentorSystem.system_status == 1 then
    ShowNotice(8943)
  elseif MentorSystem.system_status == 2 then
    ShowNotice(8944)
  elseif MentorSystem.system_status == 3 then
    if MentorSystem.ban_notice and MentorSystem.leave_ban_time then
      local TimeUtil = require("client.common.time_util")
      local remainMinutes = math.ceil((MentorSystem.leave_ban_time - TimeUtil.GetServerTimeInSec()) / 60)
      ShowNotice(LocUtil.LocalizeResFormat(MentorSystem.ban_notice, remainMinutes))
    else
      ShowNotice(100080014)
    end
  elseif MentorSystem.system_status == 4 then
    ShowNotice(11548)
  elseif MentorSystem.system_status == 0 then
    if MentorSystem.qualification == EQualification.None then
      MentorSystem.ShowRestriction()
    elseif MentorSystem.identity == EIdentity.None then
      MentorSystem.OpenIdentitySelect()
    else
      MentorSystem.ShowMainUI()
      if jump_args and jump_args.open_record then
        local logic_mentor_record = require("client.slua.logic.mentor.logic_mentor_record")
        logic_mentor_record.OpenMentorRecord()
      end
    end
  end
end
function MentorSystem.ShowMainUI()
  MentorSystem.GetServerTableData()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.get_switch_status() then
    TeamUpNewSystem.ShowUI(TeamUpNewSystem.E_UI_TYPE.MentorUI)
  else
    local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
    ui_jump_manager.Clear()
    UIManager.ShowUI(UIManager.UI_Config.mentor_mentee_change)
  end
  local logic_mentor_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mentor_new)
end
function MentorSystem.GetMentorTaskCfg(nTaskId)
  local sCfgName = "MentorTaskCfg"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    sCfgName = "MentorTaskCfg_JK"
  end
  return CDataTable.GetTableData(sCfgName, nTaskId)
end
function MentorSystem.GetMentorTaskAllRewardData(nTaskId)
  local uTaskCfg = MentorSystem.GetMentorTaskCfg(nTaskId)
  if not uTaskCfg then
    return {}
  end
  local tAllReward = {}
  for i = 1, 2 do
    if uTaskCfg["res_id" .. i] ~= 0 then
      table.insert(tAllReward, {
        resid = uTaskCfg["res_id" .. i],
        count = uTaskCfg["res_num" .. i]
      })
    end
  end
  return tAllReward
end
function MentorSystem.GetMentorAllTaskCfg()
  local sCfgName = "MentorTaskCfg"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    sCfgName = "MentorTaskCfg_JK"
  end
  return CDataTable.GetTable(sCfgName)
end
function MentorSystem.GetServerTableData()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local mentor_award_table_callBack = function()
    EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_RECORD_GET_REWARD)
    MentorSystem.InitAwardRangeData()
  end
  BasicDataServerTable:GetOrReqData(data_config_marco.mentor_award_table, mentor_award_table_callBack)
end
function MentorSystem.InitAwardRangeData()
  if MentorSystem.awardRangeData ~= nil then
    return
  end
  MentorSystem.awardRangeData = {}
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local awardTable = BasicDataServerTable:GetCacheData(data_config_marco.mentor_award_table)
  for star, teamAwards in pairs(awardTable) do
    for teamNum, awardList in pairs(teamAwards) do
      if not MentorSystem.awardRangeData[teamNum] then
        MentorSystem.awardRangeData[teamNum] = {}
      end
      for _, awardData in pairs(awardList) do
        for i = 1, #awardData.awards do
          local award = awardData.awards[i]
          local itemID = award.resid
          if not MentorSystem.awardRangeData[teamNum][itemID] then
            MentorSystem.awardRangeData[teamNum][itemID] = {min = 999, max = 0}
          end
          local count = award.count
          local pre = MentorSystem.awardRangeData[teamNum][itemID]
          local preMin = pre.min
          local preMax = pre.max
          MentorSystem.awardRangeData[teamNum][itemID].max = math.max(preMax, count)
          MentorSystem.awardRangeData[teamNum][itemID].min = math.min(preMin, count)
        end
      end
    end
  end
  log_tree("MentorSystem.InitAwardRangeData awardRangeData = ", MentorSystem.awardRangeData)
end
function MentorSystem.GetAwardRangeData(memNum)
  return MentorSystem.awardRangeData and MentorSystem.awardRangeData[memNum] or {}
end
function MentorSystem.ShowRestriction()
  local minLevel = 999
  for i, v in pairs(CDataTable.GetTable("MentorLevelLimit")) do
    if minLevel > v.MiniLevel then
      minLevel = v.MiniLevel
    end
  end
  local requirement_seg = MentorSystem.GetMentorParam("requirement_seg", MinSegNum)
  local cfg2 = FuncUtil.GetRankTableData(requirement_seg)
  if not cfg2 then
    log(bWriteLog and "MentorSystem.ShowRestriction segment cfg is nil")
    return
  end
  ShowNotice(LocUtil.LocalizeResFormat(9328, minLevel, cfg2.Name))
end
function MentorSystem.mentor_status_sync(reason, qualification, identity, waiting_status)
  log(bWriteLog and "mentor_status_sync qualification:" .. tostring(qualification) .. ",identity:" .. tostring(identity) .. ",waiting_status:" .. tostring(waiting_status))
  MentorSystem.qualification = qualification or MentorSystem.qualification
  MentorSystem.identity = identity or MentorSystem.identity
  MentorSystem.waiting_status = waiting_status or MentorSystem.waiting_status
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_STATUS_NOTIFY)
  MentorSystem.CheckShowWaitingLongTips()
end
function MentorSystem.set_mentor_identity_req(identity, cb)
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  MentorSystem.set_mentor_identity_req_id = MentorSystem.set_mentor_identity_req_id + 1
  MentorSystem.set_mentor_identity_req_cb[MentorSystem.set_mentor_identity_req_id] = cb
  log(bWriteLog and "set_mentor_identity_req:" .. tostring(identity) .. ",req_id:" .. tostring(MentorSystem.set_mentor_identity_req_id))
  MentorHandler.send_set_mentor_identity_req(identity, MentorSystem.set_mentor_identity_req_id)
end
function MentorSystem.set_mentor_identity_rsp(err_code, req_id)
  log(bWriteLog and "set_mentor_identity_rsp:" .. tostring(err_code) .. ",req_id:" .. tostring(req_id))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  MentorSystem.LoadMatchOption()
  if MentorSystem.set_mentor_identity_req_cb[req_id] then
    MentorSystem.set_mentor_identity_req_cb[req_id]()
    MentorSystem.set_mentor_identity_req_cb[req_id] = nil
  end
  if MentorSystem.AutoStartSearch then
    MentorSystem.AutoStartSearch = false
    MentorSystem.mentor_register_req()
  end
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_IDENTITY)
end
function MentorSystem.mentor_recommend_all_req(from)
  local updateUIDs = {}
  local num = 0
  for _, info in ipairs(MentorSystem.mentor_recommends) do
    if not MentorSystem.is_inviting_one(info.uid) then
      updateUIDs[tonumber(info.uid)] = true
      num = num + 1
    end
  end
  if num == 0 and #MentorSystem.mentor_recommends == 3 then
    ShowNotice(9321)
    return false
  end
  local count = 3 - #MentorSystem.mentor_recommends + num
  return MentorSystem.mentor_recommend_req(count, from, updateUIDs, true)
end
function MentorSystem.mentor_recommend_one_req(from, updateUID, isCD)
  return MentorSystem.mentor_recommend_req(1, from, {
    [tonumber(updateUID)] = true
  }, isCD)
end
function MentorSystem.mentor_recommend_req(count, from, updateUIDs, isCD)
  log(bWriteLog and "mentor_recommend_req:" .. tostring(count))
  log_tree("mentor_recommend_req updateUIDs", updateUIDs)
  MentorSystem.bIsChangeMatchOption = false
  local TimeUtil = require("client.common.time_util")
  if isCD then
    from = from or MentorSystem.recommend_req_from.FromRefresh
    local refresh_CD = MentorSystem.GetMentorParam("refresh_CD", 5)
    MentorSystem.LastRecommendTime[from] = MentorSystem.LastRecommendTime[from] or 0
    if refresh_CD > TimeUtil.GetServerTimeInSec() - MentorSystem.LastRecommendTime[from] then
      if from == MentorSystem.recommend_req_from.FromMode then
        local remain = refresh_CD - (TimeUtil.GetServerTimeInSec() - MentorSystem.LastRecommendTime[from])
        ShowNotice(LocUtil.LocalizeResFormat(9323, remain))
      else
        ShowNotice(120164)
      end
      return false
    end
    MentorSystem.LastRecommendTime[from] = TimeUtil.GetServerTimeInSec()
  end
  MentorSystem.cur_recommend_req_  local matchOptionData = MentorSystem.matchOptionData
  log(bWriteLog and "[ZH]mentor_recommend_req:" .. tostring(MentorSystem.is_open_voice) .. ",is_same_language:" .. tostring(MentorSystem.is_same_language) .. ",nZoneID:" .. tostring(matchOptionData.nZoneID) .. ",nMatchID:" .. tostring(matchOptionData.nMatchID) .. ",bAutoMatch:" .. tostring(matchOptionData.bAutoMatch) .. ",is_same_ploy:" .. tostring(MentorSystem.is_same_ploy))
  log_tree("matchOptionData", matchOptionData)
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  local subviews = matchOptionData.viewIDs
  subviews = {}
  for k, v in pairs(matchOptionData.viewIDList) do
    if v then
      table.insert(subviews, k)
    end
  end
  log_tree("[ZH] subviews", subviews)
  MentorHandler.send_mentor_recommend_req(count, matchOptionData.nZoneID, matchOptionData.nMatchID, subviews, matchOptionData.bAutoMatch and 1 or 0, MentorSystem.is_open_voice, MentorSystem.is_same_language, updateUIDs, MentorSystem.is_same_ploy)
  return true
end
MentorSystem.bDebugMentorRecommend = false
function MentorSystem.mentor_recommend_rsp(err_code, data, updateUIDs, fill_other_language_notice)
  log(bWriteLog and "mentor_recommend_rsp:" .. tostring(err_code))
  log_tree("mentor_recommend_rsp updateUIDs", updateUIDs)
  log_tree("data", data)
  if err_code ~= 0 then
    MentorSystem.bIsChangeMatchOption = false
    EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_RECOMMEND, data)
    ShowNotice(LocUtil.LocalizeResFormat(err_code))
    return
  end
  if MentorSystem.bIsChangeMatchOption then
    MentorSystem.bIsChangeMatchOption = false
    ShowNotice(8984)
    EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_UPDATE_MATCH_OPTION)
  end
  local TimeUtil = require("client.common.time_util")
  MentorSystem.LastGetRecommendTime = TimeUtil.GetServerTimeInSec()
  local AllUiD = {}
  for _, info in ipairs(MentorSystem.mentor_recommends) do
    AllUiD[tonumber(info.uid)] = true
  end
  local NoSameData = {}
  for _, info in ipairs(data) do
    MentorSystem.HandleDeclarationInMentorData(info)
    if not AllUiD[tonumber(info.uid)] then
      table.insert(NoSameData, info)
    end
  end
  if #NoSameData == 0 then
    EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_RECOMMEND, data)
    ShowNotice(LocUtil.LocalizeResFormat(9209))
    return
  end
  local index = 1
  local debugInfo = {
    replacedPlayers = {},
    insertedPlayers = {},
    backendData = data,
    deduplicatedData = NoSameData,
    originalCache = {}
  }
  for i, info in ipairs(MentorSystem.mentor_recommends) do
    debugInfo.originalCache[i] = {
      uid = info.uid
    }
    if updateUIDs[tonumber(info.uid)] then
      local target = NoSameData[index]
      if target then
        table.insert(debugInfo.replacedPlayers, {
          oldUid = info.uid,
          newUid = target.uid
        })
        MentorSystem.mentor_recommends[i] = target
        index = index + 1
      end
    end
  end
  for i = index, #NoSameData do
    if #MentorSystem.mentor_recommends < 3 then
      table.insert(debugInfo.insertedPlayers, {
        uid = NoSameData[i].uid
      })
      table.insert(MentorSystem.mentor_recommends, NoSameData[i])
    end
  end
  if MentorSystem.bDebugMentorRecommend then
    local uids = {}
    for k, v in pairs(NoSameData) do
      table.insert(uids, v.uid)
    end
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(uids, function()
      MentorSystem.OutputRecommendDebugLog(debugInfo)
    end, Enum_PROFILE_REPORT_CFG.MENTOR, 100)
  end
  if MentorSystem.cur_recommend_req_from == MentorSystem.recommend_req_from.FromRefresh then
    if fill_other_language_notice then
      ShowNotice(LocUtil.LocalizeResFormat(10445))
    else
      ShowNotice(9211)
    end
  elseif fill_other_language_notice then
    ShowNotice(LocUtil.LocalizeResFormat(10445))
  end
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_RECOMMEND, data)
end
function MentorSystem.PlayerNumChanged()
  MentorSystem.LastGetRecommendTime = 0
end
function MentorSystem.get_mentor_data_req()
  log(bWriteLog and "get_mentor_data_req")
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  MentorHandler.send_get_mentor_data_req()
end
function MentorSystem.SetMentorRecommendDebug(bEnable)
  MentorSystem.bDebugMentorRecommend = bEnable
  log(bWriteLog and string.format("MentorSystem.SetMentorRecommendDebug: %s", tostring(bEnable)))
end
function MentorSystem.IsMentorRecommendDebugEnabled()
  return MentorSystem.bDebugMentorRecommend
end
function MentorSystem.OutputRecommendDebugLog(debugInfo)
  if not debugInfo then
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local debugText = "=== \229\175\188\229\184\136\230\142\168\232\141\144\231\179\187\231\187\159Debug\230\151\165\229\191\151 ===\n"
  debugText = debugText .. "\227\128\144\229\144\142\229\143\176\228\184\139\229\143\145\231\142\169\229\174\182\230\149\176\230\141\174\227\128\145(\229\133\177" .. #debugInfo.backendData .. "\228\186\186):\n"
  for i, info in ipairs(debugInfo.backendData) do
    local playerName = logic_profile:GetNickName(info.uid) or "\230\156\170\231\159\165"
    debugText = debugText .. "  " .. i .. ". UID:" .. info.uid .. " \229\167\147\229\144\141:" .. playerName .. "\n"
  end
  debugText = debugText .. "\n\227\128\144\229\142\187\233\135\141\229\144\142\230\150\176\230\149\176\230\141\174\227\128\145(\229\133\177" .. #debugInfo.deduplicatedData .. "\228\186\186):\n"
  for i, info in ipairs(debugInfo.deduplicatedData) do
    local playerName = logic_profile:GetNickName(info.uid) or "\230\156\170\231\159\165"
    debugText = debugText .. "  " .. i .. ". UID:" .. info.uid .. " \229\167\147\229\144\141:" .. playerName .. "\n"
  end
  debugText = debugText .. "\n\227\128\144\230\155\180\230\150\176\229\137\141\229\174\162\230\136\183\231\171\175\231\188\147\229\173\152\227\128\145(\229\133\177" .. #debugInfo.originalCache .. "\228\186\186):\n"
  for i, info in ipairs(debugInfo.originalCache) do
    local playerName = logic_profile:GetNickName(info.uid) or "\230\156\170\231\159\165"
    debugText = debugText .. "  " .. i .. ". UID:" .. info.uid .. " \229\167\147\229\144\141:" .. playerName .. "\n"
  end
  if #debugInfo.replacedPlayers > 0 then
    debugText = debugText .. "\n\227\128\144\230\155\191\230\141\162\230\147\141\228\189\156\232\174\176\229\189\149\227\128\145(\229\133\177" .. #debugInfo.replacedPlayers .. "\230\172\161\230\155\191\230\141\162):\n"
    for i, replaceInfo in ipairs(debugInfo.replacedPlayers) do
      local oldPlayerName = logic_profile:GetNickName(replaceInfo.oldUid) or "\230\156\170\231\159\165"
      local newPlayerName = logic_profile:GetNickName(replaceInfo.newUid) or "\230\156\170\231\159\165"
      debugText = debugText .. "  " .. i .. ". UID:" .. replaceInfo.oldUid .. "(" .. oldPlayerName .. ") \232\162\171\230\155\191\230\141\162\228\184\186 UID:" .. replaceInfo.newUid .. "(" .. newPlayerName .. ")\n"
    end
  else
    debugText = debugText .. "\n\227\128\144\230\155\191\230\141\162\230\147\141\228\189\156\232\174\176\229\189\149\227\128\145\230\151\160\230\155\191\230\141\162\230\147\141\228\189\156\n"
  end
  if 0 < #debugInfo.insertedPlayers then
    debugText = debugText .. "\n\227\128\144\230\143\146\229\133\165\230\147\141\228\189\156\232\174\176\229\189\149\227\128\145(\229\133\177" .. #debugInfo.insertedPlayers .. "\228\186\186\230\143\146\229\133\165):\n"
    for i, insertInfo in ipairs(debugInfo.insertedPlayers) do
      local playerName = logic_profile:GetNickName(insertInfo.uid) or "\230\156\170\231\159\165"
      debugText = debugText .. "  " .. i .. ". \230\143\146\229\133\165 UID:" .. insertInfo.uid .. " \229\167\147\229\144\141:" .. playerName .. "\n"
    end
  else
    debugText = debugText .. "\n\227\128\144\230\143\146\229\133\165\230\147\141\228\189\156\232\174\176\229\189\149\227\128\145\230\151\160\230\143\146\229\133\165\230\147\141\228\189\156\n"
  end
  debugText = debugText .. "\n\227\128\144\230\155\180\230\150\176\229\144\142\229\174\162\230\136\183\231\171\175\231\188\147\229\173\152\227\128\145(\229\133\177" .. #MentorSystem.mentor_recommends .. "\228\186\186):\n"
  for i, info in ipairs(MentorSystem.mentor_recommends) do
    local playerName = logic_profile:GetNickName(info.uid) or "\230\156\170\231\159\165"
    debugText = debugText .. "  " .. i .. ". UID:" .. info.uid .. " \229\167\147\229\144\141:" .. playerName .. "\n"
  end
  debugText = debugText .. "=== Debug\230\151\165\229\191\151\231\187\147\230\157\159 ==="
  log(bWriteLog and debugText)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, "Debug\230\151\165\229\191\151", debugText)
end
function MentorSystem.get_mentor_data_rsp(ret, mentor_data)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  log_tree("get_mentor_data_rsp", mentor_data)
  MentorSystem.HandleDeclarationInMentorData(mentor_data)
  MentorSystem._  MentorSystem.mentor_data.uid = DataMgr.roleData.uid
  MentorSystem.Construct_Mentor_Data()
end
function MentorSystem.GetDisplayAwards()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local AwardsAll = {}
  local data_config_marco = require("client.logic.data.data_config_marco")
  local mentor_award_table = BasicDataServerTable:GetCacheData(data_config_marco.mentor_award_table)
  if not mentor_award_table then
    return {}
  end
  local uMentorAllTask = MentorSystem.GetMentorAllTaskCfg()
  for _, task_data in pairs(uMentorAllTask) do
    local nItemId = task_data.res_id1
    if nItemId and nItemId ~= 0 then
      AwardsAll[nItemId] = true
    end
  end
  for award, mode_data in pairs(mentor_award_table) do
    for i, star_data in pairs(mode_data) do
      for stage, data in pairs(star_data) do
        for index, award in pairs(data.awards) do
          AwardsAll[award.resid] = true
        end
      end
    end
  end
  local awards = {}
  for resid, _ in pairs(AwardsAll) do
    local item = CDataTable.GetTableData("Item", resid)
    if item then
      table.insert(awards, {
        resid = resid,
        quality = item.ItemQuality
      })
    end
  end
  table.sort(awards, function(left, right)
    return left.quality > right.quality
  end)
  return awards
end
function MentorSystem.Construct_Mentor_Data()
  local _mentor_data = MentorSystem._mentor_data
  local mentor_data = {}
  local base_info = {
    count = _mentor_data.count,
    identity = _mentor_data.identity,
    labels = _mentor_data.labels,
    evaluate = _mentor_data.evaluate,
    use_microphone = _mentor_data.use_microphone or false,
    uid = DataMgr.roleData.uid,
    kd = _mentor_data.kd_v2 or _mentor_data.kd,
    grade = _mentor_data.grade,
    evaluate_cnt = _mentor_data.evaluate_cnt,
    top10_rates = _mentor_data.top10_rates or 0,
    match_strategy = DataMgr.MatchStrategy,
    level = _mentor_data.level or 1,
    exp = _mentor_data.exp or 0,
    exp_unclaimed = _mentor_data.exp_unclaimed or 0,
    brand = _mentor_data.brand or 0,
    medal = _mentor_data.medal or 0,
    award_rate = _mentor_data.award_rate or 1.0,
    mentor_declaration = _mentor_data.mentor_declaration or ""
  }
  mentor_data.  local MentorLevelAwardSystem = require("client.slua.logic.mentor.logic_mentor_level_award")
  for key, _ in pairs(MentorLevelAwardSystem.info) do
    if _mentor_data[key] then
      MentorLevelAwardSystem.info[key] = _mentor_data[key]
    end
  end
  for task_id, task_status in pairs(_mentor_data.tasks) do
    local uTaskCfg = MentorSystem.GetMentorTaskCfg(task_id)
    if uTaskCfg then
      if uTaskCfg.refresh_type == ETaskRefreshType.Daily then
        local task = {}
        task.status = task_status.stat
        task.progress = task_status.progress
        task.        task.title_id = 8957
        task.title_tips = 8958
        mentor_data.daily_      elseif uTaskCfg.refresh_type == ETaskRefreshType.Weekly then
        local task = {}
        task.status = task_status.stat
        task.progress = task_status.progress
        task.        task.title_id = 8959
        task.title_tips = 8960
        mentor_data.weekly_      elseif uTaskCfg.refresh_type == ETaskRefreshType.Mentor then
        local task = {}
        task.status = task_status.stat
        task.progress = task_status.progress
        task.        task.mentor_cnt = uTaskCfg.mentor_cnt
        if not mentor_data.times_task then
          mentor_data.times_task = {}
        end
        table.insert(mentor_data.times_task, task)
      end
    end
  end
  if mentor_data.times_task then
    table.sort(mentor_data.times_task, function(left, right)
      return left.mentor_cnt < right.mentor_cnt
    end)
  end
  MentorSystem.  MentorSystem.LoadMatchOption()
  if MentorSystem.AutoStartSearch then
    MentorSystem.AutoStartSearch = false
    MentorSystem.mentor_register_req()
  end
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_DATA, mentor_data)
end
function MentorSystem.BackToLobbyScene()
  LobbySceneManager.LoadStreamLevel(false, LobbySceneManager.LEVEL_NAME.MENTORBGMESH)
end
function MentorSystem.ChangeScene()
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyUI(false)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  LobbySceneManager.LoadStreamLevel(true, LobbySceneManager.LEVEL_NAME.MENTORBGMESH, 10006)
  LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_LOBBY)
end
function MentorSystem.get_role_combat_info_req(callback)
  if MentorSystem.combat_info ~= nil then
    callback()
    return
  end
  MentorSystem.battle_info_  DataMgr.fillMaxSegmentInfo()
  log(bWriteLog and "MentorSystem get_role_combat_info_req, zoneId = " .. DataMgr.maxSegment.zoneid)
  local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
  SocialLobbyHandler.send_get_role_battle_info(tonumber(DataMgr.roleData.uid), tonumber(DataMgr.roleData.uid), BP_COMBAT_MSG_TYPE_MENTOR, DataMgr.maxSegment.zoneid)
end
function MentorSystem.get_role_combat_info_rsp(res, callback_uid, optype, role_combat_info, zoneid, curseasonid, allseasonlist)
  log(bWriteLog and "MentorSystem get_role_combat_info_rsp curseasonid:" .. tostring(curseasonid) .. ",res:" .. tostring(res) .. ",optype:" .. tostring(optype))
  if optype ~= BP_COMBAT_MSG_TYPE_MENTOR then
    return
  end
  if res ~= 0 then
    log_error("Error: " .. res)
    return
  end
  log_tree("DataMgr.maxSegment", DataMgr.maxSegment)
  local combat_info
  if DataMgr.maxSegment.segmentType == enum_SegmentType.solo then
    combat_info = role_combat_info.warsolo
  elseif DataMgr.maxSegment.segmentType == enum_SegmentType.double then
    combat_info = role_combat_info.warduo
  elseif DataMgr.maxSegment.segmentType == enum_SegmentType.team then
    combat_info = role_combat_info.warsquad
  elseif DataMgr.maxSegment.segmentType == enum_SegmentType.fpp_solo then
    combat_info = role_combat_info.fppsolo
  elseif DataMgr.maxSegment.segmentType == enum_SegmentType.fpp_double then
    combat_info = role_combat_info.fppduo
  elseif DataMgr.maxSegment.segmentType == enum_SegmentType.fpp_team then
    combat_info = role_combat_info.fppsquad
  end
  log_tree("MentorSystem combat_info", combat_info)
  MentorSystem.  if MentorSystem.battle_info_callback then
    MentorSystem.battle_info_callback(combat_info)
  end
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_COMBAT_INFO, callback_uid)
end
function MentorSystem.GetRecommendedIdentity()
  if not MentorSystem.combat_info then
    return EIdentity.Mentee
  end
  local canBeMentor = MentorSystem.qualification == EQualification.All or MentorSystem.qualification == EQualification.Mentor
  return MentorSystem.combat_info.sum_score >= MentorSystem.combat_info_sum_score and canBeMentor and EIdentity.Mentor or EIdentity.Mentee
end
function MentorSystem.GetCurrGrade()
  if MentorSystem.combat_info then
    return MentorSystem.combat_info.grade
  end
  return ""
end
function MentorSystem.GetKD()
  if MentorSystem.combat_info then
    return MentorSystem.combat_info.kd_v2 or MentorSystem.combat_info.kd
  end
  return 0
end
function MentorSystem.mentor_team_request(tar_uid, is_again)
  log(bWriteLog and "mentor_team_request:" .. tostring(tar_uid))
  local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
  local netDelay = logic_zone_delay.GetChoosenZoneDelay(360, 10000)
  MentorSystem.mentor_team_requesting[tonumber(tar_uid)] = 0
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  local tar_uid_map = {
    [tar_uid] = true
  }
  MentorHandler.send_mentor_team_request(tar_uid_map, netDelay, is_again)
end
function MentorSystem.one_click_mentor_team_request(tar_uid_map)
  if not tar_uid_map then
    return
  end
  log_tree("MentorSystem.one_click_mentor_team_request tar_uid_map =", tar_uid_map)
  local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
  local netDelay = logic_zone_delay.GetChoosenZoneDelay(360, 10000)
  for _, uid in ipairs(tar_uid_map) do
    MentorSystem.mentor_team_requesting[tonumber(uid)] = 0
  end
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  MentorHandler.send_mentor_team_request(tar_uid_map, netDelay, false)
end
function MentorSystem.mentor_team_request_rsp(tar_uid_map, err_code, is_again)
  log(bWriteLog and "mentor_team_request_rsp: err_code:" .. tostring(err_code) .. ",is_again:" .. tostring(is_again))
  log_tree("MentorSystem.mentor_team_request_rsp tar_uid_map = ", tar_uid_map)
  if type(tar_uid_map) == "number" then
    tar_uid_map = {
      [tar_uid_map] = true
    }
  end
  if err_code ~= 0 then
    if is_again then
      ShowNotice(9220)
    else
      ShowNotice(err_code)
      if err_code == 100080024 then
        local recommend_uid_list = {}
        for _, info in ipairs(MentorSystem.mentor_recommends) do
          for tar_uid, _ in pairs(tar_uid_map) do
            if tonumber(info.uid) == tonumber(tar_uid) then
              table.insert(recommend_uid_list, tar_uid)
            end
          end
        end
        MentorSystem.mentor_recommend_req(#recommend_uid_list, MentorSystem.recommend_req_from.FromRefresh, recommend_uid_list, false)
      elseif err_code == 100080032 then
        MentorSystem.mentor_recommend_all_req(MentorSystem.recommend_req_from.FromRefresh)
      end
    end
    if UIManager.GetUI(UIManager.UI_Config.mentee_invite_wait) then
      UIManager.CloseUI(UIManager.UI_Config.mentee_invite_wait)
    end
    return
  end
  log(bWriteLog and "mentor_team_request_rsp1")
  local TimeUtil = require("client.common.time_util")
  for tar_uid, _ in pairs(tar_uid_map) do
    MentorSystem.mentor_team_requesting[tonumber(tar_uid)] = TimeUtil.GetServerTimeInSec()
  end
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_TEAM_REQUEST_RSP, tar_uid_map)
end
function MentorSystem.is_inviting_one(uid)
  local waiting_CD = MentorSystem.GetMentorParam("waiting_CD", 6)
  local TimeUtil = require("client.common.time_util")
  return waiting_CD >= TimeUtil.GetServerTimeInSec() - (MentorSystem.mentor_team_requesting[tonumber(uid)] or 0)
end
function MentorSystem.has_inviting()
  for _, info in ipairs(MentorSystem.mentor_recommends) do
    if MentorSystem.is_inviting_one(info.uid) then
      return true
    end
  end
  return false
end
function MentorSystem.mentor_team_request_notify(from_info)
  log_tree("mentor_team_request_notify from_info", from_info)
  local ShowInviteNotice = function()
    if IsWoWEditor then
      return
    end
    local ui = UIManager.GetUI(UIManager.UI_Config.mentee_invite_notice)
    if ui then
      ui:AddShowInfo(from_info)
    else
      UIManager.ShowUI(UIManager.UI_Config.mentee_invite_notice, from_info)
    end
  end
  log(bWriteLog and "InCombatState:" .. tostring(GameStatus.IsInFightingNotSocialNotMainCityNotHome()) .. ",BBattleResultRecieved:" .. tostring(NetUtil.BBattleResultRecieved))
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    if NetUtil.BBattleResultRecieved then
      ShowInviteNotice()
    else
      MentorSystem.mentor_team_respond(from_info.uid, 2)
    end
    return
  end
  ShowInviteNotice()
end
function MentorSystem.mentor_team_request_notify_others(from_uid)
  log(bWriteLog and "mentor_team_request_notify_others:" .. tostring(from_uid))
  MentorSystem.mentor_team_waiting = true
  local time_ticker = require("common.time_ticker")
  local waitTime = MentorSystem.GetMentorParam("waiting_CD", 6)
  MentorSystem.mentor_team_waiting_time = waitTime
  if MentorSystem.mentor_team_waiting_handle then
    time_ticker.RemoveTimer(MentorSystem.mentor_team_waiting_handle)
  end
  MentorSystem.mentor_team_waiting_handle = time_ticker.AddTimerLoop(1, function()
    if MentorSystem.mentor_team_waiting_time > 0 then
      MentorSystem.mentor_team_waiting_time = MentorSystem.mentor_team_waiting_time - 1
      EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_TEAM_REQUEST_NOTIFY_OTHERS, false)
    else
      MentorSystem.mentor_team_waiting = false
      EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_TEAM_REQUEST_NOTIFY_OTHERS, true)
      time_ticker.RemoveTimer(MentorSystem.mentor_team_waiting_handle)
      MentorSystem.mentor_team_waiting_handle = nil
    end
  end, TIMER_INFINITE, 1)
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_TEAM_REQUEST_NOTIFY_OTHERS, true)
end
function MentorSystem.mentor_team_respond(from_uid, is_accept)
  log(bWriteLog and "mentor_team_respond from_uid:" .. tonumber(from_uid) .. ",is_accept:" .. tostring(is_accept))
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  MentorHandler.send_mentor_team_respond(from_uid, is_accept)
end
function MentorSystem.mentor_team_respond_notify(mentor_uid, accept_status)
  log(bWriteLog and "mentor_team_request_notify:" .. tostring(mentor_uid) .. ",accept_status:" .. tostring(accept_status))
  if UIManager.GetUI(UIManager.UI_Config.mentee_invite_wait) then
    UIManager.CloseUI(UIManager.UI_Config.mentee_invite_wait)
  end
  MentorSystem.mentor_team_requesting[tonumber(mentor_uid)] = 0
  if accept_status == 1 then
  else
    local MatchSystem = require("client.slua.logic.match.logic_match")
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if MatchSystem.nMatchStatus == ENUM_MatchStatus.Not and not TeamUpNewSystem.IsInTeam() and not GameStatus.IsInFightingStatus() then
      ShowNotice(110011)
    end
  end
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_TEAM_RESPOND_NOTIFY, accept_status, mentor_uid)
end
function MentorSystem.mentor_team_request_cancel(tar_uid)
  log(bWriteLog and "mentor_team_request_cancel")
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  MentorHandler.send_mentor_team_request_cancel(tar_uid)
end
function MentorSystem.mentor_team_request_cancel_notify(from_info)
  log_tree("mentor_team_request_cancel_notify", from_info)
end
function MentorSystem.mentor_task_reward_req(task_id)
  log(bWriteLog and "mentor_task_reward_req:" .. tostring(task_id))
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  MentorHandler.send_mentor_task_reward_req(task_id)
  MentorSystem.mentor_award_stat_req()
end
function MentorSystem.mentor_task_reward_rsp(ret, task_id)
  log(bWriteLog and "mentor_task_reward_rsp:" .. tostring(ret) .. ",task_id:" .. tostring(task_id))
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  if MentorSystem._mentor_data then
    local task = MentorSystem._mentor_data.tasks[task_id]
    if task then
      task.stat = 2
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(MentorSystem.GetMentorTaskAllRewardData(task_id))
  end
  MentorSystem.Construct_Mentor_Data()
end
function MentorSystem.mentor_task_change_notify(change_tasks)
  log_tree("mentor_task_change_notify", change_tasks)
  MentorSystem.changed_tasks = change_tasks
  if MentorSystem._mentor_data then
    for task_id, task_status in pairs(change_tasks) do
      MentorSystem._mentor_data.tasks[task_id] = task_status
    end
    MentorSystem.Construct_Mentor_Data()
  end
end
function MentorSystem.GetChangedTaskTips()
  if not MentorSystem.changed_tasks or next(MentorSystem.changed_tasks) == nil then
    return ""
  end
  local ChangedTasks = {}
  for task_id, task_status in pairs(MentorSystem.changed_tasks) do
    local uConfig = MentorSystem.GetMentorTaskCfg(task_id)
    if uConfig then
      local task = {}
      task.status = task_status.stat
      task.progress = task_status.progress
      task.cfg = uConfig
      task.      table.insert(ChangedTasks, task)
    end
  end
  table.sort(ChangedTasks, function(left, right)
    local leftScore = 0
    local rightScore = 0
    if left.status == 1 then
      leftScore = leftScore + 1000
    end
    if left.cfg.refresh_type == 1 then
      leftScore = leftScore + 100
    elseif left.cfg.refresh_type == 2 then
      leftScore = leftScore + 10
    elseif left.cfg.refresh_type == 3 then
      leftScore = leftScore + 1
    end
    if right.status == 1 then
      rightScore = rightScore + 1000
    end
    if right.cfg.refresh_type == 1 then
      rightScore = rightScore + 100
    elseif right.cfg.refresh_type == 2 then
      rightScore = rightScore + 10
    elseif right.cfg.refresh_type == 3 then
      rightScore = rightScore + 1
    end
    return leftScore > rightScore
  end)
  local changedTask = ChangedTasks[1]
  log(bWriteLog and "GetChangedTaskTips:" .. tostring(changedTask.task_id))
  local task_cfg = MentorSystem.GetMentorTaskCfg(changedTask.task_id)
  if task_cfg then
    if task_cfg.refresh_type == 1 then
      return LocUtil.LocalizeResFormat(9202, changedTask.progress, changedTask.cfg.mentor_cnt)
    elseif task_cfg.refresh_type == 2 then
      return LocUtil.LocalizeResFormat(9203, changedTask.progress, changedTask.cfg.mentor_cnt)
    elseif task_cfg.refresh_type == 3 then
      return LocUtil.LocalizeResFormat(9204, changedTask.progress, changedTask.cfg.mentor_cnt)
    end
  end
  return ""
end
function MentorSystem.GetMentorParam(paramName, defaultValue)
  local paramCfg = CDataTable.GetTableData("MentorParamCfg", paramName)
  if not paramCfg then
    return defaultValue
  end
  return paramCfg.ParamValue
end
function MentorSystem.GetMenteeEvaluateTips(mentor_info)
  local point_mentee = MentorSystem.GetMentorParam("point_mentee", 5)
  if mentor_info.change_rank_rating and point_mentee <= mentor_info.change_rank_rating then
    return LocUtil.LocalizeResFormat(10465, mentor_info.change_rank_rating)
  end
  local rank_mentee = MentorSystem.GetMentorParam("rank_mentee", 20)
  if mentor_info.person_rank and rank_mentee >= mentor_info.person_rank then
    return LocUtil.LocalizeResFormat(10466, mentor_info.person_rank)
  end
  return LocUtil.LocalizeResFormat(10467)
end
function MentorSystem.GetMentorEvaluateTips(mentor_info)
  local point_mentee = MentorSystem.GetMentorParam("point_mentor", 5)
  if mentor_info.change_rank_rating and point_mentee <= mentor_info.change_rank_rating then
    return LocUtil.LocalizeResFormat(10465, mentor_info.change_rank_rating)
  end
  local rank_mentee = MentorSystem.GetMentorParam("rank_mentor", 20)
  if mentor_info.person_rank and rank_mentee >= mentor_info.person_rank then
    return LocUtil.LocalizeResFormat(10466, mentor_info.person_rank)
  end
  return LocUtil.LocalizeResFormat(11213)
end
function MentorSystem.OnGameStateChange(eventType, eventID, vars)
  log(bWriteLog and "MentorSystem.OnGameStateChange  curr:" .. vars.current .. ",pre:" .. vars.pre)
  if vars.current == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    MentorSystem.changed_tasks = nil
    MentorSystem.mentor_info = nil
    MentorSystem.mentor_login_lobby_tips = false
    MentorSystem.mentor_team_respond_lobby = 0
    MentorSystem.combat_info = nil
  end
  if vars.current == GameStatus.Lobby and vars.pre == GameStatus.Fighting then
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0.5, function()
      if GameStatus.IsInLobbyOrMainCity() and MentorSystem.mentor_info then
        if tonumber(DataMgr.roleData.uid) == tonumber(MentorSystem.mentor_info.mentee_id) and not MentorSystem.mentor_info.is_escape then
          log(bWriteLog and "MentorSystem.OnGameStateChange:mentee:" .. tostring(MentorSystem.mentor_info.mentee_id))
          if IsWoWEditor then
            return
          end
          UIManager.ShowUI(UIManager.UI_Config.mentee_evaluate_UI25, MentorSystem.mentor_info, true)
        elseif tonumber(DataMgr.roleData.uid) == tonumber(MentorSystem.mentor_info.mentor_id) then
          log(bWriteLog and "MentorSystem.OnGameStateChange:mentor:" .. tostring(MentorSystem.mentor_info.mentor_id))
          if IsWoWEditor then
            return
          end
          UIManager.ShowUI(UIManager.UI_Config.mentee_evaluate_UI25, MentorSystem.mentor_info, false)
        end
        if MentorSystem.mentor_team_respond_lobby ~= 0 then
          MentorSystem.mentor_team_respond(MentorSystem.mentor_team_respond_lobby, 1)
        end
      end
    end)
  end
  if vars.current == GameStatus.Lobby and (vars.pre ~= GameStatus.Fighting or MentorSystem.mentor_info) then
    MentorSystem.mentor_award_stat_req()
    MentorSystem.can_show_mentor_waiting_tips = true
    EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_GUIDE_CHANGE)
  end
  if GameStatus.IsInLobbyOrMainCity() then
    MentorSystem.can_show_waiting_long_tips = true
    MentorSystem.CheckShowWaitingLongTips()
  end
  if vars.current == GameStatus.Lobby and vars.pre == GameStatus.Login then
    local miniLevel = MentorSystem.GetMentorParam("newplayer_min", 3)
    local maxLevel = MentorSystem.GetMentorParam("newplayer_max", 10)
    if miniLevel <= DataMgr.roleData.level and maxLevel >= DataMgr.roleData.level then
      local common_save_game = require("client.logic.LogicPlayerPrefs.common_save_game")
      local Mentor_Lobby_Tips_Num = common_save_game.GetSaveData(common_save_game.Configs.Mentor_Lobby_Tips)
      Mentor_Lobby_Tips_Num = Mentor_Lobby_Tips_Num or 0
      if Mentor_Lobby_Tips_Num <= 2 then
        MentorSystem.mentor_login_lobby_tips = true
        common_save_game.SaveData(common_save_game.Configs.Mentor_Lobby_Tips, Mentor_Lobby_Tips_Num + 1)
        EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_LOGIN_LOBBY_TIPS)
      end
    end
  end
end
function MentorSystem.CheckShowWaitingLongTips()
  local timer_ticker = require("common.time_ticker")
  if MentorSystem.show_waiting_long_tips_handle then
    timer_ticker.RemoveTimer(MentorSystem.show_waiting_long_tips_handle)
    MentorSystem.show_waiting_long_tips_handle = nil
  end
  if MentorSystem.identity == EIdentity.Mentor and MentorSystem.waiting_status == EWaitingStatus.Wait then
    local waiting_guidetime = MentorSystem.GetMentorParam("waiting_guidetime", 30)
    MentorSystem.show_waiting_long_tips_handle = timer_ticker.AddTimerOnce(waiting_guidetime, function()
      if MentorSystem.identity == EIdentity.Mentor and MentorSystem.waiting_status == EWaitingStatus.Wait then
        local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
        if lobbyMain then
          local Lobby_Mid_Message_UIBP = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Message_UIBP)
          if Lobby_Mid_Message_UIBP then
            Lobby_Mid_Message_UIBP:TryShowTips(LobbyMidTipsType.SocialIsland)
          end
        end
      end
    end)
  end
end
function MentorSystem.mentor_award_stat_req()
  log(bWriteLog and "mentor_award_stat_req")
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  MentorHandler.send_mentor_award_stat_req()
end
function MentorSystem.mentor_award_stat_rsp(award_mentor_status, award_common_status, award_permanent_status, have_level_award)
  log(bWriteLog and "mentor_award_stat_rsp:award_mentor_status:" .. tostring(award_mentor_status) .. ",award_common_status:" .. tostring(award_common_status) .. ",award_permanent_status:" .. tostring(award_permanent_status) .. ",have_level_award:" .. tostring(have_level_award))
  MentorSystem.  MentorSystem.  MentorSystem.  MentorSystem.  local MentorRedPointData = require("client.slua.logic.mentor.mentor_reddot_data")
  MentorRedPointData.UpdateRedDot()
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_AWARD_STAT)
end
function MentorSystem.mentor_evaluate_notify(battle_id, stat, labels)
  log_tree("mentor_evaluate_notify", {
    battle_id = battle_id,
    stat = stat,
      })
  local logic_mentor_record = require("client.slua.logic.mentor.logic_mentor_record")
  if stat == logic_mentor_record.ENUM_HISTORY_RECORD_STAT.HISTORY_STAT_NOT_REWARD then
    MentorSystem.award_mentor_status = true
    local MentorRedPointData = require("client.slua.logic.mentor.mentor_reddot_data")
    MentorRedPointData.UpdateRedDot()
    EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_AWARD_STAT)
  end
end
function MentorSystem.get_mentor_predictive_wait_time_req()
  log(bWriteLog and "mentor_award_stat_req")
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  local TimeUtil = require("client.common.time_util")
  if TimeUtil.GetServerTimeInSec() - MentorSystem.LastPredictiveWaitTimeReqTime >= 10 then
    MentorHandler.send_get_mentor_predictive_wait_time_req()
  else
    EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_GET_MENTOR_PREDICTIVE_WAIT_TIME)
  end
end
function MentorSystem.get_mentor_predictive_wait_time_rsp(predictive_time)
  log(bWriteLog and "get_mentor_predictive_wait_time_rsp:" .. tostring(predictive_time))
  MentorSystem.  local TimeUtil = require("client.common.time_util")
  MentorSystem.LastPredictiveWaitTimeReqTime = TimeUtil.GetServerTimeInSec()
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_GET_MENTOR_PREDICTIVE_WAIT_TIME)
end
function MentorSystem.notify_mentee_is_in_team(mentee_id)
  log(bWriteLog and "notify_mentee_is_in_team:" .. tostring(mentee_id))
  ShowNotice(9335)
end
function MentorSystem.GetMentorWaitTips()
  if MentorSystem.predictive_time then
    if MentorSystem.predictive_time > 15 then
      return LocUtil.LocalizeResFormat(9198)
    else
      return LocUtil.LocalizeResFormat(9671, MentorSystem.predictive_time)
    end
  else
    return LocUtil.LocalizeResFormat(9198)
  end
end
function MentorSystem.mentor_emotion_report_req(stat)
  log(bWriteLog and "mentor_emotion_report_req:" .. tostring(stat))
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  MentorHandler.send_mentor_emotion_report_req(stat)
end
function MentorSystem.HasAward()
  return MentorSystem.award_common_status or MentorSystem.award_permanent_status or MentorSystem.award_mentor_status or MentorSystem.have_level_award
end
function MentorSystem.GetLobbyTaskTips()
  if MentorSystem.award_permanent_status then
    return LocUtil.LocalizeResFormat(8973), 1
  elseif MentorSystem.award_common_status then
    return LocUtil.LocalizeResFormat(8974), 2
  elseif MentorSystem.award_mentor_status then
    return LocUtil.LocalizeResFormat(8972), 3
  else
    return "", 0
  end
end
function MentorSystem.SetResultType(battle_result)
  MentorSystem.mentor_info = battle_result.mentor_info
  if MentorSystem.mentor_info then
    MentorSystem.mentor_info.is_escape = battle_result.is_escape == 1
    MentorSystem.mentor_info.person_rank = battle_result.person_rank
    if battle_result.rating then
      MentorSystem.mentor_info.change_rank_rating = battle_result.rating.change_rank_rating
    end
  end
  log_tree("SetResultType mentor_info", MentorSystem.mentor_info)
end
function MentorSystem.GetGuideStatus()
  if not MentorSystem.IsMentorOpen() then
    return nil
  end
  if MentorSystem.identity == EIdentity.Mentor and MentorSystem.waiting_status == EWaitingStatus.Wait then
    return nil
  end
  if MentorSystem.qualification == EQualification.None then
    return nil
  end
  local AccessRestrictionSystem = require("client.logic.common.logic_access_restriction")
  if not AccessRestrictionSystem.CheckAccess(AccessRestrictionSystem.EAccessType.Mentor) then
    return nil
  end
  local common_save_game = require("client.logic.LogicPlayerPrefs.common_save_game")
  local miniLevel = MentorSystem.GetMentorParam("newplayer_min", 3)
  if MentorSystem.mentor_login_lobby_tips then
    return {
      GuideType = EGuideType.MentorLoginLobbyTips,
      LocalRes = 8968
    }
  end
  if MentorSystem.mentor_info and MentorSystem.mentor_info.emotion then
    if MentorSystem.mentor_info.emotion == MentorSystem.emotion_type.mentor then
      return {
        GuideType = EGuideType.MentorEmotion,
        LocalRes = 8976
      }
    end
    if MentorSystem.mentor_info.emotion == MentorSystem.emotion_type.mentee then
      return {
        GuideType = EGuideType.MenteeEmotion,
        LocalRes = 8975
      }
    end
    if MentorSystem.mentor_info.emotion == MentorSystem.emotion_type.SegmentSlow then
      return {
        GuideType = EGuideType.SegmentSlowEmotion,
        LocalRes = 10442
      }
    end
    if MentorSystem.mentor_info.emotion == MentorSystem.emotion_type.SegmentSmall then
      return {
        GuideType = EGuideType.SegmentSmallEmotion,
        LocalRes = 10441
      }
    end
  end
  return nil
end
function MentorSystem.ResetGuide()
  MentorSystem.mentor_login_lobby_tips = false
  if MentorSystem.mentor_info then
    MentorSystem.mentor_info.emotion = nil
  end
  local common_save_game = require("client.logic.LogicPlayerPrefs.common_save_game")
  local miniLevel = MentorSystem.GetMentorParam("newplayer_min", 3)
  if miniLevel <= DataMgr.roleData.level and not common_save_game.GetSaveData(common_save_game.Configs.Mentor_Open_Tips) then
    common_save_game.SaveData(common_save_game.Configs.Mentor_Open_Tips)
  end
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_GUIDE_CHANGE)
end
function MentorSystem.IsMentorOpen()
  return LobbySystem.CheckOpen(94001) and not Client.IsEmulator() and MentorSystem.system_status == 0
end
function MentorSystem.ShowTips()
  local title = LocUtil.GetLocalizeResStr(9324)
  local levelLimit = CDataTable.GetTableData("MentorLevelLimit", 1)
  local new_maxlevel = MentorSystem.GetMentorParam("new_maxlevel", 701)
  local cfg = FuncUtil.GetRankTableData(new_maxlevel)
  local old_minlevel = MentorSystem.GetMentorParam("old_minlevel", 301)
  local cfg2 = FuncUtil.GetRankTableData(old_minlevel)
  local content = LocUtil.LocalizeResFormat(9340, levelLimit.MiniLevel, cfg.Name, cfg2.Name)
  UIManager.ShowUI(UIManager.UI_Config.HelpTip, 0, title, content)
end
function MentorSystem.GetMatchOption()
  if not MentorSystem.matchOptionData then
    MentorSystem.LoadMatchOption()
  end
  return MentorSystem.matchOptionData
end
function MentorSystem.SaveMatchOption(data, newViewIDs)
  MentorSystem.matchOptionData = data
  data.uid = DataMgr.roleData.uid
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if MentorSystem.identity == EIdentity.Mentee then
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eMentorMatch_Mentee)
  else
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eMentorMatch_Mentor)
  end
end
function MentorSystem.SetIsSendMsg(result)
  if result and result.mentor_reward then
    MentorSystem.isSendPrivilegeMsg = true
  end
end
function MentorSystem.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby and MentorSystem.isSendPrivilegeMsg then
    MentorSystem.mentor_award_stat_req()
    MentorSystem.isSendPrivilegeMsg = false
  end
end
function MentorSystem.SetMatchOptionZone(zoneID)
  if tonumber(DataMgr.season_id) >= 16 and MentorSystem.matchOptionData then
    MentorSystem.matchOptionData.nZoneID = zoneID
  end
end
function MentorSystem.LoadMatchOption()
  MentorSystem.LoadMatchOptionByNewMode()
end
function MentorSystem.GetMapInfo()
  local data = MentorSystem.GetMatchOption()
  local desc = ""
  local subviewIds = {}
  local downLoadMapList = MentorSystem.GetHadLoadMapList(data.viewIDList)
  if not downLoadMapList or not next(downLoadMapList) then
    desc = LocUtil.GetLocalizeResStr(500048)
  else
    for chooseViewId, isSelected in pairs(data.viewIDList) do
      if isSelected then
        for kk, downMapId in pairs(downLoadMapList) do
          if chooseViewId == downMapId then
            subviewIds[chooseViewId] = true
          end
        end
      end
    end
  end
  local mapNum = 0
  local subviewID = 0
  local name = ""
  for k, v in pairs(subviewIds) do
    if v then
      mapNum = mapNum + 1
      if subviewID == 0 then
        subviewID = k
      end
    end
  end
  if 1 < mapNum then
    name = LocUtil.LocalizeResFormat(500048, mapNum)
  else
    name = logic_mode_utils.GetMapNameByViewID(subviewID)
  end
  desc = name .. " (" .. LocUtil.GetLocalizeResStr(data.nPerspective or 100054) .. ")"
  return desc, data.nPlayerNum
end
function MentorSystem.GetHadLoadMapList(viewIDList)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local LogicModeMapDownLoad = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_map_download)
  local downloadViewList = {}
  for v, _ in pairs(viewIDList) do
    local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(v) or {}
    local mapkeyList = LogicModeMapDownLoad:GetMapKeyListByViewData(viewInfo) or {}
    local state = LogicModeMapDownLoad:GetMapListState(mapkeyList)
    if state == ENUM_DownloadState.Done then
      table.insert(downloadViewList, v)
    end
  end
  return downloadViewList
end
function MentorSystem.IsMentor()
  return MentorSystem.identity == EIdentity.Mentor
end
function MentorSystem.IsMentee()
  return MentorSystem.identity == EIdentity.Mentee
end
function MentorSystem.Handle_LogOut()
  log(bWriteLog and "MentorSystem.Handle_LogOut")
  MentorSystem.LastRecommendTime = {}
  MentorSystem.LastMentorStatusReqTime = 0
  MentorSystem.mentor_info = nil
  MentorSystem.system_status = -1
  MentorSystem.waiting_status = EWaitingStatus.None
end
function MentorSystem.on_enter_mentor_prematch_state()
  log(bWriteLog and "on_enter_mentor_prematch_state")
  MentorSystem.mentor_prematch_state = true
  local time_ticker = require("common.time_ticker")
  local state_time = MentorSystem.GetMentorParam("waiting_matchtime", 3)
  MentorSystem.mentor_prematch_  if MentorSystem.mentor_prematch_state_handle then
    time_ticker.RemoveTimer(MentorSystem.mentor_prematch_state_handle)
  end
  if MentorSystem.mentor_team_waiting_handle then
    time_ticker.RemoveTimer(MentorSystem.mentor_team_waiting_handle)
    MentorSystem.mentor_team_waiting = false
  end
  ShowNotice(LocUtil.LocalizeResFormat(10451, MentorSystem.mentor_prematch_state_time))
  MentorSystem.mentor_prematch_state_handle = time_ticker.AddTimer(1, function()
    while MentorSystem.mentor_prematch_state_time > 1 do
      MentorSystem.mentor_prematch_state_time = MentorSystem.mentor_prematch_state_time - 1
      ShowNotice(LocUtil.LocalizeResFormat(10451, MentorSystem.mentor_prematch_state_time))
      EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_PREMATCH_STATE, false)
      coroutine.yield(1)
    end
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    log_tree("TeamUpNewSystem.teamInfo", TeamUpNewSystem.teamInfo)
    if TeamUpNewSystem.IsTeamLeader() then
      MentorSystem.send_mentor_match_req()
      local TimeUtil = require("client.common.time_util")
      MentorSystem.send_temp = TimeUtil.GetServerTimeInSec()
    end
    MentorSystem.mentor_prematch_state = false
  end)
  local timer_ticker = require("common.time_ticker")
  timer_ticker.AddTimer(0.3, function()
    UIManager.AndroidBackToLobby()
  end)
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_PREMATCH_STATE, true)
end
function MentorSystem.on_quit_mentor_prematch_state()
  log(bWriteLog and "on_quit_mentor_prematch_state")
  MentorSystem.mentor_prematch_state = false
  if MentorSystem.mentor_prematch_state_handle then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(MentorSystem.mentor_prematch_state_handle)
  end
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_PREMATCH_STATE)
end
function MentorSystem.send_mentor_prematch_cancel_req()
  log(bWriteLog and "send_mentor_prematch_cancel_req")
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  MentorHandler.send_mentor_prematch_cancel_req()
end
function MentorSystem.send_mentor_match_req()
  log(bWriteLog and "send_mentor_match_req")
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  MentorHandler.send_mentor_match_req()
end
function MentorSystem.on_start_match_rsp()
  MentorSystem.mentor_prematch_state = false
end
function MentorSystem.on_match_res()
  MentorSystem.mentor_prematch_state = false
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_PREMATCH_STATE, true)
end
function MentorSystem.GetViewIDList()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local subViewIDList = {}
  local version_util = require("client.common.version_util")
  local StringUtil = require("common.string_util")
  local version = version_util.GetClientFormat(Client.GetAppVersion())
  local viewCfg = CDataTable.GetTableData("MentorMapCfg", version)
  viewCfg = viewCfg or CDataTable.GetTableData("MentorMapCfg", C_DefaultViewVersion)
  local _mapList = {}
  if viewCfg then
    local mapArr = StringUtil.Split(viewCfg.ViewIDs, "|")
    for _, viewID in ipairs(mapArr) do
      local id = tonumber(viewID)
      table.insert(_mapList, id)
    end
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for _, id in ipairs(_mapList) do
    local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(id)
    local isOpen = logic_mode_selection:IsThemeOpen(viewInfo, serverTime, false)
    if isOpen and not logic_mode_utils.IsRandomView(viewInfo) then
      table.insert(subViewIDList, id)
    end
  end
  return subViewIDList
end
function MentorSystem.LoadMatchOptionByNewMode()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local jsonInfo
  if MentorSystem.identity == EIdentity.Mentee then
    jsonInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMentorMatch_Mentee)
  else
    jsonInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMentorMatch_Mentor)
  end
  if not jsonInfo or type(jsonInfo) ~= "table" or next(jsonInfo) == nil then
    log(bWriteLog and "LoadMatchOption: use defualt")
    jsonInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMentorMatch)
    jsonInfo = jsonInfo or {}
  end
  if not jsonInfo.uid or jsonInfo.uid ~= DataMgr.roleData.uid then
    jsonInfo = {}
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local subviewIdList = MentorSystem.GetViewIDList()
  log_tree("[ZH] json", jsonInfo)
  local maxSegment, zoneID, perspective, playerNum, matchID
  local autoMatch = jsonInfo.bAutoMatch
  if autoMatch == nil then
    autoMatch = true
  end
  local modeIDs = jsonInfo.modeIDs
  local viewIDs
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local playerNumList = {}
  if MentorSystem.identity == EIdentity.Mentee then
    log(bWriteLog and "[ZH] mentee")
    maxSegment = DataMgr.GetMaxRankLevel()
    if tonumber(DataMgr.season_id) >= 16 then
      zoneID = ZoneSystem.nChooseZoneID
    else
      zoneID = jsonInfo.nZoneID or DataMgr.maxSegment.zoneid
      if zoneID == 0 then
        zoneID = 1
      end
    end
    if jsonInfo.nPerspective then
      perspective = jsonInfo.nPerspective
    elseif DataMgr.maxSegment.segmentType >= enum_SegmentType.solo and DataMgr.maxSegment.segmentType <= enum_SegmentType.team then
      perspective = ENUM_PerspectiveType.TPP
    else
      perspective = ENUM_PerspectiveType.FPP
    end
    local DuoSegment = math.max(DataMgr.maxSegmentDuo.SegmentLevel, DataMgr.maxSegmentDuoFpp.SegmentLevel)
    local SquadSegment = math.max(DataMgr.maxSegmentSquad.SegmentLevel, DataMgr.maxSegmentSquadFpp.SegmentLevel)
    if jsonInfo.nPlayerNum then
      playerNum = jsonInfo.nPlayerNum
    elseif DuoSegment >= SquadSegment then
      playerNum = 2
    else
      playerNum = 4
    end
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local teamNum = TeamUpNewSystem.GetTeamNum()
    if 1 < teamNum then
      playerNum = 4
      if teamNum == 3 then
        autoMatch = true
      end
    end
    if perspective == ENUM_PerspectiveType.TPP then
      if playerNum == 2 then
        matchID = C_InitMatchIDTwoTPP
      else
        matchID = C_InitMatchIDFourTPP
      end
    elseif playerNum == 2 then
      matchID = C_InitMatchIDTwoFPP
    else
      matchID = C_InitMatchIDFourFPP
    end
    viewIDs = jsonInfo.viewIDs
  else
    log(bWriteLog and "[ZH] mentor")
    log_tree("[ZH] MentorSystem._mentor_data", MentorSystem._mentor_data)
    maxSegment = MentorSystem._mentor_data and MentorSystem._mentor_data.mentor_max_seg_level or 101
    zoneID = MentorSystem._mentor_data and MentorSystem._mentor_data.mentor_max_seg_zone or ZoneSystem.nChooseZoneID
    matchID = MentorSystem._mentor_data and MentorSystem._mentor_data.mentor_max_seg_mode or C_InitMatchIDFourTPP
    perspective, playerNum = MentorSystem.GetPerspectiveNum(matchID)
    if MentorSystem._mentor_data and MentorSystem._mentor_data.mentor_setting and MentorSystem._mentor_data.mentor_setting.multi_select_param then
      local multi_select_param = MentorSystem._mentor_data.mentor_setting.multi_select_param
      local zoneParam = multi_select_param[zoneID]
      if zoneParam then
        if perspective == ENUM_PerspectiveType.TPP then
          local modeParamFour = zoneParam[C_InitMatchIDFourTPP]
          if modeParamFour then
            viewIDs = modeParamFour
            playerNumList[4] = true
          end
          local modeParamTwo = zoneParam[C_InitMatchIDTwoTPP]
          if modeParamTwo then
            viewIDs = modeParamTwo
            playerNumList[2] = true
          end
        else
          local modeParamFour = zoneParam[C_InitMatchIDFourFPP]
          if modeParamFour then
            viewIDs = modeParamFour
            playerNumList[4] = true
          end
          local modeParamTwo = zoneParam[C_InitMatchIDTwoFPP]
          if modeParamTwo then
            viewIDs = modeParamTwo
            playerNumList[2] = true
          end
        end
      end
    elseif jsonInfo.nPerspective == perspective then
      viewIDs = jsonInfo.viewIDs
      if jsonInfo.nPlayerNumList then
        playerNumList = jsonInfo.nPlayerNumList
      end
    end
    if next(playerNumList) == nil then
      DataMgr.fillMaxSegmentInfo()
      local DuoSegment = math.max(DataMgr.maxSegmentDuo.SegmentLevel, DataMgr.maxSegmentDuoFpp.SegmentLevel)
      local SquadSegment = math.max(DataMgr.maxSegmentSquad.SegmentLevel, DataMgr.maxSegmentSquadFpp.SegmentLevel)
      if DuoSegment >= SquadSegment then
        playerNumList[2] = true
      else
        playerNumList[4] = true
      end
    end
  end
  local viewIDList = jsonInfo.viewIDList or {}
  local isHistory = next(viewIDList) ~= nil
  local selectCount = 0
  local LogicModeMapDownLoad = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_map_download)
  if isHistory then
    for i, v in ipairs(subviewIdList) do
      if viewIDList[v] then
        local subViewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(v) or {}
        local mapKeyList = LogicModeMapDownLoad:GetMapKeyListByViewData(subViewInfo)
        local state = LogicModeMapDownLoad:GetMapListState(mapKeyList or {})
        local isDownLoad = state == 3
        if not isDownLoad then
          viewIDList[v] = false
        else
          selectCount = selectCount + 1
        end
      end
    end
  end
  log(bWriteLog and "MentorSystem.LoadMatchOptionByNewMode. selectCount" .. tostring(selectCount))
  if selectCount == 0 then
    for i, v in ipairs(subviewIdList) do
      local subViewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(v) or {}
      local mapKeyList = LogicModeMapDownLoad:GetMapKeyListByViewData(subViewInfo)
      local state = LogicModeMapDownLoad:GetMapListState(mapKeyList or {})
      local isDownLoad = state == 3
      if isDownLoad then
        viewIDList[v] = true
        if MentorSystem.identity ~= EIdentity.Mentee then
          break
        end
      end
    end
  end
  log_tree("[ZH] viewIDList", viewIDList)
  MentorSystem.matchOptionData = {
    nMatchID = matchID,
    nZoneID = zoneID,
    nPerspective = perspective or C_InitPerspective,
    nPlayerNum = playerNum or C_InitPlayerNum,
    modeIDs = modeIDs,
    viewIDs = viewIDs,
    bIsOpenMic = jsonInfo.bIsOpenMic or false,
    bAutoMatch = autoMatch,
    nMaxSegment = maxSegment,
    nPlayerNumList = playerNumList,
      }
  log_tree("MentorSystem.matchOptionData", MentorSystem.matchOptionData)
end
function MentorSystem.GetPerspectiveNum(matchID)
  local perspective, playerNum
  if matchID == C_InitMatchIDFourTPP then
    perspective = ENUM_PerspectiveType.TPP
    playerNum = 4
  elseif matchID == C_InitMatchIDTwoTPP or matchID == C_InitMatchIDOneTPP then
    perspective = ENUM_PerspectiveType.TPP
    playerNum = 2
  elseif matchID == C_InitMatchIDFourFPP then
    perspective = ENUM_PerspectiveType.FPP
    playerNum = 4
  elseif matchID == C_InitMatchIDTwoFPP or matchID == C_InitMatchIDOneFPP then
    perspective = ENUM_PerspectiveType.FPP
    playerNum = 2
  else
    log_error(bWriteLog and "[v_wllwu] MentorSystem.LoadMatchOptionByNewMode error, matchID = " .. tostring(matchID))
  end
  log(bWriteLog and "[v_wllwu] MentorSystem.GetPerspectiveNum, matchID: " .. tostring(matchID) .. ",perspective:" .. tostring(perspective) .. ",playerNum:" .. tostring(playerNum))
  return perspective, playerNum
end
function MentorSystem.GetMinLevel()
  local minLevel = 999
  for i, v in pairs(CDataTable.GetTable("MentorLevelLimit")) do
    if minLevel > v.MiniLevel then
      minLevel = v.MiniLevel
    end
  end
  return minLevel
end
function MentorSystem.CheckUILocked()
  if not LobbySystem.CheckOpen(94001) or Client.IsEmulator() then
    ShowNotice(8943)
    return true
  end
  log(bWriteLog and "[v_ywuyuan] MentorSystem.CheckUILocked" .. ":" .. tostring(MentorSystem.system_status))
  if MentorSystem.system_status == 1 then
    ShowNotice(8943)
    return true
  elseif MentorSystem.system_status == 2 then
    ShowNotice(8944)
    return true
  elseif MentorSystem.system_status == 4 then
    ShowNotice(22006)
    return true
  elseif MentorSystem.system_status == 0 then
    log(bWriteLog and "[v_ywuyuan] MentorSystem.CheckUILocked" .. ":" .. tostring(MentorSystem.qualification))
    if MentorSystem.qualification == EQualification.None then
      local minLevel = MentorSystem.GetMinLevel()
      if minLevel > DataMgr.roleData.level or DataMgr.roleData and DataMgr.roleData.segment and DataMgr.roleData.segment.double < MinSegNum then
        MentorSystem.ShowRestriction()
        return true
      end
    end
  end
  return false
end
function MentorSystem.send_mentor_declaration_set_req(declaration)
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  MentorHandler.send_mentor_declaration_set_req(declaration)
end
function MentorSystem.on_mentor_declaration_set_rsp(err_code, declaration, is_dirty_cn)
  if err_code and err_code ~= 0 then
    if err_code == 99999 then
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, nil, LocUtil.GetLocalizeResStr(44791))
    else
      ShowNotice(err_code)
    end
    return
  end
  local info = {mentor_declaration_dirty_cn = is_dirty_cn, mentor_declaration = declaration}
  MentorSystem.HandleDeclarationInMentorData(info)
  MentorSystem.mentor_data.base_info.mentor_declaration = info.mentor_declaration
  ShowNotice(75473)
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_UPDATE_DECLARATION)
end
function MentorSystem.HandleDeclarationInMentorData(data)
  if not data then
    return
  end
  local pre = data.mentor_declaration
  if data.mentor_declaration_dirty_cn or pre == nil then
    data.mentor_declaration = MentorSystem.GetDeclarationDefaultMsg()
  end
  local after = data.mentor_declaration
  log(bWriteLog and "MentorSystem.HandleDeclarationInMentorData pre: " .. tostring(pre) .. ", after: " .. tostring(after))
end
function MentorSystem.GetDeclarationDefaultMsg()
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  return logic_friend_apply:GetApplyMsg(C_DefaultDeclarationID)
end
function MentorSystem.OpenUI(_, _, params)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.mentor) then
    ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.mentor))
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInLargeTeam() then
    ShowNotice(27571)
    return
  end
  if not MentorSystem.IsInTargetMode(true) then
    return
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  local isRankOrBattleRestrict = QRcodeRestrictManager:IsRestrictBatlleAll() or QRcodeRestrictManager:IsRestrictBatlleRank()
  if isRankOrBattleRestrict then
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  MentorSystem.get_mentor_status_req(function()
    log(bWriteLog and "[v_ywuyuan] get_mentor_status_req success")
    if MentorSystem.CheckUILocked() then
      log(bWriteLog and "[v_wllwu] TeamPlatform_Tab:ReqOpenMentorUI locked")
      return
    end
    if params and params.choice and tonumber(params.choice) ~= MentorSystem.identity then
      MentorSystem.set_mentor_identity_req(tonumber(params.choice), function()
        MentorSystem.AutoStartSearch = true
        MentorSystem.JumpToMentor()
      end)
    else
      MentorSystem.JumpToMentor()
    end
  end)
end
function MentorSystem.IsInTargetMode(showNotice)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logic_mode_selection:IsSelect8PlayersMode() then
    if showNotice then
      ShowNotice(27572)
    end
    log(bWriteLog and "MentorSystem.IsInTargetMode IsSelect8PlayersMode return false")
    return false
  end
  local viewIds = MentorSystem.GetViewIDList()
  local _, selectViewID, _ = logic_mode_selection:GetCurSelectInfo()
  local isIn = false
  local mapStr = ""
  for i, viewID in ipairs(viewIds) do
    if viewID == selectViewID then
      isIn = true
    end
    local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(viewID)
    mapStr = mapStr .. LocUtil.GetLocalizeResStr(viewInfo.aux_name)
    if i < #viewIds then
      mapStr = mapStr .. "\227\128\129"
    end
  end
  if not isIn and showNotice then
    ShowNotice(LocUtil.LocalizeResFormat(75383, mapStr))
  end
  return isIn
end
function MentorSystem.IsCanShowLobbyEntry()
  log(bWriteLog and "logic_mentor.IsCanShowLobbyEntry. start checking conditions")
  local levelUnlockManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not levelUnlockManager:IsFeatureUnlocked(levelUnlockManager.featureDef.mentor) then
    log(bWriteLog and "logic_mentor.IsCanShowLobbyEntry. mentor feature not unlocked")
    return false
  end
  local logicReturnActivityUtils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logicReturnActivityUtils.IsActInProgress() then
    log(bWriteLog and "logic_mentor.IsCanShowLobbyEntry. return activity not in progress")
    return false
  end
  if not DataMgr.roleData.back_user_data or not DataMgr.roleData.back_user_data.rejoin_start_time then
    log(bWriteLog and "logic_mentor.IsCanShowLobbyEntry. back_user_data or rejoin_start_time is nil")
    return false
  end
  if not DataMgr.roleData.back_user_data.entrance_abtest_group then
    log(bWriteLog and "logic_mentor.IsCanShowLobbyEntry. entrance_abtest_group is nil")
    return false
  end
  if DataMgr.roleData.back_user_data.entrance_abtest_group ~= 1001 then
    log(bWriteLog and "logic_mentor.IsCanShowLobbyEntry. entrance_abtest_group is not 1001")
    return false
  end
  local rejoinStartTime = tonumber(DataMgr.roleData.back_user_data.rejoin_start_time)
  if not rejoinStartTime or rejoinStartTime <= 0 then
    log(bWriteLog and "logic_mentor.IsCanShowLobbyEntry. invalid rejoin_start_time:" .. tostring(rejoinStartTime))
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local daysSinceReturn = math.ceil((currentTime - rejoinStartTime) / 86400)
  log(bWriteLog and "logic_mentor.IsCanShowLobbyEntry. daysSinceReturn:" .. tostring(daysSinceReturn))
  if 7 < daysSinceReturn then
    log(bWriteLog and "logic_mentor.IsCanShowLobbyEntry. daysSinceReturn > 7, not eligible")
    return false
  end
  log(bWriteLog and "logic_mentor.IsCanShowLobbyEntry. all conditions met, can show lobby entry")
  return true
end
function MentorSystem.OpenMentorWaitingTips(widget)
  local params = {
    targetWidget = widget,
    title = LocUtil.GetLocalizeResStr(78380),
    desc = LocUtil.GetLocalizeResStr(78381),
    btnGoText = LocUtil.GetLocalizeResStr(9324),
    callback = function()
      local logic_mentor = require("client.slua.logic.mentor.logic_mentor")
      logic_mentor.OpenUI()
    end
  }
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Mid_Tips_Item_UIBP, params)
end
return MentorSystem