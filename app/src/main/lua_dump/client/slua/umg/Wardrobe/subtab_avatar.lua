local WardrobeAvatar = {}
local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
function WardrobeAvatar:ctor()
  self.itemListTable = {}
  self.init = false
  self.sharedItemCount = 0
  self.curTipsItemData = nil
end
function WardrobeAvatar:OnInitialize()
  log(bWriteLog and "WardrobeAvatar:OnInitialize")
  WardrobeAvatar.__super.OnInitialize(self)
  local wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  wardrobe_avatar:InitCurrentWearPreviewMap()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local type = WardrobeLogicManager:LazySortType()
  log(bWriteLog and "WardrobeAvatar:OnInitialize type = " .. tostring(type))
  if type == 1 then
    local LoopScrollUI = self.UIRoot.LoopScrollGrid_Avatar
    if self.loopScrollGrid ~= nil then
      LoopScrollUI = self.loopScrollGrid
    end
    if self.LoopScrollGrid_Normal then
      self.LoopScrollGrid_Normal:Close()
    end
    self.LoopScrollGrid_Normal = self:InitLazySortScrollBox(LoopScrollUI, {
      GetCmpFunc = function()
        local SortPreference = WardrobeLogicManager:GetSortPreference(self.subTabConfig)
        return WardrobeLogicManager:GetSortCmpFunction(SortPreference)
      end
    })
    self.LoopScrollGrid_Normal:SetRefreshItemCallback(self.OnRefreshListItem, self)
  elseif type == 2 then
    local LoopScrollUI = self.UIRoot.LoopScrollGrid_Avatar
    if self.loopScrollGrid ~= nil then
      LoopScrollUI = self.loopScrollGrid
    end
    if self.LoopScrollGrid_Normal then
      self.LoopScrollGrid_Normal:Close()
    end
    self.LoopScrollGrid_Normal = self:InitLazySortScrollBox(LoopScrollUI, {
      GetCmpFunc = function()
        local SortPreference = WardrobeLogicManager:GetSortPreference(self.subTabConfig)
        return WardrobeLogicManager:GetSortCmpFunction(SortPreference)
      end
    })
    self.LoopScrollGrid_Normal:SetRefreshItemCallback(self.OnRefreshListItem, self)
    local config = {
      GetOriginDataSetFunc = function()
        return self:GetArrayHallDepotItemInfo()
      end,
      GetFilterFunc = function()
        return self:GetFilterFunc()
      end,
      GetConvertFunc = function()
        return self:GetConvertFunc()
      end,
      GetCmpFunc = function()
        local wearInsMap = {}
        local wearInfoMap = logic_wardrobe_avatar:GetCurrentWearPreviewMap()
        for _, v in pairs(wearInfoMap) do
          wearInsMap[v.insID] = true
        end
        return WardrobeLogicManager:GetSortFuncForLazyInit(wearInsMap, self.subTabConfig)
      end
    }
    self.LoopScrollGrid_Normal = self:InitLazyInitScrollBox(LoopScrollUI, config)
    self.LoopScrollGrid_Normal:SetRefreshItemCallback(self.OnRefreshListItem, self)
  end
  self.LoopScrollGridAvatarSlot = self:InitScrollBox(self.UIRoot.LoopScrollGridAvatarSlot)
  self.LoopScrollGridAvatarSlot:SetRefreshItemCallback(self.OnRefreshAvatarSlotItem, self)
  self.LoopScrollGridAvatarSlot:AddItemWidgetChildEvent("CommonDragDropItem", "OnDragSuccess", self.OnAvatarSlotDrop, self)
  self.LoopScrollGridAvatarSlot:AddItemWidgetChildEvent("CommonDragDropItem", "OnDragReadyToShape", self.OnAvatarSlotDrag, self)
  self.LoopScrollGridAvatarSlot:AddItemWidgetChildEvent("CommonDragDropItem", "OnDragCanCeled", self.OnAvatarSlotRemove, self)
  self.LoopScrollGrid_Normal:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragReadyToShape", self.OnAvatarDragReadyToShape, self)
  self.LoopScrollGrid_Normal:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragCanCeled", self.OnAvatarDragCanceled, self)
end
function WardrobeAvatar:RegistEvents()
  WardrobeAvatar.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_AVATAR_LIST, self.OnUpdateAvatarList, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SWITCH_USE_ROLEWEAR, self.OnFashionBagChange, self)
  self:AddCommonEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_SWITCH_PUTON_SUC, self.OnCharacterSwitchPutonSuc, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHARE_SKIN_MODE_REFRESH, self.OnShareSkinModRefresh, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHARE_BAG_LIST_UPDATE, self.OnShareBagListUpdate, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_SIMPLEUI_CLOTHES_ITEM_DRAG_SUCCESS_RTOL, self.SimpleUISelect, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_SIMPLEUI_CLOTHES_ITEM_DRAG_SUCCESS_LTOR, self.SimpleUIRemove, self)
end
function WardrobeAvatar:OnShow()
  WardrobeAvatar.__super.OnShow(self)
  self:UpdateAvatarList()
  self:RefreshShareAvatarSlot()
end
function WardrobeAvatar:Close()
  if self.TimerToUpdateHandle then
    self:RemoveTimer(self.TimerToUpdateHandle)
    self.TimerToUpdateHandle = nil
  end
  WardrobeAvatar.__super.Close(self)
end
function WardrobeAvatar:OnFashionBagChange(_, __, CurrentIndex)
  WardrobeAvatar.__super.OnFashionBagChange(self, _, __, CurrentIndex)
  self:UpdateAvatarList()
end
function WardrobeAvatar:OnCharacterSwitchPutonSuc(eventType, eventID)
  logic_wardrobe_avatar:InitCurrentWearPreviewMap(true)
  self:UpdateAvatarList()
  self.LoopScrollGrid_Normal:Deselect()
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  tipsMgr:Hide()
end
function WardrobeAvatar:OnUpdateAvatarList(eventType, eventID)
  self:UpdateAvatarList()
end
function WardrobeAvatar:OnWardrobeDataChange(eventType, eventID, changelist)
  if changelist then
    local show = false
    for _, v in pairs(changelist) do
      if not v.res_id then
        show = true
        break
      end
      local itemCfg = CDataTable.GetTableData("Item", v.res_id)
      if not itemCfg then
        show = true
        break
      end
      local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
      if not ModelDisplayTypeHelper.IsWeapon(itemCfg.ItemType) then
        show = true
        break
      end
    end
    if not show then
      log(bWriteLog and "WardrobeAvatar:OnWardrobeDataChange only weapon")
      return
    end
  end
  self:UpdateAvatarList()
end
function WardrobeAvatar:UpdateAvatarList()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local type = WardrobeLogicManager:LazySortType()
  log(bWriteLog and "WardrobeAvatar:UpdateAvatarList type = " .. tostring(type))
  if type == 2 then
    if not self._LoadSaveOperation then
      local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      logic_wardrobe:TryLoadSaveOperation()
      self._LoadSaveOperation = true
    end
    self.LoopScrollGrid_Normal:SetData()
    self.LoopScrollGrid_Normal:Deselect()
    local count = self.LoopScrollGrid_Normal:GetItemCount()
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_NoItem, count == 0)
    self:AddTimerOnce(0, function()
      self:UpdateInitItemList()
    end)
  else
    self.itemListTable = self:InitHaveItemList()
    self:SetInitItemList(self.itemListTable)
    if self.UIRoot.WidgetSwitcher_Search then
      self.itemListTable = self:DoSearch(self.itemListTable, WardrobeLogicManager:GetSearchString())
    end
    if self.bShowTagFilter then
      self.itemListTable = self:DoFilterTags(self.itemListTable)
    end
    self.itemListTable = self:FilterMultiItem(self.itemListTable)
    if self.TimerToUpdateHandle then
      self:RemoveTimer(self.TimerToUpdateHandle)
      self.TimerToUpdateHandle = nil
    end
    self:SortItem(self.itemListTable)
    local cObj_parent = WardrobeAvatar.__super
    cObj_parent.UpdateItemList(self, self.itemListTable)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_NoItem, #self.itemListTable == 0)
    local curItemData
    for k, v in pairs(self.itemListTable) do
      if v.isUsing then
        curItemData = v
      end
    end
    local usingResID
    if curItemData then
      usingResID = self:GetCurItemID(curItemData)
    end
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, usingResID)
  end
  self:UpdateAvatarSlotList()
  self:RefreshMultiLevelCanvas()
end
function WardrobeAvatar:InitHaveItemList()
  local itemListTable = {}
  local isWear = false
  local wearInfo
  self.init = true
  self.curTipsItemData = nil
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local CurrentShareType = WardrobeLogicManager:GetShareType()
  local eWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode()
  local wardrobe_fashion_utils = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local arrayHallDepotItemInfo = self:GetArrayHallDepotItemInfo()
  for _, v in pairs(arrayHallDepotItemInfo) do
    local itemCfg = CDataTable.GetTableData("Item", v.resID)
    if itemCfg and WardrobeLogicManager:IsValidCurrentPageItem(self.subTabConfig.pageId, self.subTabConfig.subTabId, v, serverTime) then
      isWear = false
      wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(v.itemSubType)
      if wearInfo ~= nil then
        if logic_wardrobe_avatar:IsItemSubType_Bag_Helmet_Armor(v.itemSubType) then
          isWear = wearInfo.insID == v.insID
        else
          isWear = wearInfo.insID == v.insID and wearInfo.resID == v.resID
        end
      end
      local itemInfo = WardrobeLogicManager:ArrayHallDepotToCommonItem(v, nil, isWear, true, false, false)
      itemInfo.isRolewear = false
      local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
      if eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.None or eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Intimacy and wardrobe_fashion_utils.CanBeSharedByItem(v) or eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag and wardrobe_fashion_utils.CanBeSharedInShareBag(v, CurrentShareType) or eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.FashionBag or eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Inherit then
        table.insert(itemListTable, itemInfo)
      end
    end
  end
  log(bWriteLog and "god test itemListTable " .. #itemListTable)
  log_tree("  WardrobeAvatar:InitHaveItemList. itemListTable ", itemListTable)
  local tempData = {}
  for _, info in pairs(itemListTable) do
    if info.lock_cnt and info.lock_cnt > 0 then
      if info.count == 0 then
        info.count = info.lock_cnt
      else
        local tFreezeData = DeepCopy(info)
        tFreezeData.count = info.lock_cnt
        info.lock_cnt = 0
        tempData[#tempData + 1] = tFreezeData
      end
    end
  end
  local TableUtil = require("common.table_util")
  TableUtil.TableConcat(itemListTable, tempData)
  return itemListTable
end
function WardrobeAvatar:OnClickItem(widget, index)
  WardrobeAvatar.__super.OnClickItem(self, widget, index)
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  if itemData and itemData.lock_cnt and itemData.lock_cnt > 0 then
    ShowNotice(3000016)
    return
  end
  if itemData then
    if not DataMgr.IsValidTime(itemData.expireTS) then
      ShowNotice(9910101)
      return
    end
    self:ShowBottomRightTips(itemData.ins_id, itemData.res_id)
    self.curTipsItemData = itemData
    local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    if logic_wardrobe:IsItemIsolated(itemData.res_id) then
      ShowNotice(4987)
      return
    end
    if not logic_wardrobe:IsCharacterUse(itemData.res_id) then
      ShowNotice(7475)
      return
    end
    local SimpleUI_Clothes = UIManager.GetUI(UIManager.UI_Config.Lobby_SimpleUI_Clothes_UIBP)
    local SubhallClothUIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Subhall_Cloth_UIBP)
    if SimpleUI_Clothes then
      SimpleUI_Clothes:ClickAvatarItem(itemData)
    elseif SubhallClothUIBP then
      SubhallClothUIBP:ClickAvatarItem(itemData)
      EventSystem:postEvent(EVENTTYPE_SUBHALL, EVENTID_SUBHALL_CLOTH_AVATAR_CLICKED_UPDATE_ITEM, itemData.ins_id)
    else
      self:ClickAvatarItem(itemData)
    end
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_SIMPLEUI_CLOTHES_AVATAR_CLICKED_UPDATA_ITEM, itemData.ins_id)
  end
end
function WardrobeAvatar:ClickAvatarItem(itemData)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bInFashionBagEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
  local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
  if not bInFashionBagEditMode then
    if GameStatus.IsInMainCity() then
      WardrobeLogicManager.ReportTLog(WardrobeLogicManager.ReportTLogEnum.Wardrobe, itemData)
    end
    local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
    if LogicFusionModule:IsFusionItem(itemData.res_id) then
      local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(itemData.itemSubType)
      local isWear = wearInfo and wearInfo.insID == itemData.ins_id
      if isWear then
        if itemData.isUsing then
          log(bWriteLog and "WardrobeAvatar:OnClickItem PutDown ins_id:" .. itemData.ins_id)
          WardrobeLogicManager:wardrobe_put_down_data_req(itemData)
        else
          LogicFusionModule:TryUpdateFusionRecord(itemData.originItem, itemData.res_id)
        end
      else
        LogicFusionModule:TryUpdateFusionRecord(itemData.originItem, itemData.res_id)
        log(bWriteLog and "WardrobeAvatar:OnClickItem PutOn ins_id:" .. itemData.ins_id)
        WardrobeLogicManager:wardrobe_puton_data_req(itemData)
      end
      return
    end
    if itemData.isUsing then
      log(bWriteLog and "WardrobeAvatar:OnClickItem PutDown ins_id:" .. itemData.ins_id)
      WardrobeLogicManager:wardrobe_put_down_data_req(itemData)
    elseif not WardrobeLogicManager:IsCharacterUse(itemData.res_id) then
      ShowNotice(7475)
    else
      log(bWriteLog and "WardrobeAvatar:OnClickItem PutOn ins_id:" .. itemData.ins_id)
      WardrobeLogicManager:wardrobe_puton_data_req(itemData)
    end
  else
    local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
    local bFusion = LogicFusionModule and LogicFusionModule:IsFusionItem(itemData.res_id) and itemData.originItem
    if FashionBagEditUtils:IsItemInTryMap(itemData.res_id, false, itemData) then
      if bFusion then
        local config = LogicFusionModule:GetFusionConfig(itemData.res_id)
        if config then
          local fusionRecord = LogicFusionModule:GetFusionRecord(config.period)
          if fusionRecord and itemData.originItem ~= fusionRecord.pre_item_id then
            log(bWriteLog and "WardrobeAvatar:OnClickItem fashion bag edit mode switch fusion form originItem:" .. tostring(itemData.originItem) .. " res_id:" .. tostring(itemData.res_id))
            LogicFusionModule:TryUpdateFusionRecord(itemData.originItem, itemData.res_id)
            return
          end
        end
      end
      log(bWriteLog and "WardrobeAvatar:OnClickItem fashion bag edit mode putoff ins_id:" .. itemData.ins_id)
      FashionBagEditUtils:PutOffFashionBagItem(itemData)
    elseif not WardrobeLogicManager:IsCharacterUse(itemData.res_id) then
      ShowNotice(7475)
    else
      log(bWriteLog and "WardrobeAvatar:OnClickItem fashion bag edit mode puton ins_id:" .. itemData.ins_id)
      FashionBagEditUtils:PutOnFashionBagItem(itemData)
      if bFusion and LogicFusionModule:IsFusionTargetItem(itemData.res_id) then
        LogicFusionModule:TryUpdateFusionRecord(itemData.originItem, itemData.res_id)
      end
    end
  end
end
function WardrobeAvatar:SortItem(itemListTable)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if WardrobeLogicManager:LazySortType() ~= 0 then
    log(bWriteLog and "WardrobeAvatar:SortItem do nothing")
    return
  end
  log(bWriteLog and "god test itemListTable " .. #itemListTable)
  local SortPreference = WardrobeLogicManager:GetSortPreference(self.subTabConfig)
  WardrobeLogicManager:SortItemTable(itemListTable, SortPreference)
  for i, v in ipairs(itemListTable) do
    v.index = i - 1
  end
end
function WardrobeAvatar:ReSortItem()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if WardrobeLogicManager:LazySortType() > 0 then
    log(bWriteLog and "WardrobeAvatar:SortItem do not resort")
    local itemListTable = self.LoopScrollGrid_Normal:GetSetData()
    self.LoopScrollGrid_Normal:SetData(itemListTable)
    return
  end
  local SortPreference = WardrobeLogicManager:GetSortPreference(self.subTabConfig)
  local itemListTable = self.LoopScrollGrid_Normal:GetSetData()
  WardrobeLogicManager:SortItemTable(itemListTable, SortPreference)
  for i, v in ipairs(itemListTable) do
    v.index = i - 1
  end
  if self.TimerToUpdateHandle then
    self:RemoveTimer(self.TimerToUpdateHandle)
    self.TimerToUpdateHandle = nil
  end
  self.TimerToUpdateHandle = self:AddTimerOnce(0, function()
    self:UpdateItemListBySort(itemListTable)
  end)
end
function WardrobeAvatar:UpdateInitItemList()
  local ItemList = {}
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local CurrentShareType = WardrobeLogicManager:GetShareType()
  local eWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode()
  local wardrobe_fashion_utils = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local arrayHallDepotItemInfo = self:GetArrayHallDepotItemInfo()
  for _, v in pairs(arrayHallDepotItemInfo) do
    local itemCfg = CDataTable.GetTableData("Item", v.resID)
    if itemCfg and WardrobeLogicManager:IsValidCurrentPageItem(self.subTabConfig.pageId, self.subTabConfig.subTabId, v, serverTime) then
      local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
      if eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.None or eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Intimacy and wardrobe_fashion_utils.CanBeSharedByItem(v) or eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag and wardrobe_fashion_utils.CanBeSharedInShareBag(v, CurrentShareType) or eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.FashionBag or eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Inherit then
        table.insert(ItemList, v)
      end
    end
  end
  self:SetInitItemList(ItemList)
end
local CONST_SUBSCRIBE_SHARE_ITEM_COUNT = 10
function WardrobeAvatar:UpdateAvatarSlotList()
  log(bWriteLog and "[debug] WardrobeAvatar:UpdateAvatarSlotList")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local bShowSubscribeShare = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.ShareBag
  if not bShowSubscribeShare then
    return
  end
  local subscribeShareItemList = WardrobeLogicManager:GetShareBagItemList()
  self.shareItemList = {}
  local shareItemList = self.shareItemList
  if subscribeShareItemList then
    for _, v in pairs(subscribeShareItemList) do
      if v then
        table.insert(shareItemList, v)
      end
    end
    self.sharedItemCount = #shareItemList
    for i = #shareItemList + 1, CONST_SUBSCRIBE_SHARE_ITEM_COUNT do
      table.insert(shareItemList, 0)
    end
  else
    self.sharedItemCount = 0
    for i = 1, CONST_SUBSCRIBE_SHARE_ITEM_COUNT do
      table.insert(shareItemList, 0)
    end
  end
  self.LoopScrollGridAvatarSlot:SetData(shareItemList)
  if self.UIRoot.TextBlock_ShareCount then
    self.UIRoot.TextBlock_ShareCount:SetText(LocUtil.LocalizeResFormat(49062, self.sharedItemCount, CONST_SUBSCRIBE_SHARE_ITEM_COUNT))
  end
end
function WardrobeAvatar:OnShareSkinModRefresh(_, _, eWardrobeEditMode)
  print(bWriteLog and "WardrobeAvatar:OnShareSkinModRefresh eWardrobeEditMode: " .. tostring(eWardrobeEditMode))
  self:UpdateAvatarList()
  if self.UIRoot.CanvasPanel_AvatarSlot then
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    local bShowSubscribeShare = eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_AvatarSlot, bShowSubscribeShare)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_SharePackageTips, bShowSubscribeShare)
    if bShowSubscribeShare then
      self:UpdateAvatarSlotList()
    end
  end
end
local Hidden = UEnums.ESlateVisibility.Hidden
local Collapsed = UEnums.ESlateVisibility.Collapsed
local SelfHitTestInvisible = UEnums.ESlateVisibility.SelfHitTestInvisible
function WardrobeAvatar:InitDragWidget(widget, itemId)
  if not itemId then
    return
  end
  local icon = widget.Image_Icon
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  if itemCfg then
    self:SetTexture(icon, itemCfg.ItemSmallIcon)
    self:SetWidgetVisible(icon, true, false)
  end
end
function WardrobeAvatar:GetItemData(index)
  return self.LoopScrollGrid_Normal:GetItemData(index)
end
function WardrobeAvatar:GetAvatarSlotData(index)
  return self.LoopScrollGridAvatarSlot:GetItemData(index)
end
function WardrobeAvatar:OnAvatarDragReadyToShape(DragWidget, Index, GeneratedWidget, DragDropData)
  log(bWriteLog and "WardrobeAvatar:OnAvatarDragReadyToShape")
  local itemData = self:GetItemData(Index)
  self:InitDragWidget(GeneratedWidget, itemData.res_id)
  self:BeginAvatarDragHint(1)
end
function WardrobeAvatar:OnAvatarDragCanceled()
  log(bWriteLog and "WardrobeAvatar:OnAvatarDragCanceled")
  self:EndAvatarDragHint()
end
function WardrobeAvatar:OnAvatarSlotDrag(DragWidget, Index, GeneratedWidget, DragDropData)
  log(bWriteLog and "WardrobeAvatar:OnAvatarSlotDrag")
  local avatarSlotData = self:GetAvatarSlotData(Index)
  self:InitDragWidget(GeneratedWidget, avatarSlotData)
  self:BeginAvatarDragHint(0)
end
function WardrobeAvatar:OnAvatarSlotDrop(DragWidget, Index, DragDropData)
  log(bWriteLog and "WardrobeAvatar:OnAvatarSlotDrop")
  local dragAvatarInsID = tonumber(DragDropData.dragExtendData)
  local avatarData = wardrobe_data:GetHallDepotItemDataByInsID(dragAvatarInsID)
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe_new:SetClickItemInsId(dragAvatarInsID)
  self:PutAvatarDataToSlot(dragAvatarInsID, Index, avatarData)
  self:EndAvatarDragHint()
  local itemData = wardrobe_data:GetHallDepotItemDataByInsID(dragAvatarInsID)
  if itemData then
    local index, data = self:GetItemIndexByInsIdAndResId(itemData.insID, itemData.resID)
    if index ~= -1 then
      self.LoopScrollGrid_Normal:RefreshAllItems()
    end
  end
  self:PlayAudio(sound_config.click_v1)
end
function WardrobeAvatar:SimpleUISelect(_, _, InsID)
  local itemData = wardrobe_data:GetHallDepotItemDataByInsID(InsID)
  if itemData then
    local index, data = self:GetItemIndexByInsIdAndResId(itemData.insID, itemData.resID)
    if index ~= -1 then
      self.LoopScrollGrid_Normal:RefreshAllItems()
    end
  end
end
function WardrobeAvatar:SimpleUIRemove(_, _, DragDropData)
  local dragAvatarInsID = DragDropData.dragExtendData
  local itemData = wardrobe_data:GetHallDepotItemDataByResID(dragAvatarInsID)
  if itemData then
    local index, data = self:GetItemIndexByInsIdAndResId(itemData.insID, itemData.resID)
    if index ~= -1 then
      self.LoopScrollGrid_Normal:RefreshItem(index)
    end
  end
end
function WardrobeAvatar:OnAvatarSlotRemove(DragWidget, Index, DragDropData)
  log(bWriteLog and "WardrobeAvatar:OnAvatarSlotRemove")
  local avatarSlot = Index
  local resID = tonumber(DragDropData.dragExtendData)
  self:RemoveAvatarDataFromSlot(resID, avatarSlot)
  self:EndAvatarDragHint()
  local itemData = wardrobe_data:GetHallDepotItemDataByResID(resID)
  if itemData then
    local index, data = self:GetItemIndexByInsIdAndResId(itemData.insID, itemData.resID)
    if index ~= -1 then
      self.LoopScrollGrid_Normal:RefreshItem(index, data)
    end
  end
  self:PlayAudio(sound_config.click_v1)
end
function WardrobeAvatar:BeginAvatarDragHint(selection)
  local widgetSwitcherDrag = self.UIRoot.WidgetSwitcher_AvatarDrag
  widgetSwitcherDrag:SetWidgetVisibility(SelfHitTestInvisible)
  widgetSwitcherDrag:SetActiveWidgetIndex(selection)
end
function WardrobeAvatar:EndAvatarDragHint()
  local widgetSwitcherDrag = self.UIRoot.WidgetSwitcher_AvatarDrag
  widgetSwitcherDrag:SetWidgetVisibility(Hidden)
end
function WardrobeAvatar:OnRefreshListItem(widget, index)
  WardrobeAvatar.__super.OnRefreshListItem(self, widget, index)
  local suitData = self:GetItemData(index)
  local DragDropItem = widget.Common_DragDrop_Item
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bEnableDrag = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.ShareBag
  local SimpleUI_Clothes = UIManager.GetUI(UIManager.UI_Config.Lobby_SimpleUI_Clothes_UIBP)
  local canmove = false
  if SimpleUI_Clothes then
    canmove = true
  end
  if suitData and (bEnableDrag or canmove) then
    DragDropItem:SetEnable(true)
    DragDropItem:SetDragEnable(true)
    DragDropItem:RegisterDrag(1, 0, 0, suitData.ins_id)
  else
    DragDropItem:SetEnable(false)
    DragDropItem:SetDragEnable(false)
  end
end
function WardrobeAvatar:UpdatePutOnData(putOnItem, putDownItem)
  if putOnItem then
    local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
    if LogicMultiItemModule:IsWardRobeMultiLevelItem(putOnItem.res_id) then
      LogicMultiItemModule:UpdateSelectMultiItem(putOnItem.res_id)
    end
  end
  WardrobeAvatar.__super.UpdatePutOnData(self, putOnItem, putDownItem)
  self:RefreshMultiLevelCanvas(putOnItem)
end
function WardrobeAvatar:ShowOrHideLevelSwitch(show, itemId)
  log(bWriteLog and "  WardrobeAvatar:ShowOrHideLevelSwitch.  " .. tostring(itemId))
  if show then
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, itemId)
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_LevelSwitch, show)
  UIManager.CloseUI(UIManager.UI_Config.Wardrobe_Tag_NewGuide_Tips_05_UIBP)
  local showTop
  if show then
    local bonus_pass_util = require("client.slua.logic.unknow_pass.BonusPass.bonus_pass_util")
    local isBpClothes, otherId = bonus_pass_util.ShowBpClothes(itemId)
    if isBpClothes then
      showTop = true
    elseif otherId then
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local showGuide = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWardrobeColorfulGuide)
      log_warning(bWriteLog and "  ShowOrHideLevelSwitch:eWardrobeColorfulGuide. showGuide: " .. tostring(showGuide))
      if not showGuide or showGuide == 0 then
        PlayerPrefsSystem.SaveTableToFile_N(1, PlayerPrefsSystem.ePlayerPrefsType.eWardrobeColorfulGuide)
        showTop = true
        if self.topTipsUI then
          self.topTipsUI:CloseSelf()
          self.topTipsUI = nil
        end
        self.topTipsUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_TopRoot, UIManager.UI_Config.Wardrobe_Tag_NewGuide_Tips_05_UIBP)
      end
    end
  end
  if not showTop and self.topTipsUI then
    self.topTipsUI:CloseSelf()
    self.topTipsUI = nil
  end
end
function WardrobeAvatar:UpdatePutDownData(putDownItem)
  WardrobeAvatar.__super.UpdatePutDownData(self, putDownItem)
  if self.curTipsItemData and putDownItem and tostring(self.curTipsItemData.ins_id) == tostring(putDownItem.instid) then
    self.curTipsItemData = nil
  end
  self:RefreshMultiLevelCanvas()
end
function WardrobeAvatar:HasExpireTime(item)
  if not item then
    return false
  end
  local expire_ts = item.expire_ts
  if expire_ts and 0 < expire_ts then
    return true
  end
  local valid_hours = item.valid_hours
  if valid_hours and 0 < valid_hours then
    return true
  end
  return false
end
function WardrobeAvatar:CanShowFusionLevelSwitch()
  return true
end
function WardrobeAvatar:RefreshMultiLevelCanvas(putOnItem)
  if not slua.isValid(self.UIRoot.CanvasPanel_LevelSwitch) then
    return
  end
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag then
    self:ShowOrHideLevelSwitch(false)
    return
  end
  local SimpleUI_Clothes = UIManager.GetUI(UIManager.UI_Config.Lobby_SimpleUI_Clothes_UIBP)
  local SubhallClothUIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Subhall_Cloth_UIBP)
  if SimpleUI_Clothes or SubhallClothUIBP then
    self:ShowOrHideLevelSwitch(false)
    return
  end
  local itemListTable = self.LoopScrollGrid_Normal:GetSetData()
  for _, itemData in pairs(itemListTable) do
    if itemData and type(itemData) == "table" and itemData.isUsing then
      local res_id = itemData.res_id
      if LogicMultiItemModule:IsWardRobeMultiLevelItemWithTab(res_id) then
        self:ShowOrHideLevelSwitch(true, res_id)
        local Level = LogicMultiItemModule:GetMultiItemLevel(res_id)
        local MultiList = LogicMultiItemModule:GetMultiListByItemID(res_id)
        for _, value in pairs(MultiList) do
          self:RefreshMultiLevelItem(value.Level, value.ItemID, value.Level == Level, wardrobe_data:HasValidItem(value.ItemID, false, self:GetDataSource()))
        end
        return
      end
      local Cfg = LogicMultiItemModule:GetCartoonStyleCfg(res_id)
      if Cfg then
        self:ShowOrHideLevelSwitch(true, res_id)
        self:RefreshMultiLevelItem(1, Cfg.BaseID, res_id == Cfg.BaseID, true)
        self:RefreshMultiLevelItem(2, Cfg.CartoonStyleID, res_id == Cfg.CartoonStyleID, true)
        return
      end
      if LogicFusionModule:IsFusionItem(res_id) and self:CanShowFusionLevelSwitch() then
        local config = LogicFusionModule:GetFusionConfig(res_id)
        local period = config.period
        local targetItem = config.targetItem
        if not wardrobe_data:HasValidItem(targetItem, false, self:GetDataSource()) then
          log(bWriteLog and "  WardrobeAvatar:RefreshMultiLevelCanvas.  " .. tostring(res_id) .. " targetItem not valid")
          return
        end
        self:ShowOrHideLevelSwitch(true, res_id)
        local fusionRecord = LogicFusionModule:GetFusionRecord(period)
        local isFusion = fusionRecord and fusionRecord.current_item_id == targetItem
        if isFusion then
          self:RefreshMultiLevelItem(1, fusionRecord.pre_item_id, false, true, LogicFusionModule:GetFusionIconPath(fusionRecord.pre_item_id, true))
          self:RefreshMultiLevelItem(2, targetItem, true, true, LogicFusionModule:GetFusionIconPath(fusionRecord.pre_item_id, false))
        else
          self:RefreshMultiLevelItem(1, res_id, true, true, LogicFusionModule:GetFusionIconPath(res_id, true))
          self:RefreshMultiLevelItem(2, targetItem, false, wardrobe_data:HasValidItem(targetItem, false, self:GetDataSource()), LogicFusionModule:GetFusionIconPath(res_id, false))
        end
        return
      end
    end
  end
  self:ShowOrHideLevelSwitch(false)
end
local normalNotUsing = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_icon_Cap_04_png.WH_icon_Cap_04_png"
local normalUsing = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_icon_Cap_04_xuanzhong_png.WH_icon_Cap_04_xuanzhong_png"
local goldenNotUsing = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_Icon_GoldOutfit_png.WH_Icon_GoldOutfit_png"
local goldenUsing = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_Icon_GoldOutfit_XuanZhong_png.WH_Icon_GoldOutfit_XuanZhong_png"
function WardrobeAvatar:RefreshMultiLevelItem(index, itemID, isUsing, isHave, iconData)
  log(bWriteLog and "WardrobeAvatar RefreshMultiLevelItem index " .. tostring(index) .. " ItemID " .. tostring(itemID) .. " isUsing " .. tostring(isUsing) .. " isHave " .. tostring(isHave))
  local widgetName = "Wardrobe_EventSpin_item_" .. tostring(index)
  local widget = self.UIRoot[widgetName]
  if not slua.isValid(widget) then
    log(bWriteLog and "WardrobeAvatar:RefreshMultiLevelItem widget is not Valid" .. tostring(index))
    return
  end
  if isUsing then
    widget.WidgetSwitcher_Using:SetActiveWidgetIndex(1)
    widget.WidgetSwitcher_Level:SetActiveWidgetIndex(1)
    widget.Button_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    widget.WidgetSwitcher_Using:SetActiveWidgetIndex(0)
    widget.WidgetSwitcher_Level:SetActiveWidgetIndex(0)
    widget.Button_0:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
  local stateCfg = CDataTable.GetTableData("ClothingStateConfig", itemID)
  local CurrentIcon = stateCfg and stateCfg.CurrentIcon
  if CurrentIcon then
    self:SetTexture(widget.Image_using, CurrentIcon)
    self:SetTexture(widget.Image_notUsing, stateCfg.OtherIcon)
  else
    self:SetTexture(widget.Image_using, normalUsing)
    self:SetTexture(widget.Image_notUsing, normalNotUsing)
  end
  if iconData then
    if iconData.usingIconPath and iconData.usingIconPath ~= "" then
      self:SetTexture(widget.Image_using, iconData.usingIconPath)
    end
    if iconData.notUsingIconPath and iconData.notUsingIconPath ~= "" then
      self:SetTexture(widget.Image_notUsing, iconData.notUsingIconPath)
    end
  end
  if isHave then
    widget.CanvasPanel_Lock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    widget.CanvasPanel_Lock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  local bIsShowRedPoint = false
  if self:InInheritMode() then
    bIsShowRedPoint = false
  else
    local Logic_ColorShapeUtils = require("client.slua.logic.wardrobe.Logic_ColorShapeUtils")
    if Logic_ColorShapeUtils.CheckIsColorShapeItemId(itemID) then
      local nColorShapeUnlockItemId = Logic_ColorShapeUtils.GetColorShapeUnlockItemId()
      local nOwnCount = wardrobe_data:GetHallDepotItemCountByResID(nColorShapeUnlockItemId)
      bIsShowRedPoint = not isHave and 0 < nOwnCount
    end
  end
  self:SetWidgetVisible(widget.Reddot_Anchor_Item01, bIsShowRedPoint)
  local showArrow
  if stateCfg and stateCfg.hideArrow == 1 then
    showArrow = false
  elseif 1 < index then
    showArrow = true
  end
  self:SetWidgetVisible(widget.WidgetSwitcher_Level, showArrow)
  self:AddOnClickedEventByControl(self.UIRoot[widgetName].Button_0, self.OnClickMultiLevelItem, self, itemID)
end
function WardrobeAvatar:ResetHeadToDefaultIfNeeded()
  local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  logic_wardrobe_avatar:InitCurrentWearPreviewMap()
  local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(BP_ENUM_AVATAR_CLOTH)
  if not wearInfo then
    return false
  end
  local ItemResID = wearInfo.resID
  local InsID = wearInfo.insID
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  local ShapeID = logic_suit_multi_shape:GetSelfSuitShapeID(ItemResID)
  if not ShapeID or ShapeID == 0 then
    return false
  end
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  if InsID then
    log(bWriteLog and string.format("WardrobeSuit:ResetHeadToDefaultIfNeeded - Reset head for ItemResID:%s InsID:%s", tostring(ItemResID), tostring(InsID)))
    WardRobeHandler.send_put_off_gold_dress_bind_req(InsID)
    return true
  end
  return false
end
function WardrobeAvatar:OnClickMultiLevelItem(itemID)
  self:PlayAudio(sound_config.click_v1)
  self:ResetHeadToDefaultIfNeeded()
  local itemData = self:GetItemDataByResID(itemID, self:GetDataSource())
  if not itemData or not next(itemData) then
    itemData = self:GetItemDataByResID(itemID, self:GetDataSource(), true)
  end
  if not itemData or not next(itemData) then
    local Logic_ColorShapeUtils = require("client.slua.logic.wardrobe.Logic_ColorShapeUtils")
    if not self:InInheritMode() and Logic_ColorShapeUtils.CheckIsColorShapeItemId(itemID) then
      self.topTipsUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_TopRoot, UIManager.UI_Config.TopTipsPanel_UIBP, itemID)
      return
    end
    ShowNotice(7781)
    return
  end
  if itemData.lock_cnt and itemData.lock_cnt > 0 and itemData.count == itemData.lock_cnt then
    ShowNotice(3000016)
    return
  end
  if itemData.isUsing then
    ShowNotice(9910122)
    return
  end
  itemData.isNew = false
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe_new:SetClickItemInsId(itemData.ins_id)
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  local tabId = wardrobe_red_point:GetTabIdByRes(itemData.res_id)
  wardrobe_red_point:OnSelectTab(tabId)
  if not DataMgr.IsValidTime(itemData.expireTS) then
    ShowNotice(9910101)
    return
  end
  self:ShowBottomRightTips(itemData.ins_id, itemData.res_id)
  self.curTipsItemData = itemData
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if logic_wardrobe:IsItemIsolated(itemData.res_id) then
    ShowNotice(4987)
    return
  end
  if not logic_wardrobe:IsCharacterUse(itemData.res_id) then
    ShowNotice(7475)
    return
  end
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  WardrobeLogicManager:wardrobe_puton_req(itemData.ins_id)
end
function WardrobeAvatar:ShowBottomRightTips(ins_id, res_id)
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  tipsMgr:Show(tipsMgr.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, ins_id, res_id)
end
function WardrobeAvatar:GetItemIndexByInsIdAndResId(ins_id, res_id)
  local itemCount = self.LoopScrollGrid_Normal:GetItemCount()
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  for i = 1, itemCount do
    local data = self.LoopScrollGrid_Normal:GetItemData(i)
    local bIsLock = data.lock_cnt and data.lock_cnt > 0
    if data.ins_id == ins_id and data.res_id == res_id and not bIsLock then
      return i, data
    end
  end
  for i = 1, itemCount do
    local data = self.LoopScrollGrid_Normal:GetItemData(i)
    local bIsLock = data.lock_cnt and data.lock_cnt > 0
    if LogicMultiItemModule:isSameGroupMultiItem(data.res_id, res_id) and not bIsLock and not self:HasExpireTime(data) then
      return i, self:GetItemDataByResID(res_id, self:GetDataSource(), data.validHours ~= 0)
    end
    if LogicMultiItemModule:isSameGroupCartoonStyle(data.res_id, res_id) and not bIsLock and not self:HasExpireTime(data) then
      return i, self:GetItemDataByResID(res_id, self:GetDataSource(), data.validHours ~= 0)
    end
  end
  return -1
end
function WardrobeAvatar:GetItemDataByResID(res_id, DataSource, withTime)
  local itemData = {}
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local v = wardrobe_data:GetHallDepotItemDataByResIDAndTimeliness(res_id, withTime, DataSource)
  if v then
    local isWear = false
    local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(v.itemSubType)
    if wearInfo ~= nil then
      if logic_wardrobe_avatar:IsItemSubType_Bag_Helmet_Armor(v.itemSubType) then
        isWear = wearInfo.insID == v.insID
      else
        isWear = wearInfo.insID == v.insID and wearInfo.resID == v.resID
      end
    end
    itemData = WardrobeLogicManager:ArrayHallDepotToCommonItem(v, nil, isWear, true, false, false)
  end
  return itemData
end
function WardrobeAvatar:RefreshShareAvatarSlot()
  if self.UIRoot.CanvasPanel_AvatarSlot then
    local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    local eWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode()
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    local bShowSubscribeShare = eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_AvatarSlot, bShowSubscribeShare)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_SharePackageTips, bShowSubscribeShare)
  end
end
function WardrobeAvatar:OnRefreshAvatarSlotItem(widget, index)
  local itemId = self.LoopScrollGridAvatarSlot:GetItemData(index)
  local DragDropItem = widget.CommonDragDropItem
  local isShared = index <= self.sharedItemCount
  if isShared and itemId ~= 0 then
    DragDropItem:SetDragEnable(true)
    DragDropItem:RegisterDrag(1, 0, 0, itemId)
  else
    DragDropItem:SetDragEnable(false)
    DragDropItem:RegisterDrag(1, 0, 0, "")
  end
  DragDropItem:SetEnable(true)
  DragDropItem:RegisterDrop(1)
  self:InitSlotItemView(widget, index, itemId, isShared)
end
function WardrobeAvatar:RemoveAvatarFromShareSlot()
end
function WardrobeAvatar:InitSlotItemView(widget, index, itemId, isShared)
  widget.TextBlock_Index:SetWidgetVisibility(SelfHitTestInvisible)
  widget.TextBlock_Index:SetText(tostring(index))
  if isShared then
    local itemCfg = CDataTable.GetTableData("Item", itemId)
    if itemCfg then
      local UIUtil = require("client.common.ui_util")
      local smallIcon, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(itemId, widget.Icon)
      self:SetTexture(widget.Icon, smallIcon, {bHasAddKnownMissing = bHasAddKnownMissing})
      self:SetWidgetVisible(widget.Icon, true, false)
      self:SetWidgetVisible(widget.IsEmpty, false, false)
    end
  else
    self:SetWidgetVisible(widget.Icon, false, false)
    self:SetWidgetVisible(widget.IsEmpty, true, false)
  end
end
function WardrobeAvatar:GetAvatarSlotIndex(insId)
  if not insId then
    return nil
  end
  for i = 1, #self.shareItemList do
    if insId == self.shareItemList[i].insID then
      return i
    end
  end
  return nil
end
function WardrobeAvatar:IsSlotHasData(index)
  return index <= self.sharedItemCount
end
function WardrobeAvatar:PutAvatarDataToSlot(insId, index, avatarData)
  if not (insId and index) or not avatarData then
    return
  end
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if logic_wardrobe_new:PutItemToShareList(avatarData.resID, index) then
    self:UpdateAvatarSlotList()
  end
end
function WardrobeAvatar:RemoveAvatarDataFromSlot(resId, avatarSlot)
  if not resId then
    return
  end
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if logic_wardrobe_new:RemoveItemFromShareList(resId) then
    self:UpdateAvatarSlotList()
  end
end
function WardrobeAvatar:OnPostInitView(widget, itemData)
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if logic_wardrobe.isInShareSubscribeSetup then
    if logic_wardrobe:FindItemInShareList(itemData.res_id) then
      widget:SetUsingState(true)
    else
      widget:SetUsingState(false)
    end
  elseif logic_wardrobe:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag then
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
    if itemData.lock_cnt and itemData.lock_cnt > 0 then
      widget:SetUsingState(false)
    end
  elseif UIManager.GetUI(UIManager.UI_Config.Lobby_Subhall_Cloth_UIBP) then
    local SubhallClothUIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Subhall_Cloth_UIBP)
    if SubhallClothUIBP:HasSetInGrid(itemData) then
      widget:SetUsingState(true)
    else
      widget:SetUsingState(false)
    end
    if itemData.lock_cnt and itemData.lock_cnt > 0 then
      widget:SetUsingState(false)
    end
  else
    local SimpleUI_Clothes = UIManager.GetUI(UIManager.UI_Config.Lobby_SimpleUI_Clothes_UIBP)
    if SimpleUI_Clothes then
      if SimpleUI_Clothes:FindItemInSlotListSelectedDataToSetUsing(itemData) then
        widget:SetUsingState(true)
      else
        widget:SetUsingState(false)
      end
      if itemData.lock_cnt and itemData.lock_cnt > 0 then
        widget:SetUsingState(false)
      end
    else
      widget:SetUsingState(itemData.isUsing)
      if itemData.lock_cnt and itemData.lock_cnt > 0 then
        widget:SetUsingState(false)
      end
    end
  end
end
function WardrobeAvatar:OnClose()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ZOOM_VISIBILITY, false)
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseRepoLuaTableData", false) then
    log(bWriteLog and "WardrobeAvatar:OnClose ReleaseRepoLuaTableData")
    self.itemListTable = nil
    self.init = nil
    self.sharedItemCount = nil
    self.curTipsItemData = nil
    self.LoopScrollGrid_Normal = nil
    self.LoopScrollGridAvatarSlot = nil
    self.TimerToUpdateHandle = nil
    self._LoadSaveOperation = nil
    self.shareItemList = nil
    self.topTipsUI = nil
    self.loopScrollGrid = nil
  end
  WardrobeAvatar.__super.OnClose(self)
end
function WardrobeAvatar:OnShareBagListUpdate()
  self:UpdateAvatarSlotList()
end
local class = require("class")
local ui_subtab_item_list_base = require("client.slua.umg.Wardrobe.subtab_item_list_base")
local CWardrobeAvatar = class(ui_subtab_item_list_base, nil, WardrobeAvatar)
return CWardrobeAvatar