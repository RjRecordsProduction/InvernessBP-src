local SubTabItemListBase = {
  ENUM_SORT_TYPE = {QUALITY = 1, LATEST = 2}
}
local SHOW_FILTER_TIP_MIN_COUNT = 10
local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
function SubTabItemListBase:ctor(selfType, subTabConfig)
  self.  self.bInit = false
  self.sortTypeList = {
    [self.ENUM_SORT_TYPE.QUALITY] = {
      type = self.ENUM_SORT_TYPE.QUALITY,
      text = LocUtil.GetLocalizeResStr(48884)
    },
    [self.ENUM_SORT_TYPE.LATEST] = {
      type = self.ENUM_SORT_TYPE.LATEST,
      text = LocUtil.GetLocalizeResStr(48883)
    }
  }
  self.searchStr = ""
  self.bShowTagFilter = not subTabConfig or not subTabConfig.hideTagFilter
  self.ClickDownLoadItemID = 0
  self.bIsShowClothMatch = false
  self.cObj_clothMatchLoop = nil
  self.bIsHasRefreshDownloadFinishPuton = false
end
function SubTabItemListBase:OnBeforeInitialize(loopScrollGrid)
  self.end
function SubTabItemListBase:InitUIControlsVisibility()
  if self.UIRoot.HorizontalBox_Wardrobe_Clothes then
    self:SetWidgetVisible(self.UIRoot.HorizontalBox_Wardrobe_Clothes, true)
  end
  if self.UIRoot.CanvasPanel_Coupon then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Coupon, false)
  end
  if self.UIRoot.CanvasPanel_IconTab then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_IconTab, false)
  end
end
function SubTabItemListBase:OnInitialize()
  self:InitUIControlsVisibility()
  log(bWriteLog and "SubTabItemListBase:OnInitialize")
  if self.loopScrollGrid ~= nil then
    self.LoopScrollGrid_Normal = self:InitScrollBox(self.loopScrollGrid)
  else
    self.LoopScrollGrid_Normal = self:InitScrollBox(self.UIRoot.LoopScrollGrid_Avatar)
  end
  self.LoopScrollGrid_Normal:SetRefreshItemCallback(self.OnRefreshListItem, self)
  if self.UIRoot.CheckBox_Sort then
    self:RefreshCheckBoxState()
  else
    log(bWriteLog and "halendeng checkbox is missing")
  end
end
function SubTabItemListBase:RegistEvents()
  SubTabItemListBase.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, self.OnWardrobeDataChange, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_ON_DATA, self.OnUpdatePutOnData, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_DOWN_DATA, self.OnUpdatePutDownData, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self.OnDownloadFinish, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_COUNT, self.RefreshCount, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_TAG_FILTER_UPDATE, self.OnWardrobeTagsSelectChange, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_TAG_DATA_UPDATE, self.OnWardrobeTagsUpdate, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_TAG_CHANGE, self.OnWardrobeTagsSelectChange, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_LOADED, self.OnBeginLobbySkinChange, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_TEAM, self.OnTeamChange, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_BACK_FASHION_BAG, self.OnWardrobeBackFashionBag, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_UPDATE, self.OnFashionBagEditUpdate, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_EXIT, self.OnFashionBagEditExit, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SPECIAL_IDLE_SWITCH, self.OnWardrobeSpecialIdleSwitch, self)
  self:AddCommonEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, self.OnLoginSuccess, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_CLICK_DOWNLOAD, self.OnItemClickDownload, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ACTION_PLAY_START, self.OnPlayAction, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ACTION_PALY_END, self.OnStopAction, self)
  if self.UIRoot.CheckBox_Sort then
    self:AddControlEventByControl(self.UIRoot.CheckBox_Sort, "OnCheckStateChanged", self.OnClickCheckBox, self)
  end
  if self.UIRoot.WidgetSwitcher_Search then
    self:InitSearchAndSort()
  end
  self:InitTagFilter()
end
function SubTabItemListBase:RefreshCount()
  log(bWriteLog and "SubTabItemListBase:RefreshCount")
  self.LoopScrollGrid_Normal:RefreshAllItems()
end
function SubTabItemListBase:OnPostInitialize()
  SubTabItemListBase.__super.OnPostInitialize(self)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SUBPAGE_OPEN)
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  logic_wardrobe_tag_mgr:ClearSelectedData()
  if not self.UIRoot then
    return
  end
  if self.UIRoot.WidgetSwitcher_Search then
    self:RefreshSearchState()
  else
    log(bWriteLog and "SubTabItemListBase WidgetSwitcher_Search is missing")
  end
  if self.UIRoot.Button_Preserve then
    self.UIRoot.Button_Preserve:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.TextBlock_9 then
    self.UIRoot.TextBlock_9:SetText(LocUtil.GetLocalizeResStr(7031))
  end
end
function SubTabItemListBase:InitSearchAndSort()
  self.UIRoot.WidgetSwitcher_Search:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if self.UIRoot.ComboBox_PlayDate then
    self.ComboBox_PlayDate = self:InitCustomComboBox(self.UIRoot.ComboBox_PlayDate)
    self.ComboBox_PlayDate:SetRefreshOptionCallback(self.OnRefreshSortItem, self)
    self.ComboBox_PlayDate:SetSelectOptionCallback(self.OnSelectSortItem, self)
    self.ComboBox_PlayDate:AddControlEventByControl(self.ComboBox_PlayDate.UIRoot, "OnOpening", self.OnSortOpen, self)
    self.ComboBox_PlayDate:SetData(self.sortTypeList)
  end
  if self.UIRoot.WidgetSwitcher_Search then
    if self.UIRoot.Search01 then
      self:AddOnTextChangedEventByControl(self.UIRoot.Search01.message_input, self.OnSearchTextChanged, self)
      self:AddOnClickedEventByControl(self.UIRoot.Search01.close, self.OnClickClearSearch, self)
    end
    if self.UIRoot.Button_DoSearch then
      self:AddOnClickedEventByControl(self.UIRoot.Button_DoSearch, self.OnClickSearch, self)
    end
    if self.UIRoot.Button_BeginSearch then
      self.UIRoot.Button_BeginSearch:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      self:AddOnClickedEventByControl(self.UIRoot.Button_BeginSearch, self.OnClickEnterSearch, self)
    end
    if self.UIRoot.Button_Clear then
      self:AddOnClickedEventByControl(self.UIRoot.Button_Clear, self.OnClickClearSearch, self)
    end
    if self.UIRoot.Text_NameOrUID then
      self.UIRoot.Text_NameOrUID:SetIsReadOnly(true)
      self.UIRoot.Text_NameOrUID:SetHintText(LocUtil.GetLocalizeResStr(52007))
    end
    self.UIRoot.WidgetSwitcher_Search:SetActiveWidgetIndex(1)
  end
end
function SubTabItemListBase:InitTagFilter()
  if self.UIRoot.CanvasPanel_Tags then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Tags, false, false)
  end
  if self.UIRoot.LoopScrollBox_Tags then
    self.LoopScrollBox_Tags = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Tags, "client.slua.umg.Wardrobe.WardrobeItem.HorizontalBox_Wardrobe_Pool_Item")
  end
  if self.UIRoot.Button_Filter then
    self:SetWidgetVisible(self.UIRoot.Button_Filter, self.bShowTagFilter, true)
    if self.bShowTagFilter then
      self:AddOnClickedEventByControl(self.UIRoot.Button_Filter, self.OnClickFilter, self)
    end
  end
  if self.UIRoot.Reddot_Anchor_Item01 then
    self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Item01, false, false)
  end
end
function SubTabItemListBase:OnWardrobeDataChange(eventType, eventID, changelist)
end
function SubTabItemListBase:OnDownloadFinish(_, _, eventData)
  self:OnRefreshAllItems(_, _, eventData)
end
function SubTabItemListBase:OnRefreshAllItems(_, _, eventData)
  local itemID = eventData.itemID
  if not itemID or tonumber(itemID) <= 0 then
    return
  end
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if not itemCfg then
    return
  end
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if weapon_diy_system:IsDIYWeapon(itemID) then
    if self.bIsShowClothMatch and self.cObj_clothMatchLoop then
      self.cObj_clothMatchLoop:RefreshAllItems()
    else
      self.LoopScrollGrid_Normal:RefreshAllItems()
    end
    return
  end
  log(bWriteLog and "SubTabItemListBase:OnRefreshAllItems 1 ItemID:" .. tostring(itemCfg.ItemID) .. ", ItemTyp:" .. tostring(itemCfg.ItemType) .. ", ItemSubType:" .. tostring(itemCfg.ItemSubType))
  if not self.ClickDownLoadItemID or self.ClickDownLoadItemID == 0 or self.ClickDownLoadItemID ~= itemCfg.ItemID then
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
    itemCfg.itemID
  })
  if state ~= PufferConst.ENUM_DownloadState.Done then
    return
  end
  local cObj_Loop
  if self.bIsShowClothMatch then
    cObj_Loop = self.cObj_clothMatchLoop
    self.bIsHasRefreshDownloadFinishPuton = false
  else
    cObj_Loop = self.LoopScrollGrid_Normal
  end
  if not cObj_Loop or not cObj_Loop.GetSetData then
    return
  end
  local itemListTable = cObj_Loop:GetSetData()
  if not itemListTable or not next(itemListTable) then
    return
  end
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  itemID = StoreUtils.GetSkinIDByLevelID(itemID)
  log(bWriteLog and "SubTabItemListBase:OnRefreshAllItems 2 itemID:" .. tostring(itemCfg.ItemID) .. ", ItemTyp:" .. tostring(itemCfg.ItemType) .. ", ItemSubType:" .. tostring(itemCfg.ItemSubType))
  for i, v in pairs(itemListTable) do
    if self.bIsShowClothMatch then
      if type(v) == "table" and v.mainItem and type(v.mainItem) == "table" and v.mainItem.res_id == itemID then
        if not v.isUsing or itemCfg.ItemType == ENUM_ITEM_TYPE.Emote then
          self:OnClothMatchDownloadFinishClick(i)
        end
        return
      end
    elseif type(v) == "table" and v.res_id == itemID then
      if not v.isUsing or itemCfg.ItemType == ENUM_ITEM_TYPE.Emote then
        self:OnClickItem(nil, i)
      end
      return
    end
  end
end
function SubTabItemListBase:OnRefreshSortItem(widget, data, index, selectIndex)
  if not data then
    return
  end
  widget.TextBlock_ItemName:SetText(data.text)
  if index == selectIndex then
    widget.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.TextBlock_ItemName:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
  else
    widget.Image_Select:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.TextBlock_ItemName:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 0.4)))
  end
end
function SubTabItemListBase:OnSelectSortItem(widget, data)
  self:PlayAudio(sound_config.click_v1)
  widget.TextBlock_ItemName:SetText(data.text)
  local SortPreference = WardrobeLogicManager:GetSortPreference(self.subTabConfig)
  if not SortPreference == (data.type == self.ENUM_SORT_TYPE.QUALITY) then
    log(bWriteLog and "SubTabItemListBase:OnSelectSortItem same")
    return
  end
  if data.type == self.ENUM_SORT_TYPE.LATEST then
    WardrobeLogicManager:SetSortPreference(self.subTabConfig, true)
  else
    WardrobeLogicManager:SetSortPreference(self.subTabConfig, false)
  end
  if self.ReSortItem then
    self:ReSortItem()
  else
    self:OnWardrobeDataChange()
  end
end
function SubTabItemListBase:OnSortOpen()
  self:PlayAudio(sound_config.popup_v1)
end
function SubTabItemListBase:OnSearchTextChanged(str)
  self.searchStr = str
end
function SubTabItemListBase:OnClickEnterSearch()
  self:PlayAudio(sound_config.click_v1)
  self.UIRoot.WidgetSwitcher_Search:SetActiveWidgetIndex(0)
  self.UIRoot.Search01.message_input:SetKeyboardFocus()
end
function SubTabItemListBase:OnClickClearSearch()
  self:PlayAudio(sound_config.click_v1)
  self.searchStr = ""
  WardrobeLogicManager:SetSearchString(self.searchStr)
  self:RefreshSearchState()
  if self.OnSearchChange then
    self:OnSearchChange()
  else
    self:OnWardrobeDataChange()
  end
  self.UIRoot.WidgetSwitcher_Search:SetActiveWidgetIndex(1)
end
function SubTabItemListBase:OnClickSearch()
  self:PlayAudio(sound_config.click_v1)
  WardrobeLogicManager:SetSearchString(self.searchStr)
  self:RefreshSearchState()
  if self.OnSearchChange then
    self:OnSearchChange()
  else
    self:OnWardrobeDataChange()
  end
  self.UIRoot.WidgetSwitcher_Search:SetActiveWidgetIndex(1)
end
function SubTabItemListBase:DoSearch(itemListTable, str)
  if not str or str == "" then
    return itemListTable
  end
  local result = {}
  if not itemListTable then
    return result
  end
  for _, v in pairs(itemListTable) do
    local name = v.itemName
    if name and string.find(string.lower(name), string.lower(str), 1, true) then
      table.insert(result, v)
    end
  end
  return result
end
function SubTabItemListBase:DoFilterTags(itemListTable)
  itemListTable = self:DoFilterByCornerTag(itemListTable)
  itemListTable = self:DoFilterByCustomTag(itemListTable)
  itemListTable = self:DoFilterByGetTime(itemListTable)
  return itemListTable
end
function SubTabItemListBase:DoFilterByCornerTag(itemListTable)
  local result = {}
  if not itemListTable then
    return result
  end
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  if not logic_wardrobe_tag_mgr:HasEnabledCornerTag() then
    return itemListTable
  end
  local SelectedCornerTagList = logic_wardrobe_tag_mgr:GetSelectedCornerTagList()
  local   for _, v in pairs(itemListTable) do
    local itemData = CDataTable.GetTableData("Item", v.res_id)
    if itemData then
      local SpecialIcon = itemData.SpecialIcon
      if SpecialIcon then
        local CornerTag = CDataTable.GetTableData("NewCornerIconTypeConfig", SpecialIcon)
        if CornerTag and SelectedCornerTagList and SelectedCornerTagList[CornerTag.TypeID] then
          result[#result + 1] = v
        end
      end
    end
  end
  return result
end
function SubTabItemListBase:DoFilterByCustomTag(itemListTable)
  local result = {}
  if not itemListTable then
    return result
  end
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  if not logic_wardrobe_tag_mgr:HasEnabledCustomTag() then
    return itemListTable
  end
  for _, v in pairs(itemListTable) do
    if logic_wardrobe_tag_mgr:IsItemMatchCustomTag(v.res_id) then
      result[#result + 1] = v
    end
  end
  return result
end
function SubTabItemListBase:DoFilterByGetTime(itemListTable)
  local result = {}
  if not itemListTable then
    return result
  end
  local TimeUtil = require("client.common.time_util")
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  if not logic_wardrobe_tag_mgr:IsTimeFilterEnabled() then
    return itemListTable
  end
  local StartTimeInfo, EndTimeInfo = logic_wardrobe_tag_mgr:GetSelectedTimeInfo()
  local StartTime, EndTime
  if StartTimeInfo and StartTimeInfo.Year and StartTimeInfo.Month then
    StartTime = TimeUtil.OSTime({
      year = StartTimeInfo.Year,
      month = StartTimeInfo.Month,
      day = 1
    })
  end
  if EndTimeInfo and EndTimeInfo.Year and EndTimeInfo.Month then
    EndTime = TimeUtil.OSTime({
      year = EndTimeInfo.Year,
      month = EndTimeInfo.Month,
      day = 31
    })
  end
  if not StartTime and not EndTime then
    return itemListTable
  end
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  for _, v in pairs(itemListTable) do
    local GetTime = logic_wardrobe_new:ExtractHigh32Bits(v.ins_id)
    local bMatch = true
    if StartTime and StartTime > GetTime then
      bMatch = false
    end
    if EndTime and EndTime < GetTime then
      bMatch = false
    end
    if bMatch then
      result[#result + 1] = v
    end
  end
  return result
end
function SubTabItemListBase:OnFashionBagChange(_, __, CurrentIndex)
  self.LoopScrollGrid_Normal:Deselect()
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  tipsMgr:Hide()
end
function SubTabItemListBase:UpdateItemList(itemListTable)
  log_tree("SubTabItemListBase:UpdateItemList ", itemListTable)
  self.LoopScrollGrid_Normal:SetData(itemListTable)
  self.LoopScrollGrid_Normal:Deselect()
  local nListCount = itemListTable and #itemListTable or 0
  if nListCount <= 0 then
    local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
    tipsMgr:Hide()
  end
  if self.UIRoot and self.UIRoot.CanvasPanel_NoItem then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_NoItem, nListCount <= 0)
  end
end
function SubTabItemListBase:UpdateItemListBySort(itemListTable)
  self.LoopScrollGrid_Normal:SetData(itemListTable)
  self.LoopScrollGrid_Normal:Deselect()
end
function SubTabItemListBase:OnRefreshListItem(widget, index)
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  local isSelect = index == self.LoopScrollGrid_Normal:GetSelectIndex()
  self:RefreshListItem(widget, itemData, isSelect, index)
end
function SubTabItemListBase:RefreshListItem(widget, itemData, selected, index, blockClick)
  if itemData then
    itemData.isSelected = selected
    self:InitView(widget, itemData, index, blockClick)
    if itemData.isSelected then
      widget:SetRenderScale(FVector2D(1.05, 1.05))
    else
      widget:SetRenderScale(FVector2D(1, 1))
    end
    if itemData.isSourceBook then
      self:SetIconAlpha(widget, 0.3)
      self:SetTryOn(widget, false)
    else
      self:SetIconAlpha(widget, 1)
      self:SetTryOn(widget, false)
      local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      local characterUse = logic_wardrobe:IsCharacterUse(itemData.res_id)
      local isIsolated = logic_wardrobe:IsItemIsolated(itemData.res_id)
      if not characterUse then
        if not logic_wardrobe:IsCharacterAction(itemData.res_id) and itemData.res_id ~= 2101018 then
          widget:SetIsolated(true, LocUtil.GetLocalizeResStr(7473))
        else
          widget:SetIsolated(false)
        end
      else
        widget:SetIsolated(isIsolated)
      end
    end
  end
end
function SubTabItemListBase:OnClickItem(widget, index)
  self:PlayAudio(sound_config.click_v1)
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  if itemData and itemData.lock_cnt and itemData.lock_cnt > 0 then
    local LogicCardCollectionGun = require("client.slua.logic.card_collection.LogicCardCollectionGun")
    if LogicCardCollectionGun.IsCardCollectionFrozenGun(itemData.res_id) then
      ShowNotice(33020231)
    else
      ShowNotice(3000016)
    end
    return
  end
  log_tree("=====OnClickItem=============", itemData)
  if itemData then
    local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    logic_wardrobe_new:SetClickItemInsId(itemData.ins_id)
    self:ClearItemNewAndRedPoint(itemData)
    local itemID = self:GetCurItemID(itemData)
    log_format("SubTabItemListBase:OnClickItem. itemID: %s", itemID)
    if itemData.isUsing then
      itemID = nil
    end
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, itemID)
  end
  self.LoopScrollGrid_Normal:Select(index)
end
function SubTabItemListBase:OnClothMatchDownloadFinishClick(index)
  log(bWriteLog and string.format("SubTabItemListBase:OnClothMatchDownloadFinishClick  index: %s curSelectIndex: %s", index, self.curSelectIndex))
  if index == self.curSelectIndex then
    log(bWriteLog and string.format("SubTabItemListBase:OnClothMatchDownloadFinishClick already selected."))
    return
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_DOWNLOADFINISH_BATCH_PUTON, self.cObj_clothMatchLoop:GetItemData(index), index)
end
function SubTabItemListBase:ClearItemNewAndRedPoint(tItemData)
  tItemData.isNew = false
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  local tabId = wardrobe_red_point:GetTabIdByRes(tItemData.res_id)
  wardrobe_red_point:OnSelectTab(tabId)
end
function SubTabItemListBase:OnShow()
  self:PlayUserWidgetAnimation(self.UIRoot.fadein, 0, 1, 0, 1)
  self:TryDirectEnlarge()
end
function SubTabItemListBase:OnHide()
  self:PlayUserWidgetAnimation(self.UIRoot.out, 0, 1, 0, 1)
end
function SubTabItemListBase:OnPlayAction(_, _, AvatarComp, ActionID)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local NeedRedirectUnenlarge = {
    [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_gloves] = ENUM_ITEM_SUBTYPE.Gloves
  }
  local ItemSubType = self.subTabConfig and NeedRedirectUnenlarge[self.subTabConfig.subTabId]
  if not self.bHasEnlarged or not ItemSubType then
    return
  end
  local MainAvatar = TeamAvatarManager.GetMainAvatar()
  local MainPawn = MainAvatar and MainAvatar:GetModel()
  local MainAvatarComp = MainPawn and MainPawn:getAvatarComponent2()
  if AvatarComp ~= MainAvatarComp then
    return
  end
  self:DirectUnEnlarge()
end
function SubTabItemListBase:OnStopAction(_, _, ActionID)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local NeedRedirectEnlarge = {
    [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_gloves] = ENUM_ITEM_SUBTYPE.Gloves
  }
  local ItemSubType = self.subTabConfig and NeedRedirectEnlarge[self.subTabConfig.subTabId]
  if self.bHasEnlarged or not ItemSubType then
    return
  end
  self:DirectEnlarge(ItemSubType)
end
function SubTabItemListBase:TryDirectEnlarge()
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local NeedEnlargeTypeTable = {
    [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_head] = 401,
    [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_face] = 402,
    [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_glasses] = 407,
    [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_bag] = 504,
    [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_helmet] = 505,
    [wardrobe_macro.ENUM_WardrobeSubTabString.Enum_WardrobeSubTabString_Head] = 401,
    [wardrobe_macro.ENUM_WardrobeSubTabString.Enum_WardrobeSubTabString_Hair] = 402,
    [wardrobe_macro.ENUM_WardrobeSubTabString.Enum_WardrobeSubTabString_Beard] = 408,
    [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_gloves] = ENUM_ITEM_SUBTYPE.Gloves,
    [wardrobe_macro.ENUM_WardrobeSubTabString.Enum_WardrobeSubTabString_ShowBrand] = 2208
  }
  if self.subTabConfig then
    local itemSubType = NeedEnlargeTypeTable[self.subTabConfig.subTabId]
    if itemSubType then
      self:DirectEnlarge(itemSubType)
    end
  end
end
function SubTabItemListBase:DirectEnlarge(itemSubType)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local GameInstance = slua.getGameInstance()
  if slua.isValid(GameInstance) then
    GameInstance:SetSSSMBoundsScale(0.4)
    GameInstance:SetSSSMBoundsZOffset(50)
    GameInstance:SetDisableSSShadowSoft(true)
  end
  Lobby_camera_manager_module:ZoomInLobbyCamera(TeamAvatarManager.GetMainAvatar(), itemSubType, Lobby_camera_manager_module.currentCameraID, nil, self:GetDirectExtraLocation())
  self.bHasEnlarged = true
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ZOOM_BUTTON, self.bHasEnlarged)
end
function SubTabItemListBase:GetDirectExtraLocation()
  local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if GarageThemeSystem:IsInGarageTheme() and TeamUpNewSystem.IsInTeam() then
    return {x = -50}
  end
end
function SubTabItemListBase:DirectUnEnlarge()
  if not self.bHasEnlarged then
    return
  end
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local GameInstance = slua.getGameInstance()
  if slua.isValid(GameInstance) then
    GameInstance:SetSSSMBoundsScale(1.0)
    GameInstance:SetSSSMBoundsZOffset(0)
    GameInstance:SetDisableSSShadowSoft(false)
  end
  Lobby_camera_manager_module:ZoomOutLobbyCamera(TeamAvatarManager.GetMainAvatar(), Lobby_camera_manager_module.currentCameraID)
  self.bHasEnlarged = false
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ZOOM_BUTTON, self.bHasEnlarged)
end
function SubTabItemListBase:RestoreDirectEnlarge()
  if self.bHasEnlarged then
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    local NeedEnlargeTypeTable = {
      [wardrobe_macro.ENUM_WardrobeSubTabString.Enum_WardrobeSubTabString_Head] = 401,
      [wardrobe_macro.ENUM_WardrobeSubTabString.Enum_WardrobeSubTabString_Hair] = 402,
      [wardrobe_macro.ENUM_WardrobeSubTabString.Enum_WardrobeSubTabString_Beard] = 408
    }
    if self.subTabConfig then
      local itemSubType = NeedEnlargeTypeTable[self.subTabConfig.subTabId]
      if itemSubType then
        self:DirectEnlarge(itemSubType)
      end
    end
  end
end
function SubTabItemListBase:OnWardrobeBackFashionBag()
  self:RestoreDirectEnlarge()
end
function SubTabItemListBase:AddExtraDataParams(extraData, itemID)
  function extraData.fDownloadClickCallback()
    log_format("SubTabItemListBase:AddExtraDataParams. clicked")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local itemID = itemID or 0
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {itemID})
    if state ~= PufferConst.ENUM_DownloadState.Download then
      local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
      local curSize, totalSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.ODPAK, {itemID})
      PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.Wardrobe, PufferTlog.Enum_TLog_Optype.UIOperate, "Skin_Download_Click_List", totalSize)
    end
  end
  extraData.showAlertSize = true
end
function SubTabItemListBase:InitView(node_widget, itemData, index, blockClick)
  local widget = node_widget
  local validHour = 0
  if itemData.expireTS and 0 < itemData.expireTS then
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    validHour = (itemData.expireTS - now) / 3600
    if validHour <= 0 then
      validHour = 1
    end
  end
  local nItemNum = 1 <= itemData.count and itemData.count or 1
  local tExtraData = itemData.extra or {}
  tExtraData.bIsShowTip = false
  tExtraData.bIsShowBigIcon = self:IsShowBigIcon()
  self:AddExtraDataParams(tExtraData, itemData.res_id)
  local itemID = self:GetCurItemID(itemData)
  widget:InitView(itemID, nItemNum, validHour, tExtraData)
  if not blockClick then
    widget:SetClickItemCallback(self.OnClickItem, self, widget, index)
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local useCount = 0
  if itemData.showUseCount then
    useCount = wardrobe_data:GetUseCount(itemData.ins_id)
  end
  widget:SetUseCount(useCount, itemData.isRolewear or false)
  widget:SetSelected(itemData.isSelected)
  widget:SetIsLock(itemData.hasLock or false)
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local isIsolated = logic_wardrobe:IsItemIsolated(itemData.res_id)
  widget:SetIsolated(isIsolated)
  widget:SetIsNew(itemData.isNew)
  widget:SetShowInheritIcon(wardrobe_data:GetItemSource(itemData.ins_id) == EWardrobeDataSource.InheritWardrobe)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if logic_wardrobe:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag then
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    local bInTryMap = FashionBagEditUtils:IsItemInTryMap(itemData.res_id, false, itemData)
    if bInTryMap and itemData.originItem then
      local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
      if LogicFusionModule and LogicFusionModule:IsFusionItem(itemData.res_id) then
        local config = LogicFusionModule:GetFusionConfig(itemData.res_id)
        if config then
          local fusionRecord = LogicFusionModule:GetFusionRecord(config.period)
          if fusionRecord and itemData.originItem ~= fusionRecord.pre_item_id then
            bInTryMap = false
          end
        end
      end
    end
    widget:SetUsingState(bInTryMap)
  else
    widget:SetUsingState(itemData.isUsing)
    if itemData.isUsing and itemData.isNew then
      self:ClearItemNewAndRedPoint(itemData)
    end
  end
  local bIsFreeze = itemData.lock_cnt and 0 < itemData.lock_cnt
  widget:SetIsRedEmotion(bIsFreeze, true)
  if bIsFreeze then
    widget:SetUsingState(false)
  end
  widget:SetColorAndPattern(itemData.color_id or 0, itemData.pattern_id or 0)
  if itemData.planID ~= nil and itemData.planID ~= 0 then
    local callback = function(texturePath)
      if widget then
        local LoadTexture = import("LoadTexture")
        local Texture = LoadTexture.GetTexture2DFromDiskFile(texturePath)
        if Texture then
          widget:SetIconFromTexture(Texture, true)
        end
      end
    end
    local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
    local scheme = WeaponDiySystem:GetSchemeData(itemData.res_id, itemData.planID)
    local WeaponDIYCapture = require("client.slua.logic.weapon_diy.logic_weapon_capture_weapon")
    local hash = Client.MD5HashAnsiString(FuncUtil.SerializeOneTable(scheme))
    WeaponDIYCapture:GetWeaponIconTexture(itemData.res_id, itemData.planID, WeaponDIYCapture.scene.diy_main, scheme, false, callback)
  end
  self:OnPostInitView(widget, itemData)
end
local MergeData = function(originData, newData)
  for k, v in pairs(newData) do
    originData[k] = v
  end
end
function SubTabItemListBase:UpdateOneItem(itemData)
  local index, data = self:GetItemIndexByInsIdAndResId(itemData.ins_id, itemData.res_id)
  if data and next(data) then
    itemData.count = data.count
  end
  if index ~= -1 and data and next(data) then
    itemData.ins_id = nil
    itemData.res_id = nil
    MergeData(data, itemData)
    self.LoopScrollGrid_Normal:RefreshItem(index, data)
  end
end
function SubTabItemListBase:GetItemIndexByInsIdAndResId(ins_id, res_id)
  local itemCount = self.LoopScrollGrid_Normal:GetItemCount()
  for i = 1, itemCount do
    local data = self.LoopScrollGrid_Normal:GetItemData(i)
    if data.ins_id == ins_id and data.res_id == res_id then
      return i, data
    end
  end
  return -1
end
function SubTabItemListBase:GetCurrentSelectItemInsID()
  local CurSelectIndex = self.LoopScrollGrid_Normal:GetSelectIndex()
  local data = self.LoopScrollGrid_Normal:GetItemData(CurSelectIndex)
  if data and data.ins_id then
    return data.ins_id
  end
  return nil
end
function SubTabItemListBase:GetItemIndexByInsId(ins_id)
  local itemCount = self.LoopScrollGrid_Normal:GetItemCount()
  for i = 1, itemCount do
    local data = self.LoopScrollGrid_Normal:GetItemData(i)
    if data.ins_id == ins_id then
      return i, data
    end
  end
  return -1
end
function SubTabItemListBase:SetIconAlpha(widget, alpha)
  widget:SetIconAlpha(alpha)
end
function SubTabItemListBase:SetTryOn(widget, tryOn)
  widget:SetIsTryOn(tryOn)
end
function SubTabItemListBase:SetIsolated(widget, show)
  widget:SetIsolated(show)
end
function SubTabItemListBase:SetUsingState(widget, isUsing)
  widget:SetIsUsing(isUsing)
end
function SubTabItemListBase:SetSelected(widget, isSelected)
  widget:SetSelected(isSelected)
end
function SubTabItemListBase:ShowMask(widget, show)
  widget:ShowMask(show)
end
function SubTabItemListBase:ReloadAllItems()
end
function SubTabItemListBase:RefreshCheckBoxState()
  if self.UIRoot.TextBlock_SortViaTime then
    self.UIRoot.TextBlock_SortViaTime:SetText(LocUtil.LocalizeResFormat(34618))
  end
  local SortPreference = WardrobeLogicManager:GetSortPreference(self.subTabConfig)
  if SortPreference then
    self.UIRoot.CheckBox_Sort:SetCheckedState(1)
  else
    if SortPreference == nil then
      WardrobeLogicManager:SetSortPreference(self.subTabConfig, false)
    end
    self.UIRoot.CheckBox_Sort:SetCheckedState(0)
  end
end
function SubTabItemListBase:RefreshSearchState()
  if self.ComboBox_PlayDate then
    local SortPreference = WardrobeLogicManager:GetSortPreference(self.subTabConfig)
    if SortPreference then
      self.ComboBox_PlayDate:SelectIndex(self.ENUM_SORT_TYPE.LATEST)
    else
      self.ComboBox_PlayDate:SelectIndex(self.ENUM_SORT_TYPE.QUALITY)
    end
  end
  self.searchStr = WardrobeLogicManager:GetSearchString()
  if self.searchStr ~= "" then
    self.UIRoot.Button_Clear:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    self.UIRoot.Button_Clear:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.Search01 then
    self.UIRoot.Search01.message_input:SetText(self.searchStr)
  end
  if self.UIRoot.Text_NameOrUID then
    self.UIRoot.Text_NameOrUID:SetText(self.searchStr)
  end
end
function SubTabItemListBase:OnClickCheckBox()
  self:PlayAudio(sound_config.toggle_v1)
  local isChecked = self.UIRoot.CheckBox_Sort:IsChecked()
  log_tree("god test self.subTabConfig", self.subTabConfig)
  if isChecked then
    WardrobeLogicManager:SetSortPreference(self.subTabConfig, true)
  else
    WardrobeLogicManager:SetSortPreference(self.subTabConfig, false)
  end
  if self.ReSortItem then
    self:ReSortItem()
  else
    self:OnWardrobeDataChange()
  end
end
function SubTabItemListBase:OnUpdatePutOnData(eventType, eventID, putOnItem, putDownItem)
  self:UpdatePutOnData(putOnItem, putDownItem)
  local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  logic_wardrobe_avatar:ProcessTakeOff()
end
function SubTabItemListBase:OnUpdatePutDownData(eventType, eventID, putDownItem)
  self:UpdatePutDownData(putDownItem)
end
function SubTabItemListBase:UpdatePutOnData(putOnItem, putDownItem)
  self:UpdatePutDownData(putDownItem)
  if putOnItem then
    local putOnItemInfo = self:UpdateItemInfo(putOnItem)
    putOnItemInfo.isUsing = true
    local itemCfg = CDataTable.GetTableData("Item", putOnItem.res_id)
    if itemCfg ~= nil then
      local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
      logic_wardrobe_avatar:AddToWearInfo(itemCfg.ItemSubType, putOnItem.instid, putOnItem.res_id, 0, 0)
    end
    self:UpdateOneItem(putOnItemInfo)
  end
end
function SubTabItemListBase:UpdatePutDownData(putDownItem)
  if putDownItem then
    local putDownItemInfo = self:UpdateItemInfo(putDownItem)
    putDownItemInfo.isUsing = false
    local itemCfg = CDataTable.GetTableData("Item", putDownItemInfo.res_id)
    if itemCfg ~= nil then
      local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
      logic_wardrobe_avatar:SetCurrentWearPreview(itemCfg.ItemSubType, nil)
    end
    self:UpdateOneItem(putDownItemInfo)
  end
end
function SubTabItemListBase:UpdateItemInfo(data)
  local item = {}
  item.ins_id = data.instid
  item.res_id = data.res_id
  item.count = data.count ~= nil and data.count or 0
  item.isNew = data.isnew ~= nil and data.isnew ~= 0
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(item.ins_id)
  if not itemInfo then
    item.isSourceBook = true
    item.hasLock = true
  end
  if itemInfo then
    item.hasLimitTime = self:HasLimitTime(itemInfo.expireTS, itemInfo.validHours)
  end
  return item
end
function SubTabItemListBase:HasLimitTime(expire_ts, valid_hours)
  if expire_ts ~= nil and 0 < expire_ts then
    return true
  end
  if valid_hours ~= nil and 0 < valid_hours then
    return true
  end
  return false
end
function SubTabItemListBase:Close()
  self:DirectUnEnlarge()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, nil)
  SubTabItemListBase.__super.Close(self)
end
function SubTabItemListBase:OnPostInitView(widget, itemData)
end
function SubTabItemListBase:GetCurItemID(itemData)
  return itemData.res_id or 0
end
function SubTabItemListBase:IsShowBigIcon()
  return false
end
function SubTabItemListBase:IsPermanentItem(ItemData)
  return ItemData and ItemData.expireTS == 0 and ItemData.validHours == 0
end
function SubTabItemListBase:FilterMultiItem(itemListTable)
  local result = {}
  local MultiLevelResult = {}
  if not itemListTable then
    return result
  end
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local bInFashionBagEditMode = wardrobeLogic:IsInFashionBagEditMode()
  for _, v in pairs(itemListTable) do
    if LogicMultiItemModule:IsWardRobeMultiLevelItem(v.res_id) then
      local GroupID = LogicMultiItemModule:GetMultiItemGroup(v.res_id)
      local bPermanent = self:IsPermanentItem(v)
      if bPermanent then
        GroupID = GroupID + 100000
      end
      if not LogicMultiItemModule:CheckLowLevelHasOwn(v.res_id, self:GetDataSource()) then
        log(bWriteLog and "LogicMultiItemModule CheckLowLevelHasOwn " .. tostring(v.res_id))
      elseif not bInFashionBagEditMode and v.isUsing then
        MultiLevelResult[GroupID] = v
        LogicMultiItemModule:UpdateSelectMultiItem(v.res_id)
      elseif bInFashionBagEditMode and FashionBagEditUtils:IsItemInTryMap(v.res_id, true, v) then
        MultiLevelResult[GroupID] = v
        LogicMultiItemModule:UpdateSelectMultiItem(v.res_id)
      elseif bPermanent and LogicMultiItemModule:IsLastSelectMultiLevel(v.res_id) then
        MultiLevelResult[GroupID] = v
      elseif not MultiLevelResult[GroupID] then
        MultiLevelResult[GroupID] = v
      end
    else
      local CartoonStyleCfg = LogicMultiItemModule:GetCartoonStyleCfg(v.res_id)
      if CartoonStyleCfg then
        if not bInFashionBagEditMode and v.isUsing then
          MultiLevelResult[CartoonStyleCfg.BaseID] = v
        elseif bInFashionBagEditMode and FashionBagEditUtils:IsItemInTryMap(v.res_id, true, v) then
          MultiLevelResult[CartoonStyleCfg.BaseID] = v
        elseif not MultiLevelResult[CartoonStyleCfg.BaseID] and v.res_id == CartoonStyleCfg.BaseID then
          MultiLevelResult[CartoonStyleCfg.BaseID] = v
        end
      elseif LogicFusionModule:IsFusionItem(v.res_id) then
        local config = LogicFusionModule:GetFusionConfig(v.res_id)
        local period = config.period
        local targetItem = config.targetItem
        local fusionRecord = LogicFusionModule:GetFusionRecord(period)
        if fusionRecord and fusionRecord.current_item_id == targetItem then
          if v.res_id == targetItem then
            for _, originItem in pairs(config.originItems) do
              local fusionItemData = DeepCopy(v)
              fusionItemData.              local displayItem = LogicFusionModule:GetDisplayItem(originItem)
              if displayItem then
                WardrobeLogicManager:SetDisplayItemId(fusionItemData, displayItem)
              end
              if originItem ~= fusionRecord.pre_item_id then
                fusionItemData.isUsing = false
              end
              table.insert(result, fusionItemData)
            end
          end
        elseif v.res_id ~= targetItem then
          table.insert(result, v)
        end
      else
        table.insert(result, v)
      end
    end
  end
  for _, v in pairs(MultiLevelResult) do
    table.insert(result, v)
  end
  log_tree("  SubTabItemListBase:FilterMultiItem. result ", result)
  return result
end
function SubTabItemListBase:NeedShowLevelSwitchCanvas(ItemID)
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  if LogicMultiItemModule:IsWardRobeMultiLevelItem(ItemID) then
    return true
  end
  return false
end
function SubTabItemListBase:RefreshSwitchPanel(ItemID)
  local bShow = self:NeedShowLevelSwitchCanvas(ItemID)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_LevelSwitch, bShow, false)
  if not bShow then
    return
  end
  local bShowLock = self:NeedShowLock(ItemID, self:GetDataSource())
  self:SetWidgetVisible(self.UIRoot.Wardrobe_EventSpin_item_2.CanvasPanel_Lock, bShowLock, false)
  local ItemLevel = self:GetItemShowLevel(ItemID)
  self:SetSwitchUsing(ItemLevel)
end
function SubTabItemListBase:GetItemShowLevel(ItemID)
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local Level = 0
  if LogicMultiItemModule:IsWardRobeMultiLevelItem(ItemID) then
    Level = LogicMultiItemModule:GetMultiItemLevel(ItemID)
  end
  return Level
end
function SubTabItemListBase:SetSwitchUsing(ItemLevel)
  if not ItemLevel or ItemLevel < 1 then
    log_error("[WardrobeMultiItem] SubTabItemListBase SetSwitchUsing" .. tostring(ItemLevel))
    return
  end
  local Item_Num = 2
  for i = 1, Item_Num do
    local widget = self.UIRoot["Wardrobe_EventSpin_item_" .. i]
    if widget then
      if i == ItemLevel then
        widget.Button_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        widget.WidgetSwitcher_Level:SetActiveWidgetIndex(1)
        widget.WidgetSwitcher_Using:SetActiveWidgetIndex(1)
      else
        widget.Button_0:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
        widget.WidgetSwitcher_Level:SetActiveWidgetIndex(0)
        widget.WidgetSwitcher_Using:SetActiveWidgetIndex(0)
      end
    end
  end
end
function SubTabItemListBase:NeedShowLock(ItemID, DataSource)
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  if LogicMultiItemModule:CheckLevel2HasOwn(ItemID, DataSource) then
    return false
  end
  return true
end
function SubTabItemListBase:OnClickFilter()
  self:PlayAudio(sound_config.click_v1)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWardrobeTagTips) or {}
  data.bHasShownFilterBtn = true
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eWardrobeTagTips)
  UIManager.ShowUI(UIManager.UI_Config.Wardrobe_Sift_Suit_Popup_UIBP, self:GetInitItemList())
end
function SubTabItemListBase:OnWardrobeTagsSelectChange()
  log(bWriteLog and "SubTabItemListBase:OnWardrobeTagsSelectChange")
  if not self.UIRoot.CanvasPanel_Tags or not self.LoopScrollBox_Tags then
    return
  end
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  local tagList = logic_wardrobe_tag_mgr:GetAllFilterList()
  if tagList and next(tagList) then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Tags, true, false)
    if self.UIRoot.Reddot_Anchor_Item01 then
      self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Item01, true, false)
    end
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Tags, false, false)
    if self.UIRoot.Reddot_Anchor_Item01 then
      self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Item01, false, false)
    end
  end
  log_tree(bWriteLog and "SubTabItemListBase:OnWardrobeTagsSelectChange", tagList)
  self.LoopScrollBox_Tags:SetData(tagList)
  if self.OnSearchChange then
    self:OnSearchChange()
  else
    self:OnWardrobeDataChange()
  end
end
function SubTabItemListBase:OnWardrobeTagsUpdate()
  log(bWriteLog and "SubTabItemListBase:OnWardrobeTagsUpdate")
  if not self.UIRoot.CanvasPanel_Tags or not self.LoopScrollBox_Tags then
    return
  end
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  local tagList = logic_wardrobe_tag_mgr:GetAllFilterList()
  if tagList and next(tagList) then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Tags, true, false)
    if self.UIRoot.Reddot_Anchor_Item01 then
      self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Item01, true, false)
    end
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Tags, false, false)
    if self.UIRoot.Reddot_Anchor_Item01 then
      self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Item01, false, false)
    end
  end
  self.LoopScrollBox_Tags:SetData(tagList)
end
function SubTabItemListBase:CheckCleanTagSelectAndRefresh()
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  if not logic_wardrobe_tag_mgr:IsCurrentPageTagPreserved() then
    logic_wardrobe_tag_mgr:ClearSelectedData()
    self:OnWardrobeTagsUpdate()
  end
end
function SubTabItemListBase:CanShowTagFilter()
  return self.bShowTagFilter
end
function SubTabItemListBase:GetInitItemList()
  return self.OriginItemList or {}
end
function SubTabItemListBase:SetInitItemList(itemList)
  if self:ItemCompareWithList(self.OriginItemList, itemList) then
    log(bWriteLog and "xcc SubTabItemListBase:SetInitItemList not need re-select")
    return
  end
  log(bWriteLog and "xcc SubTabItemListBase:SetInitItemList re-select")
  self.OriginItemList = itemList
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe:WardrobeSelectWithSaveOperation(self.OriginItemList)
end
function SubTabItemListBase:ItemCompareWithList(oriList, newList)
  if not (oriList and newList) or #oriList ~= #newList then
    return false
  end
  for index, oriCfg in pairs(oriList) do
    local newCfg = newList[index]
    if oriCfg.validHours ~= newCfg.validHours or oriCfg.expireTS ~= newCfg.expireTS or oriCfg.ins_id ~= newCfg.ins_id or oriCfg.res_id ~= newCfg.res_id then
      return false
    end
  end
  return true
end
function SubTabItemListBase:OnBeginLobbySkinChange()
  if self.bHasEnlarged then
    self:TryDirectEnlarge()
  end
end
function SubTabItemListBase:OnTeamChange()
  if self.bHasEnlarged then
    self:TryDirectEnlarge()
  end
end
function SubTabItemListBase:OnFashionBagEditUpdate(_, __)
  self.LoopScrollGrid_Normal:RefreshAllItems()
end
function SubTabItemListBase:OnFashionBagEditExit(_, __)
  self.LoopScrollGrid_Normal:RefreshAllItems()
  self.LoopScrollGrid_Normal:Deselect()
end
function SubTabItemListBase:OnWardrobeSpecialIdleSwitch(_, __)
  self:TryDirectEnlarge()
end
function SubTabItemListBase:OnLoginSuccess(_, __, bReLogin)
  if not bReLogin then
    return
  end
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if WardrobeLogicManager:GetWardrobeEditMode() ~= wardrobe_macro.EWardrobeEditMode.FashionBag then
    return
  end
  self:TryDirectEnlarge()
  self:OnReloginInFashionBagEditMode()
end
function SubTabItemListBase:OnReloginInFashionBagEditMode()
end
function SubTabItemListBase:OnItemClickDownload(_, _, data, extraData)
  if not (data and type(data) == "table" and not (#data <= 0) and tonumber(data[1])) or 0 >= tonumber(data[1]) then
    return
  end
  local itemCfg = CDataTable.GetTableData("Item", tonumber(data[1]))
  if not itemCfg then
    return
  end
  log(bWriteLog and "SubTabItemListBase:OnClickDownloadCallBack ItemID:" .. tostring(itemCfg.ItemID) .. ", ItemTyp:" .. tostring(itemCfg.ItemType) .. ", ItemSubType:" .. tostring(itemCfg.ItemSubType))
  self.ClickDownLoadItemID = itemCfg.ItemID
end
function SubTabItemListBase:GetArrayHallDepotItemInfo()
  local DataEntity = self:GetDataEntity()
  return DataEntity:GetData()
end
function SubTabItemListBase:GetFilterFunc()
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local CurrentShareType = WardrobeLogicManager:GetShareType()
  local eWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode()
  local wardrobe_fashion_utils = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local searchStr = ""
  if self.UIRoot.WidgetSwitcher_Search then
    searchStr = WardrobeLogicManager:GetSearchString()
  end
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  local SelectedCornerTagList
  if logic_wardrobe_tag_mgr:HasEnabledCornerTag() then
    SelectedCornerTagList = logic_wardrobe_tag_mgr:GetSelectedCornerTagList()
  end
  local EnabledCustomTag = logic_wardrobe_tag_mgr:HasEnabledCustomTag()
  local EnableTimeFilter = logic_wardrobe_tag_mgr:IsTimeFilterEnabled()
  local StartTime, EndTime
  if EnableTimeFilter then
    local StartTimeInfo, EndTimeInfo = logic_wardrobe_tag_mgr:GetSelectedTimeInfo()
    if StartTimeInfo and StartTimeInfo.Year and StartTimeInfo.Month then
      StartTime = TimeUtil.OSTime({
        year = StartTimeInfo.Year,
        month = StartTimeInfo.Month,
        day = 1
      })
    end
    if EndTimeInfo and EndTimeInfo.Year and EndTimeInfo.Month then
      EndTime = TimeUtil.OSTime({
        year = EndTimeInfo.Year,
        month = EndTimeInfo.Month,
        day = 31
      })
    end
    if not StartTime and not EndTime then
      EnableTimeFilter = false
    end
  end
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local MultiLevelItemCache = {}
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local bInFashionBagEditMode = wardrobeLogic:IsInFashionBagEditMode()
  local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
  local func = function(originData)
    local itemCfg = CDataTable.GetTableData("Item", originData.resID)
    if not itemCfg then
      return 0
    end
    if not WardrobeLogicManager:IsValidCurrentPageItem(self.subTabConfig.pageId, self.subTabConfig.subTabId, originData, serverTime) then
      return 0
    end
    if eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Intimacy and not wardrobe_fashion_utils.CanBeSharedByItem(originData) then
      return 0
    end
    if eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag and not wardrobe_fashion_utils.CanBeSharedInShareBag(originData, CurrentShareType) then
      return 0
    end
    if searchStr and searchStr ~= "" then
      local name = itemCfg.itemName
      if not name or not string.find(string.lower(name), string.lower(searchStr), 1, true) then
        return 0
      end
    end
    if self.bShowTagFilter then
      if SelectedCornerTagList then
        local SpecialIcon = itemCfg.SpecialIcon
        if SpecialIcon then
          local CornerTag = CDataTable.GetTableData("NewCornerIconTypeConfig", SpecialIcon)
          if CornerTag and CornerTag.TypeID and SelectedCornerTagList[CornerTag.TypeID] then
          else
            return 0
          end
        end
      end
      if EnabledCustomTag and not logic_wardrobe_tag_mgr:IsItemMatchCustomTag(originData.resID) then
        return 0
      end
      if EnableTimeFilter then
        if not originData.High32Bits then
          originData.High32Bits = WardrobeLogicManager:ExtractHigh32Bits(originData.insID)
        end
        local GetTime = originData.High32Bits
        if StartTime and GetTime < StartTime then
          return 0
        end
        if EndTime and GetTime > EndTime then
          return 0
        end
      end
    end
    if LogicMultiItemModule:IsWardRobeMultiLevelItem(originData.resID) then
      local GroupID = LogicMultiItemModule:GetMultiItemGroup(originData.resID)
      if MultiLevelItemCache[GroupID] == nil then
        MultiLevelItemCache[GroupID] = LogicMultiItemModule:GetDisPlayItemByGroup(GroupID, self:GetDataSource(), itemCfg.ItemSubType) or false
      end
      if originData.resID ~= MultiLevelItemCache[GroupID] then
        return 0
      end
    end
    local CartoonStyleCfg = LogicMultiItemModule:GetCartoonStyleCfg(originData.resID)
    if CartoonStyleCfg then
      local wear
      if bInFashionBagEditMode then
        wear = FashionBagEditUtils:IsItemInTryMap(CartoonStyleCfg.CartoonStyleID, true)
      else
        local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
        local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(itemCfg.ItemSubType)
        wear = wearInfo and CartoonStyleCfg.CartoonStyleID == wearInfo.resID or false
      end
      if wear == (originData.resID == CartoonStyleCfg.BaseID) then
        return 0
      end
    end
    if originData.lock_cnt and 0 < originData.lock_cnt and 0 < originData.count then
      return 2
    end
    return 1
  end
  return func
end
function SubTabItemListBase:GetConvertFunc()
  local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  local lockInsIDSet = {}
  local func = function(originData)
    local isWear = false
    local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(originData.itemSubType)
    if wearInfo ~= nil then
      isWear = wearInfo.insID == originData.insID
    end
    local itemInfo = WardrobeLogicManager:ArrayHallDepotToCommonItem(originData, nil, isWear, true, false, false)
    itemInfo.isRolewear = false
    if itemInfo.lock_cnt and itemInfo.lock_cnt > 0 then
      if itemInfo.count == 0 then
        itemInfo.count = itemInfo.lock_cnt
      elseif not lockInsIDSet[originData.insID] then
        lockInsIDSet[originData.insID] = true
        itemInfo.lock_cnt = 0
      else
        lockInsIDSet[originData.insID] = nil
        itemInfo.count = itemInfo.lock_cnt
      end
    end
    return itemInfo
  end
  return func
end
function SubTabItemListBase:GetDataEntity()
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData(self:GetDataSource())
  return DataEntity
end
function SubTabItemListBase:GetDataSource()
  if self:InInheritMode() then
    return EWardrobeDataSource.InheritWardrobe
  end
  return EWardrobeDataSource.Wardrobe
end
function SubTabItemListBase:InInheritMode()
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local eWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode()
  if eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Inherit then
    return true
  end
  return false
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CSubTabItemListBase = class(ui_base, nil, SubTabItemListBase)
return CSubTabItemListBase