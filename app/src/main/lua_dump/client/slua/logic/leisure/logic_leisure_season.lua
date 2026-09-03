local logic_leisure_season = {}
function logic_leisure_season:DefineAndResetData()
  self.advance_integral = nil
  self.historySeasonData = {}
end
function logic_leisure_season:RegistEvents()
end
function logic_leisure_season:OnLogOut()
  self:DefineAndResetData()
end
function logic_leisure_season:OnPostSwitchGameStatus(preState, nextState)
end
function logic_leisure_season:IsLeisureSeasonOpen()
  local leisure_season_macro = require("client.slua.logic.leisure.leisure_season_macro")
  local minSeasonID = self:GetMinLeisureSeasonID()
  if minSeasonID > DataMgr.season_id then
    log(bWriteLog and "logic_leisure_season:IsLeisureSeasonOpen false")
    return false
  end
  log(bWriteLog and "logic_leisure_season:IsLeisureSeasonOpen true")
  return true
end
function logic_leisure_season:GetMinLeisureSeasonID()
  local leisure_season_macro = require("client.slua.logic.leisure.leisure_season_macro")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    return leisure_season_macro.MinSeasonID_BLUEHOLE
  else
    return leisure_season_macro.MinSeasonID
  end
end
function logic_leisure_season:OnRedDataReady()
  log(bWriteLog and "logic_leisure_season:OnRedDataReady")
  self:UpdateNewSeasonReddot()
  self:UpdateTaskAwardFlag(DataMgr.roleData.casual_task_award_flag)
  self:UpdateSegmentAwardFlag(DataMgr.roleData.casual_segment_award_flag)
end
function logic_leisure_season:GetNextSegmentID()
  local curSegmentID = self:GetLeisureSegmentID()
  local cfg = CDataTable.GetTable("LeisureSeasonRankLevelCfg")
  for _, v in pairs(cfg) do
    if curSegmentID < v.RankID then
      return v.RankID
    end
  end
  return curSegmentID
end
function logic_leisure_season:IsReachDoubleSegment(leisureSegmentID, classicSegmentID)
  local SeasonSystem = require("client.logic.season.logic_season")
  local bestClassicSegmentID = SeasonSystem.GetBestSegment()
  local curleisureSegmentID = self:GetLeisureSegmentID()
  log(bWriteLog and "logic_leisure_season:IsReachDoubleRank classicSegmentID = " .. tostring(classicSegmentID) .. ", bestClassicSegmentID = " .. tostring(bestClassicSegmentID) .. ", leisureSegmentID = " .. tostring(leisureSegmentID) .. ", curleisureSegmentID = " .. tostring(curleisureSegmentID))
  return classicSegmentID <= bestClassicSegmentID and leisureSegmentID <= curleisureSegmentID
end
function logic_leisure_season:GetDoubleSegmentAwardStatus(leisureSegmentID, classicSegmentID)
  local leisure_season_macro = require("client.slua.logic.leisure.leisure_season_macro")
  local bReachSegment = self:IsReachDoubleSegment(leisureSegmentID, classicSegmentID)
  if bReachSegment then
    if DataMgr.roleData.casual_segment_award_flag == 2 then
      return leisure_season_macro.ENUM_TASK_STATUS.CanTakeAward
    else
      return leisure_season_macro.ENUM_TASK_STATUS.HaveTookAward
    end
  end
  return leisure_season_macro.ENUM_TASK_STATUS.NotFinish
end
function logic_leisure_season:GetLeisureSegmentID()
  local segmentID = DataMgr.roleData.casual_segment_id
  if not segmentID then
    log(bWriteLog and "logic_leisure_season:GetLeisureSegmentID not DataMgr.roleData.casual_segment_id")
    segmentID = self:GetLeisureDefaultID()
  end
  return segmentID
end
function logic_leisure_season:GetLeisureSegmentIDByUID(uid)
  if uid == DataMgr.roleData.uid then
    return self:GetLeisureSegmentID()
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    log_error(bWriteLog and "logic_leisure_season:GetLeisureSegmentIDByUID no profile")
    return 0
  end
  local segmentID = profile.casual_segment_id
  if not segmentID then
    log(bWriteLog and "logic_leisure_season:GetLeisureSegmentID not DataMgr.roleData.casual_segment_id")
    segmentID = self:GetLeisureDefaultID()
  end
  return segmentID
end
function logic_leisure_season:GetCurrentLeisureScoreByProfile(uid)
  if uid == DataMgr.roleData.uid then
    return DataMgr.roleData.casual_segment_score or 0
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    log_error(bWriteLog and "logic_leisure_season:GetLeisureSegmentIDByUID no profile")
    return 0
  end
  local segmentScore = profile.casual_segment_score
  if not segmentScore then
    log(bWriteLog and "logic_leisure_season:GetLeisureSegmentID not profile.casual_segment_score")
    return 0
  end
  return segmentScore
end
function logic_leisure_season:GetLeisureDefaultID()
  local segmentID = CDataTable.GetTableData("LeisureSeasonParamCfg", "MinSegmentId").Value
  return segmentID
end
function logic_leisure_season:GetDoubleSegmentCfg()
  local cfg = CDataTable.GetTableDataByFilter("LeisureSeasonSegmentAwardCfg", "SeasonID", DataMgr.season_id, "TaskType", 2)
  if not cfg then
    log(bWriteLog and "logic_leisure_season:GetDoubleSegmentCfg not cfg DataMgr.season_id = " .. tostring(DataMgr.season_id))
    return
  end
  local doubleSegmentData = {
    dropCfg = {
      DropItemNum = cfg.AwardCount1,
      DropItemID = cfg.AwardID1,
      DropItemTime = cfg.AwardValidHours1
    },
    awardCfg = {
      Condition1_Desc = LocUtil.GetLocalizeResStr(cfg.DescID),
      Condition2_Param2 = 0,
      Showtips = cfg.ShowTips
    },
    doubleSegmentStatus = self:GetDoubleSegmentAwardStatus(cfg.Param1, cfg.Param2),
    taskID = cfg.ID,
    leisureSegmentID = cfg.Param1,
    classicSegmentID = cfg.Param2,
    SegmentText = cfg.SegmentText
  }
  local dataList = {doubleSegmentData}
  if cfg.AwardID2 ~= 0 then
    local TableUtil = require("common.table_util")
    local doubleSegmentData2 = TableUtil.CopyTable(doubleSegmentData)
    doubleSegmentData2.dropCfg = {
      DropItemNum = cfg.AwardCount2,
      DropItemID = cfg.AwardID2,
      DropItemTime = cfg.AwardValidHours2
    }
    table.insert(dataList, doubleSegmentData2)
  end
  if cfg.AwardID3 ~= 0 then
    local TableUtil = require("common.table_util")
    local doubleSegmentData3 = TableUtil.CopyTable(doubleSegmentData)
    doubleSegmentData3.dropCfg = {
      DropItemNum = cfg.AwardCount3,
      DropItemID = cfg.AwardID3,
      DropItemTime = cfg.AwardValidHours3
    }
    table.insert(dataList, doubleSegmentData3)
  end
  return dataList
end
function logic_leisure_season:GetAdvanceIntegral()
  return self.advance_integral or 0
end
function logic_leisure_season:GetSpecialTaskType()
  local cfg = CDataTable.GetTableDataByFilter("LeisureSeasonTaskTypeCfg", "AllShow", true)
  if not cfg then
    log_warning("logic_leisure_season:GetSpecialTaskType not cfg")
    return
  end
  return cfg.TypeID
end
function logic_leisure_season:GetWeekTaskList(weekID)
  log(bWriteLog and "logic_leisure_season:GetWeekTaskList weekID = " .. tostring(weekID))
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local taskAwardCfgName = "casual_season_task_table_" .. tostring(DataMgr.season_id)
  log(bWriteLog and "logic_leisure_season:GetWeekTaskList taskAwardCfgName = " .. tostring(taskAwardCfgName))
  local cfg = BasicDataServerTable:GetCacheData(taskAwardCfgName)
  if not cfg then
    log(bWriteLog and "logic_leisure_season:GetWeekTaskList not cfg")
    return {}
  end
  local taskList = {}
  local gameId = Client.GetITopGameId()
  local TableUtil = require("common.table_util")
  for k, v in pairs(cfg) do
    local bShow = false
    if v.season_id == DataMgr.season_id then
      local startWeek = v.belong_begin_week
      local endWeek = v.belong_end_week
      if weekID >= startWeek and weekID <= endWeek and v.appid_table[gameId] then
        bShow = true
      end
    end
    if bShow then
      local version_util = require("client.common.version_util")
      local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
      if version_util.CompareVersionStandard(ClientVersion, v.min_version) >= 0 then
        local info = TableUtil.CopyTable(v)
        info.taskID = k
        table.insert(taskList, info)
      end
    end
  end
  return taskList
end
function logic_leisure_season:GetSegmentAwardList()
  local LeisureSeasonSegmentAwardCfg = CDataTable.GetTableByFilter("LeisureSeasonSegmentAwardCfg", "SeasonID", DataMgr.season_id)
  local awardList = {}
  local gameId = Client.GetITopGameId()
  local TableUtil = require("common.table_util")
  local StringUtil = require("common.string_util")
  for k, v in pairs(LeisureSeasonSegmentAwardCfg) do
    local appIDs = StringUtil.Split(v.AppID, "|")
    local bAppValid = false
    for _, id in ipairs(appIDs) do
      if id == gameId then
        bAppValid = true
        break
      end
    end
    if bAppValid then
      local version_util = require("client.common.version_util")
      local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
      if version_util.CompareVersionStandard(ClientVersion, v.minVersion) >= 0 then
        local info = TableUtil.CopyTable(v)
        info.taskID = k
        table.insert(awardList, info)
      end
    end
  end
  table.sort(awardList, function(a, b)
    return a.SortID < b.SortID
  end)
  return awardList
end
function logic_leisure_season:UpdateNewSeasonReddot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local seasonReddot = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLeisureSeasonNewSeason) or {}
  local reddotCount
  if not self:IsLeisureSeasonOpen() or seasonReddot[DataMgr.season_id] then
    reddotCount = 0
  else
    reddotCount = 1
  end
  log(bWriteLog and "logic_leisure_season:UpdateNewSeasonReddot reddotCount = " .. tostring(reddotCount))
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  local ReddotType = season_redpoint_data.ReddotType
  local leisure_season_util = require("client.slua.logic.leisure.leisure_season_util")
  leisure_season_util:SetLeisureReddotByType(ReddotType.leisureSeasonFirstLogin, reddotCount)
end
function logic_leisure_season:ClearNewSeasonReddot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local seasonReddot = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLeisureSeasonNewSeason) or {}
  seasonReddot[DataMgr.season_id] = true
  PlayerPrefsSystem.SaveTableToFile_N(seasonReddot, PlayerPrefsSystem.ePlayerPrefsType.eLeisureSeasonNewSeason)
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  local ReddotType = season_redpoint_data.ReddotType
  local leisure_season_util = require("client.slua.logic.leisure.leisure_season_util")
  leisure_season_util:SetLeisureReddotByType(ReddotType.leisureSeasonFirstLogin, 0)
end
function logic_leisure_season:UpdateTaskAwardFlag(award_flag)
  log(bWriteLog and "logic_leisure_season:UpdateTaskAwardFlag award_flag = " .. tostring(award_flag))
  DataMgr.roleData.casual_task_award_flag = award_flag or 0
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  local ReddotType = season_redpoint_data.ReddotType
  local leisure_season_util = require("client.slua.logic.leisure.leisure_season_util")
  leisure_season_util:SetLeisureReddotByType(ReddotType.leisureSeasonTaskAward, DataMgr.roleData.casual_task_award_flag)
end
function logic_leisure_season:UpdateSegmentAwardFlag(award_flag)
  log(bWriteLog and "logic_leisure_season:UpdateSegmentAwardFlag award_flag = " .. tostring(award_flag))
  DataMgr.roleData.casual_segment_award_flag = award_flag or 0
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  local ReddotType = season_redpoint_data.ReddotType
  local leisure_season_util = require("client.slua.logic.leisure.leisure_season_util")
  if DataMgr.roleData.casual_segment_award_flag == 2 then
    season_redpoint_data.SetRedByType(season_redpoint_data.ReddotType.classicDoubleSeasonReward, 1)
    leisure_season_util:SetLeisureReddotByType(ReddotType.leisureSeasonSegmentAward, 1)
  elseif DataMgr.roleData.casual_segment_award_flag == 1 then
    season_redpoint_data.SetRedByType(season_redpoint_data.ReddotType.classicDoubleSeasonReward, 0)
    leisure_season_util:SetLeisureReddotByType(ReddotType.leisureSeasonSegmentAward, 1)
  else
    season_redpoint_data.SetRedByType(season_redpoint_data.ReddotType.classicDoubleSeasonReward, 0)
    leisure_season_util:SetLeisureReddotByType(ReddotType.leisureSeasonSegmentAward, 0)
  end
end
function logic_leisure_season:GetHistorySeasonData(uid, season_id)
  if not self.historySeasonData[uid] or not self.historySeasonData[uid][season_id] then
    return nil
  end
  return self.historySeasonData[uid][season_id]
end
function logic_leisure_season:OnGetTaskStatusRsp(advance_integral, task_status_list, extra_table)
  self.  EventSystem:postEvent(EVENTTYPE_LEISURE_SEASON, EVENTID_LEISURE_SEASON_GET_TASK_STATUS_RSP, advance_integral, task_status_list, extra_table)
end
function logic_leisure_season:OnGetTaskAwardRsp(awards)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(awards)
  EventSystem:postEvent(EVENTTYPE_LEISURE_SEASON, EVENTID_LEISURE_SEASON_GET_TASK_AWARD_RSP)
end
function logic_leisure_season:OnNotifySegmentInfo(casual_segment_id, casual_segment_score, advance_integral, is_sync_classic_segment)
  DataMgr.roleData.  DataMgr.roleData.  self.  if is_sync_classic_segment then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N({bNeedTips = true}, PlayerPrefsSystem.ePlayerPrefsType.eLeisureSeasonClassicSegmentSync)
  end
  EventSystem:postEvent(EVENTTYPE_LEISURE_SEASON, EVENTID_LEISURE_SEASON_SEGMENT_NOTIFY, is_sync_classic_segment)
end
function logic_leisure_season:OnNotifyTaskAwardFlag(casual_task_awrad_flag)
  self:UpdateTaskAwardFlag(casual_task_awrad_flag)
end
function logic_leisure_season:OnNotifySegmentAwardFlag(casual_segment_award_flag)
  self:UpdateSegmentAwardFlag(casual_segment_award_flag)
  EventSystem:postEvent(EVENTTYPE_LEISURE_SEASON, EVENTID_LEISURE_SEASON_SEGMENT_AWARD_STATUS_NOTIFY)
end
function logic_leisure_season:OnGetSegmentAwardRsp(awards)
  local decomposeList = {}
  for i, v in pairs(awards) do
    if v.season_ex_item_id then
      decomposeList[i] = {
        itemid = v.resid,
        count = v.count
      }
    end
  end
  for _, v in pairs(awards) do
    if v.season_ex_item_id then
      v.resid = v.season_ex_item_id
      v.count = v.season_ex_item_num
    end
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DecomposeStyle(awards, decomposeList)
  EventSystem:postEvent(EVENTTYPE_LEISURE_SEASON, EVENTID_LEISURE_SEASON_GET_SEGMENT_AWARD_RSP)
end
function logic_leisure_season:OnSegmentAwardStatusRsp(segment_reward_list)
  EventSystem:postEvent(EVENTTYPE_LEISURE_SEASON, EVENTID_LEISURE_SEASON_SEGMENT_AWARD_STATUS_RSP, segment_reward_list)
end
function logic_leisure_season:SendRoleHistoryCasualSeasonRecordReq(uid, season_id)
  local seasonData = self:GetHistorySeasonData(uid, season_id)
  if seasonData then
    EventSystem:postEvent(EVENTTYPE_LEISURE_SEASON, EVENTID_LEISURE_SEASON_GET_HISTORY_DATA, seasonData)
    return
  end
  local LeisureSeasonHandler = require("client.network.Protocol.LeisureSeasonHandler")
  LeisureSeasonHandler.send_get_history_casual_season_record_req(uid, season_id)
end
function logic_leisure_season:OnGetRoleHistoryCasualSeasonRecordRsp(data, uid, season_id)
  log_tree(bWriteLog and "logic_leisure_season:OnGetRoleHistoryCasualSeasonRecordRsp ", data)
  if not data then
    if not self.historySeasonData[uid] then
      self.historySeasonData[uid] = {}
    end
    self.historySeasonData[uid][season_id] = {}
    EventSystem:postEvent(EVENTTYPE_LEISURE_SEASON, EVENTID_LEISURE_SEASON_GET_HISTORY_DATA, {})
    return
  end
  if not self.historySeasonData[uid] then
    self.historySeasonData[uid] = {}
  end
  self.historySeasonData[uid][season_id] = data
  EventSystem:postEvent(EVENTTYPE_LEISURE_SEASON, EVENTID_LEISURE_SEASON_GET_HISTORY_DATA, data)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_leisure_season = class(CModuleBase, nil, logic_leisure_season)
return Clogic_leisure_season