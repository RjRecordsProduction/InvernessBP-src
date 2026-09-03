local WardrobeBagBase = {}
local BindRelationIcon = {
  [0] = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_Icon_Link_Joint_png.WH_Icon_Link_Joint_png",
  [1] = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_Icon_Link_Off_png.WH_Icon_Link_Off_png"
}
function WardrobeBagBase:OnInitialize()
  log(bWriteLog and "WardrobeBagBase:OnInitialize")
  WardrobeBagBase.__super.OnInitialize(self)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  self:OnOpenBag(fashionbag_data:GetFashionBagUseIndex())
end
function WardrobeBagBase:RegistEvents()
  WardrobeBagBase.__super.RegistEvents(self)
  if self.UIRoot.Button_Link then
    self:AddOnClickedEventByControl(self.UIRoot.Button_Link, self.OnBtnLinkClick, self)
  end
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_EQUIPMENT_LEVEL, self.OnRefreshEquipmentLevel, self)
  self:AddCommonEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_BTN_CLICK, self.HandleGuideBtnClick, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOW_FASHION_BAG, self.OnWardrobeShowFashionBag, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_TAG_CLEAR_TIPS, self.TryShowNewbieGuide, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_TAG_SHOW_TIPS, self.CloseNewbieGuide, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_VIEWPORT_SIZE_CHANGED, self.OnScreenRatioChanged, self)
end
function WardrobeBagBase:OnShow()
  WardrobeBagBase.__super.OnShow(self)
  self:AddTimerOnce(0.75, function()
    local topUIName = UIManager.GetTopUIName()
    if topUIName == UIManager.UI_Config.wardrobe.keyName then
      self:TryShowNewbieGuide()
    else
      log(bWriteLog and "WardrobeBagBase:OnShow current top ui is not wardrobe main, do not show newbie guide")
    end
  end)
end
function WardrobeBagBase:OnClose()
  self:CloseNewbieGuide()
  WardrobeBagBase.__super.OnClose(self)
end
function WardrobeBagBase:OnFashionBagChange()
  WardrobeBagBase.__super.OnFashionBagChange(self)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  self:OnOpenBag(fashionbag_data:GetFashionBagUseIndex())
end
function WardrobeBagBase:OnRefreshEquipmentLevel(eventType, eventID)
  self:RefreshEquipmentLevel()
end
function WardrobeBagBase:RefreshEquipmentLevel()
  if self:NeedRefreshAvatarListWhenLevelChanged() then
    WardrobeBagBase.__super.UpdateAvatarList(self)
  end
end
function WardrobeBagBase:GetCurItemID(data)
  local itemSubType = data.itemSubType
  if not itemSubType or itemSubType == 0 then
    local itemData = CDataTable.GetTableData("Item", data.res_id)
    if itemData then
      itemSubType = itemData.ItemSubType
    end
  end
  local resID = self:GetEquipmentItemIDBySkinInsID(itemSubType, data.ins_id)
  if 0 < resID then
    return resID
  end
  return data.res_id or 0
end
function WardrobeBagBase:GetEquipmentItemIDBySkinInsID(itemSubType, itemInsID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local level = self:GetEquipmentItemShowLevel(itemSubType)
  local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(itemInsID)
  if itemInfo ~= nil then
    local itemMappingCfg = CDataTable.GetTableData("BackpackMapping", itemInfo.resID)
    if itemMappingCfg ~= nil then
      return itemMappingCfg["SkinItemIDLv" .. level] or -1
    end
  end
  return -1
end
function WardrobeBagBase:OnOpenBag(bagIndex)
  self:WatchBag(bagIndex)
  self:UpdateBindRelation()
end
function WardrobeBagBase:WatchBag(bagIndex)
end
function WardrobeBagBase:UpdateAvatarList()
  WardrobeBagBase.__super.UpdateAvatarList(self)
  self:UpdateLevelPanelShow()
end
function WardrobeBagBase:UpdateLevelPanelShow()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local simpleUI_Clothes = UIManager.GetUI(UIManager.UI_Config.Lobby_SimpleUI_Clothes_UIBP)
  if WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.ShareBag or simpleUI_Clothes then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_BagLevelPanel, false, false)
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_BagLevelPanel, true, false)
  end
end
function WardrobeBagBase:GetEquipmentItemShowLevel(ItemSubType)
  local Level = 3
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local bInFashionEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
  if not bInFashionEditMode then
    local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
    Level = logic_wardrobe_avatar:GetEquipmentItemShowLevel(ItemSubType)
  else
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    Level = FashionBagEditUtils:GetEquipmentItemShowLevel(ItemSubType)
  end
  return Level
end
function WardrobeBagBase:OnBtnLinkClick()
  self:PlayAudio(sound_config.click_v1)
  log(bWriteLog and "WardrobeBagBase:OnBtnLinkClick")
  local bind, type = self:GetBindRelation()
  if not type then
    log_error("WardrobeBagBase:OnBtnLinkClick error " .. tostring(bind) .. tostring(type))
    return
  end
  local newBind
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if bind == HallThemeUtils.CONST_RELATION_OP_TYPE.UNBIND then
    newBind = HallThemeUtils.CONST_RELATION_OP_TYPE.BIND
  else
    newBind = HallThemeUtils.CONST_RELATION_OP_TYPE.UNBIND
  end
  if not bind then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWardrobeFirstUpdateBindRelation)
    if not data or not data.hasShow then
      do
        local title = LocUtil.GetLocalizeResStr(101001)
        local content = LocUtil.GetLocalizeResStr(69716)
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        CommonMsgBoxMgr.Show(2, title, content, function()
          PlayerPrefsSystem.SaveTableToFile_N({hasShow = true}, PlayerPrefsSystem.ePlayerPrefsType.eWardrobeFirstUpdateBindRelation)
          self:ChangeBindRelation(newBind, type)
        end)
        return
      end
    end
  end
  self:ChangeBindRelation(newBind, type)
end
function WardrobeBagBase:ChangeBindRelation(newBind, type)
  log(bWriteLog and "WardrobeBagBase:ChangeBindRelation " .. tostring(newBind))
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local bInFashionEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
  if not bInFashionEditMode then
    local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
    WardRobeHandler.send_change_bind_relation_req(newBind, type):Then(function()
      self:UpdateBindRelation()
      self:_FinishBindRelationNewbieGuide()
    end)
  else
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    FashionBagEditUtils:SetDepotBindRelation(type, newBind)
    self:UpdateBindRelation()
    self:_FinishBindRelationNewbieGuide()
  end
end
function WardrobeBagBase:_FinishBindRelationNewbieGuide()
  self:CloseNewbieGuide()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWardrobeBindRelationNewbieGuide)
  if not data then
    PlayerPrefsSystem.SaveTableToFile_N({hasShow = true}, PlayerPrefsSystem.ePlayerPrefsType.eWardrobeBindRelationNewbieGuide)
    log(bWriteLog and "WardrobeBagBase:_FinishBindRelationNewbieGuide saved newbie guide record")
  end
end
function WardrobeBagBase:GetBindRelation()
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local type
  if self.subTabConfig.subTabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_helmet then
    type = HallThemeUtils.CONST_RELATION_TYPE.HELMET
  elseif self.subTabConfig.subTabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_bag then
    type = HallThemeUtils.CONST_RELATION_TYPE.BAG
  end
  local bind = HallThemeUtils.GetBindRelation(type)
  return bind, type
end
function WardrobeBagBase:UpdateBindRelation()
  local bind, type = self:GetBindRelation()
  log(bWriteLog and "WardrobeBagBase:UpdateBindRelation: " .. tostring(bind) .. tostring(type))
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local bInFashionBagEditMode = WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
  local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for i = 1, 3 do
    local widgetName = "Image_Link0" .. tostring(i)
    if self.UIRoot[widgetName] and bind and BindRelationIcon[bind] then
      self:SetTexture(self.UIRoot[widgetName], BindRelationIcon[bind])
    end
    local Skin
    if not bInFashionBagEditMode then
      if type == HallThemeUtils.CONST_RELATION_TYPE.HELMET then
        if not bind then
          Skin = fashionbag_data:GetHelmetSkin()
        else
          Skin = fashionbag_data:GetHelmetSkinByLevel(i)
        end
      elseif type == HallThemeUtils.CONST_RELATION_TYPE.BAG then
        if not bind then
          Skin = fashionbag_data:GetBagSkin()
        else
          Skin = fashionbag_data:GetBagSkinByLevel(i)
        end
      end
    else
      local BagData = FashionBagEditUtils.CurrentBagData
      if BagData then
        if type == HallThemeUtils.CONST_RELATION_TYPE.HELMET then
          Skin = BagData.helmet_skin_list[i]
        elseif type == HallThemeUtils.CONST_RELATION_TYPE.BAG then
          Skin = BagData.bag_skin_list[i]
        end
      end
    end
    local data = wardrobe_data:GetHallDepotItemDataByInsID(Skin)
    log(bWriteLog and string.format("WardrobeBagBase:UpdateBindRelation i:%s  Skin: %s bInFashionBagEditMode: %s type: %s", i, Skin, bInFashionBagEditMode, type))
    if not data then
      log(bWriteLog and "invalid Skin = " .. tostring(Skin))
      self:UpdateItemIcon(0, i, type)
    else
      self:UpdateItemIcon(data.resID, i, type)
    end
  end
end
function WardrobeBagBase:UpdateItemIcon(resID, level, type)
  local defaultItem, itemIcon
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if type == HallThemeUtils.CONST_RELATION_TYPE.HELMET then
    defaultItem = "WidgetSwitcher_Helmet_" .. tostring(level)
    itemIcon = "Image_Helmet_" .. tostring(level)
  elseif type == HallThemeUtils.CONST_RELATION_TYPE.BAG then
    defaultItem = "WidgetSwitcher_Bag_" .. tostring(level)
    itemIcon = "Image_Bag_" .. tostring(level)
  end
  if not (defaultItem and itemIcon and self.UIRoot[defaultItem]) or not self.UIRoot[itemIcon] then
    log(bWriteLog and "WardrobeBagBase:UpdateItemIcon not widget " .. tostring(defaultItem) .. " " .. tostring(itemIcon))
    return
  end
  if not resID or resID == 0 then
    self:SetWidgetVisible(self.UIRoot[defaultItem], true)
    self:SetWidgetVisible(self.UIRoot[itemIcon], false)
  else
    self:SetWidgetVisible(self.UIRoot[defaultItem], false)
    self:SetWidgetVisible(self.UIRoot[itemIcon], true)
    local LevelRes = DataMgr.GetEquipmentItemIDByResID(level, resID)
    local itemCfg = CDataTable.GetTableData("Item", LevelRes)
    if itemCfg then
      local UIUtil = require("client.common.ui_util")
      local itemCfgPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(itemCfg.itemId, self.UIRoot[itemIcon])
      self:SetTexture(self.UIRoot[itemIcon], itemCfgPath, {bHasAddKnownMissing = bHasAddKnownMissing})
    end
  end
end
function WardrobeBagBase:OnUpdatePutOnData(eventType, eventID, putOnItem, putDownItem)
  WardrobeBagBase.__super.OnUpdatePutOnData(self, eventType, eventID, putOnItem, putDownItem)
  self:UpdateBindRelation()
end
function WardrobeBagBase:OnUpdatePutDownData(eventType, eventID, putDownItem)
  WardrobeBagBase.__super.OnUpdatePutDownData(self, eventType, eventID, putDownItem)
  self:UpdateBindRelation()
end
local MergeData = function(originData, newData)
  for k, v in pairs(newData) do
    originData[k] = v
  end
end
function WardrobeBagBase:UpdateOneItem(itemData)
  local index, data = self:GetItemIndexByInsId(itemData.ins_id)
  if index ~= -1 then
    itemData.ins_id = nil
    itemData.res_id = nil
    MergeData(data, itemData)
    self.LoopScrollGrid_Normal:RefreshItem(index, data)
  end
end
function WardrobeBagBase:OnFashionBagEditUpdate(_, __)
  WardrobeBagBase.__super.OnFashionBagEditUpdate(self, _, __)
  self:UpdateBindRelation()
end
function WardrobeBagBase:OnFashionBagEditExit(_, __)
  WardrobeBagBase.__super.OnFashionBagEditExit(self, _, __)
  self:UpdateBindRelation()
  self:UpdateLevelPanelShow()
end
function WardrobeBagBase:OnScreenRatioChanged()
  self:CloseNewbieGuide()
  self:TryShowNewbieGuide()
end
function WardrobeBagBase:TryShowNewbieGuide()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWardrobeBindRelationNewbieGuide)
  if data then
    return
  end
  if UIManager.IsUIShow(UIManager.UI_Config.displaysetting) then
    log(bWriteLog and "WardrobeBagBase:TryShowNewbieGuide has display setting tips")
    return
  end
  if UIManager.IsUIShow(UIManager.UI_Config.fashion_bag_overview) then
    log(bWriteLog and "WardrobeBagBase:TryShowNewbieGuide has display fashion_bag_overview panel")
    return
  end
  log(bWriteLog and "WardrobeBagBase:TryShowNewbieGuide")
  local params = {
    uTargetWidget = self.UIRoot.Button_Link,
    uClickWidget = self.UIRoot.Button_Link,
    textID = LocUtil.GetLocalizeResStr(69717),
    bHideButtonBack = true
  }
  self.GuideID = "BindRelationNewbieGuide"
  self.newbieGuideUI = UIManager.ShowUI(UIManager.UI_Config.Common_NewbieGuide_Bubble_UIBP, self.GuideID, params)
end
function WardrobeBagBase:CloseNewbieGuide()
  if self.newbieGuideUI then
    self.newbieGuideUI:CloseSelf()
    self.newbieGuideUI = nil
    log(bWriteLog and "WardrobeBagBase:CloseNewbieGuide")
  end
end
function WardrobeBagBase:HandleGuideBtnClick(EventType, EventID, GuideID)
  if GuideID and GuideID == self.GuideID then
    log(bWriteLog and "WardrobeBagBase:HandleGuideBtnClick")
    self:CloseNewbieGuide()
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N({hasShow = true}, PlayerPrefsSystem.ePlayerPrefsType.eWardrobeBindRelationNewbieGuide)
  end
end
function WardrobeBagBase:OnWardrobeShowFashionBag()
  self:CloseNewbieGuide()
end
function WardrobeBagBase:OnWardrobeBackFashionBag()
  WardrobeBagBase.__super.OnWardrobeBackFashionBag(self)
  self:TryShowNewbieGuide()
end
function WardrobeBagBase:NeedRefreshAvatarListWhenLevelChanged()
  return true
end
local class = require("class")
local ui_subtab_avatar = require("client.slua.umg.Wardrobe.subtab_avatar")
local CWardrobeBagBase = class(ui_subtab_avatar, nil, WardrobeBagBase)
return CWardrobeBagBase