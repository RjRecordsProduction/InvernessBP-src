local SubsystemConfig = {
  ClientTLogManager = {
    module = "GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogManager",
    side = "Client"
  },
  BattleResultSubSystem = {
    module = "GameLua.Mod.BaseMod.Client.BattleResult.BattleResultSubSystem",
    side = "Client"
  },
  BattleKillBroadcastSubSystem = {
    module = "GameLua.Mod.BaseMod.Client.BattleKillBroadcast.BattleKillBroadcastSubSystem",
    side = "Client"
  },
  LevelStreamingMgr = {
    module = "GameLua.Mod.BaseMod.Client.Scene.LevelStreamingMgr",
    side = "Client"
  },
  ClientReplayUISubsystem = {
    module = "GameLua.Mod.BaseMod.Client.Replay.ClientReplayUISubsystem",
    side = "Client"
  },
  WonderfulPeriodSystem = {
    module = "GameLua.Mod.BaseMod.GamePlay.Replay.WonderfulPeriodSystem",
    side = "Both"
  },
  PlayerEventSystem = {
    module = "GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventSystemEntry",
    side = "Both"
  },
  HitMarkClientSubSystem = {
    module = "GameLua.Mod.BaseMod.Client.HitMark.HitMarkClient",
    side = "Client"
  },
  ClientHPBarSubSystem = {
    module = "GameLua.Mod.BaseMod.Client.HPBar.ClientHPBarSubSystem",
    side = "Client"
  },
  InspectionSystemReportClientLogicSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.InspectionSystem.InspectionSystemReportClientLogicSubsystem",
    side = "Client"
  },
  InspectionSystemReportDSLogicSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.InspectionSystem.InspectionSystemReportDSLogicSubsystem",
    side = "DS"
  },
  CarryBackCompTLogSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.TLog.DSCarryBackSubsystem",
    side = "DS"
  },
  AutoParachuteSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.AutoParachute.AutoParachuteSubsystem",
    side = "Client"
  },
  MapMarkLightCrossMgr = {
    module = "GameLua.Mod.BaseMod.Client.MapMarkLightCross.MapMarkLightCrossMgr",
    side = "Client"
  },
  DSAITLogSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.TLog.DSAITLogSubsystem",
    side = "DS"
  },
  DSFightTLogSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.TLog.DSFightTLogSubsystem",
    side = "DS"
  },
  DSWeaponTLogSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.TLog.DSWeaponTLogSubsystem",
    side = "DS"
  },
  DSShootTlogSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.TLog.DSShootTlogSubsystem",
    side = "DS"
  },
  AFKReportorSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.AFKReportorSubsystem",
    side = "DS"
  },
  ICTLogSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.ICTLogSubsystem",
    side = "DS"
  },
  DSReviveSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.Revive.DSReviveSubsystem",
    side = "DS"
  },
  ReviveTowerMgr = {
    module = "GameLua.Mod.BaseMod.DS.ReviveTower.ReviveTowerMgr",
    side = "Both"
  },
  StrongholdTowerMgr = {
    module = "GameLua.Mod.Library.DS.ReviveTower.StrongholdTowerMgr",
    side = "DS"
  },
  DSReviveTowerTLogSubsystem = {
    module = "GameLua.Mod.Library.DS.TLog.DSReviveTowerTLogSubsystem",
    side = "DS"
  },
  DSTeamMotivationSubsystem = {
    module = "GameLua.Mod.Library.DS.DSTeamMotivationSubsystem",
    side = "DS"
  },
  TeammateInspireSubsystem = {
    module = "GameLua.Mod.Library.GamePlay.Teammate.TeammateInspireSubsystem",
    side = "DS"
  },
  SilentCommunicationSubsystem = {
    module = "GameLua.Mod.Library.GamePlay.Teammate.SilentCommunicationSubsystem",
    side = "DS"
  },
  DSPVSSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.Security.DSPVSSubsystem",
    side = "DS"
  },
  DSCreditTLogSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.Security.DSCreditTLogSubsystem",
    side = "DS"
  },
  DSMaliciousTeammateDetectionSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.Security.DSMaliciousTeammateDetectionSubsystem",
    side = "DS"
  },
  ClientReportPlayerSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem",
    side = "Client"
  },
  DSReportPlayerSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem",
    side = "DS"
  },
  DSSecurityTLogSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem",
    side = "DS"
  },
  SettingSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.Setting.SettingSubsystem",
    side = "Client",
    bDestroyOnReconnect = false
  },
  ShieldSubSystem = {
    module = "GameLua.Mod.Library.DS.Weapon.ShieldSubSystem",
    side = "DS"
  },
  AirAttackSubsystem = {
    module = "GameLua.Mod.Library.GamePlay.Component.AirAttackSubsystem",
    side = "DS"
  },
  AITrackingLogSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.AI.AITrackingLogSubsystem",
    side = "DS"
  },
  AdvSpawnSubsystem = {
    module = "GameLua.Mod.Library.GamePlay.SpawnSystem.AdvSpawnSubsystem",
    side = "DS"
  },
  FatalDamageExpandDataSubsystem = {
    module = "GameLua.Mod.Library.DS.FatalDamageExpandData.FatalDamageExpandDataSubsystem",
    side = "DS"
  },
  HandleStateCanvasSubsystem = {
    module = "GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasSubsystem",
    side = "Client",
    bDestroyOnReconnect = false
  },
  AvatarExceptionReport = {
    module = "GameLua.Mod.Library.GamePlay.Avatar.AvatarExceptionReport",
    side = "Client"
  },
  AvatarExceptionSubsystem = {
    module = "GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionSubsystem",
    side = "Client"
  },
  LagCompensationSubSystem = {
    module = "GameLua.Mod.BaseMod.DS.Weapon.LagCompensationSubSystem",
    side = "DS"
  },
  WeaponPoolSubSystem = {
    module = "GameLua.Mod.BaseMod.Client.Weapon.WeaponPoolSubSystem",
    side = "Client"
  },
  ClientHawkEyePatrolSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.ClientHawkEyePatrolSubsystem",
    side = "Client"
  },
  DSHawkEyePatrolSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.Security.HawkEyeSpectate.DSHawkEyePatrolSubsystem",
    side = "DS"
  },
  DSCommonTLogSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.TLog.DSCommonTLogSubsystem",
    side = "DS"
  },
  DSAvatarTaskSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.TLog.DSAvatarTaskSubsystem",
    side = "DS"
  },
  DSPreCalcMapIconSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.Map.DSPreCalcMapIconSubsystem",
    side = "DS"
  },
  TeamMapMarkSubsystem = {
    module = "GameLua.Mod.Library.Client.UI.TeamMapMarkSubsystem",
    side = "Client"
  },
  GrenadesMedsSubsytem = {
    module = "GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseWidgetLogic",
    side = "Client"
  },
  ThemePropsWidgetLogic = {
    module = "GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.ThemePropsWidgetLogic",
    side = "Client"
  },
  EntireMapLeftWidgetLogic = {
    module = "GameLua.Mod.BaseMod.Client.InGameUI.Map.EntireMapLeftWidgetLogic",
    side = "Client"
  },
  RedpacketSubsystemDS = {
    module = "GameLua.Activity.IG2000.DS.RedpacketSubsystemDS",
    side = "DS"
  },
  HolographySubSystem = {
    module = "GameLua.Activity.IG2100.GamePlay.HolographySubSystem",
    side = "Both"
  },
  DSMLAITLogSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.TLog.DSMLAITLogSubsystem",
    side = "DS"
  },
  FightTaskSubSystem = {
    module = "GameLua.Mod.Library.GamePlay.Task.FightTaskSubSystem",
    side = "DS"
  },
  VoiceReportSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.Ban.VoiceReportSubsystem",
    side = "Client"
  },
  MapMarkLegendSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.Map.Subsystem.MapMarkLegendSubsystem",
    side = "Client"
  },
  AchievementDSSubsystem = {
    module = "GameLua.Mod.Library.DS.AchievementDSSubsystem",
    side = "DS"
  },
  VibrateUtilitySubsystem = {
    module = "GameLua.Mod.BaseMod.Client.VibrateUtility",
    side = "Client"
  },
  MapManagerSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.Map.Subsystem.MapManagerSubsystem",
    side = "Client"
  },
  MapResourceMarkIconSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.Map.Subsystem.MapResourceMarkIconSubsystem",
    side = "Client"
  },
  VehicleControlUISubSystem = {
    module = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleControlUISubSystem",
    side = "Client",
    bDestroyOnReconnect = false
  },
  TransparentUIModeSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.TransparentUIModeSubsystem",
    side = "Client"
  },
  ShootingUIPanelUISubSystem = {
    module = "GameLua.Mod.BaseMod.Client.ShootingUI.ShootingUIPanelUISubSystem",
    side = "Client"
  },
  OperateSubsystem = {
    module = "GameLua.Mod.BaseMod.GamePlay.Logic.Operate.OperateSubsystem",
    side = "Client"
  },
  PickUpTipsSubsystem = {
    module = "GameLua.Mod.BaseMod.GamePlay.Logic.PickUp.PickUpTipsSubsystem",
    side = "Client"
  },
  InGameItemsMgr = {
    module = "GameLua.Mod.BaseMod.DS.Items.InGameItemsMgr",
    side = "DS"
  },
  DSTaskTLogSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.TLog.DSTaskTLogSubsystem",
    side = "DS"
  },
  DSPlayerDataReportSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.BattleResult.DSPlayerDataReportSubsystem",
    side = "DS"
  },
  WeaponRecordSubSystem = {
    module = "GameLua.Mod.BaseMod.DS.BattleResult.WeaponRecordSubSystem",
    side = "DS"
  },
  OBUtilitySubsystem = {
    module = "GameLua.Mod.BaseMod.Client.OBUtilitySubsystem",
    side = "Client"
  },
  WeaponUpgradeSubSystem = {
    module = "GameLua.Mod.Library.GamePlay.Weapon.WeaponUpgradeSystem",
    side = "Both"
  },
  VehicleSubsystem = {
    module = "GameLua.GameCore.Module.Vehicle.VehicleSubsystem",
    side = "Both"
  },
  DSCircleSubSystem = {
    module = "GameLua.Mod.Library.DS.Actor.DSCircleSubSystem",
    side = "DS"
  },
  SoundMonitorSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.SoundMonitorSubsystem",
    side = "Client"
  },
  IngameLikeDSSubSystem = {
    module = "GameLua.Mod.BaseMod.DS.Like.IngameLikeDSSubSystem",
    side = "DS"
  },
  IngameLikeClientSubSystem = {
    module = "GameLua.Mod.BaseMod.Client.Like.IngameLikeClientSubSystem",
    side = "Client"
  },
  NewbieAssistDSSubSystem = {
    module = "GameLua.Mod.Library.DS.NewbieAssist.NewbieAssistDSSubSystem",
    side = "DS"
  },
  PhotoGrapherSubSystem = {
    module = "GameLua.Mod.Library.GamePlay.Camera.PhotoGrapherSubSystem",
    side = "Client"
  },
  UIControlSubSystem = {
    module = "GameLua.Mod.Library.GamePlay.Camera.UIControlSubSystem",
    side = "Client"
  },
  IngameSelfieSubsystem = {
    module = "GameLua.Mod.Library.GamePlay.Camera.IngameSelfieSubsystem",
    side = "Client"
  },
  IngameSelfieWeatherSubsystem = {
    module = "GameLua.Mod.Library.GamePlay.Camera.IngameSelfieWeatherSubsystem",
    side = "Client"
  },
  VoiceRecommendationSubsystem = {
    module = "GameLua.Mod.Library.Client.VoiceRecommendation.VoiceRecommendationSubsystem",
    side = "Client"
  },
  SoundVisualizationSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.SoundVisualization.SoundVisualizationSubsystem",
    side = "Client"
  },
  WeatherSubsystem = {
    module = "GameLua.Mod.BaseMod.GamePlay.Weather.WeatherSubsystem",
    side = "Both"
  },
  AdvertisementSubsystem = {
    module = "GameLua.Mod.Library.GamePlay.Advertisement.AdvertisementSubsystem",
    side = "Both"
  },
  AIReplaySubsystem = {
    module = "GameLua.Mod.BaseMod.DS.Replay.AIReplaySubsystem",
    side = "DS"
  },
  UGCUIControllerSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.UGCUIControllerSubsystem",
    side = "Client"
  },
  IngameGiftSubsystem = {
    module = "GameLua.Mod.Library.Client.Gift.IngameGiftSubsystem",
    side = "Client"
  },
  BornIslandTeamShowSubSystem = {
    module = "GameLua.Mod.BaseMod.Client.BornIslandTeamShow.BornIslandTeamShowSubSystem",
    side = "Client"
  },
  BornIslandTeamShowDsSubsystem = {
    module = "GameLua.Mod.Library.DS.BornIslandTeamShowDsSubsystem",
    side = "DS"
  },
  EmoteSubSystem = {
    module = "GameLua.Mod.Library.GamePlay.Avatar.Emote.EmoteSubSystem",
    side = "Both"
  },
  DSKillAndKnockDownTLogSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.TLog.DSKillAndKnockDownTLogSubsystem",
    side = "DS"
  },
  CharacterAvatarColorDIYSubsystem = {
    module = "GameLua.Mod.Library.Client.AvatarMeshEffect.CharacterAvatarColorDIYSubsystem",
    side = "Client"
  },
  ClientDataStatistcsSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.ClientDataStatistcsSubsystem",
    side = "Client"
  },
  ReportClientPingSystem = {
    module = "GameLua.Mod.BaseMod.GamePlay.FairPing.ReportClientPingSystem",
    side = "Both"
  },
  CommercialLuaFeatureSubystem = {
    module = "GameLua.Activity.Commercialize.GamePlay.CommercialLuaFeatureSubystem",
    side = "DS",
    order = 1
  },
  CoopEmoteSubSystem = {
    module = "GameLua.Activity.Commercialize.GamePlay.CoopEmote.CoopEmoteSubSystem",
    side = "DS"
  },
  VoiceChatSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.Chat.VoiceChatSubsystem",
    side = "Client",
    bDestroyOnReconnect = false
  },
  FireworkMgrSubsystem = {
    module = "GameLua.Mod.Library.GamePlay.Firework.FireworkMgrSubsystem",
    side = "Both"
  },
  AvatarChangeFormSubsystem = {
    module = "GameLua.Activity.Commercialize.GamePlay.Dragon.AvatarChangeFormSubsystem",
    side = "Client"
  },
  MapIconSubsystem = {
    module = "GameLua.Mod.Library.GamePlay.Map.MapIconSubsystem",
    side = "Both"
  },
  GameReportSubsystem = {
    module = "GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportSubsystem",
    side = "Both"
  },
  CDBarUISubSystem = {
    module = "GameLua.Mod.BaseMod.Client.InGameUI.CDBarUISubSystem",
    side = "Client"
  },
  StateMachineManager = {
    module = "GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateMachineManager",
    side = "Client"
  },
  SpectateAndReplaySubsystem = {
    module = "GameLua.Mod.BaseMod.Client.SpectateAndReplaySubsystem",
    side = "Client"
  },
  CampSubsystem = {
    module = "GameLua.Mod.BaseMod.GamePlay.Camp.CampSubsystem",
    side = "Both"
  },
  NewObjectPoolLuaBridgeSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.NewObjectPoolLuaBridgeSubsystem",
    side = "Client"
  },
  HighlightMomentSubsystem = {
    module = "GameLua.Mod.BaseMod.GamePlay.HighlightMoment.HighlightMomentSubsystem",
    side = "Both"
  },
  FinalKillEffectSubsystem = {
    module = "GameLua.Mod.Library.GamePlay.Subsystem.FinalKillEffectSubsystem",
    side = "Both"
  },
  WeaponKillCounterSubsystem = {
    module = "GameLua.Mod.BaseMod.GamePlay.WeaponKillCounter.WeaponKillCounterSubsystem",
    side = "Both"
  },
  AvatarFuzzySubsystem = {
    module = "GameLua.Mod.BaseMod.Client.AvatarFuzzySubsystem",
    side = "Client"
  },
  KillCounterUISubsystem = {
    module = "GameLua.Mod.BaseMod.Client.KillCounter.KillCounterUISubsystem",
    side = "Client"
  },
  SecretArmorySubsystem = {
    module = "GameLua.Mod.Library.Gameplay.Subsystem.SecretArmorySubsystem",
    side = "DS"
  },
  CustomVirtualItemSubsystem = {
    module = "GameLua.Mod.BaseMod.GamePlay.CustomVirtualItem.Subsystem.CustomVirtualItemSubsystem",
    side = "Both"
  },
  MontageCameraSubsystem = {
    module = "GameLua.Mod.Library.Gameplay.Subsystem.MontageCameraSubsystem",
    side = "Client"
  },
  NewYearCountdownSubsystem = {
    module = "GameLua.Mod.Library.Gameplay.Subsystem.NewYearCountdownSubsystem",
    side = "Both"
  },
  POIGeneralAreaSubsystem = {
    module = "GameLua.Mod.Library.GamePlay.Subsystem.POIGeneralAreaSubsystem",
    side = "Both"
  },
  FatalDamageSubsystem = {
    module = "GameLua.Mod.Library.DS.FatalDamageExpandData.FatalDamageSubsystem",
    side = "Both"
  },
  PersonalTaskSubsystem = {
    module = "GameLua.Mod.Library.GamePlay.Subsystem.PersonalTaskSubsystem",
    side = "Both"
  },
  SpawnAirDropShelterSubsytem = {
    module = "GameLua.Mod.Library.GamePlay.Subsystem.SpawnAirDropShelterSubsytem",
    side = "DS"
  },
  TeammateTakeOverSubsystem = {
    module = "GameLua.Mod.BaseMod.GamePlay.AI.TeammateTakeOverSubsystem",
    side = "Both"
  },
  HealTeammateSystem = {
    module = "GameLua.Mod.Library.GamePlay.Skill.Feature.HealTeammateSystem",
    side = "Client"
  },
  CISDrinkSystem = {
    module = "GameLua.Mod.Library.GamePlay.Subsystem.CISDrinkSystem",
    side = "Client"
  },
  BornIslandAirDropSystem = {
    module = "GameLua.Mod.Library.GamePlay.Subsystem.BornIslandAirDropSystem",
    side = "Both"
  },
  ModActivityAirDropManagerSystem = {
    module = "GameLua.Mod.Library.GamePlay.Subsystem.ModActivityAirDropManagerSystem",
    side = "DS"
  },
  DSChatPlayerSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.Subsystem.DSChatPlayerSubsystem",
    side = "DS"
  },
  ChangeAirDropSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.Subsystem.ChangeAirDropSubsystem",
    side = "DS"
  },
  UtilSystem = {
    module = "GameLua.Mod.Library.GamePlay.Subsystem.UtilSystem",
    side = "Both"
  },
  ClientSidePopupTipsSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.Tips.SidePopupTips.ClientSidePopupTipsSubsystem",
    side = "Client"
  },
  DataLayerSubsystem = {
    module = "GameLua.Mod.BaseMod.GamePlay.DataLayer.DataLayerSubsystem",
    side = "Both",
    order = -999
  },
  GameGuideUIConfigSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.Map.GameGuideUI.GameGuideUIConfigSubsystem",
    side = "Client"
  },
  OperationalStatsSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.Stats.OperationalStatsSubsystem",
    side = "Client"
  },
  VoiceTransformSubsystem = {
    module = "GameLua.Mod.BaseMod.Common.VoiceTransformSubsystem",
    side = "Client"
  },
  PKannualStageSystem = {
    module = "GameLua.Mod.Library.GamePlay.Subsystem.PKannualStageSystem",
    side = "DS"
  },
  GameArchiveDataSystem = {
    module = "GameLua.Mod.BaseMod.GamePlay.GameArchiveData.GameArchiveDataSystem",
    side = "DS"
  },
  ParachuteFollowBehaviorSubsystem = {
    module = "GameLua.Mod.BaseMod.DS.ParachuteFollow.ParachuteFollowBehaviorSubsystem",
    side = "DS"
  },
  ParachuteFollowBehaviorClientSubsystem = {
    module = "GameLua.Mod.BaseMod.Client.ParachuteFollow.ParachuteFollowBehaviorClientSubsystem",
    side = "Client"
  }
}
local bOk, BRSubsystemConfig = pcall(require, "GameLua.Mod.BRMod.Gameplay.Config.SubsystemConfig")
if bOk and type(BRSubsystemConfig) == "table" then
  for SubsystemName, SubsystemDef in pairs(BRSubsystemConfig) do
    SubsystemConfig[SubsystemName] = SubsystemDef
  end
else
  print("SubsystemConfig:Merge - failed to require BRMod SubsystemConfig")
end
return SubsystemConfig