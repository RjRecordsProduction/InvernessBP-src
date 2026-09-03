local local local TableUtil = require("common.table_util")
local ModelDisplayTypeHelper = {
  SubTypeList = {
    Grenade = 612,
    Smoke = 613,
    Earthquake = 614,
    Burning = 615
  },
  SubTypeBackPack = {
    [ENUM_ITEM_SUBTYPE.Upgrade_Backpack] = true,
    [ENUM_ITEM_SUBTYPE.Backpack] = true,
    [ENUM_ITEM_SUBTYPE.Helmet] = true,
    [ENUM_ITEM_SUBTYPE.Helmet_NoLevel] = true
  },
  ModelImageDisplayType = nil
}
local _GetItemmTypeAndSubType = function(itemID)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if not itemCfg then
    return 0, 0
  end
  return itemCfg.ItemType or 0, itemCfg.ItemSubType or 0
end
function ModelDisplayTypeHelper.IsCollectionHallReward(sceneType)
  local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
  return sceneType == ConstAvatarDislay.ESceneType.CollectionHallRewardInfo
end
function ModelDisplayTypeHelper.IsWeapon(itemType)
  return itemType == ENUM_ITEM_TYPE.Weapon
end
function ModelDisplayTypeHelper.IsHeadSlot(itemId)
  local itemType, itemSubType = _GetItemmTypeAndSubType(itemId)
  return itemType == ENUM_ITEM_TYPE.Extra and itemSubType == ENUM_ITEM_SUBTYPE.Head_Slot_400
end
function ModelDisplayTypeHelper.IsWeaponById(itemId)
  local itemType, itemSubType = _GetItemmTypeAndSubType(itemId)
  return ModelDisplayTypeHelper.IsWeapon(itemType)
end
function ModelDisplayTypeHelper.IsDIYWeapon(itemID)
  local WeaponDIYSystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  local itemData = WeaponDIYSystem:GetWeaponCfg(itemID)
  if itemData then
    return true
  else
    return false
  end
end
local FullScreenTb = {
  [ENUM_ITEM_TYPE.Extra] = 1,
  [ENUM_ITEM_TYPE.Backpack] = 1
}
function ModelDisplayTypeHelper.IsFullScreenType(itemType)
  if FullScreenTb[itemType] then
    return true
  end
  return false
end
function ModelDisplayTypeHelper.IsClothes(itemType)
  return itemType == ENUM_ITEM_TYPE.Extra
end
local clothesSubTypeTb = {
  [ENUM_ITEM_SUBTYPE.Head_Slot_400] = 1,
  [ENUM_ITEM_SUBTYPE.Hat_Slot] = 1,
  [ENUM_ITEM_SUBTYPE.Mask_Slot] = 1,
  [ENUM_ITEM_SUBTYPE.Package_Slot] = 1,
  [ENUM_ITEM_SUBTYPE.Pants_Slot] = 1,
  [ENUM_ITEM_SUBTYPE.Shoes_Slot] = 1,
  [ENUM_ITEM_SUBTYPE.Hair_Slot] = 1,
  [ENUM_ITEM_SUBTYPE.Eye_Slot] = 1,
  [ENUM_ITEM_SUBTYPE.Helmet_NoLevel] = 1,
  [ENUM_ITEM_SUBTYPE.Backpack] = 1,
  [ENUM_ITEM_SUBTYPE.Backpack_Pendant_Skin] = 1
}
function ModelDisplayTypeHelper.IsRealClothes(itemType, subType)
  if itemType ~= ENUM_ITEM_TYPE.Extra and itemType ~= ENUM_ITEM_TYPE.Backpack then
    return false
  end
  if subType and clothesSubTypeTb[subType] then
    return true
  end
  return false
end
function ModelDisplayTypeHelper.IsClothingSet(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Extra and subType == ENUM_ITEM_SUBTYPE.Package_Slot
end
function ModelDisplayTypeHelper.IsGoldenSuit(itemID)
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  return LogicXSuit.IsXSuit(itemID)
end
function ModelDisplayTypeHelper.IsBagWidget(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Extra and subType == ENUM_ITEM_SUBTYPE.Backpack_Pendant_Skin
end
function ModelDisplayTypeHelper.IsBagWidgetByItemId(itemId)
  local itemType, subType = _GetItemmTypeAndSubType(itemId)
  return ModelDisplayTypeHelper.IsBagWidget(itemType, subType)
end
function ModelDisplayTypeHelper.IsGlideSmoke(subType)
  return subType == ENUM_ITEM_SUBTYPE.Glider_Slot_415
end
function ModelDisplayTypeHelper.IsGlide(subType)
  return ModelDisplayTypeHelper.IsGlideSmoke(subType) or ModelDisplayTypeHelper.IsAirCastType(subType)
end
function ModelDisplayTypeHelper.IsGlideByItemID(ItemID)
  local itemType, subType = _GetItemmTypeAndSubType(ItemID)
  return ModelDisplayTypeHelper.IsGlide(subType)
end
function ModelDisplayTypeHelper.IsParachute(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Extra and subType == ENUM_ITEM_SUBTYPE.Parachute_Slot
end
function ModelDisplayTypeHelper.IsParachuteByItemId(itemId)
  local itemType, subType = _GetItemmTypeAndSubType(itemId)
  return itemType == ENUM_ITEM_TYPE.Extra and subType == ENUM_ITEM_SUBTYPE.Parachute_Slot
end
function ModelDisplayTypeHelper.IsBag(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Backpack and (subType == ENUM_ITEM_SUBTYPE.Backpack or subType == ENUM_ITEM_SUBTYPE.Upgrade_Backpack)
end
function ModelDisplayTypeHelper.IsNoLevelBag(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Backpack and subType == ENUM_ITEM_SUBTYPE.Upgrade_Backpack
end
function ModelDisplayTypeHelper.IsHelmet(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Backpack and subType == ENUM_ITEM_SUBTYPE.Helmet
end
function ModelDisplayTypeHelper.IsNoLevelHelmet(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Backpack and subType == ENUM_ITEM_SUBTYPE.Helmet_NoLevel
end
function ModelDisplayTypeHelper.IsGlasses(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Extra and subType == ENUM_ITEM_SUBTYPE.Eye_Slot
end
function ModelDisplayTypeHelper.IsHat(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Extra and subType == ENUM_ITEM_SUBTYPE.Hat_Slot
end
function ModelDisplayTypeHelper.IsMask(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Extra and subType == ENUM_ITEM_SUBTYPE.Mask_Slot
end
function ModelDisplayTypeHelper.IsGrenade(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Consumables and (subType == ENUM_ITEM_SUBTYPE.Grenade_612 or subType == ENUM_ITEM_SUBTYPE.Smoke_Grenade or subType == ENUM_ITEM_SUBTYPE.Grenade_614 or subType == ENUM_ITEM_SUBTYPE.Molotov_Cocktail)
end
function ModelDisplayTypeHelper.IsBomb(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Consumables and subType == ENUM_ITEM_SUBTYPE.Bombs
end
function ModelDisplayTypeHelper.IsBackpackOrHelmet(itemID)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if itemCfg and itemCfg.ItemType == ENUM_ITEM_TYPE.Backpack then
    return ModelDisplayTypeHelper.SubTypeBackPack[itemCfg.ItemSubType] or false
  end
  return false
end
function ModelDisplayTypeHelper.IsPlane(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Aircraft_Skin and subType == ENUM_ITEM_SUBTYPE.Aircraft_Skin
end
function ModelDisplayTypeHelper.IsMaterialPackLimitedPurchasePrivilege(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.CollectSpecial and subType == ENUM_ITEM_SUBTYPE.MaterialPackLimited
end
function ModelDisplayTypeHelper.IsPlaneByItemID(ItemID)
  if not ItemID then
    return false
  end
  local ItemCfg = CDataTable.GetTableData("Item", ItemID)
  if not ItemCfg then
    return false
  end
  return ModelDisplayTypeHelper.IsPlane(ItemCfg.ItemType, ItemCfg.ItemSubType)
end
function ModelDisplayTypeHelper.IsPlaneType(itemType)
  return itemType == ENUM_ITEM_TYPE.Aircraft_Skin
end
function ModelDisplayTypeHelper.IsGoldenSuitByQuality(itemType, ItemQuality)
  local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
  return itemType == ENUM_ITEM_TYPE.Extra and ItemQuality == ItemMacros.QUALITY_GOLDEN
end
function ModelDisplayTypeHelper.IsRedSuitByQuality(itemType, ItemQuality)
  local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
  return itemType == ENUM_ITEM_TYPE.Extra and ItemQuality == ItemMacros.QUALITY_RED
end
function ModelDisplayTypeHelper.IsVehicle(itemType)
  return itemType == ENUM_ITEM_TYPE.Aircraft_Skin or itemType == ENUM_ITEM_TYPE.Vehicle or itemType == ENUM_ITEM_TYPE.Wingman_Skin
end
function ModelDisplayTypeHelper.IsCarOrPlane(itemType)
  return itemType == ENUM_ITEM_TYPE.Aircraft_Skin or itemType == ENUM_ITEM_TYPE.Vehicle
end
function ModelDisplayTypeHelper.IsVehicleById(itemId)
  local itemType, itemSubType = _GetItemmTypeAndSubType(itemId)
  return ModelDisplayTypeHelper.IsVehicle(itemType)
end
function ModelDisplayTypeHelper.IsCar(itemType)
  return itemType == ENUM_ITEM_TYPE.Vehicle
end
function ModelDisplayTypeHelper.IsTank(itemType, itemSubType)
  return itemType == ENUM_ITEM_TYPE.Vehicle and itemSubType == ENUM_ITEM_SUBTYPE.Tank
end
function ModelDisplayTypeHelper.IsMecha(itemType, itemSubType)
  return itemType == ENUM_ITEM_TYPE.Vehicle and itemSubType == ENUM_ITEM_SUBTYPE.Mecha
end
function ModelDisplayTypeHelper.IsMTLB(itemType, itemSubType)
  return itemType == ENUM_ITEM_TYPE.Vehicle and itemSubType == ENUM_ITEM_SUBTYPE.MTLB
end
function ModelDisplayTypeHelper.IsWingMan(itemType)
  return itemType == ENUM_ITEM_TYPE.Wingman_Skin
end
function ModelDisplayTypeHelper.IsVoice(itemType)
  return itemType == ENUM_ITEM_TYPE.Victor_Speech
end
function ModelDisplayTypeHelper.IsVoiceBag(itemType, itemSubType)
  return itemType == ENUM_ITEM_TYPE.Voice_Pack and itemSubType == ENUM_ITEM_SUBTYPE.Voice_Pack
end
function ModelDisplayTypeHelper.IsEmotion(itemType)
  return itemType == ENUM_ITEM_TYPE.Emote
end
function ModelDisplayTypeHelper.IsMileStone(subType)
  return subType == ENUM_ITEM_SUBTYPE.MileStone
end
function ModelDisplayTypeHelper.IsMilestoneAction(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Emote and subType == ENUM_ITEM_SUBTYPE.MileStoneAction
end
function ModelDisplayTypeHelper.IsEmotionAction(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Emote and subType == ENUM_ITEM_SUBTYPE.Action
end
function ModelDisplayTypeHelper.IsWakeFlame(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Extra and subType == ENUM_ITEM_SUBTYPE.WakeFlame
end
function ModelDisplayTypeHelper.IsAlbumBackground(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Version_Album and subType == ENUM_ITEM_SUBTYPE.Version_Album
end
function ModelDisplayTypeHelper.IsDiyColor(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Applique and (subType == ENUM_ITEM_SUBTYPE.S12K or subType == ENUM_ITEM_SUBTYPE.BaseColor)
end
function ModelDisplayTypeHelper.IsDiyIcon(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Applique and (subType == ENUM_ITEM_SUBTYPE.Applique or subType == ENUM_ITEM_SUBTYPE.Firearms_Basic_Graphics)
end
function ModelDisplayTypeHelper.IsHolography(itemType)
  return itemType == ENUM_ITEM_TYPE.Holographic_Projection_Test
end
function ModelDisplayTypeHelper.IsTransProps(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Holographic_Projection_Test and subType == ENUM_ITEM_SUBTYPE.Holographic_Projection
end
function ModelDisplayTypeHelper.IsStatue(itemType)
  return itemType == ENUM_ITEM_TYPE.Winning_Statue_Skin
end
function ModelDisplayTypeHelper.IsHome3DAsset(itemType, itemSubType)
  return itemType == ENUM_ITEM_TYPE.Home and (itemSubType == ENUM_ITEM_SUBTYPE.HomeStatue or itemSubType == ENUM_ITEM_SUBTYPE.Home_Structure or itemSubType == ENUM_ITEM_SUBTYPE.Home_Decoration or itemSubType == ENUM_ITEM_SUBTYPE.HomeTree or itemSubType == ENUM_ITEM_SUBTYPE.HomeDBStatue or itemSubType == ENUM_ITEM_SUBTYPE.HomePictureWall)
end
function ModelDisplayTypeHelper.IsHomeStatue(itemType, itemSubType)
  return itemType == ENUM_ITEM_TYPE.Home and itemSubType == ENUM_ITEM_SUBTYPE.HomeStatue
end
function ModelDisplayTypeHelper.IsCardCollectionAction(itemType, itemSubType)
  return itemType == ENUM_ITEM_TYPE.Emote and itemSubType == ENUM_ITEM_SUBTYPE.CardCollectionAction
end
function ModelDisplayTypeHelper.IsHeirloomEuqip(ItemID)
  local logic_xmission_heirloom_equip = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_heirloom_equip)
  return logic_xmission_heirloom_equip:CheckIsHeirloomEuqip(ItemID)
end
function ModelDisplayTypeHelper.Is3DModelType(ItemID)
  local WeaponModelMgrHelper = require("client.slua.logic.manager.WeaponModelSubLogic.WeaponModelMgrHelper")
  local OriginID = WeaponModelMgrHelper.GetOriginID(ItemID)
  if not OriginID then
    return false
  end
  local Common3DModelConfig = CDataTable.GetTableData("Common3DModelConfig", OriginID)
  if not Common3DModelConfig then
    return false
  end
  return true
end
function ModelDisplayTypeHelper.IsReviveEffect(ItemType, ItemSubType)
  return ItemType == ENUM_ITEM_TYPE.WowEffect and ItemSubType == ENUM_ITEM_SUBTYPE.WowReviveEffect
end
function ModelDisplayTypeHelper.Is3DEffect(itemType, itemSubType)
  if itemType == ENUM_ITEM_TYPE.CasualShop and itemSubType == ENUM_ITEM_SUBTYPE.CasualShopEffect then
    return true
  elseif itemType == ENUM_ITEM_TYPE.WowEffect then
    return true
  else
    return false
  end
end
function ModelDisplayTypeHelper.IsAirCastType(subType)
  return subType == ENUM_ITEM_SUBTYPE.Glider_Slot_413 or subType == ENUM_ITEM_SUBTYPE.Glider_Slot_414
end
function ModelDisplayTypeHelper.IsAirCastTypeByItemID(ItemID)
  local ItemCfg = CDataTable.GetTableData("Item", ItemID)
  if not ItemCfg then
    return false
  end
  return ModelDisplayTypeHelper.IsAirCastType(ItemCfg.ItemSubType)
end
function ModelDisplayTypeHelper.IsRifle(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Weapon and subType == ENUM_ITEM_SUBTYPE.Gun_Skin_101
end
function ModelDisplayTypeHelper._IsSubmachineGun(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Weapon and subType == ENUM_ITEM_SUBTYPE.Gun_Skin_102
end
function ModelDisplayTypeHelper._IsSniperRifle(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Weapon and subType == ENUM_ITEM_SUBTYPE.Gun_Skin_103
end
function ModelDisplayTypeHelper.IsRefitVehicle(resId)
  local itemCfg = CDataTable.GetTableData("Item", resId)
  if itemCfg == nil then
    return false
  end
  local itemType = itemCfg.ItemType
  if not ModelDisplayTypeHelper.IsVehicle(itemType) then
    return false
  end
  local refitInfo = CDataTable.GetTableData("VehicleRefitInfo", resId)
  if refitInfo == nil then
    return false
  end
  return refitInfo.unlock_part_list ~= ""
end
function ModelDisplayTypeHelper.IsPet(itemType)
  return itemType == ENUM_ITEM_TYPE.Buddy
end
function ModelDisplayTypeHelper.IsPetType(itemType)
  return itemType == ENUM_ITEM_TYPE.Buddy or itemType == ENUM_ITEM_TYPE.Buddy_New
end
function ModelDisplayTypeHelper.IsPetSkin(itemType)
  return itemType == ENUM_ITEM_TYPE.Buddy_New
end
function ModelDisplayTypeHelper.IsMiniTv(itemType)
  return itemType == ENUM_ITEM_TYPE.MiniTv or itemType == ENUM_ITEM_TYPE.MiniTVNew
end
function ModelDisplayTypeHelper.IsSpray(itemType)
  return itemType == ENUM_ITEM_TYPE.Spray_Pattern
end
function ModelDisplayTypeHelper.IsGift(itemType, itemSubType)
  return itemType == ENUM_ITEM_TYPE.CYCLE_Memory_Item and itemSubType == ENUM_ITEM_SUBTYPE.Aid_Gift
end
function ModelDisplayTypeHelper.IsBox(itemType)
  return itemType == ENUM_ITEM_TYPE.Starter_Pack
end
function ModelDisplayTypeHelper.IsSuitBox(itemType, itemSubType)
  return itemType == ENUM_ITEM_TYPE.Starter_Pack and itemSubType == ENUM_ITEM_SUBTYPE.SuitBox
end
function ModelDisplayTypeHelper.IsBear(itemType, itemSubType)
  return itemType == ENUM_ITEM_TYPE.Extra and itemSubType == ENUM_ITEM_SUBTYPE.Theme_Play
end
function ModelDisplayTypeHelper.IsGloves(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Extra and subType == ENUM_ITEM_SUBTYPE.Gloves
end
function ModelDisplayTypeHelper.IsLobbyScene(itemType)
  return itemType == ENUM_ITEM_TYPE.Hall_Theme
end
function ModelDisplayTypeHelper.IsLobbySceneByItemID(ItemID)
  local itemType, subType = _GetItemmTypeAndSubType(ItemID)
  return ModelDisplayTypeHelper.IsLobbyScene(itemType)
end
function ModelDisplayTypeHelper.IsLobbyToy(itemType, itemSubType)
  return itemType == ENUM_ITEM_TYPE.Consumables and itemSubType == ENUM_ITEM_SUBTYPE.Lobby_Toy
end
function ModelDisplayTypeHelper.IsLobbyPartnerStance(itemType)
  return itemType == ENUM_ITEM_TYPE.Partner_Stance
end
function ModelDisplayTypeHelper.IsKillCounter(itemSubType)
  return itemSubType == ENUM_ITEM_SUBTYPE.KillCounter
end
local local ModelDisplayType = {Icon2D = 2, Icon3D = 3}
function ModelDisplayTypeHelper._Is2DModel(itemType, subType)
  itemType = itemType or 0
  subType = subType or 0
  return ModelDisplayTypeHelper._IsMatchIconType(itemType, subType, ModelDisplayType.Icon2D)
end
function ModelDisplayTypeHelper._Is2DModelByItemId(itemId)
  local itemType, subType = _GetItemmTypeAndSubType(itemId)
  return ModelDisplayTypeHelper._Is2DModel(itemType, subType)
end
function ModelDisplayTypeHelper._IsIcon3D(itemType, subType, itemID)
  itemType = itemType or 0
  subType = subType or 0
  itemID = itemID or 0
  return ModelDisplayTypeHelper._IsMatchIconType(itemType, subType, ModelDisplayType.Icon3D, itemID)
end
function ModelDisplayTypeHelper._IsMatchIconType(itemType, subType, displayType, itemID)
  ModelDisplayTypeHelper._TryInitModelImageDisplayType()
  local itemTypeMap = TableUtil.GetTableValue(ModelDisplayTypeHelper.ModelImageDisplayType, displayType, itemType)
  local isHaveCfgList = false
  local isNeedCheckItem = itemID ~= nil and itemID ~= 0
  if itemTypeMap and (itemTypeMap[subType] or itemTypeMap[0]) then
    if isNeedCheckItem then
      local state = false
      local subZeroMap = TableUtil.GetTableValue(itemTypeMap, 0, "itemMap")
      local subMap = TableUtil.GetTableValue(itemTypeMap, subType, "itemMap")
      if subZeroMap and not state then
        state = subZeroMap[itemID]
      end
      if subMap and not state then
        state = subMap[itemID]
      end
      if subZeroMap or subMap then
        return state
      end
    end
    return true
  end
  if isHaveCfgList and subType == 0 then
    return true
  end
  return false
end
function ModelDisplayTypeHelper._TryInitModelImageDisplayType()
  if ModelDisplayTypeHelper.ModelImageDisplayType then
    return
  end
  ModelDisplayTypeHelper.ModelImageDisplayType = {}
  local cfgData = CDataTable.GetTable("ModelImageDisplayType")
  for i, cfg in pairs(cfgData) do
    if not ModelDisplayTypeHelper.ModelImageDisplayType[cfg.displayType] then
      ModelDisplayTypeHelper.ModelImageDisplayType[cfg.displayType] = {}
    end
    local typeDataMap = ModelDisplayTypeHelper.ModelImageDisplayType[cfg.displayType]
    if not typeDataMap[cfg.itemType] then
      typeDataMap[cfg.itemType] = {}
    end
    local itemTypeData = typeDataMap[cfg.itemType]
    if not itemTypeData[cfg.subType] then
      itemTypeData[cfg.subType] = {}
    end
    local itemSubTypeData = itemTypeData[cfg.subType]
    if cfg.itemArray_a:Num() > 0 then
      itemSubTypeData.itemMap = {}
      for _, itemID in pairs(cfg.itemArray_a) do
        itemSubTypeData.itemMap[itemID] = true
      end
    end
  end
end
function ModelDisplayTypeHelper.IsWowHomePageDecoration(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.WowDecorate and subType == ENUM_ITEM_SUBTYPE.WowHomePageDecoration
end
function ModelDisplayTypeHelper.IsWowEnterRoomNotify(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.WowDecorate and subType == ENUM_ITEM_SUBTYPE.WowEnterRommNotify
end
function ModelDisplayTypeHelper.IsWowRoomDecoration(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.WowDecorate and subType == ENUM_ITEM_SUBTYPE.WowRoomDecoration
end
function ModelDisplayTypeHelper.IsWowCommentDecoration(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.WowDecorate and subType == ENUM_ITEM_SUBTYPE.WowRoomCommentSkin
end
function ModelDisplayTypeHelper.IsWowRoomEffect(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.WowDecorate and subType == ENUM_ITEM_SUBTYPE.WowRoomEffect
end
function ModelDisplayTypeHelper._IsChatBubble(itemType)
  return itemType == ENUM_ITEM_TYPE.ChatBubble
end
function ModelDisplayTypeHelper._IsDynamicNickname(itemType)
  return itemType == ENUM_ITEM_TYPE.DynamicNickname
end
function ModelDisplayTypeHelper._IsInvitationPopupSkin(itemType)
  return itemType == ENUM_ITEM_TYPE.InvitationPopupSkin
end
function ModelDisplayTypeHelper._IsSocialCardBG(itemType)
  return itemType == ENUM_ITEM_TYPE.SocialCardBG
end
function ModelDisplayTypeHelper._IsCarteFrame(itemType)
  return itemType == ENUM_ITEM_TYPE.CarteFrame
end
function ModelDisplayTypeHelper._IsNameTagFrame(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Famous_Brand and subType == ENUM_ITEM_SUBTYPE.Name_Tag_Frame
end
function ModelDisplayTypeHelper._IsCommonModelByItemId(itemId)
  local itemType, subType = _GetItemmTypeAndSubType(itemId)
  return ModelDisplayTypeHelper._IsCommonModel(itemId, itemType, subType)
end
function ModelDisplayTypeHelper._IsCommonModel(itemID, itemType, subType)
  return ModelDisplayTypeHelper.IsVehicle(itemType) or ModelDisplayTypeHelper.IsParachute(itemType, subType) or ModelDisplayTypeHelper.IsGrenade(itemType, subType) or ModelDisplayTypeHelper._IsIcon3D(itemType, subType, itemID) or ModelDisplayTypeHelper.IsMiniTv(itemType) or ModelDisplayTypeHelper.IsHolography(itemType) or ModelDisplayTypeHelper.IsStatue(itemType) or ModelDisplayTypeHelper.IsHome3DAsset(itemType, subType) or ModelDisplayTypeHelper.Is3DModelType(itemID) or ModelDisplayTypeHelper.Is3DEffect(itemType, subType)
end
function ModelDisplayTypeHelper._IsSpecialModelByItemId(itemId)
  local itemType, subType = _GetItemmTypeAndSubType(itemId)
  return ModelDisplayTypeHelper._IsSpecialModel(itemType, subType)
end
function ModelDisplayTypeHelper._IsSpecialModel(itemType, subType)
  return ModelDisplayTypeHelper.IsWeapon(itemType) or ModelDisplayTypeHelper.IsBagWidget(itemType, subType)
end
function ModelDisplayTypeHelper.IsNameFrame(itemType)
  return itemType == ENUM_ITEM_TYPE.Famous_Brand
end
function ModelDisplayTypeHelper.IsAlias(itemType)
  return itemType == ENUM_ITEM_TYPE.Achievement_Title
end
function ModelDisplayTypeHelper.IsPet(itemType)
  return itemType == ENUM_ITEM_TYPE.Buddy
end
function ModelDisplayTypeHelper.IsMotor(itemSubType)
  if itemSubType == ENUM_ITEM_SUBTYPE.Moto_TwoWheel or itemSubType == ENUM_ITEM_SUBTYPE.Moto_Foot or itemSubType == ENUM_ITEM_SUBTYPE.Moto_ThreeWheel or itemSubType == ENUM_ITEM_SUBTYPE.Moto_Snow then
    return true
  end
  return false
end
function ModelDisplayTypeHelper.IsHairByItemID(itemId)
  local itemType, subType = _GetItemmTypeAndSubType(itemId)
  return itemType == ENUM_ITEM_TYPE.Extra and subType == ENUM_ITEM_SUBTYPE.Hair_Slot
end
function ModelDisplayTypeHelper.IsHair(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Extra and subType == ENUM_ITEM_SUBTYPE.Hair_Slot
end
function ModelDisplayTypeHelper.IsTwoWeaponModel(itemId)
  local WeaponModelMgrHelper = require("client.slua.logic.manager.WeaponModelSubLogic.WeaponModelMgrHelper")
  local OriginResID = WeaponModelMgrHelper.GetRealResId(itemId, true)
  if OriginResID == 106011 then
    return true
  end
  return false
end
function ModelDisplayTypeHelper.IsPetSharePrivilege(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.CollectSpecial and subType == ENUM_ITEM_SUBTYPE.PetSharePrivilege
end
function ModelDisplayTypeHelper.IsPetSlotExpandPrivilege(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.CollectSpecial and subType == ENUM_ITEM_SUBTYPE.PetSlotPrivilege
end
function ModelDisplayTypeHelper.IsPetBubblePrivilege(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.CollectSpecial and subType == ENUM_ITEM_SUBTYPE.PetBubblePrivilege
end
function ModelDisplayTypeHelper.IsBubbleEmote(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Emote and subType == ENUM_ITEM_SUBTYPE.Bubble_Emote
end
function ModelDisplayTypeHelper.IsPetSwitchEffect(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.PetSwitchEffect and subType == ENUM_ITEM_SUBTYPE.PetSwitchEffect
end
function ModelDisplayTypeHelper.IsCommonSubtypeWear(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Extra and subType == ENUM_ITEM_SUBTYPE.Skateboard_Trail
end
function ModelDisplayTypeHelper.IsWakeFlame(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Extra and subType == ENUM_ITEM_SUBTYPE.WakeFlame
end
function ModelDisplayTypeHelper.IsFootprints(itemType, subType)
  return itemType == ENUM_ITEM_TYPE.Extra and subType == ENUM_ITEM_SUBTYPE.Footprints
end
function ModelDisplayTypeHelper.IsAdditionEffect(itemType, subType)
  return ModelDisplayTypeHelper.IsWakeFlame(itemType, subType) or ModelDisplayTypeHelper.IsFootprints(itemType, subType)
end
function ModelDisplayTypeHelper.IsThemeSystemTaskItem(itemId)
  local data = CDataTable.GetTableDataByFilter("ThemeTaskAwardIntroduction", "ItemID", itemId)
  return data ~= nil
end
function ModelDisplayTypeHelper.IsCabinShowItem(type, subType)
  return type == ENUM_ITEM_TYPE.Emote and subType == ENUM_ITEM_SUBTYPE.CardCollectionCabin
end
return ModelDisplayTypeHelper