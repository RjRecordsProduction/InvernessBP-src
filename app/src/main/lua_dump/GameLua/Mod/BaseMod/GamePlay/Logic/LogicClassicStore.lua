local LogicClassicStore = {bInited = false, bIsDS = false}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local StoreConfig = GamePlayTools.GetCurrentConfig("StoreConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local FriendlyBehaviorModule = require("GameLua.Mod.BaseMod.Common.Security.FriendlyBehavior")
local TableUtil = require("common.table_util")
function LogicClassicStore.Init()
  print(bWriteLog and "LogicClassicStore.Init")
  if LogicClassicStore.bInited then
    return
  end
  LogicClassicStore.bInited = true
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  if CGameMode then
    LogicClassicStore.bIsDS = UKismetSystemLibrary.IsDedicatedServer(CGameMode)
  end
  if LogicClassicStore.bIsDS then
    LogicClassicStore.InitForDS()
  else
    LogicClassicStore.InitForClient()
  end
end
function LogicClassicStore.InitForDS()
  print(bWriteLog and "LogicClassicStore.InitForDS")
end
function LogicClassicStore.InitForClient()
  print(bWriteLog and "LogicClassicStore.InitForClient")
end
function LogicClassicStore.ProcessItemGoodsData(GoodConfig, ItemGoodsData, tStore, StoreHideIDMap, DiscountGoodMap, RotatingDiscountMap)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType = GameMainConfig.GetModType()
  if GoodConfig.AddToStore and not StoreConfig.IsGoodsItemOpen(GoodConfig) then
    return ItemGoodsData
  end
  if not GoodConfig.AddToStore or StoreHideIDMap[GoodConfig.GoodID] then
    return ItemGoodsData
  end
  if GoodConfig.GoodBuyType == StoreConfig.BuyTeammateLifeType then
    local TeammatePlayerState = LogicClassicStore.GetTeamMatePlayerStateList()
    if TeammatePlayerState:Num() <= 1 then
      return ItemGoodsData
    end
  end
  local NewItemData = {
    Handle = require(StoreConfig.ItemGoodsHandle),
    GoodID = GoodConfig.GoodID,
    ItemID = GoodConfig.ItemID,
    Price = GoodConfig.Price,
    GoldType = GoodConfig.GoldType,
    ItemCountPerBuy = GoodConfig.ItemCountPerBuy,
    BattleLimitCount = GoodConfig.BattleLimitCount,
    StoreLimitCount = GoodConfig.StoreLimitCount,
    PlayerLimitCount = GoodConfig.PlayerLimitCount,
    TimeLimit = GoodConfig.TimeLimit,
    bSelected = false,
    bAlreadySoldOut = false,
    bSoldOut = false,
    UnlockTime = GoodConfig.TimeLimit < 0 and -GoodConfig.TimeLimit or -1,
    bCannotAfford = false,
    PlayerDiscount = 0,
    PlayerDiscountPrice = 0,
    PlayerDiscountCount = 0,
    LeftPlayerDiscountCount = 0,
    Discount = 0,
    DiscountPrice = 0,
    bDiscount = false,
    UpdateDescID = GoodConfig.UpdateDescID
  }
  local ItemType = GoodConfig.ItemType
  local PlayerDiscountCount, PlayerDiscountRate, bHaveDiscount
  local uPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(uPlayerState) and uPlayerState.StoreFeature and uPlayerState.StoreFeature.GetDiscount then
    PlayerDiscountCount, PlayerDiscountRate = uPlayerState.StoreFeature:GetDiscount(GoodConfig.ItemID)
    bHaveDiscount = 0 < PlayerDiscountCount
  end
  if bHaveDiscount then
    NewItemData.PlayerDiscount = PlayerDiscountRate
    NewItemData.PlayerDiscountPrice = math.ceil(NewItemData.Price * (1 - PlayerDiscountRate))
    NewItemData.  elseif DiscountGoodMap[GoodConfig.GoodID] then
    bHaveDiscount = true
    NewItemData.Discount = DiscountGoodMap[GoodConfig.GoodID].DiscountRate
    NewItemData.DiscountPrice = DiscountGoodMap[GoodConfig.GoodID].DiscountPrice
  elseif RotatingDiscountMap[GoodConfig.GoodID] then
    bHaveDiscount = true
    local RotatingDiscountRate = RotatingDiscountMap[GoodConfig.GoodID]
    NewItemData.Discount = math.floor(RotatingDiscountRate * 100)
    NewItemData.DiscountPrice = math.ceil(NewItemData.Price * (1 - RotatingDiscountRate))
    NewItemData.bRotatingDiscount = true
    print(bWriteLog and "LogicClassicStore:ProcessItemGoodsData Applied rotating discount to GoodID:" .. tostring(GoodConfig.GoodID) .. " Rate:" .. tostring(RotatingDiscountRate))
  end
  if bHaveDiscount then
    NewItemData.bDiscount = true
    if not NewItemData.bRotatingDiscount then
      ItemType = StoreConfig.DiscountType
    end
  end
  if not ItemGoodsData[ItemType] then
    ItemGoodsData[ItemType] = {}
  end
  if GoodConfig.GoodBuyType == StoreConfig.BuyItemType or GoodConfig.GoodBuyType == StoreConfig.BuyItemDropListType or GoodConfig.GoodBuyType == StoreConfig.ExchangeItemType or GoodConfig.GoodBuyType == StoreConfig.CustomScriptItemType then
    NewItemData.ExtraData = {
      Index = 1,
      ItemID = tonumber(GoodConfig.ItemID)
    }
    ItemGoodsData[ItemType][GoodConfig.ItemOrder] = NewItemData
  elseif GoodConfig.GoodBuyType == StoreConfig.ExchangeTicketType then
    NewItemData.ExtraData = {
      Index = 1,
      ItemID = tonumber(GoodConfig.ItemID)
    }
    NewItemData.Handle = require(StoreConfig.ExchangeTicketHandle)
    ItemGoodsData[ItemType][GoodConfig.ItemOrder] = NewItemData
  end
  return ItemGoodsData
end
function LogicClassicStore.SortItemTypes(ItemGoodsData)
  print(bWriteLog and "LogicClassicStore:SortItemTypes [1] Start sorting categories")
  local AllItemTypes = {}
  for ItemType, SubItemData in pairs(ItemGoodsData) do
    table.insert(AllItemTypes, ItemType)
  end
  table.sort(AllItemTypes)
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "LogicClassicStore:SortItemTypes [2] PlayerCharacter is invalid, return default sorted types")
    return AllItemTypes
  end
  local bCanExchangeGiftBox = LogicClassicStore.CheckCanExchangeGiftBox(ItemGoodsData, uPlayerCharacter)
  local SortedItemTypes = {}
  local ExchangeGiftBoxTypes = {}
  local OtherTypes = {}
  for ItemType, SubItemData in pairs(ItemGoodsData) do
    local bIsExchangeGiftBoxType = LogicClassicStore.IsExchangeGiftBoxType(SubItemData)
    if bIsExchangeGiftBoxType then
      table.insert(ExchangeGiftBoxTypes, ItemType)
    else
      table.insert(OtherTypes, ItemType)
    end
  end
  table.sort(ExchangeGiftBoxTypes)
  table.sort(OtherTypes)
  if bCanExchangeGiftBox then
    for _, ItemType in ipairs(ExchangeGiftBoxTypes) do
      table.insert(SortedItemTypes, ItemType)
    end
    for _, ItemType in ipairs(OtherTypes) do
      table.insert(SortedItemTypes, ItemType)
    end
    print(bWriteLog and "LogicClassicStore:SortItemTypes [6] Exchange gift box categories moved to top")
  else
    for _, ItemType in ipairs(OtherTypes) do
      table.insert(SortedItemTypes, ItemType)
    end
    for _, ItemType in ipairs(ExchangeGiftBoxTypes) do
      table.insert(SortedItemTypes, ItemType)
    end
    print(bWriteLog and "LogicClassicStore:SortItemTypes [7] Exchange gift box categories moved to bottom")
  end
  return SortedItemTypes
end
function LogicClassicStore.CheckCanExchangeGiftBox(ItemGoodsData, uPlayerCharacter)
  local bCanExchangeGiftBox = false
  for TicketType, Config in pairs(StoreConfig.ExchangeTicketConfig) do
    local TicketCount = Game:GetItemNumByResID(uPlayerCharacter, Config.TicketItemID)
    print(bWriteLog and "LogicClassicStore:CheckCanExchangeGiftBox Check ticket, TicketType:" .. tostring(TicketType) .. ", Count:" .. tostring(TicketCount))
    if 0 < TicketCount then
      for ItemType, SubItemData in pairs(ItemGoodsData) do
        for Order, ItemData in pairs(SubItemData) do
          if ItemData and (ItemData.GoodID == Config.GiftBoxItemID or ItemData.ItemID == Config.GiftBoxItemID) then
            bCanExchangeGiftBox = true
            break
          end
        end
        if bCanExchangeGiftBox then
          break
        end
      end
      if bCanExchangeGiftBox then
        break
      end
    end
  end
  if FriendlyBehaviorModule.IsEnableFriendlyGiftBox() then
    local nStockCount = FriendlyBehaviorModule.GetStockCountClient()
    if nStockCount and 0 < nStockCount then
      for ItemType, SubItemData in pairs(ItemGoodsData) do
        for Order, ItemData in pairs(SubItemData) do
          if ItemData and (ItemData.GoodID == StoreConfig.FriendlyGiftBoxItemId or ItemData.ItemID == StoreConfig.FriendlyGiftBoxItemId) then
            bCanExchangeGiftBox = true
            break
          end
        end
        if bCanExchangeGiftBox then
          break
        end
      end
    end
  end
  return bCanExchangeGiftBox
end
function LogicClassicStore.IsExchangeGiftBoxType(SubItemData)
  for Order, ItemData in pairs(SubItemData) do
    if ItemData then
      for TicketType, Config in pairs(StoreConfig.ExchangeTicketConfig) do
        if ItemData.GoodID == Config.GiftBoxItemID or ItemData.ItemID == Config.GiftBoxItemID then
          return true
        end
      end
      if ItemData.GoodID == StoreConfig.FriendlyGiftBoxItemId or ItemData.ItemID == StoreConfig.FriendlyGiftBoxItemId then
        return true
      end
    end
  end
  return false
end
function LogicClassicStore.RefreshDiscountPlan(tStore)
  local DiscountGoodMap = {}
  if not (tStore and tStore.StoreID) or tStore.StoreID ~= StoreConfig.DiscountStore and tStore.StoreID ~= StoreConfig.DesertStore then
    return DiscountGoodMap
  end
  local nDiscountPlanID = tStore:GetDiscountPlanID()
  print(bWriteLog and "LogicClassicStore:RefreshDiscountPlan " .. nDiscountPlanID)
  if nDiscountPlanID == 0 then
    return DiscountGoodMap
  end
  local DiscountPlanData = CDataTable.GetTableData(tStore:GetDataTableName() .. "DiscountPlan", nDiscountPlanID)
  for Index, DiscountGoodIDName in pairs(StoreConfig.DiscountGoodIDs) do
    local GoodID = DiscountPlanData[DiscountGoodIDName]
    if GoodID and GoodID ~= 0 then
      DiscountGoodMap[GoodID] = {
        OriginPrice = DiscountPlanData[StoreConfig.OriginPrices[Index]],
        DiscountRate = DiscountPlanData[StoreConfig.DiscountRates[Index]],
        DiscountPrice = DiscountPlanData[StoreConfig.DiscountPrices[Index]]
      }
    end
  end
  return DiscountGoodMap
end
function LogicClassicStore.GetTeamMatePlayerStateList()
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    return slua.Array(UEnums.EPropertyClass.Object)
  end
  local TeammatePlayerState = uPlayerState:GetTeamMatePlayerStateList({}, true)
  return TeammatePlayerState
end
function LogicClassicStore.LoadRotatingDiscountData(tStore)
  print(bWriteLog and "LogicClassicStore:LoadRotatingDiscountData [1]")
  local RotatingDiscountMap = {}
  if not tStore or not tStore.StoreFeature then
    print(bWriteLog and "LogicClassicStore:LoadRotatingDiscountData [2] Store or StoreFeature is invalid")
    return RotatingDiscountMap
  end
  if tStore.StoreFeature.RebuildRotatingDiscountMap then
    tStore.StoreFeature:RebuildRotatingDiscountMap()
    RotatingDiscountMap = tStore.StoreFeature.RotatingDiscountMap or {}
    print(bWriteLog and "LogicClassicStore:LoadRotatingDiscountData [3] Synced " .. tostring(#RotatingDiscountMap) .. " rotating discounts from store feature")
  else
    print(bWriteLog and "LogicClassicStore:LoadRotatingDiscountData Error RebuildRotatingDiscountMap method not found")
  end
  return RotatingDiscountMap
end
function LogicClassicStore.CheckShouldNotify(GoodID, bShouldShowNewItems, tStore)
  if not bShouldShowNewItems then
    return false
  end
  if GoodID == StoreConfig.FriendlyGiftBoxItemId and not FriendlyBehaviorModule.IsEnableFriendlyGiftBox() then
    local FormatLog = FuncUtil.FormatLog
    FormatLog("IsEnableFriendlyGiftBox return false")
    return false
  end
  if not tStore then
    return false
  end
  local ItemConfig = CDataTable.GetTableData(tStore:GetDataTableName(), GoodID)
  if ItemConfig and ItemConfig.NewGood then
    return true
  end
  return false
end
function LogicClassicStore.GetGoodBuyTypeByID(InGoodID, StoreID)
  local uCurGameState = GameplayData.GetGameState()
  if not slua.isValid(uCurGameState) then
    print(bWriteLog and "LogicClassicStore:GetGoodBuyTypeByID The uGameState is nil")
    return StoreConfig.BuyItemType
  end
  if not uCurGameState.StoreFeature then
    print(bWriteLog and "LogicClassicStore:GetGoodBuyTypeByID uGameState.StoreFeature is not valid")
    return StoreConfig.BuyItemType
  end
  if not StoreID then
    print(bWriteLog and "LogicClassicStore:GetGoodBuyTypeByID StoreID is not valid")
    return StoreConfig.BuyItemType
  end
  local GoodConfig = uCurGameState.StoreFeature:GetRealGoodConfig(StoreID, InGoodID)
  if not GoodConfig then
    print(bWriteLog and "LogicClassicStore:GetGoodBuyTypeByID GoodConfig is not valid")
    return StoreConfig.BuyItemType
  end
  return GoodConfig.GoodBuyType
end
function LogicClassicStore.CheckNeedBezelAndGunLockAndTacticalAttach()
  local bWeaponNeedBezel = false
  local bWeaponNeedGunLock = false
  local bWeaponNeedTacticalAttach = false
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) or not slua.isValid(uPlayerController.BackpackComponent) then
    return bWeaponNeedBezel, bWeaponNeedGunLock, bWeaponNeedTacticalAttach
  end
  local UBackpackUtils = import("BackpackUtils")
  local WeaponsInBackpack = UBackpackUtils.GetWeaponsInBackpack(uPlayerController.BackpackComponent)
  for i, Weapon in pairs(WeaponsInBackpack) do
    local nWeaponItemID = slua.IndexReference(Weapon, "DefineID").TypeSpecificID
    if not bWeaponNeedBezel and StoreConfig.tNeedCheckBezelWeaponID[nWeaponItemID] then
      local bCurrentWeaponNeedBezel = true
      for _, Association in pairs(slua.IndexReference(Weapon, "Associations")) do
        local TypeSpecificID = slua.IndexReference(Association, "AssociationTargetDefineID").TypeSpecificID
        if TypeSpecificID // 1000 == 207 then
          bCurrentWeaponNeedBezel = false
          break
        end
      end
      if bCurrentWeaponNeedBezel then
        bWeaponNeedBezel = true
      end
    end
    if not bWeaponNeedGunLock and StoreConfig.tNeedCheckGunLockWeaponID[nWeaponItemID] then
      local bCurrentWeaponNeedGunLock = true
      for _, Association in pairs(slua.IndexReference(Weapon, "Associations")) do
        local TypeSpecificID = slua.IndexReference(Association, "AssociationTargetDefineID").TypeSpecificID
        if TypeSpecificID // 1000 == 208 then
          bCurrentWeaponNeedGunLock = false
          break
        end
      end
      if bCurrentWeaponNeedGunLock then
        bWeaponNeedGunLock = true
      end
    end
    if not bWeaponNeedTacticalAttach and StoreConfig.tNeedCheckTacticalAttachWeaponID[nWeaponItemID] then
      local bCurrentWeaponNeedTacticalAttach = true
      for _, Association in pairs(slua.IndexReference(Weapon, "Associations")) do
        local TypeSpecificID = slua.IndexReference(Association, "AssociationTargetDefineID").TypeSpecificID
        if TypeSpecificID // 1000 == 209 then
          bCurrentWeaponNeedTacticalAttach = false
          break
        end
      end
      if bCurrentWeaponNeedTacticalAttach then
        bWeaponNeedTacticalAttach = true
      end
    end
  end
  return bWeaponNeedBezel, bWeaponNeedGunLock, bWeaponNeedTacticalAttach
end
function LogicClassicStore.GetStoreItemData(tStore, StoreHideIDMap, DiscountGoodMap, RotatingDiscountMap, bNeedBezel, bNeedGunLock, bNeedTacticalAttach)
  local uCurGameState = GameplayData.GetGameState()
  if not slua.isValid(uCurGameState) then
    print(bWriteLog and "LogicClassicStore:GetStoreItemData The uGameState is nil")
    return nil, nil
  end
  if not uCurGameState.StoreFeature then
    print(bWriteLog and "LogicClassicStore:GetStoreItemData uGameState.StoreFeature is not valid")
    return nil, nil
  end
  local StoreTableData = CDataTable.GetTable(tStore:GetDataTableName())
  if not FriendlyBehaviorModule.IsEnableFriendlyGiftBox() then
    StoreTableData[StoreConfig.FriendlyGiftBoxItemId] = nil
  end
  local ExchangeTicketHandle = require("GameLua.Mod.BaseMod.GamePlay.Store.Handle.ExchangeTicketHandle")
  if not ExchangeTicketHandle:CheckHasReviveTower() then
    local ReviveGiftBoxItemID = StoreConfig.ExchangeTicketConfig.ReviveTicket.GiftBoxItemID
    if ReviveGiftBoxItemID then
      StoreTableData[ReviveGiftBoxItemID] = nil
    end
  end
  local ItemGoodsData = {}
  local ItemDataMap = {}
  local bHasBezel = false
  local bHasTacticalAttach = false
  local bHasGunLock = false
  local TeammateDataResult = {}
  for nGoodID, GoodConfig in pairs(StoreTableData) do
    ItemGoodsData, ItemDataMap, bHasBezel, bHasGunLock, bHasTacticalAttach, TeammateDataResult = LogicClassicStore.ProcessItemGoodsDataExtended(GoodConfig, ItemGoodsData, tStore, StoreHideIDMap, DiscountGoodMap, RotatingDiscountMap, ItemDataMap, bHasBezel, bHasGunLock, bHasTacticalAttach, TeammateDataResult)
  end
  local PatchGoodsList = uCurGameState.StoreFeature[StoreConfig.PatchGoodsList[tStore.StoreID]]
  if PatchGoodsList and PatchGoodsList:Num() > 0 then
    for Index, GoodConfig in pairs(PatchGoodsList) do
      ItemGoodsData, ItemDataMap, bHasBezel, bHasGunLock, bHasTacticalAttach, TeammateDataResult = LogicClassicStore.ProcessItemGoodsDataExtended(GoodConfig, ItemGoodsData, tStore, StoreHideIDMap, DiscountGoodMap, RotatingDiscountMap, ItemDataMap, bHasBezel, bHasGunLock, bHasTacticalAttach, TeammateDataResult)
    end
  end
  local ShowDataTitle = {}
  local StoreSubData = {}
  local StoreItemType = CDataTable.GetTable(tStore:GetDataTableName() .. "Type")
  local SortedItemTypes = LogicClassicStore.SortItemTypes(ItemGoodsData)
  for _, ItemType in ipairs(SortedItemTypes) do
    local SubItemData = ItemGoodsData[ItemType]
    if SubItemData then
      table.insert(ShowDataTitle, StoreItemType[ItemType])
      local CurrentSubData = LogicClassicStore.OrganizeSubItemData(SubItemData, ItemType, tStore.StoreID, bNeedBezel, bHasBezel, bNeedGunLock, bHasGunLock, bNeedTacticalAttach, bHasTacticalAttach)
      table.insert(StoreSubData, CurrentSubData)
    end
  end
  return ShowDataTitle, StoreSubData, TeammateDataResult, ItemDataMap, bHasBezel, bHasGunLock, bHasTacticalAttach
end
function LogicClassicStore.ProcessItemGoodsDataExtended(GoodConfig, ItemGoodsData, tStore, StoreHideIDMap, DiscountGoodMap, RotatingDiscountMap, ItemDataMap, bHasBezel, bHasGunLock, bHasTacticalAttach, TeammateDataResult)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  if GoodConfig.AddToStore and not StoreConfig.IsGoodsItemOpen(GoodConfig) then
    return ItemGoodsData, ItemDataMap, bHasBezel, bHasGunLock, bHasTacticalAttach, TeammateDataResult
  end
  if not GoodConfig.AddToStore or StoreHideIDMap[GoodConfig.GoodID] then
    if ItemDataMap[GoodConfig.GoodID] then
      ItemGoodsData[ItemDataMap[GoodConfig.GoodID][1]][ItemDataMap[GoodConfig.GoodID][2]] = nil
      ItemDataMap[GoodConfig.GoodID] = nil
    end
    return ItemGoodsData, ItemDataMap, bHasBezel, bHasGunLock, bHasTacticalAttach, TeammateDataResult
  end
  if GoodConfig.GoodBuyType == StoreConfig.BuyTeammateLifeType then
    local TeammatePlayerState = LogicClassicStore.GetTeamMatePlayerStateList()
    if 1 >= TeammatePlayerState:Num() then
      TeammateDataResult.bShouldShowTeammateBuyLife = false
      return ItemGoodsData, ItemDataMap, bHasBezel, bHasGunLock, bHasTacticalAttach, TeammateDataResult
    end
  end
  if GoodConfig.ItemID == StoreConfig.BezelItemID then
    bHasBezel = true
  elseif GoodConfig.ItemID == StoreConfig.GunLockItemID then
    bHasGunLock = true
  elseif GoodConfig.ItemID == StoreConfig.TacticalAttachItemID then
    bHasTacticalAttach = true
  end
  local NewItemData = {
    Handle = require(StoreConfig.ItemGoodsHandle),
    GoodID = GoodConfig.GoodID,
    ItemID = GoodConfig.ItemID,
    Price = GoodConfig.Price,
    GoldType = GoodConfig.GoldType,
    ItemCountPerBuy = GoodConfig.ItemCountPerBuy,
    BattleLimitCount = GoodConfig.BattleLimitCount,
    StoreLimitCount = GoodConfig.StoreLimitCount,
    PlayerLimitCount = GoodConfig.PlayerLimitCount,
    TimeLimit = GoodConfig.TimeLimit,
    bSelected = false,
    bAlreadySoldOut = false,
    bSoldOut = false,
    UnlockTime = GoodConfig.TimeLimit < 0 and -GoodConfig.TimeLimit or -1,
    bCannotAfford = false,
    PlayerDiscount = 0,
    PlayerDiscountPrice = 0,
    PlayerDiscountCount = 0,
    LeftPlayerDiscountCount = 0,
    Discount = 0,
    DiscountPrice = 0,
    bDiscount = false,
    UpdateDescID = GoodConfig.UpdateDescID,
    ConfigItemType = GoodConfig.ItemType
  }
  local ItemType = GoodConfig.ItemType
  local PlayerDiscountCount, PlayerDiscountRate, bHaveDiscount
  local uPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(uPlayerState) and uPlayerState.StoreFeature and uPlayerState.StoreFeature.GetDiscount then
    PlayerDiscountCount, PlayerDiscountRate = uPlayerState.StoreFeature:GetDiscount(GoodConfig.ItemID)
    bHaveDiscount = 0 < PlayerDiscountCount
  end
  if bHaveDiscount then
    NewItemData.PlayerDiscount = PlayerDiscountRate
    NewItemData.PlayerDiscountPrice = math.ceil(NewItemData.Price * (1 - PlayerDiscountRate))
    NewItemData.  elseif DiscountGoodMap[GoodConfig.GoodID] then
    bHaveDiscount = true
    NewItemData.Discount = DiscountGoodMap[GoodConfig.GoodID].DiscountRate
    NewItemData.DiscountPrice = DiscountGoodMap[GoodConfig.GoodID].DiscountPrice
  elseif RotatingDiscountMap[GoodConfig.GoodID] then
    bHaveDiscount = true
    local RotatingDiscountRate = RotatingDiscountMap[GoodConfig.GoodID]
    NewItemData.Discount = math.floor(RotatingDiscountRate * 100)
    NewItemData.DiscountPrice = math.ceil(NewItemData.Price * (1 - RotatingDiscountRate))
    NewItemData.bRotatingDiscount = true
  end
  if bHaveDiscount then
    NewItemData.bDiscount = true
    if not NewItemData.bRotatingDiscount then
      ItemType = StoreConfig.DiscountType
    end
  end
  if not ItemGoodsData[ItemType] then
    ItemGoodsData[ItemType] = {}
  end
  if GoodConfig.GoodBuyType == StoreConfig.BuyItemType or GoodConfig.GoodBuyType == StoreConfig.BuyItemDropListType or GoodConfig.GoodBuyType == StoreConfig.ExchangeItemType or GoodConfig.GoodBuyType == StoreConfig.CustomScriptItemType then
    NewItemData.ExtraData = {
      Index = 1,
      ItemID = tonumber(GoodConfig.ItemID)
    }
    ItemGoodsData[ItemType][GoodConfig.ItemOrder] = NewItemData
  elseif GoodConfig.GoodBuyType == StoreConfig.BuyTeammateLifeType then
    TeammateDataResult.bShouldShowTeammateBuyLife = true
    TeammateDataResult.BuyTeammateLifeGoodID = GoodConfig.GoodID
    NewItemData.Empty = true
    if not TeammateDataResult.EmptyTeammateData then
      TeammateDataResult.EmptyTeammateData = {}
    end
    table.insert(TeammateDataResult.EmptyTeammateData, NewItemData)
    ItemGoodsData[ItemType] = TeammateDataResult.EmptyTeammateData
  elseif GoodConfig.GoodBuyType == StoreConfig.ExchangeTicketType then
    NewItemData.ExtraData = {
      Index = 1,
      ItemID = tonumber(GoodConfig.ItemID)
    }
    NewItemData.Handle = require(StoreConfig.ExchangeTicketHandle)
    ItemGoodsData[ItemType][GoodConfig.ItemOrder] = NewItemData
  end
  ItemDataMap[GoodConfig.GoodID] = {
    ItemType,
    GoodConfig.ItemOrder
  }
  return ItemGoodsData, ItemDataMap, bHasBezel, bHasGunLock, bHasTacticalAttach, TeammateDataResult
end
function LogicClassicStore.OrganizeSubItemData(SubItemData, ItemType, StoreID, bNeedBezel, bHasBezel, bNeedGunLock, bHasGunLock, bNeedTacticalAttach, bHasTacticalAttach)
  local CurrentSubData = {}
  if (bNeedBezel and bHasBezel or bNeedGunLock and bHasGunLock or bNeedTacticalAttach and bHasTacticalAttach) and (ItemType == StoreConfig.StoreGoodsAccessoryType and StoreID ~= StoreConfig.CarloStore or ItemType == StoreConfig.CarloStoreAccessoryType and StoreID == StoreConfig.CarloStore) then
    local CurrentSpecialAccessoriesData = {}
    for Order, ItemData in pairsByKeys(SubItemData) do
      if ItemData then
        if bNeedBezel and bHasBezel and ItemData.ItemID == StoreConfig.BezelItemID or bNeedGunLock and bHasGunLock and ItemData.ItemID == StoreConfig.GunLockItemID or bNeedTacticalAttach and bHasTacticalAttach and ItemData.ItemID == StoreConfig.TacticalAttachItemID then
          table.insert(CurrentSpecialAccessoriesData, ItemData)
        else
          table.insert(CurrentSubData, ItemData)
        end
      end
    end
    for Index, ItemData in pairs(CurrentSpecialAccessoriesData) do
      table.insert(CurrentSubData, Index, ItemData)
    end
  else
    local RotatingDiscountItems = {}
    local NormalItems = {}
    for Order, ItemData in pairsByKeys(SubItemData) do
      if ItemData then
        if ItemData.bRotatingDiscount then
          table.insert(RotatingDiscountItems, {Order = Order, ItemData = ItemData})
        else
          table.insert(NormalItems, {Order = Order, ItemData = ItemData})
        end
      end
    end
    table.sort(RotatingDiscountItems, function(a, b)
      return a.Order < b.Order
    end)
    table.sort(NormalItems, function(a, b)
      return a.Order < b.Order
    end)
    for _, Item in ipairs(RotatingDiscountItems) do
      table.insert(CurrentSubData, Item.ItemData)
    end
    for _, Item in ipairs(NormalItems) do
      table.insert(CurrentSubData, Item.ItemData)
    end
  end
  return CurrentSubData
end
function LogicClassicStore.GetStoreLimitTime(tStore)
  if not tStore or tStore.StoreID ~= StoreConfig.CarloStore then
    return nil
  end
  local fEndTimeStep = tStore:GetEndTimeStep()
  if not fEndTimeStep then
    return nil
  end
  local uGameState = GameplayData.GetGameState()
  if not Game:IsValid(uGameState) then
    return nil
  end
  local nLeftTime = math.floor(fEndTimeStep - uGameState:GetServerWorldTimeSeconds())
  return nLeftTime
end
return LogicClassicStore