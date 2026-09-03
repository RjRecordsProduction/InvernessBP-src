local ArmorySystem = {
  ENUM_REQ_Wardrobe = 2,
  ENUM_REQ_ItemUpgrade = 3,
  rsp_list = {},
  WardrobeInsList = {},
  AllWeaponSkinData = {}
}
local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
local wardrobeGunLogic = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
function ArmorySystem.ReBuildInitData(dataList)
  if nil == dataList then
    log(bWriteLog and "ArmorySystem.skin_list data is nil")
    return
  end
  ArmorySystem.AllWeaponSkinData = {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for k, v in pairs(dataList.skin_list) do
    local WeaponID = k
    if ArmorySystem.AllWeaponSkinData[WeaponID] == nil then
      ArmorySystem.AllWeaponSkinData[WeaponID] = {}
    end
    ArmorySystem.AllWeaponSkinData[WeaponID].    local data = wardrobe_data:GetHallDepotItemDataByInsID(ArmorySystem.GetSkinIdByWeaponID(WeaponID))
    if data ~= nil then
      ArmorySystem.AllWeaponSkinData[WeaponID].CurrentSkinID = data.resID
    end
    ArmorySystem.AllWeaponSkinData[WeaponID].SkinArray = {}
    local skinData = v
    for tk, tv in pairs(skinData) do
      if tv.is_open ~= 0 then
        local SkinID = tk
        local IsOpen = tv.is_open
        local ShopingID = 0
        local MoneyType = 0
        local Price = 0
        local HasEquip = false
        if ArmorySystem.AllWeaponSkinData[WeaponID].CurrentSkinID == SkinID then
          HasEquip = true
        end
        if tv.shop_info ~= nil then
          ShopingID = tv.shop_info.shopid
          MoneyType = tv.shop_info.money_type
          Price = tv.shop_info.lowest_price
        end
        local skinItem = ArmorySystem.BuildSkinItemData(WeaponID, SkinID, ShopingID, IsOpen, MoneyType, Price, HasEquip)
        table.insert(ArmorySystem.AllWeaponSkinData[WeaponID].SkinArray, skinItem)
      end
    end
  end
end
local ArmoryUI = {}
ArmoryUI.MAIN_TYPE = {}
ArmoryUI.MAIN_TYPE.WEAPON = 1
ArmoryUI.MAIN_TYPE.VEHICLE = 2
ArmoryUI.MAIN_TYPE.PLANE = 3
function ArmorySystem.BuildSkinItemData(WeaponID, SkinID, ShopingID, IsOpen, MoneyType, Price, HasEquip)
  local item = {}
  item.  item.  item.  item.  item.  item.  local itemType = ArmoryUI.MAIN_TYPE.WEAPON
  local skinMap = CDataTable.GetTableData("WeaponSkinMapping", SkinID)
  if skinMap == nil then
    skinMap = CDataTable.GetTableData("VehiclePlaneSkinMapping", SkinID)
    if skinMap ~= nil then
      itemType = ArmoryUI.MAIN_TYPE.VEHICLE
    end
  end
  local weaponCfg
  if itemType == ArmoryUI.MAIN_TYPE.WEAPON then
    weaponCfg = CDataTable.GetTableData("ArmoryConfig", WeaponID)
    item.WeaponType = weaponCfg.WeaponType
  else
    weaponCfg = CDataTable.GetTableData("ArmoryVehicleConfig", WeaponID)
    if weaponCfg == nil then
      weaponCfg = CDataTable.GetTableData("ArmoryPlaneConfig", WeaponID)
    end
    if weaponCfg ~= nil then
      item.WeaponType = weaponCfg.Type
    else
      log(bWriteLog and "not found ArmoryConfig " .. WeaponID)
      item.WeaponType = 1
    end
  end
  local skinCfg = CDataTable.GetTableData("Item", SkinID)
  local cfg = CDataTable.GetTableData("ArmoryDescConfig", SkinID)
  local insID = ArmorySystem.GetInsIdByResID(SkinID)
  item.ShortHandType = 6
  item.  item.HasOwner = false
  item.IsRedPoint = false
  item.leftTime = 0
  item.SkinUrl = ""
  item.SkinDesc = ""
  item.SkinDetailDesc = ""
  item.Quality = 0
  item.SkinName = ""
  if skinCfg ~= nil then
    item.SkinDesc = cfg.ArmorySimpleDesc
    item.Quality = skinCfg.ItemQuality
    item.SkinName = skinCfg.ItemName
    item.SkinDetailDesc = skinCfg.ItemDesc
  end
  if skinMap ~= nil then
    item.SkinUrl = skinMap.iconURL
  end
  if insID ~= nil then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local data = wardrobe_data:GetHallDepotItemDataByInsID(insID)
    if data ~= nil then
      item.HasOwner = true
      item.leftTime = data.expireTS
      item.Quality = data.itemQuality
    end
  end
  return item
end
function ArmorySystem.GetSkinListByWeaponID(WeaponID)
  local result = {}
  if ArmorySystem.rsp_list and ArmorySystem.rsp_list.skin_list and ArmorySystem.rsp_list.skin_list[WeaponID] then
    result = ArmorySystem.rsp_list.skin_list[WeaponID]
  end
  return result
end
function ArmorySystem.GetAllWeaponSkinList()
  local result = {}
  if ArmorySystem.rsp_list and ArmorySystem.rsp_list.skin_list then
    local ArmoryConfig = CDataTable.GetTable("ArmoryConfig")
    local WeaponIDMap = {}
    for k, v in pairs(ArmoryConfig) do
      WeaponIDMap[v.WeaponID] = true
    end
    for weaponID, skinList in pairs(ArmorySystem.rsp_list.skin_list) do
      if WeaponIDMap[weaponID] then
        for skinID, skinInfo in pairs(skinList) do
          result[skinID] = {skinInfo = skinInfo, weaponID = weaponID}
        end
      end
    end
  end
  log_tree(bWriteLog and "ArmorySystem.GetAllWeaponSkinList: ", result)
  return result
end
function ArmorySystem.GetSkinIdByWeaponID(WeaponID)
  local skinid = 0
  if ArmorySystem.rsp_list.install_list ~= nil and ArmorySystem.rsp_list.install_list[WeaponID] ~= nil then
    skinid = ArmorySystem.rsp_list.install_list[WeaponID].skin_id
  end
  log(bWriteLog and "GetSkinIdByWeaponID:" .. tostring(WeaponID) .. "skinid:" .. tostring(skinid))
  return skinid
end
function ArmorySystem.GetInsIdByResID(skinResId)
  return ArmorySystem.WardrobeInsList[skinResId]
end
function ArmorySystem.ContructResIdToWardrobeInsID()
  if nil == ArmorySystem.rsp_list.skin_list then
    log(bWriteLog and "ArmorySystem.skin_list data is nil 111")
    return
  end
  ArmorySystem.WardrobeInsList = {}
  for k, v in pairs(ArmorySystem.rsp_list.skin_list) do
    local skinArray = v
    for tk, _ in pairs(skinArray) do
      local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      local insID = wardrobeLogic:GetWardrobeInsIdByResId(tk)
      ArmorySystem.WardrobeInsList[tk] = insID
    end
  end
end
function ArmorySystem.get_weapon_skin_list(client_data)
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_get_all_skin_list(client_data)
end
function ArmorySystem.get_weapon_skin_list_rsp(client_data, errorCode, rsp_list, if_skin_list_saved)
  log(bWriteLog and "ArmorySystem.get_weapon_skin_list_rsp client_data = " .. tostring(client_data) .. " errorCode = " .. tostring(errorCode) .. " if_skin_list_saved = " .. tostring(if_skin_list_saved))
  if errorCode ~= 0 then
    ShowNotice(errorCode)
    return
  end
  if if_skin_list_saved == true then
    rsp_list.skin_list = slua.LuaArchiverDecode(LuaStateWrapper, rsp_list.skin_list)
  end
  ArmorySystem.  wardrobeGunLogic:OnGunSkinListRes()
end
function DelayNetRefreshWeaponUIInfo()
  log(bWriteLog and "ArmoryUI DelayNetRefreshWeaponUIInfo")
  ArmorySystem.ContructResIdToWardrobeInsID()
  ArmorySystem.ReBuildInitData(ArmorySystem.rsp_list)
end
function ArmorySystem.install_weapon_skin(client_data, weapon_id, instanceID)
  local ArmoryHandler = require("client.network.Protocol.ArmoryHandler")
  ArmoryHandler.send_install_weapon_skin(client_data, weapon_id, tonumber(instanceID))
end
function ArmorySystem.install_weapon_skin_rsp(client_data, errorCode, weapon_id, instanceID)
  log(bWriteLog and "install_weapon_skin_rsp weapon_id:" .. tostring(weapon_id) .. "instanceID:" .. tostring(instanceID))
  if errorCode ~= 0 then
    ShowNotice(errorCode)
    return
  end
  ArmorySystem.HandleWeaponSkinChange(client_data, weapon_id, instanceID)
end
function ArmorySystem.HandleWeaponSkinChange(client_data, weapon_id, instanceID)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if client_data ~= ArmorySystem.ENUM_REQ_ItemUpgrade then
    ShowNotice(LocUtil.GetLocalizeResStr(4464))
  end
  if ArmorySystem.rsp_list.install_list == nil then
    ArmorySystem.rsp_list.install_list = {}
  end
  ArmorySystem.rsp_list.install_list[weapon_id] = {}
  ArmorySystem.rsp_list.install_list[weapon_id].skin_id = instanceID
  local isCurUsing = true
  local itemId = 0
  if weapon_id == DataMgr.Weapon_ID then
    HallThemeUtils.ProcGunInstall(weapon_id, instanceID)
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetValidHallDepotItemDataByInsID(instanceID)
    local resID = 0
    if itemData and itemData.resID then
      resID = itemData.resID
      itemId = tonumber(resID)
    end
    DataMgr.InitWeaponData(weapon_id, resID, instanceID)
  elseif DataMgr.Extra_Weapon_Info_List and next(DataMgr.Extra_Weapon_Info_List) and DataMgr.Extra_Weapon_Info_List[weapon_id] ~= nil then
    HallThemeUtils.ProcGun2Install(weapon_id, instanceID)
    local extra_weapon_info_list = DataMgr.Extra_Weapon_Info_List
    extra_weapon_info_list[weapon_id].    extra_weapon_info_list[weapon_id].skin_id = instanceID
    DataMgr.InitExtraWeaponList(extra_weapon_info_list)
    isCurUsing = false
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  fashionbag_data:UpdateCurrentFashionBagWeaponSkin(weapon_id, instanceID)
  if client_data ~= nil and client_data == ArmorySystem.ENUM_REQ_Wardrobe then
    wardrobeGunLogic:UpdateGunCount()
  elseif client_data ~= nil and client_data == ArmorySystem.ENUM_REQ_ItemUpgrade then
    log(bWriteLog and "ArmorySystem.install_weapon_skin_rsp")
    if isCurUsing then
      wardrobeGunLogic:UpdateCurrentGunAvatar(weapon_id, instanceID)
    else
      wardrobeGunLogic:UpdateExtraGunAvatar(weapon_id, instanceID)
    end
  end
  EventSystem:postEvent(EVENTTYPE_ARMORY, EVENTID_ARMORY_EQUIP_STAT_CHANGE, itemId)
end
function ArmorySystem.uninstall_weapon_skin(client_data, weapon_id)
  log(bWriteLog and "uninstall_weapon_skin")
  local ArmoryHandler = require("client.network.Protocol.ArmoryHandler")
  ArmoryHandler.send_uninstall_weapon_skin(client_data, weapon_id)
end
function ArmorySystem.uninstall_weapon_skin_rsp(client_data, errorCode, weapon_id)
  log(bWriteLog and "uninstall_weapon_skin_rsp errorCode:" .. tostring(errorCode) .. "weapon_id:" .. tostring(weapon_id))
  if errorCode ~= 0 then
    ShowNotice(errorCode)
    return
  end
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if client_data ~= ArmorySystem.ENUM_REQ_ItemUpgrade then
    ShowNotice(4465)
  end
  if ArmorySystem.rsp_list.install_list ~= nil and ArmorySystem.rsp_list.install_list[weapon_id] ~= nil then
    ArmorySystem.rsp_list.install_list[weapon_id].skin_id = 0
  end
  if weapon_id == DataMgr.Weapon_ID then
    HallThemeUtils.ProcGunUnInstall(weapon_id)
    DataMgr.InitWeaponData(weapon_id, 0, 0)
  elseif DataMgr.Extra_Weapon_Info_List and next(DataMgr.Extra_Weapon_Info_List) and DataMgr.Extra_Weapon_Info_List[weapon_id] ~= nil then
    HallThemeUtils.ProcGun2UnInstall(weapon_id)
    local extra_weapon_info_list = DataMgr.Extra_Weapon_Info_List
    extra_weapon_info_list[weapon_id].    extra_weapon_info_list[weapon_id].skin_id = 0
    DataMgr.InitExtraWeaponList(extra_weapon_info_list)
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  fashionbag_data:UpdateCurrentFashionBagWeaponSkin(weapon_id, 0)
  if client_data ~= nil and client_data == ArmorySystem.ENUM_REQ_Wardrobe then
    wardrobeGunLogic:UpdateGunCount()
  end
  EventSystem:postEvent(EVENTTYPE_ARMORY, EVENTID_ARMORY_EQUIP_STAT_CHANGE)
end
function ArmorySystem.GetWeaponOriItemIdBySkinId(nItemId)
  local uSkinCfg = CDataTable.GetTableData("WeaponSkinMapping", nItemId)
  if uSkinCfg and uSkinCfg.WeaponID and uSkinCfg.WeaponID ~= 0 then
    return uSkinCfg.WeaponID
  end
  return nItemId
end
return ArmorySystem