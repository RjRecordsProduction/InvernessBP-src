local WardrobeAvatarLogic = {}
local currentWearPreviewMap = {}
local currentWearPreviewMapInited = false
function WardrobeAvatarLogic:InitCurrentWearPreviewMap(bForceInit)
  if currentWearPreviewMapInited and not bForceInit then
    return
  end
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  if not DataEntity.bInit then
    return
  end
  currentWearPreviewMap = {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local tRoleWear = AvatarData.GetRoleWear()
  if tRoleWear then
    for _, insID in pairs(tRoleWear) do
      local itemData = wardrobe_data:GetHallDepotItemDataByInsID(insID)
      if itemData then
        self:AddToWearInfo(itemData.itemSubType, itemData.insID, itemData.resID, itemData.colorID, itemData.patternID)
      end
    end
  end
  if DataMgr.equipmentSkinInsIDTable ~= nil then
    for _, insID in pairs(DataMgr.equipmentSkinInsIDTable) do
      local itemData = wardrobe_data:GetHallDepotItemDataByInsID(insID)
      if itemData then
        self:AddToWearInfo(itemData.itemSubType, itemData.insID, itemData.resID, itemData.colorID, itemData.patternID)
      end
    end
  end
  currentWearPreviewMapInited = true
end
function WardrobeAvatarLogic:AddToWearInfo(itemSubType, itemInsID, itemResID, colorID, patternID)
  currentWearPreviewMap[itemSubType] = {
    insID = itemInsID,
    resID = itemResID,
    colorID = colorID or 0,
    patternID = patternID or 0
  }
end
function WardrobeAvatarLogic:ChangeAvatarEquipment(itemResID, puton, colorID, patternID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = CDataTable.GetTableData("Item", itemResID)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  if itemData and self:IsItemSubType_Bag_Helmet_Armor(itemData.ItemSubType) then
    if not puton then
      for i = 1, 3 do
        local levelItemResID = self:GetEquipemntResIDByLevel(itemResID, i)
        TeamAvatarManager.ChangeAvatarEquipment(DataMgr.roleData.uid, AvatarData.CreateAvatarCustom(levelItemResID, colorID, patternID), puton)
      end
      return
    end
    itemResID = self:GetCurrentLevelEquipemntResID(itemResID)
  end
  TeamAvatarManager.ChangeAvatarEquipment(DataMgr.roleData.uid, AvatarData.CreateAvatarCustom(itemResID, colorID, patternID), puton)
end
function WardrobeAvatarLogic:AvatarChange(itemResID, puton, colorID, patternID)
  print(bWriteLog and "WardrobeAvatarLogic:AvatarChange", itemResID, puton, colorID, patternID)
  self:ChangeAvatarEquipment(itemResID, puton, colorID, patternID)
  local WeaponDiffColorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.WeaponDiffColorModule)
  WeaponDiffColorModule:SwitchWeaponSkinByClothID(itemResID, puton)
  return itemResID
end
local IsWearByItemSubType = function(subType)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if subType == ENUM_ITEM_SUBTYPE.Glider_Slot_415 or subType == ENUM_ITEM_SUBTYPE.Backpack_Pendant_Skin then
    return false
  end
  return math.floor(subType / 100) == 4 or DataMgr.equipmentSkinInsIDTable[subType]
end
function WardrobeAvatarLogic.OnSelectFashionBagSucess(_, __, CurrentIndex)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local bagIndex = fashionbag_data:GetFashionBagUseIndex()
  HallThemeUtils.ProcSwitchUseWearBag(bagIndex)
  local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local WeaponDiffColorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.WeaponDiffColorModule)
  local ClothSource
  for k, v in pairs(currentWearPreviewMap) do
    if IsWearByItemSubType(k) then
      local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
      local resID = v.resID
      if LogicXSuit.IsXSuit(resID) then
        resID = LogicXSuit.GetItemShowID(v.insID)
      end
      if k == ENUM_ITEM_SUBTYPE.Package_Slot then
        ClothSource = wardrobe_data:GetItemSource(v.insID)
      end
      WardrobeAvatarLogic:ChangeAvatarEquipment(resID, false)
      golden_suit_module:ModifyVehicleWhenPutOff({resID = resID})
    end
  end
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  wardrobeLogic:UpdateInvalidWearInfo(nil)
  currentWearPreviewMapInited = false
  WardrobeAvatarLogic:InitCurrentWearPreviewMap()
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local takeOffTimes = 0
  local bag = fashionbag_data:GetFashionBag(bagIndex)
  for k, v in pairs(currentWearPreviewMap) do
    if not IsWearByItemSubType(k) or k == ENUM_ITEM_SUBTYPE.Helmet_NoLevel and tonumber(v.insID) ~= bag.head_show then
    else
      local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
      local resID = LogicXSuit.GetItemShowID(v.insID)
      if k == ENUM_ITEM_SUBTYPE.Package_Slot then
        ClothSource = wardrobe_data:GetItemSource(v.insID)
      end
      WardrobeAvatarLogic:ChangeAvatarEquipment(resID, true, v.colorID, v.patternID)
      golden_suit_module:ModifyVehicleWhenPutOn(resID)
      if WardrobeAvatarLogic:ProcessTakeOff() then
        takeOffTimes = takeOffTimes + 1
      end
    end
  end
  local CurrentCloth = WeaponDiffColorModule:GetCurrentClothID()
  WeaponDiffColorModule:SwitchWeaponSkinByClothID(CurrentCloth, true, ClothSource)
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local pre_bag_pendants = fashionbag_data:GetPreBagPendants()
  for insId, _ in pairs(pre_bag_pendants) do
    logic_wardrobe:ShowBagPendantModel(insId, false)
  end
  local cur_bag_pendants = fashionbag_data:GetBagPendants()
  for insId, _ in pairs(cur_bag_pendants) do
    logic_wardrobe:ShowBagPendantModel(insId, true)
  end
  local async = require("client.common.async")
  async.Run(function(co)
    for i = 1, takeOffTimes do
      local itemList = async.AwaitEvent(co, 5, EVENTTYPE_WARDROBE, EVENTID_WARDROBE_BATCH_PUTDOWN)
      print(bWriteLog and "TakeOff response:", i)
      log_tree("on_depot_batch_put_down_rsp:", itemList)
    end
    local fashionbag_undo = require("client.slua.logic.wardrobe.fashionbag.fashionbag_undo")
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    fashionbag_undo.OnOpenBag(fashionbag_data:GetFashionBagUseIndex())
  end)
end
function WardrobeAvatarLogic:ResetCurrentWearPreviewMapInited()
  currentWearPreviewMapInited = false
end
function WardrobeAvatarLogic:HasWearSubType(itemSubType)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local tRoleWear = AvatarData.GetRoleWear()
  for _, v in pairs(tRoleWear) do
    local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(v)
    if itemInfo ~= nil and itemInfo.itemSubType == itemSubType then
      return v
    end
  end
  for _, v in pairs(DataMgr.equipmentSkinInsIDTable) do
    local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(v)
    if itemInfo ~= nil and itemInfo.itemSubType == itemSubType then
      return v
    end
  end
  return nil
end
function WardrobeAvatarLogic:GetCurrentWearPreview(itemSubType)
  return currentWearPreviewMap[itemSubType]
end
function WardrobeAvatarLogic:GetCurrentWearPreviewMap()
  return currentWearPreviewMap
end
function WardrobeAvatarLogic:SetCurrentWearPreview(itemSubType, v)
  currentWearPreviewMap[itemSubType] = v
end
function WardrobeAvatarLogic:CheckPutOffHelmetAvatar(itemCfg)
  log(bWriteLog and "itemCfg.WardrobeTab" .. itemCfg.WardrobeTab)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if itemCfg.WardrobeTab == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_head then
    self:PutOffHelmetEquipmentAvatar()
  end
end
function WardrobeAvatarLogic:CheckPutoffHatAvatar(itemCfg)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if itemCfg == nil or itemCfg.WardrobeTab == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_helmet then
    if DataMgr.equipmentSkinInsIDTable[DataMgr.HelmetSkinTableIndex] == 0 then
      return
    end
    local wearInfo = currentWearPreviewMap[ENUM_ITEM_SUBTYPE.Hat_Slot]
    if wearInfo ~= nil then
      self:AvatarChange(wearInfo.resID, false)
    end
  end
end
function WardrobeAvatarLogic:PutOffHelmetEquipmentAvatar()
  log(bWriteLog and "PutOffHelmetEquipmentAvatar")
  for k, v in pairs(DataMgr.equipmentSkinInsIDTable) do
    if k == DataMgr.HelmetSkinTableIndex then
      self:PutOffOneEquipmentAvatar(k, v, false)
      return
    end
  end
end
function WardrobeAvatarLogic:PutOffOneEquipmentAvatar(itemSubType, itemInsID, needClearWearInfo)
  local itemResID = self:GetEquipmentItemIDBySkinInsID(itemSubType, itemInsID)
  if 0 <= itemResID then
    local wearInfo = currentWearPreviewMap[itemSubType]
    log_tree("wearInfo", wearInfo)
    log_tree("currentWearPreviewMap", currentWearPreviewMap)
    if wearInfo ~= nil and wearInfo.insID == itemInsID then
      log(bWriteLog and "WardrobeAvatarLogic:PutOffOneEquipmentAvatar itemResID" .. itemResID)
      log_tree("WardrobeAvatarLogic:PutOffOneEquipmentAvatar wearInfo", wearInfo)
      if needClearWearInfo then
        currentWearPreviewMap[itemSubType] = nil
        if itemSubType == DataMgr.HelmetSkinTableIndex then
          local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
          WardRobeHandler.send_depot_set_head_show_req(0)
        end
      end
      self:AvatarChange(itemResID, false)
    end
  end
end
function WardrobeAvatarLogic:GetEquipmentItemShowLevel(itemSubType)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  if itemSubType == ENUM_ITEM_SUBTYPE.Backpack then
    return fashionbag_data:GetBagLevel()
  elseif itemSubType == ENUM_ITEM_SUBTYPE.Helmet_NoLevel then
    return fashionbag_data:GetHelmetLevel()
  elseif itemSubType == ENUM_ITEM_SUBTYPE.Armor then
    return 3
  end
  return 3
end
function WardrobeAvatarLogic:IsTabString_Bag_Helmet_Armor(wardrobeTab)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local macroTabString = wardrobe_macro.ENUM_WardrobeSubTabString
  local ret = wardrobeTab == macroTabString.ENUM_WardrobeSubTabString_bag or wardrobeTab == macroTabString.ENUM_WardrobeSubTabString_helmet or wardrobeTab == macroTabString.ENUM_WardrobeSubTabString_armor
  return ret
end
function WardrobeAvatarLogic:IsItemSubType_Bag_Helmet_Armor(itemSubType)
  local ret = itemSubType == ENUM_ITEM_SUBTYPE.Backpack or itemSubType == ENUM_ITEM_SUBTYPE.Helmet_NoLevel or itemSubType == ENUM_ITEM_SUBTYPE.Armor
  return ret
end
function WardrobeAvatarLogic:GetEquipmentItemIDBySkinInsID(itemSubType, itemInsID)
  local level = self:GetEquipmentItemShowLevel(itemSubType)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(itemInsID)
  if itemInfo ~= nil then
    local itemMappingCfg = CDataTable.GetTableData("BackpackMapping", itemInfo.resID)
    if itemMappingCfg ~= nil then
      return itemMappingCfg["SkinItemIDLv" .. level] or -1
    end
  end
  return -1
end
function WardrobeAvatarLogic:IsActiveSubType(itemSubType)
  return itemSubType == ENUM_ITEM_SUBTYPE.Head_Slot_400 or itemSubType == ENUM_ITEM_SUBTYPE.Hair_Slot
end
function WardrobeAvatarLogic:GetCurrentLevelEquipemntResID(resID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemCfg = CDataTable.GetTableData("Item", resID)
  if itemCfg then
    local level = self:GetEquipmentItemShowLevel(itemCfg.ItemSubType)
    local itemMappingCfg = CDataTable.GetTableData("BackpackMapping", resID)
    resID = itemMappingCfg and itemMappingCfg["SkinItemIDLv" .. level] or resID
  end
  return resID
end
function WardrobeAvatarLogic:GetEquipemntResIDByLevel(resID, level)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemCfg = CDataTable.GetTableData("Item", resID)
  if itemCfg then
    local itemMappingCfg = CDataTable.GetTableData("BackpackMapping", resID)
    resID = itemMappingCfg and itemMappingCfg["SkinItemIDLv" .. level] or resID
  end
  return resID
end
function WardrobeAvatarLogic:ProcessTakeOff()
  local takeOffList = self:GetTakeOffList()
  log_tree("WardrobeAvatar:ProcessTakeOff takeOffList:", takeOffList)
  if 0 < #takeOffList then
    local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    logic_wardrobe:wardrobe_batch_put_down_req(takeOffList)
    return true
  end
  return false
end
local doNotNeedPutOff = function(avatar, resId)
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  local otherId = multi_state_manager:GetOtherStateClothID(resId)
  if otherId then
    return avatar:HasEquiped(otherId)
  end
end
function WardrobeAvatarLogic:GetTakeOffList()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local mainAvatar = TeamAvatarManager.GetMainAvatar()
  if not mainAvatar then
    return {}
  end
  mainAvatar:MarkForCheckTakeoff()
  local equipments = mainAvatar:GetTakeoffEquipments()
  log_tree("WardrobeAvatar:GetTakeOffList equipments:", equipments)
  local takeOffList = {}
  for _, res_id in ipairs(equipments) do
    local ins_id = self:GetRealWearInsID(res_id)
    if ins_id ~= -1 and not doNotNeedPutOff(mainAvatar, res_id) then
      table.insert(takeOffList, ins_id)
    end
  end
  return takeOffList
end
function WardrobeAvatarLogic:GetRealWearInsID(res_id)
  local originStateItem = res_id
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  if multi_state_manager:IsMultiStateCloth(res_id) then
    originStateItem = multi_state_manager:GetOriginClothIDAndState(res_id) or res_id
  end
  local originLevelItem = res_id
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if LogicXSuit.IsXSuit(originStateItem) then
    local period = LogicXSuit.GetPeriodByItemId(res_id)
    originLevelItem = LogicXSuit.GetItemIDByPeriod(period) or originLevelItem
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local tRoleWear = AvatarData.GetRoleWear()
  for _, v in pairs(tRoleWear) do
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(v)
    if itemData and itemData.resID == res_id then
      return itemData.insID
    end
    if itemData and itemData.resID == originStateItem then
      return itemData.insID
    end
    if itemData and itemData.resID == originLevelItem then
      return itemData.insID
    end
  end
  return -1
end
function WardrobeAvatarLogic:PutOffTimeOutWear()
  local putOff = {}
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  wardrobeLogic:UpdateInvalidWearInfo(putOff)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData
  for _, v in ipairs(putOff) do
    wardrobeLogic:wardrobe_put_down_req(v)
    itemData = wardrobe_data:GetHallDepotItemDataByInsID(v)
    if itemData ~= nil then
      self:AvatarChange(itemData.resID, false)
    end
  end
  if DataMgr.Weapon_ID ~= 0 then
    itemData = wardrobe_data:GetHallDepotItemDataByInsID(DataMgr.Weapon_Skin_InsID)
    if itemData and not DataMgr.IsValidTime(itemData.expireTS) then
      local logic_wardrobe_gun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
      logic_wardrobe_gun:PutOnGunAvatar(DataMgr.Weapon_ID)
    end
  end
end
function WardrobeAvatarLogic:PutOffExpireItem(item)
  if AvatarData.CheckWearItem(item.insID) then
    self:AvatarChange(item.resID, false)
  end
end
return WardrobeAvatarLogic