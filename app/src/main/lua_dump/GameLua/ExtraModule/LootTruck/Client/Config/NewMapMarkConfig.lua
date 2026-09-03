local NewMapMarkConfig = {
  [410901] = {
    UIPath = "/Game/Mod/EvoBase/BluePrints/UI/MapItem/CommonCountdownMapMark_UIBP.CommonCountdownMapMark_UIBP_C",
    bIsUpdateSize = true,
    ZOrder = 1,
    bIsControlByLegend = false,
    CommonMarkConfig = {
      [1] = {
        UpdateWidget = "Image_Icon",
        IconPathArray = {
          "/Game/Arts/UI/Atlas/BattleUI/General_Ver2/Frames/ZD_Icon_Vehicle_png.ZD_Icon_Vehicle_png",
          "/Game/Arts/UI/Atlas/BattleUI/General_Ver2/Frames/ZD_Icon_Vehicle_Broken_png.ZD_Icon_Vehicle_Broken_png"
        }
      },
      [2] = {
        UpdateWidget = "CanvasPanel_Time",
        IconVisibleArray = {
          UEnums.ESlateVisibility.Collapsed,
          UEnums.ESlateVisibility.Collapsed
        }
      },
      [3] = {
        UpdateWidget = "Image_BG",
        IconVisibleArray = {
          UEnums.ESlateVisibility.Collapsed,
          UEnums.ESlateVisibility.Collapsed
        }
      }
    }
  }
}
return NewMapMarkConfig