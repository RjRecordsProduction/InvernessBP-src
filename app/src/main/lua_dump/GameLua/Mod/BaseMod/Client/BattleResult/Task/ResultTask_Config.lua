local ResultTask_Macro = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Macro")
local ResultTask_Config = {
  Configs = {
    [ResultTask_Macro.ENUM_TaskType.RP] = {
      Logic = "GameLua.Mod.BaseMod.Client.BattleResult.Task.RP.ResultTask_RP_Logic",
      UIUtil = "GameLua.Mod.BaseMod.Client.BattleResult.Task.RP.ResultTask_RP_UI_Util",
      TaskType_ImagePath = "/Game/Mod/EvoBase/Textures/Atlas/ResultTask/Frames/ResultTask_Icon_RP_png.ResultTask_Icon_RP_png",
      TaskType_TextID = 29902,
      nShowSort = 10
    },
    [ResultTask_Macro.ENUM_TaskType.RankAward] = {
      Logic = "GameLua.Mod.BaseMod.Client.BattleResult.Task.RankAward.ResultTask_RankAward_Logic",
      UIUtil = "GameLua.Mod.BaseMod.Client.BattleResult.Task.RankAward.ResultTask_RankAward_UI_Util",
      TaskType_ImagePath = "/Game/Mod/EvoBase/Textures/Atlas/ResultTask/Frames/ResultTask_Icon_Rank_png.ResultTask_Icon_Rank_png",
      TaskType_TextID = 29903,
      nShowSort = 20
    },
    [ResultTask_Macro.ENUM_TaskType.ManorDrawReward] = {
      Logic = "GameLua.Mod.BaseMod.Client.BattleResult.Task.ManorDrawReward.ResultTask_ManorDrawReward_Logic",
      UIUtil = "GameLua.Mod.BaseMod.Client.BattleResult.Task.ManorDrawReward.ResultTask_ManorDrawReward_UI_Util",
      TaskType_ImagePath = nil,
      TaskType_TextID = 62401,
      nShowSort = 25
    },
    [ResultTask_Macro.ENUM_TaskType.SmallRP] = {
      Logic = "GameLua.Mod.BaseMod.Client.BattleResult.Task.SmallRP.ResultTask_SmallRP_Logic",
      UIUtil = "GameLua.Mod.BaseMod.Client.BattleResult.Task.SmallRP.ResultTask_SmallRP_UIUtil",
      TaskType_ImagePath = "/Game/Mod/EvoBase/Textures/Atlas/ResultTask/Frames/ResultTask_Icon_SmallRP_png.ResultTask_Icon_SmallRP_png",
      TaskType_TextID = 79468,
      nShowSort = 30
    },
    [ResultTask_Macro.ENUM_TaskType.DailyTask] = {
      Logic = "GameLua.Mod.BaseMod.Client.BattleResult.Task.DailyTask.ResultTask_DailyTask_Logic",
      UIUtil = "GameLua.Mod.BaseMod.Client.BattleResult.Task.DailyTask.ResultTask_DailyTask_UI_Util",
      TaskType_ImagePath = "/Game/Mod/EvoBase/Textures/Atlas/ResultTask/Frames/ResultTask_Icon_Task_png.ResultTask_Icon_Task_png",
      TaskType_TextID = 29904,
      nShowSort = 40
    },
    [ResultTask_Macro.ENUM_TaskType.LevelTask] = {
      Logic = "GameLua.Mod.BaseMod.Client.BattleResult.Task.LevelTask.ResultTask_LevelTask_Logic",
      UIUtil = "GameLua.Mod.BaseMod.Client.BattleResult.Task.LevelTask.ResultTask_LevelTask_UI_Util",
      TaskType_ImagePath = "/Game/UMG/Texture/Atlas/TaskUI/Frames/Task_icon_chengzhangrenwu_png.Task_icon_chengzhangrenwu_png",
      TaskType_TextID = 4329,
      nShowSort = 50
    },
    [ResultTask_Macro.ENUM_TaskType.BP] = {
      Logic = "GameLua.Mod.BaseMod.Client.BattleResult.Task.BP.ResultTask_BP_Logic",
      UIUtil = "GameLua.Mod.BaseMod.Client.BattleResult.Task.BP.ResultTask_BP_UI_Util",
      TaskType_ImagePath = "/Game/Mod/EvoBase/Textures/Atlas/ResultTask/Frames/ResultTask_Icon_BranchRP_png.ResultTask_Icon_BranchRP_png",
      TaskType_TextID = 69353,
      nShowSort = 60
    }
  }
}
function ResultTask_Config.GetTaskConfig(taskType)
  return ResultTask_Config.Configs[taskType]
end
return ResultTask_Config