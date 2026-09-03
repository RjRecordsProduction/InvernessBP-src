local rank_util = require("client.slua.logic.rank.rank_util")
local logic_rank_Incentive = {
  activityData = nil,
  tRankRewardCfg = nil,
  selfRankData = {},
  rankAreaID = nil,
  currRankDataList = nil,
  currRankHistoryDataList = {},
  currRankHistoryTimeData = nil,
  config = {
    ActivityID = ActivityFixedID.CREATIVE_MAIN,
    ReqNumPerPage = 10,
    MaxRewardRank = 100,
    ScoreType = 72038
  },
  downloadIndex = nil
}
function logic_rank_Incentive.InitActData()
  log(bWriteLog and "[logic_rank_Incentive] InitActData")
  if not logic_rank_Incentive.activityData or not next(logic_rank_Incentive.activityData) then
    logic_rank_Incentive.GetActivitySubData()
  end
  if not logic_rank_Incentive.currRankDataList then
    logic_rank_Incentive.GetRankListReq()
  end
  if not logic_rank_Incentive.selfRankData or not next(logic_rank_Incentive.selfRankData) then
    logic_rank_Incentive.GetSelfRankReq()
  end
end
function logic_rank_Incentive.ReqRankData()
  log(bWriteLog and "[logic_rank_Incentive] ReqRankData")
end
function logic_rank_Incentive.ClearData()
  log(bWriteLog and "[logic_rank_Incentive] ClearData")
  logic_rank_Incentive.activityData = nil
  logic_rank_Incentive.selfRankData = {}
  logic_rank_Incentive.currRankDataList = nil
  logic_rank_Incentive.rankAreaID = nil
end
function logic_rank_Incentive.GetActivitySubData()
  log(bWriteLog and "[logic_rank_Incentive] GetActivitySubData")
  local activity = logic_rank_Incentive.GetActivityBYPoint()
  if not activity then
    log(bWriteLog and "[logic_rank_Incentive] nil activityData")
    return nil
  end
  local data = {
    nActID = activity.ID,
    sName = activity.Title,
    sDesc = activity.Desc,
    sBgUrl = "",
    reqID = activity.BackupParam1,
    nStartTime = activity.StartTime,
    nEndTime = activity.EndTime,
    nSwitchType = 10,
    DisplayScene = activity.DisplayScene
  }
  logic_rank_Incentive.activityData = activity
  if activity.BackupParam1 then
    logic_rank_Incentive.config.ScoreType = tonumber(activity.BackupParam1)
  end
  return data
end
function logic_rank_Incentive.GetActivityBYPoint()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local TimeUtil = require("client.common.time_util")
  local activity
  local now = TimeUtil.GetServerTimeInSec()
  local activityList = ActivityNewSystem.GetActivityListByType(13)
  if not next(activityList) then
    log(bWriteLog and "[logic_rank_Incentive] GetActivityBYPoint activityList nil ")
    return nil
  end
  for k, v in pairs(activityList) do
    if v.RedPointSwitcher == 18 then
      if v.StartTime and now > v.StartTime and v.EndTime and now < v.EndTime then
        activity = v
        log(bWriteLog and "[logic_rank_Incentive] GetActivityBYPoint RedPointSwitcher curractivity = " .. tostring(v.ID))
      else
        log(bWriteLog and "[logic_rank_Incentive] GetActivityBYPoint RedPointSwitcher == 17 but timeout " .. tostring(v.ID))
      end
    end
  end
  return activity
end
function logic_rank_Incentive.GetRankListReq()
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  UGCPassHandler.send_wow_get_IPR_rank_req()
end
function logic_rank_Incentive.GetRankListRsp(err_code, data)
  if not data or not next(data) then
    return
  end
  if data.rank_desc then
    logic_rank_Incentive.extra_reward = data.rank_desc.extra_reward
  end
  logic_rank_Incentive.AllRankDataList = data.rank_info
  logic_rank_Incentive.AllRankReward = data.rank_reward
  logic_rank_Incentive.InitRankRewardCfg("1")
  logic_rank_Incentive.SetCurrRankData("1")
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DATA_ACTIVEMOTIVATION_IPR_RANK, data)
end
function logic_rank_Incentive.SetCurrRankData(Index)
  logic_rank_Incentive.currTag = Index
  if not logic_rank_Incentive.AllRankDataList or not next(logic_rank_Incentive.AllRankDataList) then
    return
  end
  local currlist = {}
  currlist = logic_rank_Incentive.AllRankDataList[logic_rank_Incentive.currTag]
  logic_rank_Incentive.currRankDataList = currlist
  logic_rank_Incentive.FindSelfRankNo()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_INCENTIVE_LIST_UPDATE)
  if not currlist or not next(currlist) then
    return
  end
  local reqProfileUIDList = {}
  local reqModInfoList = {}
  for i = 1, logic_rank_Incentive.config.ReqNumPerPage do
    if currlist[i] and not currlist[i].req then
      table.insert(reqProfileUIDList, currlist[i].uid)
      logic_rank_Incentive.currRankDataList[i].req = true
    end
    if currlist[i] and not currlist[i].reqModInfo then
      table.insert(reqModInfoList, currlist[i].mod_id)
      logic_rank_Incentive.currRankDataList[i].reqModInfo = true
    end
  end
  logic_rank_Incentive.GetRankProfileList(reqProfileUIDList)
  logic_rank_Incentive.GetRankModInfoList(reqModInfoList)
end
function logic_rank_Incentive.InitRankRewardCfg(Index)
  if logic_rank_Incentive.tRankRewardCfg and next(logic_rank_Incentive.tRankRewardCfg) then
    return
  end
  if not logic_rank_Incentive.AllRankReward then
    return
  end
  local tAllRankRewardData = {}
  local uObj_rankRewardCfg = logic_rank_Incentive.AllRankReward or {}
  for _, v in pairs(uObj_rankRewardCfg[Index]) do
    local tRankData = {
      rank_max = v.rank_max,
      rank_min = v.rank_min
    }
    if v.item_id and v.item_num > 0 then
      local tRewardData = {
        item_id_1 = v.item_id,
        item_num_1 = v.item_num
      }
      table.insert(tRankData, tRewardData)
    end
    table.insert(tAllRankRewardData, tRankData)
  end
  logic_rank_Incentive.tRankRewardCfg = tAllRankRewardData
end
function logic_rank_Incentive.GetRankRewardCfg()
  if not logic_rank_Incentive.tRankRewardCfg then
    logic_rank_Incentive.InitRankRewardCfg()
  end
  return logic_rank_Incentive.tRankRewardCfg
end
function logic_rank_Incentive.GetRankProfileList(reqProfileUIDList)
  log(bWriteLog and "[logic_rank_creativity] GetRankProfileList")
  if not reqProfileUIDList or #reqProfileUIDList <= 0 then
    log(bWriteLog and "[logic_rank_creativity] invalid reqProfileUIDList")
    return
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(reqProfileUIDList, logic_rank_Incentive.GetRankListProfileRsp, Enum_PROFILE_REPORT_CFG.RANK_POP_LIST, nil, true)
end
function logic_rank_Incentive.GetRankListProfileRsp(profileList)
  log(bWriteLog and "[logic_rank_Incentive] GetRankListProfileRsp")
  if not profileList or not next(profileList) then
    log(bWriteLog and "[logic_rank_Incentive] invalid profileList")
    return
  end
  local profileMap = {}
  for _, profile_data in ipairs(profileList) do
    profileMap[tonumber(profile_data.uid)] = profile_data
  end
  if logic_rank_Incentive.currRankDataList then
    local match_rank_map = {}
    for index, rank_data in pairs(logic_rank_Incentive.currRankDataList) do
      if tonumber(rank_data.uid) == tonumber(DataMgr.roleData.uid) then
        rank_data.name = DataMgr.roleData.nickName
        if DataMgr.roleData.pround_info then
          rank_data.pround_level = DataMgr.roleData.pround_info.level or 0
        else
          log(bWriteLog and "[logic_rank_Incentive] invalid self pround_info: " .. tostring(DataMgr.roleData.uid))
        end
        match_rank_map[index] = rank_data
      else
        local profile_data = profileMap[tonumber(rank_data.uid)]
        if profile_data then
          rank_data.name = profile_data.nickName
          if profile_data.pround_info then
            rank_data.pround_level = profile_data.pround_info.level or 0
          else
            log(bWriteLog and "[logic_rank_Incentive] invalid pround_info: " .. tostring(rank_data.uid))
          end
          rank_data.light_board_info = profile_data.light_board_info
          match_rank_map[index] = rank_data
        end
      end
    end
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_INCENTIVE_PROFILE_UPDATE, match_rank_map)
  end
  if logic_rank_Incentive.currRankHistoryDataList and next(logic_rank_Incentive.currRankHistoryDataList) then
    local match_rank_map = {}
    for index, rank_data in pairs(logic_rank_Incentive.currRankHistoryDataList) do
      local profile_data = profileMap[tonumber(rank_data.uid)]
      if profile_data then
        rank_data.name = profile_data.nickName
        if profile_data.pround_info then
          rank_data.pround_level = profile_data.pround_info.level or 0
        else
          log(bWriteLog and "[logic_rank_Incentive] invalid pround_info: " .. tostring(rank_data.uid))
        end
        rank_data.light_board_info = profile_data.light_board_info
        match_rank_map[index] = rank_data
      end
    end
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_HISTORYRANK_INCENTIVE_PROFILE_UPDATE, match_rank_map)
  end
end
function logic_rank_Incentive.GetRankModInfoList(list)
  log(bWriteLog and "[logic_rank_Incentive] GetRankProfileList")
  local UniqueArray = {}
  local exists = {}
  for _, v in ipairs(list) do
    if not exists[v] then
      table.insert(UniqueArray, v)
      exists[v] = true
    end
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:BatchGetModInfo(UniqueArray, LogicUGC.C_ModListTypes.Incentive_Rank, nil, {bSplit = true, bSimple = true})
end
function logic_rank_Incentive.GetSelfRankReq()
  log(bWriteLog and "[logic_rank_creativity] GetSelfRankReq")
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local SortedPubModList = LogicUGC:GetSortedPubModList()
  if not SortedPubModList or not next(SortedPubModList) then
    local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
    UGCSearchHandler.send_ugc_get_all_meta_key_req()
  end
  if not SortedPubModList or not next(SortedPubModList) then
    log(bWriteLog and "UI_UGC_Mine_Works:RequestOnePageModData list is invalid")
    return
  end
  local ModIDList = {}
  for _, modInfo in ipairs(SortedPubModList) do
    local ModID = modInfo.modId or 0
    table.insert(ModIDList, ModID)
  end
  LogicUGC:BatchGetModInfo(ModIDList, LogicUGC.C_ModListTypes.Pub, nil, {bSimple = true})
end
function logic_rank_Incentive.GetSelfRankRsp()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_INCENTIVE_SELF_UPDATE)
end
function logic_rank_Incentive.FindSelfRankNo()
  if logic_rank_Incentive.currRankDataList then
    for k, v in pairs(logic_rank_Incentive.currRankDataList) do
      if tostring(v.uid) == DataMgr.roleData.uid then
        logic_rank_Incentive.selfRankData.no = v.no
      end
    end
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_INCENTIVE_SELF_UPDATE)
  end
end
function logic_rank_Incentive.GetMyBestModInfo(modList)
  if not modList or not next(modList) then
    return nil
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local pubList = LogicUGC:GetSortedPubModList()
  if not pubList or not next(pubList) then
    log(bWriteLog and "UI_UGC_Mine_Works:PublicModListToArray no publist")
    return nil
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local array = {}
  for _, pubInfo in ipairs(pubList) do
    if pubInfo.modId and modList[pubInfo.modId] then
      local state = modList[pubInfo.modId].pub_mod_meta.base.state_release
      if state ~= Config_UGC.E_PublishState.ManualReview and state ~= Config_UGC.E_PublishState.Rectification then
        table.insert(array, modList[pubInfo.modId])
      end
    end
  end
  table.sort(array, function(a, b)
    return a.pub_mod_meta.play_cnt > b.pub_mod_meta.play_cnt
  end)
  if not array[1] then
    return nil
  end
  return array[1].pub_mod_meta
end
function logic_rank_Incentive:_LoadTableCfgs()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.TableCfgs = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTableCfg)
  self.TableCfgs = self.TableCfgs or {}
end
function logic_rank_Incentive.GetHistoryRankListReq()
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  if logic_rank_Incentive.currRankHistoryDataList and next(logic_rank_Incentive.currRankHistoryDataList) then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_ACTIVITY_HISTORYRANK_UPDATE)
  else
    UGCPassHandler.send_wow_get_IPR_rank_history_req()
  end
end
function logic_rank_Incentive.GetHistoryRankListRsp(err_code, data)
  if err_code ~= 0 and err_code ~= 522017 then
    ShowNotice(err_code)
  end
  if not data or not next(data) then
    return
  end
  if data.rank_info and data.rank_info["1"] then
    logic_rank_Incentive.currRankHistoryDataList = data.rank_info["1"]
  end
  if data.rank_desc then
    logic_rank_Incentive.currRankHistoryTimeData = data.rank_desc
  end
  local reqProfileUIDList = {}
  for i = 1, #logic_rank_Incentive.currRankHistoryDataList do
    table.insert(reqProfileUIDList, logic_rank_Incentive.currRankHistoryDataList[i].uid)
  end
  logic_rank_Incentive.GetRankProfileList(reqProfileUIDList)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_ACTIVITY_HISTORYRANK_UPDATE)
end
return logic_rank_Incentive