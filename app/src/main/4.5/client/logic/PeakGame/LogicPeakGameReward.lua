local LogicPeakGameReward = {}
local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
function LogicPeakGameReward:DefineAndResetData()
  self.season_info = nil
  self.rankRewardRequestTime = 5
  self.rankLastTime = 0
  self.settlementRewardRequestTime = 5
  self.settlementLastTime = 0
end
function LogicPeakGameReward:OnInitialize()
end
function LogicPeakGameReward:RegistEvents()
end
function LogicPeakGameReward:OnLogin(bReLogin)
end
function LogicPeakGameReward:OnLogOut()
end
function LogicPeakGameReward:OnPreSwitchGameStatus(preState, nextState)
end
function LogicPeakGameReward:OnPostSwitchGameStatus(preState, nextState)
end
function LogicPeakGameReward:GetShowRewardCfg()
  log(bWriteLog and "LogicPeakGameReward:GetShowRewardCfg")
  if not self.rewardList then
    return
  end
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  local curSeasonID = LogicPeakGame:GetCurSeasonId()
  if not self.season_info or self.season_info.task_list == nil or not next(self.season_info.task_list) then
    log(bWriteLog and "LogicPeakGameReward:GetShowRewardCfg season_info is invalid")
    local cfg = CDataTable.GetTableDataByFilter("PeakGameBigSegReward", "SeasonID", curSeasonID, "SortID", 1)
    local math = require("math")
    local minReward = math.huge
    for k, v in pairs(self.rewardList) do
      minReward = math.min(minReward, k)
    end
    local reward = {}
    if cfg then
      local Condition1_Param = cfg.Condition1_Param
      local Condition1_Desc = cfg.Condition1_Desc
      reward = {
        Reward1_ItemID = self.rewardList[minReward].prize_items[1].item_id,
        Reward1_Cnt = self.rewardList[minReward].prize_items[1].num,
        Status = 0,
        Condition1_Desc = Condition1_Desc,
              }
    end
    return reward
  end
  local task_list = self.season_info.task_list
  local awardList = {}
  for ID, value in pairs(task_list) do
    local cfg = CDataTable.GetTableData("PeakGameBigSegReward", ID)
    local reward = self.rewardList[ID]
    if not reward then
      local arrayItemData = {}
      for k, v in pairs(self.rewardList) do
        local data = {
          SortID = k,
          status = v.status,
          min_score = v.min_score,
          prize_items = v.prize_items
        }
        table.insert(arrayItemData, data)
      end
      table.sort(arrayItemData, function(a, b)
        return a.SortID < b.SortID
      end)
      reward = arrayItemData[1]
    end
    if reward and cfg then
      local SeasonCardUtil = require("client.logic.season.logic_season_card_util")
      local reward = {
        ID = cfg.ID,
        SeasonID = DataMgr.season_id,
        SortID = cfg.SortID,
        Condition1_Param = cfg.Condition1_Param,
        Condition1_Desc = cfg.Condition1_Desc,
        Reward1_ItemID = reward.prize_items[1].item_id or 0,
        Reward1_Cnt = reward.prize_items[1].num or 0,
        Status = self:GetPeakGameAwardState(cfg.ID).status
      }
      table.insert(awardList, reward)
    end
  end
  if not next(awardList) then
    log(bWriteLog and "LogicPeakGameReward:GetShowRewardCfg awardList is invalid")
    return nil
  end
  table.sort(awardList, function(a, b)
    return a.SortID < b.SortID
  end)
  for i = 1, #awardList do
    if awardList[i] and awardList[i].Status ~= 2 then
      return awardList[i]
    end
  end
  return awardList[#awardList]
end
function LogicPeakGameReward:GetPeakGameAwardState(ID)
  log(bWriteLog and "LogicPeakGameReward:GetPeakGameAwardState ID = " .. tostring(ID))
  if not self.season_info then
    log(bWriteLog and "LogicPeakGameReward:GetPeakGameAwardState season_info is invalid")
    return nil
  end
  local task_list = self.season_info.task_list
  if task_list == nil or not next(task_list) then
    log(bWriteLog and "LogicPeakGameReward:GetPeakGameAwardState task_list is invalid")
    return nil
  end
  local rewardCfg = task_list[ID]
  log_tree("LogicPeakGameReward:GetPeakGameAwardState rewardCfg = ", rewardCfg)
  if not rewardCfg then
    log(bWriteLog and "LogicPeakGameReward:GetPeakGameAwardState rewardCfg is invalid")
    return nil
  end
  return rewardCfg
end
function LogicPeakGameReward:CanTakeAward()
  log(bWriteLog and "LogicPeakGameReward:CanTakeAward")
  if not self.season_info then
    log(bWriteLog and "LogicPeakGameReward:CanTakeAward season_info is invalid")
    return false
  end
  for i, v in pairs(self.season_info.task_list) do
    if v.status == 1 then
      log_tree("LogicPeakGameReward:CanTakeAward task = ", v)
      return true
    end
  end
  return false
end
function LogicPeakGameReward:ReqPeakGameSeasonInfo()
  log(bWriteLog and "LogicPeakGameReward:ReqPeakGameSeasonInfo")
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameReward:ReqPeakGameSeasonInfo not open")
    return
  end
  local PeakGameHandler = require("client.network.Protocol.PeakGameHandler")
  PeakGameHandler.send_get_peakgame_season_info_req()
end
function LogicPeakGameReward:OnGetPeakGameSeasonInfo(season_info)
  log(bWriteLog and "LogicPeakGameReward:OnGetPeakGameSeasonInfo")
  if not season_info then
    log(bWriteLog and "LogicPeakGameReward:OnGetPeakGameSeasonInfo no season_info")
    return
  end
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameReward:OnGetPeakGameSeasonInfo not open")
    return
  end
  self.  EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_GET_PEAKGAME_SEASON_INFO)
end
function LogicPeakGameReward:ReqPeakGameSegmentPrize(ID)
  log(bWriteLog and "LogicPeakGameReward:ReqPeakGameSegmentPrize ID = " .. tostring(ID))
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameReward:ReqPeakGameSegmentAllPrize not open")
    return
  end
  local PeakGameHandler = require("client.network.Protocol.PeakGameHandler")
  PeakGameHandler.send_take_peakgame_segment_prize_req(ID)
end
function LogicPeakGameReward:OnGetPeakGameSegmentPrize(ID)
  log(bWriteLog and "LogicPeakGameReward:OnGetPeakGameSegmentPrize ID = " .. tostring(ID))
  local arrayItemData = {}
  local cfg = self.rewardList[ID]
  if cfg and next(cfg) then
    for _, v in pairs(cfg.prize_items) do
      if v.item_id > 0 then
        local get_valid_hours
        local SeasonCardUtil = require("client.logic.season.logic_season_card_util")
        if SeasonCardUtil.GetItemValidHours(v.item_id, true) then
          get_valid_hours = SeasonCardUtil.GetItemValidHours(v.item_id, true)
        end
        local data = {
          count = v.num,
          res_id = v.item_id,
          valid_hours = get_valid_hours
        }
        table.insert(arrayItemData, data)
      end
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
    local LogicPeakGameReward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameReward)
    LogicPeakGameReward:ReqPeakGameSeasonInfo()
  else
    log(bWriteLog and "LogicPeakGameReward:OnGetPeakGameSegmentPrize no cfg")
  end
end
function LogicPeakGameReward:ReqPeakGameSegmentAllPrize()
  log(bWriteLog and "LogicPeakGameReward:ReqPeakGameSegmentAllPrize")
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameReward:ReqPeakGameSegmentAllPrize not open")
    return
  end
  local PeakGameHandler = require("client.network.Protocol.PeakGameHandler")
  PeakGameHandler.send_take_peakgame_segment_prize_all_req()
end
function LogicPeakGameReward:OnGetPeakGameSegmentAllPrice(awards, invoke_type)
  log(bWriteLog and "LogicPeakGameReward:OnGetPeakGameSegmentAllPrice")
  local item_map = {}
  for _, v in pairs(awards) do
    self:AddOneItem(item_map, {
      res_id = v.resid,
      count = v.count,
      valid_hours = v.valid_hours
    })
  end
  local awards_list = {}
  for _, value in pairs(item_map) do
    if not value.valid_hours or value.valid_hours <= 0 then
      local SeasonCardUtil = require("client.logic.season.logic_season_card_util")
      value.valid_hours = SeasonCardUtil.GetItemValidHours(value.res_id, true) or 0
    end
    table.insert(awards_list, value)
  end
  table.sort(awards_list, function(itemA, itemB)
    local itemCfgA = CDataTable.GetTableData("Item", itemA.res_id)
    local itemCfgB = CDataTable.GetTableData("Item", itemB.res_id)
    if not itemCfgA or not itemCfgB then
      return false
    end
    if itemCfgA.ItemQuality ~= itemCfgB.ItemQuality then
      return itemCfgA.ItemQuality > itemCfgB.ItemQuality
    end
    return false
  end)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(awards_list)
  self:ReqPeakGameSeasonInfo()
end
function LogicPeakGameReward:ReqPeakTierRewardList()
  log(bWriteLog and "LogicPeakGameReward:ReqPeakTierRewardList")
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameReward:ReqPeakTierRewardList not open")
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if nowTime - self.rankLastTime < self.rankRewardRequestTime then
    EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_TIRE_REWARD_LIST_RSP)
  else
    self.rankLastTime = nowTime
    local PeakGameHandler = require("client.network.Protocol.PeakGameHandler")
    local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
    local curZoneID = LogicPeakGameUtil.GetCurSelectZoneId()
    PeakGameHandler.send_get_peakgame_prize_info_req(PeakGameConfig.RewardType.RankRewards, curZoneID, PeakGameConfig.BattleType.Squad)
  end
end
function LogicPeakGameReward:OnGetPeakTierRewardList(rewardList)
  log(bWriteLog and "LogicPeakGameReward:OnGetPeakTierRewardList")
  if not rewardList then
    log(bWriteLog and "LogicPeakGameReward:OnGetPeakTierRewardList no rewardList")
    return
  end
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameReward:OnGetPeakTierRewardList not open")
    return
  end
  self.  EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_TIRE_REWARD_LIST_RSP)
end
function LogicPeakGameReward:ReqEndRewardList()
  log(bWriteLog and "LogicPeakGameReward:ReqEndRewardList")
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameReward:ReqEndRewardList not open")
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if nowTime - self.settlementLastTime < self.settlementRewardRequestTime then
    log(bWriteLog and "self.settlementLastTime < ")
    EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_SEASON_GET_END_AWARD_ITEMS)
  else
    self.settlementLastTime = nowTime
    local PeakGameHandler = require("client.network.Protocol.PeakGameHandler")
    local curZoneID = LogicPeakGameUtil.GetCurSelectZoneId()
    PeakGameHandler.send_get_peakgame_prize_info_req(PeakGameConfig.RewardType.SettlementReward, curZoneID, PeakGameConfig.BattleType.Squad)
  end
end
function LogicPeakGameReward:OnGetEndRewardList(endRewardList)
  log(bWriteLog and "LogicPeakGameReward:OnGetEndRewardList")
  if not endRewardList then
    log(bWriteLog and "LogicPeakGameReward:OnGetEndRewardList no rewardList")
    return
  end
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameReward:OnGetEndRewardList not open")
    return
  end
  self.  EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_SEASON_GET_END_AWARD_ITEMS)
end
function LogicPeakGameReward:AddOneItem(mapItemData, itemData)
  log(bWriteLog and "LogicPeakGameReward:AddOneItem mapItemData: " .. tostring(mapItemData) .. " itemData: " .. tostring(itemData))
  if not mapItemData or not itemData then
    return
  end
  itemData.valid_hours = itemData.valid_hours or 0
  local has = mapItemData[itemData.res_id]
  if has and has.valid_hours == itemData.valid_hours then
    has.count = has.count + itemData.count
  else
    mapItemData[itemData.res_id] = itemData
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicPeakGameReward = class(CModuleBase, nil, LogicPeakGameReward)
return CLogicPeakGameReward