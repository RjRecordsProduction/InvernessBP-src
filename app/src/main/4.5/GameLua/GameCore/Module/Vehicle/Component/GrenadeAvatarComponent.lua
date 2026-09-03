local GrenadeAvatarComponent = {}
local DeadBoxSmokeSeqActorPath = "/Game/Arts_PlayerBluePrints/DeadBox/DeadBoxSmoke/BP_DeadBoxSmokeSeqActor.BP_DeadBoxSmokeSeqActor_C"

function GrenadeAvatarComponent:ctor()
  self.LevelSequenceActor = nil
end

function GrenadeAvatarComponent:ReceiveBeginPlay()
  GrenadeAvatarComponent.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "GrenadeAvatarComponent:ReceiveBeginPlay")
  self:AddControlEvent(self, "GrenadeAvatarEqiuped", self.OnGrenadeAvatarEqiuped, self)
end

function GrenadeAvatarComponent:OnGrenadeAvatarEqiuped()
  if self.FeatureMaterial then
    self:ChangeAllMeshToFeatureMaterial(self.FeatureMaterial)
  end
end

function GrenadeAvatarComponent:CheckHasOverrideFx(PlayerController, GrenadeSkinID)
  print(bWriteLog and "GrenadeAvatarComponent:CheckHasOverrideFx GrenadeSkinID", GrenadeSkinID)
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "GrenadeAvatarComponent:CheckHasOverrideFx error PC not valid")
    return
  end
  if Game:IsAIController(PlayerController) then
    local Cfg = CDataTable.GetTableData("GrenadeKillGunBindMap", GrenadeSkinID)
    local FxGunID = 0
    if Cfg and Cfg.UnlockFxGunIDList_a and 0 < Cfg.UnlockFxGunIDList_a:Num() then
      FxGunID = Cfg.UnlockFxGunIDList_a:Get(0)
    end
    self:SetOverrideFxIndex(FxGunID)
    self:SetOverrideSoundIndex(FxGunID)
    log(bWriteLog and "GrenadeAvatarComponent:CheckHasOverrideFx, OverrideFxIndex(UnlockFxGunID) is " % tostring(FxGunID))
    return
  end
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local GrenadeBindInfo = PlayerDataMgr.GetPlayerProgressFromServer(PlayerController.UID, ExtendAttribute.GrenadeBindWeaponMap)
  if not GrenadeBindInfo then
    print(bWriteLog and "GrenadeAvatarComponent:CheckHasOverrideFx GrenadeBindInfo nil")
    self:SetOverrideFxIndex(0)
    self:SetOverrideSoundIndex(0)
    return
  end
  local UnlockWeaponID = GrenadeBindInfo[GrenadeSkinID]
  local UnlockFxGunID = 0
  print(bWriteLog and "GrenadeAvatarComponent:CheckHasOverrideFx UnlockWeaponID", UnlockWeaponID)
  if UnlockWeaponID ~= nil then
    local Cfg = CDataTable.GetTableData("GrenadeKillGunBindMap", GrenadeSkinID)
    if Cfg and Cfg.UnlockFxGunIDList_a and 0 < Cfg.UnlockFxGunIDList_a:Num() then
      for k, v in pairs(Cfg.UnlockFxGunIDList_a) do
        if v == UnlockWeaponID then
          UnlockFxGunID = Cfg.UnlockFxGunIDList_a:Get(0)
          print(bWriteLog and "GrenadeAvatarComponent:CheckHasOverrideFx go" % UnlockFxGunID)
          break
        end
      end
    end
  end
  self:SetOverrideFxIndex(UnlockFxGunID)
  local SoundOverrideWeaponID = UnlockFxGunID
  if UnlockFxGunID > 0 then
    local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
    local UnlockWeaponGroupID = ItemUpgradeMgr:GetNormalGroupIDOfWeaponID(UnlockFxGunID)
    local WeaponOverrideSoundInfo = PlayerDataMgr.GetPlayerProgressFromServer(PlayerController.UID, ExtendAttribute.WeaponOverrideSound)
    if WeaponOverrideSoundInfo then
      for GroupID, Flag in pairs(WeaponOverrideSoundInfo) do
        if GroupID == UnlockWeaponGroupID then
          if Flag then
            local EWeaponOverrideSoundSwitchType = import("/Script/ShadowTrackerExtra.EWeaponOverrideSoundSwitchType")
            EWeaponOverrideSoundSwitchType.GrenadeExplode[1] = EWeaponOverrideSoundSwitchType.GrenadeExplode
            if Flag[EWeaponOverrideSoundSwitchType.GrenadeExplode] ~= 0 then
              print(bWriteLog and "GrenadeAvatarComponent:CheckHasOverrideFx WeaponOverrideSoundSwitch is off. ID: " % UnlockFxGunID)
              SoundOverrideWeaponID = 0
            end
          end
          break
        end
      end
    end
  end
  print(bWriteLog and "GrenadeAvatarComponent:CheckHasOverrideFx SetOverrideSoundIndex. ID: " % SoundOverrideWeaponID)
  self:SetOverrideSoundIndex(SoundOverrideWeaponID)
end

function GrenadeAvatarComponent:SpawnHighLevelParticleActor(Location)
  if Client then
    Client.AddAttachFileString("ProjectileBase", false, "SpawnHighLevelParticleActor start ")
  end
  local SequencePath = self:GetSequencePath(Location)
  if not SequencePath or SequencePath == "" then
    print(bWriteLog and "[GrenadeAvatarComponent] SpawnHighLevelParticleActor no SequencePath")
    return
  end
  print(bWriteLog and "GrenadeAvatarComponent:SpawnHighLevelParticleActor " % tostring(SequencePath))
  if slua.isValid(self.LevelSequenceActor) then
    self.LevelSequenceActor:K2_DestroyActor()
  end
  self:CreateLevelSequenceActor(SequencePath, Location)
end

function GrenadeAvatarComponent:GetSequencePath(Location)
  print(bWriteLog and "GrenadeAvatarComponent:GetSequencePath" % tostring(self:IsInSky(Location)))
  if self.SkyExLevelSeqPath and slua.isValid(self.SkyExLevelSeqCache) and self:IsInSky(Location) then
    return self.SkyExLevelSeqPath
  end
  return self.ExLevelSeqPath
end

function GrenadeAvatarComponent:CreateLevelSequenceActor(seqPath, Location)
  if Client then
    Client.AddAttachFileString("ProjectileBase", false, "CreateLevelSequenceActor start " % tostring(seqPath))
  end
  if not seqPath or seqPath == "" then
    print(bWriteLog and "[GrenadeAvatarComponent] CreateLevelSequenceActor no seqPath")
  end
  local OwnerCharacter = self:GetOwner()
  if OwnerCharacter and slua.isValid(OwnerCharacter) then
    local TempOwner
    if slua.isValid(OwnerCharacter.Object) and slua.isValid(OwnerCharacter.Object.Owner) then
      TempOwner = OwnerCharacter.Object.Owner
    end
    OwnerCharacter = TempOwner or OwnerCharacter:GetAttachParentActor()
  end
  local LookAtRot = FRotator()
  if OwnerCharacter and slua.isValid(OwnerCharacter) then
    LookAtRot = import("KismetMathLibrary").FindLookAtRotation(Location, OwnerCharacter:K2_GetActorLocation())
    LookAtRot.Roll = 0
  end
  local SequenceTransform = FTransform(LookAtRot, Location, FVector(1))
  self.LevelSequenceActor = Game:PlayLevelSequence(self, seqPath, SequenceTransform, DeadBoxSmokeSeqActorPath, false)
  if not slua.isValid(self.LevelSequenceActor) then
    print(bWriteLog and "[GrenadeAvatarComponent] CreateLevelSequenceActor not slua.isValid(SequenceActor)")
  end
  self:AddGameTimer(0.1, false,
function()
    if slua.isValid(self.LevelSequenceActor) then
      self.LevelSequenceActor:Play(0.0)
    end
  end)
  if Client then
    Client.AddAttachFileString("ProjectileBase", false, "CreateLevelSequenceActor end " % tostring(seqPath))
  end
end

function GrenadeAvatarComponent:ReceiveEndPlay(EndReason, bClearTable)
  if slua.isValid(self.LevelSequenceActor) then
    self.LevelSequenceActor:K2_DestroyActor()
  end
  self.ModelActor = nil
  GrenadeAvatarComponent.__super.ReceiveEndPlay(self, EndReason, bClearTable)
end

function GrenadeAvatarComponent:ChangeAllMeshToFeatureMaterial(material)
  self.FeatureMaterial = material
  local model_util = require("client.common.model_util")
  model_util.ChangeActorAllMeshCompFeatureMaterial(self:GetOwner(), material)
end

function GrenadeAvatarComponent:ClearAllFeatureMaterial()
  self.FeatureMaterial = nil
  local model_util = require("client.common.model_util")
  model_util.ClearActorMeshCompsFeatureMaterial(self:GetOwner())
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CAvatarComp = class(CActorComponentBase, nil, GrenadeAvatarComponent)
return CAvatarComp