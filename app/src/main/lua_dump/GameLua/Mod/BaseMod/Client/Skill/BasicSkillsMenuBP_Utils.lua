local BasicSkillsMenuBP = require("GameLua.Mod.BaseMod.Client.Skill.BasicSkillsMenuBP_Config")
local GameplayStatics = import("GameplayStatics")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function BasicSkillsMenuBP:TryMegaOperator()
  local Now = GameplayStatics.GetTimeSeconds(CGameWorld)
  if Now <= self.MegaOperatorCD + self.MegaOperatorTimer then
    return
  end
  self.MegaOperatorTimer = Now
  return true
end
function BasicSkillsMenuBP:CheckColdBtn()
  if not slua.isValid(self.UIRoot) then
    return
  end
  if not self.ColdVisible then
    self.UIRoot.WidgetSwitcher_ModeSwitch:SetActiveWidgetIndex(0)
    return
  end
  local ECommonBtn = UEnums.ECommonBtn
  if self.CommonBtnType ~= ECommonBtn.None then
    self.UIRoot.WidgetSwitcher_ModeSwitch:SetActiveWidgetIndex(0)
  else
    local DoShowSKillPanel = function()
      self.UIRoot.WidgetSwitcher_ModeSwitch:SetActiveWidgetIndex(1)
      local Panel = self.UIRoot.CanvasPanel_ColdMode:GetChildAt(0)
      Panel:CheckColdSkillBtn_Lighter()
    end
    local USTExtraUIUtils = import("STExtraUIUtils")
    local uPlayerState = USTExtraUIUtils.GetCurPlayerState(self.UIRoot)
    if not slua.isValid(uPlayerState) then
      DoShowSKillPanel()
      return
    end
    local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
    if uPlayerState.LiveState == ExtraPlayerLiveState.InDefault then
      DoShowSKillPanel()
    else
      self.UIRoot.WidgetSwitcher_ModeSwitch:SetActiveWidgetIndex(0)
    end
  end
end
function BasicSkillsMenuBP:CheckColdSkillBtn()
  local Widget = self.UIRoot.CanvasPanel_ColdMode:GetChildAt(0)
  if slua.isValid(Widget) and Widget:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
    self.ColdVisible = true
  end
  self:CheckColdBtn()
end
function BasicSkillsMenuBP:GetBP_VehicleUser()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "BasicSkillsMenuBP:GetBP_VehicleUser not slua.isValid(uPlayerController)")
    return
  end
  local BP_VehicleUser_C = import("/Game/BluePrints/Core/BP_VehicleUser.BP_VehicleUser_C")
  local BP_VehicleUser = uPlayerController:GetComponentByClass(BP_VehicleUser_C)
  return BP_VehicleUser
end
function BasicSkillsMenuBP:CanShowDoorPanel()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "BasicSkillsMenuBP:CanShowDoorPanel not slua.isValid(uPlayerController)")
    return false
  end
  local uVehicleUserComponent = uPlayerController:GetVehicleUserComp()
  if uVehicleUserComponent.VehicleUserState == UEnums.ESTExtraVehicleUserState.EVUS_OutOfVehicle then
    return true
  end
  return false
end
function BasicSkillsMenuBP:GetCurrentVehicleType()
  local BP_VehicleUser = self:GetBP_VehicleUser()
  if slua.isValid(BP_VehicleUser) and slua.isValid(BP_VehicleUser.Vehicle) then
    return BP_VehicleUser.Vehicle.VehicleType
  end
end
function BasicSkillsMenuBP:CheckGridPanelDoorHide()
  if not self.LoopScrollBoxInteract then
    if slua.isValid(self.UIRoot) and slua.isValid(self.UIRoot.GridPanel_Door) then
      self.UIRoot.GridPanel_Door:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.UIRoot.CanvasPanel_InteractibleObject:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    return
  end
  if self.LoopScrollBoxInteract:GetItemCount() == 0 then
    self.UIRoot.GridPanel_Door:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_InteractibleObject:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function BasicSkillsMenuBP:CanDriveVehicle(InVehicle, InCharacter)
  local COwnerShipComponent = import("/Script/ShadowTrackerExtra.OwnershipComponent")
  local uOwnerShip = InVehicle:GetComponentByClass(COwnerShipComponent)
  if not slua.isValid(uOwnerShip) then
    return true
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return false
  end
  local uPlayerPawn = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayerPawn) then
    return false
  end
  local bCanDrive = InVehicle:CanDrive(uPlayerPawn)
  if not bCanDrive and InVehicle.CannotDriveTips ~= 0 then
    uPlayerController:DisplayGameTipWithMsgID(InVehicle.CannotDriveTips)
  end
  local sPlayerKey = InCharacter:GetPlayerKey()
  if bCanDrive and (uOwnerShip:BelongToBP(sPlayerKey) or uOwnerShip:BorrowedByBP(sPlayerKey)) then
    return true
  end
  return false
end
function BasicSkillsMenuBP:IsVehicleExclusive(InVehicle)
  local COwnerShipComponent = import("/Script/ShadowTrackerExtra.OwnershipComponent")
  local uOwnerShip = InVehicle:GetComponentByClass(COwnerShipComponent)
  if not slua.isValid(uOwnerShip) then
    return false
  end
  return uOwnerShip.bExclusive
end
function BasicSkillsMenuBP:CanPickVehicle(InVehicle)
  if not slua.isValid(InVehicle) then
    return false
  end
  local VehiclePickableComponent = InVehicle:GetPickupComponent()
  if not slua.isValid(VehiclePickableComponent) then
    return false
  end
  return VehiclePickableComponent:CanShowPickedUpButton()
end
function BasicSkillsMenuBP:GetInteractItemData()
  local InteractItemData
  local InteractItemDataPoolCount = #self.InteractItemDataPool
  if 0 < InteractItemDataPoolCount then
    InteractItemData = self.InteractItemDataPool[InteractItemDataPoolCount]
    self.InteractItemDataPool[InteractItemDataPoolCount] = nil
  else
    InteractItemData = {}
  end
  return InteractItemData
end
function BasicSkillsMenuBP:RecycleInteractItemData(InteractItemData)
  self.InteractItemDataPool[#self.InteractItemDataPool + 1] = InteractItemData
end