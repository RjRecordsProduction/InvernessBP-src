local Home_Tab_Vertical_Text_Style_Config = {
  ItemTextStyleConfig = nil,
  ArrowStyleConfig = nil,
  SubItemStyleConfig = nil,
  BackGroundStyleConfig = nil,
  AnimationConfig = nil
}
function Home_Tab_Vertical_Text_Style_Config.InitConfig()
  local HomeItemTextStyleConfig = {
    TextColorSelected = {
      1,
      1,
      1,
      1
    },
    TextColorUnselected = {
      1,
      1,
      1,
      0.4
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
      0
    },
    TextOutlineColorUnselected = {
      0,
      0,
      0,
      0
    }
  }
  local HomeSubItemStyleConfig = {
    TextColorSelected = {
      1,
      1,
      1,
      1
    },
    TextColorUnselected = {
      1,
      1,
      1,
      0.4
    }
  }
  local ArrowStyleConfig = {
    ArrowColorSelected = {
      1,
      1,
      1,
      1
    },
    ArrowColorUnselected = {
      1,
      1,
      1,
      0.4
    },
    ArrowAngleExpanded = -90,
    ArrowAngleUnexpanded = 90,
    ArrowIconPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Arrow_png.Common_Icon_Arrow_png"
  }
  local BackGroundStyleConfig = {
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
    BackgroundImageSelected = "/Game/UMG/Texture_200/Lobby_NoAtlas/Common/Tab/Vertical/LevelOne/Text/Common_Tab_Vertical_LevelOne_Text_Button.Common_Tab_Vertical_LevelOne_Text_Button"
  }
  local AnimationConfig = {AnimationPlayDelayTime = 0.1}
  Home_Tab_Vertical_Text_Style_Config.ItemTextStyleConfig = HomeItemTextStyleConfig
  Home_Tab_Vertical_Text_Style_Config.  Home_Tab_Vertical_Text_Style_Config.SubItemStyleConfig = HomeSubItemStyleConfig
  Home_Tab_Vertical_Text_Style_Config.  Home_Tab_Vertical_Text_Style_Config.  return Home_Tab_Vertical_Text_Style_Config
end
return Home_Tab_Vertical_Text_Style_Config