local AvatarCommon = {
  XSuitCornerPath = "/Game/UMG/Texture/Atlas/CommonConer_Atlas/Frames/Icon_Xsuit_png.Icon_Xsuit_png",
  GoldenSuitCornerPath = "/Game/UMG/Texture/Atlas/CommonConer_Atlas/Frames/Icon_Gilt_png.Icon_Gilt_png"
}
function AvatarCommon.DataSexToModelSex(sex)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  if sex == 1 then
    return LobbyAvatarManager.Enum_Sex.Female
  else
    return LobbyAvatarManager.Enum_Sex.Male
  end
end
function AvatarCommon.ModelSexToDataSex(sex)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  if sex == LobbyAvatarManager.Enum_Sex.Female then
    return LobbyAvatarManager.Enum_Sex_Cpp.Female
  else
    return LobbyAvatarManager.Enum_Sex_Cpp.Male
  end
end
function AvatarCommon.GetAllWearItemIDList(wearData)
  local list = {}
  if not wearData then
    return list
  end
  for i, v in pairs(wearData.WearInfoList) do
    table.insert(list, v.resID)
  end
  for i, v in pairs(wearData.bag_pendants) do
    table.insert(list, v.resID)
  end
  if wearData.weaponSkinId and wearData.weaponSkinId > 0 then
    table.insert(list, wearData.weaponSkinId)
  end
  if wearData.bagSkinInsId and 0 < wearData.bagSkinInsId then
    table.insert(list, wearData.bagSkinInsId)
  end
  if wearData.headShow and 0 < wearData.headShow then
    table.insert(list, wearData.headShow)
  end
  return list
end
function AvatarCommon.GetWearDataFromRoleData(roleData)
  if not roleData then
    log_error(bWriteLog and "AvatarCommon.GetWearDataFromRoleData. roleData = nil")
    return nil
  end
  local WearData = {}
  local mainWeaponInfo = {
    weaponResId = 0,
    weaponSkinId = 0,
    diyInfo = {
      diyWeaponId = 0,
      diyDefaultScheme = false,
      diyScheme = nil
    }
  }
  local extraWeaponInfo = {
    weaponResId = 0,
    weaponSkinId = 0,
    diyInfo = {
      diyWeaponId = 0,
      diyDefaultScheme = false,
      diyScheme = nil
    }
  }
  WearData.  WearData.  local poseId = 0
  local pspace_wear_ext = roleData.pspace_wear_ext or {}
  WearData.WearInfoList = {}
  WearData.sex = roleData.gender - 1
  WearData.pet_info = roleData.pet_info or nil
  WearData.headid = pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_HEAD] and pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_HEAD][1] or 0
  WearData.bag_pendants = {}
  WearData.uid = roleData.uid
  local show_info = {
    weapon = true,
    vehicle = true,
    helmet = true,
    bag = true,
    social_weapon = true,
    idle = true
  }
  WearData.depot_show_info = roleData.depot_show_info or show_info
  for key, default in pairs(show_info) do
    if WearData.depot_show_info[key] == nil then
      WearData.depot_show_info[key] = default
    end
  end
  for k, v in pairs(pspace_wear_ext) do
    if v[5] and tostring(roleData.uid) ~= tostring(DataMgr.roleData.uid) then
      local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
      logic_suit_dye:SetPlanData(roleData.uid, v[1], v[5])
    end
    if k >= ENUM_AVATAR_SHOW_TYPE.SHOW_POS_FACE and k <= 6 or k == ENUM_AVATAR_SHOW_TYPE.SHOW_POS_GLOVES or k == ENUM_AVATAR_SHOW_TYPE.SHOW_POS_HAIR or k == ENUM_AVATAR_SHOW_TYPE.SHOW_POS_BEARD_INFO then
      table.insert(WearData.WearInfoList, AvatarData.ConvertToAvatarCustom(v))
    end
    if k >= ENUM_AVATAR_SHOW_TYPE.SHOW_POS_UNDERCLOTH and k <= ENUM_AVATAR_SHOW_TYPE.SHOW_POS_AVATARMAX then
      table.insert(WearData.WearInfoList, AvatarData.ConvertToAvatarCustom(v))
    end
    if k == ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPON then
      mainWeaponInfo.weaponResId = v[1] or 0
    end
    if k == ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPONSKIN then
      mainWeaponInfo.weaponSkinId = v[1] or 0
    end
    if k >= ENUM_AVATAR_SHOW_TYPE.SHOW_POS_BAG_PENDANT_MIN and k <= ENUM_AVATAR_SHOW_TYPE.SHOW_POS_BAG_PENDANT_MAX then
      table.insert(WearData.bag_pendants, AvatarData.ConvertToAvatarCustom(v))
    end
    if k == ENUM_AVATAR_SHOW_TYPE.SHOW_POS_POSTRUE then
      local itemId = v[1]
      if itemId and itemId ~= 0 then
        local intimacyPoseMapping = CDataTable.GetTableData("IntimacyPoseMapping", itemId)
        if intimacyPoseMapping then
          poseId = intimacyPoseMapping.PoseType
        end
      end
    end
    if k == ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPON_DIY then
      mainWeaponInfo.diyInfo.diyWeaponId = v[1]
      mainWeaponInfo.diyInfo.diyDefaultScheme = v[2]
      mainWeaponInfo.diyInfo.diyScheme = v[4]
    end
    if k == 121 then
      extraWeaponInfo.weaponResId = v[1] or 0
    end
    if k == 122 then
      extraWeaponInfo.weaponSkinId = v[1] or 0
    end
    if k == 123 then
      extraWeaponInfo.diyInfo.diyWeaponId = v[1]
      extraWeaponInfo.diyInfo.diyDefaultScheme = v[2]
      extraWeaponInfo.diyInfo.diyScheme = v[4]
    end
  end
  local skin_info = roleData.pspace_skin_info or roleData.skin_info or {
    0,
    0,
    0,
    1,
    1
  }
  local head_show = skin_info.head_show or 0
  local bag_skin = skin_info.bag_skin or 0
  local helmet_skin = skin_info.helmet_skin or 0
  local bag_level = skin_info.bag_level or 1
  local helmet_level = skin_info.helmet_level or 1
  if head_show == helmet_skin then
    helmet_skin = DataMgr.GetEquipmentItemIDByResID(helmet_level, helmet_skin)
    head_show = helmet_skin
  end
  WearData.hatSkinId = pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_HEADWEAR] and pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_HEADWEAR][1] or 0
  WearData.  WearData.headShow = head_show
  WearData.bagSkinInsId = DataMgr.GetEquipmentItemIDByResID(bag_level, bag_skin) or 0
  WearData.  return WearData
end
function AvatarCommon.GetBagSkinInsId(roleData)
  if not roleData then
    return 0
  end
  local skin_info = roleData.pspace_skin_info or roleData.skin_info or {
    0,
    0,
    0,
    1,
    1
  }
  local bag_skin = skin_info.bag_skin or 0
  local bag_level = skin_info.bag_level or 1
  local bagSkinInsId = DataMgr.GetEquipmentItemIDByResID(bag_level, bag_skin) or 0
  return bagSkinInsId
end
function AvatarCommon.UpdateAvatar(avatar, wearData, isShowWeapon, isShowHelmet, isShowBag)
  log(bWriteLog and "AvatarCommon.UpdateAvatar")
  avatar:EnableClothAnimation(true)
  avatar:DestoryHighLevelClothEffect()
  avatar:DetachFromPawnContainer()
  avatar:EnableHatHelmetMutex(false)
  avatar:EnableLobbyShowItem(false)
  avatar:ClearEquipments()
  avatar:SetCanRotate(true)
  avatar:SwitchSexAndHeadAndHair(avatar:GetSex(), wearData.headid, 0)
  local equipmentList = {}
  if wearData.depot_show_info.idle ~= nil then
    avatar:SetForceUseDefaultIdle(not wearData.depot_show_info.idle)
  end
  if wearData.headShow ~= 0 then
    local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
    if wearData.headShow == wearData.helmet_skin and WardrobeData:IsHelmetItem(wearData.headShow) then
      if isShowHelmet and wearData.depot_show_info.helmet then
        table.insert(equipmentList, {
          ItemID = wearData.headShow
        })
      elseif wearData.hatSkinId ~= 0 then
        table.insert(equipmentList, {
          ItemID = wearData.hatSkinId
        })
      end
    elseif wearData.hatSkinId ~= 0 then
      table.insert(equipmentList, {
        ItemID = wearData.hatSkinId
      })
    end
  end
  local TableUtil = require("common.table_util")
  if isShowBag and wearData.bagSkinInsId ~= 0 and wearData.depot_show_info.bag then
    table.insert(equipmentList, {
      ItemID = wearData.bagSkinInsId
    })
    for i, equipmentInfo in ipairs(wearData.bag_pendants) do
      if equipmentInfo.ItemID ~= 0 then
        table.insert(equipmentList, TableUtil.CopyTable(equipmentInfo))
      end
    end
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  for i, equipmentInfo in ipairs(wearData.WearInfoList) do
    if equipmentInfo.ItemID ~= 0 then
      if WardrobeData:IsGlovesItem(equipmentInfo.ItemID) then
        if wearData.depot_show_info.hand then
          table.insert(equipmentList, TableUtil.CopyTable(equipmentInfo))
        end
      else
        table.insert(equipmentList, TableUtil.CopyTable(equipmentInfo))
      end
    end
  end
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.SortEquipmentListByDefaultPriority(equipmentList)
  local uid = wearData.uid
  for _, v in ipairs(equipmentList) do
    avatar:PutonEquipment(v.ItemID, v)
  end
  equipmentList = {}
  if isShowWeapon and wearData.depot_show_info.weapon then
    local weaponId = wearData.mainWeaponInfo.weaponSkinId ~= 0 and wearData.mainWeaponInfo.weaponSkinId or wearData.mainWeaponInfo.weaponResId
    if weaponId ~= 0 then
      table.insert(equipmentList, {
        ItemID = weaponId,
        extraData = {bIsUse = true},
        diyInfo = wearData.mainWeaponInfo.diyInfo
      })
    end
    local extraWeaponId = wearData.extraWeaponInfo.weaponSkinId ~= 0 and wearData.extraWeaponInfo.weaponSkinId or wearData.extraWeaponInfo.weaponResId
    if extraWeaponId ~= 0 then
      table.insert(equipmentList, {
        ItemID = extraWeaponId,
        extraData = {bIsUse = false},
        diyInfo = wearData.extraWeaponInfo.diyInfo
      })
    end
  end
  for _, v in ipairs(equipmentList) do
    local nItemId = v.ItemID
    local tAvatarCustom = AvatarData.CreateAvatarCustom(nItemId, v.ColorID, v.PatternID)
    avatar:PutonEquipment(v.ItemID, tAvatarCustom, v.extraData)
    if nItemId ~= 0 and v.diyInfo.diyWeaponId == nItemId then
      if v.diyInfo.diyDefaultScheme then
        local weapon_diy_rec_scheme = require("client.slua.logic.weapon_diy.weapon_diy_rec_scheme")
        local scheme = weapon_diy_rec_scheme[nItemId]
        if scheme then
          avatar:ChangeDiyWeaponScheme(scheme)
        end
      elseif v.diyInfo.diyScheme and v.diyInfo.diyScheme ~= "" then
        local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
        local scheme = weapon_diy_system:UnpackBinDataToLuaTable(v.diyInfo.diyScheme)
        avatar:ChangeDiyWeaponScheme(scheme)
      end
    end
  end
end
function AvatarCommon.IsXSuit(itemID)
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  local itemID = multi_state_manager:GetOriginClothIDAndState(itemID) or itemID
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if LogicXSuit.IsXSuit(itemID) then
    return true
  end
  return false
end
function AvatarCommon.IsGoldenSuit(itemID)
  local ItemConfig = CDataTable.GetTableData("Item", itemID)
  if ItemConfig and ItemConfig.ItemQuality == 8 and (ItemConfig.ItemType == ENUM_ITEM_TYPE.Extra or ItemConfig.ItemType == ENUM_ITEM_TYPE.Backpack) then
    return true
  end
  return false
end
function AvatarCommon.GetCornerPath(ItemID)
  local RareItemCfg = CDataTable.GetTableData("RareItemCfg", ItemID)
  if RareItemCfg then
    return RareItemCfg.CornerPath
  end
  return nil
end
function AvatarCommon.GetXSuitCornerPath(ItemID)
  local Path = AvatarCommon.GetCornerPath(ItemID)
  if not Path or Path == "" then
    Path = AvatarCommon.XSuitCornerPath
  end
  return Path
end
function AvatarCommon.GetGoldenSuitCornerPath(ItemID)
  local Path = AvatarCommon.GetCornerPath(ItemID)
  if not Path or Path == "" then
    Path = AvatarCommon.GoldenSuitCornerPath
  end
  return Path
end
return AvatarCommon