local Common_ComboBox_List = {}
local C_DefaultBGPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_BG_Frame_8_png.Common_BG_Frame_8_png"
local C_DefaultSceneBGPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_BG_Frame_8_Scene_png.Common_BG_Frame_8_Scene_png"
local C_DefaultItemSceneBGPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_BG_Frame_6_Scene_png.Common_BG_Frame_6_Scene_png"
local C_DefaultItemBGPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_BG_Frame_6_png.Common_BG_Frame_6_png"
local C_WowBGPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_BG_Frame_8_Scene_png.Common_BG_Frame_8_Scene_png"
local C_WowItemBGPath = "/Game/Mod/CreativeBase/Arts/Atlas/Common_New/Frames/Common_BG_Frame_6_png.Common_BG_Frame_6_png"
local C_DefaultLoopScrollBoxItemSize = 56
function Common_ComboBox_List:ctor(_, parent, bgPath)
  self.  self.end
function Common_ComboBox_List:OnInitialize()
  Common_ComboBox_List.__super.OnInitialize(self)
  self.LoopScrollBox_List = self:InitScrollBox(self.UIRoot.LoopScrollBox_List)
  self.isScene = self.parent.UIRoot.IsScene
  self.isWow = self.parent.bWow
end
function Common_ComboBox_List:RegistEvents()
  Common_ComboBox_List.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Close, self.OnClickClose, self)
  self.LoopScrollBox_List:SetRefreshItemCallback(self.OnRefreshLoopScrollBox_ListItem, self)
  self.LoopScrollBox_List:SetCreateItemCallback(self.OnCreateLoopScrollBox_ListItem, self)
  self.LoopScrollBox_List:AddItemWidgetChildEvent("Button_Select", "OnClicked", self.OnLoopScrollBox_ListItemClicked, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_VIEWPORT_SIZE_CHANGED, self.OnScreenRatioChanged, self)
end
function Common_ComboBox_List:OnPostInitialize()
  Common_ComboBox_List.__super.OnPostInitialize(self)
  self:SetSelfButton_Close(UEnums.ESlateVisibility.Visible)
  self:UpdateUI()
end
function Common_ComboBox_List:OnClose()
  local localPos = FVector2D(0, 0)
  self.UIRoot.CanvasPanel_Cut.Slot:SetPosition(localPos)
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_THEME_NEW_REDDOT)
  Common_ComboBox_List.__super.OnClose(self)
end
function Common_ComboBox_List:UpdateUI()
  log(bWriteLog and "Common_ComboBox_List:UpdateUI")
  if self.parent.UIRoot.ItemType then
    self.UIRoot.LoopScrollBox_List:SetItemType(self.parent.UIRoot.ItemType)
  end
  if self.parent.LoopScrollBoxItemSize then
    self.LoopScrollBox_List:SetItemSize(self.parent.LoopScrollBoxItemSize)
  else
    self.LoopScrollBox_List:SetItemSize(C_DefaultLoopScrollBoxItemSize)
  end
  local data = self.parent:GetSetData()
  self.LoopScrollBox_List:SetData(self.parent:GetSetData())
  if self.parent._selectIndex > 0 then
    self.LoopScrollBox_List:ScrollToItem(self.parent._selectIndex)
  end
  self.UIRoot:SetColorAndOpacity(FLinearColor(1, 1, 1, 0))
  self:AddTimerOnce(0, function()
    self.UIRoot:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
    self:AdjustPanelSize()
    self:AdjustPanelPosition()
    self:SlidePanel()
  end)
  if self.bgPath then
    self:SetTexture(self.UIRoot.Image_1, self.bgPath)
  elseif self.isScene then
    self:SetTexture(self.UIRoot.Image_1, C_DefaultSceneBGPath)
  elseif self.isWow then
    self:SetTexture(self.UIRoot.Image_1, C_WowBGPath)
  else
    self:SetTexture(self.UIRoot.Image_1, C_DefaultBGPath)
  end
end
function Common_ComboBox_List:OnScreenRatioChanged()
  log(bWriteLog and "Common_ComboBox_List:OnScreenRatioChanged")
  self.parent:CloseComboBox()
end
function Common_ComboBox_List:AdjustPanelSize()
  log(bWriteLog and "Common_ComboBox_List:AdjustPanelSize MaxShowItemCount = " .. self.parent.UIRoot.MaxShowItemCount)
  local UIUtil = require("client.common.ui_util")
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local viewportScale = UIUtil.GetViewportScale()
  local scaledGeometry = self.UIRoot.CanvasPanel_3:GetCachedGeometry()
  local unscaledGeometry = self.UIRoot.CanvasPanel_0:GetCachedGeometry()
  local scaledpanelSize = SlateBlueprintLibrary.GetLocalSize(scaledGeometry)
  local unscaledpanelSize = SlateBlueprintLibrary.GetLocalSize(unscaledGeometry)
  self.ratioX = scaledpanelSize.X / unscaledpanelSize.X
  self.ratioY = scaledpanelSize.Y / unscaledpanelSize.Y
  local dataLength = self.parent:GetDataLength()
  local itemHeight = self.UIRoot.LoopScrollBox_List.ItemSize
  self.panelHeight = 0
  if dataLength > self.parent.UIRoot.MaxShowItemCount then
    self.panelHeight = (self.parent.UIRoot.MaxShowItemCount + 0.5) * itemHeight / self.ratioY
  else
    self.panelHeight = dataLength * itemHeight / self.ratioY
  end
  local cutPanelSize = self.UIRoot.CanvasPanel_Cut.Slot:GetSize()
  cutPanelSize.Y = self.panelHeight
  local contentPanelSize = self.UIRoot.CanvasPanel_Content.Slot:GetSize()
  contentPanelSize.Y = self.panelHeight
  local buttonGeometry = self.parent.UIRoot:GetCachedGeometry()
  local boxSize = SlateBlueprintLibrary.GetAbsoluteSize(buttonGeometry)
  cutPanelSize.X = boxSize.X / viewportScale
  cutPanelSize.X = cutPanelSize.X * self.ratioX
  cutPanelSize.Y = cutPanelSize.Y * self.ratioY
  contentPanelSize.X = contentPanelSize.X * self.ratioX
  contentPanelSize.Y = contentPanelSize.Y * self.ratioY
  self.UIRoot.CanvasPanel_Cut.Slot:SetSize(cutPanelSize)
  self.UIRoot.CanvasPanel_Content.Slot:SetSize(contentPanelSize)
end
function Common_ComboBox_List:AdjustPanelPosition()
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local UIUtil = require("client.common.ui_util")
  local viewPortScale = UIUtil.GetViewportScale()
  local viewportSize = UIUtil.GetViewportSize() / viewPortScale
  local buttonGeometry = self.parent.UIRoot:GetCachedGeometry()
  local boxSize = SlateBlueprintLibrary.GetAbsoluteSize(buttonGeometry) / viewPortScale
  local comboboxAbsolutePos = SlateBlueprintLibrary.LocalToAbsolute(self.parent.UIRoot:GetCachedGeometry(), FVector2D(0, 0))
  log(bWriteLog and "Common_ComboBox_List:AdjustPanelPosition comboboxAbsolutePos =" .. comboboxAbsolutePos:ToString())
  local comboboxLocalPos = SlateBlueprintLibrary.AbsoluteToLocal(self.UIRoot.CanvasPanel_3:GetCachedGeometry(), comboboxAbsolutePos)
  log(bWriteLog and "Common_ComboBox_List:AdjustPanelPosition comboboxLocalPos =" .. comboboxLocalPos:ToString())
  local maxPositionY = comboboxLocalPos.Y + boxSize.Y * self.ratioY + self.panelHeight * self.ratioY
  if maxPositionY < viewportSize.Y * self.ratioY then
    comboboxLocalPos.Y = comboboxLocalPos.Y + boxSize.Y * self.ratioY
    self.bIsAbove = false
  elseif comboboxLocalPos.Y > self.panelHeight * self.ratioY then
    comboboxLocalPos.Y = comboboxLocalPos.Y - self.panelHeight * self.ratioY
    self.bIsAbove = true
  else
    comboboxLocalPos.Y = viewportSize.Y * self.ratioY - self.panelHeight * self.ratioY
    self.bIsAbove = false
  end
  self.UIRoot.CanvasPanel_Cut.Slot:SetPosition(comboboxLocalPos)
  log(bWriteLog and "Common_ComboBox_List:AdjustPanelPosition comboboxLocalPos fixed =" .. comboboxLocalPos:ToString())
end
function Common_ComboBox_List:SlidePanel()
  local contentPanelHeight = self.UIRoot.CanvasPanel_Content.Slot:GetSize().Y
  if contentPanelHeight <= 0 then
    log_warning("Common_ComboBox_List:SlidePanel contentPanelHeight <= 0")
    return
  end
  local factor = self.bIsAbove and -1 or 1
  local startPosition = factor * -contentPanelHeight
  local contentOffsets = self.UIRoot.CanvasPanel_Content.Slot:GetOffsets()
  contentOffsets.Top = startPosition
  self.UIRoot.CanvasPanel_Content.Slot:SetOffsets(contentOffsets)
  local mediumPosition = startPosition / 2
  local fastSpeed = factor * contentPanelHeight / 3
  local slowSpeed = factor * contentPanelHeight / 5
  if self.slideTimer then
    self:RemoveTimer(self.slideTimer)
  end
  self.slideTimer = self:AddTimerLoop(0, function()
    local TimeUtil = require("client.common.time_util")
    local currentOffsets = self.UIRoot.CanvasPanel_Content.Slot:GetOffsets()
    if factor * currentOffsets.Top > factor * mediumPosition then
      currentOffsets.Top = currentOffsets.Top + slowSpeed
    else
      currentOffsets.Top = currentOffsets.Top + fastSpeed
    end
    if factor * currentOffsets.Top >= 0 then
      currentOffsets.Top = 0
      self.UIRoot.CanvasPanel_Content.Slot:SetOffsets(currentOffsets)
      self:RemoveTimer(self.slideTimer)
    else
      self.UIRoot.CanvasPanel_Content.Slot:SetOffsets(currentOffsets)
    end
  end, TIMER_INFINITE, 0.03)
end
function Common_ComboBox_List:OnClickClose()
  self:PlayAudio(sound_config.click_v1)
  self.parent:CloseComboBox()
end
function Common_ComboBox_List:OnCreateLoopScrollBox_ListItem(widget, index)
  log(bWriteLog and "Common_ComboBox_List:OnCreateLoopScrollBox_ListItem")
  local Image_Select = widget.Image_Select
  if Image_Select then
    if self.isScene then
      self:SetTexture(widget.Image_Select, C_DefaultItemSceneBGPath)
    elseif self.isWow then
      self:SetTexture(widget.Image_Select, C_WowItemBGPath)
    else
      self:SetTexture(widget.Image_Select, C_DefaultItemBGPath)
    end
  end
end
function Common_ComboBox_List:OnRefreshLoopScrollBox_ListItem(widget, index)
  log(bWriteLog and "Common_ComboBox_List:OnRefreshLoopScrollBox_ListItem index = " .. index)
  local isSelected = self.parent._selectIndex == index
  log(bWriteLog and "Common_ComboBox_List:OnRefreshLoopScrollBox_ListItem isSelected = ", isSelected)
  if widget.Image_Select then
    self:SetWidgetVisible(widget.Image_Select, isSelected, false)
  end
  local itemData = self.LoopScrollBox_List:GetItemData(index)
  if type(itemData) == "table" and itemData.text and widget.TextBlock_ItemName then
    widget.TextBlock_ItemName:SetText(itemData.text)
  end
  if widget.TextBlock_ItemName and widget.TextBlock_ItemName.SetColorAndOpacity then
    local textColor = FLinearColor(1, 1, 1, 1)
    if self.isScene then
      textColor = isSelected and FLinearColor(1, 1, 1, 1) or FLinearColor(1, 1, 1, 0.4)
    elseif self.isWow then
      textColor = isSelected and FLinearColor(0.57, 1, 0.92, 1) or FLinearColor(1, 1, 1, 0.7)
    else
      textColor = isSelected and FLinearColor(1, 1, 1, 1) or FLinearColor(0, 0, 0, 0.4)
    end
    widget.TextBlock_ItemName:SetColorAndOpacity(FSlateColor(textColor))
  end
  local func = self.parent.OnRefreshOptionEvent
  if func then
    func(widget, self.parent:GetOptionData(index), index, self.parent:GetSelectIndex())
  end
end
function Common_ComboBox_List:OnLoopScrollBox_ListItemClicked(widget, index)
  log(bWriteLog and "Common_ComboBox_List:OnLoopScrollBox_ListItemClicked index = " .. index)
  self:PlayAudio(sound_config.click_v1)
  self.parent:SelectIndex(index)
  self.parent:CloseComboBox()
end
function Common_ComboBox_List:SetSelfButton_Close(visible)
  self.UIRoot.Button_Close:SetWidgetVisibility(visible)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUITemplate = class(ui_base, nil, Common_ComboBox_List)
return CUITemplate