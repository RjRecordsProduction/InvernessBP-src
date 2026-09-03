local PlayerStateStoreFeatureBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local StoreActions = require("GameLua.Mod.BaseMod.GamePlay.Store.StoreActions")
local StoreConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.StoreConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function PlayerStateStoreFeatureBase:ctor()
  self.BuyGoodID2GoodsListIndex = {}
  if Client then
    self.BuyGoodCounts = {}
  end
end
function PlayerStateStoreFeatureBase:_PostConstruct()
  PlayerStateStoreFeatureBase.__super._PostConstruct(self)
end
PlayerStateStoreFeatureBase.ServerRPC.RPC_Server_BuyGoods = {
  Reliable = true,
  Params = {
    import("/Script/Engine.Actor"),
    {
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    }
  }
}
PlayerStateStoreFeatureBase.ServerRPC.RPC_Server_OpenStore = {
  Reliable = true,
  Params = {
    import("/Script/Engine.Actor")
  }
}
PlayerStateStoreFeatureBase.ServerRPC.RPC_Server_CloseStore = {
  Reliable = true,
  Params = {
    import("/Script/Engine.Actor"),
    UEnums.EPropertyClass.Int
  }
}
PlayerStateStoreFeatureBase.ServerRPC.RPC_Server_ShowNearestStore = {Reliable = true}
PlayerStateStoreFeatureBase.ClientRPC.RPC_Client_BuyGoodsFinished = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
function PlayerStateStoreFeatureBase:RPC_Server_BuyGoods(StoreActor, GoodIDs, GoodNums, GoodIndexs)
  if Client then
    return
  end
  for _, IterGoodID in pairs(GoodIDs) do
    local GoodsConfig = self:GetRealGoodConfig(StoreActor, IterGoodID)
    if not GoodsConfig then
      print(bWriteLog and "PlayerStateStoreFeatureBase:RPC_Server_BuyGoods failed, GoodsConfig is nil, goodid=" .. tostring(IterGoodID))
    end
    if GoodsConfig and not StoreConfig.IsGoodsItemOpen(GoodsConfig) then
      local PlayerController = self.Owner:GetOwner()
      if slua.isValid(PlayerController) then
        IngameTipsTools.BattleGeneralTip(4000042, "", "", PlayerController.PlayerKey, false)
      end
      print(bWriteLog and "PlayerStateStoreFeatureBase:RPC_Server_BuyGoods failed, Good's not Open, goodid=" .. tostring(IterGoodID))
      return
    end
  end
  for key, iterGoodID in pairs(GoodIDs) do
    local GoodBuyType = self:GetGoodBuyTypeByID(StoreActor, iterGoodID)
    if GoodBuyType == StoreConfig.ExchangeItemType then
      print(bWriteLog and "PlayerStateStoreFeatureBase:RPC_Server_BuyGoods failed, Good's GoodBuyType cannot be ExchangeItemType, goodid=" .. tostring(iterGoodID))
      return
    end
  end
  print(bWriteLog and "PlayerStateStoreFeatureBase:RPC_Server_BuyGoods")
  if slua.isValid(StoreActor) and StoreActor.StoreFeature then
    StoreActor.StoreFeature:BuyGoodsFromStore(self.Owner:GetOwner(), GoodIDs, GoodNums, GoodIndexs)
  end
end
function PlayerStateStoreFeatureBase:RPC_Server_OpenStore(uStoreActor)
  if Client then
    return
  end
  print(bWriteLog and "PlayerStateStoreFeatureBase:RPC_Server_OpenStore")
  if slua.isValid(uStoreActor) and uStoreActor.StoreFeature then
    uStoreActor.StoreFeature:OperateStoreOpen(self.Owner:GetOwner())
  end
end
function PlayerStateStoreFeatureBase:RPC_Server_CloseStore(uStoreActor, nCloseStoreReason)
  if Client then
    return
  end
  print(bWriteLog and "PlayerStateStoreFeatureBase:RPC_Server_CloseStore")
  if slua.isValid(uStoreActor) and uStoreActor.StoreFeature then
    uStoreActor.StoreFeature:OperateStoreClose(self.Owner:GetOwner(), nCloseStoreReason)
  end
end
function PlayerStateStoreFeatureBase:ReduceGoods(nStoreID, nGoodID, nItemNum)
  print(bWriteLog and "PlayerStateStoreFeatureBase:ReduceGoods StoreID=" .. nStoreID .. " GoodID=" .. nGoodID .. " ItemNum=" .. nItemNum)
  StoreActions.ReduceGoods(self, nStoreID, nGoodID, nItemNum)
end
function PlayerStateStoreFeatureBase:GetGoodBuyTypeByID(InStoreActor, InGoodID)
  local uCurGameState = GameplayData.GetGameState()
  if not slua.isValid(uCurGameState) then
    print(bWriteLog and "PlayerStateStoreFeatureBase:OpenStorePanel The uGameState is nil, Refresh the store failed")
    return StoreConfig.BuyItemType
  end
  if not uCurGameState.StoreFeature then
    print(bWriteLog and "PlayerStateStoreFeatureBase:OpenStorePanel uGameState.StoreFeature is not valid")
    return StoreConfig.BuyItemType
  end
  if not slua.isValid(InStoreActor) then
    print(bWriteLog and "PlayerStateStoreFeatureBase:OpenStorePanel InStoreActor is not valid")
    return StoreConfig.BuyItemType
  end
  if InStoreActor.StoreID == nil then
    print(bWriteLog and "PlayerStateStoreFeatureBase:OpenStorePanel InStoreActor.StoreID is nil")
    return StoreConfig.BuyItemType
  end
  local GoodConfig = self:GetRealGoodConfig(InStoreActor, InGoodID)
  if not GoodConfig then
    print(bWriteLog and "PlayerStateStoreFeatureBase:OpenStorePanel GoodConfig is not valid")
    return StoreConfig.BuyItemType
  end
  return GoodConfig.GoodBuyType
end
function PlayerStateStoreFeatureBase:GetRealGoodConfig(InStoreActor, InGoodID)
  local CurGameState = GameplayData.GetGameState()
  if not slua.isValid(CurGameState) then
    print(bWriteLog and "PlayerStateStoreFeatureBase:GetRealGoodConfig The uGameState is nil")
    return nil
  end
  if not CurGameState.StoreFeature then
    print(bWriteLog and "PlayerStateStoreFeatureBase:GetRealGoodConfig The CurGameState.StoreFeature is nil")
    return nil
  end
  if not InStoreActor then
    print(bWriteLog and "PlayerStateStoreFeatureBase:GetRealGoodConfig The InStoreActor is nil")
    return nil
  end
  if not InStoreActor.StoreID and (not InStoreActor.StoreFeature or not InStoreActor.StoreFeature.StoreID) then
    print(bWriteLog and "PlayerStateStoreFeatureBase:GetRealGoodConfig The StoreID is nil")
    return nil
  end
  local StoreID = InStoreActor.StoreID or InStoreActor.StoreFeature.StoreID
  if not StoreID then
    return nil
  end
  return CurGameState.StoreFeature:GetRealGoodConfig(StoreID, InGoodID)
end
function PlayerStateStoreFeatureBase:RefreshClientBuyGoodsData(nStoreID)
  print(bWriteLog and "PlayerStateStoreFeatureBase:RefreshClientBuyGoodsData StoreID=" .. nStoreID)
  StoreActions.RefreshClientBuyGoodsData(self, nStoreID)
end
function PlayerStateStoreFeatureBase:RPC_Client_BuyGoodsFinished(bSuccess)
  if not Client then
    return
  end
  print(bWriteLog and "PlayerStateStoreFeatureBase:RPC_Client_BuyGoodsFinished bSuccess=" .. tostring(bSuccess))
  EventSystem:postEvent(EVENTTYPE_INGAME_STORE, EVENTID_INGAME_STORE_OPERATE_PRODUCT_END, bSuccess)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerStateStoreFeatureBase)