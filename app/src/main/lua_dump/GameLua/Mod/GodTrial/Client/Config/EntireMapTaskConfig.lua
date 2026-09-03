local EntireMapTaskConfig = {
  TitleConfig = {
    [1] = {
      Title = 69896,
      IconPath = "/Game/Mod/EvoBase/Textures/Atlas/ResultTask/Frames/ResultTask_Icon_Task_png.ResultTask_Icon_Task_png",
      ButtonLocID = 66999
    },
    [2] = {
      Title = 11318,
      IconPath = "/Game/Mod/EvoBase/Textures/Atlas/ResultTask/Frames/ResultTask_Icon_Task_png.ResultTask_Icon_Task_png"
    },
    [3] = {
      Title = 29169,
      IconPath = "/Game/Mod/EvoBase/Textures/Atlas/ResultTask/Frames/ResultTask_Icon_RP_png.ResultTask_Icon_RP_png"
    },
    [4] = {
      Title = 69352,
      IconPath = "/Game/Mod/EvoBase/Textures/Atlas/ResultTask/Frames/ResultTask_Icon_BranchRP_png.ResultTask_Icon_BranchRP_png"
    },
    [5] = {
      Title = 79468,
      IconPath = "/Game/Mod/EvoBase/Textures/Atlas/ResultTask/Frames/ResultTask_Icon_SmallRP_png.ResultTask_Icon_SmallRP_png"
    },
    [100] = {
      Title = 792324,
      IconPath = "/Game/Library/Res/Skills/GasHook/Arts/UI/Atlas/Frames/ResultTask_Icon_ContainerTrucks_png.ResultTask_Icon_ContainerTrucks_png"
    },
    [101] = {
      Title = 86879,
      IconPath = "/Game/Mod/EvoBase/Texture/Atlas/ResultTask/Frames/ResultTask_Icon_Task_png.ResultTask_Icon_Task_png",
      Priority = 1
    },
    [777] = {
      Title = 792324,
      IconPath = "/Game/Library/Res/Skills/GasHook/Arts/UI/Atlas/Frames/ResultTask_Icon_ContainerTrucks_png.ResultTask_Icon_ContainerTrucks_png"
    }
  },
  DefaultType = "GodTrialHonorTask",
  TypeModule = {
    Task = {
      ModulePath = "GameLua.Mod.BaseMod.Client.Map.EntireMapLeftPanel.EntireMapTaskItem",
      Priority = 1,
      IconPath = "/Game/Mod/EvoBase/Textures/Atlas/ResultTask/Frames/ResultTask_Icon_Task_png.ResultTask_Icon_Task_png"
    },
    GodTrialHonorTask = {
      ModulePath = "GameLua.Mod.BaseMod.Client.Map.EntireMapLeftPanel.EntireMapTaskItem",
      Priority = 2,
      IconPath = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_Rank06_png.ZD_Icon_Rank06_png"
    }
  }
}
return EntireMapTaskConfig