local logic_longline_task = {
  Enum_Reward = {
    All = 0,
    Level = 1,
    DayTask = 2,
    WeekLogin = 3,
    Team = 4
  },
  E_Reward_State = {
    Not = 0,
    CanGet = 1,
    HasGot = 2
  },
  E_Preview_Type = {Display = 1, Select = 2},
  isShowLongline = false,
  curLevel = 0,
  curScore = 0,
  teamBattleCnt = 0,
  rewardList = {},
  totalSummaryData = nil,
  dayTaskList = nil,
  dayTaskRewardList = {},
  specialList = {},
  scoreToLvNum = 0,
  allLevelRewardList = {},
  inviter_list = {},
  hasReqBackUserData = false,
  is_new_pool_mode = false,
  daily_score_limit = 0,
  daily_score_gained = 0,
  hasReachedToScoreLimit = false
}
local TimeUtil = require("client.common.time_util")
local isInitedTaskData
function logic_longline_task.on_backuser_longline_task_notify(task_data, task_list, task_reward_config, week_login_config, score_buy_config, exchange_cfg, inviter_list)
  log(bWriteLog and "logic_longline_task.on_backuser_longline_task_notify")
  if not logic_longline_task.isShowLongline then
    logic_longline_task.isShowLongline = true
  end
  local lastData
  if task_data then
    if logic_longline_task.totalSummaryData then
      local TableUtil = require("common.table_util")
      lastData = TableUtil.CopyTable(logic_longline_task.totalSummaryData)
    end
    logic_longline_task.totalSummaryData = task_data
    if task_data.score and task_data.score ~= logic_longline_task.curScore then
      logic_longline_task.curScore = task_data.score
      EventSystem:postEvent(EVENTTYPE_LONGLINE_TASK, EVENTID_LONGLINE_TASK_UPDATE_SCORE)
    end
    local bShouldUpdateReward = false
    if task_data.level and task_data.level ~= logic_longline_task.curLevel then
      logic_longline_task.curLevel = task_data.level
      bShouldUpdateReward = true
      logic_longline_task.PostRefreshRedEvent(logic_longline_task.Enum_Reward.Level)
    end
    if task_data.team_battle_cnt and task_data.team_battle_cnt ~= logic_longline_task.teamBattleCnt then
      logic_longline_task.teamBattleCnt = task_data.team_battle_cnt
      bShouldUpdateReward = true
      logic_longline_task.PostRefreshRedEvent(logic_longline_task.Enum_Reward.Team)
    end
    log(bWriteLog and string.format("logic_longline_task.on_backuser_longline_task_notify bShouldUpdateReward = %s", tostring(bShouldUpdateReward)))
    if bShouldUpdateReward then
      EventSystem:postEvent(EVENTTYPE_LONGLINE_TASK, EVENTID_LONGLINE_TASK_UPDATE_REWARD)
    end
  end
  if score_buy_config then
    for key, value in pairs(score_buy_config) do
      logic_longline_task.scoreToLvNum = key
    end
  end
  if task_reward_config then
    logic_longline_task.dayTaskRewardList = task_reward_config
  end
  logic_longline_task.HandleDayTaskData(task_list)
  if task_data then
    logic_longline_task.RefreshRedDot(lastData)
  end
  logic_longline_task.  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  LogicTeamUpSideBar.recallerIdList = inviter_list
  if task_data and task_data.daily_score_limit and task_data.daily_score_limit > 0 then
    logic_longline_task.is_new_pool_mode = true
    local daily_score_limit = tonumber(task_data.daily_score_limit) or 0
    logic_longline_task.    local daily_score_gained = tonumber(task_data.daily_score_gained) or 0
    logic_longline_task.    if not logic_longline_task.hasReachedToScoreLimit then
      log(bWriteLog and "logic_longline_task.on_backuser_longline_task_notify score:", daily_score_limit, daily_score_gained)
      if daily_score_limit <= daily_score_gained then
        log(bWriteLog and "logic_longline_task.on_backuser_longline_task_notify score to limit")
        logic_longline_task.hasReachedToScoreLimit = true
        EventSystem:postEvent(EVENTTYPE_LONGLINE_TASK, EVENTID_LONGLINE_TASK_SCORE_TO_LIMIT)
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_LONGLINE_TASK, EVENTID_LONGLINE_TASK_NOTIFY)
end
function logic_longline_task.HandleDayTaskData(task_list)
  if not task_list then
    return
  end
  local needRefreshRedDot = false
  if logic_longline_task.dayTaskList ~= nil then
    for k, v in pairs(task_list) do
      if logic_longline_task.dayTaskList[k] and logic_longline_task.dayTaskList[k].status ~= v.status then
        needRefreshRedDot = true
        break
      end
    end
  end
  logic_longline_task.dayTaskList = task_list
  if needRefreshRedDot and GameStatus.IsInLobbyOrMainCity() then
    logic_longline_task.PostRefreshRedEvent(logic_longline_task.Enum_Reward.DayTask)
  end
end
function logic_longline_task.RefreshRedDot(lastData)
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local newData = logic_longline_task.GetSummaryData()
  if not isInitedTaskData then
    isInitedTaskData = true
    logic_longline_task.PostRefreshRedEvent(logic_longline_task.Enum_Reward.All)
    return
  end
  if not lastData or not newData then
    return
  end
  local oldWeekLoginState = lastData.week_login_status or {}
  local newWeekLoginState = newData.week_login_status or {}
  for week_index, state in pairs(newWeekLoginState) do
    if oldWeekLoginState[week_index] ~= state then
      logic_longline_task.PostRefreshRedEvent(logic_longline_task.Enum_Reward.WeekLogin)
      break
    end
  end
  local oldLevelRewardState = lastData.reward_status or {}
  local newLevelRewardState = newData.reward_status or {}
  for level, time in pairs(newLevelRewardState) do
    if not oldLevelRewardState[level] or oldLevelRewardState[level] ~= time then
      logic_longline_task.PostRefreshRedEvent(logic_longline_task.Enum_Reward.Level)
      break
    end
  end
  local oldTeamRewardState = lastData.team_battle_reward_status or {}
  local newTeamRewardState = newData.team_battle_reward_status or {}
  for level, time in pairs(newTeamRewardState) do
    if not oldTeamRewardState[level] or oldTeamRewardState[level] ~= time then
      logic_longline_task.PostRefreshRedEvent(logic_longline_task.Enum_Reward.Team)
      break
    end
  end
end
function logic_longline_task.PostRefreshRedEvent(rewardType)
  EventSystem:postEvent(EVENTTYPE_LONGLINE_TASK, EVENTID_LONGLINE_REFRESH_REDDOT_INFO, rewardType)
end
function logic_longline_task.ReportEvent_GetPoint(param)
  local logic_user_ctrl = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_user_ctrl)
  if logic_user_ctrl:IsReturnUser() then
    local StatManager = import("StatManager")
    local BusinessHelper = import("BusinessHelper")
    StatManager.GetInstance():ReportEventWithParam(82, {
      openId = BusinessHelper.GetOpenId(),
      nation = DataMgr.roleData.nation,
      param = tostring(param)
    }, true)
  end
end
function logic_longline_task.IsLevelAwardHasGet(level)
  local summary_data = logic_longline_task.GetSummaryData()
  if summary_data.reward_status and summary_data.reward_status[level] then
    return true
  end
  return false
end
function logic_longline_task.IsLevelTeamAwardHasGet(level)
  local summary_data = logic_longline_task.GetSummaryData()
  if not logic_longline_task.rewardList[level].team_reward or not next(logic_longline_task.rewardList[level].team_reward) then
    return -1
  end
  if summary_data.team_battle_reward_status and summary_data.team_battle_reward_status[level] then
    return 1
  end
  return 0
end
function logic_longline_task.GetSummaryData()
  return logic_longline_task.totalSummaryData or {}
end
function logic_longline_task.GetDayTaskListData()
  return logic_longline_task.dayTaskList or {}
end
function logic_longline_task.GetLevelRewardConfig()
  return logic_longline_task.rewardList or {}
end
function logic_longline_task.GetSpecialItemList()
  return logic_longline_task.specialList or {}
end
function logic_longline_task.IsMaxLevel()
  if logic_longline_task.rewardList and #logic_longline_task.rewardList > 0 and logic_longline_task.curLevel >= #logic_longline_task.rewardList then
    log(bWriteLog and " logic_longline_task.IsMaxLevel = true")
    return true
  end
  log(bWriteLog and " logic_longline_task.IsMaxLevel = false")
  return false
end
function logic_longline_task.GetTotalScore()
  local curLevel = logic_longline_task.curLevel or 0
  local curScore = logic_longline_task.curScore or 0
  if not logic_longline_task.rewardList or not next(logic_longline_task.rewardList) then
    return curScore
  end
  for level, awardData in pairs(logic_longline_task.rewardList) do
    if level < curLevel then
      curScore = curScore + awardData.score
    end
  end
  return curScore
end
function logic_longline_task.GetExtraScore()
  local curScore = logic_longline_task.curScore or 0
  if not logic_longline_task.IsMaxLevel() then
    return 0
  end
  return curScore
end
function logic_longline_task.isHaveTaskReward()
  log(bWriteLog and "logic_longline_task.isHaveLevelOrTaskReward")
  local taskDataList = logic_longline_task.GetDayTaskListData()
  for _, taskData in pairs(taskDataList) do
    if taskData.status == logic_longline_task.E_Reward_State.CanGet then
      return true
    end
  end
end
function logic_longline_task.isHaveLevelOrTaskReward()
  local taskDataList = logic_longline_task.GetDayTaskListData()
  for _, taskData in pairs(taskDataList) do
    if taskData.status == logic_longline_task.E_Reward_State.CanGet then
      return true
    end
  end
  local allLevelRewardsList = logic_longline_task.GetAllCanGetRewards() or {}
  log_tree(bWriteLog and "logic_longline_task.isHaveLevelOrTaskReward allLevelRewardsList", allLevelRewardsList)
  if not next(allLevelRewardsList) then
    return false
  end
  return true
end
function logic_longline_task.CheckSelectRewardReceived()
  local logic_return_activity_level_reward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_level_reward)
  local level = logic_return_activity_level_reward:GetNextCanGetSelectLevel()
  if level and GameStatus.IsInLobbyOrMainCity() then
    UIManager.ShowUI(UIManager.UI_Config.ReturnAtivity_Popup_MultipleChoose_UIBP, level)
    return true
  end
  return false
end
function logic_longline_task.send_backuser_longline_task_reward_req(reward_type, param)
  local PlayerRetrunHandler = require("client.network.Protocol.PlayerReturnHandler")
  PlayerRetrunHandler.send_backuser_longline_task_reward_req(reward_type, param)
end
function logic_longline_task.on_backuser_longline_task_reward_res(reward_type, param)
  local curtime = TimeUtil.GetServerTimeInSec()
  if reward_type == logic_longline_task.Enum_Reward.All then
    local allLevelRewardsList = logic_longline_task.GetAllCanGetRewards(true) or {}
    if next(allLevelRewardsList) then
      for key, _ in pairs(logic_longline_task.rewardList) do
        if key <= logic_longline_task.curLevel and not logic_longline_task.IsLevelAwardHasGet(key) and logic_longline_task.totalSummaryData then
          logic_longline_task.totalSummaryData.reward_status[key] = curtime
        end
      end
    end
    local TableUtil = require("common.table_util")
    if type(param) == "table" then
      for i, v in ipairs(param or {}) do
        logic_longline_task.OnGetDayTaskReward(v, true)
        local arrayItemList = logic_longline_task.GetAwardInfoByTaskNo(v) or {}
        if 0 < #arrayItemList then
          for k, v in pairs(arrayItemList) do
            table.insert(allLevelRewardsList, v)
          end
        end
      end
    end
    log_tree(bWriteLog and "logic_longline_task.on_backuser_longline_task_reward_res allLevelRewardsList", allLevelRewardsList)
    if not next(allLevelRewardsList) then
      logic_longline_task.CheckSelectRewardReceived()
      return
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    local tExtendData = {
      fCloseCallback = logic_longline_task.CheckSelectRewardReceived
    }
    Logic_CommonItemGet.ShowPanel_DefaultStyle(allLevelRewardsList, nil, nil, tExtendData)
    logic_longline_task.PostRefreshRedEvent(logic_longline_task.Enum_Reward.Level)
  elseif reward_type == logic_longline_task.Enum_Reward.Level then
    local rewardData = logic_longline_task.GetLevelRewardList(param, true)
    if rewardData then
      if logic_longline_task.totalSummaryData then
        logic_longline_task.totalSummaryData.reward_status[param] = curtime
      end
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      local logic_return_activity_level_reward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_level_reward)
      local tExtendData
      if logic_return_activity_level_reward:IsSelectReward(param) then
        tExtendData = {
          fCloseCallback = logic_longline_task.CheckSelectRewardReceived
        }
      end
      Logic_CommonItemGet.ShowPanel_DefaultStyle(rewardData, nil, nil, tExtendData)
    end
    logic_longline_task.PostRefreshRedEvent(logic_longline_task.Enum_Reward.Level)
  elseif reward_type == logic_longline_task.Enum_Reward.Team then
    local teamRewardData = logic_longline_task.GetTeamLevelRewardList(param)
    if teamRewardData then
      if logic_longline_task.totalSummaryData then
        if not logic_longline_task.totalSummaryData.team_battle_reward_status then
          logic_longline_task.totalSummaryData.team_battle_reward_status = {}
        end
        logic_longline_task.totalSummaryData.team_battle_reward_status[param] = curtime
      end
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(teamRewardData)
    end
    logic_longline_task.PostRefreshRedEvent(logic_longline_task.Enum_Reward.Team)
  elseif reward_type == logic_longline_task.Enum_Reward.DayTask then
    logic_longline_task.OnGetDayTaskReward(param)
  end
  EventSystem:postEvent(EVENTTYPE_LONGLINE_TASK, EVENTID_LONGLINE_TASK_UPDATE_REWARD)
end
function logic_longline_task.GetRewardList(rewardInfo, strId, strNum)
  local arrayItemList = {}
  if not rewardInfo then
    return arrayItemList
  end
  strId = strId or "reward_id"
  strNum = strNum or "reward_num"
  local idx = 1
  while true do
    local res_id = rewardInfo[strId .. idx]
    local num = rewardInfo[strNum .. idx]
    if res_id ~= nil and res_id ~= 0 then
      local arrayItem = {}
      arrayItem.      arrayItem.count = num
      table.insert(arrayItemList, arrayItem)
      idx = idx + 1
    else
      break
    end
  end
  return arrayItemList
end
function logic_longline_task.GetAwardInfoByTaskNo(taskNo)
  local rewardInfo = {}
  if logic_longline_task.dayTaskRewardList and logic_longline_task.dayTaskRewardList[taskNo] then
    local info = logic_longline_task.dayTaskRewardList[taskNo]
    rewardInfo = logic_longline_task.GetRewardList(info)
  end
  return rewardInfo
end
function logic_longline_task.GetCurLevelScoreConfig()
  local rewardList = logic_longline_task.rewardList
  if not rewardList or not rewardList[logic_longline_task.curLevel] then
    log(bWriteLog and " GetCurLevelScoreConfig is nil : curLevel = " .. tostring(logic_longline_task.curLevel))
    return
  end
  return rewardList[logic_longline_task.curLevel].score
end
function logic_longline_task.OnGetDayTaskReward(task_no, donShowItemGet)
  logic_longline_task.curLevel = logic_longline_task.curLevel + 1
  if logic_longline_task.curLevel >= logic_longline_task.scoreToLvNum then
    logic_longline_task.curLevel = logic_longline_task.curLevel - logic_longline_task.scoreToLvNum
  end
  if logic_longline_task.dayTaskList and logic_longline_task.dayTaskList[task_no] then
    logic_longline_task.dayTaskList[task_no].status = logic_longline_task.E_Reward_State.HasGot
  end
  local arrayItemList = logic_longline_task.GetAwardInfoByTaskNo(task_no)
  if 0 < #arrayItemList and not donShowItemGet then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList)
  end
  EventSystem:postEvent(EVENTTYPE_LONGLINE_TASK, EVENTID_LONGLINE_GET_DAYTASK_REWARD, task_no)
  logic_longline_task.PostRefreshRedEvent(logic_longline_task.Enum_Reward.All)
  logic_longline_task.ReportEvent_GetPoint(task_no)
end
function logic_longline_task.HandleLevelRewardData()
  if not DataMgr.roleData.back_user_data then
    return
  end
  if not logic_longline_task.totalSummaryData then
    logic_longline_task.totalSummaryData = {}
  end
  logic_longline_task.totalSummaryData.select_idxs = DataMgr.roleData.back_user_data.longline_select_idx or {}
  logic_longline_task.rewardList = DataMgr.roleData.back_user_data.longline_select_items or {}
  logic_longline_task.totalSummaryData.reward_status = DataMgr.roleData.back_user_data.level_reward_status or {}
  logic_longline_task.totalSummaryData.team_battle_reward_status = DataMgr.roleData.back_user_data.team_battle_reward_status or {}
  logic_longline_task.teamBattleCnt = DataMgr.roleData.back_user_data.team_battle_cnt or 0
  logic_longline_task.specialList = {}
  for key, value in pairs(logic_longline_task.rewardList) do
    if value.special_display == 1 then
      local special_reward = value or {}
      special_reward.level = key
      table.insert(logic_longline_task.specialList, special_reward)
    end
    if not logic_longline_task.allLevelRewardList then
      logic_longline_task.allLevelRewardList = {}
    end
    local list = logic_longline_task.GetLevelRewardList(key)
    table.insert(logic_longline_task.allLevelRewardList, list)
  end
  table.sort(logic_longline_task.specialList, function(a, b)
    return a.level < b.level
  end)
end
function logic_longline_task.GetLevelRewardList(level, isForceRresh)
  local levelRewardList = {}
  local rewardData = logic_longline_task.rewardList[level]
  if not rewardData or not rewardData.items then
    return
  end
  local tab = {}
  logic_longline_task.allLevelRewardList = logic_longline_task.allLevelRewardList or {}
  if logic_longline_task.allLevelRewardList[level] and #logic_longline_task.allLevelRewardList[level] > 0 and not isForceRresh then
    tab = {}
    for key, value in pairs(logic_longline_task.allLevelRewardList[level]) do
      tab[key] = tab[key] or {}
      for kk, vv in pairs(value) do
        tab[key][kk] = vv
      end
    end
    return tab
  end
  if logic_longline_task.totalSummaryData and logic_longline_task.totalSummaryData.select_idxs then
    local selectRewardIndex = logic_longline_task.totalSummaryData.select_idxs[level]
    selectRewardIndex = selectRewardIndex or 1
    for key, value in pairs(rewardData.select_items) do
      if selectRewardIndex == value.index then
        local t = {
          res_id = key,
          count = value.num,
          isSelect = true,
          valid_hours = value.valid_hours
        }
        table.insert(levelRewardList, t)
      end
    end
  end
  for key, value in pairs(rewardData.items) do
    local _tab = {
      res_id = key,
      count = value.num,
      valid_hours = value.valid_hours
    }
    table.insert(levelRewardList, _tab)
  end
  return levelRewardList
end
function logic_longline_task.GetTeamLevelRewardList(level)
  local allRewardsList = {}
  if logic_longline_task.totalSummaryData and logic_longline_task.totalSummaryData.team_battle_reward_status and not logic_longline_task.totalSummaryData.team_battle_reward_status[level] then
    for k, v in pairs(LobbySystem.roleData.back_user_data.longline_select_items[level].team_reward or {}) do
      local data = {}
      data.res_id = k
      data.count = v.num
      data.valid_hours = v.valid_hours
      table.insert(allRewardsList, data)
    end
  end
  return allRewardsList
end
function logic_longline_task.GetAllCanGetRewards(bExcludeSelectReward)
  local logic_return_activity_level_reward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_level_reward)
  local allRewardsList = {}
  for level, _ in pairs(logic_longline_task.rewardList or {}) do
    if not logic_longline_task.IsLevelAwardHasGet(level) and level <= logic_longline_task.curLevel then
      local isSkip = false
      if bExcludeSelectReward and logic_return_activity_level_reward and logic_return_activity_level_reward:IsSelectReward(level) then
        isSkip = true
      end
      if not isSkip then
        local tab = logic_longline_task.GetLevelRewardList(level)
        if not next(allRewardsList) then
          for k, v in pairs(tab) do
            allRewardsList[k] = allRewardsList[k] or {}
            allRewardsList[k].count = v.count
            allRewardsList[k].res_id = v.res_id
            allRewardsList[k].valid_hours = v.valid_hours
          end
        else
          for _, val in ipairs(tab) do
            local isInsert = true
            for _, vv in pairs(allRewardsList) do
              if val.res_id == vv.res_id then
                vv.count = vv.count + val.count
                isInsert = false
              end
            end
            if isInsert then
              table.insert(allRewardsList, val)
            end
          end
        end
      end
    end
  end
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  if logic_return_activity and logic_return_activity:ReturnActivityABTest() then
    for level, _ in pairs(logic_longline_task.rewardList or {}) do
      if logic_longline_task.IsLevelTeamAwardHasGet(level) == 0 and level <= logic_longline_task.curLevel and logic_longline_task.rewardList[level].team_cnt and logic_longline_task.rewardList[level].team_cnt ~= 0 and logic_longline_task.rewardList[level].team_cnt <= logic_longline_task.teamBattleCnt then
        for k, v in pairs(logic_longline_task.rewardList[level].team_reward or {}) do
          local data = {
            res_id = k,
            count = v.num,
            valid_hours = v.valid_hours
          }
          table.insert(allRewardsList, data)
        end
      end
    end
  end
  return allRewardsList
end
function logic_longline_task.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Login then
    logic_longline_task.ResetData()
  end
  local lastStatus = GameStatus.GetLastGameStatus()
  if GameStatus.GetGameStatus() == GameStatus.Lobby and lastStatus == GameStatus.Fighting then
    log(bWriteLog and " logic_longline_task.OnModePostSwitch PostRefreshRedEvent")
    logic_longline_task.PostRefreshRedEvent(logic_longline_task.Enum_Reward.All)
  end
end
function logic_longline_task.ResetData()
  logic_longline_task.isShowLongline = false
  logic_longline_task.totalSummaryData = nil
  logic_longline_task.dayTaskList = nil
  logic_longline_task.rewardList = nil
  logic_longline_task.allLevelRewardList = nil
  isInitedTaskData = false
  logic_longline_task.hasReqBackUserData = false
  logic_longline_task.curLevel = 0
  logic_longline_task.teamBattleCnt = 0
end
function logic_longline_task.SetShowSendGiftTipsTime(uid)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSpaceGiftToReturnPlayerInfo) or {}
  local curTime = TimeUtil.GetServerTimeInSec()
  if not cfg[uid] then
    cfg[uid] = {}
  end
  if cfg[uid].showTime and TimeUtil.IsSameDay(curTime, cfg[uid].showTime) then
    return
  end
  cfg[uid].showTime = curTime
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eSpaceGiftToReturnPlayerInfo)
end
function logic_longline_task.GetAllShowSendGiftTipsCount()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSpaceGiftToReturnPlayerInfo) or {}
  local count = 0
  local curTime = TimeUtil.GetServerTimeInSec()
  for _, info in pairs(cfg) do
    if info.showTime then
      if not TimeUtil.IsSameDay(curTime, info.showTime) then
        info.showTime = nil
      else
        count = count + 1
      end
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eSpaceGiftToReturnPlayerInfo)
  return count
end
function logic_longline_task.GetShowSendGiftTipsCount(uid)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSpaceGiftToReturnPlayerInfo) or {}
  if not cfg[uid] or not cfg[uid].showTime then
    return 0
  end
  local curTime = TimeUtil.GetServerTimeInSec()
  if not TimeUtil.IsSameDay(curTime, cfg[uid].showTime) then
    return 0
  end
  return 1
end
function logic_longline_task.CheckSendGiftTimeValidity(uid)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSpaceGiftToReturnPlayerInfo) or {}
  if not cfg[uid] or not cfg[uid].sendTime then
    return true
  end
  local curTime = TimeUtil.GetServerTimeInSec()
  if TimeUtil.IsSameDay(curTime, cfg[uid].sendTime) then
    return false
  end
  return true
end
function logic_longline_task.CheckNeedShowSendGiftTips(uid)
  if logic_longline_task.GetShowSendGiftTipsCount(uid) >= 1 then
    return false
  end
  if logic_longline_task.GetAllShowSendGiftTipsCount() >= 3 then
    return false
  end
  if not logic_longline_task.CheckSendGiftTimeValidity(uid) then
    return false
  end
  return true
end
function logic_longline_task.SaveSendGiftToReturnInfo(uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    return
  end
  local logic_oldfriend_care = require("client.slua.logic.oldfriend.logic_oldfriend_care")
  if not logic_oldfriend_care.IsRejoinPlayer(profile) then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSpaceGiftToReturnPlayerInfo) or {}
  if not cfg[uid] then
    cfg[uid] = {}
  end
  local curTime = TimeUtil.GetServerTimeInSec()
  if cfg[uid].sendTime and TimeUtil.IsSameDay(curTime, cfg[uid].sendTime) then
    return
  end
  cfg[uid].sendTime = curTime
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eSpaceGiftToReturnPlayerInfo)
end
function logic_longline_task.GetRecall()
  local inviterList = logic_longline_task.GetRecallIDList()
  if not inviterList or not next(inviterList) then
    return
  end
  local members = {}
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, uid in pairs(inviterList) do
    if LogicFriend.IsMyFriend(uid) then
      local status = PlayerStatusMgr:GetStatusData(uid)
      local info = {
        uid = uid,
        online = status and status.online or 0,
        lastOnlineTime = logic_profile:GetLastOnlineTime(uid) or 0
      }
      table.insert(members, info)
    end
  end
  local recallMap = LogicFriend.GetStrangerRecallList()
  for _, info in pairs(recallMap) do
    table.insert(members, info)
  end
  table.sort(members, function(a, b)
    if a.online == b.online then
      if (a.intimacy or 0) == (b.intimacy or 0) then
        return (a.lastOnlineTime or 0) > (b.lastOnlineTime or 0)
      else
        return (a.intimacy or 0) > (b.intimacy or 0)
      end
    else
      return (a.online or 0) > (b.online or 0)
    end
  end)
  return members
end
function logic_longline_task.ReqStrangerRecallInfo()
  local inviterList = logic_longline_task.GetRecallIDList()
  if not inviterList or not next(inviterList) then
    return
  end
  local strangerUids = {}
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  for _, uid in pairs(inviterList) do
    if not LogicFriend.IsMyFriend(uid) then
      table.insert(strangerUids, uid)
    end
  end
  if #strangerUids == 0 then
    return
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.StrangerRecall, strangerUids, function()
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RECALL_STATE_CHANGE)
  end)
  local needReqUids = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, v in ipairs(strangerUids) do
    local profile = logic_profile:GetLocalProfile(v)
    if not profile then
      table.insert(needReqUids, v)
    end
  end
  if 0 < #needReqUids then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(needReqUids, nil, Enum_PROFILE_REPORT_CFG.RETURN_RECALL_LIST)
  end
end
function logic_longline_task.GetRecallIDList()
  if not logic_longline_task.inviter_list then
    return {}
  end
  local IDs = {}
  for uid, _ in pairs(logic_longline_task.inviter_list) do
    table.insert(IDs, uid)
  end
  return IDs
end
function logic_longline_task.IsHaveRcallTask()
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local taskInfo = logic_longline_task.GetDayTaskListData()
  for _, info in pairs(taskInfo) do
    for _, type in pairs(return_activity_macro.Enum_DayRecallTaskType) do
      if type == info.task_type then
        return true
      end
    end
  end
  return false
end
function logic_longline_task.IsRecaller(playerUid)
  local inviterList = logic_longline_task.GetRecallIDList()
  if not inviterList or not next(inviterList) then
    return 0
  end
  for _, uid in ipairs(inviterList) do
    if uid == playerUid then
      return 1
    end
  end
  return 0
end
function logic_longline_task.UpdateSelectIndex(list)
  if not logic_longline_task.totalSummaryData then
    logic_longline_task.totalSummaryData = {}
  end
  logic_longline_task.totalSummaryData.select_idxs = list
end
return logic_longline_task