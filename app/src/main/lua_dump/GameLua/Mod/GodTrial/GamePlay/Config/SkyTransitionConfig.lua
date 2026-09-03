local SkyTransitionConfig = {
  [440001] = {
    Name = "NTPreheatPoint",
    Sequence = "/Game/Mod/VersionRes/440/Art_Scenes/Seq/SEQ_Baltic_VersionRes_440_sky_1.SEQ_Baltic_VersionRes_440_sky_1",
    Priority = 100
  },
  [440002] = {
    Name = "CitySky",
    Sequence = "/Game/Mod/GodTrial/Arts_PlayerBluePrints/Sequence/Seq_Baltic_GodTrial_sunnday.Seq_Baltic_GodTrial_sunnday",
    Material = "/Game/Mod/GodTrial/Arts_Scenes/Sky/MI_GodTrial_SkyIslet_Sky_2.MI_GodTrial_SkyIslet_Sky_2",
    Priority = 10,
    TransitionCDTime = 5
  },
  [440003] = {
    Name = "DungeonSky",
    Sequence = "/Game/Mod/GodTrial/Arts_PlayerBluePrints/Sequence/Seq_Baltic_GodTrial_FKD.Seq_Baltic_GodTrial_FKD",
    Material = "/Game/Mod/GodTrial/Arts_Scenes/Sky/MI_GodTrial_SkyIslet_Sky_01.MI_GodTrial_SkyIslet_Sky_01",
    Priority = 100,
    SkySphereFollowActor = function(uPlayerController)
      local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
      local uDungeon = ActorTools.GetOneActor(uPlayerController, "/Game/Mod/GodTrial/BluePrints/Actor/Dungeon/BP_GodTrialDungeon.BP_GodTrialDungeon_C")
      if slua.isValid(uDungeon) then
        return uDungeon
      end
      return uPlayerController:GetPlayerCharacterSafety()
    end
  },
  [440004] = {
    Name = "TheDescendedSky",
    Sequence = "/Game/Mod/GodTrial/Arts_PlayerBluePrints/Sequence/Seq_Baltic_GodTrial.Seq_Baltic_GodTrial",
    Material = "/Game/Mod/GodTrial/Arts_Scenes/Sky/MI_GodTrial_SkyIslet_Sky_2.MI_GodTrial_SkyIslet_Sky_2",
    Priority = 50
  }
}
return SkyTransitionConfig