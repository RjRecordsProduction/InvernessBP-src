local DoubleCardSystem = {
  Enum_Show_Panel_Tip = {
    GoldAndEXP = 1,
    Shield = 2,
    ActivityBuff = 3
  }
}
function DoubleCardSystem.InitData(double_card)
  local logic_wardrobe_card = require("client.slua.logic.wardrobe.logic_wardrobe_card")
  logic_wardrobe_card:InitWeaponExpCard(double_card)
  if not double_card then
    DataMgr.doubleCard.expCardRatePlus = 0
    DataMgr.doubleCard.expCardExpireTime = 0
    DataMgr.doubleCard.goldCardRatePlus = 0
    DataMgr.doubleCard.goldCardExpireTime = 0
    return
  end
  DataMgr.doubleCard.expCardRatePlus = double_card.exp_card_rate_plus or 0
  DataMgr.doubleCard.expCardExpireTime = double_card.exp_card_expire_time or 0
  DataMgr.doubleCard.goldCardRatePlus = double_card.gold_card_rate_plus or 0
  DataMgr.doubleCard.goldCardExpireTime = double_card.gold_card_expire_time or 0
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_SYNC_DOUBLECARD_STATE)
end
function DoubleCardSystem.OnSyncDoubleCardInfo(cardInfo)
  DoubleCardSystem.InitData(cardInfo)
end
function DoubleCardSystem.OnSyncRatingCardInfo(ratingShieldData)
  local TableUtil = require("common.table_util")
  DataMgr.ratingShieldExpireTime = TableUtil.GetTableValue(ratingShieldData, "time_card", "expire_time") or 0
  DataMgr.ratingShieldCardID = 0
  if TableUtil.GetTableValue(ratingShieldData, "times_card", "is_effect") then
    DataMgr.ratingShieldCardID = TableUtil.GetTableValue(ratingShieldData, "times_card", "card_instid") or 0
  end
  DoubleCardSystem.UpdateSeasonRatingShieldCard(ratingShieldData)
  local LogicAddScordCard = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicAddScordCard)
  LogicAddScordCard:OnSyncAddScoreCardInfo(ratingShieldData)
  local logic_wardrobe_card = require("client.slua.logic.wardrobe.logic_wardrobe_card")
  logic_wardrobe_card:InitArenaTimesCard(ratingShieldData)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_SYNC_DOUBLECARD_STATE)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_SYNC_TIMECARD_STATE)
end
function DoubleCardSystem.HasGoldRate()
  local TimeUtil = require("client.common.time_util")
  return DataMgr.doubleCard.goldCardExpireTime ~= 0 and DataMgr.doubleCard.goldCardExpireTime > TimeUtil.GetServerTimeInSec()
end
function DoubleCardSystem.HasExpRate()
  local TimeUtil = require("client.common.time_util")
  return DataMgr.doubleCard.expCardExpireTime ~= 0 and DataMgr.doubleCard.expCardExpireTime > TimeUtil.GetServerTimeInSec()
end
function DoubleCardSystem.HasTimeRatingShield()
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  if not serverTime or not DataMgr.ratingShieldExpireTime then
    return false
  end
  return DataMgr.ratingShieldExpireTime ~= 0 and serverTime < DataMgr.ratingShieldExpireTime
end
function DoubleCardSystem.HasTimesRatingShield()
  local wearRatindShieldCard = DataMgr.ratingShieldCardID and DataMgr.ratingShieldCardID ~= 0
  local wearSeasonRatindShieldCard = DataMgr.seasonRatingShieldCardID and DataMgr.seasonRatingShieldCardID ~= 0
  local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local ret = false
  if wearRatindShieldCard then
    ret = 0 < wardrobeData:GetItemCountByInsID(DataMgr.ratingShieldCardID)
  end
  if wearSeasonRatindShieldCard then
    ret = ret or 0 < DoubleCardSystem.GetSeasonRatingShieldCardNum()
  end
  return ret
end
function DoubleCardSystem.UpdateSeasonRatingShieldCard(ratingShieldData)
  local TableUtil = require("common.table_util")
  DataMgr.seasonRatingShieldCardID = 0
  if TableUtil.GetTableValue(ratingShieldData, "season_times_card", "is_effect") then
    DataMgr.seasonRatingShieldCardID = TableUtil.GetTableValue(ratingShieldData, "season_times_card", "card_instid") or 0
  end
end
function DoubleCardSystem.GetAllRatingShieldCardNum()
  local cardNum = 0
  if DataMgr.ratingShieldCardID and DataMgr.ratingShieldCardID ~= 0 then
    local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
    cardNum = cardNum + wardrobeData:GetItemCountByInsID(DataMgr.ratingShieldCardID)
  end
  cardNum = cardNum + DoubleCardSystem.GetSeasonRatingShieldCardNum()
  return cardNum
end
function DoubleCardSystem.GetSeasonRatingShieldCardNum()
  local cardNum = 0
  local seasonRatingShieldCardID = DataMgr.seasonRatingShieldCardID
  if seasonRatingShieldCardID and seasonRatingShieldCardID ~= 0 then
    local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobeData:GetValidHallDepotItemDataByInsID(seasonRatingShieldCardID)
    if itemData then
      cardNum = itemData.count or 0
    end
  end
  return cardNum
end
function DoubleCardSystem.IsCanUse(itemCfg)
  if itemCfg == nil then
    return true
  end
  local itemEffectsCfg = CDataTable.GetTableData("ItemEffects", itemCfg.ItemID)
  if itemEffectsCfg == nil then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  if itemCfg.ItemType == ENUM_ITEM_TYPE.Item_Card and itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Exp_Card then
    local plus = tonumber(itemEffectsCfg.Param2)
    if DataMgr.doubleCard.expCardExpireTime ~= 0 and serverTime < DataMgr.doubleCard.expCardExpireTime and plus ~= DataMgr.doubleCard.expCardRatePlus then
      return false
    end
  elseif itemCfg.ItemType == ENUM_ITEM_TYPE.Item_Card and itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Gold_Card then
    local plus = tonumber(itemEffectsCfg.Param2)
    if DataMgr.doubleCard.goldCardExpireTime ~= 0 and serverTime < DataMgr.doubleCard.goldCardExpireTime and plus ~= DataMgr.doubleCard.goldCardRatePlus then
      return false
    end
  end
  return true
end
function DoubleCardSystem.NotifyHideDoubleCardPanel()
  EventSystem:postEvent(EVENTTYPE_DOUBLECARD, EVENTID_DOUBLECARD_PANEL_CLOSED)
end
return DoubleCardSystem