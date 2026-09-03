local logic_player_return_rank = {
  SystemInfo = {},
  PlayerInfo = {
    AwardInfo = {},
    HistoryHighestSegmentScore = -1,
    CurrentHighestSegmentScore = -1,
    CurrentGoalIndex = -1,
    StartTimestamp = 0
  },
  LastPlayerInfo = nil,
  CONST = {
    ERR_CODE_SUCCESS = 0,
    MAX_RANK_GOAL_NUM = 5,
    MAX_RANK_SCORE = 9999999,
    AWARD_STATUS_NOT_VALID = 0,
    AWARD_STATUS_CAN_GET = 1,
    AWARD_STATUS_GOT = 2
  }
}
local CalGoalIndex = function()
  for i = 1, #logic_player_return_rank.PlayerInfo.AwardInfo do
    if logic_player_return_rank.PlayerInfo.AwardInfo[i].AwardStatus == logic_player_return_rank.CONST.AWARD_STATUS_NOT_VALID then
      logic_player_return_rank.PlayerInfo.CurrentGoalIndex = i
      return
    end
  end
  logic_player_return_rank.PlayerInfo.CurrentGoalIndex = #logic_player_return_rank.PlayerInfo.AwardInfo + 1
end
local CalCurrentHighestSegmentScore = function()
  logic_player_return_rank.PlayerInfo.CurrentHighestSegmentScore = -1
  log_tree(bWriteLog and "CalCurrentHighestSegmentScore segment_rating", DataMgr.roleData.segment_rating)
  for _, region_rating in pairs(DataMgr.roleData.segment_rating) do
    for _, mode_rating in pairs(region_rating) do
      logic_player_return_rank.PlayerInfo.CurrentHighestSegmentScore = math.max(logic_player_return_rank.PlayerInfo.CurrentHighestSegmentScore, mode_rating)
    end
  end
end
function logic_player_return_rank.SaveCurrentPlayerInfo()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TableUtil = require("common.table_util")
  PlayerPrefsSystem.SaveTableToFile_N(TableUtil.CopyTable(logic_player_return_rank.PlayerInfo), PlayerPrefsSystem.ePlayerPrefsType.PlayerReturnRank)
end
function logic_player_return_rank.LoadLastPlayerInfo()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  logic_player_return_rank.LastPlayerInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.PlayerReturnRank)
  if logic_player_return_rank.LastPlayerInfo and DataMgr.roleData.back_user_data and logic_player_return_rank.LastPlayerInfo.StartTimestamp ~= DataMgr.roleData.back_user_data.rejoin_start_time then
    logic_player_return_rank.LastPlayerInfo = logic_player_return_rank.PlayerInfo
  end
end
function logic_player_return_rank.GetHighestRankScore()
  CalCurrentHighestSegmentScore()
  return logic_player_return_rank.PlayerInfo.CurrentHighestSegmentScore
end
function logic_player_return_rank.CanGetAward(index)
  local TableUtil = require("common.table_util")
  local AwardStatus = TableUtil.GetTableValue(logic_player_return_rank.PlayerInfo.AwardInfo, index, "AwardStatus")
  if AwardStatus and AwardStatus == logic_player_return_rank.CONST.AWARD_STATUS_CAN_GET then
    return true
  end
  return false
end
function logic_player_return_rank.IsAwardGroup(index)
  if not logic_player_return_rank.SystemInfo[index] then
    log_error_format("martinhtma logic_player_return_rank.IsAwardGroup index(%s) not exist!", index)
    return false
  end
  if #logic_player_return_rank.SystemInfo[index].AwardList > 1 then
    return true
  end
  return false
end
function logic_player_return_rank.GetAward(index)
  local TableUtil = require("common.table_util")
  local AwardStatus = TableUtil.GetTableValue(logic_player_return_rank.PlayerInfo.AwardInfo, index, "AwardStatus")
  if AwardStatus and AwardStatus == logic_player_return_rank.CONST.AWARD_STATUS_CAN_GET then
    logic_player_return_rank.send_backuser_segment_goal_reward_req(index)
  end
end
function logic_player_return_rank.CheckRedDot()
  for _, v in pairs(logic_player_return_rank.PlayerInfo.AwardInfo) do
    if v.AwardStatus == logic_player_return_rank.CONST.AWARD_STATUS_CAN_GET then
      return true
    end
  end
  return false
end
function logic_player_return_rank.send_backuser_get_segment_goal_req()
  local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
  PlayerReturnHandler.send_backuser_get_segment_goal_req()
end
function logic_player_return_rank.on_backuser_get_segment_goal_res(res, goal_info, max_rating, config)
  if res ~= logic_player_return_rank.CONST.ERR_CODE_SUCCESS then
    ShowNotice(res)
    return
  end
  logic_player_return_rank.PlayerInfo.HistoryHighestSegmentScore = max_rating or 0
  logic_player_return_rank.SystemInfo = {}
  logic_player_return_rank.PlayerInfo.AwardInfo = {}
  if config then
    for i, v in pairs(config) do
      if i > logic_player_return_rank.CONST.MAX_RANK_GOAL_NUM then
        break
      end
      local AwardList = {}
      for ItemID, ItemInfo in pairs(v.item_list) do
        table.insert(AwardList, {
          ItemID = ItemID,
          Num = ItemInfo.num,
          ValidHours = ItemInfo.valid_hours
        })
      end
      local RankInfo = FuncUtil.GetRankTableData(v.segment_id)
      if not RankInfo then
        log_error_format("logic_player_return_rank:on_backuser_get_segment_goal_res segment_id(%s) not exist! index(%s)", v.segment_id, i)
        return
      end
      logic_player_return_rank.SystemInfo[i] = {
        SegmentID = v.segment_id,
        SegmentScore = RankInfo.MinIntegral,
        AwardGroupIconPath = v.icon,
              }
    end
  end
  if goal_info then
    logic_player_return_rank.PlayerInfo.CurrentGoalIndex = -1
    for i, v in pairs(goal_info) do
      logic_player_return_rank.PlayerInfo.AwardInfo[i] = {AwardStatus = v}
    end
  end
  if DataMgr.roleData.back_user_data then
    logic_player_return_rank.PlayerInfo.StartTimestamp = DataMgr.roleData.back_user_data.rejoin_start_time
  end
  CalGoalIndex()
  CalCurrentHighestSegmentScore()
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_RANK_CHANGE)
end
function logic_player_return_rank.send_backuser_segment_goal_reward_req(index)
  local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
  PlayerReturnHandler.send_backuser_segment_goal_reward_req(index)
end
function logic_player_return_rank.on_backuser_segment_goal_reward_res(res, index)
  if res ~= logic_player_return_rank.CONST.ERR_CODE_SUCCESS then
    ShowNotice(res)
    return
  end
  if not logic_player_return_rank.PlayerInfo.AwardInfo[index] then
    log_error_format("logic_player_return_rank.on_backuser_segment_goal_reward_res index(%s) not exist!", index)
    return
  end
  if not logic_player_return_rank.SystemInfo[index] then
    log_error_format("logic_player_return_rank.on_backuser_segment_goal_reward_res index(%s) not exist!", index)
    return
  end
  logic_player_return_rank.PlayerInfo.AwardInfo[index].AwardStatus = logic_player_return_rank.CONST.AWARD_STATUS_GOT
  local ItemIDList = {}
  for _, v in pairs(logic_player_return_rank.SystemInfo[index].AwardList) do
    table.insert(ItemIDList, {
      res_id = v.ItemID,
      count = v.Num,
      expire_ts = v.ValidHours
    })
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(ItemIDList)
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_LOBBY_COME_BACK_RANK_GOAL_AWARD, index)
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_RANK_CHANGE)
end
return logic_player_return_rank