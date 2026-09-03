local VehicleFeatureBase = {}
function VehicleFeatureBase:ctor(_, InVehicle)
  self.OwnerVehicle = InVehicle
end
function VehicleFeatureBase:_PostConstruct()
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local FeatureClass = class(CDelegateContainer, nil, VehicleFeatureBase)
local MetaTable = getmetatable(FeatureClass)
function MetaTable.__newindex(t, k, v)
  rawset(t, k, v)
end
setmetatable(FeatureClass, MetaTable)
return FeatureClass