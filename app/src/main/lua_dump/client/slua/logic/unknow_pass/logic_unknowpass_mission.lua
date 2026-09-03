local UnknowPassMissionSystem = {
  weekMissionTimestamp = 0,
  weekMissionLeftTime = 0,
  Has_EasyCard = false,
  WeekTabReddot_List = {},
  MaxMissionWeekCount = 0,
  Week_Mission_List = {},
  WeekTabIcon_List = {},
  WeekTabTypeReddot_List = {},
  UnknowPassWeekMissionMap = {},
  CurrentMissionTabType = 1,
  CurrentGetMissionWeekIndex = 0,
  Mission_SearchType = 2,
  Mission_CurrentSelectType = 0,
  MissionWeekCurrentIndex = 0,
  Mission_CurrentRecommendType = 0,
  CurrentGetMissionTaskId = 0,
  isFinishing = false,
  MissionCardID = 0,
  isNewWeek = false,
  SeasonActive = {},
  HasWeekAward = false,
  bHasSeasonAward = false,
  limitedTimeMission = {},
  limitedTimeActMission = {},
  ReturnLobbyMsg = false,
  weektask_cur_score = 0,
  weektask_score_limit = 0,
  weektask_score_limit_max = 0,
  weektask_all_score_limit_list = {},
  limitedTimeActMissionRedData = {},
  MAX_WEEK_COUNT = 8,
  BranchCurMissionTabType = 1
}
local UnknowPass_Mission_FriendExtraStatusNone = 0
local UnknowPass_Mission_FriendExtraStatusAdding = 1
local UnknowPass_Mission_FriendExtraStatusDesc = 2
local UnknowPass_Mission_FriendExtraStatusHasGet = 3
local UnknowPass_Mission_SelectType = 4
local UnknowPass_Mission_ToysFriendType = 5
local TypeSearchIconList = {
  [1] = "/Game/UMG/Texture/Atlas/UnknowntrialUI/Frames/task_icon_gun_png.task_icon_gun_png",
  [2] = "/Game/UMG/Texture/Atlas/UnknowntrialUI/Frames/task_icon_helmet_png.task_icon_helmet_png",
  [3] = "/Game/UMG/Texture/Atlas/UnknowntrialUI/Frames/task_icon_survive_png.task_icon_survive_png",
  [4] = "/Game/UMG/Texture/Atlas/UnknowntrialUI/Frames/task_icon_parachute_png.task_icon_parachute_png",
  [5] = "/Game/UMG/Texture/Atlas/UnknowntrialUI/Frames/task_icon_others_png.task_icon_others_png"
}
local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
function UnknowPassMissionSystem.GetWeekEndTime(weekIndex)
  local cfg = UnknowPassSystem.SeasonInfo.cfg
  if not cfg then
    local TimeUtil = require("client.common.time_util")
    return TimeUtil.GetServerTimeInSec()
  else
    return cfg.begin_timestamp + 604800 * weekIndex - 1
  end
end
function UnknowPassMissionSystem.GetBoxAwardsByIndex(weekIndex)
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  local cfg = UnknowPassAwardSystem.GetWeekTaskRewardCfgTable()[weekIndex]
  return cfg
end
function UnknowPassMissionSystem.GetProgress(task_cfg, task_data)
  if task_cfg and task_data then
    if task_cfg.finish_type == 2 then
      if task_data.status == BP_UnknowPass_Mission_NotFinish then
        return 0, 1
      else
        return 1, 1
      end
    else
      return math.floor(task_data.value), math.floor(task_cfg.finish_value)
    end
  else
    return 0, 1
  end
end
function UnknowPassMissionSystem.GetRPMissionLobbyStatus()
  if not UnknowPassSystem.IsInCurSession then
    return nil
  end
  local FinishedCount = 0
  local UnknowPass_Week_Mission_NotFinish, UnknowPass_Week_Mission_Finished
  if UnknowPassSystem.Data.all_week_task_cfg then
    local HasFinishGroup = {}
    for taskId, task_cfg in pairs(UnknowPassSystem.Data.all_week_task_cfg) do
      if task_cfg and (UnknowPassSystem.IsBuyElite or task_cfg.is_elite_task == 0) then
        local task = UnknowPassSystem.Data.week_task[taskId]
        local group = UnknowPassSystem.task_group and UnknowPassSystem.task_group[task_cfg.groupId]
        local status = group and group.status or BP_UnknowPass_Mission_NotFinish
        if task and status == BP_UnknowPass_Mission_Finished then
          if not HasFinishGroup[task_cfg.groupId] then
            FinishedCount = FinishedCount + 1
          end
          HasFinishGroup[task_cfg.groupId] = true
          if UnknowPass_Week_Mission_Finished == nil then
            UnknowPass_Week_Mission_Finished = {
              status = status,
              taskId = taskId,
              lobby_title = LocUtil.LocalizeResFormat(7261)
            }
          end
        elseif task and status == BP_UnknowPass_Mission_NotFinish then
          local progress, finish_value = UnknowPassMissionSystem.GetProgress(task_cfg, task.task_data)
          if finish_value == 0 then
            finish_value = 1
          end
          local progress_percent = progress / finish_value
          if UnknowPass_Week_Mission_NotFinish == nil or progress_percent > UnknowPass_Week_Mission_NotFinish.progress_percent then
            UnknowPass_Week_Mission_NotFinish = {
              status = status,
              taskId = taskId,
              lobby_title = task_cfg.lobby_title,
              progress = progress,
              finish_value = finish_value,
                          }
          end
        end
      end
    end
  end
  if UnknowPass_Week_Mission_Finished ~= nil then
    UnknowPass_Week_Mission_Finished.lobby_title = LocUtil.LocalizeResFormat(9700, FinishedCount)
    return UnknowPass_Week_Mission_Finished
  end
  if UnknowPass_Week_Mission_NotFinish ~= nil then
    local progress = "(" .. UnknowPass_Week_Mission_NotFinish.progress .. "/" .. UnknowPass_Week_Mission_NotFinish.finish_value .. ")"
    local tips
    local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
    if Client.GetCurrentLanguage() == LanguageMacros.AR then
      tips = progress .. " " .. UnknowPass_Week_Mission_NotFinish.lobby_title
    else
      tips = UnknowPass_Week_Mission_NotFinish.lobby_title .. " " .. progress
    end
    UnknowPass_Week_Mission_NotFinish.lobby_title = tips
    return UnknowPass_Week_Mission_NotFinish
  end
  return nil
end
function UnknowPassMissionSystem.GetProcess(task_cfg, task_data)
  if task_cfg and task_data then
    if task_cfg.finish_type == 2 then
      if task_data.status == BP_UnknowPass_Mission_NotFinish then
        return "0/1"
      else
        return "1/1"
      end
    elseif task_data.share_progress and task_data.share_progress ~= 0 then
      return LocUtil.LocalizeResFormat(9683, math.floor(task_data.value - task_data.share_progress), math.floor(task_data.share_progress), math.floor(task_cfg.finish_value))
    else
      return LocUtil.LocalizeResFormat(9684, math.floor(task_data.value), math.floor(task_cfg.finish_value))
    end
  else
    return ""
  end
end
function UnknowPassMissionSystem.OpenNewMissionUI()
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
  PassPreviewSystem.HideItemModel()
  UIManager.ShowUI(UIManager.UI_Config.unknowpass_mission_sec, 0)
  local hasBubble = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassMacro.ENUM_Pass_Main_Reddot.ENUM_Pass_XmissionStrongGuide)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() and hasBubble then
    UIManager.ShowUI(UIManager.UI_Config.UnknowPass_Newbie_Xmission_UIBP)
  end
end
function UnknowPassMissionSystem.CloseNewMissionUI()
  UIManager.CloseUI(UIManager.UI_Config.unknowpass_mission_sec)
end
function UnknowPassMissionSystem.GetSeasonMissionProgress()
  if not UnknowPassSystem.Data.all_week_task_cfg then
    return
  end
  local totalNum = 0
  local completedNum = 0
  for taskId, task_cfg in pairs(UnknowPassSystem.Data.all_week_task_cfg) do
    if task_cfg.is_season == 1 then
      totalNum = totalNum + 1
      local task = UnknowPassSystem.Data.week_task[taskId]
      if task and (task.task_data.status == BP_UnknowPass_Mission_Finished or task.task_data.status == BP_UnknowPass_Mission_HasGet) then
        completedNum = completedNum + 1
      end
    end
  end
  return totalNum, completedNum
end
local MissionGroupIdMap = {}
local AllMissionGroupList = {}
local MissionGroupSortList = {}
local _bHaveCanReceive = false
local CalcFriendExtraAward = function(tTaskCfg, tTaskData, tGroup)
  if tTaskCfg.specialType ~= 2 then
    return UnknowPass_Mission_FriendExtraStatusNone, 0
  end
  local nExtraAward = UnknowPass_Mission_FriendExtraStatusDesc
  local nAddition = 0
  if tTaskData.addition ~= nil then
    nAddition = tTaskData.addition
    if tGroup and tGroup.status == BP_UnknowPass_Mission_Finished then
      nExtraAward = UnknowPass_Mission_FriendExtraStatusAdding
    elseif tGroup and tGroup.status == BP_UnknowPass_Mission_HasGet then
      nExtraAward = UnknowPass_Mission_FriendExtraStatusHasGet
    end
  end
  return nExtraAward, nAddition
end
local BuildGroupMissionList = function(tAllTaskCfg)
  local tWeekTask = UnknowPassSystem.Data.week_task
  local tTaskGroup = UnknowPassSystem.task_group
  local nCurWeekIndex = UnknowPassMissionSystem.MissionWeekCurrentIndex
  local bIsBuyElite = UnknowPassSystem.IsBuyElite
  for nTaskId, tTaskCfg in pairs(tAllTaskCfg) do
    local tTask = tWeekTask[nTaskId]
    if tTask then
      local nGroupId = tTaskCfg.groupId
      if nGroupId == 0 or not MissionGroupIdMap[nGroupId] then
        local tGroup = tTaskGroup[nGroupId]
        local nExtraAward, nAddition = CalcFriendExtraAward(tTaskCfg, tTask.task_data, tGroup)
        local bIsOpen = nCurWeekIndex >= tTaskCfg.week_index
        local tInfo = {
          groupId = nGroupId,
          title = tTaskCfg.title,
          desc = "",
          desc2 = "",
          desc3 = "",
          process = "",
          process2 = "",
          process3 = "",
          taskId = nTaskId,
          taskId2 = 0,
          taskId3 = 0,
          weekIndex = tTaskCfg.week_index,
          status = BP_UnknowPass_Mission_NotFinish,
          score = tTaskCfg.reward_score,
          isEliteMission = tTaskCfg.is_elite_task ~= 0,
          isXMission = false,
          isOpen = bIsOpen,
          sort = -tTaskCfg.sort,
          extraAddStatus = nExtraAward,
          extraAddScore = nAddition,
          share_progress = 0,
          immFinishItemNum = tTaskCfg.immFinishItemNum,
          height = 1,
          is_season = tTaskCfg.is_season,
          reward_list = tTaskCfg.reward_list,
          elite_reward_list = tTaskCfg.elite_reward_list,
          finish_progress = tTask.task_data.finish_progress,
          received_progress = tTask.task_data.received_progress,
          total_progress = tTask.task_data.total_progress
        }
        if tInfo.isEliteMission and tInfo.status ~= BP_UnknowPass_Mission_HasGet then
          tInfo.sort = tInfo.sort + 10000
        end
        if bIsOpen then
          if tInfo.isEliteMission and not bIsBuyElite then
            tInfo.status = tTask.task_data.status
          elseif tGroup then
            tInfo.status = tGroup.status
          end
          tInfo.process = UnknowPassMissionSystem.GetProcess(tTaskCfg, tTask.task_data)
          tInfo.sort = tInfo.sort + UnknowPassMissionSystem.GetSortNumberByStatus(tInfo.status, nExtraAward)
          tInfo.share_progress = tTask.task_data.share_progress or 0
          MissionGroupSortList[nGroupId] = UnknowPassMissionSystem.GetProcessSort(tTask.task_data, tTaskCfg)
        end
        if tTaskCfg.specialType == 1 then
          tInfo.extraAddStatus = UnknowPass_Mission_ToysFriendType
          tInfo.sort = tInfo.sort + 60
        end
        UnknowPassMissionSystem.UnknowPassWeekMissionMap[nTaskId] = tInfo
        table.insert(AllMissionGroupList, tInfo)
        MissionGroupIdMap[nGroupId] = #AllMissionGroupList
      end
    end
  end
end
local ShouldAddToDisplayList = function(tInfo, nTabType, tAllTaskCfg)
  local bIsSeason = tInfo.is_season == 1
  if nTabType == 999 then
    if bIsSeason then
      return true
    end
  elseif nTabType == 2 then
    if not bIsSeason then
      return false
    end
  elseif bIsSeason then
    return false
  end
  local nSearchType = UnknowPassMissionSystem.Mission_SearchType
  local nSelectType = UnknowPassMissionSystem.Mission_CurrentSelectType
  local nRecommendType = UnknowPassMissionSystem.Mission_CurrentRecommendType
  if bIsSeason and nSearchType == 0 then
    return tInfo.isOpen
  end
  local bMatch = false
  if nSearchType == 1 then
    if nSelectType == 0 then
      bMatch = tInfo.isOpen
    else
      local tCfg = tAllTaskCfg[tInfo.taskId]
      bMatch = tCfg and tCfg.WeekMissionType == nSelectType and tInfo.isOpen
    end
  elseif nSearchType == 0 then
    bMatch = tInfo.weekIndex == UnknowPassMissionSystem.CurrentGetMissionWeekIndex
  elseif nSearchType == 2 then
    if nRecommendType == 0 then
      bMatch = tInfo.isOpen
    else
      local tCfg = tAllTaskCfg[tInfo.taskId]
      bMatch = tCfg and tCfg.task_show_type == nRecommendType and tInfo.isOpen
    end
  end
  return bMatch
end
local CalcFinalSortScore = function(tInfo)
  local nSort = -1 * tInfo.groupId
  if tInfo.status == BP_UnknowPass_Mission_Finished then
    nSort = nSort + 20000
  elseif tInfo.status == BP_UnknowPass_Mission_HasGet then
    nSort = nSort + 3000
  elseif tInfo.status == BP_UnknowPass_Mission_Expired then
    nSort = nSort + 1000
  else
    nSort = nSort + 5000
  end
  return nSort
end
local FilterAndSortWeekMissionList = function(tAllTaskCfg)
  local nTabType = UnknowPassMissionSystem.CurrentMissionTabType
  local tWeekMissionList = UnknowPassMissionSystem.Week_Mission_List
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local bIsInXMission = LogicTxMissionMain.IsInXMission()
  local bIsBuyElite = UnknowPassSystem.IsBuyElite
  for _, tInfo in ipairs(AllMissionGroupList) do
    local nProcessSort = MissionGroupSortList[tInfo.groupId]
    if nProcessSort then
      tInfo.sort = tInfo.sort + nProcessSort
    end
    if ShouldAddToDisplayList(tInfo, nTabType, tAllTaskCfg) then
      tInfo.sort = math.floor(tInfo.sort)
      table.insert(tWeekMissionList, tInfo)
    end
    tInfo.sort = CalcFinalSortScore(tInfo)
    if bIsInXMission then
      local tRPTaskDesc = CDataTable.GetTableData("RPTaskDesc", tInfo.taskId)
      if tRPTaskDesc and tRPTaskDesc.SubwayDesc and tRPTaskDesc.SubwayDesc ~= 0 then
        tInfo.isXMission = true
      end
    end
  end
  table.sort(tWeekMissionList, function(a, b)
    if a.status ~= b.status and (a.status == BP_UnknowPass_Mission_HasGet or b.status == BP_UnknowPass_Mission_HasGet) then
      return a.status ~= BP_UnknowPass_Mission_HasGet
    end
    if bIsBuyElite and a.isEliteMission ~= b.isEliteMission then
      return a.isEliteMission
    end
    if a.isXMission ~= b.isXMission then
      return a.isXMission
    end
    return a.sort > b.sort
  end)
end
function UnknowPassMissionSystem.UpdateWeekMissionList(bSkipSideEffects)
  MissionGroupIdMap = {}
  MissionGroupSortList = {}
  AllMissionGroupList = {}
  UnknowPassMissionSystem.Week_Mission_List = {}
  UnknowPassMissionSystem.UnknowPassWeekMissionMap = {}
  _bHaveCanReceive = false
  local tAllTaskCfg = UnknowPassSystem.Data.all_week_task_cfg
  if tAllTaskCfg then
    BuildGroupMissionList(tAllTaskCfg)
    FilterAndSortWeekMissionList(tAllTaskCfg)
  end
  if not bSkipSideEffects then
    UnknowPassMissionSystem.UpdateMaxWeekMissionType()
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SEASON_CHANGE)
    local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
    passReddotMainSystem.UpdateReddot()
    local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
    TaskMgrSystem.RefreshLobbyTaskRedDot()
  end
end
function UnknowPassMissionSystem.GetHaveCanReceive()
  _bHaveCanReceive = false
  for _, tTaskInfo in pairs(AllMissionGroupList) do
    if tTaskInfo.status == BP_UnknowPass_Mission_Finished and (not tTaskInfo.isEliteMission or UnknowPassSystem.IsBuyElite) then
      _bHaveCanReceive = true
      break
    end
  end
  return _bHaveCanReceive
end
function UnknowPassMissionSystem.UpdateMaxWeekMissionType()
  MissionGroupIdMap = {}
  UnknowPassMissionSystem.WeekTabIcon_List = {}
  UnknowPassMissionSystem.WeekTabTypeReddot_List = {}
  for i = 1, 5 do
    table.insert(UnknowPassMissionSystem.WeekTabIcon_List, {
      IconPath = TypeSearchIconList[i],
      TotalNum = 0,
      FinishNum = 0,
      NotFinishNum = 0
    })
    MissionGroupIdMap[i] = {}
  end
  for i = 1, 5 do
    local info = {typeIndex = i, showReddot = false}
    table.insert(UnknowPassMissionSystem.WeekTabTypeReddot_List, info)
  end
  if UnknowPassSystem.Data and UnknowPassSystem.Data.all_week_task_cfg then
    for taskId, task_cfg in pairs(UnknowPassSystem.Data.all_week_task_cfg) do
      local taskCfg
      local task = UnknowPassSystem.Data.week_task[taskId]
      local isOpen = task_cfg.week_index <= UnknowPassMissionSystem.MissionWeekCurrentIndex and task ~= nil
      if isOpen and MissionGroupIdMap[task_cfg.WeekMissionType] and MissionGroupIdMap[task_cfg.WeekMissionType][task_cfg.groupId] == nil then
        MissionGroupIdMap[task_cfg.WeekMissionType][task_cfg.groupId] = 1
        UnknowPassMissionSystem.WeekTabIcon_List[task_cfg.WeekMissionType].TotalNum = UnknowPassMissionSystem.WeekTabIcon_List[task_cfg.WeekMissionType].TotalNum + 1
        local group = UnknowPassSystem.task_group[task_cfg.groupId]
        local status = group and group.status or BP_UnknowPass_Mission_NotFinish
        if status == BP_UnknowPass_Mission_HasGet or status == BP_UnknowPass_Mission_Finished then
          UnknowPassMissionSystem.WeekTabIcon_List[task_cfg.WeekMissionType].FinishNum = UnknowPassMissionSystem.WeekTabIcon_List[task_cfg.WeekMissionType].FinishNum + 1
        end
        if status == BP_UnknowPass_Mission_NotFinish then
          UnknowPassMissionSystem.WeekTabIcon_List[task_cfg.WeekMissionType].NotFinishNum = UnknowPassMissionSystem.WeekTabIcon_List[task_cfg.WeekMissionType].NotFinishNum + 1
        end
        if status == BP_UnknowPass_Mission_Finished and (task_cfg.is_elite_task == 0 or task_cfg.is_elite_task == 1 and UnknowPassSystem.IsBuyElite) then
          UnknowPassMissionSystem.WeekTabTypeReddot_List[task_cfg.WeekMissionType].showReddot = true
        end
      end
    end
  end
end
function UnknowPassMissionSystem.OnInfoUpdate()
  log(bWriteLog and "UnknowPassMissionSystem.OnInfoUpdate")
  UnknowPassMissionSystem.MissionWeekCurrentIndex = UnknowPassSystem.Data.cur_week_index or 1
  local UnknowPassEasyTicketSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_easy_ticket")
  local hasBuyTicket = UnknowPassEasyTicketSystem.HasBuyTicket()
  if hasBuyTicket then
    UnknowPassMissionSystem.MissionWeekCurrentIndex = math.min(UnknowPassMissionSystem.MissionWeekCurrentIndex + 1, UnknowPassSystem.SeasonInfo.cfg.week_num)
  end
  local TimeUtil = require("client.common.time_util")
  UnknowPassMissionSystem.weekMissionTimestamp = TimeUtil.GetServerTimeInSec()
  UnknowPassMissionSystem.weekMissionLeftTime = UnknowPassSystem.Data.week_task_left_refresh_time
  UnknowPassMissionSystem.Has_EasyCard = hasBuyTicket
  UnknowPassMissionSystem.UpdateMaxWeekCount()
  UnknowPassMissionSystem.UpdateWeekMissionList()
  UnknowPassMissionSystem.GetWeekAwardState()
  local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
  passReddotMainSystem.UpdateReddot()
  local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
  TaskMgrSystem.RefreshLobbyTaskRedDot()
  if GameStatus.IsInLobbyOrMainCity() then
    EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_RP_REFRESH_TASK_INFO)
  end
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  if UIManager.IsUIShow(UIManager.UI_Config.New_Day_Task_UIBP) or UIManager.IsUIShow(UIManager.UI_Config.unknowpass_mission_sec) then
    UpassHandle.send_limited_time_task_sync_req(false)
  end
end
function UnknowPassMissionSystem.UpdateMaxWeekCount()
  UnknowPassMissionSystem.MaxMissionWeekCount = 1
  if UnknowPassSystem.Data.all_week_task_cfg then
    for taskId, task_cfg in pairs(UnknowPassSystem.Data.all_week_task_cfg) do
      if task_cfg and UnknowPassMissionSystem.MaxMissionWeekCount < task_cfg.week_index then
        UnknowPassMissionSystem.MaxMissionWeekCount = task_cfg.week_index
      end
    end
  end
end
function UnknowPassMissionSystem.GetProcessSort(task_data, task_cfg)
  return (task_data.value + 0.5) / task_cfg.finish_value
end
function UnknowPassMissionSystem.GetSortNumberByStatus(status, isAddition)
  local sort = 0
  if isAddition ~= UnknowPass_Mission_FriendExtraStatusNone then
    sort = 50
  end
  if status == BP_UnknowPass_Mission_HasGet then
    sort = 0 + sort
  elseif status == BP_UnknowPass_Mission_NotFinish then
    sort = 1000 + sort
  elseif status == BP_UnknowPass_Mission_Finished then
    sort = 2000 + sort
  end
  return sort
end
function UnknowPassMissionSystem.RefreshWeekTabRedDot()
  UnknowPassMissionSystem.WeekTabReddot_List = {}
  for i = 1, UnknowPassMissionSystem.MaxMissionWeekCount do
    local info = {weekIndex = i, showReddot = false}
    table.insert(UnknowPassMissionSystem.WeekTabReddot_List, info)
  end
  local bRedDot = false
  UnknowPassMissionSystem.HasWeekAward = false
  UnknowPassMissionSystem.bHasSeasonAward = false
  if UnknowPassSystem.Data.all_week_task_cfg then
    for nTaskId, tTaskCfg in pairs(UnknowPassSystem.Data.all_week_task_cfg) do
      local tTaskData = UnknowPassSystem.Data.week_task[nTaskId]
      local bCurTaskRedDot = false
      if tTaskData then
        local group = UnknowPassSystem.task_group[tTaskCfg.groupId]
        bCurTaskRedDot = group and group.status == BP_UnknowPass_Mission_Finished and (tTaskCfg.is_elite_task == 0 or tTaskCfg.is_elite_task == 1 and UnknowPassSystem.IsBuyElite)
      end
      if bCurTaskRedDot then
        bRedDot = true
        if tTaskCfg.is_season == 1 then
          UnknowPassMissionSystem.bHasSeasonAward = true
          break
        end
        UnknowPassMissionSystem.HasWeekAward = true
        do
          local nWeekIndex = tTaskCfg.week_index
          UnknowPassMissionSystem.WeekTabReddot_List[nWeekIndex].showReddot = true
        end
        break
      end
    end
  end
  local data = UnknowPassMissionSystem.limitedTimeMission
  if next(data) and data.status == BP_UnknowPass_Mission_Finished then
    bRedDot = true
  end
  bRedDot = bRedDot or UnknowPassMissionSystem.isNewWeek
  log(bWriteLog and "UnknowPassMissionSystem.RefreshWeekTabRedDot bRedDot = " .. tostring(bRedDot))
  return bRedDot
end
function UnknowPassMissionSystem.GetWeekRedDotByIndex(nWeekIndex)
  if UnknowPassMissionSystem.WeekTabReddot_List[nWeekIndex] then
    return UnknowPassMissionSystem.WeekTabReddot_List[nWeekIndex].showReddot
  end
  return false
end
function UnknowPassMissionSystem.ShowAwardList(reward_list)
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_RPRewardGet(UnknowPassUtil.GetAwardList(reward_list))
end
function UnknowPassMissionSystem.GetWeekAwardState()
  local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
  passReddotMainSystem.showWeekAward = false
  UnknowPassMissionSystem.isNewWeek = false
  if UnknowPassSystem.Data.all_week_task_cfg then
    for taskId, task_cfg in pairs(UnknowPassSystem.Data.all_week_task_cfg) do
      if task_cfg then
        local task = UnknowPassSystem.Data.week_task[taskId]
        local group = UnknowPassSystem.task_group[task_cfg.groupId]
        if group and group.status == BP_UnknowPass_Mission_Finished and (task_cfg.is_elite_task == 0 or task_cfg.is_elite_task == 1 and UnknowPassSystem.IsBuyElite) then
          passReddotMainSystem.showWeekAward = true
          break
        end
      end
    end
  end
  if UnknowPassMissionSystem.SeasonActive.received then
    for i, v in pairs(UnknowPassMissionSystem.SeasonActive.received) do
      if v.status == BP_UnknowPass_Mission_Finished then
        passReddotMainSystem.showWeekAward = true
      end
    end
  end
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local weekIndex = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, UnknowPassMacro.ENUM_Pass_Main_Reddot.ENUM_Pass_Mission_WeekTask)
  if weekIndex ~= UnknowPassSystem.Data.cur_week_index then
    UnknowPassMissionSystem.isNewWeek = true
  end
end
local ParseRewardCfg = function(nRewardId, tRewardList)
  local nScoreReward = 0
  local tRewardCfg = CDataTable.GetTableData("general_task_reward_cfg", nRewardId)
  if not tRewardCfg then
    return nScoreReward
  end
  for i = 1, 4 do
    local nResId = tRewardCfg["res_id" .. i]
    if nResId ~= 0 then
      local nCount = tRewardCfg["res_num" .. i]
      table.insert(tRewardList, {res_id = nResId, res_num = nCount})
      if nResId == UnknowPassSystem.SCORE_ITEM_ID then
        nScoreReward = nScoreReward + nCount
      end
    end
  end
  return nScoreReward
end
local BuildTaskInfoMap = function(BasicDataServerTable, data_config_marco)
  local tTaskInfoMap = {}
  local tTaskCfgDiff = BasicDataServerTable:GetCacheData(data_config_marco.general_task_week_diff_cfg_simple) or {}
  local tTaskContentCfg = BasicDataServerTable:GetCacheData(data_config_marco.general_task_week_content_cfg) or {}
  for nWeekCfgId, tTasks in pairs(tTaskContentCfg) do
    local tDiffCfg = tTaskCfgDiff[nWeekCfgId]
    if tDiffCfg and tDiffCfg.season_index == UnknowPassSystem.Season then
      local nWeekIndex = tDiffCfg.week_index
      for nGroupId, tTask in pairs(tTasks) do
        for _, nId in ipairs(tTask.task_ids) do
          tTaskInfoMap[tonumber(nId)] = {
            task_group_id = nGroupId,
            weekIndex = nWeekIndex,
            reward_id = tTask.reward_id,
            elite_award_id = tTask.elite_award_id,
            is_elite = tTask.is_elite,
            special_type = tTask.special_type,
            is_season = tTask.is_season,
            is_branch = tTask.is_branch,
            task_show_type = tTask.task_show_type
          }
        end
      end
    end
  end
  return tTaskInfoMap
end
local BuildAllWeekTaskCfg = function(tTaskInfoMap, BasicDataServerTable, data_config_marco, tImmSeasonCfg, bIsShowBPTask)
  local tAllWeekTaskCfg = {}
  local bHasData = false
  local tTaskCfgs = BasicDataServerTable:GetCacheData(data_config_marco.general_task_cond_cfg_simple) or {}
  for nId, tTaskCfg in pairs(tTaskCfgs) do
    local tInfo = tTaskInfoMap[nId]
    if tInfo then
      local nRewardId = tInfo.reward_id
      local nEliteAwardId = tInfo.elite_award_id or 0
      local RPTaskDesc = CDataTable.GetTableData("RPTaskDesc", nId)
      local tCfgInfo = {
        sort = 0,
        week_index = tInfo.weekIndex,
        finish_type = tTaskCfg.finish_type,
        finish_value = tTaskCfg.finish_value,
        is_elite_task = tInfo.is_elite,
        groupId = tInfo.task_group_id,
        WeekMissionType = RPTaskDesc and RPTaskDesc.WeekIconType or 1,
        specialType = tInfo.special_type,
        is_season = tInfo.is_season,
        reward_id = nRewardId,
        is_branch = tInfo.is_branch,
        reward_list = {},
        elite_reward_list = {},
        reward_score = 0,
        immFinishItemNum = 0,
        task_show_type = tInfo.task_show_type
      }
      if tImmSeasonCfg and tImmSeasonCfg[nRewardId] then
        tCfgInfo.immFinishItemNum = tImmSeasonCfg[nRewardId].card_num or 0
      end
      tCfgInfo.reward_score = ParseRewardCfg(nRewardId, tCfgInfo.reward_list)
      ParseRewardCfg(nEliteAwardId, tCfgInfo.elite_reward_list)
      if tInfo.is_branch == 1 then
        if bIsShowBPTask then
          tAllWeekTaskCfg[tonumber(nId)] = tCfgInfo
        end
      else
        tAllWeekTaskCfg[tonumber(nId)] = tCfgInfo
      end
      bHasData = true
    end
  end
  return tAllWeekTaskCfg, bHasData
end
function UnknowPassMissionSystem.HandleWeekServerData(data)
  log(bWriteLog and "UnknowPassMissionSystem:HandleWeekServerData - Start")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local tTaskInfoMap = BuildTaskInfoMap(BasicDataServerTable, data_config_marco)
  UnknowPassMissionSystem.MissionCardID = 1613099
  local tImmCfg = BasicDataServerTable:GetCacheData(data_config_marco.general_task_imm_card_cfg) or {}
  local tImmSeasonCfg = tImmCfg[UnknowPassSystem.Season]
  if tImmSeasonCfg then
    for _, v in pairs(tImmSeasonCfg) do
      UnknowPassMissionSystem.MissionCardID = v.card_res_id
      break
    end
  end
  log(bWriteLog and "UnknowPassMissionSystem:HandleWeekServerData - MissionCardID=" .. tostring(UnknowPassMissionSystem.MissionCardID))
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  local bIsShowBPTask = Logic_BonusPass:IsShowBranchTask()
  local tAllWeekTaskCfg, bHasData = BuildAllWeekTaskCfg(tTaskInfoMap, BasicDataServerTable, data_config_marco, tImmSeasonCfg, bIsShowBPTask)
  if bHasData then
    UnknowPassSystem.Data.all_week_task_cfg = tAllWeekTaskCfg
  end
  local tWeekTask = {}
  local tTaskGroup = {}
  for nWeekIndex, tGroupTasks in pairs(data.week_task) do
    if type(nWeekIndex) == "number" then
      for nGroupId, tGroup in pairs(tGroupTasks) do
        if type(nGroupId) == "number" then
          tTaskGroup[nGroupId] = {
            status = tGroup.status
          }
          for nTaskId, tTask in pairs(tGroup) do
            if type(nTaskId) == "number" then
              tWeekTask[nTaskId] = {
                task_data = {
                  week_index = nWeekIndex,
                  status = tGroup.status,
                  finish_progress = tGroup.finish_progress or 0,
                  received_progress = tGroup.received_progress or 0,
                  total_progress = tGroup.total_progress or 0,
                  addition = tGroup.addition,
                  value = math.floor(tTask.value),
                  share_progress = tTask.share_progress
                }
              }
            end
          end
        end
      end
    end
  end
  UnknowPassSystem.Data.week_task = tWeekTask
  UnknowPassSystem.task_group = tTaskGroup
  UnknowPassMissionSystem.SeasonActive = {
    act_id = 1,
    value = 0,
    received = {},
    weekly_value = 0
  }
  UnknowPassMissionSystem.HandleActiveData(data.season_active)
  if data.base then
    UnknowPassMissionSystem.weektask_cur_score = data.base.weektask_cur_score
    UnknowPassMissionSystem.weektask_score_limit = data.base.weektask_score_limit
    UnknowPassMissionSystem.weektask_score_limit_max = data.base.weektask_score_limit_max
    UnknowPassMissionSystem.weektask_all_score_limit_list = data.base.weektask_all_score_limit_list
  end
end
function UnknowPassMissionSystem.HandleActiveData(data)
  local season_active = data
  if season_active then
    UnknowPassMissionSystem.SeasonActive.act_id = season_active.act_id
    UnknowPassMissionSystem.SeasonActive.value = season_active.value
    UnknowPassMissionSystem.SeasonActive.weekly_value = season_active.weekly_value
  end
end
function UnknowPassMissionSystem.JumpBetweenTaskAndRP(type)
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if type == 1 then
    local logic_assembly_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_assembly_system)
    logic_assembly_system:ShowMainUI()
  else
    local jumpInfo = {}
    jumpInfo.Tab1 = 4
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_AWARD_TRIGGER)
    UnknowPassTunnelSystem.ShowRP(jumpInfo)
  end
end
function UnknowPassMissionSystem.OpenQuickTeamUP(nSource, missionID, height)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local LogicQuickTeamUp = require("client.slua.logic.teamup.logic_quick_team_up")
  LogicQuickTeamUp.Entrance(nSource, missionID, height)
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_Enter_QuickTeamUp, tostring(missionID))
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Enter_QuickTeamUp, 0, tostring(missionID))
end
function UnknowPassMissionSystem.GetCanGetTotalScore()
  local totalScore = 0
  for taskId, v in pairs(UnknowPassSystem.Data.week_task) do
    local task_cfg = UnknowPassSystem.Data.all_week_task_cfg[taskId]
    local group = UnknowPassSystem.task_group[task_cfg.groupId]
    if group and group.status == BP_UnknowPass_Mission_Finished and (task_cfg.is_elite_task == 0 or task_cfg.is_elite_task == 1 and UnknowPassSystem.IsBuyElite) then
      totalScore = totalScore + task_cfg.reward_score + (v.task_data.addition or 0)
    end
  end
  log(bWriteLog and "totalScore " .. totalScore)
  local ItemQuality = CDataTable.GetTableData("Item", 1099).ItemQuality
  return {
    [1] = {
      itemId = 1099,
      itemCount = totalScore,
          }
  }
end
function UnknowPassMissionSystem.GetCanGetActiveAward()
  local res = {}
  for k, v in pairs(UnknowPassMissionSystem.SeasonActive.received) do
    if v.status == BP_UnknowPass_Mission_Finished and #v.rewards >= 1 then
      local ItemQuality = CDataTable.GetTableData("Item", v.rewards[1].res_id).ItemQuality
      local itemCount = v.rewards[1].res_num
      table.insert(res, {
        itemId = v.rewards[1].res_id,
        itemCount = itemCount,
              })
    end
  end
  return res
end
function UnknowPassMissionSystem.GetLimitActTaskInfo()
  if not UnknowPassMissionSystem.IsLimitActOpen() then
    return
  end
  return {
    nActID = ActivityFixedID.LimitActTask,
    sName = LocUtil.GetLocalizeResStr(18187),
    bRedDot = UnknowPassMissionSystem.UpdateRedTip,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = 0
  }
end
function UnknowPassMissionSystem.UpdateRedTip()
  local hasRedDot = false
  local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
  local RedDotType = ActivityMacros.RedDotType.None
  local tRedData = UnknowPassMissionSystem.limitedTimeActMissionRedData
  if tRedData and tRedData[3] then
    hasRedDot = tRedData[3]
    if hasRedDot then
      RedDotType = ActivityMacros.RedDotType.Reward
    end
  end
  log(bWriteLog and "UnknowPassMissionSystem.UpdateRedTip " .. tostring(RedDotType))
  return hasRedDot, RedDotType
end
function UnknowPassMissionSystem.IsLimitActOpen()
  if not next(UnknowPassMissionSystem.limitedTimeActMission) then
    return false
  end
  return true
end
function UnknowPassMissionSystem.GetCanReceiveAwards()
  local awardList = {}
  local reddotUtil = require("client.slua.logic.reddot.reddot_util")
  for k, Act_task_data in pairs(UnknowPassMissionSystem.limitedTimeActMission) do
    if Act_task_data.status == BP_UnknowPass_Mission_Finished then
      for index, v in ipairs(Act_task_data.rewards) do
        table.insert(awardList, reddotUtil.CreateItem(v.res_id, v.res_num))
      end
    end
  end
  log_tree("UnknowPassMissionSystem.GetCanReceiveAwards", awardList)
  return awardList
end
function UnknowPassMissionSystem.on_general_task_week_task_batch_reward_rsp(err, result)
  if err ~= 0 then
    ShowNotice(err)
  else
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    PassDataSystem.upass_get_req()
    local UpassHandle = require("client.network.Protocol.UpassHandle")
    UpassHandle.send_general_task_sync_all_req()
    local tMapAllReward = {}
    local tAllRewardId = result.reward_id_list or {}
    for _, v in pairs(tAllRewardId) do
      local tRewardCfg = CDataTable.GetTableData("general_task_reward_cfg", v)
      for i = 1, 4 do
        local nItemId = tRewardCfg["res_id" .. i]
        local res_num = tRewardCfg["res_num" .. i]
        if nItemId == 0 then
          break
        end
        if not tMapAllReward[nItemId] then
          tMapAllReward[nItemId] = {res_id = nItemId, count = res_num}
        else
          local tCacheReward = tMapAllReward[nItemId]
          tCacheReward.count = tCacheReward.count + res_num
        end
      end
    end
    local tShowAllReward = {}
    for _, v in pairs(tMapAllReward) do
      table.insert(tShowAllReward, v)
    end
    if next(tShowAllReward) then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(tShowAllReward)
    end
  end
end
function UnknowPassMissionSystem.upass_game_end_show_tasks_notify(final_tasks)
  log_tree("upass_game_end_show_tasks_notify ", final_tasks)
  UPassgameEndShowFinishTasksList = final_tasks
  EventSystem:postEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_TDM_ON_GAME_END_TASK_UPDATE)
end
function UnknowPassMissionSystem.on_general_task_game_result_notify(active_data, task_list)
  log_tree("upass_game_end_show_tasks_notify ", active_data)
  log_tree("upass_game_end_show_tasks_notify ", task_list)
  UnknowPassMissionSystem.HandleActiveData(active_data)
  UPassgameEndShowFinishTasksList = {}
  for i, v in pairs(task_list) do
    local info = {}
    info.task_id = v.task_id
    info.task_data = {}
    info.task_data.status = v.status
    info.task_data.value = v.value
    info.task_data.finish_value = v.finish_value
    info.task_data.addition = v.addition
    info.task_data.share_progress = v.share_progress
    info.task_data.IsEliteTask = true
    local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
    info.task_data.desc = NewDayTaskSystem.GetDailyTaskDesc(v.task_id, v.finish_value)
    local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
    local data_config_marco = require("client.logic.data.data_config_marco")
    local taskContentCfg = BasicDataServerTable:GetCacheData(data_config_marco.general_task_week_content_cfg)
    if taskContentCfg and taskContentCfg[v.cfg_id] and taskContentCfg[v.cfg_id][v.task_group_id] then
      local reward_id = taskContentCfg[v.cfg_id][v.task_group_id].reward_id or 1
      local tRewardCfg = CDataTable.GetTableData("general_task_reward_cfg", reward_id)
      info.task_data.RewardScore = tRewardCfg.res_num1 or 0
      info.task_data.specialType = taskContentCfg[v.cfg_id][v.task_group_id].special_type or 0
    end
    info.sort = info.task_data.value / info.task_data.finish_value
    if info.task_data.status == BP_UnknowPass_Mission_Finished then
      info.sort = info.sort + 2000
    elseif info.task_data.status == BP_UnknowPass_Mission_NotFinish then
      info.sort = info.sort + 1000
    end
    table.insert(UPassgameEndShowFinishTasksList, info)
  end
  UnknowPassMissionSystem.SeasonActive.received = UnknowPassMissionSystem.SeasonActive.received or {}
  for i, v in pairs(UnknowPassMissionSystem.SeasonActive.received) do
    local info = {}
    info.task_id = 0
    info.task_data = {}
    info.task_data.status = v.status
    info.task_data.value = active_data.value
    info.task_data.finish_value = v.finish_value
    info.task_data.addition = 0
    info.task_data.share_progress = 0
    info.task_data.IsEliteTask = true
    info.task_data.desc = ""
    info.task_data.desc = LocUtil.LocalizeResFormat(12380, v.finish_value)
    local tRewardCfg = CDataTable.GetTableData("general_task_reward_cfg", v.reward_id)
    info.task_data.RewardScore = tRewardCfg.res_num1 or 0
    info.task_data.specialType = 0
    info.sort = info.task_data.value / info.task_data.finish_value
    if info.task_data.status == BP_UnknowPass_Mission_Finished then
      info.sort = info.sort + 2000
      table.insert(UPassgameEndShowFinishTasksList, info)
      break
    end
  end
  table.sort(UPassgameEndShowFinishTasksList, function(a, b)
    return a.sort > b.sort
  end)
  EventSystem:postEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_TDM_ON_GAME_END_TASK_UPDATE)
end
function UnknowPassMissionSystem.upass_task_share_progress_ntfy(task_id, share_progress, value, status)
  for i, v in ipairs(UPassgameEndShowFinishTasksList) do
    if v.task_id == task_id then
      v.task_data.      v.task_data.      v.task_data.      break
    end
  end
end
function UnknowPassMissionSystem.upass_imm_finish_task_rsp(ret, task_id, task_data, get_reward_num_if_buy)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
end
function UnknowPassMissionSystem.upass_task_imm_finish_rsp(ret, group_id, group, get_reward_num_if_buy)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_general_task_sync_all_req()
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.upass_get_req()
end
function UnknowPassMissionSystem.upass_task_share_progress_notify(change_tasks)
  log_tree("upass_task_share_progress_notify ", change_tasks)
  if not change_tasks or next(change_tasks) == nil then
    return
  end
  local finalListMap = {}
  for i, v in ipairs(UPassgameEndShowFinishTasksList) do
    finalListMap[v.task_id] = {}
    finalListMap[v.task_id].index = i
  end
  for task_id, task_data in pairs(change_tasks) do
    if finalListMap[task_id] and finalListMap[task_id].index and UPassgameEndShowFinishTasksList[finalListMap[task_id].index].task_data then
      UPassgameEndShowFinishTasksList[finalListMap[task_id].index].    end
  end
  EventSystem:postEvent(EVENTTYPE_ACCOUNT, EVENTID_CHANGE_SHARE_PROGRESS)
end
function UnknowPassMissionSystem.upass_task_adddition_ntfy(task_id, addition)
  for i, v in ipairs(UPassgameEndShowFinishTasksList) do
    if v.task_id == task_id then
      v.task_data.      break
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACCOUNT, EVENTID_CHANGE_SHARE_PROGRESS)
end
function UnknowPassMissionSystem.CheckRedDot()
  for _, v in pairs(UnknowPassMissionSystem.Week_Mission_List) do
    if v.status == BP_UnknowPass_Mission_Finished then
      return true, ActivityMacros.RedDotType.Reward
    end
  end
  return false, ActivityMacros.RedDotType.None
end
function UnknowPassMissionSystem.GetActivitySubData()
  if not LobbySystem.CheckOpen(BP_ENUM_SHOW_RP_IN_ACTIVITY) then
    log(bWriteLog and "UnknowPassMissionSystem:BP_ENUM_SHOW_RP_IN_ACTIVITY close  20388")
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  UnknowPassMissionSystem.Mission_SearchType = 0
  UnknowPassMissionSystem.MissionWeekCurrentIndex = UnknowPassSystem.Data.cur_week_index or 1
  UnknowPassMissionSystem.CurrentGetMissionWeekIndex = UnknowPassMissionSystem.MissionWeekCurrentIndex
  UnknowPassMissionSystem.UpdateWeekMissionList()
  local hasTask
  for _, v in pairs(UnknowPassMissionSystem.UnknowPassWeekMissionMap) do
    if v.weekIndex == UnknowPassMissionSystem.CurrentGetMissionWeekIndex then
      hasTask = true
      break
    end
  end
  if not hasTask then
    log(bWriteLog and "  : no Week_Mission_List")
    return nil
  end
  return {
    nActID = ActivityFixedID.Act_RP_Task_UIBP,
    sName = LocUtil.GetLocalizeResStr(48701),
    bRedDot = UnknowPassMissionSystem.CheckRedDot,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = TimeUtil.GetServerTimeInSec()
  }
end
function UnknowPassMissionSystem.OrganizeTaskRewardData(tRewardList, tAllReward)
  local Logic_RpGiftSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  local fGetRpResIDByPointType = Logic_RpGiftSystem.GetRpResIDByPointType
  local bIsRpScore = false
  for _, v in pairs(tRewardList) do
    if Logic_RpGiftSystem.CheckNormalRPIcon(v.res_id) then
      bIsRpScore = true
    end
    local nItemId = fGetRpResIDByPointType(v.res_id)
    tAllReward[nItemId] = (tAllReward[nItemId] or 0) + v.res_num
  end
  return bIsRpScore
end
function UnknowPassMissionSystem.ShowTaskRewardGet(week_index, task_group_id)
  if UnknowPassMissionSystem.Week_Mission_List ~= nil then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    local bIsRpScore = false
    for _, info in pairs(UnknowPassMissionSystem.Week_Mission_List) do
      if info and info.weekIndex == week_index and info.groupId == task_group_id then
        local tAllReward = {}
        if info.reward_list and next(info.reward_list) then
          bIsRpScore = UnknowPassMissionSystem.OrganizeTaskRewardData(info.reward_list, tAllReward)
        end
        local bElite = UnknowPassSystem.IsBuyElite and UnknowPassSystem.PassType == 2
        bIsRpScore = bElite and info.elite_reward_list and next(info.elite_reward_list) and UnknowPassMissionSystem.OrganizeTaskRewardData(info.elite_reward_list, tAllReward) or bIsRpScore
        if next(tAllReward) then
          local tAllShowReward = {}
          for k, v in pairs(tAllReward) do
            table.insert(tAllShowReward, {res_id = k, count = v})
          end
          Logic_CommonItemGet.ShowPanel_DefaultStyle(tAllShowReward)
        end
        if bIsRpScore then
          local rpgiftSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
          local tip = rpgiftSystem.GetActRPPointDesc()
          ShowNotice(tip)
        end
        return
      end
    end
  end
end
return UnknowPassMissionSystem