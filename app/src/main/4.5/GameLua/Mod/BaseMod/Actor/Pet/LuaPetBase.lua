local LuaPetBase = {
  MulticastRPC = {},
  LuaEventContainer = {
    "EVENTID_PET_AMUSING",
    "EVENTID_PAWN_DIED"
  }
}
LuaPetBase.MulticastRPC.MulticastRPC_StopAnimation = {
  Reliable = true,
  Params = {}
}
local PetAnimationDelayConfig = {
  [50026] = {
    [50026009] = {Delay = 2}
  }
}
local PetUtil = require("GameLua.Mod.BaseMod.Actor.Pet.PetUtil")
function LuaPetBase:ctor()
  self.PetAnimationTimer = nil
  self.nPetSwimTimer = nil
  self.actionMoveTarget = nil
end
function LuaPetBase:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "needAttach",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "positionZ",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    }
  }
end
local PetParam = 0.1
function LuaPetBase:ReceiveBeginPlay()
  LuaPetBase.__super.ReceiveBeginPlay(self)
  if self.Super and self.Super.ReceiveBeginPlay then
    self.Super:ReceiveBeginPlay()
  end
  local PetLevelInfo = slua.IndexReference(self, "PetLevelInfo")
  local PetID = PetLevelInfo.PetId
  local PetLevel = PetLevelInfo.PetLevel
  self.nPetId = PetID
  print(bWriteLog and string.format("[Pet] LuaPetBase:ReceiveBeginPlay Name: %s PetID: %s, PetLevel: %s", Game:GetPlainName(self.Object), tostring(PetID), tostring(PetLevel)))
  local OwnerCharacter = self.Owner
  if slua.isValid(OwnerCharacter) then
    self:BindLuaObjEvent(OwnerCharacter, "EVENTID_PET_AMUSING", self.OnPlayerAmusing, self)
    self:AddControlEvent(OwnerCharacter, "OnScopeInDelegate", self.OnOwnerCharacterScopeIn, self)
    self:AddControlEvent(OwnerCharacter, "OnScopeOutDelegate", self.OnOwnerCharacterScopeOut, self)
    if Client then
      self:AddControlEvent(OwnerCharacter, "OnParachuteStateChanged", self.LuaHandleParachuteStateChanged, self)
      self:AddControlEvent(OwnerCharacter, "OnPerspectiveChanged", self.HandlePerspectiveChangedEvent, self)
    end
  end
  if not Client then
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_PARACHUTE_LANDED, self.OnPlayerParachuteLanded, self)
    self:BindLuaObjEvent(self.Owner, "EVENTID_PAWN_DIED", self.HandleOnPawnDie, self)
    log(bWriteLog and "LuaPetBase:ReceiveBeginPlay.  checkSwim")
    self:AddGameTimer(PetParam, false, function()
      OwnerCharacter = self.Owner
      local uPlayerController = slua.isValid(OwnerCharacter) and OwnerCharacter:GetPlayerControllerSafety()
      if slua.isValid(uPlayerController) then
        self:SetActionMoveTarget(uPlayerController)
        self:AddControlEvent(OwnerCharacter, "OnParachuteStateChanged", self.ServerLuaHandleParachuteStateChanged, self)
        self:AddControlEvent(OwnerCharacter, "OnAttachedToVehicle", self.OnPlayerAttachedToVehicle, self)
        self:AddControlEvent(OwnerCharacter, "OnDetachedFromVehicle", self.OnPlayerOnDetachedFromVehicle, self)
      else
        log(bWriteLog and "LuaPetBase:ReceiveBeginPlay.  uPlayerController is invalid")
      end
    end)
    self:AddGameTimer(0, false, function()
      self:SetupFightPetParams()
    end)
    self:AddGameTimer(PetParam, false, function()
      self:InitSwimmingStateOnAuthority()
    end)
  else
    local ENetRole = import("ENetRole")
    if slua.isValid(OwnerCharacter) and OwnerCharacter.Role == ENetRole.ROLE_SimulatedProxy then
      self:AddTimerOnce(2, function()
        local EPetState = import("EPetState")
        if self.positionZ and self:PetHasState(EPetState.PetSwimming) then
          local pos = self:K2_GetActorLocation()
          log(bWriteLog and "LuaPetBase:ReceiveBeginPlay. self.positionZ: " .. tostring(self.positionZ))
          self:K2_SetActorLocation(FVector(pos.X, pos.Y, self.positionZ), false, nil, false)
        end
      end)
    end
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local SuperData = GameplayData.GetSuperData()
    self:AddDataListener(SuperData, "CharacterDataReady", function()
      self:LuaSetPetVisibility(true)
    end)
  end
end
function LuaPetBase:ReceiveBeginDestroy()
  LuaPetBase.__super.ReceiveBeginDestroy(self)
  if self.Super and self.Super.ReceiveBeginDestroy then
    self.Super:ReceiveBeginDestroy()
  end
end
function LuaPetBase:ReceiveEndPlay(EndReason, bClearTable)
  log(bWriteLog and "LuaPetBase:ReceiveEndPlay")
  self:ShowDisappearEffect()
  LuaPetBase.__super.ReceiveEndPlay(self)
  if self.Super and self.Super.ReceiveEndPlay then
    self.Super:ReceiveEndPlay(EndReason)
  end
end
function LuaPetBase:LuaSetPetVisibility(visible)
  if not Client then
    return
  end
  log(bWriteLog and "LuaPetBase:LuaSetPetVisibility. visible: " .. tostring(visible))
  local bScopeInState = self.bScopeInState
  log(bWriteLog and "LuaPetBase:LuaSetPetVisibility. bScopeInState: " .. tostring(bScopeInState))
  if bScopeInState then
    log(bWriteLog and "LuaPetBase:LuaSetPetVisibility.  bScopeInState")
    visible = false
    self:ClientSetPetHidden(true)
    return
  end
  local bOwnerIsAutonomous = self.PetOwnerIsAutonomous and self:PetOwnerIsAutonomous()
  log(bWriteLog and "LuaPetBase:LuaSetPetVisibility. bOwnerIsAutonomous: " .. tostring(bOwnerIsAutonomous))
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if bOwnerIsAutonomous then
    if PlayerController and not PlayerController:CanShowMyPet() then
      log(bWriteLog and "LuaPetBase:LuaSetPetVisibility.  bOwnerIsAutonomous and not PlayerController:CanShowMyPet()")
      visible = false
      self:ClientSetPetHidden(true)
      return
    end
    local EPawnState = import("EPawnState")
    local Owner = self.Owner
    if slua.isValid(Owner) and (Owner:HasState(EPawnState.InVehicle) or Owner:HasState(EPawnState.DriveVehicle)) then
      log(bWriteLog and "LuaPetBase:LuaSetPetVisibility.  in car")
      visible = false
      self:ClientSetPetHidden(true)
      return
    end
  else
    local settingConfig = slua_GameFrontendHUD:GetUserSettings()
    if settingConfig then
      log(bWriteLog and "LuaPetBase:LuaSetPetVisibility. settingConfig.OpenOthersPet: " .. tostring(settingConfig.OpenOthersPet))
      if not settingConfig.OpenOthersPet then
        visible = false
        self:ClientSetPetHidden(true)
        return
      end
    end
  end
  self:ClientSetPetHidden(not visible)
end
function LuaPetBase:ClientSetPetHidden(hidden)
  log(bWriteLog and "LuaPetBase:ClientSetPetHidden. hidden: " .. tostring(hidden))
  self:SetActorHiddenInGameMask(hidden or false, 0)
end
function LuaPetBase:OnRep_positionZ()
  print(bWriteLog and "PetFormCharFeature:OnRep_positionZ", self.positionZ)
end
function LuaPetBase:AttachtoOwnerPlayer()
  log(bWriteLog and "LuaPetBase:AttachtoOwnerPlayer.  ")
  self.CharacterMovement:StopMovementImmediately()
  local EAttachmentRule = import("EAttachmentRule")
  local attachInfo = self.PetEntity.AttachInfo
  self:K2_AttachToActor(self.Owner, attachInfo.AttachSocketName, EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, false)
  self:K2_SetActorRelativeLocation(attachInfo.AttachOffset, false, nil, true)
  self.CharacterMovement:Deactivate()
end
function LuaPetBase:ParseStrToFVector(VectorStr, DefaultVector)
  if not VectorStr or VectorStr == "" then
    return DefaultVector
  end
  local ParsedVector = self:_ParseVec3(VectorStr)
  return FVector(ParsedVector.x_f, ParsedVector.y_f, ParsedVector.z_f)
end
function LuaPetBase:ParseStrToFRotator(RotatorStr, DefaultRotator)
  if not RotatorStr or RotatorStr == "" then
    return DefaultRotator
  end
  local ParsedRotator = self:_ParseVec3(RotatorStr)
  return FRotator(ParsedRotator.y_f, ParsedRotator.z_f, ParsedRotator.x_f)
end
function LuaPetBase:_ParseVec3(str)
  local vec = {
    x_f = 1,
    y_f = 1,
    z_f = 1
  }
  if str and str ~= "" then
    local StringUtil = require("common.string_util")
    local arr = StringUtil.Split(str, ";")
    if arr and #arr == 3 then
      vec = {
        x_f = tonumber(arr[1]),
        y_f = tonumber(arr[2]),
        z_f = tonumber(arr[3])
      }
    end
  end
  return vec
end
local EPetState = import("EPetState")
local EPawnState = import("EPawnState")
function LuaPetBase:InitSwimmingStateOnAuthority()
  local USphereComponent = import("SphereComponent")
  local swimCheck = self:GetComponentByClass(USphereComponent)
  log(bWriteLog and "LuaPetBase:InitSwimmingStateOnAuthority. swimCheck: " .. tostring(swimCheck))
  if not slua.isValid(self.Owner) or not self.ForceEnterSwimState then
    log(bWriteLog and "LuaPetBase:InitSwimmingStateOnAuthority. owner is invalid")
    return
  end
  if slua.isValid(swimCheck) then
    local AActor = import("/Script/Engine.Actor")
    local AWaterSwimActor = import("WaterSwimActor")
    local swimObjs = swimCheck:GetOverlappingActors(slua.Array(UEnums.EPropertyClass.Object, AActor), AWaterSwimActor)
    log(bWriteLog and "LuaPetBase:InitSwimmingStateOnAuthority. swimObjs: " .. tostring(swimObjs))
    local num = swimObjs and swimObjs:Num()
    log(bWriteLog and "LuaPetBase:InitSwimmingStateOnAuthority. num: " .. tostring(num))
    if num and 0 < num then
      log(bWriteLog and "LuaPetBase:InitSwimmingStateOnAuthority.  is in water")
      self:LuaForceEnterSwimState()
      return true
    end
  end
  local Capsule = self.CapsuleComponent
  local HalfHeight = slua.isValid(Capsule) and Capsule:GetScaledCapsuleHalfHeight() or 50.0
  local ActorLoc = self:K2_GetActorLocation()
  local Start = ActorLoc + FVector(0, 0, HalfHeight)
  local End = ActorLoc - FVector(0, 0, HalfHeight + 100)
  local ECollisionChannel = import("ECollisionChannel")
  local IgnoreActors = slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
  IgnoreActors:Add(self.Object)
  IgnoreActors:Add(self.Owner)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local AWaterSwimActor = import("WaterSwimActor")
  local bHit, uHitResults = UKismetSystemLibrary.LineTraceMultiForObjects(self.Owner, Start, End, {
    ECollisionChannel.ECC_WorldDynamic
  }, false, IgnoreActors, 0, nil, true, FLinearColor.Red, FLinearColor.Green, 1)
  log(bWriteLog and "LuaPetBase:InitSwimmingStateOnAuthority. bHit: " .. tostring(bHit))
  if bHit and uHitResults then
    local ResultsNum = uHitResults:Num()
    for i = 0, ResultsNum - 1 do
      local uHitResult = uHitResults:Get(i)
      local uHitActor = uHitResult.Actor
      if slua.isValid(uHitActor) and Game:IsClassOf(uHitActor, AWaterSwimActor) then
        log(bWriteLog and "LuaPetBase:InitSwimmingStateOnAuthority.  LineTrace hit water")
        self:LuaForceEnterSwimState()
      end
    end
  end
end
function LuaPetBase:LuaForceExitSwimState()
end
function LuaPetBase:OnRefreshPetLevelInfo()
  local PetID = self.PetLevelInfo and self.PetLevelInfo.PetId or 0
  log(bWriteLog and "LuaPetBase:OnRefreshPetLevelInfo. PetID: " .. tostring(PetID))
  self:SetupFightPetParams()
end
function LuaPetBase:SetupFightPetParams()
  local PetID = self.PetLevelInfo and self.PetLevelInfo.PetId or 0
  if PetID == 0 then
    log(bWriteLog and "LuaPetBase:SetupFightPetParams. PetID is 0")
    return
  end
  local location = self:K2_GetActorLocation()
  log(bWriteLog and "LuaPetBase:SetupFightPetParams. location.Z: " .. tostring(location.Z))
  log(bWriteLog and "LuaPetBase:SetupFightPetParams. self.PetLevelInfo.PetId: " .. tostring(self.PetLevelInfo.PetId))
  local info = self:GetMyPetInfo()
  log(bWriteLog and "LuaPetBase:SetupFightPetParams. info: " .. tostring(info))
  local PetAvatarList = info and info.PetAvatarList
  local FightPetParamsCfg
  if PetAvatarList then
    for _, id in pairs(PetAvatarList) do
      log(bWriteLog and "LuaPetBase:SetupFightPetParams. id: " .. tostring(id))
      FightPetParamsCfg = CDataTable.GetTableData("FightPetParams", id)
      if FightPetParamsCfg then
        break
      end
    end
  end
  FightPetParamsCfg = FightPetParamsCfg or CDataTable.GetTableData("FightPetParams", PetID)
  if not FightPetParamsCfg then
    return
  end
  self.  local ParachuteOffset = self:ParseStrToFVector(FightPetParamsCfg.ParachuteLocation, FVector.ZeroVector)
  local ParachuteRotation = self:ParseStrToFRotator(FightPetParamsCfg.ParachuteRotation, FRotator.ZeroRotator)
  self.PetEntity.AttachInfo.AttachOffset = ParachuteOffset
  self.PetEntity.AttachInfo.AttachRotation = ParachuteRotation
  self.PetEntity.AttachInfo.AttachSocketName = FightPetParamsCfg.ParachuteAttachPoint
  log(bWriteLog and "LuaPetBase:SetupFightPetParams. FightPetParamsCfg.ParachuteLocation: " .. tostring(FightPetParamsCfg.ParachuteLocation))
  log(bWriteLog and "LuaPetBase:SetupFightPetParams. FightPetParamsCfg.ParachuteRotation: " .. tostring(FightPetParamsCfg.ParachuteRotation))
  log(bWriteLog and "LuaPetBase:SetupFightPetParams. self.PetEntity.AttachInfo.AttachSocketName: " .. tostring(self.PetEntity.AttachInfo.AttachSocketName))
  local MeshLocation = self:ParseStrToFVector(FightPetParamsCfg.MeshLocation, FVector.ZeroVector)
  local MeshRotation = self:ParseStrToFRotator(FightPetParamsCfg.MeshRotation, FRotator.ZeroRotator)
  local MeshScale = self:ParseStrToFVector(FightPetParamsCfg.MeshScale, FVector.OneVector)
  local MeshShowScale = self.MeshShowScale
  if MeshShowScale and MeshShowScale.X ~= 0 then
    MeshScale = MeshShowScale
    log(bWriteLog and "LuaPetBase:SetupFightPetParams. MeshShowScale.X: " .. tostring(MeshShowScale.X))
  end
  if slua.isValid(self.Mesh) then
    self.Mesh:K2_SetRelativeTransform(FTransform(MeshRotation, MeshLocation, MeshScale), false, nil, false)
  end
  self.Origin  if not PetUtil.IsBird(PetID) then
    local SSwimOffsetLocation = FightPetParamsCfg.SwimOffsetLocation
    SSwimOffsetLocation = "0;0;0"
    log(bWriteLog and "LuaPetBase:SetupFightPetParams. SwimOffsetLocation: " .. tostring(SSwimOffsetLocation))
    local SwimOffsetLocation = self:ParseStrToFVector(SSwimOffsetLocation, FVector.ZeroVector)
    self.SwimOffset = SwimOffsetLocation
    local SSwimCheckLocation = FightPetParamsCfg.SwimCheckLocation
    SSwimCheckLocation = "0;0;-0"
    log(bWriteLog and "LuaPetBase:SetupFightPetParams. SwimCheckLocation: " .. tostring(SSwimCheckLocation))
    local SwimCheckLocation = self:ParseStrToFVector(SSwimCheckLocation, FVector.ZeroVector)
    local SwimCheckRotation = self:ParseStrToFRotator(FightPetParamsCfg.SwimCheckRotation, FRotator.ZeroRotator)
    local CapsuleComponent = self.CapsuleComponent
    CapsuleComponent.CapsuleHalfHeight = 30
    CapsuleComponent.CapsuleRadius = 30
    local SSwimCheckScale = FightPetParamsCfg.SwimCheckScale
    log(bWriteLog and "LuaPetBase:SetupFightPetParams. SwimCheckScale: " .. tostring(SSwimCheckScale))
    local SwimCheckScale = self:ParseStrToFVector(SSwimCheckScale, FVector.OneVector)
    if slua.isValid(self.SwimCheck) then
      log(bWriteLog and "LuaPetBase:SetupFightPetParams.  SwimCheck:K2_SetRelativeTransform")
      self.SwimCheck:K2_SetRelativeTransform(FTransform(SwimCheckRotation, SwimCheckLocation, SwimCheckScale), false, nil, false)
    end
  end
end
function LuaPetBase:LuaForceEnterSwimState()
  self:DSTeleportImp(true)
end
function LuaPetBase:TeleportIfSwim()
  if not self.PetHasState or not self:PetHasState(EPetState.PetSwimming) then
    log(bWriteLog and "LuaPetBase:TeleportIfSwim.  not swim")
    return
  end
  log(bWriteLog and "LuaPetBase:TeleportIfSwim.  swim jump")
  local location = self:K2_GetActorLocation()
  log(bWriteLog and "LuaPetBase:TeleportIfSwim. location.Z: " .. tostring(location.Z))
  self:Teleport()
end
function LuaPetBase:Teleport()
  if not self.GetController then
    log(bWriteLog and "LuaPetBase:Teleport.  GetController is nil" .. tostring(self.Object))
    return
  end
  local uController = self:GetController()
  if Game:IsValid(uController) and uController.GetBlackboardComponent ~= nil then
    local uBlackboard = uController:GetBlackboardComponent()
    if Game:IsValid(uBlackboard) then
      uBlackboard:SetValueAsBool("NeedTeleport", true)
    end
  end
end
function LuaPetBase:PetOwnerCharacterBecomeValid()
  self.Super:PetOwnerCharacterBecomeValid()
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  if not UKismetSystemLibrary.IsDedicatedServer(self) then
    self:AddSettingOptionEvent("OpenOthersPet", function(OpenOthersPet)
      print(bWriteLog and "LuaPetBase OpenOthersPet: " .. tostring(OpenOthersPet))
      self:OtherPetVisibleSettingChanged(OpenOthersPet)
    end)
  end
end
function LuaPetBase:OtherPetVisibleSettingChanged(OpenOthersPet)
  log(bWriteLog and "LuaPetBase:OtherPetVisibleSettingChanged. OpenOthersPet: " .. tostring(OpenOthersPet))
  if not Client then
    log(bWriteLog and "LuaPetBase:OtherPetVisibleSettingChanged.  not Client")
    return
  end
  local bOwnerIsAutonomous = self.PetOwnerIsAutonomous and self:PetOwnerIsAutonomous()
  if bOwnerIsAutonomous then
    log(bWriteLog and "LuaPetBase:OtherPetVisibleSettingChanged.  bOwnerIsAutonomous")
    return
  end
  local bPetHasDisappearState = self.PetHasDisappearState and self:PetHasDisappearState()
  if bPetHasDisappearState then
    log(bWriteLog and "LuaPetBase:OtherPetVisibleSettingChanged.  bPetHasDisappearState")
    return
  end
  self:LuaSetPetVisibility(OpenOthersPet)
end
local adjustHeight = 200
local maxHeight = 300
function LuaPetBase:HandleOnOwnerEnterSwim()
  local Owner = self.Owner
  if not slua.isValid(Owner) then
    return
  end
  local ownerController = Owner:GetPlayerControllerSafety()
  if not ownerController then
    return
  end
  if PetUtil.IsSpecialBird(ownerController) then
    return
  end
  if self.nPetSwimTimer then
    self:ClearSwimTimer()
  end
  log(bWriteLog and "LuaPetBase:HandleOnOwnerEnterSwim.  ")
  self.nPetSwimTimer = self:AddGameTimer(0.05, false, function()
    local PetComponent_BP = slua.isValid(self.Owner) and self.Owner.PetComponent_BP
    if slua.isValid(PetComponent_BP) and self.Owner:HasState(EPawnState.Swim) and not self:PetHasState(EPetState.PetDisappear) then
      log(bWriteLog and "LuaPetBase:HandleOnOwnerEnterSwim.  ForceEnterSwimState pos")
      local pos = self.Owner:K2_GetActorLocation()
      local myPos = self:K2_GetActorLocation()
      if myPos.Z - pos.Z > maxHeight then
        log(bWriteLog and "LuaPetBase:HandleOnOwnerEnterSwim. pos.Z: " .. tostring(pos.Z))
        self:K2_SetActorLocation(pos + FVector(0, 0, adjustHeight), false, nil, true)
      end
      self:ClearSwimTimer()
    end
  end)
end
function LuaPetBase:HandleOnOwnerLeaveSwim()
  self:ClearSwimTimer()
end
function LuaPetBase:ClearSwimTimer()
  if self.nPetSwimTimer then
    self:RemoveGameTimer(self.nPetSwimTimer)
    self.nPetSwimTimer = nil
  end
end
function LuaPetBase:OnOwnerCharacterScopeIn(bIsBegin)
  if not bIsBegin then
    return
  end
  print(bWriteLog and "LuaPetBase:OnOwnerCharacterScopeIn")
  if self.Mesh then
    self.Mesh:SetVisibility(false, true)
  end
end
function LuaPetBase:OnOwnerCharacterScopeOut(bIsBegin)
  if not bIsBegin then
    return
  end
  if self.Mesh then
    self.Mesh:SetVisibility(true, true)
  end
end
function LuaPetBase:HandleOnPawnDie(uPawn, uKiller, TypeID)
  if not Game:IsValid(uPawn) or not uPawn.PlayerKey then
    return
  end
  log(bWriteLog and "LuaPetBase:HandleOnPawnDie. uPawn.PlayerKey: " .. tostring(uPawn.PlayerKey))
  if uPawn.PlayerKey == self.ownerKey then
    log(bWriteLog and "LuaPetBase:HandleOnPawnDie.  my owner dead")
    self:AddGameTimer(1, false, function()
      if slua.isValid(self.Object) then
        self:K2_DestroyActor()
      end
    end)
  end
end
function LuaPetBase:OnPlayerEnterWater()
  local now = os.time()
  if self.lastTime and now - self.lastTime <= 1 then
    return
  end
  self.lastTime = now
  log(bWriteLog and "LuaPetBase:OnPlayerEnterWater.  ")
  self:Teleport()
end
function LuaPetBase:OnPlayerParachuteLanded(_, _, uCharacter)
  if self.Owner ~= uCharacter then
    return
  end
  log(bWriteLog and "LuaPetBase:OnPlayerParachuteLanded. uCharacter: " .. tostring(uCharacter) .. tostring(self))
  local Owner = self.Owner
  if not slua.isValid(Owner) then
    return
  end
  local PetComponent_BP = slua.isValid(Owner) and Owner.PetComponent_BP
  local ownerController = Owner:GetPlayerControllerSafety()
  if not ownerController then
    return
  end
  if slua.isValid(PetComponent_BP) then
    self:AddGameTimer(2, false, function()
      local PetID = self.PetLevelInfo.PetID
      if PetUtil.IsBird(PetID) then
        PetComponent_BP:RecreatePet()
      else
        self:DSTeleportImp(true)
      end
    end)
  end
end
function LuaPetBase:LuaHandleParachuteStateChanged(_, NewParachuteState)
  local EParachuteState = import("EParachuteState")
  if NewParachuteState == EParachuteState.PS_FreeFall then
    log(bWriteLog and "  LuaPetBase:LuaHandleParachuteStateChanged. self.nPetId: " .. tostring(self.nPetId))
    if not self.nPetId then
      return
    end
    local OwnerCharacter = self.Owner
    if not OwnerCharacter then
      log(bWriteLog and "  LuaPetBase:LuaHandleParachuteStateChanged.  not OwnerCharacter")
      return
    end
    local uAvatarComp2 = OwnerCharacter:getAvatarComponent2()
    if not slua.isValid(uAvatarComp2) then
      log(bWriteLog and "  LuaPetBase:LuaHandleParachuteStateChanged.  not uAvatarComp2")
      return
    end
    local EAvatarSlotType = import("EAvatarSlotType")
    local AvatarDesc = uAvatarComp2:GetAvatarSlotDesc(EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot)
    local AvatarItem = AvatarDesc.ItemDefineID
    local gliderID = AvatarItem and AvatarItem.TypeSpecificID or 0
    local SpecialGliderPetCfg = CDataTable.GetTableByFilter("SpecialGliderPetCfg", "PetID", self.nPetId, "Glide", gliderID)
    local curCfg
    for _, v in pairs(SpecialGliderPetCfg) do
      curCfg = v
      break
    end
    if not curCfg then
      log(bWriteLog and "  LuaPetBase:LuaHandleParachuteStateChanged.  no cfg")
      return
    end
    self.bNeedRotate = true
    self:AddTimerOnce(0.1, function()
      local StringUtil = require("common.string_util")
      local ParachuteOffset = StringUtil.Str2Vector3(curCfg.SLocation, 1)
      local RotationOffset = StringUtil.Str2Vector3(curCfg.SRotation, 2)
      self:K2_SetActorRelativeLocation(ParachuteOffset, false, nil, true)
      self:K2_SetActorRelativeRotation(RotationOffset, false, nil, true)
      log(bWriteLog and "  LuaPetBase:LuaHandleParachuteStateChanged.  AttachtoOwnerPlayer  fan")
    end)
    local delay = curCfg.NDelayTime
    if 0 < delay then
      self:SetHiddenInParachute(true)
      self:AddTimerOnce(delay, function()
        self:SetHiddenInParachute(false)
      end)
    end
  elseif self.bNeedRotate and NewParachuteState == EParachuteState.PS_Opening then
    local NewRelativeRotation = self.PetEntity.AttachInfo.AttachRotation
    self:K2_SetActorRelativeRotation(NewRelativeRotation, false, nil, true)
    self:K2_SetActorRelativeLocation(self.PetEntity.AttachInfo.AttachOffset, false, nil, true)
    self.bNeedRotate = nil
  end
end
function LuaPetBase:HandlePerspectiveChangedEvent(isFPP)
  log(bWriteLog and "LuaPetBase:HandlePerspectiveChangedEvent. isFPP: " .. tostring(isFPP))
  if self.bIsFPP == isFPP then
    return
  end
  self.bIsFPP = isFPP
  self:SetActorHiddenInGameMaskWithFPP()
end
function LuaPetBase:SetActorHiddenInGameMaskWithFPP()
  local OwnerCharacter = self.Owner
  local ownerController = slua.isValid(OwnerCharacter) and OwnerCharacter:GetPlayerControllerSafety()
  if not slua.isValid(ownerController) then
    return
  end
  if ownerController.UsingAdditionalPetIndex == -1 then
    return
  end
  if ownerController.AdditionalPetInfo:Num() <= 0 then
    return
  end
  self.bIsFPP = OwnerCharacter.IsFPP
  local petInfo = ownerController.AdditionalPetInfo:Get(ownerController.UsingAdditionalPetIndex)
  local PetAvatarList = petInfo.PetAvatarList
  local PetID = self.PetLevelInfo.PetID
  if PetUtil.IsBird(PetID) and PetUtil.GetPetBtId(PetAvatarList) ~= 1 then
    log(bWriteLog and "LuaPetBase:SetActorHiddenInGameMaskWithFPP.  bird:" .. tostring(self.bIsFPP) .. tostring(Client))
    self:SetActorHiddenInGameMask(self.bIsFPP or false, 7)
  end
end
function LuaPetBase:ServerLuaHandleParachuteStateChanged(LastParachuteState, NewParachuteState)
  print(bWriteLog and "DSReviveSubsystem:LuaHandleParachuteStateChanged, LastParachuteState = " .. tostring(LastParachuteState) .. ", NewParachuteState = " .. tostring(NewParachuteState))
end
function LuaPetBase:OnPlayerAttachedToVehicle()
  log(bWriteLog and "LuaPetBase:OnPlayerAttachedToVehicle.  ")
  self.Controller.BrainComponent:StopLogic("")
  self:AddGameTimer(0.1, false, function()
    self:SetActorHiddenInGame(true)
  end)
end
function LuaPetBase:OnPlayerOnDetachedFromVehicle()
  log(bWriteLog and "LuaPetBase:OnPlayerOnDetachedFromVehicle.  ")
  self.Controller.BrainComponent:RestartLogic()
  self:SetActorHiddenInGame(false)
  self:SetActorHiddenInGameMaskWithFPP()
end
function LuaPetBase:SetOwnerCharacter(Owner)
  self.Super:SetOwnerCharacter(Owner)
end
function LuaPetBase:CanPlay()
  local bPlayInteractSkill = Game:GetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Bool, "bPlayInteractSkill")
  if bPlayInteractSkill then
    local nPlayingSkillAnimID = Game:GetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Int, "InteractSkillAnimID")
    print(bWriteLog and string.format("[Pet] LuaPetBase:CanPlay() %s not allow to play, because playing interact skill %s", Game:GetPlainName(self.Object), tostring(nPlayingSkillAnimID)))
    return false
  end
  return true
end
function LuaPetBase:PlayPetAnimation(nAnimationID, nLength)
  if Client then
    return
  end
  print(bWriteLog and string.format("[Pet] LuaPetBase:PlayPetAnimation %s PetID:%s, nAnimationID:%s nLength:%s", Game:GetPlainName(self.Object), self.PetLevelInfo.PetId, tostring(nAnimationID), tostring(nLength)))
  local AnimationLength = nLength + nLength * 0.05
  local uPetController = self:GetController()
  if not (slua.isValid(uPetController) and slua.isValid(uPetController.Blackboard)) or not slua.isValid(uPetController.Blackboard.BlackboardAsset) then
    return
  end
  local bPlaySpecifiedAnimation = Game:GetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Bool, "bPlaySpecifiedAnimation")
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Int, "AnimationID", nAnimationID)
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Float, "AnimationLength", AnimationLength)
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Bool, "bHasTriggeredAnimation", false)
  if self.PetAnimationTimer ~= nil then
    self:RemoveGameTimer(self.PetAnimationTimer)
    self.PetAnimationTimer = nil
  end
  if not bPlaySpecifiedAnimation then
    Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Bool, "bPlaySpecifiedAnimation", true)
  end
  self.PetAnimationTimer = self:AddGameTimer(AnimationLength, false, function()
    if slua.isValid(self.Object) then
      self:StopServerAnimLogic()
    end
  end)
end
function LuaPetBase:PlayPetInteractAnimation(uMasterPawn, nAnimationID, nLength)
  if Client then
    return
  end
  if not Game:IsValid(uMasterPawn) then
    return
  end
  print(bWriteLog and string.format("[Pet] LuaPetBase:PlayPetInteractAnimation PetID:%s, nAnimationID:%s uPlayer:%s", self.PetLevelInfo.PetId, tostring(nAnimationID), Game:GetPlainName(uMasterPawn)))
  local tCustomConfig = PetAnimationDelayConfig[self.PetLevelInfo.PetId]
  if tCustomConfig ~= nil and tCustomConfig[nAnimationID] ~= nil then
    local nDelay = tCustomConfig[nAnimationID].Delay
    self:AddGameTimer(nDelay, false, function()
      if slua.isValid(self.Object) then
        self:DoPlayInteractAnimation(nAnimationID, nLength)
      end
    end)
  else
    self:DoPlayInteractAnimation(nAnimationID, nLength)
  end
end
function LuaPetBase:DoPlayInteractAnimation(nAnimationID, nLength)
  if Client then
    return
  end
  local AnimationLength = nLength + nLength * 0.05
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Bool, "bPlayInteractSkill", true)
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Int, "InteractSkillAnimID", nAnimationID)
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Bool, "bHasTriggeredAnimation", false)
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Bool, "bPlaySpecifiedAnimation", false)
  if self.PetAnimationTimer ~= nil then
    Game:ClearTimer(self.PetAnimationTimer)
    self.PetAnimationTimer = nil
  end
  self.PetAnimationTimer = self:AddGameTimer(AnimationLength, false, function()
    if slua.isValid(self.Object) then
      self:StopServerAnimLogic()
    end
  end)
end
function LuaPetBase:StopServerAnimLogic()
  if Client then
    return
  end
  local bPlayInteractSkill = Game:GetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Bool, "bPlayInteractSkill")
  print(bWriteLog and string.format("[Pet] LuaPetBase:StopServerAnimLogic PetID:%s, bPlayInteractSkill:%s", self.PetLevelInfo.PetId, tostring(bPlayInteractSkill)))
  if self.PetAnimationTimer ~= nil then
    Game:ClearTimer(self.PetAnimationTimer)
    self.PetAnimationTimer = nil
  end
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Bool, "bHasTriggeredAnimation", false)
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Bool, "bPlaySpecifiedAnimation", false)
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Bool, "bPlayInteractSkill", false)
end
function LuaPetBase:OnPlayerAmusing(uPlayer, nSkillID, tParams)
  if not Game:IsValid(uPlayer) then
    return
  end
  local OwenrCharacter = self.Owner
  if not Game:IsValid(OwenrCharacter) or OwenrCharacter.PlayerKey == nil or uPlayer.PlayerKey == nil or OwenrCharacter.PlayerKey ~= uPlayer.PlayerKey then
    return
  end
  local bUnexpectedFinish = false
  if type(tParams) ~= "number" and tParams ~= nil and tParams.UnexpectedBreak ~= nil and tParams.UnexpectedBreak == 1 then
    bUnexpectedFinish = true
  end
  if bUnexpectedFinish then
    self:StopServerAnimLogic()
    self:MulticastRPC_StopAnimation()
  end
end
function LuaPetBase:MulticastRPC_StopAnimation()
  print(bWriteLog and string.format("[Pet] LuaPetBase:MulticastRPC_StopAnimation PetID:%s", self.PetLevelInfo.PetId))
  self:StopAnimMontage()
end
function LuaPetBase:ShowDisappearEffect()
  log(bWriteLog and "LuaPetBase:ShowDisappearEffect")
  if not Client then
    return
  end
  local OwnerCharacter = self.Owner
  if not slua.isValid(OwnerCharacter) then
    return
  end
  local uPlayerController = OwnerCharacter:GetPlayerControllerSafety()
  if not slua.isValid(uPlayerController) then
    return
  end
  local PetLevelInfo = slua.IndexReference(self, "PetLevelInfo")
  local PetID = PetLevelInfo and PetLevelInfo.PetId
  if not PetID or PetID == 0 or PetID == 50001 then
    return
  end
  local EffectItemID = uPlayerController.CommerFeature and uPlayerController.CommerFeature.PetSwitchEffectID
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local EffectCfg = logic_pet:GetPortalCfgByItemId(EffectItemID)
  local particlePath = EffectCfg.DisAppear
  local scale = EffectCfg.Scale or 1
  log(bWriteLog and "LuaPetBase:ShowDisappearEffect particle path: " .. tostring(particlePath))
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(particlePath, function(uParticle)
    if slua.isValid(uParticle) and slua.isValid(self.Object) then
      local GameplayStatics = import("GameplayStatics")
      GameplayStatics.SpawnEmitterAtLocation(self.Object, uParticle, self.Object:K2_GetActorLocation(), FRotator(0, 0, 0), FVector(scale, scale, scale), true)
    end
  end)
end
function LuaPetBase:ResetMaterialIfNeed()
  log(bWriteLog and "LuaPetBase:ResetMaterialIfNeed ")
  if self.PetLevelInfo and self.PetLevelInfo.PetID and self.PetLevelInfo.PetID >= 50037 and slua.isValid(self.Mesh) then
    for i = 0, 9 do
      self.Mesh:SetMaterial(i, nil)
    end
  end
end
function LuaPetBase:LoadBehaviorTree()
  if Client then
    return
  end
  log(bWriteLog and "LuaPetBase:LoadBehaviorTree.  ")
  local info = self:GetPetInfo()
  local PetID = self.PetLevelInfo.PetID
  log(bWriteLog and "LuaPetBase:LoadBehaviorTree. id: " .. tostring(PetID))
  local PetAvatarList = info.PetAvatarList
  log(bWriteLog and "LuaPetBase:LoadBehaviorTree. PetAvatarList:Num(): " .. tostring(PetAvatarList:Num()))
  if PetUtil.IsBird(PetID) then
    self.Controller:LoadBehaviorTree(PetUtil.GetPetBtId(PetAvatarList))
  end
end
function LuaPetBase:GetMyPetInfo()
  local OwnerCharacter = self.Owner
  if not slua.isValid(OwnerCharacter) then
    return
  end
  local ownerController = OwnerCharacter:GetControllerSafety()
  if not slua.isValid(ownerController) then
    return
  end
  if ownerController.UsingAdditionalPetIndex == -1 then
    ownerController.UsingAdditionalPetIndex = 0
    if not IsEditor then
      log_error("LuaPetBase:GetMyPetInfo. ownerController.UsingAdditionalPetIndex: -1")
    end
  end
  local AdditionalPetInfo = ownerController.AdditionalPetInfo
  if not AdditionalPetInfo then
    return
  end
  if 0 >= ownerController.AdditionalPetInfo:Num() then
    return
  end
  local petInfo = ownerController.AdditionalPetInfo:Get(ownerController.UsingAdditionalPetIndex)
  return petInfo
end
function LuaPetBase:GetPetDefaultFollowType()
  local PetID = self.PetLevelInfo.PetID
  if not PetUtil.IsBird(PetID) then
    log(bWriteLog and "LuaPetBase:GetPetDefaultFollowType.  is no bird 1")
    return 1
  end
  if self.needAttach then
    log(bWriteLog and "LuaPetBase:GetPetDefaultFollowType.  0")
    return 0
  end
  log(bWriteLog and "LuaPetBase:GetPetDefaultFollowType.  1")
  return 1
end
function LuaPetBase:LoadAvatarLater(list)
  local needAttach = true
  local PetID = self.PetLevelInfo.PetID
  if not PetUtil.IsBird(PetID) then
    needAttach = false
  else
    local FlyBtIdTb = PetUtil.GetFlyBtIdTb()
    for _, id in pairs(list) do
      if FlyBtIdTb[id] then
        needAttach = false
        break
      end
    end
  end
  log(bWriteLog and "LuaPetBase:LoadAvatarLater. needAttach: " .. tostring(needAttach))
  self.end
function LuaPetBase:SetActionMoveTarget(ownerController)
  if ownerController.UsingAdditionalPetIndex == -1 then
    log(bWriteLog and "LuaPetBase:SetActionMoveTarget.  ownerController.UsingAdditionalPetIndex == -1")
    return
  end
  if ownerController.AdditionalPetInfo:Num() <= 0 then
    log(bWriteLog and "LuaPetBase:SetActionMoveTarget.  ownerController.AdditionalPetInfo:Num() <= 0")
    return
  end
  local petInfo = ownerController.AdditionalPetInfo:Get(ownerController.UsingAdditionalPetIndex)
  local PetAvatarList = petInfo.PetAvatarList
  local PetID = self.PetLevelInfo.PetID
  if PetUtil.IsBird(PetID) and PetUtil.GetPetBtId(PetAvatarList) == 1 then
    self.actionMoveTarget = FVector(-3, -60, 42)
  end
end
local specialPetAction = {
  [50001015] = FVector(-3, -60, 42),
  [50001013] = FVector(23, -48, 34.5)
}
function LuaPetBase:BeforePlayAction(nActionID)
  if Client then
    return
  end
  local actionMoveTarget = specialPetAction[nActionID]
  if not actionMoveTarget then
    return
  end
  log(bWriteLog and "LuaPetBase:BeforePlayAction. nActionID: " .. tostring(nActionID))
  if not actionMoveTarget then
    return
  end
  local OwnerCharacter = self.Owner
  if not slua.isValid(OwnerCharacter) then
    return
  end
  local transCha = OwnerCharacter:GetTransform()
  local transPos_Cha = FTransform(FRotator(0, 0, 0), actionMoveTarget, FVector(1, 1, 1))
  local targetTrans = transPos_Cha * transCha
  local LocalLocation = targetTrans:GetLocation()
  self:K2_SetActorLocationAndRotation(LocalLocation, transCha:Rotator(), false, nil, true)
end
function LuaPetBase:SetHiddenInParachute(bHidden)
  self:SetActorHiddenInGame(bHidden)
end
function LuaPetBase:HandlePetStartParachute()
  log(bWriteLog and "LuaPetBase:HandlePetStartParachute.  " .. tostring(self.bHidden))
end
function LuaPetBase:DSTeleportImp(bBorn)
  local pet = self
  local owner = self.Owner
  if not slua.isValid(owner) then
    return
  end
  if owner:HasState(EPawnState.InPlane) or owner:HasState(EPawnState.InParachute) then
    return
  end
  local ownerRot = owner:K2_GetActorRotation()
  local ownerLocation = owner:K2_GetActorLocation()
  local petPos = pet:K2_GetActorLocation()
  local traceDistance = math.random(50, 150)
  local traceCount = 6
  local degreeStep = 360 / traceCount
  local startDirectionIndex = math.random(0, traceCount - 1)
  local randomYawOffset = math.random(-10, 10)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local UKismetMathLibrary = import("/Script/Engine.KismetMathLibrary")
  local AWaterSwimActor = import("WaterSwimActor")
  local IgnoreActors = slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
  IgnoreActors:Add(pet.Object)
  IgnoreActors:Add(owner)
  local RelativeLocation = self.Mesh.RelativeLocation
  local bestGroundPos, bestGroundRot, bestWaterPos, bestWaterRot, fallbackPos, fallbackRot
  for i = 0, traceCount - 1 do
    local directionIndex = (startDirectionIndex + i) % traceCount
    log(bWriteLog and "LuaPetBase:DSTeleportImp. directionIndex: " .. tostring(directionIndex))
    local targetYaw = ownerRot.Yaw + directionIndex * degreeStep + randomYawOffset
    local actorRot = FRotator(ownerRot.Pitch, targetYaw, ownerRot.Roll)
    local actorLoc = ownerLocation + UKismetMathLibrary.GetForwardVector(actorRot) * traceDistance
    local dir = UKismetMathLibrary.GetUpVector(actorRot)
    local lineStart = dir * 20000 + actorLoc
    local lineEnd = dir * -1000 + actorLoc
    local retRot = UKismetMathLibrary.MakeRotFromZY(FVector(0, 0, 1), UKismetMathLibrary.GetRightVector(actorRot))
    local targetRot = FRotator(0, retRot.Yaw, 0)
    local bHit, HitResult = UKismetSystemLibrary.LineTraceSingle(CGameWorld, lineStart, lineEnd, 6, true, IgnoreActors, 0, nil, true, FLinearColor.Red, FLinearColor.Green, 1)
    print(bWriteLog and string.format("LuaPetBase:DSTeleportImp traceIndex:%s bHit:%s", tostring(i), tostring(bHit)))
    if bHit then
      local uHitActor = HitResult.Actor
      local hitLocation = HitResult.Location
      local bHitWater = false
      if slua.isValid(uHitActor) then
        bHitWater = Game:IsClassOf(uHitActor, AWaterSwimActor)
      end
      log(bWriteLog and "LuaPetBase:DSTeleportImp. hitLocation.Z: " .. tostring(hitLocation.Z))
      if bHitWater then
        local waterPos
        if bBorn then
          waterPos = FVector(petPos.X, petPos.Y, hitLocation.Z)
        else
          waterPos = FVector(actorLoc.X, actorLoc.Y, hitLocation.Z)
        end
        if not bestWaterPos then
          bestWaterPos = waterPos
          bestWaterRot = targetRot
        end
        if not fallbackPos then
          fallbackPos = waterPos
          fallbackRot = targetRot
        end
      else
        local groundPos = FVector(actorLoc.X, actorLoc.Y, hitLocation.Z - RelativeLocation.Z)
        if not bestGroundPos then
          bestGroundPos = groundPos
          bestGroundRot = targetRot
          log(bWriteLog and "LuaPetBase:DSTeleportImp. found ground candidate")
        end
        if not fallbackPos then
          fallbackPos = groundPos
          fallbackRot = targetRot
        end
        log(bWriteLog and "LuaPetBase:DSTeleportImp.  no wa")
        break
      end
    else
      log(bWriteLog and "LuaPetBase:DSTeleportImp. trace nothing")
      if not fallbackPos then
        fallbackPos = FVector(actorLoc.X, actorLoc.Y, ownerLocation.Z)
        fallbackRot = targetRot
      end
    end
  end
  local bInWater = bestGroundPos == nil and bestWaterPos ~= nil
  local retPos = bestGroundPos or bestWaterPos or fallbackPos or ownerLocation
  local retRot = bestGroundRot or bestWaterRot or fallbackRot or FRotator(0, ownerRot.Yaw, 0)
  log(bWriteLog and "LuaPetBase:DSTeleportImp. retPos.Z: " .. tostring(retPos.Z))
  pet:K2_SetActorLocation(retPos, false, nil, true)
  pet:K2_SetActorRotation(retRot, false, nil, true)
  if bInWater then
    pet:ISetEnterSwimMode(0)
  end
  local CharacterMovement = pet.CharacterMovement
  CharacterMovement:StopMovementImmediately()
  CharacterMovement.Velocity = FVector(0, 0, 0)
  local component = pet:GetSyncSmoothComponent()
  if component then
    component:TeleportNextSync()
    component:ForceNetUpdate()
    log(bWriteLog and "LuaPetBase:DSTeleportImp.  ForceNetUpdate")
  end
end
local Class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CLuaPetBase = Class(CActorBase, nil, LuaPetBase)
return CLuaPetBase