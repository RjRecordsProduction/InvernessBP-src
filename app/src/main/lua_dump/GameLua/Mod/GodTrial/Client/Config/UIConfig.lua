local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local Config = {
  UIConfig = {
    SkillModButtonSlot = {
      moduleName = "GameLua.Mod.BaseMod.Client.SkillPanel.SkillModButtonSlot",
      path = "/Game/Mod/GodTrial/BluePrints/UI/SkillButton/SkillModButtonSlot_BP_GodTrial.SkillModButtonSlot_BP_GodTrial",
      uiStat = {
        name = "SkillModButtonSlot"
      },
      isMainUI = false,
      isWindowsOBHide = true,
      isSingleton = true,
      zOrder = 40,
      autoCreate = true,
      mountPanel = {
        mountOuterName = "ShootingUIPanel",
        mountName = "SkillLayer"
      }
    },
    GodTrialHonorPanel = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.GodTrialHonorPanel",
      path = "/Game/Mod/GodTrial/BluePrints/UI/ArenaTrials/ArenaTrials_UI_Item.ArenaTrials_UI_Item",
      isSingleton = true,
      uiStat = {
        name = "GodTrialHonorPanel"
      },
      isMainUI = false,
      autoCreate = true,
      loadFromPool = EUIConfigPoolType.None,
      showVisibility = UIContainers.ShowVisibilityAction.DontCare,
      zOrder = 1,
      containerName = UIContainers.Bottom
    },
    CommonTrialTipsUI = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.CommonTrialTipsUI",
      path = "/Game/Mod/GodTrial/BluePrints/UI/CommonTrialTips_UIBP.CommonTrialTips_UIBP",
      uiStat = {
        name = "CommonTrialTipsUI "
      },
      closeOnHide = true,
      loadFromPool = EUIConfigPoolType.None,
      isMainUI = false,
      zOrder = 1,
      asy = true,
      showVisibility = UIContainers.ShowVisibilityAction.DontCare,
      mountPanel = {
        mountOuterName = "MainControlBaseUI",
        mountName = "CanvasPanel_DontHide"
      }
    },
    TDTrialUI = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.TDTrialUI",
      path = "/Game/Mod/GodTrial/BluePrints/UI/TDTrialUI_UIBP.TDTrialUI_UIBP",
      uiStat = {name = "TDTrialUI "},
      closeOnHide = true,
      loadFromPool = EUIConfigPoolType.None,
      isMainUI = false,
      zOrder = 0,
      asy = true,
      showVisibility = UIContainers.ShowVisibilityAction.DontCare,
      mountPanel = {
        mountOuterName = "MainControlBaseUI",
        mountName = "CanvasPanel_DontHide"
      }
    },
    EPTrialUI = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.EPTrialUI",
      path = "/Game/Mod/GodTrial/BluePrints/UI/EPTrialUI_UIBP.EPTrialUI_UIBP",
      uiStat = {name = "EPTrialUI "},
      closeOnHide = true,
      loadFromPool = EUIConfigPoolType.None,
      isMainUI = false,
      zOrder = 0,
      asy = true,
      showVisibility = UIContainers.ShowVisibilityAction.DontCare,
      mountPanel = {
        mountOuterName = "MainControlBaseUI",
        mountName = "CanvasPanel_DontHide"
      }
    },
    FBTrialUI = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.FBTrialUI",
      path = "/Game/Mod/GodTrial/BluePrints/UI/FBTrialUI_UIBP.FBTrialUI_UIBP",
      uiStat = {name = "FBTrialUI"},
      closeOnHide = true,
      loadFromPool = EUIConfigPoolType.None,
      isMainUI = false,
      zOrder = 0,
      asy = true,
      showVisibility = UIContainers.ShowVisibilityAction.DontCare,
      mountPanel = {
        mountOuterName = "MainControlBaseUI",
        mountName = "CanvasPanel_DontHide"
      }
    },
    PKTrialUI = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.PKTrialUI",
      path = "/Game/Mod/GodTrial/BluePrints/UI/PKTrialUI_UIBP.PKTrialUI_UIBP",
      uiStat = {name = "PKTrialUI "},
      containerName = UIContainers.Bottom,
      closeOnHide = true,
      loadFromPool = EUIConfigPoolType.None,
      isMainUI = false,
      zOrder = -1,
      asy = true,
      showVisibility = UIContainers.ShowVisibilityAction.DontCare
    },
    TeleportParkourTrialDungeonScreenEffectUI = {
      moduleName = "GameLua.Mod.Library.Client.UI.LoadingScreenEffectUI",
      path = "/Game/Mod/GodTrial/BluePrints/UI/GodTrial_Screen_TeleportDungeon_UIBP.GodTrial_Screen_TeleportDungeon_UIBP",
      isMainUI = false,
      asy = true,
      uiStat = {
        name = "TeleportParkourTrialDungeonScreenEffectUI"
      },
      containerName = UIContainers.Top
    },
    MercenaryAudioTipsUI = {
      moduleName = "GameLua.Mod.Library.Client.Mercenary.MercenaryAudioTipsUI",
      path = "/Game/Library/Res/AI/Centaur/BluePrints/UI/Centaur_ElasticFrame_Tips_UIBP.Centaur_ElasticFrame_Tips_UIBP",
      isMainUI = false,
      isWindowsOBHide = true,
      zOrder = 0
    },
    IngameMercenaryItemUI = {
      moduleName = "GameLua.Mod.Library.Client.Mercenary.Ingame_MercenaryItem_UIBP",
      path = "/Game/Library/Res/AI/Centaur/BluePrints/UI/Centaur_Ingame_MercenaryItem_UIBP.Centaur_Ingame_MercenaryItem_UIBP",
      fullScreen = false,
      uiStat = {
        name = "IngameMercenaryItemUI"
      },
      containerName = UIContainers.Default,
      closeOnHide = false,
      isSingleton = true
    },
    IngameTeamItem_New = {
      moduleName = "GameLua.Mod.GodTrial.Client.IngameTeamPanel.Items.IngameTeamItem_UI_New",
      path = "/Game/BluePrints/ControlInput/IngameUI/Ingame_TeamPanel_New/Items/Ingame_TeamItem_New_UIBP.Ingame_TeamItem_New_UIBP",
      fullScreen = false,
      uiStat = {
        name = "IngameTeamItem_New"
      },
      containerName = UIContainers.Default,
      closeOnHide = false,
      isSingleton = false
    },
    SurviveInfoPanel = {
      moduleName = "GameLua.Mod.GodTrial.Client.InGameUI.SurviveInfoPanel",
      path = "/Game/Mod/GodTrial/BluePrints/UI/SurviveInfoPanel.SurviveInfoPanel",
      uiStat = {
        name = "SurviveInfoPanel"
      },
      containerName = UIContainers.Default,
      zOrder = 0,
      asy = true,
      autoCreate = true,
      isMainUI = false
    },
    ResultsRanking_Protect_UIBPNew = {
      moduleName = "GameLua.Mod.GodTrial.Client.BattleResult.ResultsRankingProtectUI",
      path = "/Game/BluePrints/ControlInput/ResultsshareUI/S20/ResultsRanking_Protect_UIBPNew.ResultsRanking_Protect_UIBPNew",
      uiStat = {
        name = "ResultsRanking_Protect_UIBPNew"
      },
      closeOnHide = false,
      isMainUI = false,
      asy = true
    },
    AATrialUIPanel = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.AATrialUI",
      path = "/Game/Mod/GodTrial/BluePrints/UI/AATrialUI_UIBP.AATrialUI_UIBP",
      uiStat = {
        name = "AATrialUIPanel"
      },
      closeOnHide = true,
      loadFromPool = EUIConfigPoolType.None,
      isMainUI = false,
      asy = true,
      showVisibility = UIContainers.ShowVisibilityAction.DontCare,
      containerName = UIContainers.Bottom,
      zOrder = -10
    },
    GodTrialMapUI = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.GodTrialMapUI",
      path = "/Game/BluePrints/UI/Map/GodTrialMap_UIBP.GodTrialMap_UIBP",
      uiStat = {
        name = "GodTrialMapUI"
      },
      closeOnHide = true,
      loadFromPool = EUIConfigPoolType.None,
      isMainUI = false,
      zOrder = 0,
      asy = true,
      showVisibility = UIContainers.ShowVisibilityAction.DontCare
    },
    TimeCountingUI = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.GodTrialTimeCountingUI",
      path = "/Game/Mod/EvoBase/BluePrints/UI/MapItem/TimeCounting_UIBP.TimeCounting_UIBP",
      uiStat = {
        name = "TimeCountingUI"
      },
      closeOnHide = true,
      loadFromPool = EUIConfigPoolType.None,
      isMainUI = false,
      zOrder = 0,
      asy = true,
      showVisibility = UIContainers.ShowVisibilityAction.DontCare
    },
    GodTrialCommonTipsUI = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.GodTrialCommonTipsUI",
      path = "/Game/Mod/GodTrial/BluePrints/UI/CommonTips_UIBP.CommonTips_UIBP",
      uiStat = {
        name = "GodTrialCommonTipsUI"
      },
      isMainUI = false,
      zOrder = 0,
      asy = false,
      isSingleton = true
    },
    FPIgnitingUI = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.FPIgnitingUI",
      path = "/Game/Mod/GodTrial/BluePrints/UI/FPIgniting_UIBP.FPIgniting_UIBP",
      uiStat = {
        name = "FPIgnitingUI "
      },
      isMainUI = false,
      zOrder = 0,
      asy = false,
      isSingleton = true
    },
    FPIgnitedResultUI = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.FPIgnitedResultUI",
      path = "/Game/Mod/GodTrial/BluePrints/UI/FPIgnitedResult_UIBP.FPIgnitedResult_UIBP",
      uiStat = {
        name = "FPIgnitedResultUI "
      },
      isMainUI = false,
      zOrder = 0,
      asy = false,
      isSingleton = true
    },
    NTShowUI = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.NTShowUI",
      path = "/Game/Mod/VersionRes/440/BluePrints/UI/NTShow_UIBP.NTShow_UIBP",
      uiStat = {name = "NTShowUI"},
      isMainUI = false,
      zOrder = 0,
      asy = false,
      isSingleton = true
    },
    TeleportToNTScreenEffectUI = {
      moduleName = "GameLua.Mod.Library.Client.UI.LoadingScreenEffectUI",
      path = "/Game/Mod/VersionRes/440/BluePrints/UI/NTShow_Loading_UIBP.NTShow_Loading_UIBP",
      isMainUI = false,
      asy = true,
      uiStat = {
        name = "TeleportToNTScreenEffectUI"
      },
      zOrder = 0,
      containerName = UIContainers.Top
    },
    IngameCentaurBossHPUI = {
      moduleName = "GameLua.ExtraModule.MLAI.Mercenary.Centaur.IngameCentaurBossHPUI",
      path = "/Game/Library/Res/AI/Centaur/BluePrints/UI/IngameCentaurHP_UIBP.IngameCentaurHP_UIBP",
      containerName = UIContainers.Bottom,
      uiStat = {
        name = "IngameCentaurBossHPUI"
      },
      isMainUI = false,
      loadFromPool = EUIConfigPoolType.None,
      asy = true
    },
    BATrialUIPanel = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.BATrialUI",
      path = "/Game/Mod/GodTrial/BluePrints/UI/BATrialUI_UIBP.BATrialUI_UIBP",
      containerName = UIContainers.Bottom,
      uiStat = {
        name = "BATrialUIPanel"
      },
      isMainUI = false,
      loadFromPool = EUIConfigPoolType.None,
      asy = true
    },
    ArenaTrials_Item = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.ArenaTrials_Item",
      path = "/Game/Mod/GodTrial/BluePrints/UI/ArenaTrials/ArenaTrials_Item.ArenaTrials_Item",
      uiStat = {
        name = "ArenaTrials_Item"
      },
      isMainUI = false,
      zOrder = 0,
      asy = false,
      isSingleton = true
    },
    ArenaTrials_Detail_Item = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.ArenaTrials_Detail_Item",
      path = "/Game/Mod/GodTrial/BluePrints/UI/ArenaTrials/ArenaTrials_Detail_Item.ArenaTrials_Detail_Item",
      uiStat = {
        name = "ArenaTrials_Detail_Item"
      },
      isMainUI = false,
      zOrder = 1,
      asy = false,
      isSingleton = true
    },
    BATrialLeaveUIPanel = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.BATrialUI",
      path = "/Game/Mod/GodTrial/BluePrints/UI/BATrialLeaveUI_UIBP.BATrialLeaveUI_UIBP",
      containerName = UIContainers.Bottom,
      uiStat = {
        name = "BATrialLeaveUIPanel"
      },
      isMainUI = false,
      loadFromPool = EUIConfigPoolType.None,
      asy = true,
      zOrder = -10
    },
    EntireMapTaskUI = {
      moduleName = "GameLua.Mod.GodTrial.Client.Map.EntireMapTaskUI",
      path = "/Game/BluePrints/UI/Map/EntireMapUI_Task_UIBP.EntireMapUI_Task_UIBP",
      uiStat = {
        name = "EntireMapTaskUI"
      },
      isMainUI = false,
      closeOnHide = false,
      bPermanentDuringThisBattle = true,
      zOrder = 1,
      autoCreate = true
    },
    GodTrialHonourItemMapUI = {
      moduleName = "GameLua.Mod.GodTrial.Client.Map.GodTrialHonourItemMapUI",
      path = "/Game/Mod/GodTrial/BluePrints/UI/Map/Honour_Item_Map_UIBP.Honour_Item_Map_UIBP",
      uiStat = {
        name = "GodTrialHonourItemMapUI"
      },
      isMainUI = false,
      isSingleton = false,
      asy = false
    },
    MapSoundVisualization = {
      moduleName = "GameLua.Mod.GodTrial.Client.SoundVisualization.MapSoundVisualization",
      path = "/Game/Mod/EvoBase/BluePrints/UI/SoundVisualization/SoundVisualization_Map_Mark_UIBP.SoundVisualization_Map_Mark_UIBP",
      uiStat = {
        name = "MapSoundVisualization"
      },
      closeOnHide = false,
      AndroidBackType = EAndroidBackType.Ban,
      isMainUI = false,
      zOrder = 0
    },
    MainSoundVisualizationUI = {
      moduleName = "GameLua.Mod.GodTrial.Client.SoundVisualization.MainSoundVisualizationUI",
      path = "/Game/Mod/EvoBase/BluePrints/UI/SoundVisualization/SoundVisualization_UIBP.SoundVisualization_UIBP",
      isSingleton = false,
      uiStat = {
        name = "MainSoundVisualizationUI"
      },
      closeOnHide = false,
      asy = true,
      zOrder = 0
    },
    ModWeaponReloadUI = {
      moduleName = "GameLua.Mod.Library.GamePlay.Weapon.UI.ModWeaponReloadUI",
      path = "/Game/Library/Res/Weapons/M1_Garand_GodTrial/BluePrints/M1GarandUI_Item01_UIBP.M1GarandUI_Item01_UIBP",
      fullScreen = false,
      uiStat = {
        name = "ModWeaponReloadUI"
      },
      containerName = UIContainers.Default,
      isSingleton = false,
      asy = true
    },
    SingleReviveCountUI = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.SingleReviveCountUI",
      path = "/Game/Mod/EvoBase/BluePrints/UI/ReviveTowerUI/SingleReviePanel_UIBP.SingleReviePanel_UIBP",
      uiStat = {
        name = "SingleReviveCountUI"
      },
      isSingleton = true,
      isMainUI = false,
      AndroidBackType = EAndroidBackType.Ban,
      zOrder = 0
    },
    TeammateReviveStateIcon = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.TeammateReviveStateIcon",
      path = "/Game/Mod/EvoBase/BluePrints/UI/ReviveTowerUI/ReviveTeam_SignalTower_Item.ReviveTeam_SignalTower_Item",
      uiStat = {
        name = "TeammateReviveStateIcon"
      },
      containerName = UIContainers.Default,
      isSingleton = false,
      AndroidBackType = EAndroidBackType.Ban
    },
    GodTrial_Popup_UIBP = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.Popup.GodTrialAIConsentPopup",
      path = "/Game/Mod/GodTrial/BluePrints/UI/Popup/GodTrial_Popup_UIBP.GodTrial_Popup_UIBP",
      zOrder = 200,
      uiStat = {
        name = "GodTrial_Popup_UIBP"
      },
      isSingleton = true,
      isMainUI = false,
      closeOnHide = true,
      asy = true,
      isWindowsOBHide = true,
      loadFromPool = EUIConfigPoolType.None,
      containerName = UIContainers.Top
    },
    EnterGameFaceGuide = {
      moduleName = "GameLua.Mod.GodTrial.Client.UI.Popup.FaceIntroUI",
      path = "/Game/Mod/EvoBase/BluePrints/UI/NewbieGuide/EnterGameGuide_UIBP.EnterGameGuide_UIBP",
      zOrder = 1,
      uiStat = {
        name = "EnterGameFaceGuide"
      },
      isMainUI = false,
      closeOnHide = true,
      asy = true,
      isWindowsOBHide = true,
      loadFromPool = EUIConfigPoolType.None
    }
  },
  OldUIConfig = {
    Default = DefaultInGameWidget,
    ModAdd = {}
  },
  OtherSetting = {
    HPBarConfig = {},
    EntireMapUIPath = "/Game/Mod/GodTrial/BluePrints/UI/Map/GodTrial_EntireMapUI_BP.GodTrial_EntireMapUI_BP_C",
    MiniMapUIPath = "/Game/Mod/GodTrial/BluePrints/UI/Map/GodTrial_MiniMapUI_BP.GodTrial_MiniMapUI_BP_C"
  }
}
return Config