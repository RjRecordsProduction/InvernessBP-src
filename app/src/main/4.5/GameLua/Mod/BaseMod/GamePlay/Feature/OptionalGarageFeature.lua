local OptionalGarageFeature = {
  ServerRPC = {
    ServerRPC_ChooseVehicle = {
      Params = {
        import("/Script/Engine.Actor"),
        UEnums.EPropertyClass.Int
      },
      Reliable = true
    }
  }
}
function OptionalGarageFeature:ServerRPC_ChooseVehicle(OptionalGarageActor, nVehicleItemID)
  if Client then
    return
  end
  print(bWriteLog and "OptionalGarageFeature:ServerRPC_ChooseVehicle " .. nVehicleItemID)
  if slua.isValid(OptionalGarageActor) and OptionalGarageActor.ServerChooseVehicle then
    OptionalGarageActor:ServerChooseVehicle(self.Owner.Object, nVehicleItemID)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, OptionalGarageFeature)