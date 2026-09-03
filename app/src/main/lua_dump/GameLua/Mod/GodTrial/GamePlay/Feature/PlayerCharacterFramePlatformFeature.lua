local FPTrialConfig = require("GameLua.Mod.GodTrial.Gameplay.Config.FPTrialConfig")
local Enum = require("GameLua.Mod.GodTrial.Gameplay.Config.EnumDefine")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PlayerCharacterFramePlatformFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
PlayerCharacterFramePlatformFeature.ClientRPC.RPC_Client_OnFPTrialPreparing = {
  Reliable = true,
  Params = {}
}
PlayerCharacterFramePlatformFeature.ClientRPC.RPC_Client_OnFPTrialCompeting = {
  Reliable = true,
  Params = {}
}
PlayerCharacterFramePlatformFeature.ClientRPC.RPC_Client_OnFPTrialEnding = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Float
  }
}
function PlayerCharacterFramePlatformFeature:ctor()
  self.FPTrialManagerIndex = 0
  self.LastFPCompetingTipTime = 0
end
function PlayerCharacterFramePlatformFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "FPTrialManagerIndex",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
end
function PlayerCharacterFramePlatformFeature:ReceiveBeginPlay()
  PlayerCharacterFramePlatformFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "PlayerCharacterFramePlatformFeature:ReceiveBeginPlay")
  if self:HasAuthority() then
    self:BindLuaObjEvent(self.Owner, "EVENTID_TAKE_DAMAGE", self.OnHandleTakeDamage, self)
  else
    GameplayData.AddSelfPlayerControllerEvent(self, "OnSpectatorChange", self.OnSpectatorChange, self)
  end
end
function PlayerCharacterFramePlatformFeature:SetFPTrialManagerIndex(Index)
  self.FPTrialManagerend
function PlayerCharacterFramePlatformFeature:OnRep_FPTrialManagerIndex(OldValue)
  self:HandleFPTrialManagerIndexChanged(OldValue)
end
function PlayerCharacterFramePlatformFeature:OnSpectatorChange()
  self:HandleFPTrialManagerIndexChanged(0)
end
function PlayerCharacterFramePlatformFeature:HandleFPTrialManagerIndexChanged(LastIndex)
  if not self.Owner or not self.Owner.Object then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local LocalPlayerCharacter = uPlayerController:GetCurPawn()
  if not slua.isValid(LocalPlayerCharacter) then
    return
  end
  if LocalPlayerCharacter.PlayerKey ~= self.Owner.Object.PlayerKey then
    return
  end
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) or not GameState.GameStateFramePlatformFeature then
    return
  end
  if self.FPTrialManagerIndex == 0 and 0 < LastIndex then
    GameState.GameStateFramePlatformFeature:LeaveFPTrialArea(LastIndex - 1)
  elseif self.FPTrialManagerIndex > 0 then
    GameState.GameStateFramePlatformFeature:EnterFPTrialArea(self.FPTrialManagerIndex - 1)
  end
end
function PlayerCharacterFramePlatformFeature:GetFPTrialManagerIndex()
  return self.FPTrialManagerIndex
end
function PlayerCharacterFramePlatformFeature:RPC_Client_OnFPTrialPreparing()
  if not Client then
    return
  end
  print(bWriteLog and "PlayerCharacterFramePlatformFeature:RPC_Client_OnFPTrialPreparing")
  UIManager.ShowUI(UIManager.UI_Config_InGame.GodTrialCommonTipsUI, 4402003, FPTrialConfig.StartTrialTipsCD)
end
function PlayerCharacterFramePlatformFeature:RPC_Client_OnFPTrialCompeting()
  if not Client then
    return
  end
  print(bWriteLog and "PlayerCharacterFramePlatformFeature:RPC_Client_OnFPTrialCompeting")
  local CurrentTime = CGameState:GetServerWorldTimeSeconds()
  if CurrentTime - self.LastFPCompetingTipTime < 3 then
    return
  end
  self.LastFPCompetingTipTime = CurrentTime
  UIManager.ShowUI(UIManager.UI_Config_InGame.GodTrialCommonTipsUI, 4402058, 1)
end
function PlayerCharacterFramePlatformFeature:RPC_Client_OnFPTrialEnding(HonorScore)
  if not Client then
    return
  end
  HonorScore = math.floor(HonorScore)
  print(bWriteLog and string.format("PlayerCharacterFramePlatformFeature:RPC_Client_OnFPTrialEnding, HonorScore:%d", HonorScore))
  local UI = UIManager.ShowUI(UIManager.UI_Config_InGame.FPIgnitedResultUI)
  UI:ShowResult(HonorScore)
end
function PlayerCharacterFramePlatformFeature:OnHandleTakeDamage(uDamageInfo)
  if not uDamageInfo or not slua.isValid(uDamageInfo) then
    return
  end
  if not (self.Owner and slua.isValid(self.Owner.Object)) or self.Owner.Object ~= uDamageInfo.Target then
    return
  end
  if self.Owner.TrialFeature and self.Owner.TrialFeature.uTrialManager and self.Owner.TrialFeature.uTrialManager.TrialType == Enum.ETrialType.FramePlatform then
    print(bWriteLog and "PlayerCharacterFramePlatformFeature:OnHandleTakeDamage")
    self.Owner.TrialFeature.uTrialManager:ForcePlayerStopSkill(self.Owner.Object)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerCharacterFramePlatformFeature)