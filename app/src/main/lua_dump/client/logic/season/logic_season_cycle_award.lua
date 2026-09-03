local LogicSeasonCycleAward = {}
function LogicSeasonCycleAward.GetSeasonYearDetailInfo()
  return LogicSeasonCycleAward.season_year_detail_info
end
function LogicSeasonCycleAward.GetProcessRewardInfo()
  return LogicSeasonCycleAward.reward_info
end
function LogicSeasonCycleAward.GetSeasonProcessRewardInfo(season_year_id, medal_imprint_id)
  if not season_year_id or not medal_imprint_id then
    return nil
  end
  if not LogicSeasonCycleAward.reward_info or not LogicSeasonCycleAward.reward_info[season_year_id] then
    return nil
  end
  return LogicSeasonCycleAward.reward_info[season_year_id][medal_imprint_id]
end
function LogicSeasonCycleAward.GetMedalCollectProList(season_year_id, medal_id)
  log(bWriteLog and "LogicSeasonCycleAward.GetMedalCollectProList season_year_id = " .. tostring(season_year_id) .. " medal_id = " .. tostring(medal_id))
  if not season_year_id or not medal_id then
    return nil
  end
  if not LogicSeasonCycleAward.season_year_detail_info or not LogicSeasonCycleAward.season_year_detail_info[season_year_id] then
    return nil
  end
  local icon_collect_pro_list = LogicSeasonCycleAward.season_year_detail_info[season_year_id].icon_collect_pro_list
  if not icon_collect_pro_list then
    return nil
  end
  return icon_collect_pro_list[medal_id]
end
function LogicSeasonCycleAward.GetMakeupTaskList(season_year_id, medal_id)
  if not season_year_id or not medal_id then
    return nil
  end
  if not LogicSeasonCycleAward.season_year_detail_info or not LogicSeasonCycleAward.season_year_detail_info[season_year_id] then
    return nil
  end
  local makeup_task_list = LogicSeasonCycleAward.season_year_detail_info[season_year_id].makeup_task_list
  if not makeup_task_list then
    return nil
  end
  return makeup_task_list[medal_id]
end
function LogicSeasonCycleAward.GetYearRewardStatus(season_year_id, medal_id)
  if not season_year_id or not medal_id then
    return nil
  end
  if not LogicSeasonCycleAward.season_year_detail_info or not LogicSeasonCycleAward.season_year_detail_info[season_year_id] then
    return nil
  end
  local year_reward_list = LogicSeasonCycleAward.season_year_detail_info[season_year_id].year_reward_list
  if not year_reward_list then
    return nil
  end
  return year_reward_list[medal_id]
end
function LogicSeasonCycleAward.GetCurSeasonYearId()
  if not LogicSeasonCycleAward.season_year_detail_info then
    return 0
  end
  for season_year_id, info in pairs(LogicSeasonCycleAward.season_year_detail_info) do
    if info.is_cur_year then
      return season_year_id
    end
  end
  return 0
end
function LogicSeasonCycleAward.GetSeasonYearFinalSeason(seasonYearId)
  if not seasonYearId then
    return 0
  end
  local curSeasonYear = LogicSeasonCycleAward.GetCurSeasonYearId()
  if seasonYearId == curSeasonYear then
    return DataMgr.season_id
  end
  local SeasonYearCfg = CDataTable.GetTableData("SeasonYearInfo", seasonYearId)
  if not SeasonYearCfg then
    return 0
  end
  return SeasonYearCfg.SeasonYearEndSeason
end
function LogicSeasonCycleAward.GetLastestAceInfo(season_year_id)
  local season_year_detail_info = LogicSeasonCycleAward.season_year_detail_info
  if not (season_year_detail_info and season_year_detail_info[season_year_id] and season_year_detail_info[season_year_id].lastest_ace_info) or not next(season_year_detail_info[season_year_id].lastest_ace_info) then
    return nil
  end
  return season_year_detail_info[season_year_id].lastest_ace_info
end
local ClearData = function()
  LogicSeasonCycleAward.season_year_detail_info = nil
end
function LogicSeasonCycleAward.OnGameStateChange(eventType, eventID, gameState)
  if gameState.current == GameStatus.Login or gameState.current == GameStatus.Fighting and not GameStatus.IsInLobbyOrMainCity() then
    ClearData()
  end
end
function LogicSeasonCycleAward.send_get_season_year_reward_info_req()
  local SeasonCycleAwardHandler = require("client.network.Protocol.SeasonCycleAwardHandler")
  SeasonCycleAwardHandler.send_get_season_year_reward_info_req()
end
function LogicSeasonCycleAward.on_get_season_year_reward_info_rsp(season_year_detail_info, reward_info)
  log_tree("on_get_season_year_reward_info_rsp season_year_detail_info:", season_year_detail_info)
  log_tree("on_get_season_year_reward_info_rsp reward_info:", reward_info)
  LogicSeasonCycleAward.  LogicSeasonCycleAward.  EventSystem:postEvent(EVENTTYPE_SEASON_CYCLE_AWARD, EVENTID_SEASON_CYCLE_AWARD_INFO_RSP)
end
function LogicSeasonCycleAward.caculate_award_count()
  local season_year_detail_info = LogicSeasonCycleAward.season_year_detail_info
  local reddot_count = 0
  for _, info in pairs(season_year_detail_info) do
    for _, iconInfo in pairs(info.icon_collect_pro_list) do
      for _, seasonIconInfo in pairs(iconInfo) do
        if seasonIconInfo.status == 1 then
          reddot_count = reddot_count + 1
        end
      end
    end
    for _, yearRewardInfo in pairs(info.year_reward_list) do
      if yearRewardInfo.reward_status == 1 then
        reddot_count = reddot_count + 1
      end
    end
  end
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  season_redpoint_data.SetNewCycleRewardNumRedDot(reddot_count)
end
function LogicSeasonCycleAward.send_get_season_year_reward_req(season_year_id, icon_id)
  local SeasonCycleAwardHandler = require("client.network.Protocol.SeasonCycleAwardHandler")
  SeasonCycleAwardHandler.send_get_season_year_reward_req(season_year_id, icon_id)
end
function LogicSeasonCycleAward.on_get_season_year_reward_rsp(season_year_id, year_reward_list, itemlist)
  log_tree("on_get_season_year_reward_rsp year_reward_list:", year_reward_list)
  if not season_year_id or not year_reward_list then
    return
  end
  if not (LogicSeasonCycleAward.season_year_detail_info and LogicSeasonCycleAward.season_year_detail_info[season_year_id]) or not LogicSeasonCycleAward.season_year_detail_info[season_year_id].year_reward_list then
    return
  end
  if itemlist and 0 < #itemlist then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(itemlist)
  end
  LogicSeasonCycleAward.season_year_detail_info[season_year_id].  LogicSeasonCycleAward.send_get_season_year_reward_redpot_req()
  EventSystem:postEvent(EVENTTYPE_SEASON_CYCLE_AWARD, EVENTID_SEASON_CYCLE_TAKE_AWARD_RSP)
end
function LogicSeasonCycleAward.on_ace_imprint_status_chg_notify(icon_id, cur_status_list)
  log_tree("on_ace_imprint_status_chg_notify cur_status_list:", cur_status_list)
  if not cur_status_list then
    return
  end
  local curSeasonYear = LogicSeasonCycleAward.GetCurSeasonYearId()
  if curSeasonYear ~= 0 then
    LogicSeasonCycleAward.season_year_detail_info[curSeasonYear].icon_collect_pro_list = cur_status_list
    LogicSeasonCycleAward.send_get_season_year_reward_redpot_req()
    EventSystem:postEvent(EVENTTYPE_SEASON_CYCLE_AWARD, EVENTID_SEASON_CYCLE_MEDAL_STATUS_NOTIFY)
  end
end
function LogicSeasonCycleAward.on_season_year_makeup_task_notify(list)
  log_tree("on_season_year_makeup_task_notify list:", list)
  if not list then
    return
  end
  local curSeasonYear = LogicSeasonCycleAward.GetCurSeasonYearId()
  if curSeasonYear ~= 0 then
    LogicSeasonCycleAward.season_year_detail_info[curSeasonYear].makeup_task_    EventSystem:postEvent(EVENTTYPE_SEASON_CYCLE_AWARD, EVENTID_SEASON_CYCLE_MAKEUP_TASK_NOTIFY)
  end
end
function LogicSeasonCycleAward.GetSeasonYearAwardConfig(season_year_id)
  local list = {}
  local seasonYearRewardCfg = CDataTable.GetTable("SeasonYearReward")
  for _, cfg in pairs(seasonYearRewardCfg) do
    if cfg.SeasonYearID == season_year_id then
      table.insert(list, cfg)
    end
  end
  table.sort(list, function(a, b)
    return a.ImprintID < b.ImprintID
  end)
  return list
end
function LogicSeasonCycleAward.send_get_single_icon_reward_req(season_year_id, icon_id, season_id)
  local SeasonCycleAwardHandler = require("client.network.Protocol.SeasonCycleAwardHandler")
  SeasonCycleAwardHandler.send_get_single_icon_reward_req(season_year_id, icon_id, season_id)
end
function LogicSeasonCycleAward.on_get_single_icon_reward_res(season_year_id, icon_collect_pro_list, one_reward_itemlist, season_id)
  log_tree("on_get_single_icon_reward_res one_reward_itemlist:", one_reward_itemlist)
  if not (season_year_id and season_id) or not icon_collect_pro_list then
    return
  end
  if not (LogicSeasonCycleAward.season_year_detail_info and LogicSeasonCycleAward.season_year_detail_info[season_year_id]) or not LogicSeasonCycleAward.season_year_detail_info[season_year_id].icon_collect_pro_list then
    return
  end
  if one_reward_itemlist and 0 < #one_reward_itemlist then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(one_reward_itemlist)
  end
  LogicSeasonCycleAward.season_year_detail_info[season_year_id].  LogicSeasonCycleAward.send_get_season_year_reward_redpot_req()
  EventSystem:postEvent(EVENTTYPE_SEASON_CYCLE_AWARD, EVENTID_SEASON_CYCLE_TAKE_SINGLE_ICON_AWARD_RSP)
end
function LogicSeasonCycleAward.send_get_all_season_prize_reward_req(season_reward_list, year_reward_list)
  local SeasonCycleAwardHandler = require("client.network.Protocol.SeasonCycleAwardHandler")
  SeasonCycleAwardHandler.send_get_all_season_prize_reward_req(season_reward_list, year_reward_list)
end
function LogicSeasonCycleAward.on_get_all_season_prize_reward_rsp(icon_collect_pro_list, reward_list, year_reward_list)
  log_tree("on_get_all_season_prize_reward_rsp reward_list:", reward_list)
  if not (reward_list and type(reward_list) == "table" and icon_collect_pro_list) or type(icon_collect_pro_list) ~= "table" then
    log(bWriteLog and "on_get_all_season_prize_reward_rsp params is invalid")
    return
  end
  if not year_reward_list or type(year_reward_list) ~= "table" then
    log(bWriteLog and "on_get_all_season_prize_reward_rsp year_reward_list is invalid")
    return
  end
  if not LogicSeasonCycleAward.season_year_detail_info then
    log(bWriteLog and "on_get_all_season_prize_reward_rsp season_year_detail_info is nil")
    return
  end
  if reward_list and 0 < #reward_list then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(reward_list)
  end
  for yearId, iconCollectList in pairs(icon_collect_pro_list) do
    local oldYearData = LogicSeasonCycleAward.season_year_detail_info[yearId]
    if oldYearData and oldYearData.icon_collect_pro_list then
      oldYearData.icon_collect_pro_list = iconCollectList
    end
  end
  for yearId, yearIcon in pairs(year_reward_list) do
    local oldYearData = LogicSeasonCycleAward.season_year_detail_info[yearId]
    if oldYearData and oldYearData.year_reward_list then
      oldYearData.year_reward_list = yearIcon
    end
  end
  LogicSeasonCycleAward.send_get_season_year_reward_redpot_req()
  EventSystem:postEvent(EVENTTYPE_SEASON_CYCLE_AWARD, EVENTID_SEASON_CYCLE_MEDAL_STATUS_NOTIFY)
end
function LogicSeasonCycleAward.GetLastSeasonUnclaimedReward(season_year_id, cur_season_id)
  log(bWriteLog and "[v_ywuyuan] LogicSeasonCycleAward.GetLastSeasonUnclaimedReward" .. ":" .. tostring(season_year_id) .. ":" .. tostring(cur_season_id))
  if not season_year_id or not cur_season_id then
    return nil
  end
  if not LogicSeasonCycleAward.season_year_detail_info or not LogicSeasonCycleAward.season_year_detail_info[season_year_id] then
    return nil
  end
  local rewardCollectList = {}
  local icon_collect_pro_list = LogicSeasonCycleAward.season_year_detail_info[season_year_id].icon_collect_pro_list
  if icon_collect_pro_list then
    for medal_id, info in pairs(icon_collect_pro_list) do
      for season_id, iconInfo in pairs(info) do
        if season_id < cur_season_id and iconInfo ~= nil and iconInfo.status == 1 and iconInfo.fin_reason == "icon" then
          table.insert(rewardCollectList, {icon_id = medal_id, season_id = season_id})
        end
      end
    end
  end
  local yearCollectList = {}
  local year_reward_list = LogicSeasonCycleAward.season_year_detail_info[season_year_id].year_reward_list
  if year_reward_list then
    for icon_id, status in pairs(year_reward_list) do
      if status.reward_status == 1 then
        table.insert(yearCollectList, {icon_id = icon_id})
      end
    end
  end
  if 0 < #rewardCollectList or 0 < #yearCollectList then
    LogicSeasonCycleAward.send_get_all_icon_reward_req(season_year_id, rewardCollectList, yearCollectList)
  end
end
function LogicSeasonCycleAward.GetPreviousUnclaimedReward(cur_season_year_id, cur_season_id)
  log(bWriteLog and "LogicSeasonCycleAward.GetPreviousUnclaimedReward" .. ":" .. tostring(cur_season_year_id) .. ":" .. tostring(cur_season_id))
  if not cur_season_year_id or not cur_season_id then
    log(bWriteLog and "LogicSeasonCycleAward.GetPreviousUnclaimedReward cur_season_year_id cur_season_id is invalid")
    return
  end
  if not LogicSeasonCycleAward.season_year_detail_info or not LogicSeasonCycleAward.season_year_detail_info[cur_season_year_id] then
    log(bWriteLog and "LogicSeasonCycleAward.GetPreviousUnclaimedReward season_year_detail_info is nil")
    return
  end
  local yearInfoList = LogicSeasonCycleAward.season_year_detail_info
  local rewardCollectList = {}
  local yearCollectList = {}
  for yearid, yearInfo in pairs(yearInfoList) do
    local icon_collect_pro_list = yearInfo and yearInfo.icon_collect_pro_list or nil
    if icon_collect_pro_list then
      for medal_id, info in pairs(icon_collect_pro_list) do
        for season_id, iconInfo in pairs(info) do
          if season_id < cur_season_id and iconInfo ~= nil and iconInfo.status == 1 and (iconInfo.fin_reason == "icon" or cur_season_year_id > yearid) then
            table.insert(rewardCollectList, {
              icon_id = medal_id,
              season_id = season_id,
              year_id = yearid
            })
          end
        end
      end
    end
    local year_reward_list = yearInfo and yearInfo.year_reward_list or nil
    if cur_season_year_id > yearid and year_reward_list then
      for icon_id, status in pairs(year_reward_list) do
        if status.reward_status == 1 then
          table.insert(yearCollectList, {icon_id = icon_id, year_id = yearid})
        end
      end
    end
  end
  if 0 < #rewardCollectList or 0 < #yearCollectList then
    LogicSeasonCycleAward.send_get_all_season_prize_reward_req(rewardCollectList, yearCollectList)
  end
end
function LogicSeasonCycleAward.on_ace_imprint_icon_got_notify(medal_id, _)
  if medal_id == nil then
    return
  end
  LogicSeasonCycleAward.send_get_season_year_reward_redpot_req()
end
function LogicSeasonCycleAward.check_has_reward_by_yearid(season_year_id)
  local info = LogicSeasonCycleAward.season_year_detail_info[season_year_id]
  for _, iconInfo in pairs(info.icon_collect_pro_list) do
    for _, seasonIconInfo in pairs(iconInfo) do
      if seasonIconInfo.status == 1 then
        return true
      end
    end
  end
  for _, yearRewardInfo in pairs(info.year_reward_list) do
    if yearRewardInfo.reward_status == 1 then
      return true
    end
  end
  return false
end
function LogicSeasonCycleAward.send_get_season_year_reward_redpot_req()
  local SeasonCycleAwardHandler = require("client.network.Protocol.SeasonCycleAwardHandler")
  SeasonCycleAwardHandler.send_get_season_year_reward_redpot_req()
end
function LogicSeasonCycleAward.on_get_season_year_reward_redpot_rsp(err_code, redpot_flag)
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  local reddotCount = 0
  if err_code == 0 and redpot_flag then
    reddotCount = 1
  end
  season_redpoint_data.SetNewCycleRewardNumRedDot(reddotCount)
end
return LogicSeasonCycleAward