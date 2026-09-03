local CardCollectionDataModule = {}
local CardCollectionUtil = require("GameLua.Mod.Lobby.Base.CardCollection.logic.CardCollectionUtil")
local CardCollectionSeasonHandler = require("GameLua.Mod.Lobby.Split.CardCollection.ModCardCollectionSeasonHandler")
local CardCollectionUIConfig = require("GameLua.Mod.Lobby.Base.CardCollection.logic.CardCollectionSeasonUIConfig")
local popupType = CardCollectionUIConfig.ECardCollectionPopupType
local ERegion = {
  JAPAN = 1,
  KOREA = 2,
  BLUEHOLE = 3,
  DEFAULT = 1000
}
local CardCollectionRegionSetMap = {
  [ERegion.JAPAN] = "CardCollectionSetConfigJPKR",
  [ERegion.KOREA] = "CardCollectionSetConfigJPKR",
  [ERegion.BLUEHOLE] = "CardCollectionSetConfigBlueHole",
  [ERegion.DEFAULT] = "CardCollectionSetConfig"
}
local CardCollectionRegionScoreAwardMap = {
  [ERegion.JAPAN] = "CardCollectionScoreAwardJPKR",
  [ERegion.KOREA] = "CardCollectionScoreAwardJPKR",
  [ERegion.BLUEHOLE] = "CardCollectionScoreAwardBlueHole",
  [ERegion.DEFAULT] = "CardCollectionScoreAward"
}
local CardCollectionRegionCollectAwardMap = {
  [ERegion.JAPAN] = "CardCollectionCollectAwardJPKR",
  [ERegion.KOREA] = "CardCollectionCollectAwardJPKR",
  [ERegion.BLUEHOLE] = "CardCollectionCollectAwardBlueHole",
  [ERegion.DEFAULT] = "CardCollectionCollectAward"
}
local CardCollectionPackConfigMap = {
  [ERegion.JAPAN] = "CardCollectionPackConfigJPKR",
  [ERegion.KOREA] = "CardCollectionPackConfigJPKR",
  [ERegion.BLUEHOLE] = "CardCollectionPackConfigBlueHole",
  [ERegion.DEFAULT] = "CardCollectionPackConfig"
}
local CardCollectionRegionSeasonMap = {
  [ERegion.JAPAN] = "CardCollectionSeasonConfig",
  [ERegion.KOREA] = "CardCollectionSeasonConfig",
  [ERegion.BLUEHOLE] = "CardCollectionSeasonConfigBlueHole",
  [ERegion.DEFAULT] = "CardCollectionSeasonConfig"
}
function CardCollectionDataModule:DefineAndResetData()
  self.season_data = nil
  self.last_season_data = nil
  self.set_data = {}
  self.summary_data = nil
  self.server_season_id = nil
  self.regionConfig = {
    Set = CardCollectionRegionSetMap[ERegion[Client.GetPublishRegion()] or 1000],
    ScoreAward = CardCollectionRegionScoreAwardMap[ERegion[Client.GetPublishRegion()] or 1000],
    CollectAward = CardCollectionRegionCollectAwardMap[ERegion[Client.GetPublishRegion()] or 1000],
    Pack = CardCollectionPackConfigMap[ERegion[Client.GetPublishRegion()] or 1000],
    Season = CardCollectionRegionSeasonMap[ERegion[Client.GetPublishRegion()] or 1000]
  }
  self._specialCardConfigCache = nil
  self.PendingClickOpenCard = nil
  self.card_depot_data = nil
  self.subwayOwnedCache = nil
end
function CardCollectionDataModule:_GetTodayDateStr()
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.OSDate("!%Y%m%d", TimeUtil.GetServerTimeInSec())
end
function CardCollectionDataModule:_EnsureSeasonData()
  if not self.season_data then
    log(bWriteLog and "[CardCollection] CardCollectionDataModule:_EnsureSeasonData not season data")
    CardCollectionSeasonHandler.send_card_collect_query_season_data_req(self:GetSeasonIDByClientVersion(), false)
    return false
  end
  return true
end
function CardCollectionDataModule:_GetSeasonSetTable()
  local season_id = self:GetSeasonIDByClientVersion()
  return CDataTable.GetSplitTableByFilter("Lobby", "CardCollection", self.regionConfig.Set, "SeasonID", season_id)
end
function CardCollectionDataModule:_IterateSeasonCards(callback)
  local seasonData = self.season_data
  for _, setData in pairs(seasonData) do
    if type(setData) == "table" then
      local cards = setData.cards
      for cardID, cardInfo in pairs(cards) do
        local cardConfig = CDataTable.GetTableData("CardCollectionCardConfig", cardID)
        if cardConfig then
          callback(cardID, cardInfo, cardConfig)
        end
      end
    end
  end
end
function CardCollectionDataModule:_IsInTimeWindow(cfg, now)
  local TimeUtil = require("client.common.time_util")
  if cfg.StartTime and cfg.StartTime ~= "" then
    local startTime = TimeUtil.TimeStringToUnixstamp(cfg.StartTime)
    if startTime and 0 < startTime and now < startTime then
      return false
    end
  end
  if cfg.EndTime and cfg.EndTime ~= "" then
    local endTime = TimeUtil.TimeStringToUnixstamp(cfg.EndTime)
    if endTime and 0 < endTime and now > endTime then
      return false
    end
  end
  return true
end
function CardCollectionDataModule:GetCardShowDataByCardId(cardId)
  local cardData = {
    cardId = cardId,
    show_data = CDataTable.GetTableData("CardCollectionCardConfig", cardId)
  }
  return cardData
end
function CardCollectionDataModule:_BuildCardListWithSpecialGroup(tableData, cardsOwned, extraDataFn)
  local specialIdMap = {}
  local normalCards = {}
  local cardInfo, cardItem, specialID, group, grade, isOwned
  for _, v in pairs(tableData) do
    cardInfo = cardsOwned[v.CardID] or {}
    cardItem = {
      show_data = v,
      count = cardInfo.count or 0,
      first_ts = cardInfo.first_ts or 0,
      seq = cardInfo.seq or 0
    }
    if extraDataFn then
      local extra = extraDataFn(v)
      if extra then
        for k, val in pairs(extra) do
          cardItem[k] = val
        end
      end
    end
    specialID = v.SpecialID or 0
    if specialID == 0 then
      table.insert(normalCards, cardItem)
    else
      if not specialIdMap[specialID] then
        specialIdMap[specialID] = {owned = nil, max = nil}
      end
      group = specialIdMap[specialID]
      grade = v.Grade or 0
      isOwned = cardItem.count > 0
      if not group.max or grade > (group.max.show_data.Grade or 0) then
        group.max = cardItem
      end
      if isOwned and (not group.owned or grade > (group.owned.show_data.Grade or 0)) then
        group.owned = cardItem
      end
    end
  end
  return normalCards, specialIdMap
end
function CardCollectionDataModule:OnInitialize()
end
function CardCollectionDataModule:RegistEvents()
end
function CardCollectionDataModule:OnLogin(bReLogin)
end
function CardCollectionDataModule:OnLogOut()
end
function CardCollectionDataModule:OnPreSwitchGameStatus(preState, nextState)
  self:DefineAndResetData()
end
function CardCollectionDataModule:OnPostSwitchGameStatus(preState, nextState)
end
function CardCollectionDataModule:GetSeasonData()
  return self.season_data
end
function CardCollectionDataModule:GetLastSeasonData()
  return self.last_season_data
end
function CardCollectionDataModule:GetSetData(setID)
  return self.set_data[setID]
end
function CardCollectionDataModule:GetAllSetData()
  return self.set_data
end
function CardCollectionDataModule:SetSetData(setID, data)
  self.set_data = self.set_data or {}
  self.set_data[setID] = data
end
function CardCollectionDataModule:ClearAllSetData()
  self.set_data = {}
end
function CardCollectionDataModule:GetSummaryData()
  return self.summary_data
end
function CardCollectionDataModule:GetServerSeasonID()
  return self.server_season_id
end
function CardCollectionDataModule:GetRegionConfig()
  return self.regionConfig
end
function CardCollectionDataModule:GetSpecialCardConfig(specialID)
  if not specialID or specialID == 0 then
    return nil
  end
  if not self._specialCardConfigCache then
    self._specialCardConfigCache = CDataTable.GetSplitTable("Lobby", "CardCollection", "SpecialCardConfig") or {}
  end
  return self._specialCardConfigCache[specialID]
end
function CardCollectionDataModule:GetSignAnimPathBySpecialID(specialID)
  local cfg = self:GetSpecialCardConfig(specialID)
  if cfg and cfg.SignAnimPath and cfg.SignAnimPath ~= "" then
    return cfg.SignAnimPath
  end
  return nil
end
function CardCollectionDataModule:GetSignAnimPathByCardID(cardID)
  local cardCfg = CDataTable.GetTableData("CardCollectionCardConfig", cardID)
  if not (cardCfg and cardCfg.SpecialID) or cardCfg.SpecialID == 0 then
    return nil
  end
  return self:GetSignAnimPathBySpecialID(cardCfg.SpecialID)
end
function CardCollectionDataModule:GetSignAnimPathByItemID(itemID)
  local cardCfg = CDataTable.GetTableDataByFilter("CardCollectionCardConfig", "ItemID", itemID)
  if not (cardCfg and cardCfg.SpecialID) or cardCfg.SpecialID == 0 then
    return nil
  end
  return self:GetSignAnimPathBySpecialID(cardCfg.SpecialID)
end
function CardCollectionDataModule:GetCardDepotData()
  return self.card_depot_data
end
function CardCollectionDataModule:GetComposeCardDayLimit()
  if self.card_depot_data then
    return self.card_depot_data.compose_card_day_limit or {}
  end
  return {}
end
function CardCollectionDataModule:SetComposeCardDayLimit(compose_card_day_limit)
  if not self.card_depot_data then
    self.card_depot_data = {}
  end
  self.card_depot_data.compose_card_day_limit = compose_card_day_limit or {}
end
function CardCollectionDataModule:GetPackAlreadyBuyNum(packID)
  local limit = self:GetComposeCardDayLimit()
  return limit[packID] or 0
end
function CardCollectionDataModule:GetIsCanGetDrift()
  if self.card_depot_data then
    return self.card_depot_data.get_bottle_count_today and self.card_depot_data.get_bottle_count_today == 0
  end
  return false
end
function CardCollectionDataModule:GetIsTodayCanDrift()
  if self.card_depot_data then
    return self.card_depot_data.send_bottle_count_today and self.card_depot_data.send_bottle_count_today == 0
  end
  return false
end
function CardCollectionDataModule:SetIsTodayCanDrift(value)
  if not self.card_depot_data then
    self.card_depot_data = {}
  end
  self.card_depot_data.send_bottle_count_today = value and 0 or 1
end
function CardCollectionDataModule:UpdateHistorySetDataByCardID(setID, cardID, delta)
  if not (setID and cardID) or delta == 0 then
    return
  end
  local setData = self.set_data and self.set_data[setID]
  if not setData or type(setData) ~= "table" or not setData.cards then
    return
  end
  local cardInfo = setData.cards[cardID]
  if not cardInfo then
    return
  end
  cardInfo.count = math.max((cardInfo.count or 0) + delta, 0)
end
function CardCollectionDataModule:UpdateHistorySetDataByItemID(itemID, delta)
  if not itemID or delta == 0 then
    return
  end
  local cardConfig = CDataTable.GetTableDataByFilter("CardCollectionCardConfig", "ItemID", itemID)
  if not cardConfig then
    return
  end
  self:UpdateHistorySetDataByCardID(cardConfig.SetID, cardConfig.CardID, delta)
end
function CardCollectionDataModule:DecrementCardCount(setID, cardID)
  if self.season_data and self.season_data[setID] and self.season_data[setID].cards and self.season_data[setID].cards[cardID] then
    self.season_data[setID].cards[cardID].count = self.season_data[setID].cards[cardID].count - 1
  else
    self:UpdateHistorySetDataByCardID(setID, cardID, -1)
  end
end
function CardCollectionDataModule:SetScoreAwardClaimed(segId)
  if self.summary_data and self.summary_data.score_award then
    self.summary_data.score_award[segId] = 1
  end
end
function CardCollectionDataModule:SetCollectAwardClaimed(setId)
  if self.season_data and self.season_data[setId] then
    self.season_data[setId].collect_award = 1
  elseif self.set_data and self.set_data[setId] then
    self.set_data[setId].collect_award = 1
  end
end
function CardCollectionDataModule:GetSeasonConfigByVersion(version)
  local version_util = require("client.common.version_util")
  local clientVersion = version or version_util.GetClientFormat(Client.GetAppVersion())
  return CDataTable.GetSplitTableDataByFilter("Lobby", "CardCollection", self.regionConfig.Season, "Version", clientVersion)
end
function CardCollectionDataModule:MarkNextRefreshAsClickOpen()
  self.PendingClickOpenCard = true
end
function CardCollectionDataModule:RefreshSeasonData()
  local is_click_open_card = self.PendingClickOpenCard or false
  self.PendingClickOpenCard = nil
  CardCollectionSeasonHandler.send_card_collect_query_summary_data_req()
  CardCollectionSeasonHandler.send_card_collect_query_season_data_req(self:GetSeasonIDByClientVersion(), is_click_open_card)
end
function CardCollectionDataModule:GetSeasonIDByClientVersion()
  local version_util = require("client.common.version_util")
  local clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local seasonConfig = CDataTable.GetSplitTableDataByFilter("Lobby", "CardCollection", self.regionConfig.Season, "Version", clientVersion)
  if seasonConfig and seasonConfig.SeasonID then
    return seasonConfig.SeasonID
  end
  return 1
end
function CardCollectionDataModule:IsOldVersion()
  if IsEditor then
    return false
  end
  local localSeasonID = self:GetSeasonIDByClientVersion()
  if not self.server_season_id then
    log(bWriteLog and "[CardCollection] CardCollectionDataModule:IsOldVersion not self server season id")
    return true
  end
  log(bWriteLog and string.format("[CardCollection] CardCollectionDataModule:IsOldVersion: client season: %s, server season: %s", tostring(localSeasonID), tostring(self.server_season_id)))
  if localSeasonID ~= self.server_season_id then
    return true
  end
  return false
end
function CardCollectionDataModule:GetPlayerData()
  if not self.summary_data then
    log(bWriteLog and "[CardCollection] CardCollectionDataModule:GetPlayerData not summary data")
    CardCollectionSeasonHandler.send_card_collect_query_summary_data_req()
    return
  end
  log_tree("[CardCollection] CardCollectionDataModule:GetPlayerData summary data", self.summary_data)
  return self.summary_data
end
function CardCollectionDataModule:GetSelfCareerScore()
  if self.summary_data then
    return self.summary_data.career_score or 0
  end
  return 0
end
function CardCollectionDataModule:MatchCardFilter(cardConfig, filter)
  if not filter or not cardConfig then
    return true
  end
  for key, value in pairs(filter) do
    if cardConfig[key] ~= value then
      return false
    end
  end
  return true
end
function CardCollectionDataModule:IsSetOnline(setID)
  local setCfg = CDataTable.GetSplitTableData("Lobby", "CardCollection", self.regionConfig.Set, setID)
  if not (setCfg and setCfg.StartTime) or setCfg.StartTime == "" then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.TimeStringToUnixstamp(setCfg.StartTime) <= TimeUtil.GetServerTimeInSec()
end
function CardCollectionDataModule:IsCardOnline(showData)
  if showData.SetID and not self:IsSetOnline(showData.SetID) then
    return false
  end
  if showData.IsTimeOnline ~= 1 then
    return true
  end
  if not showData.OnlineTime or showData.OnlineTime == "" then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.TimeStringToUnixstamp(showData.OnlineTime) <= TimeUtil.GetServerTimeInSec()
end
function CardCollectionDataModule:IsCardOnlineByCardID(cardID)
  local cardCfg = CDataTable.GetTableData("CardCollectionCardConfig", cardID)
  if not cardCfg then
    return false
  end
  return self:IsCardOnline(cardCfg)
end
function CardCollectionDataModule:IsCardOnlineByItemID(itemID)
  local cardCfg = CDataTable.GetTableDataByFilter("CardCollectionCardConfig", "ItemID", itemID)
  if not cardCfg then
    return false
  end
  return self:IsCardOnline(cardCfg)
end
function CardCollectionDataModule:MergeOldCardList()
  if not self.summary_data then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:MergeOldCardList summary_data is nil, skip")
    return
  end
  if self.summary_data.card_collect_migration_v1_completed == 1 then
    log(bWriteLog and "[CardCollection] CardCollectionDataModule:MergeOldCardList migration completed")
    return
  end
  CardCollectionSeasonHandler.send_card_collect_history_click_req()
end
function CardCollectionDataModule:QuerySubwayOwned(callback)
  if self.subwayOwnedCache == true then
    if callback then
      callback(true)
    end
    return
  end
  local KarambitConfig = require("GameLua.Mod.Lobby.Split.CardCollection.logic.CardCollectionKarambitConfig")
  local subwayResId = KarambitConfig.GetWeaponResId(KarambitConfig.EPerkID.Subway)
  local wardrobeData = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  wardrobeData.QueryDepotItemsExist({subwayResId}, function()
    local owned = wardrobeData.IsDepotItemOwned(subwayResId)
    self.subwayOwnedCache = owned
    if callback then
      callback(owned)
    end
  end)
end
function CardCollectionDataModule:GetSubwayOwnedCache()
  return self.subwayOwnedCache
end
function CardCollectionDataModule:on_card_collect_query_summary_data_rsp(summary_data, card_depot_data)
  log_tree(bWriteLog and "[CardCollection] CardCollectionDataModule:on_card_collect_query_summary_data_rsp summary_data", summary_data)
  log_tree(bWriteLog and "[CardCollection] CardCollectionDataModule:on_card_collect_query_summary_data_rsp card_depot_data", card_depot_data)
  self.  self.server_season_id = summary_data.season_id
  self.  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SUMMARY_DATA_UPDATE)
end
function CardCollectionDataModule:on_card_collect_query_season_data_rsp(season_id, season_data)
  log_tree(bWriteLog and string.format("[CardCollection] CardCollectionDataModule:on_card_collect_query_season_data_rsp season_id=%d, season_data", season_id), season_data)
  self.last_season_data = self.season_data
  self.  local cardInfoModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.CardCollectionCardInfoModule)
  if cardInfoModule then
    cardInfoModule:SyncCardCountFromSeasonData(season_data)
  end
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SEASON_DATA_UPDATE, season_data)
end
function CardCollectionDataModule:on_card_collect_series_finish_ntf(series_id, season_id, card_id)
  log(bWriteLog and string.format("[CardCollection] CardCollectionDataModule.on_card_collect_series_finish_ntf series_id: %s, season_id: %s, card_id: %s", tostring(series_id), tostring(season_id), tostring(card_id)))
  self:RefreshSeasonData()
  local setCompletionData = {
    completionType = 0,
    setID = series_id,
    cardID = card_id
  }
  CardCollectionUtil.OpenPopup(popupType.Completion, {data = setCompletionData})
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SERIES_FINISH, series_id, season_id, card_id)
end
function CardCollectionDataModule:on_card_collect_season_finish_ntf(season_id)
  log(bWriteLog and string.format("[CardCollection] CardCollectionDataModule:on_card_collect_season_finish_ntf season_id=%s", tostring(season_id)))
  if not season_id or type(season_id) ~= "number" then
    return
  end
  if season_id ~= self:GetSeasonIDByClientVersion() then
    log(bWriteLog and "[CardCollection] CardCollectionDataModule:on_card_collect_season_finish_ntf season_id ~= self:GetSeasonIDByClientVersion()")
    return
  end
  self:RefreshSeasonData()
  local seasonCompletionData = {completionType = 1, seasonID = season_id}
  CardCollectionUtil.OpenPopup(popupType.Completion, {data = seasonCompletionData})
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SEASON_FINISH, season_id)
end
function CardCollectionDataModule:on_card_collect_history_click_rsp(migrated_item_ids, get_card_collect_data)
  log_tree(bWriteLog and "[CardCollection] CardCollectionDataModule:on_card_collect_history_click_rsp migrated_item_ids", migrated_item_ids)
  log_tree(bWriteLog and "[CardCollection] CardCollectionDataModule:on_card_collect_history_click_rsp get_card_collect_data", get_card_collect_data)
  if self.summary_data then
    self.summary_data.card_collect_migration_v1_completed = 1
  end
  if #migrated_item_ids == 0 then
    return
  end
  local card_list = {}
  for _, v in ipairs(migrated_item_ids) do
    table.insert(card_list, {res_id = v})
  end
  CardCollectionUtil.CardGetPanel(card_list, {1})
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CCardCollectionDataModule = class(CModuleBase, nil, CardCollectionDataModule)
return CCardCollectionDataModule