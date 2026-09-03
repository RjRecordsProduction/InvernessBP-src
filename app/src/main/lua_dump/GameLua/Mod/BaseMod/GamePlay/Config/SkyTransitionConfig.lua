local SkyTransitionConfig = {
  [1] = {
    Name = "Normal",
    Priority = -1,
    IsDefault = true,
    TransitionCDTime = 5,
    Map = {
      Baltic = {
        PUBG_Forest_SunnyDay = {
          Name = "Baltic_Sunny",
          Sequence = "/Game/Mod/EvoBase/Arts_Scenes/Weather/Sequence/SEQ_Baltic_SunnyDay.SEQ_Baltic_SunnyDay",
          Material = "/Game/Arts_Scenes/_Baltic/Sky/Materials/MI_Baltic_New_Sunny.MI_Baltic_New_Sunny"
        },
        PUBG_Forest_SunnyDay_High = {
          Name = "Baltic_Sunny_High",
          Sequence = "/Game/Mod/EvoBase/Arts_Scenes/Weather/Sequence/SEQ_Baltic_SunnyDay_High.SEQ_Baltic_SunnyDay_High",
          Material = "/Game/Arts_Scenes/_Baltic/Sky/Materials/MI_Baltic_New_Sunny.MI_Baltic_New_Sunny"
        },
        PUBG_Forest_RainyDay = {
          Name = "Baltic_Rainy",
          Sequence = "/Game/Mod/EvoBase/Arts_Scenes/Weather/Sequence/SEQ_Baltic_RainyDay.SEQ_Baltic_RainyDay",
          Material = "/Game/Arts_Scenes/_Baltic/Sky/Materials/MI_Baltic_New_Cloudy.MI_Baltic_New_Cloudy"
        },
        PUBG_Forest_SunnyDay_2UpDate = {
          Name = "Baltic_Dusk",
          Sequence = "/Game/Mod/EvoBase/Arts_Scenes/Weather/Sequence/SEQ_Baltic_SunnyDay_2UpDate.SEQ_Baltic_SunnyDay_2UpDate",
          Material = "/Game/Arts_Scenes/_Baltic/Sky/Materials/MI_Baltic_New_Sunset.MI_Baltic_New_Sunset"
        }
      },
      Livik = {
        FourMaps_SunnyDay = {
          Name = "Livik_Sunny",
          Sequence = "/Game/Mod/Livik/Arts_Scenes/Sequence/SEQ_Livik_SunnyDay.SEQ_Livik_SunnyDay",
          Material = "/Game/Mod/Livik/Livik_Scenes_New/Landscape/Sky/Sky_SphereTexturesMap_SunnyDay_Inst.Sky_SphereTexturesMap_SunnyDay_Inst"
        },
        FourMaps_Dusk = {
          Name = "Livik_Dusk",
          Sequence = "/Game/Mod/Livik/Arts_Scenes/Sequence/SEQ_Livik_Dusk.SEQ_Livik_Dusk",
          Material = "/Game/Mod/Livik/Livik_Scenes_New/Landscape/Sky/Sky_SphereTexturesMap_Dusk.Sky_SphereTexturesMap_Dusk"
        },
        FourMaps_Morning = {
          Name = "Livik_Morning",
          Sequence = "/Game/Mod/Livik/Arts_Scenes/Sequence/SEQ_Livik_Morning.SEQ_Livik_Morning",
          Material = "/Game/Mod/Livik/Livik_Scenes_New/Landscape/Sky/Sky_SphereTexturesMap_Morning.Sky_SphereTexturesMap_Morning"
        }
      },
      Neon = {
        Neon_Weather_SunnyDay01 = {
          Name = "Neon_Sunny",
          Sequence = "/Game/Mod/Neon/Maps/PUBG_Neon/Weather/Sequence/SEQ_Neon_SunnyDay.SEQ_Neon_SunnyDay",
          Material = "/Game/Mod/Neon/Arts_Scenes/_Neon/Sky/DihorOtok_SunnyDay_Inst1.DihorOtok_SunnyDay_Inst1"
        },
        Neon_Weather_SunnyDay01_High = {
          Name = "Neon_Sunny_High",
          Sequence = "/Game/Mod/Neon/Maps/PUBG_Neon/Weather/Sequence/SEQ_Neon_SunnyDay.SEQ_Neon_SunnyDay",
          Material = "/Game/Mod/Neon/Arts_Scenes/_Neon/Sky/DihorOtok_SunnyDay_Inst1.DihorOtok_SunnyDay_Inst1"
        },
        Neon_Weather_Dark01 = {
          Name = "Neon_Dark",
          Sequence = "/Game/Mod/Neon/Maps/PUBG_Neon/Weather/Sequence/SEQ_Neon_Dark.SEQ_Neon_Dark",
          Material = "/Game/Mod/Neon/Arts_Scenes/_Neon/Sky/Neon_Sky_Dark01_Inst.Neon_Sky_Dark01_Inst"
        },
        Neon_Weather_Dark01_High = {
          Name = "Neon_Dark_High",
          Sequence = "/Game/Mod/Neon/Maps/PUBG_Neon/Weather/Sequence/SEQ_Neon_Dark.SEQ_Neon_Dark",
          Material = "/Game/Mod/Neon/Arts_Scenes/_Neon/Sky/Neon_Sky_Dark01_Inst.Neon_Sky_Dark01_Inst"
        }
      },
      Desert = {
        PUBG_Desert_SunnyDay = {
          Name = "Desert_Sunny",
          Sequence = "/Game/Arts_Scenes/Desert/Weather/SEQ_Desert_N2Sunnyday.SEQ_Desert_N2Sunnyday",
          Material = "/Game/Arts_Scenes/Materials/Sky/Sky_Desert_Clear_01.Sky_Desert_Clear_01"
        }
      },
      Borderland = {
        Borderland_Weather_SunnyDay = {
          Name = "Borderland_Dark",
          Sequence = "/Game/Mod/Borderland/Maps/PUBG_Borderland/Weather/Sequence/SEQ_Borderland_SunnyDay.SEQ_Borderland_SunnyDay",
          Material = "/Game/Mod/Borderland/Arts_Scenes/_Borderland/Sky/DihorOtok_SunnyDay_Inst.DihorOtok_SunnyDay_Inst"
        },
        Borderland_Weather_Dark = {
          Name = "Borderland_Dark",
          Sequence = "/Game/Mod/Borderland/Maps/PUBG_Borderland/Weather/Sequence/SEQ_Borderland_Dark.SEQ_Borderland_Dark",
          Material = "/Game/Mod/Borderland/Arts_Scenes/_Borderland/Sky/BorderLand_SKy_Dark.BorderLand_SKy_Dark"
        }
      },
      DihorOtok = {
        PUBG_DihorOtok_SunnyDay = {
          Name = "DihorOtok_SunnyDay",
          Sequence = "/Game/Maps/PUBG_DihorOtok/Weather/Sequence/SEQ_DihorOtok_SunnyDay.SEQ_DihorOtok_SunnyDay",
          Material = "/Game/Arts_Scenes/_DihorOtok/Sky/Materials/DihorOtok_SunnyDay_Inst.DihorOtok_SunnyDay_Inst"
        },
        PUBG_DihorOtok_SnowToSquall = {
          Name = "DihorOtok_SnowToSquall",
          Sequence = "/Game/Maps/PUBG_DihorOtok/Weather/Sequence/SEQ_DihorOtok_SnowToSquall.SEQ_DihorOtok_SnowToSquall",
          Material = "/Game/Arts_Scenes/_DihorOtok/Sky/Materials/M_Sky_SnowToSquall_Inst.M_Sky_SnowToSquall_Inst"
        },
        PUBG_DihorOtok_SnowToSquall2 = {
          Name = "DihorOtok_SnowToSquall2",
          Sequence = "/Game/Maps/PUBG_DihorOtok/Weather/Sequence/SEQ_DihorOtok_SnowToSquall2.SEQ_DihorOtok_SnowToSquall2",
          Material = "/Game/Arts_Scenes/_DihorOtok/Sky/Materials/M_Sky_SnowToSquall_Inst.M_Sky_SnowToSquall_Inst"
        }
      },
      Savage = {
        PUBG_Savage_SunnyDay = {
          Name = "Savage_SunnyDay",
          Sequence = "/Game/Maps/PUBG_Savage/Weather/Sequence/SEQ_Savage_SunnyDay.SEQ_Savage_SunnyDay",
          Material = "/Game/Arts_Scenes/_Savage/Sky/Materials/SKY_Savage_Clear01.SKY_Savage_Clear01"
        },
        PUBG_Savage_RainyDay = {
          Name = "Savage_RainyDay",
          Sequence = "/Game/Maps/PUBG_Savage/Weather/Sequence/SEQ_Savage_RainyDay.SEQ_Savage_RainyDay",
          Material = "/Game/Arts_Scenes/_Savage/Buildings/Materials/M_SkySunnyToFoggy_SphereTex_Inst.M_SkySunnyToFoggy_SphereTex_Inst"
        }
      },
      Karakin = {
        Summerland_Weather_SunnyDay = {
          Name = "Karakin_SunnyDay",
          Sequence = "/Game/Mod/Karakin/Maps/PUBG_Summerland/Weather/Sequence/SEQ_Karakin_SunnyDay.SEQ_Karakin_SunnyDay",
          Material = "/Game/Mod/Karakin/Arts_Scenes/_Summerland/Sky/Mat_Summerland_Sky.Mat_Summerland_Sky"
        }
      }
    }
  },
  [8001] = {
    Name = "FinalKill_Rainy",
    Sequence = "/Game/Res/IG3200/Arts_PlayerBluePrints/FinalKill/SEQ_FinalKill_Island_Day.SEQ_FinalKill_Island_Day",
    Material = "/Game/Res/IG3200/Arts_PlayerBluePrints/Sky/Mat/UGC_SunnyDay_Inst.UGC_SunnyDay_Inst",
    Priority = 99999,
    Preload = false
  },
  [8002] = {
    Name = "SnowHouse_Snow",
    Sequence = "/Game/Library/Res/Actors/Festival/Arts_PlayerBluePrints/LevelSequence/SEQ_POI_Cip_01.SEQ_POI_Cip_01",
    Material = "/Game/Library/Res/Actors/Festival/Arts_Scenes/Sky/MI_Iceworld4_Sky_04.MI_Iceworld4_Sky_04",
    Priority = 10,
    Preload = false
  }
}
return SkyTransitionConfig