local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local HealTeammateSystem = {}
local EPawnState = import("EPawnState")
local SkillUtils = require("GameLua.GameCore.Module.Skill.SkillUtils")
local Util = require("client.slua_ui_framework.util")
local UAkGameplayStatics = import("AkGameplayStatics")
local GameplayStatics = import("GameplayStatics")
local SelectSoundPath = "/Game/Library/Res/Vehicles/Mecha/WwiseEvent/Mecha_Vehicle_Up/Play_Mecha_Vehicle_U_Hand_Aim.Play_Mecha_Vehicle_U_Hand_Aim"
local UKismetSystemLibrary = import("KismetSystemLibrary")
local ECollisionChannel = import("ECollisionChannel")
local BackpackUtils = import("BackpackUtils")
local FItemDefineID = import("/Script/Basic.ItemDefineID")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
function HealTeammateSystem:ctor()
  self.bCanShowOutline = true
  self.tMedicalItemID = {
    [601004] = 0.75,
    [601005] = 0.75,
    [601006] = 1.0
  }
end
function HealTeammateSystem:_PostConstruct()
end
function HealTeammateSystem:OnInit()
  if Client then
    self:AddCommonEvent(EVENTTYPE_INGAME_SKILL, EVENTID_INGAME_HEALTEAMMATE_ACTIVE, self.ClientHealTeammateActive, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_SKILL, EVENTID_INGAME_HEALTEAMMATE_UNACTIVE, self.ClientHealTeammateUnActive, self)
    self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ENTER_PROTECT, self.ReceiveBattleResults, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ENTER_SELFIE_MODE, self.OnEnterSelifeMode, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_EXIT_SELFIE_MODE, self.OnExitSelifeMode, self)
  end
end
function HealTeammateSystem:ReceiveBattleResults()
  printf(bWriteLog and "HealTeammateSystem:ReceiveBattleResults")
  self.bCanShowOutline = false
  self:RefreshTargetOutline(self.CachePickingTarget)
  self:StopTimerToCheckHealTeammate()
end
function HealTeammateSystem:OnEnterSelifeMode()
  self.bCanShowOutline = false
  self:RefreshTargetOutline(self.CachePickingTarget)
end
function HealTeammateSystem:OnExitSelifeMode()
  self.bCanShowOutline = true
end
function HealTeammateSystem:ClientHealTeammateActive(_, _, uCharacter, nSkillID)
  print(bWriteLog and string.format("HealTeammateSystem:ClientHandleUltraHandActive %d", nSkillID))
  if self:IsAutonomousProxy(uCharacter) then
    self:StartTimerCheckHealTeammate(uCharacter, nSkillID)
  end
end
function HealTeammateSystem:ClientHealTeammateUnActive(_, _, uCharacter, nSkillID)
  print(bWriteLog and string.format("HealTeammateSystem:ClientHandleUltraHandUnActive %d", nSkillID))
  if self:IsAutonomousProxy(uCharacter) then
    self:StopTimerToCheckHealTeammate()
    self:RefreshTargetOutline(nil)
  end
end
function HealTeammateSystem:IsAutonomousProxy(uCharacter)
  if slua.isValid(uCharacter) then
    if uCharacter.Role == 2 then
      return true
    end
    local uCurVehicle = uCharacter.CurrentVehicle
    if slua.isValid(uCurVehicle) and uCurVehicle.Role == 2 then
      return true
    end
    local uPC = uCharacter:GetPlayerControllerSafety()
    if slua.isValid(uPC) and not uPC:IsPureSpectator() and not uPC:IsDemoPlayGlobalObserver() and not uPC:IsDemoPlaySpectator() then
      return true
    end
    return false
  end
end
function HealTeammateSystem:StartTimerCheckHealTeammate(uCharacter, nSkillID)
  self:StopTimerToCheckHealTeammate()
  self.CurCharacter = uCharacter
  self.CurSkillID = nSkillID
  self.CheckHealTeammateTimer = self:AddGameTimer(0.2, true, function()
    if self.bCanShowOutline then
      local bStatusOK, bHealthOK = self:CheckShowHealTeammate()
      if bStatusOK then
        self:RefreshTargetOutline(self.CachePickingTarget)
      else
        self:RefreshTargetOutline(nil)
      end
    else
      self:RefreshTargetOutline(nil)
    end
  end)
  print(bWriteLog and string.format("HealTeammateSystem:StartTimerToCheckHealTeammate"))
end
function HealTeammateSystem:StopTimerToCheckHealTeammate()
  if self.CheckHealTeammateTimer then
    self:RemoveGameTimer(self.CheckHealTeammateTimer)
    self.CheckHealTeammateTimer = nil
    print(bWriteLog and string.format("HealTeammateSystem:StopTimerToCheckHealTeammate"))
  end
end
function HealTeammateSystem:CheckShowHealTeammate()
  local bStatusOK = false
  local bHealthOK = false
  if not slua.isValid(self.CurCharacter) then
    return bStatusOK, bHealthOK
  end
  local uSkillMgrComp = self.CurCharacter:GetSkillManager()
  if not slua.isValid(uSkillMgrComp) then
    return bStatusOK, bHealthOK
  end
  if self.CurCharacter:HasState(EPawnState.InVehicle) or self.CurCharacter:HasState(EPawnState.DriveVehicle) then
    return bStatusOK, bHealthOK
  end
  if self.CurCharacter:HasState(EPawnState.Dying) then
    return bStatusOK, bHealthOK
  end
  self.CachePickingTarget = self:GetCrossHairTargetObject()
  if slua.isValid(self.CachePickingTarget) and Game:IsClassOf(self.CachePickingTarget, import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")) then
    bStatusOK, bHealthOK = self:IsTargetStatusOK(self.CachePickingTarget)
  end
  return bStatusOK, bHealthOK
end
function HealTeammateSystem:GetCrossHairTargetObject()
  local OwnerPawn = self.CurCharacter
  if not slua.isValid(OwnerPawn) then
    return nil
  end
  local uPC = OwnerPawn:GetPlayerControllerSafety()
  if not slua.isValid(uPC) then
    return nil
  end
  local StartLocation = FVector.ZeroVector
  if uPC.PlayerCameraManager then
    StartLocation = uPC.PlayerCameraManager:GetCameraLocation()
  end
  local MaxResYawAngle = 60
  local MaxDistanceLimit = 245
  local CapsuleHeight = 200
  local FinalTraceDistance = 1000
  local Radius = 60
  local Rotation = OwnerPawn:GetControlRotation()
  local KismetMathLibrary = import("KismetMathLibrary")
  local Dir = KismetMathLibrary.CreateVectorFromYawPitch(Rotation.Yaw, Rotation.Pitch, 1)
  local EndLocation = StartLocation + Dir * FinalTraceDistance
  StartLocation = StartLocation + Dir * CapsuleHeight
  local bHit, OutHit = UKismetSystemLibrary.LineTraceSingleForObjects(OwnerPawn, StartLocation, EndLocation, {
    Game:ConvertToObjectType(ECollisionChannel.ECC_Pawn)
  }, true, nil, 0, nil, true, FLinearColor.Green, FLinearColor.Red, 0)
  if OutHit == nil or not OutHit.bBlockingHit then
    bHit, OutHit = UKismetSystemLibrary.CapsuleTraceSingleForObjects(OwnerPawn, StartLocation, EndLocation, Radius, CapsuleHeight / 2, {
      Game:ConvertToObjectType(ECollisionChannel.ECC_Pawn)
    }, true, nil, 0, nil, true, FLinearColor.Red, FLinearColor.Green, 0)
  end
  if OutHit.bBlockingHit then
    local uHitActor = OutHit.Actor
    local HitActorLoc = uHitActor:K2_GetActorLocation()
    local Distance = FVector.Distance(HitActorLoc, OwnerPawn:K2_GetActorLocation())
    if MaxDistanceLimit < Distance then
      return nil
    end
    local RelativeDir = HitActorLoc - OwnerPawn:K2_GetActorLocation()
    local ActorRotation = OwnerPawn:K2_GetActorRotation()
    local ForwardVec = KismetMathLibrary.CreateVectorFromYawPitch(ActorRotation.Yaw, ActorRotation.Pitch, 1)
    RelativeDir:Normalize(0)
    ForwardVec:Normalize(0)
    local DotValue = FVector.DotProduct(RelativeDir, ForwardVec)
    local Degrees = math.deg(math.acos(DotValue))
    if MaxResYawAngle < Degrees then
      return nil
    end
    return uHitActor
  end
end
function HealTeammateSystem:IsTargetStatusOK(uTarget)
  local bStatusOK = false
  local bHealthOK = false
  if not slua.isValid(self.CurCharacter) or not slua.isValid(uTarget) then
    return bStatusOK, bHealthOK
  end
  local uPlayerState = self.CurCharacter:GetPlayerStateSafety()
  if slua.isValid(uPlayerState) and not uPlayerState:IsTeammate(uTarget.PlayerKey) then
    return bStatusOK, bHealthOK
  end
  if uTarget:HasState(EPawnState.Dying) then
    return bStatusOK, bHealthOK
  end
  bStatusOK = true
  local uSkillMgrComp = self.CurCharacter:GetSkillManager()
  if not slua.isValid(uSkillMgrComp) then
    return bStatusOK, bHealthOK
  end
  local MedicalItemID = 0
  local MedsPanel = UIManager.GetUI(UIManager.UI_Config_InGame.MedicineChooseWidgetNew)
  if MedsPanel and MedsPanel.MySubsystem.CurrentSelectedConsumableBattleItem then
    MedicalItemID = MedsPanel.MySubsystem.CurrentSelectedConsumableBattleItem.DefineID.TypeSpecificID
  end
  local HealthPercentLimit = self.tMedicalItemID[MedicalItemID]
  if HealthPercentLimit == nil then
    return bStatusOK, bHealthOK
  end
  local uBackpackComp = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(self.CurCharacter)
  if not slua.isValid(uBackpackComp) then
    return bStatusOK, bHealthOK
  end
  local ItemDefineID = FItemDefineID(6, MedicalItemID)
  local nCount = BackpackUtils.GetItemCountByDefineID(uBackpackComp, ItemDefineID, false)
  if nCount < 1 then
    return bStatusOK, bHealthOK
  end
  local CurHealthPercent = uTarget.Health / uTarget.HealthMax
  if HealthPercentLimit <= CurHealthPercent then
    return bStatusOK, bHealthOK
  end
  bHealthOK = true
  return bStatusOK, bHealthOK
end
function HealTeammateSystem:RefreshTargetOutline(uTargetCharacter)
  local bCanShow = self.bCanShowOutline and slua.isValid(uTargetCharacter)
  local bCanShowPawn = self.LastCanShow ~= bCanShow
  self.LastCanShow = bCanShow
  local bSameHealth = false
  if slua.isValid(uTargetCharacter) and Game:IsClassOf(uTargetCharacter, import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")) then
    if self.LastHealth ~= nil then
      bSameHealth = math.abs(uTargetCharacter.Health - self.LastHealth) <= 1.0E-5
    end
    self.LastHealth = uTargetCharacter.Health
  end
  if not bCanShowPawn and bSameHealth then
    return
  end
  if slua.isValid(self.CacheOutLineActor) then
    SkillUtils.ShowActorOutline(self.CacheOutLineActor, false, FLinearColor(1, 1, 1, 1), 0.5, false)
  end
  self.CacheOutLineActor = uTargetCharacter
  if bCanShow then
    SkillUtils.ShowActorOutline(uTargetCharacter, true, FLinearColor(1, 1, 1, 1), 0.5, true)
    self:PlaySelectSound()
    self:ShowTeammateHealthUI(uTargetCharacter, true)
    print(bWriteLog and string.format("HealTeammateSystem:ShowTargetOutline target=%s->%s", tostring(slua.isValid(self.CacheOutLineActor) and self.CacheOutLineActor), tostring(uTargetCharacter)))
  else
    self:ShowTeammateHealthUI(nil, false)
    print(bWriteLog and string.format("HealTeammateSystem:ShowTargetOutline target=%s-> nil", tostring(slua.isValid(self.CacheOutLineActor) and self.CacheOutLineActor)))
  end
end
function HealTeammateSystem:ShowTeammateHealthUI(uTarget, bShow)
  if bShow and slua.isValid(uTarget) then
    UIManager.ShowUI(UIManager.UI_Config_InGame.HealTeammateUI)
    local UIPanel = UIManager.GetUI(UIManager.UI_Config_InGame.HealTeammateUI)
    if UIPanel then
      local Percent = uTarget.Health / uTarget.HealthMax
      UIPanel:RefreshTeammateHealth(Percent)
    end
  else
    UIManager.HideUI(UIManager.UI_Config_InGame.HealTeammateUI)
  end
end
function HealTeammateSystem:PlaySelectSound()
end
local class = require("class")
local CSubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(CSubsystemBase, nil, HealTeammateSystem)