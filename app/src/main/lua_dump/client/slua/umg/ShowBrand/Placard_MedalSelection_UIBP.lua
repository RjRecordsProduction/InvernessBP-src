local Placard_MedalSelection_UIBP = {}
local StringUtil = require("common.string_util")
local logic_social_battle_info = require("client.slua.logic.lobby.Left.logic_social_battle_info")
local CheckTeamName = function(txt)
  txt = StringUtil.StrTrim(txt)
  local ret, len, retStr = StringUtil.CheckName(txt, true, 20, true)
  return ret, len, retStr
end
function Placard_MedalSelection_UIBP:ctor()
  self.templateCfg = nil
  self.TemplateID = 1
  self.curEditSlotIndex = 1
  self.curEditPlacardTitleSlot = 1
  self.selectDataIndex = 1
  self.selectModeIndex = 1
  self.TeamSize = 1
  self.ViewMode = 1
  self.SelfModData = nil
end
function Placard_MedalSelection_UIBP:OnInitialize()
  self.LoopScrollBox_0 = self:InitScrollBox(self.UIRoot.LoopScrollBox_0)
  self.extendedScrollBox = self:InitScrollBox(self.UIRoot.LoopScrollGrid_1)
  self.PlacardTitleTabScrollBox = self:InitScrollBox(self.UIRoot.LoopScrollGrid_2)
  self.Common_Tab_Horizontal_LevelTwo_Text_UIBP = self:InitHorizontalLevelTwoTextTab(self.UIRoot.Common_Tab_Horizontal_LevelTwo_Text_UIBP)
  self.Common_Tab_Horizontal_LevelTwo_Text_UIBP:SetTabFixedWidth(217)
  self.Common_Tab_Horizontal_LevelTwo_Text_UIBP:SetTabFixedHeight(40)
  self.Common_ComboBox_Data = self:InitCustomComboBox(self.UIRoot.ComboBox_Season)
  self.Common_Tab_Horizontal_LevelTwo_Text_UIBP_PlacardTitle = self:InitHorizontalLevelTwoTextTab(self.UIRoot.Common_Tab_Horizontal_LevelTwo_Text_UIBP_C_0)
  self.Common_Tab_Horizontal_LevelTwo_Text_UIBP_PlacardTitle:SetTabFixedWidth(219)
  self:SetWidgetVisible(self.UIRoot.CardLabel_Popup_Item_UIBP, true)
  self.UIRoot.CardLabel_Popup_Item_UIBP.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CardLabel_Popup_Item_UIBP.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CardLabel_Popup_Item_UIBP.WidgetSwitcher_7:SetActiveWidgetIndex(0)
end
function Placard_MedalSelection_UIBP:RegistEvents()
  self.Common_Tab_Horizontal_LevelTwo_Text_UIBP:AddOnClickedCallback(self.OnClickedLevelTwoTab, self)
  self.Common_Tab_Horizontal_LevelTwo_Text_UIBP_PlacardTitle:AddOnClickedCallback(self.OnClickedLevelTwoTab, self)
  self.LoopScrollBox_0:SetRefreshItemCallback(self.OnRefreshIconItem, self)
  self.LoopScrollBox_0:AddItemWidgetChildEvent("Button_0", "OnClicked", self.OnClickIconButton, self)
  self.extendedScrollBox:SetRefreshItemCallback(self.OnRefreshTextItem, self)
  self.extendedScrollBox:AddItemWidgetChildEvent("CheckBox_Select", "OnCheckStateChanged", self.OnCheckStateChanged_TextItem, self)
  self.PlacardTitleTabScrollBox:SetRefreshItemCallback(self.OnRefreshPlacardTitleItem, self)
  self.PlacardTitleTabScrollBox:AddItemWidgetChildEvent("CheckBox_Select", "OnCheckStateChanged", self.OnCheckStateChanged_PlacardTitleItem, self)
  self:AddControlEventByControl(self.UIRoot.MultiLineEditableTextBox_Special, "OnTextChanged", self.OnTextChanged, self)
  self:AddControlEventByControl(self.UIRoot.MultiLineEditableTextBox_Special, "OnTextCommitted", self.OnTextCommitted, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Jump, self.OnClickButton_Jump, self)
  self.Common_ComboBox_Data:SetSelectOptionCallback(self.OnSelectLabelComboBoxItem, self)
  self.Common_ComboBox_Data:SetRefreshOptionCallback(self.OnReFreshLabelComboBoxItem, self)
  self:AddOnClickedEventByControl(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_12, self.OnClickViewChangeButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_0, self.OnBtnViewChangeClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_4, self.OnBtnViewChangeClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_6, self.OnClickSingleMode, self)
  self:AddOnClickedEventByControl(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_8, self.OnClickDoubleMode, self)
  self:AddOnClickedEventByControl(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_10, self.OnClickTeamMode, self)
  self:AddOnClickedEventByControl(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_1, self.OnClickViewButton, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_MINE_MODS, self.OnGetAllMetaKeyHandle, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_MOD_BATCH, self.OnNotifyReqModInfoSuccess, self)
  self:AddCommonEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_RATING_NOTIFY, self.OnPeakTimeRsp, self)
  self:AddCommonEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_INFO_UPDATE, self.OnPeakTimeRsp, self)
  self:AddCommonEvent(EVENTTYPE_PATROLLER, EVENTID_PATROLLER_UPDATE, self.OnPatrollerUpdate, self)
  self:AddCommonEvent(EVENTTYPE_PATROLLER, EVENTID_PATROLLER_STAT_UPDATE, self.OnPatrollerUpdate, self)
end
function Placard_MedalSelection_UIBP:OnPostInitialize()
  self:UpdateComboBox()
  local cardConfig = require("client.slua.umg.PersonSpace.Card.Card_Config")
  self.ViewMode = cardConfig.IndexToMode[self.selectModeIndex].ViewMode
  self.TeamSize = cardConfig.IndexToMode[self.selectModeIndex].TeamSize
end
function Placard_MedalSelection_UIBP:OnClose()
  printf("Placard_MedalSelection_UIBP:OnClose")
  self:ResetButtonState()
end
function Placard_MedalSelection_UIBP:OnReFreshLabelComboBoxItem(widget, data, index, selectIndex)
  if index == selectIndex then
    widget.TextBlock_ItemName:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
  else
    widget.TextBlock_ItemName:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 0.4)))
  end
  widget.TextBlock_ItemName:SetText(data or "")
end
function Placard_MedalSelection_UIBP:UpdateComboBox()
  local config = {
    LocUtil.LocalizeResFormat(45893),
    LocUtil.GetLocalizeResStr(641),
    LocUtil.LocalizeResFormat(46063)
  }
  local PatrollerModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PatrollerModule)
  if PatrollerModule:IsPatroller() then
    table.insert(config, LocUtil.LocalizeResFormat(24108))
  end
  self.Common_ComboBox_Data:SetData(config)
  self.Common_ComboBox_Data:SelectIndex(self.selectDataIndex)
end
function Placard_MedalSelection_UIBP:UpdateLabelData()
  printf("Placard_MedalSelection_UIBP:UpdateLabelData self.ViewMode: %s, self.TeamSize: %s", self.ViewMode, self.TeamSize)
  self.selectModeIndex = logic_social_battle_info.GetModeIndex(self.ViewMode, self.TeamSize)
  printf("Placard_MedalSelection_UIBP:UpdateLabelData DataIndex: %s, ModeIndex: %s", self.selectDataIndex, self.selectModeIndex)
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  local settings = LogicShowBrand:GetSelfSetting(self.TemplateID)
  if settings then
    local setEntry = settings[self.curEditSlotIndex]
    local id = setEntry.id
    local data_source = logic_social_battle_info.EncodeOptions(self.selectDataIndex, self.selectModeIndex, id)
    LogicShowBrand:ChangeSetting(self.TemplateID, self.curEditSlotIndex, id, nil, data_source)
  end
  self.LoopScrollBox_0:RefreshAllItems()
  if not self.templateCfg then
    return
  end
  local ShowBrandUtils = require("client.slua.logic.showbrand.ShowBrandUtils")
  local items = ShowBrandUtils.GetDataOpCfgList(self.templateCfg, self.curEditSlotIndex)
  local filteredItem = {}
  local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
  for _, v in ipairs(items) do
    if self.selectDataIndex == 4 == (ShowBrandConst.PatrollerDataType[v.ID] == true) then
      filteredItem[#filteredItem + 1] = v
    end
  end
  items = filteredItem
  self.extendedScrollBox:SetData(items)
end
function Placard_MedalSelection_UIBP:OnSelectLabelComboBoxItem(widget, data, index)
  printf("Placard_MedalSelection_UIBP:OnSelectLabelComboBoxItem data: %s, index: %s", data, index)
  self:PlayAudio(sound_config.popup_v1)
  self.selectDataIndex = index
  self:SetWidgetVisible(self.UIRoot.CardLabel_Popup_Item_UIBP, true, false)
  if self.selectDataIndex == 3 then
    self.ViewMode = 1
    self.TeamSize = 3
    self:SetNewTap()
    self:SetWidgetVisible(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_12, true, false)
  elseif self.selectDataIndex == 4 then
    self:SetWidgetVisible(self.UIRoot.CardLabel_Popup_Item_UIBP, false, false)
  else
    self:SetWidgetVisible(self.UIRoot.CardLabel_Popup_Item_UIBP.Button_12, true, true)
  end
  widget.TextBlock_ItemName:SetText(data or "")
  self:UpdateLabelData()
end
function Placard_MedalSelection_UIBP:CheckNoText(txt)
  local len = string.len(txt)
  if len == 0 then
    ShowNotice(106018)
  end
  return len == 0
end
function Placard_MedalSelection_UIBP:OnTextChanged(txt)
  if self.templateCfg == nil then
    return
  end
  if self.templateCfg.CanEdit == 0 then
    printf("Placard_MedalSelection_UIBP:OnTextCommitted CanEdit is 0")
    return
  end
  local ret, len, retStr = CheckTeamName(txt)
  self.UIRoot.MultiLineEditableTextBox_Special:SetText(retStr)
end
function Placard_MedalSelection_UIBP:OnTextCommitted(txt)
  if self.templateCfg == nil then
    return
  end
  if self.templateCfg.CanEdit == 0 then
    printf("Placard_MedalSelection_UIBP:OnTextCommitted CanEdit is 0")
    return
  end
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  local settings = LogicShowBrand:GetSelfSetting(self.TemplateID)
  local setEntry = settings[self.curEditSlotIndex]
  local curText = setEntry and setEntry.val or ""
  local ret, len, retStr = CheckTeamName(txt)
  if self:CheckNoText(retStr) then
    return
  end
  if retStr ~= curText then
    LogicShowBrand:ChangeSetting(self.TemplateID, self.curEditSlotIndex, setEntry.id, retStr)
  end
end
function Placard_MedalSelection_UIBP:OnClickIconButton(widget, index)
  self:PlayAudio(sound_config.click_v1)
  local clickId = self.LoopScrollBox_0:GetItemData(index).ID
  printf(" Placard_MedalSelection_UIBP:OnClickIconButton index: %s, clickId: %s", index, clickId)
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  local val
  local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
  if ShowBrandConst.PatrollerDataType[clickId] then
    local PatrollerModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PatrollerModule)
    val = PatrollerModule:GetPatrollerStatData(clickId)
  end
  LogicShowBrand:ChangeSetting(self.TemplateID, self.curEditSlotIndex, clickId, val)
  self.LoopScrollBox_0:RefreshAllItems()
end
function Placard_MedalSelection_UIBP:OnCheckStateChanged_TextItem(widget, index)
  self:PlayAudio(sound_config.click_v1)
  local bIsCheck = widget.Checkbox_Select:GetCheckedState() == 1
  local clickId = self.extendedScrollBox:GetItemData(index).ID
  printf(" Placard_MedalSelection_UIBP:OnCheckStateChanged_TextItem index: %s, bIsCheck: %s, clickId: %s", index, bIsCheck, clickId)
  if false == bIsCheck then
    widget.Checkbox_Select:SetCheckedState(1)
    return
  end
  local logic_social_battle_info = require("client.slua.logic.lobby.Left.logic_social_battle_info")
  local data_source = logic_social_battle_info.EncodeOptions(self.selectDataIndex, self.selectModeIndex, clickId)
  local val
  local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
  if ShowBrandConst.PatrollerDataType[clickId] then
    local PatrollerModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PatrollerModule)
    val = PatrollerModule:GetPatrollerStatData(clickId)
  end
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  LogicShowBrand:ChangeSetting(self.TemplateID, self.curEditSlotIndex, clickId, val, data_source)
  self.extendedScrollBox:RefreshAllItems()
end
function Placard_MedalSelection_UIBP:OnClickedLevelTwoTab(widget, index)
  log(bWriteLog and "Placard_MedalSelection_UIBP:OnClickedLevelTwoTab index: " .. tostring(index))
  self:PlayAudio(sound_config.tab_v1)
  local parentUI = self:GetParentUI()
  parentUI:OnSwitchToSubtab(self.TemplateID, index)
end
function Placard_MedalSelection_UIBP:OnRefreshIconItem(widget, index)
  local data = self.LoopScrollBox_0:GetItemData(index)
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  local settings = LogicShowBrand:GetSelfSetting(self.TemplateID)
  if nil == settings then
    printf("Placard_MedalSelection_UIBP:OnRefreshIconItem settings is nil. TemplateID:%s", self.TemplateID)
    return
  end
  local setEntry = settings[self.curEditSlotIndex]
  local settingId = setEntry.id
  local id = data.ID
  self:SetWidgetVisible(widget.Image_Use, settingId == id)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local nUID = tonumber(DataMgr.roleData.uid)
  local profile = logic_profile:GetLocalProfile(nUID)
  if profile then
    local ShowBrandUtils = require("client.slua.logic.showbrand.ShowBrandUtils")
    local dataVal
    local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
    if id == ShowBrandConst.ShowType.BanLevel then
      local PatrollerModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PatrollerModule)
      dataVal = PatrollerModule:GetPatrollerLevel()
    end
    ShowBrandUtils.SetMultiIconDisplay(widget, id, nUID, profile, dataVal)
  end
  local ItemName = ""
  local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
  if ShowBrandConst.IconName[id] then
    ItemName = LocUtil.GetLocalizeResStr(ShowBrandConst.IconName[id]) or ""
  end
  widget.Text_Name01:SetText(ItemName)
end
function Placard_MedalSelection_UIBP:OnRefreshTextItem(widget, index)
  local data = self.extendedScrollBox:GetItemData(index)
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  local settings = LogicShowBrand:GetSelfSetting(self.TemplateID)
  local setEntry = settings[self.curEditSlotIndex]
  local settingId = setEntry.id
  local id = data.ID
  widget.Checkbox_Select:SetCheckedState(settingId == id and 1 or 0)
  local textId = data.TextID
  local k = LocUtil.GetLocalizeResStr(textId)
  local v = 0
  local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
  if ShowBrandConst.PatrollerDataType[id] then
    local PatrollerModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PatrollerModule)
    v = PatrollerModule:GetPatrollerStatData(id)
  else
    local logic_social_battle_info = require("client.slua.logic.lobby.Left.logic_social_battle_info")
    v = logic_social_battle_info.GetDataByRawOption(DataMgr.roleData.uid, id, self.selectModeIndex, self.selectDataIndex)
  end
  local text = LocUtil.LocalizeResFormat(7616, k, v)
  widget.TagName:SetText(text)
end
function Placard_MedalSelection_UIBP:OnClickButton_Jump()
  self:PlayAudio(sound_config.click_v1)
end
function Placard_MedalSelection_UIBP:OnSwitchToJumpTab()
  self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(3)
  self.UIRoot.UTRichTextBlock_0:SetText(LocUtil.GetLocalizeResStr(76970))
end
function Placard_MedalSelection_UIBP:OnSwitchToIconTab(slotIndex)
  printf(" Placard_MedalSelection_UIBP:OnSwitchToIconTab slotIndex: %d", slotIndex)
  self.Common_Tab_Horizontal_LevelTwo_Text_UIBP:Select(1)
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  self.curEditSlotIndex = slotIndex
  local ShowBrandUtils = require("client.slua.logic.showbrand.ShowBrandUtils")
  local items = ShowBrandUtils.GetDataOpCfgList(self.templateCfg, slotIndex)
  local PatrollerModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PatrollerModule)
  if not PatrollerModule:IsPatroller() then
    local filteredItem = {}
    local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
    for _, v in ipairs(items) do
      if not ShowBrandConst.PatrollerDataType[v.ID] then
        filteredItem[#filteredItem + 1] = v
      end
    end
    items = filteredItem
  end
  self.LoopScrollBox_0:SetData(items)
end
function Placard_MedalSelection_UIBP:OnSwitchToTextTab(slotIndex)
  printf(" Placard_MedalSelection_UIBP:OnSwitchToTextTab slotIndex: %d", slotIndex)
  self.Common_Tab_Horizontal_LevelTwo_Text_UIBP:Select(2)
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  self.curEditSlotIndex = slotIndex
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  local settings = LogicShowBrand:GetSelfSetting(self.TemplateID)
  local data_source = settings[slotIndex].data_source or 1101
  local logic_social_battle_info = require("client.slua.logic.lobby.Left.logic_social_battle_info")
  local option, period_index, mode_index = logic_social_battle_info.DecodeOptions(data_source)
  self.selectDataIndex = period_index
  self.selectModeIndex = mode_index
  local cardConfig = require("client.slua.umg.PersonSpace.Card.Card_Config")
  self.ViewMode = cardConfig.IndexToMode[self.selectModeIndex].ViewMode
  self.TeamSize = cardConfig.IndexToMode[self.selectModeIndex].TeamSize
  self.Common_ComboBox_Data:SelectIndex(self.selectDataIndex)
  self:SetNewTap()
  self.UIRoot.CardLabel_Popup_Item_UIBP.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CardLabel_Popup_Item_UIBP.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CardLabel_Popup_Item_UIBP.WidgetSwitcher_7:SetActiveWidgetIndex(0)
  printf("Placard_MedalSelection_UIBP:OnSwitchToTextTab DataIndex: %s, ModeIndex: %s, ViewMode: %s, TeamSize: %s", self.selectDataIndex, self.selectModeIndex, self.ViewMode, self.TeamSize)
end
function Placard_MedalSelection_UIBP:OnSwitchToPlacardTitleSlot(PlacardTitleSlot)
  printf(" Placard_MedalSelection_UIBP:OnSwitchToPlacardTitleSlot PlacardTitleSlot: %d", PlacardTitleSlot)
  self.Common_Tab_Horizontal_LevelTwo_Text_UIBP_PlacardTitle:Select(PlacardTitleSlot)
  self.curEdit  self:UpdatePlacardTitleTabListData()
end
function Placard_MedalSelection_UIBP:UpdatePlacardTitleTabListData(NeedGetModData)
  local ListData
  if self.curEditPlacardTitleSlot == 2 then
    if self.SelfModData == nil then
      local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
      local bIsWowCreator = LogicUGCAuthor:NewCheckPlayerIsAuthor(DataMgr.roleData.uid) == true
      print(bWriteLog and "Placard_MedalSelection_UIBP:UpdatePlacardTitleTabListData bIsWowCreator:" .. tostring(bIsWowCreator))
      if bIsWowCreator then
        local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
        local PubModList = LogicUGC:GetPubModList()
        if PubModList == nil then
          self.SelfModData = {}
          if NeedGetModData ~= false then
            LogicUGC:ReqGetAllMetaKey()
          end
        else
          local ModIDList = {}
          for ModID, _ in pairs(PubModList) do
            table.insert(ModIDList, ModID)
          end
          local ModInfoList
          if NeedGetModData == false then
            ModInfoList = LogicUGC:BatchGetModInfo(ModIDList)
          else
            ModInfoList = LogicUGC:BatchGetModInfo(ModIDList, LogicUGC.C_ModListTypes.Brand_Map)
          end
          local _SelfModData = {}
          if ModInfoList and next(ModInfoList) then
            for ModID, ModeInfo in pairs(ModInfoList) do
              table.insert(_SelfModData, {
                ModID = ModID,
                SettingID = 1,
                ModInfo = ModeInfo.pub_mod_meta
              })
              table.insert(_SelfModData, {ModID = ModID, SettingID = 0})
            end
          end
          self.SelfModData = _SelfModData
        end
      else
        self.SelfModData = {}
      end
    end
    ListData = self.SelfModData
  else
    local ShowBrandUtils = require("client.slua.logic.showbrand.ShowBrandUtils")
    local items = ShowBrandUtils.GetDataOpCfgList(self.templateCfg, self.curEditPlacardTitleSlot)
    ListData = items
  end
  if ListData == nil or #ListData == 0 then
    self.UIRoot.WidgetSwitcher_2:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_2:SetActiveWidgetIndex(0)
    self.PlacardTitleTabScrollBox:SetData(ListData)
  end
end
function Placard_MedalSelection_UIBP:CheckPlacardTitleIsSelect(PlacardTitleData)
  local bSelect = false
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  local settings = LogicShowBrand:GetSelfSetting(self.TemplateID)
  local ShowBrandUtils = require("client.slua.logic.showbrand.ShowBrandUtils")
  local defaultSettings = ShowBrandUtils.GetDefaultSettings(self.TemplateID)
  local SelectDataID = defaultSettings[self.curEditPlacardTitleSlot]
  if settings ~= nil and settings[self.curEditPlacardTitleSlot] and settings[self.curEditPlacardTitleSlot].id then
    SelectDataID = settings[self.curEditPlacardTitleSlot].id
  end
  if self.curEditPlacardTitleSlot == 2 then
    local CurModID = 0
    if settings ~= nil and settings.mod_id ~= nil then
      CurModID = settings.mod_id
    end
    bSelect = CurModID == PlacardTitleData.ModID and SelectDataID == PlacardTitleData.SettingID
  else
    local id = PlacardTitleData.ID
    bSelect = id == SelectDataID
  end
  return bSelect
end
function Placard_MedalSelection_UIBP:OnRefreshPlacardTitleItem(widget, index)
  local data = self.PlacardTitleTabScrollBox:GetItemData(index)
  widget.Checkbox_Select:SetCheckedState(self:CheckPlacardTitleIsSelect(data) and 1 or 0)
  if self.curEditPlacardTitleSlot == 2 then
    if data.SettingID == 0 then
      widget.TagName:SetText(LocUtil.LocalizeResFormat(76270, data.ModID))
    else
      widget.TagName:SetText(tostring(data.ModInfo.setting.name))
    end
  else
    local textId = data.TextID
    local text = LocUtil.GetLocalizeResStr(textId)
    widget.TagName:SetText(text)
  end
end
function Placard_MedalSelection_UIBP:OnCheckStateChanged_PlacardTitleItem(widget, index)
  self:PlayAudio(sound_config.click_v1)
  local bIsCheck = widget.Checkbox_Select:GetCheckedState() == 1
  local data = self.PlacardTitleTabScrollBox:GetItemData(index)
  printf(" Placard_MedalSelection_UIBP:OnCheckStateChanged_PlacardTitleItem index: %s, bIsCheck: %s", index, bIsCheck)
  if false == bIsCheck then
    widget.Checkbox_Select:SetCheckedState(1)
    return
  end
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  local settings = LogicShowBrand:GetSelfSetting(self.TemplateID)
  if self.curEditPlacardTitleSlot == 2 then
    settings.mod_id = data.ModID
    if settings[self.curEditPlacardTitleSlot] == nil then
      settings[self.curEditPlacardTitleSlot] = {}
    end
    settings[self.curEditPlacardTitleSlot].id = data.SettingID
    LogicShowBrand:ChangeSettingFormNewSetting(self.TemplateID, settings)
  else
    LogicShowBrand:ChangeSetting(self.TemplateID, self.curEditPlacardTitleSlot, data.ID)
  end
  self.PlacardTitleTabScrollBox:RefreshAllItems()
end
function Placard_MedalSelection_UIBP:OnGetAllMetaKeyHandle()
  print(bWriteLog and "Placard_MedalSelection_UIBP:OnGetAllMetaKeyHandle curEditPlacardTitleSlot:" .. tostring(self.curEditPlacardTitleSlot))
  if self.curEditPlacardTitleSlot ~= 2 then
    return
  end
  self.SelfModData = nil
  self:UpdatePlacardTitleTabListData()
end
function Placard_MedalSelection_UIBP:OnNotifyReqModInfoSuccess(_, _, ListType, bIsDirty, MetaList, Param, FilterOfflineModList)
  print(bWriteLog and "Placard_MedalSelection_UIBP:OnNotifyReqModInfoSuccess curEditPlacardTitleSlot:" .. tostring(self.curEditPlacardTitleSlot) .. " listType:" .. tostring(ListType))
  if self.curEditPlacardTitleSlot ~= 2 then
    return
  end
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if not UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.Brand_Map) then
    return
  end
  self.SelfModData = nil
  self:UpdatePlacardTitleTabListData(false)
end
function Placard_MedalSelection_UIBP:OnPeakTimeRsp()
  log(bWriteLog and "Placard_MedalSelection_UIBP:OnPeakTimeRsp")
  if self.UIRoot.WidgetSwitcher_0:GetActiveWidgetIndex() == 0 then
    log(bWriteLog and "Placard_MedalSelection_UIBP:OnPeakTimeRsp updateItem")
    self:OnSwitchToIconTab(self.curEditSlotIndex)
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOWBRAND_ON_SETTING_CHANGE, self.TemplateID, 0, 0)
end
function Placard_MedalSelection_UIBP:OnPatrollerUpdate()
  if not self.templateCfg then
    log(bWriteLog and "Placard_MedalSelection_UIBP:OnPatrollerUpdate not self.templateCfg")
    return
  end
  self:UpdateComboBox()
  if self.UIRoot.WidgetSwitcher_0:GetActiveWidgetIndex() == 0 then
    log(bWriteLog and "Placard_MedalSelection_UIBP:OnPatrollerUpdate updateItem")
    self:OnSwitchToIconTab(self.curEditSlotIndex)
  end
end
function Placard_MedalSelection_UIBP:OnSwitchToTextEditTab()
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2)
end
function Placard_MedalSelection_UIBP:OnSwitchToPlacardTitleTab()
  local tabs = {
    LocUtil.GetLocalizeResStr(76264),
    LocUtil.GetLocalizeResStr(76265),
    LocUtil.GetLocalizeResStr(76266)
  }
  self.Common_Tab_Horizontal_LevelTwo_Text_UIBP_PlacardTitle:SetTabs(tabs)
  self:OnSwitchToPlacardTitleSlot(1)
end
function Placard_MedalSelection_UIBP:UpdateTemplate(cfg)
  self.templateCfg = cfg
  local TemplateID = cfg.TemplateID
  self.  if TemplateID == 1 then
    self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
    local tabs = {
      LocUtil.GetLocalizeResStr(74141),
      LocUtil.GetLocalizeResStr(74142)
    }
    self.Common_Tab_Horizontal_LevelTwo_Text_UIBP:SetTabs(tabs)
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  elseif TemplateID == 2 then
    self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
    local tabs = {
      LocUtil.GetLocalizeResStr(74142)
    }
    self.Common_Tab_Horizontal_LevelTwo_Text_UIBP:SetTabs(tabs)
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2)
  elseif TemplateID == 3 then
    self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(1)
    self:OnSwitchToPlacardTitleTab()
  elseif TemplateID == 7 then
    self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
    local tabs = {
      LocUtil.GetLocalizeResStr(74141)
    }
    self.Common_Tab_Horizontal_LevelTwo_Text_UIBP:SetTabs(tabs)
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  end
  if self.templateCfg.CanEdit == 0 then
    printf("Placard_MedalSelection_UIBP:UpdateTemplate CanEdit is 0")
    self.UIRoot.MultiLineEditableTextBox_Special:SetIsReadOnly(true)
  else
    self.UIRoot.MultiLineEditableTextBox_Special:SetIsReadOnly(false)
  end
end
local class = require("class")
local ui_base = require("client.slua.umg.lobby.Left.Popup.Lobby_Label_Ediotr_Base_UIBP")
local CPlacard_MedalSelection_UIBP = class(ui_base, nil, Placard_MedalSelection_UIBP)
return CPlacard_MedalSelection_UIBP