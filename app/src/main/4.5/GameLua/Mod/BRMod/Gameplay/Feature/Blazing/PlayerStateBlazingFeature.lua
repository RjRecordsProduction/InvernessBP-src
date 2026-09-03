local PlayerStateBlazingFeature = {
  ServerRPC = {},
  ClientRPC = {
    ClientRPC_OnBlazingStateChanged = {
      Params = {
        UEnums.EPropertyClass.Int,
        UEnums.EPropertyClass.Int,
        UEnums.EPropertyClass.Int
      },
      Reliable = true
    }
  },
  MulticastRPC = {},
  LuaEventContainer = {
    "BLAZING_DATA_CHANGED"
  }
}
local BlazeConfig = require("GameLua.Mod.BRMod.Gameplay.Feature.Blazing.BlazeConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function PlayerStateBlazingFeature:ctor()
  self.BlazingScore = 0
  self.LastKnockDownTime = -999
  self.ComboKillCount = 0
  self.GraceTimer = nil
  self.FadeOutTimer = nil
  self.BlazingState = BlazeConfig.EBlazeState.None
end
function PlayerStateBlazingFeature:ReceiveBeginPlay()
  PlayerStateBlazingFeature.__super.ReceiveBeginPlay(self)
end
function PlayerStateBlazingFeature:ReceiveEndPlay(EndPlayReason)
  self:_ClearGraceTimer()
  self:_ClearFadeOutTimer()
  PlayerStateBlazingFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function PlayerStateBlazingFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "BlazingScore",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "BlazingState",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
  return RepTable
end
function PlayerStateBlazingFeature:OnEnemyKnockedDown(uVictimPawn)
  if not slua.isValid(CGameState) then
    return
  end
  local CurrentTime = CGameState:GetServerWorldTimeSeconds()
  if CurrentTime - self.LastKnockDownTime > BlazeConfig.ComboTimeWindow then
    self.ComboKillCount = 0
  end
  print(bWriteLog and "PlayerStateBlazingFeature:OnEnemyKnockedDown - enemy knocked down +" .. BlazeConfig.SCORE_KNOCKDOWN, self.LastKnockDownTime, CurrentTime)
  self.LastKnockDownTime = CurrentTime
  local Score = BlazeConfig.SCORE_KNOCKDOWN
  self.ComboKillCount = self.ComboKillCount + 1
  if self.ComboKillCount == 2 then
    Score = Score + BlazeConfig.SCORE_DOUBLE_KILL_BONUS
    print(bWriteLog and "PlayerStateBlazingFeature:OnEnemyKnockedDown - double kill bonus +" .. BlazeConfig.SCORE_DOUBLE_KILL_BONUS)
  elseif self.ComboKillCount >= 3 then
    Score = Score + BlazeConfig.SCORE_TRIPLE_KILL_BONUS
    print(bWriteLog and "PlayerStateBlazingFeature:OnEnemyKnockedDown - triple kill bonus +" .. BlazeConfig.SCORE_TRIPLE_KILL_BONUS)
  end
  self:_AddScore(Score)
end
function PlayerStateBlazingFeature:OnEnemyEliminated(uVictimPawn)
  print(bWriteLog and "PlayerStateBlazingFeature:OnEnemyEliminated - enemy eliminated +" .. BlazeConfig.SCORE_ELIMINATE)
  local Score = BlazeConfig.SCORE_ELIMINATE
  if self:_CheckTeamKill(uVictimPawn) then
    Score = Score + BlazeConfig.SCORE_TEAM_KILL_BONUS
    print(bWriteLog and "PlayerStateBlazingFeature:OnEnemyEliminated - team kill bonus +" .. BlazeConfig.SCORE_TEAM_KILL_BONUS)
  end
  self:_AddScore(Score)
end
function PlayerStateBlazingFeature:OnKnockDownOrDie()
  self:_ResetBlazeState()
end
function PlayerStateBlazingFeature:_AddScore(Score)
  self.BlazingScore = math.min(self.BlazingScore + Score, BlazeConfig.BLAZE_SCORE_THRESHOLD)
  print(bWriteLog and string.format("PlayerStateBlazingFeature:_AddScore - score added:%d, total:%d, state:%d", Score, self.BlazingScore, self.BlazingState))
  self:_ClearGraceTimer()
  self:_ClearFadeOutTimer()
  if self.BlazingScore >= BlazeConfig.BLAZE_SCORE_THRESHOLD then
    self.BlazingState = BlazeConfig.EBlazeState.Active
    self:_NotifyBlazingStateChanged()
    self.GraceTimer = self:AddGameTimer(BlazeConfig.GraceKeepTime, false, function()
      self.GraceTimer = nil
      self:_StartGraceFadeOut()
    end)
  elseif self.BlazingState == BlazeConfig.EBlazeState.FadeOut then
    self.GraceTimer = self:AddGameTimer(BlazeConfig.GraceFadeKeepTime, false, function()
      self.GraceTimer = nil
      self:_StartGraceFadeOut()
    end)
  else
    self.GraceTimer = self:AddGameTimer(BlazeConfig.NormalKeepTime, false, function()
      self.GraceTimer = nil
      self:_StartNormalFade()
    end)
  end
end
function PlayerStateBlazingFeature:_StartGraceFadeOut()
  print(bWriteLog and "PlayerStateBlazingFeature:_StartGraceFadeOut")
  self.BlazingState = BlazeConfig.EBlazeState.FadeOut
  self:_NotifyBlazingStateChanged()
  self.FadeOutTimer = self:AddGameTimer(1, true, function()
    local FadeScore = self.BlazingState == BlazeConfig.EBlazeState.FadeOut and self.BlazingScore >= BlazeConfig.BLAZE_SCORE_FADEOUT_THRESHOLD and BlazeConfig.GraceFadeScorePerSecond or BlazeConfig.NormalFadeScorePerSecond
    self.BlazingScore = self.BlazingScore - FadeScore
    if self.BlazingScore <= 0 then
      self:_ResetBlazeState()
      return
    end
    if self.BlazingScore < BlazeConfig.BLAZE_SCORE_FADEOUT_THRESHOLD then
      if self.BlazingState == BlazeConfig.EBlazeState.FadeOut then
        self:_NotifyBlazingStateChanged()
      end
      self.BlazingState = BlazeConfig.EBlazeState.None
    end
  end)
end
function PlayerStateBlazingFeature:_StartNormalFade()
  print(bWriteLog and "PlayerStateBlazingFeature:_StartNormalFade")
  self.FadeOutTimer = self:AddGameTimer(1, true, function()
    self.BlazingScore = self.BlazingScore - BlazeConfig.NormalFadeScorePerSecond
    if self.BlazingScore <= 0 then
      self:_ResetBlazeState()
    end
  end)
end
function PlayerStateBlazingFeature:_ResetBlazeState()
  print(bWriteLog and "PlayerStateBlazingFeature:_ResetBlazeState")
  self:_ClearGraceTimer()
  self:_ClearFadeOutTimer()
  self.BlazingScore = 0
  self.ComboKillCount = 0
  self.LastKnockDownTime = -999
  self.BlazingState = BlazeConfig.EBlazeState.None
  self:_NotifyBlazingStateChanged()
end
function PlayerStateBlazingFeature:_NotifyBlazingStateChanged()
  if not slua.isValid(self.Owner.Object) then
    return
  end
  local TeamMateList = self.Owner:GetTeamMatePlayerStateList({}, false)
  if not TeamMateList then
    return
  end
  for i = 0, TeamMateList:Num() - 1 do
    local uTeammatePS = TeamMateList:Get(i)
    if slua.isValid(uTeammatePS) and uTeammatePS.GetPlayerInTeamIndexByPlayerState and uTeammatePS.BlazingFeature then
      local TeamIdx = uTeammatePS:GetPlayerInTeamIndexByPlayerState(self.Owner)
      print(bWriteLog and string.format("PlayerStateBlazingFeature:_NotifyBlazingStateChanged - to:%s TeamIdx:%d state:%d", uTeammatePS.PlayerName, TeamIdx, self.BlazingState))
      uTeammatePS.BlazingFeature:ClientRPC_OnBlazingStateChanged(TeamIdx, self.BlazingState, self.BlazingScore)
    end
  end
end
function PlayerStateBlazingFeature:OnRep_BlazingScore()
  print(bWriteLog and string.format("PlayerStateBlazingFeature:OnRep_BlazingScore - score:%d %s", self.BlazingScore, self.Owner.PlayerName))
  self:LuaBroadcast("BLAZING_DATA_CHANGED")
end
function PlayerStateBlazingFeature:OnRep_BlazingState()
  print(bWriteLog and string.format("PlayerStateBlazingFeature:OnRep_BlazingState - state:%d %s", self.BlazingState, self.Owner.PlayerName))
  self:LuaBroadcast("BLAZING_DATA_CHANGED")
end
function PlayerStateBlazingFeature:ClientRPC_OnBlazingStateChanged(TeamIdx, BlazingState, BlazingScore)
  print(bWriteLog and "PlayerStateBlazingFeature:ClientRPC_OnBlazingStateChanged", TeamIdx, BlazingState, BlazingScore)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_BLAZING_STATE_CHANGED, TeamIdx, BlazingState, BlazingScore)
end
function PlayerStateBlazingFeature:_CheckTeamKill(uVictimPawn)
  if not slua.isValid(uVictimPawn) then
    return false
  end
  local uVictimPS = uVictimPawn:GetPlayerStateSafety()
  if not slua.isValid(uVictimPS) then
    return false
  end
  local TeamMateList = uVictimPS:GetTeamMatePlayerStateList({}, false)
  if not TeamMateList or TeamMateList:Num() <= 0 then
    return true
  end
  local ExtraPlayerLiveState = import("/Script/ShadowTrackerExtra.ExtraPlayerLiveState")
  for i = 0, TeamMateList:Num() - 1 do
    local uTeammatePS = TeamMateList:Get(i)
    if slua.isValid(uTeammatePS) and uTeammatePS.IsInGame and uTeammatePS.LiveState and uTeammatePS:IsInGame() and uTeammatePS.LiveState ~= ExtraPlayerLiveState.InDying and uTeammatePS.LiveState ~= ExtraPlayerLiveState.InDied then
      return false
    end
  end
  print(bWriteLog and "PlayerStateBlazingFeature:_CheckTeamKill - Team Kill confirmed")
  return true
end
function PlayerStateBlazingFeature:_ClearGraceTimer()
  if self.GraceTimer then
    self:RemoveGameTimer(self.GraceTimer)
    self.GraceTimer = nil
  end
end
function PlayerStateBlazingFeature:_ClearFadeOutTimer()
  if self.FadeOutTimer then
    self:RemoveGameTimer(self.FadeOutTimer)
    self.FadeOutTimer = nil
  end
end
function PlayerStateBlazingFeature:GetOwnerPawn()
  if slua.isValid(self.Owner.Object) and self.Owner.GetPlayerCharacter then
    local uPlayerCharacter = self.Owner:GetPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      return uPlayerCharacter
    end
  end
  return nil
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerStateBlazingFeature)