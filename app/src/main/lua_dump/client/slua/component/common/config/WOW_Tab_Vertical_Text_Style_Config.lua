local WOW_Tab_Vertical_Text_Style_Config = {
  ItemTextStyleConfig = nil,
  ArrowStyleConfig = nil,
  SubItemStyleConfig = nil,
  BackGroundStyleConfig = nil,
  AnimationConfig = nil
}
function WOW_Tab_Vertical_Text_Style_Config.InitConfig()
  local InGameItemTextStyleConfig = {
    TextColorSelected = {
      1,
      0.723055,
      0.015209,
      1
    },
    TextColorUnselected = {
      1,
      1,
      1,
      0.5
    },
    TextShadowSelected = {
      0,
      0,
      0,
      0
    },
    TextShadowUnselected = {
      0,
      0,
      0,
      0
    },
    TextOutlineColorSelected = {
      0,
      0,
      0,
      1
    },
    TextOutlineColorUnselected = {
      0,
      0,
      0,
      0
    }
  }
  local ArrowStyleConfig = {
    ArrowColorSelected = {
      1,
      1,
      1,
      0.4
    },
    ArrowColorUnselected = {
      0,
      0,
      0,
      0.4
    },
    ArrowAngleExpanded = -90,
    ArrowAngleUnexpanded = 90,
    ArrowIconPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Arrow_png.Common_Icon_Arrow_png"
  }
  local SubItemStyleConfig = {
    TextColorSelected = {
      1,
      1,
      1,
      1
    },
    TextColorUnselected = {
      0,
      0,
      0,
      0.7
    }
  }
  local InGameBackGroundStyleConfig = {
    BackgroundColorSelected = {
      1,
      1,
      1,
      1
    },
    BackgroundColorUnselected = {
      1,
      1,
      1,
      0
    },
    BackgroundImageSelected = "/Game/Mod/CreativeBase/Arts/NoAtlas/Tab/Vertical/LevelOne/Text/Common_Tab_Vertical_LevelOne_Text_Button.Common_Tab_Vertical_LevelOne_Text_Button"
  }
  local AnimationConfig = {AnimationPlayDelayTime = 0.1}
  WOW_Tab_Vertical_Text_Style_Config.ItemTextStyleConfig = InGameItemTextStyleConfig
  WOW_Tab_Vertical_Text_Style_Config.  WOW_Tab_Vertical_Text_Style_Config.  WOW_Tab_Vertical_Text_Style_Config.BackGroundStyleConfig = InGameBackGroundStyleConfig
  WOW_Tab_Vertical_Text_Style_Config.  return WOW_Tab_Vertical_Text_Style_Config
end
return WOW_Tab_Vertical_Text_Style_Config