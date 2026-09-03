local PufferConst = require("client.slua.logic.download.puffer_const")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local LobbyQueuePopUIKeyDefine = require("client.slua.config.LobbyQueuePopUIKeyDefine")
local ESlateVisibility = UEnums and UEnums.ESlateVisibility or {}
local Visible = ESlateVisibility.Visible
local Collapsed = ESlateVisibility.Collapsed
require("client.slua.config.ClientMacros.bp_macros")
require("client.common.game_status")
require("client.slua.config.ClientMacros.EFixedZOrder")
require("client.slua.config.ClientMacros.UIContainers")
require("client.common.SlateUI_ID")
local teamup_ui_configs = {
  TeamQuick_Create_UIBP = {
    keyName = "TeamQuick_Create_UIBP",
    moduleName = "client.slua.umg.TeamQuick.TeamQuick_Create_UIBP",
    path = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_Create_UIBP.TeamQuick_Create_UIBP",
    jumpModuleID = BP_ENUM_MODULE_QUICKTEAM_CREATE,
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\136\155\229\187\186\229\176\143\233\152\159"
    }
  },
  TeamQuick_Lobby_Main = {
    keyName = "TeamQuick_Lobby_Main",
    moduleName = "client.slua.umg.TeamQuick.TeamQuick_Lobby_Main",
    path = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_Lobby_Main.TeamQuick_Lobby_Main",
    jumpModuleID = BP_ENUM_MODULE_QUICKTEAM_LOBBY,
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\164\167\229\142\133\228\184\187\231\149\140\233\157\162"
    }
  },
  TeamQuick_TeamCard_LabelItem = {
    keyName = "TeamQuick_TeamCard_LabelItem",
    moduleName = "client.slua.umg.TeamQuick.Item.TeamQuick_TeamCard_LabelItem",
    path = "/Game/UMG/UI_BP/TeamQuick/Item/TeamQuick_Share_Item01.TeamQuick_Share_Item01",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\174\154\229\136\182-\229\176\143\233\152\159\230\160\135\231\173\190"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  TeamQuick_Share_Item01 = {
    keyName = "TeamQuick_Share_Item01",
    moduleName = "client.slua.umg.TeamQuick.Item.TeamQuick_TeamCard_LabelItem",
    path = "/Game/UMG/UI_BP/TeamQuick/Item/TeamQuick_Share_Item01.TeamQuick_Share_Item01",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159\233\166\150\233\161\181-\229\176\143\233\152\159\230\160\135\231\173\190"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  TeamQuick_TeamCard_Chat_LabelItem = {
    keyName = "TeamQuick_TeamCard_Chat_LabelItem",
    moduleName = "client.slua.umg.TeamQuick.Item.TeamQuick_TeamCard_LabelItem",
    path = "/Game/UMG/UI_BP/TeamQuick/Item/TeamQuick_TeamCard_LabelItem.TeamQuick_TeamCard_LabelItem",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159\232\129\138\229\164\169-\229\176\143\233\152\159\230\160\135\231\173\190"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  TeamQuick_TeamSkin_UIBP = {
    keyName = "TeamQuick_TeamSkin_UIBP",
    moduleName = "client.slua.umg.TeamQuick.TeamQuick_TeamSkin_UIBP",
    path = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_TeamSkin_UIBP.TeamQuick_TeamSkin_UIBP",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\174\154\229\136\182"
    }
  },
  TeamQuick_IDSkin_UIBP = {
    keyName = "TeamQuick_IDSkin_UIBP",
    moduleName = "client.slua.umg.TeamQuick.TeamQuick_IDSkin_UIBP",
    path = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_IDSkin_UIBP.TeamQuick_IDSkin_UIBP",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\174\154\229\136\182-\229\176\143\233\152\159\230\152\181\231\167\176\233\162\156\232\137\178"
    },
    isMainUI = false
  },
  TeamQuick_BroadcastSkin_UIBP = {
    keyName = "TeamQuick_BroadcastSkin_UIBP",
    moduleName = "client.slua.umg.TeamQuick.TeamQuick_BroadcastSkin_UIBP",
    path = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_BroadcastSkin_UIBP.TeamQuick_BroadcastSkin_UIBP",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\174\154\229\136\182-\229\135\186\231\148\159\229\178\155\230\146\173\230\138\165"
    },
    isMainUI = false
  },
  TeamQuick_BGSkin_UIBP = {
    keyName = "TeamQuick_BGSkin_UIBP",
    moduleName = "client.slua.umg.TeamQuick.TeamQuick_BGSkin_UIBP",
    path = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_BGSkin_UIBP.TeamQuick_BGSkin_UIBP",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\174\154\229\136\182-\229\176\143\233\152\159\232\131\140\230\153\175"
    },
    isMainUI = false
  },
  TeamQuick_EffectSkin_UIBP = {
    keyName = "TeamQuick_EffectSkin_UIBP",
    moduleName = "client.slua.umg.TeamQuick.TeamQuick_EffectSkin_UIBP",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\174\154\229\136\182-\230\149\136\230\158\156\230\140\130\232\189\189"
    },
    isSingleton = false,
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  TeamQuick_TeamCard_Item_Preview = {
    keyName = "TeamQuick_TeamCard_Item_Preview",
    moduleName = "client.slua.umg.TeamQuick.TeamQuick_TeamCard_Item_Preview",
    path = "/Game/UMG/UI_BP/TeamQuick/Item/TeamQuick_TeamCard_Item.TeamQuick_TeamCard_Item",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\174\154\229\136\182-\229\164\167\229\142\133\231\149\140\233\157\162\230\151\182\231\154\132\233\162\132\232\167\136"
    },
    isMainUI = false
  },
  TeamQuick_TeamCard_Item_1_Preview = {
    keyName = "TeamQuick_TeamCard_Item_1_Preview",
    moduleName = "client.slua.umg.TeamQuick.TeamQuick_TeamCard_Item_1_Preview",
    path = "/Game/UMG/UI_BP/TeamQuick/Item/TeamQuick_TeamCard_Item_1.TeamQuick_TeamCard_Item_1",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\174\154\229\136\182-\229\176\143\233\152\159\232\175\166\230\131\133\231\149\140\233\157\162\230\151\182\231\154\132\233\162\132\232\167\136"
    },
    isMainUI = false
  },
  TeamQuick_Broadcast_Preview = {
    keyName = "TeamQuick_Broadcast_Preview",
    moduleName = "client.slua.umg.TeamQuick.TeamQuick_Broadcast_Preview",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\174\154\229\136\182-\229\135\186\231\148\159\229\178\155\230\146\173\230\138\165\233\162\132\232\167\136"
    },
    isSingleton = false,
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  TeamQuick_Main_UIBP = {
    keyName = "TeamQuick_Main_UIBP",
    moduleName = "client.slua.umg.TeamQuick.TeamQuick_Main_UIBP",
    path = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_Main_UIBP.TeamQuick_Main_UIBP",
    uiStat = {
      name = "\233\151\170\233\133\141\229\164\167\229\142\133\228\184\187\231\149\140\233\157\162"
    }
  },
  TeamQuick_TeamSetting_Popup = {
    keyName = "TeamQuick_TeamSetting_Popup",
    moduleName = "client.slua.umg.TeamQuick.Popup.TeamQuick_TeamSetting_Popup",
    path = "/Game/UMG/UI_BP/TeamQuick/Popup/TeamQuick_TeamSetting_Popup.TeamQuick_TeamSetting_Popup",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\176\143\233\152\159\232\174\190\231\189\174"
    }
  },
  TeamQuick_TeamMember_Tips = {
    keyName = "TeamQuick_TeamMember_Tips",
    moduleName = "client.slua.umg.TeamQuick.Item.TeamQuick_TeamMember_Tips",
    path = "/Game/UMG/UI_BP/TeamQuick/Item/TeamQuick_TeamMember_Tips.TeamQuick_TeamMember_Tips",
    uiStat = {
      name = "\233\151\170\233\133\141\229\164\167\229\142\133-\230\136\144\229\145\152\230\147\141\228\189\156\229\173\144\230\142\167\228\187\182"
    }
  },
  TeamQuick_TeamApplication_Popup = {
    keyName = "TeamQuick_TeamApplication_Popup",
    moduleName = "client.slua.umg.TeamQuick.Popup.TeamQuick_TeamApplication_Popup",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/TeamQuick/TeamQuick_TeamApplication_Popup.TeamQuick_TeamApplication_Popup",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\165\189\229\143\139&\229\176\143\233\152\159\231\148\179\232\175\183\231\149\140\233\157\162"
    }
  },
  TeamQuick_TeamApplicationLeader_Popup = {
    keyName = "TeamQuick_TeamApplicationLeader_Popup",
    moduleName = "client.slua.umg.TeamQuick.Popup.TeamQuick_TeamApplicationLeader_Popup",
    path = "/Game/UMG/UI_BP/TeamQuick/Popup/TeamQuick_TeamApplicationLeader_Popup.TeamQuick_TeamApplicationLeader_Popup",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\165\189\229\143\139&\229\176\143\233\152\159\231\148\179\232\175\183\231\149\140\233\157\162(\233\152\159\233\149\191)"
    }
  },
  TeamQuick_Reserve_Popup = {
    keyName = "TeamQuick_Reserve_Popup",
    moduleName = "client.slua.umg.TeamQuick.Popup.TeamQuick_Reserve_Popup",
    path = "/Game/UMG/UI_BP/TeamQuick/Popup/TeamQuick_Reserve_Popup.TeamQuick_Reserve_Popup",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\143\145\232\181\183\233\162\132\231\186\166"
    }
  },
  TeamQuick_Reserve_Tips_UIBP = {
    keyName = "TeamQuick_Reserve_Tips_UIBP",
    moduleName = "client.slua.umg.TeamQuick.Popup.TeamQuick_Reserve_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/TeamQuick_Reserve_Tips_UIBP.TeamQuick_Reserve_Tips_UIBP",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\138\160\229\133\165\233\162\132\231\186\166"
    }
  },
  Lobby_TeamQuick_Chat_UIBP = {
    keyName = "Lobby_TeamQuick_Chat_UIBP",
    moduleName = "client.slua.umg.LobbyChat.LobbyChat_170.Item.ChatBar.Lobby_TeamQuick_Chat_UIBP",
    path = "/Game/UMG/UI_BP/LobbyChat/LobbyChat_170/Item/TeamQuickBar/Lobby_TeamQuick_Chat_UIBP.Lobby_TeamQuick_Chat_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\164\167\229\142\133\232\129\138\229\164\169-\228\190\167\232\190\185\230\160\143-\233\151\170\233\133\141\229\176\143\233\152\159\228\191\161\230\129\175"
    }
  },
  TeamQuick_Share_UIBP = {
    keyName = "TeamQuick_Share_UIBP",
    moduleName = "client.slua.umg.lobby.FlashMatchTeam.TeamQuick_Share_UIBP",
    path = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_Share_UIBP.TeamQuick_Share_UIBP",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\138\160\229\133\165\229\176\143\233\152\159-\229\136\134\228\186\171\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  TeamQuick_InviteFriend_Popup = {
    keyName = "TeamQuick_InviteFriend_Popup",
    moduleName = "client.slua.umg.TeamQuick.TeamQuick_InviteFriend_Popup",
    path = "/Game/UMG/UI_BP/TeamQuick/Popup/TeamQuick_SelectFriend_Popup.TeamQuick_SelectFriend_Popup",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\176\143\233\152\159\232\129\138\229\164\169-\233\130\128\232\175\183\229\165\189\229\143\139"
    }
  },
  TeamQuick_InviteTeamUp_Popup = {
    keyName = "TeamQuick_InviteTeamUp_Popup",
    moduleName = "client.slua.umg.TeamQuick.TeamQuick_InviteTeamUp_Popup",
    path = "/Game/UMG/UI_BP/TeamQuick/Popup/TeamQuick_InviteTeamUp_Popup.TeamQuick_InviteTeamUp_Popup",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\176\143\233\152\159\232\129\138\229\164\169-\233\130\128\232\175\183\230\136\144\229\145\152\233\162\132\231\187\132\233\152\159"
    }
  },
  TeamQuick_Message_Popup = {
    keyName = "TeamQuick_Message_Popup",
    moduleName = "client.slua.umg.TeamQuick.TeamQuick_Message_Popup",
    path = "/Game/UMG/UI_BP/TeamQuick/Popup/TeamQuick_Message_Popup.TeamQuick_Message_Popup",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\176\143\233\152\159\232\129\138\229\164\169-\229\176\143\233\152\159\231\149\153\232\168\128"
    }
  },
  TeamQuick_root_Item_UIBP = {
    keyName = "TeamQuick_root_Item_UIBP",
    moduleName = "client.slua.umg.TeamQuick.Item.TeamQuick_root_Item_UIBP",
    path = "/Game/UMG/UI_BP/LobbyChat/LobbyChat_170/TeamQuick_root_Item_UIBP.TeamQuick_root_Item_UIBP",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\176\143\233\152\159\232\129\138\229\164\169-\229\176\143\233\152\159\231\189\174\233\161\182\229\146\140\229\133\141\230\137\147\230\137\176\232\174\190\231\189\174\231\149\140\233\157\162"
    }
  },
  TeamQuick_RewardDetails_Popup = {
    keyName = "TeamQuick_RewardDetails_Popup",
    moduleName = "client.slua.umg.TeamQuick.Popup.TeamQuick_RewardDetails_Popup",
    path = "/Game/UMG/UI_BP/TeamQuick/Popup/TeamQuick_RewardDetails_Popup.TeamQuick_RewardDetails_Popup",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\233\187\152\229\165\145\229\186\166\229\165\150\229\138\177\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  Lobby_InviteFriend_TeamQuick_UIBP = {
    keyName = "Lobby_InviteFriend_TeamQuick_UIBP",
    moduleName = "client.slua.umg.lobby.Lobby_InviteFriend_TeamQuick_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Lobby_InviteFriend_TeamQuick_UIBP.Lobby_InviteFriend_TeamQuick_UIBP",
    uiStat = {
      name = "\229\165\189\229\143\139\233\157\162\230\157\191-\233\151\170\233\133\141\229\176\143\233\152\159\233\161\181\231\173\190"
    },
    isMainUI = false,
    isSingleton = false
  },
  TeamPlatform_RecommendedTeam_Tips = {
    keyName = "TeamPlatform_RecommendedTeam_Tips",
    moduleName = "client.slua.umg.TeamPlatform.TeamPlatform_New.TeamPlatform_RecommendedTeam_Tips",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/TeamPlatform_RecommendedTeam_Tips.TeamPlatform_RecommendedTeam_Tips",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\230\142\168\232\141\144\229\176\143\233\152\159Tips"
    },
    isMainUI = false,
    isSingleton = false
  }
}
return teamup_ui_configs