local AttributeModifierFeature = {}
function AttributeModifierFeature:ctor(_, InVehicle)
  AttributeModifierFeature.__super.ctor(self, _, InVehicle)
  self.ComponentName = nil
  self.Attributes = {}
end
local function ModifyTableItem(Table, Key, Value)
  if not Table or Table[Key] == nil then
    return
  end
  if type(Value) == "table" then
    for SubKey, SubValue in pairs(Value) do
      ModifyTableItem(Table[Key], SubKey, SubValue)
    end
  else
    Table[Key] = Value
  end
end
local ModifyAttribute = function(Object, Attributes)
  if not slua.isValid(Object) then
    return
  end
  for AttributeName, AttributeValue in pairs(Attributes) do
    if Object[AttributeName] then
      if AttributeValue.Value then
        if type(AttributeValue.Value) == "table" then
          ModifyTableItem(Object, AttributeName, AttributeValue.Value)
        else
          Object[AttributeName] = AttributeValue.Value
          print(bWriteLog and string.format("AttributeModifierFeature: Object: %s, AttributeName: %s, Value: %s", Object, AttributeName, AttributeValue.Value))
        end
      end
      if AttributeValue.Factor then
        Object[AttributeName] = Object[AttributeName] * AttributeValue.Factor
        print(bWriteLog and string.format("AttributeModifierFeature: Object: %s, AttributeName: %s, Factor: %s, Value: %s", Object, AttributeName, AttributeValue.Factor, Object[AttributeName]))
      end
    end
  end
end
function AttributeModifierFeature:_PostConstruct()
  AttributeModifierFeature.__super._PostConstruct(self)
  if not slua.isValid(self.OwnerVehicle) then
    return
  end
  if self.ComponentName then
    ModifyAttribute(self.OwnerVehicle[self.ComponentName], self.Attributes)
  else
    ModifyAttribute(self.OwnerVehicle, self.Attributes)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.GameCore.Module.Vehicle.VehicleFeatures.VehicleFeatureBase")
return class(CFeatureBase, nil, AttributeModifierFeature)