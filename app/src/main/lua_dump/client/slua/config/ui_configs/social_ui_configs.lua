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
local social_ui_configs = {
  Lobby_RoleInfo_IntimateRelationship_Popup_UIBP = {
    keyName = "Lobby_RoleInfo_IntimateRelationship_Popup_UIBP",
    moduleName = "client.slua.umg.friend.Lobby_RoleInfo_IntimateRelationship_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_IntimateRelationship_Popup_UIBP.Lobby_RoleInfo_IntimateRelationship_Popup_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    asy = true,
    uiStat = {
      name = "\229\165\189\229\143\139- \228\186\178\229\175\134\229\133\179\231\179\187\232\175\166\230\131\133"
    }
  },
  Lobby_RoleInfo_Intimacy_Apply_Small_UIBP = {
    keyName = "Lobby_RoleInfo_Intimacy_Apply_Small_UIBP",
    moduleName = "client.slua.umg.PersonSpace.item.Lobby_RoleInfo_Intimacy_Apply_Small_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/item/Lobby_RoleInfo_Intimacy_Apply_Small_UIBP.Lobby_RoleInfo_Intimacy_Apply_Small_UIBP",
    uiStat = {
      name = "\229\165\189\229\143\139- \228\186\178\229\175\134\229\133\179\231\179\187\232\175\166\230\131\133 - \229\176\143\229\188\185\231\170\151"
    }
  },
  Social_Person_Space_UIBP = {
    keyName = "Social_Person_Space_UIBP",
    moduleName = "client.slua.umg.lobby.Left.Social_Person_Space_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Left/Social_Person_Space_UIBP.Social_Person_Space_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    jumpModuleID = BP_ENUM_MODULE_ROLE_SPACE,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180"
    },
    useBatchOptimization = true
  },
  roleinfo_popularity = {
    keyName = "roleinfo_popularity",
    moduleName = "client.slua.umg.person_space.roleinfo_popularity",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Popularity_UIBP.Lobby_RoleInfo_Popularity_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    jumpModuleID = BP_ENUM_MODULE_ROLEINFO_POPULARITY,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175-\228\186\186\230\176\148\229\128\188\231\149\140\233\157\162"
    }
  },
  roleinfo_send_gift = {
    keyName = "roleinfo_send_gift",
    moduleName = "client.slua.umg.person_space.roleinfo_send_gift",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Present_Popup_UIBP.Lobby_RoleInfo_Present_Popup_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175-\232\181\160\233\128\129\231\164\188\231\137\169"
    },
    moduleID = 1009901
  },
  country_area_popup = {
    keyName = "country_area_popup",
    moduleName = "client.slua.umg.country_area.country_area_popup",
    path = "/Game/UMG/UI_BP/PopupNotice/Countryarea_BP.Countryarea_BP",
    asy = true,
    uiStat = {
      name = "\229\155\189\229\174\182\230\151\151\229\184\156-\229\188\185\231\170\151"
    }
  },
  Partner_Preview_UIBP = {
    keyName = "Partner_Preview_UIBP",
    moduleName = "client.slua.umg.person_space.partner_preview_uibp",
    path = "/Game/UMG/UI_BP/PersonSpace/Partner_Preview_UIBP.Partner_Preview_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    jumpModuleID = BP_ENUM_MODULE_INTIMACY_PARTNER_PREVIEW,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\186\178\229\175\134\230\139\141\230\161\163\233\162\132\232\167\136"
    }
  },
  Friend_ReserveGuide_Tips = {
    keyName = "Friend_ReserveGuide_Tips",
    moduleName = "client.slua.umg.friend.Friend_ReserveGuide_Tips",
    path = "/Game/UMG/UI_BP/Friend/Friend_ReserveGuide_Tips.Friend_ReserveGuide_Tips",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\164\167\229\142\133-\229\165\189\229\143\139\228\190\167\230\160\143\233\162\132\231\186\166\230\140\137\233\146\174\229\188\149\229\175\188\230\143\144\231\164\186"
    }
  },
  Lobby_InviteFriend_BP = {
    keyName = "Lobby_InviteFriend_BP",
    moduleName = "client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP",
    path = "/Game/UMG/UI_BP/Lobby/Lobby_InviteFriend_BP.Lobby_InviteFriend_BP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\164\167\229\142\133-\229\165\189\229\143\139\228\190\167\230\160\143"
    }
  },
  roleinfo_combat = {
    keyName = "roleinfo_combat",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_Combat180_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Lobby_RoleInfo_Combat180_UIBP.Lobby_RoleInfo_Combat180_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\184\170\228\186\186\230\136\152\231\187\169"
    }
  },
  roleinfo_segment = {
    keyName = "roleinfo_segment",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_Segment180_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Segment180_UIBP.Lobby_RoleInfo_Segment180_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\230\174\181\228\189\141\230\128\187\232\167\136"
    }
  },
  roleinfo_history_detail = {
    keyName = "roleinfo_history_detail",
    moduleName = "client.slua.umg.person_space.roleinfo_history_detail",
    path = "/Game/UMG/UI_BP/Lobby_ShareResultsRanking/LobbyResultsRanking_UIBP.LobbyResultsRanking_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\229\155\162\231\171\158\229\142\134\229\143\178\230\136\152\231\187\169"
    }
  },
  roleinfo_history_deathmatch = {
    keyName = "roleinfo_history_deathmatch",
    moduleName = "client.slua.umg.person_space.roleinfo_history_deathmatch",
    path = "/Game/UMG/UI_BP/RoleInfo/TeamCompetitionHistory_UIBP.TeamCompetitionHistory_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\229\155\162\231\171\158\232\175\166\230\131\133"
    }
  },
  roleinfo_relationship2 = {
    keyName = "roleinfo_relationship2",
    moduleName = "client.slua.umg.person_space.roleinfo_relationship_new",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_IntimateRelationship_02_UIBP.Lobby_RoleInfo_IntimateRelationship_02_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\186\178\229\175\134\229\133\179\231\179\1872"
    }
  },
  Lobby_RoleInfo_IntimateRelationship_Overview = {
    keyName = "Lobby_RoleInfo_IntimateRelationship_Overview",
    moduleName = "client.slua.umg.PersonSpace.Intimacy.Lobby_RoleInfo_IntimateRelationship_Overview",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_IntimateRelationship_03_UIBP.Lobby_RoleInfo_IntimateRelationship_03_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isMainUI = false,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\186\178\229\175\134\229\133\179\231\179\187-\228\186\178\229\175\134\229\165\189\229\143\139"
    }
  },
  Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP = {
    keyName = "Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Intimacy.Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isMainUI = false,
    path = "/Game/UMG/UI_BP/PersonSpace/Intimacy/Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP.Lobby_RoleInfo_IntimateRelationship_CanBuild_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\186\178\229\175\134\229\133\179\231\179\187-\229\187\186\231\171\139\229\133\179\231\179\187"
    }
  },
  Lobby_RoleInfo_IntimateRelationship_Loop_UIBP = {
    keyName = "Lobby_RoleInfo_IntimateRelationship_Loop_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_IntimateRelationship_Loop_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_IntimateRelationship_Loop_UIBP.Lobby_RoleInfo_IntimateRelationship_Loop_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\186\178\229\175\134\229\133\179\231\179\187-\229\187\186\231\171\139\229\133\179\231\179\187"
    }
  },
  Lobby_RoleInfo_IntimateRelationship_Item_UIBP = {
    keyName = "Lobby_RoleInfo_IntimateRelationship_Item_UIBP",
    moduleName = "client.slua.umg.PersonSpace.item.Lobby_RoleInfo_IntimateRelationship_Item_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/item/Lobby_RoleInfo_IntimateRelationship_Item_UIBP.Lobby_RoleInfo_IntimateRelationship_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\186\178\229\175\134\229\133\179\231\179\187-\229\187\186\231\171\139\229\133\179\231\179\187-\231\187\147\231\188\152\230\142\168\232\141\144"
    }
  },
  Intimacy_Popup_Black_UIBP = {
    keyName = "Intimacy_Popup_Black_UIBP",
    moduleName = "client.slua.umg.person_space.Intimacy_Popup_Black_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Intimacy_Popup_Black_UIBP.Intimacy_Popup_Black_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\186\178\229\175\134\229\133\179\231\179\187-\229\188\128\233\187\145\229\165\189\229\143\139\232\175\166\230\131\133"
    }
  },
  Intimacy_Popup_Rules_UIBP = {
    keyName = "Intimacy_Popup_Rules_UIBP",
    moduleName = "client.slua.umg.person_space.Intimacy_Popup_Rules_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Intimacy_Popup_Rules_UIBP.Intimacy_Popup_Rules_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\186\178\229\175\134\229\133\179\231\179\187-\229\188\128\233\187\145\229\165\189\229\143\139\232\167\132\229\136\153"
    }
  },
  SocialIsland_CreateByCard_UIBP = {
    keyName = "SocialIsland_CreateByCard_UIBP",
    moduleName = "client.slua.umg.SocialIsland.SocialIslandCreateByCardUIBP",
    path = "/Game/Mod/SocialIsland/UMG/UI_BP/SocialIsland_CreateByCard_UIBP.SocialIsland_CreateByCard_UIBP",
    uiStat = {
      name = "\228\186\164\229\143\139\229\178\155-\229\136\155\229\187\186"
    }
  },
  Sociallsland_SelectMap_UIBP = {
    keyName = "Sociallsland_SelectMap_UIBP",
    moduleName = "client.slua.umg.SocialIsland.Sociallsland_SelectMap_UIBP",
    path = "/Game/Mod/SocialIsland/UMG/UI_BP/Sociallsland_SelectMap_UIBP.Sociallsland_SelectMap_UIBP",
    uiStat = {
      name = "\228\186\164\229\143\139\229\178\155-\230\168\161\229\188\143\233\128\137\230\139\169"
    }
  },
  SocialIsland_Invite_Notify_UIBP = {
    keyName = "SocialIsland_Invite_Notify_UIBP",
    moduleName = "client.slua.umg.SocialIsland.SocialIslandInviteNotifyUIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Universal_Popup_SocialIsland_Invite_UIBP.Universal_Popup_SocialIsland_Invite_UIBP",
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\228\186\164\229\143\139\229\178\155-\233\130\128\232\175\183\233\128\154\231\159\165"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  ui_complaint_socialisland = {
    keyName = "ui_complaint_socialisland",
    moduleName = "client.slua.umg.complaint.ui_complaint_socialisland",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Item_UIBP2.Inform_Item_UIBP2",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\232\129\154\228\185\144\229\155\173"
    },
    isSingleton = false
  },
  Achievement_Share = {
    keyName = "Achievement_Share",
    moduleName = "client.slua.umg.shareChild.share_achievement",
    path = "/Game/UMG/UI_BP/RoleInfo/Achievement/ShareAchievement_UIBP.ShareAchievement_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\136\134\228\186\171-\230\136\144\229\176\177"
    }
  },
  Alias_Share = {
    keyName = "Alias_Share",
    moduleName = "client.slua.umg.shareChild.share_alias",
    path = "/Game/UMG/UI_BP/RoleInfo/ShareAlias_UIBP.ShareAlias_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\136\134\228\186\171-\231\167\176\229\143\183"
    }
  },
  Moment_Select_Friend_UIBP = {
    keyName = "Moment_Select_Friend_UIBP",
    moduleName = "client.slua.umg.moment.Popup.Moment_Select_Friend_UIBP",
    path = "/Game/UMG/UI_BP/Moment/Popup/Moment_Select_Friend_UIBP.Moment_Select_Friend_UIBP",
    containerName = UIContainers.Top,
    ZOrder = 1,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136@\229\165\189\229\143\139\233\128\137\230\139\169\231\149\140\233\157\162"
    }
  },
  sharing_evaluation = {
    keyName = "sharing_evaluation",
    moduleName = "client.slua.umg.person_space.sharing_evaluation",
    path = "/Game/UMG/UI_BP/PersonSpace/Sharing_Evaluation_UIBP.Sharing_Evaluation_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\229\175\185\229\177\128\232\175\132\228\187\183"
    }
  },
  Team_Evaluation_UIBP = {
    keyName = "Team_Evaluation_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Team_Evaluation_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Team_Evaluation_UIBP.Team_Evaluation_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\229\175\185\229\177\128\232\175\132\228\187\183\229\177\149\231\164\186\233\161\181\233\157\162"
    }
  },
  Return_FriendRecord_UIBP = {
    keyName = "Return_FriendRecord_UIBP",
    moduleName = "client.slua.umg.return_activity.Return_FriendRecord_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/Return_FriendRecord_UIBP.Return_FriendRecord_UIBP",
    uiStat = {
      name = "240\229\155\158\230\181\129\229\165\189\229\143\139\228\186\146\229\138\168\232\174\176\229\189\149"
    }
  },
  Return_FriendRecord_Announce = {
    keyName = "Return_FriendRecord_Announce",
    moduleName = "client.slua.umg.return_activity.Return_FriendRecord_Announce",
    path = "/Game/UMG/UI_BP/ReturnActivity/Return_FriendRecord_Announce.Return_FriendRecord_Announce",
    uiStat = {
      name = "240\229\155\158\230\181\129\229\165\189\229\143\139\228\186\146\229\138\168\231\149\153\232\168\128"
    }
  },
  Results_Recommended_Friend_UIBP = {
    keyName = "Results_Recommended_Friend_UIBP",
    moduleName = "GameLua.Mod.BaseMod.Client.BattleResult.BattleRecommendedFriend.Results_Recommended_Friend_UIBP",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Item/ResultsStatistics_Recommended_friend_UIBP.ResultsStatistics_Recommended_friend_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\231\187\147\231\174\151\230\142\168\232\141\144\229\165\189\229\143\139"
    }
  },
  Results_BackUser_Recommended_Friend_UIBP = {
    keyName = "Results_BackUser_Recommended_Friend_UIBP",
    moduleName = "GameLua.Mod.BaseMod.Client.BattleResult.BattleRecommendedFriend.Results_BackUser_Recommended_Friend_UIBP",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Item/ResultsStatistics_Recommended_friend_UIBP.ResultsStatistics_Recommended_friend_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\155\158\229\189\146-\231\187\147\231\174\151\230\142\168\232\141\144\229\165\189\229\143\139"
    }
  },
  Intimacy_Popup_Strategy_UIBP = {
    keyName = "Intimacy_Popup_Strategy_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Intimacy_Popup_Strategy_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Intimacy_Popup_Strategy_UIBP.Intimacy_Popup_Strategy_UIBP",
    asy = true,
    uiStat = {
      name = "\228\186\178\229\175\134\229\133\179\231\179\187-\230\148\187\231\149\165\229\188\185\231\170\151"
    }
  },
  Intimacy_Popup_StrategyTwice_UIBP = {
    keyName = "Intimacy_Popup_StrategyTwice_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Intimacy_Popup_StrategyTwice_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Intimacy_Popup_StrategyTwice_UIBP.Intimacy_Popup_StrategyTwice_UIBP",
    asy = true,
    uiStat = {
      name = "\228\186\178\229\175\134\229\133\179\231\179\187-\230\155\180\230\141\162\229\133\179\231\179\187\228\186\140\230\172\161\231\161\174\232\174\164\229\188\185\231\170\151"
    }
  },
  Intimacy_Popup_Change_UIBP = {
    keyName = "Intimacy_Popup_Change_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Intimacy_Popup_Change_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Intimacy_Popup_Change_UIBP.Intimacy_Popup_Change_UIBP",
    asy = true,
    uiStat = {
      name = "\228\186\178\229\175\134\229\133\179\231\179\187-\230\155\180\230\141\162\229\133\179\231\179\187\229\144\141\231\167\176\229\188\185\231\170\151"
    }
  },
  Intimacy_Popup_Upgrade_UIBP = {
    keyName = "Intimacy_Popup_Upgrade_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Intimacy_Popup_Upgrade_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Intimacy_Popup_Upgrade_UIBP.Intimacy_Popup_Upgrade_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\228\186\178\229\175\134\229\133\179\231\179\187-\229\141\135\231\186\167\229\188\185\231\170\151"
    }
  },
  ReturnActivity_Socialize_UIBP = {
    keyName = "ReturnActivity_Socialize_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_Socialize_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Socialize_UIBP.ReturnActivity_Socialize_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\155\158\230\181\129-\230\139\141\232\132\184-\231\164\190\228\186\164\233\169\177\229\138\168\229\158\139"
    }
  },
  Escape_Settlement_02_UIBP = {
    keyName = "Escape_Settlement_02_UIBP",
    moduleName = "client.slua.umg.roleInfo.Escape_Settlement_02_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Escape_Settlement_02_UIBP.Escape_Settlement_02_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\233\157\158\229\175\185\231\167\176\231\142\169\230\179\149\229\142\134\229\143\178\230\136\152\231\187\169\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  ReturnActivity_Friends_Recommend = {
    keyName = "ReturnActivity_Friends_Recommend",
    moduleName = "client.slua.umg.return_activity.ReturnActivity_Friends_Recommend_New",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_RecommendFriend_UIBP.ReturnActivity_RecommendFriend_UIBP",
    containerName = UIContainers.Default,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\155\158\230\181\129\229\165\189\229\143\139\230\142\168\232\141\144\229\188\185\231\170\151"
    }
  },
  Intimacy_BondingBook_UIBP = {
    keyName = "Intimacy_BondingBook_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Intimacy.Intimacy_BondingBook_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Intimacy/Intimacy_BondingBook_UIBP.Intimacy_BondingBook_UIBP",
    uiStat = {
      name = "\228\186\178\229\175\134\229\133\179\231\179\187-\231\187\147\231\188\152\228\185\166"
    }
  }
}
return social_ui_configs