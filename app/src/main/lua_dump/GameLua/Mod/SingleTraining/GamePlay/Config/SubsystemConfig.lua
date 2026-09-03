local SubsystemConfig = {
  SingleTrainingTeleportSubsystem = {
    module = "GameLua.Mod.SingleTraining.DS.SingleTrainingTeleportSubsystem",
    side = "DS"
  },
  ChanllengeSubsystem = {
    module = "GameLua.Mod.SingleTraining.DS.ChanllengeSubsystem",
    side = "DS"
  },
  TrainingRoundFlowSubsystem = {
    module = "GameLua.Mod.SingleTraining.DS.TrainingRoundFlowSubsystem",
    side = "DS"
  },
  BattleKillBroadcastSubSystem = {
    module = "GameLua.Mod.SingleTraining.Client.BattleKillBroadcast.BattleKillBroadcastSubSystem",
    side = "Client"
  },
  SoundVisualizationSubsystem = {
    module = "GameLua.Mod.SingleTraining.Client.SoundVisualization.SoundVisualizationSubsystem",
    side = "Client"
  },
  FatalDamageSubsystem = {
    module = "GameLua.Mod.SingleTraining.DS.FatalDamageExpandData.FatalDamageSubsystem",
    side = "Both"
  },
  DSTaskTLogSubsystem = false,
  MapMarkAudioSubsystem = false
}
return SubsystemConfig