local SubsystemConfig = {
  CoopRankScoresSubsystem = {
    module = "GameLua.Mod.BRMod.DS.Subsystem.CoopRankScoresSubsystem",
    side = "DS"
  },
  ResultTaskSubsystem = {
    module = "GameLua.Mod.BRMod.Client.BattleResult.Task.ResultTaskSubsystem",
    side = "Client"
  },
  ParachutingUISubSystem = {
    module = "GameLua.Mod.BRMod.Gameplay.Logic.Parachute.ParachutingUISubSystem",
    side = "Client"
  },
  ConfigDrivePlaneShowSubsystem = {
    module = "GameLua.Mod.BRMod.Client.PlaneShow.ConfigDrivePlaneShowSubsystem",
    side = "Both"
  },
  AreaSelectSubsystem = {
    module = "GameLua.Mod.BRMod.Gameplay.Logic.Parachute.AreaSelectSubsystem",
    side = "Client"
  },
  AICommandSubsystem = {
    module = "GameLua.Mod.BRMod.Gameplay.AICommand.AICommandSubsystem",
    side = "Client"
  },
  BattleResultRewardSubsystem = {
    module = "GameLua.Mod.BRMod.Client.BattleResult.BattleResultRewardSubsystem",
    side = "Client"
  },
  DSPlayerBattleTickSubsystem = {
    module = "GameLua.Mod.BRMod.DS.TLog.DSPlayerBattleTickSubsystem",
    side = "DS"
  },
  VoiceEmojiBubbleSubSystem = {
    module = "GameLua.Mod.BRMod.Client.VoiceEmojiBubble.VoiceEmojiBubbleSubSystem",
    side = "Client"
  }
}
return SubsystemConfig