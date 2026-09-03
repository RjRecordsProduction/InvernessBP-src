local InputFunctionMap = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local UESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local CircleChooseUtil = require("GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseUtil")
local ECollisionChannel = import("ECollisionChannel")
InputFunctionMap.LastWeaponSlot = UESurviveWeaponPropSlot.SWPS_None
function InputFunctionMap.PressedTargetMove()
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  local uHitResult = import("/Script/Engine.HitResult")()
  local TraceType = Game:ConvertToTraceType(ECollisionChannel.ECC_WorldStatic)
  local bHit, HitResult = uPlayerController:GetHitResultUnderCursorByChannel(TraceType, true, uHitResult)
  if bHit then
    local autoNav = uPlayerController.BP_AutoNav_PlanPH or uPlayerController.BP_AutoNav
    if autoNav then
      autoNav:TryReqMoveToLocation(HitResult.Location)
    end
  end
end
function InputFunctionMap.PressedJump()
  local JumpVault = UIManager.GetUI(UIManager.UI_Config_InGame.JumpVaultBtn)
  if JumpVault and Game:IsValid(JumpVault) then
    print(bWriteLog and "JumpVault:OnPressdJump")
    JumpVault.IsPressingJumpingBtn = true
    JumpVault:RefreshJumpBtnIcon(false)
    JumpVault.IsPressingVaultBtn = false
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:Jump()
  end
end
function InputFunctionMap.ReleasedJump()
  local JumpVault = UIManager.GetUI(UIManager.UI_Config_InGame.JumpVaultBtn)
  if JumpVault and Game:IsValid(JumpVault) then
    JumpVault.IsPressingJumpingBtn = false
    JumpVault:RefreshJumpBtnIcon(false)
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:UnJump()
  end
end
function InputFunctionMap.PressedReload()
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
  if not Game:IsValid(uPlayerCharacter) then
    return
  end
  uPlayerCharacter:Reload()
end
function InputFunctionMap.PressedCrouch()
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:BleCrouch()
  end
end
function InputFunctionMap.PressedProne()
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:BleProne()
  end
end
function InputFunctionMap.PressedSwitchPMode()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(PlayerCharacter) then
    return
  end
  if PlayerCharacter.IsFPP then
    PlayerCharacter:SetCurrentPersonPerspective(false, false)
  else
    PlayerCharacter:SetCurrentPersonPerspective(true, false)
  end
end
function InputFunctionMap.PressedSprint()
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:BleSprint()
  end
end
function InputFunctionMap.StartSprint()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(PlayerCharacter) then
    return
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:TryEnterAutoSprintState(PlayerCharacter)
  end
end
function InputFunctionMap.StopSprint()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(PlayerCharacter) then
    return
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:TryExitAutoSprintState(PlayerCharacter)
  end
end
function InputFunctionMap.PressedEntireMap()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) then
    local EntireMapUIConfig = UIManager.UI_Config_InGame.EntireMapWindow
    local EntireMapUI = UIManager.GetUI(EntireMapUIConfig)
    local bIsOpen = false
    if EntireMapUI and UIManager.IsUIShow(EntireMapUIConfig) then
      EntireMapUI:HandleClickHide()
    else
      bIsOpen = true
      MainControlBaseUI:ShowEntireMapWindow()
    end
    InputFunctionMap.SetMouseCursorByUIState(bIsOpen)
  end
end
function InputFunctionMap.PressedBackPack()
  local BackpackClothingEntryUI = UIManager.GetUI(UIManager.UI_Config_InGame.BackpackClothingEntryUI)
  if BackpackClothingEntryUI then
    BackpackClothingEntryUI:OnClickBackpackButton()
    local BackpackUI = InGameUITools.GetBackpackUI()
    local bIsOpen = false
    if BackpackUI and Game:IsValid(BackpackUI) then
      bIsOpen = BackpackUI:GetVisibility() ~= UEnums.ESlateVisibility.Collapsed
    end
    InputFunctionMap.SetMouseCursorByUIState(bIsOpen)
  end
end
function InputFunctionMap.PressedQuickChatMenu()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) then
    MainControlBaseUI:ShowQuickChatMenu()
  end
end
function InputFunctionMap.PressedSwitchWeapon(nWeaponSlot)
  local ShootingUIPanel = InGameUITools.GetShootingUIPanelLuaClass()
  if Game:IsValid(ShootingUIPanel) then
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if not Game:IsValid(uPlayerCharacter) then
      return
    end
    local uWeaponManager = uPlayerCharacter:GetWeaponManager()
    if not Game:IsValid(uWeaponManager) then
      return
    end
    if Game:IsValid(uWeaponManager:GetInventoryWeaponByPropSlot(nWeaponSlot)) then
      ShootingUIPanel:ClickOnSwitchWeapon(nWeaponSlot)
      InputFunctionMap.LastWeaponSlot = nWeaponSlot
    end
  end
end
function InputFunctionMap.PressedQuickSign()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) and Game:IsValid(MainControlBaseUI.QuickSignUI) then
    MainControlBaseUI.QuickSignUI:OnClick()
  end
end
function InputFunctionMap.PressedChangeSight()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    local QuickExpressionDecalUI = MainControlBaseUI:CreateAndGetQuickExpressionDecalUI()
    if QuickExpressionDecalUI then
      QuickExpressionDecalUI:OnPressedChangeSight()
    end
  end
end
function InputFunctionMap.ReleasedChangeSight()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    local QuickExpressionDecalUI = MainControlBaseUI:CreateAndGetQuickExpressionDecalUI()
    if QuickExpressionDecalUI then
      QuickExpressionDecalUI:OnReleasedChangeSight()
    end
  end
end
function InputFunctionMap.PressedFreeCamera()
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  local ETouchIndex = import("ETouchIndex")
  uPlayerController:StartFreeCamera(ETouchIndex.Touch1)
end
function InputFunctionMap.ReleasedFreeCamera()
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  uPlayerController:ExitFreeCamera(false)
end
function InputFunctionMap.PressedPeek(bIsLeft)
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    if bIsLeft then
      OperateSubsystem:PressedLeftLean(0)
    else
      OperateSubsystem:PressedRightLean(0)
    end
  end
end
function InputFunctionMap.ReleasedPeek(bIsLeft)
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    if bIsLeft then
      OperateSubsystem:ReleasedLeftLean()
    else
      OperateSubsystem:ReleasedRightLean()
    end
  end
end
function InputFunctionMap.PressedSwimUp()
  local PlayerPawn = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerPawn) then
    print(bWriteLog and "SwimPanel:OnControlSwim Fail not slua.isValid(PlayerPawn)")
    return
  end
  PlayerPawn.SwimUpRate = 1
end
function InputFunctionMap.ReleasedSwimUp()
  local PlayerPawn = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerPawn) then
    print(bWriteLog and "SwimPanel:OnControlSwim Fail not slua.isValid(PlayerPawn)")
    return
  end
  PlayerPawn.SwimUpRate = 0
end
function InputFunctionMap.PressedSwimDown()
  local PlayerPawn = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerPawn) then
    print(bWriteLog and "SwimPanel:OnControlSwim Fail not slua.isValid(PlayerPawn)")
    return
  end
  PlayerPawn.SwimUpRate = -1
end
function InputFunctionMap.ReleasedSwimDown()
  local PlayerPawn = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerPawn) then
    print(bWriteLog and "SwimPanel:OnControlSwim Fail not slua.isValid(PlayerPawn)")
    return
  end
  PlayerPawn.SwimUpRate = 0
end
function InputFunctionMap.SetMouseCursor()
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  uPlayerController.bShowMouseCursor = not uPlayerController.bShowMouseCursor
  local InputStateControl = require("GameLua.GameCore.Module.Input.InputStateControl")
  if uPlayerController.bShowMouseCursor then
    InputFunctionMap.SetMouseCursorShow()
  else
    InputFunctionMap.SetMouseCursorHide()
  end
end
function InputFunctionMap.SetMouseCursorShow()
  print(bWriteLog and "InputStateControl_Debug_Msg: SetMouseCursorShow")
  local uPlayerController = GameplayData.GetPlayerController()
  if IsWoWEditor then
    local UIUtil = require("client.common.ui_util")
    local WorldContextObject = UIUtil.GetGameInstance()
    local UGameplayStatics = import("GameplayStatics")
    uPlayerController = UGameplayStatics.GetPlayerController(WorldContextObject, 0)
  end
  if not Game:IsValid(uPlayerController) then
    return
  end
  uPlayerController.bShowMouseCursor = true
  local UWidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
  UWidgetBlueprintLibrary.SetInputMode_GameAndUI(uPlayerController, nil, true, true)
  Client.SetUseMouseForTouch(true)
end
function InputFunctionMap.SetMouseCursorHide()
  print(bWriteLog and "InputStateControl_Debug_Msg: SetMouseCursorShow")
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  uPlayerController.bShowMouseCursor = false
  local UWidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
  UWidgetBlueprintLibrary.SetInputMode_GameOnly(uPlayerController)
  Client.SetUseMouseForTouch(false)
end
function InputFunctionMap.PressedFire()
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(uPlayerCharacter) then
    return
  end
  local WeaponManager = uPlayerCharacter:GetWeaponManager()
  if not Game:IsValid(WeaponManager) then
    return
  end
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  local CurrentUseWeaponSlot = WeaponManager:GetCurrentUsingPropSlot()
  if InputFunctionMap.CheckVehicleWeapon() then
    local VehicleUserComponent = uPlayerController:GetVehicleUserComp()
    if Game:IsValid(VehicleUserComponent) then
      VehicleUserComponent:FireVehicleWeapon()
      return
    end
  end
  local ShootingUIPanel = InGameUITools.GetShootingUIPanelLuaClass()
  if Game:IsValid(ShootingUIPanel) then
    if CurrentUseWeaponSlot ~= ESurviveWeaponPropSlot.SWPS_HandProp then
      ShootingUIPanel:OnPlayerControllerPressFire()
    else
      ShootingUIPanel:GrenadeTriggerHit(0)
    end
  end
end
function InputFunctionMap.ReleasedFire()
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  local ShootingUIPanel = InGameUITools.GetShootingUIPanelLuaClass()
  if not Game:IsValid(ShootingUIPanel) then
    return
  end
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(uPlayerCharacter) then
    return
  end
  local WeaponManager = uPlayerCharacter:GetWeaponManager()
  if not Game:IsValid(WeaponManager) then
    return
  end
  if InputFunctionMap.CheckVehicleWeapon() then
    local VehicleUserComponent = uPlayerController:GetVehicleUserComp()
    if Game:IsValid(VehicleUserComponent) then
      VehicleUserComponent:StopFireVehicleWeapon()
      return
    end
  end
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  local CurrentUseWeaponSlot = WeaponManager:GetCurrentUsingPropSlot()
  if CurrentUseWeaponSlot ~= ESurviveWeaponPropSlot.SWPS_HandProp then
    uPlayerController:EndForceTouchFire(FVector(0.0, 0.0, 0.0))
    uPlayerController.bAlreadyFired = false
  else
    ShootingUIPanel:GrenadeThrow()
  end
  local ShootingUIPanelLuaClass = InGameUITools.GetShootingUIPanelLuaClass()
  if not ShootingUIPanelLuaClass then
    return
  end
  ShootingUIPanelLuaClass:NormalFireBtnByStatus(true)
end
function InputFunctionMap.CheckVehicleWeapon()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(PlayerCharacter) then
    return
  end
  local CurVehicle = PlayerCharacter:GetCurrentVehicle()
  if not Game:IsValid(CurVehicle) then
    return
  end
  local VehicleSeats = CurVehicle:GetVehicleSeats()
  if not Game:IsValid(VehicleSeats) then
    return
  end
  local uWeaponManager = PlayerCharacter:GetWeaponManager()
  if not Game:IsValid(uWeaponManager) then
    return false
  end
  local CurWeapon = uWeaponManager:GetCurrentUsingWeapon()
  if not Game:IsValid(CurWeapon) then
    return false
  end
  local nVehicleSeatIdx = PlayerCharacter.VehicleSeatIdx
  local VehicleWeapons = VehicleSeats.VehicleWeapons
  local WeaponsOnSeat = VehicleWeapons:Get(nVehicleSeatIdx).WeaponsOnSeat
  for _, Weapon in pairs(WeaponsOnSeat) do
    if Game:IsValid(Weapon) and CurWeapon == Weapon then
      return true
    end
  end
  return false
end
function InputFunctionMap.PressedAim()
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:PressedAim()
  end
end
function InputFunctionMap.ReleasedAim()
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:ReleasedAim()
  end
end
function InputFunctionMap.PressedSetWeaponShootType()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(uPlayerCharacter) then
    return
  end
  local uCurWeapon = uPlayerCharacter:GetCurrentWeapon()
  if not Game:IsValid(uCurWeapon) then
    return
  end
  local uWeaponManager = uPlayerCharacter:GetWeaponManager()
  if not Game:IsValid(uWeaponManager) then
    return
  end
  local ShootingUIPanel = InGameUITools.GetShootingUIPanelLuaClass()
  if Game:IsValid(ShootingUIPanel) then
    local CurSlot = uWeaponManager:GetWeaponSlotInInventory(uCurWeapon)
    local CurSlotUI
    if CurSlot == UESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
      CurSlotUI = ShootingUIPanel.FirWeaponSlot
    elseif CurSlot == UESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
      CurSlotUI = ShootingUIPanel.SecWeaponSlot
    elseif CurSlot == UESurviveWeaponPropSlot.SWPS_SubShootWeapon then
      CurSlotUI = ShootingUIPanel.PistolModeUI
    end
    if Game:IsValid(CurSlotUI) then
      CurSlotUI:SetWeaponShootType()
    end
  end
end
function InputFunctionMap.MouseWheelUpSwitchWeapon()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(uPlayerCharacter) then
    return
  end
  local uWeaponManager = uPlayerCharacter:GetWeaponManager()
  if not Game:IsValid(uWeaponManager) then
    return
  end
  local uCurWeapon = uPlayerCharacter:GetCurrentWeapon()
  if not Game:IsValid(uCurWeapon) then
    InputFunctionMap.PressedSwitchWeapon(InputFunctionMap.GetPreValidWeaponSlot(5))
    return
  end
  local ShootingUIPanel = InGameUITools.GetShootingUIPanelLuaClass()
  if Game:IsValid(ShootingUIPanel) then
    local CurSlot = uWeaponManager:GetWeaponSlotInInventory(uCurWeapon)
    local NextSlot = InputFunctionMap.GetPreValidWeaponSlot(CurSlot)
    InputFunctionMap.PressedSwitchWeapon(NextSlot)
  end
end
function InputFunctionMap.GetPreValidWeaponSlot(CurSlot)
  local ResSlot = CurSlot
  local PreWeaponSlotList = {
    [1] = 4,
    [2] = 3,
    [3] = 2,
    [4] = 1
  }
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(uPlayerCharacter) then
    return
  end
  local uWeaponManager = uPlayerCharacter:GetWeaponManager()
  if not Game:IsValid(uWeaponManager) then
    return
  end
  for key, value in ipairs(PreWeaponSlotList) do
    if value < CurSlot and Game:IsValid(uWeaponManager:GetInventoryWeaponByPropSlot(value)) then
      return value
    end
  end
  return ResSlot
end
function InputFunctionMap.MouseWheelDownSwitchWeapon()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(uPlayerCharacter) then
    return
  end
  local uWeaponManager = uPlayerCharacter:GetWeaponManager()
  if not Game:IsValid(uWeaponManager) then
    return
  end
  local uCurWeapon = uPlayerCharacter:GetCurrentWeapon()
  if not Game:IsValid(uCurWeapon) then
    InputFunctionMap.PressedSwitchWeapon(InputFunctionMap.GetNextValidWeapon(0))
    return
  end
  local ShootingUIPanel = InGameUITools.GetShootingUIPanelLuaClass()
  if Game:IsValid(ShootingUIPanel) then
    local CurSlot = uWeaponManager:GetWeaponSlotInInventory(uCurWeapon)
    local NextSlot = InputFunctionMap.GetNextValidWeapon(CurSlot)
    InputFunctionMap.PressedSwitchWeapon(NextSlot)
  end
end
function InputFunctionMap.GetNextValidWeapon(CurSlot)
  local ResSlot = CurSlot
  local PreWeaponSlotList = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4
  }
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(uPlayerCharacter) then
    return
  end
  local uWeaponManager = uPlayerCharacter:GetWeaponManager()
  if not Game:IsValid(uWeaponManager) then
    return
  end
  for key, value in ipairs(PreWeaponSlotList) do
    if CurSlot < value and Game:IsValid(uWeaponManager:GetInventoryWeaponByPropSlot(value)) then
      return value
    end
  end
  return ResSlot
end
function InputFunctionMap.EntireMapZoomIn()
  local EntireMapUIConfig = UIManager.UI_Config_InGame.EntireMapWindow
  local EntireMapUI = UIManager.GetUI(EntireMapUIConfig)
  if EntireMapUI then
    EntireMapUI:HandleBtnZoomIn()
  end
end
function InputFunctionMap.EntireMapZoomOut()
  local EntireMapUIConfig = UIManager.UI_Config_InGame.EntireMapWindow
  local EntireMapUI = UIManager.GetUI(EntireMapUIConfig)
  if EntireMapUI then
    EntireMapUI:HandleBtnZoomOut()
  end
end
function InputFunctionMap.EntireMapDeleteMark()
  local EntireMapUIConfig = UIManager.UI_Config_InGame.EntireMapWindow
  local EntireMapUI = UIManager.GetUI(EntireMapUIConfig)
  if EntireMapUI then
    EntireMapUI:HandleClickDeleteMark()
  end
end
function InputFunctionMap.PressedTeamSpeaker()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) then
    local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
    if uAntsVoiceInterface:TeamSpeakerEnable() then
      local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
      logic_antsvoice_interface:OpenTeamSpeakerOnly()
    else
      local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
      logic_antsvoice_interface:CloseAllSpeaker()
    end
  end
end
function InputFunctionMap.PressedTeamMicphone()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) then
    local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
    if uAntsVoiceInterface:TeamMicphoneEnable() then
      local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
      logic_antsvoice_interface:CloseAllMicphone()
    else
      local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
      logic_antsvoice_interface:OpenTeamMicphoneOnly()
    end
  end
end
function InputFunctionMap.PressedChangeSightRoomIn()
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:ChangeSightZoom(0.2)
  end
end
function InputFunctionMap.PressedChangeSightRoomOut()
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:ChangeSightZoom(-0.2)
  end
end
function InputFunctionMap.PressedCancelThrow()
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:CancelThrow()
  end
end
function InputFunctionMap.PressedChangeThrowMode()
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:ChangeThrowMode()
  end
end
function InputFunctionMap.SelectGrenade()
  local GrenadesPanel = UIManager.GetUI(UIManager.UI_Config_InGame.GrenadeChooseWidgetNew)
  if GrenadesPanel then
    if CircleChooseUtil.IsCurrentWeaponMatchID(602004) then
      CircleChooseUtil.OnUseFistByRing()
    else
      GrenadesPanel.RingList[2]:HandleSlotChosen()
    end
  end
end
function InputFunctionMap.SelectSmokeGrenade()
  local GrenadesPanel = UIManager.GetUI(UIManager.UI_Config_InGame.GrenadeChooseWidgetNew)
  if GrenadesPanel then
    if CircleChooseUtil.IsCurrentWeaponMatchID(602002) then
      CircleChooseUtil.OnUseFistByRing()
    else
      GrenadesPanel.RingList[1]:HandleSlotChosen()
    end
  end
end
function InputFunctionMap.SelectMolotovCocktailOrStunGrenade()
  local GrenadesPanel = UIManager.GetUI(UIManager.UI_Config_InGame.GrenadeChooseWidgetNew)
  if GrenadesPanel then
    if CircleChooseUtil.IsCurrentWeaponMatchID(602001) or CircleChooseUtil.IsCurrentWeaponMatchID(602003) then
      CircleChooseUtil.OnUseFistByRing()
    else
      CircleChooseUtil.SwitchToBurnOrStun()
    end
  end
end
function InputFunctionMap.SelectMedKit()
  local MedsPanel = UIManager.GetUI(UIManager.UI_Config_InGame.MedicineChooseWidgetNew)
  if MedsPanel then
    if CircleChooseUtil.IsCurrentWeaponMatchID(601006) then
      CircleChooseUtil.OnUseFistByRing()
    else
      MedsPanel.RingList[0]:HandleSlotChosen()
    end
  end
end
function InputFunctionMap.SelectFirstAidKit()
  local MedsPanel = UIManager.GetUI(UIManager.UI_Config_InGame.MedicineChooseWidgetNew)
  if MedsPanel then
    if CircleChooseUtil.IsCurrentWeaponMatchID(601005) then
      CircleChooseUtil.OnUseFistByRing()
    else
      MedsPanel.RingList[2]:HandleSlotChosen()
    end
  end
end
function InputFunctionMap.SelectBandages()
  local MedsPanel = UIManager.GetUI(UIManager.UI_Config_InGame.MedicineChooseWidgetNew)
  if MedsPanel then
    if CircleChooseUtil.IsCurrentWeaponMatchID(601004) then
      CircleChooseUtil.OnUseFistByRing()
    else
      MedsPanel.RingList[4]:HandleSlotChosen()
    end
  end
end
function InputFunctionMap.SelectEnergyDrink()
  local MedsPanel = UIManager.GetUI(UIManager.UI_Config_InGame.MedicineChooseWidgetNew)
  if MedsPanel then
    if CircleChooseUtil.IsCurrentWeaponMatchID(601001) then
      CircleChooseUtil.OnUseFistByRing()
    else
      MedsPanel.RingList[3]:HandleSlotChosen()
    end
  end
end
function InputFunctionMap.UseCurrentMedicine()
  local MedsPanel = UIManager.GetUI(UIManager.UI_Config_InGame.MedicineChooseWidgetNew)
  if MedsPanel then
    CircleChooseUtil.UseConsumableItem(MedsPanel.MySubsystem.CurrentSelectedConsumableBattleItem)
  end
end
function InputFunctionMap.SelectMelee()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(uPlayerCharacter) then
    return
  end
  local uWeaponManager = uPlayerCharacter:GetWeaponManager()
  if not Game:IsValid(uWeaponManager) then
    return
  end
  local uCurrentWeapon = uWeaponManager:GetCurrentUsingWeapon()
  if not Game:IsValid(uCurrentWeapon) or uWeaponManager:GetWeaponSlotInInventory(uCurrentWeapon) ~= UESurviveWeaponPropSlot.SWPS_MeleeWeapon then
    CircleChooseUtil.SwitchToMelee()
  else
    CircleChooseUtil.OnUseFistByRing()
  end
end
function InputFunctionMap.PressedChangeSeat()
  local VehicleControlPanel = InGameUITools.GetVehicleControlPanelLuaClass()
  if VehicleControlPanel then
    local CurrentSeatGeneralUIConfig = VehicleControlPanel.CurrentSeatGeneralUIConfig
    if CurrentSeatGeneralUIConfig then
      local CurrentSeatGeneralUI = UIManager.GetUI(CurrentSeatGeneralUIConfig)
      if CurrentSeatGeneralUI and CurrentSeatGeneralUI:IsShow() then
        CurrentSeatGeneralUI:OnPressed_Button_ChangeSeat()
      end
    end
  end
end
function InputFunctionMap.ReleasedChangeSeat()
  local VehicleControlPanel = InGameUITools.GetVehicleControlPanelLuaClass()
  if VehicleControlPanel then
    local CurrentSeatGeneralUIConfig = VehicleControlPanel.CurrentSeatGeneralUIConfig
    if CurrentSeatGeneralUIConfig then
      local CurrentSeatGeneralUI = UIManager.GetUI(CurrentSeatGeneralUIConfig)
      if CurrentSeatGeneralUI and CurrentSeatGeneralUI:IsShow() then
        CurrentSeatGeneralUI:OnReleased_Button_ChangeSeat()
      end
    end
  end
end
function InputFunctionMap.PressedCloseChangeSeat()
  local VehicleControlPanel = InGameUITools.GetVehicleControlPanelLuaClass()
  if VehicleControlPanel then
    local CurrentSeatGeneralUIConfig = VehicleControlPanel.CurrentSeatGeneralUIConfig
    if CurrentSeatGeneralUIConfig then
      local CurrentSeatGeneralUI = UIManager.GetUI(CurrentSeatGeneralUIConfig)
      if CurrentSeatGeneralUI and CurrentSeatGeneralUI:IsShow() then
        local CurrentSeatPopupUIConfig = CurrentSeatGeneralUI.CurrentSeatPopupUIConfig
        if CurrentSeatPopupUIConfig then
          local CurrentSeatPopupUI = UIManager.GetUI(CurrentSeatPopupUIConfig)
          if CurrentSeatPopupUI and CurrentSeatPopupUI:IsShow() then
            CurrentSeatPopupUI:ClosePanel()
          end
        end
      end
    end
  end
end
function InputFunctionMap.PressedBasicSkill1()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) and Game:IsValid(MainControlBaseUI.BasicSkillsMenuUI) then
    MainControlBaseUI.BasicSkillsMenuUI:OnClickOperationItem(nil, 1)
  end
  InputFunctionMap.ReleasedFire()
end
function InputFunctionMap.PressedInteractItem()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) and Game:IsValid(MainControlBaseUI.BasicSkillsMenuUI) then
    MainControlBaseUI.BasicSkillsMenuUI:OnClickInteractItem(nil, 1)
    MainControlBaseUI.BasicSkillsMenuUI:OnPressInteractItem(nil, 1)
  end
  InputFunctionMap.ReleasedFire()
end
function InputFunctionMap.PressedExitVehicle()
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  local VehicleUserComponent = uPlayerController:GetVehicleUserComp()
  VehicleUserComponent:TryExitVehicle()
  InputFunctionMap.ReleasedFire()
end
function InputFunctionMap.PressedBasicSkill2()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) and Game:IsValid(MainControlBaseUI.BasicSkillsMenuUI) then
    MainControlBaseUI.BasicSkillsMenuUI:OnClickOperationItem(nil, 2)
  end
  InputFunctionMap.ReleasedFire()
end
function InputFunctionMap.PressedBasicSkill3()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) and Game:IsValid(MainControlBaseUI.BasicSkillsMenuUI) then
    MainControlBaseUI.BasicSkillsMenuUI:OnClickOperationItem(nil, 3)
  end
  InputFunctionMap.ReleasedFire()
end
function InputFunctionMap.PressedLeavePlane()
  local ParachutingControl = UIManager.GetUI(UIManager.UI_Config_InGame.ParachutingControl)
  if ParachutingControl then
    ParachutingControl:StartJump()
  end
end
function InputFunctionMap.PressedOpenParachute()
  local ParachutingControl = UIManager.GetUI(UIManager.UI_Config_InGame.ParachutingControl)
  if ParachutingControl then
    ParachutingControl:OpenParachute()
  end
end
function InputFunctionMap.PressedRescue()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) and Game:IsValid(MainControlBaseUI.BasicSkillsMenuUI) then
    MainControlBaseUI.BasicSkillsMenuUI:OnClickBtnRescue()
  end
  InputFunctionMap.ReleasedFire()
end
function InputFunctionMap.PressedCarryBack()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) and Game:IsValid(MainControlBaseUI.BasicSkillsMenuUI) then
    MainControlBaseUI.BasicSkillsMenuUI:OnClickCarryBackBtn()
  end
  InputFunctionMap.ReleasedFire()
end
function InputFunctionMap.PressedCancelUse()
  local CDBarUIPanel = UIManager.GetUI(UIManager.UI_Config_InGame.CDBarUIPanel)
  if CDBarUIPanel then
    CDBarUIPanel:OnClickCancelUse()
  end
end
function InputFunctionMap.PressedOpenPickUpList()
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel and Game:IsValid(PickUpListPanel.UIRoot) then
    PickUpListPanel.UIRoot.CustomizePickUpPanel_BP.ShortcutMenu_BP:OpenPickList()
  end
end
function InputFunctionMap.PressedClosePickUpList()
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel and Game:IsValid(PickUpListPanel.UIRoot) then
    PickUpListPanel.UIRoot.CustomizePickUpPanel_BP.ShortcutMenu_BP:ClosePickList()
  end
end
function InputFunctionMap.PressedPickUp(nIndex)
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel and Game:IsValid(PickUpListPanel.UIRoot) then
    PickUpListPanel:PickUpGroundItemByIndex(nIndex)
  end
end
function InputFunctionMap.PressedOpenDeathBox()
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel and Game:IsValid(PickUpListPanel.UIRoot) then
    PickUpListPanel.UIRoot.CustomizePickUpPanel_BP.ShortcutMenu_BP.PickUpBtnItem_BP:OpenDeathBox()
  end
end
function InputFunctionMap.PressedCloseDeathBox()
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel and Game:IsValid(PickUpListPanel.UIRoot) then
    PickUpListPanel.UIRoot.ShortcutMenu_BP:CloseDeathBox()
  end
end
function InputFunctionMap.PressedPickUpDeathBox(nIndex)
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel and Game:IsValid(PickUpListPanel.UIRoot) then
    PickUpListPanel:PickUpBoxItemByIndex(nIndex)
  end
end
function InputFunctionMap.GetVehicleUserComp()
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  local VehicleUserComponent = uPlayerController:GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  return VehicleUserComponent
end
function InputFunctionMap.ShouldBlockVehicleControl()
  if not Client then
    return false
  end
  local success, PlanPH_GamePlay_Tools = pcall(require, "GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if success and PlanPH_GamePlay_Tools and (PlanPH_GamePlay_Tools.IsVisitMode() or PlanPH_GamePlay_Tools.IsEditHomeMode() or PlanPH_GamePlay_Tools.IsEditPlanMode()) then
    return true
  end
  return false
end
function InputFunctionMap.PressedVehicleForward()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  VehicleUserComponent:MoveVehicleForward(1)
end
function InputFunctionMap.ReleasedVehicleForward()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  VehicleUserComponent:MoveVehicleForward(0)
end
function InputFunctionMap.PressedVehicleBackward()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  VehicleUserComponent:MoveVehicleForward(-1)
end
function InputFunctionMap.ReleasedVehicleBackward()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  VehicleUserComponent:MoveVehicleForward(0)
end
function InputFunctionMap.PressedVehicleTurnLeft()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  VehicleUserComponent:MoveVehicleRight(-1)
end
function InputFunctionMap.ReleasedVehicleTurnLeft()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  VehicleUserComponent:MoveVehicleRight(0)
end
function InputFunctionMap.PressedVehicleTurnRight()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  VehicleUserComponent:MoveVehicleRight(1)
end
function InputFunctionMap.ReleasedVehicleTurnRight()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  VehicleUserComponent:MoveVehicleRight(0)
end
function InputFunctionMap.PressedVehicleSprint()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  VehicleUserComponent:MoveVehicleForward(1.0)
  VehicleUserComponent:SetBoosting(true)
end
function InputFunctionMap.ReleasedVehicleSprint()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  VehicleUserComponent:MoveVehicleForward(0)
  VehicleUserComponent:SetBoosting(false)
end
function InputFunctionMap.PressedVehicleBrake()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local CurVehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(CurVehicle) then
    return
  end
  local MovementComponent = CurVehicle:GetMovementComponent()
  if not Game:IsValid(MovementComponent) then
    return
  end
  if MovementComponent.upInputRate then
    VehicleUserComponent:MoveVehicleUp(1.0)
  else
    VehicleUserComponent:SetBrake(1)
  end
end
function InputFunctionMap.ReleasedVehicleBrake()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  VehicleUserComponent:SetBrake(0)
end
function InputFunctionMap.LeanVehicle()
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  if VehicleUserComponent:CheckCanLeanOutVehicle() then
    VehicleUserComponent:TryLeanOutOrIn(false, false)
  else
    VehicleUserComponent:TryChangeFreeFireSeatAndLeanOut()
  end
end
function InputFunctionMap.PressedVehicleSpeaker()
  local VehicleControlPanel = InGameUITools.GetVehicleControlPanelLuaClass()
  if not VehicleControlPanel or not Game:IsValid(VehicleControlPanel) then
    return
  end
  VehicleControlPanel:SpeakerPress()
end
function InputFunctionMap.ReleasedVehicleSpeaker()
  local VehicleControlPanel = InGameUITools.GetVehicleControlPanelLuaClass()
  if not VehicleControlPanel or not Game:IsValid(VehicleControlPanel) then
    return
  end
  VehicleControlPanel:SpeakerRelease()
end
function InputFunctionMap.PressedVehicleAirControlUp()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  VehicleUserComponent:SetAirControlF(-1.0)
end
function InputFunctionMap.ReleasedVehicleAirControlUp()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  VehicleUserComponent:SetAirControlF(0)
end
function InputFunctionMap.PressedVehicleAirControlDown()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  local MovementComponent = Vehicle:GetMovementComponent()
  if not Game:IsValid(MovementComponent) then
    return
  end
  if MovementComponent.upInputRate then
    VehicleUserComponent:MoveVehicleUp(-1.0)
  else
    VehicleUserComponent:SetAirControlF(1.0)
  end
end
function InputFunctionMap.ReleasedVehicleAirControlDown()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  VehicleUserComponent:SetAirControlF(0)
end
function InputFunctionMap.PressedAircraftThrottle()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  local AircraftClass = import("VehicleAircraft")
  if Game:IsClassOf(Vehicle, AircraftClass) then
    Vehicle:SetThrottleInput(1)
  end
end
function InputFunctionMap.ReleasedAircraftThrottle()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  local AircraftClass = import("VehicleAircraft")
  if Game:IsClassOf(Vehicle, AircraftClass) then
    Vehicle:SetThrottleInput(0)
  end
end
function InputFunctionMap.PressedAircraftThrottleBackward()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  local AircraftClass = import("VehicleAircraft")
  if Game:IsClassOf(Vehicle, AircraftClass) then
    Vehicle:SetThrottleInput(-1)
  end
end
function InputFunctionMap.ReleasedAircraftThrottleBackward()
  if InputFunctionMap.ShouldBlockVehicleControl() then
    return
  end
  local VehicleUserComponent = InputFunctionMap.GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return
  end
  local Vehicle = VehicleUserComponent:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  local AircraftClass = import("VehicleAircraft")
  if Game:IsClassOf(Vehicle, AircraftClass) then
    Vehicle:SetThrottleInput(0)
  end
end
function InputFunctionMap.CloseUIByAndroidBack()
end
function InputFunctionMap.SetMouseCursorByUIState(bIsOpen)
  if bIsOpen then
    InputFunctionMap.SetMouseCursorShow()
  else
    InputFunctionMap.SetMouseCursorHide()
  end
end
function InputFunctionMap.PressedChangeThrowPlus()
  local ShootingUIPanel = InGameUITools.GetShootingUIPanelLuaClass()
  if Game:IsValid(ShootingUIPanel) then
    ShootingUIPanel:OnClickThrowPlus()
  end
end
function InputFunctionMap.PressedTransform()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local PlayerController = GameplayData.GetPlayerController()
  KismetSystemLibrary.ExecuteConsoleCommand(PlayerController, "CallGMLua Transform", nil)
end
return InputFunctionMap