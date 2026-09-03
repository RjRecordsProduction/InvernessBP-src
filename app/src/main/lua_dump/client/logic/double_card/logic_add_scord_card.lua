local AddScoreCardSystem = {}
local UseCardTypeMap = {DefaultUse = 0, PutOnUse = 1}
local ScoreTypeMap = {
  [3] = 20,
  [4] = 10
}
function AddScoreCardSystem:OnInitialize()
  AddScoreCardSystem.__super.OnInitialize(self)
  self:InitData()
end
function AddScoreCardSystem:OnSyncAddScoreCardInfo(ratingCardInfo)
  if not ratingCardInfo then
    log(bWriteLog and "AddScoreCardSystem:OnSyncRatingCardInfo ratingCardInfo is nil")
    return
  end
  if ratingCardInfo.season_add_score_card then
    DataMgr.seasonAddScoreCardInfo = ratingCardInfo.season_add_score_card
  end
  if ratingCardInfo.peakgame_times_card and ratingCardInfo.peakgame_times_card.card_instid then
    DataMgr.seasonPakeGameRatingShieldCardID = ratingCardInfo.peakgame_times_card.card_instid
  end
  if ratingCardInfo.peakgame_add_score_card then
    DataMgr.seasonPakeGameAddScoreCardInfo = ratingCardInfo.peakgame_add_score_card
  end
end
function AddScoreCardSystem:IsPutOnSeasonAddScoreCard(itemResId)
  log(bWriteLog and " AddScoreCardSystem.IsPutOnSeasonAddScoreCard")
  if not itemResId then
    log(bWriteLog and " AddScoreCardSystem.IsPutOnSeasonAddScoreCard no itemResId")
    return false
  end
  for _, scoreTypeList in pairs(self.putOnCardItemList) do
    for _, resId in pairs(scoreTypeList) do
      if tonumber(resId) == tonumber(itemResId) then
        return true
      end
    end
  end
  return false
end
function AddScoreCardSystem:CanPutOnAddScoreCard(resId, insId, itemType, itemSubType)
  log(bWriteLog and " AddScoreCardSystem.IsPutOnAddScoreCardByInsId")
  if not resId or not insId then
    log(bWriteLog and " AddScoreCardSystem.IsPutOnAddScoreCardByInsId no insId")
    return false
  end
  if itemType ~= ENUM_ITEM_TYPE.Item_Card or itemSubType ~= ENUM_ITEM_SUBTYPE.SeasonAddScoreCard then
    log(bWriteLog and string.format("AddScoreCardSystem.CanPutOnAddScoreCard no itemType"))
    return false
  end
  local isPutOnSeasonCard = self:IsPutOnSeasonAddScoreCard(resId)
  if not isPutOnSeasonCard then
    return false
  end
  if not DataMgr.seasonAddScoreCardInfo or not DataMgr.seasonAddScoreCardInfo.put_on_record_list then
    return true
  end
  local scoreCardPutOnList = DataMgr.seasonAddScoreCardInfo.put_on_record_list
  if scoreCardPutOnList[tonumber(insId)] then
    return false
  end
  return true
end
function AddScoreCardSystem:CanPutOnPeakGameAddScoreCard(resId, insId, itemType, itemSubType)
  log(bWriteLog and " AddScoreCardSystem.CanPutOnPeakGameAddScoreCard")
  if not resId or not insId then
    log(bWriteLog and " AddScoreCardSystem.CanPutOnPeakGameAddScoreCard no insId")
    return false
  end
  if itemType ~= ENUM_ITEM_TYPE.Item_Card or itemSubType ~= 2208 then
    log(bWriteLog and string.format("AddScoreCardSystem.CanPutOnPeakGameAddScoreCard no itemType"))
    return false
  end
  local isPutOnSeasonCard = self:IsPutOnSeasonAddScoreCard(resId)
  if not isPutOnSeasonCard then
    return false
  end
  if not DataMgr.seasonPakeGameAddScoreCardInfo or not DataMgr.seasonPakeGameAddScoreCardInfo.put_on_record_list then
    return true
  end
  local scoreCardPutOnList = DataMgr.seasonPakeGameAddScoreCardInfo.put_on_record_list
  if scoreCardPutOnList[tonumber(insId)] then
    return false
  end
  return true
end
function AddScoreCardSystem:IsPutOnAddScoreCardByInsId(insId)
  log(bWriteLog and " AddScoreCardSystem.IsPutOnAddScoreCardByInsId")
  if not insId then
    log(bWriteLog and " AddScoreCardSystem.IsPutOnAddScoreCardByInsId no insId")
    return false
  end
  if not DataMgr.seasonAddScoreCardInfo or not DataMgr.seasonAddScoreCardInfo.put_on_record_list then
    return false
  end
  local scoreCardPutOnList = DataMgr.seasonAddScoreCardInfo.put_on_record_list
  if scoreCardPutOnList[tonumber(insId)] then
    return true
  end
  return false
end
function AddScoreCardSystem:IsPutOnPeakGameAddScoreCardByInsId(insId)
  log(bWriteLog and " AddScoreCardSystem.IsPutOnPeakGameAddScoreCardByInsId")
  if not insId then
    log(bWriteLog and " AddScoreCardSystem.IsPutOnPeakGameAddScoreCardByInsId no insId")
    return false
  end
  if not DataMgr.seasonPakeGameAddScoreCardInfo or not DataMgr.seasonPakeGameAddScoreCardInfo.put_on_record_list then
    return false
  end
  local scoreCardPutOnList = DataMgr.seasonPakeGameAddScoreCardInfo.put_on_record_list
  if scoreCardPutOnList[tonumber(insId)] then
    return true
  end
  if tonumber(DataMgr.seasonPakeGameAddScoreCardInfo.card_instid) == tonumber(insId) then
    return true
  end
  return false
end
function AddScoreCardSystem:IsDefaultUseSeasonAddScoreCard(itemResId)
  log(bWriteLog and " AddScoreCardSystem.IsDefaultUseSeasonAddScoreCard")
  if not itemResId then
    log(bWriteLog and " AddScoreCardSystem.IsDefaultUseSeasonAddScoreCard no itemResId")
    return false
  end
  for _, scoreTypeList in pairs(self.defaultUseCardItemList) do
    for _, resId in pairs(scoreTypeList) do
      if tonumber(resId) == tonumber(itemResId) then
        return true
      end
    end
  end
  return false
end
function AddScoreCardSystem:HasValidSeasonAddScoreCard(cardAddSore)
  local count = self:GetScoreCardNumByScoreType(cardAddSore)
  return 0 < count
end
function AddScoreCardSystem:GetScoreCardNumByScoreType(score)
  if not score then
    log(bWriteLog and " AddScoreCardSystem:GetScoreCardNumByScoreType score is nil")
    return
  end
  log(bWriteLog and " AddScoreCardSystem:GetScoreCardNumByScoreType score is " .. tostring(score))
  local count = self:GetDefaultUseSCardNumByScore(score)
  log(bWriteLog and " AddScoreCardSystem:GetScoreCardNumByScoreType default use num is " .. tostring(count))
  if not DataMgr.seasonAddScoreCardInfo or not DataMgr.seasonAddScoreCardInfo.put_on_record_list then
    return count
  end
  local scoreCardPutOnList = DataMgr.seasonAddScoreCardInfo.put_on_record_list
  if type(scoreCardPutOnList) ~= "table" then
    return count
  end
  local SeasonCardsInfo = CDataTable.GetTable("SeasonCardsConfig")
  for insId, _ in pairs(scoreCardPutOnList) do
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetValidHallDepotItemDataByInsID(insId)
    if itemData and itemData.count and itemData.count > 0 then
      local itemId = itemData.resID or 0
      local cardCfg = SeasonCardsInfo[itemId]
      if cardCfg and cardCfg.Score == score then
        count = count + itemData.count
      end
    end
  end
  log(bWriteLog and " AddScoreCardSystem:GetScoreCardNumByScoreType num is " .. tostring(count))
  return count
end
function AddScoreCardSystem:InitData()
  log(bWriteLog and "AddScoreCardSystem InitData")
  self.defaultUseCardItemList = self:SetAddScoreCardItemList(self.defaultUseCardItemList, UseCardTypeMap.DefaultUse) or {}
  self.putOnCardItemList = self:SetAddScoreCardItemList(self.putOnCardItemList, UseCardTypeMap.PutOnUse) or {}
end
function AddScoreCardSystem:SetAddScoreCardItemList(cardItemList, useCardType)
  if not useCardType then
    log(bWriteLog and "AddScoreCardSystem GetDefaultUseCardItems useCardType is nil")
    return
  end
  log(bWriteLog and "AddScoreCardSystem GetDefaultUseCardItems useCardType is" .. tostring(useCardType))
  cardItemList = cardItemList or {}
  local SeasonCardsInfo = CDataTable.GetTable("SeasonCardsConfig")
  if not SeasonCardsInfo then
    log(bWriteLog and "AddScoreCardSystem GetDefaultUseCardItems no config")
    return
  end
  for resID, cardCfg in pairs(SeasonCardsInfo) do
    if ScoreTypeMap[cardCfg.CardType] and cardCfg.EffectiveType == useCardType and cardCfg.Score and cardCfg.Score ~= 0 then
      if not cardItemList[cardCfg.Score or 0] then
        cardItemList[cardCfg.Score] = {}
      end
      table.insert(cardItemList[cardCfg.Score], resID)
    end
  end
  return cardItemList
end
function AddScoreCardSystem:HasValidDefaultUseScoreCard()
  log(bWriteLog and " AddScoreCardSystem:HasDefaultUseSeasonAddScoreCard")
  local count = 0
  for _, score in pairs(ScoreTypeMap) do
    count = count + self:GetDefaultUseSCardNumByScore(score)
  end
  return 0 < count
end
function AddScoreCardSystem:GetDefaultUseSCardNumByScore(score)
  log(bWriteLog and " AddScoreCardSystem:GetDefaultUseSCardNumByScore")
  if not score then
    log(bWriteLog and " AddScoreCardSystem:GetDefaultUseSCardNumByScore invalid score")
    return 0
  end
  local cardList = self.defaultUseCardItemList
  if not (cardList and cardList[score]) or type(cardList[score]) ~= "table" then
    log(bWriteLog and " AddScoreCardSystem:GetDefaultUseSCardNumByScore invalid cardList")
    return 0
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local count = 0
  local scoreCardList = cardList[score]
  for _, resId in pairs(scoreCardList) do
    local itemData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(tonumber(resId))
    if itemData and itemData.count then
      count = count + itemData.count
    end
  end
  return count
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CAddScoreCardSystem = class(CModuleBase, nil, AddScoreCardSystem)
return CAddScoreCardSystem