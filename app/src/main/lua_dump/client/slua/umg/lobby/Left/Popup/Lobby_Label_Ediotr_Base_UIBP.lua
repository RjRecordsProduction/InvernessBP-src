local Lobby_Label_Ediotr_Base_UIBP = {}
function Lobby_Label_Ediotr_Base_UIBP:ctor()
end
function Lobby_Label_Ediotr_Base_UIBP:OnInitialize()
  Lobby_Label_Ediotr_Base_UIBP.__super.OnInitialize(self)
  self.extendedScrollBox = self:InitScrollBox(self.UIRoot.LoopScrollGrid_0)
  self.Common_ComboBox_Data = self:InitCommonComboBoxNew(self.UIRoot.Common_ComboBox_UIBP)
  self.Common_Popup_Medium_UIBP = self:InitCommonPopup(self.UIRoot.Common_Popup_Medium_UIBP)
end
function Lobby_Label_Ediotr_Base_UIBP:RegistEvents()
  Lobby_Label_Ediotr_Base_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_OK, self.OnClickOKButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Cancel, self.OnClickCancelButton, self)
  self.extendedScrollBox:SetRefreshItemCallback(self.OnRefreshItem, self)
  self.extendedScrollBox:AddItemWidgetChildEvent("Checkbox_Select", "OnCheckStateChanged", self.OnCheckStateChanged, self)
  self.Common_ComboBox_Data:SetSelectOptionCallback(self.OnSelectLabelComboBoxItem, self)
  self.Common_ComboBox_Data:SetRefreshOptionCallback(self.OnReFreshLabelComboBoxItem, self)
  self:AddOnClickedEventByControl(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_12, self.OnClickViewChangeButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_0, self.OnBtnViewChangeClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_4, self.OnBtnViewChangeClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_6, self.OnClickSingleMode, self)
  self:AddOnClickedEventByControl(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_8, self.OnClickDoubleMode, self)
  self:AddOnClickedEventByControl(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_10, self.OnClickTeamMode, self)
  self:AddOnClickedEventByControl(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_1, self.OnClickViewButton, self)
end
function Lobby_Label_Ediotr_Base_UIBP:OnPostInitialize()
  Lobby_Label_Ediotr_Base_UIBP.__super.OnPostInitialize(self)
  self:UpdateUI()
end
function Lobby_Label_Ediotr_Base_UIBP:UpdateUI()
  self.selectCnt = self:CalculateSelectCnt()
  self:InitData()
  self:RefreshSelectNumUI()
  self:SetNewTap()
  if self.UIRoot.CardLabel_Popup_Item_UIBP then
    self:SetWidgetVisible(self.UIRoot.CardLabel_Popup_Item_UIBP, true)
    self.UIRoot.CardLabel_Popup_Item_UIBP.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CardLabel_Popup_Item_UIBP.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CardLabel_Popup_Item_UIBP.WidgetSwitcher_7:SetActiveWidgetIndex(0)
  end
  self.Common_Popup_Medium_UIBP:SetData(self, LocUtil.GetLocalizeResStr(45942))
end
function Lobby_Label_Ediotr_Base_UIBP:CalculateSelectCnt()
  local cnt = 0
  for _, tagList in ipairs(self.AllTagList) do
    for _, value in pairs(tagList) do
      if value.selected then
        cnt = cnt + 1
        log(bWriteLog and "CalculateSelectCnt selected : " .. value.titleID)
      end
    end
  end
  return cnt
end
function Lobby_Label_Ediotr_Base_UIBP:InitData()
  self.isInit = false
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  self.bCheckCanPlayPeakGame = LogicPeakGame:CheckCanPlayPeakGame()
  local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
  local LogicPeakGameSegmentType = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameSegmentType)
  self.segment_show_type = LogicPeakGameSegmentType:GetSegmentShowType()
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local config = {}
  if self.bCheckCanPlayPeakGame and self.segment_show_type == PeakGameConfig.EnumSegmentShowType.PeakGame then
    config = {
      LocUtil.LocalizeResFormat(46063),
      LocUtil.GetLocalizeResStr(641)
    }
  else
    config = {
      LocUtil.LocalizeResFormat(45893),
      LocUtil.GetLocalizeResStr(641)
    }
  end
  self.Common_ComboBox_Data:SetData(config)
  if self.segment_show_type == PeakGameConfig.EnumSegmentShowType.Rank and self.selectDataIndex == 3 then
    self.selectDataIndex = 1
  elseif self.segment_show_type == PeakGameConfig.EnumSegmentShowType.PeakGame and self.selectDataIndex == 3 then
    self.selectDataIndex = 1
  end
  self.Common_ComboBox_Data:SelectIndex(self.selectDataIndex)
  local cardConfig = require("client.slua.umg.PersonSpace.Card.Card_Config")
  self.ViewMode = cardConfig.IndexToMode[self.selectModeIndex].ViewMode
  self.TeamSize = cardConfig.IndexToMode[self.selectModeIndex].TeamSize
  self:UpdateLabelData()
  self.isInit = true
end
function Lobby_Label_Ediotr_Base_UIBP:UpdateLabelData()
  if self.isInit then
    for _, tagList in pairs(self.AllTagList) do
      for _, value in pairs(tagList) do
        value.selected = false
      end
    end
    self.selectCnt = self:CalculateSelectCnt()
    self:RefreshSelectNumUI()
  end
  self:SetTagData()
end
function Lobby_Label_Ediotr_Base_UIBP:SetTagData()
  log(bWriteLog and "Lobby_Label_Ediotr_Base_UIBP:SetTagData")
  local index = self:GetIndex()
  self.extendedScrollBox:SetData(self.AllTagList[index])
end
function Lobby_Label_Ediotr_Base_UIBP:GetIndex()
  local index = 1
  if self.ViewMode == 1 then
    index = self.TeamSize
  elseif self.ViewMode == 2 then
    index = self.TeamSize + 3
  end
  return index
end
function Lobby_Label_Ediotr_Base_UIBP:OnRefreshItem(widget, index)
  local itemData = self.extendedScrollBox:GetItemData(index)
  local content = self:GetContent(itemData, index)
  widget.TextBlock_0:SetText(content)
  if itemData.selected then
    widget.Checkbox_Select:SetCheckedState(1)
    widget.Checkbox_Select:SetIsEnabled(true)
  else
    widget.Checkbox_Select:SetCheckedState(0)
    widget.Checkbox_Select:SetIsEnabled(self.selectCnt < self.EMaxCount)
  end
end
function Lobby_Label_Ediotr_Base_UIBP:OnCheckStateChanged(widget, nIndex)
  self:PlayAudio(sound_config.click_v1)
  local bIsCheck = widget.Checkbox_Select:GetCheckedState() == 1
  if bIsCheck and self.selectCnt >= self.EMaxCount then
    log(bWriteLog and "Lobby_Label_Ediotr_Base_UIBP:OnCheckStateChanged,self.selectCnt >= self.EMaxCount")
    self.extendedScrollBox:RefreshItem(nIndex)
    return
  end
  local index = self:GetIndex()
  local tagList = self.AllTagList[index]
  for index, value in pairs(tagList) do
    if index == nIndex then
      value.selected = bIsCheck
      self.selectCnt = self:CalculateSelectCnt()
      self.extendedScrollBox:RefreshAllItems()
      self:RefreshSelectNumUI()
      return
    end
  end
end
function Lobby_Label_Ediotr_Base_UIBP:OnSelectLabelComboBoxItem(widget, data, index)
  self.selectDataIndex = index
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  if self.bCheckCanPlayPeakGame and self.segment_show_type == PeakGameConfig.EnumSegmentShowType.PeakGame and self.selectDataIndex == 1 then
    self.ViewMode = 1
    self.TeamSize = 3
    self:SetNewTap()
  end
  if self.isInit then
    for _, tagList in pairs(self.AllTagList) do
      for _, value in pairs(tagList) do
        value.selected = false
      end
    end
    self.selectCnt = self:CalculateSelectCnt()
    self:RefreshSelectNumUI()
    self:PlayAudio(sound_config.popup_v1)
  end
  widget.TextBlock_ItemName:SetText(data or "")
  self:UpdateLabelData()
end
function Lobby_Label_Ediotr_Base_UIBP:OnReFreshLabelComboBoxItem(widget, data)
  widget.TextBlock_ItemName:SetText(data or "")
end
function Lobby_Label_Ediotr_Base_UIBP:RefreshSelectNumUI()
  self.UIRoot.UTRichTextBlock_0:SetText(LocUtil.LocalizeResFormat(45929, self.selectCnt, self.EMaxCount))
end
function Lobby_Label_Ediotr_Base_UIBP:OnBtnViewChangeClick()
  self:PlayAudio(sound_config.click_v1)
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  if self.bCheckCanPlayPeakGame and self.segment_show_type == PeakGameConfig.EnumSegmentShowType.PeakGame and self.selectDataIndex == 1 then
    ShowNotice(68210)
    return
  end
  self.ViewMode = self.ViewMode == 1 and 2 or 1
  self:SetNewTap()
  self:UpdateLabelData()
end
function Lobby_Label_Ediotr_Base_UIBP:OnClickSingleMode()
  self:PlayAudio(sound_config.click_v1)
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  if self.bCheckCanPlayPeakGame and self.segment_show_type == PeakGameConfig.EnumSegmentShowType.PeakGame and self.selectDataIndex == 1 then
    ShowNotice(68210)
    return
  end
  self.TeamSize = 1
  self:SetNewTap()
  self:UpdateLabelData()
end
function Lobby_Label_Ediotr_Base_UIBP:OnClickDoubleMode()
  self:PlayAudio(sound_config.click_v1)
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  if self.bCheckCanPlayPeakGame and self.segment_show_type == PeakGameConfig.EnumSegmentShowType.PeakGame and self.selectDataIndex == 1 then
    ShowNotice(68210)
    return
  end
  self.TeamSize = 2
  self:SetNewTap()
  self:UpdateLabelData()
end
function Lobby_Label_Ediotr_Base_UIBP:OnClickTeamMode()
  self:PlayAudio(sound_config.click_v1)
  self.TeamSize = 3
  self:SetNewTap()
  self:UpdateLabelData()
end
function Lobby_Label_Ediotr_Base_UIBP:OnClickViewChangeButton()
  self:PlayAudio(sound_config.popup_v1)
  self:ResetButtonState()
end
function Lobby_Label_Ediotr_Base_UIBP:OnClickViewButton()
  self:PlayAudio(sound_config.click_v1)
  self:ResetButtonState()
end
function Lobby_Label_Ediotr_Base_UIBP:ResetButtonState()
  if self.UIRoot.CardLabel_Popup_Item_UIBP.CanvasPanel_1:GetVisibility() == UEnums.ESlateVisibility.Collapsed then
    self.UIRoot.CardLabel_Popup_Item_UIBP.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.CardLabel_Popup_Item_UIBP.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.CardLabel_Popup_Item_UIBP.WidgetSwitcher_7:SetActiveWidgetIndex(1)
  else
    self.UIRoot.CardLabel_Popup_Item_UIBP.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CardLabel_Popup_Item_UIBP.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CardLabel_Popup_Item_UIBP.WidgetSwitcher_7:SetActiveWidgetIndex(0)
  end
end
function Lobby_Label_Ediotr_Base_UIBP:SetNewTap()
  if self.UIRoot.CardLabel_Popup_Item_UIBP then
    local localizeIndex = self.ViewMode == 1 and "100054" or "100053"
    local SizeText = ""
    if self.TeamSize == 1 then
      SizeText = 100030
    elseif self.TeamSize == 2 then
      SizeText = 100031
    else
      SizeText = 100032
    end
    self.UIRoot.CardLabel_Popup_Item_UIBP.TextBlock_20:SetText(LocUtil.LocalizeResFormat(87974, LocUtil.GetLocalizeResStr(localizeIndex), LocUtil.GetLocalizeResStr(SizeText)))
    self.UIRoot.CardLabel_Popup_Item_UIBP.WidgetSwitcher_0:SetActiveWidgetIndex(self.ViewMode == 2 and 1 or 0)
    self.UIRoot.CardLabel_Popup_Item_UIBP.WidgetSwitcher_1:SetActiveWidgetIndex(self.ViewMode == 1 and 1 or 0)
    self.UIRoot.CardLabel_Popup_Item_UIBP.WidgetSwitcher_2:SetActiveWidgetIndex(self.TeamSize == 1 and 1 or 0)
    self.UIRoot.CardLabel_Popup_Item_UIBP.WidgetSwitcher_4:SetActiveWidgetIndex(self.TeamSize == 2 and 1 or 0)
    self.UIRoot.CardLabel_Popup_Item_UIBP.WidgetSwitcher_5:SetActiveWidgetIndex(self.TeamSize == 3 and 1 or 0)
  end
end
function Lobby_Label_Ediotr_Base_UIBP:OnClickOKButton()
  self:PlayAudio(sound_config.click)
  self:ClickOKFunc()
end
function Lobby_Label_Ediotr_Base_UIBP:OnClickCancelButton()
  self:PlayAudio(sound_config.click)
  self:ClickCancelFunc()
end
function Lobby_Label_Ediotr_Base_UIBP:ClickOKFunc()
end
function Lobby_Label_Ediotr_Base_UIBP:ClickCancelFunc()
end
function Lobby_Label_Ediotr_Base_UIBP:GetContent()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_Label_Ediotr_Base_UIBP = class(ui_base, nil, Lobby_Label_Ediotr_Base_UIBP)
return CLobby_Label_Ediotr_Base_UIBP