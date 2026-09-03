local fashionbag_undo = {}
local UnWatchFieldNames = {
  state = true,
  bag_level = true,
  helmet_level = true
}
local UndoFuncMap = {}
local delegate_container = require("common.delegate_container")
local ArmorySystem = require("client.logic.armory.logic_armory")
local delegateContainer = delegate_container()
local savedBag = {}
local super_data = require("common.super_data")
local modifiedInfo = super_data.CreateSuperData({isModified = false})
local IsSameList = function(a, b)
  local dict = {}
  for _, v in pairs(b) do
    dict[v] = true
  end
  for _, v in pairs(a) do
    if not dict[v] then
      return false
    end
    dict[v] = nil
  end
  if next(dict) then
    return false
  end
  return true
end
local IsSameWeaponSkins = function(savedWeaponSkins, currentWeaponSkins)
  log_tree("IsSameWeaponSkins currentWeaponSkins:", currentWeaponSkins)
  log_tree("IsSameWeaponSkins savedWeaponSkins:", savedWeaponSkins)
  local dict = {}
  for weaponID, skinInfo in pairs(currentWeaponSkins) do
    if type(skinInfo) == "table" and skinInfo.skin_id then
      dict[weaponID] = skinInfo.skin_id
    end
  end
  for weaponID, skinInfo in pairs(savedWeaponSkins) do
    if dict[weaponID] ~= skinInfo.skin_id then
      return false
    end
    dict[weaponID] = nil
  end
  for _, skin_id in pairs(dict) do
    if skin_id ~= 0 then
      return false
    end
  end
  return true
end
local IsSameBagPendants = function(savedBagPendants, currentBagPendants)
  local dict = {}
  for insId, count in pairs(currentBagPendants) do
    dict[insId] = count
  end
  for insId, count in pairs(savedBagPendants) do
    if dict[insId] == nil or dict[insId] ~= count then
      return false
    end
    dict[insId] = nil
  end
  for _, count in pairs(dict) do
    if count ~= 0 then
      return false
    end
  end
  return true
end
local WatchBag = function(bagIndex)
  print(bWriteLog and "Watch Bag:", bagIndex)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local fashionBag = fashionbag_data:GetFashionBag(bagIndex)
  local isModifiedBits = 0
  local index = 0
  for fieldName, v in pairs(fashionBag) do
    if not UnWatchFieldNames[fieldName] then
      local valueType = type(v)
      local i = index
      delegateContainer:AddDataListener(fashionBag, fieldName, function(oldValue, value)
        print(bWriteLog and "fieldName Changed:", value)
        local isSame = true
        if fieldName == "weapon_skin_list" then
          isSame = IsSameWeaponSkins(savedBag[fieldName], value)
        elseif fieldName == "bag_pendants" then
          isSame = IsSameBagPendants(savedBag[fieldName], value)
        elseif valueType == "table" then
          isSame = IsSameList(savedBag[fieldName], value)
        else
          isSame = savedBag[fieldName] == value
        end
        isModifiedBits = isModifiedBits & ~(1 << i)
        if not isSame then
          isModifiedBits = isModifiedBits | 1 << i
        end
        modifiedInfo.isModified = isModifiedBits ~= 0
      end)
      index = index + 1
      assert(index < 64, "WatchBag index < 64")
    end
  end
end
local ClearWatch = function()
  delegateContainer:Dispose()
end
local Init = function()
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local fashionBags = fashionbag_data:GetFashionBags()
  fashionBags:AddListener("use_index", function(oldValue, value)
    if 0 < value then
      fashionbag_undo.OnOpenBag(value)
    end
  end)
end
function fashionbag_undo.OnOpenBag(bagIndex)
  ClearWatch()
  savedBag = {}
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local bag = fashionbag_data:GetFashionBag(bagIndex)
  for fieldName, v in pairs(bag) do
    if not UnWatchFieldNames[fieldName] then
      if type(v) == "table" then
        local TableUtil = require("common.table_util")
        savedBag[fieldName] = TableUtil.CopyTable(v)
      else
        savedBag[fieldName] = v
      end
    end
  end
  WatchBag(bagIndex)
end
function fashionbag_undo.Undo(bagIndex)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local bag = fashionbag_data:GetFashionBag(bagIndex)
  for fieldName, v in pairs(bag) do
    local undoFunc = UndoFuncMap[fieldName]
    if undoFunc then
      undoFunc(v, savedBag[fieldName])
    end
  end
end
function fashionbag_undo.GetModifiedInfo()
  return modifiedInfo
end
local RevertSkins = function(currentList, savedList)
  local savedMap = {}
  for _, insID in pairs(savedList) do
    savedMap[insID] = true
  end
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  for _, insID in pairs(currentList) do
    if not savedMap[insID] then
      WardRobeHandler.send_depot_put_down_req(tonumber(insID))
    end
    savedMap[insID] = nil
  end
  for insID, _ in pairs(savedMap) do
    WardRobeHandler.send_depot_put_on_req(insID)
  end
end
function UndoFuncMap.rolewear_list(currentWears, savedWears)
  RevertSkins(currentWears, savedWears)
end
local RevertInstance = function(currentIns, savedIns)
  if currentIns == savedIns then
    return
  end
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  if savedIns ~= 0 then
    WardRobeHandler.send_depot_put_on_req(savedIns)
  elseif currentIns ~= 0 then
    WardRobeHandler.send_depot_put_down_req(currentIns)
  end
end
function UndoFuncMap.parachute(currentIns, savedIns)
  RevertInstance(currentIns, savedIns)
end
function UndoFuncMap.bag_skin(currentIns, savedIns)
  RevertInstance(currentIns, savedIns)
end
function UndoFuncMap.helmet_skin(currentIns, savedIns)
  RevertInstance(currentIns, savedIns)
end
function UndoFuncMap.fly_skin(currentIns, savedIns)
  RevertInstance(currentIns, savedIns)
end
function UndoFuncMap.wingman_skin(currentIns, savedIns)
  RevertInstance(currentIns, savedIns)
end
function UndoFuncMap.weapon_skin_list(currentWeapons, savedWeapons)
  local savedMap = {}
  for weaponID, skinInfo in pairs(savedWeapons) do
    savedMap[weaponID] = skinInfo.skin_id
  end
  for weaponID, skinInfo in pairs(currentWeapons) do
    local savedWeaponSkin = savedMap[weaponID] or 0
    local currentWeaponSkin = skinInfo.skin_id or 0
    if currentWeaponSkin ~= 0 and savedWeaponSkin == 0 then
      ArmorySystem.uninstall_weapon_skin(ArmorySystem.ENUM_REQ_Wardrobe, weaponID)
      savedMap[weaponID] = nil
    end
  end
  for weaponID, skin_id in pairs(savedMap) do
    local currentWeaponSkin = currentWeapons[weaponID] and currentWeapons[weaponID].skin_id or 0
    if skin_id ~= 0 and skin_id ~= currentWeaponSkin then
      ArmorySystem.install_weapon_skin(ArmorySystem.ENUM_REQ_Wardrobe, weaponID, skin_id)
    end
  end
end
local RevertThrowObject = function(currentList, savedList)
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  for subType, insID in pairs(savedList) do
    if currentList[subType] ~= insID then
      if insID ~= 0 then
        WardRobeHandler.send_depot_put_on_req(insID)
      else
        WardRobeHandler.send_depot_put_down_req(currentList[subType])
      end
    end
  end
end
function UndoFuncMap.throw_object_list(currentThrowList, savedThrowList)
  RevertThrowObject(currentThrowList, savedThrowList)
end
local RevertBagPendants = function(currentBagPendants, savedBagPendants)
  local savedMap = {}
  for insID, count in pairs(savedBagPendants) do
    if 0 < count then
      savedMap[insID] = true
    end
  end
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  for insID, count in pairs(currentBagPendants) do
    if not savedMap[insID] and 0 < count then
      WardRobeHandler.send_depot_put_down_req(tonumber(insID))
    end
    savedMap[insID] = nil
  end
  for insID, _ in pairs(savedMap) do
    WardRobeHandler.send_depot_put_on_req(insID)
  end
end
function UndoFuncMap.bag_pendants(currentBagPendants, savedBagPendants)
  RevertBagPendants(currentBagPendants, savedBagPendants)
end
Init()
return fashionbag_undo