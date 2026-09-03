local SDoublePath = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/Double_Item.Double_Item"
local GraphicConst = {
  bUseV2 = true,
  SDoublePath = SDoublePath,
  FavorDef = {
    BestQuality = 1,
    Balance = 2,
    FrameRate = 3,
    Custom = 4
  },
  FavorTextDef = {
    BestQuality = 200000423,
    Balance = 200000424,
    FrameRate = 200000425,
    Custom = 200000426
  },
  CustomTabDef = {
    Global = 999,
    Battle = 0,
    Lobby = 1,
    Home = 2,
    MainCity = 3
  },
  FPSLevelDef = {
    FPS15 = 1,
    FPS20 = 2,
    FPS25 = 3,
    FPS30 = 4,
    FPS40 = 5,
    FPS60 = 6,
    FPS90 = 7,
    FPS120 = 8
  },
  ItemConfig = {
    Favor_Item = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/Favor_Item.Favor_Item",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Favor_Item"
    },
    HDR_Item = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/HDR_Item.HDR_Item",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_HDR_Item"
    },
    FPSFT = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/FPSFT_Item.FPSFT_Item",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT"
    },
    CustomTab = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/LobbyBattle_Item.LobbyBattle_Item",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_CustomTab"
    },
    Quality = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/Quality_Item.Quality_Item",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Quality"
    },
    QualityCompare = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/Quality_Compare.Quality_Compare"
    },
    FPS = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/FPS_Item.FPS_Item",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS"
    },
    FPSFT2 = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/FPSFT_Item.FPSFT_Item",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT"
    },
    MSAA = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/MSAA_Item.MSAA_Item",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_MSAA"
    },
    Reflection = {
      Path = SDoublePath,
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Reflection"
    },
    EnergySaving = {
      Path = SDoublePath,
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_EnergySaving"
    },
    Shadow = {
      Path = SDoublePath,
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Shadow"
    },
    AutoSmooth = {
      Path = SDoublePath,
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_AutoSmooth"
    },
    VivoTurbo = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/Turbo_Item.Turbo_Item",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_VivoTurbo"
    },
    VulkanTurbo = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/Turbo_Item.Turbo_Item",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_VulkanTurbo"
    },
    Line = {
      Path = "/Game/UMG/UI_BP/NewSetting/Setting_Common_Line_item.Setting_Common_Line_item",
      type = "Line"
    },
    Line2 = {
      Path = "/Game/UMG/UI_BP/NewSetting/Setting_Common_Line_item.Setting_Common_Line_item",
      type = "Line"
    },
    Line3 = {
      Path = "/Game/UMG/UI_BP/NewSetting/Setting_Common_Line_item.Setting_Common_Line_item",
      type = "Line"
    },
    Line4 = {
      Path = "/Game/UMG/UI_BP/NewSetting/Setting_Common_Line_item.Setting_Common_Line_item",
      type = "Line"
    },
    Line5 = {
      Path = "/Game/UMG/UI_BP/NewSetting/Setting_Common_Line_item.Setting_Common_Line_item",
      type = "Line"
    },
    Style = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/Style_Item.Style_Item",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Style"
    },
    ColorBlind = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/ColorBlind_Item.ColorBlind_Item",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_ColorBlind"
    },
    Brightness = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/Bright_Item.Bright_Item",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Brightness"
    },
    SpecialScreen = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/SpecialScreen_Item.SpecialScreen_Item",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_SpecialScreen"
    },
    EnhanceLobby = {
      Path = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/EnhanceLobby_Item.EnhanceLobby_Item",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_EnhanceLobby"
    },
    TitleParam = {
      Path = "/Game/UMG/UI_BP/Setting25/Item/WBP_Setting_Title.WBP_Setting_Title",
      Script = "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_TitleParam"
    }
  }
}
return GraphicConst