local TipsManager = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
local GetLogicMultiItemModule = function()
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  return LogicMultiItemModule
end
local WardrobeGliding = {}
function WardrobeGliding:ctor()
  self.AllItemList = {}
  self.itemList = {}
  self.currentSelected = nil
  self.ClickCDTimer = nil
  self.bInGlideScene = false
end
function WardrobeGliding:OnInitialize()
  log(bWriteLog and "WardrobeGliding:OnInitialize")
  WardrobeGliding.__super.OnInitialize(self)
  self.LoopScrollBox = self.LoopScrollGrid_Normal
end
function WardrobeGliding:RegistEvents()
  WardrobeGliding.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Wardrobe_EventSpin_item_1.Button_0, self.OnClickGlide, self)
  self:AddOnClickedEventByControl(self.UIRoot.Wardrobe_EventSpin_item_2.Button_0, self.OnClickHighLevelGlide, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOW_FASHION_BAG, self.OnWardrobeShowFashionBag, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SWITCH_USE_ROLEWEAR, self.OnSelectFashionBagSucess, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_JUMPBACK, self.OnFashionBagEditJumpBack, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_EQUIPED_GLIDE_MESHLOADED_HANDLE, self.OnEquipmentGlideByMeshLoaded, self)
end
function WardrobeGliding:OnPostInitialize()
  WardrobeGliding.__super.OnPostInitialize(self)
  self:InitGlidingList()
  WardrobeLogicManager:EnterGrenadeScene()
  self:InitModelDisplay()
  self:InitSwitchGlidingPanel()
  local EntryIconMgr = require("client.slua.umg.Wardrobe.entry.entry_icon_mgr")
  EntryIconMgr:SetIconVisibilityNoCreat(EntryIconMgr.ENUM_CHARACTER, false)
  self:ShowCurWearGlide()
  self:InitLevelCanvas()
end
function WardrobeGliding:OnClose()
  local EntryIconMgr = require("client.slua.umg.Wardrobe.entry.entry_icon_mgr")
  EntryIconMgr:SetIconVisibilityNoCreat(EntryIconMgr.ENUM_CHARACTER, true)
  self:HideSwitchGlidingPanel()
  TeamAvatarManager.ShowAllAvatar(TeamAvatarManager.MUTEX_WARDROBE)
  TeamAvatarManager.ReleaseMutex(TeamAvatarManager.MUTEX_WARDROBE)
  ModelDisplayer.Destroy()
end
function WardrobeGliding:ShowCurWearGlide()
  local ItemID, InsID
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if WardrobeLogicManager:GetWardrobeEditMode() ~= wardrobe_macro.EWardrobeEditMode.FashionBag then
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    local gliding = fashionbag_data:GetAircraftOrGliding()
    InsID = gliding
    local Data = WardrobeDataManager:GetValidHallDepotItemDataByInsID(InsID)
    ItemID = Data and Data.resID
    local DataSource = wardrobe_data:GetItemSource(InsID)
    if DataSource == self:GetDataSource() then
      self.LoopScrollGrid_Normal:Select(1)
    else
      log(bWriteLog and "WardrobeGliding:ShowCurWearGlide not select itemSource = " .. tostring(DataSource) .. ", DataSource = " .. tostring(self:GetDataSource()))
    end
  else
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    InsID = FashionBagEditUtils:GetCurrentGlidingOrAircraft()
    local DepotItemData = WardrobeDataManager:GetHallDepotItemDataByInsID(InsID)
    ItemID = DepotItemData and DepotItemData.resID
    local Index = self:GetItemIndexByResID(ItemID)
    self.LoopScrollGrid_Normal:Select(Index)
  end
  if not ItemID then
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, ItemID)
    self:SwtichGlideScene(false)
    return
  end
  log(bWriteLog and string.format("WardrobeGliding:ShowCurWearGlide. ItemID=%s", tostring(ItemID)))
  local GlideSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GlideSystem)
  local Origin  if LogicXSuit.IsXSuitGlide(ItemID) and self:CheckIsWearing7LevelCloth() and GlideSystem:UseHighLevelGlideSetting(ItemID) then
    ItemID = LogicXSuit.GetSpecialGlideID(ItemID)
  end
  self:ShowGlide(ItemID)
  local DataSource = wardrobe_data:GetItemSource(InsID)
  if DataSource ~= self:GetDataSource() then
    self:RefreshSwitchPanel()
    TipsManager:Hide()
  else
    self:RefreshSwitchPanel(ItemID)
    TipsManager:Show(TipsManager.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, InsID, OriginItemID)
  end
end
function WardrobeGliding:OnWardrobeDataChange(eventType, eventID)
  self:InitGlidingList()
end
function WardrobeGliding:InitGlidingList()
  log(bWriteLog and "WardrobeGliding:InitGlidingList")
  local itemInfo, isUsing
  local CurPage = self.subTabConfig.pageId
  local SubPage = self.subTabConfig.subTabId
  local depotItemList = self:GetArrayHallDepotItemInfo()
  self.itemList = {}
  self.AllItemList = {}
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local gliding = fashionbag_data:GetAircraftOrGliding()
  for _, v in pairs(depotItemList) do
    if WardrobeLogicManager:IsValidCurrentPageItem(CurPage, SubPage, v, serverTime) then
      if v.insID == gliding then
        isUsing = true
      else
        isUsing = false
      end
      itemInfo = WardrobeLogicManager:ArrayHallDepotToCommonItem(v, #self.AllItemList, isUsing, false, false, false, false)
      table.insert(self.AllItemList, itemInfo)
    end
  end
  self:SetInitItemList(self.AllItemList)
  if self.UIRoot.WidgetSwitcher_Search then
    self.itemList = self:DoSearch(self.AllItemList, WardrobeLogicManager:GetSearchString())
  end
  if self.bShowTagFilter then
    self.itemList = self:DoFilterTags(self.itemList)
  end
  self.itemList = self:FilterMultiItem(self.itemList)
  self:SortElements()
  WardrobeGliding.__super.UpdateItemList(self, self.itemList)
  WardrobeLogicManager:SetCurrentTabId(SubPage)
end
function WardrobeGliding:SortElements()
  local SortPreference = WardrobeLogicManager:GetSortPreference(self.subTabConfig)
  WardrobeLogicManager:SortItemTable(self.itemList, SortPreference)
end
function WardrobeGliding:OnClickItem(widget, index)
  WardrobeGliding.__super.OnClickItem(self, widget, index)
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  if itemData then
    self:ClickItem(itemData)
  end
end
function WardrobeGliding:ClickItem(itemData)
  if not DataMgr.IsValidTime(itemData.expireTS) then
    ShowNotice(9910101)
    return
  end
  TipsManager:Show(TipsManager.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, itemData.ins_id, itemData.res_id)
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if not logic_wardrobe:IsCanUse(itemData.res_id) then
    ShowNotice(4987)
    return
  end
  local itemInsID = itemData.ins_id
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag then
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    if FashionBagEditUtils:IsItemInTryMap(itemData.res_id, false, itemData) then
      FashionBagEditUtils:PutOffFashionBagItem(itemData)
      self:SwtichGlideScene(false)
      ModelDisplayer.HideAircraft()
    else
      FashionBagEditUtils:PutOnFashionBagItem(itemData)
      self:ShowGlide(itemData.res_id)
    end
  elseif itemData.isUsing then
    self:HideSwitchGlidingPanel()
    log(bWriteLog and "WardrobeAvatar:ClickItem PutDown ins_id:" .. itemInsID)
    WardrobeLogicManager:wardrobe_put_down_req(itemInsID)
  else
    log(bWriteLog and "WardrobeAvatar:ClickItem PutOn ins_id:" .. itemInsID)
    WardrobeLogicManager:wardrobe_puton_req(itemInsID)
  end
end
function WardrobeGliding:ChangeItemStatus(itemInsID, status)
  log(bWriteLog and "[WardrobeMultiItem] ChangeItemStatus itemInsID:" .. tostring(itemInsID) .. " status:" .. tostring(status))
  local itemCount = self.LoopScrollBox:GetItemCount()
  for i = 1, itemCount do
    local data = self.LoopScrollBox:GetItemData(i)
    if data.ins_id == itemInsID then
      data.isUsing = status
      self.LoopScrollBox:RefreshItem(i, data)
    end
  end
end
function WardrobeGliding:InitLevelSwitchIcon()
  local NotUsingIcon = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_icon_Cap_04_png.WH_icon_Cap_04_png"
  for Index = 1, 2 do
    local WidgetName = "Wardrobe_EventSpin_item_" .. tostring(Index)
    local Widget = self.UIRoot[WidgetName]
    if not slua.isValid(Widget) then
      return
    end
    self:SetTexture(Widget.Image_using, NotUsingIcon)
    self:SetTexture(Widget.Image_notUsing, NotUsingIcon)
  end
end
function WardrobeGliding:OnUpdatePutOnData(eventType, eventID, putOnItem, putDownItem)
  if putDownItem ~= nil then
    local item_cfg_down = CDataTable.GetTableData("Item", putDownItem.res_id)
    if item_cfg_down and WardrobeDataManager.IsGlideType(item_cfg_down.ItemSubType) and putOnItem ~= nil then
      local item_cfg_on = CDataTable.GetTableData("Item", putOnItem.res_id)
      if not WardrobeDataManager.IsGlideType(item_cfg_on.ItemSubType) then
        self:SetDisplaySetting(false)
      end
    end
    self:ChangeItemStatus(putDownItem.instid, false)
  end
  if putOnItem ~= nil then
    local ItemID = putOnItem.res_id
    local item_cfg_on = CDataTable.GetTableData("Item", putOnItem.res_id)
    if item_cfg_on and WardrobeDataManager.IsGlideType(item_cfg_on.ItemSubType) then
      if LogicXSuit.IsXSuitGlide(ItemID) and self:CheckIsWearing7LevelCloth() then
        ItemID = LogicXSuit.GetSpecialGlideID(ItemID)
      end
      self:RefreshSwitchPanel(ItemID)
      self:RefreshMultiItem(ItemID)
      self:ShowGlide(ItemID)
      local item_cfg_on = CDataTable.GetTableData("Item", ItemID)
      if WardrobeDataManager.IsGlideType(item_cfg_on.ItemSubType) then
        self:SetDisplaySetting(true)
      end
    end
    self:ChangeItemStatus(putOnItem.instid, true)
  end
end
function WardrobeGliding:OnUpdatePutDownData(eventType, eventID, putDownItem)
  local item_cfg = CDataTable.GetTableData("Item", putDownItem.res_id)
  if WardrobeDataManager.IsGlideType(item_cfg.ItemSubType) then
    self:SetDisplaySetting(false)
  end
  local SpecialGlideID = LogicXSuit.GetSpecialGlideID(putDownItem.res_id)
  if ModelDisplayer.HasEquiped(putDownItem.res_id) or ModelDisplayer.HasEquiped(SpecialGlideID) then
    self:SwtichGlideScene(false)
    ModelDisplayer.HideAircraft()
  end
  self:ChangeItemStatus(putDownItem.instid, false)
end
function WardrobeGliding:ReSortItem()
  self:SortElements()
  self:UpdateItemListBySort(self.itemList)
end
function WardrobeGliding:SetDisplaySetting(isPutOn)
  local LogicDisplaySetting = require("client.slua.logic.wardrobe.logic_display_setting")
  if isPutOn then
    LogicDisplaySetting.SetAircastUsed(true)
  else
    LogicDisplaySetting.SetAircastUsed(false)
  end
end
function WardrobeGliding:InitSwitchGlidingPanel()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_LevelSwitch, false, false)
  self:SetWidgetVisible(self.UIRoot.Wardrobe_EventSpin_item_1.CanvasPanel_Lock, false, false)
  self:SetSwitchUsing(1)
  self:InitLevelSwitchIcon()
end
function WardrobeGliding:HideSwitchGlidingPanel()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_LevelSwitch, false, false)
end
function WardrobeGliding:InitModelDisplay()
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local tabId = logic_wardrobe.GetCurrentTabId()
  if tabId ~= wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_effect then
    return
  end
  log(bWriteLog and "WardrobeGliding:InitModelDisplay")
  local wearingInfo
  if WardrobeLogicManager:GetWardrobeEditMode() ~= wardrobe_macro.EWardrobeEditMode.FashionBag then
    wearingInfo = AvatarData.GetWearInfo()
  else
    log(bWriteLog and "WardrobeGliding:InitModelDisplay In FashingBag")
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    wearingInfo = FashionBagEditUtils:GetWearInfo()
  end
  log_tree("WardrobeGliding:InitModelDisplay wearingInfo", wearingInfo)
  if not wearingInfo then
    return
  end
  ModelDisplayer.Destroy()
  ModelDisplayer.Init(wearingInfo)
  ModelDisplayer.SetNeedAutoRotate(false)
  local LogicDisplaySetting = require("client.slua.logic.wardrobe.logic_display_setting")
  local ShowingAvatar = ModelDisplayer.GetShowingAvatar()
  if ShowingAvatar then
    ShowingAvatar:SetForceUseDefaultIdle(not LogicDisplaySetting.ShowIdle())
  end
end
function WardrobeGliding:ResetModelDisplayEquipment()
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local tabId = logic_wardrobe.GetCurrentTabId()
  if tabId ~= wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_effect then
    return
  end
  log(bWriteLog and "WardrobeGliding:ResetModelDisplayEquipment")
  local wearingInfo
  if WardrobeLogicManager:GetWardrobeEditMode() ~= wardrobe_macro.EWardrobeEditMode.FashionBag then
    wearingInfo = AvatarData.GetWearInfo()
  else
    log(bWriteLog and "WardrobeGliding:ResetModelDisplayEquipment In FashingBag")
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    wearingInfo = FashionBagEditUtils:GetWearInfo()
  end
  log_tree("WardrobeGliding:ResetModelDisplayEquipment wearingInfo", wearingInfo)
  if not wearingInfo then
    return
  end
  local currentWearingSet = {}
  for _, v in pairs(wearingInfo) do
    currentWearingSet[v.ItemID] = true
  end
  local ShowingAvatar = ModelDisplayer.GetShowingAvatar()
  if ShowingAvatar then
    local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
    local characterID = NewCharacterNetSystem:GetCurUsedCharacterID()
    local NewCharacterAvatarSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterAvatarSystem)
    local avatarData = NewCharacterAvatarSystem:GetAvatarDataByCharacterID(characterID)
    local keepEquipments = {}
    if avatarData then
      if avatarData.headid then
        keepEquipments[avatarData.headid] = true
      end
      if avatarData.hairid then
        keepEquipments[avatarData.hairid] = true
      end
    end
    local lastEquipments = ShowingAvatar:GetEquipments()
    for _, v in ipairs(lastEquipments) do
      local itemID = v.itemID
      if not keepEquipments[itemID] and not currentWearingSet[itemID] then
        ShowingAvatar:PutoffEquipment(itemID)
      end
    end
    for _, v in ipairs(wearingInfo) do
      ShowingAvatar:PutonEquipment(v.ItemID)
    end
  end
  ModelDisplayer.SetNeedAutoRotate(false)
  local LogicDisplaySetting = require("client.slua.logic.wardrobe.logic_display_setting")
  if ShowingAvatar then
    ShowingAvatar:SetForceUseDefaultIdle(not LogicDisplaySetting.ShowIdle())
  end
end
function WardrobeGliding:GetCurrentSelectId()
  local SelectIndex = self.LoopScrollGrid_Normal:GetSelectIndex()
  if SelectIndex < 1 then
    log(bWriteLog and "[XSuitGlide] GetCurrentSelectId SelectIndex:" .. tostring(SelectIndex))
    return 0
  end
  local itemData = self.LoopScrollGrid_Normal:GetItemData(SelectIndex)
  if not itemData then
    log(bWriteLog and "[XSuitGlide] GetCurrentSelectId not itemData SelectIndex:" .. tostring(SelectIndex))
    return 0
  end
  return itemData.res_id
end
function WardrobeGliding:CheckClickCD()
  if self.ClickCDTimer then
    return true
  end
  self.ClickCDTimer = self:AddTimerOnce(2, function()
    self.ClickCDTimer = nil
  end)
  return false
end
function WardrobeGliding:InitLevelCanvas()
  self:SetWidgetVisible(self.UIRoot.Wardrobe_EventSpin_item_1.CanvasPanel_Lock, false, false)
  self.UIRoot.Wardrobe_EventSpin_item_1.WidgetSwitcher_Level:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:SetTexture(self.UIRoot.Wardrobe_EventSpin_item_1.Image_1, "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_icon_AirVehicle01_png.WH_icon_AirVehicle01_png")
  self:SetTexture(self.UIRoot.Wardrobe_EventSpin_item_1.Image_3, "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_icon_AirVehicle02_png.WH_icon_AirVehicle02_png")
  self:SetTexture(self.UIRoot.Wardrobe_EventSpin_item_2.Image_1, "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_icon_AirVehicle03_png.WH_icon_AirVehicle03_png")
  self:SetTexture(self.UIRoot.Wardrobe_EventSpin_item_2.Image_3, "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_icon_AirVehicle04_png.WH_icon_AirVehicle04_png")
end
function WardrobeGliding:OnClickGlide()
  self:PlayAudio(sound_config.click_v1)
  log(bWriteLog and "[XSuitGlide] OnClickGlide ")
  if self:CheckClickCD() then
    ShowNotice(930033)
    return
  end
  local CurrentSelectID = self:GetCurrentSelectId()
  if LogicXSuit.IsXSuitGlide(CurrentSelectID) then
    self:HandleClickXSuitBaseGilde(CurrentSelectID)
  elseif GetLogicMultiItemModule():IsWardRobeMultiLevelItem(CurrentSelectID) then
    local ItemID = GetLogicMultiItemModule():GetItemID(CurrentSelectID, 1)
    self:HandleClickMultiBaseGlide(ItemID)
  end
end
function WardrobeGliding:OnClickHighLevelGlide()
  self:PlayAudio(sound_config.click_v1)
  if self:CheckClickCD() then
    ShowNotice(930033)
    return
  end
  local CurrentSelectID = self:GetCurrentSelectId()
  log(bWriteLog and "[WardrobeMultiItem] OnClickHighLevelGlide CurrentSelectID" .. tostring(CurrentSelectID))
  if LogicXSuit.IsXSuitGlide(CurrentSelectID) then
    self:HandleClickXSuitSpecialGilde(CurrentSelectID)
  elseif GetLogicMultiItemModule():IsWardRobeMultiLevelItem(CurrentSelectID) then
    local ItemID = GetLogicMultiItemModule():GetItemID(CurrentSelectID, 2)
    self:HandleClickMultiHighLevelGlide(ItemID)
  end
end
function WardrobeGliding:HandleClickMultiBaseGlide(ItemID)
  log(bWriteLog and "[WardrobeMultiItem] HandleClickMultiBaseGlide ItemID" .. tostring(ItemID))
  local itemData = self:GetItemInfo(ItemID)
  if not itemData or not next(itemData) then
    log_error("[WardrobeMultiItem] HandleClickMultiBaseGlide Can`t find ItemID " .. tostring(ItemID))
    log_tree("[WardrobeMultiItem] self.AllItemList", self.AllItemList)
    return
  end
  self:ClickItem(itemData)
end
function WardrobeGliding:HandleClickMultiHighLevelGlide(ItemID)
  log(bWriteLog and "[WardrobeMultiItem] HandleClickMultiHighLevelGlide ItemID" .. tostring(ItemID))
  local itemData = self:GetItemInfo(ItemID)
  if not itemData or not next(itemData) then
    GetLogicMultiItemModule():ShowUnlockJumpTips(ItemID, self.UIRoot.Wardrobe_EventSpin_item_2)
    return
  end
  self:ClickItem(itemData)
end
function WardrobeGliding:GetItemInfo(ItemID)
  local ItemInfo = {}
  for key, value in pairs(self.AllItemList) do
    if value.res_id == ItemID then
      ItemInfo = value
      break
    end
  end
  return ItemInfo
end
function WardrobeGliding:RefreshMultiItem(PutOnItemID)
  if not GetLogicMultiItemModule():IsWardRobeMultiLevelItem(PutOnItemID) then
    return
  end
  GetLogicMultiItemModule():UpdateSelectMultiItem(PutOnItemID)
  local ItemInfo = self:GetItemInfo(PutOnItemID)
  local Level1ID = GetLogicMultiItemModule():GetItemID(PutOnItemID, 1)
  local Level2ID = GetLogicMultiItemModule():GetItemID(PutOnItemID, 2)
  local itemCount = self.LoopScrollBox:GetItemCount()
  for i = 1, itemCount do
    local data = self.LoopScrollBox:GetItemData(i)
    if data.res_id == Level1ID or data.res_id == Level2ID then
      self.LoopScrollBox:RefreshItem(i, ItemInfo)
    end
  end
end
function WardrobeGliding:NeedShowLevelSwitchCanvas(ItemID)
  if self:GetCurrentSelectId() == 0 then
    return false
  end
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag then
    return false
  end
  if LogicXSuit.IsXSuitGlide(ItemID) then
    return true
  end
  return WardrobeGliding.__super.NeedShowLevelSwitchCanvas(self, ItemID)
end
function WardrobeGliding:NeedShowLock(ItemID, DataSource)
  if LogicXSuit.IsXSuitGlide(ItemID) and self:CheckIsWearing7LevelCloth() then
    return false
  end
  return WardrobeGliding.__super.NeedShowLock(self, ItemID, DataSource)
end
function WardrobeGliding:HandleClickXSuitBaseGilde(ItemID)
  log(bWriteLog and "[WardrobeMultiItem] HandleClickXSuitBaseGilde ItemID" .. tostring(ItemID))
  self:RefreshSwitchPanel(ItemID)
  self:ShowGlide(ItemID)
  if self:CheckIsWearing7LevelCloth() then
    local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
    WardRobeHandler.send_set_xsuit_glide_req(ItemID, false)
  end
end
function WardrobeGliding:HandleClickXSuitSpecialGilde(ItemID)
  if not self:CheckIsWearing7LevelCloth() then
    ShowNotice(49553)
    return
  end
  local SpecialGlideID = LogicXSuit.GetSpecialGlideID(ItemID)
  log(bWriteLog and "[WardrobeMultiItem] HandleClickXSuitSpecialGilde ItemID:" .. tostring(ItemID) .. " SpecialGlideID:" .. tostring(SpecialGlideID))
  self:RefreshSwitchPanel(SpecialGlideID)
  self:ShowGlide(SpecialGlideID)
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_set_xsuit_glide_req(ItemID, true)
end
function WardrobeGliding:CheckIsWearing7LevelCloth()
  local res_id = self:GetCurrentSelectId()
  if res_id == 0 then
    log(bWriteLog and "[XSuitGlide] CheckIsWearing7LevelCloth res_id ==0")
    return
  end
  local Level7ID = LogicXSuit.GetLevel7XSuitID(res_id)
  local bHasEuqip = ModelDisplayer.HasEquiped(Level7ID)
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  local allDisplayID = multi_state_manager:GetAllDisplayClothIDByOriginID(Level7ID)
  if allDisplayID then
    for _, disPlayID in pairs(allDisplayID) do
      if ModelDisplayer.HasEquiped(disPlayID) then
        bHasEuqip = true
        break
      end
    end
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local WardrobeNum = wardrobe_data:GetHallDepotItemCountByResID(Level7ID, true)
  local InheritNum = wardrobe_data:GetHallDepotItemCountByResID(Level7ID, true, EWardrobeDataSource.InheritWardrobe)
  log(bWriteLog and "[XSuitGlide] CheckIsWearing7LevelCloth Level7ID:" .. tostring(Level7ID) .. " bHasEuqip:" .. tostring(bHasEuqip) .. " WardrobeNum:" .. tostring(WardrobeNum) .. " InheritNum:" .. tostring(InheritNum))
  if bHasEuqip and (0 < WardrobeNum or 0 < InheritNum) then
    return true
  end
  return false
end
function WardrobeGliding:GetItemShowLevel(ItemID)
  local Level = WardrobeGliding.__super.GetItemShowLevel(self, ItemID)
  if LogicXSuit.IsXSuitGlide(ItemID) then
    if LogicXSuit.IsNormalGlideID(ItemID) then
      Level = 1
    else
      Level = 2
    end
  end
  return Level
end
function WardrobeGliding:SwtichGlideScene(bEnter)
  log(bWriteLog and "WardrobeGliding:SwtichGlideScene bEnter" .. tostring(bEnter) .. "self.bInGlideScene" .. tostring(self.bInGlideScene))
  if bEnter == self.bInGlideScene then
    return
  end
  local ShowingAvatar = ModelDisplayer.GetShowingAvatar()
  self.bInGlideScene = bEnter
  local GlideSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GlideSystem)
  if bEnter then
    local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
    if UIManager.IsUIShow(UIManager.UI_Config.fashion_bag_overview) then
      GlideSystem:EnterGlideScene(ConstAvatarDislay.ESceneType.FashionBag, ShowingAvatar)
    else
      GlideSystem:EnterGlideScene(ConstAvatarDislay.ESceneType.Wardrobe, ShowingAvatar)
    end
  else
    GlideSystem:ExitGlideScene()
    if UIManager.IsUIShow(UIManager.UI_Config.fashion_bag_overview) then
      local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
      WardrobeLogicManager:EnterWardrobeScene(Lobby_camera_manager_module.Enum_CameraID.wardrobe_fashionbag, LobbySceneManager.LEVEL_NAME.MALL)
    else
      WardrobeLogicManager:EnterGrenadeScene()
    end
  end
end
function WardrobeGliding:ShowGlide(ItemID)
  self:SwtichGlideScene(true)
  ModelDisplayer.Display(ItemID, true)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, ItemID)
end
function WardrobeGliding:OnWardrobeShowFashionBag()
  log(bWriteLog and string.format("WardrobeGliding:OnWardrobeShowFashionBag"))
  local CurrentGlidingResID = self:_GetCurrentGlidingResID()
  if CurrentGlidingResID then
    local GlideSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GlideSystem)
    local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
    GlideSystem:EnterGlideScene(ConstAvatarDislay.ESceneType.FashionBag, ModelDisplayer.GetShowingAvatar(), true)
  end
  self:_CheckGlideIsEquipped()
  if not self.bInGlideScene then
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.Enum_CameraID.wardrobe_fashionbag, 0.3)
  end
end
function WardrobeGliding:OnWardrobeBackFashionBag()
  WardrobeGliding.__super.OnWardrobeBackFashionBag(self)
  self:_CheckGlideIsEquipped()
  if self.bInGlideScene then
    local GlideSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GlideSystem)
    local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
    GlideSystem:EnterGlideScene(ConstAvatarDislay.ESceneType.Wardrobe, ModelDisplayer.GetShowingAvatar(), true)
  else
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.Enum_CameraID.store_general, 0.3)
  end
end
function WardrobeGliding:OnSelectFashionBagSucess(_, __, CurrentIndex)
  self:InitGlidingList()
  self:InitModelDisplay()
  self:RefreshSwitchGlidingPanel()
  local CurrentGlidingResID = self:_GetCurrentGlidingResID()
  if CurrentGlidingResID then
    local GlideSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GlideSystem)
    local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
    GlideSystem:EnterGlideScene(ConstAvatarDislay.ESceneType.FashionBag, ModelDisplayer.GetShowingAvatar(), true)
  end
  self:ShowCurWearGlide()
  self:_CheckGlideIsEquipped()
  if not self.bInGlideScene then
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.Enum_CameraID.wardrobe_fashionbag)
  end
end
function WardrobeGliding:OnReloginInFashionBagEditMode()
  self.bInGlideScene = nil
  self:RefreshSceneAndGlider()
  self.LoopScrollBox:RefreshAllItems()
end
function WardrobeGliding:OnFashionBagEditExit(_, __)
  WardrobeGliding.__super.OnFashionBagEditExit(self, _, __)
  self:RefreshSceneAndGlider()
end
function WardrobeGliding:RefreshSceneAndGlider()
  self:InitGlidingList()
  self:InitModelDisplay()
  self:ShowCurWearGlide()
end
function WardrobeGliding:RefreshSwitchGlidingPanel()
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local gliding = fashionbag_data:GetAircraftOrGliding()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(gliding)
  if itemInfo then
    self:RefreshSwitchPanel(itemInfo.resID)
  else
    self:HideSwitchGlidingPanel()
  end
end
function WardrobeGliding:OnFashionBagChange(_, __, CurrentIndex)
  WardrobeGliding.__super.OnFashionBagChange(self, _, __, CurrentIndex)
  self:InitModelDisplay()
end
function WardrobeGliding:OnFashionBagEditJumpBack(_, __)
  self.bInGlideScene = nil
  self:RefreshSceneAndGlider()
end
function WardrobeGliding:OnEquipmentGlideByMeshLoaded()
  local GlideSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GlideSystem)
  local avatar = ModelDisplayer.GetShowingAvatar()
  local bHasEquipedGlide = avatar:HasEquipedGlide()
  GlideSystem:HandleGildeEquip(bHasEquipedGlide, avatar:GetEquipedGlideID())
end
function WardrobeGliding:_GetCurrentGlidingResID()
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local gliding = fashionbag_data:GetAircraftOrGliding()
  local Data = WardrobeDataManager:GetValidHallDepotItemDataByInsID(gliding)
  local ItemID = Data and Data.resID
  return ItemID
end
function WardrobeGliding:_CheckGlideIsEquipped()
  if ModelDisplayer.GetShowingAvatar() and ModelDisplayer.GetShowingAvatar():GetEquipedGlideID() ~= 0 then
    self.bInGlideScene = true
  else
    self.bInGlideScene = false
  end
end
function WardrobeGliding:GetItemIndexByResID(ResID)
  local Index = 1
  local ItemCount = self.LoopScrollGrid_Normal:GetItemCount()
  for i = 1, ItemCount do
    local TempItemData = self.LoopScrollGrid_Normal:GetItemData(i)
    if TempItemData.res_id == ResID then
      Index = i
      break
    end
  end
  return Index
end
function WardrobeGliding:OnDownloadFinish(_, _, eventData)
  WardrobeGliding.__super.OnDownloadFinish(self, _, _, eventData)
  local itemID = eventData.itemID
  if not itemID or tonumber(itemID) <= 0 then
    return
  end
  local CurrentGlidingResID = self:_GetCurrentGlidingResID()
  log(bWriteLog and "WardrobeGliding:OnDownloadFinish CurrentGlidingResID = " .. tostring(CurrentGlidingResID) .. " itemID = " .. tostring(itemID))
  local GlideSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GlideSystem)
  local CurLobbyID = GlideSystem:ConvertToLobbyID(CurrentGlidingResID)
  local ItemLobbyID = GlideSystem:ConvertToLobbyID(itemID)
  log(bWriteLog and "WardrobeGliding:OnDownloadFinish CurLobbyGlideID = " .. tostring(CurLobbyID) .. " itemLobbyID = " .. tostring(ItemLobbyID))
  if CurLobbyID and tonumber(CurLobbyID) == tonumber(ItemLobbyID) then
    local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
    if UIManager.IsUIShow(UIManager.UI_Config.fashion_bag_overview) then
      GlideSystem:EnterGlideScene(ConstAvatarDislay.ESceneType.FashionBag, ModelDisplayer.GetShowingAvatar(), true)
    else
      GlideSystem:EnterGlideScene(ConstAvatarDislay.ESceneType.Wardrobe, ModelDisplayer.GetShowingAvatar(), true)
    end
  end
end
local class = require("class")
local normal_item_list = require("client.slua.umg.Wardrobe.subtab_item_list_base")
local Gliding = class(normal_item_list, nil, WardrobeGliding)
return Gliding