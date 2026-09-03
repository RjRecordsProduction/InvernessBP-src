local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
local FormatLog = FuncUtil.FormatLog
local LogIf = SecurityCommonUtils.LogIf
local TimeUtil = require("client.common.time_util")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local FriendlyBehaviorModule = require("GameLua.Mod.BaseMod.Common.Security.FriendlyBehavior")
local BRPlayerStateStoreFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
function BRPlayerStateStoreFeature:ctor()
  FormatLog("BRPlayerStateStoreFeature:ctor called")
end
function BRPlayerStateStoreFeature:_PostConstruct()
  BRPlayerStateStoreFeature.__super._PostConstruct(self)
  self.bHasInit = false
end
function BRPlayerStateStoreFeature:ReceiveBeginPlay()
  BRPlayerStateStoreFeature.__super.ReceiveBeginPlay(self)
  local StoreConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.StoreConfig")
  self.LastSearchStoreTime = 0 - StoreConfig.HideFarStoreScreenMarkTime
  print(bWriteLog and "BRPlayerStateStoreFeature:ReceiveBeginPlay", self.Owner)
  if not Client then
    self.tFarScreenMarkList = {}
  end
end
function BRPlayerStateStoreFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local FBuyGoodsInfo = import("BuyGoodInfo")
  local RepTable = {
    {
      "DesignatedStoreBuyGoodsList",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Array,
      FBuyGoodsInfo
    },
    {
      "FriendlyPointsCurrValue",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "FriendlyPointsTodayValue",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "FriendlyUsesCountThisGame",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "FriendlyPointsGainedThisGame",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Int
    }
  }
  return RepTable
end
function BRPlayerStateStoreFeature:ReceivePostLoginInit()
  if not self.Owner then
    FormatLog("BRPlayerStateStoreFeature:ReceivePostLoginInit, self.Owner is nil")
    return
  end
  if not slua.isValid(self.Owner:GetOwner()) then
    FormatLog("BRPlayerStateStoreFeature:ReceivePostLoginInit, self.Owner:GetOwner() is nil")
    return
  end
  if self:HasAuthority() then
    if CGame:IsEditor() then
      if not self.bHasInit then
        self.FriendlyPointsCurrValue = 100
        self.FriendlyPointsTodayValue = 0
        self.FriendlyPointsTodayTs = TimeUtil.OSTime()
        self.bHasInit = true
      else
        FormatLog("[%u][%s] bHasInit is true", self.Owner.PlayerKey, self.Owner.PlayerName)
      end
    elseif not self.bHasInit then
      local uPlayerController = self.Owner:GetOwner()
      local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
      local tPlayerInfo = ServerPlayerDataMgr.GetPlayerInfo(uPlayerController.UID)
      if tPlayerInfo and tPlayerInfo.friendly_points_curr_value then
        self.FriendlyPointsCurrValue = tPlayerInfo.friendly_points_curr_value or 0
        self.FriendlyPointsTodayValue = tPlayerInfo.friendly_points_today_value or 0
        self.FriendlyPointsTodayTs = tPlayerInfo.friendly_points_today_ts or 0
        FormatLog("[%u][%s] Init from PlayerInfo", self.Owner.PlayerKey, self.Owner.PlayerName)
        FormatLog("tPlayerInfo.friendly_points_curr_value[%s]", tPlayerInfo.friendly_points_curr_value)
        FormatLog("tPlayerInfo.friendly_points_today_value[%s]", tPlayerInfo.friendly_points_today_value)
        FormatLog("tPlayerInfo.friendly_points_today_ts[%s]", tPlayerInfo.friendly_points_today_ts)
      else
        FormatLog("Errror: [%u][%s] tPlayerInfo is nil", self.Owner.PlayerKey, self.Owner.PlayerName)
      end
      self.bHasInit = true
    else
      FormatLog("[%u][%s] bHasInit is true", self.Owner.PlayerKey, self.Owner.PlayerName)
    end
    self.FriendlyPointsGainedThisGame = 0
    self.FriendlyUsesCountThisGame = 0
    self.FriendlyPointsChangeFlow = ""
    local sTimeStamp = ""
    if TimeUtil.OSDate then
      sTimeStamp = TimeUtil.OSDate("%Y-%m-%d %H:%M:%S", self.FriendlyPointsTodayTs)
    end
    FormatLog("[%u][%s] Init FriendlyPointsCurrValue[%s], FriendlyPointsTodayValue[%s], FriendlyPointsTodayTs[%s,%s], FriendlyPointsGainedThisGame[%d], FriendlyUsesCountThisGame[%d], FriendlyPointsChangeFlow[%s]", self.Owner.PlayerKey, self.Owner.PlayerName, self.FriendlyPointsCurrValue, self.FriendlyPointsTodayValue, self.FriendlyPointsTodayTs, sTimeStamp, self.FriendlyPointsGainedThisGame, self.FriendlyUsesCountThisGame, self.FriendlyPointsChangeFlow)
  end
end
function BRPlayerStateStoreFeature:RPC_Server_BuyGoods(StoreActor, GoodIDs, GoodNums, GoodIndexs)
  BRPlayerStateStoreFeature.__super.RPC_Server_BuyGoods(self, StoreActor, GoodIDs, GoodNums, GoodIndexs)
end
function BRPlayerStateStoreFeature:RPC_Server_OpenStore(StoreActor)
  BRPlayerStateStoreFeature.__super.RPC_Server_OpenStore(self, StoreActor)
end
function BRPlayerStateStoreFeature:RPC_Server_CloseStore(uStoreActor, nCloseStoreReason)
  BRPlayerStateStoreFeature.__super.RPC_Server_CloseStore(self, uStoreActor, nCloseStoreReason)
end
function BRPlayerStateStoreFeature:RPC_Client_BuyGoodsFinished(bSuccess)
  BRPlayerStateStoreFeature.__super.RPC_Client_BuyGoodsFinished(self, bSuccess)
end
function BRPlayerStateStoreFeature:OnRep_DesignatedStoreBuyGoodsList()
  print(bWriteLog and "BRPlayerStateStoreFeature:OnRep_DesignatedStoreBuyGoodsList")
  local StoreConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.StoreConfig")
  self:RefreshClientBuyGoodsData(StoreConfig.DesignatedStore)
end
function BRPlayerStateStoreFeature:OnRep_FriendlyPointsCurrValue()
  FriendlyBehaviorModule.CacheFriendlyPointsCurrValue(self.FriendlyPointsCurrValue)
  local Owner = self.Owner
  if not Owner then
    return
  end
  FormatLog("[%u][%s] OnRep_FriendlyPointsCurrValue[%d]", Owner.PlayerKey, Owner.PlayerName, self.FriendlyPointsCurrValue)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_PLAYER_STATE_FriendlyPointsCurrValue_CHANGED, Owner, self.FriendlyPointsCurrValue)
end
function BRPlayerStateStoreFeature:OnRep_FriendlyPointsTodayValue()
  FriendlyBehaviorModule.CacheFriendlyPointsTodayValue(self.FriendlyPointsTodayValue)
  local Owner = self.Owner
  if not Owner then
    return
  end
  FormatLog("[%u][%s] OnRep_FriendlyPointsTodayValue[%d]", Owner.PlayerKey, Owner.PlayerName, self.FriendlyPointsTodayValue)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_PLAYER_STATE_FriendlyPointsTodayValue_CHANGED, Owner, self.FriendlyPointsTodayValue)
end
function BRPlayerStateStoreFeature:OnRep_FriendlyUsesCountThisGame()
  FriendlyBehaviorModule.CacheFriendlyUsesCountThisGame(self.FriendlyUsesCountThisGame)
  local Owner = self.Owner
  if not Owner then
    return
  end
  FormatLog("[%u][%s] OnRep_FriendlyUsesCountThisGame[%d]", Owner.PlayerKey, Owner.PlayerName, self.FriendlyUsesCountThisGame)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_PLAYER_STATE_FriendlyUsesCountThisGame_CHANGED, Owner, self.FriendlyUsesCountThisGame)
end
function BRPlayerStateStoreFeature:OnRep_FriendlyPointsGainedThisGame()
  FriendlyBehaviorModule.CacheFriendlyPointsGainedThisGame(self.FriendlyPointsGainedThisGame)
  local Owner = self.Owner
  if not Owner then
    return
  end
  FormatLog("[%u][%s] OnRep_FriendlyPointsGainedThisGame[%d]", Owner.PlayerKey, Owner.PlayerName, self.FriendlyPointsGainedThisGame)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_PLAYER_STATE_FriendlyPointsGainedThisGame_CHANGED, Owner, self.FriendlyPointsGainedThisGame)
end
BRPlayerStateStoreFeature.EGainFriendlyPointsType = {
  HealTeammate = 1,
  RescueTeammate = 2,
  RecallTeammate = 3
}
function BRPlayerStateStoreFeature:GetGainFriendlyPoints(nType)
  local uGameState = GameplayData.GetGameState()
  if not uGameState then
    return 0
  end
  if nType == BRPlayerStateStoreFeature.EGainFriendlyPointsType.HealTeammate then
    return uGameState.StoreFeature.FriendlyPointsHealTeammate
  elseif nType == BRPlayerStateStoreFeature.EGainFriendlyPointsType.RescueTeammate then
    return uGameState.StoreFeature.FriendlyPointsRescueTeammate
  elseif nType == BRPlayerStateStoreFeature.EGainFriendlyPointsType.RecallTeammate then
    return uGameState.StoreFeature.FriendlyPointsRecallTeammate
  end
  return 0
end
function BRPlayerStateStoreFeature:GainFriendlyPoints(GainPointsType, nRecallCount)
  nRecallCount = nRecallCount or 1
  if nRecallCount <= 0 then
    FormatLog("Error: nRecallCount <= 0")
    nRecallCount = 1
  end
  if not self:HasAuthority() then
    return
  end
  if not FriendlyBehaviorModule.IsEnableFriendlyGiftBox() then
    FormatLog("IsEnableFriendlyGiftBox=false")
    return
  end
  local nPoints = self:GetGainFriendlyPoints(GainPointsType)
  nPoints = nPoints * nRecallCount
  if not nPoints or nPoints <= 0 then
    FormatLog("invalid nPoints[%s]", nPoints)
    return
  end
  if not self.FriendlyPointsTodayTs then
    FormatLog("self.FriendlyPointsTodayTs is nil")
    return
  end
  local nNowTimetamp = TimeUtil.OSTime()
  local bIsSameDay = TimeUtil.IsSameDay(self.FriendlyPointsTodayTs, nNowTimetamp)
  if not bIsSameDay then
    self.FriendlyPointsTodayValue = 0
    self.FriendlyPointsTodayTs = nNowTimetamp
    local sTimeStamp = TimeUtil.OSDate("%Y-%m-%d %H:%M:%S", self.FriendlyPointsTodayTs)
    FormatLog("bIsSameDay=false, Refresh FriendlyPointsTodayValue, FriendlyPointsTodayTs[%s,%s]", self.FriendlyPointsTodayTs, sTimeStamp)
  end
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    return
  end
  local Owner = self.Owner
  if not Owner then
    return
  end
  local FriendlyPointsDayMaxValue = uGameState.StoreFeature.FriendlyPointsDayMaxValue or 0
  local FriendlyPointsTotalMaxValue = uGameState.StoreFeature.FriendlyPointsTotalMaxValue or 0
  local FriendlyPointsMaxGainingPerGame = uGameState.StoreFeature.FriendlyPointsMaxGainingPerGame or 0
  local nPointsCanGain = math.min(FriendlyPointsMaxGainingPerGame - self.FriendlyPointsGainedThisGame, FriendlyPointsDayMaxValue - self.FriendlyPointsTodayValue, FriendlyPointsTotalMaxValue - self.FriendlyPointsCurrValue, nPoints)
  if nPointsCanGain <= 0 then
    FormatLog("[%u][%s] GainFriendlyPoints blocked. Reached some max limits. nPoints[%d]", Owner.PlayerKey, Owner.PlayerName, nPoints)
    FormatLog("[%u][%s] PerGameMax: [%d - %d = %d]", Owner.PlayerKey, Owner.PlayerName, FriendlyPointsMaxGainingPerGame, self.FriendlyPointsGainedThisGame, FriendlyPointsMaxGainingPerGame - self.FriendlyPointsGainedThisGame)
    FormatLog("[%u][%s] DayMax    : [%d - %d = %d]", Owner.PlayerKey, Owner.PlayerName, FriendlyPointsDayMaxValue, self.FriendlyPointsTodayValue, FriendlyPointsDayMaxValue - self.FriendlyPointsTodayValue)
    FormatLog("[%u][%s] TotalMax  : [%d - %d = %d]", Owner.PlayerKey, Owner.PlayerName, FriendlyPointsTotalMaxValue, self.FriendlyPointsCurrValue, FriendlyPointsTotalMaxValue - self.FriendlyPointsCurrValue)
    return
  end
  self.FriendlyPointsGainedThisGame = self.FriendlyPointsGainedThisGame + nPointsCanGain
  self.FriendlyPointsTodayValue = self.FriendlyPointsTodayValue + nPointsCanGain
  self.FriendlyPointsCurrValue = self.FriendlyPointsCurrValue + nPointsCanGain
  FormatLog(string.format("[%u][%s] Type[%d], nPoints[%d], nPointsCanGain[%d], Total=[%d/%d], Today[%d/%d], ThisGame[%d/%d]", Owner.PlayerKey, Owner.PlayerName, GainPointsType, nPoints, nPointsCanGain, self.FriendlyPointsCurrValue, FriendlyPointsTotalMaxValue, self.FriendlyPointsTodayValue, FriendlyPointsDayMaxValue, self.FriendlyPointsGainedThisGame, FriendlyPointsMaxGainingPerGame))
  self:RecordFriendlyPointsChangeFlow(GainPointsType, nPointsCanGain)
end
function BRPlayerStateStoreFeature:CanBuyFriendlyGiftBox()
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    return false
  end
  if not uGameState.StoreFeature then
    return false
  end
  if not FriendlyBehaviorModule.IsEnableFriendlyGiftBox() then
    FormatLog("IsEnableFriendlyGiftBox=false")
    return false
  end
  if self.FriendlyPointsCurrValue < uGameState.StoreFeature.FriendlyGiftBoxPrice then
    FormatLog("FriendlyPointsCurrValue[%s] < FriendlyGiftBoxPrice[%s]", self.FriendlyPointsCurrValue, uGameState.StoreFeature.FriendlyGiftBoxPrice)
    return false
  end
  if self.FriendlyUsesCountThisGame >= uGameState.StoreFeature.FriendlyGiftBoxBuyMaxCount then
    FormatLog("FriendlyUsesCountThisGame[%s] >= FriendlyGiftBoxBuyMaxCount[%s]", self.FriendlyUsesCountThisGame, uGameState.StoreFeature.FriendlyGiftBoxBuyMaxCount)
    return false
  end
  return true
end
function BRPlayerStateStoreFeature:ConsumeFriendlyGiftBoxCost()
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    FormatLog("Invalid uGameState")
    return
  end
  if not uGameState.StoreFeature then
    FormatLog("uGameState.StoreFeature is nil")
    return
  end
  local Owner = self.Owner
  if not self:CanBuyFriendlyGiftBox() and Owner then
    FormatLog("[%u][%s] ConsumeFriendlyGiftBoxCost Error, CanBuyFriendlyGiftBox return false. [%d][%d]", Owner.PlayerKey, Owner.PlayerName, self.FriendlyPointsCurrValue, self.FriendlyUsesCountThisGame)
  end
  if Owner then
    FormatLog("[%u][%s] before ConsumeFriendlyGiftBoxCost[%d][%d]", Owner.PlayerKey, Owner.PlayerName, self.FriendlyPointsCurrValue, self.FriendlyUsesCountThisGame)
  end
  self.FriendlyPointsCurrValue = self.FriendlyPointsCurrValue - uGameState.StoreFeature.FriendlyGiftBoxPrice
  self.FriendlyUsesCountThisGame = self.FriendlyUsesCountThisGame + 1
  if Owner then
    FormatLog("[%u][%s] after  ConsumeFriendlyGiftBoxCost[%d][%d]", Owner.PlayerKey, Owner.PlayerName, self.FriendlyPointsCurrValue, self.FriendlyUsesCountThisGame)
  end
  self:RecordFriendlyPointsChangeFlow(4, 0 - uGameState.StoreFeature.FriendlyGiftBoxPrice)
end
function BRPlayerStateStoreFeature:RecordFriendlyPointsChangeFlow(nType, nPoint)
  if not self:HasAuthority() then
    return
  end
  local sFlow = string.format("%d:%d", nType, nPoint)
  if self.FriendlyPointsChangeFlow == "" then
    self.FriendlyPointsChangeFlow = sFlow
  else
    self.FriendlyPointsChangeFlow = self.FriendlyPointsChangeFlow .. ";" .. sFlow
  end
  FormatLog("[%u][%s] RecordFriendlyPointsChangeFlow[%s]", self.Owner.PlayerKey, self.Owner.PlayerName, self.FriendlyPointsChangeFlow)
end
function BRPlayerStateStoreFeature:ProcessPlayerResult(nUID, tResult)
  FormatLog("")
  tResult.friendly_points_curr_value = self.friendly_points_curr_value
  tResult.friendly_points_today_value = self.friendly_points_today_value
  tResult.friendly_points_today_ts = self.friendly_points_today_ts
  tResult.friendly_points_change_flow = {}
end
function BRPlayerStateStoreFeature:RPC_Server_ShowNearestStore()
  if Client then
    return
  end
  print(bWriteLog and "BRPlayerStateStoreFeature:RPC_Server_ShowNearestStore")
  if not self:CheckSearchStoreTimeLimit() then
    return
  end
  local DSPreCalcMapIconSubsystem = SubsystemMgr:Get("DSPreCalcMapIconSubsystem")
  if not DSPreCalcMapIconSubsystem then
    print(bWriteLog and "BRPlayerStateStoreFeature:RPC_Server_ShowNearestStore DSPreCalcMapIconSubsystem is nil")
    return
  end
  local uPlayerState = self.Owner
  local uPlayerCharacter = uPlayerState:GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    return
  end
  if self.HideNearestClassicStoreScreenMarkTimer then
    return
  end
  print(bWriteLog and "BRPlayerStateStoreFeature:RPC_Server_ShowNearestStore", self.Owner)
  local StoreConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.StoreConfig")
  local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
  for _, sStoreTag in pairs(StoreConfig.tStoreTags) do
    local PreCalMarkDatas = DSPreCalcMapIconSubsystem:GetMarkActionByName(sStoreTag)
    if PreCalMarkDatas then
      for _, uMapMarkData in pairs(PreCalMarkDatas) do
        local StoreLocation = uMapMarkData.Location
        local uMarkInstID = InGameMarkTools.ServerAddMapMark(1009, StoreLocation + FVector(0, 0, 150), 0, 4, nil, 0, uPlayerState)
        local num = #self.tFarScreenMarkList + 1
        self.tFarScreenMarkList[num] = uMarkInstID
        print(bWriteLog and "BRPlayerStateStoreFeature:RPC_Server_ShowNearestStore uMarkAction", num, uMarkInstID)
      end
    end
  end
  Game:UIShowTips(Game:GetPlayerKey(uPlayerCharacter), 48601)
  self.HideNearestClassicStoreScreenMarkTimer = self:AddGameTimer(StoreConfig.HideFarStoreScreenMarkTime, true, function()
    self:ClearFarScreenMarkList()
  end)
end
function BRPlayerStateStoreFeature:ClearFarScreenMarkList()
  print(bWriteLog and "BRPlayerStateStoreFeature:ClearFarScreenMarkList", self.Owner)
  local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
  for Index, uMarkAction in pairs(self.tFarScreenMarkList) do
    print(bWriteLog and "BRPlayerStateStoreFeature:ClearFarScreenMarkList uMarkAction", Index, uMarkAction)
    if uMarkAction then
      InGameMarkTools.HideMapMark(uMarkAction)
    end
  end
  self.tFarScreenMarkList = {}
  self.HideNearestClassicStoreScreenMarkTimer = nil
end
function BRPlayerStateStoreFeature:CheckSearchStoreTimeLimit()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    return false
  end
  local Now = uGameState:GetServerWorldTimeSeconds()
  local StoreConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.StoreConfig")
  if Now > self.LastSearchStoreTime + StoreConfig.HideFarStoreScreenMarkTime then
    self.LastSearchStoreTime = Now
    return true
  end
  print(bWriteLog and "BRPlayerStateStoreFeature:CheckSearchStoreTimeLimit false")
  return false
end
function BRPlayerStateStoreFeature:ShowNearestClassicStoreScreenMark()
  local bSearchStoreTimeLimit = self:CheckSearchStoreTimeLimit()
  print(bWriteLog and "BRPlayerStateStoreFeature:ShowNearestClassicStoreScreenMark", bSearchStoreTimeLimit)
  if not bSearchStoreTimeLimit then
    EventSystem:postEvent(EVENTTYPE_INGAME_CLASSICSTORE, EVENTID_INGAME_CLASSICSTORE_REFIND_NEAREST_STORE)
  else
    self:RPC_Server_ShowNearestStore()
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local BackpackUI = InGameUITools.GetBackpackUI()
  if BackpackUI and slua.isValid(BackpackUI.UIRoot) then
    BackpackUI:ClickCloseBackpack()
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.Gameplay.Store.PlayerStateStoreFeatureBase")
return class(CFeatureBase, nil, BRPlayerStateStoreFeature)