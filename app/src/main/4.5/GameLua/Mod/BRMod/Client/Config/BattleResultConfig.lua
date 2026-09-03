local BattleResultConfig = {
  BattleResultProcess = {
    {
      ProcessName = "BattleResultDataLogic",
      Model = "GameLua.Mod.BRMod.Client.BattleResult.BattleResultData.BattleResultDataLogic"
    },
    {
      ProcessName = "BattleResultDeadTombBoxLogic",
      Model = "GameLua.Mod.BRMod.Client.BattleResult.BattleResultDeadTombBox.BattleResultDeadTombBoxLogic"
    },
    {
      ProcessName = "BattleResultCountDownLogic",
      Model = "GameLua.Mod.BRMod.Client.BattleResult.GameOverTips.BattleResultCountDownLogic"
    },
    {
      ProcessName = "BattleResultChickenDrawLogic",
      Model = "GameLua.Mod.BRMod.Client.BattleResult.BattleResultChickenDraw.BattleResultChickenDrawLogic"
    },
    {
      ProcessName = "BattleResultMedalDisplayLogic",
      Model = "GameLua.Mod.BRMod.Client.BattleResult.BattleResultMedal.BattleResultMedalDisplayLogic"
    },
    {
      ProcessName = "ResultRankingProtectLogic",
      Model = "GameLua.Mod.BRMod.Client.BattleResult.ResultRankingProtect.ResultRankingProtectLogic"
    },
    {
      ProcessName = "BattleResultShowMvpLogic",
      Model = "GameLua.Mod.BaseMod.Client.BattleResult.ShowMvp.BattleResultShowMvpLogic"
    },
    {
      ProcessName = "BattleResultShowAvatarLogic",
      Model = "GameLua.Mod.BRMod.Client.BattleResult.ShowAvatar.BattleResultShowAvatarLogic"
    },
    {
      ProcessName = "BattleFeedBackLogic",
      Model = "GameLua.Mod.BRMod.Client.BattleResult.BattleFeedBack.BattleFeedBackLogic"
    }
  },
  OBBattleResultProcess = {
    {
      ProcessName = "BattleResultDataLogic",
      Model = "GameLua.Mod.BRMod.Client.OBBattleResult.BattleResultDataLogic"
    },
    {
      ProcessName = "BattleResultShowRankLogic",
      Model = "GameLua.Mod.BRMod.Client.OBBattleResult.BattleResultShowRankLogic"
    },
    {
      ProcessName = "BattleResultShowTitleLogic",
      Model = "GameLua.Mod.BRMod.Client.OBBattleResult.BattleResultShowTitleLogic"
    }
  },
  OtherConfig = {
    KingEliminationBGPath = "/Game/Arts/UI/NoAtlas/Share/Battle_Show_MVP_BG12.Battle_Show_MVP_BG12"
  },
  NoLightResultLevels = {PUBG_Neon_AvatarDisplay = true}
}
return BattleResultConfig