local UESTExtraVehicleType = import("ESTExtraVehicleType")
local SilentCommunicationConfig = {
  Condition = {
    bDeepOverwrite = true,
    [1] = {
      Priority = 2,
      MaxTimes = 99,
      MsgID = {
        [1] = 30029
      }
    },
    [3] = {
      Priority = 6,
      Value = 0.2,
      MaxTimes = 1,
      MsgID = {
        [1] = 33928
      }
    },
    [4] = {
      Priority = 4,
      Value = 0.2,
      MaxTimes = 1,
      MsgID = {
        [1] = 33924
      }
    },
    [6] = {Priority = 1, MaxTimes = 99}
  },
  CDTime = 2,
  ForbidVehicleType = {
    [UESTExtraVehicleType.VT_RaptorDinosaur] = true,
    [UESTExtraVehicleType.VT_Pterosaur] = true,
    [UESTExtraVehicleType.VT_TyrannosaurusRex] = true,
    [UESTExtraVehicleType.VT_UAVDeer] = true,
    [UESTExtraVehicleType.VT_Titan] = true,
    [UESTExtraVehicleType.VT_Optimus] = true,
    [UESTExtraVehicleType.VT_OptimusVehicle] = true,
    [UESTExtraVehicleType.VT_Megatron] = true,
    [UESTExtraVehicleType.VT_MegatronVehicle] = true,
    [UESTExtraVehicleType.VT_UAVVine] = true,
    [UESTExtraVehicleType.VT_Scorpion] = true
  }
}
return SilentCommunicationConfig