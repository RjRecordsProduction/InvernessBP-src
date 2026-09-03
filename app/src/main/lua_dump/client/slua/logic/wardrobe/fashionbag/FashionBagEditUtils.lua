local tonumber = _G.tonumber
local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
local wardrobe_fashion_utils = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
local FashionBagEditUtils = {
  ENUM_FashionBagGuideType = {SaveToPlan = 2}
}
local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local ROLEWEAR_SUBTYPES = {
  ENUM_ITEM_SUBTYPE.Hat_Slot,
  ENUM_ITEM_SUBTYPE.Mask_Slot,
  ENUM_ITEM_SUBTYPE.Package_Slot,
  ENUM_ITEM_SUBTYPE.Pants_Slot,
  ENUM_ITEM_SUBTYPE.Shoes_Slot,
  ENUM_ITEM_SUBTYPE.Eye_Slot,
  ENUM_ITEM_SUBTYPE.Upgrade_Backpack,
  ENUM_ITEM_SUBTYPE.Helmet,
  ENUM_ITEM_SUBTYPE.Gloves
}
local WARDROBE_SUBTAB_STRING_2_WEARINDEX = {
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_head] = 1,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_face] = 2,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_clothes] = 3,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_suit] = 3,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_trousers] = 4,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_shoes] = 5,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_glasses] = 6
}
function FashionBagEditUtils:ctor()
end
function FashionBagEditUtils:DefineAndResetData()
  self.bApplyAfterEdit = false
  self:ClearEditTempData()
end
function FashionBagEditUtils:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_GOLDEN_SUIT, EVENTID_GOLDEN_SUIT_UPGRADE_SUCCESS, self.OnXSuitUpgrade, self)
  self:AddCommonEvent(EVENTTYPE_SUITDYE, EVENTID_SUITDYE_UPGRADE_SUCCESS, self.OnSuitDyeUpgrade, self)
  self:AddCommonEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_UPGRADE_RSP, self.OnItemUpgrade, self)
end
function FashionBagEditUtils:OnLogin(bReLogin)
  log(bWriteLog and string.format("FashionBagEditUtils:OnLogin. bReLogin=%s", tostring(bReLogin)))
  if bReLogin and self.EditIndex ~= nil then
    local OldEditIndex = self.EditIndex
    self:AbortFashionBagModify(true)
    self:StartEditFashionBag(OldEditIndex, true)
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_UPDATE)
  end
end
function FashionBagEditUtils:StartEditFashionBag(Index, bRelogin)
  log(bWriteLog and "FashionBagEditUtils:StartEditFashionBag. " .. tostring(Index))
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_ENTER)
  self.Edit  local TableUtil = require("common.table_util")
  if Index == 5 then
    Index = Index + 1
  end
  self.CurrentBagData = TableUtil.CopyTable(fashionbag_data:GetFashionBag(Index))
  self.CurrentBagData.weapon_list = self.CurrentBagData.weapon_skin_list or self.CurrentBagData.weapon_list
  self.CurrentBagData.avatar_show = TableUtil.CopyTable(fashionbag_data:GetAvatarShowData(Index))
  if not self.restoreData or not bRelogin then
    self:StoreMyAvatarInfo()
  end
  local Avatar = self:_GetMyAvatar()
  self:ClearRolewear()
  self.CurrentTryItemMap = {}
  self.CurrentWearList = {}
  if self.CurrentBagData.rolewear_list then
    for k, InsID in pairs(self.CurrentBagData.rolewear_list) do
      local ItemData = wardrobe_data:GetHallDepotItemDataByInsID(InsID)
      if ItemData then
        local RoleWearIndex = wardrobe_fashion_utils:GetRoleWearIndexBySubType(ItemData.itemSubType)
        if RoleWearIndex then
          self.CurrentWearList[RoleWearIndex] = tonumber(InsID)
          self:_AddToTryMapByInsID(InsID)
          if Avatar then
            local ItemID = self:_GetDisplayItemIDFromItemID(ItemData.resID)
            Avatar:PutonEquipment(ItemID, nil, {withOutAction = 1})
            self:HandleMyAvatarShapeInfo(Avatar, ItemID)
          end
        end
      end
    end
  end
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if not self.CurrentBagData.depot_bind_relation[HallThemeUtils.CONST_RELATION_TYPE.HELMET] then
    self.CurrentBagData.depot_bind_relation[HallThemeUtils.CONST_RELATION_TYPE.HELMET] = HallThemeUtils.CONST_RELATION_OP_TYPE.BIND
    self.CurrentBagData.helmet_skin_list = {
      [1] = self.CurrentBagData.helmet_skin,
      [2] = self.CurrentBagData.helmet_skin,
      [3] = self.CurrentBagData.helmet_skin
    }
  end
  if not self.CurrentBagData.depot_bind_relation[HallThemeUtils.CONST_RELATION_TYPE.BAG] then
    self.CurrentBagData.depot_bind_relation[HallThemeUtils.CONST_RELATION_TYPE.BAG] = HallThemeUtils.CONST_RELATION_OP_TYPE.BIND
    self.CurrentBagData.bag_skin_list = {
      [1] = self.CurrentBagData.bag_skin,
      [2] = self.CurrentBagData.bag_skin,
      [3] = self.CurrentBagData.bag_skin
    }
  end
  if self.CurrentBagData.bag_skin and self.CurrentBagData.bag_skin ~= 0 then
    local BagItemData = wardrobe_data:GetHallDepotItemDataByInsID(self.CurrentBagData.bag_skin)
    if BagItemData and BagItemData.resID then
      local DisplayItemID = self:_GetDisplayItemIDFromItemID(BagItemData.resID)
      Avatar:PutonEquipment(DisplayItemID)
    end
    self:_AddToTryMapByInsID(self.CurrentBagData.bag_skin)
  end
  if self.CurrentBagData.bag_pendants and next(self.CurrentBagData.bag_pendants) then
    for InsID, v in pairs(self.CurrentBagData.bag_pendants) do
      if v then
        local ItemData = wardrobe_data:GetHallDepotItemDataByInsID(InsID)
        if ItemData then
          self:_AddToTryMapByInsID(InsID)
          if Avatar then
            local ItemID = self:_GetDisplayItemIDFromItemID(ItemData.resID)
            Avatar:PutonEquipment(ItemID)
          end
        end
      end
    end
  end
  if self.CurrentBagData.weapon_list then
    for k, v in pairs(self.CurrentBagData.weapon_list) do
      if v and v.skin_id then
        self:_AddWeaponToTryMapByInsID(v.skin_id, k)
      end
    end
  end
  self:_AddToTryMapByInsID(self.CurrentBagData.parachute)
  self:_AddToTryMapByInsID(self.CurrentBagData.fly_skin)
  self:_AddToTryMapByInsID(self.CurrentBagData.wingman_skin)
  self:_AddToTryMapByInsID(self.CurrentBagData.gliding)
  self:_AddToTryMapByInsID(self.CurrentBagData.aircraft_put_id)
  if self.CurrentBagData.throw_object_list then
    for k, SkinInsID in pairs(self.CurrentBagData.throw_object_list) do
      if SkinInsID then
        self:_AddToTryMapByInsID(SkinInsID)
      end
    end
  end
  if self.CurrentBagData.avatar_show[HallThemeUtils.knapsack_ext_background] then
    self:_AddToTryMapByInsID(self.CurrentBagData.avatar_show[HallThemeUtils.knapsack_ext_background].instid)
  end
  if self.CurrentBagData.bag_pendants and next(self.CurrentBagData.bag_pendants) then
    for SkinInsID, v in pairs(self.CurrentBagData.bag_pendants) do
      if SkinInsID and SkinInsID ~= 0 then
        self:_AddToTryMapByInsID(SkinInsID)
        break
      end
    end
  end
  self:_UpdateAvatarWeapon()
  self:BeginPreviewCurrentTheme()
  local HelmetLevel = self.CurrentBagData.helmet_level or 3
  self:SetHelmetLevel(HelmetLevel, true, false)
  local BagLevel = self.CurrentBagData.bag_level or 3
  self:SetBackpackLevel(BagLevel, true)
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  LogicFusionModule:BeginFashionBagEdit(self.EditIndex, self.CurrentWearList)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_AVATAR_LIST)
end
function FashionBagEditUtils:ApplySaveFashionBagData()
  log(bWriteLog and "FashionBagEditUtils:ApplySaveFashionBagData. ")
  self:RestoreMyAvatarInfo()
  self:SetModifiedFlag(false)
  self:_CheckAvatarShow()
  local FashionBagHandler = require("client.network.Protocol.FashionBagHandler")
  FashionBagHandler.send_edit_rolewear_template_req(self.EditIndex, {
    rolewear_info = self.CurrentWearList,
    knapsack_ext_info = self.CurrentBagData
  })
  if self:GetApplyAfterEditFlag() then
    local fashionbag_logic = require("client.slua.logic.wardrobe.fashionbag.fashionbag_logic")
    fashionbag_logic:SetIgnoreNextApplyTips(true)
    FashionBagHandler.send_apply_rolewear_template_req(self.EditIndex)
  end
  self:ClearEditTempData()
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  LobbyThemeManager:EndPreviewTheme()
end
function FashionBagEditUtils:AbortFashionBagModify(bRelogin)
  if not bRelogin then
    self:RestoreMyAvatarInfo()
  end
  self:SetModifiedFlag(false)
  self.EditIndex = nil
  self:ClearEditTempData()
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  LobbyThemeManager:EndPreviewTheme()
end
function FashionBagEditUtils:UpdateAvatarTarotWeapon(ClothInsID, WeaponInsID, bPutOffCloth)
  local MyAvatar = self:_GetMyAvatar()
  if not MyAvatar then
    return false
  end
  if not WeaponInsID then
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    local AvatarShow = self.CurrentBagData.avatar_show
    if AvatarShow and AvatarShow[HallThemeUtils.knapsack_ext_weapon_skin] then
      WeaponInsID = AvatarShow[HallThemeUtils.knapsack_ext_weapon_skin].instid
    end
  end
  if not ClothInsID then
    local RoleWearIndex = wardrobe_fashion_utils:GetRoleWearIndexBySubType(ENUM_ITEM_SUBTYPE.Package_Slot)
    ClothInsID = self.CurrentWearList[RoleWearIndex]
  end
  local WeaponData = wardrobe_data:GetValidHallDepotItemDataByInsID(WeaponInsID)
  local ClothData = wardrobe_data:GetValidHallDepotItemDataByInsID(ClothInsID)
  local WeaponSource = wardrobe_data:GetItemSource(WeaponInsID)
  local ClothSource = wardrobe_data:GetItemSource(ClothInsID) or WeaponSource
  local ClothResID = not bPutOffCloth and ClothData and ClothData.resID or 1
  local WeaponResID = WeaponData and WeaponData.resID or 0
  local WeaponDiffColorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.WeaponDiffColorModule)
  local DstWeaponResID = WeaponDiffColorModule:FindTargetWeaponResID(ClothResID, WeaponResID)
  if WeaponDiffColorModule:HasDiffColorPrivilege(ClothSource) and WeaponSource == ClothSource and WeaponDiffColorModule:CheckWeaponColorFollowSwitch(ClothResID, ClothSource) then
    local WeaponCfg = CDataTable.GetTableData("WeaponSkinMapping", DstWeaponResID)
    if WeaponCfg and WeaponCfg.WeaponID then
      local WeaponWearInfo = {
        weaponId = WeaponCfg.WeaponID,
        skinId = DstWeaponResID
      }
      local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
      LobbyAvatarManager.EquipWeapon(DataMgr.roleData.uid, WeaponWearInfo, nil, true)
      return true
    end
  end
  return false
end
function FashionBagEditUtils:PutOnFashionBagItem(ItemData)
  log(bWriteLog and string.format("FashionBagEditUtils:PutOnFashionBagItem. ItemData=%s InsID=%s, ResID=%s", tostring(ItemData), tostring(ItemData and ItemData.ins_id), tostring(ItemData and ItemData.res_id)))
  if not ItemData then
    return
  end
  self:SetModifiedFlag(true)
  local InsID = tonumber(ItemData.ins_id)
  if not self.CurrentBagData then
    self.CurrentBagData = {}
  end
  if not self.CurrentWearList then
    self.CurrentWearList = {}
  end
  local CurrentBagData = self.CurrentBagData
  local OldInsID
  local bUseDefaultPutOn = true
  local ItemSubType = ItemData.itemSubType
  if ItemSubType == ENUM_ITEM_SUBTYPE.Hat_Slot or ItemSubType == ENUM_ITEM_SUBTYPE.Mask_Slot or ItemSubType == ENUM_ITEM_SUBTYPE.Package_Slot or ItemSubType == ENUM_ITEM_SUBTYPE.Pants_Slot or ItemSubType == ENUM_ITEM_SUBTYPE.Shoes_Slot or ItemSubType == ENUM_ITEM_SUBTYPE.Gloves or ItemSubType == ENUM_ITEM_SUBTYPE.Eye_Slot then
    local RoleWearIndex = wardrobe_fashion_utils:GetRoleWearIndexBySubType(ItemData.itemSubType)
    if RoleWearIndex then
      OldInsID = self.CurrentWearList[RoleWearIndex]
      self.CurrentWearList[RoleWearIndex] = InsID
    end
    if ItemSubType == ENUM_ITEM_SUBTYPE.Hat_Slot then
      self.CurrentBagData.head_show = InsID
    end
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Parachute_Slot then
    OldInsID = CurrentBagData.parachute
    CurrentBagData.parachute = InsID
    bUseDefaultPutOn = false
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Helmet_NoLevel then
    OldInsID = CurrentBagData.helmet_skin_list[CurrentBagData.helmet_level]
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    if self:GetDepotBindRelation(HallThemeUtils.CONST_RELATION_TYPE.HELMET) == HallThemeUtils.CONST_RELATION_OP_TYPE.UNBIND then
      CurrentBagData.helmet_skin_list[CurrentBagData.helmet_level] = InsID
    else
      for i = 1, 3 do
        CurrentBagData.helmet_skin_list[i] = InsID
      end
    end
    CurrentBagData.helmet_skin = InsID
    self.CurrentBagData.head_show = InsID
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Backpack then
    OldInsID = CurrentBagData.bag_skin_list[CurrentBagData.bag_level]
    CurrentBagData.bag_skin_list[CurrentBagData.bag_level] = InsID
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    if self:GetDepotBindRelation(HallThemeUtils.CONST_RELATION_TYPE.BAG) == HallThemeUtils.CONST_RELATION_OP_TYPE.UNBIND then
      CurrentBagData.bag_skin_list[CurrentBagData.bag_level] = InsID
    else
      for i = 1, 3 do
        CurrentBagData.bag_skin_list[i] = InsID
      end
    end
    CurrentBagData.bag_skin = InsID
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Aircraft_Skin then
    OldInsID = CurrentBagData.fly_skin
    CurrentBagData.fly_skin = InsID
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Wingman then
    OldInsID = CurrentBagData.wingman_skin
    CurrentBagData.wingman_skin = InsID
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Theme_Play then
    if not CurrentBagData.avatar_show then
      CurrentBagData.avatar_show = {}
    end
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    OldInsID = CurrentBagData.avatar_show and CurrentBagData.avatar_show[HallThemeUtils.knapsack_ext_background].instid
    CurrentBagData.avatar_show[HallThemeUtils.knapsack_ext_background] = {
      instid = InsID,
      is_show = true,
      relat_param = 0
    }
    local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
    LobbyThemeManager:BeginPreviewTheme(ItemData.res_id, true, true)
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Backpack_Pendant_Skin then
    if not CurrentBagData.bag_pendants then
      CurrentBagData.bag_pendants = {}
    end
    for SkinID, v in pairs(CurrentBagData.bag_pendants) do
      if SkinID and SkinID ~= 0 then
        OldInsID = SkinID
        CurrentBagData.bag_pendants[OldInsID] = nil
        break
      end
    end
    CurrentBagData.bag_pendants[InsID] = 1
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Glider_Slot_413 or ItemSubType == ENUM_ITEM_SUBTYPE.Glider_Slot_414 then
    bUseDefaultPutOn = false
    OldInsID = CurrentBagData.aircraft_put_id
    CurrentBagData.aircraft_put_id = InsID
    if CurrentBagData.gliding and CurrentBagData.gliding ~= 0 then
      self:_RemoveFromTryMapByInsID(CurrentBagData.gliding)
      CurrentBagData.gliding = 0
    end
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Glider_Slot_415 then
    bUseDefaultPutOn = false
    OldInsID = CurrentBagData.gliding
    CurrentBagData.gliding = InsID
    if CurrentBagData.aircraft_put_id and CurrentBagData.aircraft_put_id ~= 0 then
      self:_RemoveFromTryMapByInsID(CurrentBagData.aircraft_put_id)
      CurrentBagData.aircraft_put_id = 0
    end
  end
  local Avatar = self:_GetMyAvatar()
  local DisplayItemID = self:_GetDisplayItemIDFromItemID(ItemData.res_id)
  if bUseDefaultPutOn then
    Avatar:PutonEquipment(DisplayItemID)
    self:HandleMyAvatarShapeInfo(Avatar, DisplayItemID)
    local TakeOffEquipments = Avatar:GetTakeoffEquipments()
    for _, TakeOffItemID in ipairs(TakeOffEquipments) do
      local TakeOffItemData = CDataTable.GetTableData("Item", TakeOffItemID)
      if TakeOffItemData and ItemData.itemSubType ~= TakeOffItemData.itemSubType and TakeOffItemData.itemSubType ~= ENUM_ITEM_SUBTYPE.Helmet then
        self:_RemoveFromTryMap(TakeOffItemID)
        local RoleWearIndex = wardrobe_fashion_utils:GetRoleWearIndexBySubType(TakeOffItemData.itemSubType)
        if RoleWearIndex then
          self.CurrentWearList[RoleWearIndex] = nil
        end
      end
    end
  end
  if ItemSubType == ENUM_ITEM_SUBTYPE.Package_Slot then
    self:UpdateAvatarTarotWeapon(InsID, nil)
  end
  if ItemData.itemSubType == ENUM_ITEM_SUBTYPE.Hat_Slot or ItemData.itemSubType == ENUM_ITEM_SUBTYPE.Mask_Slot then
    self:_UpdateHelmetShow()
  end
  self:_RemoveFromTryMapByInsID(OldInsID)
  self:_AddToTryMap(ItemData.res_id, ItemData.ins_id)
  local OldItemData = OldInsID and wardrobe_data:GetHallDepotItemDataByInsID(OldInsID)
  local OldResID = OldItemData and OldItemData.resID
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  LogicFusionModule:SyncFashionBagEditingOnWear(OldResID, ItemData.res_id)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_UPDATE)
end
function FashionBagEditUtils:PutOffFashionBagItem(ItemData)
  log(bWriteLog and string.format("FashionBagEditUtils:PutOffFashionBagItem. ItemData=%s InsID=%s, ResID=%s", tostring(ItemData), tostring(ItemData and ItemData.ins_id), tostring(ItemData and ItemData.res_id)))
  if not ItemData then
    return
  end
  self:SetModifiedFlag(true)
  if not self.CurrentBagData then
    self.CurrentBagData = {}
  end
  local CurrentBagData = self.CurrentBagData
  local ItemSubType = ItemData.itemSubType
  local bUseDefaultPutOff = true
  local OldInsID
  if ItemSubType == ENUM_ITEM_SUBTYPE.Hat_Slot or ItemSubType == ENUM_ITEM_SUBTYPE.Mask_Slot or ItemSubType == ENUM_ITEM_SUBTYPE.Package_Slot or ItemSubType == ENUM_ITEM_SUBTYPE.Pants_Slot or ItemSubType == ENUM_ITEM_SUBTYPE.Shoes_Slot or ItemSubType == ENUM_ITEM_SUBTYPE.Gloves or ItemSubType == ENUM_ITEM_SUBTYPE.Eye_Slot then
    local RoleWearIndex = wardrobe_fashion_utils:GetRoleWearIndexBySubType(ItemSubType)
    if RoleWearIndex then
      OldInsID = self.CurrentWearList[RoleWearIndex]
      self.CurrentWearList[RoleWearIndex] = nil
    end
    if ItemSubType == ENUM_ITEM_SUBTYPE.Hat_Slot then
      self.CurrentBagData.head_show = self.CurrentBagData.helmet_skin or 0
    end
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Parachute_Slot then
    OldInsID = CurrentBagData.parachute
    CurrentBagData.parachute = nil
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_PARACHUTE_UPDATE, 0)
    bUseDefaultPutOff = false
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Helmet_NoLevel then
    OldInsID = CurrentBagData.helmet_skin_list[CurrentBagData.helmet_level]
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    if self:GetDepotBindRelation(HallThemeUtils.CONST_RELATION_TYPE.HELMET) == HallThemeUtils.CONST_RELATION_OP_TYPE.UNBIND then
      CurrentBagData.helmet_skin_list[CurrentBagData.helmet_level] = 0
    else
      for i = 1, 3 do
        CurrentBagData.helmet_skin_list[i] = 0
      end
    end
    CurrentBagData.helmet_skin = 0
    self.CurrentBagData.head_show = self.CurrentWearList[1] or 0
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Backpack then
    OldInsID = CurrentBagData.bag_skin_list[CurrentBagData.bag_level]
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    if self:GetDepotBindRelation(HallThemeUtils.CONST_RELATION_TYPE.BAG) == HallThemeUtils.CONST_RELATION_OP_TYPE.UNBIND then
      CurrentBagData.bag_skin_list[CurrentBagData.bag_level] = 0
    else
      for i = 1, 3 do
        CurrentBagData.bag_skin_list[i] = 0
      end
    end
    CurrentBagData.bag_skin = 0
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Aircraft_Skin then
    OldInsID = CurrentBagData.fly_skin
    CurrentBagData.fly_skin = nil
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Wingman then
    OldInsID = CurrentBagData.wingman_skin
    CurrentBagData.wingman_skin = nil
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Theme_Play then
    if not CurrentBagData.avatar_show then
      CurrentBagData.avatar_show = {}
    end
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    OldInsID = CurrentBagData.avatar_show[HallThemeUtils.knapsack_ext_background] and CurrentBagData.avatar_show[HallThemeUtils.knapsack_ext_background].instid
    CurrentBagData.avatar_show[HallThemeUtils.knapsack_ext_background] = nil
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Backpack_Pendant_Skin then
    if not CurrentBagData.bag_pendants then
      CurrentBagData.bag_pendants = {}
    end
    for SkinID, v in pairs(CurrentBagData.bag_pendants) do
      if SkinID and SkinID ~= 0 then
        OldInsID = SkinID
        CurrentBagData.bag_pendants[OldInsID] = nil
        break
      end
    end
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Glider_Slot_413 or ItemSubType == ENUM_ITEM_SUBTYPE.Glider_Slot_414 then
    bUseDefaultPutOff = false
    OldInsID = CurrentBagData.aircraft_put_id
    CurrentBagData.aircraft_put_id = nil
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Glider_Slot_415 then
    bUseDefaultPutOff = false
    OldInsID = CurrentBagData.gliding
    CurrentBagData.gliding = nil
  end
  local Avatar = self:_GetMyAvatar()
  local DisplayItemID = self:_GetDisplayItemIDFromItemID(ItemData.res_id)
  if bUseDefaultPutOff then
    Avatar:PutoffEquipment(DisplayItemID)
  end
  if ItemSubType == ENUM_ITEM_SUBTYPE.Package_Slot then
    self:UpdateAvatarTarotWeapon(OldInsID, nil, true)
  end
  if ItemData.itemSubType == ENUM_ITEM_SUBTYPE.Hat_Slot or ItemData.itemSubType == ENUM_ITEM_SUBTYPE.Mask_Slot then
    self:_UpdateHelmetShow()
  end
  self:_RemoveFromTryMapByInsID(OldInsID)
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  LogicFusionModule:SyncFashionBagEditingOnWear(ItemData.res_id, nil)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_UPDATE)
end
function FashionBagEditUtils:ChangeWeaponID(NewWeaponID)
  self:_UpdateAvatarShowByWeaponID(NewWeaponID, nil)
  self:_CheckAvatarShow()
end
function FashionBagEditUtils:PutOnWeaponSkin(WeaponID, ItemData, planID)
  log(bWriteLog and string.format("FashionBagEditUtils:PutOnWeaponSkin. WeaponID=%s, ItemData=%s, InsID=%s, ResID=%s", tostring(WeaponID), tostring(ItemData), tostring(ItemData and ItemData.ins_id), tostring(ItemData and ItemData.res_id)))
  if not WeaponID or not ItemData then
    return
  end
  self:SetModifiedFlag(true)
  if not self.CurrentBagData then
    self.CurrentBagData = {}
  end
  if not self.CurrentBagData.weapon_list then
    self.CurrentBagData.weapon_list = {}
  end
  if not self.CurrentWearList then
    self.CurrentWearList = {}
  end
  local InsID = tonumber(ItemData.ins_id) or 0
  local OldInsID = self.CurrentBagData.weapon_list[WeaponID] and self.CurrentBagData.weapon_list[WeaponID].skin_id
  local WeaponData = {skin_id = InsID}
  self.CurrentBagData.weapon_list[WeaponID] = WeaponData
  self:_RemoveFromTryMapByInsID(OldInsID)
  local ExtraData
  if ItemData.planID then
    ExtraData = {
      planID = ItemData.planID
    }
  end
  self:_AddToTryMap(ItemData.res_id, ItemData.ins_id, ExtraData)
  self:_UpdateAvatarShowByWeaponID(WeaponID, InsID, planID)
  self:_CheckAvatarShow()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_UPDATE)
end
function FashionBagEditUtils:PutOffWeaponSkin(WeaponID)
  log(bWriteLog and string.format("FashionBagEditUtils:PutOffWeaponSkin. WeaponID=%s", tostring(WeaponID)))
  if not WeaponID then
    return
  end
  self:SetModifiedFlag(true)
  if not self.CurrentBagData then
    self.CurrentBagData = {}
  end
  if not self.CurrentBagData.weapon_list then
    self.CurrentBagData.weapon_list = {}
  end
  local OldInsID = self.CurrentBagData.weapon_list[WeaponID] and self.CurrentBagData.weapon_list[WeaponID].skin_id
  self.CurrentBagData.weapon_list[WeaponID] = nil
  self:_RemoveFromTryMapByInsID(OldInsID)
  self:_UpdateAvatarShowByWeaponID(WeaponID, 0)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_UPDATE)
end
function FashionBagEditUtils:PutOnThrowObject(ItemData)
  log(bWriteLog and string.format("FashionBagEditUtils:PutOnThrowObject. ItemData=%s, InsID=%s, ResID=%s", tostring(ItemData), tostring(ItemData and ItemData.ins_id), tostring(ItemData and ItemData.res_id)))
  if not ItemData then
    return
  end
  local ItemSubType = ItemData.itemSubType
  if ItemSubType ~= ENUM_ITEM_SUBTYPE.Grenade_612 and ItemSubType ~= ENUM_ITEM_SUBTYPE.Smoke_Grenade and ItemSubType ~= ENUM_ITEM_SUBTYPE.Grenade_614 and ItemSubType ~= ENUM_ITEM_SUBTYPE.Molotov_Cocktail then
    return
  end
  self:SetModifiedFlag(true)
  if not self.CurrentBagData then
    self.CurrentBagData = {}
  end
  if not self.CurrentBagData.throw_object_list then
    self.CurrentBagData.throw_object_list = {}
  end
  local InsID = tonumber(ItemData.ins_id) or 0
  local OldInsID = self.CurrentBagData.throw_object_list[ItemSubType]
  self.CurrentBagData.throw_object_list[ItemSubType] = InsID
  if ItemSubType == ENUM_ITEM_SUBTYPE.Grenade_612 then
    self.CurrentBagData.grenade_skin = InsID
  end
  self:_RemoveFromTryMapByInsID(OldInsID)
  self:_AddToTryMap(ItemData.res_id, ItemData.ins_id)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_UPDATE)
end
function FashionBagEditUtils:SetBackpackLevel(Level, bForceUpdate)
  Level = Level or 3
  if not self.CurrentBagData then
    self.CurrentBagData = {}
  end
  local OldLevel = self.CurrentBagData.bag_level or 3
  self.CurrentBagData.bag_level = Level
  if bForceUpdate or OldLevel ~= Level then
    local Avatar = self:_GetMyAvatar()
    if self.CurrentBagData.bag_skin_list[OldLevel] and self.CurrentBagData.bag_skin_list[OldLevel] ~= 0 then
      local ItemData = wardrobe_data:GetHallDepotItemDataByInsID(self.CurrentBagData.bag_skin_list[OldLevel])
      if ItemData and ItemData.resID then
        local DisplayItemID = DataMgr.GetEquipmentItemIDByResID(OldLevel, ItemData.resID)
        Avatar:PutoffEquipment(DisplayItemID)
      end
      self:_RemoveFromTryMapByInsID(self.CurrentBagData.bag_skin_list[OldLevel])
    end
    if self.CurrentBagData.bag_skin_list[Level] and self.CurrentBagData.bag_skin_list[Level] ~= 0 then
      local ItemData = wardrobe_data:GetHallDepotItemDataByInsID(self.CurrentBagData.bag_skin_list[Level])
      if ItemData and ItemData.resID then
        local DisplayItemID = self:_GetDisplayItemIDFromItemID(ItemData.resID)
        Avatar:PutonEquipment(DisplayItemID)
      end
      self:_AddToTryMapByInsID(self.CurrentBagData.bag_skin_list[Level])
    end
    self.CurrentBagData.bag_skin = self.CurrentBagData.bag_skin_list[Level]
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_EDIT_BAG_LEVEL_CHANGE)
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_SINGLE_ITEM_UPDATE_TAB, wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_bag, self.CurrentBagData.bag_skin)
  end
end
function FashionBagEditUtils:GetCurrentBackpackLevel()
  return self.CurrentBagData and self.CurrentBagData.bag_level or 3
end
function FashionBagEditUtils:SetHelmetLevel(Level, bIgnoreLevelCheck, bIgnoreHeadShowCheck)
  Level = Level or 3
  if not self.CurrentBagData then
    self.CurrentBagData = {}
  end
  local OldLevel = self.CurrentBagData.helmet_level or 3
  self.CurrentBagData.helmet_level = Level
  local updateAvatarShow = bIgnoreHeadShowCheck or self.CurrentBagData.helmet_skin_list[Level] and self.CurrentBagData.helmet_skin_list[Level] == self.CurrentBagData.head_show
  if bIgnoreLevelCheck or OldLevel ~= Level then
    local Avatar = self:_GetMyAvatar()
    if self.CurrentBagData.helmet_skin_list[OldLevel] and self.CurrentBagData.helmet_skin_list[OldLevel] ~= 0 then
      if updateAvatarShow then
        local ItemData = wardrobe_data:GetHallDepotItemDataByInsID(self.CurrentBagData.helmet_skin_list[OldLevel])
        if ItemData and ItemData.resID then
          local DisplayItemID = DataMgr.GetEquipmentItemIDByResID(OldLevel, ItemData.resID)
          Avatar:PutoffEquipment(DisplayItemID)
        end
      end
      self:_RemoveFromTryMapByInsID(self.CurrentBagData.helmet_skin_list[OldLevel])
    end
    if self.CurrentBagData.helmet_skin_list[Level] and self.CurrentBagData.helmet_skin_list[Level] ~= 0 then
      if updateAvatarShow then
        local ItemData = wardrobe_data:GetHallDepotItemDataByInsID(self.CurrentBagData.helmet_skin_list[Level])
        if ItemData and ItemData.resID then
          local DisplayItemID = self:_GetDisplayItemIDFromItemID(ItemData.resID)
          Avatar:PutonEquipment(DisplayItemID)
        end
      end
      self:_AddToTryMapByInsID(self.CurrentBagData.helmet_skin_list[Level])
    end
    if bIgnoreHeadShowCheck then
      self.CurrentBagData.head_show = self.CurrentBagData.helmet_skin_list[Level]
    end
    self.CurrentBagData.helmet_skin = self.CurrentBagData.helmet_skin_list[Level]
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_EDIT_HELMET_LEVEL_CHANGE)
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_SINGLE_ITEM_UPDATE_TAB, wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_helmet, self.CurrentBagData.helmet_skin)
  end
end
function FashionBagEditUtils:GetCurrentHelmetLevel()
  return self.CurrentBagData and self.CurrentBagData.helmet_level or 3
end
function FashionBagEditUtils:SetModifiedFlag(bModifiedFlag)
  self.bHasModified = bModifiedFlag
end
function FashionBagEditUtils:HasModified()
  return self.bHasModified
end
function FashionBagEditUtils:IsItemInTryMap(ItemID, bStrict, ExtraData)
  if not ItemID or ItemID == 0 then
    return false
  end
  if not self.CurrentTryItemMap then
    return false
  end
  if not bStrict then
    local bonus_pass_util = require("client.slua.logic.unknow_pass.BonusPass.bonus_pass_util")
    local AssociateItemID
    local bMatchAssociate = false
    bMatchAssociate, AssociateItemID = bonus_pass_util.IsHigherItem(ItemID)
    if not bMatchAssociate then
      bMatchAssociate, AssociateItemID = bonus_pass_util.IsBPBaseItem(ItemID)
    end
    if AssociateItemID and self.CurrentTryItemMap[AssociateItemID] then
      if ExtraData and ExtraData.planID then
        if self.CurrentTryItemMap[AssociateItemID].ExtraData and self.CurrentTryItemMap[AssociateItemID].ExtraData.planID == ExtraData.planID then
          return true
        end
      else
        return true
      end
    end
  end
  if ExtraData and ExtraData.planID then
    if self.CurrentTryItemMap[ItemID] and self.CurrentTryItemMap[ItemID].ExtraData and self.CurrentTryItemMap[ItemID].ExtraData.planID == ExtraData.planID then
      return true
    end
  else
    return self.CurrentTryItemMap[ItemID] and true or false
  end
  return false
end
function FashionBagEditUtils:GetCurrentEditIndex()
  return self.EditIndex
end
function FashionBagEditUtils:GetApplyAfterEditFlag()
  return self.bApplyAfterEdit
end
function FashionBagEditUtils:SetApplyAfterEditFlag(bApplyAfterEditFlag)
  self.bApplyAfterEdit = bApplyAfterEditFlag
end
function FashionBagEditUtils:GetCurrentParachute()
  return self.CurrentBagData and self.CurrentBagData.parachute
end
function FashionBagEditUtils:GetCurrentPlane()
  return self.CurrentBagData and self.CurrentBagData.fly_skin
end
function FashionBagEditUtils:GetCurrentWingman()
  return self.CurrentBagData and self.CurrentBagData.wingman_skin
end
function FashionBagEditUtils:GetCurrentThrowObject()
  return self.CurrentBagData and self.CurrentBagData.throw_object_list
end
function FashionBagEditUtils:GetThrowObjectInsIDBySubType(ItemSubType)
  if not ItemSubType then
    return 0
  end
  return self.CurrentBagData and self.CurrentBagData.throw_object_list[ItemSubType] or 0
end
function FashionBagEditUtils:GetCurrentGlidingOrAircraft()
  if not self.CurrentBagData then
    return nil
  end
  if self.CurrentBagData.aircraft_put_id and self.CurrentBagData.aircraft_put_id ~= 0 then
    return self.CurrentBagData.aircraft_put_id
  end
  if self.CurrentBagData.gliding and self.CurrentBagData.gliding ~= 0 then
    return self.CurrentBagData.gliding
  end
  return nil
end
function FashionBagEditUtils:GetCurrentWearPackage()
  local RoleWearIndex = wardrobe_fashion_utils:GetRoleWearIndexBySubType(ENUM_ITEM_SUBTYPE.Package_Slot)
  if self.CurrentWearList and self.CurrentWearList[RoleWearIndex] then
    return self.CurrentWearList[RoleWearIndex]
  else
    return 0
  end
end
function FashionBagEditUtils:GetWearInfo()
  local WearInfoList = {}
  local wardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  if not self.CurrentWearList then
    return WearInfoList
  end
  for k, v in pairs(self.CurrentWearList) do
    local cfg = wardrobeData:GetHallDepotItemDataByInsID(v)
    if cfg then
      local temp = AvatarData.GetItemWearInfo(v, cfg)
      table.insert(WearInfoList, temp)
    end
  end
  return WearInfoList
end
function FashionBagEditUtils:GetDepotItemData(ItemID)
  if not ItemID then
    return nil
  end
  return wardrobe_data:GetHallDepotItemDataByResID(ItemID)
end
function FashionBagEditUtils:_GetMyAvatar()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local myAvatar = TeamAvatarManager.GetAvatarByUid(tonumber(DataMgr.roleData.uid))
  return myAvatar
end
function FashionBagEditUtils:StoreMyAvatarInfo()
  log(bWriteLog and "FashionBagEditUtils:StoreMyAvatarInfo. ")
  local myAvatar = self:_GetMyAvatar()
  if myAvatar then
    myAvatar:StopAction()
    self.restoreData = {
      _storeEquipments = myAvatar:GetEquipments()
    }
  end
  self.restoreData_Bak = nil
  self.restoreData_Temp = nil
end
function FashionBagEditUtils:RestoreMyAvatarInfo()
  log(bWriteLog and "FashionBagEditUtils:RestoreMyAvatarInfo. ")
  local myAvatar = self:_GetMyAvatar()
  if myAvatar and self.restoreData then
    myAvatar:SetStoreEquipments(self.restoreData._storeEquipments)
    myAvatar:RestoreEquipments()
    if self.restoreData._storeEquipments then
      for _, v in pairs(self.restoreData._storeEquipments) do
        self:HandleMyAvatarShapeInfo(myAvatar, v.itemID)
      end
    end
  end
  self.restoreData = nil
end
function FashionBagEditUtils:ClearEditTempData()
  log(bWriteLog and "FashionBagEditUtils:ClearEditTempData. ")
  self.EditIndex = nil
  self.CurrentWearList = nil
  self.CurrentKnapsack = nil
  self.CurrentBagData = nil
  self.bHasModified = false
  self.CurrentTryItemMap = nil
  self.CachedInsID2ResID = nil
end
function FashionBagEditUtils:_AddToTryMap(AddItemID, AddInsID, ExtraData)
  AddItemID = tonumber(AddItemID)
  AddInsID = tonumber(AddInsID)
  if not (AddItemID and AddItemID ~= 0 and AddInsID) or AddInsID == 0 then
    return
  end
  if not self.CurrentTryItemMap then
    self.CurrentTryItemMap = {}
  end
  log(bWriteLog and "FashionBagEditUtils:_AddToTryMap ItemID:" .. tostring(AddItemID))
  self.CurrentTryItemMap[AddItemID] = {
    ResID = AddItemID,
    InsID = AddInsID,
      }
  if not self.CachedInsID2ResID then
    self.CachedInsID2ResID = {}
  end
  self.CachedInsID2ResID[AddInsID] = AddItemID
  local ItemCfg = CDataTable.GetTableData("Item", AddItemID)
  if ItemCfg then
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_SINGLE_ITEM_UPDATE_TAB, ItemCfg.WardrobeTab, AddInsID)
  end
end
function FashionBagEditUtils:_AddToTryMapByInsID(AddInsID)
  AddInsID = tonumber(AddInsID)
  if not AddInsID or AddInsID == 0 then
    return
  end
  local AddItemData = wardrobe_data:GetHallDepotItemDataByInsID(AddInsID)
  if AddItemData then
    self:_AddToTryMap(AddItemData.resID, AddItemData.insID)
  end
end
function FashionBagEditUtils:_AddWeaponToTryMapByInsID(AddInsID, WeaponID)
  AddInsID = tonumber(AddInsID)
  if not AddInsID or AddInsID == 0 then
    return
  end
  local AddItemData = wardrobe_data:GetHallDepotItemDataByInsID(AddInsID)
  if AddItemData then
    local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
    local ExtraData
    if WeaponDiySystem:IsDIYWeapon(AddItemData.resID) then
      local planID = WeaponDiySystem:GetCurUsePlanIdByWeaponId(AddItemData.resID)
      if planID then
        ExtraData = {planID = planID}
      end
    end
    self:_AddToTryMap(AddItemData.resID, AddItemData.insID, ExtraData)
  end
end
function FashionBagEditUtils:_RemoveFromTryMap(RemoveItemID)
  RemoveItemID = tonumber(RemoveItemID)
  if not RemoveItemID or RemoveItemID == 0 then
    return
  end
  if not self.CurrentTryItemMap then
    self.CurrentTryItemMap = {}
  end
  local OldInsID = self.CurrentTryItemMap[RemoveItemID] and self.CurrentTryItemMap[RemoveItemID].InsID
  if self.CachedInsID2ResID and self.CachedInsID2ResID[OldInsID] then
    self.CachedInsID2ResID[OldInsID] = nil
  end
  log(bWriteLog and "FashionBagEditUtils:_RemoveFromTryMap ItemID:" .. tostring(RemoveItemID))
  self.CurrentTryItemMap[RemoveItemID] = nil
  local ItemCfg = CDataTable.GetTableData("Item", RemoveItemID)
  if ItemCfg then
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_SINGLE_ITEM_UPDATE_TAB, ItemCfg.WardrobeTab, 0)
  end
end
function FashionBagEditUtils:_RemoveFromTryMapByInsID(RemoveInsID)
  RemoveInsID = tonumber(RemoveInsID)
  if not RemoveInsID or RemoveInsID == 0 then
    return
  end
  local RemoveItemData = wardrobe_data:GetHallDepotItemDataByInsID(RemoveInsID)
  if RemoveItemData then
    self:_RemoveFromTryMap(RemoveItemData.resID)
  end
end
function FashionBagEditUtils:_GetDisplayItemIDFromItemID(itemID)
  if not itemID then
    return nil
  end
  local itemIDForDisplay = itemID
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  local curItemType = itemCfg and itemCfg.ItemType
  local curItemSubType = itemCfg and itemCfg.ItemSubType
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if ModelDisplayTypeHelper.IsBag(curItemType, curItemSubType) or ModelDisplayTypeHelper.IsNoLevelBag(curItemType, curItemSubType) then
    local BagLevel = self.CurrentBagData.bag_level or 3
    itemIDForDisplay = DataMgr.GetEquipmentItemIDByResID(BagLevel, itemID)
  elseif ModelDisplayTypeHelper.IsNoLevelHelmet(curItemType, curItemSubType) then
    local HelmetLevel = self.CurrentBagData.helmet_level or 3
    itemIDForDisplay = DataMgr.GetEquipmentItemIDByResID(HelmetLevel, itemID)
  elseif LogicXSuit.IsXSuit(itemID) then
    itemIDForDisplay = LogicXSuit.ChangeItemIDByMyselfState(itemID)
  end
  return itemIDForDisplay
end
function FashionBagEditUtils:_UpdateAvatarShowByWeaponID(WeaponID, WeaponSkinID, planID)
  if not self.CurrentBagData then
    self.CurrentBagData = {}
  end
  if not self.CurrentBagData.avatar_show then
    self.CurrentBagData.avatar_show = {}
  end
  local AvatarShow = self.CurrentBagData.avatar_show
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local OldWeaponID = self:GetMainWeaponID()
  if WeaponID == 0 or WeaponID == OldWeaponID and WeaponSkinID == nil then
    AvatarShow[HallThemeUtils.knapsack_ext_weapon_skin] = {
      instid = 0,
      is_show = true,
      relat_param = 0
    }
    AvatarShow[HallThemeUtils.knapsack_ext_second_weapon_skin] = nil
    LobbyAvatarManager.UnEquipWeapon(DataMgr.roleData.uid)
    return
  end
  local bSaveToSecondWeapon = false
  local bMeleeWeapon = self:_IsMeleeWeapon(WeaponID)
  local bOldMeleeWeapon = self:_IsMeleeWeapon(OldWeaponID)
  bSaveToSecondWeapon = bMeleeWeapon and not bOldMeleeWeapon or not bMeleeWeapon and bOldMeleeWeapon
  local NewInstID = WeaponSkinID
  NewInstID = NewInstID or self.CurrentBagData and self.CurrentBagData.weapon_list and self.CurrentBagData.weapon_list[WeaponID] and self.CurrentBagData.weapon_list[WeaponID].skin_id or 0
  if bSaveToSecondWeapon then
    AvatarShow[HallThemeUtils.knapsack_ext_second_weapon_skin] = AvatarShow[HallThemeUtils.knapsack_ext_weapon_skin]
  end
  AvatarShow[HallThemeUtils.knapsack_ext_weapon_skin] = {
    instid = NewInstID,
    is_show = true,
    relat_param = WeaponID
  }
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemData = wardrobe_data:GetValidHallDepotItemDataByInsID(NewInstID)
  local SkinResID = ItemData and ItemData.resID
  if not self:UpdateAvatarTarotWeapon(nil, NewInstID) then
    local WeaponWearInfo = {weaponId = WeaponID, skinId = SkinResID}
    LobbyAvatarManager.EquipWeapon(DataMgr.roleData.uid, WeaponWearInfo, nil, true)
  end
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
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_EDIT_BAG_LEVEL_CHANGE, WeaponID, NewInstID)
end
function FashionBagEditUtils:_IsMeleeWeapon(WeaponID)
  if not WeaponID then
    return false
  end
  local ItemCfg = CDataTable.GetTableData("Item", WeaponID)
  if not ItemCfg then
    return false
  end
  return ItemCfg.ItemSubType == 108
end
function FashionBagEditUtils:GetMainWeaponID()
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  return self.CurrentBagData and self.CurrentBagData.avatar_show and self.CurrentBagData.avatar_show[HallThemeUtils.knapsack_ext_weapon_skin] and self.CurrentBagData.avatar_show[HallThemeUtils.knapsack_ext_weapon_skin].relat_param or 0
end
function FashionBagEditUtils:GetSecondWeaponID()
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  return self.CurrentBagData and self.CurrentBagData.avatar_show and self.CurrentBagData.avatar_show[HallThemeUtils.knapsack_ext_second_weapon_skin] and self.CurrentBagData.avatar_show[HallThemeUtils.knapsack_ext_second_weapon_skin].relat_param or 0
end
function FashionBagEditUtils:GetSkinIDByWeaponID(WeaponID)
  if not WeaponID then
    return 0
  end
  local WeaponList = self.CurrentBagData and self.CurrentBagData.weapon_list
  if not WeaponList then
    return 0
  end
  return WeaponList[WeaponID] and WeaponList[WeaponID].skin_id or 0
end
function FashionBagEditUtils:_UpdateAvatarWeapon()
  log(bWriteLog and "FashionBagEditUtils:_UpdateAvatarWeapon. ")
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  LobbyAvatarManager.UnEquipWeapon(DataMgr.roleData.uid)
  if self.CurrentBagData and self.CurrentBagData.avatar_show then
    local AvatarShow = self.CurrentBagData.avatar_show
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    local MainWeaponData = AvatarShow[HallThemeUtils.knapsack_ext_weapon_skin]
    if MainWeaponData then
      local WeaponID = MainWeaponData.relat_param or 0
      local SkinInsID = MainWeaponData.instid or 0
      if WeaponID ~= 0 then
        local ItemData = wardrobe_data:GetValidHallDepotItemDataByInsID(SkinInsID)
        local SkinResID = ItemData and ItemData.resID
        if not self:UpdateAvatarTarotWeapon(nil, SkinInsID) then
          local WeaponWearInfo = {weaponId = WeaponID, skinId = SkinResID}
          LobbyAvatarManager.EquipWeapon(DataMgr.roleData.uid, WeaponWearInfo, nil, true)
        end
        local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
        if WeaponDiySystem:IsDIYWeapon(SkinResID) then
          local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
          local CurPlanID = WeaponDiySystem:GetCurUsePlanIdByWeaponId(SkinResID)
          if CurPlanID then
            local scheme = WeaponDiySystem:GetSchemeData(SkinResID, CurPlanID)
            local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
            local avatar = TeamAvatarManager.GetAvatarByUid(DataMgr.roleData.uid)
            if avatar then
              avatar:ChangeDiyWeaponScheme(scheme)
            end
          end
        end
      end
    end
    local SecondWeaponData = AvatarShow[HallThemeUtils.knapsack_ext_second_weapon_skin]
    if SecondWeaponData then
      local WeaponID = SecondWeaponData.relat_param or 0
      local SkinInsID = SecondWeaponData.instid or 0
      if WeaponID ~= 0 then
        local ItemData = wardrobe_data:GetValidHallDepotItemDataByInsID(SkinInsID)
        local SkinResID = ItemData and ItemData.resID
        local WeaponWearInfo = {weaponId = WeaponID, skinId = SkinResID}
        LobbyAvatarManager.EquipWeapon(DataMgr.roleData.uid, WeaponWearInfo, nil, false)
        local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
        if WeaponDiySystem:IsDIYWeapon(SkinResID) then
          local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
          local CurPlanID = WeaponDiySystem:GetCurUsePlanIdByWeaponId(SkinResID)
          if CurPlanID then
            local scheme = WeaponDiySystem:GetSchemeData(SkinResID, CurPlanID)
            local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
            local avatar = TeamAvatarManager.GetAvatarByUid(DataMgr.roleData.uid)
            if avatar then
              avatar:ChangeDiyWeaponScheme(scheme)
            end
          end
        end
      end
    end
  end
end
function FashionBagEditUtils:StoreFashionBagEditData()
  log(bWriteLog and "FashionBagEditUtils:StoreFashionBagEditData. ")
  if self.EditIndex ~= nil then
    local TableUtil = require("common.table_util")
    self.EditIndex_Bak = self.EditIndex
    self.CurrentWearList_Bak = self.CurrentWearList
    self.CurrentKnapsack_Bak = self.CurrentKnapsack
    self.CurrentBagData_Bak = self.CurrentBagData
    self.bHasModified_Bak = self.bHasModified
    self.CurrentTryItemMap_Bak = self.CurrentTryItemMap
    self.restoreData_Bak = TableUtil.CopyTable(self.restoreData)
    local myAvatar = self:_GetMyAvatar()
    if myAvatar then
      self.restoreData_Temp = {
        _storeEquipments = myAvatar:GetEquipments()
      }
    end
    return true
  end
  return false
end
function FashionBagEditUtils:RestoreFashionBagData()
  log(bWriteLog and "FashionBagEditUtils:RestoreFashionBagData. ")
  self.EditIndex = self.EditIndex_Bak
  self.CurrentWearList = self.CurrentWearList_Bak
  self.CurrentKnapsack = self.CurrentKnapsack_Bak
  self.CurrentBagData = self.CurrentBagData_Bak
  self.bHasModified = self.bHasModified_Bak
  self.CurrentTryItemMap = self.CurrentTryItemMap_Bak
  self.restoreData = self.restoreData_Bak
  local myAvatar = self:_GetMyAvatar()
  if myAvatar and self.restoreData_Temp then
    myAvatar:SetStoreEquipments(self.restoreData_Temp._storeEquipments)
    myAvatar:RestoreEquipments()
    if self.restoreData_Temp._storeEquipments then
      for _, v in pairs(self.restoreData_Temp._storeEquipments) do
        self:HandleMyAvatarShapeInfo(myAvatar, v.itemID)
      end
    end
  end
  self.EditIndex_Bak = nil
  self.CurrentWearList_Bak = nil
  self.CurrentKnapsack_Bak = nil
  self.CurrentBagData_Bak = nil
  self.bHasModified_Bak = false
  self.CurrentTryItemMap_Bak = nil
  self.restoreData_Bak = nil
end
function FashionBagEditUtils:_UpdateHelmetShow()
  log(bWriteLog and "FashionBagEditUtils:_UpdateHelmetShow. ")
  local CurrentBagData = self.CurrentBagData
  if not CurrentBagData then
    return
  end
  local wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  local helmet_skin = CurrentBagData.helmet_skin_list[self:GetCurrentHelmetLevel()] or 0
  if helmet_skin == 0 then
    wardrobe_avatar:PutOffHelmetEquipmentAvatar()
  else
    local HelmetItemData = wardrobe_data:GetHallDepotItemDataByInsID(helmet_skin)
    if HelmetItemData then
      if helmet_skin == CurrentBagData.head_show then
        wardrobe_avatar:AvatarChange(HelmetItemData.resID, true)
        self:SetHelmetLevel(self:GetCurrentHelmetLevel(), true, false)
      else
        local HatWearIndex = wardrobe_fashion_utils:GetRoleWearIndexBySubType(ENUM_ITEM_SUBTYPE.Hat_Slot)
        local HatSkin = self.CurrentWearList and self.CurrentWearList[HatWearIndex] or 0
        if helmet_skin ~= 0 and HatSkin == 0 then
          self:SetHelmetLevel(self:GetCurrentHelmetLevel(), true, false)
        else
          wardrobe_avatar:AvatarChange(HelmetItemData.resID, false)
        end
      end
    end
  end
end
function FashionBagEditUtils:CanShowFashionBagGuide(GuideType)
  if not GuideType then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local FashionBagShowState = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFashionBagSaveGuideShowState) or {}
  local bHasShown = FashionBagShowState[GuideType]
  return not bHasShown
end
function FashionBagEditUtils:ClearFahsionBagGuide(GuideType)
  if not GuideType then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local FashionBagShowState = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFashionBagSaveGuideShowState) or {}
  FashionBagShowState[GuideType] = true
  PlayerPrefsSystem.SaveTableToFile_N(FashionBagShowState, PlayerPrefsSystem.ePlayerPrefsType.eFashionBagSaveGuideShowState)
end
function FashionBagEditUtils:ClearRolewear()
  local Avatar = self:_GetMyAvatar()
  if not Avatar then
    return
  end
  for k, v in pairs(ROLEWEAR_SUBTYPES) do
    Avatar:PutoffSubtype(v)
  end
end
function FashionBagEditUtils:OnXSuitUpgrade(_, __, Level, Period)
  log(bWriteLog and string.format("FashionBagEditUtils:OnXSuitUpgrade. Level=%s, Period=%s", tostring(Level), tostring(Period)))
  if not self.CurrentWearList or not self.CurrentWearList_Bak then
    return
  end
  local SuitSlotIndex = wardrobe_fashion_utils:GetRoleWearIndexBySubType(ENUM_ITEM_SUBTYPE.Package_Slot)
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local NewSuitItemID = LogicXSuit.GetItemIDByLevel(Period, Level)
  if not NewSuitItemID then
    return
  end
  local NewSuitItemData = wardrobe_data:GetHallDepotItemDataByResID(NewSuitItemID)
  if not NewSuitItemData then
    return
  end
  local NewSuitInsID = tonumber(NewSuitItemData.insID)
  if not NewSuitInsID then
    return
  end
  if not self.CachedInsID2ResID then
    self.CachedInsID2ResID = {}
  end
  self.CachedInsID2ResID[NewSuitInsID] = NewSuitItemID
  local OldInsID = self.CurrentWearList and self.CurrentWearList[SuitSlotIndex]
  local OldItemID = OldInsID and self.CachedInsID2ResID and self.CachedInsID2ResID[OldInsID]
  if OldItemID and LogicXSuit.IsXSuit(OldItemID) then
    local OldSuitPeriod = LogicXSuit.GetPeriodByItemId(OldItemID)
    if OldSuitPeriod and OldSuitPeriod == Period then
      self.CurrentWearList[SuitSlotIndex] = NewSuitInsID
      if not self.CurrentTryItemMap then
        self.CurrentTryItemMap = {}
      end
      self.CurrentTryItemMap[OldItemID] = nil
      self.CurrentTryItemMap[NewSuitItemID] = {ResID = NewSuitItemID, InsID = NewSuitInsID}
      if self.restoreData and self.restoreData._storeEquipments then
        for k, v in pairs(self.restoreData._storeEquipments) do
          if v.itemID == OldItemID then
            v.itemID = NewSuitItemID
          end
        end
      end
      if self.restoreData_Temp and self.restoreData_Temp._storeEquipments then
        for k, v in pairs(self.restoreData_Temp._storeEquipments) do
          if v.itemID == OldItemID then
            v.itemID = NewSuitItemID
          end
        end
      end
    end
  end
  local OldInsIDBak = self.CurrentWearList_Bak and self.CurrentWearList_Bak[SuitSlotIndex]
  local OldItemIDBak = OldInsIDBak and self.CachedInsID2ResID and self.CachedInsID2ResID[OldInsIDBak]
  if OldItemIDBak and LogicXSuit.IsXSuit(OldItemIDBak) then
    local OldSuitPeriod = LogicXSuit.GetPeriodByItemId(OldItemIDBak)
    if OldSuitPeriod and OldSuitPeriod == Period then
      self.CurrentWearList_Bak[SuitSlotIndex] = NewSuitInsID
      if not self.CurrentTryItemMap_Bak then
        self.CurrentTryItemMap_Bak = {}
      end
      self.CurrentTryItemMap_Bak[OldItemIDBak] = nil
      self.CurrentTryItemMap_Bak[NewSuitItemID] = {ResID = NewSuitItemID, InsID = NewSuitInsID}
      if self.restoreData_Bak and self.restoreData_Bak._storeEquipments then
        for k, v in pairs(self.restoreData_Bak._storeEquipments) do
          if v.itemID == OldItemID then
            v.itemID = NewSuitItemID
          end
        end
      end
    end
  end
end
function FashionBagEditUtils:OnSuitDyeUpgrade(_, __, Period, Level)
  log(bWriteLog and string.format("FashionBagEditUtils:OnSuitDyeUpgrade. SuitID=%s, Level=%s", tostring(Period), tostring(Level)))
  if not self.CurrentWearList or not self.CurrentWearList_Bak then
    return
  end
  if not self.CurrentWearList or not self.CurrentWearList_Bak then
    return
  end
  local SuitSlotIndex = wardrobe_fashion_utils:GetRoleWearIndexBySubType(ENUM_ITEM_SUBTYPE.Package_Slot)
  local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
  local NewSuitItemID = logic_suit_dye:GetSuitIdByPeriodLevel(Period, Level)
  if not NewSuitItemID then
    return
  end
  local NewSuitItemData = wardrobe_data:GetHallDepotItemDataByResID(NewSuitItemID)
  if not NewSuitItemData then
    return
  end
  local NewSuitInsID = tonumber(NewSuitItemData.insID)
  if not NewSuitInsID then
    return
  end
  if not self.CachedInsID2ResID then
    self.CachedInsID2ResID = {}
  end
  self.CachedInsID2ResID[NewSuitInsID] = NewSuitItemID
  local OldInsID = self.CurrentWearList and self.CurrentWearList[SuitSlotIndex]
  local OldItemID = OldInsID and self.CachedInsID2ResID and self.CachedInsID2ResID[OldInsID]
  if OldItemID and logic_suit_dye:IsDyeSuit(OldItemID) then
    local OldSuitPeriod = logic_suit_dye:GetPeriodBySuitId(OldItemID)
    if OldSuitPeriod and OldSuitPeriod == Period then
      self.CurrentWearList[SuitSlotIndex] = NewSuitInsID
      if not self.CurrentTryItemMap then
        self.CurrentTryItemMap = {}
      end
      self.CurrentTryItemMap[OldItemID] = nil
      self.CurrentTryItemMap[NewSuitItemID] = {ResID = NewSuitItemID, InsID = NewSuitInsID}
      if self.restoreData and self.restoreData._storeEquipments then
        for k, v in pairs(self.restoreData._storeEquipments) do
          if v.itemID == OldItemID then
            v.itemID = NewSuitItemID
          end
        end
      end
      if self.restoreData_Temp and self.restoreData_Temp._storeEquipments then
        for k, v in pairs(self.restoreData_Temp._storeEquipments) do
          if v.itemID == OldItemID then
            v.itemID = NewSuitItemID
          end
        end
      end
    end
  end
  local OldInsIDBak = self.CurrentWearList_Bak and self.CurrentWearList_Bak[SuitSlotIndex]
  local OldItemIDBak = OldInsIDBak and self.CachedInsID2ResID and self.CachedInsID2ResID[OldInsIDBak]
  if OldItemIDBak and logic_suit_dye:IsDyeSuit(OldItemIDBak) then
    local OldSuitPeriod = logic_suit_dye:GetPeriodBySuitId(OldItemIDBak)
    if OldSuitPeriod and OldSuitPeriod == Period then
      self.CurrentWearList_Bak[SuitSlotIndex] = NewSuitInsID
    end
    if not self.CurrentTryItemMap_Bak then
      self.CurrentTryItemMap_Bak = {}
    end
    self.CurrentTryItemMap_Bak[OldItemIDBak] = nil
    self.CurrentTryItemMap_Bak[NewSuitItemID] = {ResID = NewSuitItemID, InsID = NewSuitInsID}
    if self.restoreData_Bak and self.restoreData_Bak._storeEquipments then
      for k, v in pairs(self.restoreData_Bak._storeEquipments) do
        if v.itemID == OldItemID then
          v.itemID = NewSuitItemID
        end
      end
    end
  end
end
function FashionBagEditUtils:OnItemUpgrade(_, __, RetData)
  log(bWriteLog and string.format("FashionBagEditUtils:OnItemUpgrade. RetData=%s", tostring(RetData)))
  local NewInsID = RetData and RetData[1]
  local OldInsID = RetData and RetData[2]
  if not NewInsID or not OldInsID then
    return
  end
  if not self.CurrentBagData or not self.CurrentBagData_Bak then
    return
  end
  if self.CurrentBagData.weapon_list then
    for WeaponID, WeaponData in pairs(self.CurrentBagData.weapon_list) do
      if WeaponData.skin_id == OldInsID then
        WeaponData.skin_id = NewInsID
      end
    end
  end
  if self.CurrentBagData_Bak.weapon_list then
    for WeaponID, WeaponData in pairs(self.CurrentBagData_Bak.weapon_list) do
      if WeaponData.skin_id == OldInsID then
        WeaponData.skin_id = NewInsID
      end
    end
  end
  local bHasEquip = false
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if self.CurrentBagData.avatar_show then
    for k, v in pairs(self.CurrentBagData.avatar_show) do
      if (k == HallThemeUtils.knapsack_ext_weapon_skin or k == HallThemeUtils.knapsack_ext_second_weapon_skin) and v.instid == OldInsID then
        v.instid = NewInsID
        bHasEquip = true
      end
    end
  end
  if self.CurrentBagData_Bak.avatar_show then
    for k, v in pairs(self.CurrentBagData_Bak.avatar_show) do
      if (k == HallThemeUtils.knapsack_ext_weapon_skin or k == HallThemeUtils.knapsack_ext_second_weapon_skin) and v.instid == OldInsID then
        v.instid = NewInsID
        bHasEquip = true
      end
    end
  end
  local NewItemData = wardrobe_data:GetHallDepotItemDataByInsID(NewInsID)
  if bHasEquip and NewItemData then
    if self.CurrentTryItemMap then
      self.CurrentTryItemMap[NewItemData.resID] = {
        ResID = NewItemData.resID,
        InsID = NewItemData.insID
      }
    end
    if self.CurrentTryItemMap_Bak then
      self.CurrentTryItemMap_Bak[NewItemData.resID] = {
        ResID = NewItemData.resID,
        InsID = NewItemData.insID
      }
    end
  end
end
function FashionBagEditUtils:_CheckAvatarShow()
  local AvatarShow = self.CurrentBagData and self.CurrentBagData.avatar_show
  if not AvatarShow then
    return
  end
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  for k, v in pairs(AvatarShow) do
    if (k == HallThemeUtils.knapsack_ext_weapon_skin or k == HallThemeUtils.knapsack_ext_second_weapon_skin) and AvatarShow[k] then
      local WeaponID = AvatarShow[k].relat_param
      local WeaponSkinInsID = AvatarShow[k].instid
      if WeaponSkinInsID and WeaponSkinInsID ~= 0 then
        local ItemData = wardrobe_data:GetHallDepotItemDataByInsID(WeaponSkinInsID)
        if ItemData and ItemData.resID then
          local WeaponCfg = CDataTable.GetTableData("WeaponSkinMapping", ItemData.resID)
          if WeaponCfg and WeaponCfg.WeaponID ~= WeaponID then
            log_error(bWriteLog and string.format("FashionBagEditUtils:_CheckAvatarShow failed, slot:%s, relat_param:%s, inst_id:%s, WeaponID:%s", tostring(k), tostring(WeaponSkinInsID), tostring(WeaponCfg.WeaponID), tostring(WeaponID)))
          end
        end
      end
    end
  end
end
function FashionBagEditUtils:GetInstanceIDInBagEditBySubTabString(SubTabString)
  if not SubTabString then
    return 0
  end
  if WARDROBE_SUBTAB_STRING_2_WEARINDEX[SubTabString] then
    local InsID = self.CurrentWearList and self.CurrentWearList[WARDROBE_SUBTAB_STRING_2_WEARINDEX[SubTabString]] or 0
    if InsID ~= 0 and (SubTabString == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_clothes or SubTabString == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_suit) then
      local ItemData = wardrobe_data:GetHallDepotItemDataByInsID(InsID)
      if ItemData and ItemData.subTabType ~= SubTabString then
        InsID = 0
      end
    end
    return InsID
  elseif SubTabString == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_bag then
    return self.CurrentBagData and self.CurrentBagData.bag_skin or 0
  elseif SubTabString == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_helmet then
    return self.CurrentBagData and self.CurrentBagData.helmet_skin or 0
  end
  return 0
end
function FashionBagEditUtils:GetPreviewThemeSkinInsID()
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local avatar_show = self.CurrentBagData.avatar_show[HallThemeUtils.knapsack_ext_background]
  return avatar_show.instid or 0
end
function FashionBagEditUtils:GetPreviewThemeSkinResID()
  local InsID = self:GetPreviewThemeSkinInsID()
  local ItemData = wardrobe_data:GetHallDepotItemDataByInsID(InsID)
  if not (ItemData and ItemData.resID) or ItemData.resID == 0 then
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    return HallThemeUtils.GetDefaultThemeItemID()
  end
  return ItemData.resID
end
function FashionBagEditUtils:HandleMyAvatarShapeInfo(Avatar, ItemID)
  if not Avatar or not ItemID then
    return
  end
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  if logic_suit_multi_shape:CanCurrentSuitChangeHead(ItemID) then
    local ShapeID = logic_suit_multi_shape:GetSelfSuitShapeID(ItemID)
    if ShapeID then
      Avatar:HandleShapeInfo(ItemID, ShapeID)
    end
  end
end
function FashionBagEditUtils:GetEquipmentItemShowLevel(ItemSubType)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if ItemSubType == ENUM_ITEM_SUBTYPE.Backpack then
    return self:GetCurrentBackpackLevel()
  elseif ItemSubType == ENUM_ITEM_SUBTYPE.Helmet_NoLevel then
    return self:GetCurrentHelmetLevel()
  end
  return 3
end
function FashionBagEditUtils:GetCurrentLevelEquipmentResID(ResID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemCfg = CDataTable.GetTableData("Item", ResID)
  if itemCfg then
    local level = self:GetEquipmentItemShowLevel(itemCfg.ItemSubType)
    local itemMappingCfg = CDataTable.GetTableData("BackpackMapping", ResID)
    ResID = itemMappingCfg and itemMappingCfg["SkinItemIDLv" .. level] or ResID
  end
  return ResID
end
function FashionBagEditUtils:GetDepotBindRelation(type)
  if self.CurrentBagData then
    return self.CurrentBagData.depot_bind_relation[type]
  end
end
function FashionBagEditUtils:SetDepotBindRelation(type, op)
  if self.CurrentBagData then
    self.CurrentBagData.depot_bind_relation[type] = op
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    if type == HallThemeUtils.CONST_RELATION_TYPE.BAG then
      local bag_level = self:GetCurrentBackpackLevel()
      for i = 1, 3 do
        self.CurrentBagData.bag_skin_list[i] = self.CurrentBagData.bag_skin_list[bag_level]
      end
    elseif type == HallThemeUtils.CONST_RELATION_TYPE.HELMET then
      local helmet_level = self:GetCurrentHelmetLevel()
      for i = 1, 3 do
        self.CurrentBagData.helmet_skin_list[i] = self.CurrentBagData.helmet_skin_list[helmet_level]
      end
    end
  else
    log_error("FashionBagEditUtils:DepotBindRelation not CurrentBagData")
  end
end
function FashionBagEditUtils:BeginPreviewCurrentTheme()
  local PreviewThemeResID = self:GetPreviewThemeSkinResID()
  if PreviewThemeResID and PreviewThemeResID ~= 0 then
    local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
    LobbyThemeManager:BeginPreviewTheme(PreviewThemeResID, true, true)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CFashionBagEditUtils = class(CModuleBase, nil, FashionBagEditUtils)
return CFashionBagEditUtils