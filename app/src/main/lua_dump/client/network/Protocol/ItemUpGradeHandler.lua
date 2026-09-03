local NetManager = require("client.network.comm.NetManager")
local ItemUpGradeHandler = {
  data = {}
}
function ItemUpGradeHandler.send_upgrade_unlock_accessory_req(instid, acc_id, item_cost)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckUCRestrict() then
    return
  end
  NetManager.SendPkg(843168295, instid, acc_id, item_cost)
end
function ItemUpGradeHandler.on_upgrade_unlock_accessory_rsp(error_code, res_id, acc_id)
  if error_code == 0 then
    EventSystem:postEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_UNLOCK_SUCCESS, res_id, acc_id)
  else
    ShowNotice(error_code)
  end
end
function ItemUpGradeHandler.SaveData(groupId, partId)
  if not ItemUpGradeHandler.data[groupId] then
    ItemUpGradeHandler.data[groupId] = {}
  end
  ItemUpGradeHandler.data[groupId][partId] = 1
end
function ItemUpGradeHandler.send_upgrade_query_accessory_req()
  NetManager.SendPkg(1475477299)
end
function ItemUpGradeHandler.on_upgrade_query_accessory_rsp(acc_list)
  ItemUpGradeHandler.data = acc_list
  log_tree("ItemUpGradeHandler.data", ItemUpGradeHandler.data)
end
function ItemUpGradeHandler.HasItem(itemId)
  log(bWriteLog and "  : HasItem: " .. tostring(itemId))
  if not ItemUpGradeHandler.data or not next(ItemUpGradeHandler.data) then
    return false
  end
  for _, group in pairs(ItemUpGradeHandler.data) do
    if group[itemId] then
      return true
    end
  end
  return false
end
function ItemUpGradeHandler.IsUnLock(groupId, partId)
  if ItemUpGradeHandler.data[groupId] then
    if ItemUpGradeHandler.data[groupId][partId] then
      return true
    else
      return false
    end
  else
    return false
  end
end
function ItemUpGradeHandler.send_upgrade_item_req(instid, group_id, item_level, item_cost)
  NetManager.SendPkg(104623399, instid, group_id, item_level, item_cost)
end
function ItemUpGradeHandler.on_upgrade_item_rsp(error_code, ret)
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  ItemUpgradeMgr:upgrade_item_rsp(error_code, ret)
end
function ItemUpGradeHandler.send_upgrade_query_refit_req()
  NetManager.SendPkg(1227310835)
end
function ItemUpGradeHandler.on_upgrade_query_refit_rsp(refit_info, refit_map_inherit)
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  ItemUpgradeMgr:on_upgrade_query_refit_rsp(refit_info)
  local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
  LogicInheritWardrobe:CacheRefitMapInherit(refit_map_inherit)
  local WeaponDiffColorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.WeaponDiffColorModule)
  WeaponDiffColorModule:CacheSelfPrivilege(refit_info)
  WeaponDiffColorModule:CacheInheritedPrivilege(refit_map_inherit)
  WeaponDiffColorModule:SwitchWeaponSkinByClothID(WeaponDiffColorModule:GetCurrentClothID(), true)
  EventSystem:postEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_TOGGLE_WEAPON_SWITCH_BY_CLOTH)
end
function ItemUpGradeHandler.send_upgrade_unlock_refit_req(instid, cost_list)
  NetManager.SendPkg(1232171623, instid, cost_list)
end
function ItemUpGradeHandler.on_upgrade_unlock_refit_rsp(error_code, refit_info)
  log(bWriteLog and "[bgp] on_upgrade_unlock_refit_rsp-> error_code" .. tostring(error_code))
  log_tree(bWriteLog and "[bgp]on_upgrade_unlock_refit_rsp-> refit_info:", refit_info)
  if error_code ~= 0 then
    ShowNotice(error_code)
    return
  end
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  ItemUpgradeMgr:UpdateRefitUnlockData(refit_info)
  local WeaponDiffColorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.WeaponDiffColorModule)
  WeaponDiffColorModule:CacheSelfPrivilege(refit_info)
  WeaponDiffColorModule:SwitchWeaponSkinByClothID(WeaponDiffColorModule:GetCurrentClothID(), true)
  EventSystem:postEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_TOGGLE_WEAPON_SWITCH_BY_CLOTH)
end
function ItemUpGradeHandler.send_upgrade_refit_req(instid)
  NetManager.SendPkg(702130559, instid)
end
function ItemUpGradeHandler.on_upgrade_refit_rsp(error_code, instid, res_id)
  if error_code ~= 0 then
    ShowNotice(error_code)
    return
  end
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local weaponId = ItemUpgradeMgr:GetNormalItemID(tonumber(DataMgr.Weapon_Skin_InsID))
  log_tree("ItemUpGradeHandler on_upgrade_refit_rsp ", {
    instid,
    res_id,
    weaponId
  })
  local cfg = CDataTable.GetTableData("WeaponSkinMapping", res_id)
  local BaseWeaponID = cfg and cfg.WeaponID
  if BaseWeaponID then
    if ItemUpgradeMgr:GetNormalItemID(tonumber(res_id)) == tonumber(weaponId) or tonumber(instid) == tonumber(weaponId) then
      local ArmorySystem = require("client.logic.armory.logic_armory")
      log(bWriteLog and "ItemUpGradeHandler.on_upgrade_refit_rsp:" .. tostring(BaseWeaponID))
      ArmorySystem.install_weapon_skin(ArmorySystem.ENUM_REQ_ItemUpgrade, BaseWeaponID, instid)
    end
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    local WardrobeGunLogic = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
    local extraWeaponIdList = LobbyAvatarManager.GetExtraWeaponIdList()
    for _, secondGunID in pairs(extraWeaponIdList) do
      local secondSkinInsID = WardrobeGunLogic:GetSkinIdByWeaponID(secondGunID)
      if secondSkinInsID and secondGunID == BaseWeaponID then
        log(bWriteLog and "OnEquipStateChange, UpdateExtraGunAvatar " .. tostring(secondGunID) .. "  " .. tostring(secondSkinInsID))
        WardrobeGunLogic:UpdateExtraGunAvatar(secondGunID, secondSkinInsID)
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_REFIT_SUCCESS, error_code, instid, res_id)
end
function ItemUpGradeHandler.on_upgrade_accessory_notify(group_id, acc_id)
  local data = ItemUpGradeHandler.data[group_id]
  if data then
    data[acc_id] = 1
  else
    ItemUpGradeHandler.data[group_id] = {
      [acc_id] = 1
    }
  end
end
function ItemUpGradeHandler.send_taluo_get_dress_change_gun_flag_req()
  NetManager.SendPkg(403929247)
end
function ItemUpGradeHandler.on_taluo_get_dress_change_gun_flag_rsp(err_code, flag_list, flag_inherit_list)
  log(bWriteLog and string.format("ItemUpGradeHandler.on_taluo_get_dress_change_gun_flag_rsp err_code = %s", err_code))
  if err_code ~= 0 then
    return
  end
  local WeaponDiffColorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.WeaponDiffColorModule)
  for id, flag in pairs(flag_list) do
    if id ~= 1 then
      WeaponDiffColorModule:UpdateWeaponSwitchByClothFlag(id, flag, EWardrobeDataSource.Wardrobe)
    end
  end
  if flag_inherit_list then
    for id, flag in pairs(flag_inherit_list) do
      if id ~= 1 then
        WeaponDiffColorModule:UpdateWeaponSwitchByClothFlag(id, flag, EWardrobeDataSource.InheritWardrobe)
      end
    end
  end
  WeaponDiffColorModule:SwitchWeaponSkinByClothID(WeaponDiffColorModule:GetCurrentClothID(), true)
end
function ItemUpGradeHandler.send_taluo_set_dress_change_gun_flag_req(itemid, flag, source)
  if source == nil then
    source = EWardrobeDataSource.Wardrobe
  end
  NetManager.SendPkg(698978159, itemid, flag, source)
end
function ItemUpGradeHandler.on_taluo_set_dress_change_gun_flag_rsp(err_code, itemid, flag, source)
  log(bWriteLog and string.format("ItemUpGradeHandler.on_taluo_set_dress_change_gun_flag_rsp err_code = %s, itemid = %s, flag = %s, source = %s", err_code, itemid, flag, source))
  if err_code ~= 0 then
    return
  end
  local WeaponDiffColorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.WeaponDiffColorModule)
  WeaponDiffColorModule:UpdateWeaponSwitchByClothFlag(itemid, flag, source)
  WeaponDiffColorModule:SwitchWeaponSkinByClothID(WeaponDiffColorModule:GetCurrentClothID(), true)
  EventSystem:postEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_TOGGLE_WEAPON_SWITCH_BY_CLOTH)
end
function ItemUpGradeHandler.send_taluo_change_gun_with_dress_req(gunid, target_gunid)
  log(bWriteLog and string.format("ItemUpGradeHandler.send_taluo_change_gun_with_dress_req gunid = %s, target_gunid = %s", gunid, target_gunid))
  NetManager.SendPkg(1687811883, gunid, target_gunid)
end
function ItemUpGradeHandler.on_taluo_change_gun_with_dress_rsp(err_code, gunid, target_gunid, source)
  log(bWriteLog and string.format("ItemUpGradeHandler.on_taluo_change_gun_with_dress_rsp err_code = %s, gunid = %s, target_gunid = %s, source = %s", err_code, gunid, target_gunid, source))
  if err_code ~= 0 then
    if err_code == 34735 then
      ShowNotice(err_code)
    end
    return
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemData = WardrobeData:GetHallDepotItemDataByResID(target_gunid, source)
  if not ItemData then
    log(bWriteLog and string.format("ItemUpGradeHandler.on_taluo_change_gun_with_dress_rsp Failed to get item data"))
    return
  end
  local cfg = CDataTable.GetTableData("WeaponSkinMapping", target_gunid)
  local BaseWeaponID = cfg and cfg.WeaponID
  if BaseWeaponID then
    local weaponId = DataMgr.Weapon_Skin_InsID
    if tonumber(gunid) == tonumber(weaponId) or tonumber(ItemData.insID) == tonumber(weaponId) then
      local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
      local avatar = TeamAvatarManager.GetMainAvatar()
      if avatar then
        avatar:SetCanPlaySwitchWeapon(1)
      end
      local ArmorySystem = require("client.logic.armory.logic_armory")
      log(bWriteLog and "ItemUpGradeHandler.on_taluo_change_gun_with_dress_rsp:" .. tostring(BaseWeaponID))
      ArmorySystem.install_weapon_skin(ArmorySystem.ENUM_REQ_ItemUpgrade, BaseWeaponID, ItemData.insID)
    end
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    local WardrobeGunLogic = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
    local extraWeaponIdList = LobbyAvatarManager.GetExtraWeaponIdList()
    for _, secondGunID in pairs(extraWeaponIdList) do
      local secondSkinInsID = WardrobeGunLogic:GetSkinIdByWeaponID(secondGunID)
      if secondSkinInsID and secondGunID == BaseWeaponID then
        log(bWriteLog and "OnEquipStateChange, UpdateExtraGunAvatar " .. tostring(secondGunID) .. "  " .. tostring(secondSkinInsID))
        WardrobeGunLogic:UpdateExtraGunAvatar(secondGunID, secondSkinInsID)
      end
    end
  end
  local t = {
    instid = ItemData.insID,
    res_id = target_gunid,
    ItemData.count
  }
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ITEM_DATA, t)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_COLLECT_UNLOCK_ITEM_CHANGE)
end
function ItemUpGradeHandler.send_set_item_upgrade_switch_info_req(instid, switch_flag)
  NetManager.SendPkg(445952103, instid, switch_flag)
end
function ItemUpGradeHandler.on_set_item_upgrade_switch_info_rsp(err_code, instid, flag, group_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log(bWriteLog and "ItemUpGradeHandler.on_set_item_upgrade_switch_info_rsp " .. tostring(instid) .. " flag = " .. tostring(flag) .. " group_id = " .. tostring(group_id))
  DataMgr.UpdateWeaponSkinSoundSwitchInfo(instid, flag, group_id)
end
function ItemUpGradeHandler.send_set_gun_upgrade_parts_switch_req(instid, acc_id, switch_flag)
  NetManager.SendPkg(1303324775, instid, acc_id, switch_flag)
end
function ItemUpGradeHandler.on_set_gun_upgrade_parts_switch_rsp(err_code, gun_type, part_type, switch_flag)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  EventSystem:postEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_PARTS_SWITCH_UPDATE, gun_type, part_type, switch_flag)
end
function ItemUpGradeHandler.send_set_weapon_audio_volume_req(instid, audio_type, volume)
  NetManager.SendPkg(789363799, instid, audio_type, volume)
end
function ItemUpGradeHandler.on_set_weapon_audio_volume_rsp(err_code, instid, audio_type, volume, group_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log(bWriteLog and "ItemUpGradeHandler.on_set_weapon_audio_volume_rsp " .. tostring(instid) .. " audio_type = " .. tostring(audio_type) .. " volume = " .. tostring(volume) .. " group_id = " .. tostring(group_id))
  DataMgr.UpdateWeaponSkinSoundVolumeInfo(instid, audio_type, volume, group_id)
end
return ItemUpGradeHandler