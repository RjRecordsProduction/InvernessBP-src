local custom_combobox = {}
local string_format = string.format
local table_pack = table.pack
local local local local local slua_isValid = slua.isValid
local local local local 
function custom_combobox:ctor()
  self.OnRefreshOptionEvent = nil
  self.OnSelectOptionEvent = nil
  self.OnOpenStateChangedEvent = nil
  self._data = nil
  self._selectIndex = 0
  self.bHasPlayAni = {}
end
function custom_combobox:RegistEvents()
  custom_combobox.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot, "OnRefreshItem", self._OnRefreshItem, self)
  self:AddControlEventByControl(self.UIRoot, "OnSelectItem", self._OnItemSelected, self)
  self:AddControlEventByControl(self.UIRoot, "OnOpenChanged", self._OnItemOpenChanged, self)
  local logic_comp_combobox = require("client.slua.logic.clicker.logic_comp_combobox")
  logic_comp_combobox.AddCombobox(self)
end
function custom_combobox:OnClose()
  local logic_comp_combobox = require("client.slua.logic.clicker.logic_comp_combobox")
  logic_comp_combobox.RemoveCombobox(self)
end
function custom_combobox:_OnRefreshItem(widget, index)
  log(bWriteLog and "custom_combobox:_OnRefreshItem index = " .. index)
  index = tonumber(index)
  if widget.ComboBox_Comp_Empty_Item then
    self:AddControlEventByControl(widget.ComboBox_Comp_Empty_Item, "TouchStartEventDispatcher", self._OnItemPressed, self, widget, index)
    self.bHasCompEmptyItem = true
  else
    self.bHasCompEmptyItem = false
  end
  if index then
    self:Update_Image_Select(widget, index)
    local func = self.OnRefreshOptionEvent
    if func then
      func(widget, self._data[index], index, self._selectIndex)
    end
    if widget.fadein and not self.bHasPlayAni[index] then
      self:PlayWidgetAnimation(widget, widget.fadein, 0, 1, 0, 1)
      self.bHasPlayAni[index] = true
    end
  end
end
function custom_combobox:_OnItemPressed(widget, index)
  log(bWriteLog and "custom_combobox:_OnItemPressed index = " .. index)
  widget.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local logic_comp_combobox = require("client.slua.logic.clicker.logic_comp_combobox")
  logic_comp_combobox.ProcPressCombobox()
end
function custom_combobox:Update_Image_Select(widget, index)
  if widget.Image_Select then
    log(bWriteLog and "custom_combobox:Update_Image_Select index = " .. tostring(index) .. " self._selectIndex = " .. tostring(self._selectIndex))
    if self._selectIndex == index then
      widget.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      widget.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function custom_combobox:_OnItemSelected(widget, index)
  log(bWriteLog and "custom_combobox:_OnItemSelected index = " .. index)
  index = tonumber(index)
  if index then
    self._selectIndex = index
    local func = self.OnSelectOptionEvent
    if func then
      func(widget, self._data[index], index, self._selectIndex)
    end
  end
end
function custom_combobox:_OnItemOpenChanged(bIsOpen, bAbove)
  log(bWriteLog and "custom_combobox:_OnItemOpenChanged bIsOpen: " .. tostring(bIsOpen) .. " bAbove: " .. tostring(bAbove))
  self.  if bIsOpen then
    self:RefreshOptions()
  else
    self.bHasPlayAni = {}
  end
  local func = self.OnOpenStateChangedEvent
  if func then
    func(bIsOpen, bAbove)
  end
end
function custom_combobox:SetRefreshOptionCallback(callback, funcSelf)
  function self.OnRefreshOptionEvent(...)
    return callback(funcSelf, ...)
  end
end
function custom_combobox:SetSelectOptionCallback(callback, ...)
  local args = table_pack(...)
  local common = require("client.slua_ui_framework.common")
  function self.OnSelectOptionEvent(...)
    return common.CallCombinationArgs(callback, args, ...)
  end
end
function custom_combobox:SetOpenStateChangedCallback(callback, ...)
  local args = table_pack(...)
  local common = require("client.slua_ui_framework.common")
  function self.OnOpenStateChangedEvent(...)
    return common.CallCombinationArgs(callback, args, ...)
  end
end
function custom_combobox:SetData(arrayData)
  if self.OnRefreshOptionEvent == nil then
    log_error("custom_combobox:SetData Must set call SetRefreshOptionCallback before SetData!")
  end
  self._data = arrayData
  self._selectIndex = 0
  self.UIRoot:ClearOptions()
  for i, _ in ipairs(arrayData) do
    self.UIRoot:AddOption(i)
  end
end
function custom_combobox:GetOptionCount()
  return self.UIRoot:GetOptionCount()
end
function custom_combobox:GetOptionData(index)
  if not self._data then
    log_warning("custom_combobox:GetOptionData _data is nil!")
    return nil
  end
  if index <= 0 or index > #self._data then
    log_warning(string_format("custom_combobox:GetOptionData index[%d] out of range[1..%d]", index, #self._data))
  end
  return self._data[index]
end
function custom_combobox:RefreshOptions()
  if not self.UIRoot then
    return
  end
  self.UIRoot:RefreshOptions()
end
function custom_combobox:SelectIndex(index)
  if index <= 0 or index > #self._data then
    log_warning(string_format("custom_combobox:SelectIndex index[%d] out of range[1..%d]", index, #self._data))
  end
  self.UIRoot:SetSelectedOption(index)
end
function custom_combobox:SelectNone()
  if self.UIRoot.ContentWidget then
    local func = self.OnSelectOptionEvent
    if func then
      func(self.UIRoot.ContentWidget, nil)
    end
  end
end
function custom_combobox:SetHasDownArrow(hasDownArrow)
  log(bWriteLog and "SetHasDownArrow:" .. tostring(hasDownArrow))
  local WidgetStyle = self.UIRoot.WidgetStyle
  local newComboButtonStyle = WidgetStyle.ComboButtonStyle
  local newSlateBrush = newComboButtonStyle.DownArrowImage
  local ESlateBrushDrawType = import("ESlateBrushDrawType")
  if hasDownArrow then
    newSlateBrush.DrawAs = ESlateBrushDrawType.Image
  else
    newSlateBrush.DrawAs = ESlateBrushDrawType.NoDrawType
  end
  newComboButtonStyle.DownArrowImage = newSlateBrush
  WidgetStyle.ComboButtonStyle = newComboButtonStyle
  self.UIRoot.  if slua_isValid(self.UIRoot.OpenDownArrowImage) then
    local newOpenBrush = self.UIRoot.OpenDownArrowImage
    newOpenBrush.DrawAs = hasDownArrow and ESlateBrushDrawType.Image or ESlateBrushDrawType.NoDrawType
    self.UIRoot.OpenDownArrowImage = newOpenBrush
  end
  if slua_isValid(self.UIRoot.CloseDownArrowImage) then
    local newCloseBrush = self.UIRoot.CloseDownArrowImage
    newCloseBrush.DrawAs = hasDownArrow and ESlateBrushDrawType.Image or ESlateBrushDrawType.NoDrawType
    self.UIRoot.CloseDownArrowImage = newCloseBrush
  end
end
function custom_combobox:SetDownArrowSize(size)
  local WidgetStyle = self.UIRoot.WidgetStyle
  local newComboButtonStyle = WidgetStyle.ComboButtonStyle
  local newSlateBrush = newComboButtonStyle.DownArrowImage
  newSlateBrush.ImageSize = size
  newComboButtonStyle.DownArrowImage = newSlateBrush
  WidgetStyle.ComboButtonStyle = newComboButtonStyle
  self.UIRoot.  if slua_isValid(self.UIRoot.OpenDownArrowImage) then
    local newOpenBrush = self.UIRoot.OpenDownArrowImage
    newOpenBrush.ImageSize = size
    self.UIRoot.OpenDownArrowImage = newOpenBrush
  end
  if slua_isValid(self.UIRoot.CloseDownArrowImage) then
    local newCloseBrush = self.UIRoot.CloseDownArrowImage
    newCloseBrush.ImageSize = size
    self.UIRoot.CloseDownArrowImage = newCloseBrush
  end
end
function custom_combobox:SetDownArrowImageSlateBrush(DownArrowSlateBrush)
  if not slua_isValid(DownArrowSlateBrush) or not DownArrowSlateBrush.ResourceObject then
    log(bWriteLog and "custom_combobox:SetDownArrowImageSlateBrush DownArrowSlateBrush is invalid")
    return
  end
  local WidgetStyle = self.UIRoot.WidgetStyle
  local newComboButtonStyle = WidgetStyle.ComboButtonStyle
  local newSlateBrush = DownArrowSlateBrush
  newComboButtonStyle.DownArrowImage = newSlateBrush
  WidgetStyle.ComboButtonStyle = newComboButtonStyle
  self.UIRoot.end
function custom_combobox:GetSelectIndex()
  return self._selectIndex
end
function custom_combobox:GetSetData()
  return self._data
end
function custom_combobox:GetDataLength()
  log(bWriteLog and "custom_combobox:GetDataLength data length = " .. tostring(#self._data))
  return #self._data
end
function custom_combobox:CloseComboBox()
  if self.UIRoot and self.UIRoot.CloseComboBox then
    self.UIRoot:CloseComboBox()
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUILoopScrollBox = class(ui_base, nil, custom_combobox)
return CUILoopScrollBox