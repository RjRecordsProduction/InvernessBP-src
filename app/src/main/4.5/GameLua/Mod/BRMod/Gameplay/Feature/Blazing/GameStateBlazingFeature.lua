local GameStateBlazingFeature = {}
local ESTEPoseState = import("ESTEPoseState")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local BlazeConfig = require("GameLua.Mod.BRMod.Gameplay.Feature.Blazing.BlazeConfig")
function GameStateBlazingFeature:ReceiveBeginPlay()
  local BattleType = ServerDataMgr and ServerDataMgr.SyncGameParams and ServerDataMgr.SyncGameParams.battle_type or 0
  print("GameStateBlazingFeature:ReceiveBeginPlay BattleType", BattleType, BlazeConfig)
  if not BlazeConfig or not BlazeConfig.ActiveModType[BattleType] then
    return
  end
  if not Client then
    local GameState = GameplayData.GetGameState()
    local uEGameModeType = import("EGameModeType")
    if slua.isValid(GameState) and GameState.GameModeType == uEGameModeType.EEntertainmentGameMode then
      print("GameStateBlazingFeature:ReceiveBeginPlay entertainment game mode")
      return
    end
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    if GameMainConfig.IsPeakGame() then
      print("GameStateBlazingFeature:ReceiveBeginPlay peak game")
      return
    end
    print(bWriteLog and "GameStateBlazingFeature:ReceiveBeginPlay")
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PAWN_GO_TO_NEAR_DEATH, self.OnNearDeath, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CHARACTER_DIED, self.OnCharacterDied, self)
  end
end
function GameStateBlazingFeature:OnNearDeath(_, _, uVictim, uCauser, nTypeID, uKillerCharacter, DamageItemID, DamageEvent)
  if not slua.isValid(uVictim) then
    return
  end
  local uVictimPS = uVictim:GetPlayerStateSafety()
  if slua.isValid(uVictimPS) and uVictimPS.BlazingFeature then
    uVictimPS.BlazingFeature:OnKnockDownOrDie()
  end
  if not slua.isValid(uKillerCharacter) or not self:CheckKillValid(uVictim, uCauser, uKillerCharacter) then
    return
  end
  local uKillerPS = uKillerCharacter:GetPlayerStateSafety()
  if not slua.isValid(uKillerPS) then
    return
  end
  local BlazingFeature = uKillerPS.BlazingFeature
  if not BlazingFeature then
    return
  end
  print(bWriteLog and "GameStateBlazingFeature:OnNearDeath", uKillerPS.PlayerName, uVictim, uCauser, nTypeID, DamageItemID)
  BlazingFeature:OnEnemyKnockedDown(uVictim)
end
function GameStateBlazingFeature:OnCharacterDied(_, _, uVictim, uCauser, nTypeID, uKillerCharacter, AdditionalValue, DamageEvent)
  if not slua.isValid(uVictim) then
    return
  end
  local uVictimPS = uVictim:GetPlayerStateSafety()
  if slua.isValid(uVictimPS) and uVictimPS.BlazingFeature then
    uVictimPS.BlazingFeature:OnKnockDownOrDie()
  end
  if not slua.isValid(uKillerCharacter) or not self:CheckKillValid(uVictim, uCauser, uKillerCharacter) then
    return
  end
  local uKillerPS = uKillerCharacter:GetPlayerStateSafety()
  if not slua.isValid(uKillerPS) then
    return
  end
  local BlazingFeature = uKillerPS.BlazingFeature
  if not BlazingFeature then
    return
  end
  print(bWriteLog and "GameStateBlazingFeature:OnCharacterDied", uKillerPS.PlayerName, uVictim, uCauser, nTypeID, uKillerCharacter, AdditionalValue)
  if uVictim.PoseState ~= ESTEPoseState.Dying and uVictim.PoseState ~= ESTEPoseState.DyingBeCarried and uVictim.PoseState ~= ESTEPoseState.DyingSwim then
    BlazingFeature:OnEnemyKnockedDown(uVictim)
    BlazingFeature:OnEnemyEliminated(uVictim)
  else
    BlazingFeature:OnEnemyEliminated(uVictim)
  end
end
function GameStateBlazingFeature:CheckKillValid(uVictim, uCauser, uKillerCharacter)
  if not (Game:IsHuman(uVictim) and Game:IsPlayer(uKillerCharacter)) or Game:IsMonster(uVictim) then
    return false
  end
  local uKillerController = uKillerCharacter:GetPlayerControllerSafety()
  local victimController = uVictim:GetControllerSafety()
  if not (Game:GetTeamID(uVictim) ~= Game:GetTeamID(uKillerCharacter) and uVictim ~= uKillerCharacter and slua.isValid(uKillerController)) or not slua.isValid(victimController) then
    return false
  end
  return true
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, GameStateBlazingFeature)