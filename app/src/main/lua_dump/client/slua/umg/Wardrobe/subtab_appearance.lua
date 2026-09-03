local WardrobeAppearance = {}
local WardrobeLogicAppearance = require("client.slua.logic.wardrobe.logic_wardrobe_appearance")
local AppearanceType = WardrobeLogicAppearance.AppearanceType
local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local SubTabString = wardrobe_macro.ENUM_WardrobeSubTabString
local TopTitle = {
  [AppearanceType.Head] = LocUtil.GetLocalizeResStr(69095),
  [AppearanceType.Hair] = LocUtil.GetLocalizeResStr(69096),
  [AppearanceType.Beard] = LocUtil.GetLocalizeResStr(69097)
}
local LimitSlot = {
  [AppearanceType.Head] = {
    [1] = 1
  },
  [AppearanceType.Hair] = {
    [2] = 1,
    [3] = 1,
    [4] = 1
  },
  [AppearanceType.Beard] = {
    [2] = 1,
    [3] = 1,
    [4] = 1
  }
}
local ColorConfig = {
  [AppearanceType.Hair] = AppearanceType.HairColor,
  [AppearanceType.Beard] = AppearanceType.BeardColor
}
local subTabId2AppearanceType = {
  [SubTabString.Enum_WardrobeSubTabString_Head] = AppearanceType.Head,
  [SubTabString.Enum_WardrobeSubTabString_Hair] = AppearanceType.Hair,
  [SubTabString.Enum_WardrobeSubTabString_Beard] = AppearanceType.Beard,
  [SubTabString.Enum_WardrobeSubTabString_UnderWear] = AppearanceType.UnderCloth
}
local ItemStatus = {
  Unused = 1,
  Used = 2,
  Locked = 3,
  LockTry = 4
}
local ENUM_SubTab = {UnderCloth = 1, UnderPants = 2}
function WardrobeAppearance:ctor(_, args)
  self.AppearanceType = AppearanceType.Head
  if args and args.subTabId then
    self.AppearanceType = subTabId2AppearanceType[args.subTabId] or AppearanceType.Head
  end
  self.bCanModify = true
  self.bNeedPutOffHeadEquip = true
  self.bCanPutOff = false
  self.CurSubTab = ENUM_SubTab.UnderCloth
  self.selectColorIndex = nil
  self.bShowTagFilter = false
  self.cachedAppearanceItems = {}
end
function WardrobeAppearance:OnInitialize()
  self.LoopScrollGrid_Normal = self:InitScrollBox(self.UIRoot.LoopScrollGrid_Avatar)
  self.LoopScrollGrid_Normal:SetRefreshItemCallback(self.OnRefreshListItem, self)
  self.LoopScrollGrid_Normal:AddItemWidgetChildEvent("Common_Item_BP", "OnClickItemCallback", self.OnClickItem, self)
  if self.UIRoot.CheckBox_Sort then
    self:RefreshCheckBoxState()
  end
  if self.AppearanceType == AppearanceType.UnderCloth or self.AppearanceType == AppearanceType.UnderPants then
    self.UIRoot.WidgetSwitcher_Title:SetActiveWidgetIndex(1)
    local tabList = {
      [1] = LocUtil.LocalizeResFormat(69714),
      [2] = LocUtil.LocalizeResFormat(69715)
    }
    self.Common_Tab_Underwear_Sel = self:InitHorizontalLevelTwoTextTab(self.UIRoot.Common_Tab_Underwear_Sel)
    self.Common_Tab_Underwear_Sel:SetTabs(tabList, self.CurSubTab)
    self.Common_Tab_Underwear_Sel:AddOnClickedCallback(self.OnClickHorizontalTabButton, self)
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    if AvatarData.GetGameGender() == LobbyAvatarManager.Enum_Sex.Male then
      self.CurSubTab = 2
      self.AppearanceType = AppearanceType.UnderPants
      self.Common_Tab_Underwear_Sel:SetChildShow(1, false)
      self.Common_Tab_Underwear_Sel:Select(self.CurSubTab)
    end
  else
    self.UIRoot.WidgetSwitcher_Title:SetActiveWidgetIndex(0)
  end
end
function WardrobeAppearance:RegistEvents()
  WardrobeAppearance.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_APPEARANCE, self.RefreshAppearance, self)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local myAvatar = TeamAvatarManager.GetMainAvatar()
  if myAvatar and myAvatar:GetModel() then
    self:AddControlEventByControl(myAvatar:GetModel(), "OnAvatarComponentAllMeshLoaded", self.OnAvatarEquipmentChange, self)
  end
end
function WardrobeAppearance:OnAvatarEquipmentChange()
  self:CheckCanModifyAppearance(self.AppearanceType)
end
function WardrobeAppearance:OnPostInitialize()
  WardrobeAppearance.__super.OnPostInitialize(self)
  self:CheckCanModifyAppearance(self.AppearanceType)
  self.bCanPutOff = self.AppearanceType == AppearanceType.UnderCloth or self.AppearanceType == AppearanceType.UnderPants
  WardrobeLogicAppearance:Init()
  if self.bNeedPutOffHeadEquip then
    WardrobeLogicAppearance:TakeOffMakeUp()
  end
  self:ShowCantChangeNotice()
  local appearanceType = self.AppearanceType
  if TopTitle[appearanceType] then
    self.UIRoot.TextBlock_Title:SetText(TopTitle[appearanceType])
    self.UIRoot.WidgetSwitcher_Title:SetActiveWidgetIndex(0)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Tips, true)
  end
  self:ScrollInit(self.LoopScrollGrid_Normal, self.AppearanceType)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Color, false)
  if ColorConfig[appearanceType] then
    self.ColorScroll = self:InitScrollBox(self.UIRoot.LoopScrollBox_0)
    self.ColorScroll:SetRefreshItemCallback(self.RefreshColorItem, self)
    self.ColorScroll:AddItemWidgetChildEvent("Button_0", "OnClicked", self.OnClickedColorItem, self)
    local colorType = ColorConfig[self.AppearanceType]
    self:ScrollInit(self.ColorScroll, colorType)
    self.selectColorIndex = self.ColorScroll:GetSelectIndex()
  end
end
function WardrobeAppearance:ShowCantChangeNotice()
  local TryShowNotice = function()
    if not self.bCanModify then
      ShowNotice(69102)
    end
  end
  if self.AppearanceType == AppearanceType.UnderCloth or self.AppearanceType == AppearanceType.UnderPants then
    self:AddTimerOnce(0.5, function()
      TryShowNotice()
    end)
  else
    TryShowNotice()
  end
end
function WardrobeAppearance:OnClose()
  WardrobeLogicAppearance:RestoreToOrigin()
  if self.bNeedPutOffHeadEquip then
    WardrobeLogicAppearance:TakeOnMakeUp()
  end
  WardrobeLogicAppearance:DeInit()
  self.cachedAppearanceItems = {}
end
function WardrobeAppearance:OnClickItem(widget, index)
  if not self.bCanModify then
    ShowNotice(69102)
    return
  end
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.WardrobeUndo) then
    return
  end
  log(bWriteLog and string.format("WardrobeAppearance:OnClickItem index=%s", tostring(index)))
  local avatarItem = self.LoopScrollGrid_Normal:GetItemData(index)
  if not avatarItem then
    return
  end
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  local curItemID
  if avatarItem.ItemId ~= 0 then
    local finalItemId = avatarItem.ItemId
    if avatarItem.UnderWearID and avatarItem.UnderWearID ~= 0 then
      finalItemId = avatarItem.UnderWearID
    end
    curItemID = finalItemId
    tipsMgr:Show(tipsMgr.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, nil, finalItemId)
  else
    tipsMgr:Hide()
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, curItemID)
  local CurSelectIndex = self.LoopScrollGrid_Normal:GetSelectIndex()
  local CurSelectData = self.LoopScrollGrid_Normal:GetItemData(CurSelectIndex)
  if CurSelectData and avatarItem.Owned and not CurSelectData.Owned then
    WardrobeLogicAppearance:RestoreToOrigin()
  end
  if not WardrobeLogicAppearance:HasEquipItemData(self.AppearanceType, avatarItem.AvatarId) then
    if avatarItem.Owned then
      WardrobeLogicAppearance:PutAvatar(avatarItem.AvatarId, self.AppearanceType)
    else
      WardrobeLogicAppearance:TryOnAvatar(avatarItem.AvatarType, avatarItem.AvatarId)
    end
  elseif self.AppearanceType == AppearanceType.UnderCloth or self.AppearanceType == AppearanceType.UnderPants then
    WardrobeLogicAppearance:PutAvatar(avatarItem.AvatarId, self.AppearanceType, false)
  end
  self.LoopScrollGrid_Normal:Select(index)
end
function WardrobeAppearance:OnClickedColorItem(widget, index)
  self:PlayAudio(sound_config.click_v1)
  if not self.bCanModify then
    ShowNotice(69102)
    return
  end
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.WardrobeUndo) then
    return
  end
  local scrollSelectedIndex = self.selectColorIndex
  if scrollSelectedIndex == index then
    return
  end
  local colorItem = self.ColorScroll:GetItemData(index)
  if not colorItem then
    return
  end
  local selectColorData = self.ColorScroll:GetItemData(scrollSelectedIndex)
  if not selectColorData then
    return
  end
  local selectAvatarItem = self.LoopScrollGrid_Normal:GetItemData(self.LoopScrollGrid_Normal:GetSelectIndex())
  if not selectAvatarItem then
    return
  end
  self.selectColorIndex = index
  local colorType = ColorConfig[self.AppearanceType]
  if WardrobeLogicAppearance:HasEquipItemData(self.AppearanceType, selectAvatarItem.AvatarId) then
    WardrobeLogicAppearance:PutAvatar(colorItem.AvatarId, colorType)
  else
    WardrobeLogicAppearance:TryOnAvatar(colorType, colorItem.AvatarId)
  end
end
function WardrobeAppearance:RefreshAppearance()
  if self.LoopScrollGrid_Normal then
    self.LoopScrollGrid_Normal:RefreshAllItems()
  end
  if self.ColorScroll then
    local colorType = ColorConfig[self.AppearanceType]
    local data = self:GetAppearanceItems(colorType)
    local index = self:GetAvatarSelectIndex(data, colorType)
    if self.ColorScroll:GetSelectIndex() ~= index then
      local curSelectColorItem = self.ColorScroll:GetItemData(self.ColorScroll:GetSelectIndex())
      local needSelectColorItem = self.ColorScroll:GetItemData(index)
      if not curSelectColorItem or not needSelectColorItem then
        return
      end
      self.ColorScroll:Select(index)
      self.selectColorIndex = index
    end
  end
end
function WardrobeAppearance:OnDownloadFinish(_, _, eventData)
  WardrobeAppearance.__super.OnDownloadFinish(self, _, _, eventData)
  local itemID = eventData.itemID
  if not itemID or tonumber(itemID) <= 0 then
    return
  end
  local avatarId = WardrobeLogicAppearance:GetAvatarIdByBodyID(itemID)
  if not avatarId then
    return
  end
  local avatarData = WardrobeLogicAppearance:GetAvatarDataById(avatarId)
  local appearance = avatarData.AvatarType
  local equipped = WardrobeLogicAppearance:HasEquipItemView(appearance, avatarId)
  if equipped then
    WardrobeLogicAppearance:ModifyAvatar(avatarData.AvatarType, avatarData)
  end
end
function WardrobeAppearance:ScrollInit(scrollComp, appearanceType)
  local Data = self:GetAppearanceItems(appearanceType)
  local equipId = WardrobeLogicAppearance:GetAppearanceEquipAvatarId(appearanceType)
  local index = 0
  local itemID
  local TableUtil = require("common.table_util")
  local data = TableUtil.CopyTable(Data)
  for i, itemData in pairs(data) do
    local judgeId = itemData.AvatarId
    local bEquip = judgeId == equipId
    if bEquip then
      index = i
      itemID = itemData.ItemId
    end
    if not itemData.Owned then
      itemData.useStatus = ItemStatus.Locked
    end
  end
  scrollComp:SetData(data)
  if index ~= 0 then
    scrollComp:Select(index)
  end
  if scrollComp == self.LoopScrollGrid_Normal then
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, itemID)
  end
end
function WardrobeAppearance:OnRefreshListItem(widget, index)
  local itemData = self.LoopScrollGrid_Normal:GetItemData(index)
  if not itemData then
    return
  end
  local common_item = widget.Common_Item_BP
  if itemData.ItemId then
    local finalItemId = itemData.ItemId
    if itemData.UnderWearID and itemData.UnderWearID ~= 0 then
      finalItemId = itemData.UnderWearID
    end
    common_item:InitView(finalItemId, 0)
    common_item:SetClickItemCallback(self.OnClickItem, self, common_item, index)
  end
  if itemData.ItemId == 0 then
    common_item:SetSpecialIconShow(false)
  end
  if itemData.AvatarIcon and itemData.FemaleAvatarIcon then
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    local iconPath = itemData.AvatarIcon
    if AvatarData.GetGameGender() == LobbyAvatarManager.Enum_Sex.Female then
      iconPath = itemData.FemaleAvatarIcon
    end
    log(bWriteLog and string.format("WardrobeAppearance:OnRefreshListItem. Avatar Icon itemId=%s, IconPath=%s", tostring(itemData.ItemId), tostring(iconPath)))
    common_item:SetIconFromPath(iconPath, {bMatchSize = true})
  else
    log(bWriteLog and string.format("WardrobeAppearance:OnRefreshListItem. Has not Avatar Icon itemId=%s", tostring(itemData.ItemId)))
  end
  local bIsSelect = index == self.LoopScrollGrid_Normal:GetSelectIndex()
  common_item:SetSelected(bIsSelect)
  if bIsSelect then
    local equipData = WardrobeLogicAppearance:GetAppearanceEquipData(self.AppearanceType)
    if ColorConfig[self.AppearanceType] and equipData and equipData.ItemId and equipData.ItemId ~= 0 then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Color, true)
    else
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Color, false)
    end
  end
  local Equip = WardrobeLogicAppearance:HasEquipItemData(self.AppearanceType, itemData.AvatarId)
  common_item:SetUsingState(Equip)
  if itemData.useStatus == ItemStatus.Locked or itemData.useStatus == ItemStatus.LockTry then
    common_item:ShowMask(true)
  else
    common_item:ShowMask(false)
  end
  if itemData.Owned then
    self:SetWidgetVisible(widget.Image_Lock, false)
  else
    self:SetWidgetVisible(widget.Image_Lock, true)
  end
end
function WardrobeAppearance:RefreshColorItem(widget, index)
  local colorData = self.ColorScroll:GetItemData(index)
  if not colorData then
    return
  end
  if colorData.AvatarIcon then
    self:SetTexture(widget.Image_Color, colorData.AvatarIcon)
  end
  local bEquip = WardrobeLogicAppearance:HasEquipItemView(ColorConfig[self.AppearanceType], colorData.AvatarId)
  if bEquip then
    self:SetWidgetVisible(widget.Common_selected_UIBP.Image_95, true)
    self:SetWidgetVisible(widget.Image_Using, true)
  else
    self:SetWidgetVisible(widget.Common_selected_UIBP.Image_95, false)
    self:SetWidgetVisible(widget.Image_Using, false)
  end
end
function WardrobeAppearance:OnClickHorizontalTabButton(widget, index)
  self:PlayAudio(sound_config.click_v1)
  if self.CurSubTab == index then
    return
  end
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  tipsMgr:Hide()
  self.CurSubTab = index
  if index == ENUM_SubTab.UnderCloth then
    self.AppearanceType = AppearanceType.UnderCloth
  elseif index == ENUM_SubTab.UnderPants then
    self.AppearanceType = AppearanceType.UnderPants
  end
  self:ScrollInit(self.LoopScrollGrid_Normal, self.AppearanceType)
end
function WardrobeAppearance:GetAvatarSelectIndex(data, appearanceType)
  local equipId = WardrobeLogicAppearance:GetAppearanceEquipAvatarId(appearanceType)
  for index, itemData in pairs(data) do
    if itemData.AvatarId == equipId then
      return index
    end
  end
  return 1
end
function WardrobeAppearance:CheckCanModifyAppearance(appearanceType)
  if appearanceType == AppearanceType.UnderCloth or appearanceType == AppearanceType.UnderPants then
    self.bNeedPutOffHeadEquip = false
    local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
    local myAvatar = TeamAvatarManager.GetMainAvatar()
    if myAvatar and myAvatar:GetModel() then
      self.bCanModify = not myAvatar:GetModel():HasEquipSwimConfigItem()
    else
      log(bWriteLog and "WardrobeAppearance:CheckCanModifyAppearance myAvatar is not Valid")
      self.bCanModify = true
    end
    return
  end
  local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
  if NewCharacterNetSystem:CurRoleIsCharacter() then
    self.bCanModify = false
    self.bNeedPutOffHeadEquip = false
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local tRoleData = AvatarData.GetRoleWear()
  for _, insId in pairs(tRoleData) do
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(insId)
    if itemData and itemData.resID then
      local fixCfg = CDataTable.GetTableData("FixGenderAvatarTable", itemData.resID)
      if fixCfg then
        self.bCanModify = false
        self.bNeedPutOffHeadEquip = false
      else
        local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
        local avatarSuitsCfg = CDataTable.GetTableData("AvatarSuitsTable", itemData.resID)
        if avatarSuitsCfg then
          local gender = DataMgr.avatarData.gamegender
          local limitStr = avatarSuitsCfg.MaleSuits
          if gender == LobbyAvatarManager.Enum_Sex.Female then
            limitStr = avatarSuitsCfg.FemaleSuits
          end
          local StringUtil = require("common.string_util")
          local limitTable = StringUtil.Split(limitStr, "|")
          local limitSlots = LimitSlot[self.AppearanceType]
          for slot, _ in pairs(limitSlots) do
            if not self:CheckCanModify(itemData.resID, slot, limitTable) then
              self.bCanModify = false
              self.bNeedPutOffHeadEquip = false
              break
            end
          end
        end
      end
    end
  end
end
function WardrobeAppearance:CheckCanModify(itemId, slot, limitTable)
  log(bWriteLog and string.format("WardrobeAppearance:CheckCanModify. itemId=%s, slot=%s", tostring(itemId), tostring(slot)))
  if not slot then
    return true
  end
  if limitTable and limitTable[slot] and tonumber(limitTable[slot]) ~= 0 then
    log(bWriteLog and "WardrobeAppearance:CheckCanModify. Slot Limit")
    return false
  end
  return true
end
function WardrobeAppearance:GetAppearanceItems(appearanceType)
  if not appearanceType then
    return {}
  end
  if self.cachedAppearanceItems[appearanceType] then
    return self.cachedAppearanceItems[appearanceType]
  end
  local result = WardrobeLogicAppearance:GetAppearanceItems(appearanceType)
  self.cachedAppearanceItems[appearanceType] = result
  return result
end
local class = require("class")
local ui_subtab_item_list_base = require("client.slua.umg.Wardrobe.subtab_item_list_base")
local CWardrobeAppearance = class(ui_subtab_item_list_base, nil, WardrobeAppearance)
return CWardrobeAppearance