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
local rank_ui_configs = {
  Rank_Intimacy_UIBP = {
    keyName = "Rank_Intimacy_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Rank.umg.Rank_Intimacy_UIBP",
    path = "/Game/Mod/Lobby/Split/Rank/UMG/Rank_Intimacy_UIBP.Rank_Intimacy_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true
  },
  Rank_Popularity_main_BP = {
    keyName = "Rank_Popularity_main_BP",
    moduleName = "client.slua.umg.activity.rank_popularity.Rank_Popularity_main_BP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Rank_Popularity_main_BP.Rank_Popularity_main_BP",
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148\229\128\188\230\142\146\232\161\140\230\166\156(\230\150\176)"
    }
  },
  Rank_Arrogance_main_BP = {
    keyName = "Rank_Arrogance_main_BP",
    moduleName = "client.slua.umg.activity.rank_pround.Rank_Arrogance_main_BP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Rank_Arrogance_main_BP.Rank_Arrogance_main_BP",
    isMainUI = false,
    uiStat = {
      name = "\232\177\170\230\176\148\229\128\188\230\142\146\232\161\140\230\166\156"
    }
  },
  Rank_Guard_main_BP = {
    keyName = "Rank_Guard_main_BP",
    moduleName = "client.slua.umg.activity.rank_guard.Rank_Guard_main_BP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Rank_Guard_main_BP.Rank_Guard_main_BP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\136\230\138\164\229\128\188\230\142\146\232\161\140\230\166\156"
    }
  },
  Rank_Creativity_main_BP = {
    keyName = "Rank_Creativity_main_BP",
    moduleName = "client.slua.umg.activity.rank_Creativity.Rank_Creativity_main_BP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/UGC/EventActivityCenter/UGC_Event_RankingList_UIBP.UGC_Event_RankingList_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\229\136\155\230\131\179\229\128\188\230\142\146\232\161\140\230\166\156"
    }
  },
  Rank_IceSnow_Main_BP = {
    keyName = "Rank_IceSnow_Main_BP",
    moduleName = "client.slua.umg.activity.rank.MainActivity.290.Rank_IceSnow_Main_BP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Rank_Popularity_main_BP.Rank_Popularity_main_BP",
    isMainUI = false,
    uiStat = {
      name = "\229\134\176\233\155\170\233\173\133\229\138\155\229\128\188\230\142\146\232\161\140\230\166\156"
    }
  },
  Rank_Collection_Main_BP = {
    keyName = "Rank_Collection_Main_BP",
    moduleName = "client.slua.umg.activity.rank.MainActivity.290.Rank_Collection_Main_BP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Rank_Popularity_main_BP.Rank_Popularity_main_BP",
    isMainUI = false,
    uiStat = {
      name = "\229\133\184\232\151\143\233\173\133\229\138\155\229\128\188\230\142\146\232\161\140\230\166\156"
    }
  },
  ui_rank = {
    keyName = "ui_rank",
    moduleName = "GameLua.Mod.Lobby.Split.Rank.umg.Rank_UIBP_440",
    path = "/Game/Mod/Lobby/Split/Rank/UMG/Rank_UIBP_440.Rank_UIBP_440",
    jumpModuleID = BP_ENUM_MODULE_RANK,
    uiStat = {
      name = "440-\230\150\176\230\142\146\232\161\140\230\166\156"
    },
    useBatchOptimization = true,
    asy = true
  },
  Lobby_RoleInfo_Rank_Data_Tag_UIBP = {
    keyName = "Lobby_RoleInfo_Rank_Data_Tag_UIBP",
    moduleName = "client.slua.umg.lobby.Left.Popup.Lobby_RoleInfo_Rank_Data_Tag_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Left/Popup/Lobby_Left_CustomizeData_Popup_UIBP.Lobby_Left_CustomizeData_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\184\170\228\186\186\229\144\141\231\137\135\229\136\134\228\186\171-\230\142\146\228\189\141\230\149\176\230\141\174\230\160\135\231\173\190"
    }
  },
  BlackFriday_Rank_UIBP = {
    keyName = "BlackFriday_Rank_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Rank.BlackFriday_Rank_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Rank/BlackFriday_Rank_UIBP.BlackFriday_Rank_UIBP",
    jumpModuleID = BP_ENUM_MODULE_BLACK_FRIDAY_RANK,
    uiStat = {
      name = "\233\187\145\228\186\148-\230\142\146\232\161\140\230\166\156-\228\184\187UI"
    }
  },
  HistoryRanking_Share = {
    keyName = "HistoryRanking_Share",
    moduleName = "client.slua.umg.shareChild.share_history_ranking",
    path = "/Game/UMG/UI_BP/Lobby_ShareResultsRanking/LobbyShareRanking_UIBP.LobbyShareRanking_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\136\134\228\186\171-\229\142\134\229\143\178\230\142\146\228\189\141"
    }
  },
  HistoryResults_Share = {
    keyName = "HistoryResults_Share",
    moduleName = "client.slua.umg.shareChild.share_history_results",
    path = "/Game/UMG/UI_BP/Lobby_ShareResultsRanking/LobbyShareResults_UIBP.LobbyShareResults_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\136\134\228\186\171-\229\142\134\229\143\178\230\136\152\231\187\169"
    }
  },
  ui_warzone_rank = {
    keyName = "ui_warzone_rank",
    moduleName = "client.slua.umg.LBS.ui_warzone_rank_new",
    path = "/Game/UMG/UI_BP/LBS/WarZoneRanking_new_UIBP.WarZoneRanking_new_UIBP",
    jumpModuleID = BP_ENUM_MODULE_WARZONE_RANK,
    uiStat = {
      name = "\230\136\152\229\140\186/LBS-\230\142\146\232\161\140\230\166\156"
    }
  },
  WarZoneRanking_new_TwoCombox_Item = {
    keyName = "WarZoneRanking_new_TwoCombox_Item",
    moduleName = "client.slua.umg.LBS.WarZoneRanking_new_TwoCombox_Item",
    path = "/Game/UMG/UI_BP/LBS/WarZoneRanking_new_TwoCombox_Item.WarZoneRanking_new_TwoCombox_Item",
    isSingleton = false,
    uiStat = {
      name = "\230\136\152\229\140\186/LBS-\230\142\146\232\161\140\230\166\156-lbs\229\136\151\232\161\168\231\187\132\228\187\182"
    }
  },
  ui_warzone_guide = {
    keyName = "ui_warzone_guide",
    moduleName = "client.slua.umg.LBS.ui_warzone_guide",
    path = "/Game/UMG/UI_BP/LBS/WarZoneRanking_Popup_08_UIBP.WarZoneRanking_Popup_08_UIBP",
    uiStat = {
      name = "\230\136\152\229\140\186/LBS-\233\166\150\230\172\161\232\191\155\229\133\165\229\188\149\229\175\188\231\149\140\233\157\162"
    }
  },
  WarZoneRanking_Popup_08_UIBP = {
    keyName = "WarZoneRanking_Popup_08_UIBP",
    moduleName = "client.slua.umg.LBS.WarZoneRanking_Popup_08_UIBP",
    path = "/Game/UMG/UI_BP/LBS/WarZoneRanking_Popup_08_UIBP.WarZoneRanking_Popup_08_UIBP",
    uiStat = {
      name = "\230\136\152\229\140\186/LBS-\233\128\154\231\148\168\230\182\136\230\129\175\229\188\185\231\170\151"
    }
  },
  WarZoneRanking_Popup_09_UIBP = {
    keyName = "WarZoneRanking_Popup_09_UIBP",
    moduleName = "client.slua.umg.LBS.WarZoneRanking_Popup_09_UIBP",
    path = "/Game/UMG/UI_BP/LBS/WarZoneRanking_Popup_09_UIBP.WarZoneRanking_Popup_09_UIBP",
    uiStat = {
      name = "\230\136\152\229\140\186/LBS-\232\175\183\230\177\130\228\189\141\231\189\174\230\157\131\233\153\144\229\188\185\231\170\151"
    }
  },
  ui_lbs_gps_reset = {
    keyName = "ui_lbs_gps_reset",
    moduleName = "client.slua.umg.LBS.ui_lbs_gps_reset",
    path = "/Game/UMG/UI_BP/LBS/WarZoneRanking_Popup_01_UIBP.WarZoneRanking_Popup_01_UIBP",
    uiStat = {
      name = "\230\136\152\229\140\186/LBS-\233\135\141\231\189\174\229\156\176\229\159\159"
    }
  },
  Test_ResultsRankingProtectUI = {
    keyName = "Test_ResultsRankingProtectUI",
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.Test_ResultsRankingProtectUI",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/S20/ResultsRanking_Protect_UIBPNew.ResultsRanking_Protect_UIBPNew",
    uiStat = {
      name = "\231\187\143\229\133\184\230\174\181\228\189\141\231\187\147\231\174\151\233\157\162\230\157\191-gm\230\181\139\232\175\149\231\148\168"
    }
  },
  ResultsRanking_Protect_Share_UIBP = {
    keyName = "ResultsRanking_Protect_Share_UIBP",
    moduleName = "client.slua.umg.shareChild.ResultsRanking_Protect_Share_UIBP",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Share/ResultsRanking_Protect_Share_UIBP.ResultsRanking_Protect_Share_UIBP",
    uiStat = {
      name = "1.\231\187\147\231\174\151\229\136\134\228\186\171-\229\133\168\233\152\159\230\136\152\231\187\169"
    }
  },
  ResultsRanking_Protect_Share_UIBP_2 = {
    keyName = "ResultsRanking_Protect_Share_UIBP_2",
    moduleName = "client.slua.umg.shareChild.ResultsRanking_Protect_Share_UIBP_2",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Share/ResultsRanking_Protect_Share_UIBP_2.ResultsRanking_Protect_Share_UIBP_2",
    uiStat = {
      name = "Personal space share card"
    }
  },
  PersonSpace_Share_Select_Pose_Medal_UIBP = {
    keyName = "PersonSpace_Share_Select_Pose_Medal_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Share_Select_Pose_Medal_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Share_Select_Pose_Medal_UIBP.Share_Select_Pose_Medal_UIBP",
    isSingleton = false,
    uiStat = {
      name = "Share pose/background selection panel (PersonSpace)"
    }
  },
  ResultsRanking_Share_UIBP = {
    keyName = "ResultsRanking_Share_UIBP",
    moduleName = "client.slua.umg.shareChild.ResultsRanking_Share_UIBP",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Share/ResultsRanking_Share_UIBP.ResultsRanking_Share_UIBP",
    uiStat = {
      name = "2.\231\187\147\231\174\151\229\136\134\228\186\171-\230\174\181\228\189\141\231\187\147\231\174\1511"
    }
  },
  PeakGame_ResultsRanking_Share_UIBPNew = {
    keyName = "PeakGame_ResultsRanking_Share_UIBPNew",
    moduleName = "client.slua.umg.shareChild.PeakGame_ResultsRanking_Share_UIBPNew",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Share/PeakGame_ResultsRanking_Share_UIBP.PeakGame_ResultsRanking_Share_UIBP",
    uiStat = {
      name = "2.\231\187\147\231\174\151\229\136\134\228\186\171-\229\183\133\229\179\176\232\181\155\230\174\181\228\189\141\231\187\147\231\174\1511"
    }
  },
  ResultsRanking_History_Protect_Share_UIBP = {
    keyName = "ResultsRanking_History_Protect_Share_UIBP",
    moduleName = "client.slua.umg.shareChild.ResultsRanking_History_Protect_Share_UIBP",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Share/ResultsRanking_Protect_Share_UIBP.ResultsRanking_Protect_Share_UIBP",
    uiStat = {
      name = "9.\231\187\147\231\174\151\229\136\134\228\186\171-\229\142\134\229\143\178\230\136\152\231\187\169-\229\133\168\233\152\159\230\149\176\230\141\174"
    }
  },
  RoleInfo_Rank_Popup_UIBP = {
    keyName = "RoleInfo_Rank_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.RoleInfo_Rank_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/RoleInfo_Rank_Popup_UIBP.RoleInfo_Rank_Popup_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\230\174\181\228\189\141\229\188\185\231\170\151"
    }
  },
  RoleInfo_PeakRank_Popup_UIBP = {
    keyName = "RoleInfo_PeakRank_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_PeakGame_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Lobby_RoleInfo_PeakGame_Popup_UIBP.Lobby_RoleInfo_PeakGame_Popup_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\230\174\181\228\189\141\229\188\185\231\170\151"
    }
  },
  Rank_Award_Sub_UIBP = {
    keyName = "Rank_Award_Sub_UIBP",
    moduleName = "client.slua.umg.return_activity.Rank_Award_Sub_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/Return_Award_Sub_UIBP.Return_Award_Sub_UIBP",
    isSingleton = false,
    uiStat = {
      name = "200\229\155\158\230\181\129\230\180\187\229\138\168-\230\174\181\228\189\141\229\165\150\229\138\177\231\149\140\233\157\162"
    }
  },
  Rank_Award_Sub_UIBP_2 = {
    keyName = "Rank_Award_Sub_UIBP_2",
    moduleName = "client.slua.umg.ReturnActivity.Rank_Award_Sub_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/Return_Award_Sub_UIBP_2.Return_Award_Sub_UIBP_2",
    uiStat = {
      name = "\229\155\158\230\181\129\231\137\185\230\157\131\231\149\140\233\157\162-\230\174\181\228\189\141\229\165\150\229\138\177"
    },
    isMainUI = false
  },
  Lobby_RoleInfo_Popularity_RankList_UIBP = {
    keyName = "Lobby_RoleInfo_Popularity_RankList_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_Popularity_RankList_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Popularity_RankList_UIBP.Lobby_RoleInfo_Popularity_RankList_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148PK-\228\186\186\230\176\148\231\155\155\229\133\184-\230\142\146\232\161\140\230\166\156"
    }
  },
  PeakGame_Rank_UIBP = {
    keyName = "PeakGame_Rank_UIBP",
    moduleName = "client.slua.umg.PeakGame.Rank.PeakGame_Rank_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Rank/PeakGame_Rank_UIBP.PeakGame_Rank_UIBP",
    jumpModuleID = BP_ENUM_MODULE_PEAKGAME_RANK,
    asy = true,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\229\183\133\229\179\176\230\174\191\229\160\130"
    }
  },
  PeakGame_Weekly_Ranklist_UIBP = {
    keyName = "PeakGame_Weekly_Ranklist_UIBP",
    moduleName = "client.slua.umg.PeakGame.Rank.PeakGame_Weekly_Ranklist_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Rank/PeakGame_Weekly_Ranklist_UIBP.PeakGame_Weekly_Ranklist_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\229\183\133\229\179\176\230\174\191\229\160\130-\229\145\168\230\166\156"
    },
    useBatchOptimization = true
  },
  Rank_PlanPH_Entrance_UIBP = {
    keyName = "Rank_PlanPH_Entrance_UIBP",
    moduleName = "client.slua.umg.rank.Rank_PlanPH_Entrance_UIBP",
    path = "/Game/UMG/UI_BP/Rank/Rank_PlanPH_Entrance_UIBP.Rank_PlanPH_Entrance_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173-2D\233\151\168\231\137\140"
    }
  },
  Lobby_PeakGame_Rank_Chart_UIBP = {
    keyName = "Lobby_PeakGame_Rank_Chart_UIBP",
    moduleName = "client.slua.umg.PeakGame.Lobby_PeakGame_Rank_Chart_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Lobby_PeakGame_Chart_Double_UIBP.Lobby_PeakGame_Chart_Double_UIBP",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\228\184\187\231\149\140\233\157\162\231\167\175\229\136\134\232\161\168\230\160\188\231\149\140\233\157\162"
    },
    isSingleton = false,
    isMainUI = false
  },
  Lobby_PeakGame_Rank_Chart_Default_UIBP = {
    keyName = "Lobby_PeakGame_Rank_Chart_Default_UIBP",
    moduleName = "client.slua.umg.PeakGame.Lobby_PeakGame_Rank_Chart_Default_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Lobby_PeakGame_Chart_UIBP.Lobby_PeakGame_Chart_UIBP",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\228\184\187\231\149\140\233\157\162\231\167\175\229\136\134\232\161\168\230\160\188-\233\187\152\232\174\164\232\167\132\229\136\153\231\149\140\233\157\162"
    },
    isSingleton = false,
    isMainUI = false
  },
  PeakGame_ResultsRanking_Protect_UIBPNew = {
    keyName = "PeakGame_ResultsRanking_Protect_UIBPNew",
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.Test_PeakGame_ResultsRanking_Protect_UIBPNew",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/PeakGame/PeakGame_ResultsRanking_Protect_UIBPNew.PeakGame_ResultsRanking_Protect_UIBPNew",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\230\174\181\228\189\141\231\187\147\231\174\151\233\157\162\230\157\191"
    }
  },
  PeakGame_ResultsRanking_Protect_Tips02_Item = {
    keyName = "PeakGame_ResultsRanking_Protect_Tips02_Item",
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.PeakGame_ResultsRanking_Protect_Tips02_Item",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/PeakGame/Item/PeakGame_ResultsRanking_Protect_Tips02_Item.PeakGame_ResultsRanking_Protect_Tips02_Item",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\230\174\181\228\189\141\233\161\181\231\187\147\231\174\151\232\175\166\230\131\133item"
    },
    closeOnHide = false,
    isMainUI = false,
    isSingleton = false
  },
  ResultsRanking_Protect_Tips02_Item = {
    keyName = "ResultsRanking_Protect_Tips02_Item",
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.ResultsRanking_Protect_Tips02_Item",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/S20/ResultsRanking_Protect_Tips02_Item.ResultsRanking_Protect_Tips02_Item",
    uiStat = {
      name = "\231\187\143\229\133\184\230\174\181\228\189\141\233\161\181\231\187\147\231\174\151\232\175\166\230\131\133item"
    }
  },
  PeakGame_HOF_Ranklist_UIBP = {
    keyName = "PeakGame_HOF_Ranklist_UIBP",
    moduleName = "client.slua.umg.PeakGame.Rank.PeakGame_HOF_Ranklist_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Rank/PeakGame_HOF_Ranklist_UIBP.PeakGame_HOF_Ranklist_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\229\144\141\228\186\186\229\160\130"
    }
  },
  PeakGame_Ability_Ranklist_UIBP = {
    keyName = "PeakGame_Ability_Ranklist_UIBP",
    moduleName = "client.slua.umg.PeakGame.Rank.PeakGame_Ability_Ranklist_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Rank/PeakGame_Ability_Ranklist_UIBP.PeakGame_Ability_Ranklist_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\232\131\189\229\138\155\230\166\156"
    }
  },
  PeakGame_Rank_LevelUP_UIBP = {
    keyName = "PeakGame_Rank_LevelUP_UIBP",
    moduleName = "client.slua.umg.PeakGame.Rank.PeakGame_Rank_LevelUP_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Rank/PeakGame_Rank_LevelUP_UIBP.PeakGame_Rank_LevelUP_UIBP",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\229\141\135\230\174\181\231\149\140\233\157\162"
    }
  },
  PeakGame_Rank_Popup_UIBP = {
    keyName = "PeakGame_Rank_Popup_UIBP",
    moduleName = "client.slua.umg.PeakGame.Popup.PeakGame_Rank_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Popup/PeakGame_Rank_Popup_UIBP.PeakGame_Rank_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\230\174\181\228\189\141\229\164\150\230\152\190\232\174\190\231\189\174\231\149\140\233\157\162"
    }
  },
  kol_main_page = {
    keyName = "kol_main_page",
    moduleName = "client.slua.umg.Kol_IN.Page.kol_main_page",
    path = "/Game/Arts_UI/FromUMG/KolRank/UIBP/KOL_Min_UIBP.KOL_Min_UIBP",
    jumpModuleID = BP_ENUM_MODULE_KOL_RANK,
    isSingleton = true,
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "kol\230\142\146\232\161\140\230\166\156\228\184\187\231\149\140\233\157\162"
    }
  },
  kol_list_page_new = {
    keyName = "kol_list_page_new",
    moduleName = "client.slua.umg.Kol_IN.Page.kol_list_page_new",
    path = "/Game/Arts_UI/FromUMG/KolRank/UIBP/KOL_Rank_Show_KR_UIBP.KOL_Rank_Show_KR_UIBP",
    isSingleton = true,
    asy = true,
    uiStat = {
      name = "kol\230\142\146\232\161\140\230\166\156 kol list \231\149\140\233\157\162"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  my_kol_page = {
    keyName = "my_kol_page",
    moduleName = "client.slua.umg.Kol_IN.Page.my_kol_page",
    path = "/Game/Arts_UI/FromUMG/KolRank/UIBP/KOL_My_UIBP.KOL_My_UIBP",
    isSingleton = true,
    asy = true,
    uiStat = {
      name = "kol\230\142\146\232\161\140\230\166\156 my kol \231\149\140\233\157\162"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Skip
  },
  top_fans_page = {
    keyName = "top_fans_page",
    moduleName = "client.slua.umg.Kol_IN.Page.top_fans_page",
    path = "/Game/Arts_UI/FromUMG/KolRank/UIBP/KOL_Fans_Rank_UIBP.KOL_Fans_Rank_UIBP",
    isSingleton = true,
    asy = true,
    uiStat = {
      name = "kol\230\142\146\232\161\140\230\166\156 top fans \231\149\140\233\157\162"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  kol_business_card_in = {
    keyName = "kol_business_card_in",
    moduleName = "client.slua.umg.Kol_IN.Popup.kol_business_card_in",
    path = "/Game/Arts_UI/FromUMG/KolRank/UIBP/KOL_My_Popup_UIBP.KOL_My_Popup_UIBP",
    isSingleton = true,
    asy = true,
    uiStat = {
      name = "kol\230\142\146\232\161\140\230\166\156 \232\175\166\230\131\133\229\144\141\231\137\135"
    }
  },
  kol_user_history_season = {
    keyName = "kol_user_history_season",
    moduleName = "client.slua.umg.Kol_IN.Popup.kol_user_history_season",
    path = "/Game/Arts_UI/FromUMG/KolRank/UIBP/KOL_HistoricalRecords_Popup.KOL_HistoricalRecords_Popup",
    isSingleton = true,
    asy = true,
    uiStat = {
      name = "kol\230\142\146\232\161\140\230\166\156 \231\142\169\229\174\182\228\184\170\228\186\186\229\142\134\229\143\178\232\181\155\229\173\163"
    }
  },
  my_kol_share_team = {
    keyName = "my_kol_share_team",
    moduleName = "client.slua.umg.Kol_IN.Page.my_kol_share_team",
    path = "/Game/Arts_UI/FromUMG/KolRank/UIBP/KOL_Share_Popup_UIBP.KOL_Share_Popup_UIBP",
    isSingleton = true,
    asy = true,
    uiStat = {
      name = "kol\230\142\146\232\161\140\230\166\156 \229\155\162\233\152\159\229\136\134\228\186\171"
    }
  },
  my_kol_share_user = {
    keyName = "my_kol_share_user",
    moduleName = "client.slua.umg.Kol_IN.Page.my_kol_share_user",
    path = "/Game/Arts_UI/FromUMG/KolRank/UIBP/KOL_Share_Popup_UIBP.KOL_Share_Popup_UIBP",
    isSingleton = true,
    asy = true,
    uiStat = {
      name = "kol\230\142\146\232\161\140\230\166\156 \228\184\170\228\186\186\229\136\134\228\186\171"
    }
  },
  kol_lobby_tip = {
    keyName = "kol_lobby_tip",
    moduleName = "client.slua.umg.Kol_IN.Popup.kol_lobby_tip",
    path = "/Game/UMG/UI_BP/Common/KolRank/KOL_Tips_UIBP.KOL_Tips_UIBP",
    isMainUI = false,
    uiStat = {
      name = "kol\230\142\146\232\161\140\230\166\156 \229\164\167\229\142\133\229\133\165\229\143\163 \230\143\144\231\164\186"
    }
  },
  kol_score_tip_uibp = {
    keyName = "kol_score_tip_uibp",
    moduleName = "client.slua.umg.Kol_IN.Popup.kol_score_tip_uibp",
    path = "/Game/Arts_UI/FromUMG/KolRank/UIBP/Kol_Score_Tip_UIBP.Kol_Score_Tip_UIBP",
    isSingleton = true,
    asy = true,
    uiStat = {
      name = "kol\230\142\146\232\161\140\230\166\156-\232\142\183\229\143\150\231\167\175\229\136\134\230\143\144\231\164\186"
    }
  },
  RankSmall_Integral_Name_Star_UIBP = {
    keyName = "RankSmall_Integral_Name_Star_UIBP",
    moduleName = "client.slua.umg.rankIntegral.Item.RankSmall_Integral_Name_Star_UIBP",
    path = "/Game/UMG/UI_BP/Common/RankIntegral/RankSmall_Integral_Name_Star_UIBP.RankSmall_Integral_Name_Star_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    asy = true,
    uiStat = {
      name = "\231\187\143\229\133\184\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1901"
    }
  },
  RankSmall_Name_Star_UIBP = {
    keyName = "RankSmall_Name_Star_UIBP",
    moduleName = "client.slua.umg.rankIntegral.Item.RankSmall_Name_Star_UIBP",
    path = "/Game/UMG/UI_BP/Common/RankIntegral/RankSmall_Name_Star_UIBP.RankSmall_Name_Star_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    asy = true,
    uiStat = {
      name = "\231\187\143\229\133\184\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1902"
    }
  },
  RankSmall_Integral_Star_UIBP = {
    keyName = "RankSmall_Integral_Star_UIBP",
    moduleName = "client.slua.umg.rankIntegral.Item.RankSmall_Integral_Star_UIBP",
    path = "/Game/UMG/UI_BP/Common/RankIntegral/RankSmall_Integral_Star_UIBP.RankSmall_Integral_Star_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    asy = true,
    uiStat = {
      name = "\231\187\143\229\133\184\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1903"
    }
  },
  RankSmall_Integral_UIBP = {
    keyName = "RankSmall_Integral_UIBP",
    moduleName = "client.slua.umg.rankIntegral.Item.RankSmall_Integral_UIBP",
    path = "/Game/UMG/UI_BP/Common/RankIntegral/RankSmall_Integral_UIBP.RankSmall_Integral_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    asy = true,
    uiStat = {
      name = "\231\187\143\229\133\184\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1904"
    }
  },
  RankSmall_Star_UIBP = {
    keyName = "RankSmall_Star_UIBP",
    moduleName = "client.slua.umg.rankIntegral.Item.RankSmall_Star_UIBP",
    path = "/Game/UMG/UI_BP/Common/RankIntegral/RankSmall_Star_UIBP.RankSmall_Star_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    asy = true,
    uiStat = {
      name = "\231\187\143\229\133\184\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1905"
    }
  },
  RankSmall_Integral_Name_UIBP = {
    keyName = "RankSmall_Integral_Name_UIBP",
    moduleName = "client.slua.umg.rankIntegral.Item.RankSmall_Integral_Name_UIBP",
    path = "/Game/UMG/UI_BP/Common/RankIntegral/RankSmall_Integral_Name_UIBP.RankSmall_Integral_Name_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    asy = true,
    uiStat = {
      name = "\231\187\143\229\133\184\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1906"
    }
  },
  RankSmall_Star_Name_UIBP = {
    keyName = "RankSmall_Star_Name_UIBP",
    moduleName = "client.slua.umg.rankIntegral.Item.RankSmall_Star_Name_UIBP",
    path = "/Game/UMG/UI_BP/Common/RankIntegral/RankSmall_Star_Name_UIBP.RankSmall_Star_Name_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    asy = true,
    uiStat = {
      name = "\231\187\143\229\133\184\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1907"
    }
  },
  RankSmall_Star_Name_UIBP_2 = {
    keyName = "RankSmall_Star_Name_UIBP_2",
    moduleName = "client.slua.umg.rankIntegral.Item.RankSmall_Star_Name_UIBP_2",
    path = "/Game/UMG/UI_BP/Common/RankIntegral/RankSmall_Star_Name_UIBP_2.RankSmall_Star_Name_UIBP_2",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    asy = true,
    uiStat = {
      name = "\231\187\143\229\133\184\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1908-\231\164\190\228\186\164\232\135\170\229\174\154\228\185\137\229\144\141\231\137\135\228\184\147\231\148\168"
    }
  },
  RankSmall_Star_Name_Tips_UIBP = {
    keyName = "RankSmall_Star_Name_Tips_UIBP",
    moduleName = "client.slua.umg.rankIntegral.Item.RankSmall_Star_Name_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Common/RankIntegral/RankSmall_Star_Name_Tips_UIBP.RankSmall_Star_Name_Tips_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    asy = true,
    uiStat = {
      name = "\231\187\143\229\133\184\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1909-\231\164\190\228\186\164\232\135\170\229\174\154\228\185\137\229\144\141\231\137\135-\229\176\143\230\168\161\229\157\151tips\228\184\147\231\148\168"
    }
  },
  RankSmall_Star2_UIBP = {
    keyName = "RankSmall_Star2_UIBP",
    moduleName = "client.slua.umg.rankIntegral.Item.RankSmall_Star_UIBP",
    path = "/Game/UMG/UI_BP/Common/RankIntegral/RankSmall_Star2_UIBP.RankSmall_Star2_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    asy = true,
    uiStat = {
      name = "\231\187\143\229\133\184\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\19010"
    }
  },
  rank_inspect_msg_box = {
    keyName = "rank_inspect_msg_box",
    moduleName = "client.slua.umg.rank.rank_inspect_msg_box",
    path = "/Game/UMG/UI_BP/Rank/Rank_Show_Popup_UIBP.Rank_Show_Popup_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\230\142\146\232\161\140\230\166\156-\229\183\161\230\159\165\231\161\174\232\174\164\228\191\161\230\129\175"
    }
  },
  PeakGame_Weekly_Award_UIBP = {
    keyName = "PeakGame_Weekly_Award_UIBP",
    moduleName = "client.slua.umg.PeakGame.Rank.AwardPopup.PeakGame_Weekly_Award_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Rank/PeakGame_Award_UIBP.PeakGame_Award_UIBP",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\229\183\133\229\179\176\230\174\191\229\160\130-\229\145\168\230\166\156\231\187\147\231\174\151\229\188\185\231\170\151"
    }
  },
  PeakGame_HOF_Award_UIBP = {
    keyName = "PeakGame_HOF_Award_UIBP",
    moduleName = "client.slua.umg.PeakGame.Rank.AwardPopup.PeakGame_HOF_Award_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Rank/PeakGame_Award_UIBP.PeakGame_Award_UIBP",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\229\183\133\229\179\176\230\174\191\229\160\130-\229\144\141\228\186\186\229\160\130\231\187\147\231\174\151\229\188\185\231\170\151"
    }
  },
  PeakGame_Ability_Award_UIBP = {
    keyName = "PeakGame_Ability_Award_UIBP",
    moduleName = "client.slua.umg.PeakGame.Rank.AwardPopup.PeakGame_Ability_Award_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Rank/PeakGame_Ability_Award_UIBP.PeakGame_Ability_Award_UIBP",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\229\183\133\229\179\176\230\174\191\229\160\130-\232\131\189\229\138\155\230\166\156\231\187\147\231\174\151\229\188\185\231\170\151"
    }
  },
  LobbyResults_Settlement_UIBP = {
    keyName = "LobbyResults_Settlement_UIBP",
    moduleName = "client.slua.umg.Lobby_ShareResultsRanking.LobbyResults_Settlement_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_ShareResultsRanking/LobbyResults_Settlement_UIBP.LobbyResults_Settlement_UIBP",
    uiStat = {
      name = "\233\157\158\229\175\185\231\167\176\231\142\169\230\179\149-\229\142\134\229\143\178\230\136\152\231\187\169\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  RankItemTwoHeader_UIBP = {
    keyName = "RankItemTwoHeader_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Rank.umg.Item.Header.RankItemTwoHeader_UIBP",
    path = "/Game/Mod/Lobby/Split/Rank/UMG/RankItem/Header/RankItemTwoHeader_UIBP.RankItemTwoHeader_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\142\146\232\161\140\230\166\156item-\229\143\140\229\164\180\229\131\143"
    }
  },
  RankItemCommonDetail_UIBP = {
    keyName = "RankItemCommonDetail_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Rank.umg.Item.Header.RankItemCommonDetail_UIBP",
    path = "/Game/Mod/Lobby/Split/Rank/UMG/RankItem/Header/RankItemCommonDetail_UIBP.RankItemCommonDetail_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\142\146\232\161\140\230\166\156item-\231\142\169\229\174\182\233\128\154\231\148\168\228\191\161\230\129\175\231\149\140\233\157\162"
    }
  },
  RankItemOneHeader_UIBP = {
    keyName = "RankItemOneHeader_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Rank.umg.Item.Header.RankItemOneHeader_UIBP",
    path = "/Game/Mod/Lobby/Split/Rank/UMG/RankItem/Header/RankItemOneHeader_UIBP.RankItemOneHeader_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\142\146\232\161\140\230\166\156item-\229\141\149\229\164\180\229\131\143"
    }
  },
  RankItemNoHeader_UIBP = {
    keyName = "RankItemNoHeader_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Rank.umg.Item.Header.RankItemNoHeader_UIBP",
    path = "/Game/Mod/Lobby/Split/Rank/UMG/RankItem/Header/RankItemNoHeader_UIBP.RankItemNoHeader_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\142\146\232\161\140\230\166\156item-\230\151\160\230\149\176\230\141\174"
    }
  },
  RankItemPVEDetail_UIBP = {
    keyName = "RankItemPVEDetail_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Rank.umg.Item.Header.RankItemPVEDetail_UIBP",
    path = "/Game/Mod/Lobby/Split/Rank/UMG/RankItem/Header/RankItemPVEDetail_UIBP.RankItemPVEDetail_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\142\146\232\161\140\230\166\156item-\231\142\169\229\174\182PVE\228\191\161\230\129\175\231\149\140\233\157\162"
    }
  },
  RankItem_AliasTitle_UIBP = {
    keyName = "RankItem_AliasTitle_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Rank.umg.Item.Score.RankItem_AliasTitle_UIBP",
    path = "/Game/Mod/Lobby/Split/Rank/UMG/RankItem/Score/RankItem_AliasTitle_UIBP.RankItem_AliasTitle_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\142\146\232\161\140\230\166\156\229\136\134\230\149\176-\231\167\176\229\143\183-\229\173\144\231\149\140\233\157\162"
    }
  },
  RanItem_LevelInfo_UIBP = {
    keyName = "RanItem_LevelInfo_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Rank.umg.Item.Score.RanItem_LevelInfo_UIBP",
    path = "/Game/Mod/Lobby/Split/Rank/UMG/RankItem/Score/RanItem_LevelInfo_UIBP.RanItem_LevelInfo_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\142\146\232\161\140\230\166\156\229\136\134\230\149\176-\231\173\137\231\186\167\228\191\161\230\129\175-\229\173\144\231\149\140\233\157\162"
    }
  },
  RankItem_SpecialScore_UIBP = {
    keyName = "RankItem_SpecialScore_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Rank.umg.Item.Score.RankItem_SpecialScore_UIBP",
    path = "/Game/Mod/Lobby/Split/Rank/UMG/RankItem/RankItem_SpecialScore_UIBP.RankItem_SpecialScore_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\142\146\232\161\140\230\166\156-\231\137\185\230\174\138\229\136\134\230\149\176"
    }
  },
  RankItem_PlanPHScore_UIBP = {
    keyName = "RankItem_PlanPHScore_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Rank.umg.Item.Score.RankItem_PlanPHScore_UIBP",
    path = "/Game/Mod/Lobby/Split/Rank/UMG/RankItem/RankItem_PlanPHScore_UIBP.RankItem_PlanPHScore_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\142\146\232\161\140\230\166\156-\229\174\182\229\155\173\229\136\134\230\149\176"
    }
  },
  RankItem_BaseScore_UIBP = {
    keyName = "RankItem_BaseScore_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Rank.umg.Item.Score.RankItem_BaseScore_UIBP",
    path = "/Game/Mod/Lobby/Split/Rank/UMG/RankItem/RankItem_BaseScore_UIBP.RankItem_BaseScore_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\142\146\232\161\140\230\166\156-\229\159\186\231\161\128\229\136\134\230\149\176"
    }
  },
  Rank_List_Item_UIBP_440 = {
    keyName = "Rank_List_Item_UIBP_440",
    moduleName = "GameLua.Mod.Lobby.Split.Rank.umg.Rank_List_Item_UIBP_440",
    path = "/Game/Mod/Lobby/Split/Rank/UMG/Rank_List_Item_UIBP_440.Rank_List_Item_UIBP_440",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\142\146\232\161\140\230\166\156-\230\142\146\232\161\140\230\166\156item"
    }
  },
  Rank_Reward_Item_UIBP = {
    keyName = "Rank_Reward_Item_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Rank.umg.Item.Score.Rank_Reward_Item_UIBP",
    path = "/Game/Mod/Lobby/Split/Rank/UMG/RankItem/Rank_Reward_Item_UIBP.Rank_Reward_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\142\146\232\161\140\230\166\156-\229\165\150\229\138\177item"
    }
  },
  Lobby_RoleInfo_IntimacyItem_UIBP = {
    keyName = "Lobby_RoleInfo_IntimacyItem_UIBP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/Common/Items/Lobby_RoleInfo_IntimacyItem_UIBP.Lobby_RoleInfo_IntimacyItem_UIBP",
    uiStat = {
      name = "\230\142\146\232\161\140\230\166\156-\228\186\178\229\175\134\229\186\166item"
    },
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool
  }
}
return rank_ui_configs