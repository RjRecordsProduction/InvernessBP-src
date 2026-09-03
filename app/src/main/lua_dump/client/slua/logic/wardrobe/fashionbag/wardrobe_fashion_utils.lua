local wardrobe_fashion_utils = {dev = false}
local util = require("client.slua_ui_framework.util")
local bPrint = true
local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local EnumSubTabString = wardrobe_macro.ENUM_WardrobeSubTabString
local EnumPageType = wardrobe_macro.ENUM_WardrobePageTypeId
local cachedShareSkinConfig = {}
local cachedResultGetBlackList
local quickIgnoredRecord = {}
local SubType2Index = {
  [401] = 1,
  [402] = 2,
  [403] = 3,
  [404] = 4,
  [405] = 5,
  [407] = 6,
  [ENUM_ITEM_SUBTYPE.Gloves] = 8
}
local DEFAULT_SKINS = {
  [504] = 501000,
  [901] = 1901001,
  [902] = 1902001,
  [903] = 1903001,
  [904] = 1904001,
  [905] = 1905001,
  [906] = 1906001,
  [907] = 1907001,
  [908] = 1908001,
  [909] = 1909001,
  [910] = 1910001,
  [911] = 1911001,
  [912] = 1912001,
  [913] = 1913001,
  [914] = 1914001,
  [915] = 1915001,
  [916] = 1916001,
  [917] = 1917001,
  [918] = 1918001,
  [919] = 1919001,
  [920] = 1920001,
  [953] = 1953001,
  [960] = 1960001,
  [961] = 1961001,
  [966] = 1966001,
  [801] = 1801101,
  [701] = 703001
}
local BAG_UNLOCK_MONEY_TYPE = {
  [2] = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/LOBBY_icon_jinbi_64x64_png.LOBBY_icon_jinbi_64x64_png",
  [3] = "/Game/Arts/UI/TableIcons/ItemIcon/Currency/Task_icon_dianquan_128.Task_icon_dianquan_128",
  [4] = "/Game/Arts/UI/TableIcons/UnknowPass/Pass_Normal.Pass_Normal"
}
local EBackpackClothArmorType = UEnums.EBackpackClothArmorType
local ItemSubType2ClothArmorType = {
  [400] = EBackpackClothArmorType.Cap,
  [401] = EBackpackClothArmorType.Cap,
  [402] = EBackpackClothArmorType.Mask,
  [403] = EBackpackClothArmorType.Jacket,
  [404] = EBackpackClothArmorType.Trouser,
  [405] = EBackpackClothArmorType.Shoe,
  [406] = EBackpackClothArmorType.Cap,
  [407] = EBackpackClothArmorType.Glasses,
  [452] = EBackpackClothArmorType.Gloves,
  [501] = EBackpackClothArmorType.RealPackage,
  [502] = EBackpackClothArmorType.RealHelmet,
  [504] = EBackpackClothArmorType.RealPackage,
  [505] = EBackpackClothArmorType.RealHelmet,
  [701] = EBackpackClothArmorType.Parachute,
  [801] = EBackpackClothArmorType.Aircraft
}
local FASHION_BAG_EDIT_VISIBLE_PAGE_TYPE = {
  [EnumPageType.ENUM_WardrobePageType_Avatar] = true,
  [EnumPageType.ENUM_WardrobePageType_Weapon] = true,
  [EnumPageType.ENUM_WardrobePageType_Parachute] = true
}
local FASHION_BAG_EDIT_VISIBLE_PARACHUTE_SUB_PAGE_TYPE = {
  [EnumSubTabString.ENUM_WardrobeSubTabString_parachute] = true,
  [EnumSubTabString.ENUM_WardrobeSubTabString_plane] = true,
  [EnumSubTabString.ENUM_WardrobeSubTabString_throw_object] = true,
  [EnumSubTabString.ENUM_WardrobeSubTabString_hallTheme] = true,
  [EnumSubTabString.ENUM_WardrobeSubTabString_effect] = true
}
local INHERIT_EDIT_VISIBLE_PAGE_TYPE = {
  [EnumPageType.ENUM_WardrobePageType_Avatar] = true,
  [EnumPageType.ENUM_WardrobePageType_Weapon] = true,
  [EnumPageType.ENUM_WardrobePageType_Vehicle] = true,
  [EnumPageType.ENUM_WardrobePageType_Parachute] = true
}
local INHERIT_EDIT_VISIBLE_PARACHUTE_SUB_PAGE_TYPE = {
  [EnumSubTabString.ENUM_WardrobeSubTabString_emoj] = true,
  [EnumSubTabString.ENUM_WardrobeSubTabString_effect] = true,
  [EnumSubTabString.ENUM_WardrobeSubTabString_throw_object] = true
}
local SHARE_BAG_SUPPORTED_SUBTYPE = {
  [ENUM_ITEM_SUBTYPE.Hat_Slot] = true,
  [ENUM_ITEM_SUBTYPE.Mask_Slot] = true,
  [ENUM_ITEM_SUBTYPE.Package_Slot] = true,
  [ENUM_ITEM_SUBTYPE.Pants_Slot] = true,
  [ENUM_ITEM_SUBTYPE.Shoes_Slot] = true,
  [ENUM_ITEM_SUBTYPE.Eye_Slot] = true,
  [ENUM_ITEM_SUBTYPE.Gloves] = true,
  [ENUM_ITEM_SUBTYPE.Backpack] = true,
  [ENUM_ITEM_SUBTYPE.Helmet_NoLevel] = true
}
local diySummaryReqingMap = {}
local _GetDiyPlanIdSafe = function(weaponResID)
  local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if weaponResID == nil then
    log(bWriteLog and "wardrobe_fashion_utils:_GetDiyPlanIdSafe[1] invalid weaponResID")
    return nil
  end
  if WeaponDiySystem and WeaponDiySystem.IsDIYWeapon and not WeaponDiySystem:IsDIYWeapon(weaponResID) then
    return nil
  end
  local planID = WeaponDiySystem and WeaponDiySystem.GetCurUsePlanIdByWeaponId and WeaponDiySystem:GetCurUsePlanIdByWeaponId(weaponResID)
  if planID ~= nil and planID ~= 0 then
    return planID
  end
  if not diySummaryReqingMap[weaponResID] then
    diySummaryReqingMap[weaponResID] = true
    if WeaponDiySystem and WeaponDiySystem.GetDiyItemSummaryDataReq then
      log_format("wardrobe_fashion_utils:_GetDiyPlanIdSafe[4] request diy summary. weaponResID:%s", tostring(weaponResID))
      WeaponDiySystem:GetDiyItemSummaryDataReq(weaponResID)
    else
      log(bWriteLog and "wardrobe_fashion_utils:_GetDiyPlanIdSafe[4] WeaponDiySystem missing summary req API")
    end
  end
  return nil
end
local _Trans = function(insId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  return wardrobe_data:GetHallDepotItemDataByInsID(insId)
end
local _TransWithFilter = function(insId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local item = wardrobe_data:GetHallDepotItemDataByInsID(insId)
  if not item then
    return item, true
  end
  return item, not wardrobe_fashion_utils.CanBeSharedByItem(item)
end
local _GetWeaponSkinList = function(weapon_skin_list)
  local list = {}
  if weapon_skin_list == nil then
    return list
  end
  for k, v in pairs(weapon_skin_list) do
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemCfg = wardrobe_data:GetHallDepotItemDataByInsID(v.skin_id)
    if itemCfg then
      local tmp = {}
      tmp.weaponId = k
      tmp.itemQuality = itemCfg.itemQuality
      tmp.resID = itemCfg.resID
      local planID = _GetDiyPlanIdSafe(itemCfg.resID)
      if planID then
        tmp.      end
      table.insert(list, tmp)
    end
  end
  if 0 < #list then
    table.sort(list, function(a, b)
      return a.weaponId < b.weaponId
    end)
  end
  return list
end
local _GetPlaneSkinList = function(fly_skin, wingman_skin)
  local list = {}
  if fly_skin then
    local planeData = _Trans(fly_skin)
    if planeData then
      local tmp = {
        resID = planeData.resID,
        vehicleType = planeData.itemSubType,
        itemQuality = planeData.itemQuality
      }
      table.insert(list, tmp)
    end
  end
  if wingman_skin then
    local wingmanData = _Trans(wingman_skin)
    if wingmanData then
      local tmp = {
        resID = wingmanData.resID,
        vehicleType = wingmanData.itemSubType,
        itemQuality = wingmanData.itemQuality
      }
      table.insert(list, tmp)
    end
  end
  return list
end
local setImg = function(widget, resID)
  widget.Image_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local UIUtil = require("client.common.ui_util")
  local iconPath = UIUtil.GetItemBigIcon(resID)
  if iconPath then
    widget.Image_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Image_ClothingItemIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    util.SetTexture(widget.Image_ClothingItemIcon, iconPath, {sync = false})
  end
end
local setBg = function(widget, itemQuality, itemID)
  widget.Image_Quality_Bg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if itemQuality ~= 0 then
    local UIUtil = require("client.common.ui_util")
    local specialQualityBg, bHasAddKnownMissing = UIUtil.GetSpecialQualityBg(itemID, widget.Image_Quality_Bg)
    if specialQualityBg and specialQualityBg ~= "" then
      widget.Image_Quality_Bg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      widget.Image_ClothingSlotBG:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
      util.SetTexture(widget.Image_Quality_Bg, specialQualityBg, {bHasAddKnownMissing = bHasAddKnownMissing})
      return
    end
    local bgPath = UIUtil.GetBgQualityPath(itemQuality)
    if bgPath then
      widget.Image_Quality_Bg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      widget.Image_ClothingSlotBG:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
      util.SetTexture(widget.Image_Quality_Bg, bgPath)
    end
  end
end
local setNum = function(widget, num)
  widget.TextBlock_Num:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if num then
    widget.TextBlock_Num:SetText(tostring(num))
    widget.TextBlock_Num:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
local setIcon = function(widget, itemCfg, level)
  log(bWriteLog and string.format("setIcon, ctl:%s", tostring(widget)))
  if not widget then
    return
  end
  widget.CanvasPanel_Freeze:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.Panel_Download:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.Image_Quality_Bg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.Image_ClothingItemIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.Image_Icon_Quality_Bottom:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if widget.Switcher_Joint then
    widget.Switcher_Joint:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local UIUtil = require("client.common.ui_util")
  if itemCfg then
    local resID = itemCfg.resID
    if not itemCfg.itemSubType or itemCfg.resID ~= DEFAULT_SKINS[tonumber(itemCfg.itemSubType)] then
      if level then
        resID = DataMgr.GetEquipmentItemIDByResID(level, resID)
      end
      setImg(widget, resID)
      setBg(widget, itemCfg.itemQuality, resID)
      UIUtil.SetItemCoBrandedVisibility(itemCfg.resID, widget)
      local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
      local tItemData = wardrobe_data:GetHallDepotItemDataByResID(resID)
      if tItemData and tItemData.lock_cnt and tItemData.lock_cnt > 0 then
        widget.CanvasPanel_Freeze:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
    elseif itemCfg.resID == DEFAULT_SKINS[tonumber(itemCfg.itemSubType)] then
      widget:ShowNull()
      UIUtil.SetItemCoBrandedVisibility(0, widget)
    end
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local common_download_handler = require("client.slua.common.common_download_handler")
    common_download_handler.CreateDownloadUI(PufferConst.ENUM_DownloadType.ODPAK, {resID}, widget.Panel_Download)
  else
    widget:ShowNull()
    UIUtil.SetItemCoBrandedVisibility(0, widget)
  end
end
local setIconWithIgnored = function(widget, itemCfg, bGray)
  log(bWriteLog and string.format("setIconWithIgnored. widget=%s, itemCfg=%s, bGray=%s", tostring(widget), tostring(itemCfg), tostring(bGray)))
  if not widget then
    return
  end
  widget.Panel_Download:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.Image_Quality_Bg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.Image_ClothingItemIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.Image_Icon_Quality_Bottom:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if itemCfg then
    if not itemCfg.itemSubType or itemCfg.resID ~= DEFAULT_SKINS[tonumber(itemCfg.itemSubType)] then
      setImg(widget, itemCfg.resID)
      setBg(widget, itemCfg.itemQuality, itemCfg.resID)
      local UIUtil = require("client.common.ui_util")
      UIUtil.SetItemCoBrandedVisibility(itemCfg.resID, widget)
    else
      if itemCfg.resID == DEFAULT_SKINS[tonumber(itemCfg.itemSubType)] then
        widget:ShowNull()
        local UIUtil = require("client.common.ui_util")
        UIUtil.SetItemCoBrandedVisibility(0, widget)
      end
      bGray = false
    end
    if itemCfg.bIgnored ~= nil then
      bGray = itemCfg.bIgnored
    end
    if bGray then
      widget.Canvas_Clothingmask:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      widget.Canvas_Clothingmask:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local common_download_handler = require("client.slua.common.common_download_handler")
    common_download_handler.CreateDownloadUI(PufferConst.ENUM_DownloadType.ODPAK, {
      itemCfg.resID
    }, widget.Panel_Download)
  else
    widget.Canvas_Clothingmask:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if itemCfg == nil then
      widget:ShowNull()
      local UIUtil = require("client.common.ui_util")
      UIUtil.SetItemCoBrandedVisibility(0, widget)
    end
  end
end
function wardrobe_fashion_utils.UpdateGridView(indexWidget, rolewear_list, knapsack_ext_info)
  print(bWriteLog and " wardrobe_fashion_utils.UpdateGridView")
  local roleWearList = {}
  if rolewear_list then
    for _, ins_id in pairs(rolewear_list) do
      local tmp = _Trans(ins_id)
      if tmp and tmp.itemSubType and tmp.resID then
        local resID = tmp.resID
        local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
        if LogicXSuit.IsXSuit(resID) then
          resID = LogicXSuit.ChangeItemIDByInsID(ins_id)
        end
        roleWearList[tmp.itemSubType] = {
          resID = resID,
          itemQuality = tmp.itemQuality
        }
      end
    end
  end
  local TableUtil = require("common.table_util")
  local clothesId = TableUtil.GetTableValue(roleWearList, ENUM_ITEM_SUBTYPE.Package_Slot, "resID")
  local hatId = TableUtil.GetTableValue(roleWearList, ENUM_ITEM_SUBTYPE.Hat_Slot, "resID")
  if hatId and clothesId then
    local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
    local specialHat = golden_suit_module:GetSpecialHatId(clothesId, hatId)
    log(bWriteLog and "  wardrobe_fashion_utils.UpdateGridView. specialHat: " .. tostring(specialHat))
    if specialHat then
      roleWearList[ENUM_ITEM_SUBTYPE.Hat_Slot].resID = specialHat
    end
  end
  setIcon(indexWidget.ClothingSlotItem_Cap, roleWearList[ENUM_ITEM_SUBTYPE.Hat_Slot])
  setIcon(indexWidget.ClothingSlotItem_Mask, roleWearList[ENUM_ITEM_SUBTYPE.Mask_Slot])
  setIcon(indexWidget.ClothingSlotItem_Glasses, roleWearList[ENUM_ITEM_SUBTYPE.Eye_Slot])
  setIcon(indexWidget.ClothingSlotItem_Jacket, roleWearList[ENUM_ITEM_SUBTYPE.Package_Slot])
  setIcon(indexWidget.ClothingSlotItem_Trouser, roleWearList[ENUM_ITEM_SUBTYPE.Pants_Slot])
  setIcon(indexWidget.ClothingSlotItem_Shoe, roleWearList[ENUM_ITEM_SUBTYPE.Shoes_Slot])
  setIcon(indexWidget.ClothingSlotItem_Hand, roleWearList[ENUM_ITEM_SUBTYPE.Gloves])
  if knapsack_ext_info then
    setIcon(indexWidget.ClothingSlotItem_Parachute, _Trans(knapsack_ext_info.parachute))
    setIcon(indexWidget.ClothingSlotItem_Aircraft, _Trans(knapsack_ext_info.fly_skin))
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    local helmet_skin = knapsack_ext_info.helmet_skin
    local bag_skin = knapsack_ext_info.bag_skin
    if knapsack_ext_info.depot_bind_relation then
      if knapsack_ext_info.depot_bind_relation[HallThemeUtils.CONST_RELATION_TYPE.HELMET] then
        helmet_skin = knapsack_ext_info.helmet_skin_list[knapsack_ext_info.helmet_level or 3] or 0
      end
      if knapsack_ext_info.depot_bind_relation[HallThemeUtils.CONST_RELATION_TYPE.BAG] then
        bag_skin = knapsack_ext_info.bag_skin_list[knapsack_ext_info.bag_level or 3] or 0
      end
    end
    setIcon(indexWidget.ClothingSlotItem_RealHelmet, _Trans(helmet_skin), knapsack_ext_info.helmet_level or 3)
    setIcon(indexWidget.ClothingSlotItem_RealPackage, _Trans(bag_skin), knapsack_ext_info.bag_level or 3)
    local SkateboardInsID = knapsack_ext_info.gliding and knapsack_ext_info.gliding ~= 0 and knapsack_ext_info.gliding or knapsack_ext_info.aircraft_put_id or 0
    setIcon(indexWidget.ClothingSlotItem_Skateboard, _Trans(SkateboardInsID))
    setNum(indexWidget.ClothingSlotItem_Guns, #_GetWeaponSkinList(knapsack_ext_info.weapon_skin_list) or 0)
    setNum(indexWidget.ClothingSlotItem_Aircraft, #_GetPlaneSkinList(knapsack_ext_info.fly_skin, knapsack_ext_info.wingman_skin) or 0)
  end
end
function wardrobe_fashion_utils.UpdateGridViewWithFilter(indexWidget, rolewear_list, knapsack_ext_info)
  local roleWearList = {}
  local validInstIdList = {}
  if rolewear_list then
    for _, insId in pairs(rolewear_list) do
      local tmp, bIgnored = _TransWithFilter(insId)
      if tmp and tmp.itemSubType and tmp.resID then
        local resID = tmp.resID
        local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
        if LogicXSuit.IsXSuit(resID) then
          resID = LogicXSuit.ChangeItemIDByInsID(insId)
        end
        roleWearList[tmp.itemSubType] = {
          resID = resID,
          itemQuality = tmp.itemQuality,
                  }
        if not bIgnored then
          table.insert(validInstIdList, tonumber(insId))
        end
      end
    end
  end
  local TableUtil = require("common.table_util")
  local clothesId = TableUtil.GetTableValue(roleWearList, ENUM_ITEM_SUBTYPE.Package_Slot, "resID")
  local hatId = TableUtil.GetTableValue(roleWearList, ENUM_ITEM_SUBTYPE.Hat_Slot, "resID")
  if hatId and clothesId then
    local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
    local specialHat = golden_suit_module:GetSpecialHatId(clothesId, hatId)
    log(bWriteLog and "  wardrobe_fashion_utils.UpdateGridViewWithFilter. specialHat: " .. tostring(specialHat))
    if specialHat then
      roleWearList[ENUM_ITEM_SUBTYPE.Hat_Slot].resID = specialHat
    end
  end
  setIconWithIgnored(indexWidget.ClothingSlotItem_Cap, roleWearList[ENUM_ITEM_SUBTYPE.Hat_Slot])
  setIconWithIgnored(indexWidget.ClothingSlotItem_Mask, roleWearList[ENUM_ITEM_SUBTYPE.Mask_Slot])
  setIconWithIgnored(indexWidget.ClothingSlotItem_Glasses, roleWearList[ENUM_ITEM_SUBTYPE.Eye_Slot])
  setIconWithIgnored(indexWidget.ClothingSlotItem_Jacket, roleWearList[ENUM_ITEM_SUBTYPE.Package_Slot])
  setIconWithIgnored(indexWidget.ClothingSlotItem_Trouser, roleWearList[ENUM_ITEM_SUBTYPE.Pants_Slot])
  setIconWithIgnored(indexWidget.ClothingSlotItem_Shoe, roleWearList[ENUM_ITEM_SUBTYPE.Shoes_Slot])
  setIconWithIgnored(indexWidget.ClothingSlotItem_Hand, roleWearList[ENUM_ITEM_SUBTYPE.Gloves])
  local p_parachute, ignore_p_parachute = _TransWithFilter(knapsack_ext_info.parachute)
  local p_fly_skin, ignore_p_fly_skin = _TransWithFilter(knapsack_ext_info.fly_skin)
  local p_helmet_skin, ignore_p_helmet_skin = _TransWithFilter(knapsack_ext_info.helmet_skin)
  local p_bag_skin, ignore_p_bag_skin = _TransWithFilter(knapsack_ext_info.bag_skin)
  local SkateboardInsID = knapsack_ext_info.gliding and knapsack_ext_info.gliding ~= 0 and knapsack_ext_info.gliding or knapsack_ext_info.aircraft_put_id or 0
  local p_bag_skateboard, ignore_p_bag_skateboard = _TransWithFilter(SkateboardInsID)
  log(bWriteLog and string.format("wardrobe_fashion_utils.UpdateGridViewWithFilter. indexWidget=%s, p_parachute=%s, ignore_p_parachute=%s", tostring(indexWidget), tostring(p_parachute), tostring(ignore_p_parachute)))
  setIconWithIgnored(indexWidget.ClothingSlotItem_Parachute, p_parachute, ignore_p_parachute)
  setIconWithIgnored(indexWidget.ClothingSlotItem_Aircraft, p_fly_skin, ignore_p_fly_skin)
  setIconWithIgnored(indexWidget.ClothingSlotItem_RealHelmet, p_helmet_skin, ignore_p_helmet_skin)
  setIconWithIgnored(indexWidget.ClothingSlotItem_RealPackage, p_bag_skin, ignore_p_bag_skin)
  setIconWithIgnored(indexWidget.ClothingSlotItem_Skateboard, p_bag_skateboard, ignore_p_bag_skateboard)
  setNum(indexWidget.ClothingSlotItem_Guns, #_GetWeaponSkinList(knapsack_ext_info.weapon_skin_list) or 0)
  setNum(indexWidget.ClothingSlotItem_Aircraft, #_GetPlaneSkinList(knapsack_ext_info.fly_skin, knapsack_ext_info.wingman_skin) or 0)
  if not ignore_p_parachute then
    table.insert(validInstIdList, tonumber(knapsack_ext_info.parachute))
  end
  if not ignore_p_fly_skin then
    table.insert(validInstIdList, tonumber(knapsack_ext_info.fly_skin))
  end
  if not ignore_p_helmet_skin then
    table.insert(validInstIdList, tonumber(knapsack_ext_info.helmet_skin))
  end
  if not ignore_p_bag_skin then
    table.insert(validInstIdList, tonumber(knapsack_ext_info.bag_skin))
  end
  return validInstIdList
end
function wardrobe_fashion_utils.CanBeShared(nInstId)
  local _, bIgnored = _TransWithFilter(nInstId)
  return not bIgnored
end
function wardrobe_fashion_utils.CanBeSharedByItem(item)
  if quickIgnoredRecord[item.resID] then
    return false
  end
  local params = wardrobe_fashion_utils.GetShareSkinConfigLazy()
  local Quality, unSortedVars = params.Quality, params.unSortedVars
  local blackList = wardrobe_fashion_utils.GetBlackList()
  if not unSortedVars[item.itemSubType] then
    if bPrint then
      print(bWriteLog and " wardrobe_fashion_utils.CanBeSharedByItem not opened type:" .. item.itemSubType)
    end
    quickIgnoredRecord[item.resID] = true
    return false
  end
  if blackList[item.resID] then
    if bPrint then
      print(bWriteLog and " wardrobe_fashion_utils.CanBeSharedByItem in blacklist:" .. item.resID)
    end
    quickIgnoredRecord[item.resID] = true
    return false
  end
  if Quality < item.itemQuality then
    if bPrint then
      print(bWriteLog and " wardrobe_fashion_utils.CanBeSharedByItem quality bigger:" .. item.itemQuality)
    end
    quickIgnoredRecord[item.resID] = true
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  if item.insID and wardrobe_data:GetItemSource(item.insID) == EWardrobeDataSource.InheritWardrobe then
    if bPrint then
      print(bWriteLog and " wardrobe_fashion_utils.CanBeSharedByItem is inherit item:" .. item.insID)
    end
    return false
  end
  return true
end
function wardrobe_fashion_utils.CanBeSharedByItemConfig(itemCfg)
  if quickIgnoredRecord[itemCfg.ItemID] then
    return false
  end
  local params = wardrobe_fashion_utils.GetShareSkinConfigLazy()
  local Quality, unSortedVars = params.Quality, params.unSortedVars
  local blackList = wardrobe_fashion_utils.GetBlackList()
  if not unSortedVars[itemCfg.ItemSubType] then
    if bPrint then
      print(bWriteLog and " wardrobe_fashion_utils.CanBeSharedByItemConfig not opened type:" .. itemCfg.ItemSubType)
    end
    quickIgnoredRecord[itemCfg.ItemID] = true
    return false
  end
  if blackList[itemCfg.ItemID] then
    if bPrint then
      print(bWriteLog and " wardrobe_fashion_utils.CanBeSharedByItemConfig in blacklist:" .. itemCfg.ItemID)
    end
    quickIgnoredRecord[itemCfg.ItemID] = true
    return false
  end
  if Quality < itemCfg.ItemQuality then
    if bPrint then
      print(bWriteLog and " wardrobe_fashion_utils.CanBeSharedByItemConfig quality bigger:" .. itemCfg.ItemQuality)
    end
    quickIgnoredRecord[itemCfg.ItemID] = true
    return false
  end
  return true
end
function wardrobe_fashion_utils.GetBlackList()
  if cachedResultGetBlackList then
    return cachedResultGetBlackList
  end
  local list = CDataTable.GetTableByFilter("FriendShareBagBlacklist", "bShield", 1)
  local t = {}
  for k, v in pairs(list) do
    t[k] = true
  end
  cachedResultGetBlackLis  return cachedResultGetBlackList
end
function wardrobe_fashion_utils.GetShareSkinConfigLazy()
  if next(cachedShareSkinConfig) then
    return cachedShareSkinConfig
  end
  local awardid = 20005
  local tosplit = ""
  local Quality = 5
  local UseTimes = 5
  local ShareTimes = 5
  local cfgs = CDataTable.GetTableByFilter("IntimacyPartnerAward", "AwardID1", awardid)
  for _, v in pairs(cfgs) do
    tosplit = v.SubTypes
    Quality = v.Quality
    UseTimes = v.UseTimes
    ShareTimes = v.ShareTimes
    break
  end
  local StringUtil = require("common.string_util")
  local openedSubtypes = StringUtil.Split(tosplit, "|")
  local sortedVars = {}
  local sortedVarsForRepeat = {}
  local unSortedVars = {}
  for _, v in pairs(openedSubtypes) do
    local numberV = tonumber(v)
    local ClothArmorType = ItemSubType2ClothArmorType[numberV]
    if not sortedVarsForRepeat[ClothArmorType] then
      sortedVarsForRepeat[ClothArmorType] = true
      sortedVars[#sortedVars + 1] = {ClothArmorType = ClothArmorType, subtype = numberV}
    end
    print(bWriteLog and " wardrobe_fashion_utils.GetOpenedSlotAndQuality  v :" .. numberV)
    unSortedVars[numberV] = true
  end
  table.sort(sortedVars, function(a, b)
    return a.ClothArmorType < b.ClothArmorType
  end)
  cachedShareSkinConfig = {
    sortedVars = sortedVars,
    Quality = Quality,
    unSortedVars = unSortedVars,
    UseTimes = UseTimes,
      }
  print(bWriteLog and string.format(" wardrobe_fashion_utils.GetShareSkinConfigLazy UseTimes:%s,ShareTimes:%s", UseTimes, ShareTimes))
  return cachedShareSkinConfig
end
function wardrobe_fashion_utils.GetSupportSubTypeForShareBag()
  return SHARE_BAG_SUPPORTED_SUBTYPE
end
function wardrobe_fashion_utils.CanBeSharedInShareBag(itemData, ShareType)
  if not itemData then
    return false
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if LogicXSuit.IsXSuit(itemData.resID) then
    return false
  end
  if itemData.validHours and itemData.validHours > 0 then
    return false
  end
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local qualityLimit = WardrobeLogicManager:GetSharedBackpackQualityLimit(ShareType)
  if qualityLimit < itemData.itemQuality then
    return false
  end
  local blacklist = WardrobeLogicManager:GetSharedBackpackBlackItemTable()
  if blacklist[itemData.resID] then
    return false
  end
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  for _, v in pairs(logic_share_bag_privilege_util.ENUM_ShareType) do
    if v ~= ShareType then
      local ShareItemListOfOtherType = logic_share_bag_privilege_util:GetShareItemsByShareType(v, true)
      if ShareItemListOfOtherType and ShareItemListOfOtherType[itemData.resID] then
        return false
      end
    end
  end
  return true
end
function wardrobe_fashion_utils:CheckTabShowByPageType(WardrobeEditMode, WardrobePageType, ExtraData)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if WardrobeEditMode == wardrobe_macro.EWardrobeEditMode.None then
    return true
  end
  if WardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Intimacy then
    return WardrobePageType == wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar
  elseif WardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag then
    local share_bag_macros = require("client.slua.logic.share_bag.share_bag_macros")
    local shareBagSubType = ExtraData and ExtraData.shareBagSubType
    if shareBagSubType == share_bag_macros.ENUM_ShareType.Subscribe or shareBagSubType == share_bag_macros.ENUM_ShareType.Collection then
      return WardrobePageType == wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar
    elseif shareBagSubType == share_bag_macros.ENUM_ShareType.Weapon then
      return WardrobePageType == wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon
    end
    return false
  elseif WardrobeEditMode == wardrobe_macro.EWardrobeEditMode.FashionBag then
    if FASHION_BAG_EDIT_VISIBLE_PAGE_TYPE[WardrobePageType] then
      return true
    end
    return false
  elseif WardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Inherit then
    if INHERIT_EDIT_VISIBLE_PAGE_TYPE[WardrobePageType] then
      return true
    end
    return false
  end
  return true
end
function wardrobe_fashion_utils:CheckSubTabShowBySubTabInfo(WardrobeEditMode, WardrobePageType, SubTabID, ItemSubTypeList)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.None then
    return true
  end
  if WardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag or WardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Intimacy then
    local supportSubTypeMap
    if WardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag then
      supportSubTypeMap = wardrobe_fashion_utils.GetSupportSubTypeForShareBag()
    elseif WardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Intimacy then
      supportSubTypeMap = wardrobe_fashion_utils.GetShareSkinConfigLazy().unSortedVars
    end
    if not supportSubTypeMap then
      return false
    end
    if ItemSubTypeList and next(ItemSubTypeList) then
      for kk, vv in pairs(ItemSubTypeList) do
        if supportSubTypeMap[vv] then
          return true
        end
      end
    end
    return false
  elseif WardrobeEditMode == wardrobe_macro.EWardrobeEditMode.FashionBag then
    if WardrobePageType == wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute then
      return FASHION_BAG_EDIT_VISIBLE_PARACHUTE_SUB_PAGE_TYPE[SubTabID]
    end
    return true
  elseif WardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Inherit then
    if WardrobePageType == wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute then
      return INHERIT_EDIT_VISIBLE_PARACHUTE_SUB_PAGE_TYPE[SubTabID]
    end
    return true
  end
  return true
end
function wardrobe_fashion_utils:GetRoleWearIndexBySubType(SubType)
  if not SubType then
    return nil
  end
  return SubType2Index[SubType]
end
wardrobe_fashion_utils.wardrobe_fashion_utils.wardrobe_fashion_utils.wardrobe_fashion_utils.wardrobe_fashion_utils.wardrobe_fashion_utils.wardrobe_fashion_utils.return wardrobe_fashion_utils