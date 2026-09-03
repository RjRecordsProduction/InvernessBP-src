local BUTTON_EXPAND_WIDTH = 76
local BUTTON_FOLD_WIDTH = 66
local Config = {
  ExpandList = {
    EState = {Expand = 1, Fold = 2},
    BackgroundPositionX = {-580, -487},
    Background1PositionX = {-229.3, -139.0},
    ItemListContainerWidth = {167, 78},
    ItemSizeBoxContainerWidth = {164, 70},
    FunctionButtonWidth = {76, 66},
    PopupWidgetPaddingRight = {230, 140},
    DropPaddingRight = {490, 400},
    FunctionButtonBackground = {
      Button_Drop_Image = {BUTTON_EXPAND_WIDTH, BUTTON_FOLD_WIDTH},
      Button_Equip_Image = {BUTTON_EXPAND_WIDTH, BUTTON_FOLD_WIDTH},
      UnableToEquip_Image = {
        BUTTON_EXPAND_WIDTH + 4,
        BUTTON_FOLD_WIDTH + 4
      },
      Button_DropPartly_Image = {BUTTON_EXPAND_WIDTH, BUTTON_FOLD_WIDTH},
      DropPartlyDisableState_Image = {
        BUTTON_EXPAND_WIDTH + 4,
        BUTTON_FOLD_WIDTH + 4
      },
      Button_DropAll_Image = {BUTTON_EXPAND_WIDTH, BUTTON_FOLD_WIDTH},
      Button_DropUAV_Image = {BUTTON_EXPAND_WIDTH, BUTTON_FOLD_WIDTH},
      Button_UseUAV_Image = {BUTTON_EXPAND_WIDTH, BUTTON_FOLD_WIDTH},
      Button_CallBack_Image = {BUTTON_EXPAND_WIDTH, BUTTON_FOLD_WIDTH},
      Button_Controll_Image = {BUTTON_EXPAND_WIDTH, BUTTON_FOLD_WIDTH},
      Button_DropUAV2_Image = {BUTTON_EXPAND_WIDTH, BUTTON_FOLD_WIDTH},
      Button_UseUAV2_Image = {BUTTON_EXPAND_WIDTH, BUTTON_FOLD_WIDTH},
      Button_DisdropUAV_Image = {BUTTON_EXPAND_WIDTH, BUTTON_FOLD_WIDTH},
      Button_DisuseUAV_Image = {BUTTON_EXPAND_WIDTH, BUTTON_FOLD_WIDTH}
    },
    GridPanelIndex = {
      Button_Drop = {
        Row = {0, 1},
        Column = {0, 0}
      },
      Button_Equip = {
        Row = {0, 0},
        Column = {1, 0}
      },
      UnableToEquip = {
        Row = {0, 0},
        Column = {1, 0}
      },
      Button_DropAll = {
        Row = {0, 1},
        Column = {1, 0}
      },
      Button_0 = {
        Row = {0, 1},
        Column = {0, 0}
      },
      Button_1 = {
        Row = {0, 0},
        Column = {1, 0}
      },
      Button_CallBack = {
        Row = {0, 1},
        Column = {0, 0}
      },
      Button_Controll = {
        Row = {0, 0},
        Column = {1, 0}
      },
      Button_Drop2 = {
        Row = {0, 1},
        Column = {0, 0}
      },
      Button_6 = {
        Row = {0, 0},
        Column = {1, 0}
      },
      Button_7 = {
        Row = {0, 1},
        Column = {0, 0}
      },
      Button_8 = {
        Row = {0, 0},
        Column = {1, 0}
      }
    }
  }
}
return Config