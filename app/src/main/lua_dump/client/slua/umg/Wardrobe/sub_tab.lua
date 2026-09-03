local SubTab = {}
local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
function SubTab:ctor(selfType, tabConfig, jumpSubTabId)
  self.  self.iconItemID = nil
  self.end
function SubTab:OnInitialize()
  log(bWriteLog and "SubTab:Initialize")
  self:SetWidgetVisible(self.UIRoot.Image_ItemIcon, false)
  self:SetWidgetVisible(self.UIRoot.Image_Icon, true)
  self.UIRoot.Button_SubTab:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.UIRoot.Image_Selected:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:UpdateTabIcon(false)
end
function SubTab:RegistEvents()
  SubTab.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SubTab, self.OnClick, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SubTab_Clicked, self.OnSubTabClicked, self)
  self:AddCommonEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_UPDATE_DRESS_STATE, self.OnStateUpdate, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_DOWN_DATA, self.OnClothesUpdate, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_ON_DATA, self.OnClothesUpdate, self)
  local tabID = self.tabConfig.subTabId
  local tabEquip = self:GetEquipTab(tabID)
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  self.UIRoot.Reddot_Anchor:ShowRedPointByPath(wardrobe_red_point.C_Wardrobe_RedPoint_Style)
  local tabRedPoint = wardrobe_red_point:GetTab(tabID)
  if tabRedPoint then
    local validityCheck = function()
      if self:InInheritMode() then
        return false
      end
      return true
    end
    tabRedPoint:RegisterWidget(self.UIRoot.Reddot_Anchor, validityCheck)
  end
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bInWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
  if tabEquip then
    if self.tabConfig.refreshIcon then
      self:AddDataListener(tabEquip, "instanceID", function(oldValue, value)
        log(bWriteLog and "SubTab:RegistEvents. InstanceID change")
        bInWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
        if not bInWardrobeEditMode then
          self:RefreshTabIcon(oldValue, value)
        end
      end)
      self:AddDataListener(tabEquip, "level", function(oldValue, value)
        bInWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
        if not bInWardrobeEditMode then
          self:RefreshTabIcon(nil, tabEquip.instanceID)
        end
      end)
    end
  else
    log_error(string.format("Can't find tabEquip of '%s'", tabID))
  end
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_SINGLE_ITEM_UPDATE_TAB, self.OnFashionBagEditTabUpdate, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_EXIT, self.OnFashionBagEditTabExit, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_ENTER, self.OnFashionBagEditTabEnter, self)
end
function SubTab:UpdateTabIcon(selected)
  if selected then
    self:SetTexture(self.UIRoot.Image_Icon, self.tabConfig.tabIconSelect, {sync = false})
  else
    self:SetTexture(self.UIRoot.Image_Icon, self.tabConfig.tabIconNormal, {sync = false})
  end
end
function SubTab:RefreshTabIcon(oldInsID, insID)
  log(bWriteLog and "SubTab:RefreshTabIcon insID = " .. tostring(insID) .. " " .. tostring(self.tabConfig.subTabId))
  local icon = self.UIRoot.Image_ItemIcon
  local iconNormal = self.UIRoot.Image_Icon
  if insID == 0 then
    self.iconItemID = nil
    icon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    iconNormal:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    local item = WardrobeDataManager:GetHallDepotItemDataByInsID(insID)
    if item then
      self.iconItemID = item.resID
      local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
      local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
      local bInWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
      local resID
      if not bInWardrobeEditMode then
        resID = logic_wardrobe_avatar:GetCurrentLevelEquipemntResID(item.resID)
      else
        local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
        resID = FashionBagEditUtils:GetCurrentLevelEquipmentResID(item.resID)
      end
      local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
      if LogicXSuit.IsXSuit(resID) then
        resID = LogicXSuit.GetItemShowID(insID)
        self.iconItemID = resID
      end
      local itemCfg = CDataTable.GetTableData("Item", resID)
      if itemCfg then
        local UIUtil = require("client.common.ui_util")
        local itemCfgPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(itemCfg.itemId, icon)
        local params = {sync = bHasAddKnownMissing, bHasAddKnownMissing = bHasAddKnownMissing}
        self:SetTexture(icon, itemCfgPath, params)
        icon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        iconNormal:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      else
        icon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        iconNormal:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.iconItemID = nil
      end
    end
    self:OnClothesUpdate()
  end
end
function SubTab:OnPostInitialize()
  if self.jumpSubTabId ~= nil then
    if self.jumpSubTabId == self.tabConfig.subTabId then
      self:OnClick()
    end
  else
    local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    if logic_wardrobe:GetWardrobeEditMode() ~= wardrobe_macro.EWardrobeEditMode.FashionBag then
      if self.tabConfig.defaultSelected then
        self:OnClick()
      end
    elseif self.tabConfig.defaultSelectedInEditMode then
      self:OnClick()
    end
  end
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bInWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
  if bInWardrobeEditMode then
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    local InsID = FashionBagEditUtils:GetInstanceIDInBagEditBySubTabString(self.tabConfig.subTabId)
    self:RefreshTabIcon(nil, InsID)
  end
  self:RefreshShareCount(false)
end
function SubTab:OnClick()
  self:PlayAudio(sound_config.subTab_v1)
  self:PlayUserWidgetAnimation(self.UIRoot.fadein, 0, 1, 0, 1)
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe:ChangeToLobbyScene(self.tabConfig.subTabId)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SubTab_Clicked, self.tabConfig)
  if UIManager.GetUI(UIManager.UI_Config.Lobby_SimpleUI_Clothes_UIBP) then
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_SIMPLEUI_CLOTHES_SUBTAB_CLICKED, self.tabConfig)
  end
  if UIManager.GetUI(UIManager.UI_Config.Lobby_Subhall_Cloth_UIBP) then
    EventSystem:postEvent(EVENTTYPE_SUBHALL, EVENTID_SUBHALL_CLOTH_SUBTAB_CLICKED, self.tabConfig)
  end
  logic_wardrobe:SetCurrentTabId(self.tabConfig.subTabId)
  if self.tabConfig and self.tabConfig.pageId then
    logic_wardrobe:SetCurrentPageId(self.tabConfig.pageId)
  end
  self.UIRoot.Button_SubTab:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Image_Selected:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:UpdateTabIcon(true)
end
function SubTab:GetEquipTab(tabID)
  local tabSurveillance = require("client.slua.logic.wardrobe.tab_surveillance")
  return tabSurveillance.GetTabEquip(tabID)
end
function SubTab:OnSubTabClicked(eventType, eventID, subTabConfig)
  if subTabConfig.pageId ~= self.tabConfig.pageId or subTabConfig.subTabId ~= self.tabConfig.subTabId then
    self.UIRoot.Button_SubTab:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.Image_Selected:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:UpdateTabIcon(false)
  end
end
function SubTab:OnStateUpdate(_, _, period)
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  log(bWriteLog and "SubTab:OnStateUpdate  period = " .. tostring(period) .. "  iconItemID = " .. tostring(self.iconItemID))
  local tabEquip = self:GetEquipTab(self.tabConfig.subTabId)
  local source = WardrobeDataManager:GetItemSource(tabEquip.instanceID)
  local item = LogicXSuit.GetItemIDByPeriod(period, source)
  if not item or item ~= self.iconItemID then
    return
  end
  item = LogicXSuit.ChangeItemIDByMyselfState(item, source)
  if item then
    local icon = self.UIRoot.Image_ItemIcon
    local UIUtil = require("client.common.ui_util")
    local itemCfgPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(item, icon)
    self:SetTexture(icon, itemCfgPath, {bHasAddKnownMissing = bHasAddKnownMissing})
  end
end
function SubTab:OnClothesUpdate()
  log(bWriteLog and "  SubTab:OnClothesUpdate. self.iconItemID: " .. tostring(self.iconItemID))
  local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
  local clothes, hatId, specialHat = golden_suit_module:GetSpecialClothesAndHat()
  local icon = self.UIRoot.Image_ItemIcon
  local UIUtil = require("client.common.ui_util")
  if specialHat and hatId == self.iconItemID then
    local itemCfgPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(specialHat, icon)
    self:SetTexture(icon, itemCfgPath, {bHasAddKnownMissing = bHasAddKnownMissing})
  elseif self.iconItemID then
    local itemCfgPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(self.iconItemID, icon)
    self:SetTexture(icon, itemCfgPath, {bHasAddKnownMissing = bHasAddKnownMissing})
  end
end
function SubTab:RefreshShareCount(bShow, count)
  self:SetWidgetVisible(self.UIRoot.TextBlock_Quantity, bShow, false)
  self.UIRoot.TextBlock_Quantity:SetText(count or 0)
end
function SubTab:OnFashionBagEditTabUpdate(_, _, WardrobeTab, InsID)
  if not self.tabConfig.refreshIcon then
    return
  end
  if not self.tabConfig.bRefreshIconOnEditMode then
    return
  end
  if not self.tabConfig or self.tabConfig.subTabId ~= WardrobeTab then
    return
  end
  self:RefreshTabIcon(nil, InsID)
end
function SubTab:OnFashionBagEditTabExit()
  if not self.tabConfig.refreshIcon then
    return
  end
  local tabSurveillance = require("client.slua.logic.wardrobe.tab_surveillance")
  local TabEquip = tabSurveillance.GetTabEquip(self.tabConfig.subTabId)
  if TabEquip then
    self:RefreshTabIcon(nil, TabEquip.instanceID)
  end
end
function SubTab:OnFashionBagEditTabEnter()
  self:RefreshTabIcon(nil, 0)
end
local class = require("class")
local baseTab = require("client.slua.umg.Wardrobe.base_tab")
local CSubTab = class(baseTab, nil, SubTab)
return CSubTab