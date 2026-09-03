local StoreActions = {}
local StoreConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.StoreConfig")
function StoreActions:CanAddBattleItemToBag(PlayerController, ItemID, ItemNum)
  if not Game:IsValid(PlayerController) then
    return
  end
  local uCharacter = PlayerController:GetPlayerCharacterSafety()
  if not Game:IsValid(uCharacter) then
    return
  end
  print(bWriteLog and "StoreBaseUtil.CanAddBattleItemToBag")
  local ItemRecord = CDataTable.GetTableData("Item", ItemID)
  local MaxCount = ItemRecord and ItemRecord.MaxCount or 0
  if ItemNum > MaxCount then
    sandbox.LogError(string.format("StoreActions:BuyBackpackItem exceed MaxCount ItemID:%d ItemID:%d", ItemID, ItemNum))
    Game:UIShowTips(Game:GetPlayerKey(uCharacter), 30010)
    return
  end
  local BackpackComponent = PlayerController.BackpackComponent
  if not Game:IsValid(BackpackComponent) then
    return
  end
  local ItemDefineID = FItemDefineID(0, ItemID)
  return true
end
function StoreActions:DoAddBattleItemToBag(PlayerController, ItemID, ItemNum, StoreActorFeature)
  local nInstId = CGame:GenerateRandomInstanceID() + 100000
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  local bAutoEquip = false
  local uItemRecord = CDataTable.GetTableData("Item", ItemID)
  local StoreActor = StoreActorFeature.Owner
  local ItemType = uItemRecord and uItemRecord.ItemType or 0
  local BackpackComponent = PlayerController.BackpackComponent
  local EBattleItemPickupReason = import("EBattleItemPickupReason")
  if ItemType == StoreConfig.AccessoryType then
    bAutoEquip = true
  end
  local UnitWeight_f = uItemRecord and uItemRecord.UnitWeight_f or 0
  local Weight = UnitWeight_f * ItemNum
  if not bAutoEquip and Weight + BackpackComponent.OccupiedCapacity > BackpackComponent.Capacity then
    local OutPutNum = ItemNum
    if 1 < ItemNum then
      local CanAddNum = math.floor((BackpackComponent.Capacity - BackpackComponent.OccupiedCapacity) / UnitWeight_f)
      OutPutNum = ItemNum - CanAddNum
      Game:AddItemByResIDWithReason(PlayerCharacter, ItemID, CanAddNum, EBattleItemPickupReason.FromStore, nInstId, -1, 0, bAutoEquip)
    end
    print(bWriteLog and "StoreActions:DoAddBattleItemToBag Item TotalWeight Larger then Capacity")
    StoreActions.DropOutItem(StoreActor, PlayerCharacter, ItemID, OutPutNum)
  elseif ItemNum > BackpackComponent:CheckLeftLimitCountForItem(ItemID, ItemNum) then
    local CanAddNum = BackpackComponent:CheckLeftLimitCountForItem(ItemID, ItemNum)
    local OutPutNum = ItemNum - CanAddNum
    Game:AddItemByResIDWithReason(PlayerCharacter, ItemID, CanAddNum, EBattleItemPickupReason.FromStore, nInstId, -1, 0, bAutoEquip)
    StoreActions.DropOutItem(StoreActor, PlayerCharacter, ItemID, OutPutNum)
  else
    local result = Game:AddItemByResIDWithReason(PlayerCharacter, ItemID, ItemNum, EBattleItemPickupReason.FromStore, nInstId, -1, 0, bAutoEquip)
    if not result then
      StoreActions.DropOutItem(StoreActor, PlayerCharacter, ItemID, ItemNum)
    end
  end
  if slua.isValid(PlayerCharacter) and PlayerCharacter.CalculatePickUpItemFlowInstance then
    PlayerCharacter:CalculatePickUpItemFlowInstance(ItemID, ItemNum, PlayerCharacter:K2_GetActorLocation(), 5, 0, nInstId, 0)
  end
  return true
end
function StoreActions.DropOutItem(StoreActor, PlayerCharacter, ItemID, ItemNum)
  ItemNum = math.floor(tonumber(ItemNum) or 0)
  if ItemNum <= 0 then
    return
  end
  print(bWriteLog and "StoreActions:DropOutItem ItemID:" .. ItemID .. " ItemNum:" .. ItemNum)
  Game:GenerateItemOnGround(PlayerCharacter, ItemID, ItemNum)
end
function StoreActions.AddBattleItemToBag(PlayerController, ItemID, ItemNum, Logic)
  if not StoreActions:CanAddBattleItemToBag(PlayerController, ItemID, ItemNum, Logic) then
    return
  end
  local uCharacter = PlayerController:GetPlayerCharacterSafety()
  if Game.IsValid(uCharacter) then
    Game:UIShowTips(Game:GetPlayerKey(uCharacter), 51021)
  end
  return StoreActions:DoAddBattleItemToBag(PlayerController, ItemID, ItemNum, Logic)
end
function StoreActions.AddMultiBattleItemToBag(PlayerController, ItemIDs, ItemNums, StoreActorFeature)
  if not Game:IsValid(PlayerController) then
    return
  end
  local bSuccess = -1
  for Index, ItemID in pairs(ItemIDs) do
    local ItemNum = ItemNums[Index]
    if not StoreActions:CanAddBattleItemToBag(PlayerController, ItemID, ItemNum) then
      bSuccess = Index
      break
    end
  end
  if bSuccess < 0 then
    for Index, ItemID in pairs(ItemIDs) do
      local ItemNum = ItemNums[Index]
      StoreActions:DoAddBattleItemToBag(PlayerController, ItemID, ItemNum, StoreActorFeature)
    end
    return true
  end
end
function StoreActions.AddGoods(StoreComponent, nItemID, nInitCount, nMaxCount, bRandomHide)
  if not nItemID then
    sandbox.LogError(string.format("StoreActions:AddGoods illegal ItemID:%s", nItemID))
    return
  end
  nItemID = tonumber(nItemID)
  nInitCount = nInitCount or -1
  nMaxCount = nMaxCount or -1
  bRandomHide = bRandomHide or false
  local ListNum = StoreComponent.GoodsList:Num()
  if StoreComponent.DataMgr then
    StoreComponent.DataMgr.ItemID2GoodsIndex[nItemID] = ListNum
  else
    if not StoreComponent.ItemID2GoodsIndex then
      StoreComponent.ItemID2GoodsIndex = {}
    end
    StoreComponent.ItemID2GoodsIndex[nItemID] = ListNum
  end
  StoreComponent.GoodsList:Add({
    ItemID = nItemID,
    Count = nInitCount,
    MaxCount = nMaxCount,
    RandomHide = bRandomHide
  })
  local GoodsInfo = StoreComponent.GoodsList:Get(ListNum)
  GoodsInfo.ItemID = nItemID
  GoodsInfo.Count = nInitCount
  GoodsInfo.MaxCount = nMaxCount
  GoodsInfo.RandomHide = bRandomHide
  StoreComponent.GoodsList:Set(ListNum, GoodsInfo)
  print(bWriteLog and "AddGoods GoodsInfo ItemID=" .. tostring(GoodsInfo.ItemID) .. " Count=" .. tostring(GoodsInfo.Count) .. " MaxCount=" .. tostring(GoodsInfo.MaxCount) .. " RandomHide=" .. tostring(GoodsInfo.RandomHide))
  StoreComponent:ForceNetUpdate()
end
function StoreActions.AddBattleGoods(BattleStoreComponent, nItemID, tCurrencyCost, nInitCount, nItemType, nItemOrder, nItemCountPerBuy, nMaxCount, nPlayerBuyMaxCount, nTimeLimit)
  if not nItemID then
    sandbox.LogError(string.format("StoreActions:AddBattleGoods illegal ItemID:%s", nItemID))
    return
  end
  nItemID = tonumber(nItemID)
  tCurrencyCost = tCurrencyCost or {}
  nInitCount = nInitCount or -1
  nItemType = nItemType or 1
  nItemOrder = nItemOrder or 1
  nItemCountPerBuy = nItemCountPerBuy or 1
  nMaxCount = nMaxCount or -1
  nPlayerBuyMaxCount = nPlayerBuyMaxCount or -1
  nTimeLimit = nTimeLimit or -1
  local ListNum = BattleStoreComponent.BattleGoodsList:Num()
  if BattleStoreComponent.DataMgr then
    BattleStoreComponent.DataMgr.ItemID2GoodsIndex[nItemID] = ListNum
  else
    if not BattleStoreComponent.ItemID2GoodsIndex then
      BattleStoreComponent.ItemID2GoodsIndex = {}
    end
    BattleStoreComponent.ItemID2GoodsIndex[nItemID] = ListNum
  end
  BattleStoreComponent.BattleGoodsList:Add({
    ItemID = nItemID,
    CurrencyCost = tCurrencyCost,
    BattleCount = nInitCount,
    ItemType = nItemType,
    ItemOrder = nItemOrder,
    ItemCountPerBuy = nItemCountPerBuy,
    BattleMaxCount = nMaxCount,
    PlayerBuyMaxCount = nPlayerBuyMaxCount,
    TimeLimit = nTimeLimit
  })
  local GoodsInfo = BattleStoreComponent.BattleGoodsList:Get(ListNum)
  GoodsInfo.ItemID = nItemID
  GoodsInfo.BattleCount = nInitCount
  GoodsInfo.ItemType = nItemType
  GoodsInfo.ItemOrder = nItemOrder
  GoodsInfo.ItemCountPerBuy = nItemCountPerBuy
  GoodsInfo.BattleMaxCount = nMaxCount
  GoodsInfo.PlayerBuyMaxCount = nPlayerBuyMaxCount
  GoodsInfo.TimeLimit = nTimeLimit
  BattleStoreComponent.BattleGoodsList:Set(ListNum, GoodsInfo)
  print(bWriteLog and "AddBattleGoods GoodsInfo ItemID=" .. tostring(GoodsInfo.ItemID) .. " CurrencyCost=" .. tostring(tCurrencyCost[1]) .. " Count=" .. tostring(GoodsInfo.Count) .. " ItemType=" .. tostring(GoodsInfo.ItemType) .. " ItemOrder=" .. tostring(GoodsInfo.ItemOrder) .. " ItemCountPerBuy=" .. tostring(GoodsInfo.ItemCountPerBuy) .. " BattleMaxCount=" .. tostring(GoodsInfo.BattleMaxCount))
  BattleStoreComponent:ForceNetUpdate()
end
function StoreActions.ReduceGoods(tStoreFeature, nStoreID, nGoodID, nItemNum)
  print(bWriteLog and "StoreActions.ReduceGoods StoreID=" .. nStoreID .. " GoodID=" .. nGoodID .. " ItemNum=" .. nItemNum)
  local StoreIndex = tStoreFeature.BuyGoodID2GoodsListIndex[nStoreID]
  if not StoreIndex then
    tStoreFeature.BuyGoodID2GoodsListIndex[nStoreID] = {}
  end
  local GoodIndex = tStoreFeature.BuyGoodID2GoodsListIndex[nStoreID][nGoodID]
  local BuyGoodsList = tStoreFeature[StoreConfig.BuyGoodsList[nStoreID]]
  if not BuyGoodsList then
    print(bWriteLog and string.format("StoreActions.ReduceGoods: nStoreID, %d, BuyGoodsListName, %s", nStoreID, StoreConfig.BuyGoodsList[nStoreID]))
    return
  end
  local BuyGoodInfo = import("BuyGoodInfo")()
  if GoodIndex then
    local GoodInfo = BuyGoodsList:Get(GoodIndex)
    BuyGoodInfo.BuyGoodCount = GoodInfo.BuyGoodCount + nItemNum
    BuyGoodInfo.BuyGoodID = GoodInfo.BuyGoodID
    BuyGoodsList:Set(GoodIndex, BuyGoodInfo)
  else
    if not BuyGoodsList then
      GoodIndex = 0
    else
      GoodIndex = BuyGoodsList:Num()
    end
    tStoreFeature.BuyGoodID2GoodsListIndex[nStoreID][nGoodID] = GoodIndex
    BuyGoodInfo.BuyGoodID = nGoodID
    BuyGoodInfo.BuyGoodCount = nItemNum
    BuyGoodsList:Add(BuyGoodInfo)
  end
  tStoreFeature[StoreConfig.BuyGoodsList[nStoreID]] = tStoreFeature[StoreConfig.BuyGoodsList[nStoreID]]
end
function StoreActions.RefreshClientBuyGoodsData(tStoreFeature, nStoreID)
  print(bWriteLog and "StoreActions.RefreshClientBuyGoodsData StoreID=" .. nStoreID)
  local BuyGoodsListPropertyName = StoreConfig.BuyGoodsList[nStoreID]
  local BuyGoodsInfo = tStoreFeature[BuyGoodsListPropertyName]
  local nBuyGoodsCount = BuyGoodsInfo:Num()
  if nBuyGoodsCount == 0 then
    return
  end
  local nSavedGoodsCount = tStoreFeature.BuyGoodCounts[BuyGoodsListPropertyName] or 0
  if nSavedGoodsCount == nBuyGoodsCount then
    return
  end
  if not tStoreFeature.BuyGoodID2GoodsListIndex[BuyGoodsListPropertyName] then
    tStoreFeature.BuyGoodID2GoodsListIndex[BuyGoodsListPropertyName] = {}
  end
  for i = nSavedGoodsCount, nBuyGoodsCount - 1 do
    local GoodInfo = BuyGoodsInfo:Get(i)
    tStoreFeature.BuyGoodID2GoodsListIndex[BuyGoodsListPropertyName][GoodInfo.BuyGoodID] = i
  end
  tStoreFeature.BuyGoodCounts[BuyGoodsListPropertyName] = nBuyGoodsCount
end
return StoreActions