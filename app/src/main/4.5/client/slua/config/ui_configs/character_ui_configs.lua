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
local character_ui_configs = {
  CharacterSelect = {
    keyName = "CharacterSelect",
    moduleName = "GameLua.Mod.Lobby.Split.NewCharacter.umg.CharacterSelect",
    path = "/Game/Mod/Lobby/Split/NewCharacter/UIBP/CharacterUI_Select_UIBP.CharacterUI_Select_UIBP",
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178-\233\128\137\230\139\169\231\149\140\233\157\162"
    }
  },
  CharacterMain = {
    keyName = "CharacterMain",
    moduleName = "GameLua.Mod.Lobby.Split.NewCharacter.umg.CharacterMain",
    jumpModuleID = BP_ENUM_MODULE_CHARACTER,
    path = "/Game/Mod/Lobby/Split/NewCharacter/UIBP/CharacterUI_Main_UIBP01.CharacterUI_Main_UIBP01",
    asy = true,
    sceneID = 3,
    uiStat = {
      name = "\232\167\146\232\137\178-\228\184\187\231\149\140\233\157\162"
    }
  },
  CharacterHomePage = {
    keyName = "CharacterHomePage",
    moduleName = "GameLua.Mod.Lobby.Split.NewCharacter.umg.CharacterHomePage",
    path = "/Game/Mod/Lobby/Split/NewCharacter/UIBP/CharacterUI_HomePage.CharacterUI_HomePage",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178-\233\166\150\233\161\181"
    }
  },
  CharacterSkin = {
    keyName = "CharacterSkin",
    moduleName = "GameLua.Mod.Lobby.Split.NewCharacter.umg.CharacterSkin",
    path = "/Game/Mod/Lobby/Split/NewCharacter/UIBP/CharacterUI_clothes_UIBP.CharacterUI_clothes_UIBP",
    isMainUI = false,
    asy = true,
    isSingleton = false,
    uiStat = {
      name = "\232\167\146\232\137\178-\232\161\163\230\156\141\233\161\181"
    }
  },
  CharacterAction = {
    keyName = "CharacterAction",
    moduleName = "GameLua.Mod.Lobby.Split.NewCharacter.umg.CharacterAction",
    path = "/Game/Mod/Lobby/Split/NewCharacter/UIBP/CharacterUI_clothes_UIBP.CharacterUI_clothes_UIBP",
    isMainUI = false,
    asy = true,
    isSingleton = false,
    uiStat = {
      name = "\232\167\146\232\137\178-\229\138\168\228\189\156\233\161\181"
    }
  },
  CharacterVoice = {
    keyName = "CharacterVoice",
    moduleName = "GameLua.Mod.Lobby.Split.NewCharacter.umg.CharacterVoice",
    path = "/Game/Mod/Lobby/Split/NewCharacter/UIBP/CharacterUI_Main_Voice_UIBP.CharacterUI_Main_Voice_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178-\229\163\176\233\159\179\233\161\181"
    }
  },
  CharacterLevelPreview = {
    keyName = "CharacterLevelPreview",
    moduleName = "GameLua.Mod.Lobby.Split.NewCharacter.umg.CharacterLevelPreview",
    path = "/Game/Mod/Lobby/Split/NewCharacter/UIBP/CharacterUI_Main_Level_UIBP.CharacterUI_Main_Level_UIBP",
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178-\231\173\137\231\186\167\233\162\132\232\167\136"
    }
  },
  CharacterLevelUp = {
    keyName = "CharacterLevelUp",
    moduleName = "GameLua.Mod.Lobby.Split.NewCharacter.umg.CharacterLevelUp",
    path = "/Game/Mod/Lobby/Split/NewCharacter/UIBP/CharacterUI_Levelup_01_UIBP.CharacterUI_Levelup_01_UIBP",
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178-\229\141\135\231\186\167\231\149\140\233\157\162"
    }
  },
  CharacterLevelBox = {
    keyName = "CharacterLevelBox",
    moduleName = "GameLua.Mod.Lobby.Split.NewCharacter.umg.CharacterLevelBox",
    path = "/Game/Mod/Lobby/Split/NewCharacter/UIBP/CharacterUI_baoxiang_Preview_UIBP.CharacterUI_baoxiang_Preview_UIBP",
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178-\229\174\157\231\174\177\233\162\132\232\167\136"
    }
  },
  CharacterUseBox = {
    keyName = "CharacterUseBox",
    moduleName = "GameLua.Mod.Lobby.Split.NewCharacter.umg.CharacterUseBox",
    path = "/Game/Mod/Lobby/Split/NewCharacter/UIBP/CharacterUI_Use_Props_UIBP.CharacterUI_Use_Props_UIBP",
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178-\228\189\191\231\148\168\229\174\157\231\174\177"
    }
  },
  CharacterShare = {
    keyName = "CharacterShare",
    moduleName = "GameLua.Mod.Lobby.Split.NewCharacter.umg.CharacterShare",
    path = "/Game/Mod/Lobby/Split/NewCharacter/UIBP/CharacterUI_Share01_UIBP.CharacterUI_Share01_UIBP",
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178-\232\131\140\230\153\175\230\149\133\228\186\139\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  CharacterShareChoose = {
    keyName = "CharacterShareChoose",
    moduleName = "GameLua.Mod.Lobby.Split.NewCharacter.umg.CharacterShareChoose",
    path = "/Game/Mod/Lobby/Split/NewCharacter/UIBP/CharacterUI_Share02_UIBP.CharacterUI_Share02_UIBP",
    asy = true,
    uiStat = {
      name = "\229\136\134\228\186\171-\232\167\146\232\137\178"
    }
  },
  CharacterBuy = {
    keyName = "CharacterBuy",
    moduleName = "GameLua.Mod.Lobby.Split.NewCharacter.umg.CharacterBuy",
    path = "/Game/Mod/Lobby/Split/NewCharacter/UIBP/CharacterUI_Recharge_Popups_UIBP.CharacterUI_Recharge_Popups_UIBP",
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178-\232\180\173\228\185\176\229\188\185\231\170\151"
    }
  },
  CharacterBuyTicket = {
    keyName = "CharacterBuyTicket",
    moduleName = "GameLua.Mod.Lobby.Split.NewCharacter.umg.CharacterBuyTicket",
    path = "/Game/Mod/Lobby/Split/NewCharacter/UIBP/CharacterUI_Coupon_Popups_UIBP.CharacterUI_Coupon_Popups_UIBP",
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178-\229\133\145\230\141\162\229\136\184\231\188\150\232\190\145"
    }
  },
  Title_Main_UIBP = {
    keyName = "Title_Main_UIBP",
    moduleName = "client.slua.umg.roleInfo.Title.Title_Main_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Title/Title_Main_UIBP.Title_Main_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\232\141\163\232\170\137-\231\167\176\229\143\183"
    }
  },
  Title_Main_Guest_UIBP = {
    keyName = "Title_Main_Guest_UIBP",
    moduleName = "client.slua.umg.roleInfo.Title.Title_Main_Guset_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Title/Title_Main_UIBP.Title_Main_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\232\141\163\232\170\137-\231\167\176\229\143\183-\229\174\162\230\128\129"
    }
  },
  Title_Select_Popup_UIBP = {
    keyName = "Title_Select_Popup_UIBP",
    moduleName = "client.slua.umg.roleInfo.Title.Popup.Title_Select_Popup_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Title/Popup/Title_Select_Popup_UIBP.Title_Select_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\232\141\163\232\170\137-\231\167\176\229\143\183-\231\167\176\229\143\183\233\128\137\230\139\169"
    }
  },
  roleinfo_main = {
    keyName = "roleinfo_main",
    moduleName = "client.slua.umg.person_space.roleinfo_main",
    path = "/Game/UMG/UI_BP/RoleInfo/Lobby_NewRoleInfo_Mgr_UIBP.Lobby_NewRoleInfo_Mgr_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    jumpModuleID = BP_ENUM_MODULE_ROLEINFO,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175\228\184\187\231\149\140\233\157\162"
    }
  },
  Personalization_UIBP = {
    keyName = "Personalization_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_UIBP.Personalization_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176-\228\184\187\231\149\140\233\157\162"
    }
  },
  Personalization_Title_UIBP = {
    keyName = "Personalization_Title_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_Title_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_Title_UIBP.Personalization_Title_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176-\228\184\170\228\186\186\231\167\176\229\143\183"
    }
  },
  Personalization_Flag_UIBP = {
    keyName = "Personalization_Flag_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_Flag_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_Flag_UIBP.Personalization_Flag_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176-\229\155\189\229\174\182\230\151\151\229\184\156"
    }
  },
  Personalization_Avatar_UIBP = {
    keyName = "Personalization_Avatar_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_Avatar_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_Avatar_UIBP.Personalization_Avatar_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176-\229\164\180\229\131\143"
    }
  },
  Personalization_AvatarFrame_UIBP = {
    keyName = "Personalization_AvatarFrame_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_AvatarFrame_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_AvatarFrame_UIBP.Personalization_AvatarFrame_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176-\229\164\180\229\131\143\230\161\134"
    }
  },
  Personalization_Teambrand_UIBP = {
    keyName = "Personalization_Teambrand_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_Teambrand_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_Teambrand_UIBP.Personalization_Teambrand_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176-\229\144\141\231\137\140\230\161\134"
    }
  },
  Personalization_InvitationPopup_UIBP = {
    keyName = "Personalization_InvitationPopup_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_InvitationPopup_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_InvitationPopup_UIBP.Personalization_InvitationPopup_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176-\233\130\128\232\175\183\229\188\185\231\170\151"
    }
  },
  Personalization_InformationCard_UIBP = {
    keyName = "Personalization_InformationCard_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_InformationCard_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_InformationCard_UIBP.Personalization_InformationCard_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176-\228\184\170\228\186\186\229\144\141\231\137\135"
    }
  },
  Personalization_SocialCard_UIBP = {
    keyName = "Personalization_SocialCard_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_SocialCard_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_SocialCard_UIBP.Personalization_SocialCard_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176-\231\164\190\228\186\164\229\144\141\231\137\135"
    }
  },
  Personalization_Nickname_UIBP = {
    keyName = "Personalization_Nickname_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_Nickname_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_Nickname_UIBP.Personalization_Nickname_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176--\230\152\181\231\167\176\230\149\136\230\158\156"
    }
  },
  Personalization_TeamShow_UIBP = {
    keyName = "Personalization_TeamShow_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_TeamShow_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_TeamShow_UIBP.Personalization_TeamShow_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176--\230\152\181\231\167\176\233\162\156\232\137\178"
    }
  },
  Personalization_ChatBubble_UIBP = {
    keyName = "Personalization_ChatBubble_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_ChatBubble_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_ChatBubble_UIBP.Personalization_ChatBubble_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176-\232\129\138\229\164\169\230\176\148\230\179\161"
    }
  },
  Personalization_EntryAction_UIBP = {
    keyName = "Personalization_EntryAction_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_EntryAction_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_EntryAction_UIBP.Personalization_EntryAction_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176-\229\133\165\229\156\186\229\138\168\228\189\156"
    }
  },
  Personalization_RoleInfoBG_UIBP = {
    keyName = "Personalization_RoleInfoBG_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_RoleInfoBG_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_RoleInfoBG_UIBP.Personalization_RoleInfoBG_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176-\232\181\132\230\150\153\232\131\140\230\153\175"
    }
  },
  Personalization_Opening_UIBP = {
    keyName = "Personalization_Opening_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_Opening_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_Opening_UIBP.Personalization_Opening_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176-\229\188\128\229\177\128\229\138\168\231\148\187"
    }
  },
  Personalization_SocialCardFrame_UIBP = {
    keyName = "Personalization_SocialCardFrame_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_SocialCardFrame_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_SocialCard_UIBP.Personalization_SocialCard_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176-\231\164\190\228\186\164\229\144\141\231\137\135\230\161\134"
    }
  },
  Personalization_ProfileFrame_UIBP = {
    keyName = "Personalization_ProfileFrame_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_ProfileFrame_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_InformationCard_UIBP.Personalization_InformationCard_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175-\228\184\170\228\186\186\228\191\161\230\129\175\230\161\134"
    }
  },
  role_info_big_avatar = {
    keyName = "role_info_big_avatar",
    moduleName = "client.slua.umg.roleInfo/RoleInfo_BigAvatar",
    path = "/Game/UMG/UI_BP/RoleInfo/Lobby_RoleInfo_NewBigAvatar_UIBP.Lobby_RoleInfo_NewBigAvatar_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\229\164\167\229\164\180\229\131\143"
    }
  },
  setting_red_title = {
    keyName = "setting_red_title",
    moduleName = "client.slua.umg.NewSetting.Main.setting_red_title",
    path = "/Game/UMG/UI_BP/NewSetting/Setting_NewTitle_UIBP.Setting_NewTitle_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\231\186\162\231\130\185title"
    }
  },
  item_upgrade_shape_tab = {
    keyName = "item_upgrade_shape_tab",
    moduleName = "client.slua.umg.upgrade.item_upgrade_shape_tab",
    path = "/Game/UMG/UI_BP/NewItemUpgrade/ItemUpgrade_TitleTab_ImageUI.ItemUpgrade_TitleTab_ImageUI",
    isSingleton = false,
    uiStat = {
      name = "\231\160\148\231\169\182\230\137\128\229\189\162\230\128\129\229\136\135\230\141\162tab\231\187\132\228\187\182"
    }
  },
  Alias_popup = {
    keyName = "Alias_popup",
    moduleName = "client.slua.umg.shareChild.alias.alias_popup",
    path = "/Game/UMG/UI_BP/RoleInfo/Title_Get_UIBP.Title_Get_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\142\183\229\190\151\231\167\176\229\143\183\229\188\185\231\170\151"
    }
  },
  WarZoneTitle_Share = {
    keyName = "WarZoneTitle_Share",
    moduleName = "client.slua.umg.shareChild.share_warZoneTitle",
    path = "/Game/UMG/UI_BP/WarZone/WarZone_ShareRanking_UIBP.WarZone_ShareRanking_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\136\134\228\186\171-\230\136\152\229\140\186\230\142\146\232\161\140"
    }
  },
  ui_warzone_my_title2 = {
    keyName = "ui_warzone_my_title2",
    moduleName = "client.slua.umg.LBS.ui_warzone_my_title2",
    path = "/Game/UMG/UI_BP/LBS/WarZoneRanking_Popup_04_UIBP_2.WarZoneRanking_Popup_04_UIBP_2",
    uiStat = {
      name = "\230\136\152\229\140\186/LBS-\230\136\145\231\154\132\231\167\176\229\143\183\231\149\140\233\157\162"
    }
  },
  ui_warzone_my_title_item = {
    keyName = "ui_warzone_my_title_item",
    moduleName = "client.slua.umg.LBS.ui_warzone_my_title_item",
    path = "/Game/UMG/UI_BP/LBS/Item/WarZoneRanking_Popup_04_01_Item.WarZoneRanking_Popup_04_01_Item",
    isSingleton = false,
    uiStat = {
      name = "\230\136\152\229\140\186/LBS-\230\136\145\231\154\132\231\167\176\229\143\183\231\149\140\233\157\162-Item"
    }
  },
  ResultsOB_ResultTitle_UIBP = {
    keyName = "ResultsOB_ResultTitle_UIBP",
    moduleName = "client.slua.umg.obresults.ResultsOB_ResultTitle_UIBP",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/ResultsOB/New_ResultsOB_ResultTitle_UIBP.New_ResultsOB_ResultTitle_UIBP",
    uiStat = {
      name = "OB\231\187\147\231\174\151\231\149\140\233\157\162\230\157\176\229\135\186\231\142\169\229\174\182\229\177\149\231\164\186"
    }
  },
  Personalization_Information_Preview_UIBP = {
    keyName = "Personalization_Information_Preview_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_Information_Preview_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Item/Personalization_Information_Preview_UIBP.Personalization_Information_Preview_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\229\174\154\229\136\182-\228\191\161\230\129\175\229\141\161\233\162\132\232\167\136"
    }
  },
  Personalization_SocialCard_Preview_UIBP = {
    keyName = "Personalization_SocialCard_Preview_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_SocialCard_Preview_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Item/Personalization_SocialCard_Preview_UIBP.Personalization_SocialCard_Preview_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\229\174\154\229\136\182-\231\164\190\228\186\164\229\144\141\231\137\135\233\162\132\232\167\136"
    }
  },
  Personalization_Teambrand_Preview_UIBP = {
    keyName = "Personalization_Teambrand_Preview_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_Teambrand_Preview_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Item/Personalization_Teambrand_Preview_UIBP.Personalization_Teambrand_Preview_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\229\174\154\229\136\182-\229\144\141\231\137\140\230\161\134"
    }
  },
  Personalization_InvitationPopup_Preview_UIBP = {
    keyName = "Personalization_InvitationPopup_Preview_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_InvitationPopup_Preview_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Item/Personalization_InvitationPopup_Preview_UIBP.Personalization_InvitationPopup_Preview_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\229\174\154\229\136\182-\233\130\128\232\175\183\229\188\185\231\170\151"
    }
  },
  CharacterLevelUpAward = {
    keyName = "CharacterLevelUpAward",
    moduleName = "GameLua.Mod.Lobby.Split.NewCharacter.umg.CharacterLevelUpAward",
    path = "/Game/UMG/UI_BP/Common/CharacterUI_Levelup_02_UIBP.CharacterUI_Levelup_02_UIBP",
    uiStat = {
      name = "\232\167\146\232\137\178-\229\141\135\231\186\167\229\165\150\229\138\177\231\149\140\233\157\162"
    }
  },
  Weapon_Diy_Frame = {
    keyName = "Weapon_Diy_Frame",
    moduleName = "client.slua.umg.WeaponDIY.weapon_diy_frame",
    jumpModuleID = BP_ENUM_MODULE_WEAPON_DIY,
    path = "/Game/UMG/UI_BP/GunDIY/GunDIY_Frame_UIBP.GunDIY_Frame_UIBP",
    ODPackID = PufferConst.EODPackID.DIY,
    asy = true,
    sceneID = 2,
    uiStat = {
      name = "\230\158\170\230\162\176diy-\228\184\187\231\149\140\233\157\162"
    }
  },
  Weapon_Diy_Pattern = {
    keyName = "Weapon_Diy_Pattern",
    moduleName = "client.slua.umg.WeaponDIY.weapon_diy_pattern",
    path = "/Game/UMG/UI_BP/GunDIY/GunDIY_DiyPopup_UIBP.GunDIY_DiyPopup_UIBP",
    uiStat = {
      name = "\230\158\170\230\162\176diy\226\128\148PatternEditUI"
    }
  },
  weapon_diy_buy_box = {
    keyName = "weapon_diy_buy_box",
    moduleName = "client.slua.umg.WeaponDIY.weapon_diy_buy_box",
    path = "/Game/UMG/UI_BP/GunDIY/GunDIY_BuyTips_UIBP.GunDIY_BuyTips_UIBP",
    asy = true,
    uiStat = {
      name = "\230\158\170\230\162\176diy\226\128\148\229\174\157\231\174\177\232\142\183\229\143\150"
    }
  },
  weapon_diy_buy_detail = {
    keyName = "weapon_diy_buy_detail",
    moduleName = "client.slua.umg.WeaponDIY.weapon_diy_buy_detail",
    path = "/Game/UMG/UI_BP/GunDIY/GunDIY_DiyCheck_UIBP.GunDIY_DiyCheck_UIBP",
    asy = true,
    uiStat = {
      name = "\230\158\170\230\162\176diy\226\128\148\232\180\173\228\185\176\232\175\166\230\131\133"
    }
  },
  Weapon_Diy_Turntable = {
    keyName = "Weapon_Diy_Turntable",
    moduleName = "client.slua.umg.WeaponDIY.weapon_diy_turntable",
    path = "/Game/UMG/UI_BP/GunDIY/GunDIY_LuckyDraw_UIBP.GunDIY_LuckyDraw_UIBP",
    asy = true,
    jumpModuleID = BP_ENUM_MODULE_WEAPON_DIY_BOX,
    uiStat = {
      name = "\230\158\170\230\162\176diy\226\128\148\232\189\174\231\155\152"
    }
  },
  Weapon_Diy_NewTips = {
    keyName = "Weapon_Diy_NewTips",
    moduleName = "client.slua.umg.WeaponDIY.weapon_diy_newtips",
    path = "/Game/UMG/UI_BP/GunDIY/NewTips_UIBP.NewTips_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    asy = true,
    uiStat = {
      name = "\230\158\170\230\162\176diy\226\128\148\230\150\176\230\137\139\229\188\149\229\175\188"
    }
  },
  weapon_diy_exchange_list = {
    keyName = "weapon_diy_exchange_list",
    moduleName = "client.slua.umg.WeaponDIY.weapon_diy_exchange_list",
    path = "/Game/UMG/UI_BP/GunDIY/GunDIY_Exchange01_UIBP.GunDIY_Exchange01_UIBP",
    asy = true,
    uiStat = {
      name = "\230\158\170\230\162\176diy-\229\150\183\230\182\130\229\133\145\230\141\162\229\136\151\232\161\168"
    }
  },
  weapon_diy_exchange_detail = {
    keyName = "weapon_diy_exchange_detail",
    moduleName = "client.slua.umg.WeaponDIY.weapon_diy_exchange_detail",
    path = "/Game/UMG/UI_BP/GunDIY/GunDIY_Exchange02_UIBP.GunDIY_Exchange02_UIBP",
    asy = true,
    uiStat = {
      name = "\230\158\170\230\162\176diy-\229\150\183\230\182\130\229\133\145\230\141\162\231\149\140\233\157\162"
    }
  },
  weapon_diy_share = {
    keyName = "weapon_diy_share",
    moduleName = "client.slua.umg.WeaponDIY.weapon_diy_share",
    path = "/Game/UMG/UI_BP/GunDIY/GunDIY_Share_UIBP.GunDIY_Share_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\136\134\228\186\171-\230\158\170\230\162\176diy"
    }
  },
  weapon_diy_switch = {
    keyName = "weapon_diy_switch",
    moduleName = "client.slua.umg.WeaponDIY.weapon_diy_switch",
    path = "/Game/UMG/UI_BP/GunDIY/GunDIY_Switch_UIBP.GunDIY_Switch_UIBP",
    asy = true,
    uiStat = {
      name = "\230\158\170\230\162\176diy-\229\136\135\230\141\162\230\158\170\230\162\176"
    }
  },
  weapon_diy_control = {
    keyName = "weapon_diy_control",
    moduleName = "client.slua.umg.WeaponDIY.weapon_diy_control",
    path = "/Game/UMG/UI_BP/GunDIY/GunDIY_Control_UIBP.GunDIY_Control_UIBP",
    isMainUI = false
  },
  UpgradedWeaponKillFlauntDynamicUI = {
    keyName = "UpgradedWeaponKillFlauntDynamicUI",
    moduleName = "GameLua.Mod.BaseMod.Client.FlauntDynamicUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/Flaunt_WeaponHighlight_UIBP.Flaunt_WeaponHighlight_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\160\148\231\169\182\230\137\128-\229\141\135\231\186\167\231\139\153\229\135\187\230\158\170\229\135\187\230\157\128\233\171\152\229\133\137\230\151\182\229\136\187 UI"
    }
  }
}
return character_ui_configs