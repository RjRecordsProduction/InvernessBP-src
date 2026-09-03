local logic_card_collection_season = {}
local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
local CardCollectionUtil = require("client.slua.umg.CardCollection.CardCollectionUtil")
local CardCollectionSeasonHandler = require("client.network.Protocol.CardCollectionSeasonHandler")
local CardCollectionUIConfig = require("client.slua.logic.card_collection_season.CardCollectionSeasonUIConfig")
local logic_card_collection_cache = require("client.slua.logic.card_collection_season.logic_card_collection_cache")
local popupType = CardCollectionUIConfig.ECardCollectionPopupType
local panelType = CardCollectionUIConfig.ECardCollectionPanelType
local CardSourceType = {
  gift_receive = CardCollectionUIConfig.ECardFromType.FriendGift,
  exchange_sender = CardCollectionUIConfig.ECardFromType.FriendSwap
}
local ERegion = {
  JAPAN = 1,
  KOREA = 2,
  BLUEHOLE = 3,
  DEFAULT = 1000
}
local EXCHANGE_LIST_OFFSET = 100
local QUERY_DRIFT_BOTTLE_INTERVAL = 7200
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
local EGiftShowType = {Send = 1, Receive = 2}
function logic_card_collection_season:DefineAndResetData()
  self.season_data = nil
  self.last_season_data = nil
  self.set_data = {}
  self.summary_data = nil
  self.server_season_id = nil
  self._tCardCountCache = {}
  self.show_infoMap = {}
  self.SwapOutsideShareCallBack = nil
  self.FriendSwapCallBack = nil
  self.pendingExchangeList = {}
  self.pendingExchangeCardMap = {}
  self._specialCardConfigCache = nil
  self.IsNewMap = {}
  self._GMTestCardList = nil
  self.compose_card_day_limit = {}
  self.GM_DirectShowGetDriftBottle = nil
  self.PendingClickOpenCard = nil
  self._tPauseCardPackReasons = {}
  self._nPauseCardPackTimer = nil
  self.regionConfig = {
    Set = CardCollectionRegionSetMap[ERegion[Client.GetPublishRegion()] or 1000],
    ScoreAward = CardCollectionRegionScoreAwardMap[ERegion[Client.GetPublishRegion()] or 1000],
    CollectAward = CardCollectionRegionCollectAwardMap[ERegion[Client.GetPublishRegion()] or 1000],
    Pack = CardCollectionPackConfigMap[ERegion[Client.GetPublishRegion()] or 1000]
  }
  self.exchangeListPage = {
    exchange = {
      list = {},
      offset = 0
    },
    gift_send = {
      list = {},
      offset = 0
    },
    gift_received = {
      list = {},
      offset = 0
    }
  }
end
function logic_card_collection_season:OnInitialize()
end
function logic_card_collection_season:RegistEvents()
end
function logic_card_collection_season:OnLogin(bReLogin)
end
function logic_card_collection_season:OnLogOut()
end
function logic_card_collection_season:PauseCardPack(reason)
  if not reason or reason == "" then
    return
  end
  self._tPauseCardPackReasons[reason] = true
  log_tree("[CardCollection] PauseCardPack _tPauseCardPackReasons", self._tPauseCardPackReasons)
  if self._nPauseCardPackTimer then
    self:RemoveTimer(self._nPauseCardPackTimer)
  end
  self._nPauseCardPackTimer = self:AddTimerOnce(5, function()
    self._nPauseCardPackTimer = nil
    self._tPauseCardPackReasons = {}
    log_tree("[CardCollection] PauseCardPack auto cleared all _tPauseCardPackReasons")
  end)
end
function logic_card_collection_season:ResumeCardPack(reason)
  if not reason or reason == "" then
    return
  end
  self._tPauseCardPackReasons[reason] = nil
  log_tree("[CardCollection] ResumeCardPack _tPauseCardPackReasons", self._tPauseCardPackReasons)
  if not next(self._tPauseCardPackReasons) and self._nPauseCardPackTimer then
    self:RemoveTimer(self._nPauseCardPackTimer)
    self._nPauseCardPackTimer = nil
  end
end
function logic_card_collection_season:IsCardPackPaused()
  return next(self._tPauseCardPackReasons)
end
function logic_card_collection_season:OnPreSwitchGameStatus(preState, nextState)
  self:DefineAndResetData()
  if self.QuerySwapClaimTimer then
    self:RemoveTimer(self.QuerySwapClaimTimer)
    self.QuerySwapClaimTimer = nil
  end
end
function logic_card_collection_season:OnPostSwitchGameStatus(preState, nextState)
  if preState ~= GameStatus.Login and nextState == GameStatus.Lobby then
    self:QuerySwapAndGiftClaim()
  end
end
function logic_card_collection_season:GetSeasonConfigByVersion(version)
  local version_util = require("client.common.version_util")
  local clientVersion = version or version_util.GetClientFormat(Client.GetAppVersion())
  return CDataTable.GetTableDataByFilter("CardCollectionSeasonConfig", "Version", clientVersion)
end
function logic_card_collection_season:MarkNextRefreshAsClickOpen()
  self.PendingClickOpenCard = true
end
function logic_card_collection_season:RefreshSeasonData()
  local is_click_open_card = self.PendingClickOpenCard or false
  self.PendingClickOpenCard = nil
  CardCollectionSeasonHandler.send_card_collect_query_summary_data_req()
  CardCollectionSeasonHandler.send_card_collect_query_season_data_req(self:GetSeasonIDByClientVersion(), is_click_open_card)
end
function logic_card_collection_season:GetSeasonIDByClientVersion()
  local version_util = require("client.common.version_util")
  local clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local seasonConfig = CDataTable.GetTableDataByFilter("CardCollectionSeasonConfig", "Version", clientVersion)
  if seasonConfig and seasonConfig.SeasonID then
    return seasonConfig.SeasonID
  end
  return 1
end
function logic_card_collection_season:QuerySpecialCard()
  local newbieCardID = {
    32,
    33,
    34,
    35
  }
  for _, cardID in ipairs(newbieCardID) do
    if self:GetOwnCardNumByCardID(cardID) > 0 then
      log(bWriteLog and string.format("[CardCollection] logic_card_collection_season:QuerySpecialCard: already own newbie card %d", cardID))
      return
    end
  end
  CardCollectionSeasonHandler.send_card_collect_get_newbie_card_req()
end
function logic_card_collection_season:GetSetTaskConfig(setID)
  if not setID then
    return {}
  end
  local configTable = CDataTable.GetTableByFilter("CardCollectionCardConfig", "SetID", setID)
  if not configTable then
    return {}
  end
  local result = {}
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  for _, config in pairs(configTable) do
    if config.TaskDesc and config.TaskDesc ~= "" and self:IsConfigOnline(config, currentTime) then
      table.insert(result, {show_data = config})
    end
  end
  return result
end
function logic_card_collection_season:GetSetPackConfig(setID)
  if not setID then
    return {}
  end
  local setConfig = CDataTable.GetTableData(self.regionConfig.Set, setID)
  if not setConfig or not setConfig.PackID then
    return {}
  end
  local StringUtil = require("common.string_util")
  local packIdList = StringUtil.Split(setConfig.PackID, "|")
  if not packIdList or not next(packIdList) then
    return {}
  end
  local result = {}
  local seenPackID = {}
  for _, packIdStr in ipairs(packIdList) do
    local packId = tonumber(packIdStr)
    if packId and not seenPackID[packId] then
      local packConfig = self:GetPackConfigByPackIDForPreview(packId)
      if packConfig then
        seenPackID[packId] = true
        local packData = {}
        for k, v in pairs(packConfig) do
          packData[k] = v
        end
        local nameList = packData.GetWayName and StringUtil.Split(packData.GetWayName, "|") or {}
        local linkList = packData.JumpLink and StringUtil.Split(packData.JumpLink, "|") or {}
        local getWayList = {}
        for i, name in ipairs(nameList) do
          table.insert(getWayList, {
            Name = LocUtil.GetLocalizeResStr(name),
            JumpUrl = linkList[i] or ""
          })
        end
        packData.GetWayList = getWayList
        table.insert(result, packData)
      end
    end
  end
  return result
end
function logic_card_collection_season:GetPackConfigByPackID(packID)
  local nPackID = tonumber(packID)
  if not nPackID then
    return nil
  end
  local version_util = require("client.common.version_util")
  local clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local configTable = CDataTable.GetTableByFilter(self.regionConfig.Pack, "PackID", nPackID, "Version", clientVersion)
  if configTable then
    for _, cfg in pairs(configTable) do
      return cfg
    end
  end
  return nil
end
function logic_card_collection_season:GetPackConfigByPackIDForPreview(packID)
  local nPackID = tonumber(packID)
  if not nPackID then
    return nil
  end
  local version_util = require("client.common.version_util")
  local clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local configTable = CDataTable.GetTableByFilter(self.regionConfig.Pack, "PackID", nPackID, "Version", clientVersion)
  if not configTable then
    return nil
  end
  for _, cfg in pairs(configTable) do
    if self:_IsInTimeWindow(cfg, now) then
      return cfg
    end
  end
  return nil
end
function logic_card_collection_season:_IsInTimeWindow(cfg, now)
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
function logic_card_collection_season:ParsePackDropIDList(dropID)
  local result = {}
  local StringUtil = require("common.string_util")
  local splitList = StringUtil.Split(dropID, ";") or {}
  for _, value in ipairs(splitList) do
    table.insert(result, tonumber(value))
  end
  return result
end
function logic_card_collection_season:GetFragment()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemDataByResID(1024)
  if not itemData then
    return 0
  end
  return itemData.count
end
function logic_card_collection_season:GetTotalDismantleFragment()
  local duplicateCards = self:GetCardListDuplicate({
    configFilter = {CanDismantle = 1}
  })
  if not duplicateCards then
    return 0
  end
  local CardCollectionGradeConfig = CDataTable.GetTable("CardCollectionGradeConfig")
  if not CardCollectionGradeConfig then
    return 0
  end
  local fragmentCache = {}
  for _, scoreCfg in pairs(CardCollectionGradeConfig) do
    fragmentCache[scoreCfg.Grade] = scoreCfg.FragmentNum or 0
  end
  local totalFragment = 0
  for _, cardData in ipairs(duplicateCards) do
    local grade = cardData.show_data and cardData.show_data.Grade or 0
    totalFragment = totalFragment + (fragmentCache[grade] or 0)
  end
  return totalFragment
end
function logic_card_collection_season:GetMinPackPrice()
  local packConfigList = self:GetPackConfig()
  if not packConfigList or #packConfigList == 0 then
    return nil
  end
  local minPrice
  for _, packCfg in ipairs(packConfigList) do
    if packCfg.CanExchange == 1 and packCfg.Price and 0 < packCfg.Price and (not minPrice or minPrice > packCfg.Price) then
      minPrice = packCfg.Price
    end
  end
  return minPrice
end
function logic_card_collection_season:GetOnSwapNum(itemID)
  return self.pendingExchangeCardMap[itemID]
end
function logic_card_collection_season:CanBuyPackAfterDismantle()
  local currentFragment = self:GetFragment()
  local dismantleFragment = self:GetTotalDismantleFragment()
  local totalFragment = currentFragment + dismantleFragment
  local minPackPrice = self:GetMinPackPrice()
  if not minPackPrice then
    return false, totalFragment, nil
  end
  return totalFragment >= minPackPrice, totalFragment, minPackPrice
end
function logic_card_collection_season:IsDismantleTipShownToday()
  if self:IsOldVersion() then
    return true
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local currentDay = self:_GetTodayDateStr()
  local lastShowDay = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionDismantleTipDate) or ""
  return currentDay == lastShowDay
end
function logic_card_collection_season:SetDismantleTipShownToday()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local currentDay = self:_GetTodayDateStr()
  PlayerPrefsSystem.SaveTableToFile_N(currentDay, PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionDismantleTipDate)
end
function logic_card_collection_season:IsNewSet(setID)
  if not setID then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local readSetMap = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionNewSetRead) or {}
  return not readSetMap[tostring(setID)]
end
function logic_card_collection_season:MarkNewSetRead(setID)
  if not setID then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local readSetMap = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionNewSetRead) or {}
  if readSetMap[tostring(setID)] then
    return
  end
  readSetMap[tostring(setID)] = true
  PlayerPrefsSystem.SaveTableToFile_N(readSetMap, PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionNewSetRead)
end
function logic_card_collection_season:GetPackConfig()
  local version_util = require("client.common.version_util")
  local clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local configTable = CDataTable.GetTableByFilter(self.regionConfig.Pack, "Version", clientVersion) or {}
  local result = {}
  local seenPackID = {}
  for _, config in pairs(configTable) do
    local packID = tonumber(config.PackID)
    if packID and not seenPackID[packID] and self:_IsInTimeWindow(config, now) then
      seenPackID[packID] = true
      table.insert(result, config)
    end
  end
  return result
end
function logic_card_collection_season:DismantleCard(cardList)
  log_tree("[CardCollection] logic_card_collection_season:DismantleCard", cardList)
  CardCollectionSeasonHandler.send_card_collect_batch_decompose_req(cardList)
end
function logic_card_collection_season:GetSetAwardData(set_id, bIsHistory)
  if not self:_EnsureSeasonData() then
    return
  end
  log_tree("[CardCollection] logic_card_collection_season:GetSetAwardData season data", self.season_data)
  set_id = set_id or 1
  local awardTable = CDataTable.GetTableByFilter(self.regionConfig.CollectAward, "SetID", set_id)
  local tempData = bIsHistory and self.set_data or self.season_data
  local awardList = {}
  local itemList, itemId, itemIdKey, itemNumKey, jumpTextKey, jumpPathKey, setData, ownedNum, totalNum
  if not awardTable then
    return awardList
  end
  for _, v in pairs(awardTable) do
    itemList = {}
    for i = 1, 3 do
      itemIdKey = string.format("ItemID%d", i)
      itemId = v[itemIdKey]
      if itemId and 0 < itemId then
        itemNumKey = string.format("ItemNum%d", i)
        jumpTextKey = string.format("JumpText%d", i)
        jumpPathKey = string.format("JumpPath%d", i)
        setData = tempData[set_id] or {}
        ownedNum = setData.count or 0
        totalNum = self:GetTotalCardNumBySetID(set_id)
        table.insert(itemList, {
          show_data = {
            ItemID = itemId,
            ItemNum = v[itemNumKey] or 0,
            JumpText = v[jumpTextKey] or "",
            JumpPath = v[jumpPathKey] or ""
          },
          status = setData.collect_award == 1 and 2 or ownedNum >= totalNum and 1 or 0
        })
      end
    end
    awardList = {
      SetID = v.SetID,
      items = itemList
    }
  end
  return awardList
end
function logic_card_collection_season:GetSeasonAwardData()
  if not self.summary_data then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:GetSeasonAwardData not summary data")
    CardCollectionSeasonHandler.send_card_collect_query_summary_data_req()
    return
  end
  log_tree("[CardCollection] logic_card_collection_season:GetSeasonAwardData summary data", self.summary_data)
  local season_id = self:GetSeasonIDByClientVersion()
  local awardTable = CDataTable.GetTableByFilter(self.regionConfig.ScoreAward, "SeasonID", season_id)
  local awardList = {}
  if awardTable then
    for _, v in pairs(awardTable) do
      table.insert(awardList, {
        show_data = v,
        score = self.summary_data.season_score,
        status = self.summary_data.score_award[v.StageID] == 1 and 2 or self.summary_data.season_score >= v.StageScore and 1 or 0
      })
    end
  end
  return awardList
end
function logic_card_collection_season:GetCardShowDataByCardId(cardId)
  local cardData = {
    cardId = cardId,
    show_data = CDataTable.GetTableData("CardCollectionCardConfig", cardId)
  }
  return cardData
end
function logic_card_collection_season:GetCardShowDataByItemId(itemId)
  log(bWriteLog and string.format("[CardCollection] logic_card_collection_season:GetCardShowDataByItemId itemId: %d", itemId))
  return CDataTable.GetTableDataByFilter("CardCollectionCardConfig", "ItemID", itemId)
end
function logic_card_collection_season:IsOldVersion()
  if IsEditor then
    return false
  end
  local localSeasonID = self:GetSeasonIDByClientVersion()
  if not self.server_season_id then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:IsOldVersion not self server season id")
    return true
  end
  log(bWriteLog and string.format("[CardCollection] logic_card_collection_season:IsOldVersion: client season: %s, server season: %s", tostring(localSeasonID), tostring(self.server_season_id)))
  if localSeasonID ~= self.server_season_id then
    return true
  end
  return false
end
function logic_card_collection_season:GetFriendList()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local friendList = logic_new_friend.GetFriendList(true)
  local tabData = {}
  local profile, data
  for _, friend in ipairs(friendList) do
    profile = logic_profile:GetLocalProfile(friend.uid)
    if profile then
      data = {}
      data.uid = friend.uid
      data.intimacy = friend.intimacy
      data.nickName = profile.nickName
      data.picUrl = profile.picUrl
      data.sex = profile.sex
      data.level = profile.level
      data.cur_avatar_box_id = profile.cur_avatar_box_id
      table.insert(tabData, data)
    end
  end
  return tabData
end
function logic_card_collection_season:QuerySwapHistory(offset)
  self.exchangeListPage.exchange.list = {}
  CardCollectionSeasonHandler.send_card_collect_get_exchange_list_req("exchange", offset or 0)
end
function logic_card_collection_season:QueryGiftHistory(type, offset)
  self.exchangeListPage[type].list = {}
  CardCollectionSeasonHandler.send_card_collect_get_exchange_list_req(type, offset or 0)
end
function logic_card_collection_season:GetHistoryCardTable()
  local version_util = require("client.common.version_util")
  local ClientVersion = Client.GetAppVersion()
  local setConfigTable = CDataTable.GetTable(self.regionConfig.Set)
  local history_setTable = {}
  for k, v in pairs(setConfigTable) do
    if version_util.CompareVersionMain(ClientVersion, v.Version) > 0 then
      table.insert(history_setTable, v)
    else
      log(bWriteLog and "logic_card_collection_season:Cur setPage version > ClientVersion" .. "  setId = " .. tostring(v.SetId))
    end
  end
  return history_setTable
end
function logic_card_collection_season:HasCanReceiveCollectAward(setID)
  if not self.season_data then
    return false
  end
  local setData = self.season_data[setID]
  if not setData then
    return false
  end
  if setData.collect_award == 1 then
    return false
  end
  local ownedNum = setData.count or 0
  local totalNum = self:GetTotalCardNumBySetID(setID)
  return ownedNum >= totalNum and 0 < totalNum
end
function logic_card_collection_season:RefreshAllCollectAwardRedDot(reddotData)
  if not self.season_data then
    return
  end
  for setID, setData in pairs(self.season_data) do
    if type(setID) == "number" and type(setData) == "table" then
      if self:HasCanReceiveCollectAward(setID) then
        reddotData:SetCollectAwardRedDot(setID)
      else
        reddotData:CloseCollectAwardRedDot(setID)
      end
    end
  end
end
function logic_card_collection_season:HasCanReceiveScoreAward()
  if not self.summary_data then
    CardCollectionSeasonHandler.send_card_collect_query_summary_data_req()
    return false
  end
  local seasonScore = self.summary_data.season_score or 0
  local scoreAward = self.summary_data.score_award or {}
  local awardTable = CDataTable.GetTable(self.regionConfig.ScoreAward)
  if not awardTable then
    return false
  end
  for _, awardConfig in pairs(awardTable) do
    local stageID = awardConfig.StageID
    local stageScore = awardConfig.StageScore or 0
    if scoreAward[stageID] ~= 1 and seasonScore >= stageScore then
      return true
    end
  end
  return false
end
function logic_card_collection_season:GetSetListByVersion(version)
  local version_util = require("client.common.version_util")
  local targetVersion = version or version_util.GetClientFormat(Client.GetAppVersion())
  local setConfigTable = CDataTable.GetTableByFilter(self.regionConfig.Set, "Version", targetVersion)
  local setList = {}
  if setConfigTable then
    for _, setCfg in pairs(setConfigTable) do
      table.insert(setList, setCfg)
    end
  end
  table.sort(setList, function(a, b)
    return a.SetID < b.SetID
  end)
  log(bWriteLog and string.format("[CardCollection] GetSetListByVersion version=%s, count=%d", tostring(targetVersion), #setList))
  return setList
end
function logic_card_collection_season:GetSetTabDataByVersion(version)
  if not self:_EnsureSeasonData() then
    return
  end
  log_tree("[CardCollection] logic_card_collection_season:GetSetTabDataByVersion season data", self.season_data)
  local setList = self:GetSetListByVersion(version)
  local seasonData = self.season_data
  local tabData = {}
  local setIDToIndex = {}
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  for _, setCfg in pairs(setList) do
    local startTime = setCfg.StartTime
    local isOnline = startTime == "" or currentTime >= TimeUtil.TimeStringToUnixstamp(startTime)
    if isOnline then
      local setID = setCfg.SetID
      local setData = seasonData[setID] or {}
      table.insert(tabData, {
        text = setCfg.Name,
        setID = setID,
        ownNum = setData.count or 0,
        totalNum = self:GetTotalCardNumBySetID(setID)
      })
      setIDToIndex[setID] = #tabData
    end
  end
  return tabData, setIDToIndex
end
function logic_card_collection_season:GetHistorySetDataBySetId(setID)
  if not self.set_data[setID] then
    return nil
  end
  local seasonDataBackup = self.season_data
  self.season_data = self.set_data
  local result = self:GetCardDataBySetID(setID)
  self.season_data = seasonDataBackup
  if not result then
    return nil
  end
  return {
    CardData = result.CardData,
    OwnedNum = result.OwnedNum,
    TotalNum = result.TotalNum,
    collect_award = result.collect_award
  }
end
function logic_card_collection_season:GetAllHistorySetData()
  local version_util = require("client.common.version_util")
  local historyData = self:GetHistoryCardTable()
  local ClientVersion = Client.GetAppVersion()
  for k, v in pairs(historyData) do
    if v then
      if version_util.CompareVersionFull(ClientVersion, v.Version) >= 0 then
        if not self.set_data[v.SetId] then
          CardCollectionSeasonHandler.send_card_collect_query_series_data_req(v.SetId)
        end
      else
        log(bWriteLog and "logic_card_collection_season:Cur setPage version > ClientVersion" .. "  setId = " .. tostring(v.SetId))
      end
    end
  end
end
function logic_card_collection_season:GetCardListSwapable(filter)
  if not self:_EnsureSeasonData() then
    return
  end
  log_tree("[CardCollection] logic_card_collection_season:GetCardListSwapable season data", self.season_data)
  filter = filter or {}
  local configFilter = filter.configFilter or {}
  local dataFilter = filter.dataFilter or {}
  configFilter.CanSwap = 1
  local cardList = {}
  self:_IterateSeasonCards(function(cardID, cardInfo, cardConfig)
    local count = cardInfo.count or 0
    if count <= 0 then
      return
    end
    local specialCfg = count <= 1 and self:GetSpecialCardConfig(cardConfig and cardConfig.SpecialID)
    if count <= 1 and (not specialCfg or specialCfg.CanExchangeOnlyOne ~= 1) then
      return
    end
    if not self:MatchCardFilter(cardConfig, configFilter) then
      return
    end
    table.insert(cardList, {show_data = cardConfig})
  end)
  if dataFilter.CurrentVersionOnly then
    return cardList
  end
  self:GetAllHistorySetData()
  for _, setData in pairs(self.set_data or {}) do
    if type(setData) == "table" and setData.cards then
      for cardID, cardInfo in pairs(setData.cards) do
        local cardConfig = CDataTable.GetTableData("CardCollectionCardConfig", cardID)
        local count = cardInfo.count or 0
        if not (count <= 0) then
          local specialCfg = count <= 1 and self:GetSpecialCardConfig(cardConfig and cardConfig.SpecialID)
          if (not (count <= 1) or specialCfg and specialCfg.CanExchangeOnlyOne == 1) and self:MatchCardFilter(cardConfig, configFilter) then
            table.insert(cardList, {show_data = cardConfig})
          end
        end
      end
    end
  end
  return cardList
end
function logic_card_collection_season:GetTotalCardNumBySetID(setID)
  local tableData = CDataTable.GetTableByFilter("CardCollectionCardConfig", "SetID", setID)
  if not tableData then
    return 0
  end
  local specialIdSet = {}
  local totalNum = 0
  for _, v in pairs(tableData) do
    local specialID = v.SpecialID or 0
    if specialID == 0 then
      totalNum = totalNum + 1
    elseif not specialIdSet[specialID] then
      specialIdSet[specialID] = true
      totalNum = totalNum + 1
    end
  end
  return totalNum
end
function logic_card_collection_season:GetSetProgress(setID)
  local setData = self.season_data and self.season_data[setID] or {}
  local own = setData.count or 0
  local total = self:GetTotalCardNumBySetID(setID)
  return own, total
end
function logic_card_collection_season:GetSeasonScore()
  if not self.summary_data then
    return 0, 0
  end
  return self.summary_data.season_score
end
function logic_card_collection_season:GetSeasonProgress()
  if not self.season_data then
    return 0, 0
  end
  local setTable = self:_GetSeasonSetTable()
  if not setTable then
    return 0, 0
  end
  local totalNum = 0
  local ownedNum = 0
  for _, setConfig in pairs(setTable) do
    local setID = setConfig.SetID
    local setData = self.season_data[setID] or {}
    if setData then
      ownedNum = ownedNum + (setData.count or 0)
      totalNum = totalNum + self:GetTotalCardNumBySetID(setID)
    end
  end
  return ownedNum, totalNum
end
function logic_card_collection_season:IsSeasonAllCollected()
  if not self.season_data then
    return false
  end
  local setTable = self:_GetSeasonSetTable()
  if not setTable then
    return false
  end
  for _, setConfig in pairs(setTable) do
    local setID = setConfig.SetID
    local setData = self.season_data[setID] or {}
    local ownedNum = setData.count or 0
    local totalNum = self:GetTotalCardNumBySetID(setID)
    if ownedNum < totalNum then
      return false
    end
  end
  return true
end
function logic_card_collection_season:GetCardDataBySetID(setID)
  if not self:_EnsureSeasonData() then
    return
  end
  log_tree("[CardCollection] logic_card_collection_season:GetCardDataBySetID season data", self.season_data)
  local tableData = CDataTable.GetTableByFilter("CardCollectionCardConfig", "SetID", setID)
  local setConfig = CDataTable.GetTableData(self.regionConfig.Set, setID)
  local setData = self.season_data[setID] or {}
  local cardsOwned = setData.cards or {}
  local specialSetMap = {}
  local specialLogicTable = CDataTable.GetTable("CardSpecialLogicConfig")
  if specialLogicTable then
    for _, row in pairs(specialLogicTable) do
      if row.SetID ~= 0 then
        local data = self:GetCardShowDataByItemId(row.CardItemID)
        specialSetMap[data.CardID] = row.SetID
      end
    end
  end
  local filteredData = {}
  local existCardIDs = {}
  for _, cardConfig in pairs(tableData) do
    local overrideSetID = specialSetMap[cardConfig.CardID]
    if not overrideSetID or overrideSetID == setID then
      table.insert(filteredData, cardConfig)
      existCardIDs[cardConfig.CardID] = true
    end
  end
  for cardID, overrideSetID in pairs(specialSetMap) do
    if overrideSetID == setID and not existCardIDs[cardID] then
      local cardConfig = CDataTable.GetTableData("CardCollectionCardConfig", cardID)
      if cardConfig then
        table.insert(filteredData, cardConfig)
      end
    end
  end
  local normalCards, specialIdMap = self:_BuildCardListWithSpecialGroup(filteredData, cardsOwned, function()
    return {
      ExtraScore = setConfig.ExtraScore
    }
  end)
  local cardData = {}
  local totalNum = 0
  for _, grp in pairs(specialIdMap) do
    local cardItem = grp.owned or grp.max
    if cardItem then
      table.insert(cardData, cardItem)
      totalNum = totalNum + 1
    end
  end
  for _, item in ipairs(normalCards) do
    table.insert(cardData, item)
    totalNum = totalNum + 1
  end
  local res = {
    CardData = cardData,
    OwnedNum = setData.count or 0,
    TotalNum = totalNum,
    collect_award = setData.collect_award or 0,
    ExtraScore = setConfig.ExtraScore,
    ActivityEndTime = setConfig.ActivityEndTime,
    ActivityStartTime = setConfig.ActivityStartTime
  }
  return res
end
function logic_card_collection_season:GetCardListDuplicate(filter)
  if not self:_EnsureSeasonData() then
    return
  end
  log_tree("[CardCollection] logic_card_collection_season:GetCardListDuplicate season data", self.season_data)
  filter = filter or {}
  local configFilter = filter.configFilter or {}
  local duplicateCards = {}
  self:_IterateSeasonCards(function(cardID, cardInfo, cardConfig)
    local count = cardInfo.count - 1
    local match = self:MatchCardFilter(cardConfig, configFilter)
    if match then
      for i = 1, count do
        table.insert(duplicateCards, {show_data = cardConfig})
      end
    end
  end)
  self:GetAllHistorySetData()
  for _, setData in pairs(self.set_data or {}) do
    if type(setData) == "table" and setData.cards then
      for cardID, cardInfo in pairs(setData.cards) do
        local cardConfig = CDataTable.GetTableData("CardCollectionCardConfig", cardID)
        local count = (cardInfo.count or 0) - 1
        if not (count <= 0) and self:MatchCardFilter(cardConfig, configFilter) then
          for i = 1, count do
            table.insert(duplicateCards, {show_data = cardConfig})
          end
        end
      end
    end
  end
  return duplicateCards
end
function logic_card_collection_season:GetCardListUnowned(filter)
  if not self:_EnsureSeasonData() then
    return
  end
  log_tree("[CardCollection] logic_card_collection_season:GetCardListUnowned season data", self.season_data)
  filter = filter or {}
  local configFilter = filter.configFilter or {}
  local dataFilter = filter.dataFilter or {}
  local seasonData = self.season_data
  local unownedCards = {}
  local time_util = require("client.common.time_util")
  local currentTime = time_util.GetServerTimeInSec()
  local setList = self:GetSetListByVersion()
  local match, seriesID, cardID, seriesData, cardsOwned, cardInfo, cardConfigList
  for _, setCfg in ipairs(setList) do
    seriesID = setCfg.SetID
    seriesData = seasonData[seriesID]
    cardsOwned = seriesData and seriesData.cards or {}
    cardConfigList = CDataTable.GetTableByFilter("CardCollectionCardConfig", "SetID", seriesID)
    if cardConfigList then
      for _, cardConfig in pairs(cardConfigList) do
        match = self:MatchCardFilter(cardConfig, configFilter)
        cardID = cardConfig.CardID
        cardInfo = cardsOwned[cardID]
        if match and self:IsConfigOnline(cardConfig, currentTime) and (not cardInfo or (cardInfo.count or 0) == 0) then
          table.insert(unownedCards, {show_data = cardConfig})
        end
      end
    end
  end
  if dataFilter.CurrentVersionOnly then
    return unownedCards
  end
  self:GetAllHistorySetData()
  for historySetID, historySetData in pairs(self.set_data or {}) do
    if type(historySetData) == "table" then
      local historyCardsOwned = historySetData.cards or {}
      cardConfigList = CDataTable.GetTableByFilter("CardCollectionCardConfig", "SetID", historySetID)
      if cardConfigList then
        for _, cardConfig in pairs(cardConfigList) do
          match = self:MatchCardFilter(cardConfig, configFilter)
          cardID = cardConfig.CardID
          cardInfo = historyCardsOwned[cardID]
          if match and (not cardInfo or (cardInfo.count or 0) == 0) then
            table.insert(unownedCards, {show_data = cardConfig})
          end
        end
      end
    end
  end
  return unownedCards
end
function logic_card_collection_season:GetPlayerData()
  if not self.summary_data then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:GetPlayerData not summary data")
    CardCollectionSeasonHandler.send_card_collect_query_summary_data_req()
    return
  end
  log_tree("[CardCollection] logic_card_collection_season:GetPlayerData summary data", self.summary_data)
  return self.summary_data
end
function logic_card_collection_season:GetCardScoreLevelCfgByScore(score)
  log(bWriteLog and "logic_card_collection_season:GetCardScoreLevelCfgByScore:" .. score)
  score = score or 0
  local cfg = CDataTable.GetTable("CardScoreLevelCfg")
  for i, data in ipairs(cfg or {}) do
    if not cfg[i + 1] or score <= data.MinScore and score < cfg[i + 1].MinScore then
      return data
    end
  end
end
function logic_card_collection_season:GetCardScroreByUid(uid, forceUpdata)
  uid = tonumber(uid)
  if not self.show_infoMap then
    self.show_infoMap = {}
  end
  if forceUpdata then
    CardCollectionSeasonHandler.send_card_collect_query_show_info_req(uid)
    return 0
  end
  if self.show_infoMap[uid] then
    return self.show_infoMap[uid].career_score or 0
  else
    CardCollectionSeasonHandler.send_card_collect_query_show_info_req(uid)
  end
  return 0
end
function logic_card_collection_season:GetCardCollectionSetConfigBySetID(setId)
  local cfg = CDataTable.GetTableData(self.regionConfig.Set, setId)
  return cfg
end
function logic_card_collection_season:GetCardCollectionSetConfigBySeasonID(seasonID)
  seasonID = seasonID or self:GetSeasonIDByClientVersion()
  local cfg = CDataTable.GetTableByFilter(self.regionConfig.Set, "SeasonID", seasonID)
  return cfg
end
function logic_card_collection_season:GetSelectVersionCardList(uid)
  if self._GMTestCardList then
    return self._GMTestCardList
  end
  uid = tonumber(uid)
  if not uid then
    return
  end
  if uid == tonumber(DataMgr.roleData.uid) and self.show_series_id then
    return self:GetCardsByVersionList(self.show_series_id)
  end
  if self.show_infoMap[uid] then
    log_tree("[CardCollection] logic_card_collection_season:GetSelectVersionCardList show_infoMap", self.show_infoMap[uid])
    local series_id = self.show_infoMap[uid].show_series_id
    return self:GetCardsByVersionList(series_id)
  else
    log(bWriteLog and "[CardCollection] logic_card_collection_season:GetSelectVersionCardList not show_infoMap")
    CardCollectionSeasonHandler.send_card_collect_query_show_info_req(uid)
    return
  end
end
function logic_card_collection_season:GetCardsByVersionList(series_id)
  local tableData = CDataTable.GetTableByFilter("CardCollectionCardConfig", "SetID", series_id, "ActionUse", 1)
  return tableData
end
function logic_card_collection_season:GenSwapOrder(onwedList, wantCard)
  local given_card = {}
  for i, v in ipairs(onwedList) do
    table.insert(given_card, v.show_data.ItemID)
  end
  local expect_card_id = wantCard.show_data.ItemID
  CardCollectionSeasonHandler.send_card_collect_gen_exchange_req(given_card, expect_card_id)
end
function logic_card_collection_season:QuerySwapOrderByOrderId(orderId)
  CardCollectionSeasonHandler.send_card_collect_get_exchange_req(orderId)
end
function logic_card_collection_season:GetOwnCardNumByCardID(cardID)
  log(bWriteLog and string.format("[CardCollection] logic_card_collection_season:GetOwnCardNumByCardID cardID=%s", tostring(cardID)))
  local cardConfig = CDataTable.GetTableData("CardCollectionCardConfig", cardID)
  if not cardConfig then
    return 0
  end
  local setID = cardConfig.SetID
  local setCfg = CDataTable.GetTableData(self.regionConfig.Set, setID)
  local isCurrentSeason = setCfg and setCfg.SeasonID == self:GetSeasonIDByClientVersion()
  if isCurrentSeason then
    if not self:_EnsureSeasonData() then
      return 0
    end
    local setData = self.season_data[setID]
    local cardInfo = setData and setData.cards and setData.cards[cardID]
    return cardInfo and (cardInfo.count or 0) or 0
  end
  local historySetData = self.set_data and self.set_data[setID]
  if historySetData then
    local cardInfo = historySetData.cards and historySetData.cards[cardID]
    return cardInfo and (cardInfo.count or 0) or 0
  end
  self.set_data = self.set_data or {}
  self.set_data[setID] = {}
  CardCollectionSeasonHandler.send_card_collect_query_series_data_req(setID)
  return 0
end
function logic_card_collection_season:GetOwnCardNumByItemID(itemID)
  local cardConfig = CDataTable.GetTableDataByFilter("CardCollectionCardConfig", "ItemID", itemID)
  if not cardConfig then
    return 0
  end
  return self:GetOwnCardNumByCardID(cardConfig.CardID)
end
function logic_card_collection_season:GetCardShowDataByOrderInfo(orderInfo)
  local cardConfig
  local show_data = {
    give_card_list = {},
    expect_card = nil
  }
  if orderInfo.data.give_card_list then
    for _, itemID in ipairs(orderInfo.data.give_card_list) do
      cardConfig = CDataTable.GetTableDataByFilter("CardCollectionCardConfig", "ItemID", itemID)
      table.insert(show_data.give_card_list, {show_data = cardConfig, itemID = itemID})
    end
  end
  if orderInfo.data.expect_res_id then
    cardConfig = CDataTable.GetTableDataByFilter("CardCollectionCardConfig", "ItemID", orderInfo.data.expect_res_id)
    show_data.expect_card = {
      show_data = cardConfig,
      itemID = orderInfo.data.expect_res_id
    }
  end
  if orderInfo.data.gift_card_id then
    cardConfig = CDataTable.GetTableDataByFilter("CardCollectionCardConfig", "ItemID", orderInfo.data.gift_card_id)
    show_data.gift_card = {
      show_data = cardConfig,
      itemID = orderInfo.data.gift_card_id
    }
  end
  return show_data
end
function logic_card_collection_season:GetSeasonSetData()
  if not self:_EnsureSeasonData() then
    return
  end
  log_tree("[CardCollection] logic_card_collection_season:GetSeasonSetData season data", self.season_data)
  local seasonID = self:GetSeasonIDByClientVersion()
  local setConfigTable = CDataTable.GetTableByFilter(self.regionConfig.Set, "SeasonID", seasonID)
  local res = {}
  local setIDToIndex = {}
  local setData
  if setConfigTable then
    for setID, v in pairs(setConfigTable) do
      setData = self.season_data[setID] or {}
      table.insert(res, {
        count = setData.count or 0,
        show_data = v
      })
      setIDToIndex[setID] = #res
    end
  end
  return res, setIDToIndex
end
function logic_card_collection_season:IsTodayCanDrift()
  if self:IsOldVersion() then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:IsTodayCanDrift is old version")
    return
  end
  return self.isTodayCanDrift or false
end
function logic_card_collection_season:IsTodayCanGetDrift()
  if self:IsOldVersion() then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:IsTodayCanGetDrift is old version")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local lastReqTime = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionDriftBottleReqTime) or 0
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and string.format("[CardCollection] logic_card_collection_season:IsTodayCanGetDrift lastReqTime: %d, currentTime: %d", lastReqTime, currentTime))
  return currentTime - lastReqTime >= QUERY_DRIFT_BOTTLE_INTERVAL
end
function logic_card_collection_season:SwapOutsideShare(give_card_list, expect_res_id)
  self:GenSwapOrder(give_card_list, expect_res_id)
  function self.SwapOutsideShareCallBack(give_card_list, expect_res_id, short_order_id, create_time)
    CardCollectionSeasonHandler.send_card_collect_share_exchange_req(short_order_id, 2)
    CardCollectionUtil.OpenSwapShare(give_card_list, expect_res_id, short_order_id, create_time)
  end
end
function logic_card_collection_season:GetCardIsNew(cardID)
  if not cardID then
    return false
  end
  if not self.last_season_data then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:GetCardIsNew last_season_data is nil, return false")
    return false
  end
  if self.IsNewMap[cardID] then
    log(bWriteLog and string.format("[CardCollection] logic_card_collection_season:GetCardIsNew cardID:%s already in IsNewMap, return false", tostring(cardID)))
    return false
  end
  local isNew = true
  for _, setData in pairs(self.last_season_data) do
    if type(setData) == "table" and type(setData.cards) == "table" and isNew then
      isNew = not setData.cards[cardID]
    end
  end
  self.IsNewMap[cardID] = true
  log(bWriteLog and string.format("[CardCollection] logic_card_collection_season:GetCardIsNew cardID:%s isNew:%s", tostring(cardID), tostring(isNew)))
  return isNew
end
function logic_card_collection_season:GetCardCollectionLevelByScore(score)
  local levelConfig = CDataTable.GetTable("CardScoreLevelCfg")
  local level = 1
  for i, v in pairs(levelConfig) do
    if score < v.MinScore then
      return level
    end
    level = v.Level
  end
  return level
end
function logic_card_collection_season:GetSelfCareerScore()
  if not self.summary_data then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:GetSelfCareerScore summary_data is nil, return 0")
    return 0
  end
  return self.summary_data.career_score or 0
end
function logic_card_collection_season:GetCardListBySetID(setID)
  local tableData = CDataTable.GetTableByFilter("CardCollectionCardConfig", "SetID", setID)
  if not tableData then
    return {}
  end
  local specialIdSet = {}
  local cardList = {}
  for _, cardCfg in pairs(tableData) do
    local specialID = cardCfg.SpecialID or 0
    if specialID == 0 then
      table.insert(cardList, {show_data = cardCfg})
    elseif not specialIdSet[specialID] then
      specialIdSet[specialID] = true
      table.insert(cardList, {show_data = cardCfg})
    end
  end
  return cardList
end
function logic_card_collection_season:GetCardListBySeasonID(seasonID)
  local TableUtil = require("common.table_util")
  local setList = CDataTable.GetTableByFilter(self.regionConfig.Set, "SeasonID", seasonID)
  if not setList then
    return {}
  end
  local cardList = {}
  for _, setCfg in pairs(setList) do
    TableUtil.TableConcat(cardList, self:GetCardListBySetID(setCfg.SetID))
  end
  return cardList
end
function logic_card_collection_season:GetAdditionalAwardBySetID(setID)
  if not setID then
    return nil
  end
  local additionalAward = CDataTable.GetTableByFilter("CardCollectionSetSpecialAward", "SetID", setID)
  if not additionalAward then
    return nil
  end
  local res = {}
  for _, v in pairs(additionalAward) do
    table.insert(res, v)
  end
  return res
end
function logic_card_collection_season:GetSwapLimit()
  local limitDay = CDataTable.GetTableData("CardCollectionParamConfig", "order_interval_day")
  local validDay = CDataTable.GetTableData("CardCollectionParamConfig", "order_expire_day")
  return tonumber(limitDay.ParamValue), tonumber(validDay.ParamValue)
end
function logic_card_collection_season:GetGiftLimit()
  local limitIntimacy = CDataTable.GetTableData("CardCollectionParamConfig", "gift_card_intimacy")
  local limitDay = CDataTable.GetTableData("CardCollectionParamConfig", "gift_card_day_limit")
  return tonumber(limitDay.ParamValue), tonumber(limitIntimacy.ParamValue)
end
function logic_card_collection_season:MergeOldCardList()
  if not self.summary_data then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:MergeOldCardList summary_data is nil, skip")
    return
  end
  if self.summary_data.card_collect_migration_v1_completed == 1 then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:MergeOldCardList already merged, skip")
    return
  end
  CardCollectionSeasonHandler.send_card_collect_history_click_req()
end
function logic_card_collection_season:QueryGetDriftBottle()
  if self:IsOldVersion() then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:QueryGetDriftBottle is old version")
    return
  end
  if self:IsTodayCanGetDrift() then
    CardCollectionSeasonHandler.send_card_collect_get_bottle_req()
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local TimeUtil = require("client.common.time_util")
    PlayerPrefsSystem.SaveTableToFile_N(TimeUtil.GetServerTimeInSec(), PlayerPrefsSystem.ePlayerPrefsType.eCardCollectionDriftBottleReqTime)
  end
end
function logic_card_collection_season:ShowGetDriftBottle()
  log(bWriteLog and "[CardCollection] logic_card_collection_season:ShowGetDriftBottle")
  local driftData = logic_card_collection_cache.LoadDriftBottleData()
  if not driftData or not next(driftData) then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:ShowGetDriftBottle not data")
    return
  end
  log_tree(bWriteLog and "[CardCollection] logic_card_collection_season:ShowGetDriftBottle driftData", driftData)
  for _, v in ipairs(driftData) do
    CardCollectionUtil.OpenPopup(popupType.GetDrift, {
      awardList = v.awardList,
      senderUid = v.senderUid
    })
  end
  logic_card_collection_cache.ClearDriftBottleData()
end
function logic_card_collection_season:ShowClaimCard()
  log(bWriteLog and "[CardCollection] logic_card_collection_season:ShowClaimCard")
  local cacheList = logic_card_collection_cache.LoadClaimData()
  if not cacheList or not next(cacheList) then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:ShowClaimCard no data")
    return
  end
  log_tree(bWriteLog and "[CardCollection] logic_card_collection_season:ShowClaimCard cacheList", cacheList)
  for _, entry in ipairs(cacheList) do
    local extendData
    if entry.fromType then
      extendData = {
        from = entry.fromType,
        uid = entry.senderUid,
        nickName = entry.senderName or ""
      }
    end
    if entry.awardList then
      for _, item in ipairs(entry.awardList) do
        local panelExtendData = {}
        if extendData then
          for k, v in pairs(extendData) do
            panelExtendData[k] = v
          end
        end
        panelExtendData.bSkipRefresh = true
        CardCollectionUtil.CardGetPanel({item}, nil, panelExtendData)
      end
    end
  end
  logic_card_collection_cache.ClearClaimData()
end
function logic_card_collection_season:GetPackAlreadyBuyNum(packID)
  return self.compose_card_day_limit[packID] or 0
end
function logic_card_collection_season:OnPackGetNotify(data)
  log_tree("[CardCollection] logic_card_collection_season:OnPackGetNotify", data)
  local time_ticker = require("common.time_ticker")
  local timer
  timer = time_ticker.AddTimerLoop(0, function()
    if self:IsCardPackPaused() then
      return
    end
    if not UIManager.GetUI(UIManager.UI_Config.Common_ItemGet_UIBP) then
      log(bWriteLog and "[CardCollection] logic_card_collection_season:OnPackGetNotify show")
      CardCollectionUtil.OpenPopup(popupType.Removal, data)
      time_ticker.RemoveTimer(timer)
    end
  end, TIMER_INFINITE, 1)
end
function logic_card_collection_season:GetCardPersonlizedData(cardID, setID)
  local res = {}
  if not self.season_data or not cardID then
    return res
  end
  if not setID then
    local cardConfig = CDataTable.GetTableData("CardCollectionCardConfig", cardID)
    if not cardConfig then
      return res
    end
    setID = cardConfig.SetID
  end
  local seriesData = self.season_data[setID]
  if not seriesData or not seriesData.cards then
    return res
  end
  local cardData = seriesData.cards[cardID]
  if not cardData then
    return res
  end
  res.seq = cardData.seq
  return res
end
function logic_card_collection_season:MatchCardFilter(cardConfig, filter)
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
function logic_card_collection_season:IsConfigOnline(config, currentTime)
  if config.IsTimeOnline ~= 1 then
    return true
  end
  if not config.OnlineTime or config.OnlineTime == "" then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  return currentTime >= TimeUtil.TimeStringToUnixstamp(config.OnlineTime)
end
function logic_card_collection_season:IsInRemovalBlackList(reason, subreason)
  if not reason or reason == 0 or not subreason then
    return false
  end
  local reasonOnly = CDataTable.GetTableDataByFilter("RemovalBlackList", "reason", reason, "subreason", 0)
  if reasonOnly then
    return true
  end
  if subreason ~= 0 then
    local subReasonHit = CDataTable.GetTableDataByFilter("RemovalBlackList", "reason", reason, "subreason", subreason)
    if subReasonHit then
      return true
    end
  end
  return false
end
function logic_card_collection_season:QuerySwapClaimOnLogin()
  log(bWriteLog and "[CardCollection] logic_card_collection_season:QuerySwapClaimOnLogin")
  self.QuerySwapClaimTimer = self:AddTimerOnce(600, function()
    log(bWriteLog and "[CardCollection] logic_card_collection_season:QuerySwapClaimOnLogin send_card_collect_claim_award_req")
    CardCollectionSeasonHandler.send_card_collect_claim_award_req("exchange_sender")
  end)
end
function logic_card_collection_season:QuerySwapAndGiftClaim()
  log(bWriteLog and "[CardCollection] logic_card_collection_season:QuerySwapAndGiftClaim")
  if self.QuerySwapClaimTimer then
    self:RemoveTimer(self.QuerySwapClaimTimer)
    self.QuerySwapClaimTimer = nil
  end
  CardCollectionSeasonHandler.send_card_collect_claim_award_req("exchange_sender")
  CardCollectionSeasonHandler.send_card_collect_claim_award_req("gift_receive")
end
function logic_card_collection_season:_GetTodayDateStr()
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.OSDate("!%Y%m%d", TimeUtil.GetServerTimeInSec())
end
function logic_card_collection_season:_EnsureSeasonData()
  if not self.season_data then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:_EnsureSeasonData not season data")
    CardCollectionSeasonHandler.send_card_collect_query_season_data_req(self:GetSeasonIDByClientVersion(), false)
    return false
  end
  return true
end
function logic_card_collection_season:_GetSeasonSetTable()
  local season_id = self:GetSeasonIDByClientVersion()
  return CDataTable.GetTableByFilter(self.regionConfig.Set, "SeasonID", season_id)
end
function logic_card_collection_season:_IterateSeasonCards(callback)
  local seasonData = self.season_data
  for _, setData in pairs(seasonData) do
    if type(setData) == "table" then
      local cards = setData.cards
      for cardID, cardInfo in pairs(cards) do
        local cardConfig = CDataTable.GetTableData("CardCollectionCardConfig", cardID)
        callback(cardID, cardInfo, cardConfig)
      end
    end
  end
end
function logic_card_collection_season:GetSpecialCardConfig(specialID)
  if not specialID or specialID == 0 then
    return nil
  end
  if not self._specialCardConfigCache then
    self._specialCardConfigCache = CDataTable.GetTable("SpecialCardConfig") or {}
  end
  return self._specialCardConfigCache[specialID]
end
function logic_card_collection_season:GetSignAnimPathBySpecialID(specialID)
  local cfg = self:GetSpecialCardConfig(specialID)
  if cfg and cfg.SignAnimPath and cfg.SignAnimPath ~= "" then
    return cfg.SignAnimPath
  end
  return nil
end
function logic_card_collection_season:GetSignAnimPathByCardID(cardID)
  local cardCfg = CDataTable.GetTableData("CardCollectionCardConfig", cardID)
  if not (cardCfg and cardCfg.SpecialID) or cardCfg.SpecialID == 0 then
    return nil
  end
  return self:GetSignAnimPathBySpecialID(cardCfg.SpecialID)
end
function logic_card_collection_season:GetSignAnimPathByItemID(itemID)
  local cardCfg = CDataTable.GetTableDataByFilter("CardCollectionCardConfig", "ItemID", itemID)
  if not (cardCfg and cardCfg.SpecialID) or cardCfg.SpecialID == 0 then
    return nil
  end
  return self:GetSignAnimPathBySpecialID(cardCfg.SpecialID)
end
function logic_card_collection_season:_BuildCardListWithSpecialGroup(tableData, cardsOwned, extraDataFn)
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
function logic_card_collection_season:_GetSenderName()
end
function logic_card_collection_season:UpdateCardCountCache(tResIdCountMap)
  if not tResIdCountMap then
    return
  end
  for resid, count in pairs(tResIdCountMap) do
    local nResId = tonumber(resid) or 0
    if 0 < nResId then
      self._tCardCountCache[nResId] = tonumber(count) or 0
    end
  end
  log_tree(bWriteLog and "logic_card_collection_season:UpdateCardCountCache self._tCardCountCache", self._tCardCountCache)
end
function logic_card_collection_season:GetCardCount(nResId)
  return self._tCardCountCache[tonumber(nResId) or 0] or 0
end
function logic_card_collection_season:HasCard(nResId)
  return self:GetCardCount(nResId) > 0
end
function logic_card_collection_season:SyncCardCountFromSetData(tSetData)
  if not tSetData or type(tSetData) ~= "table" then
    return
  end
  local cards = tSetData.cards
  if not cards then
    return
  end
  for cardID, cardInfo in pairs(cards) do
    local nCardID = tonumber(cardID) or 0
    if 0 < nCardID and type(cardInfo) == "table" then
      local data = self:GetCardShowDataByCardId(nCardID)
      self._tCardCountCache[data.show_data.ItemID] = tonumber(cardInfo.count) or 0
    end
  end
end
function logic_card_collection_season:SyncCardCountFromSeasonData(tSeasonData)
  if not tSeasonData or type(tSeasonData) ~= "table" then
    return
  end
  for _, setData in pairs(tSeasonData) do
    if type(setData) == "table" and setData.cards then
      for cardID, cardInfo in pairs(setData.cards) do
        local nCardID = tonumber(cardID) or 0
        if 0 < nCardID and type(cardInfo) == "table" then
          local data = self:GetCardShowDataByCardId(nCardID)
          if data and data.show_data then
            self._tCardCountCache[data.show_data.ItemID] = tonumber(cardInfo.count) or 0
          end
        end
      end
    end
  end
end
function logic_card_collection_season:_UpdateHistorySetDataByItemID(itemID, delta)
  if not itemID or delta == 0 then
    return
  end
  local cardConfig = CDataTable.GetTableDataByFilter("CardCollectionCardConfig", "ItemID", itemID)
  if not cardConfig then
    return
  end
  local setID = cardConfig.SetID
  local cardID = cardConfig.CardID
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
function logic_card_collection_season:on_card_collect_query_series_data_rsp(series_id, series_data)
  log_tree(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_card_collect_query_series_data_rsp series_id=%s, series_data", tostring(series_id)), series_data)
  self.set_data = self.set_data or {}
  self.set_data[series_id] = series_data
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SERIES_DATA_UPDATE, series_id, series_data)
end
function logic_card_collection_season:on_card_collect_get_score_award_rsp(seg_id, award_item)
  log_tree(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_card_collect_get_score_award_rsp seg_id=%s, award_item", tostring(seg_id)), award_item)
  self.summary_data.score_award[seg_id] = 1
  local card_collection_reddot_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.card_collection_reddot_data)
  card_collection_reddot_data:RefreshScoreAwardRedDot()
  if award_item then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(award_item)
  end
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SCORE_AWARD_RECEIVED, seg_id, award_item)
end
function logic_card_collection_season:on_card_collect_get_collect_award_rsp(series_id, award_item)
  log_tree(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_card_collect_get_collect_award_rsp series_id=%s, award_item", tostring(series_id)), award_item)
  if award_item then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(award_item)
  end
  if self.season_data[series_id] then
    self.season_data[series_id].collect_award = 1
  elseif self.set_data[series_id] then
    self.set_data[series_id].collect_award = 1
  end
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_COLLECT_AWARD_RECEIVED, series_id, award_item)
end
function logic_card_collection_season:on_card_collect_query_summary_data_rsp(summary_data, card_depot_data)
  log_tree(bWriteLog and "[CardCollection] logic_card_collection_season:on_card_collect_query_summary_data_rsp summary_data", summary_data)
  log_tree(bWriteLog and "[CardCollection] logic_card_collection_season:on_card_collect_query_summary_data_rsp card_depot_data", card_depot_data)
  self.  self.server_season_id = summary_data.season_id
  self.compose_card_day_limit = card_depot_data.compose_card_day_limit
  self.isCanGetDrift = card_depot_data.get_bottle_count_today and card_depot_data.get_bottle_count_today == 0
  self.isTodayCanDrift = card_depot_data.send_bottle_count_today and card_depot_data.send_bottle_count_today == 0
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SUMMARY_DATA_UPDATE, summary_data)
end
function logic_card_collection_season:on_card_collect_query_season_data_rsp(season_id, season_data)
  log_tree(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_card_collect_query_season_data_rsp season_id=%d, season_data", season_id), season_data)
  self.last_season_data = self.season_data
  self.  self:SyncCardCountFromSeasonData(season_data)
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SEASON_DATA_UPDATE, season_data)
end
function logic_card_collection_season:on_card_collect_query_show_info_rsp(target_uid, show_info)
  log_tree(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_card_collect_query_show_info_rsp target_uid=%s, show_info", tostring(target_uid)), show_info)
  self.show_infoMap[target_uid] = show_info
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_FIND_SERIES_RSP, target_uid, show_info)
end
function logic_card_collection_season:on_card_collect_set_show_series_id_rsp(show_series_id)
  log(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_card_collect_set_show_series_id_rsp show_series_id=%s", tostring(show_series_id)))
  self.  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SET_CURSHOW_SERIESID, show_series_id)
end
function logic_card_collection_season:on_card_collect_get_bottle_rsp(award_list, send_uid)
  log(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_card_collect_get_bottle_rsp res_id=%s, send_uid=%s", tostring(award_list.res_id), tostring(send_uid)))
  logic_card_collection_cache.SaveDriftBottleData(award_list, send_uid)
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_GET_DRIFT_BOTTLE, award_list, send_uid)
  if self.GM_DirectShowGetDriftBottle then
    self:ShowGetDriftBottle()
  end
end
function logic_card_collection_season:on_card_collect_get_exchange_list_rsp(order_type, offset, count, total_count, exchange_list)
  log_tree("[CardCollection] logic_card_collection_season:on_card_collect_get_exchange_list_rsp exchange_list", exchange_list)
  log(bWriteLog and string.format("[CardCollection] on_card_collect_get_exchange_list_rsp order_type=%s, offset=%s, count=%s, total_count=%s", tostring(order_type), tostring(offset), tostring(count), tostring(total_count)))
  self.pendingExchangeCardMap = {}
  if exchange_list then
    for _, orderInfo in pairs(exchange_list) do
      orderInfo.show_data = self:GetCardShowDataByOrderInfo(orderInfo)
      if orderInfo.order_status == 0 then
        for _, cardId in ipairs(orderInfo.data.give_card_list) do
          self.pendingExchangeCardMap[cardId] = 1
        end
        self.pendingExchangeCardMap[orderInfo.data.expect_res_id] = 1
      end
    end
    local TableUtil = require("common.table_util")
    TableUtil.TableConcat(self.exchangeListPage[order_type].list, exchange_list)
    self.exchangeListPage[order_type].offset = offset + count
    table.sort(self.exchangeListPage[order_type].list, function(a, b)
      return (a.order_id or 0) > (b.order_id or 0)
    end)
    if count == EXCHANGE_LIST_OFFSET then
      CardCollectionSeasonHandler.send_card_collect_get_exchange_list_req(order_type, self.exchangeListPage[order_type].offset)
    end
  end
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_EXCHANGE_LIST_UPDATE, self.exchangeListPage[order_type].list)
end
function logic_card_collection_season:on_card_collect_batch_decompose_rsp(card_list, card_pieces_list)
  log_tree(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_card_collect_batch_decompose_rsp pieces=%d, card_list", card_pieces_list[1].count), card_list)
  log_tree(bWriteLog and "[CardCollection] logic_card_collection_season:on_card_collect_batch_decompose_rsp card_pieces_list", card_pieces_list)
  self:RefreshSeasonData()
  if card_list then
    for itemID, count in pairs(card_list) do
      if itemID then
        self:_UpdateHistorySetDataByItemID(itemID, -count)
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_DECOMPOSE_RESULT, card_pieces_list[1].count)
end
function logic_card_collection_season:on_card_collect_compose_card_pack_rsp(card_pack_id, card_pack_count, card_list, compose_card_day_limit)
  log_tree(string.format("[CardCollection] logic_card_collection_season:on_card_collect_compose_card_pack_rsp pack_id=%s, num=%s, card_list", tostring(card_pack_id), tostring(card_pack_count)), card_list)
  log_tree("[CardCollection] logic_card_collection_season:on_card_collect_compose_card_pack_rsp compose_card_day_limit", compose_card_day_limit)
  local data = {
    card_pack_id = card_pack_id,
    card_list = card_list,
      }
  CardCollectionUtil.OpenPopup(popupType.Removal, data)
  self.  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_COMPOSE_RESULT, card_pack_id, card_pack_count, card_list)
end
function logic_card_collection_season:on_card_collect_gen_exchange_rsp(give_card_list, expect_res_id, short_order_id, create_time)
  log_tree(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_card_collect_gen_exchange_rsp order_id=%s, expect_res_id=%s, create_time=%s, give_card_list", tostring(short_order_id), tostring(expect_res_id), tostring(create_time)), give_card_list)
  if self.FriendSwapCallBack then
    self.FriendSwapCallBack(give_card_list, expect_res_id, short_order_id)
    self.FriendSwapCallBack = nil
  end
  if self.SwapOutsideShareCallBack then
    self.SwapOutsideShareCallBack(give_card_list, expect_res_id, short_order_id, create_time)
    self.SwapOutsideShareCallBack = nil
  end
  self:RefreshSeasonData()
  if give_card_list then
    for _, itemID in ipairs(give_card_list) do
      self:_UpdateHistorySetDataByItemID(itemID, -1)
    end
  end
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_GEN_EXCHANGE_RESULT, give_card_list, expect_res_id, short_order_id)
end
function logic_card_collection_season:on_card_collect_cancel_exchange_rsp(order_id)
  log(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_card_collect_cancel_exchange_rsp order_id=%s", tostring(order_id)))
  ShowNotice(LocUtil.GetLocalizeResStr(33020173))
  self:QuerySwapHistory()
  self:RefreshSeasonData()
  self.set_data = {}
end
function logic_card_collection_season:on_card_collect_deal_exchange_rsp(order_id, select_card_id)
  log(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_card_collect_deal_exchange_rsp order_id=%s, select_card_id=%s", tostring(order_id), tostring(select_card_id)))
  CardCollectionUtil.CardGetPanel({
    {res_id = select_card_id}
  })
  self:RefreshSeasonData()
  self.set_data = {}
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_DEAL_EXCHANGE_RESULT, order_id, select_card_id)
end
function logic_card_collection_season:on_card_collect_gift_card_rsp(card_id, receive_uid)
  log(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_card_collect_gift_card_rsp card_id=%s, receive_uid=%s", tostring(card_id), tostring(receive_uid)))
  ShowNotice(LocUtil.GetLocalizeResStr(33020178))
  self:RefreshSeasonData()
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_GIFT_CARD_RESULT, card_id, receive_uid)
end
function logic_card_collection_season:on_card_collect_get_exchange_rsp(order_info)
  log_tree(bWriteLog and "[CardCollection] logic_card_collection_season:on_card_collect_get_exchange_rsp order_info", order_info)
  if order_info then
    order_info.show_data = self:GetCardShowDataByOrderInfo(order_info)
  end
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_GET_EXCHANGE_RESULT, order_info)
end
function logic_card_collection_season:on_card_collect_get_newbie_card_rsp(register_years, collect_level, card_list)
  if not register_years then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:on_card_collect_get_newbie_card_rsp register_years is nil")
    return
  end
  log_tree(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_card_collect_get_newbie_card_rsp register_years=%s, collect_level=%s, card_list", tostring(register_years), tostring(collect_level)), card_list)
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_GET_NEWBIE_CARD, register_years, collect_level, card_list)
end
function logic_card_collection_season:on_card_collect_claim_award_rsp(claim_type, order_count, award_list, dealer_uid_list)
  log_tree(string.format("[CardCollection] logic_card_collection_season:on_card_collect_claim_award_rsp claim_type=%s, order_count=%s, award_list", tostring(claim_type), tostring(order_count)), award_list)
  log_tree(string.format("[CardCollection] logic_card_collection_season:on_card_collect_claim_award_rsp uid list"), dealer_uid_list)
  if self.DelayRefreshDataTimer then
    self:RemoveTimer(self.DelayRefreshDataTimer)
    self.DelayRefreshDataTimer = nil
  end
  self.DelayRefreshDataTimer = self:AddTimerOnce(0.2, function()
    self:RefreshSeasonData()
    self.DelayRefreshDataTimer = nil
  end)
  if order_count < 1 then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:on_card_collect_claim_award_rsp award_list is nil")
    return
  end
  local fromType = CardSourceType[claim_type]
  local uid = dealer_uid_list[1]
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if profile then
    logic_card_collection_cache.SaveClaimData(award_list, fromType, uid, profile.nickName or "")
  else
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      tonumber(uid)
    }, function(profileList)
      local nickName = ""
      if profileList and 0 < #profileList then
        nickName = profileList[1].nickName or ""
      end
      logic_card_collection_cache.SaveClaimData(award_list, fromType, uid, nickName)
    end, Enum_PROFILE_REPORT_CFG.CARD_COLLECTION, nil, true)
  end
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_CLAIM_AWARD_RESULT, claim_type, order_count, award_list, dealer_uid_list)
end
function logic_card_collection_season:on_card_collect_send_bottle_rsp(bottle_card_id, send_type, award_list)
  log_tree(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_card_collect_send_bottle_rsp bottle_card_id=%s, send_type=%s, award_list", tostring(bottle_card_id), tostring(send_type)), award_list)
  self.isTodayCanDrift = false
  local cardData = self:GetCardShowDataByItemId(bottle_card_id)
  if cardData then
    local setID = cardData.SetID
    local cardID = cardData.CardID
    if self.season_data and self.season_data[setID] and self.season_data[setID].cards and self.season_data[setID].cards[cardID] then
      self.season_data[setID].cards[cardID].count = self.season_data[setID].cards[cardID].count - 1
    else
      self:_UpdateHistorySetDataByItemID(bottle_card_id, -1)
    end
  end
  local data = {
    card_pack_id = bottle_card_id,
    card_list = award_list,
    card_pack_count = 1,
    extendData = {nickName = ""}
  }
  CardCollectionUtil.OpenPopup(popupType.Removal, data)
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SEND_BOTTLE_RESULT, bottle_card_id)
end
function logic_card_collection_season:on_card_collect_series_finish_ntf(series_id, season_id, card_id)
  log(bWriteLog and string.format("[CardCollection] logic_card_collection_season.on_card_collect_series_finish_ntf series_id: %s, season_id: %s, card_id: %s", tostring(series_id), tostring(season_id), tostring(card_id)))
  self:RefreshSeasonData()
  local setCompletionData = {
    completionType = 0,
    setID = series_id,
    cardID = card_id
  }
  CardCollectionUtil.OpenPopup(popupType.Completion, {data = setCompletionData})
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SERIES_FINISH, series_id, season_id, card_id)
end
function logic_card_collection_season:on_card_collect_season_finish_ntf(season_id)
  log(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_card_collect_season_finish_ntf season_id=%s", tostring(season_id)))
  if not season_id or type(season_id) ~= "number" then
    return
  end
  if season_id ~= self:GetSeasonIDByClientVersion() then
    log(bWriteLog and "[CardCollection] logic_card_collection_season:on_card_collect_season_finish_ntf season_id ~= self:GetSeasonIDByClientVersion()")
    return
  end
  self:RefreshSeasonData()
  local seasonCompletionData = {completionType = 1, seasonID = season_id}
  CardCollectionUtil.OpenPopup(popupType.Completion, {data = seasonCompletionData})
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SEASON_FINISH, season_id)
end
function logic_card_collection_season:on_card_collect_history_click_rsp(migrated_item_ids, get_card_collect_data)
  log_tree(bWriteLog and "[CardCollection] logic_card_collection_season:on_card_collect_history_click_rsp migrated_item_ids", migrated_item_ids)
  log_tree(bWriteLog and "[CardCollection] logic_card_collection_season:on_card_collect_history_click_rsp get_card_collect_data", get_card_collect_data)
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
function logic_card_collection_season:on_add_card_pack_result_notify(card_pack_id, card_pack_count, card_list, reason, subreason)
  log(bWriteLog and string.format("[CardCollection] logic_card_collection_season:on_add_card_pack_result_notify card_pack_id=%s, card_pack_count=%s, reason=%s, subreason=%s", tostring(card_pack_id), tostring(card_pack_count), tostring(reason), tostring(subreason)))
  log_tree("[CardCollection] logic_card_collection_season:on_add_card_pack_result_notify card_list", card_list)
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_ADD_PACK_RESULT, card_pack_id, card_pack_count, card_list, reason, subreason)
  if self:IsInRemovalBlackList(reason, subreason) then
    log(bWriteLog and string.format("[CardCollection] on_add_card_pack_result_notify reason=%s subreason=%s hit RemovalBlackList, skip", tostring(reason), tostring(subreason)))
    return
  end
  local data = {
    card_pack_id = card_pack_id,
    card_pack_count = card_pack_count,
    card_list = card_list,
    reason = reason,
      }
  self:OnPackGetNotify(data)
end
function logic_card_collection_season:SendCardCollectionSwapRequest(friendUid, giveCardList, expectResId)
  if not friendUid then
    log(bWriteLog and "[CardCollection] SendCardCollectionSwapRequest invalid param, missing friendUid")
    return
  end
  log(bWriteLog and string.format("[CardCollection] SendCardCollectionSwapRequest friendUid=%s", tostring(friendUid)))
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  if not logic_chat_channel_friend.CanSendMsg(friendUid) then
    log(bWriteLog and string.format("[CardCollection] SendCardCollectionSwapRequest can't send msg to %s", tostring(friendUid)))
    return
  end
  local give_card_list = {}
  for _, v in ipairs(giveCardList) do
    table.insert(give_card_list, v.show_data.ItemID)
  end
  CardCollectionSeasonHandler.send_card_collect_gen_exchange_req(give_card_list, expectResId)
  function self.FriendSwapCallBack(rsp_give_card_list, rsp_expect_res_id, rsp_short_order_id)
    local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
    local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
    local ChatHandler = require("client.network.Protocol.ChatHandler")
    local TimeUtil = require("client.common.time_util")
    local msg = {
      text = LocUtil.GetLocalizeResStr(33020197),
      sendTime = TimeUtil.GetServerTimeInSec(),
      msgType = chat_macro.CardCollectionSwapMsgType,
      quickMsg = false,
      other = {
        give_card_list = rsp_give_card_list,
        expect_res_id = rsp_expect_res_id,
        short_order_id = rsp_short_order_id
      }
    }
    CardCollectionSeasonHandler.send_card_collect_share_exchange_req(rsp_short_order_id, 1, {friend_uid = friendUid})
    local msgId = chat_main.CacheMsg(msg)
    ChatHandler.send_chat_req(friendUid, chat_macro.Channel.channelPrivate, msgId, msg)
    ShowNotice(LocUtil.GetLocalizeResStr(33020200))
  end
end
function logic_card_collection_season:GetNewbieCardConfig(category)
  local result = {
    Level = {},
    CardID = {}
  }
  if not category then
    return result
  end
  local configTable = CDataTable.GetTableByFilter("NewbieCardConfig", "Category", category) or {}
  local sortedList = {}
  for _, config in pairs(configTable) do
    table.insert(sortedList, config)
  end
  table.sort(sortedList, function(a, b)
    return a.ID < b.ID
  end)
  for _, config in ipairs(sortedList) do
    table.insert(result.Level, config.RightBoundary)
    table.insert(result.CardID, config.CardItemID)
  end
  return result
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_card_collection_season = class(CModuleBase, nil, logic_card_collection_season)
return Clogic_card_collection_season