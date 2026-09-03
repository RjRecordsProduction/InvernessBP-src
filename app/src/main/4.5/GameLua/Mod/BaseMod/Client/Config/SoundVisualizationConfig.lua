local UESTExtraVehicleType = import("ESTExtraVehicleType")
local SoundVisualizationConfig = {
  SpecialVehiclVoiceIcon = {
    [UESTExtraVehicleType.VT_RaptorDinosaur] = {
      MapIcon = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_Velociraptors_Island_png.ZD_Icon_Velociraptors_Island_png",
      MainIcon = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/SoundVisualization_Icon_Velociraptors_png.SoundVisualization_Icon_Velociraptors_png"
    },
    [UESTExtraVehicleType.VT_Pterosaur] = {
      MapIcon = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_Pterosaur_Island_png.ZD_Icon_Pterosaur_Island_png",
      MainIcon = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/SoundVisualization_Icon_Pterosaur_png.SoundVisualization_Icon_Pterosaur_png"
    },
    [UESTExtraVehicleType.VT_TyrannosaurusRex] = {
      MapIcon = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_TyrannosaurusRex_Island_png.ZD_Icon_TyrannosaurusRex_Island_png",
      MainIcon = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/SoundVisualization_Icon_TyrannosaurusRex_png.SoundVisualization_Icon_TyrannosaurusRex_png"
    },
    [UESTExtraVehicleType.VT_Titan] = {
      MapIcon = "/Game/Library/Res/Vehicles/Giant/Arts/UI/Atlas/Frames/ZD_Icon_GiantFeet_Island_png.ZD_Icon_GiantFeet_Island_png",
      MainIcon = "/Game/Library/Res/Vehicles/Giant/Arts/UI/Atlas/Frames/ZD_icon_GiantFeet_png.ZD_icon_GiantFeet_png"
    }
  }
}
return SoundVisualizationConfig