local WardrobeSuit = {
  switchLevel = 0,
  goldenSuitLevel = 0,
  showSwitchTip = nil,
  period = nil
}
local CLICK_INTERVAL = 2
local partNum = 6
local C_First_Column = 1
local C_Second_Column = 2
local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
local CONST_SUBSCRIBE_SHARE_ITEM_COUNT = 10
local ENUM_TabId = {ENUM_TabId_Suit = 1, ENUM_TabId_Match = 2}
function WardrobeSuit:ctor(selfType, subTabConfig)
  self.curSelectIndex = 0
  self.preSelectIndex = 0
  self.SuitMatchList = {}
  self.OriginalSuitMatchList = {}
end
function WardrobeSuit:OnInitialize()
  log(bWriteLog and string.format("WardrobeSuit:OnInitialize"))
  WardrobeSuit.__super.OnInitialize(self)
  local tabList = {
    [1] = LocUtil.LocalizeResFormat(43334),
    [2] = LocUtil.LocalizeResFormat(43335)
  }
  self.Common_Tab_SuitMode = self:InitHorizontalLevelTwoTextTab(self.UIRoot.Common_Tab_SuitMode)
  self.Common_Tab_SuitMode:SetTabs(tabList, 1)
  self.Common_Tab_SuitMode:AddOnClickedCallback(self.OnClickHorizontalTabButton, self)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bShowTabSuitmode = true
  if WardrobeLogicManager:GetWardrobeEditMode() ~= wardrobe_macro.EWardrobeEditMode.None or UIManager.GetUI(UIManager.UI_Config.Lobby_Subhall_Cloth_UIBP) then
    bShowTabSuitmode = false
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_16, bShowTabSuitmode)
  self.LoopScrollGrid_Match = self:InitChildClassScrollBox(self.UIRoot.LoopScrollGrid_Match, "client.slua.umg.Wardrobe.subtab_matchItem")
  self.LoopScrollBox_SwitchHead = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_SwitchHead, "client.slua.umg.Wardrobe.WardrobeItem.WardrobeLeftSwitchHeadItem", true)
  self.ExtendedLoopScrollGrid_MatchItem = self:InitExtendedScrollGrid(self.UIRoot.ExtendedLoopScrollGrid_MatchItem, {
    "client.slua.umg.Wardrobe.Item.Wardrobe_Suit_Line_UIBP",
    "client.slua.umg.Wardrobe.Item.Wardrobe_Suit_Match_Item"
  })
end
function WardrobeSuit:RegistEvents()
  WardrobeSuit.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CLOTH_FUSION_UPDATE, self.OnFusionUpdate, self)
  self:AddCommonEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_UPDATE_DRESS_LEVEL, self.OnSwitchLevelUpdate, self)
  self:AddCommonEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_UPDATE_DRESS_STATE, self.OnStateUpdate, self)
  self:AddControlEventByControl(self.UIRoot.Wardrobe_pharaohrises_item.Button_0, "OnClicked", self.OnSwitchLevelClick, self, 1)
  self:AddControlEventByControl(self.UIRoot.Wardrobe_pharaohrises_item_0.Button_0, "OnClicked", self.OnSwitchLevelClick, self, 3)
  self:AddControlEventByControl(self.UIRoot.Wardrobe_pharaohrises_item_1.Button_0, "OnClicked", self.OnSwitchLevelClick, self, 6)
  self:AddControlEventByControl(self.UIRoot.Wardrobe_pharaohrises_item_2.Button_0, "OnClicked", self.OnSwitchLevelClick, self, 7)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ChangeState, self.OnChangeStateClick, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SUIT_ZOOM, self.ZoomToHead, self)
  self:AddCommonEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_SWITCH_SUC, self.OnChangeSwitchSucc, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_AVATAR_GAME_GENDER_CHANGE, self.OnGameGenderChange, self)
end
function WardrobeSuit:OnShow()
  self:OnClickButtonSuit()
  self:RefreshShareAvatarSlot()
  local index = self.Common_Tab_SuitMode:GetSelectedIndex()
  self:CheckChangeHeadNewGuideShow(index)
end
function WardrobeSuit:OnClose()
  self.bIsShowClothMatch = false
  self.cObj_clothMatchLoop = nil
  WardrobeSuit.__super.OnClose(self)
end
function WardrobeSuit:OnFashionBagChange()
  WardrobeSuit.__super.OnFashionBagChange(self)
  local index = self.Common_Tab_SuitMode:GetSelectedIndex()
  if index == ENUM_TabId.ENUM_TabId_Suit then
    self:RefreshSuitList()
    self:UpdateGoldenSuitButton()
    self:UpdateGoldChangeHeadPanel()
  elseif index == ENUM_TabId.ENUM_TabId_Match then
    self:RefreshMatchList()
  end
  self:InitTips()
end
function WardrobeSuit:OnClickHorizontalTabButton(widget, index)
  self:PlayAudio(sound_config.click_v1)
  if index == ENUM_TabId.ENUM_TabId_Suit then
    self:OnClickButtonSuit()
  elseif index == ENUM_TabId.ENUM_TabId_Match then
    self:OnClickButtonMatch()
  end
  self.UIRoot.HorizontalBox_Wardrobe_Clothes:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function WardrobeSuit:CanShowFusionLevelSwitch()
  local index = self.Common_Tab_SuitMode and self.Common_Tab_SuitMode:GetSelectedIndex() or ENUM_TabId.ENUM_TabId_Suit
  return index ~= ENUM_TabId.ENUM_TabId_Match
end
function WardrobeSuit:OnClickButtonSuit()
  self.bIsShowClothMatch = false
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Match, false)
  self:SetWidgetVisible(self.UIRoot.LoopScrollGrid_Avatar, true, true)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_MatchItem, false)
  self.ComboBox_PlayDate:SetData(self.sortTypeList)
  self:RefreshSearchState()
  self:RefreshSuitList()
  self:InitTips()
  self:UpdateGoldenSuitButton()
  self:UpdateGoldChangeHeadPanel()
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  logic_wardrobe_tag_mgr:UpdateItemList(self:GetInitItemList())
  logic_wardrobe_tag_mgr:GetCustomTagList()
end
function WardrobeSuit:OnClickButtonMatch()
  self.bIsShowClothMatch = true
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Match, true)
  self:SetWidgetVisible(self.UIRoot.LoopScrollGrid_Avatar, false, true)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_MatchItem, false)
  self:InitTips()
  self.UIRoot.CanvasPanel_4:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_LevelSwitch, false)
  self:SetSwitchHeadPanelShow(false)
  local logic_outfit_combination = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_outfit_combination)
  local types = logic_outfit_combination:GetMatchTypeSortTypeList()
  self.ComboBox_PlayDate:SetData(types)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local SortPreference = WardrobeLogicManager:GetMatchTabSortPreference()
  self.ComboBox_PlayDate:SelectIndex(SortPreference)
  log(bWriteLog and string.format("WardrobeSuit:OnClickButtonMatch SortPreference: %s", SortPreference))
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  logic_wardrobe_tag_mgr:UpdateItemList(self:GetInitItemList())
  logic_wardrobe_tag_mgr:GetCustomTagList()
end
function WardrobeSuit:GetInitItemList()
  local index = self.Common_Tab_SuitMode:GetSelectedIndex()
  if index == ENUM_TabId.ENUM_TabId_Suit then
    return self.OriginItemList or {}
  else
    local logic_outfit_combination = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_outfit_combination)
    local itemList = logic_outfit_combination:GetItemListForFilter(self.OriginalSuitMatchList)
    return itemList
  end
end
function WardrobeSuit:ShowBottomRightTips(ins_id, res_id)
  local index = self.Common_Tab_SuitMode:GetSelectedIndex()
  if index == ENUM_TabId.ENUM_TabId_Suit then
    WardrobeSuit.__super.ShowBottomRightTips(self, ins_id, res_id)
  end
end
function WardrobeSuit:OnSelectSortItem(widget, data)
  local index = self.Common_Tab_SuitMode:GetSelectedIndex()
  if index == ENUM_TabId.ENUM_TabId_Suit then
    WardrobeSuit.__super.OnSelectSortItem(self, widget, data)
  else
    self:PlayAudio(sound_config.click_v1)
    widget.TextBlock_ItemName:SetText(data.text)
    local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    WardrobeLogicManager:SetMatchSortPreference(data.type)
    self:RefreshMatchList()
  end
end
function WardrobeSuit:RefreshSuitList()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if WardrobeLogicManager:GetWardrobeEditMode() ~= wardrobe_macro.EWardrobeEditMode.None then
    WardrobeSuit.__super.UpdateAvatarList(self)
    return
  end
  local index = self.Common_Tab_SuitMode:GetSelectedIndex()
  if index ~= ENUM_TabId.ENUM_TabId_Suit then
    return
  end
  WardrobeSuit.__super.UpdateAvatarList(self)
end
function WardrobeSuit:RefreshMatchList()
  local index = self.Common_Tab_SuitMode:GetSelectedIndex()
  if index ~= ENUM_TabId.ENUM_TabId_Match then
    return
  end
  self:InitSuitMatchList()
end
function WardrobeSuit:SetMatchTabList()
  local suitList = self.SuitMatchList
  if 0 < #suitList then
    self.LoopScrollGrid_Match:SetData(suitList)
    self.cObj_clothMatchLoop = self.LoopScrollGrid_Match
  end
  local logic_outfit_combination = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_outfit_combination)
  local isOpen = logic_outfit_combination:IsOpenRandom()
  local num = isOpen and 1 or 0
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_NoItem, num >= #suitList)
  self:InitCurSelectIndex(self.SuitMatchList)
end
function WardrobeSuit:InitSuitMatchList()
  local logic_outfit_combination = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_outfit_combination)
  local suitList = logic_outfit_combination:GetOutfitCombinationList()
  local TableUtil = require("common.table_util")
  self.OriginalSuitMatchList = TableUtil.LiteCopy(suitList, true)
  self.SuitMatchList = self:FilterMatchTabList(suitList)
  local isOpen = logic_outfit_combination:IsOpenRandom()
  if isOpen and 0 < #suitList then
    table.insert(self.SuitMatchList, 1, {randomButton = true, openRandom = false})
  end
  logic_outfit_combination:SortMatchTabList(self.SuitMatchList)
  self:SetMatchTabList()
end
function WardrobeSuit:GetOriginalSuitMatchList()
  return self.OriginalSuitMatchList
end
function WardrobeSuit:OnSearchChange()
  local index = self.Common_Tab_SuitMode:GetSelectedIndex()
  if index == ENUM_TabId.ENUM_TabId_Suit then
    self:OnWardrobeDataChange()
  elseif index == ENUM_TabId.ENUM_TabId_Match then
    self:InitSuitMatchList()
  end
end
function WardrobeSuit:FilterMatchTabList(list)
  local result = list
  if self.UIRoot.WidgetSwitcher_Search then
    local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    result = self:DoSearchMatchTabList(list, WardrobeLogicManager:GetSearchString())
  end
  local logic_outfit_combination = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_outfit_combination)
  result = logic_outfit_combination:DoFilterByFusionRecordMatchTabList(result)
  if self.bShowTagFilter then
    result = logic_outfit_combination:DoFilterTagsMatchTabList(result)
  end
  return result
end
function WardrobeSuit:DoSearchMatchTabList(itemListTable, str)
  if not str or str == "" then
    return itemListTable
  end
  local result = {}
  if not itemListTable then
    return result
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, v in pairs(itemListTable) do
    local name = v.name
    if name and string.find(string.lower(name), string.lower(str), 1, true) then
      table.insert(result, v)
    else
      for i = 1, partNum do
        local insId = v["part" .. tostring(i)]
        if insId and 0 < insId then
          local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(insId)
          local itemName = itemInfo.itemName
          if itemName and string.find(string.lower(name), string.lower(str), 1, true) then
            table.insert(result, v)
            break
          end
        end
      end
    end
  end
  return result
end
function WardrobeSuit:SetCurrentSelectMatchList(tData)
  local SimpleUI_Clothes = UIManager.GetUI(UIManager.UI_Config.Lobby_SimpleUI_Clothes_UIBP)
  local SubhallClothUIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Subhall_Cloth_UIBP)
  if SimpleUI_Clothes or SubhallClothUIBP then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_MatchItem, false)
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local list = {}
  local first, mainPartInsID, mainPartResID = false, 0, 0
  if tData then
    for i = 1, partNum do
      local insId = tData["part" .. tostring(i)]
      if insId and 0 < insId then
        local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(insId)
        if not list[C_First_Column] then
          list[C_First_Column] = {}
        end
        table.insert(list[C_First_Column], itemInfo.resID)
        if not first then
          first, mainPartInsID, mainPartResID = true, insId, itemInfo.resID
        end
      end
    end
    for i, v in ipairs(tData.additionalPart or {}) do
      if not list[C_Second_Column] then
        list[C_Second_Column] = {}
      end
      table.insert(list[C_Second_Column], v)
    end
  end
  self.ExtendedLoopScrollGrid_MatchItem:SetData(list)
  for k, v in pairs(list) do
    self.ExtendedLoopScrollGrid_MatchItem:SetSubData(k, v)
  end
  self:SetMatchItemBG(list)
  if list[C_First_Column] and 0 < #list[C_First_Column] then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_MatchItem, true)
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_MatchItem, false)
  end
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  tipsMgr:Show(tipsMgr.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_SUIT, mainPartInsID, mainPartResID, tData.ID)
end
function WardrobeSuit:SetMatchItemBG(nList)
  local fNum = 0
  if nList[C_First_Column] then
    fNum = #nList[C_First_Column]
  end
  local sNum = 0
  if nList[C_Second_Column] then
    sNum = #nList[C_Second_Column]
  end
  local len = 0
  if 0 < fNum then
    len = fNum * 66 + 6
  end
  if 0 < sNum then
    len = len + 6
    len = len + sNum * 66
  end
  if 270 < len then
    self.UIRoot.Image_MatchItem.Slot:SetOffsets(FMargin(0, 0, 72, -15))
  else
    self.UIRoot.Image_MatchItem.Slot:SetOffsets(FMargin(0, 0, 72, -15 + (270 - len)))
  end
  self:SetWidgetVisible(self.UIRoot.Image_MatchItem, 0 < fNum)
end
function WardrobeSuit:RefreshSuitIcon(widget, suitConfig)
  local UIUtil = require("client.common.ui_util")
  local iconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(suitConfig.part1, widget.Image_Icon)
  local params = {sync = false, bHasAddKnownMissing = bHasAddKnownMissing}
  self:SetTexture(widget.Image_Icon, iconPath, params)
  local QualityPath = UIUtil.GetBgQualityPath(suitConfig.quality)
  self:SetTexture(widget.Image_Quality_Bg, QualityPath)
  self:SetWidgetVisible(widget.Image_Quality_Bg, true)
  self:SetWidgetVisible(widget.Image_Icon_Quality_Bottom, false)
end
function WardrobeSuit:InitCurSelectIndex(suitList)
  local logic_outfit_combination = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_outfit_combination)
  for i, v in ipairs(suitList) do
    if not v.randomButton and logic_outfit_combination:IsSuitWearing(v) then
      self.curSelectIndex = i
      self:SetCurrentSelectMatchList(v)
      self:RefreshMultiLevelCanvas()
      break
    end
  end
end
function WardrobeSuit:OnUpdatePutOnData(eventType, eventID, putOnItem, putDownItem)
  WardrobeSuit.__super.OnUpdatePutOnData(self, eventType, eventID, putOnItem, putDownItem)
  local index = self.Common_Tab_SuitMode:GetSelectedIndex()
  if index == ENUM_TabId.ENUM_TabId_Suit then
    local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
    if putDownItem then
      if LogicXSuit.IsXSuit(putDownItem.res_id) then
        self.UIRoot.CanvasPanel_4:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
      if logic_suit_multi_shape:CanCurrentSuitChangeHead(putDownItem.res_id) then
        self:SetSwitchHeadPanelShow(false)
      end
    end
    if putOnItem ~= nil then
      if LogicXSuit.IsXSuit(putOnItem.res_id) then
        self.goldenSuitLevel = LogicXSuit.GetLevelByItemId(putOnItem.res_id) or 0
        self.UIRoot.CanvasPanel_4:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.switchLevel = LogicXSuit.GetSwitchLevelByInsID(putOnItem.instid)
        self.period = LogicXSuit.GetPeriodByItemId(putOnItem.res_id)
        self:SetSwitchLevel(self.switchLevel, self.goldenSuitLevel, self.period)
        self:UpdateChangeStateButton(putOnItem.res_id)
      else
        self:UpdateChangeStateButton(putOnItem.res_id)
      end
      if logic_suit_multi_shape:CanCurrentSuitChangeHead(putOnItem.res_id) then
        self:UpdateGoldChangeHeadPanel(putOnItem.res_id)
      end
    end
  elseif index == ENUM_TabId.ENUM_TabId_Match then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    if putOnItem ~= nil then
      if LogicXSuit.IsXSuit(putOnItem.res_id) then
        self.goldenSuitLevel = LogicXSuit.GetLevelByItemId(putOnItem.res_id) or 0
        self.switchLevel = LogicXSuit.GetSwitchLevelByInsID(putOnItem.instid)
        self.period = LogicXSuit.GetPeriodByItemId(putOnItem.res_id)
      end
      local itemData = wardrobe_data:GetHallDepotItemDataByInsID(putOnItem.instid)
      if itemData and itemData.itemType == ENUM_ITEM_TYPE.Extra and itemData.itemSubType == ENUM_ITEM_SUBTYPE.Backpack_Pendant_Skin then
        local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
        logic_wardrobe:ShowBagPendantModel(putOnItem.instid, true)
        if putDownItem ~= nil then
          logic_wardrobe:ShowBagPendantModel(putDownItem.instid, false)
        end
      end
    end
  end
end
function WardrobeSuit:OnUpdatePutDownData(eventType, eventID, putDownItem)
  WardrobeSuit.__super.OnUpdatePutDownData(self, eventType, eventID, putDownItem)
  local index = self.Common_Tab_SuitMode:GetSelectedIndex()
  if index == ENUM_TabId.ENUM_TabId_Suit then
    if LogicXSuit.IsXSuit(putDownItem.res_id) then
      self.UIRoot.CanvasPanel_4:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
    if logic_suit_multi_shape:CanCurrentSuitChangeHead(putDownItem.res_id) then
      self:SetSwitchHeadPanelShow(false)
    end
  elseif index == ENUM_TabId.ENUM_TabId_Match then
    local selectIndex = self.LoopScrollGrid_Match:GetSelectIndex()
    if 0 < selectIndex then
      self.LoopScrollGrid_Match:RefreshItem(selectIndex)
      self.cObj_clothMatchLoop = self.LoopScrollGrid_Match
    end
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(putDownItem.instid)
    if itemData and itemData.itemType == ENUM_ITEM_TYPE.Extra and itemData.itemSubType == ENUM_ITEM_SUBTYPE.Backpack_Pendant_Skin then
      local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      logic_wardrobe:ShowBagPendantModel(putDownItem.instid, false)
    end
  end
end
function WardrobeSuit:SimpleUIRemove(_, _, DragDropData)
  WardrobeSuit.__super.SimpleUIRemove(self, _, _, DragDropData)
  if self.LoopScrollGrid_Match:GetItemCount() == 0 then
    return
  end
  local dragAvatarInsID = DragDropData.dragExtendData
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = WardrobeDataManager:GetHallDepotItemDataByResID(dragAvatarInsID)
  if itemData then
    for key, value in pairs(self.SuitMatchList) do
      if value.part1 and itemData.insID == value.part1 then
        self.LoopScrollGrid_Match:RefreshItem(key)
        self.cObj_clothMatchLoop = self.LoopScrollGrid_Match
        break
      end
    end
  end
end
function WardrobeSuit:OnAvatarDragReadyToShape(DragWidget, Index, GeneratedWidget, DragDropData)
  log(bWriteLog and "WardrobeAvatar:OnAvatarDragReadyToShape")
  local itemData = self:GetItemData(Index)
  self:InitDragWidget(GeneratedWidget, itemData.res_id)
  self:BeginAvatarDragHint(1)
end
function WardrobeSuit:OnAvatarDragCanceled()
  log(bWriteLog and "WardrobeAvatar:OnAvatarDragCanceled")
  self:EndAvatarDragHint()
end
function WardrobeSuit:SwtichLevelChange(control, starNum, isLock, isSelect, period)
  if self:InInheritMode() then
    control:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local maxLevel = LogicXSuit.GetActSuitMaxLevelByPeriod(period)
  if starNum > maxLevel then
    control:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  else
    control:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  for i = 1, 7 do
    local star = control["WidgetSwitcher_" .. i]
    if i <= starNum then
      star:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      if isSelect then
        star:SetActiveWidgetIndex(1)
      else
        star:SetActiveWidgetIndex(0)
      end
    else
      star:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  if isSelect then
    control.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  else
    control.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  end
  if isLock then
    if control.CanvasPanel_3 then
      control.CanvasPanel_3:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif control.CanvasPanel_3 then
    control.CanvasPanel_3:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function WardrobeSuit:SetSwitchLevel(selectLevel, maxLevel, period)
  self:SwtichLevelChange(self.UIRoot.Wardrobe_pharaohrises_item, 1, maxLevel < 1, selectLevel == 1, period)
  self:SwtichLevelChange(self.UIRoot.Wardrobe_pharaohrises_item_0, 3, maxLevel < 3, selectLevel == 3, period)
  self:SwtichLevelChange(self.UIRoot.Wardrobe_pharaohrises_item_1, 6, maxLevel < 6, selectLevel == 6, period)
  self:SwtichLevelChange(self.UIRoot.Wardrobe_pharaohrises_item_2, 7, maxLevel < 7, selectLevel == 7, period)
  if not self.showSwitchTip then
    local LogicNewbie = require("client.logic.newbie.logic_newbie")
    local GuideType = LogicNewbie.NEWBIE_GUIDE_MODULE_WARDROBE_XSUIT
    local bGuide = DataMgr.HaveNewbieGuide(GuideType, 1)
    if bGuide and not self:InInheritMode() then
      self.showSwitchTip = true
    else
      self.showSwitchTip = false
    end
  end
  if self.showSwitchTip then
    self.UIRoot.CanvasPanel_13:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.CanvasPanel_13:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function WardrobeSuit:OnSwitchLevelClick(index)
  self:PlayAudio(sound_config.click_v1)
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.subtab_suit) then
    return
  end
  if self.showSwitchTip then
    local LogicNewbie = require("client.logic.newbie.logic_newbie")
    local GuideType = LogicNewbie.NEWBIE_GUIDE_MODULE_WARDROBE_XSUIT
    DataMgr.SetNewbieGuide(GuideType, 1)
    self.showSwitchTip = false
    self.UIRoot.CanvasPanel_13:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if index == self.switchLevel then
    return
  end
  LogicXSuit.SetSwitchLevelByPeriod(self.period, index)
end
function WardrobeSuit:OnChangeStateClick()
  log(bWriteLog and "WardrobeSuit OnChangeStateClick ")
  self:PlayAudio(sound_config.click_v1)
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.subtab_suit) then
    return
  end
  local state = LogicXSuit.GetCurStateByPeriod(self.period, self:GetDataSource())
  if state then
    if state == 1 then
      state = 2
    else
      state = 1
    end
    if LogicXSuit.CheckUnlockState(self.period, state, self:GetDataSource()) then
      LogicXSuit.SendSetGoldDressStateReq(self.period, state, self:GetDataSource())
    else
      ShowNotice(44672)
    end
  else
    log(bWriteLog and "WardrobeSuit:OnChangeStateClick miss state")
  end
end
function WardrobeSuit:OnSwitchLevelUpdate()
  if not self.period then
    return
  end
  self.switchLevel = LogicXSuit.GetSwitchLevelByPeriod(self.period)
  self:SetSwitchLevel(self.switchLevel, self.goldenSuitLevel, self.period)
  self:UpdateChangeStateButton(LogicXSuit.GetItemIDByPeriod(self.period))
  local itemID
  local index = self.Common_Tab_SuitMode:GetSelectedIndex()
  if index == ENUM_TabId.ENUM_TabId_Suit then
    local insID = self:GetCurrentSelectItemInsID()
    if insID then
      itemID = LogicXSuit.GetItemShowID(insID)
    end
  end
  log_format("WardrobeSuit:OnSwitchLevelUpdate. itemID=%s", itemID)
  if itemID then
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, itemID)
  end
end
function WardrobeSuit:OnStateUpdate()
  self:UpdateChangeStateButton(LogicXSuit.GetItemIDByPeriod(self.period, self:GetDataSource()))
  self:UpdateAvatarList()
end
function WardrobeSuit:OnFusionUpdate(_, _, changedPeriods)
  log(bWriteLog and "WardrobeSuit:OnFusionUpdate")
  if not changedPeriods or not next(changedPeriods) then
    self:UpdateAvatarList()
    return
  end
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  local itemCount = self.LoopScrollGrid_Normal:GetItemCount()
  for i = 1, itemCount do
    local data = self.LoopScrollGrid_Normal:GetItemData(i)
    if data then
      local originResId = data.originItem or data.res_id
      local config = LogicFusionModule:GetFusionConfig(originResId)
      if config and changedPeriods[config.period] then
        local newItemData = self:RebuildFusionItemData(config, originResId)
        if newItemData then
          self.LoopScrollGrid_Normal:RefreshItem(i, newItemData)
        else
          log_error("WardrobeSuit:OnFusionUpdate. RebuildFusionItemData failed")
        end
      end
    end
  end
  self:UpdateAvatarSlotList()
  self:RefreshMultiLevelCanvas()
end
function WardrobeSuit:GetItemIndexByInsIdAndResId(ins_id, res_id)
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  if not LogicFusionModule:IsFusionTargetItem(res_id) then
    return WardrobeSuit.__super.GetItemIndexByInsIdAndResId(self, ins_id, res_id)
  end
  local config = LogicFusionModule:GetFusionConfig(res_id)
  if not config then
    return WardrobeSuit.__super.GetItemIndexByInsIdAndResId(self, ins_id, res_id)
  end
  local fusionRecord = LogicFusionModule:GetFusionRecord(config.period)
  if not fusionRecord or fusionRecord.current_item_id ~= res_id then
    return WardrobeSuit.__super.GetItemIndexByInsIdAndResId(self, ins_id, res_id)
  end
  local preItemId = fusionRecord.pre_item_id
  local itemCount = self.LoopScrollGrid_Normal:GetItemCount()
  for i = 1, itemCount do
    local data = self.LoopScrollGrid_Normal:GetItemData(i)
    if data and data.ins_id == ins_id and data.res_id == res_id and data.originItem == preItemId then
      return i, data
    end
  end
  return WardrobeSuit.__super.GetItemIndexByInsIdAndResId(self, ins_id, res_id)
end
function WardrobeSuit:RebuildFusionItemData(config, originResId)
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local period = config.period
  local targetItem = config.targetItem
  local fusionRecord = LogicFusionModule:GetFusionRecord(period)
  if not fusionRecord then
    return nil
  end
  if fusionRecord.current_item_id == targetItem then
    local depotData = wardrobe_data:GetHallDepotItemDataByResID(targetItem)
    if not depotData then
      return nil
    end
    local isWear = false
    local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(depotData.itemSubType)
    if wearInfo ~= nil then
      isWear = wearInfo.insID == depotData.insID and wearInfo.resID == depotData.resID
    end
    local isUsing = isWear and originResId == fusionRecord.pre_item_id
    local itemInfo = WardrobeLogicManager:ArrayHallDepotToCommonItem(depotData, nil, isUsing, true, false, false)
    itemInfo.isRolewear = false
    itemInfo.originItem = originResId
    local displayItem = LogicFusionModule:GetDisplayItem(originResId)
    if displayItem then
      WardrobeLogicManager:SetDisplayItemId(itemInfo, displayItem)
    end
    return itemInfo
  else
    local depotData = wardrobe_data:GetHallDepotItemDataByResID(originResId)
    if not depotData then
      return nil
    end
    local isWear = false
    local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(depotData.itemSubType)
    if wearInfo ~= nil then
      isWear = wearInfo.insID == depotData.insID and wearInfo.resID == depotData.resID
    end
    local itemInfo = WardrobeLogicManager:ArrayHallDepotToCommonItem(depotData, nil, isWear, true, false, false)
    itemInfo.isRolewear = false
    return itemInfo
  end
end
function WardrobeSuit:OnCharacterSwitchPutonSuc(_, __, id)
  WardrobeSuit.__super.OnCharacterSwitchPutonSuc(self, _, _, id)
  self.LoopScrollGrid_Match:RefreshAllItems()
  self.cObj_clothMatchLoop = self.LoopScrollGrid_Match
end
function WardrobeSuit:OnShareSkinModRefresh(_, __, eWardrobeEditMode)
  WardrobeSuit.__super.OnShareSkinModRefresh(self, _, __, eWardrobeEditMode)
  print(bWriteLog and " WardrobeSuit:OnShareSkinModRefresh eWardrobeEditMode: " .. tostring(eWardrobeEditMode))
  self:RefreshSuitList()
  self:UpdateGoldenSuitButton()
  self:UpdateGoldChangeHeadPanel()
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_16, eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.None)
end
function WardrobeSuit:UpdateGoldenSuitButton()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local eWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode()
  self.UIRoot.CanvasPanel_4:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local period, itemID, InsID = LogicXSuit.GetPeriodOfCurrentlyWearing()
  local SimpleUI_Clothes = UIManager.GetUI(UIManager.UI_Config.Lobby_SimpleUI_Clothes_UIBP)
  local Subhall_Cloth_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Subhall_Cloth_UIBP)
  if SimpleUI_Clothes or Subhall_Cloth_UIBP then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_4, false)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_LevelSwitch, false)
    return
  end
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  local Source = WardrobeDataManager:GetItemSource(InsID)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if Source == self:GetDataSource() and period and eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.None then
    self.UIRoot.CanvasPanel_4:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.switchLevel = LogicXSuit.GetSwitchLevelByInsID(InsID)
    self.goldenSuitLevel = LogicXSuit.GetLevelByPeriod(period) or 0
    self.    self:SetSwitchLevel(self.switchLevel, self.goldenSuitLevel, period)
    self:UpdateChangeStateButton(itemID)
  end
end
function WardrobeSuit:InitTips()
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  local index = self.Common_Tab_SuitMode:GetSelectedIndex()
  if index == ENUM_TabId.ENUM_TabId_Suit then
    if self.curTipsItemData then
      tipsMgr:Show(tipsMgr.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, self.curTipsItemData.ins_id, self.curTipsItemData.res_id)
    else
      tipsMgr:Hide()
    end
  elseif index == ENUM_TabId.ENUM_TabId_Match then
    tipsMgr:Hide()
  end
end
function WardrobeSuit:UpdateChangeStateButton(itemID)
  log(bWriteLog and "WardrobeSuit:UpdateChangeStateButton itemID" .. tostring(itemID) .. " self.period " .. tostring(self.period) .. " self.switchLevel " .. tostring(self.switchLevel))
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, nil, itemID)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Golden, false)
  local show = LogicXSuit.IsMultiStateCloth(itemID)
  if not show then
    self.UIRoot.Button_ChangeState:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local xsuit_config_and_cache = require("client.slua.logic.XSuit.xsuit_config_and_cache")
  local multiCfg = xsuit_config_and_cache.GetMultiTypeUnlockConfigByPeriod(self.period)
  if not (multiCfg and multiCfg.unlock_level) or self.switchLevel < multiCfg.unlock_level then
    self.UIRoot.Button_ChangeState:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self.UIRoot.Button_ChangeState:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  local state = LogicXSuit.GetCurStateByItemID(itemID, self:GetDataSource())
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  local icon = multi_state_manager:GetWardrobeIcon(itemID, state)
  if icon then
    self:SetTexture(self.UIRoot.State_Image, icon)
  else
    self.UIRoot.Button_ChangeState:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local nextState = state == 1 and 2 or 1
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_11, not LogicXSuit.CheckUnlockState(self.period, nextState, self:GetDataSource()), false)
end
function WardrobeSuit:UpdateGoldChangeHeadPanel(ItemID)
  log(bWriteLog and "WardrobeSuit:UpdateGoldChangeHeadPanel.")
  local SimpleUI_Clothes = UIManager.GetUI(UIManager.UI_Config.Lobby_SimpleUI_Clothes_UIBP)
  local SubhallClothUIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Subhall_Cloth_UIBP)
  if SimpleUI_Clothes or SubhallClothUIBP then
    self:SetSwitchHeadPanelShow(false)
    return
  end
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if WardrobeLogicManager:GetWardrobeEditMode() ~= wardrobe_macro.EWardrobeEditMode.None then
    self:SetSwitchHeadPanelShow(false)
    return
  end
  ItemID = ItemID or self.curTipsItemData and self.curTipsItemData.res_id
  if not ItemID then
    local itemListTable = self.LoopScrollGrid_Normal:GetSetData()
    for _, itemData in pairs(itemListTable) do
      if itemData and type(itemData) == "table" and itemData.isUsing then
        ItemID = itemData.res_id
        break
      end
    end
  end
  if not ItemID then
    self:SetSwitchHeadPanelShow(false)
    return
  end
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  if not logic_suit_multi_shape:CanCurrentSuitChangeHead(ItemID) then
    self:SetSwitchHeadPanelShow(false)
    return
  end
  local HatItemID = logic_suit_multi_shape:GetResponseHatItemID(ItemID)
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  if HatItemID and HatItemID ~= 0 and not WardrobeDataManager:GetHallDepotItemDataByResID(HatItemID) then
    self:SetSwitchHeadPanelShow(false)
    return
  end
  self:SetSwitchHeadPanelShow(true)
  local GroupedHeadInfo = logic_suit_multi_shape:GetGroupedHeadInfoBySuitID(ItemID, false) or {}
  self.LoopScrollBox_SwitchHead:SetData(GroupedHeadInfo)
  local ShapeID = logic_suit_multi_shape:GetSelfSuitShapeID(ItemID)
  if next(GroupedHeadInfo) then
    if ShapeID then
      local index = 1
      for i, v in ipairs(GroupedHeadInfo) do
        local breakOuter = false
        if v.MatchItemIDList then
          for _, MatchItemID in pairs(v.MatchItemIDList) do
            if ShapeID == MatchItemID then
              index = i
              breakOuter = false
              break
            end
          end
        end
        if breakOuter then
          break
        end
      end
      self.LoopScrollBox_SwitchHead:Select(index)
    else
      self.LoopScrollBox_SwitchHead:Select(1)
    end
  end
  if ShapeID then
    local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
    local Avatar = TeamAvatarManager.GetMainAvatar()
    if Avatar then
      Avatar:HandleShapeInfo(ItemID, ShapeID)
    end
  end
end
function WardrobeSuit:OnClickItem(widget, index)
  WardrobeSuit.__super.OnClickItem(self, widget, index)
  self:DirectUnEnlarge()
  self:CheckChangeHeadNewGuideShow(index)
  self:SuitVoiceMuteTipsProcess(index)
end
function WardrobeSuit:CheckContainVoiceFeature(resId)
  local featuresItem = CDataTable.GetTableData("FeaturesItems", resId)
  local StringUtil = require("common.string_util")
  if not featuresItem then
    log(bWriteLog and "[lesterzy] WardrobeSuit:CheckContainVoiceFeature \230\156\170\232\131\189\231\148\177\231\137\169\229\147\129 res_id \230\137\190\229\136\176\229\175\185\229\186\148 featuresItem")
    return false
  end
  if not featuresItem.Features then
    log(bWriteLog and "[lesterzy] WardrobeSuit:CheckContainVoiceFeature \230\156\170\232\131\189\231\148\177\231\137\169\229\147\129 res_id \230\137\190\229\136\176\229\175\185\229\186\148 featuresItem.Features")
    return false
  end
  local features = StringUtil.Split(featuresItem.Features, ";")
  log(bWriteLog and string.format("[lesterzy] WardrobeSuit:CheckVoiceMuteTipsShow features %s", featuresItem.Features))
  for i = 1, #features do
    if features[i] == "1749" then
      return true
    end
  end
  return false
end
function WardrobeSuit:CheckNeverNoticeBefore(index)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWardrobeSuitVoiceMuteNotice)
  if not record then
    record = {}
  else
    for i = 1, #record do
      if record[i] == index then
        return false
      end
    end
  end
  table.insert(record, index)
  PlayerPrefsSystem.SaveTableToFile_N(record, PlayerPrefsSystem.ePlayerPrefsType.eWardrobeSuitVoiceMuteNotice)
  return true
end
function WardrobeSuit:SuitVoiceMuteTipsProcess(index)
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  if not itemData then
    log(bWriteLog and "WardrobeSuit:SuitVoiceMuteTipsProcess itemData is nil for index " .. tostring(index))
    return
  end
  local resId = itemData.res_id
  if not self:CheckContainVoiceFeature(resId) then
    return
  end
  if not self:CheckNeverNoticeBefore(resId) then
    return
  end
  ShowNotice(84011)
end
function WardrobeSuit:CheckChangeHeadNewGuideShow(index)
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  if itemData then
    local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
    logic_suit_multi_shape:IsShowChangeHeadNewGuide(itemData.res_id)
  end
end
function WardrobeSuit:ZoomToHead(_, __, bZoomIn)
  if bZoomIn then
    self:DirectEnlarge(ENUM_ITEM_SUBTYPE.Hat_Slot)
  else
    self:DirectUnEnlarge()
  end
end
function WardrobeSuit:SetSwitchHeadPanelShow(bShow)
  local index = self.Common_Tab_SuitMode:GetSelectedIndex()
  if index == ENUM_TabId.ENUM_TabId_Match then
    log(bWriteLog and string.format("WardrobeSuit:SetSwitchHeadPanelShow current tab is match tab, not show switch head panel."))
    bShow = false
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_SwitchHead, bShow, false)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ZOOM_VISIBILITY, bShow)
end
function WardrobeSuit:OnChangeSwitchSucc()
  local index = self.Common_Tab_SuitMode:GetSelectedIndex()
  if index == ENUM_TabId.ENUM_TabId_Match then
    self:InitSuitMatchList()
    return
  end
  self:UpdateGoldChangeHeadPanel()
end
function WardrobeSuit:OnGameGenderChange()
  self:UpdateGoldChangeHeadPanel()
end
local class = require("class")
local ui_subtab_avatar = require("client.slua.umg.Wardrobe.subtab_avatar")
local CWardrobeSuit = class(ui_subtab_avatar, nil, WardrobeSuit)
return CWardrobeSuit