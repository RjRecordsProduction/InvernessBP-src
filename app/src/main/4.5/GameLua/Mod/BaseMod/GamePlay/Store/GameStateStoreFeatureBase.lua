local GameStateStoreFeatureBase = {}
local StoreConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.StoreConfig")
local StoreActions = require("GameLua.Mod.BaseMod.GamePlay.Store.StoreActions")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function GameStateStoreFeatureBase:ctor()
  self.StoreData = {}
  self.BuyGoodID2GoodsListIndex = {}
  if Client then
    self.BuyGoodCounts = {}
  end
  self.tPatchGoodID2GoodListIndex = {}
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  self.nModID = GameMainConfig.GetModeID()
  self.ModType = GameMainConfig.GetModType()
  self.MapType = GameMainConfig.GetMapType()
  self.StoreRandomHideList = {}
end
function GameStateStoreFeatureBase:_PostConstruct()
  GameStateStoreFeatureBase.__super._PostConstruct(self)
end
function GameStateStoreFeatureBase:ReceiveBeginPlay()
  GameStateStoreFeatureBase.__super.ReceiveBeginPlay(self)
  if not Client then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uGameMode = GameplayData.GetGameMode()
    if slua.isValid(uGameMode) then
      self.nGameReadyTimeConfigValue = uGameMode.GameModeStateReady.StateTime
    end
  end
  self:RegistEvents()
end
function GameStateStoreFeatureBase:RegistEvents()
  if not Client then
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_ITEM, EVENTID_PLAYEREVENT_PICKUPITEM, self.OnHandlePickupItem, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYERSETTLEMENT_START, self.OnPlayerBeforeSettlement, self)
  end
end
function GameStateStoreFeatureBase:GetStoreDataFromTable(nStoreID)
  print(bWriteLog and "GameStateStoreFeatureBase:GetStoreDataFromTable StoreID = ", nStoreID)
  if not self.StoreData[nStoreID] then
    local IngameStoreData = CDataTable.GetTableData("IngameStoreTable", nStoreID)
    if IngameStoreData then
      local StoreData = {
        nBuySuccessType = IngameStoreData.BuySuccessType,
        bDisableWhenNotInBlueCircle = IngameStoreData.bDisableWhenNotInBlueCircle == 1,
        sDataTableName = IngameStoreData.DataTableName,
        fBuyFrequence = IngameStoreData.BuyFrequence,
        nNewGoodNotifyTimes = IngameStoreData.NewGoodNotifyTimes
      }
      local StoreConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.StoreConfig")
      local EncodeModeStoreID = self.nModID * StoreConfig.StoreDataEncodeMagnification + nStoreID
      local IngameStoreNameData = CDataTable.GetTableData("IngameStoreTableName", EncodeModeStoreID)
      local sDataTableName
      if IngameStoreNameData then
        sDataTableName = IngameStoreNameData.DataTableName
      elseif self.MapType ~= "Baltic" and self.MapType ~= "UnknownMap" and self.ModType ~= "Sink2" then
        sDataTableName = StoreData.sDataTableName .. self.MapType
      end
      print(bWriteLog and "GameStateStoreFeatureBase:GetStoreDataFromTable sDataTableName:", tostring(sDataTableName), "StoreData.sDataTableName:", tostring(StoreData.sDataTableName))
      if sDataTableName and CDataTable.IsTableExist(sDataTableName) then
        print(bWriteLog and "GameStateStoreFeatureBase:GetStoreDataFromTable sDataTableName and table exist")
        StoreData.      end
      self.StoreData[nStoreID] = StoreData
      if Client then
        self:RefreshClientPatchGoodsData(nStoreID)
      else
        self:InitStoreRandomHideData(nStoreID)
        self:InitStorePatchData(nStoreID)
      end
    end
  end
  return self.StoreData[nStoreID]
end
function GameStateStoreFeatureBase:GetThemeStoreConfig()
  return {}
end
function GameStateStoreFeatureBase:GetRealGoodConfig(nStoreID, nGoodID)
  print(bWriteLog and "GameStateStoreFeatureBase:GetRealGoodConfig, StoreID=" .. tostring(nStoreID) .. ", GoodID=" .. tostring(nGoodID))
  local StoreConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.StoreConfig")
  local sPatchGoodsListPropertyName = StoreConfig.PatchGoodsList[nStoreID]
  if self.tPatchGoodID2GoodListIndex[sPatchGoodsListPropertyName] then
    local nPatchGoodIndex = self.tPatchGoodID2GoodListIndex[sPatchGoodsListPropertyName][nGoodID]
    if nPatchGoodIndex then
      local BattleGoodsInfo = self[sPatchGoodsListPropertyName]
      return BattleGoodsInfo:Get(nPatchGoodIndex)
    end
  end
  if self.StoreData[nStoreID] and self.StoreData[nStoreID].sDataTableName then
    return CDataTable.GetTableData(self.StoreData[nStoreID].sDataTableName, nGoodID)
  end
  return nil
end
function GameStateStoreFeatureBase:GenerateRandomHideList(DataTableName)
  if not DataTableName or not CDataTable.IsTableExist(DataTableName) then
    return {}
  end
  local StoreData = CDataTable.GetTable(DataTableName)
  if not StoreData then
    return {}
  end
  local RandomGroups = {}
  for _, GoodConfig in pairs(StoreData) do
    if GoodConfig.StoreRandomSetting then
      local GroupID, Count = string.match(GoodConfig.StoreRandomSetting, "^(%d+)%-(%d+)$")
      GroupID = tonumber(GroupID)
      Count = tonumber(Count)
      if GroupID and Count then
        RandomGroups[GroupID] = RandomGroups[GroupID] or {
          GoodIDs = {},
                  }
        table.insert(RandomGroups[GroupID].GoodIDs, GoodConfig.GoodID)
      end
    end
  end
  local HideGoodIDs = {}
  for GroupID, GroupData in pairs(RandomGroups) do
    local TotalCount = #GroupData.GoodIDs
    if TotalCount > GroupData.Count then
      local SelectedSet = {}
      local AvailableIDs = {}
      for _, GoodID in ipairs(GroupData.GoodIDs) do
        table.insert(AvailableIDs, GoodID)
      end
      for i = 1, GroupData.Count do
        if 0 < #AvailableIDs then
          local RandomIndex = math.random(1, #AvailableIDs)
          SelectedSet[AvailableIDs[RandomIndex]] = true
          table.remove(AvailableIDs, RandomIndex)
        end
      end
      for _, GoodID in ipairs(GroupData.GoodIDs) do
        if not SelectedSet[GoodID] then
          HideGoodIDs[GoodID] = true
          print(bWriteLog and "GameStateStoreFeatureBase:GenerateRandomHideList Hide GoodID", GoodID)
        end
      end
    end
  end
  return HideGoodIDs
end
function GameStateStoreFeatureBase:InitStoreRandomHideData(nStoreID)
  local StoreDataTableName = self.StoreData[nStoreID].sDataTableName
  if not self.StoreRandomHideList[nStoreID] then
    print(bWriteLog and "GameStateStoreFeatureBase.InitStoreRandomHideData, StoreID", nStoreID)
    self.StoreRandomHideList[nStoreID] = self:GenerateRandomHideList(StoreDataTableName)
  end
end
function GameStateStoreFeatureBase:InitStorePatchData(nStoreID)
  print(bWriteLog and "GameStateStoreFeatureBase.InitStorePatchData, StoreID=" .. nStoreID)
  local StoreDataTableName = self.StoreData[nStoreID].sDataTableName
  local StoreData = CDataTable.GetTable(StoreDataTableName)
  for Index, GoodConfig in pairs(StoreData) do
    if GoodConfig.NewVersionPatch then
      self:AddBattlePatchGoods(nStoreID, GoodConfig.GoodID, GoodConfig.GoodBuyType, GoodConfig.ItemID, GoodConfig.BattleLimitCount, GoodConfig.StoreLimitCount, GoodConfig.PlayerLimitCount, GoodConfig.TimeLimit, GoodConfig.ItemType, GoodConfig.ItemOrder, GoodConfig.ItemCountPerBuy, GoodConfig.Price, GoodConfig.AddToStore)
    end
  end
  self:ForceNetUpdate()
end
function GameStateStoreFeatureBase:AddBattlePatchGoods(nStoreID, nGoodID, nGoodBuyType, nItemID, nBattleLimitCount, nStoreLimitCount, nPlayerLimitCount, nTimeLimit, nItemType, nItemOrder, nItemCountPerBuy, nPrice, bAddToStore)
  if not nGoodID then
    print(bWriteLog and "GameStateStoreFeatureBase:AddBattlePatchGoods failed, nGoodID is nil")
    return
  end
  local BattleGoodInfo = import("BattleGoodInfo")()
  BattleGoodInfo.GoodID = nGoodID
  BattleGoodInfo.GoodBuyType = nGoodBuyType or 0
  BattleGoodInfo.ItemID = nItemID or 0
  BattleGoodInfo.BattleLimitCount = nBattleLimitCount or 0
  BattleGoodInfo.StoreLimitCount = nStoreLimitCount or 0
  BattleGoodInfo.PlayerLimitCount = nPlayerLimitCount or 0
  BattleGoodInfo.TimeLimit = nTimeLimit or 0
  BattleGoodInfo.ItemType = nItemType or 1
  BattleGoodInfo.ItemOrder = nItemOrder or 1
  BattleGoodInfo.ItemCountPerBuy = nItemCountPerBuy or 1
  BattleGoodInfo.Price = nPrice or 0
  if bAddToStore ~= nil then
    if type(bAddToStore) == "number" then
      BattleGoodInfo.AddToStore = 0 < bAddToStore
    else
      BattleGoodInfo.AddToStore = bAddToStore
    end
  else
    BattleGoodInfo.AddToStore = true
  end
  local StoreConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.StoreConfig")
  local sPatchGoodsListPropertyName = StoreConfig.PatchGoodsList[nStoreID]
  local BattleGoodsInfo = self[sPatchGoodsListPropertyName]
  local nCurrentNum = BattleGoodsInfo:Num()
  if not self.tPatchGoodID2GoodListIndex[sPatchGoodsListPropertyName] then
    self.tPatchGoodID2GoodListIndex[sPatchGoodsListPropertyName] = {}
  end
  self.tPatchGoodID2GoodListIndex[sPatchGoodsListPropertyName][nGoodID] = nCurrentNum
  BattleGoodsInfo:Add(BattleGoodInfo)
  print(bWriteLog and "GameStateStoreFeatureBase:AddBattlePatchGoods BattleGoodInfo GoodID=" .. tostring(BattleGoodInfo.GoodID) .. " GoodBuyType=" .. tostring(BattleGoodInfo.GoodBuyType) .. " ItemID=" .. tostring(BattleGoodInfo.ItemID) .. " BattleLimitCount=" .. tostring(BattleGoodInfo.BattleLimitCount) .. " StoreLimitCount=" .. tostring(BattleGoodInfo.StoreLimitCount) .. " PlayerLimitCount=" .. tostring(BattleGoodInfo.PlayerLimitCount) .. " TimeLimit=" .. tostring(BattleGoodInfo.TimeLimit) .. " ItemType=" .. tostring(BattleGoodInfo.ItemType) .. " ItemOrder=" .. tostring(BattleGoodInfo.ItemOrder) .. " ItemCountPerBuy=" .. tostring(BattleGoodInfo.ItemCountPerBuy) .. " Price=" .. tostring(BattleGoodInfo.Price) .. " AddToStore" .. tostring(BattleGoodInfo.AddToStore))
end
function GameStateStoreFeatureBase:ReduceGoods(nStoreID, nGoodID, nItemNum)
  print(bWriteLog and "GameStateStoreFeatureBase:ReduceGoods StoreID=" .. nStoreID .. " GoodID=" .. nGoodID .. " ItemNum=" .. nItemNum)
  StoreActions.ReduceGoods(self, nStoreID, nGoodID, nItemNum)
end
function GameStateStoreFeatureBase:OnHandlePickupItem(EventType, EventID, PlayerKey, ItemID, Count, Reason)
  if ItemID ~= StoreConfig.GoldID then
    return
  end
  local EBattleItemPickupReason = import("EBattleItemPickupReason")
  if Reason == EBattleItemPickupReason.Initial then
    return
  end
  local PlayerController = Game:GetPlayerControllerByPlayerKey(PlayerKey)
  if not slua.isValid(PlayerController) then
    return
  end
  local BackpackComp = PlayerController:GetBackpackComponent()
  local nGoldCount = BackpackComp:GetItemCountByItemSpecialID(StoreConfig.GoldID)
  local ParamTable = {}
  table.insert(ParamTable, ItemID)
  table.insert(ParamTable, Count)
  table.insert(ParamTable, nGoldCount)
  IngameTipsTools.BattleGeneralShowItemTipsByTextID(39180, ParamTable, PlayerKey)
  local PlayerState = PlayerController.PlayerState
  if Game:IsValid(PlayerState) then
    PlayerState:AddGeneralCount(249, Count, false)
  end
end
function GameStateStoreFeatureBase:OnPlayerBeforeSettlement(EventType, EventID, nPlayerUID, tResult)
  local uPlayerController = Game:GetPlayerControllerByUID(nPlayerUID)
  if Game:IsValid(uPlayerController) then
    local uBackpackComponent = uPlayerController:GetBackpackComponent()
    if Game:IsValid(uBackpackComponent) then
      local Count = uBackpackComponent:GetItemCountByItemSpecialID(StoreConfig.GoldID)
      tResult.GeneralCounterMap[233] = Count
    end
  end
end
function GameStateStoreFeatureBase:RefreshClientBuyGoodsData(nStoreID)
  print(bWriteLog and "GameStateStoreFeatureBase.RefreshClientBuyGoodsData StoreID=" .. nStoreID)
  StoreActions.RefreshClientBuyGoodsData(self, nStoreID)
end
function GameStateStoreFeatureBase:RefreshClientPatchGoodsData(nStoreID)
  print(bWriteLog and "GameStateStoreFeatureBase.RefreshClientPatchGoodsData StoreID=" .. tostring(nStoreID))
  local sPatchGoodsListPropertyName = StoreConfig.PatchGoodsList[nStoreID]
  local BattleGoodsInfo = self[sPatchGoodsListPropertyName]
  if not BattleGoodsInfo then
    print(bWriteLog and "GameStateStoreFeatureBase.RefreshClientPatchGoodsData BattleGoodsInfo is nil")
    return
  end
  local nBattleGoodsCount = BattleGoodsInfo:Num()
  if nBattleGoodsCount == 0 then
    return
  end
  self.tPatchGoodID2GoodListIndex[sPatchGoodsListPropertyName] = {}
  for i = 0, nBattleGoodsCount - 1 do
    local GoodInfo = BattleGoodsInfo:Get(i)
    if GoodInfo and GoodInfo.GoodID then
      self.tPatchGoodID2GoodListIndex[sPatchGoodsListPropertyName][GoodInfo.GoodID] = i
    end
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, GameStateStoreFeatureBase)