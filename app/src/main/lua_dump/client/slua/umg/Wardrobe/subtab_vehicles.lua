local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
local WardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local TabSurveillance = require("client.slua.logic.wardrobe.tab_surveillance")
local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
local Visible = UEnums.ESlateVisibility.Visible
local Collapsed = UEnums.ESlateVisibility.Collapsed
local HitTestInvisible = UEnums.ESlateVisibility.HitTestInvisible
local SelfHitTestInvisible = UEnums.ESlateVisibility.SelfHitTestInvisible
local WardrobeVehicle = {}
local showVehicleId = 0
local showVehicleItemSource = EWardrobeDataSource.Wardrobe
local SlotNum = 5
local vehicleSceneLoaded = false
local Vehicle = WardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Vehicle
local GetLogicMultiItemModule = function()
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  return LogicMultiItemModule
end
function WardrobeVehicle:ctor()
  self.vehicleList = {}
  self.TypeStringToID = {}
  self.TypeIDToString = {}
  self.vehicleCategory = {}
  self.TabItemCount = {}
  self.curSelectVehicleType = nil
  self.subTabId = "Vehicle"
  self.VehicleSlot = {}
  self.DefaultVehicleInsId = {}
  self.AllItemList = {}
  self.curPutOnInsId = nil
end
function WardrobeVehicle:OnShow()
  WardrobeVehicle.__super.OnShow(self)
  local logic_SuperCar_200Version = require("client.maps.logic_SuperCar_200Version")
  logic_SuperCar_200Version.SetSpringArmCamCanTouchRotate(true)
  log(bWriteLog and "WardrobeVehicle:Initialize:OnShow")
  TeamAvatarManager.GetMutex(TeamAvatarManager.MUTEX_WARDROBE)
  TeamAvatarManager.HideAllAvatar(TeamAvatarManager.MUTEX_WARDROBE)
  self:RefreshVehicleTypeComboBox()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOW_ENTRY_ICON, false)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOW_BG, false)
  local vehicleData = self:GetVehicleList(1)
  if vehicleData then
    WardrobeLogicManager:SetCurrentTabId(vehicleData.WardrobeTab)
  end
  self:ShowCarSkinList()
  if self.UIRoot.WidgetSwitcher_LeftPanel then
    self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_LeftPanel, false, false)
  end
end
function WardrobeVehicle:ShowCarSkinList()
  self.UIRoot.CanvasPanel_CarSkinDrag:SetWidgetVisibility(Visible)
end
function WardrobeVehicle:OnHide()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOW_ENTRY_ICON, true)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOW_BG, true)
  WardrobeVehicle.__super.OnHide(self)
end
function WardrobeVehicle:OnClose()
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  if self.redHandle then
    local vehiclePage = wardrobe_red_point:GetVehiclePage()
    if vehiclePage then
      vehiclePage:RemoveEvent(self.redHandle)
    end
    self.redHandle = nil
  end
  self:RefreshSwitchPanel()
  local sub_tab_buttons_mgr = require("client.slua.umg.Wardrobe.sub_tab_buttons_mgr")
  sub_tab_buttons_mgr:HideChangeViewButton()
  sub_tab_buttons_mgr:HideVehicleCabrioletButton()
  local logic_lobby_garage_scene = require("client.maps.logic_lobby_garage_scene")
  logic_lobby_garage_scene.SetTAA(false)
  local sub_tab_supercar_buttons_mgr = require("client.slua.umg.Wardrobe.sub_tab_supercar_buttons_mgr")
  sub_tab_supercar_buttons_mgr:HideDoorViewButtons()
  self:CloseFeaturePanel()
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  HallThemeUtils.ShowThemeVehicle()
end
function WardrobeVehicle:Close()
  log(bWriteLog and "WardrobeVehicle:Initialize:Close")
  TeamAvatarManager.ShowAllAvatar(TeamAvatarManager.MUTEX_WARDROBE)
  TeamAvatarManager.ReleaseMutex(TeamAvatarManager.MUTEX_WARDROBE)
  local logic_SuperCar_200Version = require("client.maps.logic_SuperCar_200Version")
  logic_SuperCar_200Version.SetSpringArmCamCanTouchRotate(true)
  if self.UIRoot then
    self.UIRoot.Reddot_Anchor:UnBind()
  end
  showVehicleId = 0
  vehicleSceneLoaded = false
  self.TabItemCount = {}
  WardrobeVehicle.__super.Close(self)
end
function WardrobeVehicle:OnInitialize()
  log(bWriteLog and "WardrobeVehicle:OnInitilize")
  WardrobeVehicle.__super.OnInitialize(self)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_BagMode, false)
  self:SetWidgetVisible(self.UIRoot.Common_Tab_BagMode, false)
  self.VehicleComboBox = self:InitCommonComboBoxNew(self.UIRoot.Common_ComboBox_GunType)
  self.VehicleComboBox:SetSelectOptionCallback(self.OnSelectVehicleType, self)
  self.VehicleComboBox:SetRefreshOptionCallback(self.OnRefreshVehicleType, self)
  self.LoopScrollGridSkins = self.LoopScrollGrid_Normal
  self.LoopScrollGridVehicles = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_GunList, "client.slua.umg.Wardrobe.Item.Wardrobe_GunTypeItem_BP")
  self.LoopScrollGridSkins:SetRefreshItemCallback(self.OnRefreshVehicleSkin, self)
  self:AddControlEventByControl(self.UIRoot.Button_0, "OnClicked", self.OnClickButton_ShowTips, self)
  self:InitVehicleList()
  self.LoopScrollGridSkins:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragReadyToShape", self.OnVehicleDragReadyToShape, self)
  self.LoopScrollGridSkins:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragCanCeled", self.OnVehicleDragCanceled, self)
  self.LoopScrollBox_0 = self:InitScrollBox(self.UIRoot.LoopScrollBox_0)
  self.LoopScrollBox_0:SetRefreshItemCallback(self.OnRefreshVehicleSlotItem, self)
  self.LoopScrollBox_0:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragSuccess", self.OnVehicleSlotDrop, self)
  self.LoopScrollBox_0:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragReadyToShape", self.OnVehicleSlotDrag, self)
  self.LoopScrollBox_0:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragCanCeled", self.OnVehicleSlotRemove, self)
  self.UIRoot.TextBlock_0:SetText(LocUtil.LocalizeResFormat(33524))
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  local vehiclePage = wardrobe_red_point:GetVehiclePage()
  self.UIRoot.Reddot_Anchor:ShowRedPointByPath(wardrobe_red_point.C_Wardrobe_RedPoint_Style)
  if vehiclePage then
    self.redHandle = vehiclePage:BindEvent(function(value)
      self.VehicleComboBox:RefreshOptions()
      self.LoopScrollGridVehicles:RefreshAllItems()
      self:SetWidgetVisible(self.UIRoot.Reddot_Anchor, value ~= 0)
    end)
  end
  local tabSurveillance = require("client.slua.logic.wardrobe.tab_surveillance")
  tabSurveillance.VehicleChange()
  WardrobeLogicManager:SetCurrSceneType(WardrobeLogicManager.VehicleSceneType.None)
  local vehicleItemID = self:GetItemIDByFristTab()
  WardrobeLogicManager:EnterVehicleSceneByItemID(vehicleItemID)
  local sub_tab_buttons_mgr = require("client.slua.umg.Wardrobe.sub_tab_buttons_mgr")
  sub_tab_buttons_mgr:InitUI()
  sub_tab_buttons_mgr:ToggleChangeViewBtnDisplayByCarID(vehicleItemID)
  sub_tab_buttons_mgr:CheckShowVehicleCabrioletButton(vehicleItemID)
  self:AddOnClickedEventByControl(self.UIRoot.Wardrobe_EventSpin_item_1.Button_0, self.OnClickBaseLevel, self)
  self:AddOnClickedEventByControl(self.UIRoot.Wardrobe_EventSpin_item_2.Button_0, self.OnClickHighLevel, self)
  self:InitLevelCanvas()
end
function WardrobeVehicle:RegistEvents()
  WardrobeVehicle.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_VEHICLE_SLOT_DATA_CHANGE, self.OnSlotSkinDataChange, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_LOADED, self.OnVehicleSceneLoaded, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_GARAGE_MODEL_READY, self.OnModelReady, self)
end
function WardrobeVehicle:IsShowBigIcon()
  return true
end
function WardrobeVehicle:OnSportsCarFeatureUpdate(carItemID, bIsRareCar)
  self:CloseFeaturePanel()
  if not carItemID then
    return
  end
  local featuresItem = CDataTable.GetTableData("FeaturesItems", carItemID)
  if not featuresItem then
    return
  end
  log(bWriteLog and "WardrobeVehicle:OnSportsCarFeatureUpdate carItemID = " .. carItemID)
  local ConstDetail = require("client.slua.traits.DetailComponent.ConstDetail")
  local DetailConfig = ConstDetail.GetDefaultCloseConfig()
  DetailConfig.feature = true
  DetailConfig.superCarDoorSlot = bIsRareCar
  DetailConfig.cavrioletBtnSlot = bIsRareCar
  DetailConfig.car = false
  DetailConfig.videoBtn = false
  DetailConfig.sportCarInstruction = false
  DetailConfig.skipAutoPlayVideo = false
  local offset = {
    feature = FVector2D(0, 50),
    sportsCarEnter = FVector2D(100, 0)
  }
  local initData = {
    switches = DetailConfig,
    offsetInfo = offset,
    ViewCompPadding = FMargin(0, 250, 0, 0)
  }
  local mainUI = UIManager.GetUI(UIManager.UI_Config.wardrobe)
  if not mainUI then
    return
  end
  self.widgetDetailComponent = mainUI:CreateChildWindow(mainUI.UIRoot.CanvasPanel_Detail, UIManager.UI_Config.DetailComponentMain, initData)
  local LogicVehicleAccessory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleAccessory)
  local TableUtil = require("common.table_util")
  local accessoryList = TableUtil.CopyTable(LogicVehicleAccessory:GetEquipedAccessoryList(carItemID, showVehicleItemSource))
  local extraData = {AccessoryList = accessoryList}
  self.widgetDetailComponent:SetData(carItemID, extraData)
end
function WardrobeVehicle:CloseFeaturePanel()
  log(bWriteLog and "WardrobeVehicle:CloseFeaturePanel  ")
  if self.widgetDetailComponent then
    self.widgetDetailComponent:Close()
    self.widgetDetailComponent = nil
  end
end
function WardrobeVehicle:OnRefreshVehicleType(widget, vehicleTypeID)
  log(bWriteLog and "WardrobeVehicle:OnRefreshVehicleType")
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  widget.Reddot_Anchor:ShowRedPointByPath(wardrobe_red_point.C_Wardrobe_RedPoint_Style)
  local vehicleType = wardrobe_red_point:GetVehicleType(tonumber(vehicleTypeID))
  if vehicleType then
    vehicleType:RegisterWidget(widget.Reddot_Anchor)
  end
  self:SetVehicleName(widget, vehicleTypeID)
end
function WardrobeVehicle:OnSelectVehicleType(widget, vehicleTypeID)
  log(bWriteLog and "WardrobeVehicle:OnSelectVehicleType" .. tostring(vehicleTypeID))
  self:PlayAudio(sound_config.click_v1)
  local vehicleName = self:GetTabStringByID(vehicleTypeID)
  if vehicleName ~= nil then
    widget.TextBlock_ItemName:SetText(vehicleName)
  end
  self:CheckCleanTagSelectAndRefresh()
  self:CloseFeaturePanel()
  self.curSelectVehicleType = vehicleTypeID
  self:ChangeVehicleType(vehicleTypeID)
end
function WardrobeVehicle:ChangeVehicleType(selectVehicleType)
  log(bWriteLog and "WardrobeVehicle:ChangeVehicleType")
  local vehicleData = self:GetVehicles(selectVehicleType)
  if not vehicleData then
    return
  end
  self.vehicleList = {}
  for _, v in pairs(vehicleData) do
    table.insert(self.vehicleList, v)
  end
  self:SetVehicleList(self.vehicleList)
  self:ChoiceVehicleTab(nil, 1)
end
function WardrobeVehicle:RefreshVehicleTypeComboBox()
  log(bWriteLog and "WardrobeVehicle:InitVehicleList")
  local defaultSelection = 1
  local vehicleList = {}
  for vehicleType, _ in pairs(self.vehicleCategory) do
    table.insert(vehicleList, vehicleType)
  end
  self.VehicleComboBox:SetData(vehicleList, defaultSelection)
end
function WardrobeVehicle:InitVehicleList()
  log(bWriteLog and "WardrobeVehicle:InitVehicleList")
  self.UIRoot.HorizontalBox_Pendant:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local VehicleTable = CDataTable.GetTable("WardrobeVehiclesTaxonomy")
  for k, v in pairs(VehicleTable) do
    if v.VehicleDefualtSkinID == DataMgr.defaultWingmanSkinResID then
    else
      self:SetVehicles(v.CategoryID, v.VehicleCategory, v)
      local tabData = self:GetEquipTab(v.WardrobeTab)
      if tabData then
        self:AddDataListener(tabData, "instanceID", self.RefreshTabIcon, self)
      end
    end
  end
  self:SortVehicleTab()
  self:UpdateTabItemCount()
end
function WardrobeVehicle:InitVehicleSkin(vehicleData, index)
  log(bWriteLog and "WardrobeVehicle:InitVehicleSkin")
  if not vehicleData then
    return
  end
  local tabID = vehicleData.WardrobeTab
  local pageID = Vehicle
  local isUsing, itemInfo
  local skinItemList = {}
  local depotItemList = self:GetArrayHallDepotItemInfo()
  local equippedSkinInsID = TabSurveillance.GetEquipStates(tabID)
  local item = WardrobeDataManager:GetHallDepotItemDataByInsID(equippedSkinInsID)
  log(bWriteLog and "InitVehicleSkin tabID" .. tostring(tabID))
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(depotItemList) do
    if WardrobeLogicManager:IsValidCurrentPageItem(pageID, tabID, v, serverTime) then
      isUsing = DataMgr.vst_skin and DataMgr.vst_skin == v.insID
      itemInfo = WardrobeLogicManager:ArrayHallDepotToCommonItem(v, #skinItemList, isUsing, false, false, false, false)
      local bIsFreeze = item and item.lock_cnt and item.lock_cnt > 0
      local bSlot, _index = self:IsOnSlotSkinList(itemInfo)
      if bSlot and not bIsFreeze then
        self.curPutOnInsId = _index == 1 and itemInfo.ins_id or self.curPutOnInsId
        itemInfo.isUsing = true
      else
        itemInfo.isUsing = false
      end
      log_tree("InitVehicleSkin itemInfo", itemInfo)
      if itemInfo.res_id ~= WardrobeMacro.DefaultVehiclesId[itemInfo.itemSubType] then
        table.insert(skinItemList, itemInfo)
      else
        self.DefaultVehicleInsId[itemInfo.itemSubType] = v.insID
      end
    end
  end
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if item then
    local bIsFreeze = false
    for _, value in pairs(skinItemList) do
      if item.resID == value.res_id then
        bIsFreeze = value.lock_cnt and value.lock_cnt > 0
        break
      end
    end
    local itemData = self.LoopScrollGridVehicles:GetItemData(index)
    if bIsFreeze and itemData then
      self:ShowVehicleInfo(item.insID, itemData.VehicleDefualtSkinID, item.itemSubType)
    else
      self:ShowVehicleInfo(item.insID, item.resID, item.itemSubType)
    end
    local resId = item.resID
    local sceneLoaded = vehicleSceneLoaded
    local insID = item.insID
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local source = insID and wardrobe_data:GetItemSource(insID) or EWardrobeDataSource.Wardrobe
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, resId, nil, function()
      if sceneLoaded then
        logic_wardrobe_new:ShowVehicleModel(resId, source)
      end
    end)
  end
  self.AllItemList = skinItemList
  self:SetInitItemList(self.AllItemList)
  self.LoopScrollBox_Tags:RefreshAllItems()
  if self.UIRoot.WidgetSwitcher_Search then
    skinItemList = self:DoSearch(skinItemList, WardrobeLogicManager:GetSearchString())
  end
  if self.bShowTagFilter then
    skinItemList = self:DoFilterTags(skinItemList)
  end
  skinItemList = self:FilterMultiItem(skinItemList)
  local SortPreference = WardrobeLogicManager:GetSortPreference(self)
  WardrobeLogicManager:SortItemTable(skinItemList, SortPreference)
  if skinItemList == nil or next(skinItemList) == nil then
    self:ShowEmptyGunSkinList(true)
  else
    self:ShowEmptyGunSkinList(false)
  end
  self:SetVehicleSkins(skinItemList)
  self:RefreshSwitchPanel()
end
function WardrobeVehicle:ShowEmptyGunSkinList(show)
  if show then
    self.UIRoot.WidgetSwitcher_Wardrobe_Empty:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_Wardrobe_Empty:SetWidgetVisibility(SelfHitTestInvisible)
  else
    self.UIRoot.WidgetSwitcher_Wardrobe_Empty:SetWidgetVisibility(Collapsed)
  end
end
function WardrobeVehicle:OnClickGunListItem(widget, index, itemUI)
  log(bWriteLog and "WardrobeVehicle:OnClickedVehicleTab")
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.WardrobeVehicleTab) then
    return
  end
  self:PlayAudio(sound_config.subTab_v1)
  self.LoopScrollGridVehicles:Select(index)
  self:CheckCleanTagSelectAndRefresh()
  self:CloseFeaturePanel()
  local vehicleData = self:GetVehicleList(index)
  if not vehicleData then
    return
  end
  local itemID = self:GetItemIDByVehocleData(vehicleData)
  self:InitVehicleSkin(vehicleData, index)
  local itemData = self.LoopScrollGridVehicles:GetItemData(index)
  local data = self:GetItemInfo(itemID)
  local bIsFreeze = data.lock_cnt and data.lock_cnt > 0
  if bIsFreeze then
    itemID = itemData.VehicleDefualtSkinID
  end
  WardrobeLogicManager:EnterVehicleSceneByItemID(itemID)
  self:InitVehicleSlotSkin(vehicleData)
  local insid = self:GetInsIDByVehocleData(vehicleData)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local depotItemData = wardrobe_data:GetHallDepotItemDataByInsID(insid)
  if not insid or insid == 0 or not depotItemData then
    log("WardrobeVehicle:OnClickGunListItem insid is invalid, use default skin insid")
    local defaultItemData = wardrobe_data:GetHallDepotItemDataByResID(itemData.VehicleDefualtSkinID)
    if defaultItemData and defaultItemData.insID then
      insid = defaultItemData.insID
      log("WardrobeVehicle:OnClickGunListItem use default skin insid: " .. tostring(insid))
    end
  end
  if not bIsFreeze then
    WardrobeLogicManager:wardrobe_puton_req(insid, {bFromVehicleType = true})
  end
  WardrobeLogicManager:SetCurrentTabId(vehicleData.WardrobeTab)
  self:RefreshVehicleProficiency(vehicleData)
end
function WardrobeVehicle:ChoiceVehicleTab(widget, index)
  log(bWriteLog and "WardrobeVehicle:ChoiceVehicleTab")
  self:PlayAudio(sound_config.subTab_v1)
  local vehicleData = self:GetVehicleList(index)
  local itemID = self:GetItemIDByVehocleData(vehicleData)
  self:InitVehicleSkin(vehicleData, index)
  local itemData = self.LoopScrollGridVehicles:GetItemData(index)
  local data = self:GetItemInfo(itemID)
  local bIsFreeze = data.lock_cnt and data.lock_cnt > 0
  if bIsFreeze then
    itemID = itemData.VehicleDefualtSkinID
  end
  WardrobeLogicManager:EnterVehicleSceneByItemID(itemID)
  self:InitVehicleSlotSkin(vehicleData)
  WardrobeLogicManager:SetCurrentTabId(vehicleData.WardrobeTab)
  self.LoopScrollGridVehicles:Select(index)
  self:RefreshVehicleProficiency(vehicleData)
end
function WardrobeVehicle:OnClickItem(widget, index)
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.WardrobeVehicleItem) then
    return
  end
  log(bWriteLog and "WardrobeVehicle:OnClickItem")
  WardrobeVehicle.__super.OnClickItem(self, widget, index)
  local itemData = self.LoopScrollGridSkins:GetItemData(index)
  if itemData and itemData.lock_cnt and itemData.lock_cnt > 0 then
    ShowNotice(3000016)
    return
  end
  local vehicleSkin = self:GetVehicleSkins(index)
  log(bWriteLog and "WardrobeVehicle:OnClickItem vehicleSkin " .. tostring(vehicleSkin))
  self:ClickItem(vehicleSkin)
end
function WardrobeVehicle:ClickItem(vehicleSkin, bForceUsing)
  if not vehicleSkin then
    log_error("[WardrobeMultiItem] WardrobeVehicle ClickItem vehicleSkin is nil ")
    return
  end
  local itemID = vehicleSkin.res_id
  log_tree("WardrobeVehicle:ClickItem vehicleSkin", vehicleSkin)
  local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
  local needWear = golden_suit_module:VehicleNeedClothes(itemID)
  if needWear ~= 0 then
    local itemData = CDataTable.GetTableData("Item", needWear)
    local word = LocUtil.LocalizeResFormat(774799, itemData.ItemName)
    ShowNotice(word)
    self:ShowVehicleInfo(vehicleSkin.ins_id, itemID, vehicleSkin.itemSubType)
    return
  end
  local sub_tab_buttons_mgr = require("client.slua.umg.Wardrobe.sub_tab_buttons_mgr")
  sub_tab_buttons_mgr:HideChangeViewButton()
  local sub_tab_supercar_buttons_mgr = require("client.slua.umg.Wardrobe.sub_tab_supercar_buttons_mgr")
  sub_tab_supercar_buttons_mgr:HideDoorViewButtons()
  if vehicleSkin.ins_id ~= self.curPutOnInsId then
    vehicleSkin.isUsing = false
  end
  if not bForceUsing and vehicleSkin.isUsing == true then
    itemID = WardrobeMacro.DefaultVehiclesId[vehicleSkin.itemSubType]
    local DefalutCarInsId = self.DefaultVehicleInsId[vehicleSkin.itemSubType]
    if not DefalutCarInsId then
      log_tree("WardrobeVehicle:ClickItem not DefalutCarInsId", self.DefaultVehicleInsId)
      local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      DefalutCarInsId = wardrobeLogic:GetWardrobeInsIdByResId(itemID)
      self.DefaultVehicleInsId[vehicleSkin.itemSubType] = DefalutCarInsId
    end
    WardrobeLogicManager:EnterVehicleSceneByItemID(itemID)
    self:ShowVehicleInfo(DefalutCarInsId, itemID, vehicleSkin.itemSubType)
    WardrobeLogicManager:wardrobe_puton_req(DefalutCarInsId)
    self:UnEquipSlotVehicle(vehicleSkin.ins_id, 1)
    return
  end
  if not DataMgr.IsValidTime(vehicleSkin.expireTS) then
    ShowNotice(9910101)
    return
  end
  WardrobeLogicManager:EnterVehicleSceneByItemID(itemID)
  self:ShowVehicleInfo(vehicleSkin.ins_id, itemID, vehicleSkin.itemSubType)
  if not WardrobeLogicManager:IsCanUse(itemID) then
    ShowNotice(4987)
    return
  end
  WardrobeLogicManager:wardrobe_puton_req(vehicleSkin.ins_id)
end
function WardrobeVehicle:HandleVehicleView(itemID)
  self:AddTimerOnce(0, function()
    local sub_tab_buttons_mgr = require("client.slua.umg.Wardrobe.sub_tab_buttons_mgr")
    sub_tab_buttons_mgr:ToggleChangeViewBtnDisplayByCarID(itemID)
  end)
end
function WardrobeVehicle:HandleSuperCarDoor(itemID)
  self:AddTimerOnce(0, function()
    local sub_tab_supercar_buttons_mgr = require("client.slua.umg.Wardrobe.sub_tab_supercar_buttons_mgr")
    sub_tab_supercar_buttons_mgr:ToggleDoorBtnDisplayByCarID(itemID)
  end)
end
function WardrobeVehicle:HandleCabrioletBtn(itemID)
  self:AddTimerOnce(0, function()
    local sub_tab_buttons_mgr = require("client.slua.umg.Wardrobe.sub_tab_buttons_mgr")
    sub_tab_buttons_mgr:CheckShowVehicleCabrioletButton(itemID)
  end)
end
function WardrobeVehicle:OnRefreshGunListItem(widget, index, itemUI)
  log(bWriteLog and "WardrobeVehicle:OnRefreshVehicles")
  local vehicle = self:GetVehicleList(index)
  if vehicle then
    local root = widget.Wardrobe_GunTypeItem_UIBP
    local icon = root.Image_Wardrobe_GunLogo
    local select = root.Image_Try
    self:SetWidgetVisible(select, index == self.LoopScrollGridVehicles:GetSelectIndex())
    local equippedSkinInsID = TabSurveillance.GetEquipStates(vehicle.WardrobeTab)
    local item = WardrobeDataManager:GetHallDepotItemDataByInsID(equippedSkinInsID)
    if equippedSkinInsID == tonumber(DataMgr.vst_skin) then
      root.Image_Using:SetWidgetVisibility(Visible)
    else
      root.Image_Using:SetWidgetVisibility(Collapsed)
    end
    local UIUtil = require("client.common.ui_util")
    if item then
      local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
      local tCarData = wardrobe_data:GetHallDepotItemDataByResID(item.resID)
      local bIsFreeze = tCarData and tCarData.lock_cnt and tCarData.lock_cnt > 0
      if bIsFreeze then
        local smallIcon, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(vehicle.VehicleDefualtSkinID, icon)
        local params = {sync = false, bHasAddKnownMissing = bHasAddKnownMissing}
        self:SetTexture(icon, smallIcon, params)
      else
        local smallIcon, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(item.resID, icon)
        local params = {sync = false, bHasAddKnownMissing = bHasAddKnownMissing}
        self:SetTexture(icon, smallIcon, params)
      end
    else
      local ItemID = vehicle.VehicleDefualtSkinID
      if ItemID then
        log(bWriteLog and "WardrobeVehicle:UseDefaultVehicle ItemID" .. tostring(ItemID))
        local smallIcon, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(ItemID, icon)
        local params = {sync = false, bHasAddKnownMissing = bHasAddKnownMissing}
        self:SetTexture(icon, smallIcon, params)
      end
      log(bWriteLog and "WardrobeVehicle:OnRefreshVehicles " .. tostring(index) .. "equippedSkinInsID " .. tostring(equippedSkinInsID))
    end
    local cnt = self:CountDistinctItemOfSubTab(vehicle)
    if 0 < cnt then
      root.TextBlock_0:SetText(tostring(cnt))
    else
      root.TextBlock_0:SetText("")
    end
    root.TextBlock_Wardrobe_GunLogo:SetWidgetVisibility(Collapsed)
    local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
    root.Reddot_Anchor:ShowRedPointByPath(wardrobe_red_point.C_Wardrobe_RedPoint_Style)
    local vehicleType = wardrobe_red_point:GetTab(vehicle.WardrobeTab)
    if vehicleType then
      vehicleType:RegisterWidget(root.Reddot_Anchor)
    end
    if item then
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local common_download_handler = require("client.slua.common.common_download_handler")
      local downloadID = item.resID
      local baseResID = CDataTable.GetTableData("VehiclePlaneSkinMapping", downloadID)
      if baseResID ~= 0 then
        downloadID = baseResID.OrginalID
      end
      common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.ODPAK, {downloadID}, itemUI, widget.Panel_Download, {bShowIconOnly = true})
    end
  end
end
function WardrobeVehicle:RefreshVehicleProficiency(vehicleInfo)
  local vehicleId = vehicleInfo.VehicleDefualtSkinID
  local careerSystem = require("client.slua.logic.career.logic_career")
  local careerSystemvehicle = require("client.slua.logic.career.logicCareerVehicle")
  local careerSystemSwitch = careerSystem.IsOpen()
  if not careerSystemSwitch then
    return
  end
  self.UIRoot.Node_ProValue:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local proficiency = careerSystemvehicle.GetVehicleProData(vehicleId) or 0
  local VehicleTypeTable = CDataTable.GetTable("CareerVehicleConfig")
  if not (VehicleTypeTable and VehicleTypeTable[vehicleId]) or not VehicleTypeTable[vehicleId].name then
    return
  end
  local vehicleName = VehicleTypeTable[vehicleId].name
  self.UIRoot.TextProficiency:SetText(LocUtil.LocalizeResFormat(24837, vehicleName, proficiency))
end
function WardrobeVehicle:OnRefreshVehicleSkin(widget, index)
  log(bWriteLog and "WardrobeVehicle:OnRefreshVehicleSkin")
  local itemData = self:GetVehicleSkins(index)
  if itemData then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    itemData.isSelected = index == self.LoopScrollGridSkins:GetSelectIndex()
    if itemData.isSelected then
      widget:SetRenderScale(FVector2D(1.05, 1.05))
    else
      widget:SetRenderScale(FVector2D(1, 1))
    end
    WardrobeVehicle.__super.InitView(self, widget, itemData, index)
    self:SetIconAlpha(widget, 1)
    local tCarData = wardrobe_data:GetHallDepotItemDataByResID(itemData.res_id)
    local bIsFreeze = tCarData and tCarData.lock_cnt and tCarData.lock_cnt > 0
    local bSlot = self:IsOnSlotSkinList(itemData)
    if bSlot and not bIsFreeze then
      widget:SetUsingState(true)
    else
      widget:SetUsingState(false)
    end
    widget:SetIsShowExclusivePng(false)
  end
  local DragDropItem = widget.Common_DragDrop_Item
  DragDropItem:SetDragEnable(true)
  if itemData then
    DragDropItem:RegisterDrag(1, 0, 0, itemData.ins_id)
  end
  DragDropItem:SetEnable(true)
end
function WardrobeVehicle:IsOnSlotSkinList(itemData)
  if DataMgr.VehicleSlotList and DataMgr.VehicleSlotList[itemData.itemSubType] then
    for index, insId in pairs(DataMgr.VehicleSlotList[itemData.itemSubType]) do
      if insId == tonumber(itemData.ins_id) then
        return true, index
      end
    end
  end
end
function WardrobeVehicle:IsOnSlotSkinListByInsID(InsID)
  if not InsID then
    return false
  end
  if DataMgr.VehicleSlotList and DataMgr.VehicleSlotList[itemData.itemSubType] then
    for _, insId in pairs(DataMgr.VehicleSlotList[itemData.itemSubType]) do
      if insId == tonumber(itemData.ins_id) then
        return true
      end
    end
  end
end
function WardrobeVehicle:OnWardrobeDataChange(eventType, eventID)
  local vehicleData = self:GetVehicleList(self.LoopScrollGridVehicles:GetSelectIndex())
  self:InitVehicleSkin(vehicleData)
  self:InitVehicleSlotSkin(vehicleData)
end
function WardrobeVehicle:OnSlotSkinDataChange()
  local vehicleData = self:GetVehicleList(self.LoopScrollGridVehicles:GetSelectIndex())
  self:InitVehicleSlotSkin(vehicleData)
  self.LoopScrollGridSkins:RefreshAllItems()
end
function WardrobeVehicle:RefreshTabIcon(oldInsID, insID)
  log(bWriteLog and "WardrobeVehicle:RefreshTabIcon")
  self.LoopScrollGridVehicles:RefreshAllItems()
end
function WardrobeVehicle:ChangeItemStatusByInsID(itemInsID, status, Type)
  local itemCount = self:GetSkinCount()
  for i = 1, itemCount do
    local data = self:GetVehicleSkins(i)
    if data.ins_id == itemInsID then
      data[Type] = status
      self:RefreshSkin(i, data)
      break
    end
  end
end
function WardrobeVehicle:OnUpdatePutOnData(eventType, eventID, putOnItem, putDownItem)
  self.curPutOnInsId = nil
  if putDownItem ~= nil then
    self:ChangeItemStatusByInsID(putDownItem.instid, false, "isUsing")
  end
  if putOnItem ~= nil then
    self.curPutOnInsId = putOnItem.instid
    self:RefreshSwitchPanel(putOnItem.res_id)
    self:RefreshMultiItem(putOnItem.res_id)
    self:ChangeItemStatusByInsID(putOnItem.instid, true, "isUsing")
    self:RefreshTabIcon()
  end
end
function WardrobeVehicle:SetVehicles(vehicleTypeID, vehicleTypeName, vehicleData)
  local vehicleList = self:GetVehicles(vehicleTypeID)
  if vehicleList == nil then
    vehicleList = {}
    self.TabItemCount[vehicleTypeID] = {}
    self.vehicleCategory[vehicleTypeID] = vehicleList
    self.TypeStringToID[vehicleTypeName] = vehicleTypeID
    self.TypeIDToString[vehicleTypeID] = vehicleTypeName
  end
  table.insert(vehicleList, vehicleData)
  self.TabItemCount[vehicleTypeID][vehicleData.WardrobeTab] = 0
end
function WardrobeVehicle:GetEquipTab(tabID)
  return TabSurveillance.GetTabEquip(tabID)
end
function WardrobeVehicle:GetSkinCount()
  return self.LoopScrollGridSkins:GetItemCount()
end
function WardrobeVehicle:RefreshSkin(index, data)
  log_tree("WardrobeVehicle RefreshSkin data", data)
  self.LoopScrollGridSkins:RefreshItem(index, data)
end
function WardrobeVehicle:ClearVehicleSkins()
  self.LoopScrollGridSkins:SetData({})
end
function WardrobeVehicle:SetVehicleSkins(skinTable)
  log_tree("WardrobeVehicle:SetVehicleSkins skinTable", skinTable)
  self.LoopScrollGridSkins:SetData(skinTable)
end
function WardrobeVehicle:GetVehicleSkins(index)
  return self.LoopScrollGridSkins:GetItemData(index)
end
function WardrobeVehicle:GetVehicleSlotSkins(index)
  return self.LoopScrollBox_0:GetItemData(index)
end
function WardrobeVehicle:SetVehicleSlotSkins(skinItemList)
  for _ = 1, SlotNum - #skinItemList do
    table.insert(skinItemList, {})
  end
  self.LoopScrollBox_0:SetData(skinItemList)
end
function WardrobeVehicle:ClearVehicleList()
  self.LoopScrollGridVehicles:SetData({})
end
function WardrobeVehicle:SetVehicleList(vehiclesTable)
  self.LoopScrollGridVehicles:SetData(vehiclesTable)
end
function WardrobeVehicle:GetVehicleList(index)
  return self.LoopScrollGridVehicles:GetItemData(index)
end
function WardrobeVehicle:GetTabStringByID(vehicleTypeID)
  return LocUtil.GetLocalizeResStr(self.TypeIDToString[tonumber(vehicleTypeID)])
end
function WardrobeVehicle:GetIDByTabString(vehicleTypeTabString)
  return self.TypeStringToID[vehicleTypeTabString]
end
function WardrobeVehicle:GetVehicles(vehicleTypeID)
  return self.vehicleCategory[tonumber(vehicleTypeID)]
end
function WardrobeVehicle:SortVehicleTab()
  local sortFunc = function(a, b)
    if a.CategoryID ~= b.CategoryID then
      return a.CategoryID < b.CategoryID
    end
    return a.ItemSubType < b.ItemSubType
  end
  for _, v in pairs(self.vehicleCategory) do
    table.sort(v, sortFunc)
  end
end
function WardrobeVehicle:ShowVehicleInfo(skinInsID, skinResID, itemSubType)
  log(bWriteLog and "WardrobeVehicle:ShowVehicleInfo skinResID = " .. tostring(skinResID))
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local source = wardrobe_data:GetItemSource(skinInsID) or EWardrobeDataSource.Wardrobe
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  if skinResID ~= WardrobeMacro.DefaultVehiclesId[itemSubType] and self:GetDataSource() == source then
    tipsMgr:Show(tipsMgr.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, skinInsID, skinResID)
  else
    tipsMgr:Hide()
  end
  self:CloseFeaturePanel()
  showVehicleId = skinResID
  showVehicleItemSource = source
  if vehicleSceneLoaded == true then
    WardrobeLogicManager:ShowVehicleModel(skinResID, source)
    local LadderCarDetailConfig = require("client.slua.logic.lobby_activity.LadderCarDetailConfig")
    self:OnSportsCarFeatureUpdate(showVehicleId, LadderCarDetailConfig.IsRareCar(showVehicleId))
  end
end
function WardrobeVehicle:OnModelReady(_, __, ID)
  log(bWriteLog and "WardrobeDataManager.OnModelReady" .. tostring(ID))
  if ID and ID == showVehicleId then
    self:HandleVehicleView(ID)
    self:HandleSuperCarDoor(ID)
    self:HandleCabrioletBtn(ID)
  end
end
function WardrobeVehicle:OnVehicleSceneLoaded(eventType, eventID, sceneName)
  if sceneName == LobbySceneManager.LEVEL_NAME.GARAGE or sceneName == LobbySceneManager.LEVEL_NAME.SUPERCAR then
    vehicleSceneLoaded = true
    log(bWriteLog and "WardrobeVehicle.OnVehicleSceneLoaded: " .. sceneName .. tostring(showVehicleId))
    local LadderCarDetailConfig = require("client.slua.logic.lobby_activity.LadderCarDetailConfig")
    WardrobeLogicManager:ShowVehicleModel(showVehicleId, showVehicleItemSource)
    self:OnSportsCarFeatureUpdate(showVehicleId, LadderCarDetailConfig.IsRareCar(showVehicleId))
  end
end
function WardrobeVehicle:CountDistinctItemOfSubTab(vehicleData)
  local tabID = vehicleData.WardrobeTab
  for _, vehicleSubTabList in pairs(self.TabItemCount) do
    if vehicleSubTabList[tabID] then
      return vehicleSubTabList[tabID]
    end
  end
  return 0
end
function WardrobeVehicle:SetVehicleName(widget, vehicleTypeID)
  local vehicleName = self:GetTabStringByID(vehicleTypeID)
  if vehicleName ~= nil then
    local cnt = 0
    for _, v in pairs(self.TabItemCount[tonumber(vehicleTypeID)]) do
      cnt = cnt + v
    end
    if 0 < cnt then
      widget.TextBlock_ItemName:SetText(string.format("%s (%d)", vehicleName, cnt))
    else
      widget.TextBlock_ItemName:SetText(vehicleName)
    end
  end
end
function WardrobeVehicle:UpdateTabItemCount()
  local depotItemList = self:GetArrayHallDepotItemInfo()
  local pageID = Vehicle
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for k, v in pairs(depotItemList) do
    for vehicleTypeID, vehicleSubTabList in pairs(self.TabItemCount) do
      if v.mainTabType == pageID and vehicleSubTabList[v.subTabType] and (v.expireTS == 0 or serverTime < v.expireTS) and not self:CheckDefault(v) and not self:CheckIsHighLevelItem(v.resID) then
        vehicleSubTabList[v.subTabType] = vehicleSubTabList[v.subTabType] + 1
      end
    end
  end
end
function WardrobeVehicle:CheckDefault(item)
  local defaultTb = CDataTable.GetTableDataByFilter("DefaultItem", "id", item.resID)
  return defaultTb ~= nil
end
function WardrobeVehicle:CheckIsHighLevelItem(ItemID)
  if not GetLogicMultiItemModule():IsWardRobeMultiLevelItem(ItemID) then
    return false
  end
  local level = GetLogicMultiItemModule():GetMultiItemLevel(ItemID)
  if 1 < level then
    return true
  end
  return false
end
function WardrobeVehicle:GetItemIDByFristTab()
  if not self.vehicleCategory or not next(self.vehicleCategory) then
    return 0
  end
  for _, vehicleTabData in pairs(self.vehicleCategory) do
    if vehicleTabData and next(vehicleTabData) then
      for _, vehicleData in pairs(vehicleTabData) do
        return self:GetItemIDByVehocleData(vehicleData) or 0
      end
      return 0
    end
  end
  return 0
end
function WardrobeVehicle:GetItemIDByVehocleData(vehicleData)
  if not vehicleData then
    return nil
  end
  local tabID = vehicleData.WardrobeTab
  local equippedSkinInsID = TabSurveillance.GetEquipStates(tabID)
  local item = WardrobeDataManager:GetHallDepotItemDataByInsID(equippedSkinInsID) or {}
  return item.resID
end
function WardrobeVehicle:GetInsIDByVehocleData(vehicleData)
  if not vehicleData then
    return nil
  end
  local tabID = vehicleData.WardrobeTab
  local equippedSkinInsID = TabSurveillance.GetEquipStates(tabID)
  return equippedSkinInsID
end
function WardrobeVehicle:InitVehicleSlotSkin(vehicleData)
  log(bWriteLog and "WardrobeVehicle:InitVehicleSlotSkin")
  if not vehicleData then
    return
  end
  local itemInfo
  local skinSlotItemList = {}
  local currentSlotSkin = {}
  if DataMgr.VehicleSlotList then
    currentSlotSkin = DataMgr.VehicleSlotList[vehicleData.ItemSubType]
  end
  if currentSlotSkin and next(currentSlotSkin) then
    for _, value in pairs(currentSlotSkin) do
      local data = WardrobeDataManager:GetHallDepotItemDataByInsID(value)
      if data then
        itemInfo = WardrobeLogicManager:ArrayHallDepotToCommonItem(data, #skinSlotItemList, false, false, false, false, false)
        if not itemInfo.lock_cnt or itemInfo.lock_cnt == 0 then
          table.insert(skinSlotItemList, itemInfo)
        end
      end
    end
  end
  self:SetVehicleSlotSkins(skinSlotItemList)
end
function WardrobeVehicle:OnRefreshVehicleSlotItem(widget, index)
  log(bWriteLog and "WardrobeVehicle:OnRefreshVehicleSlotItem")
  local DragDropItem = widget.Common_DragDrop_Item
  local itemData = self:GetVehicleSlotSkins(index)
  local node_commonItem = widget
  if itemData and next(itemData) then
    itemData.extra = itemData.extra or {}
    itemData.extra.bIsSkipDownload = true
    WardrobeVehicle.__super.InitView(self, widget, itemData, index, true)
    node_commonItem:SetSpecialIconShow(false)
    self:SetIconAlpha(widget, 1)
    DragDropItem:SetDragEnable(true)
    DragDropItem:RegisterDrag(1, 0, 0, itemData.ins_id)
  else
    DragDropItem:SetDragEnable(false)
    DragDropItem:RegisterDrag(1, 0, 0, "")
    node_commonItem:HideItem()
  end
  DragDropItem:SetEnable(true)
  DragDropItem:RegisterDrop(1)
end
function WardrobeVehicle:InitSlotItemView(widget, index, VehicleData, isPutOnVehicle)
  local actionResID = VehicleData.resID or VehicleData.res_id
  local itemCfg = CDataTable.GetTableData("Item", actionResID)
  local icon = widget.targetUI.Image_Wardrobe_CarLogo
  if itemCfg then
    self:SetTexture(icon, itemCfg.ItemBigIcon, {sync = false})
    icon:SetWidgetVisibility(SelfHitTestInvisible)
  end
end
function WardrobeVehicle:OnVehicleDragReadyToShape(DragWidget, Index, GeneratedWidget, DragDropData)
  log(bWriteLog and "WardrobeVehicle OnVehicleDragReadyToShape")
  local VehicleData = self:GetVehicleSkins(Index)
  self:InitDragWidget(GeneratedWidget, VehicleData)
  self:BeginVehicleDragHint(1)
end
function WardrobeVehicle:BeginVehicleDragHint(selection)
  log(bWriteLog and "WardrobeVehicle BeginVehicleDragHint")
  local logic_SuperCar_200Version = require("client.maps.logic_SuperCar_200Version")
  logic_SuperCar_200Version.SetSpringArmCamCanTouchRotate(false)
  local widgetSwitcherDrag = self.UIRoot.WidgetSwitcher_SkinDrag
  widgetSwitcherDrag:SetWidgetVisibility(SelfHitTestInvisible)
  widgetSwitcherDrag:SetActiveWidgetIndex(selection)
end
function WardrobeVehicle:EndVehicleDragHint()
  log(bWriteLog and "WardrobeVehicle EndVehicleDragHint")
  local logic_SuperCar_200Version = require("client.maps.logic_SuperCar_200Version")
  logic_SuperCar_200Version.SetSpringArmCamCanTouchRotate(true)
  local widgetSwitcherDrag = self.UIRoot.WidgetSwitcher_SkinDrag
  widgetSwitcherDrag:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
end
function WardrobeVehicle:InitDragWidget(widget, VehicleData)
  local icon = widget.Image_Icon
  local actionResID = VehicleData.resID or VehicleData.res_id
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemCfg = CDataTable.GetTableData("Item", actionResID)
  if itemCfg then
    local UIUtil = require("client.common.ui_util")
    local smallIcon, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(actionResID, icon)
    local params = {sync = false, bHasAddKnownMissing = bHasAddKnownMissing}
    self:SetTexture(icon, smallIcon, params)
    icon:SetWidgetVisibility(SelfHitTestInvisible)
  end
end
function WardrobeVehicle:OnVehicleDragCanceled()
  log(bWriteLog and "WardrobeVehicle OnVehicleDragCanceled")
  self:EndVehicleDragHint()
end
function WardrobeVehicle:OnVehicleSlotDrag(DragWidget, Index, GeneratedWidget, DragDropData)
  log(bWriteLog and "WardrobeVehicle OnVehicleSlotDrag")
  local VehicleData = self:GetVehicleSlotSkins(Index)
  self:InitDragWidget(GeneratedWidget, VehicleData)
  self:BeginVehicleDragHint(0)
end
function WardrobeVehicle:OnVehicleSlotDrop(DragWidget, Index, DragDropData)
  log(bWriteLog and "WardrobeVehicle:OnVehicleSlotDrop")
  self:PlayAudio(sound_config.click_v1)
  self:EndVehicleDragHint()
  local dragVehicleInsID = tonumber(DragDropData.dragExtendData)
  local DataEntity = self:GetDataEntity()
  local VehicleData = DataEntity:GetDataByInsID(dragVehicleInsID)
  if not VehicleData then
    return
  end
  if VehicleData and not DataMgr.IsValidTime(VehicleData.expireTS) then
    ShowNotice(9910101)
    return
  end
  local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
  local needWear = golden_suit_module:VehicleNeedClothes(VehicleData.resID)
  if needWear ~= 0 then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = CDataTable.GetTableData("Item", needWear)
    local word = LocUtil.LocalizeResFormat(774799, itemData.ItemName)
    ShowNotice(word)
    return
  end
  self:EquipSlotVehicle(dragVehicleInsID, Index)
end
function WardrobeVehicle:EquipSlotVehicle(dragVehicleInsID, Index)
  local WardrobeNewHandler = require("client.network.Protocol.WardrobeNewHandler")
  WardrobeNewHandler.send_depot_modify_combat_vehicle_req(tonumber(dragVehicleInsID), Index, true)
end
function WardrobeVehicle:UnEquipSlotVehicle(dragVehicleInsID, Index)
  local WardrobeNewHandler = require("client.network.Protocol.WardrobeNewHandler")
  WardrobeNewHandler.send_depot_modify_combat_vehicle_req(tonumber(dragVehicleInsID), Index, false)
end
function WardrobeVehicle:OnVehicleSlotRemove(DragWidget, Index, DragDropData)
  self:EndVehicleDragHint()
  local data = self:GetVehicleSlotSkins(Index)
  self:UnEquipSlotVehicle(data.ins_id, Index)
  self:PlayAudio(sound_config.click_v1)
end
function WardrobeVehicle:OnClickCheckBox()
  self:PlayAudio(sound_config.toggle_v1)
  local isChecked = self.UIRoot.CheckBox_Sort:IsChecked()
  if isChecked then
    WardrobeLogicManager:SetSortPreference(self, true)
  else
    WardrobeLogicManager:SetSortPreference(self, false)
  end
  self:OnWardrobeDataChange()
end
function WardrobeVehicle:OnSelectSortItem(widget, data)
  self:PlayAudio(sound_config.click_v1)
  widget.TextBlock_ItemName:SetText(data.text)
  if data.type == self.ENUM_SORT_TYPE.LATEST then
    WardrobeLogicManager:SetSortPreference(self, true)
  else
    WardrobeLogicManager:SetSortPreference(self, false)
  end
  self:OnWardrobeDataChange()
end
function WardrobeVehicle:RefreshCheckBoxState()
  self.UIRoot.TextBlock_SortViaTime:SetText(LocUtil.LocalizeResFormat(34618))
  local SortPreference = WardrobeLogicManager:GetSortPreference(self)
  if SortPreference then
    self.UIRoot.CheckBox_Sort:SetCheckedState(1)
  else
    if SortPreference == nil then
      WardrobeLogicManager:SetSortPreference(self, false)
    end
    self.UIRoot.CheckBox_Sort:SetCheckedState(0)
  end
end
function WardrobeVehicle:OnClickButton_ShowTips()
  self:PlayAudio(sound_config.click_v1)
  local content = LocUtil.GetLocalizeResStr(33525)
  local title = LocUtil.GetLocalizeResStr(5077)
  UIManager.ShowUI(UIManager.UI_Config.HelpTip, 0, title, content)
end
function WardrobeVehicle:OnClickBaseLevel()
  self:PlayAudio(sound_config.click_v1)
  local ItemID = GetLogicMultiItemModule():GetItemID(self:GetCurrentSelectId(), 1)
  log(bWriteLog and "[WardrobeMultiItem] WardrobeVehicle OnClickBaseLevel ItemID" .. tostring(ItemID))
  local itemData = self:GetItemInfo(ItemID)
  if not itemData then
    log_error("[WardrobeMultiItem] HandleClickMultiBaseGlide Can`t find ItemID " .. tostring(ItemID))
    log_tree("[WardrobeMultiItem] self.AllItemList", self.AllItemList)
    return
  end
  self:ClickItem(itemData)
end
function WardrobeVehicle:OnClickHighLevel()
  self:PlayAudio(sound_config.click_v1)
  local ItemID = GetLogicMultiItemModule():GetItemID(self:GetCurrentSelectId(), 2)
  log(bWriteLog and "[WardrobeMultiItem] WardrobeVehicle OnClickHighLevel ItemID" .. tostring(ItemID))
  local itemData = self:GetItemInfo(ItemID)
  if not itemData or not next(itemData) then
    GetLogicMultiItemModule():ShowUnlockJumpTips(ItemID, self.UIRoot.Wardrobe_EventSpin_item_2)
    return
  end
  self:ClickItem(itemData)
end
function WardrobeVehicle:RefreshMultiItem(PutOnItemID)
  if not GetLogicMultiItemModule():IsWardRobeMultiLevelItem(PutOnItemID) then
    return
  end
  GetLogicMultiItemModule():UpdateSelectMultiItem(PutOnItemID)
  local ItemInfo = self:GetItemInfo(PutOnItemID)
  local Level1ID = GetLogicMultiItemModule():GetItemID(PutOnItemID, 1)
  local Level2ID = GetLogicMultiItemModule():GetItemID(PutOnItemID, 2)
  local itemCount = self.LoopScrollGrid_Normal:GetItemCount()
  for i = 1, itemCount do
    local data = self.LoopScrollGrid_Normal:GetItemData(i)
    if data.res_id == Level1ID or data.res_id == Level2ID then
      self.LoopScrollGrid_Normal:RefreshItem(i, ItemInfo)
    end
  end
end
function WardrobeVehicle:GetItemInfo(ItemID)
  local ItemInfo = {}
  for key, value in pairs(self.AllItemList) do
    if value.res_id == ItemID then
      ItemInfo = value
      break
    end
  end
  return ItemInfo
end
function WardrobeVehicle:InitLevelCanvas()
  self:SetWidgetVisible(self.UIRoot.Wardrobe_EventSpin_item_1.CanvasPanel_Lock, false, false)
  self.UIRoot.Wardrobe_EventSpin_item_1.WidgetSwitcher_Level:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:SetTexture(self.UIRoot.Wardrobe_EventSpin_item_1.Image_notUsing, "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_icon_Vehicle01_png.WH_icon_Vehicle01_png")
  self:SetTexture(self.UIRoot.Wardrobe_EventSpin_item_1.Image_using, "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_icon_Vehicle02_png.WH_icon_Vehicle02_png")
  self:SetTexture(self.UIRoot.Wardrobe_EventSpin_item_2.Image_notUsing, "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_icon_Vehicle03_png.WH_icon_Vehicle03_png")
  self:SetTexture(self.UIRoot.Wardrobe_EventSpin_item_2.Image_using, "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_icon_Vehicle04_png.WH_icon_Vehicle04_png")
end
function WardrobeVehicle:GetCurrentSelectId()
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
function WardrobeVehicle:NeedShowLevelSwitchCanvas(ItemID)
  if self:GetCurrentSelectId() == 0 then
    return false
  end
  return WardrobeVehicle.__super.NeedShowLevelSwitchCanvas(self, ItemID)
end
function WardrobeVehicle:OnDownloadFinish(_, _, eventData)
  log(bWriteLog and "WardrobeVehicle OnDownloadFinish " .. tostring(eventData and eventData.itemID) .. " self.ClickDownLoadItemID: " .. tostring(self.ClickDownLoadItemID))
  local LastClickDownLoadItemID = self.ClickDownLoadItemID
  WardrobeVehicle.__super.OnDownloadFinish(self, _, _, eventData)
  local DownloadItemID = eventData and eventData.itemID or 0
  if DownloadItemID == 0 or LastClickDownLoadItemID ~= DownloadItemID then
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {LastClickDownLoadItemID}) == PufferConst.ENUM_DownloadState.Done then
    local ItemDataList = self.LoopScrollGridSkins:GetSetData()
    if ItemDataList then
      for _, ItemData in pairs(ItemDataList) do
        if ItemData.res_id == LastClickDownLoadItemID then
          log(bWriteLog and "WardrobeVehicle OnDownloadFinish find item" .. tostring(eventData and eventData.itemID))
          self:ClickItem(ItemData, true)
          break
        end
      end
    end
  end
end
local class = require("class")
local normal_item_list = require("client.slua.umg.Wardrobe.subtab_item_list_base")
local Vehicles = class(normal_item_list, nil, WardrobeVehicle)
return Vehicles