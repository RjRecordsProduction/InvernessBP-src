local UI_Connect_Wait = {bShowAnim = true, bCanCrtlFromLua = false}
function UI_Connect_Wait:ctor(selfType, bShowAnim, bImmediatelyShow, tips)
  self.  self.bImmediatelyShow = bImmediatelyShow or false
  self.extraTips = tips
end
function UI_Connect_Wait:OnPostInitialize()
  UI_Connect_Wait.__super.OnPostInitialize(self)
  self.UIRoot.BIsShowAnim = self.bShowAnim
  self.UIRoot.bImmediatelyShow = self.bImmediatelyShow
  if self.animTimer then
    self:RemoveTimer(self.animTimer)
    self.animTimer = nil
  end
  if not self.UIRoot.Reconnect_UIBP then
    return
  end
  self.UIRoot.Reconnect_UIBP.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:ShowTips(self.extraTips)
  if not self.UIRoot.BIsShowAnim then
    return
  end
  if self.UIRoot.bImmediatelyShow then
    self.bCanCrtlFromLua = true
    self.UIRoot.Reconnect_UIBP.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    self.animTimer = self:AddTimerOnce(3.0, function()
      self.bCanCrtlFromLua = true
      if self.UIRoot.Reconnect_UIBP then
        self.UIRoot.Reconnect_UIBP.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      end
    end)
  end
  self.bCanCrtlFromLua = false
end
function UI_Connect_Wait:ShowTips(text)
  if text ~= nil and text ~= "" then
    self.UIRoot.Reconnect_UIBP.TextBlock_Tips:SetText(text)
  else
    self.UIRoot.Reconnect_UIBP.TextBlock_Tips:SetText(LocUtil.GetLocalizeResStr(24684))
  end
end
function UI_Connect_Wait:SwitchAnimState(bShowAnim)
  if bShowAnim then
    if self.bCanCrtlFromLua then
      self.bCanCrtlFromLua = true
      self.UIRoot.Reconnect_UIBP.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    end
  elseif self.bCanCrtlFromLua then
    self.UIRoot.Reconnect_UIBP.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function UI_Connect_Wait:SwitchImmediatelyShow(bImmediatelyShow)
  if not self.bImmediatelyShow and bImmediatelyShow then
    self.bCanCrtlFromLua = true
    self.UIRoot.Reconnect_UIBP.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
  self.bImmediatelyShow = bImmediatelyShow or false
  self.UIRoot.bImmediatelyShow = self.bImmediatelyShow
end
function UI_Connect_Wait:OnShow()
  UI_Connect_Wait.__super.OnShow(self)
  GlobalData.SetAndroidKeyIsValid(false)
end
function UI_Connect_Wait:OnHide()
  UI_Connect_Wait.__super.OnHide(self)
  GlobalData.SetAndroidKeyIsValid(true)
  if self.animTimer then
    self:RemoveTimer(self.animTimer)
    self.animTimer = nil
  end
  if not self.UIRoot.Reconnect_UIBP then
    return
  end
  self.UIRoot.Reconnect_UIBP.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUI_Connect_Wait = class(ui_base, nil, UI_Connect_Wait)
return CUI_Connect_Wait