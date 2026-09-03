local logic_corps_fight = {
  We = 1,
  Enemy = 2,
  ShowTipFlag = true,
  ShowFightTip = false,
  req_enemy_summary = false
}
local Color = {Blue = 1, Red = 2}
logic_corps_fight.COLOR = Color
local error_code = {
  corps_race_act_not_in_time = 111340,
  corps_race_act_cannot_enroll = 111341,
  corps_race_change_active_type_limit = 111342,
  corps_race_member_num_limit = 111343,
  corps_race_act_already_enrolled = 111344,
  corps_race_act_enroll_qps_limit = 111345,
  corps_race_act_week_active_cfg_err = 111346,
  corps_race_act_leaguesvr_no_inited = 111347,
  corps_race_act_leaguesvr_db_error = 111348,
  corps_race_act_not_enrolled = 111349,
  corps_race_act_enroll_cding = 111350,
  corps_race_act_already_rewarded = 111351,
  corps_race_act_personal_score_limit = 111352,
  corps_race_act_not_in_reward_time = 111353,
  corps_race_act_status_not_calc = 111354,
  corps_race_act_add_res_failed = 111355
}
local DEBUG_TIME
local GetServerTimeInUTC = function()
  if DEBUG_TIME then
    return DEBUG_TIME
  end
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.GetServerTimeInSec()
end
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local corpsRaceActConfig
local PHASE = {
  Register = 1,
  Free1 = 2,
  Fight = 3,
  Free2 = 4,
  Free3 = 5
}
local RESULT = {
  Win = 1,
  Tie = 2,
  Failure = 3,
  Flow = 4
}
logic_corps_fight.local reqTime = 0
local corpsRaceTaskConfig, corpsRaceDailyTaskConfig, corpsRaceRewardConfig, corpsRacePersonRewardConfig
local totalDay = 15
local corpfightInfo, corpMemberScoreList, corpsRaceImageConfig, corpsRaceOccupyImageConfig, enemyCorpsInfo, showscore
local corpsDayTaskTimes = 4
local gm_member_limit_flag
local cache_data = {
  curTimeCfg = nil,
  curPhase = nil,
  raceData = {},
  occupySupplyScore = {},
  colorPos = {}
}
local corpsRaceRewardPreviewConfig, taskTipMsgCache
local convertStringTblToNumberTbl = function(tbl)
  local num = #tbl
  for i = 1, num do
    tbl[i] = tonumber(tbl[i]) or 0
  end
  return tbl
end
local splitItemBycomma = function(cfgItem, keyTbl)
  local itemTemp = {}
  for i, k in ipairs(keyTbl) do
    local resStr = cfgItem[k]
    if resStr ~= "" then
      local StringUtil = require("common.string_util")
      itemTemp[k] = StringUtil.SplitToNum(resStr, ";")
    end
  end
  return itemTemp
end
local packItem = function(itemId, num, expire)
  if itemId ~= 0 then
    return {
      itemId,
      num,
      expire
    }
  else
    return nil
  end
end
local arrangeItem = function(itemTbl, keyTbl)
  local retItemList = {}
  local itemIDKey = keyTbl[1]
  local itemNumKey = keyTbl[2]
  local itemExpireKey = keyTbl[3]
  if next(itemTbl) then
    local itemIDArr = itemTbl[itemIDKey]
    local itemNumArr = itemTbl[itemNumKey]
    local itemExpireArr = itemTbl[itemExpireKey]
    retItemList[RESULT.Win] = packItem(itemIDArr[RESULT.Win], itemNumArr[RESULT.Win], itemExpireArr[RESULT.Win])
    retItemList[RESULT.Failure] = packItem(itemIDArr[RESULT.Failure], itemNumArr[RESULT.Failure], itemExpireArr[RESULT.Failure])
    retItemList[RESULT.Tie] = packItem(itemIDArr[RESULT.Tie], itemNumArr[RESULT.Tie], itemExpireArr[RESULT.Tie])
  end
  return retItemList
end
local solveItem = function(cfgItem, keyTbl)
  local itemTemp = splitItemBycomma(cfgItem, keyTbl)
  local item = arrangeItem(itemTemp, keyTbl)
  return item
end
function logic_corps_fight.InitCorpsRaceTable()
  local TimeUtil = require("client.common.time_util")
  if corpsRaceActConfig ~= nil then
    return
  end
  local cfg = CDataTable.GetTable("corps_race_act_config")
  if cfg == nil then
    return
  end
  local keyTbl = {
    "act_id",
    "limit_number",
    "limit_person_score"
  }
  local timeTbl = {
    "act_start_time",
    "enroll_end_time",
    "task_start_time",
    "task_end_time",
    "act_end_time"
  }
  local itemKeyTbl1, itemKeyTbl2, itemKeyTbl3, first_itemkeyTbl
  if logic_corps_fight.CheckJK() then
    itemKeyTbl1 = {
      "jk_res_id1",
      "jk_res_num1",
      "jk_valid_hours1"
    }
    itemKeyTbl2 = {
      "jk_res_id2",
      "jk_res_num2",
      "jk_valid_hours2"
    }
    itemKeyTbl3 = {
      "jk_res_id3",
      "jk_res_num3",
      "jk_valid_hours3"
    }
    first_itemkeyTbl = {
      "fist_jk_res_id",
      "fist_jk_res_num",
      "fist_jk_valid_hours"
    }
  else
    itemKeyTbl1 = {
      "res_id1",
      "res_num1",
      "valid_hours1"
    }
    itemKeyTbl2 = {
      "res_id2",
      "res_num2",
      "valid_hours2"
    }
    itemKeyTbl3 = {
      "res_id3",
      "res_num3",
      "valid_hours3"
    }
    first_itemkeyTbl = {
      "first_res_id",
      "first_res_num",
      "first_valid_hours"
    }
  end
  local readTbl = {}
  for _, v in pairs(cfg) do
    local tmp = {}
    for i, k in pairs(keyTbl) do
      tmp[k] = v[k]
    end
    for i, k in pairs(timeTbl) do
      tmp[k] = TimeUtil.TimeStringToUnixstamp(v[k])
    end
    tmp.reward1 = solveItem(v, itemKeyTbl1)
    tmp.reward2 = solveItem(v, itemKeyTbl2)
    tmp.reward3 = solveItem(v, itemKeyTbl3)
    tmp.first_reward = solveItem(v, first_itemkeyTbl)
    readTbl[#readTbl + 1] = tmp
  end
  corpsRaceActConfig = readTbl
end
function logic_corps_fight.GetCurRaceTimecfg()
  if cache_data.curTimeCfg then
    return cache_data.curTimeCfg
  end
  local curTimeCfg
  local now = GetServerTimeInUTC()
  if corpsRaceActConfig then
    for i = #corpsRaceActConfig, 1, -1 do
      local v = corpsRaceActConfig[i]
      local startTime = v.act_start_time
      local endTime = v.act_end_time
      if now >= startTime and now <= endTime then
        curTimeCfg = v
        break
      end
    end
    if curTimeCfg == nil then
      log_warning("[v_ywuyuan corp_fight]  not find the current time cfg  so just use the first cfg")
      curTimeCfg = corpsRaceActConfig[1]
    end
  end
  cache_data.  return curTimeCfg
end
function logic_corps_fight.GetNextCurRaceTimeCfg()
  local curTimeCfg = logic_corps_fight.GetCurRaceTimecfg()
  if curTimeCfg then
    return corpsRaceActConfig[curTimeCfg.act_id + 1]
  end
  return nil
end
function logic_corps_fight.CheckFightIsRunning()
  local _phase = logic_corps_fight.GetPhase()
  return PHASE.Free3 ~= _phase
end
function logic_corps_fight.CheckFightInRegister()
  local _phase = logic_corps_fight.GetPhase()
  return PHASE.Register == _phase
end
function logic_corps_fight.CheckFightInMatch()
  local _phase = logic_corps_fight.GetPhase()
  return PHASE.Free1 == _phase
end
function logic_corps_fight.CheckFightInFighting()
  local _phase = logic_corps_fight.GetPhase()
  log(bWriteLog and string.format("logic_corps_fight.CheckFightInFighting, _phase:%s", _phase))
  return PHASE.Fight == _phase
end
function logic_corps_fight.CheckFightInResult()
  local _phase = logic_corps_fight.GetPhase()
  return PHASE.Free2 == _phase
end
function logic_corps_fight.GetPhase()
  if cache_data.curPhase == nil then
    local curRaceTimecfg = logic_corps_fight.GetCurRaceTimecfg()
    local now = GetServerTimeInUTC()
    local curPhase
    if curRaceTimecfg then
      if now >= curRaceTimecfg.act_start_time and now <= curRaceTimecfg.enroll_end_time then
        curPhase = PHASE.Register
      elseif now > curRaceTimecfg.enroll_end_time and now < curRaceTimecfg.task_start_time then
        curPhase = PHASE.Free1
      elseif now >= curRaceTimecfg.task_start_time and now <= curRaceTimecfg.task_end_time then
        curPhase = PHASE.Fight
      elseif now > curRaceTimecfg.task_end_time and now <= curRaceTimecfg.act_end_time then
        curPhase = PHASE.Free2
      end
    end
    if curPhase == nil then
      curPhase = PHASE.Free3
    end
    cache_data.  end
  return cache_data.curPhase
end
function logic_corps_fight.GetUltimateReward(resultType)
  local curRaceTimecfg = logic_corps_fight.GetCurRaceTimecfg()
  if curRaceTimecfg then
    return {
      curRaceTimecfg.reward1[resultType],
      curRaceTimecfg.reward2[resultType],
      curRaceTimecfg.reward3[resultType]
    }
  end
  return {}
end
function logic_corps_fight.GetFirstReward()
  local curRaceTimecfg = logic_corps_fight.GetCurRaceTimecfg()
  if curRaceTimecfg then
    return curRaceTimecfg.first_reward
  end
  return {}
end
function logic_corps_fight.InitCorpsRaceTaskTable()
  if corpsRaceTaskConfig ~= nil then
    return
  end
  local cfg = CDataTable.GetTable("corps_race_act_tasks_config")
  if cfg == nil then
    return
  end
  local keyTbl = {
    "task_id",
    "daily_limit",
    "cond_desc",
    "task_name",
    "match_id_list",
    "cond_desc1",
    "cond_para1",
    "score1",
    "cond_desc2",
    "cond_para2",
    "score2",
    "cond_desc3",
    "cond_para3",
    "score3"
  }
  local readTbl = {}
  for _, v in pairs(cfg) do
    local tmp = {}
    for i, k in pairs(keyTbl) do
      if k == "match_id_list" then
        local StringUtil = require("common.string_util")
        tmp[k] = StringUtil.Split(v[k], ";")
      else
        tmp[k] = v[k]
      end
    end
    readTbl[v.task_id] = tmp
  end
  corpsRaceTaskConfig = readTbl
end
function logic_corps_fight.GetTaskCfgByTaskID(task_id)
  if type(corpsRaceTaskConfig) == "table" then
    return corpsRaceTaskConfig[task_id]
  end
end
function logic_corps_fight.InitCorpsRaceDailyTaskTable()
  if corpsRaceDailyTaskConfig ~= nil then
    return
  end
  local cfg = CDataTable.GetTable("corps_race_act_daily_task_table")
  if cfg == nil then
    return
  end
  local keyTbl = {
    "energy_type"
  }
  local _totalDay = logic_corps_fight.GetTotalDay()
  for i = 1, _totalDay do
    keyTbl[#keyTbl + 1] = string.format("task_id%d", i)
  end
  local readTbl = {}
  for _, v in pairs(cfg) do
    local tmp = {}
    for i, k in pairs(keyTbl) do
      tmp[k] = v[k]
    end
    readTbl[v.energy_type] = tmp
  end
  corpsRaceDailyTaskConfig = readTbl
end
function logic_corps_fight.GetDailyTaskCfgByTaskIDAndDayIdx(energyType, dayIndex)
  if corpsRaceDailyTaskConfig then
    local cfg = corpsRaceDailyTaskConfig[energyType]
    if cfg then
      return cfg[string.format("task_id%d", dayIndex)]
    end
    log(bWriteLog and "[v_ywuyuan corp_fight] GetDailyTaskCfgByTaskIDAndDayIdx not find ")
    return corpsRaceDailyTaskConfig[1].task_id1
  end
  return nil
end
function logic_corps_fight.GetTotalDay()
  return totalDay
end
function logic_corps_fight.InitCorpsRaceRewardTable()
  if corpsRaceRewardConfig ~= nil then
    return
  end
  local cfg = CDataTable.GetTable("corps_race_act_result_reward_config")
  if cfg == nil then
    return
  end
  local keyTbl = {
    "id",
    "act_id",
    "day_index",
    "supplie_number"
  }
  local itemKeyTbl1, itemKeyTbl2
  if logic_corps_fight.CheckJK() then
    itemKeyTbl1 = {
      "jk_res_id1",
      "jk_res_num1",
      "jk_valid_hours1"
    }
    itemKeyTbl2 = {
      "jk_res_id2",
      "jk_res_num2",
      "jk_valid_hours2"
    }
  else
    itemKeyTbl1 = {
      "res_id1",
      "res_num1",
      "valid_hours1"
    }
    itemKeyTbl2 = {
      "res_id2",
      "res_num2",
      "valid_hours2"
    }
  end
  local timecfg = logic_corps_fight.GetCurRaceTimecfg()
  local readTbl = {}
  if timecfg then
    local targetId = timecfg.act_id
    for _, v in pairs(cfg) do
      if v.act_id == targetId then
        local tmp = {}
        for i, k in ipairs(keyTbl) do
          tmp[k] = v[k]
        end
        tmp.reward1 = solveItem(v, itemKeyTbl1)
        tmp.reward2 = solveItem(v, itemKeyTbl2)
        if tmp.supplie_number then
          local StringUtil = require("common.string_util")
          tmp.supplie_number = StringUtil.SplitToNum(tmp.supplie_number, ";")
        end
        readTbl[tmp.day_index] = tmp
      end
    end
  end
  corpsRaceRewardConfig = readTbl
end
function logic_corps_fight.GetRewardCfgByTaskIDAndResultType(dayIndex, resultType)
  if corpsRaceRewardConfig then
    local cfg = corpsRaceRewardConfig[dayIndex]
    if cfg then
      return {
        cfg.reward1[resultType],
        cfg.reward2[resultType]
      }
    end
  end
  return nil
end
function logic_corps_fight.GetRewardCfg()
  return corpsRaceRewardConfig
end
function logic_corps_fight.InitCorpsRacePersonRewardTable()
  if corpsRacePersonRewardConfig ~= nil then
    return
  end
  local cfg = CDataTable.GetTable("corps_race_act_personal_reward_cfg")
  if cfg == nil then
    return
  end
  local keyTbl = {
    "id",
    "act_id",
    "index",
    "min_score"
  }
  local res_id1, res_num1, valid_hours1
  if logic_corps_fight.CheckJK() then
    res_id1 = "jk_res_id1"
    res_num1 = "jk_res_num1"
    valid_hours1 = "jk_valid_hours1"
  else
    res_id1 = "res_id1"
    res_num1 = "res_num1"
    valid_hours1 = "valid_hours1"
  end
  local timecfg = logic_corps_fight.GetCurRaceTimecfg()
  local readTbl = {}
  if timecfg then
    local targetId = timecfg.act_id
    for _, v in pairs(cfg) do
      if v.act_id == targetId then
        local tmp = {}
        for i, k in pairs(keyTbl) do
          tmp[k] = v[k]
        end
        tmp.res_id1 = v[res_id1]
        tmp.res_num1 = v[res_num1]
        tmp.valid_hours1 = v[valid_hours1]
        readTbl[#readTbl + 1] = tmp
      end
    end
  end
  corpsRacePersonRewardConfig = readTbl
end
function logic_corps_fight.GetPersonRewardConfig()
  return corpsRacePersonRewardConfig
end
function logic_corps_fight.InitCorpsRaceImageConfig()
  if corpsRaceImageConfig ~= nil then
    return
  end
  local cfg = CDataTable.GetTable("corps_race_image_cfg")
  if cfg == nil then
    return
  end
  local index = "index"
  local pic_url
  if logic_corps_fight.CheckJK() then
    pic_url = "jp_pic_url"
  elseif logic_corps_fight.CheckIndia() then
    pic_url = "india_pic_url"
  else
    pic_url = "pic_url"
  end
  local readTbl = {}
  for _, v in ipairs(cfg) do
    local tmp = {}
    tmp[index] = v[index]
    tmp.pic_url = v[pic_url]
    readTbl[#readTbl + 1] = tmp
  end
  corpsRaceImageConfig = readTbl
end
function logic_corps_fight.GetCorpsRaceImageConfig()
  return corpsRaceImageConfig
end
function logic_corps_fight.InitCorpsRaceOccupyImageConfig()
  if corpsRaceOccupyImageConfig ~= nil then
    return
  end
  local cfg = CDataTable.GetTable("corps_race_occupy_image_cfg")
  if cfg == nil then
    return
  end
  local keyTbl = {"index", "img_path"}
  local readTbl = {}
  for _, v in ipairs(cfg) do
    local tmp = {}
    for i, k in ipairs(keyTbl) do
      tmp[k] = v[k]
    end
    readTbl[#readTbl + 1] = tmp
  end
  corpsRaceOccupyImageConfig = readTbl
end
function logic_corps_fight.GetCorpsRaceOccupyImageConfigByIndex(index)
  return corpsRaceOccupyImageConfig[index]
end
function logic_corps_fight.InitCorpsRaceRewardPreviewConfig()
  if corpsRaceRewardPreviewConfig ~= nil then
    return
  end
  local cfg = CDataTable.GetTable("corps_race_reward_preview_cfg")
  if cfg == nil then
    return
  end
  local timecfg = logic_corps_fight.GetCurRaceTimecfg()
  if not timecfg then
    log(bWriteLog and "[DeanJYT] logic_corps_fight.InitCorpsRaceRewardPreviewConfig timecfg is nil")
    return
  end
  local readTbl = {}
  for _, v in pairs(cfg) do
    if v.act_id == timecfg.act_id then
      if logic_corps_fight.CheckJK() then
        readTbl.res_id1 = v.jk_res_id1
        readTbl.res_id2 = v.jk_res_id2
      else
        readTbl.res_id1 = v.res_id1
        readTbl.res_id2 = v.res_id2
      end
      readTbl.text_id1 = v.text_id1
      readTbl.text_id2 = v.text_id2
      break
    end
  end
  corpsRaceRewardPreviewConfig = readTbl
end
function logic_corps_fight.GetCorpsRaceOccupyRewardPreviewConfig()
  return corpsRaceRewardPreviewConfig
end
function logic_corps_fight.InitAllCfgTable()
  log(bWriteLog and "[v_ywuyuan] logic_corps_fight.InitAllCfgTable")
  logic_corps_fight.InitCorpsRaceTable()
end
function logic_corps_fight.InitCfgTable()
  logic_corps_fight.InitCorpsRaceTaskTable()
  logic_corps_fight.InitCorpsRacePersonRewardTable()
  logic_corps_fight.InitCorpsRaceDailyTaskTable()
end
function logic_corps_fight.DelayInitCfgTable()
  log(bWriteLog and "[v_ywuyuan] logic_corps_fight.DelayInitCfgTable")
  logic_corps_fight.InitCorpsRaceRewardTable()
  logic_corps_fight.InitCorpsRaceImageConfig()
  logic_corps_fight.InitCorpsRaceOccupyImageConfig()
  logic_corps_fight.InitCorpsRaceRewardPreviewConfig()
end
local bNextNeedRefresh = false
function logic_corps_fight.OnNextDayDoRefresh()
  logic_corps_fight.UpdateRedDotPoint()
  logic_corps_fight.ReqNecessaryInfoForFight()
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_REFRESH_UI)
end
function logic_corps_fight.OnNextDay()
  logic_corps_fight.ResetCacheData()
  if logic_corps_fight.CheckActNotOpen() then
    return
  end
  if GameStatus.IsInLobbyOrMainCity() then
    bNextNeedRefresh = false
  else
    bNextNeedRefresh = true
  end
end
function logic_corps_fight.OnModePostSwitch(preState, nextState)
  local curStatus = GameStatus.GetGameStatus()
  local lastStatus = GameStatus.GetLastGameStatus()
  if curStatus == GameStatus.Lobby and lastStatus == GameStatus.Login then
    log(bWriteLog and "[v_ywuyuan] logic_corps_fight.OnModePostSwitch!!!!!!!")
    logic_corps_fight.ShowTipFlag = true
  elseif lastStatus == GameStatus.Fighting and curStatus == GameStatus.Lobby and bNextNeedRefresh then
    logic_corps_fight.OnNextDayDoRefresh()
    bNextNeedRefresh = false
  end
end
function logic_corps_fight.OnLogin()
  logic_corps_fight.InitAllCfgTable()
  logic_corps_fight.ShowTipFlag = true
  EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, logic_corps_fight.OnLogout)
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_END, logic_corps_fight.ShowScoreTip)
  EventSystem:registEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, logic_corps_fight.OnNextDay)
end
function logic_corps_fight.ResetData()
  log(bWriteLog and "[v_ywuyuan] logic_corps_fight.ResetData")
  corpsRaceTaskConfig = nil
  corpsRaceDailyTaskConfig = nil
  corpsRaceRewardConfig = nil
  corpsRacePersonRewardConfig = nil
  corpsRaceImageConfig = nil
  corpsRaceOccupyImageConfig = nil
  corpsRaceActConfig = nil
  corpsRaceRewardPreviewConfig = nil
  taskTipMsgCache = nil
end
function logic_corps_fight.ResetCacheData()
  cache_data = {
    raceData = {},
    occupySupplyScore = {},
    colorPos = {}
  }
end
function logic_corps_fight.OnLogout()
  logic_corps_fight.ResetData()
  EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, logic_corps_fight.OnLogout)
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_END, logic_corps_fight.ShowScoreTip)
  EventSystem:unregistEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, logic_corps_fight.OnNextDay)
end
function logic_corps_fight.ReqNecessaryInfoForFight()
  if logic_corps_fight.CheckActNotOpen() then
    return
  end
  logic_corps_fight.ResetCacheData()
  if DataMgr.corpsInfo.id ~= 0 and logic_corps_fight.CheckFightIsRunning() then
    logic_corps_fight.send_corps_race_act_info_req()
  end
end
function logic_corps_fight.ForceSendCorpInfoReq()
  reqTime = 0
  logic_corps_fight.send_corps_race_act_info_req()
end
function logic_corps_fight.SetCorpfightInfo(_corpfightInfo)
  corpfightInfo = _corpfightInfo
end
function logic_corps_fight.GetCorpfightInfo()
  return corpfightInfo
end
function logic_corps_fight.SetEnemyCorpsInfo(_enemyCorpsInfo)
  enemyCorpsInfo = _enemyCorpsInfo
end
function logic_corps_fight.GetEnemyCorpInfo()
  return enemyCorpsInfo
end
function logic_corps_fight.SetCorpMemberScoreList(_corpMemberScoreList)
  corpMemberScoreList = _corpMemberScoreList
end
function logic_corps_fight.GetCorpMemberScoreList()
  return corpMemberScoreList
end
function logic_corps_fight.send_corps_race_act_info_req()
  if DEBUG_TIME then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSecWithFraction()
  if math.abs(currentTime - reqTime) < 1 then
    log(bWriteLog and "[v_ywuyuan]" .. "frequency of req is limited!!!")
    return
  end
  reqTime = currentTime
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  log(bWriteLog and "[v_ywuyuan] send_corps_race_act_info_req")
  CorpsHandler.send_corps_race_act_info_req()
end
local defaultHandle = function(extInfo)
  extInfo.daily_award_status = extInfo.daily_award_status or {}
  extInfo.score_award_status = extInfo.score_award_status or {}
  extInfo.final_award_status = extInfo.final_award_status or false
  extInfo.battle_switch = extInfo.battle_switch or false
  extInfo.task_status = extInfo.task_status or {}
  local task_status = {}
  for i = 1, 4 do
    task_status[#task_status + 1] = extInfo.task_status[i]
  end
  extInfo.  return extInfo
end
local constructEnemyInfo = function(del_smpl_data)
  local TimeUtil = require("client.common.time_util")
  del_smpl_data.top3_members = {}
  local now = GetServerTimeInUTC()
  if TimeUtil.IsSameDay(now, del_smpl_data.delete_tm) then
    del_smpl_data.race_total_score = del_smpl_data.total_score
  else
    del_smpl_data.race_total_score = 0
  end
  del_smpl_data.race_total_score = del_smpl_data.race_total_score or 0
  del_smpl_data.day_scores = logic_corps_fight.SolveWinAndLoseBit(corpfightInfo.win_bits, corpfightInfo.lose_bits)
  logic_corps_fight.SetEnemyCorpsInfo(del_smpl_data)
end
local constructDefaultEnemyInfo = function()
  local enemyInfo = {}
  enemyInfo.name = LocUtil.GetLocalizeResStr(23780)
  enemyInfo.level = 1
  enemyInfo.icon = 2001001
  enemyInfo.city = "G1"
  enemyInfo.icon_text = "NAME"
  enemyInfo.member_num = 0
  enemyInfo.top3_members = {}
  enemyInfo.race_total_score = 0
  enemyInfo.day_scores = logic_corps_fight.SolveWinAndLoseBit(corpfightInfo.win_bits, corpfightInfo.lose_bits)
  logic_corps_fight.SetEnemyCorpsInfo(enemyInfo)
end
function logic_corps_fight.on_corps_race_act_info_res(res, info, ext_info)
  logic_corps_fight.ResetCacheData()
  corpfightInfo = nil
  log(bWriteLog and string.format("logic_corps_fight.on_corps_race_act_info_res, res:%s", res))
  log_tree(bWriteLog and "logic_corps_fight.on_corps_race_act_info_res info", info)
  log_tree(bWriteLog and "logic_corps_fight.on_corps_race_act_info_res ext_info", ext_info)
  if res ~= 0 then
    logic_corps_fight.ShowErrorTips(res)
  else
    info.ext_info = defaultHandle(ext_info)
    logic_corps_fight.SetCorpfightInfo(info)
    if (logic_corps_fight.CheckFightInFighting() or logic_corps_fight.CheckFightInResult()) and logic_corps_fight.CheckRegisterSuccess() and logic_corps_fight.CheckFightMatched() == false then
      constructDefaultEnemyInfo()
    elseif (logic_corps_fight.CheckFightInFighting() or logic_corps_fight.CheckFightInResult()) and logic_corps_fight.CheckRegisterSuccess() == false then
    elseif info.del_smpl_data then
      constructEnemyInfo(info.del_smpl_data)
    elseif UIManager.IsUIShow(UIManager.UI_Config.CorpsHomepageNewUI2) or logic_corps_fight.req_enemy_summary then
      logic_corps_fight.req_enemy_summary = false
      logic_corps_fight.send_enemy_corp_summay_req()
    end
    logic_corps_fight.UpdateRedDotPoint()
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_REFRESH_UI)
  end
end
function logic_corps_fight.send_corps_race_act_enroll_req()
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_corps_race_act_enroll_req()
end
function logic_corps_fight.on_corps_race_act_enroll_res(res)
  logic_corps_fight.ResetCacheData()
  if res ~= 0 then
    logic_corps_fight.ShowErrorTips(res)
  else
    local _corpfightInfo = logic_corps_fight.GetCorpfightInfo()
    _corpfightInfo.is_enrolled = true
    local logic_corps_fight_new = GetModuleForBlackList(ModuleManager.CommonModuleConfig.logic_corps_fight_new)
    if logic_corps_fight_new then
      logic_corps_fight_new:SetSignPk(true)
    else
      log(bWriteLog and "logic_corps_fight.on_corps_race_act_enroll_res, logic_corps_fight_new is nil")
    end
    logic_corps_fight.SetCorpfightInfo(_corpfightInfo)
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_REGISTER_REFRESH_UI, 1)
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_REFRESH_LOBBYTIPS)
    logic_corps_fight.UpdateRedDotPoint()
  end
end
function logic_corps_fight.send_corps_race_act_member_score_req()
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_corps_race_act_member_score_req()
end
function logic_corps_fight.on_corps_race_act_member_score_res(res, score_list)
  if res ~= 0 then
    logic_corps_fight.ShowErrorTips(res)
  else
    logic_corps_fight.SetCorpMemberScoreList(score_list)
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_RANK_REFRESH_UI, 1)
  end
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_REDPACKET_CORP_LIST_RSP, score_list)
end
function logic_corps_fight.send_corps_race_act_reward_req(reward_type, index)
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_corps_race_act_reward_req(reward_type, index)
end
function logic_corps_fight.on_corps_race_act_reward_res(res, reward_type, index, item_list)
  logic_corps_fight.ResetCacheData()
  if res ~= 0 then
    logic_corps_fight.ShowErrorTips(res)
  else
    if reward_type == 3 then
      corpfightInfo.ext_info.daily_award_status[index] = true
      EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_OVERVIEW_REFRESH_UI, 1)
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      local tExtendData = {
        fCloseCallback = logic_corps_fight.CheckShowNextUI
      }
      Logic_CommonItemGet.ShowPanel_DefaultStyle(item_list, false, true, tExtendData)
    elseif reward_type == 2 then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(item_list)
      if index == 0 then
        logic_corps_fight.UpdateAllRewardData()
      elseif index == nil then
        corpfightInfo.ext_info.final_award_status = true
      end
      EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_RESULT_REFRESH_UI, 2)
    elseif reward_type == 1 then
      corpfightInfo.ext_info.score_award_status[index] = true
      EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_MAIN_REFRESH_UI, 1)
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(item_list)
    end
    logic_corps_fight.UpdateRedDotPoint()
  end
end
function logic_corps_fight.send_enemy_corp_summay_req()
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  local _corpFightInfo = logic_corps_fight.GetCorpfightInfo()
  if _corpFightInfo.race_corpsid ~= 0 then
    CorpsMgr.get_corps_summary_req(_corpFightInfo.race_corpsid, DataMgr.roleData.uid, logic_corps_fight.send_enemy_corp_summay_rsp)
  end
end
function logic_corps_fight.send_enemy_corp_summay_rsp(summary)
  log_tree("summary", summary)
  logic_corps_fight.ResetCacheData()
  logic_corps_fight.SetEnemyCorpsInfo(summary)
  logic_corps_fight.UpdateRedDotPoint()
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_REFRESH_UI)
end
function logic_corps_fight.send_corps_race_act_set_switch_req(isOpen)
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_corps_race_act_set_switch_req(isOpen)
end
function logic_corps_fight.on_corps_race_act_set_switch_res(res, nextState, limit_lv)
  logic_corps_fight.ResetCacheData()
  if res ~= 0 then
    if res == 100150013 then
      local HDmpveChannelID = Client.GetLoginChannel(NetInterface)
      local SettingAccount = require("client.logic.setting.logic_setting_account")
      local ChannelName = SettingAccount.GetNameByHDmpveChannel(HDmpveChannelID)
      local NoticeMessage = LocUtil.LocalizeResFormat(14253, ChannelName, limit_lv)
      ShowNotice(NoticeMessage)
    else
      logic_corps_fight.ShowErrorTips(res)
    end
  else
    corpfightInfo.ext_info.battle_switch = nextState
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_TODAY_REFRESH_UI, 1)
  end
end
function logic_corps_fight.on_corps_race_daily_occupy_notify(win_bits, lose_bits, day_scores, dst_day_scores)
  log(bWriteLog and "v_ywuyuan on_corps_race_daily_occupy_notify")
end
function logic_corps_fight.on_corps_race_act_battle_notify(score)
  log(bWriteLog and "v_ywuyuan on_corps_race_act_battle_notify")
  if GameStatus.IsInLobbyOrMainCity() then
    logic_corps_fight.ShowTipUI(LocUtil.LocalizeResFormat(23764, score))
  else
    show  end
  if corpfightInfo and corpfightInfo.my_score then
    corpfightInfo.my_score = corpfightInfo.my_score + score
    logic_corps_fight.UpdateRedDotPoint()
  end
end
local bSendFlag = false
function logic_corps_fight.GetDisBandRaceSummary(race_id)
  local _corpFightInfo = logic_corps_fight.GetCorpfightInfo()
  if _corpFightInfo and _corpFightInfo.race_corpsid and _corpFightInfo.race_corpsid == race_id then
    if bSendFlag == false then
      bSendFlag = true
      logic_corps_fight.ForceSendCorpInfoReq()
    else
      constructDefaultEnemyInfo()
      logic_corps_fight.UpdateRedDotPoint()
      EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_REFRESH_UI)
    end
  end
end
function logic_corps_fight.ShowTabUI()
  local ui = logic_corps_fight.DoShowTabUI()
  logic_corps_fight.HideCorpModel()
  logic_corps_fight.CreateTimer()
  logic_corps_fight.CheckShowNextUI()
  EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_REFRESH_UI, logic_corps_fight.RefreshAllUI)
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyUI(false)
  return ui
end
function logic_corps_fight.DoShowTabUI()
  logic_corps_fight.DoCloseTabUI()
  local ui
  if logic_corps_fight.CheckFightInFighting() then
    if logic_corps_fight.CheckRegisterSuccess() then
      ui = UIManager.ShowUI(UIManager.UI_Config.corps_fight_main)
    else
      ui = UIManager.ShowUI(UIManager.UI_Config.corps_fight_register)
    end
  elseif logic_corps_fight.CheckFightInResult() then
    if logic_corps_fight.CheckRegisterSuccess() then
      ui = UIManager.ShowUI(UIManager.UI_Config.corps_fight_result)
    else
      ui = UIManager.ShowUI(UIManager.UI_Config.corps_fight_register)
    end
  elseif logic_corps_fight.CheckFightInRegister() then
    ui = UIManager.ShowUI(UIManager.UI_Config.corps_fight_register)
  else
    if logic_corps_fight.CheckFightInMatch() then
      ui = UIManager.ShowUI(UIManager.UI_Config.corps_fight_register)
    else
    end
  end
  return ui
end
function logic_corps_fight.CloseTabUI()
  logic_corps_fight.DestroyTimer()
  logic_corps_fight.DoCloseTabUI()
  EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_REFRESH_UI, logic_corps_fight.RefreshAllUI)
end
function logic_corps_fight.DoCloseTabUI()
  UIManager.CloseUI(UIManager.UI_Config.corps_fight_register)
  UIManager.CloseUI(UIManager.UI_Config.corps_fight_main)
  UIManager.CloseUI(UIManager.UI_Config.corps_fight_result)
  UIManager.CloseUI(UIManager.UI_Config.corps_fight_rank_reward)
end
function logic_corps_fight.ShowRankUI()
  UIManager.ShowUI(UIManager.UI_Config.corps_fight_member_rank)
end
function logic_corps_fight.ShowRewardUI()
  UIManager.ShowUI(UIManager.UI_Config.corps_fight_reward)
end
function logic_corps_fight.ShowHelpUI()
  local timecfg = logic_corps_fight.GetCurRaceTimecfg()
  local title = LocUtil.GetLocalizeResStr(23761)
  local s1 = LocUtil.LocalizeResFormat(23762, timecfg.limit_number)
  local s2 = LocUtil.LocalizeResFormat(23782)
  local s3 = LocUtil.LocalizeResFormat(23783)
  local s4 = LocUtil.LocalizeResFormat(23784)
  local s5 = LocUtil.LocalizeResFormat(23785, corpsDayTaskTimes)
  local s6 = LocUtil.LocalizeResFormat(23786, timecfg.limit_person_score or 0)
  local content = string.format("%s%s%s%s%s%s", s1, s2, s3, s4, s5, s6)
  UIManager.ShowUI(UIManager.UI_Config.HelpTip, 0, title, content)
end
function logic_corps_fight.ShowShareUI()
  local Util = require("client.slua_ui_framework.util")
  local acceptor = "game://?module=" .. BP_ENUM_MODULE_CORPS .. "&id=10"
  local cfg = {
    shareTitle = "share title",
    shareContent = LocUtil.GetLocalizeResStr("4366"),
    share_type = ShareBtnTLogShareTypeDefine.LegionConfrontationSharing,
    sceneType = ShareSceneType.CorpFight,
    campaign = "corp_fight",
    moduleParams = acceptor
  }
  Util.ShowShare(cfg, UIManager.UI_Config.corps_fight_share)
end
function logic_corps_fight.ShowTodayResultUI()
  local nextState = logic_corps_fight.GetLastDayStatus()
  UIManager.ShowUI(UIManager.UI_Config.corps_fight_result_today, nextState)
end
function logic_corps_fight.ShowStartUI()
  UIManager.ShowUI(UIManager.UI_Config.corps_fight_start)
end
function logic_corps_fight.ShowSwitchTip()
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local bSwitch = logic_corps_fight.GetBattleSwitch()
  local title = LocUtil.LocalizeResFormat(101001)
  local msg
  if bSwitch then
    msg = LocUtil.LocalizeResFormat(23731)
  else
    msg = LocUtil.LocalizeResFormat(23732)
  end
  CommonMsgBoxMgr.Show(1, title, msg)
end
function logic_corps_fight.ShowUltimateResultUI()
  UIManager.ShowUI(UIManager.UI_Config.corps_fight_rank_reward)
end
function logic_corps_fight.ShowTipUI(msg)
  log(bWriteLog and "logic_corps_fight ShowTipUI msg = " .. tostring(msg))
  if not taskTipMsgCache then
    taskTipMsgCache = {}
  end
  table.insert(taskTipMsgCache, msg)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_POST_SWITCH_SHOW_CORPS_FIGHT_TASK_TIP)
end
function logic_corps_fight.ShowNextTaskTip()
  log(bWriteLog and "logic_corps_fight ShowNextTaskTip")
  if not taskTipMsgCache or #taskTipMsgCache == 0 then
    return
  end
  local msg = table.remove(taskTipMsgCache, 1)
  logic_corps_fight.ShowTaskTipUI(msg)
end
function logic_corps_fight.ShowTaskTipUI(msg)
  log(bWriteLog and "logic_corps_fight ShowTaskTipUI msg = " .. tostring(msg))
  UIManager.ShowUI(UIManager.UI_Config.corps_fight_tip, msg)
end
function logic_corps_fight.ShowRightTipUI()
  local bopen = logic_corps_fight.CheckCanBattle()
  local msg
  if bopen then
    msg = LocUtil.LocalizeResFormat(23792)
  else
    msg = LocUtil.LocalizeResFormat(23795)
  end
  UIManager.ShowUI(UIManager.UI_Config.corps_fight_right_tip, msg)
end
function logic_corps_fight.RefreshAllUI()
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_MAIN_REFRESH_UI, 1)
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_OVERVIEW_REFRESH_UI, 1)
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_TODAY_REFRESH_UI, 2)
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_REGISTER_REFRESH_UI, 1)
end
local corp_fight_timer, lastPhase
function logic_corps_fight.CreateTimer()
  lastPhase = logic_corps_fight.GetPhase()
  if corp_fight_timer == nil then
    local time_ticker = require("common.time_ticker")
    corp_fight_timer = time_ticker.AddTimerLoop(1, function()
      local curPhase = logic_corps_fight.GetPhase()
      if curPhase ~= lastPhase then
        logic_corps_fight.DoShowTabUI()
        lastPhase = curPhase
      end
    end, TIMER_INFINITE, 1)
  end
end
function logic_corps_fight.DestroyTimer()
  local time_ticker = require("common.time_ticker")
  if corp_fight_timer then
    time_ticker.RemoveTimer(corp_fight_timer)
    corp_fight_timer = nil
  end
end
function logic_corps_fight.CheckRegisterSuccess()
  if not corpfightInfo then
    return false
  end
  local timecfg = logic_corps_fight.GetCurRaceTimecfg()
  local curActID = timecfg and timecfg.act_id
  if not curActID then
    log(bWriteLog and "logic_corps_fight.CheckRegisterSuccess return of not curActID")
    return false
  end
  if curActID ~= corpfightInfo.act_id then
    log(bWriteLog and string.format("logic_corps_fight.CheckRegisterSuccess, curActID ~= corpfightInfo.act_id %s ~= %s", curActID, corpfightInfo.act_id))
    return false
  end
  if not corpfightInfo.is_enrolled then
    log(bWriteLog and "logic_corps_fight.CheckRegisterSuccess return of not is_enrolled")
    return false
  end
  return true
end
function logic_corps_fight.CheckFightMatched()
  if corpfightInfo and corpfightInfo.race_corpsid then
    return corpfightInfo.race_corpsid ~= 0
  end
  return false
end
function logic_corps_fight.GetMyScore()
  return corpfightInfo.my_score or 0
end
function logic_corps_fight.GetOccupySupplyScore(owner)
  if cache_data.occupySupplyScore[owner] == nil then
    local nextState = logic_corps_fight.GetOccupyRaceData(owner)
    local supply_score = 0
    for i, v in ipairs(nextState) do
      if corpsRaceRewardConfig and corpsRaceRewardConfig[i] and corpsRaceRewardConfig[i].supplie_number and corpsRaceRewardConfig[i].supplie_number[v] then
        supply_score = supply_score + corpsRaceRewardConfig[i].supplie_number[v]
      end
    end
    cache_data.occupySupplyScore[owner] = supply_score
  end
  return cache_data.occupySupplyScore[owner]
end
function logic_corps_fight.GetOccupyRaceData(owner)
  if cache_data.raceData[owner] == nil then
    local lastDay = logic_corps_fight.GetLastDayInFight()
    local fightInfo = logic_corps_fight.GetCorpfightInfo()
    local enemyInfo = logic_corps_fight.GetEnemyCorpInfo()
    local curStatus = {}
    if fightInfo ~= nil and enemyInfo ~= nil and lastDay ~= nil then
      for i = 1, lastDay do
        curStatus[i] = logic_corps_fight.GetResultStatusByDayIndex(i, owner)
      end
    end
    cache_data.raceData[owner] = curStatus
  end
  return cache_data.raceData[owner]
end
function logic_corps_fight.GetOccupyRewardStatus()
  if cache_data.rewardStatus == nil then
    local fightInfo = logic_corps_fight.GetCorpfightInfo()
    local res = {}
    if fightInfo and fightInfo.ext_info and fightInfo.ext_info.daily_award_status then
      for k, v in pairs(fightInfo.ext_info.daily_award_status) do
        res[k] = true
      end
    end
    cache_data.rewardStatus = res
  end
  return cache_data.rewardStatus
end
function logic_corps_fight.GetTop3Member(owner)
  local top3_member
  if owner == logic_corps_fight.We then
    local fightInfo = logic_corps_fight.GetCorpfightInfo()
    top3_member = fightInfo.top3_members
  elseif owner == logic_corps_fight.Enemy then
    local enemyInfo = logic_corps_fight.GetEnemyCorpInfo()
    if enemyInfo then
      top3_member = enemyInfo.get_top3_race_members
    end
  end
  return top3_member or {}
end
function logic_corps_fight.CheckHasGetPersonReward(reward_id)
  if corpfightInfo and corpfightInfo.ext_info and corpfightInfo.ext_info.score_award_status then
    for k, v in pairs(corpfightInfo.ext_info.score_award_status) do
      if k == reward_id and v == true then
        return true
      end
    end
  end
  return false
end
function logic_corps_fight.RequestEnemyCorpInfo()
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  CorpsMgr.get_corps_summary_req(corpfightInfo.race_corpsid, DataMgr.roleData.uid, function(corps_summary)
    log_tree("corsp_summary", corps_summary)
    logic_corps_fight.SetEnemyCorpsInfo(corps_summary)
  end)
end
local oneHour = 3600
local oneDayTime = 24 * oneHour
function logic_corps_fight.GetCurrentDayInFight(bNotUseCache)
  if bNotUseCache == true then
    cache_data.curDay = nil
  end
  if cache_data.curDay == nil then
    local now = GetServerTimeInUTC()
    local curDay = logic_corps_fight.GetDayFromFightStart(now)
    cache_data.  end
  return cache_data.curDay
end
function logic_corps_fight.GetLastDayInFight()
  local curRaceTimecfg = logic_corps_fight.GetCurRaceTimecfg()
  if logic_corps_fight.CheckFightInFighting() then
    local cday = logic_corps_fight.GetCurrentDayInFight()
    if cday and 2 <= cday then
      return cday - 1
    end
  elseif logic_corps_fight.CheckFightInResult() then
    local time_0 = curRaceTimecfg.task_start_time % oneDayTime
    local diffTime = curRaceTimecfg.task_end_time - curRaceTimecfg.task_start_time + time_0
    local day = math.ceil(diffTime / oneDayTime)
    return day
  end
  return 0
end
function logic_corps_fight.GetDayFromFightStart(time)
  if logic_corps_fight.CheckFightInFighting() then
    local curRaceTimecfg = logic_corps_fight.GetCurRaceTimecfg()
    local now = time
    local time_0 = curRaceTimecfg.task_start_time % oneDayTime
    local diffTime = now - curRaceTimecfg.task_start_time + time_0
    local day = math.ceil(diffTime / oneDayTime)
    return day
  end
  return 0
end
function logic_corps_fight.GetTodayRestTime()
  local TimeUtil = require("client.common.time_util")
  local restTime = TimeUtil.GetTodayTimestamp()
  return TimeUtil.FormatCountDownTime_HMS(restTime)
end
function logic_corps_fight.GetBeginFightRestTime()
  local TimeUtil = require("client.common.time_util")
  local now = GetServerTimeInUTC()
  local curCfg = logic_corps_fight.GetCurRaceTimecfg()
  local restTime = curCfg.task_start_time - now
  if restTime < 0 then
    return ""
  else
    return TimeUtil.FormatCountDownTime_D_or_HMS(restTime, 1)
  end
end
function logic_corps_fight.GetNextFightBeginTime()
  local TimeUtil = require("client.common.time_util")
  local nextcurCfg = logic_corps_fight.GetNextCurRaceTimeCfg()
  if nextcurCfg then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    local strRegion = Client.GetPublishRegion()
    if strRegion == PublishRegionMacros.BLUEHOLE or PublishRegionMacros.IsJapanOrKorea() then
      return TimeUtil.FormatTime_YMDHM(nextcurCfg.act_start_time, true)
    else
      return TimeUtil.FormatTime_YMD(nextcurCfg.act_start_time)
    end
  end
  return ""
end
function logic_corps_fight.GetSupplyByIndexAndResultType(index, resultType)
  if corpsRaceRewardConfig[index] then
    return corpsRaceRewardConfig[index].supplie_number[resultType] or 0
  end
  return 0
end
function logic_corps_fight.GetCorpBaseInfo(owner)
  local dataTbl
  local LogicCorps = require("client.slua.logic.corps.logic_corps")
  if owner == logic_corps_fight.We then
    dataTbl = {
      icon_text = DataMgr.corpsInfo.icon_text,
      icon = DataMgr.corpsInfo.icon,
      city = DataMgr.corpsInfo.city,
      name = DataMgr.corpsInfo.name,
      level = DataMgr.corpsInfo.level,
      MemberCount = #DataMgr.corpsInfo.corpsMemberList,
      icon_text_color = LogicCorps.IDToColor(DataMgr.corpsInfo.icon_text_colour)
    }
  else
    local enemyInfo = logic_corps_fight.GetEnemyCorpInfo()
    if enemyInfo then
      dataTbl = {
        icon_text = enemyInfo.icon_text,
        icon = enemyInfo.icon,
        city = enemyInfo.city,
        name = enemyInfo.name,
        level = enemyInfo.level,
        MemberCount = enemyInfo.member_num,
        icon_text_color = enemyInfo.icon_text_colour and LogicCorps.IDToColor(tonumber(enemyInfo.icon_text_colour))
      }
    end
  end
  return dataTbl
end
function logic_corps_fight.CheckShowTab()
  if logic_corps_fight.CheckActNotOpen() then
    return false
  end
  if DataMgr.corpsInfo.id ~= 0 then
    if logic_corps_fight.CheckFightIsRunning() then
      return true
    end
    return false
  end
  return false
end
function logic_corps_fight.GetCorpMemberByUid(uid)
  local memberList = DataMgr.corpsInfo.corpsMemberList
  for i, v in ipairs(memberList) do
    if v.id == uid then
      return v
    end
  end
  return nil
end
function logic_corps_fight.SetBattleSwitch(bSwitch)
  if corpfightInfo and corpfightInfo.ext_info then
    corpfightInfo.ext_info.battle_switch = bSwitch
  end
end
function logic_corps_fight.GetBattleSwitch()
  log_tree(bWriteLog and "logic_corps_fight.GetBattleSwitch corpfightInfo", corpfightInfo)
  if corpfightInfo and corpfightInfo.ext_info then
    return corpfightInfo.ext_info.battle_switch
  end
  return false
end
function logic_corps_fight.GetCurScore(owner)
  local curScore = 0
  if owner == logic_corps_fight.We then
    local _corpfightInfo = logic_corps_fight.GetCorpfightInfo()
    if _corpfightInfo and _corpfightInfo.total_score then
      curScore = _corpfightInfo.total_score
    end
  else
    local _enemyCorpsInfo = logic_corps_fight.GetEnemyCorpInfo()
    if _enemyCorpsInfo and _enemyCorpsInfo.race_total_score then
      curScore = _enemyCorpsInfo.race_total_score
    end
  end
  return curScore or 0
end
function logic_corps_fight.GetMyTodayScore()
  local _corpfightInfo = logic_corps_fight.GetCorpfightInfo()
  local curScore = _corpfightInfo.cur_score
  return curScore
end
function logic_corps_fight.GetTaskStatus()
  local _corpfightInfo = logic_corps_fight.GetCorpfightInfo()
  local taskStatus
  if _corpfightInfo and _corpfightInfo.ext_info then
    taskStatus = _corpfightInfo.ext_info.task_status
  end
  return taskStatus or {}
end
function logic_corps_fight.GetTaskTimes()
  local _corpfightInfo = logic_corps_fight.GetCorpfightInfo()
  local taskTimes
  if _corpfightInfo and _corpfightInfo.ext_info then
    taskTimes = _corpfightInfo.ext_info.task_times
  end
  return taskTimes or 0
end
function logic_corps_fight.GetFinalResult(bMyCorp)
  if bMyCorp == nil then
    bMyCorp = true
  end
  local weNumber = logic_corps_fight.GetOccupySupplyScore(logic_corps_fight.We)
  local enemyNumber = logic_corps_fight.GetOccupySupplyScore(logic_corps_fight.Enemy)
  local resultType
  if weNumber == enemyNumber then
    resultType = RESULT.Tie
  elseif weNumber > enemyNumber then
    resultType = bMyCorp and RESULT.Win or RESULT.Failure
  elseif weNumber < enemyNumber then
    resultType = bMyCorp and RESULT.Failure or RESULT.Win
  end
  return resultType
end
function logic_corps_fight.GetLastDayStatus()
  local lastDayIndex = logic_corps_fight.GetLastDayInFight()
  local race_data = logic_corps_fight.GetOccupyRaceData(logic_corps_fight.We)
  if lastDayIndex and race_data then
    local nextState = race_data[lastDayIndex]
    return nextState
  end
  return nil
end
local packKeyWithCorpsId = function(key)
  return key .. "_" .. DataMgr.corpsInfo.id
end
function logic_corps_fight.CheckUICondition(prefType)
  local TimeUtil = require("client.common.time_util")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(prefType) or {}
  local key = packKeyWithCorpsId(TimeUtil.FormatTime_YMD(GetServerTimeInUTC()))
  local bRet = false
  if prefType == PlayerPrefsSystem.ePlayerPrefsType.CorpFightToday then
    if logic_corps_fight.CheckFightInFighting() and cfg[key] == nil and logic_corps_fight.GetLastDayStatus() ~= nil and logic_corps_fight.CheckRegisterSuccess() then
      bRet = true
    end
  elseif prefType == PlayerPrefsSystem.ePlayerPrefsType.CorpFightStart then
    if logic_corps_fight.CheckFightInFighting() and cfg[key] == nil and logic_corps_fight.CheckRegisterSuccess() then
      bRet = true
    end
  elseif prefType == PlayerPrefsSystem.ePlayerPrefsType.CorpFightStartMatched then
    local curRaceTimecfg = logic_corps_fight.GetCurRaceTimecfg()
    key = packKeyWithCorpsId(TimeUtil.FormatTime_YMD(curRaceTimecfg.act_start_time))
    if logic_corps_fight.CheckRegisterSuccess() and cfg[key] == nil then
      bRet = true
    end
  elseif prefType == PlayerPrefsSystem.ePlayerPrefsType.CorpFightUltimateReward then
    if logic_corps_fight.CheckFightInResult() and cfg[key] == nil and logic_corps_fight.CheckRegisterSuccess() and logic_corps_fight.CheckCanGetUltimateReward() then
      bRet = true
    end
  elseif prefType == PlayerPrefsSystem.ePlayerPrefsType.CorpFightRegister then
    local curRaceTimecfg = logic_corps_fight.GetCurRaceTimecfg()
    if curRaceTimecfg and curRaceTimecfg.act_start_time then
      key = packKeyWithCorpsId(TimeUtil.FormatTime_YMD(curRaceTimecfg.act_start_time))
    end
    if logic_corps_fight.CheckFightInRegister() and logic_corps_fight.CheckRegisterSuccess() == false and cfg[key] == nil then
      bRet = true
    end
  elseif prefType == PlayerPrefsSystem.ePlayerPrefsType.CorpFightDaily then
    if logic_corps_fight.CheckFightInFighting() and cfg[key] == nil and logic_corps_fight.CheckRegisterSuccess() and logic_corps_fight.GetRestTimes() > 0 then
      bRet = true
    end
  elseif prefType == PlayerPrefsSystem.ePlayerPrefsType.CorpFightFloatTip and logic_corps_fight.CheckFightInFighting() and logic_corps_fight.GetBattleSwitch() == true and logic_corps_fight.CheckRegisterSuccess() then
    local bopen = logic_corps_fight.CheckCanBattle()
    local cfgTbl = cfg[key] or {}
    log_tree(bWriteLog and "logic_corps_fight.CheckUICondition CorpFightFloatTip cfgTbl", cfgTbl)
    if bopen == true and (cfgTbl.open_times == nil or cfgTbl.open_times < 1) then
      bRet = true
    end
    if bopen == false and (cfgTbl.close_times == nil or 1 > cfgTbl.close_times) then
      bRet = true
    end
  end
  return bRet
end
function logic_corps_fight.UpdateUICondition(prefType)
  local TimeUtil = require("client.common.time_util")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(prefType) or {}
  local key
  if prefType == PlayerPrefsSystem.ePlayerPrefsType.CorpFightRegister then
    local curRaceTimecfg = logic_corps_fight.GetCurRaceTimecfg()
    key = packKeyWithCorpsId(TimeUtil.FormatTime_YMD(curRaceTimecfg.act_start_time))
    cfg[key] = true
  elseif prefType == PlayerPrefsSystem.ePlayerPrefsType.CorpFightStartMatched then
    local curRaceTimecfg = logic_corps_fight.GetCurRaceTimecfg()
    key = packKeyWithCorpsId(TimeUtil.FormatTime_YMD(curRaceTimecfg.act_start_time))
    cfg[key] = true
  elseif prefType == PlayerPrefsSystem.ePlayerPrefsType.CorpFightFloatTip then
    key = packKeyWithCorpsId(TimeUtil.FormatTime_YMD(GetServerTimeInUTC()))
    local bopen = logic_corps_fight.CheckCanBattle()
    local times = "close_times"
    if bopen == true then
      times = "open_times"
    end
    if cfg[key] == nil then
      cfg[key] = {}
    end
    if cfg[key][times] == nil then
      cfg[key][times] = 1
    else
      cfg[key][times] = cfg[key][times] + 1
    end
  else
    key = packKeyWithCorpsId(TimeUtil.FormatTime_YMD(GetServerTimeInUTC()))
    cfg[key] = true
  end
  PlayerPrefsSystem.SaveTableToFile_N(cfg, prefType)
end
local addList = function(aTbl, bTbl)
  for i, v in ipairs(bTbl) do
    aTbl[#aTbl + 1] = v
  end
end
function logic_corps_fight.GetAllRestRewardList(resultType)
  if cache_data.RestRewardList == nil then
    local retTbl = {}
    local ret1Tbl = logic_corps_fight.GetRestOccupyReward()
    local ret2Tbl = logic_corps_fight.GetRestPersonReward()
    local ret3Tbl = logic_corps_fight.GetRestUltimateReward(resultType)
    addList(retTbl, ret1Tbl)
    addList(retTbl, ret2Tbl)
    addList(retTbl, ret3Tbl)
    cache_data.RestRewardList = retTbl
  end
  return cache_data.RestRewardList
end
function logic_corps_fight.GetRestOccupyReward()
  if cache_data.RestOccupyReward == nil then
    local retTbl = {}
    local raceData = logic_corps_fight.GetOccupyRaceData(logic_corps_fight.We)
    local rewardStatus = logic_corps_fight.GetOccupyRewardStatus()
    for i, v in ipairs(raceData) do
      local rewardTbl = logic_corps_fight.GetRewardCfgByTaskIDAndResultType(i, v)
      local bNoScore = logic_corps_fight.CheckNoScoreByDay(i)
      if rewardStatus[i] == nil and rewardTbl and 0 < #rewardTbl and bNoScore == false then
        local rewardTbl2 = logic_corps_fight.GetRewardCfgByTaskIDAndResultType(i, v)
        addList(retTbl, rewardTbl2)
      end
    end
    cache_data.RestOccupyReward = retTbl
  end
  return cache_data.RestOccupyReward
end
function logic_corps_fight.GetRestPersonReward()
  local retTbl = {}
  local my_score = logic_corps_fight.GetMyScore()
  local PersonRewardConfig = logic_corps_fight.GetPersonRewardConfig()
  if not PersonRewardConfig then
    return
  end
  for i, v in ipairs(PersonRewardConfig) do
    if my_score >= v.min_score and logic_corps_fight.CheckHasGetPersonReward(i) == false then
      retTbl[#retTbl + 1] = {
        v.res_id1,
        v.res_num1,
        v.valid_hours1
      }
    end
  end
  cache_data.RestPersonReward = retTbl
  return cache_data.RestPersonReward
end
function logic_corps_fight.GetRestUltimateReward(resultType)
  local retTbl = {}
  if logic_corps_fight.CheckCanGetUltimateReward() then
    retTbl = logic_corps_fight.GetUltimateReward(resultType)
  end
  return retTbl
end
function logic_corps_fight.CheckCanGetUltimateReward()
  local timecfg = logic_corps_fight.GetCurRaceTimecfg()
  local limit_person_score = timecfg.limit_person_score or 0
  if corpfightInfo and corpfightInfo.ext_info and corpfightInfo.ext_info.final_award_status == false and limit_person_score <= logic_corps_fight.GetMyScore() then
    return true
  end
  return false
end
function logic_corps_fight.CheckOccupyRewardExist()
  local retTbl = logic_corps_fight.GetRestOccupyReward()
  return 0 < #retTbl
end
function logic_corps_fight.CheckPersonRewardExist()
  local retTbl = logic_corps_fight.GetRestPersonReward()
  return retTbl and 0 < #retTbl or false
end
function logic_corps_fight.UpdateAllRewardData()
  local raceData = logic_corps_fight.GetOccupyRaceData(logic_corps_fight.We)
  for i, v in ipairs(raceData) do
    if v == logic_corps_fight.RESULT.Win or v == logic_corps_fight.RESULT.Tie then
      corpfightInfo.ext_info.daily_award_status[i] = true
    end
  end
  corpfightInfo.ext_info.final_award_status = true
  local my_score = logic_corps_fight.GetMyScore()
  local PersonRewardConfig = logic_corps_fight.GetPersonRewardConfig()
  for i, v in ipairs(PersonRewardConfig) do
    if my_score >= v.min_score then
      corpfightInfo.ext_info.score_award_status[i] = true
    end
  end
  cache_data.RestPersonReward = nil
  cache_data.RestOccupyReward = nil
  cache_data.RestRewardList = nil
end
function logic_corps_fight.CheckShowNextUI()
  if logic_corps_fight.CheckUICondition(PlayerPrefsSystem.ePlayerPrefsType.CorpFightUltimateReward) then
    logic_corps_fight.ShowUltimateResultUI()
    logic_corps_fight.UpdateUICondition(PlayerPrefsSystem.ePlayerPrefsType.CorpFightUltimateReward)
  elseif logic_corps_fight.CheckUICondition(PlayerPrefsSystem.ePlayerPrefsType.CorpFightToday) then
    logic_corps_fight.ShowTodayResultUI()
    logic_corps_fight.UpdateUICondition(PlayerPrefsSystem.ePlayerPrefsType.CorpFightToday)
  elseif logic_corps_fight.CheckUICondition(PlayerPrefsSystem.ePlayerPrefsType.CorpFightStart) then
    logic_corps_fight.ShowStartUI()
    logic_corps_fight.UpdateUICondition(PlayerPrefsSystem.ePlayerPrefsType.CorpFightStart)
  end
end
function logic_corps_fight.CheckMemberLimit()
  local timecfg = logic_corps_fight.GetCurRaceTimecfg()
  if #DataMgr.corpsInfo.corpsMemberList == 0 then
    return false
  end
  if #DataMgr.corpsInfo.corpsMemberList < timecfg.limit_number then
    return true
  end
  return false
end
function logic_corps_fight.DoEnterFunc()
  UIManager.CloseUI(UIManager.UI_Config.CorpsTabMgr)
  EventSystem:postEvent(EVNETID_MATCH_NEW_GUIDE, EVENTID_MATCH_NEWBIE_CLICK_Entry)
end
function logic_corps_fight.CheckNeedInit()
  if corpfightInfo == nil then
    return true
  end
  if corpfightInfo ~= nil and corpfightInfo.race_corpsid ~= nil and corpfightInfo.race_corpsid ~= 0 and enemyCorpsInfo == nil then
    return true
  end
  return false
end
function logic_corps_fight.CheckShowFightBeginTip(matchID)
  if logic_corps_fight.GetBattleSwitch() and logic_corps_fight.CheckFightInFighting() and logic_corps_fight.CheckRegisterSuccess() and logic_corps_fight.GetCropsDayTaskTimes() > logic_corps_fight.GetTaskTimes() and logic_corps_fight.CheckMatchIDIsInCurTask(matchID) then
    return true
  end
  return false
end
function logic_corps_fight.CheckNoScoreByDay(idx)
  local fightInfo = logic_corps_fight.GetCorpfightInfo()
  local shift = 1
  if fightInfo and fightInfo.score_bits then
    local score_bits = fightInfo.score_bits
    shift = shift << idx
    if 0 < score_bits & shift then
      return false
    else
      return true
    end
  end
  return true
end
function logic_corps_fight.GetCropsDayTaskTimes()
  return corpsDayTaskTimes
end
function logic_corps_fight.GetExtraFromCorpTabMgr()
  local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
  local extra = logic_corps_tab_mgr.extra
  logic_corps_tab_mgr.extra = nil
  return extra
end
function logic_corps_fight.ShowScoreTip()
  log(bWriteLog and "logic_corps_fight.ShowScoreTip")
  logic_corps_fight.InitCfgTable()
  logic_corps_fight.DoShowRightTipUI()
  if showscore ~= nil then
    logic_corps_fight.ShowTipUI(LocUtil.LocalizeResFormat(23764, showscore))
    showscore = nil
  end
  if logic_corps_fight.ShowFightTip then
    logic_corps_fight.ShowRightTipUI()
    logic_corps_fight.UpdateUICondition(PlayerPrefsSystem.ePlayerPrefsType.CorpFightFloatTip)
    logic_corps_fight.ShowFightTip = false
  end
end
function logic_corps_fight.CheckActNotOpen()
  return LobbySystem.CheckOpen(BP_ENUM_CORP_FIGHT_SWITCH) == false
end
function logic_corps_fight.GetLimitPersonScore()
  local timecfg = logic_corps_fight.GetCurRaceTimecfg()
  return timecfg.limit_person_score or 0
end
function logic_corps_fight.CheckShowRightTipUI()
  log(bWriteLog and "logic_corps_fight.CheckShowRightTipUI")
  if logic_corps_fight.CheckUICondition(PlayerPrefsSystem.ePlayerPrefsType.CorpFightFloatTip) and logic_corps_fight.ShowTipFlag == true then
    return true
  end
  return false
end
function logic_corps_fight.DoShowRightTipUI()
  log(bWriteLog and "logic_corps_fight.DoShowRightTipUI")
  if logic_corps_fight.CheckShowRightTipUI() then
    logic_corps_fight.ShowFightTip = true
  end
  logic_corps_fight.ShowTipFlag = false
  log(bWriteLog and string.format("logic_corps_fight.DoShowRightTipUI, ShowFightTip:%s", logic_corps_fight.ShowFightTip))
end
function logic_corps_fight.CheckCanBattle()
  if IsWoWEditor then
    return false
  end
  local rest = logic_corps_fight.GetRestTimes()
  local switch = logic_corps_fight.GetBattleSwitch()
  log(bWriteLog and string.format("logic_corps_fight.CheckCanBattle, switch:%s", switch))
  log(bWriteLog and string.format("logic_corps_fight.CheckCanBattle, rest:%s", rest))
  if 0 < rest and switch == true then
    return true
  else
    return false
  end
end
function logic_corps_fight.GetRestTimes()
  local taskCfg = logic_corps_fight.GetCurTaskCfg()
  local tasktimes = logic_corps_fight.GetTaskTimes()
  log_tree(bWriteLog and "logic_corps_fight.GetRestTimes taskCfg", taskCfg)
  log(bWriteLog and string.format("logic_corps_fight.GetRestTimes, tasktimes:%s", tasktimes))
  if not taskCfg then
    return 0
  end
  local rest = taskCfg.daily_limit - tasktimes
  return rest
end
function logic_corps_fight.GetCurTaskCfg()
  local energyType = DataMgr.corpsInfo.energyType
  local dayIndex = logic_corps_fight.GetCurrentDayInFight()
  local taskID = logic_corps_fight.GetDailyTaskCfgByTaskIDAndDayIdx(energyType, dayIndex)
  local taskCfg = logic_corps_fight.GetTaskCfgByTaskID(taskID)
  return taskCfg
end
function logic_corps_fight.CheckMatchIDIsInCurTask(matchID)
  local taskCfg = logic_corps_fight.GetCurTaskCfg()
  if taskCfg == nil or taskCfg.match_id_list == nil then
    return false
  end
  if taskCfg then
    if #taskCfg.match_id_list == 0 or #taskCfg.match_id_list == 1 and taskCfg.match_id_list[1] == "" then
      return true
    end
    if #taskCfg.match_id_list > 0 then
      local matchIDStr = tostring(matchID)
      for i, v in ipairs(taskCfg.match_id_list) do
        if matchIDStr == v then
          return true
        end
      end
    end
  end
  return false
end
function logic_corps_fight.CheckBlueTeamIsMe()
  if corpfightInfo and corpfightInfo.race_corpsid then
    return DataMgr.corpsInfo.id > corpfightInfo.race_corpsid
  end
  return false
end
function logic_corps_fight.GetPositionByColor(_color)
  if cache_data.colorPos[_color] == nil then
    local isMeBlue = logic_corps_fight.CheckBlueTeamIsMe()
    local pos
    if isMeBlue then
      if logic_corps_fight.COLOR.Red == _color then
        pos = logic_corps_fight.Enemy
      else
        pos = logic_corps_fight.We
      end
    elseif logic_corps_fight.COLOR.Red == _color then
      pos = logic_corps_fight.We
    else
      pos = logic_corps_fight.Enemy
    end
    cache_data.colorPos[_color] = pos
  end
  return cache_data.colorPos[_color]
end
function logic_corps_fight.CheckShowMatchAnim()
  if logic_corps_fight.CheckUICondition(PlayerPrefsSystem.ePlayerPrefsType.CorpFightStartMatched) then
    logic_corps_fight.UpdateUICondition(PlayerPrefsSystem.ePlayerPrefsType.CorpFightStartMatched)
    return true
  end
  return false
end
function logic_corps_fight.GetCurTime()
  return GetServerTimeInUTC()
end
function logic_corps_fight.CheckShowBgFunc()
  if logic_corps_fight.CheckFightInResult() and logic_corps_fight.CheckRegisterSuccess() then
    return true
  end
  return false
end
function logic_corps_fight.SetCorpUIBaseInfo(widgetTbl, dataTbl)
  if widgetTbl.TextLogo and dataTbl then
    widgetTbl.TextLogo:SetText(string.upper(dataTbl.icon_text))
    if dataTbl.icon_text_color then
      widgetTbl.TextLogo:SetColorAndOpacity(dataTbl.icon_text_color)
    end
  end
  if widgetTbl.Image_Flag and dataTbl then
    local CorpsBadge = CDataTable.GetTableData("CorpsBadge", dataTbl.icon)
    local LogicCorps = require("client.slua.logic.corps.logic_corps")
    if CorpsBadge then
      local util = require("client.slua_ui_framework.util")
      util.SetTexture(widgetTbl.Image_Flag, CorpsBadge.BigIconPath, {sync = false})
    end
  end
  if widgetTbl.Image_Nation and dataTbl then
    local UIUtil = require("client.common.ui_util")
    UIUtil.UpdateNationImage(widgetTbl.Image_Nation, dataTbl.city)
  end
  if widgetTbl.CorpsName and dataTbl then
    widgetTbl.CorpsName:SetText(dataTbl.name)
  end
  if widgetTbl.Corps_Level and dataTbl then
    widgetTbl.Corps_Level:SetText(LocUtil.LocalizeResFormat(4436) .. dataTbl.level)
  end
  if widgetTbl.CorpsMemberCount and dataTbl then
    local CorpsLevel = CDataTable.GetTableData("CorpsLevel", dataTbl.level)
    if CorpsLevel then
      widgetTbl.CorpsMemberCount:SetText(dataTbl.MemberCount .. "/" .. CorpsLevel.MemberLimit)
    else
      widgetTbl.CorpsMemberCount:SetText(dataTbl.MemberCount .. "/" .. 25)
      log_error("no CorpsLevel:" .. tostring(DataMgr.corpsInfo.level))
    end
  end
end
function logic_corps_fight.GetResultStatusByDayIndex(index, owner)
  local fightInfo = logic_corps_fight.GetCorpfightInfo()
  local enemyInfo = logic_corps_fight.GetEnemyCorpInfo()
  if fightInfo == nil or enemyInfo == nil or fightInfo.day_scores == nil or enemyInfo.day_scores == nil then
    return RESULT.Flow
  end
  local f_score = fightInfo.day_scores[index] or 0
  local e_score = enemyInfo.day_scores[index] or 0
  local nextState
  if f_score == e_score and f_score == 0 then
    nextState = RESULT.Flow
  end
  if f_score == e_score and f_score ~= 0 then
    nextState = RESULT.Tie
  end
  if f_score > e_score then
    nextState = owner == logic_corps_fight.We and RESULT.Win or RESULT.Failure
  end
  if f_score < e_score then
    nextState = owner == logic_corps_fight.We and RESULT.Failure or RESULT.Win
  end
  return nextState
end
function logic_corps_fight.ShowErrorTips(res)
  if res == 100150011 or res == 100150012 then
    local HDmpveChannelID = Client.GetLoginChannel(NetInterface)
    local SettingAccount = require("client.logic.setting.logic_setting_account")
    local ChannelName = SettingAccount.GetNameByHDmpveChannel(HDmpveChannelID)
    local NoticeMessage = LocUtil.LocalizeResFormat(14252, ChannelName)
    ShowNotice(NoticeMessage)
  else
    ShowNotice(res)
  end
end
function logic_corps_fight.HideCorpModel()
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  local CorpsCoupleAvatar = CoupleAvatarSystem:GetCoupleAvatar(CoupleAvatarSystem.ESceneType.Corps)
  if CorpsCoupleAvatar then
    CorpsCoupleAvatar:HideAvatars()
  end
end
function logic_corps_fight.SolveWinAndLoseBit(winbits, losebits)
  local lastDay = logic_corps_fight.GetLastDayInFight()
  local my_day_score = corpfightInfo.day_scores
  local enemy_day_score = {}
  local shift = 2
  if lastDay then
    for i = 1, lastDay do
      local score = my_day_score[i] or 0
      if 0 < winbits & shift then
        enemy_day_score[i] = score - 1
      elseif 0 < losebits & shift then
        enemy_day_score[i] = score + 1
      else
        enemy_day_score[i] = score
      end
      shift = shift << 1
    end
  end
  return enemy_day_score
end
function logic_corps_fight.JoinConfrontation()
  log(bWriteLog and "[v_yunjxing] JoinConfrontation")
  if logic_corps_fight.CheckMemberLimitSwitchOpen() == false and logic_corps_fight.CheckMemberLimit() then
    ShowNotice(23769)
    return
  end
  logic_corps_fight.send_corps_race_act_enroll_req()
end
function logic_corps_fight.FightButtonOpenRedPoint()
  if logic_corps_fight.CheckNeedInit() then
    return false
  end
  return logic_corps_fight.CheckUICondition(PlayerPrefsSystem.ePlayerPrefsType.CorpFightRegister)
end
function logic_corps_fight.FightButtonDailyRedPoint()
  if logic_corps_fight.CheckNeedInit() then
    return false
  end
  if logic_corps_fight.CheckFightInFighting() then
    return logic_corps_fight.CheckUICondition(PlayerPrefsSystem.ePlayerPrefsType.CorpFightDaily)
  end
  return false
end
function logic_corps_fight.UpdateButtonDailyRedPoint()
  logic_corps_fight.UpdateUICondition(PlayerPrefsSystem.ePlayerPrefsType.CorpFightDaily)
end
function logic_corps_fight.FightButtonOccupyRedPoint()
  if logic_corps_fight.CheckNeedInit() then
    return false
  end
  if logic_corps_fight.CheckFightInFighting() then
    return logic_corps_fight.CheckOccupyRewardExist()
  end
  return false
end
function logic_corps_fight.FightButtonScoreRedPoint()
  if logic_corps_fight.CheckNeedInit() then
    return false
  end
  if logic_corps_fight.CheckFightInFighting() or logic_corps_fight.CheckFightInResult() then
    return logic_corps_fight.CheckPersonRewardExist()
  end
  return false
end
function logic_corps_fight.FightButtonRewardRedPoint()
  if logic_corps_fight.CheckNeedInit() then
    return false
  end
  if logic_corps_fight.CheckFightInResult() then
    return logic_corps_fight.CheckCanGetUltimateReward()
  end
  return false
end
function logic_corps_fight.UpdateRedDotPoint()
  local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
  logic_corps_tab_mgr.UpdateRedPoint()
end
function logic_corps_fight.SetMemberLimitSwitch(bflag)
  gm_member_limit_flag = bflag
end
function logic_corps_fight.CheckMemberLimitSwitchOpen()
  return gm_member_limit_flag == true
end
function logic_corps_fight.ClearSaveData()
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.CorpFightToday)
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.CorpFightStart)
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.CorpFightDaily)
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.CorpFightUltimateReward)
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.CorpFightRegister)
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.CorpFightFloatTip)
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.CorpFightStartMatched)
end
local constructDefaultFightInfo = function()
  local info = {
    act_id = 1,
    active_type = 1,
    cur_score = 0,
    day_scores = {},
    is_enrolled = false,
    lose_bits = 0,
    win_bits = 0,
    my_score = 0,
    race_corpsid = 0,
    score_bits = 0,
    top3_members = {},
    total_score = 0
  }
  info.ext_info = defaultHandle({})
  corpfightInfo = info
end
function logic_corps_fight.GM_SetFightRegister()
  if not corpsRaceActConfig then
    return
  end
  DEBUG_TIME = corpsRaceActConfig[1].act_start_time
  constructDefaultFightInfo()
  constructDefaultEnemyInfo()
end
function logic_corps_fight.GM_SetFightStart()
  if not corpsRaceActConfig then
    return
  end
  DEBUG_TIME = corpsRaceActConfig[1].task_start_time
  constructDefaultFightInfo()
  constructDefaultEnemyInfo()
  corpfightInfo.is_enrolled = true
  local logic_corps_fight_new = GetModuleForBlackList(ModuleManager.CommonModuleConfig.logic_corps_fight_new)
  logic_corps_fight_new:SetSignPk(true)
end
function logic_corps_fight.GM_SetFightEnd()
  if not corpsRaceActConfig then
    return
  end
  DEBUG_TIME = corpsRaceActConfig[1].task_end_time + 10000
  constructDefaultFightInfo()
  constructDefaultEnemyInfo()
  corpfightInfo.is_enrolled = true
  local logic_corps_fight_new = GetModuleForBlackList(ModuleManager.CommonModuleConfig.logic_corps_fight_new)
  logic_corps_fight_new:SetSignPk(true)
end
local _curday
function logic_corps_fight.GM_SetFightNextDay()
  if _curday == nil then
    _curday = 0
  else
    _curday = _curday + 1
  end
  if not corpsRaceActConfig then
    return
  end
  DEBUG_TIME = corpsRaceActConfig[1].task_start_time + _curday * 24 * 60 * 60
  constructDefaultFightInfo()
  constructDefaultEnemyInfo()
  corpfightInfo.is_enrolled = true
  local logic_corps_fight_new = GetModuleForBlackList(ModuleManager.CommonModuleConfig.logic_corps_fight_new)
  logic_corps_fight_new:SetSignPk(true)
end
function logic_corps_fight.CheckJK()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    return true
  end
  return false
end
function logic_corps_fight.CheckIndia()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return true
  end
  return false
end
function logic_corps_fight.CheckShowCorpFightInMainUI()
  if logic_corps_fight.CheckFightInFighting() and logic_corps_fight.GetBattleSwitch() == true and logic_corps_fight.CheckRegisterSuccess() then
    return true
  end
  return false
end
return logic_corps_fight