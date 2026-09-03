local EPawnState = import("EPawnState")
local ESTEPoseState = import("ESTEPoseState")
local EPlayerCameraMode = import("EPlayerCameraMode")
local ESTEScopeType = import("ESTEScopeType")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GameComponentData = require("GameLua.GameCore.Data.GameComponentData")
local uSTExtraUIUtils = import("STExtraUIUtils")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local UBowAccumulateEnergyState = import("BowAccumulateEnergyState")
local EUAESkillEvent = import("EUAESkillEvent")
local ThrowComponent = import("Script/ShadowTrackerExtra.ThrowComponent")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local OperateSubsystem = {}
function OperateSubsystem:OnInit()
  print(bWriteLog and "OperateSubsystem:OnInit")
  self:RegistEvents()
end
function OperateSubsystem:OnRelease()
  print(bWriteLog and "OperateSubsystem:OnRelease")
  OperateSubsystem.__super.OnRelease(self)
end
function OperateSubsystem:RegistEvents()
  self:InitFovValue()
  self:RegistEvents_JumpVault()
end
function OperateSubsystem:InitFovValue()
  print(bWriteLog and "OperateSubsystem:InitFovValue 0")
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  print(bWriteLog and "OperateSubsystem:InitFovValue 1")
  local Crt_FpViewValue = SettingModule:GetOptionValue("FpViewValue")
  local Crt_TpViewValue = SettingModule:GetOptionValue("TpViewValue")
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "CharacterDataReady", function()
    self:CustomEventChangeFOV(Crt_FpViewValue)
    self:CustomEventChangeTPPFOV(Crt_TpViewValue)
  end)
  self:AddSettingOptionEvent("FpViewValue", function(FpViewValue)
    self:CustomEventChangeFOV(FpViewValue)
  end)
  self:AddSettingOptionEvent("TpViewValue", function(TpViewValue)
    self:CustomEventChangeTPPFOV(TpViewValue)
  end)
end
function OperateSubsystem:CustomEventChangeFOV(FpViewValue)
  print(bWriteLog and "OperateSubsystem CustomEventChangeFOV " .. FpViewValue)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    local CameraComponent = PlayerCharacter:GetFPPCamera()
    if slua.isValid(CameraComponent) then
      FpViewValue = FuncUtil.Clamp(FpViewValue, 80, 103)
      CameraComponent:SetFieldOfView(FpViewValue)
      print(bWriteLog and "OperateSubsystem CustomEventChangeFOV Success1")
    end
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.CurCameraMode == EPlayerCameraMode.PCM_FPP then
    local GameInstance = slua_GameFrontendHUD:GetGameInstance()
    if slua.isValid(GameInstance) then
      GameInstance:SetFOVScreenSizeCullingFactor(FpViewValue)
    end
  end
end
function OperateSubsystem:CustomEventChangeTPPFOV(TpViewValue)
  print(bWriteLog and "OperateSubsystem:HandleViewValueChanged CustomEventChangeTPPFOV " .. TpViewValue)
  if 90 < TpViewValue or TpViewValue < 80 then
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerCharacter) and slua.isValid(PlayerController) then
    PlayerCharacter:SetTpCameraFov(TpViewValue)
    PlayerCharacter:SetFovInTPPSpringArm(TpViewValue)
    if PlayerController.NormalCameraModeData then
      PlayerController.NormalCameraModeData.SwitchCameraData.CameraFOV = TpViewValue
    end
    print(bWriteLog and "OperateSubsystem:HandleViewValueChanged CustomEventChangeTPPFOV Success")
  end
end
function OperateSubsystem:ChangeSightZoom(Value)
  local ScopeZoomUIBP = UIManager.GetUI(UIManager.UI_Config_InGame.ScopeZoomUIBP)
  if ScopeZoomUIBP then
    local CurrentValue = ScopeZoomUIBP.UIRoot.Slider_X8Zoom:GetValue()
    ScopeZoomUIBP:ChangeSightZoom(CurrentValue - Value)
  end
end
function OperateSubsystem:PressedAim()
  if self:CheckSpecialAimPressed() then
    return
  end
  self:OnAimBtnPressDown(0, nil, false)
end
function OperateSubsystem:ReleasedAim()
  if self:CheckSpecialAimReleased() then
    return
  end
  self:OnAimBtnHoldEnded(self.KeyboardAimPointerIndex)
end
function OperateSubsystem:DoOpenShotAnim(PointerIndex, ScopeIn, IgnoreAngledSight, uPlayerController, bIsTouchBegin)
  if not self:IsWeaponEntityEnableScopeIn() then
    local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
    IngameTipsTools.BattleNormalTipsByTextID(733001)
    return
  end
  if not slua.isValid(uPlayerController) then
    return
  end
  local uPlayerPawn = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayerPawn) then
    return
  end
  local WeaponManager = uPlayerPawn:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    return
  end
  local CurrentUsingWeapon = WeaponManager:GetCurrentUsingWeapon()
  if slua.isValid(uPlayerPawn.FPPComponent) and slua.isValid(CurrentUsingWeapon) and slua.isValid(CurrentUsingWeapon.WeaponAvatarComponent) then
    local AimMesh = CurrentUsingWeapon:GetScopeAimCameraTransform(uPlayerPawn.FPPComponent.ScopeAimCameraSocketName, 0, false)
    if slua.isValid(AimMesh) and not AimMesh:DoesSocketExist(uPlayerPawn.FPPComponent.ScopeAimCameraSocketName) then
      CurrentUsingWeapon.WeaponAvatarComponent:ReloadAllEquippedAvatar(false)
    end
  end
  local uMoveComponent = uPlayerPawn:GetMovementComponent()
  local Velocity = slua.isValid(uMoveComponent) and uMoveComponent.Velocity or FVector(0, 0, 0)
  if ScopeIn and 0 < Velocity:SizeSquared() and uPlayerPawn:HasState(EPawnState.Prone) and (not uPlayerController.bAutoSprint or 0 < uPlayerController.AutoSprintCD) then
    return
  end
  if IgnoreAngledSight then
    if ScopeIn then
      uPlayerPawn:ScopeIn(ESTEScopeType.Normal)
    else
      uPlayerPawn:ScopeOut(ESTEScopeType.Normal)
    end
  else
    uPlayerPawn:DoNormalSight(ScopeIn)
  end
  uPlayerController:DoubleClickCancel(PointerIndex)
  if not uPlayerPawn.bIsGunADS then
    return
  end
  local ShootAimBtnUI = UIManager.GetUI(UIManager.UI_Config_InGame.ShootAimBtnUI)
  if ShootAimBtnUI then
    ShootAimBtnUI:OnScopeStateChanged(uPlayerController.AimMode, bIsTouchBegin, PointerIndex)
  end
  self.KeyboardAimPointerIndex = bIsTouchBegin and PointerIndex or nil
  if not uPlayerPawn:HasState(EPawnState.LeanOutVehicle) then
    local uVehicleUserComp = uPlayerController:GetVehicleUserComp()
    if slua.isValid(uVehicleUserComp) then
      uVehicleUserComp:TryLeanOutorIn(false, false)
    end
  end
  uPlayerController:SetTouchFingerIndex(bIsTouchBegin, PointerIndex)
end
function OperateSubsystem:IsWeaponEntityEnableScopeIn()
  print(bWriteLog and "OperateSubsystem:IsWeaponEntityEnableScopeIn")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "OperateSubsystem:IsWeaponEntityEnableScopeIn - PlayerCharacter invalid")
    return true
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "OperateSubsystem:IsWeaponEntityEnableScopeIn - WeaponManager invalid")
    return true
  end
  local CurrentUsingWeapon = WeaponManager:GetCurrentUsingWeapon()
  if not slua.isValid(CurrentUsingWeapon) or not slua.isValid(CurrentUsingWeapon.WeaponEntityComp) then
    return true
  end
  return CurrentUsingWeapon.WeaponEntityComp.bEnableScopeIn
end
function OperateSubsystem:OnAimBtnPressDown(PointerIndex, MouseEvent, RotateViewWithSniperSwitch)
  print(bWriteLog and "OperateSubsystem:OnAimBtnPressDown")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local VehicleUserComp = PlayerController:GetVehicleUserComp()
  if not slua.isValid(VehicleUserComp) then
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if not slua.isValid(PlayerCharacter) then
      return
    end
    local bIgnoreAngledSight = not PlayerCharacter:HaveAngledSight()
    local bIsGunADS = not PlayerCharacter.bIsGunADS
    self:DoOpenShotAnim(PointerIndex, bIsGunADS, bIgnoreAngledSight, PlayerController, true)
    if not RotateViewWithSniperSwitch then
      PlayerController:AddIgnoreCameraMoveIndex(PointerIndex)
    end
    return
  end
  local bIsInVehicle = false
  local VehicleAndCharacterValid = slua.isValid(VehicleUserComp.Character) and slua.isValid(VehicleUserComp.Vehicle)
  if VehicleAndCharacterValid then
    if VehicleUserComp:CheckCanLeanOutVehicle() then
      bIsInVehicle = true
    elseif self:IsWeaponEntityEnableScopeIn() then
      VehicleUserComp:TryChangeFreeFireSeatandScopeIn()
      return
    end
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local bIgnoreAngledSight = not PlayerCharacter:HaveAngledSight()
  local bIsGunADS = not PlayerCharacter.bIsGunADS
  self:DoOpenShotAnim(PointerIndex, bIsGunADS, bIgnoreAngledSight, PlayerController, true)
  if not RotateViewWithSniperSwitch then
    PlayerController:AddIgnoreCameraMoveIndex(PointerIndex)
  end
end
function OperateSubsystem:OnAimBtnHoldEnded(ShotAimPointerIndex)
  print(bWriteLog and "OperateSubsystem:OnAimBtnHoldEnded")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) or ShotAimPointerIndex == nil then
    return
  end
  local uPlayerPawn = uPlayerController:GetPlayerCharacterSafety()
  if slua.isValid(uPlayerPawn) then
    uPlayerPawn.bShouldAutoRestoreADSAfterProneStop = false
  end
  self:DoOpenShotAnim(ShotAimPointerIndex, false, true, uPlayerController, false)
end
function OperateSubsystem:CheckSpecialAimPressed()
  local UESTExtraVehicleType = import("ESTExtraVehicleType")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local CurVehicle = PlayerCharacter:GetCurrentVehicle()
  if not slua.isValid(CurVehicle) then
    return
  end
  if CurVehicle.VehicleType == UESTExtraVehicleType.VT_Tank then
    CurVehicle:OnClickShootScopeBtn(uPlayerController)
    return true
  end
end
function OperateSubsystem:CheckSpecialAimReleased()
  local UESTExtraVehicleType = import("ESTExtraVehicleType")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local CurVehicle = PlayerCharacter:GetCurrentVehicle()
  if not slua.isValid(CurVehicle) then
    return
  end
  if CurVehicle.VehicleType == UESTExtraVehicleType.VT_Tank then
    CurVehicle:OnClickShootScopeBtn(uPlayerController)
    return true
  end
end
function OperateSubsystem:OnHoldOpenShootAim(FingerIndex)
  self:OpenShootAim(FingerIndex, false, true)
end
function OperateSubsystem:OpenShootAim(FingerIndex, bScopeIn, bIgnoreAngledSight)
  print(bWriteLog and "OperateSubsystem:OpenShootAim")
  if not self:IsWeaponEntityEnableScopeIn() then
    IngameTipsTools.BattleNormalTipsByTextID(733001)
    print(bWriteLog and "OperateSubsystem:OpenShootAim - weapon cannot scope in")
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "OperateSubsystem:OpenShootAim - PlayerController invalid")
    return
  end
  local PlayerCharacter = PlayerController:K2_GetPawn()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "OperateSubsystem:OpenShootAim - PlayerCharacter invalid")
    return
  end
  local MovementComponent = PlayerCharacter:GetMovementComponent()
  if not slua.isValid(MovementComponent) then
    print(bWriteLog and "OperateSubsystem:OpenShootAim - MovementComponent invalid")
    return
  end
  local Velocity = MovementComponent.Velocity
  local VectorLength = Velocity.X * Velocity.X + Velocity.Y * Velocity.Y + Velocity.Z * Velocity.Z
  local bContinue = false
  if 0 < VectorLength and PlayerCharacter:HasState(EPawnState.Prone) then
    if PlayerController.bAutoSprint and 0 >= PlayerController.AutoSprintCD then
      bContinue = true
    end
  else
    bContinue = true
  end
  if bContinue then
    if bIgnoreAngledSight then
      if bScopeIn then
        PlayerCharacter:ScopeIn(ESTEScopeType.Normal)
      else
        PlayerCharacter:ScopeOut(ESTEScopeType.Normal)
      end
    else
      PlayerCharacter:DoNormalSight(bScopeIn)
    end
    PlayerController:DoubleClickCancel(FingerIndex)
    if PlayerCharacter.bIsGunADS and not PlayerCharacter:HasState(EPawnState.LeanOutVehicle) then
      local VehicleUserComponent = PlayerController:GetVehicleUserComp()
      if slua.isValid(VehicleUserComponent) then
        VehicleUserComponent:TryLeanOutOrIn(false, false)
      end
    end
  end
  PlayerController:SetScopeFingerIndex(true, FingerIndex)
end
function OperateSubsystem:BleProne()
  print(bWriteLog and "OperateSubsystem:BleProne [1]")
  local EPawnState = import("EPawnState")
  local ESTEPoseState = import("ESTEPoseState")
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "OperateSubsystem:BleProne not PlayerCharacter")
    return false
  end
  if PlayerCharacter.bDisableProne then
    BattleGeneralSAPTip(11019)
    print(bWriteLog and "OperateSubsystem:BleProne not PlayerCharacter.bDisableProne")
    return false
  end
  local IsEnableProne = self:IsCurrentWeaponEntityEnableProne()
  if not IsEnableProne then
    local CurWeapon = self:GetCurrentWeapon()
    if slua.isValid(CurWeapon) and slua.isValid(CurWeapon.WeaponEntityComp) and PlayerCharacter:GetWeaponManager() and not CurWeapon.WeaponEntityComp.bEnableProneHolding and not CurWeapon.WeaponEntityComp.bUseAnimWhenDisableProneHolding then
      local Slot = PlayerCharacter:GetWeaponManager():GetCurrentUsingPropSlot()
      PlayerCharacter:SwitchWeaponBySlot(ESurviveWeaponPropSlot.SWPS_None, false, false, false)
      PlayerCharacter:GetWeaponManager():SetNextUseWeaponSlot(Slot)
    else
      print(bWriteLog and "OperateSubsystem:BleProne not IsEnableProne")
      IngameTipsTools.BattleNormalTipsByTextID(733000)
      return false
    end
  end
  if self:IsPressingJumpOrVault() or PlayerCharacter:HasState(EPawnState.Jump) then
    print(bWriteLog and "OperateSubsystem:BleProne IsPressingJumpOrVault or HasState Jump")
    return false
  end
  if PlayerCharacter:HasState(EPawnState.CoopVaultPrepare) then
    local uVaultComp = PlayerCharacter:GetVaultComponent()
    if slua.isValid(uVaultComp) then
      uVaultComp:InterruptCooperationVault(true)
    end
  end
  local bSuccess = false
  if PlayerCharacter.PoseState ~= ESTEPoseState.Prone and PlayerCharacter.PoseState ~= ESTEPoseState.Crawl then
    local TargetPose = ESTEPoseState.Prone
    if PlayerCharacter:HasState(EPawnState.Sprint) then
      TargetPose = ESTEPoseState.Crawl
    end
    if PlayerCharacter:SwitchPoseState(TargetPose, false, false, true, true) then
      self:UpdateProneBtnStatus(2)
      bSuccess = true
    end
  else
    local TargetPose = ESTEPoseState.Stand
    if PlayerCharacter:HasState(EPawnState.Sprint) then
      TargetPose = ESTEPoseState.Sprint
    end
    if PlayerCharacter:SwitchPoseState(TargetPose, false, false, true, true) then
      self:UpdateProneBtnStatus(0)
      self:SetSprintImgOpacity(1)
      local WeaponManager = PlayerCharacter:GetWeaponManager()
      local CurWeapon = self:GetCurrentWeapon()
      if slua.isValid(WeaponManager) and not slua.isValid(CurWeapon) and WeaponManager:GetNextUseWeaponSlot() ~= ESurviveWeaponPropSlot.SWPS_None then
        PlayerCharacter:SwitchWeaponBySlot(WeaponManager:GetNextUseWeaponSlot(), true, true, false)
        WeaponManager:SetNextUseWeaponSlot(ESurviveWeaponPropSlot.SWPS_None)
      end
      bSuccess = true
    end
  end
  local OperationalStatsSubsystem = SubsystemMgr:Get("OperationalStatsSubsystem")
  if OperationalStatsSubsystem then
    OperationalStatsSubsystem:AddOperationalStats(OperationalStatsSubsystem.StatsDataKey.Prone, 1)
  end
  return bSuccess
end
function OperateSubsystem:BleCrouch()
  print(bWriteLog and "OperateSubsystem:BleCrouch [1]")
  local EPawnState = import("EPawnState")
  local ESTEPoseState = import("ESTEPoseState")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "OperateSubsystem:BleCrouch not PlayerCharacter")
    return false
  end
  local STCharacterMovement = PlayerCharacter.STCharacterMovement
  if not slua.isValid(STCharacterMovement) or STCharacterMovement.GetIsOpenShovelingAbility == nil then
    print(bWriteLog and "OperateSubsystem:BleCrouch not STCharacterMovement")
    return false
  end
  local IsOpenShovelingAbility = STCharacterMovement:GetIsOpenShovelingAbility()
  local bShovelingSwitch = self:GetShovelingSetting()
  local IsOpenShovelingAbilityFinal = IsOpenShovelingAbility and bShovelingSwitch
  if IsOpenShovelingAbilityFinal and PlayerCharacter:HasState(EPawnState.Shoveling) then
    print(bWriteLog and "OperateSubsystem:BleCrouch Shoveling")
    return false
  end
  local StartShoveling = function()
    print(bWriteLog and "OperateSubsystem:BleCrouch StartShoveling")
    self:StartShovelingCD()
    self:UpdateCrouchBtnStatus(1)
    return true
  end
  local ToCrouch = function(bSprint)
    print(bWriteLog and "OperateSubsystem:BleCrouch ToCrouch " .. tostring(bSprint))
    local bSuccess = false
    if bSprint then
      bSuccess = PlayerCharacter:SwitchPoseState(ESTEPoseState.CrouchSprint, false, false, true, true)
    else
      bSuccess = PlayerCharacter:SwitchPoseState(ESTEPoseState.Crouch, false, false, true, true)
    end
    if bSuccess then
      self:UpdateCrouchBtnStatus(1)
      self:EnableMovement()
      self:SetSprintImgOpacity(1)
    end
    return bSuccess
  end
  local ToStand = function(bSprint)
    print(bWriteLog and "OperateSubsystem:BleCrouch ToStand " .. tostring(bSprint))
    local bSuccess = false
    if bSprint then
      bSuccess = PlayerCharacter:SwitchPoseState(ESTEPoseState.Sprint, false, false, true, true)
    else
      bSuccess = PlayerCharacter:SwitchPoseState(ESTEPoseState.Stand, false, false, true, true)
    end
    if bSuccess then
      self:UpdateCrouchBtnStatus(0)
      self:SetSprintImgOpacity(1)
    end
    return bSuccess
  end
  if PlayerCharacter:HasState(EPawnState.CoopVaultPrepare) then
    local uVaultComp = PlayerCharacter:GetVaultComponent()
    if slua.isValid(uVaultComp) then
      uVaultComp:InterruptCooperationVault(true)
    end
  end
  local bResult = false
  local bUnSwing = self:DealSwimForce(-1, PlayerCharacter)
  if bUnSwing and PlayerCharacter.PoseState ~= ESTEPoseState.Crouch and PlayerCharacter.PoseState ~= ESTEPoseState.CrouchSprint then
    local IsEnablePlayerShovleing = self:IsEnablePlayerShovleing()
    if IsEnablePlayerShovleing then
      if IsOpenShovelingAbilityFinal then
        if self:InShovelingCD() then
          print(bWriteLog and "OperateSubsystem:BleCrouch InShovelingCD1")
          return false
        end
        local bShoveling = PlayerCharacter:UpdateShovelingState()
        if bShoveling then
          bResult = StartShoveling()
        else
          bResult = ToCrouch(true)
        end
      else
        bResult = ToCrouch(true)
      end
    else
      bResult = ToCrouch(false)
    end
  elseif PlayerCharacter.PoseState == ESTEPoseState.Crouch or PlayerCharacter.PoseState == ESTEPoseState.CrouchSprint then
    if PlayerCharacter:HasState(EPawnState.Sprint) then
      local IsEnablePlayerShovleing = self:IsEnablePlayerShovleing()
      if IsOpenShovelingAbilityFinal and IsEnablePlayerShovleing then
        if self:InShovelingCD() then
          print(bWriteLog and "OperateSubsystem:BleCrouch InShovelingCD2")
          return false
        end
        local bShoveling = PlayerCharacter:UpdateShovelingState()
        if bShoveling then
          bResult = StartShoveling()
        else
          bResult = ToStand(true)
        end
      else
        bResult = ToStand(true)
      end
    else
      bResult = ToStand(false)
    end
  end
  local OperationalStatsSubsystem = SubsystemMgr:Get("OperationalStatsSubsystem")
  if OperationalStatsSubsystem then
    OperationalStatsSubsystem:AddOperationalStats(OperationalStatsSubsystem.StatsDataKey.Crouch, 1)
  end
  return bResult
end
function OperateSubsystem:IsCurrentWeaponEntityEnableProne()
  print(bWriteLog and "OperateSubsystem:IsCurrentWeaponEntityEnableProne [1]")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return true
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    return true
  end
  local CurrentUsingWeapon = WeaponManager:GetCurrentUsingWeapon()
  if not slua.isValid(CurrentUsingWeapon) or not slua.isValid(CurrentUsingWeapon.WeaponEntityComp) then
    return true
  end
  return CurrentUsingWeapon.WeaponEntityComp.bEnableProneHolding
end
function OperateSubsystem:GetCurrentWeapon()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return nil
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    return nil
  end
  return WeaponManager:GetCurrentUsingWeapon()
end
function OperateSubsystem:IsPressingJumpOrVault()
  local JumpVaultBtn = UIManager.GetUI(UIManager.UI_Config_InGame.JumpVaultBtn)
  if JumpVaultBtn then
    return JumpVaultBtn.IsPressingJumpingBtn or JumpVaultBtn.IsPressingVaultBtn
  end
  return false
end
function OperateSubsystem:UpdateProneBtnStatus(Index)
  print(bWriteLog and "OperateSubsystem:UpdateProneBtnStatus [1] Index=" .. tostring(Index))
  local ProneUIBP = UIManager.GetUI(UIManager.UI_Config_InGame.ProneUIBP)
  if ProneUIBP then
    ProneUIBP:UpdateProneBtnStatus(Index)
  end
end
function OperateSubsystem:SetSprintImgOpacity(Opacity)
  local AutoSprintUI = UIManager.GetUI(UIManager.UI_Config_InGame.ShootingUI_AutoSprintBtn)
  if AutoSprintUI then
    AutoSprintUI:SetSprintImgOpacity(Opacity)
  end
end
function OperateSubsystem:UpdateCrouchBtnStatus(Index)
  print(bWriteLog and "OperateSubsystem:UpdateCrouchBtnStatus [1] Index=" .. tostring(Index))
  local CrouchUIBP = UIManager.GetUI(UIManager.UI_Config_InGame.CrouchUIBP)
  if CrouchUIBP then
    CrouchUIBP:UpdateCrouchBtnStatus(Index)
  end
end
function OperateSubsystem:BleSprint()
  local AutoSprintUI = UIManager.GetUI(UIManager.UI_Config_InGame.ShootingUI_AutoSprintBtn)
  if AutoSprintUI then
    AutoSprintUI:BleSprint()
  end
end
function OperateSubsystem:GetShovelingSetting()
  print(bWriteLog and "OperateSubsystem:GetShovelingSetting [1]")
  local EGameModeType = import("EGameModeType")
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return true
  end
  if GameState.GameModeType ~= EGameModeType.EDeathMatchGameMode and GameState.GameModeType ~= EGameModeType.ECreativeModeGameMode then
    return true
  end
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  return SettingModule:GetOptionValue("ShovelSwitch")
end
function OperateSubsystem:IsEnablePlayerShovleing()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) and PlayerCharacter.IsEnablePlayerShovleing then
    return PlayerCharacter:IsEnablePlayerShovleing()
  end
  return false
end
function OperateSubsystem:InShovelingCD()
  local CrouchUIBP = UIManager.GetUI(UIManager.UI_Config_InGame.CrouchUIBP)
  if CrouchUIBP then
    return CrouchUIBP:InShovelingCD()
  end
  return false
end
function OperateSubsystem:StartShovelingCD()
  print(bWriteLog and "OperateSubsystem:StartShovelingCD [1]")
  local CrouchUIBP = UIManager.GetUI(UIManager.UI_Config_InGame.CrouchUIBP)
  if CrouchUIBP then
    CrouchUIBP:StartShovelingCD()
  end
end
function OperateSubsystem:DealSwimForce(UpOffset, PlayerCharacter)
  print(bWriteLog and "OperateSubsystem:DealSwimForce")
  local Unswing = true
  if PlayerCharacter and PlayerCharacter.GetPlayerAnimParam then
    local AnimParamList = PlayerCharacter:GetPlayerAnimParam(0.01)
    local EMovementMode = import("EMovementMode")
    if AnimParamList.MovementMode == EMovementMode.MOVE_Swimming then
      Unswing = false
      local OffSet = FVector(0, 0, UpOffset * 100)
      PlayerCharacter.CharacterMovement:AddImpulse(OffSet, true)
    end
  end
  return Unswing
end
function OperateSubsystem:EnableMovement()
  print(bWriteLog and "OperateSubsystem:EnableMovement [1]")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "OperateSubsystem:EnableMovement PlayerController invalid")
    return
  end
  local ControlledPawn = PlayerController:K2_GetPawn()
  if not slua.isValid(ControlledPawn) then
    print(bWriteLog and "OperateSubsystem:EnableMovement ControlledPawn invalid")
    return
  end
  local CharacterMovement = ControlledPawn.CharacterMovement
  if not slua.isValid(CharacterMovement) or not CharacterMovement.SetMovementMode then
    print(bWriteLog and "OperateSubsystem:EnableMovement CharacterMovement invalid")
    return
  end
  local EMovementMode = import("EMovementMode")
  CharacterMovement:SetMovementMode(EMovementMode.MOVE_Walking, 0)
end
function OperateSubsystem:RegistEvents_JumpVault()
  self:AddUIMessageEvent("StartVaultCastUIMsg", self.StartVaultCastUIMsg, self)
  GameComponentData.AddSelfVaultControllerComponentEvent(self, "OnVaultFailFromDS", function()
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    self:JumpDetailReset(PlayerCharacter)
  end, self)
end
function OperateSubsystem:Jump()
  self:JumpDetailForCharacter()
  local OperationalStatsSubsystem = SubsystemMgr:Get("OperationalStatsSubsystem")
  if OperationalStatsSubsystem then
    OperationalStatsSubsystem:AddOperationalStats(OperationalStatsSubsystem.StatsDataKey.Jump, 1)
  end
end
function OperateSubsystem:UnJump()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "JumpVault:OnReleasedJump not slua.isValid(PlayerCharacter)")
    return
  end
  if PlayerCharacter.PoseState == ESTEPoseState.Stand or PlayerCharacter.PoseState == ESTEPoseState.Sprint then
    PlayerCharacter:StopJumping()
    PlayerCharacter.Jumped = false
  end
end
function OperateSubsystem:EndVault()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "JumpVault:OnHoldEndedVault not slua.isValid(uPlayerCharacter)")
    return
  end
  local VaultComponent = PlayerCharacter:GetVaultComponent()
  if not slua.isValid(VaultComponent) then
    print(bWriteLog and "JumpVault:OnHoldEndedVault not VaultComponent")
    return
  end
  VaultComponent.bHoldingVaultButton = false
end
function OperateSubsystem:JumpDetailForCharacter()
  print(bWriteLog and "OperateSubsystem:JumpDetailForCharacter")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  if PlayerCharacter:HasState(EPawnState.CoopVaultPrepare) then
    local uVaultComp = PlayerCharacter:GetVaultComponent()
    if slua.isValid(uVaultComp) then
      uVaultComp:InterruptCooperationVault(true)
    end
  end
  local bBlock = self:InteractiveMoveComponentHandleJump()
  if bBlock then
    print(bWriteLog and "OperateSubsystem:JumpDetailForCharacter bBlock=true")
    return
  end
  local bCanVault, PlayerCharacter, Vault_Controller = self:CheckCanVault()
  local JumpVaultUI = UIManager.GetUI(UIManager.UI_Config_InGame.JumpVaultBtn)
  if bCanVault and JumpVaultUI and (JumpVaultUI.IsShowVaultBtn and JumpVaultUI.IsPressingVaultBtn or not JumpVaultUI.IsShowVaultBtn) then
    Vault_Controller:jumpfromUI()
  else
    self:JumpDetailReset(PlayerCharacter)
  end
  local ECustomMovmentMode = import("ECustomMovmentMode")
  local MoveObj = PlayerCharacter.STCharacterMovement:GetSpecialMoveObjByCustomMovementMode(ECustomMovmentMode.CUSTOM_MOVE_FreeWallClimb)
  if slua.isValid(MoveObj) then
    local FreeWallClimbingComponent_C = import("/Script/Addons.FreeWallClimbingComponent")
    local FreeWallClimbComp = PlayerCharacter:GetComponentByClass(FreeWallClimbingComponent_C)
    if slua.isValid(FreeWallClimbComp) then
      FreeWallClimbComp:ToggleWallClimb()
    end
  end
end
function OperateSubsystem:StartVaultCastUIMsg()
  print(bWriteLog and "OperateSubsystem:StartVaultCastUIMsg")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "OperateSubsystem:StartVaultCastUIMsg not slua.isValid(uPlayerCharacter)")
    return
  end
  PlayerCharacter.Vault_Controller:JumpVault()
end
function OperateSubsystem:CheckCanVault()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return false, PlayerCharacter, nil
  end
  local Vault_Controller = PlayerCharacter:GetVaultComponent()
  if PlayerCharacter:HasState(EPawnState.SwitchWeapon) then
    return false, PlayerCharacter, Vault_Controller
  end
  if PlayerCharacter:HasState(EPawnState.Vault) then
    return false, PlayerCharacter, Vault_Controller
  end
  if not slua.isValid(Vault_Controller) then
    return false, PlayerCharacter, Vault_Controller
  end
  local bCanVault = false
  bCanVault = Vault_Controller:CheckCanVault(bCanVault)
  return bCanVault, PlayerCharacter, Vault_Controller
end
function OperateSubsystem:InteractiveMoveComponentHandleJump()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return false
  end
  if not PlayerCharacter.IsInteractiveMoveComponentTakeOverJump then
    return false
  end
  if not PlayerCharacter:IsInteractiveMoveComponentTakeOverJump() then
    return false
  end
  PlayerCharacter:InteractiveMoveComponentHandleJumpInput()
  return true
end
function OperateSubsystem:JumpDetailReset(PlayerCharacter)
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local Unswing = self:DealSwimForce(1, PlayerCharacter)
  if not Unswing then
    return
  end
  local PoseState = PlayerCharacter.PoseState
  if PoseState == ESTEPoseState.Stand or PoseState == ESTEPoseState.Sprint then
    if PlayerCharacter.Jump then
      PlayerCharacter:Jump()
      PlayerCharacter.Jumped = true
    end
    return
  end
  if PoseState == ESTEPoseState.Crouch or PoseState == ESTEPoseState.Prone or PoseState == ESTEPoseState.CrouchSprint or PoseState == ESTEPoseState.Crawl then
    if PlayerCharacter:HasState(EPawnState.Shoveling) then
      if PlayerCharacter.Jump then
        PlayerCharacter:Jump()
        PlayerCharacter.Jumped = true
      end
    else
      local SwitchPose = ESTEPoseState.Stand
      if PoseState == ESTEPoseState.CrouchSprint or PoseState == ESTEPoseState.Crawl then
        SwitchPose = ESTEPoseState.Sprint
      end
      local bSuccess = PlayerCharacter:SwitchPoseState(SwitchPose, false, false, true, true)
    end
    return
  end
end
function OperateSubsystem:VaultFailFromDS()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:VaultFailFromDS not slua.isValid(uPlayerCharacter)")
    return
  end
  self:JumpDetailForCharacter()
end
function OperateSubsystem:PressedLeftLean(PointerIndex)
  print(bWriteLog and "OperateSubsystem:PressedLeftLean")
  self:TryToLean(true, PointerIndex)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
    local RotateViewWithPeekSwitch = SettingModule:GetOptionValue("RotateViewWithPeekSwitch")
    if not RotateViewWithPeekSwitch then
      PlayerController:AddIgnoreCameraMoveIndex(PointerIndex)
    end
  end
  local OperationalStatsSubsystem = SubsystemMgr:Get("OperationalStatsSubsystem")
  if OperationalStatsSubsystem then
    OperationalStatsSubsystem:AddOperationalStats(OperationalStatsSubsystem.StatsDataKey.Peek, 1)
  end
end
function OperateSubsystem:ReleasedLeftLean()
  print(bWriteLog and "OperateSubsystem:ReleasedLeftLean")
  local Character = GameplayData.GetPlayerCharacter()
  if not slua.isValid(Character) then
    return
  end
  Character:TryPeek(true, false)
end
function OperateSubsystem:PressedRightLean(PointerIndex)
  print(bWriteLog and "OperateSubsystem:PressedRightLean")
  self:TryToLean(false, PointerIndex)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
    local RotateViewWithPeekSwitch = SettingModule:GetOptionValue("RotateViewWithPeekSwitch")
    if not RotateViewWithPeekSwitch then
      PlayerController:AddIgnoreCameraMoveIndex(PointerIndex)
    end
  end
  local OperationalStatsSubsystem = SubsystemMgr:Get("OperationalStatsSubsystem")
  if OperationalStatsSubsystem then
    OperationalStatsSubsystem:AddOperationalStats(OperationalStatsSubsystem.StatsDataKey.Peek, 1)
  end
end
function OperateSubsystem:ReleasedRightLean()
  print(bWriteLog and "OperateSubsystem:ReleasedRightLean")
  local Character = GameplayData.GetPlayerCharacter()
  if not slua.isValid(Character) then
    return
  end
  Character:TryPeek(false, false)
end
function OperateSubsystem:TryToLean(IsLeft, PointerIndex)
  local Character = GameplayData.GetPlayerCharacter()
  if not slua.isValid(Character) then
    return
  end
  Character:TryPeek(IsLeft, true)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:SetTouchFingerIndex(true, PointerIndex)
  end
end
function OperateSubsystem:LeftLean(FingerIndex)
  print(bWriteLog and "OperateSubsystem:LeftLean")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  PlayerCharacter:TryPeek(true, true)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:SetPeekFingerIndex(true, FingerIndex, false)
  end
end
function OperateSubsystem:RightLean(FingerIndex)
  print(bWriteLog and "OperateSubsystem:RightLean")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  PlayerCharacter:TryPeek(false, true)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:SetPeekFingerIndex(true, FingerIndex, false)
  end
end
function OperateSubsystem:ChangeCharacterPerspective(bFirst)
  print(bWriteLog and "OperateSubsystem:ChangeCharacterPerspective")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  PlayerCharacter:SetCurrentPersonPerspective(bFirst, false)
end
function OperateSubsystem:ShowEntireMapWindow()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if slua.isValid(MainControlBaseUI) then
    MainControlBaseUI:ShowEntireMapWindow()
  end
end
function OperateSubsystem:OnRedSightPressed(PointerIndex, ISP90, RotateViewWithSniperSwitch)
  print(bWriteLog and string.format("OperateSubsystem:OnRedSightPressed [1] PointerIndex: %s", tostring(PointerIndex)))
  local PlayerPawn = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerPawn) then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local IsCoolingDownFinish = PlayerPawn:IsSwitchCoolingDownFinish()
  print(bWriteLog and string.format("OperateSubsystem:OnRedSightPressed [2] IsCoolingDownFinish: %s", tostring(IsCoolingDownFinish)))
  if not IsCoolingDownFinish then
    return
  end
  local FingerIndex = PointerIndex or 0
  PlayerController:SetTouchFingerIndex(true, FingerIndex)
  if ISP90 then
    PlayerPawn:DoWeaponSight()
  else
    local bIsGunADS = PlayerPawn.bIsGunADS or false
    local IsPush = not bIsGunADS
    PlayerPawn:DoAngledSight(IsPush)
  end
  if not RotateViewWithSniperSwitch then
    PlayerController:AddIgnoreCameraMoveIndex(FingerIndex)
  end
  local OperationalStatsSubsystem = SubsystemMgr:Get("OperationalStatsSubsystem")
  if OperationalStatsSubsystem then
    OperationalStatsSubsystem:AddOperationalStats(OperationalStatsSubsystem.StatsDataKey.RedSight, 1)
  end
end
function OperateSubsystem:OnRedSightReleased(ISP90)
  print(bWriteLog and "OperateSubsystem:OnRedSightReleased [1]")
  local PlayerPawn = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerPawn) then
    return
  end
  local Controller = GameplayData.GetPlayerController()
  if not slua.isValid(Controller) then
    return
  end
  local SensibilityConfig = Controller.SensibilityConfig
  if not SensibilityConfig then
    return
  end
  local SideMirrorModeC = SensibilityConfig.SideMirrorModeC or 0
  local IsNotEqual2 = SideMirrorModeC ~= 2
  if IsNotEqual2 then
    print(bWriteLog and string.format("OperateSubsystem:OnRedSightReleased [2] SideMirrorModeC != 2, check ISP90: %s", tostring(ISP90)))
    if not ISP90 then
      PlayerPawn:DoAngledSight(false)
    end
  end
end
function OperateSubsystem:SimReload()
  print(bWriteLog and "OperateSubsystem:SimReload")
  local ReloadUI = UIManager.GetUI(UIManager.UI_Config.ReloadUI)
  if ReloadUI and ReloadUI.UIRoot then
    ReloadUI:SimReload()
  end
end
function OperateSubsystem:HandleReloadFinish()
  print(bWriteLog and "OperateSubsystem:HandleReloadFinish")
  local ReloadUI = UIManager.GetUI(UIManager.UI_Config.ReloadUI)
  if ReloadUI and ReloadUI.UIRoot then
    ReloadUI:HandleReloadFinish()
  end
end
function OperateSubsystem:SetReloadUIVisibility(bShow)
  print(bWriteLog and "OperateSubsystem:HandleReloadFinish")
  local ReloadUI = UIManager.GetUI(UIManager.UI_Config.ReloadUI)
  if ReloadUI and ReloadUI.UIRoot then
    ReloadUI:SetReloadUIVisibility(bShow)
  end
end
function OperateSubsystem:ChangeThrowMode()
  print(bWriteLog and "OperateSubsystem:HandleReloadFinish")
  local SwitchThrowUI = UIManager.GetUI(UIManager.UI_Config.SwitchThrowUI)
  if SwitchThrowUI and SwitchThrowUI.UIRoot then
    SwitchThrowUI:OnClickedChangeThrowMode()
  end
end
function OperateSubsystem:GetCurrentUsingPropSlot()
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return ESurviveWeaponPropSlot.SWPS_None
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if slua.isValid(WeaponManager) then
    return WeaponManager:GetCurrentUsingPropSlot()
  end
  return ESurviveWeaponPropSlot.SWPS_None
end
function OperateSubsystem:GetCurUsingWeapon()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return nil
  end
  if not PlayerController.GetPlayerCharacterSafety then
    return nil
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) then
    return nil
  end
  return PlayerCharacter:GetCurrentWeapon()
end
function OperateSubsystem:CanPlayerAutoSprintOrSwim()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "OperateSubsystem:CanPlayerAutoSprintOrSwim not PlayerController")
    return false
  end
  if not PlayerController.IsPlayerUnableToDoAutoSprintOperation then
    print(bWriteLog and "OperateSubsystem:CanPlayerAutoSprintOrSwim not not PlayerController.IsPlayerUnableToDoAutoSprintOperation")
    return true
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "OperateSubsystem:CanPlayerAutoSprintOrSwim not PlayerCharacter")
    return false
  end
  local UIDataProcessingFunctionLibrary = import("UIDataProcessingFunctionLibrary")
  return UIDataProcessingFunctionLibrary.IsPlayerCanDoSprintOperation(PlayerCharacter)
end
function OperateSubsystem:CanUseGrenadeWeapon(GrenadeID)
  print(bWriteLog and "OperateSubsystem:CanUseGrenadeWeapon")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "OperateSubsystem:CanUseGrenadeWeapon not slua.isValid(uPlayerCharacter)")
    return true
  end
  if GrenadeID == 602038 then
    if PlayerCharacter:HasState(EPawnState.Sprint) or PlayerCharacter:HasState(EPawnState.Vault) or PlayerCharacter:HasState(EPawnState.Crouch) or PlayerCharacter:HasState(EPawnState.Prone) or PlayerCharacter:IsOnVehicle() then
      print(bWriteLog and "OperateSubsystem:CanUseGrenadeWeapon 0")
      return false
    else
      print(bWriteLog and "OperateSubsystem:CanUseGrenadeWeapon 1")
      return true
    end
  end
  if GrenadeID == 602035 and PlayerCharacter:IsOnVehicle() then
    print(bWriteLog and "OperateSubsystem:CanUseGrenadeWeapon 2")
    return false
  end
  if GrenadeID == 602111 or GrenadeID == 602113 then
    if PlayerCharacter:HasState(EPawnState.Prone) or PlayerCharacter:IsOnVehicle() then
      print(bWriteLog and "ShootingUIPanelUIBase:CanUseGrenadeWeapon Player is in invalid state, cannot switch to weapon:", GrenadeID)
      return false
    else
      print(bWriteLog and "OperateSubsystem:CanUseGrenadeWeapon 4")
      return true
    end
  end
  print(bWriteLog and "OperateSubsystem:CanUseGrenadeWeapon 5")
  return true
end
function OperateSubsystem:ActiveSprint()
  local AutoSprintUI = UIManager.GetUI(UIManager.UI_Config_InGame.ShootingUI_AutoSprintBtn)
  if AutoSprintUI then
    AutoSprintUI:ActiveSprint()
  end
end
function OperateSubsystem:TryExitAutoSprintState(PlayerCharacter)
  local AutoSprintUI = UIManager.GetUI(UIManager.UI_Config_InGame.ShootingUI_AutoSprintBtn)
  if AutoSprintUI then
    AutoSprintUI:TryExitAutoSprintState(PlayerCharacter)
  end
end
function OperateSubsystem:TryEnterAutoSprintState(PlayerCharacter)
  local AutoSprintUI = UIManager.GetUI(UIManager.UI_Config_InGame.ShootingUI_AutoSprintBtn)
  if AutoSprintUI then
    AutoSprintUI:TryEnterAutoSprintState(PlayerCharacter)
  end
end
function OperateSubsystem:HideAutoSprintUI()
  local AutoSprintUI = UIManager.GetUI(UIManager.UI_Config_InGame.ShootingUI_AutoSprintBtn)
  if AutoSprintUI then
    AutoSprintUI:HideAutoSprintUI()
  end
end
function OperateSubsystem:CancelThrow()
  local player = GameplayData.GetPlayerCharacter()
  if slua.isValid(player) then
    player:TouchCancelSkillLock()
  else
    return false
  end
  player:TriggerCustomEvent(EUAESkillEvent.PlayerRequestCancel, -1)
  EventSystem:postEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_THROW_CANCEL_BUTTON_CLICK)
  local uWeapon = player:GetCurrentWeapon()
  if not slua.isValid(uWeapon) then
    print(bWriteLog and "CancelThrowBtn:CancelThrow weapon is invalid")
    return false
  end
  local BowState = uWeapon:GetComponentByClass(UBowAccumulateEnergyState)
  if slua.isValid(BowState) then
    BowState:ForceEndState(true)
  else
    local uThrowComponent = uWeapon:GetComponentByClass(ThrowComponent)
    if slua.isValid(uThrowComponent) then
      uThrowComponent:CancelThrow(false)
    end
  end
  return true
end
function OperateSubsystem:ChangeThrowVisible(bVisible)
  local CancelThrowPanel = UIManager.GetUI(UIManager.UI_Config_InGame.CancelThrowBtn)
  if not CancelThrowPanel then
    return
  end
  if bVisible then
    CancelThrowPanel:ShowCancelGrenadeBtn()
  else
    CancelThrowPanel:HideCancelGrenadeBtn()
  end
end
function OperateSubsystem:ToggleCancelBtn(bOpen, nTextID)
  local CancelThrowPanel = UIManager.GetUI(UIManager.UI_Config_InGame.CancelThrowBtn)
  if not CancelThrowPanel then
    return
  end
  if bOpen then
    CancelThrowPanel:ChangeText(nTextID)
  else
    CancelThrowPanel:HideCancelGrenadeBtn()
    CancelThrowPanel:ChangeIndex(0)
  end
end
function OperateSubsystem:VehicleShootingCheckShootingState()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local ShootingUIPanelLuaClass = InGameUITools.GetShootingUIPanelLuaClass()
  if ShootingUIPanelLuaClass then
    ShootingUIPanelLuaClass:VehicleShootingCheckShootingState()
  end
end
function OperateSubsystem:InterruptThrow()
  print(bWriteLog and "OperateSubsystem:InterruptThrow")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerCharacter) or not slua.isValid(PlayerController) then
    return
  end
  PlayerCharacter:ScopeOut(ESTEScopeType.Normal)
  if PlayerCharacter:HasState(EPawnState.LeanOutVehicle) then
    local uVehicleUserComp = PlayerController:GetVehicleUserComp()
    if slua.isValid(uVehicleUserComp) then
      uVehicleUserComp:TryLeanOutOrIn(false, false)
    end
  end
  PlayerController:BroadcastUIMessage("UIMsg_ResetCancelFireBtn", 0, "", "")
  if PlayerCharacter:HasState(EPawnState.HoldGrenade) then
    print(bWriteLog and "OperateSubsystem:InterruptThrow - cancel grenade skill")
    PlayerController.TouchEndTriggerSkillID = -1
    PlayerCharacter:TriggerCustomEvent(EUAESkillEvent.PlayerRequestCancel, -1)
    local Weapon = PlayerCharacter:GetCurrentWeapon()
    if slua.isValid(Weapon) then
      local ThrowComponentInstance = Weapon:GetComponentByClass(ThrowComponent)
      if slua.isValid(ThrowComponentInstance) then
        ThrowComponentInstance:CancelThrow(false)
      end
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, OperateSubsystem)