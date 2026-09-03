local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
require("client.slua.config.ClientMacros.bp_macros")
local assembly_ui_configs = {
  assembly_share_component_jk = {
    keyName = "assembly_share_component_jk",
    moduleName = "client.slua.umg.activity.assembly.jk.assembly_share_component_jk",
    path = "/Game/UMG/UI_BP/Lobby/Shareinterface_UIBP_New.Shareinterface_UIBP_New",
    uiStat = {
      name = "\229\143\172\229\155\158\230\180\187\229\138\168-\230\151\165\233\159\169\231\139\172\231\171\139\229\143\172\229\155\158-\229\136\134\228\186\171\231\187\132\228\187\182"
    }
  },
  assembly_share_component = {
    keyName = "assembly_share_component",
    moduleName = "client.slua.umg.activity.assembly.assembly_share_component",
    path = "/Game/UMG/UI_BP/Lobby/Shareinterface_UIBP_New.Shareinterface_UIBP_New"
  },
  Assembly_Team_Invite_Tip_UIBP = {
    keyName = "Assembly_Team_Invite_Tip_UIBP",
    moduleName = "client.slua.umg.teamup.Assembly_Team_Invite_Tip_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Team_Invite_Tip_UIBP.Team_Invite_Tip_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\143\172\229\155\158-\233\130\128\232\175\183\231\187\132\233\152\159\230\181\174\231\170\151"
    }
  },
  JKRecall = {
    keyName = "JKRecall",
    moduleName = "client.slua.umg.activity.new_activity_center.JKRecall",
    path = "/Game/Mod/Lobby/Split/NewActivity/NewActivty_COMEBACK/JK/LOBBY_ComeBack_Task_JK_Popup_01_UIBP.LOBBY_ComeBack_Task_JK_Popup_01_UIBP",
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\230\151\165\233\159\169\231\139\172\231\171\139\229\143\172\229\155\158\233\130\128\232\175\183\228\186\186"
    }
  },
  LOBBY_ComeBack_Assembly_Set_UIBP = {
    keyName = "LOBBY_ComeBack_Assembly_Set_UIBP",
    moduleName = "client.slua.umg.activity.assembly.LOBBY_ComeBack_Assembly_Set_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/COMEBACK/LOBBY_ComeBack_Assembly_Set_UIBP.LOBBY_ComeBack_Assembly_Set_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\232\181\155\228\186\139\230\153\139\231\186\167\229\188\185\231\170\151"
    }
  },
  assembly_award_page = {
    keyName = "assembly_award_page",
    moduleName = "client.slua.umg.activity.assembly.assembly_award_page",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/COMEBACK/LOBBY_ComeBack_Task_Assembly_04_UIBP.LOBBY_ComeBack_Task_Assembly_04_UIBP",
    uiStat = {
      name = "\229\143\172\229\155\158\230\180\187\229\138\168-\229\155\158\229\189\146\229\165\150\229\138\177"
    },
    isSingleton = false,
    isMainUI = false
  },
  assembly_invite_share = {
    keyName = "assembly_invite_share",
    moduleName = "client.slua.umg.activity.assembly.assembly_invite_share",
    isSingleton = false,
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/COMEBACK/LOBBY_ComeBack_Assembly_Share_UIBP.LOBBY_ComeBack_Assembly_Share_UIBP",
    uiStat = {
      name = "\229\143\172\229\155\158\230\180\187\229\138\168-\233\130\128\232\175\183\229\136\134\228\186\171"
    }
  },
  LOBBY_ComeBack_Task_JK_UIBP = {
    keyName = "LOBBY_ComeBack_Task_JK_UIBP",
    moduleName = "client.slua.umg.activity.assembly.jk.LOBBY_ComeBack_Task_JK_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/NewActivty_COMEBACK/JK/LOBBY_ComeBack_Task_JK_UIBP.LOBBY_ComeBack_Task_JK_UIBP",
    uiStat = {
      name = "\229\143\172\229\155\158\230\180\187\229\138\168-\230\151\165\233\159\169\231\139\172\231\171\139\229\143\172\229\155\158"
    },
    isMainUI = false
  },
  assembly_friend_invite_popup_jk = {
    keyName = "assembly_friend_invite_popup_jk",
    moduleName = "client.slua.umg.activity.assembly.jk.assembly_friend_invite_popup_jk",
    path = "/Game/Mod/Lobby/Split/NewActivity/NewActivty_COMEBACK/JK/LOBBY_ComeBack_Task_JK_Popup_UIBP.LOBBY_ComeBack_Task_JK_Popup_UIBP",
    uiStat = {
      name = "\229\143\172\229\155\158\230\180\187\229\138\168-\230\151\165\233\159\169\231\139\172\231\171\139\229\143\172\229\155\158-\229\183\178\229\143\172\229\155\158\229\136\151\232\161\168"
    }
  },
  assembly_friend_share_jk = {
    keyName = "assembly_friend_share_jk",
    moduleName = "client.slua.umg.activity.assembly.jk.assembly_friend_share_jk",
    path = "/Game/Mod/Lobby/Split/NewActivity/NewActivty_COMEBACK/JK/LOBBY_ComeBack_Task_JK_Share_UIBP.LOBBY_ComeBack_Task_JK_Share_UIBP",
    uiStat = {
      name = "\229\143\172\229\155\158\230\180\187\229\138\168-\230\151\165\233\159\169\231\139\172\231\171\139\229\143\172\229\155\158-\229\136\134\228\186\171\229\155\190"
    }
  },
  LOBBY_ComeBack_Task_UIBP = {
    keyName = "LOBBY_ComeBack_Task_UIBP",
    moduleName = "client.slua.umg.task.Task_Integration.LOBBY_ComeBack_Task_UIBP",
    path = "/Game/Mod/Lobby/Split/AssemblyComeBack/LOBBY_ComeBack_Task_UIBP.LOBBY_ComeBack_Task_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\187\187\229\138\161-\229\143\172\229\155\158&\231\187\132\233\152\159\228\187\187\229\138\161"
    }
  },
  LOBBY_ComeBack_TaskTips_UIBP = {
    keyName = "LOBBY_ComeBack_TaskTips_UIBP",
    moduleName = "client.slua.umg.task.Task_Integration.LOBBY_ComeBack_TaskTips_UIBP",
    path = "/Game/Mod/Lobby/Split/AssemblyComeBack/LOBBY_ComeBack_TaskTips_UIBP.LOBBY_ComeBack_TaskTips_UIBP",
    uiStat = {
      name = "\229\143\172\229\155\158\228\187\187\229\138\161\232\191\155\229\186\166\229\188\185\231\170\151"
    }
  },
  Lobby_Integration_Assembly_Exchange_UIBP = {
    keyName = "Lobby_Integration_Assembly_Exchange_UIBP",
    moduleName = "client.slua.umg.task.Task_Integration.Lobby_Integration_Assembly_Exchange_UIBP",
    path = "/Game/UMG/UI_BP/Task/Task_Integration/Task_New/Lobby_Integration_Assembly_Exchange_UIBP.Lobby_Integration_Assembly_Exchange_UIBP",
    uiStat = {
      name = "\228\187\187\229\138\161-\229\143\172\229\155\158\229\133\145\230\141\162"
    },
    isMainUI = false
  },
  Lobby_Integration_Assembly_Exchange_Main_UIBP = {
    keyName = "Lobby_Integration_Assembly_Exchange_Main_UIBP",
    moduleName = "client.slua.umg.task.Task_Integration.Lobby_Integration_Assembly_Exchange_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_CALLBACK_EXCHANGE,
    path = "/Game/UMG/UI_BP/Task/Task_Integration/Task_New/Lobby_Integration_Assembly_Exchange_UIBP.Lobby_Integration_Assembly_Exchange_UIBP",
    uiStat = {
      name = "\228\187\187\229\138\161-\229\143\172\229\155\158\229\133\145\230\141\162"
    }
  },
  Lobby_Backflow_Assembly_Award_UIBP = {
    keyName = "Lobby_Backflow_Assembly_Award_UIBP",
    moduleName = "client.slua.umg.task.Task_Integration.Lobby_Backflow_Assembly_Award_UIBP",
    path = "/Game/Mod/Lobby/Split/AssemblyComeBack/Lobby_Backflow_Assembly_Award_UIBP.Lobby_Backflow_Assembly_Award_UIBP",
    uiStat = {
      name = "\228\187\187\229\138\161-\229\143\172\229\155\158\229\188\149\229\175\188"
    }
  },
  Assembly_New_Main_UIBP = {
    keyName = "Assembly_New_Main_UIBP",
    moduleName = "client.slua.umg.AssemblyComeBack.Assembly_New_Main_UIBP",
    path = "/Game/Mod/Lobby/Split/AssemblyComeBack/Assembly_Main_UIBP.Assembly_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_ASSEMBLY,
    uiStat = {
      name = "\230\150\176\231\137\136\233\155\134\231\187\147\231\179\187\231\187\159\228\184\187\231\149\140\233\157\162"
    }
  },
  Assembly_Rally_UIBP = {
    keyName = "Assembly_Rally_UIBP",
    moduleName = "client.slua.umg.AssemblyComeBack.Assembly_Rally_UIBP",
    path = "/Game/Mod/Lobby/Split/AssemblyComeBack/Assembly_Rally_UIBP.Assembly_Rally_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\155\134\231\187\147\231\179\187\231\187\159-\229\143\172\229\155\158\233\161\181"
    }
  },
  Assembly_TeamUp_UIBP = {
    keyName = "Assembly_TeamUp_UIBP",
    moduleName = "client.slua.umg.AssemblyComeBack.Assembly_TeamUp_UIBP",
    path = "/Game/Mod/Lobby/Split/AssemblyComeBack/Assembly_TeamUp_UIBP.Assembly_TeamUp_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\155\134\231\187\147\231\179\187\231\187\159-\231\187\132\233\152\159\233\161\181"
    }
  },
  Assembly_Popup_Missions_UIBP = {
    keyName = "Assembly_Popup_Missions_UIBP",
    moduleName = "client.slua.umg.AssemblyComeBack.Popup.Assembly_Popup_Missions_UIBP",
    path = "/Game/Mod/Lobby/Split/AssemblyComeBack/Popup/Assembly_Popup_Missions_UIBP.Assembly_Popup_Missions_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\233\155\134\231\187\147\231\179\187\231\187\159-\229\143\172\229\155\158\228\187\187\229\138\161\229\188\185\231\170\151"
    }
  },
  Assembly_Popup_Share_UIBP = {
    keyName = "Assembly_Popup_Share_UIBP",
    moduleName = "client.slua.umg.AssemblyComeBack.Popup.Assembly_Popup_Share_UIBP",
    path = "/Game/Mod/Lobby/Split/AssemblyComeBack/Popup/Assembly_Popup_Share_UIBP.Assembly_Popup_Share_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\155\134\231\187\147\231\179\187\231\187\159-\229\136\134\228\186\171\229\188\185\231\170\151"
    }
  },
  Assembly_Bind_Popup_UIBP = {
    keyName = "Assembly_Bind_Popup_UIBP",
    moduleName = "client.slua.umg.AssemblyComeBack.Popup.Assembly_Bind_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/AssemblyComeBack/Popup/Assembly_Bind_Popup_UIBP.Assembly_Bind_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\233\155\134\231\187\147\231\179\187\231\187\159-\231\187\145\229\174\154\229\143\172\229\155\158\229\133\179\231\179\187\229\188\185\231\170\151"
    }
  }
}
return assembly_ui_configs