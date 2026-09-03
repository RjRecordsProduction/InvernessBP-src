local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
local VehicleConfig = {}
VehicleConfig.ConfigMap = {
  [ESTExtraVehicleShapeType.VST_Snowboard] = "GameLua.Mod.Library.GamePlay.Vehicle.Snowborad.SnowboradConfig",
  [ESTExtraVehicleShapeType.VST_BigFoot] = "GameLua.Mod.Library.GamePlay.Vehicle.BigFoot.BigFootConfig",
  [ESTExtraVehicleShapeType.VST_Fighter] = "GameLua.Mod.Library.GamePlay.Vehicle.Fighter.FighterConfig",
  [ESTExtraVehicleShapeType.VST_AmphibiousBoat] = "GameLua.Mod.Library.GamePlay.Vehicle.AmphibiousBoat.AmphibiousBoatConfig",
  [ESTExtraVehicleShapeType.VST_Horse] = "GameLua.Mod.Library.GamePlay.Vehicle.Horse.HorseConfig",
  [ESTExtraVehicleShapeType.VST_WarHorse] = "GameLua.Mod.Library.GamePlay.Vehicle.Horse.HorseConfig",
  [ESTExtraVehicleShapeType.VST_HorseLiquid] = "GameLua.Mod.Library.GamePlay.Vehicle.Horse.HorseConfig",
  [ESTExtraVehicleShapeType.VST_TigerVehicle] = "GameLua.Mod.Library.GamePlay.Vehicle.Tiger.TigerConfig",
  [ESTExtraVehicleShapeType.VST_MammothVehicle] = "GameLua.Mod.Library.GamePlay.Vehicle.Mammoth.MammothConfig",
  [ESTExtraVehicleShapeType.VST_Panda] = "GameLua.Mod.Library.GamePlay.Vehicle.Panda.PandaConfig",
  [ESTExtraVehicleShapeType.VST_PandaBall] = "GameLua.Mod.Library.GamePlay.Vehicle.Panda.PandaBallConfig",
  [ESTExtraVehicleShapeType.VST_Camel] = "GameLua.Mod.Library.GamePlay.Vehicle.Camel.CamelVehicleConfig",
  [ESTExtraVehicleShapeType.VST_PicoBus] = "GameLua.Mod.Library.GamePlay.Vehicle.PicoBus.PicoBusConfig",
  [ESTExtraVehicleShapeType.VST_Blanc] = "GameLua.Mod.Library.GamePlay.Vehicle.Blanc.BlancConfig",
  [ESTExtraVehicleShapeType.VST_Titan] = "GameLua.Mod.Library.GamePlay.Vehicle.Titan.TitanConfig",
  [ESTExtraVehicleShapeType.VST_Optimus] = "GameLua.Mod.Library.GamePlay.Vehicle.Transformer.Config.TFOptimusConfig",
  [ESTExtraVehicleShapeType.VST_OptimusVehicle] = "GameLua.Mod.Library.GamePlay.Vehicle.Transformer.Config.TFOptimusVehicleConfig",
  [ESTExtraVehicleShapeType.VST_Megatron] = "GameLua.Mod.Library.GamePlay.Vehicle.Transformer.Config.TFMegatronConfig",
  [ESTExtraVehicleShapeType.VST_MegatronVehicle] = "GameLua.Mod.Library.GamePlay.Vehicle.Transformer.Config.TFMegatronVehicleConfig",
  [ESTExtraVehicleShapeType.VST_Broom] = "GameLua.Mod.Library.GamePlay.Vehicle.Broom.BroomConfig",
  [ESTExtraVehicleShapeType.VST_PenguinCart] = "GameLua.Mod.Library.GamePlay.Vehicle.PenguinCart.Config.PenguinCartConfig",
  [ESTExtraVehicleShapeType.VST_LootTruck] = "GameLua.Mod.Library.GamePlay.Vehicle.LootTruck.LootTruckConfig",
  [ESTExtraVehicleShapeType.VST_Buggy_0] = "GameLua.Mod.Library.GamePlay.Vehicle.Buggy.BuggyConfig",
  [ESTExtraVehicleShapeType.VST_Deer] = "GameLua.Mod.Library.GamePlay.Vehicle.Deer.Config.DeerConfig",
  [ESTExtraVehicleShapeType.VST_Scorpion] = "GameLua.Mod.Library.GamePlay.Vehicle.Scorpion.ScorpionConfig",
  [ESTExtraVehicleShapeType.VST_MTLB] = "GameLua.Mod.Library.GamePlay.Vehicle.MTLB.MTLBConfig",
  [ESTExtraVehicleShapeType.VST_CustomVehicle1] = "GameLua.Mod.Library.GamePlay.Vehicle.Roadster.RoadsterConfig",
  TeamModes = {
    [1] = "GameLua.Mod.Library.Gameplay.Vehicle.Config.TeamMode.TeamMode1.VehicleConfig",
    [2] = "GameLua.Mod.Library.Gameplay.Vehicle.Config.TeamMode.TeamMode2.VehicleConfig",
    [4] = "GameLua.Mod.Library.Gameplay.Vehicle.Config.TeamMode.TeamMode4.VehicleConfig"
  },
  Maps = {
    Baltic = "GameLua.Mod.Library.Gameplay.Vehicle.Config.Map.Baltic.VehicleConfig",
    Livik = "GameLua.Mod.Library.Gameplay.Vehicle.Config.Map.Livik.VehicleConfig",
    Savage = "GameLua.Mod.Library.Gameplay.Vehicle.Config.Map.Savage.VehicleConfig",
    Desert = "GameLua.Mod.Library.Gameplay.Vehicle.Config.Map.Desert.VehicleConfig",
    Neon = "GameLua.Mod.Neon.Gameplay.Module.Vehicle.VehicleConfig"
  },
  default = {
    STExtraVehicleBase = "GameLua.Mod.Library.Gameplay.Vehicle.Config.VehicleBaseConfig",
    STExtraWheeledVehicle = "GameLua.Mod.Library.Gameplay.Vehicle.Config.WheeledVehicleConfig",
    STExtraFloatingVehicle = "GameLua.Mod.Library.Gameplay.Vehicle.Config.FloatingVehicleConfig",
    STExtraHelicopterVehicle = "GameLua.Mod.Library.Gameplay.Vehicle.Config.HelicopterConfig",
    STExtraUAVVehicleBase = "GameLua.Mod.Library.Gameplay.Vehicle.Config.VehicleUAVBaseConfig",
    VehicleBike = "GameLua.Mod.Library.Gameplay.Vehicle.Config.VehicleBikeConfig",
    BioVehicleBase = "GameLua.Mod.Library.Gameplay.Vehicle.Config.BioVehicleBaseConfig",
    MechaVehicle = "GameLua.Mod.Library.Gameplay.Vehicle.Config.MechaVehicleConfig",
    HoveringMecha = "GameLua.Mod.Library.Gameplay.Vehicle.HoveringMecha.HoveringMechaConfig",
    VehicleAircraft = "GameLua.Mod.Library.Gameplay.Vehicle.Config.AircraftConfig"
  }
}
return VehicleConfig