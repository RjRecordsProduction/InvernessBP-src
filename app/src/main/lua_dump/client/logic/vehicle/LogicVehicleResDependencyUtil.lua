local LogicVehicleResDependencyUtil = {
  VEHICLE_TYPE_TO_CONTAINER_ID_LIST = {
    [1] = {1990002, 1990003},
    [2] = {1990004, 1990005},
    [3] = {1990006, 1990007},
    [4] = {1990012, 1990013},
    [7] = {1990010, 1990011},
    [9] = {1990014, 1990015},
    [10] = {1990008, 1990009},
    [12] = {1990016, 1990017}
  }
}
function LogicVehicleResDependencyUtil:GetRelatedItemIDList(ItemID)
  local RelatedItemIDList = {}
  self:_AppendDeadBoxItemID(ItemID, RelatedItemIDList)
  self:_AppendContainerItemID(ItemID, RelatedItemIDList)
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
  if not VehicleEffectCfg then
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
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicVehicleResDependencyUtil = class(CModuleBase, nil, LogicVehicleResDependencyUtil)
return CLogicVehicleResDependencyUtil