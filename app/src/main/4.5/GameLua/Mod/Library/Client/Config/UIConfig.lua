local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local Config = {
  UIConfig = {
    MusicGameUI = {
      moduleName = "GameLua.Mod.Library.Client.MusicGameUI",
      path = "/Game/Mod/MusicFestival/BluePrints/UI/ElecMusic_UIBP.ElecMusic_UIBP",
      isSingleton = true,
      uiStat = {
        name = "MusicGameUI"
      },
      isMainUI = false,
      zOrder = 50
    },
    CatapultMachine_ChangeSeat_UI = {
      moduleName = "GameLua.Mod.Library.Client.CatapultMachine.CatapultMachineChangeSeatUI",
      path = "/Game/Mod/EvoBase/BluePrints/UIBP/CatapultMachine/CatapultMachineChangeSeatUI.CatapultMachineChangeSeatUI",
      uiStat = {
        name = "CatapultMachine_ChangeSeat_UI"
      },
      zOrder = 1,
      closeOnHide = false,
      isMainUI = false,
      asy = true
    },
    CatapultMachine_Button = {
      moduleName = "GameLua.Mod.Library.Client.CatapultMachine.CatapultMachineEnterUI",
      path = "/Game/Mod/EvoBase/BluePrints/UIBP/CatapultMachine/CatapultMachine_EnterUI.CatapultMachine_EnterUI",
      uiStat = {
        name = "CatapultMachine_Button"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true
    },
    CatapultMachine_TouchPanel = {
      moduleName = "GameLua.Mod.Library.Client.CatapultMachine.CatapultMachineTouchPanel",
      path = "/Game/Mod/EvoBase/BluePrints/UIBP/CatapultMachine/CatapultMachineUI_TouchPanel.CatapultMachineUI_TouchPanel",
      uiStat = {
        name = "CatapultMachine_TouchPanel"
      },
      containerName = UIContainers.Bottom,
      closeOnHide = false,
      isMainUI = false,
      asy = true
    },
    CatapultMachine_UI = {
      moduleName = "GameLua.Mod.Library.Client.CatapultMachine.CatapultMachineUI",
      path = "/Game/Mod/EvoBase/BluePrints/UIBP/CatapultMachine/CatapultMachineUI.CatapultMachineUI",
      uiStat = {
        name = "CatapultMachine_UI"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true
    },
    AutoAddHPUI = {
      moduleName = "GameLua.Mod.Library.Client.Buff.AutoAddHPUI",
      path = "/Game/Mod/EvoBase/Arts_PlayerBluePrints/Buffs/BuffAddHp_UIBP.BuffAddHp_UIBP",
      uiStat = {
        name = "AutoAddHPUI"
      },
      zOrder = 0,
      closeOnHide = true,
      isMainUI = false
    },
    DynahexSupply_Shop_UIBP = {
      moduleName = "GameLua.Mod.Library.Client.Store.DynahexSupply_Shop_UIBP",
      path = "/Game/Library/Res/Actors/DynahexSupply/BluePrints/UIBP/DynahexSupply_Shop_UIBP.DynahexSupply_Shop_UIBP",
      uiStat = {
        name = "DynahexSupply_Shop_UIBP"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true
    },
    DynahexSupply_Main = {
      moduleName = "GameLua.Mod.Library.Client.Store.DynahexSupply_Main",
      path = "/Game/Library/Res/Actors/DynahexSupply/BluePrints/UIBP/DynahexSupply_Main.DynahexSupply_Main",
      uiStat = {
        name = "DynahexSupply_Main"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true
    },
    UltraHandBreakFree_Button = {
      moduleName = "GameLua.Mod.Library.Client.UI.SkillButton.UltraBreakFreeButtonUI",
      path = "/Game/Library/Res/Skills/Mecha/Blueprints/UI/UltraBreakFreeButton.UltraBreakFreeButton",
      uiStat = {
        name = "UltraHandBreakFree_Button"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true
    },
    MechaColorChangeUI = {
      moduleName = "GameLua.Mod.Mecha.Client.UI.MechaColorChangeUI",
      path = "/Game/Library/Res/Actors/MechaPaint/Mecha_Coloring_UIBP.Mecha_Coloring_UIBP",
      uiStat = {
        name = "MechaColorChangeUI"
      },
      isMainUI = false,
      asy = true,
      zOrder = 1
    },
    MechaColorTipsUI = {
      moduleName = "GameLua.Mod.Mecha.Client.UI.MechaColorTipsUI",
      path = "/Game/Library/Res/Actors/MechaPaint/Mecha_Coloring_Tips_UIBP.Mecha_Coloring_Tips_UIBP",
      uiStat = {
        name = "MechaColorTipsUI"
      },
      isMainUI = false,
      asy = true,
      zOrder = 999
    },
    MechaPaint_InteractUI = {
      moduleName = "GameLua.Mod.Mecha.Client.UI.MechaPaintInteractUI",
      path = "/Game/Library/Res/Actors/MechaPaint/MechaPaint_InteractUI.MechaPaint_InteractUI",
      uiStat = {
        name = "MechaPaint_InteractUI"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true
    },
    MechaSeekAndLockUI = {
      moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.ControlUI.MechaSeekAndLockUI",
      path = "/Game/Library/Res/Vehicles/Mecha/BluePrints/UI/MissileAim_UIBP2.MissileAim_UIBP2",
      containerName = UIContainers.Default,
      zOrder = 0,
      showVisibility = UEnums.ESlateVisibility.Collapsed,
      uiStat = {
        name = "MechaSeekAndLockUI"
      },
      isMainUI = false,
      asy = true
    },
    SmartAssistantMainUIBP = {
      keyName = "SmartAssistantMainUIBP",
      moduleName = "GameLua.Mod.Library.Client.SmartAssistant.SmartAssistantMainUIBP",
      path = "/Game/Library/Res/Actors/SmartAssistant/BluePrints/UI/SmartAssistant_Main_UIBP.SmartAssistant_Main_UIBP",
      uiStat = {
        name = "SmartAssistantMainUIBP"
      },
      isSingleton = true,
      containerName = UIContainers.Default,
      zOrder = 10,
      closeOnHide = false,
      asy = true
    },
    SmartAssistantGuideUIBP = {
      keyName = "SmartAssistantGuideUIBP",
      moduleName = "GameLua.Mod.Library.Client.SmartAssistant.SmartAssistantGuideUIBP",
      path = "/Game/Library/Res/Actors/SmartAssistant/BluePrints/UI/SmartAssistant_Guide_UIBP.SmartAssistant_Guide_UIBP",
      uiStat = {
        name = "SmartAssistantGuideUIBP"
      },
      isSingleton = true,
      containerName = UIContainers.Default,
      zOrder = 11,
      closeOnHide = false,
      asy = true
    },
    SmartAssistantAnswerItemUIBP = {
      keyName = "SmartAssistantAnswerItemUIBP",
      moduleName = "GameLua.Mod.Library.Client.SmartAssistant.SmartAssistantAnswerItemUIBP",
      path = "/Game/Library/Res/Actors/SmartAssistant/BluePrints/UI/Item/SmartAssistant_Dialogue_Item_UIBP_01.SmartAssistant_Dialogue_Item_UIBP_01",
      uiStat = {
        name = "SmartAssistantAnswerItemUIBP"
      },
      isSingleton = false,
      isMainUI = false,
      asy = true
    }
  }
}
return Config