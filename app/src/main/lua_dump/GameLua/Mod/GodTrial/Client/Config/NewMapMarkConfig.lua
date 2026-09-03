local NewMapMarkConfig = {
  LegendTagMap = {
    ["10001"] = {
      "DungeonArea1",
      "DungeonArea2"
    },
    ["10002"] = {"BossArea"}
  },
  [440001] = {
    UIPath = "/Game/Mod/EvoBase/BluePrints/UI/MapItem/CommonCountdownMapMark_UIBP.CommonCountdownMapMark_UIBP_C",
    bIsUpdateSize = true,
    ZOrder = 5,
    CommonMarkConfig = {
      [1] = {
        UpdateWidget = "Image_Icon",
        IconVisibleArray = {
          UEnums.ESlateVisibility.Collapsed,
          UEnums.ESlateVisibility.Collapsed
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
  },
  [440002] = {
    UIPath = "/Game/Mod/EvoBase/BluePrints/UI/MapItem/CommonCountdownMapMark_UIBP.CommonCountdownMapMark_UIBP_C",
    bIsUpdateSize = true,
    ZOrder = 5,
    CommonMarkConfig = {
      [1] = {
        UpdateWidget = "Image_Icon",
        IconVisibleArray = {
          UEnums.ESlateVisibility.Collapsed,
          UEnums.ESlateVisibility.Collapsed
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
  },
  [440003] = {
    UIPath = "/Game/Mod/GodTrial/BluePrints/UI/Mark/FramePlatformMapMark_UIBP.FramePlatformMapMark_UIBP_C",
    bIsUpdateSize = true,
    ZOrder = 3,
    CommonMarkConfig = {
      [1] = {
        UpdateWidget = "Image_Icon",
        IconPathArray = {
          "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_SHTPositioning02_png.ZD_Icon_SHTPositioning02_png",
          "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_SHTPositioning03_png.ZD_Icon_SHTPositioning03_png",
          "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_SHTPositioning03_png.ZD_Icon_SHTPositioning03_png",
          "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_SHTPositioning03_png.ZD_Icon_SHTPositioning03_png",
          "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_SHTPositioning04_png.ZD_Icon_SHTPositioning04_png",
          "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_SHTPositioning02_png.ZD_Icon_SHTPositioning02_png"
        }
      },
      [2] = {
        UpdateWidget = "CanvasPanel_Time",
        IconVisibleArray = {
          UEnums.ESlateVisibility.SelfHitTestInvisible,
          UEnums.ESlateVisibility.Collapsed,
          UEnums.ESlateVisibility.SelfHitTestInvisible,
          UEnums.ESlateVisibility.SelfHitTestInvisible,
          UEnums.ESlateVisibility.Collapsed,
          UEnums.ESlateVisibility.Collapsed
        }
      },
      [3] = {
        UpdateWidget = "CanvasPanel_Finished",
        IconVisibleArray = {
          UEnums.ESlateVisibility.Collapsed,
          UEnums.ESlateVisibility.Collapsed,
          UEnums.ESlateVisibility.Collapsed,
          UEnums.ESlateVisibility.Collapsed,
          UEnums.ESlateVisibility.SelfHitTestInvisible,
          UEnums.ESlateVisibility.SelfHitTestInvisible
        }
      }
    }
  },
  [440004] = {
    UIPath = "/Game/Mod/EvoBase/BluePrints/UI/MapItem/CommonCountdownMapMark_UIBP.CommonCountdownMapMark_UIBP_C",
    bIsUpdateSize = true,
    Size = FVector2D(100, 50),
    ZOrder = 6,
    CommonMarkConfig = {
      [1] = {
        UpdateWidget = "Image_Icon",
        IconPathArray = {
          "/Game/Mod/GodTrial/Arts/UI/NoAtlas/ZD_Castle_NameBackGround01.ZD_Castle_NameBackGround01",
          "/Game/Mod/GodTrial/Arts/UI/NoAtlas/ZD_Castle_NameBackGround02.ZD_Castle_NameBackGround02"
        },
        IconVisibleArray = {
          UEnums.ESlateVisibility.Collapsed,
          UEnums.ESlateVisibility.SelfHitTestInvisible
        },
        CanHighlightArray = {false, true}
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
    },
    bIsControlByLegend = true,
    LegendTags = "",
    LegendIconPath = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_Castle_png.ZD_Icon_Castle_png",
    LegendTextID = 4401006
  },
  [440005] = {
    UIPath = "/Game/Mod/EvoBase/BluePrints/UI/MapItem/CommonCountdownMapMark_UIBP.CommonCountdownMapMark_UIBP_C",
    bIsUpdateSize = true,
    ZOrder = 5,
    CommonMarkConfig = {
      [1] = {
        UpdateWidget = "Image_Icon",
        IconVisibleArray = {
          UEnums.ESlateVisibility.Collapsed,
          UEnums.ESlateVisibility.Collapsed
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
  },
  [420015] = {
    UIPath = "/Game/Library/Res/AI/Centaur/Arts/UI/Atlas/Frames/ZD_Icon_Map_Centaur_png.ZD_Icon_Map_Centaur_png",
    bIsIcon = true,
    Size = FVector2D(32, 32),
    bIsBindActor = true,
    ZOrder = 2
  },
  [420016] = {
    UIPath = "/Game/Library/Res/AI/Centaur/Arts/UI/Atlas/Frames/ZD_Icon_Map_Centaur_png.ZD_Icon_Map_Centaur_png",
    bIsIcon = true,
    Size = FVector2D(32, 32),
    ZOrder = 2
  },
  [420017] = {
    UIPath = "/Game/Mod/GodTrial/BluePrints/UI/Mark/GodTrialGeneralMapMark_UIBP.GodTrialGeneralMapMark_UIBP_C",
    bIsUpdateSize = true,
    Size = FVector2D(32, 32),
    CommonMarkConfig = {
      [1] = {
        UpdateWidget = "Image_Icon",
        IconPathArray = {
          "/Game/Mod/GodTrial/Arts/UI/NoAtlas/ZD_Flag_NameBackGround02.ZD_Flag_NameBackGround02",
          "/Game/Mod/GodTrial/Arts/UI/NoAtlas/ZD_Flag_NameBackGround01.ZD_Flag_NameBackGround01"
        }
      }
    },
    bIsControlByLegend = true,
    LegendTags = "",
    LegendIconPath = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_Flag_png.ZD_Icon_Flag_png",
    LegendTextID = 4402029
  },
  [420018] = {
    UIPath = "/Game/Mod/GodTrial/BluePrints/UI/Mark/GodTrialGeneralMapMark_UIBP.GodTrialGeneralMapMark_UIBP_C",
    bIsUpdateSize = true,
    Size = FVector2D(64, 32),
    CommonMarkConfig = {
      [1] = {
        UpdateWidget = "Image_Icon",
        IconPathArray = {
          "/Game/Mod/GodTrial/Arts/UI/NoAtlas/ZD_LRS_NameBackGround02.ZD_LRS_NameBackGround02",
          "/Game/Mod/GodTrial/Arts/UI/NoAtlas/ZD_LRS_NameBackGround01.ZD_LRS_NameBackGround01"
        }
      }
    },
    bIsControlByLegend = true,
    LegendTags = "",
    LegendIconPath = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_LRS_png.ZD_Icon_LRS_png",
    LegendTextID = 4402043
  },
  [420019] = {
    UIPath = "/Game/Mod/GodTrial/BluePrints/UI/Mark/GodTrialGeneralMapMark_UIBP.GodTrialGeneralMapMark_UIBP_C",
    bIsUpdateSize = true,
    Size = FVector2D(48, 24),
    CommonMarkConfig = {
      [1] = {
        UpdateWidget = "Image_Icon",
        IconPathArray = {
          "/Game/Mod/GodTrial/Arts/UI/NoAtlas/ZD_Wings_NameBackGround02.ZD_Wings_NameBackGround02",
          "/Game/Mod/GodTrial/Arts/UI/NoAtlas/ZD_Wings_NameBackGround01.ZD_Wings_NameBackGround01"
        }
      }
    },
    bIsControlByLegend = true,
    LegendTags = "",
    LegendIconPath = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_FlyingWing_png.ZD_Icon_FlyingWing_png",
    LegendTextID = 4402015
  },
  [420020] = {
    UIPath = "/Game/Mod/GodTrial/BluePrints/UI/Mark/GodTrialGeneralMapMark_UIBP.GodTrialGeneralMapMark_UIBP_C",
    bIsUpdateSize = true,
    Size = FVector2D(16, 32),
    CommonMarkConfig = {
      [1] = {
        UpdateWidget = "Image_Icon",
        IconPathArray = {
          "/Game/Mod/GodTrial/Arts/UI/NoAtlas/ZD_SHT_NameBackGround02.ZD_SHT_NameBackGround02",
          "/Game/Mod/GodTrial/Arts/UI/NoAtlas/ZD_SHT_NameBackGround01.ZD_SHT_NameBackGround01"
        }
      }
    },
    bIsControlByLegend = true,
    LegendTags = "",
    LegendIconPath = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_SHT_png.ZD_Icon_SHT_png",
    LegendTextID = 4401028
  },
  [440021] = {
    UIPath = "/Game/Mod/EvoBase/BluePrints/UI/MapItem/CommonCountdownMapMark_UIBP.CommonCountdownMapMark_UIBP_C",
    bIsUpdateSize = true,
    Size = FVector2D(75, 75),
    CommonMarkConfig = {
      [1] = {
        UpdateWidget = "Image_Icon",
        IconPathArray = {
          "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_Casrriage_png.ZD_Icon_Casrriage_png",
          "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_Casrriage_Gray_png.ZD_Icon_Casrriage_Gray_png"
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
    },
    bIsControlByLegend = true,
    LegendTags = "DungeonArea1",
    LegendIconPath = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_Casrriage_png.ZD_Icon_Casrriage_png",
    LegendTextID = 4401099,
    ZOrder = 2
  },
  [440022] = {
    UIPath = "/Game/Mod/EvoBase/BluePrints/UI/MapItem/CommonCountdownMapMark_UIBP.CommonCountdownMapMark_UIBP_C",
    bIsUpdateSize = true,
    Size = FVector2D(32, 32),
    CommonMarkConfig = {
      [1] = {
        UpdateWidget = "Image_Icon",
        IconPathArray = {
          "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_Map_GodTeleport_png.ZD_Icon_Map_GodTeleport_png"
        }
      },
      [2] = {
        UpdateWidget = "CanvasPanel_Time",
        IconVisibleArray = {
          UEnums.ESlateVisibility.Collapsed
        }
      },
      [3] = {
        UpdateWidget = "Image_BG",
        IconVisibleArray = {
          UEnums.ESlateVisibility.Collapsed
        }
      }
    },
    bIsControlByLegend = true,
    LegendTags = "DungeonArea2",
    LegendIconPath = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_Map_GodTeleport_png.ZD_Icon_Map_GodTeleport_png",
    LegendTextID = 440400066,
    ZOrder = 0
  }
}
return NewMapMarkConfig