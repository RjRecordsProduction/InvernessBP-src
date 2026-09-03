local card_collection_reddot_data = {}
local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
local logic_card_collection_cache = require("GameLua.Mod.Lobby.Split.CardCollection.logic.logic_card_collection_cache")
local CardCollectionRedDotType = {
  CollectAward = 1,
  NewSet = 2,
  ScoreAward = 3,
  DailyTask = 4,
  Drift = 5,
  CardGet = 6,
  Claim = 7
}
local RedDotCategory = {
  [CardCollectionRedDotType.ScoreAward] = reddot_macro.Category.Receive,
  [CardCollectionRedDotType.CollectAward] = reddot_macro.Category.Receive,
  [CardCollectionRedDotType.NewSet] = reddot_macro.Category.NewArrivals,
  [CardCollectionRedDotType.DailyTask] = reddot_macro.Category.Receive,
  [CardCollectionRedDotType.Drift] = reddot_macro.Category.Receive,
  [CardCollectionRedDotType.CardGet] = reddot_macro.Category.Receive,
  [CardCollectionRedDotType.Claim] = reddot_macro.Category.Receive
}
card_collection_reddot_data.RedDotType = CardCollectionRedDotType
local SetCoverRedDotKey = {
  Root = "SetCoverMerged",
  CollectAward = "CollectAward",
  CardGet = "CardGet"
}
function card_collection_reddot_data:DefineAndResetData()
  self.redDotData = nil
end
function card_collection_reddot_data:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SEASON_DATA_UPDATE, self.RefreshCollectAwardRedDot, self)
  self:AddCommonEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SUMMARY_DATA_UPDATE, self.OnSummaryDataUpdate, self)
  self:AddCommonEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_SCORE_AWARD_RECEIVED, self.RefreshScoreAwardRedDot, self)
  self:AddCommonEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_COLLECT_AWARD_RECEIVED, self.RefreshCollectAwardRedDot, self)
  self:AddCommonEvent(EVENTTYPE_CARD_COLLECTION, EVENTID_CARDCOLLECTION_CARD_GET, self.OnCardGet, self)
  self:AddCommonEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_SYNC, self.RefreshDailyTaskRedDot, self)
  self:AddCommonEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_CHANGE, self.RefreshDailyTaskRedDot, self)
  self:AddCommonEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_OFFLINE_CHEST, self.RefreshDailyTaskRedDot, self)
end
function card_collection_reddot_data:OnLogOut()
  self.redDotData = nil
end
function card_collection_reddot_data:OnSummaryDataUpdate()
  self:RefreshScoreAwardRedDot()
  local driftModule = ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.CardCollectionDriftModule)
  driftModule:QueryGetDriftBottle()
end
function card_collection_reddot_data:OnCardGet(_, _, cardList)
  if not cardList or not next(cardList) then
    return
  end
  for _, v in ipairs(cardList) do
    self:SetCardGetRedDotByCardID(v.show_data.CardID, v.show_data.SetID)
  end
end
function card_collection_reddot_data:GetRedDotData()
  if self.redDotData == nil or not next(self.redDotData) then
    local defaultData = {
      newCount = 0,
      desc = reddot_macro.SystemName.CardCollection,
      isDynamic = true
    }
    local super_data = require("common.super_data")
    local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
    self.redDotData = super_data.CreateSuperData(defaultData)
    reddot_manager:Regist(self.redDotData)
  end
  return self.redDotData
end
function card_collection_reddot_data:_GetSubRedDotData(type, isDynamic)
  local data = self:GetRedDotData()
  if not data[type] then
    local category = RedDotCategory[type]
    local newData = {
      newCount = 0,
      subID = category or type,
          }
    newData.    data[type] = newData
  end
  return data[type]
end
function card_collection_reddot_data:_HasSubRedDot(type)
  local data = self:_GetSubRedDotData(type)
  local hasRedDot = data.newCount > 0
  log(bWriteLog and string.format("card_collection_reddot_data:_HasSubRedDot type=%d, result=%s", type, tostring(hasRedDot)))
  return hasRedDot
end
function card_collection_reddot_data:_SetSubRedDot(type, newCount)
  log(bWriteLog and string.format("card_collection_reddot_data:_SetSubRedDot type=%d, newCount=%d", type, newCount))
  local data = self:_GetSubRedDotData(type)
  local oldCount = data.newCount or 0
  data.end
function card_collection_reddot_data:_UpdateRootNewCount(delta)
  local rootData = self:GetRedDotData()
  local newTotal = (rootData.newCount or 0) + delta
  if newTotal < 0 then
    newTotal = 0
  end
  log(bWriteLog and string.format("card_collection_reddot_data:_UpdateRootNewCount delta=%d, newTotal=%d", delta, newTotal))
  rootData.newCount = newTotal
end
function card_collection_reddot_data:_GetSetCoverRootRedDotData()
  local data = self:GetRedDotData()
  if not data[SetCoverRedDotKey.Root] then
    data[SetCoverRedDotKey.Root] = {newCount = 0, isDynamic = true}
  end
  return data[SetCoverRedDotKey.Root]
end
function card_collection_reddot_data:GetSetCoverRedDotData(setID)
  local parentData = self:_GetSetCoverRootRedDotData()
  if not parentData[setID] then
    parentData[setID] = {newCount = 0, isDynamic = true}
  end
  return parentData[setID]
end
function card_collection_reddot_data:_GetSetCoverAwardRedDotData(setID)
  local setCoverRedDotData = self:GetSetCoverRedDotData(setID)
  if not setCoverRedDotData[SetCoverRedDotKey.CollectAward] then
    setCoverRedDotData[SetCoverRedDotKey.CollectAward] = {
      newCount = 0,
      subID = CardCollectionRedDotType.CollectAward,
      category = RedDotCategory[CardCollectionRedDotType.CollectAward]
    }
  end
  return setCoverRedDotData[SetCoverRedDotKey.CollectAward]
end
function card_collection_reddot_data:_GetSetCoverCardGetRedDotData(setID)
  local setCoverRedDotData = self:GetSetCoverRedDotData(setID)
  if not setCoverRedDotData[SetCoverRedDotKey.CardGet] then
    setCoverRedDotData[SetCoverRedDotKey.CardGet] = {
      newCount = 0,
      isDynamic = true,
      subID = CardCollectionRedDotType.CardGet,
      category = RedDotCategory[CardCollectionRedDotType.CardGet]
    }
  end
  return setCoverRedDotData[SetCoverRedDotKey.CardGet]
end
function card_collection_reddot_data:GetDailyTaskRedDotData()
  return self:_GetSubRedDotData(CardCollectionRedDotType.DailyTask)
end
function card_collection_reddot_data:HasScoreAwardRedDot()
  return self:_HasSubRedDot(CardCollectionRedDotType.ScoreAward)
end
function card_collection_reddot_data:SetScoreAwardRedDot()
  log(bWriteLog and "card_collection_reddot_data:SetScoreAwardRedDot")
  self:_SetSubRedDot(CardCollectionRedDotType.ScoreAward, 1)
end
function card_collection_reddot_data:CloseScoreAwardRedDot()
  if not self:HasScoreAwardRedDot() then
    return
  end
  log(bWriteLog and "card_collection_reddot_data:CloseScoreAwardRedDot")
  self:_SetSubRedDot(CardCollectionRedDotType.ScoreAward, 0)
end
function card_collection_reddot_data:RefreshScoreAwardRedDot()
  log(bWriteLog and "card_collection_reddot_data:RefreshScoreAwardRedDot")
  local awardModule = ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.CardCollectionAwardModule)
  if awardModule:HasCanReceiveScoreAward() then
    self:SetScoreAwardRedDot()
  else
    self:CloseScoreAwardRedDot()
  end
end
function card_collection_reddot_data:GetCollectAwardRedDotData(setID)
  return self:_GetSetCoverAwardRedDotData(setID)
end
function card_collection_reddot_data:HasCollectAwardRedDot(setID)
  local data = self:GetCollectAwardRedDotData(setID)
  return data.newCount > 0
end
function card_collection_reddot_data:SetCollectAwardRedDot(setID)
  log(bWriteLog and string.format("card_collection_reddot_data:SetCollectAwardRedDot setID=%s", tostring(setID)))
  local data = self:GetCollectAwardRedDotData(setID)
  data.newCount = 1
end
function card_collection_reddot_data:CloseCollectAwardRedDot(setID)
  if not self:HasCollectAwardRedDot(setID) then
    return
  end
  log(bWriteLog and string.format("card_collection_reddot_data:CloseCollectAwardRedDot setID=%s", tostring(setID)))
  local data = self:GetCollectAwardRedDotData(setID)
  data.newCount = 0
end
function card_collection_reddot_data:RefreshCollectAwardRedDot()
  log(bWriteLog and "card_collection_reddot_data:RefreshCollectAwardRedDot")
  local setModule = ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.CardCollectionSetModule)
  setModule:RefreshAllCollectAwardRedDot(self)
end
function card_collection_reddot_data:GetNewSetRedDotData(setID)
  local parentData = self:_GetSubRedDotData(CardCollectionRedDotType.NewSet)
  if not parentData[setID] then
    parentData[setID] = {
      newCount = 0,
      subID = CardCollectionRedDotType.NewSet,
      category = RedDotCategory[CardCollectionRedDotType.NewSet]
    }
  end
  return parentData[setID]
end
function card_collection_reddot_data:HasNewSetRedDot(setID)
  local data = self:GetNewSetRedDotData(setID)
  return data.newCount > 0
end
function card_collection_reddot_data:SetNewSetRedDot(setID)
  log(bWriteLog and string.format("card_collection_reddot_data:SetNewSetRedDot setID=%s", tostring(setID)))
  local data = self:GetNewSetRedDotData(setID)
  data.newCount = 1
end
function card_collection_reddot_data:CloseNewSetRedDot(setID)
  if not self:HasNewSetRedDot(setID) then
    return
  end
  log(bWriteLog and string.format("card_collection_reddot_data:CloseNewSetRedDot setID=%s", tostring(setID)))
  local data = self:GetNewSetRedDotData(setID)
  data.newCount = 0
end
function card_collection_reddot_data:GetDriftRedDotData()
  return self:_GetSubRedDotData(CardCollectionRedDotType.Drift)
end
function card_collection_reddot_data:HasDriftRedDot()
  return self:_HasSubRedDot(CardCollectionRedDotType.Drift)
end
function card_collection_reddot_data:SetDriftRedDot()
  log(bWriteLog and "card_collection_reddot_data:SetDriftRedDot")
  self:_SetSubRedDot(CardCollectionRedDotType.Drift, 1)
end
function card_collection_reddot_data:CloseDriftRedDot()
  if not self:HasDriftRedDot() then
    return
  end
  log(bWriteLog and "card_collection_reddot_data:CloseDriftRedDot")
  self:_SetSubRedDot(CardCollectionRedDotType.Drift, 0)
end
function card_collection_reddot_data:RefreshDriftRedDot()
  log(bWriteLog and "card_collection_reddot_data:RefreshDriftRedDot")
  if logic_card_collection_cache.HasDriftBottleData() then
    self:SetDriftRedDot()
  else
    self:CloseDriftRedDot()
  end
end
local _GetSetIDByCardID = function(cardID)
  local cardConfig = CDataTable.GetTableData("CardCollectionCardConfig", cardID)
  if cardConfig then
    return cardConfig.SetID
  end
  return nil
end
function card_collection_reddot_data:GetCardGetRedDotData()
  return self:_GetSetCoverRootRedDotData()
end
function card_collection_reddot_data:GetCardGetRedDotDataBySetID(setID)
  return self:_GetSetCoverCardGetRedDotData(setID)
end
function card_collection_reddot_data:GetCardGetRedDotDataByCardID(cardID, setID)
  setID = setID or _GetSetIDByCardID(cardID)
  if not setID then
    return nil
  end
  local setData = self:GetCardGetRedDotDataBySetID(setID)
  if not setData[cardID] then
    setData[cardID] = {
      newCount = 0,
      subID = CardCollectionRedDotType.CardGet,
      category = RedDotCategory[CardCollectionRedDotType.CardGet]
    }
  end
  return setData[cardID]
end
function card_collection_reddot_data:HasCardGetRedDotByCardID(cardID, setID)
  local data = self:GetCardGetRedDotDataByCardID(cardID, setID)
  return data ~= nil and data.newCount > 0
end
function card_collection_reddot_data:SetCardGetRedDotByCardID(cardID, setID)
  log(bWriteLog and string.format("card_collection_reddot_data:SetCardGetRedDotByCardID cardID=%s", tostring(cardID)))
  local data = self:GetCardGetRedDotDataByCardID(cardID, setID)
  if data then
    data.newCount = 1
  end
end
function card_collection_reddot_data:CloseCardGetRedDotByCardID(cardID, setID)
  log(bWriteLog and string.format("card_collection_reddot_data:CloseCardGetRedDotByCardID cardID=%s", tostring(cardID)))
  local data = self:GetCardGetRedDotDataByCardID(cardID, setID)
  if data then
    data.newCount = 0
  end
  logic_card_collection_cache.RemoveCardGetDataByCardID(cardID)
end
function card_collection_reddot_data:RefreshCardGetRedDot()
  log(bWriteLog and "card_collection_reddot_data:RefreshCardGetRedDot")
  local cacheMap = logic_card_collection_cache.LoadCardGetData()
  if not cacheMap or not next(cacheMap) then
    return
  end
  for cardIDStr, entry in pairs(cacheMap) do
    local cardID = tonumber(cardIDStr)
    if cardID then
      self:SetCardGetRedDotByCardID(cardID, entry.setID)
    end
  end
end
function card_collection_reddot_data:HasDailyTaskRedDot()
  log(bWriteLog and "card_collection_reddot_data:HasDailyTaskRedDot")
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  local hasCommonReward = false
  local hasLoginAward = false
  for _, task in ipairs(NewDayTaskSystem.DailyTasks) do
    if task.isLoginAward then
      hasLoginAward = task.status == 1
    elseif task.status == 1 then
      hasCommonReward = true
    end
  end
  if NewDayTaskSystem.LimitTask.status == 1 then
    hasCommonReward = true
  end
  local hasOfflineBox = false
  local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
  local boxStatus = logic_theme_system:CheckOfflineChestV2CanOpen()
  hasOfflineBox = boxStatus == 1
  log(bWriteLog and string.format("card_collection_reddot_data:HasDailyTaskRedDot, hasLoginAward=%s, hasCommonReward=%s, hasOfflineBox=%s", tostring(hasLoginAward), tostring(hasCommonReward), tostring(hasOfflineBox)))
  local bHasReward = hasLoginAward or hasCommonReward or hasOfflineBox
  return bHasReward
end
function card_collection_reddot_data:RefreshDailyTaskRedDot()
  log(bWriteLog and "card_collection_reddot_data:RefreshDailyTaskRedDot")
  self:_SetSubRedDot(CardCollectionRedDotType.DailyTask, self:HasDailyTaskRedDot() and 1 or 0)
end
function card_collection_reddot_data:GetClaimRedDotData()
  return self:_GetSubRedDotData(CardCollectionRedDotType.Claim)
end
function card_collection_reddot_data:HasClaimRedDot()
  return self:_HasSubRedDot(CardCollectionRedDotType.Claim)
end
function card_collection_reddot_data:SetClaimRedDot()
  log(bWriteLog and "card_collection_reddot_data:SetClaimRedDot")
  self:_SetSubRedDot(CardCollectionRedDotType.Claim, 1)
end
function card_collection_reddot_data:CloseClaimRedDot()
  if not self:HasClaimRedDot() then
    return
  end
  log(bWriteLog and "card_collection_reddot_data:CloseClaimRedDot")
  self:_SetSubRedDot(CardCollectionRedDotType.Claim, 0)
end
function card_collection_reddot_data:RefreshClaimRedDot()
  log(bWriteLog and "card_collection_reddot_data:RefreshClaimRedDot")
  if logic_card_collection_cache.HasClaimData() then
    self:SetClaimRedDot()
  else
    self:CloseClaimRedDot()
  end
end
function card_collection_reddot_data:RefreshAllReddots()
  self:RefreshCollectAwardRedDot()
  self:RefreshScoreAwardRedDot()
  self:RefreshDriftRedDot()
  self:RefreshDailyTaskRedDot()
  self:RefreshClaimRedDot()
  self:RefreshCardGetRedDot()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, card_collection_reddot_data)