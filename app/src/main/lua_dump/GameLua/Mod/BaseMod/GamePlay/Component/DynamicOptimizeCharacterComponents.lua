local ENetRole = import("ENetRole")
local EComponentDormantType = import("EComponentDormantType")
local EPawnState = import("EPawnState")
local EPlayerCameraMode = import("EPlayerCameraMode")
local EParachuteState = import("EParachuteState")
local EAvatarSlotType = import("EAvatarSlotType")
local EMovementMode = import("EMovementMode")
local GameplayStatics = import("GameplayStatics")
local ECharacterHealthStatus = import("ECharacterHealthStatus")
local DynamicOptimizeCharacterComponents = {}
function DynamicOptimizeCharacterComponents:ctor(selfType)
  self.CurrentNoAimCameraMode = EPlayerCameraMode.PCM_None
  self.SoundDormant = false
  self.CurrentTarget = nil
  self.CurrentParachuteState = EParachuteState.PS_None
  self.tParachuteMeshSlots = {
    EAvatarSlotType.EAvatarSlotType_ParachuteEquipemtSlot
  }
  self.DelayInitSeconds = math.random()
  self.EnableScopeOpt = true
  self.BackUpViewDistance = 1.0
end
function DynamicOptimizeCharacterComponents:ReceiveBeginPlay()
  if GameStatus.IsInLobbyOrMainCity() then
    print(bWriteLog and "[Warning]DynamicOptimizeCharacterComponents IsInLobbyOrMainCity=1, ReceiveBeginPlay return!")
    return
  end
  if not Client then
    print(bWriteLog and "[Warning]DynamicOptimizeCharacterComponents ReceiveBeginPlay Return")
    return
  end
  if Client.IsWindowOB and Client.IsWindowsClientReplay and (Client.IsWindowOB() or Client.IsWindowsClientReplay()) then
    return
  end
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local Enable = UKismetSystemLibrary.GetConsoleVariableIntValue("DynamicOptimize.Enable")
  if Enable <= 0 then
    print(bWriteLog and "DynamicOptimizeCharacterComponents:ReceiveBeginPlay Enable <= 0")
    return
  end
  DynamicOptimizeCharacterComponents.__super.ReceiveBeginPlay(self)
  self.OwnerCharacter = self:GetOwner()
  if self:IsClientViewCharacter() then
    log(bWriteLog and "Init HLOD Scale HandleOnSwitchCameraModeStart For HLOD ")
    local ScreenWidth = Client.GetScreenWidth()
    local ScreenHight = Client.GetScreenHight()
    self.EnableScopeOpt = true
  end
  if Game:IsValid(self.OwnerCharacter) then
    print(bWriteLog and string.format("[Warning]TestCarryBack DynamicOptimizeCharacterComponents:ReceiveBeginPlay CurPCPawn:%s, PlayerName:%s Role:%d", self.OwnerCharacter, self.OwnerCharacter:GetPlayerNameSafety(), self.OwnerCharacter.Role))
    print(bWriteLog and string.format("[Warning]TestCarryBack DynamicOptimizeCharacterComponents:ReceiveBeginPlay CurDynamicOpComp:%s, PlayerName:%s Role:%d", self.Object, self.OwnerCharacter:GetPlayerNameSafety(), self.OwnerCharacter.Role))
  end
  self:AddGameTimer(self.DelayInitSeconds, false, function()
    self:DelayInit()
  end)
end
function DynamicOptimizeCharacterComponents:DelayInit()
  if self.AwakeAllComponents ~= nil then
    self:AwakeAllComponents()
  end
  self:Init()
end
function DynamicOptimizeCharacterComponents:Init()
  print(bWriteLog and string.format("DynamicOptimizeCharacterComponents Init PlayerName:%s Role:%d", self.OwnerCharacter:GetPlayerNameSafety(), self.OwnerCharacter.Role))
  if not slua.isValid(self.OwnerCharacter) then
    print(bWriteLog and "DynamicOptimizeCharacterComponents not self.OwnerCharacter")
    return
  end
  if slua.isValid(self.OwnerCharacter.ParticleSystem) then
    self:SetComponentTickEnableSafety(self.OwnerCharacter.ParticleSystem, false)
    self:DestroyUnuseComponent(self.OwnerCharacter.ParticleSystem, "")
  end
  if slua.isValid(self.OwnerCharacter.Arrow) then
    self:SetComponentTickEnableSafety(self.OwnerCharacter.Arrow, false)
    self:DestroyUnuseComponent(self.OwnerCharacter.Arrow, "")
  end
  if Client then
    self:AddControlEvent(self.OwnerCharacter, "OnPerspectiveChanged", self.HandlePerspectiveChangedEvent, self)
    self:AddControlEvent(self.OwnerCharacter, "CharacterCommonEventDelegate", self.HandleCharacterCommonEvent, self)
    self:AddControlEvent(self.OwnerCharacter, "OnScopeInDelegate", self.HandleScopeInDelegate, self)
    self:AddControlEvent(self.OwnerCharacter, "OnScopeOutDelegate", self.HandleScopeOutDelegate, self)
    self:AddControlEvent(self.OwnerCharacter, "OnFakeOnVehicleDelegate", self.HandleOnFakeOnVehicleDelegate, self)
    local uAvatarComp = self.OwnerCharacter:getAvatarComponent2()
    if slua.isValid(uAvatarComp) then
      self:AddControlEvent(uAvatarComp, "OnClothPlaneCutChanged", self.CheckAvatarDormant, self)
      self:AddControlEvent(uAvatarComp, "OnRegisterEntityTick", self.CheckAvatarDormant, self)
      self:AddControlEvent(uAvatarComp, "OnEnableEffectTickChanged", self.CheckAvatarDormant, self)
      self:AddControlEvent(uAvatarComp, "OnAvatarDataDirtyChanged", self.CheckAvatarDormant, self)
    end
    local uPlayEmoteComp = self.OwnerCharacter:GetPlayEmoteComponent()
    if slua.isValid(uPlayEmoteComp) then
      self:AddControlEvent(uPlayEmoteComp, "OnLoadAndStartPlayEmoteAnimEvent", self.CheckEmoteDormant, self)
      self:AddControlEvent(uPlayEmoteComp, "EmoteMontageFinishedEvent", self.CheckEmoteDormant, self)
    end
  end
  if slua.isValid(self.OwnerCharacter.PetComponent_BP) then
    self:AddControlEvent(self.OwnerCharacter.PetComponent_BP, "OnRepPetPawnCalled", self.HandlenRepPetPawn, self)
  end
  self:AddControlEvent(self.OwnerCharacter, "OnPostRepAttachment", self.HandleOnPostRepAttachment, self)
  self:AddControlEvent(self.OwnerCharacter, "OnParachuteStateChanged", self.HandlOnParachuteStateChanged, self)
  self:AddControlEvent(self.OwnerCharacter, "OnRepParachuteStateDelegate", self.HandlOnRepParachuteStateDelegate, self)
  if slua.isValid(self.OwnerCharacter.BP_SwimController) then
    self:AddControlEvent(self.OwnerCharacter.BP_SwimController, "OnPlayerTouchWater", self.HandleOnPlayerTouchWater, self)
    local uPlayerController = self.OwnerCharacter:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      self:AddControlEvent(uPlayerController, "OnPlayerEnterWater", self.HandleOnPlayerTouchWater, self, true)
    end
  end
  self:CheckInitAwakeComponents()
  self:AddGameTimer(5, false, function()
    local bInParachuate = self.OwnerCharacter.ParachuteState ~= EParachuteState.PS_None
    self:DormantParachuteComponents(not bInParachuate)
  end)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  GameplayData.AddSelfPlayerControllerEvent(self, "OnSetViewTarget", self.HandleOnSetViewTarget, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnSwitchCameraModeStart", self.HandleOnSwitchCameraModeStart, self)
  print(bWriteLog and string.format("DynamicOptimizeCharacterComponents AddSelfPlayerControllerEvent OnSetViewTarget PlayerName:%s Role:%d, DynamicOp:%s", self.OwnerCharacter:GetPlayerNameSafety(), self.OwnerCharacter.Role, self.Object))
end
function DynamicOptimizeCharacterComponents:HandleOnControllerBeginPlayFinish()
  if not GameStatus.IsInMainCity() then
    print(bWriteLog and "[Warning]IsInMainCity=true, DynamicOptimizeCharacterComponents HandleOnControllerBeginPlayFinish return!")
    return
  end
  if self.GetOwner then
    local OwnerCharacter = self:GetOwner()
    if slua.isValid(OwnerCharacter) then
      print(bWriteLog and string.format("DynamicOptimizeCharacterComponents HandleOnControllerBeginPlayFinish PlayerName:%s Role:%d, DynamicOp:%s", OwnerCharacter:GetPlayerNameSafety(), OwnerCharacter.Role, self.Object))
      print(bWriteLog and string.format("DynamicOptimizeCharacterComponents:HandleOnControllerBeginPlayFinish CurDynamicOpComp:%s, PlayerName:%s Role:%d", self.Object, OwnerCharacter:GetPlayerNameSafety(), OwnerCharacter.Role))
    end
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  GameplayData.AddSelfPlayerControllerEvent(self, "OnSetViewTarget", self.HandleOnSetViewTarget, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnSwitchCameraModeStart", self.HandleOnSwitchCameraModeStart, self)
  print(bWriteLog and "DynamicOptimizeCharacterComponents:HandleOnControllerBeginPlayFinish End AddSelfPlayerControllerEvent Done!")
end
function DynamicOptimizeCharacterComponents:DormantOtherCharacterComponents()
  if not slua.isValid(self.OwnerCharacter) then
    return
  end
  self:DormantComponentFull(self.OwnerCharacter.CustomSpringArm, "")
  self:DormantComponentFull(self.OwnerCharacter.FPPSpringArm, "")
  self:DormantComponentFull(self.OwnerCharacter.ScopingSpringArm, "")
  self.SoundDormant = true
  self:DormantComponentFull(self.OwnerCharacter.AmbientSoundComp, "")
end
function DynamicOptimizeCharacterComponents:AwakeOtherCharacterComponents()
  if self.SoundDormant then
    self:DormantComponentFull(self.OwnerCharacter.AmbientSoundComp, "")
    self.SoundDormant = false
  end
end
function DynamicOptimizeCharacterComponents:CheckInitAwakeComponents()
  if self.OwnerCharacter:HasState(EPawnState.DetectPaintDecal) then
    if self:IsFullDormant(self.OwnerCharacter.BP_PaintDecalDetectLine1) then
      self:AwakeComponentFull(self.OwnerCharacter.BP_PaintDecalDetectLine1, "")
    end
  else
    self:DormantComponentFull(self.OwnerCharacter.BP_PaintDecalDetectLine1, "")
  end
  self:CheckPetDormant()
  self:CheckAvatarDormant()
  self:CheckEmoteDormant()
  if Client and self:IsClientViewCharacter() then
    local uPlayerController = self.OwnerCharacter:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      self:CameraChangeDormantComponents(uPlayerController.CurCameraMode)
    end
  else
    self:DormantOtherCharacterComponents()
  end
  local bOnVehicle = self.OwnerCharacter:HasState(EPawnState.DriveVehicle) or self.OwnerCharacter:HasState(EPawnState.InVehicle)
  self:DormantVehicleComponents(bOnVehicle)
  local bInParachuate = self.OwnerCharacter.ParachuteState ~= EParachuteState.PS_None
  self:DormantParachuteComponents(not bInParachuate)
  if slua.isValid(self.OwnerCharacter.STCharacterMovement) then
    local bSwim = self.OwnerCharacter.STCharacterMovement.MovementMode == EMovementMode.MOVE_Swimming or self.OwnerCharacter:HasState(EPawnState.Swim)
    self:HandleOnPlayerTouchWater(bSwim)
  end
  if slua.isValid(self.OwnerCharacter.NearDeatchComponent) then
    local bNearDeatchTick = self.OwnerCharacter.HealthStatus == ECharacterHealthStatus.HasLastBreath
    self:SetComponentTickEnableSafety(self.OwnerCharacter.NearDeatchComponent, bNearDeatchTick)
    self:AddControlEvent(self.OwnerCharacter, "OnHealthStatusChangeDelegate", self.HandleOnHealthStatusChangeDelegate, self)
  end
  if slua.isValid(self.OwnerCharacter.NewEffectComponent) then
    local bEffectTick = self.OwnerCharacter.NewEffectComponent:GetGraphsNum() > 0
    self:SetComponentTickEnableSafety(self.OwnerCharacter.NewEffectComponent, bEffectTick)
    self:AddControlEvent(self.OwnerCharacter.NewEffectComponent, "EffectGraphChangeDelegate", self.HandleEffectGraphChangeDelegate, self)
  end
  local bPlayEmote = self.OwnerCharacter:HasState(EPawnState.PlayEmote)
  print(bWriteLog and string.format("DynamicOptimizeCharacterComponents CheckInitAwakeComponents bPlayEmote:%s", tostring(bPlayEmote)))
  self:DormantPlayEmoteComponents(not bPlayEmote)
end
function DynamicOptimizeCharacterComponents:CheckPetDormant()
  if slua.isValid(self.OwnerCharacter.PetComponent_BP) then
    if slua.isValid(self.OwnerCharacter.PetComponent_BP.PetPawn) then
      self:AwakeComponentTick(self.OwnerCharacter.PetComponent_BP, "")
      if self.OwnerCharacter.PetParachuteSpline then
        if self.OwnerCharacter:HasState(EPawnState.InParachute) then
          self:AwakeComponentFull(self.OwnerCharacter.PetParachuteSpline, "")
        else
          self:DormantComponentFull(self.OwnerCharacter.PetParachuteSpline, "")
        end
      end
    else
      self:DormantComponentTick(self.OwnerCharacter.PetComponent_BP, "")
      self:DormantComponentFull(self.OwnerCharacter.PetParachuteSpline, "")
    end
  end
end
function DynamicOptimizeCharacterComponents:CheckAvatarDormant()
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local uAvatarComp = self.OwnerCharacter:getAvatarComponent2()
  local bIsStandAlone = UKismetSystemLibrary.IsStandalone(self)
  if slua.isValid(uAvatarComp) and not bIsStandAlone then
    local EClothCutStateType = import("EClothCutStateType")
    local bNeedTick = uAvatarComp.bNeedUpdateLightMat or uAvatarComp.ClothPlaneCutState ~= EClothCutStateType.EClothCutStateType_NotCut or uAvatarComp.EntityTickList:Num() > 0 or uAvatarComp.EnableEffectTick or uAvatarComp.bAvatarDataDirty
    bNeedTick = bNeedTick or uAvatarComp:IsLobbyActor() or self.OwnerCharacter.bOpenAvatarTick
    if bNeedTick then
      self:AwakeComponentTick(uAvatarComp, "")
    else
      self:DormantComponentTick(uAvatarComp, "")
    end
  end
end
function DynamicOptimizeCharacterComponents:CheckEmoteDormant()
  if self.OwnerCharacter and self.OwnerCharacter.HasState then
    local bPlayEmote = self.OwnerCharacter:HasState(EPawnState.PlayEmote)
    print(bWriteLog and string.format("DynamicOptimizeCharacterComponents CheckEmoteDormant bPlayEmote:%s", tostring(bPlayEmote)))
    self:DormantPlayEmoteComponents(not bPlayEmote)
  end
end
function DynamicOptimizeCharacterComponents:DormantParachuteComponents(bDormant)
  local uAvatarComp = self.OwnerCharacter:getAvatarComponent2()
  if slua.isValid(uAvatarComp) and self.tParachuteMeshSlots ~= nil then
    for i, v in ipairs(self.tParachuteMeshSlots) do
      local uParachuteMesh = uAvatarComp:GetMeshCompBySlot(v)
      local bReallyDormant = bDormant
      if self.CurrentParachuteState ~= EParachuteState.PS_FreeFall and v == EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot then
        bReallyDormant = true
      end
      if v == EAvatarSlotType.EAvatarSlotType_ParachuteEquipemtSlot and self.CurrentParachuteState == EParachuteState.PS_FreeFall and uAvatarComp:NeedHideParachuteEquipemtInFreeState() then
        bReallyDormant = true
      end
      if slua.isValid(uParachuteMesh) then
        if bReallyDormant then
          self:DormantComponentFull(uParachuteMesh, "")
        else
          self:AwakeComponentFull(uParachuteMesh, "")
          uParachuteMesh:SetVisibility(true, false)
        end
      end
    end
  end
  self:CheckPetDormant()
end
function DynamicOptimizeCharacterComponents:CameraChangeDormantComponents(CameraMode)
  if self.OwnerCharacter == nil or not slua.isValid(self.OwnerCharacter) then
    return
  end
  if CameraMode then
  end
  if CameraMode == EPlayerCameraMode.PCM_Normal or CameraMode == EPlayerCameraMode.PCM_Plane then
    self.CurrentNoAim    self:DormantComponentFull(self.OwnerCharacter.FPPSpringArm, "")
    self:DormantComponentFull(self.OwnerCharacter.ScopingSpringArm, "")
    self:AwakeComponentFull(self.OwnerCharacter.CustomSpringArm, "")
    self:SetComponentActiveSafety(self.OwnerCharacter.FPPSpringArm, false)
    self:SetComponentActiveSafety(self.OwnerCharacter.ScopingSpringArm, false)
    self:SetComponentActiveSafety(self.OwnerCharacter.CustomSpringArm, true)
  elseif CameraMode == EPlayerCameraMode.PCM_FPP then
    self.CurrentNoAim    self:DormantComponentFull(self.OwnerCharacter.CustomSpringArm, "")
    self:DormantComponentFull(self.OwnerCharacter.ScopingSpringArm, "")
    self:AwakeComponentFull(self.OwnerCharacter.FPPSpringArm, "")
    self:SetComponentActiveSafety(self.OwnerCharacter.CustomSpringArm, false)
    self:SetComponentActiveSafety(self.OwnerCharacter.ScopingSpringArm, false)
    self:SetComponentActiveSafety(self.OwnerCharacter.FPPSpringArm, true)
  elseif CameraMode == EPlayerCameraMode.PCM_Aim then
    local uCurrentShootWeapon = self.OwnerCharacter:GetCurrentShootWeapon()
    if slua.isValid(uCurrentShootWeapon) then
      local ShootWeaponEntityComponent = uCurrentShootWeapon:GetShootWeaponEntityComponent()
      if slua.isValid(ShootWeaponEntityComponent) and ShootWeaponEntityComponent.ShowBulletTraceWhenScoped then
        return
      end
    end
    self:AwakeComponentFull(self.OwnerCharacter.FPPSpringArm, "")
    self:AwakeComponentFull(self.OwnerCharacter.CustomSpringArm, "")
    self:AwakeComponentFull(self.OwnerCharacter.ScopingSpringArm, "")
    self:SetComponentActiveSafety(self.OwnerCharacter.FPPSpringArm, true)
    self:SetComponentActiveSafety(self.OwnerCharacter.CustomSpringArm, true)
    self:SetComponentActiveSafety(self.OwnerCharacter.ScopingSpringArm, true)
  end
end
function DynamicOptimizeCharacterComponents:DormantComponentFull(uDormantComp, Reason)
  if slua.isValid(uDormantComp) and self.DormantComponent then
    self:DormantComponent(uDormantComp, EComponentDormantType.DormantFull, Reason)
  end
end
function DynamicOptimizeCharacterComponents:AwakeComponentFull(uAwakeComp, Reason)
  if slua.isValid(uAwakeComp) and self.AwakeComponent then
    self:AwakeComponent(uAwakeComp, EComponentDormantType.DormantFull, Reason, true)
  end
end
function DynamicOptimizeCharacterComponents:DormantComponentTick(uDormantComp, Reason)
  if slua.isValid(uDormantComp) and self.DormantComponent then
    self:DormantComponent(uDormantComp, EComponentDormantType.DormantTick, Reason)
  end
end
function DynamicOptimizeCharacterComponents:AwakeComponentTick(uAwakeComp, Reason)
  if slua.isValid(uAwakeComp) and self.AwakeComponent then
    self:AwakeComponent(uAwakeComp, EComponentDormantType.DormantTick, Reason, true)
  end
end
function DynamicOptimizeCharacterComponents:IsDormant(uAwakeComp)
  if self:IsFullDormant(uAwakeComp) then
    return true
  end
  if self:IsTickDormant(uAwakeComp) then
    return true
  end
  return false
end
function DynamicOptimizeCharacterComponents:IsFullDormant(uAwakeComp)
  if slua.isValid(uAwakeComp) and self.IsComponentDormant then
    return self:IsComponentDormant(uAwakeComp, EComponentDormantType.DormantFull)
  end
  return false
end
function DynamicOptimizeCharacterComponents:IsTickDormant(uAwakeComp)
  if slua.isValid(uAwakeComp) and self.IsComponentDormant then
    return self:IsComponentDormant(uAwakeComp, EComponentDormantType.DormantTick)
  end
  return false
end
function DynamicOptimizeCharacterComponents:SetComponentTickEnableSafety(uComp, bTick)
  if slua.isValid(uComp) then
    self:SetComponentTickDirectly(uComp, bTick)
  end
end
function DynamicOptimizeCharacterComponents:SetComponentActiveSafety(uComp, bActive)
  if slua.isValid(uComp) then
    uComp:SetActive(bActive, false)
  end
end
function DynamicOptimizeCharacterComponents:HandlePerspectiveChangedEvent(bIsFPP)
  if not self:IsClientViewCharacter() then
    return
  end
  self:AwakeOtherCharacterComponents()
  local uSwitchCameraMode = EPlayerCameraMode.PCM_Normal
  if bIsFPP then
    uSwitchCameraMode = EPlayerCameraMode.PCM_FPP
  end
  local uPlayerController = GameplayStatics.GetPlayerController(self.Object, 0)
  if slua.isValid(uPlayerController) then
    local uTarget = uPlayerController:GetViewTarget()
    if slua.isValid(uTarget) and uTarget == self.OwnerCharacter then
      uSwitchCameraMode = uPlayerController.CurCameraMode
      if slua.isValid(uTarget.DynamicOptimizeCharacterComps) then
        uTarget.DynamicOptimizeCharacterComps:CameraChangeDormantComponents(uSwitchCameraMode)
      end
    end
  end
end
function DynamicOptimizeCharacterComponents:HandleScopeInDelegate()
  if self:IsClientViewCharacter() then
    self:CameraChangeDormantComponents(EPlayerCameraMode.PCM_Aim)
  end
end
function DynamicOptimizeCharacterComponents:HandleScopeOutDelegate()
  if self:IsClientViewCharacter() then
    self:CameraChangeDormantComponents(self.CurrentNoAimCameraMode)
  end
end
function DynamicOptimizeCharacterComponents:HandleCharacterCommonEvent(strMsg)
  if strMsg == "VehShoulderEnable" then
    self:AwakeComponentFull(self.OwnerCharacter.ShoulderCameraSpringArm, "")
    self:SetComponentTickEnableSafety(self.OwnerCharacter.ShoulderCameraSpringArm, true)
  elseif strMsg == "VehShoulderDisable" then
    self:DormantComponentFull(self.OwnerCharacter.ShoulderCameraSpringArm, "")
    self:SetComponentTickEnableSafety(self.OwnerCharacter.ShoulderCameraSpringArm, false)
  elseif strMsg == "StartPaint" then
    self:AwakeComponentFull(self.OwnerCharacter.BP_PaintDecalDetectLine1, "")
  elseif strMsg == "ClosePaint" then
    self:DormantComponentFull(self.OwnerCharacter.BP_PaintDecalDetectLine1, "")
  end
end
function DynamicOptimizeCharacterComponents:HandlenRepPetPawn(uPetPawn)
  self:CheckPetDormant()
end
function DynamicOptimizeCharacterComponents:HandleOnPostRepAttachment(uAttachParentActor, ...)
  local bOnVehicle = Game:IsClassOf(uAttachParentActor, import("STExtraVehicleBase"))
  self:DormantVehicleComponents(bOnVehicle)
end
function DynamicOptimizeCharacterComponents:DormantVehicleComponents(bOnVehicle)
  local strVehicle = "Vehicle"
  if bOnVehicle then
    self:DormantComponentFull(self.OwnerCharacter.ProneCapsuleComponent, strVehicle)
    self:DormantComponentFull(self.OwnerCharacter.HitBox_Stand, strVehicle)
    self:DormantComponentFull(self.OwnerCharacter.HitBox_Prone, strVehicle)
    self:DormantComponentFull(self.OwnerCharacter.PetComponent_BP, strVehicle)
    self:DormantComponentFull(self.OwnerCharacter.PetParachuteSpline, strVehicle)
    self:DormantComponentFull(self.OwnerCharacter.BP_PaintDecalDetectLine1, strVehicle)
    local bDormantVehicleShoulder = true
    if slua.isValid(self.OwnerCharacter.CurrentVehicle) and slua.isValid(self.OwnerCharacter.SpringArmComp) and self.OwnerCharacter.SpringArmComp.bIsShoulderMode then
      bDormantVehicleShoulder = false
    end
    if bDormantVehicleShoulder then
      self:DormantComponentFull(self.OwnerCharacter.ShoulderCameraSpringArm, strVehicle)
      self:SetComponentTickEnableSafety(self.OwnerCharacter.ShoulderCameraSpringArm, false)
    else
      self:AwakeComponentFull(self.OwnerCharacter.ShoulderCameraSpringArm, strVehicle)
      self:SetComponentTickEnableSafety(self.OwnerCharacter.ShoulderCameraSpringArm, true)
    end
  else
    self:AwakeComponentFull(self.OwnerCharacter.ProneCapsuleComponent, strVehicle)
    self:AwakeComponentFull(self.OwnerCharacter.HitBox_Stand, strVehicle)
    self:AwakeComponentFull(self.OwnerCharacter.HitBox_Prone, strVehicle)
    self:AwakeComponentFull(self.OwnerCharacter.PetComponent_BP, strVehicle)
    self:AwakeComponentFull(self.OwnerCharacter.PetParachuteSpline, strVehicle)
    self:AwakeComponentFull(self.OwnerCharacter.BP_PaintDecalDetectLine1, strVehicle)
    self:DormantComponentFull(self.OwnerCharacter.ShoulderCameraSpringArm, strVehicle)
    self:SetComponentTickEnableSafety(self.OwnerCharacter.ShoulderCameraSpringArm, false)
  end
end
function DynamicOptimizeCharacterComponents:HandlOnPawnRespawnDelegate()
end
function DynamicOptimizeCharacterComponents:HandlOnParachuteStateChanged(LastParachuteState, ParachuteState)
  if self.CurrentParachuteState == ParachuteState then
    return
  end
  self.Current  if ParachuteState == EParachuteState.PS_None then
    self:DormantParachuteComponents(true)
  elseif ParachuteState ~= EParachuteState.PS_None then
    self:DormantParachuteComponents(false)
  end
end
function DynamicOptimizeCharacterComponents:HandlOnRepParachuteStateDelegate()
  self:HandlOnParachuteStateChanged(self.OwnerCharacter.LastParachuteState, self.OwnerCharacter.ParachuteState)
end
function DynamicOptimizeCharacterComponents:HandleOnFakeOnVehicleDelegate()
  if self.CurrentParachuteState == EParachuteState.PS_FreeFall then
    log(bWriteLog and "DynamicOptimizeCharacterComponents:HandleOnFakeOnVehicleDelegate")
    self:DormantParachuteComponents(false)
  end
end
function DynamicOptimizeCharacterComponents:HandleOnPlayerTouchWater(bEnterWater)
end
function DynamicOptimizeCharacterComponents:HandleOnSetViewTarget(uNewTarget)
  local uPlayerController = GameplayStatics.GetPlayerController(self.Object, 0)
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and string.format("[Warning]DynamicOptimizeCharacterComponents HandleOnSetViewTarget uPlayerController=nil"))
    return
  end
  local uCurPawn = uPlayerController:GetCurPawn()
  if not slua.isValid(self.OwnerCharacter) then
    print(bWriteLog and string.format("[Warning]DynamicOptimizeCharacterComponents HandleOnSetViewTarget uCurPawn=nil"))
    return
  end
  print(bWriteLog and string.format("DynamicOptimizeCharacterComponents HandleOnSetViewTarget Begin PlayerName:%s Role:%d", self.OwnerCharacter:GetPlayerNameSafety(), self.OwnerCharacter.Role))
  if uPlayerController.bIsForReplay and slua.isValid(uNewTarget) and Game:IsPlayer(uNewTarget) and self.OwnerCharacter == uNewTarget then
    if uPlayerController.CurCameraMode == EPlayerCameraMode.PCM_None then
      uPlayerController.CurCameraMode = EPlayerCameraMode.PCM_Normal
      print(bWriteLog and "DynamicOptimizeCharacterComponents HandleOnSetViewTarget CurCameraMode from PCM_None to PCM_Normal")
    end
    if not slua.isValid(uCurPawn) then
      uPlayerController:SetSTExtraBaseCharacter(uNewTarget)
      print(bWriteLog and "DynamicOptimizeCharacterComponents HandleOnSetViewTarget uCurPawn invalid")
      EventSystem:postEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_REPLAY_SET_CHARACTER)
    end
    uCurPawn = uNewTarget
    print(bWriteLog and "DynamicOptimizeCharacterComponents HandleOnSetViewTarget uPlayerController uCurPawn set to uNewTarget")
  end
  if not slua.isValid(uCurPawn) or self.OwnerCharacter ~= uCurPawn then
    print(bWriteLog and string.format("[Warning]DynamicOptimizeCharacterComponents HandleOnSetViewTarget OwnerCharacter~=uCurPawn, PlayerName:%s Role:%d", self.OwnerCharacter:GetPlayerNameSafety(), self.OwnerCharacter.Role))
    print(bWriteLog and string.format("[Warning]DynamicOptimizeCharacterComponents HandleOnSetViewTarget OwnerCharacter:%s, uCurPawn:%s", self.OwnerCharacter, uCurPawn))
    return
  end
  if self.CurrentTarget == uNewTarget then
    print(bWriteLog and string.format("[warning]DynamicOptimizeCharacterComponents HandleOnSetViewTarget uNewTarget==self.CurrentTarget PlayerName:%s Role:%d", self.OwnerCharacter:GetPlayerNameSafety(), self.OwnerCharacter.Role))
    print(bWriteLog and string.format("[warning]DynamicOptimizeCharacterComponents HandleOnSetViewTarget uNewTarget:%s", uNewTarget))
    return
  end
  self.CurrentTarget = uNewTarget
  local uOldTarget = uPlayerController:GetViewTarget()
  local bSetViewTarget = false
  if slua.isValid(uOldTarget) and slua.isValid(uNewTarget) and uOldTarget ~= uNewTarget and uOldTarget.DynamicOptimizeCharacterComps and uNewTarget.DynamicOptimizeCharacterComps then
    print(bWriteLog and string.format("DynamicOptimizeCharacterComponents HandleOnSetViewTarget uOldTarget ~= uNewTarget PlayerName:%s Role:%d", self.OwnerCharacter:GetPlayerNameSafety(), self.OwnerCharacter.Role))
    uOldTarget.DynamicOptimizeCharacterComps:DormantOtherCharacterComponents()
    uNewTarget.DynamicOptimizeCharacterComps:AwakeOtherCharacterComponents()
    uNewTarget.DynamicOptimizeCharacterComps:CameraChangeDormantComponents(uPlayerController.CurCameraMode)
    bSetViewTarget = true
  end
  if not bSetViewTarget and slua.isValid(uNewTarget) and uNewTarget.DynamicOptimizeCharacterComps then
    print(bWriteLog and string.format("DynamicOptimizeCharacterComponents HandleOnSetViewTarget uNewTarget PlayerName:%s Role:%d", self.OwnerCharacter:GetPlayerNameSafety(), self.OwnerCharacter.Role))
    uNewTarget.DynamicOptimizeCharacterComps:AwakeOtherCharacterComponents()
    uNewTarget.DynamicOptimizeCharacterComps:CameraChangeDormantComponents(uPlayerController.CurCameraMode)
  end
  print(bWriteLog and string.format("DynamicOptimizeCharacterComponents HandleOnSetViewTarget End PlayerName:%s Role:%d", self.OwnerCharacter:GetPlayerNameSafety(), self.OwnerCharacter.Role))
end
function DynamicOptimizeCharacterComponents:IsClientViewCharacter()
  if not slua.isValid(self.OwnerCharacter) then
    return false
  end
  if self.OwnerCharacter:IsLocalControlOrView() then
    return true
  end
  if self.OwnerCharacter.Role == ENetRole.ROLE_Authority then
    return false
  end
  local uPlayerController = GameplayStatics.GetPlayerController(self.Object, 0)
  if not slua.isValid(uPlayerController) then
    return false
  end
  if uPlayerController.IsSpectator == nil or uPlayerController.IsDemoPlaySpectator == nil then
    return false
  end
  if uPlayerController:IsSpectator() or uPlayerController:IsDemoPlaySpectator() then
    local uCurPawn = uPlayerController:GetCurPawn()
    if slua.isValid(uCurPawn) and self.OwnerCharacter == uCurPawn then
      return true
    end
  end
  local EPawnState = import("EPawnState")
  local uViewTarget = uPlayerController:GetViewTarget()
  local uCarryBackComp = self.OwnerCharacter:GetCarryBackComp()
  if uCarryBackComp and uViewTarget == uCarryBackComp.CarryBackCharacter then
    return true
  end
  return false
end
function DynamicOptimizeCharacterComponents:HandleOnSwitchCameraModeStart(NewCameraMode)
  if self:IsClientViewCharacter() then
    printf("==>DynamicOptimizeCharacterComponents HandleOnSwitchCameraModeStart PlayerName:%s NewCameraMode:%d role:%d", self.OwnerCharacter:GetPlayerNameSafety(), NewCameraMode, self.OwnerCharacter.Role)
    self:CameraChangeDormantComponents(NewCameraMode)
    if self.EnableScopeOpt then
      log(bWriteLog and "HandleOnSwitchCameraModeStart For HLOD " .. tostring(NewCameraMode))
      local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
      local STExtraGameInstance = import("STExtraGameInstance")
      local GameInstance = STExtraGameInstance.GetInstance()
      local EPlayerCameraMode = import("EPlayerCameraMode")
      if NewCameraMode == EPlayerCameraMode.PCM_Aim then
        GameInstance:ExecuteCMD("r.HLOD.EnableScopeDistanceScale", 1)
        self.BackUpViewDistance = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("r.ViewDistanceScale")
        GameInstance:ExecuteCMD("r.ViewDistanceScale", 1.3)
        print(bWriteLog and "DynamicOptimizeCharacterComponents HandleOnSwitchCameraModeStart ViewDistancescale[%s])", self.BackUpViewDistance)
      else
        GameInstance:ExecuteCMD("r.HLOD.EnableScopeDistanceScale", 0)
        GameInstance:ExecuteCMD("r.ViewDistanceScale", self.BackUpViewDistance)
        print(bWriteLog and "DynamicOptimizeCharacterComponents HandleOnSwitchCameraModeStart Recover viewdistancescale[%s])", self.BackUpViewDistance)
      end
    end
  end
end
function DynamicOptimizeCharacterComponents:HandleOnHealthStatusChangeDelegate()
  if slua.isValid(self.OwnerCharacter) and slua.isValid(self.OwnerCharacter.NearDeatchComponent) then
    local bNearDeatchTick = self.OwnerCharacter.HealthStatus == ECharacterHealthStatus.HasLastBreath
    self:SetComponentTickEnableSafety(self.OwnerCharacter.NearDeatchComponent, bNearDeatchTick)
  end
end
function DynamicOptimizeCharacterComponents:HandleEffectGraphChangeDelegate(nEffectNum)
  self:SetComponentTickEnableSafety(self.OwnerCharacter.NewEffectComponent, 0 < nEffectNum)
end
function DynamicOptimizeCharacterComponents:DormantPlayEmoteComponents(bDormant)
  if not slua.isValid(self.OwnerCharacter) then
    return
  end
  print(bWriteLog and string.format("DynamicOptimizeCharacterComponents DormantPlayEmoteComponents bDormant:%s, PlayerName:%s", tostring(bDormant), self.OwnerCharacter:GetPlayerNameSafety()))
  local uPlayEmoteComp = self.OwnerCharacter:GetPlayEmoteComponent()
  if slua.isValid(uPlayEmoteComp) then
    if bDormant then
      self:DormantComponentFull(uPlayEmoteComp, "")
    else
      self:AwakeComponentFull(uPlayEmoteComp, "")
    end
  end
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CDynamicOptimizeCharacterComponent = class(CActorComponentBase, nil, DynamicOptimizeCharacterComponents)
return CDynamicOptimizeCharacterComponent