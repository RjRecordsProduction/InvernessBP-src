local FormatLog = FuncUtil.FormatLog
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local FriendlyBehaviorModule = require("GameLua.Mod.BaseMod.Common.Security.FriendlyBehavior")
local ASTExtraPlayerState = import("/Script/ShadowTrackerExtra.STExtraPlayerState")
local BRGameStateStoreFeature = {}
function BRGameStateStoreFeature:ctor()
  self.FriendlyPointsDayMaxValue = 100
  self.FriendlyPointsTotalMaxValue = 200
  self.FriendlyGiftBoxBuyMaxCount = 1
  self.FriendlyGiftBoxPrice = 100
  self.FriendlyPointsMaxGainingPerGame = 20
  self.FriendlyPointsHealTeammate = 1
  self.FriendlyPointsRescueTeammate = 10
  self.FriendlyPointsRecallTeammate = 10
  if Client then
    FormatLog("friendly ResetCacheDataFromPlayerState")
    FriendlyBehaviorModule.ResetCacheDataFromGameState()
  end
  FormatLog("ctor init friendly value")
end
function BRGameStateStoreFeature:ReceiveBeginPlay()
  BRGameStateStoreFeature.__super.ReceiveBeginPlay(self)
  if self:HasAuthority() then
    if not CGame:IsEditor() then
      if ServerDataMgr and ServerDataMgr.SyncGameParams then
        self.FriendlyPointsDayMaxValue = ServerDataMgr.SyncGameParams.friendly_points_day_max_value or 100
        self.FriendlyPointsTotalMaxValue = ServerDataMgr.SyncGameParams.friendly_points_total_max_value or 200
        self.FriendlyGiftBoxBuyMaxCount = ServerDataMgr.SyncGameParams.friendly_points_gift_box_buy_max_cnt or 1
        self.FriendlyGiftBoxPrice = ServerDataMgr.SyncGameParams.friendly_points_gift_box_price or 100
        self.FriendlyPointsMaxGainingPerGame = ServerDataMgr.SyncGameParams.friendly_points_game_max_value or 20
        self.FriendlyPointsHealTeammate = ServerDataMgr.SyncGameParams.friendly_points_heal_teammate_value or 1
        self.FriendlyPointsRescueTeammate = ServerDataMgr.SyncGameParams.friendly_points_rescue_teammate_value or 10
        self.FriendlyPointsRecallTeammate = ServerDataMgr.SyncGameParams.friendly_points_recall_teammate_value or 10
        FormatLog("Init from ServerDataMgr.SyncGameParams, battle_type[%s]", ServerDataMgr.SyncGameParams.battle_type)
        FormatLog("friendly_points_day_max_value[%s]", ServerDataMgr.SyncGameParams.friendly_points_day_max_value)
        FormatLog("friendly_points_total_max_value[%s]", ServerDataMgr.SyncGameParams.friendly_points_total_max_value)
        FormatLog("friendly_points_gift_box_buy_max_cnt[%s]", ServerDataMgr.SyncGameParams.friendly_points_gift_box_buy_max_cnt)
        FormatLog("friendly_points_gift_box_price[%s]", ServerDataMgr.SyncGameParams.friendly_points_gift_box_price)
        FormatLog("friendly_points_game_max_value[%s]", ServerDataMgr.SyncGameParams.friendly_points_game_max_value)
        FormatLog("friendly_points_heal_teammate_value[%s]", ServerDataMgr.SyncGameParams.friendly_points_heal_teammate_value)
        FormatLog("friendly_points_rescue_teammate_value[%s]", ServerDataMgr.SyncGameParams.friendly_points_rescue_teammate_value)
        FormatLog("friendly_points_recall_teammate_value[%s]", ServerDataMgr.SyncGameParams.friendly_points_recall_teammate_value)
      else
        FormatLog("Error:Invalid ServerDataMgr.SyncGameParams")
      end
    end
    FormatLog("FriendlyPointsDayMaxValue[%s]", self.FriendlyPointsDayMaxValue)
    FormatLog("FriendlyPointsTotalMaxValue[%s]", self.FriendlyPointsTotalMaxValue)
    FormatLog("FriendlyGiftBoxBuyMaxCount[%s]", self.FriendlyGiftBoxBuyMaxCount)
    FormatLog("FriendlyGiftBoxPrice[%s]", self.FriendlyGiftBoxPrice)
    FormatLog("FriendlyPointsMaxGainingPerGame[%s]", self.FriendlyPointsMaxGainingPerGame)
    FormatLog("FriendlyPointsHealTeammate[%s]", self.FriendlyPointsHealTeammate)
    FormatLog("FriendlyPointsRescueTeammate[%s]", self.FriendlyPointsRescueTeammate)
    FormatLog("FriendlyPointsRecallTeammate[%s]", self.FriendlyPointsRecallTeammate)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PAWN_RESCUE, self.OnPawnRescue, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_REVIVE_COMMON_SUCCESS_NUM, self.OnReviveCommonSuccessNum, self)
    self:AddCommonEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_STRONGEST_REVIVE, self.OnStrongestRevive, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_INTERACTIVE_BEHAVIOR, self.OnPlayerInteractiveBehavior, self)
  end
end
function BRGameStateStoreFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local FBattleGoodInfo = import("BattleGoodInfo")
  local FBuyGoodsInfo = import("BuyGoodInfo")
  local RepTable = {
    {
      "DesignatedStorePatchGoodsList",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      FBattleGoodInfo
    },
    {
      "NeonPremiumStorePatchGoodsList",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      FBattleGoodInfo
    },
    {
      "DesignatedStoreBuyGoodsList",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      FBuyGoodsInfo
    },
    {
      "nGameReadyTimeConfigValue",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "DiscountStorePatchGoodsList",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      FBuyGoodsInfo
    },
    {
      "KFCStorePatchGoodsList",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      FBuyGoodsInfo
    },
    {
      "BuyAndSellStorePatchGoodsList",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      FBuyGoodsInfo
    },
    {
      "FriendlyPointsDayMaxValue",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "FriendlyPointsTotalMaxValue",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "FriendlyPointsMaxGainingPerGame",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "FriendlyPointsHealTeammate",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "FriendlyPointsRescueTeammate",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "FriendlyPointsRecallTeammate",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "FriendlyGiftBoxBuyMaxCount",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "FriendlyGiftBoxPrice",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    }
  }
  return RepTable
end
function BRGameStateStoreFeature:OnRep_FriendlyPointsDayMaxValue()
  FormatLog("OnRep_FriendlyPointsDayMaxValue[%d]", self.FriendlyPointsDayMaxValue)
  FriendlyBehaviorModule.CacheFriendlyPointsDayMaxValue(self.FriendlyPointsDayMaxValue)
end
function BRGameStateStoreFeature:OnRep_FriendlyPointsTotalMaxValue()
  FormatLog("OnRep_FriendlyPointsTotalMaxValue[%d]", self.FriendlyPointsTotalMaxValue)
  FriendlyBehaviorModule.CacheFriendlyPointsTotalMaxValue(self.FriendlyPointsTotalMaxValue)
end
function BRGameStateStoreFeature:OnRep_FriendlyPointsMaxGainingPerGame()
  FormatLog("OnRep_FriendlyPointsMaxGainingPerGame[%d]", self.FriendlyPointsMaxGainingPerGame)
  FriendlyBehaviorModule.CacheFriendlyPointsMaxGainingPerGame(self.FriendlyPointsMaxGainingPerGame)
end
function BRGameStateStoreFeature:OnRep_FriendlyPointsHealTeammate()
  FormatLog("OnRep_FriendlyPointsHealTeammate[%d]", self.FriendlyPointsHealTeammate)
  FriendlyBehaviorModule.CacheFriendlyPointsHealTeammate(self.FriendlyPointsHealTeammate)
end
function BRGameStateStoreFeature:OnRep_FriendlyPointsRescueTeammate()
  FormatLog("OnRep_FriendlyPointsRescueTeammate[%d]", self.FriendlyPointsRescueTeammate)
  FriendlyBehaviorModule.CacheFriendlyPointsRescueTeammate(self.FriendlyPointsRescueTeammate)
end
function BRGameStateStoreFeature:OnRep_FriendlyPointsRecallTeammate()
  FormatLog("OnRep_FriendlyPointsRecallTeammate[%d]", self.FriendlyPointsRecallTeammate)
  FriendlyBehaviorModule.CacheFriendlyPointsRecallTeammate(self.FriendlyPointsRecallTeammate)
end
function BRGameStateStoreFeature:OnRep_FriendlyGiftBoxPrice()
  FormatLog("OnRep_FriendlyGiftBoxPrice[%d]", self.FriendlyGiftBoxPrice)
  FriendlyBehaviorModule.CacheFriendlyGiftBoxPrice(self.FriendlyGiftBoxPrice)
end
function BRGameStateStoreFeature:OnRep_FriendlyGiftBoxBuyMaxCount()
  FormatLog("OnRep_FriendlyGiftBoxBuyMaxCount[%d]", self.FriendlyGiftBoxBuyMaxCount)
  FriendlyBehaviorModule.CacheFriendlyGiftBoxBuyMaxCount(self.FriendlyGiftBoxBuyMaxCount)
end
function BRGameStateStoreFeature:OnPawnRescue(_, _, Rescuer, Rescuee)
  if slua.isValid(Rescuer) and slua.isValid(Rescuee) and Rescuer ~= Rescuee then
    FormatLog("Friendly Rescuer[%d][%s] Rescuee[%d][%s] gain points", Rescuer.PlayerKey, Rescuer.PlayerName, Rescuee.PlayerKey, Rescuee.PlayerName)
    local uPlayerState = GameplayData.GetPlayerState(Rescuer.PlayerKey)
    if uPlayerState and uPlayerState.StoreFeature then
      uPlayerState.StoreFeature:GainFriendlyPoints(uPlayerState.StoreFeature.EGainFriendlyPointsType.RescueTeammate)
      FormatLog("[OnPawnRescue] Friendly Rescuer[%d][%s] Rescuee[%d][%s] gain points", Rescuer.PlayerKey, Rescuer.PlayerName, Rescuee.PlayerKey, Rescuee.PlayerName)
    else
      FormatLog("[OnPawnRescue] Invalid uPlayerState.StoreFeature")
    end
  end
end
function BRGameStateStoreFeature:OnReviveCommonSuccessNum(_, _, nReviveType, nRecallerPlayerKey, nRecallCount)
  FormatLog("[OnReviveCommonSuccessNum] nReviveType[%d] nRecallerPlayerKey[%u] nRecallCount[%d]", nReviveType, nRecallerPlayerKey, nRecallCount)
  if nReviveType == 4 or nReviveType == 5 then
    FormatLog("[OnReviveCommonSuccessNum] nReviveType[%d] return", nReviveType)
    return
  end
  local uPlayerState = GameplayData.GetPlayerState(nRecallerPlayerKey)
  if slua.isValid(uPlayerState) then
    if uPlayerState.StoreFeature then
      uPlayerState.StoreFeature:GainFriendlyPoints(uPlayerState.StoreFeature.EGainFriendlyPointsType.RecallTeammate, nRecallCount)
      FormatLog("[OnReviveCommonSuccessNum] Friendly Recaller[%d][%s] gain points", uPlayerState.PlayerKey, uPlayerState.PlayerName)
    else
      FormatLog("[OnReviveCommonSuccessNum] Invalid uPlayerState.StoreFeature")
    end
  end
end
function BRGameStateStoreFeature:OnStrongestRevive(_, _, uCharacter, nRecallCount)
  if not slua.isValid(uCharacter) then
    FormatLog("[OnStrongestRevive] invalid uCharacter")
  end
  FormatLog("[OnStrongestRevive] uCharacter[%s][%s] nRecallCount[%s]", uCharacter.PlayerName, uCharacter.PlayerKey, nRecallCount)
  local uPlayerState = GameplayData.GetPlayerState(uCharacter.PlayerKey)
  if slua.isValid(uPlayerState) then
    if uPlayerState.StoreFeature then
      uPlayerState.StoreFeature:GainFriendlyPoints(uPlayerState.StoreFeature.EGainFriendlyPointsType.RecallTeammate, nRecallCount)
      FormatLog("[OnStrongestRevive] Friendly Recaller[%d][%s] gain points", uPlayerState.PlayerKey, uPlayerState.PlayerName)
    else
      FormatLog("[OnStrongestRevive] Invalid uPlayerState.StoreFeature")
    end
  end
end
function BRGameStateStoreFeature:OnPlayerInteractiveBehavior(_, _, nSourceUID, nTargetUID, sBehaviorType)
  if sBehaviorType == "AddBlood" then
    local uPlayerState = Game:GetPlayerStateByUID(nTargetUID)
    if uPlayerState and uPlayerState.StoreFeature then
      uPlayerState.StoreFeature:GainFriendlyPoints(uPlayerState.StoreFeature.EGainFriendlyPointsType.HealTeammate)
      FormatLog("[OnPlayerInteractiveBehavior] Friendly Healer[%d][%s] gain points", uPlayerState.PlayerKey, uPlayerState.PlayerName)
    else
      FormatLog("[OnPlayerInteractiveBehavior] Invalid uPlayerState.StoreFeature")
    end
  end
end
function BRGameStateStoreFeature:OnRep_DesignatedStoreBuyGoodsList()
  print(bWriteLog and "BRGameStateStoreFeature:OnRep_DesignatedStoreBuyGoodsList")
  local StoreConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.StoreConfig")
  self:RefreshClientBuyGoodsData(StoreConfig.DesignatedStore)
end
function BRGameStateStoreFeature:OnRep_DesignatedStorePatchGoodsList()
  print(bWriteLog and "BRGameStateStoreFeature:OnRep_DesignatedStorePatchGoodsList")
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.Gameplay.Store.GameStateStoreFeatureBase")
return class(CFeatureBase, nil, BRGameStateStoreFeature)