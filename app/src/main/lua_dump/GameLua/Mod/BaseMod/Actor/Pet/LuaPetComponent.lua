local LuaPetComponent = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local CONST_ATTACH_SCALE = 0.3
local FGameModePlayerPetInfo = import("GameModePlayerPetInfo")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local BubbleSkeletalPath = "/Game/Arts_Player/MiniTV/Mesh/MiniTVBubble_Skin.MiniTVBubble_Skin"
print("LuaPetComponent")
local CONST_DEFAULT_MINITV_ID = 1601019
function LuaPetComponent:ctor()
  self.MiniTvPawn = nil
  self.bEnableMiniTvPawn = false
  self.bForceHideBubble = false
end
function LuaPetComponent:RecreatePet()
  log(bWriteLog and "LuaPetComponent:RecreatePet.  ")
  local character = self:GetOwner()
  if not character then
    return
  end
  local ownerController = character:GetPlayerControllerSafety()
  if not ownerController then
    return
  end
  self:DoChangePetWithInfo(ownerController.AdditionalPetInfo:Get(ownerController.UsingAdditionalPetIndex))
end
function LuaPetComponent:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "MiniTvPawn",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Object
    },
    {
      "MiniTvInfo",
      ELifetimeCondition.COND_None,
      FGameModePlayerPetInfo
    },
    {
      "bEnableMiniTvPawn",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    }
  }
end
function LuaPetComponent:ReceiveBeginPlay()
  LuaPetComponent.__super.ReceiveBeginPlay(self)
  self.Super:ReceiveBeginPlay()
  if UKismetSystemLibrary.IsDedicatedServer(self) then
    local Owner = self:GetOwner()
    self:BindLuaObjEvent(Owner, "EVENTID_CHARACTER_POSSESSED", self.OnCharacterPossessed, self)
  end
end
function LuaPetComponent:SpawnMiniTvWithInfo(MiniTvInfo)
  if not self.bEnableMiniTvPawn then
    log(bWriteLog and "LuaPetComponent:SpawnMiniTvWithInfo bEnableMiniTvPawn is false")
    return
  end
  if self.PetInfo.PetId == 50000 then
    return
  end
  log(bWriteLog and "LuaPetComponent:SpawnMiniTvPawn ")
  if not self.MiniTvInfo or self.MiniTvInfo.PetId <= 0 then
    return
  end
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) or not Owner.GetPlayerStateSafety then
    return
  end
  local uPlayerState = Owner:GetPlayerStateSafety()
  local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
  if not uPlayerState or uPlayerState.LiveState == ExtraPlayerLiveState.IsDied then
    return
  end
  local PetLevelCfg = CDataTable.GetTableData("PetLevelTable", self.MiniTvInfo.PetCfgId)
  if not PetLevelCfg then
    return
  end
  local MiniTvClassPath = self:IsFppMode() and PetLevelCfg.PetCharacter or PetLevelCfg.PetFPPCharacter
  log(bWriteLog and "LuaPetComponent:SpawnMiniTvPawn MiniTvClassPath:" .. tostring(MiniTvClassPath))
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local SoftObjPath = KismetSystemLibrary.MakeSoftObjectPath(MiniTvClassPath)
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local MiniTvClass = STExtraBlueprintFunctionLibrary.GetClassByAssetReference(SoftObjPath)
  if not slua.isValid(MiniTvClass) then
    return
  end
  self:SpawnMiniTv(MiniTvClass)
end
function LuaPetComponent:SpawnMiniTv(MiniTvClass)
  if self.MiniTvPawn and slua.isValid(self.MiniTvPawn) then
    if self.bNeedRecreateMiniTv then
      self.MiniTvPawn:K2_DestroyActor()
      self.MiniTvPawn = nil
    else
      return
    end
  end
  if not slua.isValid(MiniTvClass) then
    return
  end
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) then
    return
  end
  self.bNeedRecreateMiniTv = false
  Owner:ForceNetUpdate()
  self.SpawnTrans = Owner:GetTransform()
  local SpawnLocation = self.SpawnTrans:GetLocation()
  local Start = FVector(SpawnLocation.X, SpawnLocation.Y, SpawnLocation.Z + 200)
  local End = FVector(SpawnLocation.X, SpawnLocation.Y, SpawnLocation.Z - 1000)
  local ECollisionChannel = import("ECollisionChannel")
  local EDrawDebugTrace = import("EDrawDebugTrace")
  local World = CGameMode:GetWorld()
  if not slua.isValid(World) then
    return
  end
  local uHitResult = import("/Script/Engine.HitResult")()
  local bHit = false
  bHit, uHitResult = UKismetSystemLibrary.LineTraceSingle(World, Start, End, ECollisionChannel.ECC_Vehicle, false, {}, EDrawDebugTrace.None, uHitResult, true, FLinearColor.Red, FLinearColor.Green, 0.0)
  if uHitResult.BlockingHit then
    SpawnLocation = uHitResult.Location + FVector(0, 0, self.spawnPetZ)
  end
  local MiniTvPawn = World:SpawnActor(MiniTvClass, SpawnLocation, self.SpawnTrans:Rotator(), nil)
  if slua.isValid(MiniTvPawn) then
    MiniTvPawn:SetOwner(Owner)
    MiniTvPawn.PetInfo = self.MiniTvInfo
    MiniTvPawn.PetLevelInfo.PetId = self.MiniTvInfo.PetId
    MiniTvPawn.PetLevelInfo.PetLevel = self.MiniTvInfo.PetLevel
    if MiniTvPawn.PetEventManager then
      MiniTvPawn.PetEventManager:InitEventConfigs(false)
    end
    self:SetMiniTVPawn(MiniTvPawn)
    MiniTvPawn.RelativePetID = self.PetInfo.PetId
  end
end
function LuaPetComponent:SetMiniTVPawn(MiniTvPawn)
  print(bWriteLog and "LuaPetComponent:SetMiniTVPawn")
  self.  if UKismetSystemLibrary.IsDedicatedServer(self) then
    self:OnRep_MiniTvPawn()
  end
  self:ForceNetUpdate()
end
function LuaPetComponent:GetMiniTVPawn()
  return self.MiniTvPawn
end
function LuaPetComponent:OnRep_MiniTvPawn()
  print(bWriteLog and "LuaPetComponent:OnRep_MiniTvPawn")
  if not slua.isValid(self.MiniTvPawn) then
    return
  end
  self:CheckMiniTvLocalSkinIsDownload()
  local OwnerPawn = self:GetOwner()
  if not slua.isValid(OwnerPawn) then
    return
  end
  self.MiniTvPawn:SetOwnerCharacter(OwnerPawn)
  if self.MiniTVPawn.PetEventManager then
    self.MiniTVPawn.PetEventManager:InitEventConfigs(false)
  end
  self:CheckAndRefreshAttachmentState()
  if self.OnRepPetPawnCallback then
    self.OnRepPetPawnCallback(self.MiniTvPawn)
  end
  if not self.bIsDS and OwnerPawn and OwnerPawn.PetFormCharFeature and OwnerPawn.PetFormCharFeature.bInPlane then
    local EPetState = import("EPetState")
    print(bWriteLog and "LuaPetComponent:OnRep_MiniTvPawn PetFormCharFeature.bInPlane")
    self.MiniTvPawn:PetEnterState(EPetState.PetDisappear)
  end
end
function LuaPetComponent:OnRep_MiniTvInfo()
  print(bWriteLog and "LuaPetComponent:OnRep_MiniTvInfo")
  self:CheckMiniTvLocalSkinIsDownload()
end
function LuaPetComponent:OnCharacterPossessed()
  print(bWriteLog and "LuaPetComponent:OnCharacterPossessed entry")
  if not UKismetSystemLibrary.IsDedicatedServer(self) then
    return
  end
  self.MiniTvInfo = FGameModePlayerPetInfo()
  self.MiniTvInfo.PetId = 50000
  self.MiniTvInfo.PetLevel = 1
  self.MiniTvInfo.PetCfgId = 500000001
  self.MiniTvInfo.PetAvatarList:Clear()
  local MiniTVDataUtil = require("GameLua.Activity.Commercialize.GamePlay.MiniTV.MiniTVDataUtil")
  local Owner = self:GetOwner()
  local MiniTVDressID = 0
  local bEnableMiniTvPawn = false
  if slua.isValid(Owner) then
    local UID = Game:GetPlayerUID(Owner.Object)
    if UID then
      MiniTVDressID = MiniTVDataUtil:GetPlayerMiniTVDressID(UID) or 0
      bEnableMiniTvPawn = MiniTVDataUtil:IsMiniTvEnabled(UID)
    end
  end
  self.  print(bWriteLog and "LuaPetComponent:OnCharacterPossessed MiniTVDressID:" .. tostring(MiniTVDressID))
  if MiniTVDressID ~= 0 then
    self.MiniTvInfo.PetAvatarList:Add(MiniTVDressID)
  end
end
function LuaPetComponent:CheckAndRefreshAttachmentState(retryTimes)
  if not slua.isValid(self.MiniTvPawn) then
    return
  end
  local PetID = self.PetInfo.PetId
  print(bWriteLog and "LuaPetComponent:CheckAndRefreshAttachmentState PetID:" .. tostring(PetID))
  if PetID and PetID ~= 0 and PetID ~= 50001 then
    local bPetMeshValid = true
    if Client then
      bPetMeshValid = slua.isValid(self.PetPawn) and slua.isValid(self.PetPawn.Mesh) and slua.isValid(self.PetPawn.Mesh.SkeletalMesh)
      if not bPetMeshValid then
        print(bWriteLog and "LuaPetComponent:CheckAndRefreshAttachmentState Pet mesh is not valid yet, will retry")
      end
    end
    if bPetMeshValid and slua.isValid(self.MiniTvPawn.Mesh) and slua.isValid(self.PetPawn) and slua.isValid(self.PetPawn.Mesh) then
      self.MiniTvPawn.bMiniTvAttachToPawn = true
      local KismetMathLibrary = import("KismetMathLibrary")
      local scaleCfg = CDataTable.GetTableData("PetScaleTable", PetID)
      local socketScale = scaleCfg and scaleCfg.MiniTvSocketScale_f or 1
      local meshScale = CONST_ATTACH_SCALE * socketScale
      local Transform = KismetMathLibrary.MakeTransform(FVector(0, 0, 0), FRotator(0, 0, 0), FVector(meshScale, meshScale, meshScale))
      local EAttachmentRule = import("EAttachmentRule")
      self.MiniTvPawn.Mesh:K2_AttachToComponent(self.PetPawn.Mesh, "MiniTVSocket", EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, true)
      self.MiniTvPawn.Mesh:K2_SetRelativeTransform(Transform, false, nil, false)
      self.MiniTvPawn.Bubble:K2_AttachToComponent(self.MiniTvPawn.Mesh, "BubbleSocket", EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, true)
      local Util = require("client.slua_ui_framework.util")
      Util.GetAssetAsync(BubbleSkeletalPath, function(BubbleMesh)
        if slua.isValid(self.MiniTvPawn) and slua.isValid(self.MiniTvPawn.Bubble) and slua.isValid(BubbleMesh) then
          print("LuaPetComponent:CheckAndRefreshAttachmentState SetBubble")
          if not self.bForceHideBubble then
            self.MiniTvPawn.Bubble:SetVisibility(true, false)
          else
            self.MiniTvPawn.Bubble:SetVisibility(false, false)
          end
          self.MiniTvPawn.Bubble:SetSkeletalMesh(BubbleMesh, true)
        end
      end)
    else
      print(bWriteLog and "LuaPetComponent:CheckAndRefreshAttachmentState invalid Mesh or PetPawn")
      retryTimes = retryTimes or 0
      if retryTimes < 10 then
        self:AddTimerOnce(0.5, function()
          self:CheckAndRefreshAttachmentState(retryTimes + 1)
        end)
      end
      if Client then
        self:ListenPetMeshLoaded()
      end
    end
  else
    self.MiniTvPawn.bMiniTvAttachToPawn = false
  end
  print(bWriteLog and "LuaPetComponent:CheckAndRefreshAttachmentState bMiniTvAttachToPawn:" .. tostring(self.MiniTvPawn and self.MiniTvPawn.bMiniTvAttachToPawn))
end
function LuaPetComponent:OnRep_PetInfo()
  print(bWriteLog and "LuaPetComponent:OnRep_PetInfo")
  self:CheckAndRefreshAttachmentState()
end
function LuaPetComponent:ListenPetMeshLoaded()
  if self.bListeningPetMeshLoaded then
    return
  end
  if not slua.isValid(self.PetPawn) then
    return
  end
  local PetAvatarComp = self.PetPawn.PetAvatarComponent_BP
  if not slua.isValid(PetAvatarComp) then
    print(bWriteLog and "LuaPetComponent:ListenPetMeshLoaded PetAvatarComponent_BP not found, skip")
    return
  end
  self.bListeningPetMeshLoaded = true
  self:AddControlEvent(PetAvatarComp, "OnAvatarAllMeshLoaded", function()
    print(bWriteLog and "LuaPetComponent:ListenPetMeshLoaded OnAvatarAllMeshLoaded fired, retry attach")
    self:RemoveControlEvent(PetAvatarComp, "OnAvatarAllMeshLoaded")
    self.bListeningPetMeshLoaded = false
    self:CheckAndRefreshAttachmentState()
  end)
  print(bWriteLog and "LuaPetComponent:ListenPetMeshLoaded registered OnAvatarAllMeshLoaded callback")
end
function LuaPetComponent:SetPetActorHiddenInGameMask(bNewHidden, HiddenMask)
  print(bWriteLog and "LuaPetComponent:SetPetActorHiddenInGameMask", tostring(bNewHidden), tostring(HiddenMask))
  if slua.isValid(self.PetPawn) then
    self.PetPawn:SetActorHiddenInGameMask(bNewHidden, HiddenMask)
  end
  if self.MiniTvPawn and slua.isValid(self.MiniTvPawn) then
    self.MiniTvPawn:SetActorHiddenInGameMask(bNewHidden, HiddenMask)
  end
end
function LuaPetComponent:PlaySpecifiedPetAnimationCheck(uInPlayer)
  if not slua.isValid(uInPlayer) then
    print(bWriteLog and "LuaPetComponent:PlaySpecifiedPetAnimationCheck uInPlayer is invalid")
    return false
  end
  local EPawnState = import("EPawnState")
  if uInPlayer:HasState(EPawnState.SpecialSuit) then
    ShowNotice(30121)
    print(bWriteLog and "LuaPetComponent:PlaySpecifiedPetAnimationCheck uInPlayer is in SpecialSuit")
    return false
  end
  return true
end
function LuaPetComponent:PetLeaveState(InPetState)
  print(bWriteLog and "LuaPetComponent:PetLeaveState", tostring(InPetState))
  if self.PetPawn and slua.isValid(self.PetPawn) and self.PetPawn:PetHasState(InPetState) then
    self.PetPawn:PetLeaveState(InPetState)
  end
  if self.MiniTvPawn and slua.isValid(self.MiniTvPawn) and self.MiniTvPawn:PetHasState(InPetState) then
    self.MiniTvPawn:PetLeaveState(InPetState)
  end
end
function LuaPetComponent:PetEnterState(InPetState)
  print(bWriteLog and "LuaPetComponent:PetEnterState", tostring(InPetState))
  if self.PetPawn and slua.isValid(self.PetPawn) and not self.PetPawn:PetHasState(InPetState) then
    self.PetPawn:PetEnterState(InPetState)
  end
  if self.MiniTvPawn and slua.isValid(self.MiniTvPawn) and not self.MiniTvPawn:PetHasState(InPetState) then
    self.MiniTvPawn:PetEnterState(InPetState)
  end
end
function LuaPetComponent:CheckMiniTvLocalSkinIsDownload()
  print("LuaPetComponent:CheckMiniTvLocalSkinIsDownload")
  if not Client then
    return
  end
  if not slua.isValid(self.MiniTvPawn) then
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local miniTvDressId
  if self.MiniTvInfo and self.MiniTvInfo.PetAvatarList then
    local avatarCount = self.MiniTvInfo.PetAvatarList:Num()
    if 0 < avatarCount then
      miniTvDressId = self.MiniTvInfo.PetAvatarList:Get(0)
    end
  end
  if miniTvDressId and miniTvDressId ~= CONST_DEFAULT_MINITV_ID then
    if PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {miniTvDressId}) ~= PufferConst.ENUM_DownloadState.Done then
      print(bWriteLog and "LuaPetComponent:CheckMiniTvLocalSkinIsDownload dress is not downloaded, equip default dress", tostring(miniTvDressId))
      self.MiniTvPawn.PetAvatarComponent_BP:PetEquipItemById(CONST_DEFAULT_MINITV_ID)
      self.bForceHideBubble = false
    else
      print(bWriteLog and "LuaPetComponent:CheckMiniTvLocalSkinIsDownload dress is downloaded", tostring(miniTvDressId))
      self.MiniTvPawn.PetAvatarComponent_BP:PetEquipItemById(miniTvDressId)
      self.bForceHideBubble = false
      local SADisplayCfg = CDataTable.GetTableData("SmartAssistantDisplayConfig", miniTvDressId)
      if SADisplayCfg and SADisplayCfg.bHideBubble then
        self.bForceHideBubble = true
      end
    end
    if not self.bForceHideBubble then
      self.MiniTvPawn.Bubble:SetVisibility(true, false)
    else
      self.MiniTvPawn.Bubble:SetVisibility(false, false)
    end
  end
end
function LuaPetComponent:GetMiniTvType()
  local MiniTvUtil = require("GameLua.Mod.BaseMod.Actor.Pet.MiniTvUtil")
  if not slua.isValid(self.MiniTvPawn) then
    return MiniTvUtil.ENUM_MINITV_TYPE.None
  end
  local PetID = self.PetInfo.PetId
  if PetID and PetID ~= 0 and PetID ~= 50001 then
    return MiniTvUtil.ENUM_MINITV_TYPE.AttachedToPet
  end
  return MiniTvUtil.ENUM_MINITV_TYPE.Standalone
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CPetAvatarComponent = class(CActorComponentBase, nil, LuaPetComponent)
return CPetAvatarComponent