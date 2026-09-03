local WardrobeGun = {}
local WardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local logic_wardrobe_gun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
local Weapon = WardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon
local Logic_Career = require("client.slua.logic.career.logic_career")
local Logic_Career_Weapon = require("client.slua.logic.career.logic_career_weapon")
local GetItemUpgradeMgr = function()
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  return ItemUpgradeMgr
end
local ENUM_Tab = {ENUM_Tab_Gun = 1, ENUM_Tab_Pendants = 2}
function WardrobeGun:ctor(_, _, args)
  self.CurrentGunType = 1
  self.CurrentGunID = 0
  self.  logic_wardrobe_gun:SetShareBagConfigGunID(0)
end
function WardrobeGun:OnInitialize()
  WardrobeGun.__super.OnInitialize(self)
  local tabList = {
    [ENUM_Tab.ENUM_Tab_Gun] = LocUtil.LocalizeResFormat(43523),
    [ENUM_Tab.ENUM_Tab_Pendants] = LocUtil.LocalizeResFormat(43524)
  }
  self.Common_Tab_BagMode = self:InitHorizontalLevelTwoTextTab(self.UIRoot.Common_Tab_BagMode)
  self.Common_Tab_BagMode:SetTabs(tabList, ENUM_Tab.ENUM_Tab_Gun)
  self.Common_Tab_BagMode:AddOnClickedCallback(self.OnClickHorizontalTabButton, self)
  self:RefreshCommonTab()
  self:RefreshShareBagTips()
  self.LoopScrollGrid_GunList = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_GunList, "client.slua.umg.Wardrobe.Item.Wardrobe_GunTypeItem_BP")
  self.LoopScrollGrid_Pendant = self:InitScrollBox(self.UIRoot.LoopScrollGrid_Pendant)
  self.LoopScrollGrid_Pendant:SetRefreshItemCallback(self.OnRefreshPendantList, self)
  self.UIRoot.Node_ProValue:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:RefreshSwitchPanel()
  if not GetItemUpgradeMgr().itemRefitUnlockList or not next(GetItemUpgradeMgr().itemRefitUnlockList) then
    GetItemUpgradeMgr():send_upgrade_query_refit_req()
  end
  self.LoopScrollGridShareSlot = self:InitScrollBox(self.UIRoot.LoopScrollGridShareSlot)
  self.LoopScrollGridShareSlot:AddItemWidgetChildEvent("CommonDragDropItem", "OnDragSuccess", self.OnShareSlotDrop, self)
  self.LoopScrollGridShareSlot:SetRefreshItemCallback(self.OnRefreshShareSlotItem, self)
  self.LoopScrollGridShareSlot:AddItemWidgetChildEvent("CommonDragDropItem", "OnDragReadyToShape", self.OnShareSlotDrag, self)
  self.LoopScrollGridShareSlot:AddItemWidgetChildEvent("CommonDragDropItem", "OnDragCanceled", self.OnShareSlotRemove, self)
  self.LoopScrollGrid_Normal:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragReadyToShape", self.OnGunItemDragReadyToShape, self)
  self.LoopScrollGrid_Normal:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragCanceled", self.OnGunItemDragCanceled, self)
  self.LoopScrollGrid_Normal:AddItemWidgetChildEvent("Common_DragDrop_Item", "OnDragSuccess", self.OnDragSuccess, self)
end
function WardrobeGun:RegistEvents()
  WardrobeGun.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_GUN_LIST, self.OnUpdateGunList, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_GUN_TAB_UI, self.UpdateTabUI, self)
  self:AddCommonEvent(EVENTTYPE_ARMORY, EVENTID_ARMORY_EQUIP_STAT_CHANGE, self.OnUpdateSkinEquipState, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN, self.OnUpdateCurrentPutOnGun, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SWITCH_USE_ROLEWEAR, self.OnFashionBagChange, self)
  self:AddCommonEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_SUMMARY_DATA, self.OnGetDiyData, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_CURRENT_TAB, self.OnRefreshGunList, self)
  self:AddCommonEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_REFIT_SUCCESS, self.OnRefitRspCallBack, self)
  self:AddCommonEvent(EVENTTYPE_WEAPON_PENDANT, EVENTID_WEAPON_PENDANT_WEAR_UPDATE, self.UpDateWeaponPendantWear, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHARE_SKIN_MODE_REFRESH, self.OnShareSkinModRefresh, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SELF_USING_SHARE_WEAPON_CHANGE, self.OnSelfUsingWeaponChange, self)
  self.Common_ComboBox_GunType = self:InitCommonComboBoxNew(self.UIRoot.Common_ComboBox_GunType)
  self.Common_ComboBox_GunType:SetSelectOptionCallback(self.OnSelectGunTypeItem, self)
  self.Common_ComboBox_GunType:SetRefreshOptionCallback(self.OnRefreshGunTypeItem, self)
  self:AddOnClickedEventByControl(self.UIRoot.Wardrobe_Details_item.Button_ChangeState, self.OnClickChangeState, self)
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  local weaponPage = wardrobe_red_point:GetWeaponPage()
  self.UIRoot.Reddot_Anchor:ShowRedPointByPath(wardrobe_red_point.C_Wardrobe_RedPoint_Style)
  if weaponPage then
    self.redHandle = weaponPage:BindEvent(function(value)
      if not slua.isValid(self.UIRoot) then
        return
      end
      logic_wardrobe_gun:UpdateSubTabItemCount(self:GetDataSource())
      self.Common_ComboBox_GunType:RefreshOptions()
      self.LoopScrollGrid_GunList:RefreshAllItems()
      self:SetWidgetVisible(self.UIRoot.Reddot_Anchor, value ~= 0)
    end)
  end
  self:ListenGunIconChange()
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_EDIT_BAG_LEVEL_CHANGE, self.OnFashionBagEditWeaponUpdate, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHARE_BAG_LIST_UPDATE, self.OnShareBagListUpdate, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_LEGEND_WEAPON_UPDATE, self._OnLgdWpnUpdate, self)
end
function WardrobeGun:_OnLgdWpnUpdate()
  self:UpdateGunList()
end
function WardrobeGun:OnShow()
  WardrobeGun.__super.OnShow(self)
  self:InitGunID()
  self:RefreshGunTypeComboBox()
  self:RefreshProficiencyDisplay()
  local itemData = self.LoopScrollGrid_GunList:GetItemData(1)
  if itemData then
    local ClickGun = itemData.resID
    local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
    local tabId = wardrobe_red_point:GetTabIdByRes(ClickGun)
    local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    logic_wardrobe:SetCurrentTabId(tabId)
  end
  self:JumpToSpecialGunItemID()
  self:HideCarSkinList()
  self:RefreshShareSlot()
  self:ReqLegendWeaponCardStatus()
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  if not logic_display_setting.ShowGun() and DataMgr.Weapon_ID == 0 then
    logic_wardrobe_gun:OnPutOnStateChange()
  end
end
function WardrobeGun:RefreshAllItems()
  self.LoopScrollGrid_GunList:RefreshAllItems()
end
function WardrobeGun:HideCarSkinList()
  self.UIRoot.CanvasPanel_CarSkinDrag:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function WardrobeGun:JumpToSpecialGunItemID()
  if not self.args or not self.gunResInfoList then
    return
  end
  local index
  for i, info in pairs(self.gunResInfoList) do
    if info.resID == self.args then
      index = i
      break
    end
  end
  if not index then
    return
  end
  self:OnClickGunListItem(nil, index, nil, true)
end
function WardrobeGun:OnClose()
  print(bWriteLog and "[gun] WardrobeGun:OnClose")
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  if self.redHandle then
    local vehiclePage = wardrobe_red_point:GetWeaponPage()
    if vehiclePage then
      vehiclePage:RemoveEvent(self.redHandle)
    end
    self.redHandle = nil
  end
  self.UIRoot.LoopScrollGrid_Avatar:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.HorizontalBox_Pendant:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:RefreshSwitchPanel()
  self.UIRoot.Reddot_Anchor:UnBind()
end
function WardrobeGun:OnUpdateGunList(eventType, eventID, showType)
  self:UpdateGunList(showType)
end
function WardrobeGun:OnUpdateSkinEquipState(eventType, eventID)
  self:RefreshPutOnGunSkinListItem()
  self:UpdatePendantTab()
end
function WardrobeGun:OnUpdateCurrentPutOnGun(eventType, eventID, isRefresh, gunID, checkGunType)
  self:UpdateCurrentPutOnGun(isRefresh, gunID, checkGunType)
  local EntryIconMgr = require("client.slua.umg.Wardrobe.entry.entry_icon_mgr")
  EntryIconMgr:RefreshGunEntryIcons(gunID or 0)
end
function WardrobeGun:OnFashionBagChange(_, __, CurrentIndex)
  WardrobeGun.__super.OnFashionBagChange(self, _, __, CurrentIndex)
  self:UpdateGunList(self.CurrentGunType)
end
function WardrobeGun:OnWardrobeDataChange(eventType, eventID)
  local index = self.Common_Tab_BagMode:GetSelectedIndex()
  if index == ENUM_Tab.ENUM_Tab_Gun then
    local curGun = self:GetCurrentShowGunID()
    self:RefreshGunSkinList(curGun)
  elseif index == ENUM_Tab.ENUM_Tab_Pendants then
    self:RefreshBagPendantsList()
  end
end
function WardrobeGun:InitGunID()
  logic_wardrobe_gun:SetGunID(0)
  logic_wardrobe_gun:SetPreviewGunResID(0)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bInWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
  if not bInWardrobeEditMode then
    if DataMgr.Weapon_ID ~= 0 then
      local gunCfg = CDataTable.GetTableData("ArmoryConfig", DataMgr.Weapon_ID)
      if gunCfg ~= nil then
        logic_wardrobe_gun:SetGunID(DataMgr.Weapon_ID)
        log(bWriteLog and "[gun] set gun type branch 1 to : " .. tostring(DataMgr.Weapon_ID))
        self.CurrentGunType = gunCfg.WeaponType
        logic_wardrobe_gun:SetPreviewGunResID(DataMgr.Weapon_ID)
        local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
        local itemData = wardrobe_data:GetValidHallDepotItemDataByInsID(DataMgr.Weapon_Skin_InsID)
        itemData = itemData or wardrobe_data:GetHallDepotItemDataByResID(DataMgr.Weapon_Skin_ResID)
        if itemData then
          logic_wardrobe_gun:SetPreviewGunResID(itemData.resID)
        end
      end
    end
  else
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    local WeaponID = FashionBagEditUtils:GetMainWeaponID()
    if WeaponID ~= 0 then
      local gunCfg = CDataTable.GetTableData("ArmoryConfig", WeaponID)
      if gunCfg ~= nil then
        log(bWriteLog and "[gun] set gun type branch 2 to : " .. tostring(gunCfg.WeaponType))
        self.CurrentGunType = gunCfg.WeaponType
      end
    end
  end
end
function WardrobeGun:UpdateGunList(showType)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  log(bWriteLog and "WardrobeGun:UpdateGunList showType " .. tostring(showType))
  if not self:IsShow() then
    return
  end
  local gunArray = logic_wardrobe_gun:GetGunArrayByGunType(self.CurrentGunType)
  local gunResInfoList = {}
  if gunArray ~= nil then
    for _, v in ipairs(gunArray) do
      local info = {}
      local skinInsID = self:GetShowSkinIDByWeaponID(v.WeaponID)
      info.resID = v.WeaponID
      logic_wardrobe_gun:InitGunInfo(info, skinInsID)
      log(bWriteLog and "WardrobeGun:UpdateGunList WeaponID=" .. tostring(v.WeaponID) .. ", skinID = " .. tostring(skinInsID))
      local UnknowPassTreasureBoxSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_treasurebox")
      info.total_count = UnknowPassTreasureBoxSystem.GetItemCount(info.skinResID)
      info.use_count = HallThemeUtils.GetUsedItemCount(skinInsID, HallThemeUtils.knapsack_ext_weapon_skin)
      table.insert(gunResInfoList, info)
    end
  end
  self.LoopScrollGrid_GunList:SetData(gunResInfoList)
  self.  local curGun = self:GetCurrentShowGunID()
  if 0 < curGun then
    self:UpdateCurrentPutOnGun(true, curGun)
  end
  self.Common_Tab_BagMode:Select(1)
  self:OnClickButtonGun(true)
  self:UpdateShareSlotList()
end
function WardrobeGun:ReqLegendWeaponCardStatus()
  local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
  logic_legend_weapon:ReqCardStatus()
end
function WardrobeGun:OnRefreshGunList(_, __)
  logic_wardrobe_gun:UpdateSubTabItemCount(self:GetDataSource())
  self.LoopScrollGrid_GunList:RefreshAllItems()
end
function WardrobeGun:OnRefreshGunListItem(widget, index, itemUI)
  local itemData = self.LoopScrollGrid_GunList:GetItemData(index)
  if itemData then
    local cls_GunResInfo = import("/Game/StructFromLua/BP_STRUCT_Wardrobe_GunResInfo.BP_STRUCT_Wardrobe_GunResInfo")
    local obj_GunResInfo = cls_GunResInfo()
    local util = require("client.slua_ui_framework.util")
    util.TableToBPObject(itemData, obj_GunResInfo)
    widget:InitView(obj_GunResInfo)
    local id = itemData.resID
    if itemData.skinResID and itemData.skinResID > 0 then
      id = itemData.skinResID
    end
    local UIUtil = require("client.common.ui_util")
    local iconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(id, widget.Wardrobe_GunTypeItem_UIBP.Image_Wardrobe_GunLogo)
    local params = {sync = false, bHasAddKnownMissing = bHasAddKnownMissing}
    self:SetTexture(widget.Wardrobe_GunTypeItem_UIBP.Image_Wardrobe_GunLogo, iconPath, params)
    widget.Wardrobe_GunTypeItem_UIBP.TextBlock_Wardrobe_GunLogo:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.Wardrobe_GunTypeItem_UIBP.Image_Using:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local cfg = CDataTable.GetTableData("ArmoryDescConfig", itemData.resID)
    if cfg then
      widget.Wardrobe_GunTypeItem_UIBP.TextBlock_Wardrobe_GunLogo:SetText(cfg.ArmorySimpleDesc)
    end
    local GunID
    local isCurSelectIndex = false
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    local bInFashionEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
    local bInShareBagMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.ShareBag
    if bInShareBagMode then
      GunID = logic_wardrobe_gun:GetShareBagConfigGunID()
      if GunID == 0 then
        GunID = logic_wardrobe_gun:GetGunID()
      end
      isCurSelectIndex = itemData.resID == GunID
    elseif bInFashionEditMode then
      local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
      GunID = FashionBagEditUtils:GetMainWeaponID()
      isCurSelectIndex = itemData.resID == GunID
    else
      GunID = logic_wardrobe_gun:GetGunID()
      isCurSelectIndex = itemData.resID == self.CurrentGunID
    end
    widget:SetTryOnEnable(isCurSelectIndex)
    if isCurSelectIndex then
      widget.Wardrobe_GunTypeItem_UIBP.Image_Using:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      widget.Wardrobe_GunTypeItem_UIBP.Image_Using:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    widget.Wardrobe_GunTypeItem_UIBP.TextBlock_Wardrobe_GunLogo:SetSelectColor(isCurSelectIndex)
    local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
    widget.Wardrobe_GunTypeItem_UIBP.Reddot_Anchor:ShowRedPointByPath(wardrobe_red_point.C_Wardrobe_RedPoint_Style)
    local tab = wardrobe_red_point:GetTabByResId(itemData.resID)
    if tab then
      tab:RegisterWidget(widget.Wardrobe_GunTypeItem_UIBP.Reddot_Anchor)
    end
    local cnt = logic_wardrobe_gun:GetSubTabItemCount(itemData.resID)
    if 0 < cnt then
      widget.Wardrobe_GunTypeItem_UIBP.TextBlock_0:SetText(tostring(cnt))
    else
      widget.Wardrobe_GunTypeItem_UIBP.TextBlock_0:SetText("")
    end
    local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
    local curPlanId = weapon_diy_system:GetCurUsePlanIdByWeaponId(itemData.skinResID)
    if curPlanId ~= nil and curPlanId ~= 0 then
      local callback = function(texturePath, planID)
        local curUsePlanId = weapon_diy_system:GetCurUsePlanIdByWeaponId(itemData.skinResID)
        if curUsePlanId ~= nil and curUsePlanId ~= planID then
          return
        end
        local LoadTexture = import("LoadTexture")
        local Texture = LoadTexture.GetTexture2DFromDiskFile(texturePath)
        if Texture then
          widget.Wardrobe_GunTypeItem_UIBP.Image_Wardrobe_GunLogo:SetBrushFromTexture(Texture, false)
        end
      end
      local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
      local scheme = WeaponDiySystem:GetSchemeData(itemData.skinResID, curPlanId)
      local WeaponDIYCapture = require("client.slua.logic.weapon_diy.logic_weapon_capture_weapon")
      WeaponDIYCapture:GetWeaponIconTexture(itemData.skinResID, curPlanId, WeaponDIYCapture.scene.diy_congratulations, scheme, false, callback)
    end
    local bShowTrialTime = false
    local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
    if logic_legend_weapon and logic_legend_weapon:IsLegendWeaponItem(itemData.resID) then
      local nRemainSec = logic_legend_weapon:GetTrialRemainTime(itemData.resID)
      if 0 < nRemainSec then
        bShowTrialTime = true
        local TimeUtil = require("client.common.time_util")
        local sTimeText = TimeUtil.FormatCountDownTime_DH_or_HM(nRemainSec)
        widget.Wardrobe_GunTypeItem_UIBP.TextBlock_LimitTime:SetText(sTimeText)
      end
    end
    widget.Wardrobe_GunTypeItem_UIBP.CanvasPanel_LimitTime:SetWidgetVisibility(bShowTrialTime and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed)
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local common_download_handler = require("client.slua.common.common_download_handler")
    common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.ODPAK, {
      itemData.resID,
      cfg.ItemBigIcon
    }, itemUI, widget.Panel_Download, {bShowIconOnly = true})
  end
end
local ArmorySystem = require("client.logic.armory.logic_armory")
function WardrobeGun:OnClickGunListItem(widget, index, itemUI, hideAudio)
  log(bWriteLog and "WardrobeGun:OnClickGunListItem " .. tostring(index))
  if hideAudio then
  else
    self:PlayAudio(sound_config.subTab_v1)
  end
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.WardrobeGunSubTab) then
    return
  end
  self.Common_Tab_BagMode:Select(1)
  self:OnClickButtonGun()
  local itemData = self.LoopScrollGrid_GunList:GetItemData(index)
  if itemData then
    local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
    tipsMgr:Hide()
    local ClickGun = itemData.resID
    local GunID = logic_wardrobe_gun:GetGunID()
    log(bWriteLog and "WardrobeGun:OnClickGunListItem " .. ClickGun)
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    local bInWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
    local bInShareBagMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.ShareBag
    if not bInWardrobeEditMode and not bInShareBagMode then
      local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
      if logic_legend_weapon:IsLegendWeaponItem(ClickGun) then
        local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
        if logic_legend_weapon:IsPermanent(ClickGun) then
          UIManager.ShowUI(UIManager.UI_Config.CardCollection_SpecialBuffCard_Popup_UIBP2, ClickGun)
        else
          UIManager.ShowUI(UIManager.UI_Config.CardCollection_SpecialBuffCard_Popup_UIBP, ClickGun)
        end
      elseif DataMgr.Weapon_ID ~= 0 then
        logic_legend_weapon:SetSceneLobbyOff()
        if ClickGun ~= DataMgr.Weapon_ID then
          logic_wardrobe_gun:put_on_weapon_wear(ArmorySystem.ENUM_REQ_Wardrobe, ClickGun)
          logic_wardrobe_gun:SetKeepGunID(ClickGun)
        else
          logic_wardrobe_gun:put_on_weapon_wear(ArmorySystem.ENUM_REQ_Wardrobe, 0)
        end
      else
        logic_legend_weapon:SetSceneLobbyOff()
        if GunID ~= ClickGun then
          GunID = ClickGun
          logic_wardrobe_gun:SetKeepGunID(ClickGun)
          logic_wardrobe_gun:put_on_weapon_wear(ArmorySystem.ENUM_REQ_Wardrobe, ClickGun)
        else
          if GunID ~= 0 then
            logic_wardrobe_gun:SetKeepGunID(GunID)
          end
          GunID = 0
          logic_wardrobe_gun:PutOffGunAvatar()
        end
        logic_wardrobe_gun:SetGunID(GunID)
      end
    elseif bInWardrobeEditMode then
      local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
      FashionBagEditUtils:ChangeWeaponID(ClickGun)
      self.LoopScrollGrid_GunList:RefreshAllItems()
    elseif bInShareBagMode then
      logic_wardrobe_gun:SetShareBagConfigGunID(ClickGun)
      self.LoopScrollGrid_GunList:RefreshAllItems()
    end
    self:ShowEmptyGunSkinList(false)
    if logic_wardrobe_gun:HasGunSkinList() then
      self:UpdateGunSkinList(ClickGun, true)
    else
      logic_wardrobe_gun:GetGunSkinListReq()
    end
    self:RefreshProficiencyDisplay()
    local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
    local tabId = wardrobe_red_point:GetTabIdByRes(ClickGun)
    if tabId then
      local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      logic_wardrobe:SetCurrentTabId(tabId)
    end
  end
end
function WardrobeGun:UpdateCurrentPutOnGun(isRefresh, gunID, checkGunType)
  if not self:IsShow() then
    return
  end
  logic_wardrobe_gun:SetIsPutOnGun(DataMgr.Weapon_ID ~= 0)
  if isRefresh then
    self:UpdatePutOnGunListItem()
  end
  self:UpdatePendantTab()
end
function WardrobeGun:UpdatePutOnGunListItem()
  local GunID = logic_wardrobe_gun:GetGunID()
  local preSelect = self.CurrentGunID
  log(bWriteLog and "WardrobeGun:UpdatePutOnGunListItem .. " .. tostring(GunID) .. tostring(preSelect))
  if GunID ~= 0 then
    self.Current  end
  local itemCount = self.LoopScrollGrid_GunList:GetItemCount()
  for i = 1, itemCount do
    local data = self.LoopScrollGrid_GunList:GetItemData(i)
    if data.resID == self.CurrentGunID or data.resID == preSelect then
      self.LoopScrollGrid_GunList:RefreshItem(i, self.LoopScrollGrid_GunList:GetItemData(i))
    end
  end
  local resID = DataMgr.Weapon_Skin_ResID
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, resID)
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  if PufferSwitch.CanAutoDownload() then
    return
  end
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local state = PufferODPakManager:GetStateByItemID(resID)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  if state == PufferConst.ENUM_DownloadState.Done then
    return
  end
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.Wardrobe, PufferTlog.Enum_TLog_Optype.Cancel, "Inventory_Intercept", resID)
end
function WardrobeGun:RefreshGunSkinList(gunID, bForceUpdateTags)
  log(bWriteLog and "WardrobeGun:RefreshGunSkinList " .. tostring(gunID))
  if 0 < gunID then
    local gunCfg = CDataTable.GetTableData("ArmoryConfig", gunID)
    if gunCfg ~= nil and gunCfg.WeaponType == self.CurrentGunType then
      self:UpdateGunSkinList(gunID, bForceUpdateTags)
    else
      self:ShowEmptyGunSkinList(true)
    end
  else
    self:ShowEmptyGunSkinList(true)
  end
end
function WardrobeGun:ShowEmptyGunSkinList(show, bIgnoreData)
  log(bWriteLog and "WardrobeGun:ShowEmptyGunSkinList " .. tostring(show))
  self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_Wardrobe_Empty, show)
  if show then
    self.UIRoot.WidgetSwitcher_Wardrobe_Empty:SetActiveWidgetIndex(1)
    WardrobeGun.__super.UpdateItemList(self, {})
    local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
    logic_wardrobe_tag_mgr:UpdateItemList({})
    logic_wardrobe_tag_mgr:ClearItemList()
    if not bIgnoreData then
      self:SetInitItemList({})
    end
    self.LoopScrollBox_Tags:RefreshAllItems()
    self:RefreshSwitchPanel()
  end
end
function WardrobeGun:UpdateGunSkinList(gunID, bForceUpdateTags)
  log(bWriteLog and "WardrobeGun:UpdateGunSkinList Wardrobe_GunID " .. tostring(gunID))
  if not self:IsShow() then
    return
  end
  local skinList = ArmorySystem.GetSkinListByWeaponID(gunID)
  if skinList ~= nil then
    local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    local wardrobeLogicGun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
    local SortPreference = logic_wardrobe:GetSortPreference(wardrobeLogicGun)
    local arraySkillList = logic_wardrobe_gun:GetSkinList(skinList, SortPreference, gunID, self:GetDataSource())
    self:SetInitItemList(arraySkillList)
    if bForceUpdateTags then
      local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
      logic_wardrobe_tag_mgr:UpdateItemList(arraySkillList)
      self.LoopScrollBox_Tags:RefreshAllItems()
    end
    if self.UIRoot.WidgetSwitcher_Search then
      arraySkillList = self:DoSearch(arraySkillList, WardrobeLogicManager:GetSearchString())
    end
    if self.bShowTagFilter then
      arraySkillList = self:DoFilterTags(arraySkillList)
    end
    if #arraySkillList == 0 then
      self:ShowEmptyGunSkinList(true, true)
    else
      self.UIRoot.WidgetSwitcher_Wardrobe_Empty:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      local CurSkinInsID = self:GetCurrentSelectItemInsID()
      WardrobeGun.__super.UpdateItemList(self, arraySkillList)
      local TargetSkinIndex = self:GetItemIndexByInsId(CurSkinInsID)
      if 0 < TargetSkinIndex then
        self.LoopScrollGrid_Normal:Select(TargetSkinIndex)
      end
    end
  end
  local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
  if logic_share_bag_team_util:GetUsingShareWeaponIDByUID(DataMgr.roleData.uid) == 0 then
    logic_wardrobe_gun.OnEquipStateChange()
  end
  self:RefreshSwitchPanel()
end
function WardrobeGun:IsShowBigIcon()
  return true
end
function WardrobeGun:OnRefreshListItem(widget, index)
  WardrobeGun.__super.OnRefreshListItem(self, widget, index)
  local itemData = self:GetItemData(index)
  if not itemData then
    return
  end
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bShareBag = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.ShareBag
  local dragDropItem = widget.Common_DragDrop_Item
  if bShareBag then
    dragDropItem:SetEnable(true)
    dragDropItem:SetDragEnable(true)
    dragDropItem:RegisterDrag(1, 0, 0, itemData.ins_id)
  else
    dragDropItem:SetEnable(false)
    dragDropItem:SetDragEnable(false)
  end
end
function WardrobeGun:OnClickItem(widget, index)
  local tabIndex = self.Common_Tab_BagMode:GetSelectedIndex()
  if tabIndex == ENUM_Tab.ENUM_Tab_Pendants then
    self:OnClickPendantItem(widget, index)
    return
  end
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  WardrobeGun.__super.OnClickItem(self, widget, index)
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  if itemData and itemData.lock_cnt and itemData.lock_cnt > 0 then
    return
  end
  if itemData then
    if not DataMgr.IsValidTime(itemData.expireTS) then
      ShowNotice(9910101)
      return
    end
    local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
    tipsMgr:Show(tipsMgr.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, itemData.ins_id, itemData.res_id)
    local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    if logic_wardrobe:IsItemIsolated(itemData.res_id) then
      ShowNotice(4987)
      return
    end
    if not logic_wardrobe:IsCharacterUse(itemData.res_id) then
      ShowNotice(7475)
      return
    end
    local needEquipPlan = false
    local skinInsID = itemData.ins_id
    log(bWriteLog and "WardrobeGun:OnClickItem skinInsID " .. skinInsID)
    if itemData.planID then
      local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
      needEquipPlan = itemData.planID ~= WeaponDiySystem:GetCurUsePlanIdByWeaponId(itemData.res_id)
      if needEquipPlan then
        WeaponDiySystem:UseDiyCustomSchemeReq(itemData.res_id, itemData.planID)
      end
    end
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    local bInFashionBagEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
    local bInShareBagMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.ShareBag
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    local cfg = CDataTable.GetTableData("WeaponSkinMapping", itemData.res_id)
    if cfg then
      if bInShareBagMode then
        local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
        local myAvatar = TeamAvatarManager.GetAvatarByUid(tonumber(DataMgr.roleData.uid))
        local bPutOn = true
        if myAvatar then
          local skinResID = myAvatar:GetCurHoldingWeaponSkinID()
          if skinResID == itemData.res_id then
            bPutOn = false
          end
        end
        self:LocalUpdateWeaponOnShareBag(skinInsID, cfg.WeaponID, itemData.planID, bPutOn)
      elseif not bInFashionBagEditMode then
        if HallThemeUtils.IsWeaponWear(skinInsID) == false or needEquipPlan then
          ArmorySystem.install_weapon_skin(ArmorySystem.ENUM_REQ_Wardrobe, cfg.WeaponID, skinInsID)
        else
          ArmorySystem.uninstall_weapon_skin(ArmorySystem.ENUM_REQ_Wardrobe, cfg.WeaponID)
        end
      elseif not FashionBagEditUtils:IsItemInTryMap(itemData.res_id, false, itemData) then
        log(bWriteLog and "WardrobeGun:OnClickItem fashion bag edit mode puton ins_id:" .. itemData.ins_id)
        FashionBagEditUtils:PutOnWeaponSkin(cfg.WeaponID, itemData, itemData.planID)
      else
        log(bWriteLog and "WardrobeGun:OnClickItem fashion bag edit mode putoff ins_id:" .. itemData.ins_id)
        FashionBagEditUtils:PutOffWeaponSkin(cfg.WeaponID)
      end
    end
  end
end
function WardrobeGun:RefreshPutOnGunSkinListItem()
  local curGun = self:GetCurrentShowGunID()
  local skinInsID = logic_wardrobe_gun:GetSkinIdByWeaponID(curGun)
  local itemCount = self.LoopScrollGrid_Normal:GetItemCount()
  for i = 1, itemCount do
    local data = self.LoopScrollGrid_Normal:GetItemData(i)
    if data.planID ~= nil then
      local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
      data.isUsing = tonumber(data.ins_id) == skinInsID and data.planID == weapon_diy_system:GetCurUsePlanIdByWeaponId(data.res_id)
    else
      data.isUsing = tonumber(data.ins_id) == skinInsID
    end
    self.LoopScrollGrid_Normal:RefreshItem(i, data)
  end
  self:RefreshSwitchPanel(skinInsID)
end
function WardrobeGun:RefreshSwitchPanel(skinInsID)
  log(bWriteLog and "[WardrobeMultiItem] WardrobeGun RefreshSwitchPanel" .. tostring(skinInsID))
  if not skinInsID or tonumber(skinInsID) == 0 then
    self.UIRoot.Wardrobe_Details_item:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local data = wardrobe_data:GetValidHallDepotItemDataByInsID(skinInsID)
  if not data then
    log_error("[WardrobeMultiItem] WardrobeGun RefreshSwitchPanel Can`t Find data")
    self.UIRoot.Wardrobe_Details_item:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local WeaponLevel1ID = GetItemUpgradeMgr():GetLevel1ItemID(data.resID)
  local WeaponSwitchConfig = CDataTable.GetTableData("WeaponSwitchConfig", WeaponLevel1ID)
  if not WeaponSwitchConfig then
    self.UIRoot.Wardrobe_Details_item:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self.UIRoot.Wardrobe_Details_item:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:SetTexture(self.UIRoot.Wardrobe_Details_item.State_Image, WeaponSwitchConfig.SwtichICON)
  local IsRift = GetItemUpgradeMgr():IsRefitUnlockComplete2(GetItemUpgradeMgr():GetBaseItemID(data.resID), self:GetDataSource())
  if IsRift then
    self.UIRoot.Wardrobe_Details_item.CanvasPanel_Lock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.Wardrobe_Details_item.CanvasPanel_Lock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function WardrobeGun:RefreshGunTypeComboBox()
  local gunTypeArray = logic_wardrobe_gun:GetGunTypeArray()
  local gunList = {}
  for _, v in ipairs(gunTypeArray) do
    table.insert(gunList, tostring(v.TypeID))
  end
  self.Common_ComboBox_GunType:SetData(gunList, self.CurrentGunType)
end
function WardrobeGun:OnRefreshGunTypeItem(widget, typeID)
  log(bWriteLog and "WardrobeGun:OnRefreshGunTypeItem")
  local armoryTypeCfg = CDataTable.GetTableData("ArmoryTypeConfig", typeID)
  self:SetItemName(widget, armoryTypeCfg)
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  widget.Reddot_Anchor:ShowRedPointByPath(wardrobe_red_point.C_Wardrobe_RedPoint_Style)
  local weaponType = wardrobe_red_point:GetWeaponType(armoryTypeCfg.TypeID)
  if weaponType then
    weaponType:RegisterWidget(widget.Reddot_Anchor)
  end
end
function WardrobeGun:OnSelectGunTypeItem(widget, typeID)
  log(bWriteLog and "WardrobeGun:OnSelectGunTypeItem")
  self:PlayAudio(sound_config.click_v1)
  local armoryTypeCfg = CDataTable.GetTableData("ArmoryTypeConfig", typeID)
  if armoryTypeCfg ~= nil then
    widget.TextBlock_ItemName:SetText(armoryTypeCfg.TypeName)
    self:SetWidgetVisible(widget.Reddot_Anchor, false)
    log(bWriteLog and "[gun] set gun type branch 3 to : " .. tostring(armoryTypeCfg.TypeID))
    self.CurrentGunType = armoryTypeCfg.TypeID
    self:OnGunTypeChanged()
    local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
    tipsMgr:Hide()
  end
end
function WardrobeGun:OnGunTypeChanged()
  if logic_wardrobe_gun:HasGunSkinList() then
    self:UpdateGunList(self.CurrentGunType)
  else
    logic_wardrobe_gun:GetGunSkinListReq()
  end
end
function WardrobeGun:OnGetDiyData()
  if logic_wardrobe_gun:HasGunSkinList() then
    self:UpdateGunList(self.CurrentGunType)
  end
end
function WardrobeGun:ListenGunIconChange()
  local WardrobeUtils = require("client.slua.logic.wardrobe.wardrobe_utils")
  local tabSurveillance = require("client.slua.logic.wardrobe.tab_surveillance")
  local subConfig = WardrobeUtils.GetSubTabConfigByPageID(Weapon)
  if not subConfig or not next(subConfig) then
    return
  end
  for _, tabConfig in pairs(subConfig) do
    local tabEquip = tabSurveillance.GetTabEquip(tabConfig.subTabID)
    if tabEquip then
      self:AddDataListener(tabEquip, "instanceID", function(weaponID, oldValue, value)
        self:RefreshGunListIcon(weaponID, value)
      end, tabConfig.subTabID)
    end
  end
end
function WardrobeGun:RefreshGunListIcon(weaponID, insID)
  local index = self:FindIndexByWeaponID(weaponID)
  if index then
    local itemData = self.LoopScrollGrid_GunList:GetItemData(index)
    logic_wardrobe_gun:InitGunInfo(itemData, insID)
    self.LoopScrollGrid_GunList:RefreshItem(index, itemData)
  end
end
function WardrobeGun:FindIndexByWeaponID(weaponID)
  local itemCount = self.LoopScrollGrid_GunList:GetItemCount()
  for i = 1, itemCount do
    local data = self.LoopScrollGrid_GunList:GetItemData(i)
    if data.resID == weaponID then
      return i
    end
  end
end
function WardrobeGun:SetItemName(widget, armoryTypeCfg)
  local ItemName = armoryTypeCfg.TypeName
  if ItemName ~= nil then
    local cnt = logic_wardrobe_gun:GetTabItemCount(armoryTypeCfg.TypeID)
    if 0 < cnt then
      widget.TextBlock_ItemName:SetText(string.format("%s(%d)", ItemName, cnt))
    else
      widget.TextBlock_ItemName:SetText(ItemName)
    end
  end
end
function WardrobeGun:RefreshProficiencyDisplay()
  if Logic_Career.IsOpen() then
    local node_root = self.UIRoot
    local nWeaponId = logic_wardrobe_gun:GetGunID()
    local sWeaponName = ""
    local cfg = CDataTable.GetTableData("ArmoryDescConfig", nWeaponId)
    if cfg then
      sWeaponName = cfg.ArmorySimpleDesc
    end
    node_root.TextProficiency:SetText(LocUtil.LocalizeResFormat(24837, sWeaponName, Logic_Career_Weapon.GetWeaponPro(nWeaponId)))
    node_root.Node_ProValue:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function WardrobeGun:OnClickCheckBox()
  self:PlayAudio(sound_config.toggle_v1)
  local isChecked = self.UIRoot.CheckBox_Sort:IsChecked()
  if isChecked then
    WardrobeLogicManager:SetSortPreference(logic_wardrobe_gun, true)
  else
    WardrobeLogicManager:SetSortPreference(logic_wardrobe_gun, false)
  end
  self:OnWardrobeDataChange()
end
function WardrobeGun:OnSelectSortItem(widget, data)
  self:PlayAudio(sound_config.click_v1)
  widget.TextBlock_ItemName:SetText(data.text)
  if data.type == self.ENUM_SORT_TYPE.LATEST then
    WardrobeLogicManager:SetSortPreference(logic_wardrobe_gun, true)
  else
    WardrobeLogicManager:SetSortPreference(logic_wardrobe_gun, false)
  end
  self:OnWardrobeDataChange()
end
function WardrobeGun:RefreshCheckBoxState()
  self.UIRoot.TextBlock_SortViaTime:SetText(LocUtil.LocalizeResFormat(34618))
  local SortPreference = WardrobeLogicManager:GetSortPreference(logic_wardrobe_gun)
  if SortPreference then
    self.UIRoot.CheckBox_Sort:SetCheckedState(1)
  else
    if SortPreference == nil then
      WardrobeLogicManager:SetSortPreference(logic_wardrobe_gun, false)
    end
    self.UIRoot.CheckBox_Sort:SetCheckedState(0)
  end
end
function WardrobeGun:OnClickHorizontalTabButton(widget, index)
  self:PlayAudio(sound_config.click_v1)
  if index == ENUM_Tab.ENUM_Tab_Gun then
    self:OnClickButtonGun()
  elseif index == ENUM_Tab.ENUM_Tab_Pendants then
    self:OnClickButtonPendants()
  end
end
function WardrobeGun:OnClickButtonGun(bForceUpdateTags)
  self.UIRoot.HorizontalBox_Pendant:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.LoopScrollGrid_Avatar:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  tipsMgr:Hide()
  self:CheckCleanTagSelectAndRefresh()
  self:DirectUnEnlarge()
  local curGun = self:GetCurrentShowGunID()
  self:RefreshGunSkinList(curGun, bForceUpdateTags)
end
function WardrobeGun:OnClickButtonPendants()
  local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
  if logic_share_bag_team_util:GetUsingShareWeaponIDByUID(DataMgr.roleData.uid) ~= 0 then
    self.Common_Tab_BagMode:Select(ENUM_Tab.ENUM_Tab_Gun)
    ShowNotice(79416)
    return
  end
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local weaponSkinIns = HallThemeUtils.GetCurWeaponInstId()
  if not weaponSkinIns or weaponSkinIns == 0 then
    log(bWriteLog and "WardrobeGun:OnClickButtonPendants not weaponSkinIns")
    self.Common_Tab_BagMode:Select(ENUM_Tab.ENUM_Tab_Gun)
    ShowNotice(48242)
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
  local weaponSkinData = wardrobe_data:GetValidHallDepotItemDataByInsID(weaponSkinIns)
  if not (weaponSkinData and weaponSkinData.resID) or not logic_weapon_pendant:CanSkinWithPendant(weaponSkinData.resID) then
    log(bWriteLog and "WardrobeGun:OnClickButtonPendants not weaponSkinData")
    self.Common_Tab_BagMode:Select(ENUM_Tab.ENUM_Tab_Gun)
    ShowNotice(48242)
    return
  end
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  if Lobby_camera_manager_module:GetZoomInLobbyCameraCfg(weaponSkinData.itemSubType, Lobby_camera_manager_module.currentCameraID) then
    self:DirectEnlarge(weaponSkinData.itemSubType)
  else
    self:DirectEnlarge(ENUM_ITEM_SUBTYPE.Gun_Pendant_Skin)
  end
  self.UIRoot.LoopScrollGrid_Avatar:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.HorizontalBox_Pendant:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  tipsMgr:Hide()
  self:RefreshBagPendantsList()
end
function WardrobeGun:RefreshBagPendantsList()
  self.pendantList = self:GetBagPendantsList()
  self:SetInitItemList(self.pendantList)
  if self.UIRoot.WidgetSwitcher_Search then
    self.pendantList = self:DoSearch(self.pendantList, WardrobeLogicManager:GetSearchString())
  end
  if self.bShowTagFilter then
    self.pendantList = self:DoFilterTags(self.pendantList)
  end
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobeLogicGun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  local SortPreference = logic_wardrobe:GetSortPreference(wardrobeLogicGun)
  logic_wardrobe:SortItemTable(self.pendantList, SortPreference)
  self.LoopScrollGrid_Pendant:SetData(self.pendantList)
  self:ShowEmptyGunSkinList(#self.pendantList == 0)
end
function WardrobeGun:GetBagPendantsList()
  local pendantList = {}
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local weaponSkinIns = HallThemeUtils.GetCurWeaponInstId()
  if not weaponSkinIns or weaponSkinIns == 0 then
    log(bWriteLog and "WardrobeGun:GetBagPendantsList not weaponSkinIns")
    return pendantList
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local weaponSkinData = wardrobe_data:GetValidHallDepotItemDataByInsID(weaponSkinIns)
  if not weaponSkinData or not weaponSkinData.resID then
    log(bWriteLog and "WardrobeGun:GetBagPendantsList not weaponSkinData")
    return pendantList
  end
  local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
  local usingPendantIns = logic_weapon_pendant:GetPendantInsBySkinID(weaponSkinData.resID)
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local pageId = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute
  local subTabId = wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_bag_pendant
  local arrayHallDepotItemInfo = wardrobe_data:GetArrayHallDepotItemInfo(self:GetDataSource())
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(arrayHallDepotItemInfo) do
    local itemCfg = CDataTable.GetTableData("Item", v.resID)
    if itemCfg and logic_wardrobe:IsValidCurrentPageItem(pageId, subTabId, v, serverTime) and logic_weapon_pendant:IsWeaponPendant(v.resID) then
      local isWear = tonumber(v.insID) == usingPendantIns
      local itemInfo = logic_wardrobe:ArrayHallDepotToCommonItem(v, nil, isWear, true, false, false)
      itemInfo.isRolewear = false
      table.insert(pendantList, itemInfo)
    end
  end
  return pendantList
end
function WardrobeGun:OnRefreshPendantList(widget, index)
  local widgetData = self.LoopScrollGrid_Pendant:GetItemData(index)
  local isSelect = index == self.LoopScrollGrid_Pendant:GetSelectIndex()
  WardrobeGun.__super.RefreshListItem(self, widget, widgetData, isSelect, index)
end
function WardrobeGun:OnClickPendantItem(widget, index)
  self:PlayAudio(sound_config.click_v1)
  local pendantData = self.LoopScrollGrid_Pendant:GetItemData(index)
  if pendantData then
    pendantData.isNew = false
    if not DataMgr.IsValidTime(pendantData.expireTS) then
      ShowNotice(9910101)
      return
    end
    local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    logic_wardrobe:SetClickItemInsId(pendantData.ins_id)
    local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
    tipsMgr:Show(tipsMgr.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, pendantData.ins_id, pendantData.res_id)
    if logic_wardrobe:IsItemIsolated(pendantData.res_id) then
      ShowNotice(4987)
      return
    end
    if not logic_wardrobe:IsCharacterUse(pendantData.res_id) then
      ShowNotice(7475)
      return
    end
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    local weaponSkinIns = HallThemeUtils.GetCurWeaponInstId()
    if not weaponSkinIns or weaponSkinIns == 0 then
      log(bWriteLog and "WardrobeGun:OnClickPendantItem not weaponSkinIns")
      return
    end
    local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
    if pendantData.isUsing then
      logic_weapon_pendant:PutOffPendant(weaponSkinIns, tonumber(pendantData.ins_id))
    else
      logic_weapon_pendant:PutOnPendant(weaponSkinIns, tonumber(pendantData.ins_id))
    end
  end
  self.LoopScrollGrid_Pendant:Select(index)
end
function WardrobeGun:UpDateWeaponPendantWear(_, _, newIns, oldIns)
  log(bWriteLog and "WardrobeGun:UpDateWeaponPendantWear " .. tostring(newIns) .. tostring(oldIns))
  local index = self.Common_Tab_BagMode:GetSelectedIndex()
  if index == ENUM_Tab.ENUM_Tab_Gun then
    return
  end
  if not newIns and not oldIns then
    self:RefreshBagPendantsList()
    return
  end
  local itemCount = self.LoopScrollGrid_Pendant:GetItemCount()
  for i = 1, itemCount do
    local data = self.LoopScrollGrid_Pendant:GetItemData(i)
    if tonumber(data.ins_id) == newIns then
      data.isUsing = true
      self.LoopScrollGrid_Pendant:RefreshItem(i, data)
    end
    if tonumber(data.ins_id) == oldIns then
      data.isUsing = false
      self.LoopScrollGrid_Pendant:RefreshItem(i, data)
    end
  end
end
function WardrobeGun:UpdatePendantTab()
  local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
  if logic_share_bag_team_util:GetUsingShareWeaponIDByUID(DataMgr.roleData.uid) ~= 0 then
    log(bWriteLog and "WardrobeGun:UpdatePendantTab is using share weapon")
    self.Common_Tab_BagMode:SetChildLock(ENUM_Tab.ENUM_Tab_Pendants, true)
    return
  end
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local weaponSkinIns = HallThemeUtils.GetCurWeaponInstId()
  if not weaponSkinIns or weaponSkinIns == 0 then
    log(bWriteLog and "WardrobeGun:UpdatePendantTab not weaponSkinIns")
    self.Common_Tab_BagMode:SetChildLock(ENUM_Tab.ENUM_Tab_Pendants, true)
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
  local weaponSkinData = wardrobe_data:GetValidHallDepotItemDataByInsID(weaponSkinIns)
  if not (weaponSkinData and weaponSkinData.resID) or not logic_weapon_pendant:CanSkinWithPendant(weaponSkinData.resID) then
    log(bWriteLog and "WardrobeGun:UpdatePendantTab not weaponSkinData")
    self.Common_Tab_BagMode:SetChildLock(ENUM_Tab.ENUM_Tab_Pendants, true)
    return
  end
  log(bWriteLog and "WardrobeGun:UpdatePendantTab unlock")
  self.Common_Tab_BagMode:SetChildLock(ENUM_Tab.ENUM_Tab_Pendants, false)
end
function WardrobeGun:OnClickChangeState()
  self:PlayAudio(sound_config.click_v1)
  local CurSelectIndex = self.LoopScrollGrid_Normal:GetSelectIndex()
  log(bWriteLog and "[WardrobeMultiItem] OnClickChangeState " .. tostring(CurSelectIndex))
  if CurSelectIndex <= 0 then
    log_error("[WardrobeMultiItem] OnClickChangeState CurSelectIndex <= 0")
    return
  end
  local ItemData = self.LoopScrollGrid_Normal:GetItemData(CurSelectIndex)
  if GetItemUpgradeMgr():IsRefitUnlockComplete2(GetItemUpgradeMgr():GetBaseItemID(ItemData.res_id), self:GetDataSource()) then
    local ItemUpGradeHandler = require("client.network.Protocol.ItemUpGradeHandler")
    ItemUpGradeHandler.send_upgrade_refit_req(tonumber(ItemData.ins_id))
  else
    local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
    local RiftID = GetItemUpgradeMgr():GetRefitItemID(ItemData.res_id)
    local Level1ID = GetItemUpgradeMgr():GetLevel1ItemID(RiftID)
    LogicMultiItemModule:ShowUnlockJumpTips(Level1ID, self.UIRoot.Wardrobe_Details_item)
  end
end
function WardrobeGun:OnRefitRspCallBack(_, __, error_code, instid, res_id)
  if error_code ~= 0 then
    log_error("[WardrobeMultiItem] WardrobeGun OnRefitRspCallBack error_code ~= 0" .. tostring(error_code))
    return
  end
  log(bWriteLog and "[WardrobeMultiItem] WardrobeGun OnRefitRspCallBack" .. tostring(self.CurrentGunID))
  self:UpdateGunSkinList(self.CurrentGunID)
  local itemCount = self.LoopScrollGrid_Normal:GetItemCount()
  for i = 1, itemCount do
    local data = self.LoopScrollGrid_Normal:GetItemData(i)
    if tonumber(data.ins_id) == tonumber(instid) then
      self.LoopScrollGrid_Normal:Select(i)
      self.LoopScrollGrid_Normal:RefreshItem(i, data)
      local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
      tipsMgr:Show(tipsMgr.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, data.ins_id, data.res_id)
      self:RefreshSwitchPanel(data.ins_id)
      ArmorySystem.HandleWeaponSkinChange(ArmorySystem.ENUM_REQ_Wardrobe, self.CurrentGunID, data.ins_id)
    end
  end
end
function WardrobeGun:OnFashionBagEditWeaponUpdate(_, __, WeaponID, SkinInstID)
  self.LoopScrollGrid_GunList:RefreshAllItems()
  self:RefreshGunListIcon(WeaponID, SkinInstID)
end
function WardrobeGun:GetCurrentShowGunID()
  local GunID = 0
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bInFashionEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
  local bInShareBagMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.ShareBag
  if bInShareBagMode then
    GunID = logic_wardrobe_gun:GetShareBagConfigGunID()
    print(bWriteLog and "[gun] get share bag config gun id " .. tostring(GunID))
    if GunID == 0 then
      GunID = logic_wardrobe_gun:GetGunID()
    end
  elseif bInFashionEditMode then
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    GunID = FashionBagEditUtils:GetMainWeaponID()
  else
    GunID = logic_wardrobe_gun:GetGunID()
    if GunID == 0 then
      GunID = logic_wardrobe_gun:GetKeepGunID()
    end
    if GunID == 0 then
      GunID = 101001
    end
  end
  return GunID
end
function WardrobeGun:GetShowSkinIDByWeaponID(WeaponID)
  if not WeaponID then
    return 0
  end
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bInFashionEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
  if not bInFashionEditMode then
    return logic_wardrobe_gun:GetSkinIdByWeaponID(WeaponID)
  else
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    return FashionBagEditUtils:GetSkinIDByWeaponID(WeaponID)
  end
  return 0
end
function WardrobeGun:OnFashionBagEditExit(_, __)
  WardrobeGun.__super.OnFashionBagEditExit(self, _, __)
  self:UpdateTabUI()
end
function WardrobeGun:UpdateTabUI(_, __)
  self:InitGunID()
  self:RefreshGunTypeComboBox()
  self:UpdateGunList(self.CurrentGunType)
  self:RefreshCommonTab()
  self:RefreshShareBagTips()
end
function WardrobeGun:RefreshCommonTab()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local WardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode()
  local bShowBagModeTabPanel = WardrobeEditMode == wardrobe_macro.EWardrobeEditMode.None or WardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Inherit
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_BagMode, bShowBagModeTabPanel)
  self:SetWidgetVisible(self.UIRoot.Common_Tab_BagMode, bShowBagModeTabPanel)
end
function WardrobeGun:UpdateShareSlotList()
  log(bWriteLog and "WardrobeGun:UpdateShareSlotList")
  self:RefreshCommonTab()
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local bShowSubscribeShare = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.ShareBag
  if not bShowSubscribeShare then
    return
  end
  local share_bag_macros = require("client.slua.logic.share_bag.share_bag_macros")
  local originShareItemList = WardrobeLogicManager:GetShareBagItemList()
  self.shareItemList = {}
  local shareItemList = self.shareItemList
  if originShareItemList then
    for _, v in pairs(originShareItemList) do
      if v then
        table.insert(shareItemList, v)
      end
    end
    self.sharedItemCount = #shareItemList
    for i = #shareItemList + 1, share_bag_macros.MAX_ITEM_COUNT_PER_SHARE_TYPE do
      table.insert(shareItemList, 0)
    end
  else
    self.sharedItemCount = 0
    for i = 1, share_bag_macros.MAX_ITEM_COUNT_PER_SHARE_TYPE do
      table.insert(shareItemList, 0)
    end
  end
  self.LoopScrollGridShareSlot:SetData(shareItemList)
  if self.UIRoot.TextBlock_ShareCount then
    self.UIRoot.TextBlock_ShareCount:SetText(LocUtil.LocalizeResFormat(49062, self.sharedItemCount, share_bag_macros.MAX_ITEM_COUNT_PER_SHARE_TYPE))
  end
end
function WardrobeGun:RefreshShareSlot()
  if self.UIRoot.WidgetSwitcher_LeftPanel then
    local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    local eWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode()
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    local bShowShareBag = eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag
    self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_LeftPanel, bShowShareBag, false)
  end
end
function WardrobeGun:OnShareSlotDrop(dragWidget, index, dragDropData)
  log(bWriteLog and "WardrobeGun:OnShareSlotDrop")
  log(bWriteLog and "WardrobeGun:OnAvatarSlotDrop")
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  local dragAvatarInsID = tonumber(dragDropData.dragExtendData)
  local avatarData = WardrobeDataManager:GetHallDepotItemDataByInsID(dragAvatarInsID)
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe_new:SetClickItemInsId(dragAvatarInsID)
  self:PutWeaponDataToSlot(dragAvatarInsID, index, avatarData)
  self:EndAvatarDragHint()
  local itemData = WardrobeDataManager:GetHallDepotItemDataByInsID(dragAvatarInsID)
  if itemData then
    local i, data = self:GetItemIndexByInsIdAndResId(itemData.insID, itemData.resID)
    if i ~= -1 then
      self.LoopScrollGrid_Normal:RefreshAllItems()
    end
  end
  self:PlayAudio(sound_config.click_v1)
end
function WardrobeGun:GetShareSlotData(index)
  return self.LoopScrollGridShareSlot:GetItemData(index)
end
function WardrobeGun:OnShareSlotDrag(dragWidget, index, generatedWidget, dragDropData)
  log(bWriteLog and "WardrobeGun:OnAvatarSlotDrag")
  local avatarSlotData = self:GetShareSlotData(index)
  self:InitDragWidget(generatedWidget, avatarSlotData)
  self:BeginAvatarDragHint(0)
end
function WardrobeGun:OnShareSlotRemove(dragWidget, index, dragDropData)
  log(bWriteLog and "WardrobeGun:OnAvatarSlotRemove")
  local avatarSlot = index
  local resID = tonumber(dragDropData.dragExtendData)
  self:RemoveWeaponDataFromSlot(resID, avatarSlot)
  self:EndAvatarDragHint()
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = WardrobeDataManager:GetHallDepotItemDataByResID(resID)
  if itemData then
    local i, data = self:GetItemIndexByInsIdAndResId(itemData.insID, itemData.resID)
    if i ~= -1 then
      self.LoopScrollGrid_Normal:RefreshItem(i, data)
    end
  end
  self:PlayAudio(sound_config.click_v1)
end
function WardrobeGun:OnGunItemDragReadyToShape(dragWidget, index, generatedWidget, dragDropData)
  log(bWriteLog and "WardrobeGun:OnGunItemDragReadyToShape")
  local itemData = self:GetItemData(index)
  self:InitDragWidget(generatedWidget, itemData.res_id)
  self:BeginAvatarDragHint(1)
end
function WardrobeGun:OnGunItemDragCanceled()
  log(bWriteLog and "WardrobeGun:OnAvatarDragCanceled")
  self:EndAvatarDragHint()
end
function WardrobeGun:BeginAvatarDragHint(selection)
  local widgetSwitcherDrag = self.UIRoot.WidgetSwitcher_AvatarDrag
  widgetSwitcherDrag:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  widgetSwitcherDrag:SetActiveWidgetIndex(selection)
end
function WardrobeGun:EndAvatarDragHint()
  local widgetSwitcherDrag = self.UIRoot.WidgetSwitcher_AvatarDrag
  widgetSwitcherDrag:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
end
function WardrobeGun:GetItemData(index)
  return self.LoopScrollGrid_Normal:GetItemData(index)
end
function WardrobeGun:InitDragWidget(widget, itemId)
  if not itemId then
    return
  end
  local icon = widget.Image_Icon
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  if itemCfg then
    self:SetTexture(icon, itemCfg.ItemSmallIcon)
    self:SetWidgetVisible(icon, true, false)
  end
end
function WardrobeGun:PutWeaponDataToSlot(insId, index, avatarData)
  if not (insId and index) or not avatarData then
    return
  end
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if logic_wardrobe_new:PutItemToShareList(avatarData.resID, index) then
    self:UpdateShareSlotList()
  end
end
function WardrobeGun:RemoveWeaponDataFromSlot(resId, avatarSlot)
  if not resId then
    return
  end
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if logic_wardrobe_new:RemoveItemFromShareList(resId) then
    self:UpdateShareSlotList()
  end
end
function WardrobeGun:OnRefreshShareSlotItem(widget, index)
  local itemId = self.LoopScrollGridShareSlot:GetItemData(index)
  local dragDropItem = widget.CommonDragDropItem
  local isShared = index <= self.sharedItemCount
  if isShared and itemId ~= 0 then
    dragDropItem:SetDragEnable(true)
    dragDropItem:RegisterDrag(1, 0, 0, itemId)
  else
    dragDropItem:SetDragEnable(false)
    dragDropItem:RegisterDrag(1, 0, 0, "")
  end
  dragDropItem:SetEnable(true)
  dragDropItem:RegisterDrop(1)
  self:InitSlotItemView(widget, index, itemId, isShared)
end
function WardrobeGun:InitSlotItemView(widget, index, itemId, isShared)
  self:SetWidgetVisible(widget.TextBlock_Index, true, false)
  widget.TextBlock_Index:SetText(tostring(index))
  if isShared then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
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
function WardrobeGun:OnShareSkinModRefresh(_, _, eWardrobeEditMode)
  log(bWriteLog and string.format("WardrobeGun:OnShareSkinModRefresh. eWardrobeEditMode=%s", eWardrobeEditMode))
  self:RefreshShareSlot()
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bShowSubscribeShare = eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag
  self:RefreshShareBagTips(eWardrobeEditMode)
  if bShowSubscribeShare then
    self:UpdateShareSlotList()
  end
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  self:SetWidgetVisible(self.UIRoot.Common_Tab_BagMode, eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.None)
end
function WardrobeGun:InitView(node_widget, itemData, index, blockClick)
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
  local itemCfg = CDataTable.GetTableData("Item", itemData.res_id)
  local tExtraData = itemData.extra or {}
  tExtraData.bIsShowTip = false
  tExtraData.bIsShowBigIcon = self:IsShowBigIcon()
  function tExtraData.fCheckIconScaleCallback(nItemId, sIconPath, iconWidget)
    local UIUtil = require("client.common.ui_util")
    UIUtil.CheckAndUpdateIconScale(nItemId, sIconPath, iconWidget, 1)
  end
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
    local currentCommonItemsUibp = node_widget._cObj_ui
    local icon = currentCommonItemsUibp and currentCommonItemsUibp.UIRoot and currentCommonItemsUibp.UIRoot.Image_Icon or nil
    local callback = function(texturePath)
      if widget then
        local LoadTexture = import("LoadTexture")
        local Texture = LoadTexture.GetTexture2DFromDiskFile(texturePath)
        if Texture then
          widget:SetIconFromTexture(Texture, true)
          local Client = import("ScriptHelperClient")
          if slua.isValid(icon) and Client.RemoveKnownMissingPackageRefObjectByObj then
            Client.RemoveKnownMissingPackageRefObjectByObj(icon)
          end
          if icon then
            icon:SetRenderAngle(0)
            icon:SetRenderScale(FVector2D(1.0, 1.0))
          end
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
function WardrobeGun:OnPostInitView(widget, itemData)
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
    widget:SetUsingState(bInTryMap)
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
function WardrobeGun:OnShareBagListUpdate()
  self:UpdateShareSlotList()
end
function WardrobeGun:RefreshShareBagTips(wardrobeEditMode)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  wardrobeEditMode = wardrobeEditMode or WardrobeLogicManager:GetWardrobeEditMode() or wardrobe_macro.EWardrobeEditMode.None
  local bShowSubscribeShare = wardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag
  if self.UIRoot.CanvasPanel_SharePackageTips then
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    local bShowSubscribeShare = wardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_SharePackageTips, bShowSubscribeShare)
  end
end
function WardrobeGun:LocalUpdateWeaponOnShareBag(NewInstID, WeaponID, planID, isPutOn)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemData = wardrobe_data:GetValidHallDepotItemDataByInsID(NewInstID)
  local SkinResID = 0
  if isPutOn then
    SkinResID = ItemData and ItemData.resID
  end
  local WeaponWearInfo = {weaponId = WeaponID, skinId = SkinResID}
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.EquipWeapon(DataMgr.roleData.uid, WeaponWearInfo, nil, true)
  local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if WeaponDiySystem:IsDIYWeapon(SkinResID) then
    local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
    if planID then
      local scheme = WeaponDiySystem:GetSchemeData(SkinResID, planID)
      local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
      local avatar = TeamAvatarManager.GetAvatarByUid(DataMgr.roleData.uid)
      if avatar then
        avatar:ChangeDiyWeaponScheme(scheme)
      end
    end
  end
end
function WardrobeGun:OnSelfUsingWeaponChange(_, __)
  self:UpdatePendantTab()
end
local class = require("class")
local ui_subtab_item_list_base = require("client.slua.umg.Wardrobe.subtab_item_list_base")
local CWardrobeGun = class(ui_subtab_item_list_base, nil, WardrobeGun)
return CWardrobeGun