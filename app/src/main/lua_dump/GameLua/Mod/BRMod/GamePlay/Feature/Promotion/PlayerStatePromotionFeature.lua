local PlayerStatePromotionFeature = {
  ServerRPC = {},
  ClientRPC = {}
}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
PlayerStatePromotionFeature.ClientRPC.ClientRPC_PromotionRoundPassed = {
  Reliable = true,
  Params = {}
}
PlayerStatePromotionFeature.ClientRPC.ClientRPC_PromotionSeriesComplete = {
  Reliable = true,
  Params = {}
}
function PlayerStatePromotionFeature:ctor()
  self.bPromotionChecked = false
end
function PlayerStatePromotionFeature:ReceiveBeginPlay()
  PlayerStatePromotionFeature.__super.ReceiveBeginPlay(self)
  if not Client then
    local uGameState = GameplayData.GetGameState()
    if uGameState then
      self:AddControlEvent(uGameState, "OnPlayerNumChange", self.OnHandlePlayerNumChanged, self)
      self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_REVIVE_TOWER_CLOSE, self.OnReviveTowerClose, self)
    end
  end
end
function PlayerStatePromotionFeature:ReceiveEndPlay(EndPlayReason)
  PlayerStatePromotionFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function PlayerStatePromotionFeature:OnHandlePlayerNumChanged()
  self:_CheckAndNotifyPromotion(self.Owner.UID)
end
function PlayerStatePromotionFeature:OnReviveTowerClose()
  self:_CheckAndNotifyPromotion(self.Owner.UID)
end
function PlayerStatePromotionFeature:_CheckAndNotifyPromotion()
  local uOwnerPS = self.Owner
  if not uOwnerPS then
    print(bWriteLog and "PlayerStatePromotionFeature:_CheckAndNotifyPromotion - Owner PlayerState invalid")
    return
  end
  if slua.isValid(CGameState) and CGameState:GetGameModeState() ~= "FightingState" then
    return false
  end
  if self.bPromotionChecked then
    return
  end
  local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
  if DSReviveSubsystem and not DSReviveSubsystem:GetRevivalClosedResult() then
    return
  end
  local nUID = uOwnerPS.UID
  if not uOwnerPS.PromotionLayer or uOwnerPS.PromotionLayer <= 0 then
    return
  end
  local NeedPersonRank = uOwnerPS.PromotionNeedPersonRank
  local ProgressCount = uOwnerPS.PromotionProgressCount
  local ContinueWinCount = uOwnerPS.PromotionContinueWinCount
  if not NeedPersonRank or NeedPersonRank <= 0 then
    return
  end
  local RealPlayerCount = 0
  if _G.IsEditor then
    RealPlayerCount = self:GetRealPlayerCountByUID(nUID)
  else
    RealPlayerCount = GameplayCallbacks.GetRealPlayerCountByUID(nUID)
  end
  print(bWriteLog and string.format("PlayerStatePromotionFeature:_CheckAndNotifyPromotion - UID:%d RealPlayerCount:%d NeedPersonRank:%d ProgressCount:%d ContinueWinCount:%d", nUID, RealPlayerCount, NeedPersonRank, ProgressCount or 0, ContinueWinCount or 0))
  if NeedPersonRank < RealPlayerCount then
    return
  end
  self.bPromotionChecked = true
  ProgressCount = ProgressCount or 0
  ContinueWinCount = ContinueWinCount or 0
  local ReportInfo = {
    TriggerType = 1,
    UID = nUID,
    PlayerRank = RealPlayerCount,
    NeedPersonRank = NeedPersonRank,
    TriggerTime = GamePlayTools.GetServerWorldTimeSeconds(),
    Progress = ProgressCount,
    ContinueWinCnt = ContinueWinCount
  }
  if 0 < ContinueWinCount and ContinueWinCount <= ProgressCount + 1 then
    print(bWriteLog and string.format("PlayerStatePromotionFeature:_CheckAndNotifyPromotion - Series complete! progress:%d+1 >= continueWin:%d, send ClientRPC_PromotionSeriesComplete", ProgressCount, ContinueWinCount))
    self:ClientRPC_PromotionSeriesComplete()
    if GameplayCallbacks then
      ReportInfo.TriggerType = 2
      GameplayCallbacks.ReportPromotionAchieve(ReportInfo)
    end
  else
    print(bWriteLog and string.format("PlayerStatePromotionFeature:_CheckAndNotifyPromotion - Round passed! progress:%d+1 < continueWin:%d, send ClientRPC_PromotionRoundPassed", ProgressCount, ContinueWinCount))
    self:ClientRPC_PromotionRoundPassed()
    if GameplayCallbacks then
      GameplayCallbacks.ReportPromotionAchieve(ReportInfo)
    end
  end
end
function PlayerStatePromotionFeature:GetRealPlayerCountByUID(nUID)
  local RealPlayerCount = 0
  if CGameState and CGameState.GetPlayerStateByUID then
    local uPlayerState = CGameState:GetPlayerStateByUID(nUID)
    if uPlayerState and slua.isValid(uPlayerState) and uPlayerState.GetDiedPlayerCount and 0 < uPlayerState:GetDiedPlayerCount() then
      RealPlayerCount = uPlayerState:GetDiedPlayerCount()
    end
  end
  if RealPlayerCount == 0 and CGameState then
    RealPlayerCount = CGameState:GetAlivePlayerNum() + 1
    print(bWriteLog and "GameplayCallbacks.GetRealPlayerCountByUID, no DiedPlayerCount, use GetAlivePlayerNum")
  end
  RealPlayerCount = math.max(0, math.min(100, RealPlayerCount))
  print(bWriteLog and "GameplayCallbacks.GetRealPlayerCountByUID, nUID = " .. tostring(nUID) .. ", RealPlayerCount = " .. tostring(RealPlayerCount))
  return RealPlayerCount
end
function PlayerStatePromotionFeature:ClientRPC_PromotionRoundPassed()
  print(bWriteLog and "PlayerStatePromotionFeature:ClientRPC_PromotionRoundPassed - Show round passed hint")
  IngameTipsTools.BattleGeneralTip(12411)
end
function PlayerStatePromotionFeature:ClientRPC_PromotionSeriesComplete()
  print(bWriteLog and "PlayerStatePromotionFeature:ClientRPC_PromotionSeriesComplete - Show series complete hint")
  IngameTipsTools.BattleGeneralTip(12410)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerStatePromotionFeature)