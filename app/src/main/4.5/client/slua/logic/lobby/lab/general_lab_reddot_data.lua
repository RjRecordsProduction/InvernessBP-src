local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
local general_lab_reddot_data = {}
general_lab_reddot_data.countFieldName = "newCount"
general_lab_reddot_data.ENUM_LAB_SYSTEMS = {
  research = "research",
  Companions = "Companions",
  Vehicle = "Vehicle"
}
general_lab_reddot_data.ENUM_LAB_REDDOT_CATERGORY = reddot_macro.Category
general_lab_reddot_data.ENUM_LAB_ANCHORS = {
  Weapon_DIY = "Reddot_Anchor_GunDiy",
  Character = "Reddot_Anchor_Char",
  research = "Reddot_Anchor_Research",
  Companions = "Reddot_Anchor_Pet",
  Golden_Suit = "Reddot_Anchor_Clothes",
  Vehicle = "Reddot_Anchor_Car"
}
local groupName = "WorkShop"
local groupData
local isInited = false
local superReddotData = {}
local LoginModule = {
  "client.slua.logic.pet.reddot_pet"
}
local GenerateDefaultSystemData = function(system)
  local data = {
    desc = reddot_macro.SystemName[system],
    newCount = 0
  }
  return data
end
local CharacterInitFunc = function(data)
  general_lab_reddot_data.AddNode(data, "reddots", general_lab_reddot_data.GenerateNodeData(general_lab_reddot_data.ENUM_LAB_REDDOT_CATERGORY.NewArrivals, 2))
  return data
end
local WeaponDIYInitFunc = function(data)
  general_lab_reddot_data.AddNode(data, "reddots", general_lab_reddot_data.GenerateNodeData(general_lab_reddot_data.ENUM_LAB_REDDOT_CATERGORY.NewArrivals, 2))
  return data
end
local ResearchInitFunc = function(data)
  local ResearchRedDot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ResearchRedDot)
  return ResearchRedDot:GetData()
end
local PetInitFunc = function(data)
  local reddotPet = require("client.slua.logic.pet.reddot_pet")
  return reddotPet:GetData()
end
local VehicleInitFunc = function()
  local reddotVehicle = require("client.slua.logic.vehicle.reddot_vehicle")
  return reddotVehicle.GetData()
end
local LabSystemInitFunc = setmetatable({
  Weapon_DIY = WeaponDIYInitFunc,
  Character = CharacterInitFunc,
  research = ResearchInitFunc,
  Companions = PetInitFunc,
  Vehicle = VehicleInitFunc
}, {
  __call = function(t, system, ...)
    local data = GenerateDefaultSystemData(system)
    if t[system] ~= nil then
      return t[system](data, ...)
    else
      return data
    end
  end
})
function general_lab_reddot_data.GenerateNodeData(isDynamic, category, subID)
  local node = {
    newCount = 0,
    category = category or general_lab_reddot_data.ENUM_LAB_REDDOT_CATERGORY.Other,
      }
  node.instances = {_isLeaf = true}
  return node
end
function general_lab_reddot_data.AddNode(parentNode, nodeName, nodeData)
  if parentNode == nil then
    return
  end
  nodeData = nodeData or general_lab_reddot_data.GenerateNodeData(false)
  nodeData.subID = nodeData.subID or parentNode.subID
  local isRoot = parentNode.desc ~= nil
  if isRoot then
    parentNode[nodeName] = nodeData
  else
    parentNode[nodeName] = not isRoot and parentNode.isDynamic and nodeData or nil
  end
end
function general_lab_reddot_data.AddReddot(node, instanceId, category)
  if node == nil then
    node = general_lab_reddot_data.GenerateNodeData(category)
  end
  if node == nil or node.isDynamic then
    return
  end
  node.instances = node.instances or {_isLeaf = true}
  node.instances[instanceId] = true
  node.category = category or node.category
end
function general_lab_reddot_data.RemoveReddot(node, instanceID)
  if node == nil or node.isDynamic then
    return
  end
  node.instances = node.instances or {_isLeaf = true}
  node.instances[instanceID] = nil
end
function general_lab_reddot_data.ReduceReddotNum()
  local gropData = general_lab_reddot_data.GetReddotData(reddot_macro.SystemName.Vehicle)
  local reddotVehicle = require("client.slua.logic.vehicle.reddot_vehicle")
  local index = reddotVehicle.SubSysID.GetReward
  if not (gropData and gropData[reddotVehicle.SubSysID.VehicleCollect]) or not gropData[reddotVehicle.SubSysID.VehicleCollect][index] then
    log(bWriteLog and "general_lab_reddot_data.ReduceReddotNum invalid data")
    return
  end
  local data = gropData[reddotVehicle.SubSysID.VehicleCollect][index]
  data.newCount = data.newCount - 1
  log(bWriteLog and "general_lab_reddot_data.ReduceReddotNum data.newCount = " .. tostring(data.newCount))
  EventSystem:postEvent(EVENTID_LOBBY_MAIN_REDDOT, EVENTID_LOBBY_MAIN_REDDOT_UPDATE, BP_ENUM_MODULE_WorkShop)
end
function general_lab_reddot_data.ClearNode(node)
  if type(node) ~= "table" then
    return
  end
  if node._isLeaf == true then
    for k, v in pairs(node) do
      node[k] = nil
    end
    return
  end
  for k, v in pairs(node) do
    general_lab_reddot_data.ClearNode(v)
  end
end
function general_lab_reddot_data.ClearAllReddot(system)
  local node = general_lab_reddot_data.GetReddotData(system)
  general_lab_reddot_data.ClearNode(node)
end
function general_lab_reddot_data.GetReddotData(system)
  if not isInited then
    general_lab_reddot_data.InitData()
  end
  return superReddotData[system]
end
function general_lab_reddot_data.InitData()
  if isInited then
    return
  end
  superReddotData = {}
  local super_data = require("common.super_data")
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  isInited = true
  local reddot_group = require("client.slua.logic.reddot.reddot_group")
  groupData = reddot_group:AddGroup(groupName)
  for k, v in pairs(general_lab_reddot_data.ENUM_LAB_SYSTEMS) do
    local data = LabSystemInitFunc(k)
    superReddotData[k] = super_data.CreateSuperData(data)
    reddot_manager:Regist(superReddotData[k])
    reddot_group:AddToGroup(superReddotData[k], groupName)
    log(bWriteLog and "[HZA]Init Lab Reddot Data")
  end
end
function general_lab_reddot_data.GetGropData()
  return groupData
end
function general_lab_reddot_data.GetData(systemName)
  if not isInited or systemName == nil then
    return superReddotData
  else
    return superReddotData[systemName]
  end
end
function general_lab_reddot_data.DestroyData()
  superReddotData = nil
  isInited = false
  groupData = nil
end
function general_lab_reddot_data.OnLogin()
  general_lab_reddot_data.InitData()
  for k, v in ipairs(LoginModule) do
    local module = require(v)
    module:OnLogin()
  end
  EventSystem:postEvent(EVENTID_LOBBY_MAIN_REDDOT, EVENTID_LOBBY_MAIN_REDDOT_UPDATE, BP_ENUM_MODULE_WorkShop)
end
function general_lab_reddot_data.OnLogout()
  general_lab_reddot_data.DestroyData()
  for k, v in pairs(LoginModule) do
    local module = require(v)
    module:OnLogout()
  end
end
return general_lab_reddot_data