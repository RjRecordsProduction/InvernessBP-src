local ReddotVehicle = {
  SubSysID = {
    GetReward = 1,
    NewFeatureItem = 2,
    NewPlateBG = 3,
    VehicleCollect = 4,
    FeatureUnlock = 5,
    SpecialEffect = 6
  }
}
local ReddotType = ReddotVehicle.SubSysID
local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
local systemName = reddot_macro.SystemName.Vehicle
function ReddotVehicle:GetData()
  local data = {
    desc = systemName,
    newCount = 0,
    [ReddotType.VehicleCollect] = {
      newCount = 0,
      subID = ReddotVehicle.SubSysID.VehicleCollect,
      category = reddot_macro.Category.Receive,
      [ReddotType.GetReward] = {
        newCount = 0,
        subID = ReddotVehicle.SubSysID.GetReward,
        category = reddot_macro.Category.Receive,
        instances = {_isLeaf = true}
      },
      [ReddotType.NewPlateBG] = {
        newCount = 0,
        subID = ReddotType.NewPlateBG,
        category = reddot_macro.Category.NewArrivals,
        instances = {_isLeaf = true}
      }
    },
    [ReddotType.NewFeatureItem] = {
      newCount = 0,
      subID = ReddotType.NewFeatureItem,
      category = reddot_macro.Category.NewArrivals,
      instances = {_isLeaf = true}
    },
    [ReddotType.FeatureUnlock] = {
      newCount = 0,
      subID = ReddotType.FeatureUnlock,
      category = reddot_macro.Category.NewArrivals,
      instances = {_isLeaf = true}
    },
    [ReddotType.SpecialEffect] = {newCount = 0, isDynamic = true}
  }
  return data
end
return ReddotVehicle