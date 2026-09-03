local FeaturePanDefenseEffect = {}
local Trait = require("common.trait")
local TFeaturePanDefenseEffect = Trait(Trait.TraitPrototype, nil, FeaturePanDefenseEffect)
function FeaturePanDefenseEffect:PlayDefenseEffect(data)
  local seqPath = data.config.PathOne
  local pak_util = require("client.common.pak_util")
  if not pak_util.IsPufferDownloadedByPathList({seqPath}, true) then
    return
  end
  log(bWriteLog and "FeaturePanDefenseEffect:PlayDefenseEffect")
  self:NotifyOtherFeatureStop(data)
  self.isPlayinDefenseEffect = true
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Hide()
  local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
  local hitEffectLocation = ConstAvatarDislay.GetSpawnLocationByHitEffect(self.curScene)
  hitEffectLocation = hitEffectLocation - FVector(0, 0, 90)
  self:CreateLevelSequenceActor(seqPath, hitEffectLocation)
end
function FeaturePanDefenseEffect:StopDefenseEffect()
  log(bWriteLog and "FeaturePanDefenseEffect:StopDefenseEffect")
  if slua.isValid(self.SequenceActor) then
    self.SequenceActor:K2_DestroyActor()
    self.SequenceActor = nil
  end
  if not self.isPlayinDefenseEffect then
    log(bWriteLog and "FeaturePanDefenseEffect:StopDefenseEffect not self.isPlayinDefenseEffect")
    return
  end
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Show()
end
function FeaturePanDefenseEffect:CreateLevelSequenceActor(seqPath, Location)
  if not seqPath or not Location then
    log(bWriteLog and "FeaturePanDefenseEffect:CreateLevelSequenceActor invalid param")
    return false
  end
  if slua.isValid(self.SequenceActor) then
    self.SequenceActor:K2_DestroyActor()
    self.SequenceActor = nil
  end
  local SequenceTransform = FTransform()
  SequenceTransform:SetLocation(Location)
  local DeadSmokeSeqActorPath = "/Game/Arts_PlayerBluePrints/DeadBox/DeadBoxSmoke/BP_Lobby_DeadBoxSmokeSeqActor.BP_Lobby_DeadBoxSmokeSeqActor_C"
  local UIUtil = require("client.common.ui_util")
  self.SequenceActor = Game:PlayLevelSequence(UIUtil.GetGameInstance(), seqPath, SequenceTransform, DeadSmokeSeqActorPath, false)
  if not slua.isValid(self.SequenceActor) then
    log(bWriteLog and "FeaturePanDefenseEffect:CreateLevelSequenceActor invalid SequenceActor")
    return false
  end
  self.SeqTimer = self:AddGameTimer(0.1, false, function()
    if slua.isValid(self.SequenceActor) then
      self.SequenceActor:Play(0.0)
    end
  end)
  log(bWriteLog and "FeaturePanDefenseEffect:CreateLevelSequenceActor play")
  return true
end
return TFeaturePanDefenseEffect