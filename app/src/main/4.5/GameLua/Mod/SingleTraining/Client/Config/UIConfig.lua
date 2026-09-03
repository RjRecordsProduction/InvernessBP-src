local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local Config = {
  UIConfig = {
    SingleShootingTrainBattleUI = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Shooting.SingleShootingTrainBattleUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTrain_Main_UI.SingleTrain_Main_UI",
      uiStat = {
        name = "SingleShootingTrainBattleUI"
      },
      zOrder = 1,
      isMainUI = false
    },
    SingleTraining_MapGuide = {
      moduleName = "GameLua.Mod.SingleTraining.Client.SingleTrainGuideUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTrain_Guide_UIBP.SingleTrain_Guide_UIBP",
      zOrder = 1
    },
    SingleTraining_ShootingRule = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Shooting.SingleTrainShootingRuleUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTrain_ShootingRule_UIBP.SingleTrain_ShootingRule_UIBP"
    },
    SingleTraining_ThrowBomRule = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Bomb.ThrowBomRuleUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/ThrowBomb/ThrowBom_Rule_UIBP.ThrowBom_Rule_UIBP"
    },
    SingleTraining_AIRule = {
      moduleName = "GameLua.Mod.SingleTraining.Client.AI.SingleTrainingAIRuleUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/AI/SingleTraining_AI_Rule_UIBP.SingleTraining_AI_Rule_UIBP"
    },
    SingleShootingTrainModeSelect = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Shooting.SingleShootingTrainModeSelect",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTraining_ShootingTraining_UIBP.SingleTraining_ShootingTraining_UIBP",
      uiStat = {
        name = "SingleShootingTrainModeSelect"
      }
    },
    SingleShootingTrainRuleSelect = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Shooting.SingleShootingTrainRuleSelect",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTraining_RoutineTraining_UIBP.SingleTraining_RoutineTraining_UIBP",
      uiStat = {
        name = "SingleShootingTrainRuleSelect"
      }
    },
    SingleTraining_RuleDescription = {
      moduleName = "GameLua.Mod.SingleTraining.Client.SingleTrainingRuleDescriptionUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTraining_RuleDescription_UIBP.SingleTraining_RuleDescription_UIBP",
      isMainUI = false
    },
    SingleTrainingInteractiveUI = {
      moduleName = "GameLua.Mod.SingleTraining.Client.SingleTrainingInteractiveUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTraining_Interactive_UIBP.SingleTraining_Interactive_UIBP",
      isSingleton = true,
      uiStat = {
        name = "SingleTrainingInteractiveUI"
      },
      isMainUI = false,
      containerName = UIContainers.Bottom
    },
    MapGuideInteractiveUI = {
      moduleName = "GameLua.Mod.SingleTraining.Client.SingleTrainingMapGuideUI",
      path = "/Game/Mod/EvoBase/BluePrints/UI/Interactive_UIBP.Interactive_UIBP",
      isSingleton = true,
      uiStat = {
        name = "MapGuideInteractiveUI"
      },
      isMainUI = false,
      containerName = UIContainers.Bottom
    },
    SingleShootingTrainResult = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Shooting.SingleTrainingShootingResultUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTraining_TechnicalStatistics_02_UIBP.SingleTraining_TechnicalStatistics_02_UIBP",
      uiStat = {
        name = "SingleShootingTrainResult"
      }
    },
    SingleShootingTrainCustomSettingUI = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Shooting.SingleShootingTrainCustomSettingUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTrain_Customize_UIBP.SingleTrain_Customize_UIBP",
      uiStat = {
        name = "SingleShootingTrainCustomSettingUI"
      }
    },
    SingleTrainEndTrainTipsUI = {
      moduleName = "GameLua.Mod.SingleTraining.Client.SingleTrainEndTrainTipsUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTraining_End_Tips_UIBP.SingleTraining_End_Tips_UIBP",
      uiStat = {
        name = "SingleTrainEndTrainTipsUI"
      },
      closeOnHide = false
    },
    SingleTrainEntranceUI = {
      moduleName = "GameLua.Mod.SingleTraining.Client.SingleTrainingEntranceUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTraining_Entrance_UIBP.SingleTraining_Entrance_UIBP",
      uiStat = {
        name = "SingleTrainEntranceUI"
      },
      closeOnHide = false,
      loadFromPool = EUIConfigPoolType.None,
      zOrder = -1,
      AndroidBackType = EAndroidBackType.Ban
    },
    SingleTraining_AI_FightMode = {
      moduleName = "GameLua.Mod.SingleTraining.Client.AI.SingleTrainingAIFightMode",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/AI/SingleTraining_ConfrontationMode_UIBP.SingleTraining_ConfrontationMode_UIBP",
      uiStat = {
        name = "SingleTraining_AI_FightMode"
      }
    },
    SingleTraining_AI_Main = {
      moduleName = "GameLua.Mod.SingleTraining.Client.AI.SingleTrainingAIMain",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/AI/SingleTraining_AI_UIBP.SingleTraining_AI_UIBP",
      uiStat = {
        name = "SingleTraining_AI_Main"
      },
      isMainUI = false,
      zOrder = 2
    },
    SingleTraining_AI_FightMode_Result = {
      moduleName = "GameLua.Mod.SingleTraining.Client.AI.SingleTrainingAIFightModeResult",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/AI/SingleTraining_TechnicalStatistics_Bionic_UIBP.SingleTraining_TechnicalStatistics_Bionic_UIBP",
      uiStat = {
        name = "SingleTraining_AI_FightMode_Result"
      }
    },
    SingleTraining_ThrowBomb_FightMode = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Bomb.SingleTrainThrowBombUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/ThrowBomb/SingleTrainThrowBombUIBP.SingleTrainThrowBombUIBP",
      uiStat = {
        name = "SingleTraining_ThrowBomb_FightMode"
      }
    },
    SingleTraining_ThrowBomb_Result = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Bomb.SingleTrainThrowBombUIResult",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/ThrowBomb/SingleTrainingThrowBombResultUIBP.SingleTrainingThrowBombResultUIBP",
      uiStat = {
        name = "SingleTraining_ThrowBomb_Result"
      }
    },
    SingleTraining_ThrowBomb_PlayingHUDUI = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Bomb.SingleTrainThrowBombHudUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/ThrowBomb/SingleTraining_ThrowBombHUD_UIBP.SingleTraining_ThrowBombHUD_UIBP",
      uiStat = {
        name = "SingleTraining_ThrowBomb_PlayingHUDUI"
      },
      isMainUI = false
    },
    SingleTraining_Sensitivity_Enter = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Sensitivity.SingleTrainingSensitivityEnter",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTrain_Sensitivity_Btn_UIBP.SingleTrain_Sensitivity_Btn_UIBP",
      uiStat = {
        name = "SingleTraining_Sensitivity_Enter"
      },
      isMainUI = false,
      zOrder = 1
    },
    SingleTraining_Sensitivity_List = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Sensitivity.SingleTrainingSensitivityList",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTrain_Sensitivity_UIBP.SingleTrain_Sensitivity_UIBP",
      uiStat = {
        name = "SingleTraining_Sensitivity_List"
      },
      zOrder = 2,
      isMainUI = false,
      closeOnHide = true
    },
    SingleTraining_Sound_Footsteps = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Sound.SingleTrainFootstepsUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/Sound/SingleTraining_Sound_Footsteps_UIBP.SingleTraining_Sound_Footsteps_UIBP",
      uiStat = {
        name = "SingleTraining_Sound_Footsteps"
      },
      closeOnHide = false,
      zOrder = 2
    },
    SingleTraining_Sound_Gun = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Sound.SingleTrainGunUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/Sound/SingleTraining_Sound_Gun_UIBP.SingleTraining_Sound_Gun_UIBP",
      uiStat = {
        name = "SingleTraining_Sound_Gun"
      },
      closeOnHide = false,
      zOrder = 2
    },
    SingleTraining_Sound_Btn = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Sound.SingleTrainSoundBtnUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/Sound/SingleTraining_Sound_Btn_UIBP.SingleTraining_Sound_Btn_UIBP",
      uiStat = {
        name = "SingleTraining_Sound_Btn"
      },
      closeOnHide = false,
      zOrder = 1,
      AndroidBackType = EAndroidBackType.Ban
    },
    SingleTraining_Sound_Count = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Sound.SingleTrainSoundCountUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/Sound/SingleTraining_Sound_Count_UIBP.SingleTraining_Sound_Count_UIBP",
      uiStat = {
        name = "SingleTraining_Sound_Count"
      },
      AndroidBackType = EAndroidBackType.Ban,
      closeOnHide = false,
      zOrder = 2
    },
    SingleTrain_Sound_FlyNumManager = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Sound.SingleTrainSoundFlyNumManagerUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/Sound/SingleTraining_Sound_FlyNumManager_UIBP.SingleTraining_Sound_FlyNumManager_UIBP",
      uiStat = {
        name = "SingleTrain_Sound_FlyNumManager"
      },
      closeOnHide = false,
      AndroidBackType = EAndroidBackType.Ban
    },
    SingleTraining_Sound_Score = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Sound.SingleTrainSoundScoreUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/Sound/SingleTraining_Sound_Score_UIBP.SingleTraining_Sound_Score_UIBP",
      uiStat = {
        name = "SingleTraining_Sound_Score"
      },
      closeOnHide = false,
      zOrder = 2,
      AndroidBackType = EAndroidBackType.Ban
    },
    SingleTraining_Sound_Tips = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Sound.SingleTrainSoundTipsUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/Sound/SingleTraining_Sound_Tips_UIBP.SingleTraining_Sound_Tips_UIBP",
      uiStat = {
        name = "SingleTraining_Sound_Tips"
      },
      closeOnHide = false,
      zOrder = 2,
      AndroidBackType = EAndroidBackType.Ban
    },
    BallisticTargetUI = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Shooting.BallisticTargetUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTrain_Target_Item_UIBP.SingleTrain_Target_Item_UIBP",
      uiStat = {
        name = "BallisticTargetUI"
      },
      closeOnHide = false,
      zOrder = 1,
      AndroidBackType = EAndroidBackType.Ban
    },
    BallisticTargetDamageUI = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Shooting.BallisticTargetDamageUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTrain_BulletDamage_UIBP.SingleTrain_BulletDamage_UIBP",
      uiStat = {
        name = "BallisticTargetDamageUI"
      },
      closeOnHide = false,
      AndroidBackType = EAndroidBackType.Ban
    },
    BallisticTargetDamageMainUI = {
      moduleName = "GameLua.Mod.SingleTraining.Client.Shooting.BallisticTargetDamageMainUI",
      path = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTraining_DamageMainUI.SingleTraining_DamageMainUI",
      uiStat = {
        name = "BallisticTargetDamageMainUI"
      },
      closeOnHide = false,
      AndroidBackType = EAndroidBackType.Ban
    },
    EntireMapWindow = {
      moduleName = "GameLua.Mod.SingleTraining.Client.EntireMapWindow",
      path = "/Game/BluePrints/UI/Map/EntireMapUIWidget.EntireMapUIWidget",
      uiStat = {
        name = "EntireMapWindow"
      },
      closeOnHide = false,
      bPermanentDuringThisBattle = true,
      AndroidBackType = EAndroidBackType.Skip,
      zOrder = 100
    }
  },
  OldUIConfig = {
    Default = {
      "GrenadeChooseWidget",
      "MedicineChooseWidget",
      "LeftKillInfo"
    },
    ModAdd = {}
  }
}
return Config