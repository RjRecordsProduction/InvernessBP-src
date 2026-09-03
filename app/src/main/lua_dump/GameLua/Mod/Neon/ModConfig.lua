local ModConfig = {
  Import = {
    Config = {
      GamePlay = {
        PlaneShowConfig = {
          OnPostMerge = function(Result, Context)
            local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
            if GameMainConfig.HasExtraModule("PMGC2025") then
              local PMGCConfig = require("GameLua.ExtraModule.PMGC2025.Gameplay.Config.PMGCConfig")
              local TimeUtil = require("client.common.time_util")
              local nowTime = TimeUtil.GetServerTimeInSec()
              local ActivityStartTime = TimeUtil.TimeStringToUnixstamp(PMGCConfig.PmgcPlaneShowStartTime, false)
              local ActivityFinshTime = TimeUtil.TimeStringToUnixstamp(PMGCConfig.PmgcPlaneShowEndTime, false)
              local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
              if nowTime < ActivityFinshTime and nowTime > ActivityStartTime and not GamePlayTools.IsBlueHoleVersion() then
                local TableUtil = require("common.table_util")
                TableUtil.OverrideTable(Result, Context.OriginConfig.PMGC2025)
              end
            end
            return Result
          end
        }
      }
    }
  },
  Export = {
    Name = "Neon",
    AutoExportAllConfig = true,
    Inject = {
      Custom = function(Params)
        local ModID = Params.ModID
        local tBTModeTable = CDataTable.GetTableData("BTMode", ModID)
        local sModeName = tBTModeTable ~= nil and tBTModeTable.GameModeName or ""
        local DebugMsg = string.format("(Custom Inject) GameModeName = %s", sModeName)
        Params.LogAndRecordDebugInfo(Params.ExtraModuleInfo.Name, DebugMsg, 2, Params.DebugInfos)
        return string.find(sModeName, "BluePrints/Core/Neon") ~= nil
      end
    },
    LuaFeature = {
      GameMode = {},
      GameState = {},
      PlayerCharacter = {
        {
          ElectromagneticPulseFeature = "GameLua.Mod.Neon.Gameplay.Feature.ElectromagneticPulseFeature"
        },
        {
          FishingFeature = "GameLua.Mod.Neon.Gameplay.Feature.FishingFeature"
        }
      },
      PlayerController = {
        {
          HighAltitudeDell = "GameLua.Mod.Neon.Gameplay.Feature.HighAltitudeDell"
        }
      },
      PlayerState = {
        {
          StoreFeature = "GameLua.Mod.Neon.Gameplay.Store.NeonPlayerStateStoreFeature"
        }
      }
    }
  }
}
return ModConfig