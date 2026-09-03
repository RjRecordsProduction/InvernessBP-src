local InputConditions = {bTestMove = true}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
function InputConditions.SwimInputCondition()
  local EPawnState = import("EPawnState")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return false
  end
  if PlayerCharacter:HasState(EPawnState.Swim) then
    return true
  end
  return false
end
function InputConditions.EntireMapCondition()
  local EntireMapUIConfig = UIManager.UI_Config_InGame.EntireMapWindow
  local EntireMapUI = UIManager.GetUI(EntireMapUIConfig)
  if EntireMapUI and UIManager.IsUIShow(EntireMapUIConfig) then
    return true
  end
  return false
end
function InputConditions.ScrollWeaponCondition()
  local Res = false
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if Game:IsValid(uPlayerCharacter) then
    local uWeaponManager = uPlayerCharacter:GetWeaponManager()
    if Game:IsValid(uWeaponManager) then
      local uCurWeapon = uPlayerCharacter:GetCurrentWeapon()
      if not Game:IsValid(uCurWeapon) then
        return true
      else
        local CurSlot = uWeaponManager:GetWeaponSlotInInventory(uCurWeapon)
        local UESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
        if CurSlot == UESurviveWeaponPropSlot.SWPS_MainShootWeapon1 or CurSlot == UESurviveWeaponPropSlot.SWPS_MainShootWeapon2 or CurSlot == UESurviveWeaponPropSlot.SWPS_SubShootWeapon or CurSlot == UESurviveWeaponPropSlot.SWPS_MeleeWeapon then
          Res = true
        end
      end
    end
    local bIsGunADS = uPlayerCharacter:IsGunADS()
    Res = Res and not bIsGunADS
  end
  Res = not InputConditions.IsShowMouseCursorCondition() and Res
  return Res
end
function InputConditions.CanCancelCondition()
  local Res = false
  local CircleChooseUtil = require("GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseUtil")
  local UAESkillManagerUtils = import("UAESkillManagerUtils")
  local EPawnState = import("EPawnState")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if Game:IsValid(uPlayerCharacter) then
    local uWeaponManager = uPlayerCharacter:GetWeaponManager()
    if Game:IsValid(uWeaponManager) then
      local uCurWeapon = uWeaponManager:GetCurrentUsingWeapon()
      if Game:IsValid(uCurWeapon) then
        if CircleChooseUtil.IsAGrenade(uCurWeapon:GetItemDefineID().TypeSpecificID) then
          Res = uPlayerCharacter:HasState(EPawnState.HoldGrenade)
        elseif CircleChooseUtil.SimMelee(uCurWeapon:GetItemDefineID().TypeSpecificID) then
          local ThrowComponent = uCurWeapon:GetComponentByClass(import("/Script/ShadowTrackerExtra.ThrowComponent"))
          if not slua.isValid(ThrowComponent) then
            return
          end
          local ThrowState = ThrowComponent:GetThrowState()
          if ThrowState == 1 or ThrowState == 2 then
            Res = true
          end
        end
      end
    end
  end
  return Res
end
function InputConditions.OnVehicleCondition()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if Game:IsValid(uPlayerCharacter) and Game:IsValid(uPlayerCharacter.CurrentVehicle) then
    return true
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if Game:IsValid(uPlayerController) then
    local uVehicleUser = uPlayerController:GetVehicleUserComp()
    if Game:IsValid(uVehicleUser) and Game:IsValid(uVehicleUser.UnmannedVehicle) then
      return true
    end
  end
  return false
end
function InputConditions.NotOnVehicleCondition()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if Game:IsValid(uPlayerCharacter) and Game:IsValid(uPlayerCharacter.CurrentVehicle) then
    return false
  end
  return true
end
function InputConditions.OnPlaneCondition()
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return false
  end
  local uPlayerState = uPlayerController.PlayerState
  if not Game:IsValid(uPlayerState) then
    return false
  end
  local LiveState = uPlayerState.LiveState
  local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
  if LiveState and LiveState == ExtraPlayerLiveState.InPlane then
    return true
  end
end
function InputConditions.ParachutingCondition()
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return false
  end
  local uPlayerState = uPlayerController.PlayerState
  if not Game:IsValid(uPlayerState) then
    return false
  end
  local LiveState = uPlayerState.LiveState
  local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
  if LiveState and LiveState == ExtraPlayerLiveState.InParachute then
    return true
  end
end
function InputConditions.BasicSkillOperationCondition()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) and Game:IsValid(MainControlBaseUI.BasicSkillsMenuUI) then
    local BasicSkillsMenuUI = MainControlBaseUI.BasicSkillsMenuUI
    return BasicSkillsMenuUI.UIRoot.GridPanel_DriveAndGetIn:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible
  end
  return false
end
function InputConditions.BasicSkillInteractCondition()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) and Game:IsValid(MainControlBaseUI.BasicSkillsMenuUI) then
    local BasicSkillsMenuUI = MainControlBaseUI.BasicSkillsMenuUI
    return BasicSkillsMenuUI.UIRoot.GridPanel_Door:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible
  end
  return false
end
function InputConditions.RescueCondition()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) and Game:IsValid(MainControlBaseUI.BasicSkillsMenuUI) and Game:IsValid(MainControlBaseUI.BasicSkillsMenuUI.UIRoot) and Game:IsValid(MainControlBaseUI.BasicSkillsMenuUI.UIRoot.BtnRescue) then
    return MainControlBaseUI.BasicSkillsMenuUI.UIRoot.BtnRescue:GetVisibility() == UEnums.ESlateVisibility.Visible
  end
  return false
end
function InputConditions.CarryBackCondition()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) and Game:IsValid(MainControlBaseUI.BasicSkillsMenuUI) and Game:IsValid(MainControlBaseUI.BasicSkillsMenuUI.UIRoot) and Game:IsValid(MainControlBaseUI.BasicSkillsMenuUI.UIRoot.Button_PutDown) then
    return MainControlBaseUI.BasicSkillsMenuUI.UIRoot.Button_PutDown:GetVisibility() == UEnums.ESlateVisibility.Visible
  end
  return false
end
function InputConditions.CancelUseCondition()
  if UIManager.GetUI(UIManager.UI_Config_InGame.CDBarUIPanel) then
    return true
  end
  return false
end
function InputConditions.VehicleDriverCondition()
  return InputConditions.OnVehicleCondition() and InGameUITools.CheckIsDriver()
end
function InputConditions.VehiclePassengerCondition()
  return InputConditions.OnVehicleCondition() and not InGameUITools.CheckIsDriver()
end
function InputConditions.CanOpenPickUpListCondition()
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel and Game:IsValid(PickUpListPanel.UIRoot) then
    local UI = PickUpListPanel.UIRoot.CustomizePickUpPanel_BP.ShortcutMenu_BP.WidgetSwitcher_0
    local nActiveIndex = UI:GetActiveWidgetIndex()
    return nActiveIndex == 0 and PickUpListPanel:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible and UI:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible
  end
  return false
end
function InputConditions.CanClosePickUpListCondition()
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel and Game:IsValid(PickUpListPanel.UIRoot) then
    local UI = PickUpListPanel.UIRoot.CustomizePickUpPanel_BP.ShortcutMenu_BP.WidgetSwitcher_0
    local nActiveIndex = UI:GetActiveWidgetIndex()
    return nActiveIndex == 1 and PickUpListPanel:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible and UI:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible
  end
  return false
end
function InputConditions.CanOpenDeathBoxCondition()
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel and Game:IsValid(PickUpListPanel.UIRoot) then
    local nActiveIndex = PickUpListPanel.UIRoot.ShortcutMenu_BP.WidgetSwitcher_1:GetActiveWidgetIndex()
    return nActiveIndex == 0 and PickUpListPanel:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible and PickUpListPanel.UIRoot.ShortcutMenu_BP.WidgetSwitcher_1:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible
  end
  return false
end
function InputConditions.CanCloseDeathBoxCondition()
  local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
  if PickUpListPanel and Game:IsValid(PickUpListPanel.UIRoot) then
    local nActiveIndex = PickUpListPanel.UIRoot.ShortcutMenu_BP.WidgetSwitcher_1:GetActiveWidgetIndex()
    return nActiveIndex == 1 and PickUpListPanel:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible and PickUpListPanel.UIRoot.ShortcutMenu_BP.WidgetSwitcher_1:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible
  end
  return false
end
function InputConditions.ChangeScopeCondition()
  return true
end
function InputConditions.IsWeaponEntityEnableScopeIn()
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
  return CurrentUsingWeapon.WeaponEntityComp.bEnableScopeIn
end
function InputConditions.VehicleCanBoostCondition()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return false
  end
  local CurrentVehicle = PlayerCharacter:GetCurrentVehicle()
  if not slua.isValid(CurrentVehicle) then
    return false
  end
  return CurrentVehicle.bCanBoostSpeed
end
function InputConditions.CanSwitchScopeCondition()
  local PModePanel = UIManager.GetUI(UIManager.UI_Config_InGame.MultiLayer_PMode_UIBP)
  if PModePanel then
    return PModePanel:IsShow()
  end
  return false
end
function InputConditions.IsShowMouseCursorCondition()
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return false
  end
  return uPlayerController.bShowMouseCursor
end
function InputConditions.IsAGrenadeCondition()
  local CircleChooseUtil = require("GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseUtil")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    local uWeaponMgr = uPlayerCharacter:GetWeaponManager()
    if slua.isValid(uWeaponMgr) then
      local uCurrentWeapon = uWeaponMgr:GetCurrentUsingWeapon()
      if slua.isValid(uCurrentWeapon) then
        local nItemID = uCurrentWeapon:GetItemDefineID().TypeSpecificID
        return CircleChooseUtil.IsAGrenade(nItemID)
      end
    end
  end
end
function InputConditions.FreeCameraCondition()
  local PlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(PlayerController) then
    return
  end
  local PlayerState = PlayerController.PlayerState
  if not Game:IsValid(PlayerState) then
    return
  end
  local LiveState = PlayerState.LiveState
  local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
  if LiveState == ExtraPlayerLiveState.InPlane then
    return false
  end
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if Game:IsValid(uPlayerCharacter) and uPlayerCharacter:IsGunADS() then
    return false
  end
  return true
end
function InputConditions.PlanPHPutCondition()
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  local bVisitMode = PlanPH_GamePlay_Tools.IsVisitMode()
  if bVisitMode then
    return false
  end
  local PlanPH_HomeArea_Manager = require("GameLua.Mod.PlanPH.Gameplay.HomeArea.PlanPH_HomeArea_Manager")
  local homeAreaInfo = PlanPH_HomeArea_Manager.GetCurHome()
  if not homeAreaInfo then
    return false
  end
  local CurEditMode = homeAreaInfo.homeEditorSystem:GetCurEditMode()
  return CurEditMode == 3 or CurEditMode == 4 or CurEditMode == 5
end
function InputConditions.CanVehicleTransform()
  local PlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(PlayerController) then
    return
  end
  local VehicleUserComp = PlayerController:GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComp) then
    return
  end
  local Vehicle = VehicleUserComp:GetVehicle()
  if not Game:IsValid(Vehicle) then
    return
  end
  local EVehicleFeatureType = import("EVehicleFeatureType")
  local TransformComponent = Vehicle:GetFeatureComponent(EVehicleFeatureType.Transform)
  return Game:IsValid(TransformComponent) and TransformComponent:IsTransformEnabled()
end
return InputConditions