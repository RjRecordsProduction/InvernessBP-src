local Common_ComboBox_UIBP = {}
local EArrowStyle = {Default = 1, Change = 2}
local ArrowPath = {
  [EArrowStyle.Default] = {
    Expand = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Unfold_02_png.Common_Icon_Unfold_02_png",
    Normal = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Unfold_png.Common_Icon_Unfold_png"
  },
  [EArrowStyle.Change] = {
    Expand = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Change_png.Common_Icon_Change_png",
    Normal = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Change_png.Common_Icon_Change_png"
  }
}
function Common_ComboBox_UIBP:ctor(_, bgPath, bWow, extraData)
  self.bIsOpen = false
  self.bIsNew = true
  self._data = nil
  self._selectIndex = 0
  self.  self.  self.arrowStyle = extraData and extraData.arrowStyle or EArrowStyle.Default
  if not ArrowPath[self.arrowStyle] then
    self.arrowStyle = EArrowStyle.Default
  end
end
function Common_ComboBox_UIBP:OnInitialize()
  Common_ComboBox_UIBP.__super.OnInitialize(self)
  self.TextBlock_ItemName = self.UIRoot.NamedSlot_Content:GetContent().TextBlock_ItemName
end
function Common_ComboBox_UIBP:RegistEvents()
  Common_ComboBox_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Switch, self._OnButton_SwitchClick, self)
end
function Common_ComboBox_UIBP:OnPostInitialize()
  Common_ComboBox_UIBP.__super.OnPostInitialize(self)
  self:SetBgColor(1, 1, 1, 1)
  self:CloseComboBox()
end
function Common_ComboBox_UIBP:OnClose()
  UIManager.CloseUI(UIManager.UI_Config.Common_ComboBox_List)
  Common_ComboBox_UIBP.__super.OnClose(self)
end
function Common_ComboBox_UIBP:_OnButton_SwitchClick()
  log(bWriteLog and "Common_ComboBox_UIBP:_OnButton_SwitchClick")
  if not self.bIsOpen then
    self:PlayAudio(sound_config.menu_open)
    self.bIsOpen = true
    local expandArrowPath = ArrowPath[self.arrowStyle].Expand
    self:SetTexture(self.UIRoot.Image_Arrow, expandArrowPath)
    UIManager.ShowUI(UIManager.UI_Config.Common_ComboBox_List, self, self.bgPath)
  else
    self:PlayAudio(sound_config.menu_close)
    self:CloseComboBox()
  end
  local func = self.OnOpenStateChangedEvent
  if func then
    func(self.bIsOpen)
  end
end
function Common_ComboBox_UIBP:SetData(arrayData, initialIndex, bSkipSelectCallback)
  self._data = arrayData
  self._selectIndex = initialIndex or 0
  self:SelectIndex(self._selectIndex, bSkipSelectCallback)
end
function Common_ComboBox_UIBP:SetRefreshOptionCallback(callback, funcSelf)
  function self.OnRefreshOptionEvent(...)
    return callback(funcSelf, ...)
  end
end
function Common_ComboBox_UIBP:SetSelectOptionCallback(callback, ...)
  local args = table.pack(...)
  local common = require("client.slua_ui_framework.common")
  function self.OnSelectOptionEvent(...)
    return common.CallCombinationArgs(callback, args, ...)
  end
end
function Common_ComboBox_UIBP:SetOpenStateChangedCallback(callback, ...)
  local args = table.pack(...)
  local common = require("client.slua_ui_framework.common")
  function self.OnOpenStateChangedEvent(...)
    return common.CallCombinationArgs(callback, args, ...)
  end
end
function Common_ComboBox_UIBP:SetCurrentText(text)
  if self.TextBlock_ItemName then
    self.TextBlock_ItemName:SetText(text)
  end
end
function Common_ComboBox_UIBP:GetOptionCount()
  return self:GetDataLength()
end
function Common_ComboBox_UIBP:GetOptionData(index)
  if index <= 0 or index > #self._data then
    log_warning(string.format("Common_ComboBox_UIBP:GetOptionData index[%d] out of range[1..%d]", index, #self._data))
  end
  return self._data[index]
end
function Common_ComboBox_UIBP:RefreshOptions()
  local Common_ComboBox_List = UIManager.GetUI(UIManager.UI_Config.Common_ComboBox_List)
  if Common_ComboBox_List then
    Common_ComboBox_List.LoopScrollBox_List:RefreshAllItems()
  end
end
function Common_ComboBox_UIBP:RefreshLoopData()
  local Common_ComboBox_List = UIManager.GetUI(UIManager.UI_Config.Common_ComboBox_List)
  if Common_ComboBox_List then
    Common_ComboBox_List:UpdateUI()
  end
end
function Common_ComboBox_UIBP:SelectIndex(index, bSkipCallback)
  if not index or not self._data then
    log_warning("Common_ComboBox_UIBP:SelectIndex not index or not self._data")
    return
  end
  if index <= 0 or index > #self._data then
    log_warning(string.format("Common_ComboBox_UIBP:SelectIndex index[%d] out of range[1..%d]", index, #self._data))
    return
  end
  if type(self._data[index]) == "table" and self._data[index].text then
    self:SetCurrentText(self._data[index].text)
  end
  self._selectIndex = index
  local Common_ComboBox_List = UIManager.GetUI(UIManager.UI_Config.Common_ComboBox_List)
  if Common_ComboBox_List then
    Common_ComboBox_List.LoopScrollBox_List:Select(self._selectIndex)
  end
  if bSkipCallback then
    return
  end
  if not self.UIRoot then
    return
  end
  local func = self.OnSelectOptionEvent
  if func then
    func(self.UIRoot.NamedSlot_Content:GetContent(), self:GetOptionData(index), index, self:GetSelectIndex())
  end
end
function Common_ComboBox_UIBP:SelectNone()
  local func = self.OnSelectOptionEvent
  if func then
    func(self.UIRoot, nil)
  end
end
function Common_ComboBox_UIBP:GetSelectIndex()
  return self._selectIndex
end
function Common_ComboBox_UIBP:GetSetData()
  return self._data
end
function Common_ComboBox_UIBP:GetSelectData()
  return self._data[self._selectIndex]
end
function Common_ComboBox_UIBP:GetDataLength()
  if self._data then
    return #self._data
  else
    log_warning("Common_ComboBox_UIBP:GetOptionCount no data")
    return 0
  end
end
function Common_ComboBox_UIBP:CloseComboBox()
  if self.UIRoot then
    self.bIsOpen = false
    local normalArrowPath = ArrowPath[self.arrowStyle].Normal
    self:SetTexture(self.UIRoot.Image_Arrow, normalArrowPath)
    UIManager.CloseUI(UIManager.UI_Config.Common_ComboBox_List)
    local func = self.OnOpenStateChangedEvent
    if func then
      func(self.bIsOpen)
    end
  end
end
function Common_ComboBox_UIBP:SetComboBoxLoopScrollBoxItemSize(itemSize)
  itemSize = tonumber(itemSize)
  if itemSize then
    self.LoopScrollBoxItemSize = itemSize
  end
end
function Common_ComboBox_UIBP:SetBgColor(r, g, b, a)
  if self.UIRoot and self.UIRoot.Image_bg then
    self.UIRoot.Image_bg:SetColorAndOpacity(FLinearColor(r, g, b, a))
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCommon_ComboBox_UIBP = class(ui_base, nil, Common_ComboBox_UIBP)
return CCommon_ComboBox_UIBP