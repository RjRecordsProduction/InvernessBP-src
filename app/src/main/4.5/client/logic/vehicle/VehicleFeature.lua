local VehicleFeature = {}
local Enum_Equipment_OpType = {Install = 0, Unload = 1}
function VehicleFeature:DefineAndResetData()
  self.currentFeature = {}
  self.currentInstallFeature = {}
end
function VehicleFeature:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Lobby then
    self.currentFeature = {}
    self.currentInstallFeature = {}
    local VehicleAccessoryHandler = require("client.network.Protocol.VehicleAccessoryHandler")
    VehicleAccessoryHandler.send_get_sports_car_feature_req()
  end
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self.currentFeature = {}
    self.currentInstallFeature = {}
  end
end
function VehicleFeature:OnVehicleFeatureResponse(ret_list, install_list)
  self.currentFeature = ret_list or {}
  self.currentInstallFeature = install_list or {}
  local needRed = {}
  local data = self:GetLocalVehicleUnloadFeaturesRedData()
  local changed = false
  for id, v in pairs(self.currentFeature) do
    if not data[id] then
      needRed[id] = 1
      data[id] = 1
      changed = true
    end
  end
  self:SaveLocalVehicleUnloadFeaturesRedData(data, changed)
  self:SetRedDot(needRed)
end
function VehicleFeature:AddVehicleFeatureResponse(add_list)
  if not add_list then
    return
  end
  local needRed = {}
  local data = self:GetLocalVehicleUnloadFeaturesRedData()
  for ifeature_item_id, v in pairs(add_list) do
    self.currentFeature[ifeature_item_id] = 1
    data[ifeature_item_id] = 1
    needRed[ifeature_item_id] = 1
  end
  self:SaveLocalVehicleUnloadFeaturesRedData(data, true)
  self:SetRedDot(needRed)
end
function VehicleFeature:InstallFeatureResponse(feature_id, op_type)
  if not feature_id then
    return
  end
  if op_type == Enum_Equipment_OpType.Install then
    self.currentInstallFeature[feature_id] = 1
  elseif op_type == Enum_Equipment_OpType.Unload then
    self.currentInstallFeature[feature_id] = nil
  end
end
local sortItem = function(a, b)
  if a.unlock == b.unlock then
    local ac = a.config
    local bc = b.config
    if ac.SortPriority == bc.SortPriority then
      return ac.ItemID > bc.ItemID
    else
      return ac.SortPriority > bc.SortPriority
    end
  else
    return a.unlock
  end
end
function VehicleFeature:GetSpecialEffectCfgList()
  local FeatureList = {}
  local FeatureUnlockCfg = CDataTable.GetTable("SpecialEffectCfg")
  if not FeatureUnlockCfg then
    return {}
  end
  for _, cfg in pairs(FeatureUnlockCfg) do
    local sub = cfg.SubTab
    if not FeatureList[sub] then
      FeatureList[sub] = {}
    end
    table.insert(FeatureList[sub], {
      unlock = self.currentFeature[cfg.ItemID] ~= nil,
      config = cfg
    })
  end
  for _, v in ipairs(FeatureList) do
    table.sort(v, sortItem)
  end
  return FeatureList
end
function VehicleFeature:GetPreviewVideoPath(itemID)
  local config = CDataTable.GetTableData("SpecialEffectCfg", itemID)
  if not config then
    return nil
  end
  return config.PreviewVideoPath
end
function VehicleFeature:IsUnlockFeature(itemID)
  if self.currentFeature and self.currentFeature[itemID] then
    return true
  end
  return false
end
function VehicleFeature:IsInstallFeature(itemID)
  if self.currentInstallFeature and self.currentInstallFeature[itemID] then
    return true
  end
  return false
end
function VehicleFeature:InstallFeatures(itemID)
  local VehicleAccessoryHandler = require("client.network.Protocol.VehicleAccessoryHandler")
  VehicleAccessoryHandler.send_car_feature_op_req(itemID, Enum_Equipment_OpType.Install)
end
function VehicleFeature:UnloadFeatures(itemID)
  local VehicleAccessoryHandler = require("client.network.Protocol.VehicleAccessoryHandler")
  VehicleAccessoryHandler.send_car_feature_op_req(itemID, Enum_Equipment_OpType.Unload)
end
function VehicleFeature:GetLocalVehicleUnloadFeaturesRedData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local temp = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eVehicleUnlockFeatureRedDot)
  return temp or {}
end
function VehicleFeature:SaveLocalVehicleUnloadFeaturesRedData(data, changed)
  if not data then
    return
  end
  if not changed then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(data or {}, PlayerPrefsSystem.ePlayerPrefsType.eVehicleUnlockFeatureRedDot)
end
function VehicleFeature:SetRedDot(red)
  if not red or not next(red) then
    return
  end
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local generalLabReddotData = require("client.slua.logic.lobby.lab.general_lab_reddot_data")
  local reddotVehicle = require("client.slua.logic.vehicle.reddot_vehicle")
  local gropData = generalLabReddotData.GetReddotData(reddot_macro.SystemName.Vehicle)
  local SpecialEffectCfg = CDataTable.GetTable("SpecialEffectCfg")
  SpecialEffectCfg = SpecialEffectCfg or {}
  for id, v in pairs(red) do
    if SpecialEffectCfg[id] and gropData and gropData[reddotVehicle.SubSysID.SpecialEffect] then
      local temp = gropData[reddotVehicle.SubSysID.SpecialEffect]
      local subTab = SpecialEffectCfg[id].SubTab
      if subTab and 0 < subTab then
        if not temp[subTab] then
          temp[subTab] = {
            newCount = 0,
            category = reddot_macro.Category.NewArrivals,
            subID = reddotVehicle.SubSysID.SpecialEffect,
            instances = {_isLeaf = true}
          }
        end
        temp[subTab].instances[id] = true
      end
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, VehicleFeature)
return CModuleTemplate