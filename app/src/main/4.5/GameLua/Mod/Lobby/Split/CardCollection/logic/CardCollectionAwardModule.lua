local CardCollectionAwardModule = {}
local CardCollectionSeasonHandler = require("GameLua.Mod.Lobby.Split.CardCollection.ModCardCollectionSeasonHandler")
function CardCollectionAwardModule:DefineAndResetData()
end
function CardCollectionAwardModule:_GetDataModule()
  return ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.CardCollectionDataModule)
end
function CardCollectionAwardModule:OnInitialize()
end
function CardCollectionAwardModule:RegistEvents()
end
function CardCollectionAwardModule:OnLogin(bReLogin)
end
function CardCollectionAwardModule:OnLogOut()
end
function CardCollectionAwardModule:OnPreSwitchGameStatus(preState, nextState)
end
function CardCollectionAwardModule:OnPostSwitchGameStatus(preState, nextState)
end
function CardCollectionAwardModule:GetSetAwardData(set_id, bIsHistory)
  local dataModule = self:_GetDataModule()
  if not dataModule:_EnsureSeasonData() then
    return
  end
  log_tree("[CardCollection] CardCollectionAwardModule:GetSetAwardData season data", dataModule:GetSeasonData())
  set_id = set_id or 1
  local regionConfig = dataModule:GetRegionConfig()
  local awardTable = CDataTable.GetSplitTableByFilter("Lobby", "CardCollection", regionConfig.CollectAward, "SetID", set_id)
  local tempData = bIsHistory and dataModule:GetAllSetData() or dataModule:GetSeasonData()
  local awardList = {}
  local itemList, itemId, itemIdKey, itemNumKey, jumpTextKey, jumpPathKey, setData
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
        local isCollected = 0 < (setData.finish_ts or 0)
        table.insert(itemList, {
          show_data = {
            ItemID = itemId,
            ItemNum = v[itemNumKey] or 0,
            JumpText = v[jumpTextKey] or "",
            JumpPath = v[jumpPathKey] or ""
          },
          status = setData.collect_award == 1 and 2 or isCollected and 1 or 0
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
function CardCollectionAwardModule:GetSeasonAwardData()
  local dataModule = self:_GetDataModule()
  local summaryData = dataModule:GetSummaryData()
  if not summaryData then
    log(bWriteLog and "[CardCollection] CardCollectionAwardModule:GetSeasonAwardData not summary data")
    CardCollectionSeasonHandler.send_card_collect_query_summary_data_req()
    return
  end
  log_tree("[CardCollection] CardCollectionAwardModule:GetSeasonAwardData summary data", summaryData)
  local regionConfig = dataModule:GetRegionConfig()
  local season_id = dataModule:GetSeasonIDByClientVersion()
  local awardTable = CDataTable.GetSplitTableByFilter("Lobby", "CardCollection", regionConfig.ScoreAward, "SeasonID", season_id)
  local awardList = {}
  if awardTable then
    for _, v in pairs(awardTable) do
      table.insert(awardList, {
        show_data = v,
        score = summaryData.season_score,
        status = summaryData.score_award[v.StageID] == 1 and 2 or summaryData.season_score >= v.StageScore and 1 or 0
      })
    end
  end
  return awardList
end
function CardCollectionAwardModule:HasCanReceiveScoreAward()
  local dataModule = self:_GetDataModule()
  local summaryData = dataModule:GetSummaryData()
  if not summaryData then
    CardCollectionSeasonHandler.send_card_collect_query_summary_data_req()
    return false
  end
  local seasonScore = summaryData.season_score or 0
  local scoreAward = summaryData.score_award or {}
  local regionConfig = dataModule:GetRegionConfig()
  local awardTable = CDataTable.GetSplitTable("Lobby", "CardCollection", regionConfig.ScoreAward)
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
function CardCollectionAwardModule:GetSeasonScore()
  local dataModule = self:_GetDataModule()
  local summaryData = dataModule:GetSummaryData()
  if not summaryData then
    return 0, 0
  end
  return summaryData.season_score
end
function CardCollectionAwardModule:GetSeasonProgress()
  local dataModule = self:_GetDataModule()
  local seasonData = dataModule:GetSeasonData()
  if not seasonData then
    return 0, 0
  end
  local setTable = dataModule:_GetSeasonSetTable()
  if not setTable then
    return 0, 0
  end
  local totalNum = 0
  local ownedNum = 0
  for _, setConfig in pairs(setTable) do
    local setID = setConfig.SetID
    local setData = seasonData[setID] or {}
    if setData then
      ownedNum = ownedNum + (setData.count or 0)
      totalNum = totalNum + (setConfig.TotalCardCount or 0)
    end
  end
  return ownedNum, totalNum
end
function CardCollectionAwardModule:IsSeasonAllCollected()
  local dataModule = self:_GetDataModule()
  local seasonData = dataModule:GetSeasonData()
  if not seasonData then
    return false
  end
  local setTable = dataModule:_GetSeasonSetTable()
  if not setTable then
    return false
  end
  for _, setConfig in pairs(setTable) do
    local setID = setConfig.SetID
    local setData = seasonData[setID] or {}
    local ownedNum = setData.count or 0
    local totalNum = setConfig.TotalCardCount or 0
    if ownedNum < totalNum then
      return false
    end
  end
  return true
end
function CardCollectionAwardModule:on_card_collect_get_score_award_rsp(seg_id, award_item)
  log_tree(bWriteLog and string.format("[CardCollection] CardCollectionAwardModule:on_card_collect_get_score_award_rsp seg_id=%s, award_item", tostring(seg_id)), award_item)
  self:_GetDataModule():SetScoreAwardClaimed(seg_id)
  local card_collection_reddot_data = ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.card_collection_reddot_data)
  card_collection_reddot_data:RefreshScoreAwardRedDot()
  if award_item then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(award_item)
  end
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SCORE_AWARD_RECEIVED, seg_id, award_item)
end
function CardCollectionAwardModule:on_card_collect_get_collect_award_rsp(series_id, award_item)
  log_tree(bWriteLog and string.format("[CardCollection] CardCollectionAwardModule:on_card_collect_get_collect_award_rsp series_id=%s, award_item", tostring(series_id)), award_item)
  if award_item then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(award_item)
  end
  self:_GetDataModule():SetCollectAwardClaimed(series_id)
  EventSystem:postEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_COLLECT_AWARD_RECEIVED, series_id, award_item)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CCardCollectionAwardModule = class(CModuleBase, nil, CardCollectionAwardModule)
return CCardCollectionAwardModule