local ESpawnActorCollisionHandlingMethod = import("ESpawnActorCollisionHandlingMethod")
local UGameplayStatics = import("GameplayStatics")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local FinalKillEffectSubsystem = {}
function FinalKillEffectSubsystem:OnInit()
  if not Client then
    local ModeID = GameMainConfig.GetModeID()
    local IsBRMode = GamePlayTools.IsBRMode(ModeID)
    print(bWriteLog and string.format("FinalKillEffectSubsystem:OnInit ModeID = %s, IsBRMode = %s", ModeID, IsBRMode))
    if not IsBRMode then
      return
    end
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_JOIN, self.OnPlayerPostLogin, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CHARACTER_DIED_PRE, self.OnCharacterDiePre, self)
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FinishedState"
    }, self.OnGameFinished, self)
    self:AddCommonEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_SPECIAL_SHOW_START, self.OnSpecialShowTrigger, self)
  end
end
function FinalKillEffectSubsystem:OnPlayerPostLogin(_, __, uNewPlayerCharacter)
  if not slua.isValid(uNewPlayerCharacter) then
    return
  end
  local FinalKillEffectItemId = self:GetFinalKillEffectItemId(uNewPlayerCharacter)
  print(bWriteLog and string.format("FinalKillEffectSubsystem:OnPlayerPostLogin %s, FinalKillEffectItemId = %s", uNewPlayerCharacter:ToString(), FinalKillEffectItemId))
  if FinalKillEffectItemId then
    uNewPlayerCharacter:EnsureDynamicFeature("FinalKillEffect")
    if uNewPlayerCharacter.FinalKillEffect then
      uNewPlayerCharacter.FinalKillEffect:PrepareItem(FinalKillEffectItemId)
    end
  end
end
function FinalKillEffectSubsystem:OnCharacterDiePre(_, __, uKilledPawn, EventType, uDamageCauser, uEventInstigatorCtrl)
  if not slua.isValid(uKilledPawn) then
    print(bWriteLog and string.format("FinalKillEffectSubsystem:OnCharacterDiePre uKilledPawn is not valid, return"))
    return
  end
  local StrTarget = uKilledPawn.ToString ~= nil and uKilledPawn:ToString() or tostring(uKilledPawn)
  print(bWriteLog and string.format("FinalKillEffectSubsystem:OnCharacterDiePre %s", StrTarget))
  local uKillerPawn = self:GetKillerPawn(uEventInstigatorCtrl)
  if not slua.isValid(uKillerPawn) then
    print(bWriteLog and string.format("FinalKillEffectSubsystem:OnCharacterDiePre uKillerPawn is not valid, will clear LastKillInfo and return"))
    self.LastKillInfo = nil
    return
  end
  self.LastKillInfo = {
    Caster = {
      Location = uKillerPawn:K2_GetActorLocation(),
      Pawn = uKillerPawn
    },
    Target = {
      Location = uKilledPawn:K2_GetActorLocation(),
      Pawn = uKilledPawn
    }
  }
  local StrCaster = uKillerPawn.ToString ~= nil and uKillerPawn:ToString() or tostring(uKillerPawn)
  print(bWriteLog and string.format("FinalKillEffectSubsystem:OnCharacterDiePre %s(%s) =X> %s(%s)", StrCaster, uKillerPawn:K2_GetActorLocation():ToString(), StrTarget, uKilledPawn:K2_GetActorLocation():ToString()))
  self:TryRemoveNamedGameTimer("ClearKillInfoTimer")
  self.ClearKillInfoTimer = self:AddGameTimer(0.05, false, function()
    print(bWriteLog and "FinalKillEffectSubsystem:OnCharacterDiePre clear LastKillInfo next frame")
    self.LastKillInfo = nil
  end)
end
function FinalKillEffectSubsystem:GetKillerPawn(uEventInstigatorCtrl)
  if not slua.isValid(uEventInstigatorCtrl) then
    return
  end
  if uEventInstigatorCtrl.GetPlayerCharacterSafety ~= nil then
    return uEventInstigatorCtrl:GetPlayerCharacterSafety()
  else
    return uEventInstigatorCtrl:K2_GetPawn()
  end
end
function FinalKillEffectSubsystem:OnGameFinished()
  print(bWriteLog and string.format("FinalKillEffectSubsystem:OnGameFinished"))
  self:TryTriggerFinalKillEffect()
end
function FinalKillEffectSubsystem:TryTriggerFinalKillEffect(TestItemId)
  local FinalKiller = self:GetFinalKiller()
  if slua.isValid(FinalKiller) then
    local FinalKillEffectItemId = self:GetFinalKillEffectItemId(FinalKiller, TestItemId)
    local FinalKillEffectCfg = CDataTable.GetTableData("FinalKillEffectCfg", FinalKillEffectItemId)
    if FinalKillEffectItemId and FinalKillEffectCfg then
      self:CreateFinalKillEffect(FinalKiller, FinalKillEffectCfg)
    else
      local StrFinalKiller = FinalKiller.ToString ~= nil and FinalKiller:ToString() or tostring(FinalKiller)
      print(bWriteLog and string.format("FinalKillEffectSubsystem:TryTriggerFinalKillEffect %s has no kill effect item (FinalKillEffectItemId = %s)", StrFinalKiller, FinalKillEffectItemId))
    end
  else
    print(bWriteLog and string.format("FinalKillEffectSubsystem:TryTriggerFinalKillEffect FinalKiller is not valid"))
  end
end
function FinalKillEffectSubsystem:GetFinalKiller()
  if not self.LastKillInfo then
    print(bWriteLog and string.format("FinalKillEffectSubsystem:GetFinalKiller LastKillInfo is not valid, return"))
    return
  end
  local uKillerPawn = self.LastKillInfo.Caster.Pawn
  local uKilledPawn = self.LastKillInfo.Target.Pawn
  if uKillerPawn == uKilledPawn then
    print(bWriteLog and string.format("FinalKillEffectSubsystem:GetFinalKiller uKillerPawn == uKilledPawn, return"))
    return
  end
  return uKillerPawn
end
function FinalKillEffectSubsystem:GetFinalKillEffectItemId(PlayerCharacter, TestItemId)
  if not slua.isValid(PlayerCharacter) then
    return
  end
  if TestItemId then
    return TestItemId
  end
  if _G.IsEditor and TEST_FINAL_KILL_EFFECT_ITEM_ID then
    return TEST_FINAL_KILL_EFFECT_ITEM_ID
  end
  local nUID = Game:GetPlayerUID(PlayerCharacter)
  local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local FinalKillEffectItemId = ServerPlayerDataMgr.GetPlayerProgressFromServer(nUID, ExtendAttribute.FinalKillEffect)
  return FinalKillEffectItemId
end
function FinalKillEffectSubsystem:OnSpecialShowTrigger(_, __, TeamID)
  print(bWriteLog and "FinalKillEffectSubsystem:OnSpecialShowTrigger TeamID:" .. tostring(TeamID))
  self.SpecialShowend
function FinalKillEffectSubsystem:CreateFinalKillEffect(PlayerCharacter, Config)
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and string.format("FinalKillEffectSubsystem:CreateFinalKillEffect PlayerCharacter is not valid"))
    return
  end
  if self.SpecialShowTeamID and PlayerCharacter.TeamID == self.SpecialShowTeamID then
    print(bWriteLog and "FinalKillEffectSubsystem:CreateFinalKillEffect SpecialShow Started Not Trigger Effect TeamID:" .. tostring(self.SpecialShowTeamID))
    return
  end
  print(bWriteLog and string.format("FinalKillEffectSubsystem:CreateFinalKillEffect %s", PlayerCharacter:ToString()))
  local Location = self:GetTriggerLocation(Config)
  Location = Location or PlayerCharacter:K2_GetActorLocation()
  local Rotator = self:GetTriggerRotator(Config)
  Rotator = Rotator or FRotator(0, 0, 0)
  print(bWriteLog and string.format("FinalKillEffectSubsystem:CreateFinalKillEffect TriggerLocationType = %s, Location = %s", Config.TriggerLocationType, Location:ToString()))
  local PlayerTeamMemberNames = self:GetTeamMemberNames(PlayerCharacter)
  self:ForEachTriggerPlayerCharacter(PlayerCharacter, function(PC)
    PC:EnsureDynamicFeature("FinalKillEffect")
    if PC.FinalKillEffect then
      PC.FinalKillEffect:TriggerEffect(Config, Location, Rotator, PlayerTeamMemberNames)
    end
  end)
end
function FinalKillEffectSubsystem:GetTeamMemberNames(PlayerCharacter)
  local Names = PlayerCharacter.PlayerName
  local OwnerPlayerState = GameplayData.GetPlayerState(PlayerCharacter.PlayerKey)
  if slua.isValid(OwnerPlayerState) then
    local TeammatePlayerStateList = OwnerPlayerState:GetTeamMatePlayerStateList({}, true)
    for _, PlayerState in pairs(TeammatePlayerStateList) do
      if slua.isValid(PlayerState) then
        local TeammatePlayerCharacter = PlayerState:GetPlayerCharacter()
        if slua.isValid(TeammatePlayerCharacter) then
          Names = Names .. "    " .. TeammatePlayerCharacter.PlayerName
        end
      end
    end
  end
  return Names
end
function FinalKillEffectSubsystem:GetTriggerLocation(Config)
  if not self.LastKillInfo then
    print(bWriteLog and string.format("FinalKillEffectSubsystem:GetTriggerLocation LastKillInfo is not valid, return"))
    return
  end
  local TriggerLocationType = Config.TriggerLocationType or 1
  if TriggerLocationType == 1 then
    return self.LastKillInfo.Caster.Location
  elseif TriggerLocationType == 2 then
    return self.LastKillInfo.Target.Location
  elseif TriggerLocationType == 3 then
    return (self.LastKillInfo.Caster.Location + self.LastKillInfo.Target.Location) / 2
  end
end
function FinalKillEffectSubsystem:GetTriggerRotator(Config)
  if not self.LastKillInfo then
    print(bWriteLog and string.format("FinalKillEffectSubsystem:GetTriggerRotation LastKillInfo is not valid, return"))
    return
  end
  local TriggerRotatorType = Config.TriggerRotatorType or 0
  if TriggerRotatorType == 0 then
    return FRotator(0, 0, 0)
  elseif TriggerRotatorType == 1 then
    local src = FVector(0, 1, 0)
    local dst = self.LastKillInfo.Caster.Pawn:K2_GetActorLocation() - self.LastKillInfo.Target.Location
    dst.Z = 0
    local CosTheta = (src.X * dst.X + src.Y * dst.Y) / math.sqrt(dst.X * dst.X + dst.Y * dst.Y)
    local theta = math.deg(math.acos(CosTheta))
    local z = src.X * dst.Y - src.Y * dst.X
    if 0 <= z then
      return FRotator(0, theta, 0)
    else
      return FRotator(0, -theta, 0)
    end
  end
end
function FinalKillEffectSubsystem:ForEachTriggerPlayerCharacter(PlayerCharacter, Callback)
  Callback(PlayerCharacter)
  local OwnerPlayerState = GameplayData.GetPlayerState(PlayerCharacter.PlayerKey)
  if slua.isValid(OwnerPlayerState) then
    local TeammatePlayerStateList = OwnerPlayerState:GetTeamMatePlayerStateList({}, true)
    for _, PlayerState in pairs(TeammatePlayerStateList) do
      if slua.isValid(PlayerState) then
        local TeammatePlayerCharacter = PlayerState:GetPlayerCharacter()
        if slua.isValid(TeammatePlayerCharacter) then
          Callback(TeammatePlayerCharacter)
        end
      end
    end
  end
end
local class = require("class")
local CSubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(CSubsystemBase, nil, FinalKillEffectSubsystem)