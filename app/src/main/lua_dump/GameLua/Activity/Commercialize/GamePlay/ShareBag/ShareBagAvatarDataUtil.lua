local ShareBagAvatarDataUtil = {}
local NORMAL_SHARE_BAG_COUNT = 5
function ShareBagAvatarDataUtil:GeneratePlayerAvatarData(PlayerInfo, uPlayerController, bHasFlyingState)
  print(bWriteLog and "ShareBagAvatarDataUtil.GeneratePlayerAvatarData bSubscribeBagOpened:" .. tostring(uPlayerController.bSubscribeBagOpened) .. " FashionBagStartIndex:" .. tostring(uPlayerController.FashionBagStartIndex))
  local ShareBagUtil = require("GameLua.Activity.Commercialize.GamePlay.ShareBag.ShareBagUtil")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local allWear = {}
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  log_tree("ShareBagAvatarDataUtil.GeneratePlayerAvatarData ext_attr:", PlayerInfo.ext_attr)
  if PlayerInfo.all_wear_ext then
    for i = 1, 4 do
      local itemList = {}
      local wear = PlayerInfo.all_wear_ext[i]
      if wear == nil then
        local rolewearInfo = {RolewearInfo = itemList, IsLocked = true}
        table.insert(allWear, rolewearInfo)
      else
        ShareBagUtil:fillWearToGameModePlayerItem(wear, uPlayerController, itemList)
        local rolewearInfo = {RolewearInfo = itemList, IsLocked = false}
        table.insert(allWear, rolewearInfo)
      end
    end
    local itemList = {}
    local rpPlusBagIndex = 6
    local wear = PlayerInfo.all_wear_ext[rpPlusBagIndex]
    if wear == nil then
      local rolewearInfo = {RolewearInfo = itemList, IsLocked = true}
      table.insert(allWear, rolewearInfo)
    else
      ShareBagUtil:fillWearToGameModePlayerItem(wear, uPlayerController, itemList)
      local rolewearInfo = {RolewearInfo = itemList, IsLocked = false}
      table.insert(allWear, rolewearInfo)
    end
    local CurrentItemList = {}
    local CurrentWear = PlayerInfo.use_rolewear and PlayerInfo.all_wear_ext[PlayerInfo.use_rolewear]
    local CurrentRoleWearInfo = {RolewearInfo = CurrentItemList, IsLocked = false}
    if CurrentWear ~= nil then
      ShareBagUtil:fillWearToGameModePlayerItem(CurrentWear, uPlayerController, CurrentItemList)
    end
    table.insert(allWear, CurrentRoleWearInfo)
  end
  local share_wear = PlayerInfo.share_wear
  log_tree("ShareBagAvatarDataUtil.GeneratePlayerAvatarData share_wear:", share_wear)
  if share_wear and share_wear.friend_uid ~= 0 then
    uPlayerController.nInLeftSharedSkinTimes = share_wear.in_left_times
    uPlayerController.nOutLeftSharedSkinTimes = share_wear.out_left_times
    uPlayerController.bSharedSkinOpened = true
    local uFriendPC = Game:GetPlayerControllerByUID(share_wear.friend_uid)
    ShareBagUtil:CompleteFriendShareSkin(uPlayerController, PlayerInfo, uFriendPC, bHasFlyingState)
  else
    uPlayerController.bSharedSkinOpened = false
  end
  uPlayerController.FashionBagStartIndex = 0
  uPlayerController.bSubscribeBagOpened = false
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local share_bag_wear_list = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(uPlayerController.UID, ExtendAttribute.ShareBagList)
  local shareWearInfo = {
    wear_list = {},
    knapsack_ext_info = {}
  }
  local bHasSubscribeShareItem = false
  log_tree("ShareBagAvatarDataUtil.GeneratePlayerAvatarData share_bag_wear_list:", share_bag_wear_list)
  if share_bag_wear_list then
    for share_type, single_share_wear in pairs(share_bag_wear_list) do
      if share_type == 1 or share_type == 2 then
        if single_share_wear then
          if single_share_wear.wear_list and next(single_share_wear.wear_list) then
            for k, v in pairs(single_share_wear.wear_list) do
              shareWearInfo.wear_list[k] = v
            end
            bHasSubscribeShareItem = true
          end
          if single_share_wear.knapsack_ext_info then
            local shared_bag_skin = single_share_wear.knapsack_ext_info.bag_skin or 0
            if shared_bag_skin ~= 0 then
              shareWearInfo.knapsack_ext_info.bag_skin = shared_bag_skin
              bHasSubscribeShareItem = true
            end
            local shared_helmet_skin = single_share_wear.knapsack_ext_info.helmet_skin or 0
            if shared_helmet_skin ~= 0 then
              shareWearInfo.knapsack_ext_info.helmet_skin = shared_helmet_skin
              bHasSubscribeShareItem = true
            end
          end
        end
      elseif share_type == 4 and single_share_wear.weapon_list and next(single_share_wear.weapon_list) then
        bHasSubscribeShareItem = true
        shareWearInfo.knapsack_ext_info.weapon_list = {}
        for _, item_id in pairs(single_share_wear.weapon_list) do
          table.insert(shareWearInfo.knapsack_ext_info.weapon_list, item_id)
          if PlayerInfo and PlayerInfo.weapon_skin_list then
            table.insert(PlayerInfo.weapon_skin_list, 1, item_id)
          end
        end
      end
    end
    if bHasSubscribeShareItem then
      local wear = {}
      local CurrentWearExt = PlayerInfo.use_rolewear and PlayerInfo.all_wear_ext and PlayerInfo.all_wear_ext[PlayerInfo.use_rolewear]
      if CurrentWearExt then
        for k, v in pairs(CurrentWearExt) do
          wear[k] = v
        end
      end
      if shareWearInfo.wear_list then
        for k, v in pairs(shareWearInfo.wear_list) do
          wear[k] = v
        end
      end
      local itemList = {}
      ShareBagUtil:fillWearToGameModePlayerItem(wear, uPlayerController, itemList)
      local rolewearInfo = {RolewearInfo = itemList, IsLocked = false}
      uPlayerController.bSubscribeBagOpened = true
      uPlayerController.FashionBagStartIndex = 1
      table.insert(allWear, 1, rolewearInfo)
    end
  end
  if uPlayerController.bSubscribeBagOpened then
    uPlayerController.RolewearIndex = 0
  else
    uPlayerController.RolewearIndex = NORMAL_SHARE_BAG_COUNT
  end
  local KnapsackExtInfoList = {}
  if shareWearInfo and uPlayerController.bSubscribeBagOpened then
    local knapsack_ext_info = {}
    local CurrentWearExtKnapsackExtInfo = PlayerInfo.use_rolewear and PlayerInfo.all_knapsack_ext_info and PlayerInfo.all_knapsack_ext_info[PlayerInfo.use_rolewear]
    if CurrentWearExtKnapsackExtInfo then
      for k, v in pairs(CurrentWearExtKnapsackExtInfo) do
        knapsack_ext_info[k] = v
      end
      if shareWearInfo.knapsack_ext_info then
        local bag_skin = shareWearInfo.knapsack_ext_info.bag_skin or 0
        if bag_skin ~= 0 then
          knapsack_ext_info.          knapsack_ext_info.bag_skin_list = {
            bag_skin,
            bag_skin,
            bag_skin
          }
        end
        local helmet_skin = shareWearInfo.knapsack_ext_info.helmet_skin or 0
        if helmet_skin ~= 0 then
          knapsack_ext_info.          knapsack_ext_info.helmet_skin_list = {
            helmet_skin,
            helmet_skin,
            helmet_skin
          }
        end
        local weapon_list = shareWearInfo.knapsack_ext_info.weapon_list
        if weapon_list and next(weapon_list) then
          knapsack_ext_info.        end
      end
    end
    local ParachuteGliderID = ShareBagUtil:GetParachuteGliderIDFromFashionBag(PlayerInfo)
    ShareBagUtil:fillKnapsackSingleInfo(knapsack_ext_info, KnapsackExtInfoList, bHasFlyingState, 1, ParachuteGliderID, uPlayerController)
  end
  if PlayerInfo.all_knapsack_ext_info then
    for i = 1, 4 do
      local ParachuteGliderID = ShareBagUtil:GetParachuteGliderIDFromFashionBag(PlayerInfo, i)
      ShareBagUtil:fillKnapsackSingleInfo(PlayerInfo.all_knapsack_ext_info[i], KnapsackExtInfoList, bHasFlyingState, i, ParachuteGliderID, uPlayerController)
    end
    local rpPlusBagIndex = 6
    local RPParachuteGliderID = ShareBagUtil:GetParachuteGliderIDFromFashionBag(PlayerInfo, rpPlusBagIndex)
    ShareBagUtil:fillKnapsackSingleInfo(PlayerInfo.all_knapsack_ext_info[rpPlusBagIndex], KnapsackExtInfoList, bHasFlyingState, rpPlusBagIndex, RPParachuteGliderID, uPlayerController)
    if PlayerInfo.use_rolewear and PlayerInfo.all_knapsack_ext_info[PlayerInfo.use_rolewear] then
      local ParachuteGliderID = ShareBagUtil:GetParachuteGliderIDFromFashionBag(PlayerInfo, PlayerInfo.use_rolewear)
      ShareBagUtil:fillKnapsackSingleInfo(PlayerInfo.all_knapsack_ext_info[PlayerInfo.use_rolewear], KnapsackExtInfoList, bHasFlyingState, 5, ParachuteGliderID, uPlayerController)
    end
    uPlayerController.InitialKnapsackExtInfo = KnapsackExtInfoList
    log_tree("ShareBagAvatarDataUtil.GeneratePlayerAvatarData KnapsackExtInfoList:", KnapsackExtInfoList)
  end
  log_tree("ShareBagAvatarDataUtil.GeneratePlayerAvatarData allWear:", allWear)
  if next(allWear) ~= nil then
    uPlayerController.InitialAllWear = allWear
  end
  print(bWriteLog and "ShareBagAvatarDataUtil.GeneratePlayerAvatarData End ")
end
return ShareBagAvatarDataUtil