local SettingSaveToCloud_TipsUIBP = {}
function SettingSaveToCloud_TipsUIBP:ctor(_, ContentText, ConfirmFunc)
  self.  self.end
function SettingSaveToCloud_TipsUIBP:OnInitialize()
  self.Common_Popup_Small_UIBP = self:InitCommonPopup(self.UIRoot.Common_Popup_Small_UIBP)
  self.Common_Popup_Small_UIBP:SetData(self, LocUtil.GetLocalizeResStr(14040), {showCloseBtn = true})
end
function SettingSaveToCloud_TipsUIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Confirm, self.OnButton_ConfirmClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Cancel, self.OnButton_CloseClick, self)
end
function SettingSaveToCloud_TipsUIBP:OnShow()
  self.UIRoot.UTRichTextBlock_0:SetText(self.ContentText)
end
function SettingSaveToCloud_TipsUIBP:OnButton_ConfirmClick()
  self:PlayAudio(sound_config.click)
  if self.ConfirmFunc then
    self.ConfirmFunc()
  end
  UIManager.CloseUI(UIManager.UI_Config.Setting_Cloud_Manage_Popups_UIBP)
  self:CloseSelf()
end
function SettingSaveToCloud_TipsUIBP:OnButton_CloseClick()
  self:PlayAudio(sound_config.click)
  self:CloseSelf()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CSettingSaveToCloud_TipsUIBP = class(ui_base, nil, SettingSaveToCloud_TipsUIBP)
return CSettingSaveToCloud_TipsUIBP