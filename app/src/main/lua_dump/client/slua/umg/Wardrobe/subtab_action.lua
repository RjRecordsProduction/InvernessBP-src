local TipsManager = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
local Hidden = UEnums.ESlateVisibility.Hidden
local Collapsed = UEnums.ESlateVisibility.Collapsed
local SelfHitTestInvisible = UEnums.ESlateVisibility.SelfHitTestInvisible
local WardrobeAction = {}
function WardrobeAction:ctor(_, subTabConfig, args)
  self.itemList = {}
  self.ActionSlot = {}
  self.SelectActionIndex = 0
  self.ActionSlotsCardinality = 0
  self.end
function WardrobeAction:OnShow()
  WardrobeAction.__super.OnShow(self)
  self:InitActionList()
  self:InitActionSlot()
  if self.args and type(self.args) == "table" and self.args.TransientData and self.args.TransientData.ActionID ~= nil then
    local action = self.args.TransientData.ActionID
    self:AddTimerOnce(0.1, function()
      self:TrySelectAction(action)
    end)
  end
end
function WardrobeAction:OnInitialize()
  WardrobeAction.__super.OnInitialize(self)
  self.LoopScrollBox = self.LoopScrollGrid_Normal
  self.ActionSlotRoot = self.UIRoot.CavasExpression
  self.WidgetDragGuide = self.UIRoot.WidgetSwitcherMotionDrag
  self.LoopScrollBox:SetRefreshItemCallback(self.OnRefreshListItem, self)
  self.LoopScrollBox:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragReadyToShape", self.OnActionDragReadyToShape, self)
  self.LoopScrollBox:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragCanCeled", self.OnActionDragCanceled, self)
  self.LoopScrollGridActionSlot = self:InitScrollBox(self.UIRoot.LoopScrollGridActionSlot)
  self.LoopScrollGridActionSlot:SetRefreshItemCallback(self.OnRefreshActionSlotItem, self)
  self.LoopScrollGridActionSlot:AddItemWidgetChildEvent("CommonDragDropItem", "OnDragSuccess", self.OnActionSlotDrop, self)
  self.LoopScrollGridActionSlot:AddItemWidgetChildEvent("CommonDragDropItem", "OnDragReadyToShape", self.OnActionSlotDrag, self)
  self.LoopScrollGridActionSlot:AddItemWidgetChildEvent("CommonDragDropItem", "OnDragCanCeled", self.OnActionSlotRemove, self)
  self.LoopScrollGridActionSlot:AddItemWidgetChildEvent("CommonDragDropItem", "OnDragClicked", self.OnClickedActionSlotItem, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_BaseEmote, self.OnClickBaseEmoteButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ParticleEmote, self.OnClickParticleEmoteButton, self)
  self.UIRoot.UTRichTextBlock_0:SetText(LocUtil.GetLocalizeResStr(87092))
end
function WardrobeAction:RegistEvents()
  WardrobeAction.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST, self.OnActionEquipStateChange, self)
  self:AddCommonEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPGRADE, self.OnEmoteUpgrade, self)
end
function WardrobeAction:InitActionList()
  log(bWriteLog and "WardrobeGesture:InitGestureList")
  self.itemList = {}
  local itemInfo, isUsing
  local CurPage = self.subTabConfig.pageId
  local SubPage = self.subTabConfig.subTabId
  local depotItemList = self:GetArrayHallDepotItemInfo()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(depotItemList) do
    if WardrobeLogicManager:IsValidCurrentPageItem(CurPage, SubPage, v, serverTime) then
      isUsing = self:CheckActionIsUsing(v)
      itemInfo = WardrobeLogicManager:ArrayHallDepotToCommonItem(v, #self.itemList, isUsing, false, false, false, false)
      local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
      if LogicParticleEmote:HasUnlockParticle(itemInfo.res_id) then
        local ParticleEmoteID = LogicParticleEmote:GetParticleEmoteID(itemInfo.res_id)
        local ParticleEmoteCfg = CDataTable.GetTableData("Item", ParticleEmoteID)
        itemInfo.extra = {
          displayResId = ParticleEmoteID,
          displayQuality = ParticleEmoteCfg and ParticleEmoteCfg.ItemQuality or nil
        }
        itemInfo.HasUnlockParticle = true
        itemInfo.HasOpenParticle = DataMgr.show_effect
      end
      table.insert(self.itemList, itemInfo)
    end
  end
  self:SetInitItemList(self.itemList)
  if self.UIRoot.WidgetSwitcher_Search then
    self.itemList = self:DoSearch(self.itemList, WardrobeLogicManager:GetSearchString())
  end
  if self.bShowTagFilter then
    self.itemList = self:DoFilterTags(self.itemList)
  end
  self:SortElements()
  WardrobeAction.__super.UpdateItemList(self, self.itemList)
  self:HideParticleEmoteSwitchPanel()
end
function WardrobeAction:TrySelectAction(action)
  log(bWriteLog and "WardrobeAction:TrySelectAction action=" .. tostring(action))
  local itemListTable = self.LoopScrollGrid_Normal:GetSetData()
  if not itemListTable or not next(itemListTable) then
    return
  end
  for i, v in pairs(itemListTable) do
    self.LoopScrollGrid_Normal:ScrollToItem(i)
    if v.res_id == action then
      self:OnClickItem(nil, i)
      return
    end
  end
end
function WardrobeAction:ShowParticleEmoteSwitchPanel(EmoteID)
  log(bWriteLog and "[ParticleEmote] WardrobeAction ShowParticleEmoteSwitchPanel EmoteID" .. tostring(EmoteID))
  self.UIRoot.CanvasPanel_SE_Switch:SetWidgetVisibility(SelfHitTestInvisible)
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  if LogicParticleEmote:Is2LevelParticleEmote(EmoteID) then
    self:SwtichToParticleEmoteSwitcher()
  else
    self:SwtichToBaseEmoteSwitcher()
  end
  local BaseEmoteID = LogicParticleEmote:GetBaseID(EmoteID)
  if LogicParticleEmote:HasUnlockParticle(BaseEmoteID) then
    self.UIRoot.Image_Lock:SetWidgetVisibility(Collapsed)
    self:SetWidgetVisible(self.UIRoot.Image_Reddot, false, false)
  else
    self.UIRoot.Image_Lock:SetWidgetVisibility(SelfHitTestInvisible)
    self:SetWidgetVisible(self.UIRoot.Image_Reddot, LogicParticleEmote:HaveUnLockProp(EmoteID), false)
  end
end
function WardrobeAction:SwtichToBaseEmoteSwitcher()
  self.UIRoot.WidgetSwitcher_BaseEmote:SetActiveWidgetIndex(1)
  self.UIRoot.WidgetSwitcher_ParticleEmote:SetActiveWidgetIndex(0)
  self.UIRoot.Button_BaseEmote:SetIsEnabled(false)
  self.UIRoot.Button_ParticleEmote:SetIsEnabled(true)
  local Index = self.LoopScrollBox:GetSelectIndex()
  local actionData = self:GetAction(Index)
  TipsManager:Show(TipsManager.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, actionData.ins_id, actionData.res_id)
  self:CloseParticleTipsUI()
end
function WardrobeAction:SwtichToParticleEmoteSwitcher()
  self.UIRoot.WidgetSwitcher_BaseEmote:SetActiveWidgetIndex(0)
  self.UIRoot.WidgetSwitcher_ParticleEmote:SetActiveWidgetIndex(1)
  self.UIRoot.Button_BaseEmote:SetIsEnabled(true)
  self.UIRoot.Button_ParticleEmote:SetIsEnabled(false)
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  local Index = self.LoopScrollBox:GetSelectIndex()
  local actionData = self:GetAction(Index)
  local baseItem = actionData.res_id
  local upgradeItem = LogicParticleEmote:GetParticleEmoteID(baseItem)
  TipsManager:Show(TipsManager.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, actionData.ins_id, upgradeItem)
  local UIUtil = require("client.common.ui_util")
  local itemCfg = UIUtil.GetItemCfg(upgradeItem)
  self:CloseParticleTipsUI()
  if not LogicParticleEmote:HasUnlockParticle(baseItem) then
    local param = {
      buttonName = LocUtil.GetLocalizeResStr(48678),
      callback = function()
        LogicParticleEmote:ShowUnlockPropPanel(baseItem)
      end,
      title = itemCfg.itemName,
      content = itemCfg.ItemDesc,
      attachWidget = self.UIRoot.Button_ParticleEmote,
      offset = FVector2D(0, 0)
    }
    self.particleTipsUI = UIManager.ShowUI(UIManager.UI_Config.Common_VerticalTips_UIBP, param)
  end
end
function WardrobeAction:CloseParticleTipsUI()
  if self.particleTipsUI then
    self.particleTipsUI:CloseSelf()
    self.particleTipsUI = nil
  end
end
function WardrobeAction:HideParticleEmoteSwitchPanel()
  self.UIRoot.CanvasPanel_SE_Switch:SetWidgetVisibility(Collapsed)
  self:CloseParticleTipsUI()
end
function WardrobeAction:OnClickBaseEmoteButton()
  self:PlayAudio(sound_config.click_v1)
  local Index = self.LoopScrollBox:GetSelectIndex()
  local actionData = self:GetAction(Index)
  if not actionData then
    log_error("[ParticleEmote] WardrobeAction OnClickBaseEmoteButton Index:" .. tostring(Index))
    return
  end
  self:SwtichToBaseEmoteSwitcher()
  log(bWriteLog and "[ParticleEmote] WardrobeAction OnClickParticleEmoteButton actionData.res_id" .. tostring(actionData.res_id))
  WardrobeLogicManager:PlayMotion(actionData.res_id)
end
function WardrobeAction:OnClickParticleEmoteButton()
  self:PlayAudio(sound_config.click_v1)
  local Index = self.LoopScrollBox:GetSelectIndex()
  local actionData = self:GetAction(Index)
  if not actionData then
    log_error("[ParticleEmote] WardrobeAction OnClickParticleEmoteButton Index:" .. tostring(Index))
    return
  end
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  local ParticleEmoteID = LogicParticleEmote:GetParticleEmoteID(actionData.res_id)
  log(bWriteLog and "[ParticleEmote] WardrobeAction OnClickParticleEmoteButton ParticleEmoteID" .. tostring(ParticleEmoteID))
  self:SwtichToParticleEmoteSwitcher()
  WardrobeLogicManager:PlayMotion(ParticleEmoteID)
end
function WardrobeAction:OnEmoteUpgrade(_, _, EmoteID)
  local Index = self.LoopScrollBox:GetSelectIndex()
  local actionData = self:GetAction(Index)
  if not actionData or actionData.res_id ~= EmoteID then
    log(bWriteLog and "[ParticleEmote] OnEmoteUpgrade actionData is nil Index:" .. tostring(Index))
    self:HideParticleEmoteSwitchPanel()
    TipsManager:Hide()
    return
  end
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  local ItemID = actionData.res_id
  log(bWriteLog and "[ParticleEmote] OnEmoteUpgrade ShowTips ID " .. tostring(ItemID))
  local ParticleEmoteID = LogicParticleEmote:GetParticleEmoteID(ItemID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local ParticleEmoteCfg = CDataTable.GetTableData("Item", ParticleEmoteID)
  actionData.extra = {
    displayResId = ParticleEmoteID,
    displayQuality = ParticleEmoteCfg and ParticleEmoteCfg.ItemQuality or nil
  }
  actionData.HasUnlockParticle = true
  actionData.HasOpenParticle = DataMgr.show_effect
  self.LoopScrollBox:RefreshItem(Index, actionData)
  TipsManager:Show(TipsManager.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, actionData.ins_id, ParticleEmoteID)
  self:ShowParticleEmoteSwitchPanel(ParticleEmoteID)
  WardrobeLogicManager:PlayMotion(ParticleEmoteID)
end
function WardrobeAction:InitActionSlot()
  self:RefreshActionSlot()
  local ActionSlotDisplayList = {}
  for _, action in ipairs(self.ActionSlot) do
    table.insert(ActionSlotDisplayList, action)
  end
  for _ = 1, self.ActionSlotsCardinality - #self.ActionSlot do
    table.insert(ActionSlotDisplayList, {})
  end
  self.LoopScrollGridActionSlot:SetData(ActionSlotDisplayList)
end
function WardrobeAction:RefreshActionSlot()
  self.ActionSlot = {}
  self.ActionSlotsCardinality = DataMgr.MotionSlotMax
  local motionItems = DataMgr.GetMotionItemDatas()
  for _, v in ipairs(motionItems) do
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    if LogicXSuit.IsBattleEmotion(v.resID) then
      table.insert(self.ActionSlot, {})
    else
      table.insert(self.ActionSlot, v)
    end
  end
end
function WardrobeAction:OnActionEquipStateChange()
  self:InitActionList()
  self:InitActionSlot()
end
function WardrobeAction:OnWardrobeDataChange(eventType, eventID, changelist)
  if not changelist then
    log(bWriteLog and "WardrobeAction OnWardrobeDataChange changelist is nil")
    return
  end
  local HasEmote = false
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  for _, info in pairs(changelist) do
    local itemCfg = CDataTable.GetTableData("Item", info.res_id)
    if itemCfg and ModelDisplayTypeHelper.IsEmotion(itemCfg.ItemType) then
      HasEmote = true
      break
    end
  end
  if HasEmote then
    self:InitActionList()
  end
end
function WardrobeAction:OnSearchChange()
  self:InitActionList()
end
function WardrobeAction:OnClickItem(widget, index)
  WardrobeAction.__super.OnClickItem(self, widget, index)
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  local actionData = self:GetAction(index)
  if not actionData then
    log_error("[ParticleEmote] WardrobeAction OnClickItem Index:" .. tostring(index))
    return
  end
  local EmoteID = actionData.res_id
  local CanPlay
  local TipsID = actionData.res_id
  TipsManager:Show(TipsManager.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, actionData.ins_id, TipsID)
  EmoteID, CanPlay = LogicParticleEmote:GetNeedPlayEmoteID(actionData.res_id)
  if CanPlay then
    local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
    local wordId = golden_suit_module:EmoteNeedClothesWithWord(EmoteID)
    if wordId then
      ShowNotice(wordId)
      return
    end
    local wordId = golden_suit_module:EmoteNeedClothesAllWithWord(EmoteID)
    if wordId then
      ShowNotice(wordId)
      return
    end
    WardrobeLogicManager:PlayMotion(EmoteID)
  else
    ShowNotice(44712)
  end
  if LogicParticleEmote:IsParticleEmote(actionData.res_id) then
    self:ShowParticleEmoteSwitchPanel(EmoteID)
  else
    self:HideParticleEmoteSwitchPanel()
  end
end
function WardrobeAction:OnClickedActionSlotItem(widget, index)
  local actionData = self:GetActionSlot(index)
  self:PlayAudio(sound_config.click_v1)
  if actionData and next(actionData) ~= nil then
    local CoopEmoteUtil = require("GameLua.Activity.Commercialize.GamePlay.CoopEmote.CoopEmoteUtil")
    if not CoopEmoteUtil.CanShowInLobby(actionData.resID) then
      ShowNotice(44712)
      return
    end
    local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
    local EmoteID, CanPlay = LogicParticleEmote:GetNeedPlayEmoteID(actionData.resID)
    WardrobeLogicManager:PlayMotion(EmoteID)
  end
end
function WardrobeAction:OnRefreshListItem(widget, index)
  WardrobeAction.__super.OnRefreshListItem(self, widget, index)
  local actionData = self:GetAction(index)
  local DragDropItem = widget.Common_DragDrop_Item
  widget:SetIsUnlockParticleEmote(actionData.HasUnlockParticle)
  widget:SetIsOpenParticleEmote(actionData.HasOpenParticle)
  DragDropItem:SetEnable(true)
  DragDropItem:SetDragEnable(true)
  DragDropItem:RegisterDrag(1, 0, 0, actionData.ins_id)
end
function WardrobeAction:OnRefreshActionSlotItem(widget, index)
  local actionData = self:GetActionSlot(index)
  local DragDropItem = widget.CommonDragDropItem
  local isPutOnAction = index <= #self.ActionSlot
  if isPutOnAction and actionData and actionData.insID then
    DragDropItem:SetDragEnable(true)
    DragDropItem:RegisterDrag(1, 0, 0, actionData.insID)
  else
    DragDropItem:SetDragEnable(false)
    DragDropItem:RegisterDrag(1, 0, 0, "")
  end
  DragDropItem:SetEnable(true)
  DragDropItem:RegisterDrop(1)
  self:InitSlotItemView(widget, index, actionData, isPutOnAction)
end
function WardrobeAction:InitSlotItemView(widget, index, actionData, isPutOnAction)
  widget.TextBlock_Index:SetWidgetVisibility(SelfHitTestInvisible)
  widget.TextBlock_Index:SetText(tostring(index))
  widget.ActionIcon:SetWidgetVisibility(Collapsed)
  widget.Icon_Color:SetWidgetVisibility(Collapsed)
  local icon = widget.Icon_Color
  local empty = widget.IsEmpty
  if isPutOnAction and actionData and next(actionData) ~= nil then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemCfg = CDataTable.GetTableData("Item", actionData.resID)
    local wheelRotateAngel = (index - 1) * 30
    if itemCfg then
      local UIUtil = require("client.common.ui_util")
      local smallIcon, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(actionData.resID, icon)
      self:SetTexture(icon, smallIcon, {bHasAddKnownMissing = bHasAddKnownMissing})
      empty:SetWidgetVisibility(Collapsed)
      icon:SetWidgetVisibility(SelfHitTestInvisible)
    end
  else
    local wheelRotateAngel = (index - 1) * 30
    icon:SetWidgetVisibility(Collapsed)
    empty:SetWidgetVisibility(SelfHitTestInvisible)
  end
end
function WardrobeAction:InitDragWidget(widget, actionData)
  local icon = widget.Image_Icon
  local actionResID = actionData.resID or actionData.res_id
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemCfg = CDataTable.GetTableData("Item", actionResID)
  if itemCfg then
    self:SetTexture(icon, itemCfg.ItemSmallIcon)
    icon:SetWidgetVisibility(SelfHitTestInvisible)
  end
end
function WardrobeAction:OnActionDragReadyToShape(DragWidget, Index, GeneratedWidget, DragDropData)
  local actionData = self:GetAction(Index)
  self:InitDragWidget(GeneratedWidget, actionData)
  self:BeginActionDragHint(1)
end
function WardrobeAction:OnActionDragCanceled()
  self:EndActionDragHint()
end
function WardrobeAction:OnActionSlotDrag(DragWidget, Index, GeneratedWidget, DragDropData)
  local actionData = self:GetActionSlot(Index)
  self:InitDragWidget(GeneratedWidget, actionData)
  self:BeginActionDragHint(0)
end
function WardrobeAction:OnActionSlotDrop(DragWidget, Index, DragDropData)
  local dragActionInsID = tonumber(DragDropData.dragExtendData)
  local actionData = WardrobeDataManager:GetHallDepotItemDataByInsID(dragActionInsID)
  self:EquipAction(dragActionInsID, Index, actionData)
  self:EndActionDragHint()
  self:PlayAudio(sound_config.click_v1)
end
function WardrobeAction:OnActionSlotRemove(DragWidget, Index, DragDropData)
  local actionSlot = Index
  local dragActionInsID = tonumber(DragDropData.dragExtendData)
  self:RemoveActionFromSlot(dragActionInsID, actionSlot)
  self:EndActionDragHint()
  self:PlayAudio(sound_config.click_v1)
end
function WardrobeAction:BeginActionDragHint(selection)
  local widgetSwitcherDrag = self.UIRoot.WidgetSwitcher_ActionDrag
  widgetSwitcherDrag:SetWidgetVisibility(SelfHitTestInvisible)
  widgetSwitcherDrag:SetActiveWidgetIndex(selection)
end
function WardrobeAction:EndActionDragHint()
  local widgetSwitcherDrag = self.UIRoot.WidgetSwitcher_ActionDrag
  widgetSwitcherDrag:SetWidgetVisibility(Hidden)
end
function WardrobeAction:OnRemoveEquipAction()
  self:InitActionSlot()
end
function WardrobeAction:SetAction(actionList)
  self.LoopScrollBox:SetData(actionList)
end
function WardrobeAction:GetAction(index)
  return self.LoopScrollBox:GetItemData(index)
end
function WardrobeAction:SetActionSlot(actionList)
  self.LoopScrollGridActionSlot._data = actionList
  self.LoopScrollGridActionSlot._selectIndex = 0
  self.LoopScrollGridActionSlot.UIRoot:SetItemCount(#actionList)
end
function WardrobeAction:GetActionSlot(index)
  return self.LoopScrollGridActionSlot:GetItemData(index)
end
function WardrobeAction:GetActionInsID(index)
  return self.WardrobeAction[index]
end
function WardrobeAction:GetActionDataByInsID(insID)
  for _, v in self.itemList, nil, nil do
    if v.insID == insID then
      return v
    end
  end
end
function WardrobeAction:EquipAction(actionInsID, droppedSlot, actionData)
  local TimeUtil = require("client.common.time_util")
  if not WardrobeLogicManager:IsValidTime(TimeUtil.GetServerTimeInSec(), actionData and actionData.expireTS) then
    log(bWriteLog and "EquipEmoj time is not valid")
    self:InitActionList()
    return
  end
  WardrobeLogicManager:EquipMotion(actionInsID, droppedSlot)
end
function WardrobeAction:RemoveActionFromSlot(dragActionInsID, droppedSlot)
  WardrobeLogicManager:unequip_motion_req(dragActionInsID, droppedSlot)
end
function WardrobeAction:CheckNeedRefreshActionSlot()
  if #self.ActionSlot ~= #DataMgr.MotionSlotList then
    DataMgr.sync_motion_info_req(false)
  end
end
function WardrobeAction:CheckActionIsUsing(actionData)
  local motionItems = DataMgr.GetMotionItemDatas()
  for _, v in ipairs(motionItems) do
    if v.resID == actionData.resID and v.insID == actionData.insID then
      return true
    end
  end
  return false
end
function WardrobeAction:SortElements()
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local SortPreference = logic_wardrobe:GetSortPreference(self.subTabConfig)
  logic_wardrobe:SortItemTable(self.itemList, SortPreference, true)
  for i, v in pairs(self.itemList) do
    v.index = i - 1
  end
end
function WardrobeAction:ReSortItem()
  self:SortElements()
  self:UpdateItemListBySort(self.itemList)
end
function WardrobeAction:OnClose()
  WardrobeAction.__super.OnClose(self)
  self:HideParticleEmoteSwitchPanel()
end
local class = require("class")
local normal_item_list = require("client.slua.umg.Wardrobe.subtab_item_list_base")
local Action = class(normal_item_list, nil, WardrobeAction)
return Action