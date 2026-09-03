local LobbyChat_InformationCustomButton_UIBP = {}
function LobbyChat_InformationCustomButton_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_0, self.OnClickButtonSelect, self)
end
function LobbyChat_InformationCustomButton_UIBP:OnClickButtonSelect()
  self:PlayAudio(sound_config.click_v1)
  if self.SetSelectCallBack then
    self:SetSelectCallBack(self.index)
  end
end
function LobbyChat_InformationCustomButton_UIBP:SetSelectCallBack(index, callback)
  self.SetSelectCallBack = callback
  self.  if index == 1 then
    self.UIRoot.TextBlock_Title_1:SetText("2x2")
    self.UIRoot.TextBlock_Title_2:SetText("2x2")
    self.UIRoot.TextBlock_1:SetText("2x2")
    self.UIRoot.WidgetSwitcher_Type:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_Type1:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_2:SetActiveWidgetIndex(0)
  elseif index == 2 then
    self.UIRoot.TextBlock_Title_1:SetText("1x2")
    self.UIRoot.TextBlock_Title_2:SetText("1x2")
    self.UIRoot.TextBlock_1:SetText("1x2")
    self.UIRoot.WidgetSwitcher_Type:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_Type1:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_2:SetActiveWidgetIndex(1)
  elseif index == 3 then
    self.UIRoot.TextBlock_Title_1:SetText("1x1")
    self.UIRoot.TextBlock_Title_2:SetText("1x1")
    self.UIRoot.TextBlock_1:SetText("1x1")
    self.UIRoot.WidgetSwitcher_Type:SetActiveWidgetIndex(2)
    self.UIRoot.WidgetSwitcher_Type1:SetActiveWidgetIndex(2)
    self.UIRoot.WidgetSwitcher_2:SetActiveWidgetIndex(2)
  end
end
function LobbyChat_InformationCustomButton_UIBP:SetSelected(isSelected)
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(isSelected and 1 or 0)
end
function LobbyChat_InformationCustomButton_UIBP:SetSwitchIndex(index)
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(index)
end
local class = require("class")
local scroll_box_child_base = require("client.slua_ui_framework.component.scroll_box_child_base")
return class(scroll_box_child_base, nil, LobbyChat_InformationCustomButton_UIBP)