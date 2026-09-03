local Setting_Option_OpenWindow = {}
function Setting_Option_OpenWindow:OnInitialize()
  Setting_Option_OpenWindow.__super.OnInitialize(self)
  local titelWidget = self.Data.bReplaceTitleAndContent and self.UIRoot.Setting_Language_Item_UIBP.TextBlock_7 or self.UIRoot.Setting_Option_Base.Text
  titelWidget:SetText(LocUtil.GetLocalizeResStr(self.Data.Text))
  self:SetupHelpButton(self.UIRoot.Setting_Option_Base.Button_Help)
  self:OnRefreshOption()
end
function Setting_Option_OpenWindow:OnRefreshOption()
  local contentWidget = self.Data.bReplaceTitleAndContent and self.UIRoot.Setting_Option_Base.Text or self.UIRoot.Setting_Language_Item_UIBP.TextBlock_7
  if self.Data.GetFunc then
    contentWidget:SetText(self.Data.GetFunc())
  else
    contentWidget:SetText("")
  end
end
function Setting_Option_OpenWindow:RegistEvents()
  Setting_Option_OpenWindow.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Setting_Language_Item_UIBP.Button_Language, self.OnClickChangeBtn, self)
end
function Setting_Option_OpenWindow:OnClickChangeBtn()
  self:PlayAudio(sound_config.click_v1)
  if self.Data.SetFunc then
    self.Data.SetFunc()
  end
end
local class = require("class")
local Setting_Item_Base = require("client.slua.umg.NewSetting.Item.Setting_Item_Base")
return class(Setting_Item_Base, nil, Setting_Option_OpenWindow)