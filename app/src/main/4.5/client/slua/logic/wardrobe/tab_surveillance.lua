local SuperData = require("common.super_data")
local WardrobeUtils = require("client.slua.logic.wardrobe.wardrobe_utils")
local WardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local WardrobeDataManger = require("client.slua.logic.wardrobe.wardrobe_data")
local Avatar = WardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar
local tab_surveillance = {}
local EquipStates, delegateContainer
local GenerateWatchData = function()
  if EquipStates then
    return
  end
  local watchData = {}
  local tabConfig = WardrobeUtils.GetTabConfig()
  local subTabConfig = WardrobeUtils.GetSubTabConfig()
  for _, pageConfig in pairs(tabConfig) do
    local subTabs = subTabConfig[pageConfig.pageId].subTabs
    for _, subTabConfig in pairs(subTabs) do
      watchData[subTabConfig.subTabID] = {instanceID = 0, level = 0}
    end
  end
  EquipStates = SuperData.CreateSuperData(watchData)
end
local ClearBagWatch = function()
  if delegateContainer then
    delegateContainer:Dispose()
    delegateContainer = nil
  end
end
local UpdateEquipStates = function(insID)
  local item = WardrobeDataManger:GetHallDepotItemDataByInsID(insID)
  if item then
    local wardrobeSubTab = item.subTabType
    if wardrobeSubTab ~= WardrobeMacro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_FootEffect and EquipStates and EquipStates[wardrobeSubTab] then
      EquipStates[wardrobeSubTab].instanceID = tonumber(insID) or 0
    end
    return wardrobeSubTab
  end
end
local GetHandleFunc = function(fieldName, fieldValue)
  if fieldName == "state" or fieldName == "throw_object_list" or fieldName == "bag_pendants" then
    return nil
  end
  if type(fieldValue) == "table" then
    if fieldName == "rolewear_list" then
      return tab_surveillance.RoleWearChange
    elseif fieldName == "weapon_skin_list" then
      return tab_surveillance.WeaponChange
    end
  elseif fieldName == "helmet_level" or fieldName == "bag_level" then
    return tab_surveillance.LevelChange
  else
    return tab_surveillance.SingleValueChange
  end
end
local SubTabObserver = function()
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local fashionBag = fashionbag_data:GetFashionBags()
  fashionBag:AddListener("use_index", function(oldValue, value)
    tab_surveillance.SwitchBag(value)
  end)
end
function tab_surveillance.OnHallDepotDataInit(eventID, eventType, arrayItemData)
  if not arrayItemData then
    return
  end
  GenerateWatchData()
  SubTabObserver()
end
function tab_surveillance.GetTabEquip(subTabID)
  return EquipStates and EquipStates[subTabID]
end
function tab_surveillance.GetEquipStates(subTabID)
  return EquipStates and EquipStates[subTabID] and EquipStates[subTabID].instanceID
end
function tab_surveillance.SwitchBag(useIndex)
  ClearBagWatch()
  local delegate_container = require("common.delegate_container")
  delegateContainer = delegate_container()
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local fashionBag = fashionbag_data:GetFashionBag(useIndex)
  for fieldName, fieldValue in pairs(fashionBag) do
    local handleFunc = GetHandleFunc(fieldName, fieldValue)
    if handleFunc then
      delegateContainer:AddDataListener(fashionBag, fieldName, function(oldValue, value)
        handleFunc(value, fieldName)
      end)
    end
  end
end
function tab_surveillance.LevelChange(value, fieldName)
  if not EquipStates then
    return false
  end
  if fieldName == "helmet_level" then
    EquipStates[WardrobeMacro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_helmet].level = value
  elseif fieldName == "bag_level" then
    EquipStates[WardrobeMacro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_bag].level = value
  end
end
function tab_surveillance.SingleValueChange(value, fieldName)
  print(bWriteLog and "SubTabSurveillance : singleValue Changed", value, fieldName)
  if fieldName == "bag_skin" and tonumber(value) == 0 and EquipStates then
    EquipStates[WardrobeMacro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_bag].instanceID = 0
  elseif fieldName == "helmet_skin" and tonumber(value) == 0 and EquipStates then
    EquipStates[WardrobeMacro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_helmet].instanceID = 0
  else
    UpdateEquipStates(value)
  end
end
function tab_surveillance.RoleWearChange(value)
  print(bWriteLog and "SubTabSurveillance : roleWear", value)
  local currentEquippedSubTab = {}
  local AddToStates = function(insID)
    local wardrobeSubTab = UpdateEquipStates(insID)
    if wardrobeSubTab then
      currentEquippedSubTab[wardrobeSubTab] = true
    end
  end
  for _, insID in pairs(value) do
    AddToStates(insID)
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local bag = fashionbag_data:GetCurrentFashionBag()
  AddToStates(bag.bag_skin)
  AddToStates(bag.helmet_skin)
  if not EquipStates then
    return
  end
  local avatarTab = WardrobeUtils.GetSubTabConfigByPageID(Avatar)
  for _, tabConfig in pairs(avatarTab) do
    if not currentEquippedSubTab[tabConfig.subTabID] then
      EquipStates[tabConfig.subTabID].instanceID = 0
    end
  end
end
function tab_surveillance.WeaponChange(value)
  if not EquipStates then
    return
  end
  for weaponID, item in pairs(value) do
    if weaponID and EquipStates[weaponID] then
      if next(item) then
        if EquipStates[weaponID].instanceID == tonumber(item.skin_id) then
          EquipStates[weaponID].instanceID = 0
        end
        EquipStates[weaponID].instanceID = tonumber(item.skin_id)
      else
        EquipStates[weaponID].instanceID = 0
      end
    end
  end
end
function tab_surveillance.GetWardrobeTabByItemSubType(ItemSubType)
  local iters = CDataTable.GetTableByFilter("WardrobeVehiclesTaxonomy", "ItemSubType", ItemSubType)
  if iters then
    for _, v in pairs(iters) do
      if v.ItemSubType == ItemSubType then
        return v.WardrobeTab
      end
    end
  end
  return ""
end
function tab_surveillance.VehicleChange()
  print(bWriteLog and "SubTabSurveillance : vehicleChange")
  for itemSubType, insID in pairs(DataMgr.vehicleSkinInsIDTable) do
    local wardrobeTab = tab_surveillance.GetWardrobeTabByItemSubType(itemSubType)
    if wardrobeTab and EquipStates and EquipStates[wardrobeTab] then
      local nInsID = insID
      if nInsID then
        EquipStates[wardrobeTab].instanceID = nInsID
      else
        log(bWriteLog and string.format("tab_surveillance.VehicleChange: invalid insID %s", insID))
      end
    end
  end
end
function tab_surveillance.OnGameStateChange(eventType, eventID, gameState)
  if gameState.current == GameStatus.Login then
    ClearBagWatch()
    EquipStates = nil
  end
end
return tab_surveillance