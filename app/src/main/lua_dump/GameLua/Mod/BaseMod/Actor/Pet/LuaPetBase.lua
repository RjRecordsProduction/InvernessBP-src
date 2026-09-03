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
  self:BindLuaObjEvent(self.Owner, "EVENTID_PET_AMUSING", self.OnPlayerAmusing, self)
  local OwnerCharacter = self.Owner
  if slua.isValid(OwnerCharacter) then
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
    self:AddGameTimer(0.5, true, function()
      self:CheckSwim()
    end)
    self:AddGameTimer(1, false, function()
      self:TeleportIfSwim()
      OwnerCharacter = self.Owner
      local uPlayerController = slua.isValid(OwnerCharacter) and OwnerCharacter:GetPlayerControllerSafety()
      if slua.isValid(uPlayerController) then
        self:SetActionMoveTarget(uPlayerController)
        self:AddControlEvent(uPlayerController, "OnPlayerEnterWater", self.OnPlayerEnterWater, self, true)
        self:AddControlEvent(OwnerCharacter, "OnParachuteStateChanged", self.ServerLuaHandleParachuteStateChanged, self)
        self:AddControlEvent(OwnerCharacter, "OnAttachedToVehicle", self.OnPlayerAttachedToVehicle, self)
        self:AddControlEvent(OwnerCharacter, "OnDetachedFromVehicle", self.OnPlayerOnDetachedFromVehicle, self)
      end
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
  end
  self:SetupFightPetParams()
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
  if self.nSettingHandle then
    local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
    SettingSubsystem:UnregisterUserSettingDelegate(self.nSettingHandle)
    self.nSettingHandle = nil
  end
  LuaPetBase.__super.ReceiveEndPlay(self)
  if self.Super and self.Super.ReceiveEndPlay then
    self.Super:ReceiveEndPlay(EndReason)
  end
end
function LuaPetBase:OnRep_positionZ()
end
function LuaPetBase:SetupFightPetParams()
  log(bWriteLog and "LuaPetBase:SetupFightPetParams. self.PetLevelInfo.PetId: " .. tostring(self.PetLevelInfo.PetId))
  local PetID = self.PetLevelInfo.PetId
  if PetID == 0 then
    self:AddTimerOnce(0.5, function()
      self:SetupFightPetParams()
    end)
    return
  end
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
  self.Originend
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
function LuaPetBase:CheckSwim()
  self.positionZ = self:K2_GetActorLocation().Z
  if not self.ForceEnterSwimState then
    return
  end
  local Owner = self.Owner
  local PetComponent_BP = slua.isValid(Owner) and Owner.PetComponent_BP
  if slua.isValid(PetComponent_BP) and Owner:HasState(EPawnState.Swim) and not self:PetHasState(EPetState.PetSwimming) and not self:PetHasState(EPetState.PetDisappear) then
    log(bWriteLog and "LuaPetBase:CheckSwim.  ForceEnterSwimState")
    self:ForceEnterSwimState()
  end
end
function LuaPetBase:TeleportIfSwim()
  if not self.PetHasState or not self:PetHasState(EPetState.PetSwimming) then
    log(bWriteLog and "LuaPetBase:TeleportIfSwim.  not swim")
    return
  end
  log(bWriteLog and "LuaPetBase:TeleportIfSwim.  swim jump")
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
    local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
    if not SettingSubsystem then
      return
    end
    self.nSettingHandle = SettingSubsystem:RegisterUserSettingsDelegate_Bool("OpenOthersPet", function(OpenOthersPet)
      print(bWriteLog and "LuaPetBase OpenOthersPet: " .. tostring(OpenOthersPet))
      if self.OtherPetVisibleSettingChanged then
        self:OtherPetVisibleSettingChanged(OpenOthersPet)
      end
    end)
  end
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
  if not PetUtil.IsSpecialBird(ownerController) then
    log(bWriteLog and "LuaPetBase:OnPlayerParachuteLanded.  not special bird")
    return
  end
  if slua.isValid(PetComponent_BP) then
    self:AddGameTimer(2, false, function()
      PetComponent_BP:RecreatePet()
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
  if not self.ForceEnterSwimState then
    return
  end
  local EParachuteState = import("EParachuteState")
  print(bWriteLog and "DSReviveSubsystem:LuaHandleParachuteStateChanged, LastParachuteState = " .. tostring(LastParachuteState) .. ", NewParachuteState = " .. tostring(NewParachuteState))
  if self.ForceEnterSwimState and LastParachuteState ~= NewParachuteState and LastParachuteState == EParachuteState.PS_Opening then
    self:AddTimer(1, function()
      if slua.isValid(self.Object) and self:PetHasState(EPetState.PetSwimming) then
        self:Teleport()
        coroutine.yield(0.5)
        self:ForceEnterSwimState()
      end
    end)
  end
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
local Class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CLuaPetBase = Class(CActorBase, nil, LuaPetBase)
return CLuaPetBase