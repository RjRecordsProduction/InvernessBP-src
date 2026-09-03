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
    Name = "BaseMod",
    Dev = {
      "GMConfig",
      "GMFuncConfig"
    }
  },
  Define = {
    ClassNamePath = {
      BRGameModeBase = "GameLua.Mod.BRMod.Gameplay.Core.BRGameModeBase",
      BRGameStateBase = "GameLua.Mod.BRMod.Gameplay.Core.BRGameStateBase",
      BRPlayerCharacterBase = "GameLua.Mod.BRMod.Gameplay.Core.BRPlayerCharacterBase",
      BRPlayerControllerBase = "GameLua.Mod.BRMod.Gameplay.Core.BRPlayerControllerBase",
      BRPlayerStateBase = "GameLua.Mod.BRMod.Gameplay.Core.BRPlayerStateBase"
    }
  }
}
return ModConfig