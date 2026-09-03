local fashionbag_data = {}
local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local DEFAULT_BAG_INDEX = 9
local fashion_bags = {
  use_index = DEFAULT_BAG_INDEX,
  bags = {
    {
      state = wardrobe_macro.enum_FashionBagState.CanBuy,
      head_show = 0,
      fly_skin = 0,
      wingman_skin = 0,
      bag_skin = 0,
      bag_skin_list = {_isLeaf = true},
      parachute = 0,
      gliding = 0,
      aircraft_put_id = 0,
      bag_level = 3,
      helmet_skin = 0,
      helmet_skin_list = {_isLeaf = true},
      helmet_level = 3,
      depot_bind_relation = {_isLeaf = true},
      rolewear_list = {_isLeaf = true},
      weapon_skin_list = {_isLeaf = true},
      throw_object_list = {_isLeaf = true},
      bag_pendants = {_isLeaf = true}
    }
  },
  previousBag = nil
}
local super_data = require("common.super_data")
fashion_bags = super_data.CreateSuperData(fashion_bags)
local shared_bag = {
  lastCopyIndex = 1,
  isOpened = false,
  times = 0,
  instIdList = {}
}
function fashionbag_data:GetRolewearByIndex(index)
  local bag = self:GetFashionBag(index)
  if not bag or not bag.rolewear_list then
    return {}
  end
  return bag.rolewear_list
end
function fashionbag_data:GetFashionBag(bag_index)
  return fashion_bags.bags[bag_index] or {}
end
function fashionbag_data:GetSharedBag()
  return shared_bag or {}
end
local FashionStateValid = function(state)
  return state and (state == wardrobe_macro.enum_FashionBagState.UnLock or 0 < state)
end
function fashionbag_data:IsFashionBagValid(bag_index)
  local state = self:GetFashionBagStateByIndex(bag_index)
  return FashionStateValid(state)
end
function fashionbag_data:GetUseCountInFashionBags(insID)
  local useCount = 0
  insID = tonumber(insID)
  if not insID then
    return useCount
  end
  for _, bag in pairs(fashion_bags.bags) do
    if FashionStateValid(bag.state) then
      for _, item in pairs(bag.rolewear_list) do
        if item == tonumber(insID) then
          useCount = useCount + 1
        end
      end
    end
  end
  return useCount
end
function fashionbag_data:GetCurrentFashionBag()
  return fashion_bags.bags[fashion_bags.use_index] or {}
end
function fashionbag_data:GetPreFashionBag()
  return fashion_bags.previousBag or {}
end
function fashionbag_data:GetCurrentFashionBagRolewearList()
  local bag = self:GetCurrentFashionBag()
  return bag.rolewear_list
end
local GenDefaultBagStruct = function()
  return {
    state = -1,
    head_show = 0,
    rolewear_list = {_isLeaf = true},
    parachute = 0,
    gliding = 0,
    aircraft_put_id = 0,
    bag_skin = 0,
    bag_skin_list = {_isLeaf = true},
    bag_level = 3,
    helmet_skin = 0,
    helmet_skin_list = {_isLeaf = true},
    helmet_level = 3,
    depot_bind_relation = {_isLeaf = true},
    fly_skin = 0,
    wingman_skin = 0,
    weapon_skin_list = {_isLeaf = true},
    throw_object_list = {_isLeaf = true},
    bag_pendants = {_isLeaf = true}
  }
end
function fashionbag_data:GetFashionBagUseIndex()
  return fashion_bags.use_index or DEFAULT_BAG_INDEX
end
function fashionbag_data:SetFashionBagUseIndex(index)
  local TableUtil = require("common.table_util")
  fashion_bags.previousBag = TableUtil.CopyTable(fashionbag_data:GetCurrentFashionBag())
end
function fashionbag_data:SetPlanSkin(insID)
  local bag = self:GetCurrentFashionBag()
  bag.fly_skin = tonumber(insID) or 0
end
function fashionbag_data:GetPlanSkin()
  local bag = self:GetCurrentFashionBag()
  return bag.fly_skin or 0
end
function fashionbag_data:SetWingmanSkin(insID)
  local bag = self:GetCurrentFashionBag()
  bag.wingman_skin = tonumber(insID) or 0
end
function fashionbag_data:GetWingmanSkin()
  local bag = self:GetCurrentFashionBag()
  return bag.wingman_skin or 0
end
function fashionbag_data:SetGliding(insID)
  local bag = self:GetCurrentFashionBag()
  bag.gliding = tonumber(insID) or 0
end
function fashionbag_data:GetGliding()
  local bag = self:GetCurrentFashionBag()
  return bag.gliding or 0
end
function fashionbag_data:SetAircraft(insID)
  local bag = self:GetCurrentFashionBag()
  bag.aircraft_put_id = tonumber(insID) or 0
end
function fashionbag_data:GetAircraftOrGliding()
  local bag = self:GetCurrentFashionBag()
  if bag.aircraft_put_id and bag.aircraft_put_id ~= 0 then
    return bag.aircraft_put_id
  end
  if bag.gliding and bag.gliding ~= 0 then
    return bag.gliding
  end
  return 0
end
function fashionbag_data:GetAircraft()
  local bag = self:GetCurrentFashionBag()
  return bag.aircraft_put_id or 0
end
function fashionbag_data:SetParachute(insID)
  local bag = self:GetCurrentFashionBag()
  bag.parachute = tonumber(insID) or 0
end
function fashionbag_data:GetParachute()
  local bag = self:GetCurrentFashionBag()
  return bag.parachute or 0
end
function fashionbag_data:SetParachuteWithBagIndex(BagIndex, InsID)
  local bag = self:GetFashionBag(BagIndex)
  bag.parachute = tonumber(InsID) or 0
end
function fashionbag_data:GetParachuteWithBagIndex(BagIndex)
  local bag = self:GetFashionBag(BagIndex)
  return bag.parachute or 0
end
function fashionbag_data:GetFashionBagStateByIndex(bag_index)
  local bag = self:GetFashionBag(bag_index)
  if bag then
    return bag.state or wardrobe_macro.enum_FashionBagState.Lock
  end
  return wardrobe_macro.enum_FashionBagState.Lock
end
function fashionbag_data:SetFashionBagStateByIndex(bag_index, state)
  local bag = self:GetFashionBag(bag_index)
  if not bag then
    fashion_bags.bags[bag_index] = GenDefaultBagStruct()
    bag = fashion_bags.bags[bag_index]
  end
  bag.end
function fashionbag_data:UpdateAllFashionBagRolewears(rolewears)
  for i, rolewear_list in pairs(rolewears) do
    local bag = fashion_bags.bags[i]
    if not bag then
      fashion_bags.bags[i] = GenDefaultBagStruct()
      bag = fashion_bags.bags[i]
    end
    local tempList = {}
    for _, item in pairs(rolewear_list) do
      if tonumber(item) and tonumber(item) ~= 0 then
        table.insert(tempList, item)
      end
    end
    bag.rolewear_list = tempList
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_COUNT)
end
function fashionbag_data:UpdateFashionBagRolewearByIndex(index, rolewear)
  if not index then
    return
  end
  rolewear = rolewear or {}
  local bag = fashion_bags.bags[index]
  if not bag then
    fashion_bags.bags[index] = GenDefaultBagStruct()
    bag = fashion_bags.bags[index]
  end
  local tempList = {}
  for _, item in pairs(rolewear) do
    if tonumber(item) and tonumber(item) ~= 0 then
      table.insert(tempList, item)
    end
  end
  bag.rolewear_list = tempList
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_COUNT)
end
function fashionbag_data:UpdateAllFashionBagStates(rolestates)
  for i, _ in pairs(fashion_bags.bags) do
    if rolestates[i] == nil then
      rolestates[i] = wardrobe_macro.enum_FashionBagState.Lock
    end
  end
  for i, state in pairs(rolestates) do
    local bag = fashion_bags.bags[i]
    if not bag then
      fashion_bags.bags[i] = GenDefaultBagStruct()
      bag = fashion_bags.bags[i]
    end
    bag.  end
end
local avatar_show_data = {}
function fashionbag_data:SetAvatarShowData(index, avatar_show)
  avatar_show_data[index] = avatar_show
end
function fashionbag_data:GetAvatarShowData(index)
  return avatar_show_data[index]
end
local originKnapsackExtInfo = {}
function fashionbag_data:SetAllKnapsackExtInfo(allKnapsackExtInfo)
  originKnapsackExtInfo = allKnapsackExtInfo or {}
end
function fashionbag_data:SetKnapsackExtInfoByIndex(index, knapsackExtInfo)
  if not index then
    return
  end
  originKnapsackExtInfo[index] = knapsackExtInfo
end
function fashionbag_data:GetAllKnapsackExtInfo()
  return originKnapsackExtInfo
end
function fashionbag_data:GetKnapsackExtInfoByIndex(index)
  if not index then
    return nil
  end
  return originKnapsackExtInfo[index]
end
function fashionbag_data:UpdateSharedBag(instidList, bIsOpened, times)
  instidList = instidList or {}
  local table_util = require("common.table_util")
  shared_bag.instIdList = table_util.CopyTable(instidList)
  if bIsOpened ~= nil then
    shared_bag.isOpened = bIsOpened
    shared_bag.  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHARED_BAG_REFRESH_VIEW)
end
function fashionbag_data:UpdateAllFashionBagExtraInfos(all_knapsack_ext_info)
  if not all_knapsack_ext_info then
    return
  end
  for i, extendBag in pairs(all_knapsack_ext_info) do
    local bag = fashion_bags.bags[i]
    if not bag then
      fashion_bags.bags[i] = GenDefaultBagStruct()
      bag = fashion_bags.bags[i]
    end
    bag.parachute = extendBag.parachute
    bag.gliding = extendBag.gliding or 0
    bag.aircraft_put_id = extendBag.aircraft_put_id or 0
    bag.bag_skin = extendBag.bag_skin or 0
    bag.bag_level = extendBag.bag_level or bag.helmet_level
    bag.bag_skin_list = extendBag.bag_skin_list or {}
    bag.helmet_skin = extendBag.helmet_skin or 0
    bag.helmet_level = extendBag.helmet_level or bag.helmet_level
    bag.helmet_skin_list = extendBag.helmet_skin_list or {}
    bag.depot_bind_relation = extendBag.depot_bind_relation or {}
    bag.fly_skin = extendBag.fly_skin
    bag.wingman_skin = extendBag.wingman_skin or bag.wingman_skin
    bag.weapon_skin_list = extendBag.weapon_list or bag.weapon_skin_list
    bag.throw_object_list = extendBag.throw_object_list or bag.throw_object_list
    bag.bag_pendants = extendBag.bag_pendants or bag.bag_pendants
    self:SetAvatarShowData(i, extendBag.avatar_show)
    self:SetHeadShow(extendBag.head_show, i)
  end
end
function fashionbag_data:UpdateFashionBagExtraInfoByIndex(index, knapsack_ext_info)
  if not index or not knapsack_ext_info then
    return
  end
  local bag = fashion_bags.bags[index]
  if not bag then
    fashion_bags.bags[index] = GenDefaultBagStruct()
    bag = fashion_bags.bags[index]
  end
  bag.parachute = knapsack_ext_info.parachute or 0
  bag.gliding = knapsack_ext_info.gliding or 0
  bag.aircraft_put_id = knapsack_ext_info.aircraft_put_id or 0
  bag.bag_skin = knapsack_ext_info.bag_skin or 0
  bag.bag_skin_list = knapsack_ext_info.bag_skin_list or {}
  bag.bag_level = knapsack_ext_info.bag_level or bag.helmet_level
  bag.helmet_skin = knapsack_ext_info.helmet_skin or 0
  bag.helmet_skin_list = knapsack_ext_info.helmet_skin_list or {}
  bag.helmet_level = knapsack_ext_info.helmet_level or bag.helmet_level
  bag.depot_bind_relation = knapsack_ext_info.depot_bind_relation or {}
  bag.fly_skin = knapsack_ext_info.fly_skin or 0
  bag.wingman_skin = knapsack_ext_info.wingman_skin or bag.wingman_skin
  bag.weapon_skin_list = knapsack_ext_info.weapon_list or bag.weapon_skin_list
  bag.throw_object_list = knapsack_ext_info.throw_object_list or bag.throw_object_list
  bag.bag_pendants = knapsack_ext_info.bag_pendants or bag.bag_pendants
  self:SetAvatarShowData(index, knapsack_ext_info.avatar_show)
  self:SetHeadShow(knapsack_ext_info.head_show, index)
end
function fashionbag_data:UpdateCurrentFashionBagWeaponSkin(weaponID, skinID)
  local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
  if logic_legend_weapon:IsLegendWeaponItem(weaponID) then
    return
  end
  local bag = self:GetCurrentFashionBag()
  local weapon_skin_list = bag.weapon_skin_list
  weapon_skin_list = weapon_skin_list or {}
  if not weapon_skin_list[weaponID] then
    weapon_skin_list[weaponID] = {}
  end
  weapon_skin_list[weaponID].skin_id = skinID
  bag.end
function fashionbag_data:OnSelectFashionBag(index)
  local TableUtil = require("common.table_util")
  AvatarData.SetRoleWear(TableUtil.CopyTable(self:GetRolewearByIndex(index)))
  local bag = self:GetFashionBag(index)
  DataMgr.equipmentSkinInsIDTable[504] = bag.bag_skin
  DataMgr.equipmentSkinInsIDTable[505] = bag.helmet_skin
  self:SetFashionBagUseIndex(index)
end
function fashionbag_data:SaveRolewearToFashionBag(index)
  local bag = fashion_bags.bags[index]
  if bag == nil then
    fashion_bags.bags[index] = GenDefaultBagStruct()
    bag = fashion_bags.bags[index]
  end
  local rolewear_list = {}
  local tRoleData = AvatarData.GetRoleWear()
  for _, v in pairs(tRoleData) do
    if tonumber(v) and tonumber(v) ~= 0 then
      table.insert(rolewear_list, v)
    end
  end
  bag.end
function fashionbag_data:IsFashionBagRolewearFitCharacter(character_id)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for bag_index, _ in pairs(fashion_bags.bags) do
    local rolewear = self:GetRolewearByIndex(bag_index)
    for _, instId in pairs(rolewear) do
      local data = wardrobe_data:GetHallDepotItemDataByInsID(instId)
      if data then
        local itemCfg = CDataTable.GetTableData("character_param_table", data.resID)
        if itemCfg and itemCfg.character_param ~= 0 and itemCfg.character_param ~= character_id then
          return false
        end
      end
    end
  end
  return true
end
function fashionbag_data:GetFashionBags()
  return fashion_bags
end
function fashionbag_data:UpdateParachute(putOnId)
  DataMgr.UpdateItemNewFlag(putOnId, self:GetParachute())
  self:SetParachute(putOnId)
end
function fashionbag_data:UpdatePlaneSkin(putOnId)
  DataMgr.UpdateItemNewFlag(putOnId, self:GetPlanSkin())
  self:SetPlanSkin(putOnId)
end
function fashionbag_data:UpdataWingmanSkin(putOnId)
  DataMgr.UpdateItemNewFlag(putOnId, self:GetWingmanSkin())
  self:SetWingmanSkin(putOnId)
end
function fashionbag_data:ClearAircraftOrGliding()
  DataMgr.UpdateEffect(0)
  self:SetGliding(0)
  self:SetAircraft(0)
end
function fashionbag_data:UpdateAircraftOrGliding(PutOnID, bAircraft)
  DataMgr.UpdateEffect(PutOnID)
  if bAircraft then
    self:SetAircraft(PutOnID)
    self:SetGliding(0)
  else
    self:SetGliding(PutOnID)
    self:SetAircraft(0)
  end
end
function fashionbag_data:SetBagSkin(skin)
  local bag = self:GetCurrentFashionBag()
  bag.bag_end
function fashionbag_data:GetBagSkin()
  local bag = self:GetCurrentFashionBag()
  return bag.bag_skin
end
function fashionbag_data:SetBagLevel(lv)
  local bag = self:GetCurrentFashionBag()
  bag.bag_level = lv or bag.bag_level
end
function fashionbag_data:GetBagLevel()
  local bag = self:GetCurrentFashionBag()
  return bag.bag_level or 3
end
function fashionbag_data:GetBagSkinByLevel(level)
  local bag = self:GetCurrentFashionBag()
  if bag.bag_skin_list then
    return bag.bag_skin_list[level] or 0
  end
  return 0
end
function fashionbag_data:SetBagSkinByLevel(skin, level)
  local bag = self:GetCurrentFashionBag()
  if not bag.bag_skin_list then
    bag.bag_skin_list = {}
  end
  bag.bag_skin_list[level] = skin
end
function fashionbag_data:SetHeadShow(instId, bagIndex)
  local bag = self:GetFashionBag(bagIndex or fashion_bags.use_index)
  bag.head_show = instId or 0
end
function fashionbag_data:GetHeadShow(bagIndex)
  local bag = self:GetFashionBag(bagIndex or fashion_bags.use_index)
  return bag.head_show
end
function fashionbag_data:SetHelmetSkin(skin)
  local bag = self:GetCurrentFashionBag()
  bag.helmet_end
function fashionbag_data:GetHelmetSkin()
  local bag = self:GetCurrentFashionBag()
  return bag.helmet_skin
end
function fashionbag_data:SetHelmetLevel(lv)
  local bag = self:GetCurrentFashionBag()
  bag.helmet_level = lv or bag.helmet_level
end
function fashionbag_data:GetHelmetLevel()
  local bag = self:GetCurrentFashionBag()
  return bag.helmet_level or 3
end
function fashionbag_data:GetHelmetSkinByLevel(level)
  local bag = self:GetCurrentFashionBag()
  if bag.helmet_skin_list then
    return bag.helmet_skin_list[level] or 0
  end
  return 0
end
function fashionbag_data:SetHelmetSkinByLevel(skin, level)
  local bag = self:GetCurrentFashionBag()
  if not bag.helmet_skin_list then
    bag.helmet_skin_list = {}
  end
  bag.helmet_skin_list[level] = skin
end
function fashionbag_data:GetDepotBindRelation(type)
  local bag = self:GetCurrentFashionBag()
  if bag.depot_bind_relation then
    return bag.depot_bind_relation[type]
  end
  return nil
end
function fashionbag_data:SetDepotBindRelation(type, op)
  local bag = self:GetCurrentFashionBag()
  if not bag.depot_bind_relation then
    bag.depot_bind_relation = {}
  end
  bag.depot_bind_relation[type] = op
end
function fashionbag_data:SetDepotBindRelationAll(depot_bind_relation)
  local bag = self:GetCurrentFashionBag()
  bag.end
function fashionbag_data:SetThrowObjectSkin(itemSubType, skin, index)
  local bag
  if not index then
    bag = self:GetCurrentFashionBag()
  else
    bag = self:GetFashionBag(index)
  end
  local throw_object_list = bag.throw_object_list
  throw_object_list[itemSubType] = tonumber(skin) or 0
  bag.end
function fashionbag_data:GetThrowObjectSkin(itemSubType, index)
  local bag
  if not index then
    bag = self:GetCurrentFashionBag()
  else
    bag = self:GetFashionBag(index)
  end
  return bag.throw_object_list[itemSubType] or 0
end
function fashionbag_data:PutOnThrowObjectSkin(putOnId, index)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(putOnId)
  if itemInfo ~= nil then
    if index == self.use_index then
      DataMgr.UpdateItemNewFlag(putOnId, self:GetThrowObjectSkin(itemInfo.itemSubType))
    end
    self:SetThrowObjectSkin(itemInfo.itemSubType, putOnId, index)
  end
end
function fashionbag_data:PutDownThrowObjectSkin(putDownId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(putDownId)
  if itemInfo ~= nil then
    DataMgr.UpdateItemNewFlag(0, putDownId)
    self:SetThrowObjectSkin(itemInfo.itemSubType, 0)
  end
end
function fashionbag_data:ProcessInvalidThrowObject()
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local bag = self:GetCurrentFashionBag()
  for _, v in pairs(bag.throw_object_list) do
    if v ~= 0 and not logic_wardrobe:IsWearValid(v, serverTime) then
      local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(v)
      if itemInfo ~= nil then
        self:SetThrowObjectSkin(itemInfo.itemSubType, 0)
      end
    end
  end
end
function fashionbag_data:IsThrowObjectWearing(skin)
  local bag = self:GetCurrentFashionBag()
  for _, v in pairs(bag.throw_object_list) do
    if v == skin then
      return true
    end
  end
  return false
end
function fashionbag_data:GetBagPendants()
  local bag = self:GetCurrentFashionBag()
  return bag.bag_pendants or {}
end
function fashionbag_data:GetPreBagPendants()
  local bag = self:GetPreFashionBag()
  return bag.bag_pendants or {}
end
function fashionbag_data:PutOnBagPendants(putOnInsId, putDownInsId)
  putDownInsId = tonumber(putDownInsId)
  if putDownInsId ~= 0 then
    self:SetBagPendants(putDownInsId, 0)
  end
  self:SetBagPendants(putOnInsId, 1)
end
function fashionbag_data:PutDownBagPendants(insId)
  self:SetBagPendants(insId, 0)
end
function fashionbag_data:SetBagPendants(insID, count)
  insID = tonumber(insID)
  local bag = self:GetCurrentFashionBag()
  local bag_pendants = bag.bag_pendants or {}
  bag_pendants[insID] = count ~= 0 and count or nil
  bag.end
function fashionbag_data:IsBagPendantWearing(insID)
  insID = tonumber(insID)
  local bag = self:GetCurrentFashionBag()
  local bag_pendants = bag.bag_pendants or {}
  if bag_pendants[insID] ~= nil and 0 < bag_pendants[insID] then
    return true
  end
  return false
end
function fashionbag_data:ClearBagPendants(insID)
  insID = tonumber(insID)
  local bag = self:GetCurrentFashionBag()
  if bag.bag_pendants then
    bag.bag_pendants[insID] = nil
  end
end
function fashionbag_data:ProcessInvalidBagPendants()
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local bag = self:GetCurrentFashionBag()
  for insId, _ in pairs(bag.bag_pendants) do
    if insId ~= 0 and not logic_wardrobe:IsWearValid(insId, serverTime) then
      local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(insId)
      if itemInfo ~= nil then
        self:ClearBagPendants(insId)
      end
    end
  end
end
return fashionbag_data