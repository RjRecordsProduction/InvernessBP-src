local BuildVehicleConfig = {
  BuildingId = 56,
  BuildingSkillId = 1000110,
  StorageSkillId = 1000111,
  DriverDistanceTLogIDHigh = 0,
  DriverDistanceTLogIDLow = 0,
  VehicleClass = "/Game/Arts_PlayerBluePrints/AircraftVehicle/BP_AircraftVehicleBase.BP_AircraftVehicleBase",
  CreateVehicleLocationOffset = FVector(0, 0, 350),
  SphereCheckRadius = 0,
  CheckDistance = 1500,
  CheckAngle = 0,
  CheckObjectTypes = {
    0,
    2,
    4
  },
  FanCheckObjectTypes = {4},
  bDebugShow = false,
  CheckActorNum = 1,
  CheckBlock = true,
  bUseMultiTargetCheck = false,
  NoFuelTips = 12112,
  AutoStorageHeight = 1500,
  AutoSpawnVehicleDistance = 150,
  AutoSpawnVehicleCapsuleH = 140,
  AutoSpawnVehicleCapsuleR = 140,
  OpenParachuteHeightInFlyVehicle = 999999999,
  FocusAudioPath = "/Game/Library/Res/Vehicles/Skate/WwiseEvent/Atlantis_Vehicle_Ray_330/Play_Atlantis_Ray_UI_Aim.Play_Atlantis_Ray_UI_Aim",
  BornAudioPath = "/Game/Library/Res/Vehicles/Skate/WwiseEvent/Atlantis_Vehicle_Ray_330/Play_Atlantis_Ray_Show.Play_Atlantis_Ray_Show",
  AIControllerPath = "/Game/Library/Res/Vehicles/Skate/Arts_PlayerBlueprints/AI/Skate_AIController.Skate_AIController",
  VehicleStopAutoIncreaseFuelTime = {
    Baltic_Main = 900,
    PUBG_Savage_Main = 600,
    FourMaps_Main = 600
  }
}
return BuildVehicleConfig