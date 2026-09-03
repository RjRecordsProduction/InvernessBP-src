local SubTabButtons_Mgr = {}
function SubTabButtons_Mgr:InitUI()
  local uiWardrobe = UIManager.GetUI(UIManager.UI_Config.wardrobe)
  if uiWardrobe and not self.uiIns then
    self.uiIns = uiWardrobe:CreateChildWindowWithLuaAndBpPath("CarButton_Slot", nil, "client.slua.umg.Wardrobe.sub_tab_buttons", "/Game/UMG/UI_BP/Wardrobe/Wardrobe_CarButton_Item.Wardrobe_CarButton_Item")
  end
end
function SubTabButtons_Mgr:ToggleChangeViewBtnDisplayByCarID(carID)
  if not self.uiIns then
    return
  end
  local LadderCarDetailConfig = require("client.slua.logic.lobby_activity.LadderCarDetailConfig")
  if LadderCarDetailConfig.IsRareCar(carID) then
    log(bWriteLog and "SubTabButtons_Mgr:ToggleChangeViewBtnDisplayByCarID to collapsed carID: " .. tostring(carID))
    self.uiIns:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    log(bWriteLog and "SubTabButtons_Mgr:ToggleChangeViewBtnDisplayByCarID to self hit test invisible carID: " .. tostring(carID))
    self.uiIns:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function SubTabButtons_Mgr:HideChangeViewButton()
  if not self.uiIns then
    log(bWriteLog and "[cw] HideChangeViewButton(), self.uiIns is nil ")
    return
  end
  log(bWriteLog and "[cw] ShowChangeViewButton() set change view to collapsed")
  self.uiIns:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function SubTabButtons_Mgr:ShowChangeViewButton()
  if not self.uiIns then
    log(bWriteLog and "[cw] ShowChangeViewButton(), self.uiIns is nil ")
    return
  end
  log(bWriteLog and "[cw] ShowChangeViewButton() set change view to self hit test invisible")
  self.uiIns:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function SubTabButtons_Mgr:CheckShowVehicleCabrioletButton(vehicleId)
  local uiWardrobe = UIManager.GetUI(UIManager.UI_Config.wardrobe)
  if not uiWardrobe or not uiWardrobe.UIRoot then
    return
  end
  local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
  local LadderCarDetailConfig = require("client.slua.logic.lobby_activity.LadderCarDetailConfig")
  local bShow = not LadderCarDetailConfig.IsRareCar(vehicleId) and VehiclePlateLicenseUtil.CheckIsCabrioLetVehicle(vehicleId)
  if not bShow then
    uiWardrobe.UIRoot.CanvasPanel_CarCabriolet:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  uiWardrobe.UIRoot.CanvasPanel_CarCabriolet:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if not self.CabrioletBtnUI then
    self.CabrioletBtnUI = uiWardrobe:CreateChildWindowWithLuaAndBpPath("CanvasPanel_CarCabriolet", nil, "client.slua.umg.vehicle.Item.Vehicle_Cabriolet_Button_Item", "/Game/UMG/UI_BP/Vehicle/CollectItem/Vehicle_CarButton_Item.Vehicle_CarButton_Item")
  end
  self.CabrioletBtnUI:SetVehicleData()
end
function SubTabButtons_Mgr:HideVehicleCabrioletButton()
  local uiWardrobe = UIManager.GetUI(UIManager.UI_Config.wardrobe)
  if not uiWardrobe or not uiWardrobe.UIRoot then
    return
  end
  uiWardrobe.UIRoot.CanvasPanel_CarCabriolet:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function SubTabButtons_Mgr:SetBtnInitStatus()
  if self.uiIns and self.uiIns.UIRoot then
    self.uiIns.UIRoot.WidgetSwitcher_CarView:SetActiveWidgetIndex(1)
  end
end
function SubTabButtons_Mgr:ClearIns()
  self.uiIns = nil
  self.CabrioletBtnUI = nil
end
return SubTabButtons_Mgr