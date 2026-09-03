local Common_ScreenBox_UIBP = {}
function Common_ScreenBox_UIBP:ctor()
  self.data = {}
  self.defaultSelect = 1
  self.checkBoxStateChangeCB = nil
  self.clickSelectCB = nil
  self.clickClearCB = nil
  self.firstClickSelectCB = nil
  self.currentSelectIndex = 1
end
function Common_ScreenBox_UIBP:OnInitialize()
end
function Common_ScreenBox_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Select, self.OnClickButton_Select, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Clear, self.OnClickButton_Clear, self)
end
function Common_ScreenBox_UIBP:OnPostInitialize()
  self:RefreshSwitcher(true)
end
function Common_ScreenBox_UIBP:OnClickButton_Select()
  self:PlayAudio(sound_config.click_v1)
  local ui_util = require("client.common.ui_util")
  local pos = ui_util.GetWidgetViewportPos(self.UIRoot.CanvasPanel_Root)
  log(bWriteLog and "Common_ScreenBox_UIBP:OnClickButton_Select x = " .. pos.X .. " y = " .. pos.Y)
  self.listUI = UIManager.ShowUI(UIManager.UI_Config.Common_ScreenBox_List_UIBP, self.data, self.defaultSelect, self.checkBoxStateChangeCB)
  self.listUI:SetParentStateChangeCallBack(self.OnStateChange, self)
  local UIUtil = require("client.common.ui_util")
  local viewPortScale = UIUtil.GetViewportScale()
  local ViewportSize = UIUtil.GetViewportSize()
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local buttonGeometry = self.UIRoot:GetCachedGeometry()
  local boxSize = SlateBlueprintLibrary.GetAbsoluteSize(buttonGeometry)
  self:SetWidgetVisible(self.listUI.UIRoot.CanvasPanel_Cut, false)
  self:AddTimerOnce(0.1, function()
    local tool_widget_align = require("client.common.tool_widget_align")
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    local Platform = Client.GetDevicePlatformName()
    local offset = FVector2D(26, 31)
    if Platform == DevicePlatformNameMacros.IOS then
      offset = FVector2D(18, 32)
    end
    tool_widget_align.AlignWidget(self.listUI.UIRoot.CanvasPanel_Cut, self.listUI.UIRoot.CanvasPanel_Root, self.UIRoot.CanvasPanel_Root, offset)
    self:SetWidgetVisible(self.listUI.UIRoot.CanvasPanel_Cut, true)
  end)
  if self.firstClickSelectCB then
    self.firstClickSelectCB()
    self.firstClickSelectCB = nil
  end
  if self.clickSelectCB then
    self.clickSelectCB()
  end
end
function Common_ScreenBox_UIBP:OnClickButton_Clear(fromClick)
  if fromClick ~= false then
    self:PlayAudio(sound_config.click_v1)
  end
  self.currentSelectIndex = 1
  if self.clickClearCB then
    self.clickClearCB()
  end
  self:RefreshSwitcher(1)
  local defaultText = self.data and self.data[1] and self.data[1].text or ""
  self:RefreshText(defaultText)
  UIManager.CloseUI(UIManager.UI_Config.Common_ScreenBox_List_UIBP)
end
function Common_ScreenBox_UIBP:SetData(data, defaultSelect)
  self.  self.  local defaultText = self.data and self.data[1] and self.data[1].text or ""
  self:RefreshText(defaultText)
end
function Common_ScreenBox_UIBP:RefreshText(text)
  self.UIRoot.TextBlock_Name:SetText(text)
end
function Common_ScreenBox_UIBP:SetSelectIndex(index)
  self.defaultSelect = index
  self.currentSelectIndex = index
end
function Common_ScreenBox_UIBP:SetCheckBoxStateChangeCallBack(callBack, funcSelf)
  function self.checkBoxStateChangeCB(...)
    return callBack(funcSelf, ...)
  end
end
function Common_ScreenBox_UIBP:SetClickSelectCallBack(callBack, funcSelf)
  if callBack and type(callBack) == "function" then
    function self.clickSelectCB(...)
      return callBack(funcSelf, ...)
    end
  end
end
function Common_ScreenBox_UIBP:SetClearCallBack(callBack, funcSelf)
  function self.clickClearCB(...)
    return callBack(funcSelf, ...)
  end
end
function Common_ScreenBox_UIBP:SetFirstClickSelectCallBack(callBack, funcSelf)
  function self.firstClickSelectCB(...)
    return callBack(funcSelf, ...)
  end
end
function Common_ScreenBox_UIBP:GetCurrentIndex()
  return self.currentSelectIndex
end
function Common_ScreenBox_UIBP:GetSelectData()
  return self.currentSelectIndex and self.data[self.currentSelectIndex] and self.data[self.currentSelectIndex].data or {}
end
function Common_ScreenBox_UIBP:RefreshSwitcher(bShowSelect)
  self.UIRoot.WidgetSwitcher_SelectedOrClear:SetActiveWidgetIndex(bShowSelect and 0 or 1)
end
function Common_ScreenBox_UIBP:OnStateChange(index, data, isCheck)
  self:RefreshSwitcher(not isCheck)
  if isCheck then
    self:RefreshText(data.text)
    self.currentSelectIndex = index
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCommon_ScreenBox_UIBP = class(ui_base, nil, Common_ScreenBox_UIBP)
return CCommon_ScreenBox_UIBP