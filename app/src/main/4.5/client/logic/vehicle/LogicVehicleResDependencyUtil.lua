local LogicVehicleResDependencyUtil = {
  VEHICLE_TYPE_TO_CONTAINER_ID_LIST = {
    [1] = {1990002, 1990003},
    [2] = {1990004, 1990005},
    [3] = {1990006, 1990007},
    [4] = {1990012, 1990013},
    [7] = {1990010, 1990011},
    [9] = {1990014, 1990015},
    [10] = {1990008, 1990009},
    [12] = {1990016, 1990017},
    [13] = {1990018, 1990019},
    [14] = {1990020, 1990021},
    [15] = {1990022, 1990023}
  }
}
function LogicVehicleResDependencyUtil:GetRelatedItemIDList(ItemID)
  local RelatedItemIDList = {}
  self:_AppendDeadBoxItemID(ItemID, RelatedItemIDList)
  self:_AppendContainerItemID(ItemID, RelatedItemIDList)
  self:_AppendVehiclePartsItemID(ItemID, RelatedItemIDList)
  log_tree("LogicVehicleResDependencyUtil GetRelatedItemIDList RelatedItemList", RelatedItemIDList)
  return RelatedItemIDList
end
function LogicVehicleResDependencyUtil:GetVehicleParachutePropertyBPPath(ItemID)
  if not ItemID then
    return nil
  end
  local VehicleEffectCfg = CDataTable.GetTableData("BetterVehicleEffect", ItemID)
  if not VehicleEffectCfg then
    return nil
  end
  return VehicleEffectCfg.PropertyForParachute
end
function LogicVehicleResDependencyUtil:_AppendDeadBoxItemID(ItemID, ResultList)
  if not ItemID or not ResultList then
    return
  end
  local CollectCarKillBoxCfg = CDataTable.GetTableData("CollectCarKillBox", ItemID)
  if not CollectCarKillBoxCfg then
    return nil
  end
  table.insert(ResultList, ItemID)
  table.insert(ResultList, CollectCarKillBoxCfg.DiedBoxLobbyID)
  table.insert(ResultList, CollectCarKillBoxCfg.DiedBoxBattleID)
end
function LogicVehicleResDependencyUtil:_AppendContainerItemID(ItemID, ResultList)
  if not ItemID or not ResultList then
    return
  end
  local VehicleEffectCfg = CDataTable.GetTableData("BetterVehicleEffect", ItemID)
  if not VehicleEffectCfg or VehicleEffectCfg.BornFall == 0 then
    return
  end
  local ContainerIDList = LogicVehicleResDependencyUtil.VEHICLE_TYPE_TO_CONTAINER_ID_LIST[VehicleEffectCfg.VehicleType]
  if not ContainerIDList or not next(ContainerIDList) then
    return
  end
  for _, ContainerID in pairs(ContainerIDList) do
    table.insert(ResultList, ContainerID)
  end
end
function LogicVehicleResDependencyUtil:_AppendVehiclePartsItemID(ItemID, ResultList)
  if not ItemID or not ResultList then
    return
  end
  local SportCarDefaultSetCfg = CDataTable.GetTableData("SportCarDefaultSet", ItemID)
  if not (SportCarDefaultSetCfg and SportCarDefaultSetCfg.SetIDList) or SportCarDefaultSetCfg.SetIDList == "" then
    return
  end
  local StringUtil = require("common.string_util")
  local DefaultItems = StringUtil.Split(SportCarDefaultSetCfg.SetIDList, "|")
  for _, ItemIdStr in ipairs(DefaultItems) do
    local PartItemID = tonumber(ItemIdStr)
    if PartItemID and PartItemID ~= 0 then
      table.insert(ResultList, PartItemID)
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicVehicleResDependencyUtil = class(CModuleBase, nil, LogicVehicleResDependencyUtil)
return CLogicVehicleResDependencyUtil