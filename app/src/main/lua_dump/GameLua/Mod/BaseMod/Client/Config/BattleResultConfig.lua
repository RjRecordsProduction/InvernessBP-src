local BattleResultConfig = {
  BattleResultProcess = {
    {
      ProcessName = "BattleResultDataLogic",
      Model = "GameLua.Mod.BaseMod.Client.BattleResult.BattleResultData.BattleResultDataLogic"
    },
    {
      ProcessName = "BattleResultSpecialShowBaseLogic",
      Model = "GameLua.Mod.Library.Client.BattleResultLib.SpecialShow.Logic.BattleResultSpecialShowBaseLogic"
    },
    {
      ProcessName = "BattleResultDeadTombBoxLogic",
      Model = "GameLua.Mod.Library.Client.BattleResultLib.SpecialShow.Logic.BattleResultSpecialShowDeadTombBoxLogic"
    },
    {
      ProcessName = "BattleResultCountDownLogic",
      Model = "GameLua.Mod.Library.Client.BattleResultLib.SpecialShow.Logic.BattleResultSpecialShowCountDownLogic"
    },
    {
      ProcessName = "BattleResultChickenDrawLogic",
      Model = "GameLua.Mod.BaseMod.Client.BattleResult.BattleResultChickenDraw.BattleResultChickenDrawLogic"
    },
    {
      ProcessName = "BattleResultMedalDisplayLogic",
      Model = "GameLua.Mod.BaseMod.Client.BattleResult.BattleResultMedal.BattleResultMedalDisplayLogic"
    },
    {
      ProcessName = "ResultRankingProtectLogic",
      Model = "GameLua.Mod.BaseMod.Client.BattleResult.ResultRankingProtect.ResultRankingProtectLogic"
    },
    {
      ProcessName = "BattleResultShowMvpLogic",
      Model = "GameLua.Mod.BaseMod.Client.BattleResult.ShowMvp.BattleResultShowMvpLogic"
    },
    {
      ProcessName = "BattleResultShowAvatarLogic",
      Model = "GameLua.Mod.BaseMod.Client.BattleResult.ShowAvatar.BattleResultShowAvatarLogic"
    },
    {
      ProcessName = "BattleFeedBackLogic",
      Model = "GameLua.Mod.BaseMod.Client.BattleResult.BattleFeedBack.BattleFeedBackLogic"
    }
  },
  OBBattleResultProcess = {
    {
      ProcessName = "BattleResultDataLogic",
      Model = "GameLua.Mod.BaseMod.Client.OBBattleResult.BattleResultDataLogic"
    },
    {
      ProcessName = "BattleResultShowRankLogic",
      Model = "GameLua.Mod.BaseMod.Client.OBBattleResult.BattleResultShowRankLogic"
    },
    {
      ProcessName = "BattleResultShowTitleLogic",
      Model = "GameLua.Mod.BaseMod.Client.OBBattleResult.BattleResultShowTitleLogic"
    }
  },
  OtherConfig = {
    KingEliminationBGPath = "/Game/Arts/UI/NoAtlas/Share/Battle_Show_MVP_BG12.Battle_Show_MVP_BG12"
  },
  NoLightResultLevels = {PUBG_Neon_AvatarDisplay = true}
}
return BattleResultConfig