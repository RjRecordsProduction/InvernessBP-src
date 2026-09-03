local Config = {
  AssetMap = {},
  CustomUIObjectPath = "/Game/Mod/CreativeBase/BluePrints/Object/CustomUIObjects/BP_Creative_EditWidgetObjet.BP_Creative_EditWidgetObjet_C"
}
local CreativeGlobalDefine = require("GameLua.Mod.CreativeBase.Gameplay.Config.Asset.Common.CreativeGlobalDefine")
Config.C_SizeMin = 5
Config.C_SizeMax = 1024
Config.C_TextDefaultFontSize = 15
Config.C_TextFontSizeMax = 45
Config.TextFontSizeRange = {
  Min = Config.C_SizeMin,
  Max = Config.C_TextFontSizeMax,
  Default = Config.C_TextDefaultFontSize
}
Config.MaxUICount = 300
Config.MaxCustomUIDepth = 3
Config.CircleFrameImageScale = FVector2D(0.69, 0.69)
Config.TemplateGroupAssetIDMap = {
  [5310001] = true,
  [5310002] = true,
  [5310003] = true,
  [5310004] = true,
  [5310005] = true,
  [5310006] = true,
  [5310007] = true,
  [5310008] = true
}
Config.Enum_CustomUIOperatorType = {CustomUIEdit = 1, CustomUISelect = 2}
Config.CustomUIAniFPSLimit = {
  High = 0.03333333333333333,
  Medium = 0.06666666666666667,
  Low = 0.125
}
Config.CanvasType = {
  W16_H9 = 1,
  W19_H9 = 2,
  W20_H9 = 3,
  W4_H3 = 4
}
Config.UMGCanvasType = {
  Default = 1,
  Game = 2,
  Dynamic = 3
}
Config.UMGCanvasCost = 20
Config.CanvasSize = {
  [1] = {
    Width = 916,
    Height = 515,
    Image = "/Game/Mod/CreativeEdit/Arts/NoAtlas/CustomUI/Canvas/Custom_Canvas_01.Custom_Canvas_01"
  },
  [2] = {
    Width = 916,
    Height = 435,
    Image = "/Game/Mod/CreativeEdit/Arts/NoAtlas/CustomUI/Canvas/Custom_Canvas_02.Custom_Canvas_02"
  },
  [3] = {
    Width = 916,
    Height = 413,
    Image = "/Game/Mod/CreativeEdit/Arts/NoAtlas/CustomUI/Canvas/Custom_Canvas_03.Custom_Canvas_03"
  },
  [4] = {
    Width = 688,
    Height = 516,
    Image = "/Game/Mod/CreativeEdit/Arts/NoAtlas/CustomUI/Canvas/Custom_Canvas_04.Custom_Canvas_04"
  }
}
Config.CanvasList = {
  {CanvasType = 1, Title = 8800243},
  {CanvasType = 2, Title = 8800244},
  {CanvasType = 3, Title = 8800245},
  {CanvasType = 4, Title = 8800246}
}
Config.SnapTypeParameterList = {
  "GuideLineSnapping",
  "RotationAngleSnapping",
  "EqualDistanceSnapping",
  "BoundingBoxSnapping"
}
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local HPBarIconPath = "/Game/MultiRegion/Content/IN/Mod/CreativeBase/Arts/NoAtlas/ProgressBar/Ugc_ProgressBar_Icon02.Ugc_ProgressBar_Icon02"
if not PublishRegionMacros.IsBLUEHOLE() then
  HPBarIconPath = "/Game/Mod/CreativeBase/Arts/NoAtlas/ProgressBar/Ugc_ProgressBar_Icon02.Ugc_ProgressBar_Icon02"
end
Config.Enum_FrameType = {
  Rectangle = 0,
  Circle = 1,
  Hexagon = 2
}
Config.Enum_AnchorValueType = {Pixel = 0, Percentage = 1}
Config.PERCENT_SCALE = 100
Config.ControlType = {
  Example = -1,
  All = 0,
  Button = 1,
  Image = 2,
  Text = 3,
  ProgressBar = 4,
  HPBar = 5,
  TalentNode = 6,
  TalentInfo = 7,
  UIGroup = 8
}
Config.OOPClassPath = {
  [Config.ControlType.Button] = "GameLua.Mod.CreativeBase.Client.CreativeCustomUI.CreativeCustomButtonOOPClass",
  [Config.ControlType.Image] = "GameLua.Mod.CreativeBase.Client.CreativeCustomUI.CreativeCustomImageOOPClass",
  [Config.ControlType.Text] = "GameLua.Mod.CreativeBase.Client.CreativeCustomUI.CreativeCustomTextOOPClass",
  [Config.ControlType.ProgressBar] = "GameLua.Mod.CreativeBase.Client.CreativeCustomUI.CreativeCustomProgressBarOOPClass",
  [Config.ControlType.HPBar] = "GameLua.Mod.CreativeBase.Client.CreativeCustomUI.CreativeCustomHPBarOOPClass",
  [Config.ControlType.TalentNode] = "GameLua.Mod.CreativeBase.Client.CreativeCustomUI.CreativeCustomWidgetOOPClass",
  [Config.ControlType.TalentInfo] = "GameLua.Mod.CreativeBase.Client.CreativeCustomUI.CreativeCustomWidgetOOPClass",
  [Config.ControlType.UIGroup] = "GameLua.Mod.CreativeBase.Client.CreativeCustomUI.CreativeCustomWidgetOOPClass"
}
Config.UIWidgetCost = {
  [Config.ControlType.Button] = 50,
  [Config.ControlType.Image] = 30,
  [Config.ControlType.Text] = 40,
  [Config.ControlType.ProgressBar] = 40,
  [Config.ControlType.HPBar] = 40,
  [Config.ControlType.TalentNode] = 110,
  [Config.ControlType.TalentInfo] = 300,
  [Config.ControlType.UIGroup] = 20
}
Config.LeftMenuConfig = {
  {
    Name = 2026032019,
    Image = "/Game/Mod/CreativeBase/Arts/NoAtlas/CustomUI/Official_Icon_Border.Official_Icon_Border",
    SelectedImage = "/Game/Mod/CreativeBase/Arts/NoAtlas/CustomUI/Official_Icon_Border.Official_Icon_Border",
    SubMenu = {
      [1] = {
        Name = 2026032019,
        Image = "/Game/Mod/CreativeBase/Arts/NoAtlas/CustomUI/Official_Icon_Border.Official_Icon_Border",
        SelectedImage = "/Game/Mod/CreativeBase/Arts/NoAtlas/CustomUI/Official_Icon_Border.Official_Icon_Border",
        AssetCategory = {
          [1] = {
            Title = 2026032019,
            AssetList = {
              {
                AssetId = 1200002,
                Name = 2026032019,
                Image = "/Game/Mod/CreativeBase/Arts/NoAtlas/CustomUI/Official_Icon_Border.Official_Icon_Border"
              }
            }
          }
        }
      }
    }
  },
  {
    Name = 8800229,
    Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_png.Custom_Icon_Button_png",
    SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_Select_png_png.Custom_Icon_Button_Select_png_png",
    SubMenu = {
      [1] = {
        Name = 8700833,
        Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_png.Custom_Icon_Button_png",
        SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_Select_png_png.Custom_Icon_Button_Select_png_png",
        AssetCategory = {
          [1] = {
            Title = 8700833,
            AssetList = {
              {
                AssetId = 5100036,
                Name = 8800291,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/256/CustomUI_Icon_Add.CustomUI_Icon_Add"
              },
              {
                AssetId = 5100037,
                Name = 8500125,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/256/CustomUI_Icon_Close.CustomUI_Icon_Close"
              },
              {
                AssetId = 5100038,
                Name = 8700833,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/256/CustomUI_Icon_Common.CustomUI_Icon_Common"
              },
              {
                AssetId = 5100039,
                Name = 8310012,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/256/CustomUI_Icon_Delete.CustomUI_Icon_Delete"
              },
              {
                AssetId = 5100040,
                Name = 4486,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/256/CustomUI_Icon_Exit.CustomUI_Icon_Exit"
              },
              {
                AssetId = 5100041,
                Name = 4539,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/256/CustomUI_Icon_Question.CustomUI_Icon_Question"
              },
              {
                AssetId = 5100044,
                Name = 29091,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/256/CustomUI_Icon_Refresh.CustomUI_Icon_Refresh"
              },
              {
                AssetId = 5100042,
                Name = 19520,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/256/CustomUI_Icon_Skip.CustomUI_Icon_Skip"
              },
              {
                AssetId = 5100043,
                Name = 8800292,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/256/CustomUI_Icon_Subtract.CustomUI_Icon_Subtract"
              }
            }
          }
        }
      },
      [2] = {
        Name = 8500464,
        Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_png.Custom_Icon_Button_png",
        SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_Select_png_png.Custom_Icon_Button_Select_png_png",
        AssetCategory = {
          [1] = {
            Title = 8500101,
            AssetList = {
              {
                AssetId = 5100016,
                Name = 8800332,
                Image = "/Game/Library/CreativeDL/IG2200/Arts/Icon_LD/Prefab/Icon_BalticBuilding001_128.Icon_BalticBuilding001_128"
              },
              {
                AssetId = 5100017,
                Name = 8800333,
                Image = "/Game/Library/CreativeDL/IG2200/Arts/Icon_LD/Prefab/Icon_BalticBuilding002_128.Icon_BalticBuilding002_128"
              },
              {
                AssetId = 5100018,
                Name = 8800334,
                Image = "/Game/Library/CreativeDL/IG2200/Arts/Icon_LD/Prefab/Icon_BalticBuilding003_128.Icon_BalticBuilding003_128"
              },
              {
                AssetId = 5100019,
                Name = 8800335,
                Image = "/Game/Library/CreativeDL/IG2200/Arts/Icon_LD/Prefab/Icon_BalticBuilding004_128.Icon_BalticBuilding004_128"
              },
              {
                AssetId = 5100020,
                Name = 8800336,
                Image = "/Game/Library/CreativeDL/IG2200/Arts/Icon_LD/Prefab/Icon_BalticBuilding005_128.Icon_BalticBuilding005_128"
              }
            }
          }
        }
      },
      [3] = {
        Name = 8340201,
        Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_png.Custom_Icon_Button_png",
        SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_Select_png_png.Custom_Icon_Button_Select_png_png",
        AssetCategory = {
          [1] = {
            Title = 8202307,
            AssetList = {
              {
                AssetId = 5100009,
                Name = 8800271,
                Image = "/Game/Arts/UI/TableIcons/ItemIcon/Weapon/Icon_WEP_AK47.Icon_WEP_AK47"
              },
              {
                AssetId = 5100001,
                Name = 8800272,
                Image = "/Game/Arts/UI/TableIcons/ItemIcon/Weapon/Icon_WEP_M16A4.Icon_WEP_M16A4"
              },
              {
                AssetId = 5100002,
                Name = 8800273,
                Image = "/Game/Arts/UI/TableIcons/ItemIcon/Weapon/Icon_WEP_SCAR.Icon_WEP_SCAR"
              },
              {
                AssetId = 5100003,
                Name = 8800274,
                Image = "/Game/Arts/UI/TableIcons/ItemIcon/Weapon/Icon_WEP_M416.Icon_WEP_M416"
              },
              {
                AssetId = 5100010,
                Name = 8340444,
                Image = "/Game/Arts/UI/TableIcons/ItemIcon/Weapon/Icon_WEP_FireLauncher.Icon_WEP_FireLauncher"
              }
            }
          },
          [2] = {
            Title = 8202308,
            AssetList = {
              {
                AssetId = 5100011,
                Name = 8800276,
                Image = "/Game/Arts/UI/TableIcons/ItemIcon/Weapon/Icon_WEP_P92.Icon_WEP_P92"
              },
              {
                AssetId = 5100012,
                Name = 8800277,
                Image = "/Game/Arts/UI/TableIcons/ItemIcon/Weapon/Icon_WEP_P1911.Icon_WEP_P1911"
              },
              {
                AssetId = 5100013,
                Name = 8800278,
                Image = "/Game/Arts/UI/TableIcons/ItemIcon/Weapon/Icon_WEP_R1895.Icon_WEP_R1895"
              },
              {
                AssetId = 5100014,
                Name = 8800279,
                Image = "/Game/Arts/UI/TableIcons/ItemIcon/Weapon/Icon_WEP_P18C.Icon_WEP_P18C"
              },
              {
                AssetId = 5100015,
                Name = 8340450,
                Image = "/Game/Arts/UI/TableIcons/ItemIcon/Weapon/Icon_WEP_Rhino.Icon_WEP_Rhino"
              }
            }
          }
        }
      },
      [4] = {
        Name = 8202502,
        Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_png.Custom_Icon_Button_png",
        SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_Select_png_png.Custom_Icon_Button_Select_png_png",
        AssetCategory = {
          [1] = {
            Title = 8202502,
            AssetList = {
              {
                AssetId = 5100004,
                Name = 8500610,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_InstantSmokeBomb.RuneDevice_Icon_InstantSmokeBomb"
              },
              {
                AssetId = 5100025,
                Name = 66462,
                Image = "/Game/Library/Res/Skills/Hook/Arts/UI/Atlas/Frames/Eastern_Icon_Hook_lock_png.Eastern_Icon_Hook_lock_png"
              },
              {
                AssetId = 5100026,
                Name = 20230622,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/ZD_Icon_Transformation.ZD_Icon_Transformation"
              },
              {
                AssetId = 5100027,
                Name = 8202548,
                Image = "/Game/Library/Res/Actors/BladeBall/Arts/UI/Atlas/Frames/ZD_Icon_Sprint02_png.ZD_Icon_Sprint02_png"
              },
              {
                AssetId = 5100028,
                Name = 8202549,
                Image = "/Game/Library/Res/Actors/BladeBall/Arts/UI/Atlas/Frames/ZD_Icon_SuperJump02_png.ZD_Icon_SuperJump02_png"
              },
              {
                AssetId = 5100083,
                Name = 8880184,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_MoveBack.RuneDevice_Icon_MoveBack"
              },
              {
                AssetId = 5100084,
                Name = 8880185,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Thunderbolt.RuneDevice_Icon_Thunderbolt"
              },
              {
                AssetId = 5100085,
                Name = 8880186,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_MoveForward.RuneDevice_Icon_MoveForward"
              },
              {
                AssetId = 5100086,
                Name = 8880188,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_HeavenlyThunder.RuneDevice_Icon_HeavenlyThunder"
              },
              {
                AssetId = 5100087,
                Name = 8880189,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_ThrowDarts.RuneDevice_Icon_ThrowDarts"
              },
              {
                AssetId = 5100088,
                Name = 8880191,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_EnhancedState.RuneDevice_Icon_EnhancedState"
              },
              {
                AssetId = 5100089,
                Name = 8880193,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_IceCrystal.RuneDevice_Icon_IceCrystal"
              },
              {
                AssetId = 5100090,
                Name = 8880194,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Frozen.RuneDevice_Icon_Frozen"
              },
              {
                AssetId = 5100091,
                Name = 8880187,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_IceThorn.RuneDevice_Icon_IceThorn"
              },
              {
                AssetId = 5100092,
                Name = 8880192,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_DevilPumpkin.RuneDevice_Icon_DevilPumpkin"
              },
              {
                AssetId = 5100093,
                Name = 8880196,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Penetrate.RuneDevice_Icon_Penetrate"
              },
              {
                AssetId = 5100094,
                Name = 8880195,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_ShieldEffect.RuneDevice_Icon_ShieldEffect"
              },
              {
                AssetId = 5100095,
                Name = 8880197,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_SwordFlash.RuneDevice_Icon_SwordFlash"
              },
              {
                AssetId = 5100096,
                Name = 8880198,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_EnergyCannon.RuneDevice_Icon_EnergyCannon"
              },
              {
                AssetId = 5100097,
                Name = 8880190,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Gathering.RuneDevice_Icon_Gathering"
              }
            }
          }
        }
      },
      [5] = {
        Name = 8700829,
        Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_png.Custom_Icon_Button_png",
        SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_Select_png_png.Custom_Icon_Button_Select_png_png",
        AssetCategory = {
          [1] = {
            Title = 8700829,
            AssetList = {
              {
                AssetId = 5100005,
                Name = 49843,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_VehicleRepair.RuneDevice_Icon_VehicleRepair"
              },
              {
                AssetId = 5100021,
                Name = 49847,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Invincible.RuneDevice_Icon_Invincible"
              },
              {
                AssetId = 5100022,
                Name = 16003733,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_Accelerate.RuneDevice_Icon_Accelerate"
              },
              {
                AssetId = 5100023,
                Name = 16003735,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_PlayerDamageUp.RuneDevice_Icon_PlayerDamageUp"
              },
              {
                AssetId = 5100024,
                Name = 16003736,
                Image = "/Game/Mod/CreativeBase/RuneDevice/Arts/NoAtlas/Icon/RuneDevice_Icon_RespiratoryReturn.RuneDevice_Icon_RespiratoryReturn"
              }
            }
          }
        }
      }
    }
  },
  {
    Name = 8800211,
    Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Picture_png.Custom_Icon_Picture_png",
    SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Picture_Select_png.Custom_Icon_Picture_Select_png",
    SubMenu = {
      [1] = {
        Name = 8800293,
        Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Picture_png.Custom_Icon_Picture_png",
        SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Picture_Select_png.Custom_Icon_Picture_Select_png",
        AssetCategory = {
          [1] = {
            Title = 8800303,
            AssetList = {
              {
                AssetId = 5100029,
                Name = 8800296,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Triangle.CustomUI_Icon_Triangle"
              },
              {
                AssetId = 5100030,
                Name = 8800297,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Circle.CustomUI_Icon_Circle"
              },
              {
                AssetId = 5100031,
                Name = 8800298,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_RegularHexagon.CustomUI_Icon_RegularHexagon"
              },
              {
                AssetId = 5100101,
                Name = 8800299,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_RoundedRectangle.CustomUI_Icon_RoundedRectangle"
              },
              {
                AssetId = 5100102,
                Name = 8800300,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Square.CustomUI_Icon_Square"
              },
              {
                AssetId = 5100103,
                Name = 8800301,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_SquareBorder.CustomUI_Icon_SquareBorder"
              },
              {
                AssetId = 5100035,
                Name = 8800302,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Toroidal.CustomUI_Icon_Toroidal"
              }
            }
          }
        }
      },
      [2] = {
        Name = 8800294,
        Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Picture_png.Custom_Icon_Picture_png",
        SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Picture_Select_png.Custom_Icon_Picture_Select_png",
        AssetCategory = {
          [1] = {
            Title = 8800294,
            AssetList = {
              {
                AssetId = 5100045,
                Name = 8800304,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Number.CustomUI_Icon_Number"
              },
              {
                AssetId = 5100046,
                Name = 8800281,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Number_0.CustomUI_Icon_Number_0"
              },
              {
                AssetId = 5100047,
                Name = 8800282,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Number_1.CustomUI_Icon_Number_1"
              },
              {
                AssetId = 5100048,
                Name = 8800283,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Number_2.CustomUI_Icon_Number_2"
              },
              {
                AssetId = 5100049,
                Name = 8800284,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Number_3.CustomUI_Icon_Number_3"
              },
              {
                AssetId = 5100050,
                Name = 8800285,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Number_4.CustomUI_Icon_Number_4"
              },
              {
                AssetId = 5100051,
                Name = 8800286,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Number_5.CustomUI_Icon_Number_5"
              },
              {
                AssetId = 5100052,
                Name = 8800287,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Number_6.CustomUI_Icon_Number_6"
              },
              {
                AssetId = 5100053,
                Name = 8800288,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Number_7.CustomUI_Icon_Number_7"
              },
              {
                AssetId = 5100054,
                Name = 8800289,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Number_8.CustomUI_Icon_Number_8"
              },
              {
                AssetId = 5100055,
                Name = 8800290,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Number_9.CustomUI_Icon_Number_9"
              }
            }
          }
        }
      },
      [3] = {
        Name = 8800295,
        Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Picture_png.Custom_Icon_Picture_png",
        SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Picture_Select_png.Custom_Icon_Picture_Select_png",
        AssetCategory = {
          [1] = {
            Title = 8800295,
            AssetList = {
              {
                AssetId = 5100056,
                Name = 8800305,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Letter.CustomUI_Icon_Letter"
              },
              {
                AssetId = 5100057,
                Name = 8800306,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_A.CustomUI_Icon_A"
              },
              {
                AssetId = 5100058,
                Name = 8800307,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_B.CustomUI_Icon_B"
              },
              {
                AssetId = 5100059,
                Name = 8800308,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_C.CustomUI_Icon_C"
              },
              {
                AssetId = 5100060,
                Name = 8800309,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_D.CustomUI_Icon_D"
              },
              {
                AssetId = 5100061,
                Name = 8800310,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_E.CustomUI_Icon_E"
              },
              {
                AssetId = 5100062,
                Name = 8800311,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_F.CustomUI_Icon_F"
              },
              {
                AssetId = 5100063,
                Name = 8800312,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_G.CustomUI_Icon_G"
              },
              {
                AssetId = 5100064,
                Name = 8800313,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_H.CustomUI_Icon_H"
              },
              {
                AssetId = 5100065,
                Name = 8800314,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_I.CustomUI_Icon_I"
              },
              {
                AssetId = 5100066,
                Name = 8800315,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_J.CustomUI_Icon_J"
              },
              {
                AssetId = 5100067,
                Name = 8800316,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_K.CustomUI_Icon_K"
              },
              {
                AssetId = 5100068,
                Name = 8800317,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_L.CustomUI_Icon_L"
              },
              {
                AssetId = 5100069,
                Name = 8800318,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_M.CustomUI_Icon_M"
              },
              {
                AssetId = 5100070,
                Name = 8800319,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_N.CustomUI_Icon_N"
              },
              {
                AssetId = 5100071,
                Name = 8800320,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_O.CustomUI_Icon_O"
              },
              {
                AssetId = 5100072,
                Name = 8800321,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_P.CustomUI_Icon_P"
              },
              {
                AssetId = 5100073,
                Name = 8800322,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Q.CustomUI_Icon_Q"
              },
              {
                AssetId = 5100074,
                Name = 8800323,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_R.CustomUI_Icon_R"
              },
              {
                AssetId = 5100075,
                Name = 8800324,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_S.CustomUI_Icon_S"
              },
              {
                AssetId = 5100076,
                Name = 8800325,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_T.CustomUI_Icon_T"
              },
              {
                AssetId = 5100077,
                Name = 8800326,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_U.CustomUI_Icon_U"
              },
              {
                AssetId = 5100078,
                Name = 8800327,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_V.CustomUI_Icon_V"
              },
              {
                AssetId = 5100079,
                Name = 8800328,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_W.CustomUI_Icon_W"
              },
              {
                AssetId = 5100080,
                Name = 8800329,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_X.CustomUI_Icon_X"
              },
              {
                AssetId = 5100081,
                Name = 8800330,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Y.CustomUI_Icon_Y"
              },
              {
                AssetId = 5100082,
                Name = 8800331,
                Image = "/Game/Library/CreativeDL/IG3700/Arts/Icon/CustomUI/128/CustomUI_Icon_Z.CustomUI_Icon_Z"
              }
            }
          }
        }
      },
      [4] = {
        Name = 87163,
        Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Picture_png.Custom_Icon_Picture_png",
        SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Picture_Select_png.Custom_Icon_Picture_Select_png",
        AssetCategory = {
          [1] = {
            Title = 87163,
            AssetList = {
              {
                AssetId = 5100200,
                Name = 87165,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/chaoshen_png.chaoshen_png"
              },
              {
                AssetId = 5100201,
                Name = 87169,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/liansha_png.liansha_png"
              },
              {
                AssetId = 5100202,
                Name = 87166,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/chaoshengzhongzhi_png.chaoshengzhongzhi_png"
              },
              {
                AssetId = 5100203,
                Name = 87164,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/bangshouzhongzhi_png.bangshouzhongzhi_png"
              },
              {
                AssetId = 5100204,
                Name = 87167,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/daozi_png.daozi_png"
              },
              {
                AssetId = 5100205,
                Name = 87168,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/fuchou_02_png.fuchou_02_png"
              },
              {
                AssetId = 5100206,
                Name = 87168,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/fuchou_png.fuchou_png"
              },
              {
                AssetId = 5100207,
                Name = 87178,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/Tmode_shouliezhe_png.Tmode_shouliezhe_png"
              },
              {
                AssetId = 5100208,
                Name = 87174,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/Tmode_chongzhengqigu_png.Tmode_chongzhengqigu_png"
              },
              {
                AssetId = 5100209,
                Name = 81769,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/Tmode_zaijiezaili_png.Tmode_zaijiezaili_png"
              },
              {
                AssetId = 5100210,
                Name = 87173,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/Tmode_baibuchuangyang_png.Tmode_baibuchuangyang_png"
              },
              {
                AssetId = 5100211,
                Name = 87176,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/Tmode_hontianlei_png.Tmode_hontianlei_png"
              },
              {
                AssetId = 5100212,
                Name = 87175,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/Tmode_dakaishajie_png.Tmode_dakaishajie_png"
              },
              {
                AssetId = 5100213,
                Name = 87177,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/Tmode_juedifanji_png.Tmode_juedifanji_png"
              },
              {
                AssetId = 5100214,
                Name = 87179,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/Tmode_suijiazhuangjia_png.Tmode_suijiazhuangjia_png"
              },
              {
                AssetId = 5100215,
                Name = 87180,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/Tomde_diyidixue_png.Tomde_diyidixue_png"
              },
              {
                AssetId = 5100216,
                Name = 87170,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/Match_icon_10_png.Match_icon_10_png"
              },
              {
                AssetId = 5100217,
                Name = 87171,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/Match_icon_11_png.Match_icon_11_png"
              },
              {
                AssetId = 5100218,
                Name = 87172,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/Match_icon_12_png.Match_icon_12_png"
              },
              {
                AssetId = 5100219,
                Name = 87169,
                Image = "/Game/Arts/UI/Atlas/BattleUI/Tmode/Frames/Match_icon_9_png.Match_icon_9_png"
              }
            }
          }
        }
      }
    }
  },
  {
    Name = 8800205,
    Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Text_png.Custom_Icon_Text_png",
    SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Text_Select_png.Custom_Icon_Text_Select_png",
    SubMenu = {
      [1] = {
        Name = 8800205,
        Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Text_png.Custom_Icon_Text_png",
        SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Text_Select_png.Custom_Icon_Text_Select_png",
        AssetCategory = {
          [1] = {
            Title = 8800232,
            AssetList = {
              {
                AssetId = 4201024,
                Name = 8800343,
                Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Text_png.Custom_Icon_Text_png"
              }
            }
          }
        }
      }
    }
  },
  {
    Name = 8800230,
    Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Progress_png.Custom_Icon_Progress_png",
    SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Progress_Select_png.Custom_Icon_Progress_Select_png",
    SubMenu = {
      [1] = {
        Name = 8800230,
        Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Progress_png.Custom_Icon_Progress_png",
        SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Progress_Select_png.Custom_Icon_Progress_Select_png",
        AssetCategory = {
          [1] = {
            Title = 8800232,
            AssetList = {
              {
                AssetId = 4201023,
                Name = 8800342,
                Image = "/Game/Mod/CreativeBase/Arts/NoAtlas/ProgressBar/Ugc_ProgressBar_Icon01.Ugc_ProgressBar_Icon01"
              },
              {
                AssetId = 5100100,
                Name = 8880199,
                Image = HPBarIconPath
              }
            }
          }
        }
      }
    }
  },
  {
    Name = 8888758,
    Image = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Device_Xuanzhong_png.ZD_icon_Device_Xuanzhong_png",
    SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Function_Select_png.Custom_Icon_Function_Select_png",
    SubMenu = {
      [1] = {
        Name = 8888759,
        Image = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Progress_png.Custom_Icon_Progress_png",
        SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Progress_Select_png.Custom_Icon_Progress_Select_png",
        AssetCategory = {
          [1] = {
            Title = 8800232,
            AssetList = {
              {
                AssetId = 5300001,
                Name = 8888760,
                Image = "/Game/Mod/CreativeBase/Arts/NoAtlas/CustomUI/Custom_Icon_Talent.Custom_Icon_Talent"
              },
              {
                AssetId = 5300002,
                Name = 8888761,
                Image = "/Game/Mod/CreativeEdit/Arts/NoAtlas/CustomUI/Custom_Icon_Rect_InfoPanel.Custom_Icon_Rect_InfoPanel"
              }
            }
          }
        }
      }
    }
  },
  {
    Name = 8880412,
    Image = "/Game/Mod/CreativeBase/Arts/Atlas/UI/Frames/ZD_icon_Prefab_Xuanzhong_02_png.ZD_icon_Prefab_Xuanzhong_02_png",
    SelectedImage = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Prefab_Select_png.Custom_Icon_Prefab_Select_png",
    SubMenu = {
      [1] = {
        Name = 8888841,
        AssetCategory = {
          [1] = {
            Title = 8888839,
            AssetList = {
              {
                AssetId = 5310001,
                Name = 8888858,
                Image = "/Game/Mod/CreativeEdit/Arts/NoAtlas/CustomUI/Custom_Icon_TalentTree02.Custom_Icon_TalentTree02"
              },
              {
                AssetId = 5310002,
                Name = 8888857,
                Image = "/Game/Mod/CreativeEdit/Arts/NoAtlas/CustomUI/Custom_Icon_TalentTree01.Custom_Icon_TalentTree01"
              }
            }
          },
          [2] = {
            Title = 2026061403,
            AssetList = {
              {
                AssetId = 5310003,
                Name = 2026061404,
                Image = "/Game/Mod/CreativeEdit/Arts/NoAtlas/CustomUI/Custom_BG_04.Custom_BG_04"
              },
              {
                AssetId = 5310004,
                Name = 2026061405,
                Image = "/Game/Mod/CreativeEdit/Arts/NoAtlas/CustomUI/Custom_BG_02.Custom_BG_02"
              },
              {
                AssetId = 5310005,
                Name = 2026061406,
                Image = "/Game/Mod/CreativeEdit/Arts/NoAtlas/CustomUI/Custom_BG_03.Custom_BG_03"
              },
              {
                AssetId = 5310006,
                Name = 2026061407,
                Image = "/Game/Mod/CreativeEdit/Arts/NoAtlas/CustomUI/Custom_BG_01.Custom_BG_01"
              },
              {
                AssetId = 5310007,
                Name = 2026061408,
                Image = "/Game/Mod/CreativeEdit/Arts/NoAtlas/CustomUI/Custom_BG_05.Custom_BG_05"
              },
              {
                AssetId = 5310008,
                Name = 2026061409,
                Image = "/Game/Mod/CreativeEdit/Arts/NoAtlas/CustomUI/Custom_BG_06.Custom_BG_06"
              }
            }
          }
        }
      },
      [2] = {
        Name = 99009830,
        AssetCategory = {
          [1] = {
            Title = 99009830,
            AssetListFunc = function()
              local logic_ugc_prefab_mall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
              local PrefabType = logic_ugc_prefab_mall.ENUM_PREFAB_TYPE.CUSTOMUI
              local TabType = logic_ugc_prefab_mall.ENUM_FILTER_TYPE.MyPrivate
              local logic_ugc_prefab_mall_asset_mgr = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_asset_mgr")
              local CustomIconMetaList = logic_ugc_prefab_mall_asset_mgr:GetMyPrefabMallMeta(TabType, PrefabType)
              return CustomIconMetaList
            end
          }
        }
      },
      [3] = {
        Name = 8888685,
        AssetCategory = {
          [1] = {
            Title = 8888685,
            AssetListFunc = function()
              local logic_ugc_prefab_mall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
              local PrefabType = logic_ugc_prefab_mall.ENUM_PREFAB_TYPE.CUSTOMUI
              local TabType = logic_ugc_prefab_mall.ENUM_FILTER_TYPE.MyShare
              local logic_ugc_prefab_mall_asset_mgr = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_asset_mgr")
              local CustomIconMetaList = logic_ugc_prefab_mall_asset_mgr:GetMyPrefabMallMeta(TabType, PrefabType)
              return CustomIconMetaList
            end
          }
        }
      },
      [4] = {
        Name = 99009831,
        AssetCategory = {
          [1] = {
            Title = 99009831,
            AssetListFunc = function()
              local logic_ugc_prefab_mall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
              local PrefabType = logic_ugc_prefab_mall.ENUM_PREFAB_TYPE.CUSTOMUI
              local TabType = logic_ugc_prefab_mall.ENUM_FILTER_TYPE.MyFavorite
              local logic_ugc_prefab_mall_asset_mgr = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_asset_mgr")
              local CustomIconMetaList = logic_ugc_prefab_mall_asset_mgr:GetMyPrefabMallMeta(TabType, PrefabType)
              return CustomIconMetaList
            end
          }
        }
      }
    }
  }
}
Config.SelectPanelType = {Color = 1, Image = 2}
Config.E_Align = {
  Left = 1,
  Center = 2,
  Right = 3,
  Top = 4,
  Bottom = 5
}
Config.E_AuxLineOperateType = {Horizontal = 101, Vertical = 102}
Config.GroupItemIconConfig = {
  [Config.ControlType.Example] = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_png.Custom_Icon_Button_png",
  [Config.ControlType.UIGroup] = "/Game/Mod/CreativeBase/Arts/NoAtlas/CustomUI/Official_Icon_Border.Official_Icon_Border",
  [Config.ControlType.Button] = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_png.Custom_Icon_Button_png",
  [Config.ControlType.Image] = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Picture_png.Custom_Icon_Picture_png",
  [Config.ControlType.Text] = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Text_png.Custom_Icon_Text_png",
  [Config.ControlType.ProgressBar] = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Progress_png.Custom_Icon_Progress_png",
  [Config.ControlType.HPBar] = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Progress_png.Custom_Icon_Progress_png",
  [Config.ControlType.TalentNode] = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_png.Custom_Icon_Button_png",
  [Config.ControlType.TalentInfo] = "/Game/Mod/CreativeEdit/Arts/Atlas/Custom/Frames/Custom_Icon_Button_png.Custom_Icon_Button_png"
}
Config.CustomUIParameterConfig = {
  [Config.ControlType.Example] = {
    [1] = {
      ParameterStruct = {
        {
          ParameterTitle = "##Example\232\135\170\229\174\154\228\185\137\229\177\158\230\128\167",
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIExample.PropertyA",
            "CustomUIExample.PropertyB"
          }
        },
        {
          ParameterTitle = "##Example\231\187\167\230\137\191\231\154\132\229\177\158\230\128\167",
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIButton.NormalImage",
            "CustomUIImage.ImageColor",
            "CustomUIBase.Visible"
          }
        }
      }
    },
    [2] = {
      ParameterStruct = {
        {
          ParameterTitle = 8888785,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.ShowOnEvent",
            "CustomUIBase.HideOnEvent"
          }
        },
        {
          ParameterTitle = 8888790,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.OnClickPostEvent"
          }
        }
      }
    }
  },
  [Config.ControlType.Button] = {
    [1] = {
      ParameterStruct = {
        {
          ParameterTitle = 8800252,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIButton.NormalImage",
            "CustomUIButton.NormalImageColor",
            "CustomUIButton.NormalImageOpacity",
            "CustomUIButton.PressedImage",
            "CustomUIButton.PressedImageColor",
            "CustomUIButton.PressedImageOpacity",
            "CustomUIButton.FrameBgType"
          }
        },
        {
          ParameterTitle = 8800205,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIButton.TextVisibility",
            "CustomUIButton.Text",
            "CustomUIButton.TextFontSize",
            "CustomUIButton.TextColor",
            "CustomUIButton.TextOpacity",
            "CustomUIButton.TextHorizontalAlign",
            "CustomUIButton.TextVerticalAlign"
          }
        },
        {
          ParameterTitle = 8800253,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.Opacity",
            "CustomUIBase.BackGroundOpacity",
            "CustomUIBase.Visible",
            "CustomUIBase.Width",
            "CustomUIBase.Height",
            "CustomUIBase.AdaptationInfo",
            "Transform.Location.Z",
            "CustomUIButton.LongPressedTriggerTime",
            "CustomUIBase.FrameVisibility"
          }
        }
      }
    },
    [2] = {
      ParameterStruct = {
        {
          ParameterTitle = 8888785,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.ShowOnEvent",
            "CustomUIBase.HideOnEvent"
          }
        },
        {
          ParameterTitle = 8888790,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.OnClickPostEvent"
          }
        }
      }
    }
  },
  [Config.ControlType.TalentNode] = {
    [1] = {
      ParameterStruct = {
        {
          ParameterTitle = 8800252,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIButton.NormalImage",
            "CustomUIButton.NormalImageColor",
            "CustomUIButton.NormalImageOpacity",
            "CustomUIButton.PressedImage",
            "CustomUIButton.PressedImageColor",
            "CustomUIButton.PressedImageOpacity",
            "CustomUIButton.FrameBgType"
          }
        },
        {
          ParameterTitle = 8888771,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUITalentNode.LineColor",
            "CustomUITalentNode.LineThickness",
            "CustomUITalentNode.bShowArrow"
          }
        },
        {
          ParameterTitle = 8800253,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.Opacity",
            "CustomUIBase.BackGroundOpacity",
            "CustomUIBase.Visible",
            "CustomUIBase.Width",
            "CustomUIBase.Height",
            "CustomUIBase.AdaptationInfo",
            "Transform.Location.Z",
            "CustomUIButton.LongPressedTriggerTime",
            "CustomUIBase.FrameVisibility"
          }
        }
      }
    },
    [2] = {
      bMultiSelectHide = true,
      ParameterStruct = {
        {
          ParameterTitle = 8888775,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "Description"
          }
        },
        "ParentNodes",
        {
          ParameterTitle = 8888779,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "UnlockCondition",
            "ConditionProgress"
          }
        },
        {
          ParameterTitle = 8600211,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "bConsumeItem",
            "ConsumeItemID",
            "ConsumeItemCount"
          }
        },
        {
          ParameterTitle = 65127,
          ParameterTipsTextId = 8888877,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "TalentRewards"
          }
        },
        {
          ParameterTitle = 99009851,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "bSaveToCloud"
          }
        }
      }
    },
    [3] = {
      ParameterStruct = {
        {
          ParameterTitle = 8888785,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "UnLockReceiveEvent",
            "ActiveReceiveEvent",
            "CustomUIBase.ShowOnEvent",
            "CustomUIBase.HideOnEvent"
          }
        },
        {
          ParameterTitle = 8888790,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.OnClickPostEvent",
            "UnlockPostEvent",
            "ActivePostEvent"
          }
        }
      }
    }
  },
  [Config.ControlType.TalentInfo] = {
    [1] = {
      ParameterStruct = {
        {
          ParameterTitle = 8888802,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUITalentInfo.VisibilityType",
            "CustomUITalentInfo.DisplayType"
          }
        },
        {
          ParameterTitle = 8800253,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.Width",
            "CustomUIBase.Height",
            "CustomUIBase.AdaptationInfo",
            "Transform.Location.Z"
          }
        }
      }
    },
    [2] = {
      ParameterStruct = {
        {
          ParameterTitle = 8888785,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.HideOnEvent"
          }
        }
      }
    }
  },
  [Config.ControlType.Image] = {
    [1] = {
      ParameterStruct = {
        {
          ParameterTitle = 8800252,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIImage.Image",
            "CustomUIImage.ImageColor",
            "CustomUIImage.ImageOpacity"
          }
        },
        {
          ParameterTitle = 8800253,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.Opacity",
            "CustomUIBase.BackGroundOpacity",
            "CustomUIBase.Visible",
            "CustomUIBase.Width",
            "CustomUIBase.Height",
            "CustomUIBase.AdaptationInfo",
            "Transform.Location.Z",
            "CustomUIBase.FrameVisibility"
          }
        }
      }
    },
    [2] = {
      ParameterStruct = {
        {
          ParameterTitle = 8888785,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.ShowOnEvent",
            "CustomUIBase.HideOnEvent"
          }
        },
        {
          ParameterTitle = 8888790,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.OnClickPostEvent"
          }
        }
      }
    }
  },
  [Config.ControlType.Text] = {
    [1] = {
      ParameterStruct = {
        {
          ParameterTitle = 8800205,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIText.Text",
            "CustomUIText.TextFontSize",
            "CustomUIText.TextColor",
            "CustomUIText.TextOutline",
            "CustomUIText.TextOutlineColor",
            "CustomUIText.TextOutlineSize",
            "CustomUIText.TextBold",
            "CustomUIText.TextProjection",
            "CustomUIText.TextProjectionColor",
            "CustomUIText.TextProjectionHorizontalOffset",
            "CustomUIText.TextProjectionVerticalOffset",
            "CustomUIText.TextOpacity",
            "CustomUIText.TextHorizontalAlign",
            "CustomUIText.TextVerticalAlign"
          }
        },
        {
          ParameterTitle = 8800253,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.Opacity",
            "CustomUIBase.BackGroundOpacity",
            "CustomUIBase.Visible",
            "CustomUIBase.Width",
            "CustomUIBase.Height",
            "CustomUIBase.AdaptationInfo",
            "Transform.Location.Z",
            "CustomUIBase.FrameVisibility"
          }
        }
      }
    },
    [2] = {
      ParameterStruct = {
        {
          ParameterTitle = 8888785,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.ShowOnEvent",
            "CustomUIBase.HideOnEvent"
          }
        },
        {
          ParameterTitle = 8888790,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.OnClickPostEvent"
          }
        }
      }
    }
  },
  [Config.ControlType.ProgressBar] = {
    [1] = {
      ParameterStruct = {
        {
          ParameterTitle = 8800230,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIProgressBar.bIsShowHPNumber",
            "CustomUIProgressBar.ShowStyle",
            "CustomUIProgressBar.MinValue",
            "CustomUIProgressBar.MaxValue",
            "CustomUIProgressBar.DefaultValue",
            "CustomUIProgressBar.FillImageColor",
            "CustomUIProgressBar.NameTextLocation",
            "CustomUIProgressBar.NameTextFontSize",
            "CustomUIProgressBar.NameTextColor",
            "CustomUIProgressBar.TextOpacity"
          }
        },
        {
          ParameterTitle = 8800253,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.Opacity",
            "CustomUIBase.BackGroundOpacity",
            "CustomUIBase.Visible",
            "CustomUIBase.Width",
            "CustomUIBase.Height",
            "CustomUIBase.AdaptationInfo",
            "Transform.Location.Z",
            "CustomUIBase.FrameVisibility"
          }
        }
      }
    },
    [2] = {
      ParameterStruct = {
        {
          ParameterTitle = 8888785,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.ShowOnEvent",
            "CustomUIBase.HideOnEvent"
          }
        },
        {
          ParameterTitle = 8888790,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.OnClickPostEvent"
          }
        }
      }
    }
  },
  [Config.ControlType.HPBar] = {
    [1] = {
      ParameterStruct = {
        {
          ParameterTitle = 8800230,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIProgressBar.bIsShowHPNumber",
            "CustomUIProgressBar.ShowStyle",
            "CustomUIProgressBar.MinValue",
            "CustomUIProgressBar.MaxValue",
            "CustomUIProgressBar.DefaultValue",
            "CustomUIProgressBar.FillImageColor",
            "CustomUIProgressBar.NameTextLocation",
            "CustomUIProgressBar.NameTextFontSize",
            "CustomUIProgressBar.NameTextColor",
            "CustomUIProgressBar.TextOpacity"
          }
        },
        {
          ParameterTitle = 8800253,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.Opacity",
            "CustomUIBase.BackGroundOpacity",
            "CustomUIBase.Visible",
            "CustomUIBase.Width",
            "CustomUIBase.Height",
            "CustomUIBase.AdaptationInfo",
            "Transform.Location.Z",
            "CustomUIBase.FrameVisibility"
          }
        }
      }
    },
    [2] = {
      ParameterStruct = {
        {
          ParameterTitle = 8888785,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.ShowOnEvent",
            "CustomUIBase.HideOnEvent"
          }
        },
        {
          ParameterTitle = 8888790,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.OnClickPostEvent"
          }
        }
      }
    }
  },
  [Config.ControlType.UIGroup] = {
    [1] = {
      ParameterStruct = {
        {
          ParameterTitle = 8800253,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.Visible",
            "CustomUIBase.Width",
            "CustomUIBase.Height",
            "CustomUIBase.AdaptationInfo",
            "Transform.Location.Z"
          }
        }
      }
    },
    [2] = {
      ParameterStruct = {
        {
          ParameterTitle = 8888785,
          EditType = CreativeGlobalDefine.Enum_ParameterEditType.Struct,
          ParameterStruct = {
            "CustomUIBase.ShowOnEvent",
            "CustomUIBase.HideOnEvent"
          }
        }
      }
    }
  }
}
Config.DefaultUITabConfig = {8888763, 8888765}
Config.SpecialCustomUITabConfig = {
  [Config.ControlType.TalentNode] = {
    8888763,
    8888764,
    8888765
  }
}
Config.EAdaptationType = {
  Horizon = 0,
  Left = 1,
  Right = 2,
  LeftAndRight = 3,
  Vertical = 4,
  Bottom = 5,
  Top = 6,
  BottomAndTop = 7
}
function Config.Init()
  for CtrlType, v in ipairs(Config.LeftMenuConfig) do
    for i, v1 in ipairs(v.SubMenu) do
      if v1.AssetCategory then
        for j, v2 in ipairs(v1.AssetCategory) do
          if v2.AssetList then
            for k, v3 in ipairs(v2.AssetList) do
              local AssetId = v3.AssetId
              local AssetInfo = v3
              Config.AssetMap[AssetId] = AssetInfo
            end
          end
        end
      end
    end
  end
end
function Config.GetAssetInfo(AssetId)
  return Config.AssetMap[AssetId]
end
Config.Init()
return Config