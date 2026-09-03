local ShareBagUtil = {}
local AvatarDataUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarDataUtil")
function ShareBagUtil:fillWearToGameModePlayerItem(wear, uPlayerController, itemList)
  print(bWriteLog and "ShareBagAvatarDataUtil.fillWearToGameModePlayerItem uid:" .. tostring(uPlayerController.UID))
  local XSuitAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitAvatarDataUtil")
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  for i, v in pairs(wear) do
    if v and next(v) ~= nil and v[ENUM_AVATAR_DATA_TYPE.ItemID] then
      local item = {}
      item.ItemTableID = v[ENUM_AVATAR_DATA_TYPE.ItemID]
      XSuitAvatarDataUtil:FillXSuitDressList(v, item, uPlayerController)
      item.AdditionIntData = CommerAvatarDataUtil:GetAdditionIntData(v)
      item.Count = 1
      table.insert(itemList, item)
    end
  end
end
function ShareBagUtil:GetParachuteGliderIDFromPlayerInfo(PlayerInfo)
  if PlayerInfo and PlayerInfo.ingame_use_item_info then
    for k, v in pairs(PlayerInfo.ingame_use_item_info) do
      local EquipData = CDataTable.GetTableData("Item", k)
      if EquipData and EquipData.ItemType == ENUM_ITEM_TYPE.Extra and (EquipData.ItemSubType == 413 or EquipData.ItemSubType == 414 or EquipData.ItemSubType == 415) then
        return k
      end
    end
  end
  return 0
end
function ShareBagUtil:GetParachuteGliderIDFromFashionBag(PlayerInfo, RolewearIndex)
  if not PlayerInfo or not PlayerInfo.all_knapsack_ext_info then
    return 0
  end
  RolewearIndex = RolewearIndex or PlayerInfo.use_rolewear
  if not RolewearIndex or not PlayerInfo.all_knapsack_ext_info[RolewearIndex] then
    return 0
  end
  local Glider = PlayerInfo.all_knapsack_ext_info[RolewearIndex].gliding
  local GliderAircraft = PlayerInfo.all_knapsack_ext_info[RolewearIndex].aircraft_put_id
  if Glider and Glider ~= 0 then
    return Glider
  elseif GliderAircraft and GliderAircraft ~= 0 then
    return GliderAircraft
  end
  return 0
end
function ShareBagUtil:fillKnapsackSingleInfo(tInfo, KnapsackExtInfoList, bHasFlyingState, i, ParachuteGliderID, uPlayerController)
  local SingleInfo = {}
  if tInfo == nil then
    if type(KnapsackExtInfoList) == "table" then
      table.insert(KnapsackExtInfoList, {
        KnapsackExtInfo = SingleInfo,
        IsLocked = true,
        WearIndex = i
      })
    end
  else
    if bHasFlyingState then
      SingleInfo.Parachute = tInfo.parachute or 703001
      SingleInfo.ParachuteGlider = ParachuteGliderID or 0
    else
      SingleInfo.Parachute = 0
      SingleInfo.ParachuteGlider = 0
    end
    SingleInfo.BagSkin = tInfo.bag_skin or 0
    SingleInfo.HelmetSkin = tInfo.helmet_skin or 0
    SingleInfo.BagSkinList = tInfo.bag_skin_list or {}
    SingleInfo.HelmetSkinList = tInfo.helmet_skin_list or {}
    SingleInfo.FlySkin = tInfo.fly_skin or 0
    SingleInfo.WingmanSkin = tInfo.wingman_skin or 0
    SingleInfo.GrenadeSkin = tInfo.grenade_skin or 0
    SingleInfo.ConsumableAvatarList = {}
    local tempGrenadeList = tInfo.throw_object_list or {}
    local tempGrenade = {}
    for grenadeK, grenadeV in pairs(tempGrenadeList) do
      if grenadeK == 612 then
        tempGrenade.GrenadeAvatarShoulei = grenadeV
      elseif grenadeK == 613 then
        tempGrenade.GrenadeAvatarSmoke = grenadeV
      elseif grenadeK == 614 then
        tempGrenade.GrenadeAvatarStun = grenadeV
      elseif grenadeK == 615 then
        tempGrenade.GrenadeAvatarBurn = grenadeV
      end
    end
    SingleInfo.ConsumableAvatarList = tempGrenade
    local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
    SingleInfo.WeaponList = CommerAvatarDataUtil:ConstructWeaponSkinList(uPlayerController, tInfo.weapon_list, tInfo.weapon_attach_list, tInfo.weapon_pendant)
    SingleInfo.BackPackPendantList = {}
    local tempPendantList = tInfo.pendants or {}
    for pK, pV in pairs(tempPendantList) do
      if pK == 1 and 0 < pV then
        local tempPendant = {ItemTableID = pV, Count = 1}
        table.insert(SingleInfo.BackPackPendantList, tempPendant)
      end
    end
    if type(KnapsackExtInfoList) == "table" then
      table.insert(KnapsackExtInfoList, {
        KnapsackExtInfo = SingleInfo,
        IsLocked = false,
        WearIndex = i
      })
    end
  end
  return SingleInfo
end
function ShareBagUtil:ShareSkinFillInEditor(uPlayerController, PlayerInfo, bHasFlyingState)
  if IsEditor then
    uPlayerController.nFriendLeftSharedSkinTimes = 10
    local share_wear = PlayerInfo.share_wear
    if share_wear and next(share_wear.wear_list) then
      local itemList2 = {}
      self:fillWearToGameModePlayerItem(share_wear.wear_list, uPlayerController, itemList2)
      print(bWriteLog and string.format(" ShareBagUtil.ShareSkinFillInEditor len:%s", uPlayerController.InitialSharedSkin:Num()))
      uPlayerController.InitialSharedSkin = itemList2
    end
    if share_wear and share_wear.knapsack_ext_info then
      local ParachuteGliderID = self:GetParachuteGliderIDFromFashionBag(PlayerInfo)
      local SingleInfo = self:fillKnapsackSingleInfo(share_wear.knapsack_ext_info, nil, bHasFlyingState, 0, ParachuteGliderID, uPlayerController)
      SingleInfo.weapon_list = AvatarDataUtil.FilterWeaponAttachments(uPlayerController, SingleInfo.weapon_list)
      uPlayerController.InitialSharedKnapsack = SingleInfo
    end
  end
end
function ShareBagUtil:WearAndExtInfo2ItemIdList(wearList, knapsackExtInfo)
  local wardrobe_fashion_utils = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
  local itemidList = {}
  local itemTable = CDataTable.GetTable("Item")
  for i, v in pairs(wearList) do
    local itemId = v.ItemTableID
    if 0 < itemId then
      local itemCfg = itemTable[itemId]
      if itemCfg and wardrobe_fashion_utils.CanBeSharedByItemConfig(itemCfg) then
        local addition = FuncUtil.LuaArrayToTable(v.AdditionIntData)
        table.insert(itemidList, {itemId, addition})
      else
        print(bWriteLog and " AvatarDataUtil.WearAndExtInfo2ItemIdList unexpect itemid:" .. itemId)
      end
    end
  end
  local items = {
    knapsackExtInfo.FlySkin,
    knapsackExtInfo.WingmanSkin,
    knapsackExtInfo.HelmetSkin,
    knapsackExtInfo.GrenadeSkin,
    knapsackExtInfo.Parachute,
    knapsackExtInfo.BagSkin
  }
  for k, v in pairs(items) do
    local itemId = v
    if 0 < itemId then
      local itemCfg = itemTable[itemId]
      if itemCfg and wardrobe_fashion_utils.CanBeSharedByItemConfig(itemCfg) then
        table.insert(itemidList, {itemId, nil})
      else
        print(bWriteLog and " AvatarDataUtil.WearAndExtInfo2ItemIdList unexpect itemid:" .. itemId)
      end
    end
  end
  return itemidList
end
function ShareBagUtil:CompleteFriendShareSkin(uPlayerController, PlayerInfo, uFriendPC, bHasFlyingState)
  if Game:IsValid(uFriendPC) then
    local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
    local FriendPlayerInfo = PlayerDataMgr.GetPlayerInfo(uFriendPC.UID)
    if FriendPlayerInfo == nil then
      print(bWriteLog and " CompleteFriendShareSkin FriendPlayerInfo is nil.  should only happen in editor")
      local hasData = false
      local UKismetSystemLibrary = import("KismetSystemLibrary")
      if UKismetSystemLibrary.IsStandalone(uFriendPC) then
        FriendPlayerInfo, hasData = AvatarDataUtil.GetAvatarStandaloneData()
      end
      if not hasData then
        FriendPlayerInfo = AvatarDataUtil.GetAvatarTestData()
      end
      if IsEditor then
        PlayerDataMgr.OnSyncPlayerInfo(uFriendPC.UID, FriendPlayerInfo)
      end
    end
    print(bWriteLog and " CompleteFriendShareSkin  assert -1 uPlayerController.nFriendLeftSharedSkinTimes = " .. uPlayerController.nFriendLeftSharedSkinTimes)
    uPlayerController.nFriendLeftSharedSkinTimes = uFriendPC.nOutLeftSharedSkinTimes
    do
      local share_wear = FriendPlayerInfo and FriendPlayerInfo.share_wear
      if share_wear and next(share_wear.wear_list) then
        local itemList2 = {}
        self:fillWearToGameModePlayerItem(share_wear.wear_list, uPlayerController, itemList2)
        uPlayerController.InitialSharedSkin = itemList2
      end
      if share_wear and share_wear.knapsack_ext_info then
        local ParachuteGliderID = self:GetParachuteGliderIDFromFashionBag(FriendPlayerInfo)
        local SingleInfo = self:fillKnapsackSingleInfo(share_wear.knapsack_ext_info, nil, bHasFlyingState, 0, ParachuteGliderID, uPlayerController)
        SingleInfo.weapon_list = AvatarDataUtil.FilterWeaponAttachments(uPlayerController, SingleInfo.weapon_list)
        uPlayerController.InitialSharedKnapsack = SingleInfo
      end
    end
    print(bWriteLog and " CompleteFriendShareSkin  assert -1 uFriendPC.nFriendLeftSharedSkinTimes = " .. uFriendPC.nFriendLeftSharedSkinTimes)
    uFriendPC.nFriendLeftSharedSkinTimes = uPlayerController.nOutLeftSharedSkinTimes
    local share_wear = PlayerInfo.share_wear
    if share_wear and next(share_wear.wear_list) then
      local itemList2 = {}
      self:fillWearToGameModePlayerItem(share_wear.wear_list, uFriendPC, itemList2)
      uFriendPC.InitialSharedSkin = itemList2
    end
    if share_wear and share_wear.knapsack_ext_info then
      local ParachuteGliderID = self:GetParachuteGliderIDFromFashionBag(PlayerInfo)
      local SingleInfo = self:fillKnapsackSingleInfo(share_wear.knapsack_ext_info, nil, bHasFlyingState, 0, ParachuteGliderID, uPlayerController)
      SingleInfo.weapon_list = AvatarDataUtil.FilterWeaponAttachments(uFriendPC, SingleInfo.weapon_list)
      uFriendPC.InitialSharedKnapsack = SingleInfo
    end
  else
    print(bWriteLog and string.format(" CompleteFriendShareSkin invalid friend. myuid:%s frienduid:%s", uPlayerController.UID, PlayerInfo.share_wear.friend_uid))
    self:ShareSkinFillInEditor(uPlayerController, PlayerInfo, bHasFlyingState)
  end
end
return ShareBagUtil