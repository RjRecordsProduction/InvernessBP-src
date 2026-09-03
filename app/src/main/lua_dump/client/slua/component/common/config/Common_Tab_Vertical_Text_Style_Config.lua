local Common_Tab_Vertical_Text_Style_Config = {}
local Home_Tab_Vertical_Text_Style_Config = require("client.slua.component.common.config.Home_Tab_Vertical_Text_Style_Config")
local WOW_Tab_Vertical_Text_Style_Config = require("client.slua.component.common.config.WOW_Tab_Vertical_Text_Style_Config")
local TypeMap = {
  [0] = Common_Tab_Vertical_Text_Style_Config,
  [1] = Home_Tab_Vertical_Text_Style_Config,
  [2] = WOW_Tab_Vertical_Text_Style_Config
}
function Common_Tab_Vertical_Text_Style_Config.InitConfig()
  local ItemTextStyleConfig = {
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
  Common_Tab_Vertical_Text_Style_Config.  Common_Tab_Vertical_Text_Style_Config.  Common_Tab_Vertical_Text_Style_Config.  Common_Tab_Vertical_Text_Style_Config.  Common_Tab_Vertical_Text_Style_Config.  return Common_Tab_Vertical_Text_Style_Config
end
function Common_Tab_Vertical_Text_Style_Config.GetConfig(type)
  type = type or 0
  local config = TypeMap[type]
  if not config then
    log_error_format("Common_Tab_Vertical_Text_Style_Config.GetConfig: invalid type = %s, fallback to default", tostring(type))
    config = TypeMap[0]
  end
  return config.InitConfig()
end
return Common_Tab_Vertical_Text_Style_Config