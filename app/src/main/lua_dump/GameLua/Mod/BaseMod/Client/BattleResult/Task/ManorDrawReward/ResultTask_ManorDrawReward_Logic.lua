local ResultTask_ManorDrawReward_Logic = {}
function ResultTask_ManorDrawReward_Logic:OnInit()
end
function ResultTask_ManorDrawReward_Logic:OnUnInit()
end
function ResultTask_ManorDrawReward_Logic:GetSummaryInfo()
  local logic_manor_draw_reward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_manor_draw_reward)
  local rewardResult = logic_manor_draw_reward:GetRewardResult()
  if rewardResult then
    local ResultTask_Macro = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Macro")
    rewardResult.taskType = ResultTask_Macro.ENUM_TaskType.ManorDrawReward
    rewardResult.bPlayProgressBarAnim = false
  end
  return rewardResult
end
return ResultTask_ManorDrawReward_Logic