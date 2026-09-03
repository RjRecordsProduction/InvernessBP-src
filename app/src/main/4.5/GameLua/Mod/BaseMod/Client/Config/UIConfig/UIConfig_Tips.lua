local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Tips = {
  AITakeOverConfirmUI = {
    moduleName = "GameLua.Mod.BaseMod.GamePlay.AI.AITakeOverConfirmUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/TeammateTakeOver/AI_Popup_UIBP.AI_Popup_UIBP",
    uiStat = {
      name = "AITakeOverConfirmUI"
    },
    containerName = UIContainers.Top,
    isSingleton = true,
    asy = true,
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None
  },
  BackPackBtnGuidTip = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.GuideTipsUI.BackPackBtnGuidTip",
    path = "/Game/BluePrints/ControlInput/GuideTipsUI/BackPackBtnGuidTip.BackPackBtnGuidTip",
    isMainUI = false,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "BackPackBtnGuidTip"
    }
  },
  BattlePopStrongTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.BattlePopTipsUI.BattlePopStrongTips",
    path = "/Game/BluePrints/ControlInput/BattlePopTips/BattlePopStrongTips.BattlePopStrongTips",
    isSingleton = true,
    uiStat = {
      name = "BattlePopStrongTips"
    },
    isMainUI = false,
    containerName = UIContainers.Top,
    asy = true,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  BattlePopTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.BattlePopTipsUI.BattlePopTips",
    path = "/Game/BluePrints/ControlInput/BattlePopTips/BattlePopTips.BattlePopTips",
    isSingleton = true,
    uiStat = {
      name = "BattlePopTips"
    },
    isMainUI = false,
    containerName = UIContainers.Top,
    asy = true,
    showVisibility = UEnums.ESlateVisibility.HitTestInvisible,
    autoCreate = true,
    zOrder = 10000
  },
  BattlePopTipsUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.BattlePopTipsUI.BattlePopTipsUI",
    path = "/Game/BluePrints/ControlInput/BattlePopTips_Res.BattlePopTips_Res",
    isSingleton = true,
    uiStat = {
      name = "BattlePopTipsUI"
    },
    isMainUI = false,
    containerName = UIContainers.Bottom
  },
  BattlePopWeakSingleTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.BattlePopTipsUI.BattlePopWeakTips",
    path = "/Game/BluePrints/ControlInput/BattlePopTips/BattlePopWeakTips.BattlePopWeakTips",
    isSingleton = true,
    uiStat = {
      name = "BattlePopWeakSingleTips"
    },
    isMainUI = false,
    containerName = UIContainers.Top,
    asy = true,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  BattlePopWeakTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.BattlePopTipsUI.BattlePopWeakTips",
    path = "/Game/BluePrints/ControlInput/BattlePopTips/BattlePopWeakTips.BattlePopWeakTips",
    isSingleton = true,
    uiStat = {
      name = "BattlePopWeakTips"
    },
    isMainUI = false,
    containerName = UIContainers.Top,
    asy = true,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  BirthIslandTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.Tips.BirthIslandTips",
    path = "/Game/BluePrints/ControlInput/IngameUI/BirthIslandTips.BirthIslandTips",
    isMainUI = false,
    isWindowsOBHide = false,
    zOrder = 0,
    autoCreate = true,
    loadFromPool = EUIConfigPoolType.None,
    mountPanel = {
      mountOuterName = "MainControlBaseUI",
      mountName = "CanvasPanel_AutoJoinPanel"
    },
    asy = true,
    uiStat = {
      name = "BirthIslandTips"
    }
  },
  CommonConfirm = {
    moduleName = "GameLua.Mod.BaseMod.Common.Confirm.CommonConfirm",
    path = "/Game/BluePrints/ControlInput/IngameUI/ComfirmBox/CommonConfirm_UIBP.CommonConfirm_UIBP",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "CommonConfirm"
    }
  },
  EmergencyCallTips = {
    moduleName = "GameLua.Mod.Library.Client.UI.EmergencyCallTips",
    path = "/Game/Mod/EvoBase/BluePrints/UIBP/EmergencyCall/EmergencyCallTips_UIBP.EmergencyCallTips_UIBP",
    uiStat = {
      name = "EmergencyCallTips"
    },
    zOrder = 0,
    closeOnHide = true,
    loadFromPool = EUIConfigPoolType.None,
    isMainUI = false
  },
  FirstTimeTipsFPP = {
    moduleName = "GameLua.Mod.Library.Client.UI.FirstTimeTips.FirstTimeTipsFPP",
    path = "/Game/BluePrints/ControlInput/IngameFirstTimeTips/FirstTimeTips_FPP.FirstTimeTips_FPP",
    isMainUI = false,
    isWindowsOBHide = true,
    asy = true,
    zOrder = BP_ENUM_UI_RANK_ZORDER,
    uiStat = {
      name = "FirstTimeTipsFPP"
    }
  },
  FluctuationConfirm = {
    moduleName = "GameLua.Mod.BaseMod.Client.Tips.FluctuationConfirm",
    path = "/Game/BluePrints/ControlInput/IngameUI/ComfirmBox/FluctuationConfirm_UIBP.FluctuationConfirm_UIBP",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 80,
    mountPanel = {
      mountOuterName = "MainControlBaseUI",
      mountName = "CanvasPanel_42"
    },
    uiStat = {
      name = "FluctuationConfirm"
    }
  },
  HaveDeadBoxNearbyTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.GuideTipsUI.HaveDeadBoxNearbyTips",
    path = "/Game/BluePrints/ControlInput/GuideTipsUI/HaveDeadBoxNearbyTips.HaveDeadBoxNearbyTips",
    isMainUI = false,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "HaveDeadBoxNearbyTips"
    }
  },
  ImprisonmentTip = {
    moduleName = "GameLua.Mod.BaseMod.Client.Tips.ImprisonmentTip",
    path = "/Game/BluePrints/ControlInput/IngameUI/ImprisonmentTip_UIBP.ImprisonmentTip_UIBP",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 0,
    mountPanel = {
      mountOuterName = "MainControlBaseUI",
      mountName = "CanvasPanel_42"
    },
    uiStat = {
      name = "ImprisonmentTip"
    }
  },
  InspectionSystemKickPlayerConfirm = {
    moduleName = "GameLua.Mod.BaseMod.Client.InspectionSystem.InspectionSystemKickPlayerConfirm",
    path = "/Game/Mod/EvoBase/BluePrints/UI/InspectionSystem/InspectionSystemKickPlayerConfirm.InspectionSystemKickPlayerConfirm",
    isSingleton = true,
    uiStat = {
      name = "InspectionSystemReportButton"
    }
  },
  MiniTvBannerTipsUI = {
    moduleName = "GameLua.Mod.Library.Client.MiniTv.MiniTvBannerTipsUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/MiniTv/MiniTvBanner_Tips_UIBP.MiniTvBanner_Tips_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    uiStat = {
      name = "MiniTvBannerTipsUI"
    },
    isMainUI = false
  },
  MoveAimTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.GuideTipsUI.MoveAimTips",
    path = "/Game/BluePrints/ControlInput/GuideTipsUI/MoveAimTips.MoveAimTips",
    isMainUI = false,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "MoveAimTips"
    }
  },
  NightVisionConfirm = {
    moduleName = "GameLua.Mod.Library.Client.Tips.NightVisionConfirm",
    path = "/Game/BluePrints/ControlInput/IngameUI/ComfirmBox/NightVisionConfirm_UIBP.NightVisionConfirm_UIBP",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 80,
    mountPanel = {
      mountOuterName = "MainControlBaseUI",
      mountName = "CanvasPanel_42"
    },
    uiStat = {
      name = "NightVisionConfirm"
    }
  },
  QuickReportConfirmCancelWindow = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.QuickReportConfirmCancelWindow",
    path = "/Game/BluePrints/ControlInput/QuickReportConfirmCancelWindow_UIBP.QuickReportConfirmCancelWindow_UIBP",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "QuickReportConfirmCancelWindow"
    }
  },
  QuickReportConfirmWindow = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.QuickReportConfirmWindow",
    path = "/Game/BluePrints/ControlInput/QuickReportConfirmWindow_UIBP.QuickReportConfirmWindow_UIBP",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "QuickReportConfirmWindow"
    }
  },
  RealTimeBlocking = {
    moduleName = "GameLua.Mod.BaseMod.Client.Tips.RealTimeBlocking",
    path = "/Game/BluePrints/ControlInput/IngameUI/TipsItem/Real_time_Blocking.Real_time_Blocking",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 0,
    asy = true,
    mountPanel = {
      mountOuterName = "MainControlBaseUI",
      mountName = "CanvasPanel_KickOutTip"
    },
    uiStat = {
      name = "NightVisionConfirm"
    }
  },
  RevengeItemTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.KillInfoTips.RevengeItemTips",
    path = "/Game/BluePrints/ControlInput/IngameUI/TipsItem/KingEliminationItem02_Tips_UIBP.KingEliminationItem02_Tips_UIBP",
    isSingleton = true,
    uiStat = {
      name = "RevengeItemTips"
    },
    isMainUI = false,
    containerName = UIContainers.Top,
    asy = true,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  SecurityConfirmCancelWindowForTesting = {
    moduleName = "GameLua.Mod.BaseMod.Client.Security.UI.SecurityConfirmCancelWindowForTesting",
    path = "/Game/BluePrints/ControlInput/QuickReportConfirmCancelWindow_UIBP.QuickReportConfirmCancelWindow_UIBP",
    isSingleton = true,
    isMainUI = true,
    isWindowsOBHide = true,
    asy = true,
    uiStat = {
      name = "SecurityConfirmCancelWindowForTesting"
    }
  },
  SecurityNotifyNormalTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.Security.UI.SecurityNotifyNormalTips",
    path = "/Game/BluePrints/ControlInput/IDIP/Tlog_Tips_UIBP.Tlog_Tips_UIBP",
    isSingleton = true,
    uiStat = {
      name = "SecurityNotifyNormalTips"
    },
    isMainUI = false
  },
  ShowOffTipsUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.ShowOffTipsUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/ShowResultsText_UIBP.ShowResultsText_UIBP",
    uiStat = {
      name = "ShowOffTipsUI"
    },
    containerName = UIContainers.Default,
    closeOnHide = false,
    isSingleton = true,
    asy = true
  },
  SkillConfirmButton = {
    moduleName = "GameLua.Mod.BaseMod.Client.SkillPanel.SkillConfirmButton",
    path = "/Game/BluePrints/ControlInput/SkillUI/SkillConfirmButton_BP.SkillConfirmButton_BP",
    uiStat = {
      name = "SkillConfirmButton"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0,
    autoCreate = true,
    mountPanel = {
      mountOuterName = "ShootingUIPanel",
      mountName = "CanvasPanelLowRate"
    }
  },
  SwitchWeaponGuideTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.GuideTipsUI.SwitchWeaponGuideTips",
    path = "/Game/BluePrints/ControlInput/NewbieItem/SwitchWeaponGuideTips_UIBP.SwitchWeaponGuideTips_UIBP",
    uiStat = {
      name = "SwitchWeaponGuideTips"
    },
    zOrder = 0,
    closeOnHide = false,
    isMainUI = false,
    asy = true
  },
  VoiceReportPop = {
    moduleName = "GameLua.Mod.BaseMod.Client.Ban.VoiceReportPop",
    path = "/Game/BluePrints/ControlInput/IngameUI/Ban/VoiceReportBtn_Popup_UIBP.VoiceReportBtn_Popup_UIBP",
    uiStat = {
      name = "VoiceReportPop"
    },
    containerName = UIContainers.Default,
    isSingleton = true,
    AndroidBackType = EAndroidBackType.Ban,
    asy = true
  },
  DamageTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.DamageTips",
    path = "/Game/Mod/EvoBase/BluePrints/UIBP/DamageTips.DamageTips",
    uiStat = {name = "DamageTips"},
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.None
  },
  SidePopupTipsUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Tips.SidePopupTips.SidePopupTipsUIBase",
    path = "/Game/BluePrints/UI/GhostTips/SidePopupTips_UIBP.SidePopupTips_UIBP",
    containerName = UIContainers.Bottom,
    isSingleton = false,
    uiStat = {
      name = "SidePopupTipsUI"
    },
    isMainUI = false,
    asy = true
  },
  SidePopupTipsItemUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Tips.SidePopupTips.SidePopupTipsItemUIBase",
    path = "/Game/BluePrints/UI/GhostTips/SidePopupItemTips_UIBP.SidePopupItemTips_UIBP",
    containerName = UIContainers.Default,
    isSingleton = false,
    uiStat = {
      name = "SidePopupTipsItemUI"
    },
    isMainUI = false,
    asy = false,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  PromotionMissionAdvancementTipsUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Tips.PromotionMissionAdvancementTipsUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Tips/PromotionMission_Task_Tips02_UIBP.PromotionMission_Task_Tips02_UIBP",
    isSingleton = true,
    uiStat = {
      name = "PromotionMissionAdvancementTipsUI"
    },
    isMainUI = false,
    containerName = UIContainers.Top,
    asy = true,
    showVisibility = UEnums.ESlateVisibility.HitTestInvisible,
    zOrder = 10000
  },
  PromotionMissionTaskTipsUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Tips.PromotionMissionTaskTipsUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Tips/PromotionMission_Task_Tips02_UIBP.PromotionMission_Task_Tips02_UIBP",
    isSingleton = true,
    uiStat = {
      name = "PromotionMissionTaskTipsUI"
    },
    isMainUI = false,
    containerName = UIContainers.Top,
    asy = true,
    showVisibility = UEnums.ESlateVisibility.HitTestInvisible,
    zOrder = 10000
  },
  PromotionMissionTaskTeammateTipsUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Tips.PromotionMissionTaskTeammateTipsUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Tips/PromotionMission_Task_Tips03_UIBP.PromotionMission_Task_Tips03_UIBP",
    isSingleton = true,
    uiStat = {
      name = "PromotionMissionTaskTeammateTipsUI"
    },
    isMainUI = false,
    containerName = UIContainers.Top,
    asy = true,
    showVisibility = UEnums.ESlateVisibility.HitTestInvisible,
    zOrder = 10000
  },
  PromotionTaskParachuteTipsUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Tips.PromotionTaskParachuteTipsUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Tips/PromotionMission_Task_Tips04_UIBP.PromotionMission_Task_Tips04_UIBP",
    isSingleton = true,
    uiStat = {
      name = "PromotionTaskParachuteTipsUI"
    },
    isMainUI = false,
    containerName = UIContainers.Top,
    asy = true,
    showVisibility = UEnums.ESlateVisibility.HitTestInvisible,
    zOrder = 10000
  }
}
return UIConfig_Tips