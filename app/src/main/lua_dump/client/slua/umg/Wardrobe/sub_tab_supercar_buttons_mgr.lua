local SuperCarSubTabButtons_Mgr = {}
function SuperCarSubTabButtons_Mgr:CreateButtonAndAttachToParent(parent, parentNode)
  if not self.superCarBtnUI and parent and parentNode then
    self.superCarBtnUI = parent:CreateChildWindow(parentNode, UIManager.UI_Config.sub_tab_supercar_buttons)
    self.superCarBtnUI:SetAutoSize(true)
  end
  if self.superCarBtnUI then
    self.superCarBtnUI:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if SuperCarSubTabButtons_Mgr.cache_carID ~= 0 then
    SuperCarSubTabButtons_Mgr:ToggleDoorBtnDisplayByCarID(SuperCarSubTabButtons_Mgr.cache_carID)
  end
end
function SuperCarSubTabButtons_Mgr:ToggleDoorBtnDisplayByCarID(carID)
  if not self.superCarBtnUI then
    SuperCarSubTabButtons_Mgr.cache_carID = carID or 0
    log(bWriteLog and "[cw] self.superCarBtnUI is nil ")
    return
  end
  local LadderCarDetailConfig = require("client.slua.logic.lobby_activity.LadderCarDetailConfig")
  if LadderCarDetailConfig.IsRareCar(carID) then
    self.superCarBtnUI:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.superCarBtnUI:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function SuperCarSubTabButtons_Mgr:ShowDoorViewButtons()
  if self.superCarBtnUI then
    self.superCarBtnUI:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function SuperCarSubTabButtons_Mgr:HideDoorViewButtons()
  if self.superCarBtnUI then
    self.superCarBtnUI:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function SuperCarSubTabButtons_Mgr:ClearIns()
  self.superCarBtnUI = nil
end
return SuperCarSubTabButtons_Mgr