local TeachingLevelConfig = {}
local EditCfg = require("GameLua.Mod.CreativeBase.Client.CreativeModeEditMainCtrl.CreativeModeEditCfg")
TeachingLevelConfig.LevelEnum = {
  Level1_PlaceGuide = 1,
  Level2_RotateGuide = 2,
  Level3_MoveGuide = 3,
  Level4_ActionGuide = 4,
  Level5_SaveGuide = 5
}
TeachingLevelConfig.DefaultConfig = {
  ViewMode = EditCfg.EditMode.FreeView,
  InitBins = {},
  bCanSave = false,
  AudioPath = "/Game/Mod/CreativeBase/WwiseEvent/Destructible_Music_350/Play_Destructible_Music_350.Play_Destructible_Music_350"
}
TeachingLevelConfig.LuaLevelConfig = {
  [1] = {
    InitBins = {
      "NewBie_Level01_Start",
      "NewBie_Level01_Base",
      "NewBie_Level01_AirWall"
    }
  },
  [2] = {
    InitBins = {
      "NewBie_Level02_Start",
      "NewBie_Level02_Base",
      "NewBie_Level02_AirWall"
    }
  },
  [3] = {
    InitBins = {
      "NewBie_Level03_Start",
      "NewBie_Level03_Base",
      "NewBie_Level03_AirWall"
    }
  },
  [4] = {
    InitBins = {
      "NewBie_Level04_Start",
      "NewBie_Level04_Base",
      "NewBie_Level04_AirWall"
    }
  },
  [5] = {
    InitBins = {
      "NewBie_Level05_All"
    },
    bCanSave = true
  },
  [101] = {
    InitBins = {
      "Level_11_Start"
    }
  },
  [102] = {
    InitBins = {
      "BinData_New41_Test"
    }
  },
  [103] = {
    InitBins = {
      "Level_21_All"
    }
  },
  [104] = {
    InitBins = {
      "BinData_New43_Test"
    }
  },
  [105] = {
    InitBins = {
      "Level_23_Start"
    }
  },
  [106] = {
    InitBins = {
      "BinData_New45_Test"
    },
    bCanSave = true
  }
}
TeachingLevelConfig.LuaLevelConfig = {}
function TeachingLevelConfig.GetLevelConfig(LevelID)
  if LevelID == nil then
    return
  end
  local TeachingConfig = CDataTable.GetTable("UGCNoviceTeachingConfig")[LevelID]
  if not TeachingConfig then
    return nil
  end
  local TableUtil = require("common.table_util")
  TeachingConfig = TableUtil.CopyTable(TeachingConfig)
  for key, value in pairs(TeachingLevelConfig.DefaultConfig) do
    if not TeachingConfig[key] then
      TeachingConfig[key] = value
    end
  end
  if TeachingLevelConfig.LuaLevelConfig[LevelID] then
    for key, value in pairs(TeachingLevelConfig.LuaLevelConfig[LevelID]) do
      TeachingConfig[key] = value
    end
  end
  return TeachingConfig
end
return TeachingLevelConfig