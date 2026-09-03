local ESpawnActorCollisionHandlingMethod = import("ESpawnActorCollisionHandlingMethod")
local UGameplayStatics = import("GameplayStatics")
local PlayerCharacterFinalKillEffectFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local LevelSequenceActorClassPath = "/Game/Mod/EvoBase/BluePrints/Actor/BP_FinalKillEffectLevelSequenceActor.BP_FinalKillEffectLevelSequenceActor"
function PlayerCharacterFinalKillEffectFeature:ctor()
  self.AudioPlayingID = nil
end
function PlayerCharacterFinalKillEffectFeature:ReceiveBeginPlay()
  PlayerCharacterFinalKillEffectFeature.__super.ReceiveBeginPlay(self)
  if not self:IsLocal() then
    return
  end
  if Client then
    self:AddCommonEventWithConditions(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ON_END_PHASE, {
      [1] = "ResultRankingProtectLogic"
    }, self.ProcessBattleResultOnEndPhase, self)
  end
end
function PlayerCharacterFinalKillEffectFeature:ProcessBattleResultOnEndPhase()
  if not self:IsLocal() then
    return
  end
  print(bWriteLog and string.format("PlayerCharacterFinalKillEffectFeature:ProcessBattleResultOnEndPhase"))
  if self.HasRainy then
    self:SetRainyActive(false)
  end
  local audio_util = require("client.common.audio_util")
  if self.AudioPlayingID then
    audio_util.StopSound(self.AudioPlayingID)
    self.AudioPlayingID = nil
  end
end
function PlayerCharacterFinalKillEffectFeature:ReceiveEndPlay(EndPlayReason)
  if Client then
    print(bWriteLog and string.format("PlayerCharacterFinalKillEffectFeature:ReceiveEndPlay"))
    self:ClearAllTimers()
  end
  PlayerCharacterFinalKillEffectFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function PlayerCharacterFinalKillEffectFeature:ClearAllTimers()
  print(bWriteLog and string.format("PlayerCharacterFinalKillEffectFeature:ClearAllTimers"))
  if self.ClearRainyTimer then
    self:RemoveGameTimer(self.ClearRainyTimer)
    self.ClearRainyTimer = nil
  end
end
PlayerCharacterFinalKillEffectFeature.ClientRPC.PrepareItem = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function PlayerCharacterFinalKillEffectFeature:PrepareItem(ItemId)
  print(bWriteLog and string.format("PlayerCharacterFinalKillEffectFeature:PrepareItem ItemId = %s", ItemId))
  if not self.Config and ItemId ~= nil then
    self.Config = CDataTable.GetTableData("FinalKillEffectCfg", ItemId)
  end
  slua.loadClass(LevelSequenceActorClassPath)
  if self.Config and self.Config.SkyTransitionID and self:IsLocal() then
    local PlayerController = slua_GameFrontendHUD:GetPlayerController()
    PlayerController.SkyTransition:PreloadSequenceById(self.Config.SkyTransitionID)
  end
end
function PlayerCharacterFinalKillEffectFeature:TriggerEffect(Config, Location, Rotator, TeamMemberNames)
  print(bWriteLog and string.format("PlayerCharacterFinalKillEffectFeature:TriggerEffect ItemID = %s, Location = %s, Rotator = %s", Config.ItemID, Location:ToString(), Rotator:ToString()))
  if not self.Owner.SkyTransition then
    print(bWriteLog and string.format("PlayerCharacterFinalKillEffectFeature:TriggerEffect SkyTransition is not valid, return"))
    return
  end
  self:TriggerParticleEffect(Config.ItemID, Location, Rotator, TeamMemberNames)
  self.FinalKillEffectSkyTransitionId = Config.SkyTransitionID
  self.Owner.SkyTransition:SetStateActive(self.FinalKillEffectSkyTransitionId, true)
  if Config.Duration and Config.Duration > 0 then
    print(bWriteLog and string.format("FinalKillEffectSubsystem:TriggerEffect will restore SkyTransition after %s seconds", Config.Duration))
    self:AddGameTimer(Config.Duration, false, function()
      self:RestoreSkyTransition()
    end)
  end
end
function PlayerCharacterFinalKillEffectFeature:RestoreSkyTransition()
  if self.Owner and self.Owner.SkyTransition then
    print(bWriteLog and string.format("FinalKillEffectSubsystem:RestoreSkyTransition"))
    self.Owner.SkyTransition:SetStateActive(self.FinalKillEffectSkyTransitionId, false)
  end
end
PlayerCharacterFinalKillEffectFeature.ClientRPC.TriggerParticleEffect = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    import("/Script/CoreUObject.Vector"),
    import("/Script/CoreUObject.Rotator"),
    UEnums.EPropertyClass.Str
  }
}
function PlayerCharacterFinalKillEffectFeature:TriggerParticleEffect(ItemId, Location, Rotator, TeamMemberNames)
  if not Client then
    print(bWriteLog and string.format("PlayerCharacterFinalKillEffectFeature:TriggerParticleEffect: not client return"))
    return
  end
  print(bWriteLog and string.format("PlayerCharacterFinalKillEffectFeature:TriggerParticleEffect ItemId = %s, Location = %s, Rotator = %s", ItemId, Location:ToString(), Rotator:ToString()))
  if not self.Config then
    self.Config = CDataTable.GetTableData("FinalKillEffectCfg", ItemId)
  end
  local AsyncAsset = self:GetNeededAssetPath(ItemId)
  if AsyncAsset == "" then
    self:CreateLevelSequenceActor(ItemId, Location, Rotator)
    self:PlayEffect(self.Config)
  else
    local util = require("client.slua_ui_framework.util")
    util.GetAssetAsync(AsyncAsset, function(LoadObj)
      self:CreateLevelSequenceActor(ItemId, Location, Rotator, {TeamMemberNames = TeamMemberNames, WidgetClass = LoadObj})
      self:PlayEffect(self.Config)
    end)
  end
end
function PlayerCharacterFinalKillEffectFeature:GetNeededAssetPath(ItemID)
  if ItemID == 61950002 then
    return "/Game/UMG/UI_BP/FinalKill/NameCard_UIBP.NameCard_UIBP_C"
  end
  return ""
end
function PlayerCharacterFinalKillEffectFeature:CreateLevelSequenceActor(ItemId, Location, Rotator, ExtraParam)
  local SequenceTransform = FTransform(Rotator, Location, FVector(1, 1, 1))
  local LevelSequenceActorClass = slua.loadClass(LevelSequenceActorClassPath)
  local LevelSequenceActor = UGameplayStatics.BeginDeferredActorSpawnFromClass(self.Owner, LevelSequenceActorClass, SequenceTransform, ESpawnActorCollisionHandlingMethod.Undefined, CGameMode)
  if not slua.isValid(LevelSequenceActor) then
    print(bWriteLog and string.format("PlayerCharacterFinalKillEffectFeature:CreateLevelSequenceActor create actor failed, return"))
    return
  end
  print(bWriteLog and string.format("PlayerCharacterFinalKillEffectFeature:CreateLevelSequenceActor ItemId = %s", ItemId))
  LevelSequenceActor.  if ItemId == 61950002 then
    LevelSequenceActor:SetCallback("OnPlay", function()
      self:AddGameTimer(0, false, function()
        self:CreateNameCardFor61950002(ExtraParam)
      end)
    end)
  end
  UGameplayStatics.FinishSpawningActor(LevelSequenceActor, SequenceTransform)
end
function PlayerCharacterFinalKillEffectFeature:PlayEffect(Config)
  if not Config then
    print(bWriteLog and string.format("PlayerCharacterFinalKillEffectFeature:PlayEffect Config is not valid, return"))
    return
  end
  if not Config.Effect then
    print(bWriteLog and string.format("PlayerCharacterFinalKillEffectFeature:PlayEffect no Effect, return"))
    return
  end
  local StringUtil = require("common.string_util")
  local Effects = StringUtil.Split(Config.Effect, "|")
  for _, EffectName in ipairs(Effects) do
    if EffectName == "Rainy" then
      self.HasRainy = true
      self:SetRainyActive(true)
      if Config.Duration and Config.Duration > 0 then
        self.ClearRainyTimer = self:AddGameTimer(Config.Duration, false, function()
          self:SetRainyActive(false)
        end)
      end
    end
  end
end
function PlayerCharacterFinalKillEffectFeature:CreateNameCardFor61950002(ExtraParam)
  local WidgetClass = ExtraParam and ExtraParam.WidgetClass
  local Names = ExtraParam and ExtraParam.TeamMemberNames
  local UGameplayStatics = import("GameplayStatics")
  local uActor = import("/Script/Engine.Actor")
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  local uClass = import("SkeletalMeshActor")
  local SkeletalMeshCompClass = import("/Script/Engine.SkeletalMeshComponent")
  local uTempArray = UGameplayStatics.GetAllActorsOfClass(uGameInstance, uClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
  local SkeletalMeshComp, SkeletalMeshActor
  if slua.isValid(uTempArray) then
    for k, v in pairs(uTempArray) do
      local tempComp = v:GetComponentByClass(SkeletalMeshCompClass)
      if slua.isValid(tempComp) and tempComp:ComponentHasTag("TrophyWithName") then
        print(bWriteLog and "PlayerCharacterFinalKillEffectFeature:CreateNameCard find target to bind")
        SkeletalMeshActor = v
        SkeletalMeshComp = tempComp
        break
      end
    end
  end
  if SkeletalMeshComp == nil or not slua.isValid(SkeletalMeshComp) then
    print(bWriteLog and "PlayerCharacterFinalKillEffectFeature:CreateNameCard failed to find target to bind, itemid = 61950002")
    return
  end
  local UWidgetComponent = import("WidgetComponent")
  if not slua.isValid(self.FirstTeamNameWidgetComp) then
    self.FirstTeamNameWidgetComp = Game:AddComponent(UWidgetComponent, SkeletalMeshActor, "Widget")
  end
  if not slua.isValid(self.FirstTeamNameWidgetComp) or not slua.isValid(WidgetClass) then
    print(bWriteLog and "PlayerCharacterFinalKillEffectFeature:CreateNameCard Failed to Create Component")
    return
  end
  if self.FirstTeamNameWidgetComp.DrawSize.X then
    self.FirstTeamNameWidgetComp.DrawSize.X = 700
  end
  self:AddGameTimer(7, false, function()
    if not slua.isValid(self.FirstTeamNameWidgetComp) or not slua.isValid(SkeletalMeshComp) then
      print(bWriteLog and "PlayerCharacterFinalKillEffectFeature:CreateNameCard Component is not valid")
      return
    end
    self.FirstTeamNameWidgetComp:K2_AttachToComponent(SkeletalMeshComp, "Bone002", UEnums.EAttachmentRule.KeepRelative, UEnums.EAttachmentRule.KeepRelative, UEnums.EAttachmentRule.KeepRelative, false)
    local Spawntransform = FTransform(FRotator(90, 180, 0), FVector(-45, 10, 170), FVector(1, 1, 1))
    self.FirstTeamNameWidgetComp:K2_SetRelativeTransform(Spawntransform, false, nil, false)
    CGame:SetWidgetClass(self.FirstTeamNameWidgetComp, WidgetClass)
    local userWidget = self.FirstTeamNameWidgetComp:GetUserWidgetObject()
    if not slua.isValid(userWidget) then
      print(bWriteLog and "PlayerCharacterFinalKillEffectFeature:CreateNameCard Failed to Create widget")
      return
    end
    print(bWriteLog and "PlayerCharacterFinalKillEffectFeature:CreateNameCard Names: " .. Names)
    userWidget.PlayerName:SetText(Names)
  end)
end
function PlayerCharacterFinalKillEffectFeature:SetRainyActive(IsActive)
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and string.format("PlayerCharacterFinalKillEffectFeature:SetRainyActive PlayerController is not valid, return"))
    return
  end
  print(bWriteLog and string.format("PlayerCharacterFinalKillEffectFeature:SetRainyActive %s", IsActive))
  PlayerController:SetIsRainy(IsActive)
  local audio_util = require("client.common.audio_util")
  local AudioAssetPath = IsActive == true and "/Game/WwiseEvent/Character_KillEffect/Character_KillEffect_320/Play_Character_KillEffect_Thunder_320.Play_Character_KillEffect_Thunder_320" or "/Game/WwiseEvent/Character_KillEffect/Character_KillEffect_320/Stop_Character_KillEffect_Thunder_2D_320.Stop_Character_KillEffect_Thunder_2D_320"
  self.AudioPlayingID = audio_util.PlayAudioAsync(AudioAssetPath, self.Owner.Object)
end
function PlayerCharacterFinalKillEffectFeature:IsLocal()
  return self.Owner.IsLocallyControlled ~= nil and self.Owner:IsLocallyControlled() or self.Owner.IsLocalViewed ~= nil and self.Owner:IsLocalViewed()
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CPlayerCharacterFinalKillEffectFeature = class(CFeatureBase, nil, PlayerCharacterFinalKillEffectFeature)
return require("combine_class").SetFeatureDynamic(CPlayerCharacterFinalKillEffectFeature)