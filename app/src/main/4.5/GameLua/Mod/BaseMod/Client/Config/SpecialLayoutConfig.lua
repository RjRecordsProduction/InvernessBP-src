local SpecialLayoutConfig = {}
local IsBluehole = function()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  return Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
end
SpecialLayoutConfig.CategoryCfg = {
  {
    DisplayName = 66002,
    Contents = {
      "Horse",
      "Camel",
      "CombinedMech"
    }
  },
  {
    DisplayName = 78046,
    Contents = {
      "MotorGlider",
      "Fighter"
    }
  },
  {
    DisplayName = 39265,
    Contents = {"Tank"}
  },
  {
    DisplayName = 2026051116,
    Contents = {"Naruto"}
  }
}
SpecialLayoutConfig.ContentCfg = {
  MotorGlider = {
    DisplayName = 69527,
    ModesStrID = 78047,
    ControlMode = 2,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_01.SpecialVehicle_Image_01",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Glider_png.Setting_Icon_Glider_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Joystick_Image13.SpecialVehicle_Joystick_Image13",
    SettingKeys = {
      "bMotorGliderFlipJoystick"
    },
    VehicleType = 58,
    Buttons = {
      [240] = {
        Text = 87005,
        BGPath = "/Game/Arts/DefaultBrush/DefaultBrush_32_32.DefaultBrush_32_32",
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_icon_jiashi_jiasu_3_png.ZD_icon_jiashi_jiasu_3_png"
      },
      [241] = {
        Text = 87006,
        BGPath = "/Game/Arts/DefaultBrush/DefaultBrush_32_32.DefaultBrush_32_32",
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_icon_jiashi_jiasu_3_png.ZD_icon_jiashi_jiasu_3_png",
        IconSize = 70,
        IsFlipUD = true
      }
    }
  },
  NitrogenBoost = {
    DisplayName = 87762,
    ModesStrID = 8796688,
    ControlMode = 3,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_NitrogenBoost.SpecialVehicle_Image_NitrogenBoost",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_NitrogenBoost_png.Setting_Icon_NitrogenBoost_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_NitrogenBoost_Image28.SpecialVehicle_NitrogenBoost_Image28",
    Buttons = {
      [88] = {
        Text = 792594,
        IconPath = "/Game/Mod/ZNQ8th/Arts/UI/Atlas/Frames/ZD_Icon_NitrogenBoost_png.ZD_Icon_NitrogenBoost_png"
      }
    }
  },
  Tank = {
    DisplayName = 39265,
    ModesStrID = 48780,
    ControlMode = 3,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_02.SpecialVehicle_Image_02",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Key_Image11.SpecialVehicle_Key_Image11",
    VehicleType = 110,
    Buttons = {
      [174] = {
        BGPath = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Image_Fire_Bg_png.ZD_Image_Fire_Bg_png",
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_tankekaihuo_1_png.ZD_icon_tankekaihuo_1_png",
        IconSize = 96,
        IsFlipLR = true
      },
      [175] = {
        BGPath = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Image_Fire_Bg_png.ZD_Image_Fire_Bg_png",
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_tankekaihuo_1_png.ZD_icon_tankekaihuo_1_png"
      },
      [176] = {
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_kaijing_png.ZD_icon_kaijing_png",
        IconSize = 64
      },
      [177] = {
        Text = 87008,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_tanchutanke_png.ZD_icon_tanchutanke_png",
        IconSize = 45
      }
    }
  },
  Velociraptor = {
    IgnoreFunc = IsBluehole,
    DisplayName = 48649,
    ModesStrID = 48951,
    ControlMode = 3,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Velociraptor.SpecialVehicle_Image_Velociraptor",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Velociraptor_png.Setting_Icon_Velociraptor_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Key_Image06.SpecialVehicle_Key_Image06",
    VehicleType = 112,
    Buttons = {
      [225] = {
        Text = 48790,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
        IconSize = 56
      }
    }
  },
  Pterosaur = {
    DisplayName = 48650,
    ModesStrID = 48951,
    ControlMode = 2,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Pterosaur.SpecialVehicle_Image_Pterosaur",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Pterosaur_png.Setting_Icon_Pterosaur_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Joystick_Image19.SpecialVehicle_Joystick_Image19",
    VehicleType = 113,
    Buttons = {
      [202] = {
        Text = 48792,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Image_Cursor_Promptst02_png.ZD_Image_Cursor_Promptst02_png",
        IconSize = 54
      },
      [227] = {
        Text = 48791,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Srint_png.ZD_Icon_Srint_png",
        IconSize = 64
      },
      [204] = {},
      [205] = {}
    }
  },
  TRex = {
    IgnoreFunc = IsBluehole,
    DisplayName = 8204304,
    ModesStrID = 48951,
    ControlMode = 3,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_TRex.SpecialVehicle_Image_TRex",
    Icon = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/VehileTypeIcon/ZD_Icon_TRex.ZD_Icon_TRex",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Key_Image05.SpecialVehicle_Key_Image05",
    VehicleType = 114,
    Buttons = {
      [226] = {
        Text = 48793,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Roar_png.ZD_Icon_Roar_png"
      },
      [225] = {
        Text = 48794,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Gllop_png.ZD_Icon_Gllop_png"
      }
    }
  },
  Reindeer = {
    DisplayName = 64360,
    ModesStrID = 49488,
    ControlMode = 3,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Reindeer_02.SpecialVehicle_Image_Reindeer_02",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Reindeer_png.Setting_Icon_Reindeer_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Key_Image10.SpecialVehicle_Key_Image10",
    VehicleType = 117,
    Buttons = {
      [225] = {
        Text = 48790,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Fawn_Jump_png.ZD_Icon_Fawn_Jump_png",
        IconSize = 64
      },
      [226] = {
        Text = 49995,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_png.ZD_Icon_Link_png",
        IconSize = 64
      }
    }
  },
  FlyingReindeer = {
    DisplayName = 64362,
    ModesStrID = 49488,
    ControlMode = 2,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Sled_02.SpecialVehicle_Image_Sled_02",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Sled_png.Setting_Icon_Sled_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Joystick_Image21.SpecialVehicle_Joystick_Image21",
    VehicleType = 118,
    Buttons = {
      [227] = {
        Text = 5078,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png"
      },
      [204] = {},
      [205] = {}
    }
  },
  FlyingCarpet = {
    DisplayName = 66600,
    ModesStrID = 8500854,
    ControlMode = 2,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Flying_Carpet.SpecialVehicle_Image_Flying_Carpet",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Flying_Carpet02_png.Setting_Icon_Flying_Carpet02_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Key_Image04.SpecialVehicle_Key_Image04",
    VehicleType = 120,
    Buttons = {
      [202] = {
        Text = 48791,
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/ZD_Icon_Sprint_png.ZD_Icon_Sprint_png",
        IconSize = 54
      },
      [227] = {
        Text = 9834,
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/ZD_Icon_HandOff_png.ZD_Icon_HandOff_png",
        IconSize = 64
      },
      [204] = {},
      [205] = {}
    }
  },
  HoverMech = {
    DisplayName = 66832,
    ModesStrID = 49488,
    ControlMode = 2,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Mecha_Upper.SpecialVehicle_Image_Mecha_Upper",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Mecha_Upper_png.Setting_Icon_Mecha_Upper_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Joystick_Image11.SpecialVehicle_Joystick_Image11",
    VehicleType = 121,
    Buttons = {
      [245] = {
        BGPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_image_bg_kaihuo_1_png.ZD_image_bg_kaihuo_1_png",
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Magnetic_png.Setting_Icon_Magnetic_png",
        IsFlipLR = true
      },
      [246] = {
        BGPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_image_bg_kaihuo_1_png.ZD_image_bg_kaihuo_1_png",
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Magnetic_png.Setting_Icon_Magnetic_png"
      },
      [247] = {
        Text = 66934,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_png.ZD_Icon_Link_png"
      },
      [248] = {}
    }
  },
  BipedMech = {
    DisplayName = 66833,
    ModesStrID = 49488,
    ControlMode = 2,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Mecha_Limb.SpecialVehicle_Image_Mecha_Limb",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Mecha_Limb_png.Setting_Icon_Mecha_Limb_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Joystick_Image10.SpecialVehicle_Joystick_Image10",
    VehicleType = 122,
    Buttons = {
      [245] = {
        BGPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_image_bg_kaihuo_1_png.ZD_image_bg_kaihuo_1_png",
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Rpg_png.Setting_Icon_Rpg_png",
        IsFlipLR = true
      },
      [246] = {
        BGPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_image_bg_kaihuo_1_png.ZD_image_bg_kaihuo_1_png",
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Rpg_png.Setting_Icon_Rpg_png"
      },
      [247] = {
        Text = 66934,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_png.ZD_Icon_Link_png"
      },
      [248] = {},
      [249] = {
        Text = 48790,
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Refresh_Jump_png.Setting_Icon_Refresh_Jump_png"
      }
    }
  },
  CombinedMechBody = {
    DisplayName = 66834,
    ModesStrID = 48780,
    ControlMode = 2,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Mecha_Body.SpecialVehicle_Image_Mecha_Body",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Mecha_Body_png.Setting_Icon_Mecha_Body_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Joystick_Image12.SpecialVehicle_Joystick_Image12",
    VehicleType = 122,
    Buttons = {
      [245] = {
        BGPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_image_bg_kaihuo_1_png.ZD_image_bg_kaihuo_1_png",
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Rpg_png.Setting_Icon_Rpg_png",
        IsFlipLR = true
      },
      [246] = {
        BGPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_image_bg_kaihuo_1_png.ZD_image_bg_kaihuo_1_png",
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Rpg_png.Setting_Icon_Rpg_png"
      },
      [247] = {
        Text = 66935,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Separate_png.ZD_Icon_Separate_png"
      },
      [248] = {},
      [249] = {
        Text = 801011,
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Refresh_Jump_png.Setting_Icon_Refresh_Jump_png"
      }
    }
  },
  Fighter = {
    DisplayName = 69526,
    ModesStrID = 63027,
    ControlMode = 2,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_03.SpecialVehicle_Image_03",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Warcraft_png.Setting_Icon_Warcraft_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Joystick_Image18.SpecialVehicle_Joystick_Image18",
    VehicleType = 124,
    SettingKeys = {
      "bMotorGliderFlipJoystick"
    },
    Buttons = {
      [39] = {
        Text = 87005,
        BGPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_image_bg_kaihuo_1_png.ZD_image_bg_kaihuo_1_png",
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Btn_Advance_png.Setting_Icon_Btn_Advance_png",
        IconSize = 64
      },
      [40] = {
        Text = 87006,
        BGPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_image_bg_kaihuo_1_png.ZD_image_bg_kaihuo_1_png",
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Btn_Receding_png.Setting_Icon_Btn_Receding_png",
        IconSize = 64
      },
      [37] = {
        BGPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_image_bg_kaihuo_1_png.ZD_image_bg_kaihuo_1_png",
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Fire_png.Setting_Icon_Fire_png",
        IconSize = 64,
        IsFlipLR = true
      },
      [38] = {
        BGPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_image_bg_kaihuo_1_png.ZD_image_bg_kaihuo_1_png",
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Fire_png.Setting_Icon_Fire_png",
        IconSize = 64
      },
      [41] = {
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_kaijing_png.ZD_icon_kaijing_png",
        IconSize = 64
      },
      [44] = {
        Text = 87007,
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Jamming_Bombsn_png.Setting_Icon_Jamming_Bombsn_png",
        IconSize = 64
      },
      [36] = {}
    }
  },
  CombinedMech = {
    DisplayName = 66834,
    ModesStrID = 48780,
    ControlMode = 2,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Mecha_Body02.SpecialVehicle_Image_Mecha_Body02",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Mecha_Body_png.Setting_Icon_Mecha_Body_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Joystick_Image12.SpecialVehicle_Joystick_Image12",
    VehicleType = 122,
    Buttons = {
      [245] = {
        BGPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_image_bg_kaihuo_1_png.ZD_image_bg_kaihuo_1_png",
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Rpg_png.Setting_Icon_Rpg_png",
        IsFlipLR = true
      },
      [246] = {
        BGPath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_image_bg_kaihuo_1_png.ZD_image_bg_kaihuo_1_png",
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Rpg_png.Setting_Icon_Rpg_png"
      },
      [248] = {},
      [249] = {
        Text = 801011,
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Refresh_Jump_png.Setting_Icon_Refresh_Jump_png"
      }
    }
  },
  Horse = {
    DisplayName = 69811,
    ModesStrID = 76537,
    ControlMode = 3,
    AvailableModes = {3, 2},
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Horse.SpecialVehicle_Image_Horse",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Horse_png.Setting_Icon_Horse_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Joystick_Image23.SpecialVehicle_Joystick_Image23",
    VehicleType = 126,
    SettingKeys = {
      "bAvoidObstacle",
      "bJumpOverObstacle"
    },
    Buttons = {
      [225] = {
        Text = 69815,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png"
      },
      [226] = {
        Text = 69814,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png"
      },
      [210] = {
        Text = 69812,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Follow_png.ZD_Icon_Follow_png"
      },
      [211] = {
        Text = 69817,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
      },
      [267] = {
        Text = 76274,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/VehileControlPanel_New/Frames/ZD_Icon_Vehicle_AutomaticForward_1_png.ZD_Icon_Vehicle_AutomaticForward_1_png"
      }
    }
  },
  SymbioteHorse = {
    DisplayName = 66275,
    ModesStrID = 72021,
    ControlMode = 3,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Horse_02.SpecialVehicle_Image_Horse_02",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Horse_02_png.Setting_Icon_Horse_02_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Key_Image03.SpecialVehicle_Key_Image03",
    VehicleType = 128,
    Buttons = {
      [225] = {
        Text = 69815,
        IconPath = "/Game/Mod/Hw4Liquid/Arts/UI/Atlas/Frames/ZD_Icon_Horse_png.ZD_Icon_Horse_png"
      },
      [211] = {
        Text = 18373,
        IconPath = "/Game/Mod/Hw4Liquid/Arts/UI/Atlas/Frames/ZD_Icon_Throwing_png.ZD_Icon_Throwing_png"
      },
      [226] = {
        Text = 18775,
        IconPath = "/Game/Mod/Hw4Liquid/Arts/UI/Atlas/Frames/ZD_Icon_Attack_png.ZD_Icon_Attack_png"
      }
    }
  },
  SaberTiger = {
    DisplayName = 76272,
    ModesStrID = 49488,
    ControlMode = 3,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Tiger.SpecialVehicle_Image_Tiger",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Tiger_png.Setting_Icon_Tiger_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Key_Image07.SpecialVehicle_Key_Image07",
    VehicleType = 130,
    Buttons = {
      [225] = {
        Text = 69815,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/VehileControlPanel_New/Frames/ZD_Icon_Skill_Tiger_Pounce_png.ZD_Icon_Skill_Tiger_Pounce_png"
      },
      [211] = {
        Text = 69817,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
      },
      [266] = {
        Text = 76273,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skill_Tiger_Drift_02_png.ZD_Icon_Skill_Tiger_Drift_02_png"
      },
      [267] = {
        Text = 76274,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skill_Tiger_Rush_02_png.ZD_Icon_Skill_Tiger_Rush_02_png"
      }
    }
  },
  Mammoth = {
    DisplayName = 6350026,
    ModesStrID = 49488,
    ControlMode = 3,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Elephant.SpecialVehicle_Image_Elephant",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Elephant_png.Setting_Icon_Elephant_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Key_Image02.SpecialVehicle_Key_Image02",
    VehicleType = 131,
    Buttons = {
      [268] = {
        Text = 6350035,
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Elephant_Dance_png.Setting_Icon_Elephant_Dance_png"
      }
    }
  },
  Panda = {
    DisplayName = 76681,
    ModesStrID = 49488,
    ControlMode = 3,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Panda.SpecialVehicle_Image_Panda",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Panda_png.Setting_Icon_Panda_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Key_Image08.SpecialVehicle_Key_Image08",
    VehicleType = 134,
    Buttons = {
      [211] = {
        Text = 76679,
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Panda_02_png.Setting_Icon_Panda_02_png"
      },
      [225] = {
        Text = 69815,
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Panda_Jump_png.Setting_Icon_Panda_Jump_png"
      }
    }
  },
  Scorpion = {
    DisplayName = 81276,
    ModesStrID = 612401111,
    ControlMode = 2,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Scorpion.SpecialVehicle_Image_Scorpion",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Scorpion_png_png.Setting_Icon_Scorpion_png_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Image_Operate_Scorpion.SpecialVehicle_Image_Operate_Scorpion",
    Buttons = {
      [282] = {
        Text = 81567,
        IconPath = "/Game/Library/Res/Vehicles/Scorpion/Art/UI/Atlas/Frames/ZD_icon_ScorpionSpike01_png.ZD_icon_ScorpionSpike01_png"
      },
      [283] = {
        Text = 81278,
        IconPath = "/Game/Library/Res/Vehicles/Scorpion/Art/UI/Atlas/Frames/ZD_icon_ScorpionStealth01_png.ZD_icon_ScorpionStealth01_png"
      },
      [279] = {
        Text = 81282,
        IconPath = "/Game/Library/Res/Vehicles/Scorpion/Art/UI/Atlas/Frames/ZD_icon_ScorpionGlide01_png.ZD_icon_ScorpionGlide01_png"
      },
      [280] = {
        Text = 81362,
        BGPath = "/Game/Library/Res/SkillsCommon/UICommon/Textures/NoAtlas/SkillButton_BG.SkillButton_BG",
        IconPath = "/Game/Library/Res/Vehicles/Scorpion/Art/UI/Atlas/Frames/ZD_icon_Scorpion_png.ZD_icon_Scorpion_png"
      },
      [281] = {
        Text = 81362,
        BGPath = "/Game/Library/Res/SkillsCommon/UICommon/Textures/NoAtlas/SkillButton_BG.SkillButton_BG",
        IconPath = "/Game/Library/Res/Vehicles/Scorpion/Art/UI/Atlas/Frames/ZD_icon_Scorpion_png.ZD_icon_Scorpion_png",
        IsFlipLR = true
      }
    }
  },
  Deer = {
    DisplayName = 527154,
    ModesStrID = 612401111,
    ControlMode = 3,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Deer01.SpecialVehicle_Image_Deer01",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Deer_png.Setting_Icon_Deer_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Key_Image13.SpecialVehicle_Key_Image13",
    Buttons = {
      [225] = {
        Text = 69815,
        IconPath = "/Game/Library/Res/Vehicles/Deer/Art/UI/Atlas/Frames/ZD_icon_DeerJump01_png.ZD_icon_DeerJump01_png"
      }
    }
  },
  Camel = {
    DisplayName = 76994,
    ModesStrID = 76537,
    ControlMode = 3,
    AvailableModes = {3, 2},
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Camel.SpecialVehicle_Image_Camel",
    Icon = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Camel_png.Setting_Icon_Camel_png",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Key_Image09.SpecialVehicle_Key_Image09",
    VehicleType = 137,
    Buttons = {
      [225] = {
        Text = 69815,
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Jumping_png.Setting_Icon_Jumping_png"
      },
      [210] = {
        Text = 76997,
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Follow_png.Setting_Icon_Follow_png"
      },
      [275] = {
        Text = 77032,
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Search_png.Setting_Icon_Search_png"
      },
      [276] = {
        Text = 76995,
        IconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Spirit_png.Setting_Icon_Spirit_png"
      },
      [211] = {
        Text = 69817,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
      },
      [267] = {
        Text = 76274,
        IconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/VehileControlPanel_New/Frames/ZD_Icon_Vehicle_AutomaticForward_1_png.ZD_Icon_Vehicle_AutomaticForward_1_png"
      }
    }
  },
  Naruto = {
    DisplayName = 2026051116,
    ModesStrID = "",
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_Scroll.SpecialVehicle_Image_Scroll",
    BackCustomTypeList = {
      1,
      2,
      3,
      4,
      5,
      8,
      9,
      10,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      25,
      152,
      153,
      154,
      155
    },
    SettingKeys = {
      "bShowNinjutsuLabel"
    },
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Joystick_Image30.SpecialVehicle_Joystick_Image30",
    Buttons = {
      [75] = {
        Text = 4500026,
        IconPath = "/Game/Library/Res/Skills/NTSkills/Arts/UI/Atlas/Frames/NTSkills_Icon_Rasengan02_png.NTSkills_Icon_Rasengan02_png"
      },
      [76] = {
        Text = 450240,
        IconPath = "/Game/Library/Res/Skills/NTSkills/Arts/UI/Atlas/Frames/NTSkills_Icon_NinjaRun_02_png.NTSkills_Icon_NinjaRun_02_png"
      },
      [77] = {
        Text = 450241,
        IconPath = "/Game/Library/Res/Skills/NTSkills/Arts/UI/Atlas/Frames/NTSkills_Icon_Follow.NTSkills_Icon_Follow"
      },
      [78] = {
        Text = 450242,
        IconPath = "/Game/Library/Res/Skills/NTSkills/Arts/UI/Atlas/Frames/NTSkills_Icon_WeiShou_Skill.NTSkills_Icon_WeiShou_Skill"
      },
      [79] = {
        Text = 4500027,
        IconPath = "/Game/Mod/PlanNT/Arts/Frames/ZD_Icon_PlanNTVoice_png.ZD_Icon_PlanNTVoice_png"
      },
      [80] = {
        Text = 4500053,
        IconPath = "/Game/Library/Res/Skills/NTSkills/Arts/UI/Atlas/Frames/NTSkills_Icon_Swap_png.NTSkills_Icon_Swap_png"
      }
    }
  },
  SpiderGloves = {
    DisplayName = 450110,
    ModesStrID = 89310,
    DisplayImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/SpecialVehicle_Image_SpiderGloves.SpecialVehicle_Image_SpiderGloves",
    Icon = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/VehileTypeIcon/ZD_Icon_Gloves.ZD_Icon_Gloves",
    OpImage = "/Game/UMG/Texture_200/Lobby_NoAtlas/Setting/Panel/SpecialVehicle_Image_Gloves.SpecialVehicle_Image_Gloves",
    BackCustomTypeList = {
      1,
      2,
      3,
      4,
      5,
      8,
      9,
      10,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      25,
      152,
      153,
      154,
      155
    },
    Buttons = {
      [81] = {
        Text = 450104,
        IconPath = "/Game/Library/Res/Weapons/SPSilkHand/UI/Atlas/Frames/ZD_Icon_SPSilkHand01_png.ZD_Icon_SPSilkHand01_png"
      }
    }
  }
}
local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
SpecialLayoutConfig.NestedOptions = {
  bMotorGliderFlipJoystick = {
    Key = "bMotorGliderFlipJoystick",
    UI = AliasMap.CompactSwitcher,
    Text = 78050,
    Help = 78051
  },
  bAvoidObstacle = {
    Key = "bAvoidObstacle",
    UI = AliasMap.CompactSwitcher,
    Text = 75403,
    Help = 76922
  },
  bJumpOverObstacle = {
    Key = "bJumpOverObstacle",
    UI = AliasMap.CompactSwitcher,
    Text = 75404,
    Help = 76921
  },
  TransformerAudioSwitch = {
    Key = "TransformerAudioSwitch",
    UI = AliasMap.CompactSwitcher,
    Text = 792588,
    Help = 792589
  },
  bShowNinjutsuLabel = {
    Key = "bShowNinjutsuLabel",
    UI = AliasMap.CompactSwitcher,
    Text = 4500028
  }
}
return SpecialLayoutConfig