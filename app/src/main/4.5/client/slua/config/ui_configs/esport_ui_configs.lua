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
local esport_ui_configs = {
  esport_center = {
    keyName = "esport_center",
    moduleName = "client.slua.umg.esport.esport_center",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/ESport_Center_UIBP.ESport_Center_UIBP",
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.TopZOrder
  },
  crew_safety_detection_tournament = {
    keyName = "crew_safety_detection_tournament",
    moduleName = "client.slua.umg.crew.crew_safety_detection_tournament",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/ESport_detection_UIBP.ESport_detection_UIBP",
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\229\174\137\229\133\168\230\163\128\230\181\139"
    }
  },
  crew_safety_detection_pug = {
    keyName = "crew_safety_detection_pug",
    moduleName = "client.slua.umg.crew.crew_safety_detection_pug",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/ESport_detection_UIBP.ESport_detection_UIBP",
    uiStat = {
      name = "\231\171\158\230\138\128\232\181\155-\229\174\137\229\133\168\230\163\128\230\181\139"
    }
  },
  crew_safety_detection_allstar = {
    keyName = "crew_safety_detection_allstar",
    moduleName = "client.slua.umg.crew.crew_safety_detection_allstar",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/ESport_detection_UIBP.ESport_detection_UIBP",
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\229\174\137\229\133\168\230\163\128\230\181\139"
    }
  },
  live_video_slap = {
    keyName = "live_video_slap",
    moduleName = "client.slua.umg.live_video.LiveVideo_UIBP",
    path = "/Game/UMG/UI_BP/ESport/LiveVideo_UIBP.LiveVideo_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\232\181\155\228\186\139\231\155\180\230\146\173\230\139\141\232\132\184"
    }
  },
  egame_center = {
    keyName = "egame_center",
    moduleName = "client.slua.umg.esport.egame_center",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/EGame/ESport_Lobby_UIBP.ESport_Lobby_UIBP",
    jumpModuleID = BP_ENUM_MODULE_EGAME_CENTER,
    asy = true,
    uiStat = {
      name = "\232\181\155\228\186\139-\228\184\187\231\149\140\233\157\162"
    }
  },
  Championship_Popup_Select = {
    keyName = "Championship_Popup_Select",
    moduleName = "client.slua.umg.championship_india.championship_popup_select",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/EGame/ESport_Lobby_Popup_UIBP.ESport_Lobby_Popup_UIBP",
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\232\181\155\228\186\139\229\133\165\229\143\163\231\177\187\229\158\139\233\128\137\230\139\169"
    }
  },
  allstar_champion = {
    keyName = "allstar_champion",
    moduleName = "client.slua.umg.esport.allstar.lobby.allstar_champion",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/EGame/ESport_Champion_UIBP.ESport_Champion_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\229\134\160\229\134\155"
    }
  },
  allstar_champion_detail = {
    keyName = "allstar_champion_detail",
    moduleName = "client.slua.umg.esport.allstar.lobby.allstar_champion_detail",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/EGame/ESport_Champion_show_UIBP.ESport_Champion_show_UIBP",
    asy = true,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\229\134\160\229\134\155\232\175\166\230\131\133"
    }
  },
  allstar_season_anim = {
    keyName = "allstar_season_anim",
    moduleName = "client.slua.umg.esport.allstar.allstar_season_anim",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/EGame/ESport_Open_UIBP.ESport_Open_UIBP",
    asy = true,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\229\138\168\231\148\187"
    }
  },
  allstar_main = {
    keyName = "allstar_main",
    moduleName = "client.slua.umg.esport.allstar.lobby.allstar_main",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/AllStar_Main_UIBP.AllStar_Main_UIBP",
    asy = true,
    jumpModuleID = BP_ENUM_MODULE_ALLSTAR_MAIN,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\228\184\187\231\149\140\233\157\162"
    }
  },
  allstar_rank_main = {
    keyName = "allstar_rank_main",
    moduleName = "client.slua.umg.esport.allstar.rank.allstar_rank_main",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/AllStar_Main_UIBP_2.AllStar_Main_UIBP_2",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\230\142\146\232\161\140\230\166\156\228\184\187\233\161\181"
    }
  },
  allstar_lobby = {
    keyName = "allstar_lobby",
    moduleName = "client.slua.umg.esport.allstar.lobby.allstar_lobby",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/AllStar_Apply_UIBP.AllStar_Apply_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\229\164\167\229\142\133"
    }
  },
  allstar_rank = {
    keyName = "allstar_rank",
    moduleName = "client.slua.umg.esport.allstar.rank.allstar_rank",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/AllStar_Rank_UIBP.AllStar_Rank_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\229\133\168\230\176\145\232\181\155\230\142\146\232\161\140\230\166\156"
    }
  },
  allstar_ban = {
    keyName = "allstar_ban",
    moduleName = "client.slua.umg.esport.allstar.allstar_ban",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/AllStar_Rank_Ban_UIBP.AllStar_Rank_Ban_UIBP",
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\229\176\129\231\166\129\229\144\141\229\141\149"
    }
  },
  allstar_gp = {
    keyName = "allstar_gp",
    moduleName = "client.slua.umg.esport.allstar.exchange.allstar_gp",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/AllStar_GP_UIBP.AllStar_GP_UIBP",
    asy = true,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\231\180\175\232\174\161\229\165\150\229\138\177"
    }
  },
  allstar_schedule = {
    keyName = "allstar_schedule",
    moduleName = "client.slua.umg.esport.allstar.allstar_game_schedule",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/AllStar_Course_UIBP.AllStar_Course_UIBP",
    asy = true,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\232\181\155\231\168\139\229\155\190"
    }
  },
  allstar_face = {
    keyName = "allstar_face",
    moduleName = "client.slua.umg.esport.allstar.allstar_face",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/ESport_TournamentDescription_UIBP.ESport_TournamentDescription_UIBP",
    asy = true,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\230\139\141\232\132\184"
    }
  },
  allstar_exchangegift = {
    keyName = "allstar_exchangegift",
    moduleName = "client.slua.umg.esport.allstar.exchange.allstar_exchangegift",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/AllStar_Exchange_Gift_UIBP.AllStar_Exchange_Gift_UIBP",
    asy = true,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\229\174\157\231\174\177\231\137\169\229\147\129"
    }
  },
  allstar_exchangeshop = {
    keyName = "allstar_exchangeshop",
    moduleName = "client.slua.umg.esport.allstar.exchange.allstar_exchangeshop",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/AllStar_Exchange_UIBP.AllStar_Exchange_UIBP",
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\229\133\145\230\141\162\229\149\134\229\159\142"
    }
  },
  allstar_stage_item = {
    keyName = "allstar_stage_item",
    moduleName = "client.slua.umg.esport.allstar.lobby.allstar_stage_item",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/Item/AllStar_Apply_Item_01_UIBP.AllStar_Apply_Item_01_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\233\152\182\230\174\181Item"
    }
  },
  allstar_stage_content = {
    keyName = "allstar_stage_content",
    moduleName = "client.slua.umg.esport.allstar.lobby.allstar_stage_content",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/Item/AllStar_Apply_Item_02_UIBP.AllStar_Apply_Item_02_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\233\152\182\230\174\181\232\175\166\230\131\133"
    }
  },
  allstar_game_detail = {
    keyName = "allstar_game_detail",
    moduleName = "client.slua.umg.esport.allstar.lobby.allstar_game_detail",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/Popup/AllStar_Popup_Confirm_UIBP.AllStar_Popup_Confirm_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\230\175\148\232\181\155\232\175\166\230\131\133"
    }
  },
  allstar_select_area = {
    keyName = "allstar_select_area",
    moduleName = "client.slua.umg.esport.allstar.lobby.allstar_select_area",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/Popup/AllStar_Popup_Select_UIBP.AllStar_Popup_Select_UIBP",
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\233\128\137\230\139\169\232\181\155\229\140\186"
    }
  },
  allstar_segment_award = {
    keyName = "allstar_segment_award",
    moduleName = "client.slua.umg.esport.allstar.rank.allstar_segment_award",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/AllStar_Rank_Reward_UIBP.AllStar_Rank_Reward_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\232\181\155\229\140\186\230\166\156\229\165\150\229\138\177"
    }
  },
  allstar_segment_rank = {
    keyName = "allstar_segment_rank",
    moduleName = "client.slua.umg.esport.allstar.rank.allstar_segment_rank",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/AllStar_Season_Rank_UIBP.AllStar_Season_Rank_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\232\181\155\229\140\186\230\142\146\232\161\140\230\166\156"
    }
  },
  ui_room_waiting_allstar = {
    keyName = "ui_room_waiting_allstar",
    moduleName = "client.slua.umg.room.room_waiting_allstar",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/Enter_the_game/NewRoomWaiting.NewRoomWaiting",
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\231\173\137\229\190\133\231\149\140\233\157\162-\229\133\168\230\176\145\232\181\155"
    }
  },
  allstar_match_team = {
    keyName = "allstar_match_team",
    moduleName = "client.slua.umg.esport.allstar.match.allstar_match_team",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/Enter_the_game/ESport_enter_team_UIBP.ESport_enter_team_UIBP",
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\230\175\148\232\181\155-\233\152\159\228\188\141\231\174\161\231\144\134"
    }
  },
  allstar_share = {
    keyName = "allstar_share",
    moduleName = "client.slua.umg.esport.allstar.allstar_upgrade_share",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/Enter_the_game/ESport_enter_Successful_share_UIBP.ESport_enter_Successful_share_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\230\153\139\231\186\167\229\136\134\228\186\171"
    }
  },
  allstar_result_popup = {
    keyName = "allstar_result_popup",
    moduleName = "client.slua.umg.esport.allstar.allstar_result_popup",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/Enter_the_game/ESport_enter_Successful_promotion_UIBP.ESport_enter_Successful_promotion_UIBP",
    asy = true,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\232\181\155\228\186\139\231\187\147\230\158\156\229\188\185\231\170\151"
    }
  },
  esport_share = {
    keyName = "esport_share",
    moduleName = "client.slua.umg.esport.esport_team.esport_team_share",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/Enter_the_game/ESport_enter_Successful_team_share_UIBP.ESport_enter_Successful_team_share_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\233\152\159\228\188\141\229\136\134\228\186\171"
    }
  },
  allstar_ob_room_waiting = {
    keyName = "allstar_ob_room_waiting",
    moduleName = "client.slua.umg.esport.allstar.allstar_ob_room_waiting",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/Enter_the_game/OB_RoomWating.OB_RoomWating",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\232\167\130\229\175\159\232\128\133\231\173\137\229\190\133\230\136\191\233\151\180"
    }
  },
  Championship_Begin_Popup = {
    keyName = "Championship_Begin_Popup",
    moduleName = "client.slua.umg.championship_india.championship_begin_popup",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/Enter_the_game/ESport_enter_lobby_tips_UIBP.ESport_enter_lobby_tips_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\230\138\165\229\144\141\230\143\144\233\134\146"
    }
  },
  allstar_begin_popup = {
    keyName = "allstar_begin_popup",
    moduleName = "client.slua.umg.esport.allstar.allstar_begin_popup",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/ESport/AllStar/Enter_the_game/ESport_enter_lobby_tips_UIBP.ESport_enter_lobby_tips_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\230\138\165\229\144\141\230\143\144\233\134\146"
    },
    isMainUI = false
  },
  Championship_Invite_Tip = {
    keyName = "Championship_Invite_Tip",
    moduleName = "client.slua.umg.championship_india.championship_invite_tip",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\233\130\128\232\175\183\229\188\185\231\170\151"
    }
  },
  championship_teamup = {
    keyName = "championship_teamup",
    moduleName = "client.slua.umg.Championship_India.championship_teamup",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_India_Prepare_1_UIBP.Championship_India_Prepare_1_UIBP",
    uiStat = {
      name = "\232\181\158\229\138\169\232\181\155-\231\187\132\233\152\159"
    }
  },
  Championship_Sponsor_Mgr_UIBP = {
    keyName = "Championship_Sponsor_Mgr_UIBP",
    moduleName = "client.slua.umg.championship_india.championship_sponsor_mgr_ui_bp",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_Sponsor_Mgr_UIBP.Championship_Sponsor_Mgr_UIBP",
    uiStat = {
      name = "\231\171\158\230\138\128\232\181\155-\233\161\181\231\173\190\231\174\161\231\144\134"
    }
  },
  Championship_Sponsor_OneMain_UIBP = {
    keyName = "Championship_Sponsor_OneMain_UIBP",
    moduleName = "client.slua.umg.championship_india.championship_sponsor_one_main_ui_bp",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_Sponsor_OneMain_UIBP.Championship_Sponsor_OneMain_UIBP",
    uiStat = {
      name = "\231\171\158\230\138\128\232\181\155-\228\184\187\233\161\181"
    }
  },
  Championship_Sponsor_One_Desc_UIBP = {
    keyName = "Championship_Sponsor_One_Desc_UIBP",
    moduleName = "client.slua.umg.championship_india.championship_sponsor_one_desc_ui_bp",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_Sponsor_One_Desc_UIBP.Championship_Sponsor_One_Desc_UIBP",
    uiStat = {
      name = "\231\171\158\230\138\128\232\181\155-\232\175\166\230\131\133\228\187\139\231\187\141"
    }
  },
  Championship_Sponsor_One_Desc_Tips_UIBP = {
    keyName = "Championship_Sponsor_One_Desc_Tips_UIBP",
    moduleName = "client.slua.umg.championship_india.championship_sponsor_one_desc_tips_ui_bp",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Sponsor_One_desc_tips_UIBP.Sponsor_One_desc_tips_UIBP",
    uiStat = {
      name = "\231\171\158\230\138\128\232\181\155-\232\175\166\230\131\133\228\187\139\231\187\141Tips"
    }
  },
  Championship_Sponsor_TotalRank_UIBP = {
    keyName = "Championship_Sponsor_TotalRank_UIBP",
    moduleName = "client.slua.umg.championship_india.championship_sponsor_totalrank",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_Sponsor_TotalRank_UIBP.Championship_Sponsor_TotalRank_UIBP",
    uiStat = {
      name = "\231\171\158\230\138\128\232\181\155-\230\128\187\230\166\156"
    }
  },
  Championship_Rule_UIBP = {
    keyName = "Championship_Rule_UIBP",
    moduleName = "client.slua.umg.championship_india.Championship_India_Rule",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_India_jiesuan_1_BP.Championship_India_jiesuan_1_BP",
    uiStat = {
      name = "\233\148\166\230\160\135\232\181\155-\231\167\175\229\136\134\232\167\132\229\136\153"
    }
  },
  Championship_Rule2_UIBP = {
    keyName = "Championship_Rule2_UIBP",
    moduleName = "client.slua.umg.championship_india.Championship_India_Rule2",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_India_jiesuan_2_BP.Championship_India_jiesuan_2_BP",
    uiStat = {
      name = "\233\148\166\230\160\135\232\181\155-\231\167\175\229\136\134\232\167\132\229\136\153"
    }
  },
  Championship_Popup_SignUp = {
    keyName = "Championship_Popup_SignUp",
    moduleName = "client.slua.umg.championship_india.championship_popup_signup",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Champior_Entrance_Zijian_UIPB.Champior_Entrance_Zijian_UIPB",
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\230\138\165\229\144\141\229\188\185\231\170\151"
    }
  },
  Championship_Apply_List = {
    keyName = "Championship_Apply_List",
    moduleName = "client.slua.umg.championship_india.championship_apply_list",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Champior_Entrance_Zijian_UIPB_01.Champior_Entrance_Zijian_UIPB_01",
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\231\187\132\233\152\159\231\148\179\232\175\183"
    }
  },
  Championship_Find_List = {
    keyName = "Championship_Find_List",
    moduleName = "client.slua.umg.championship_india.championship_find_list",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Champior_Entrance_Zijian_UIPB_01.Champior_Entrance_Zijian_UIPB_01",
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\229\143\145\231\142\176\229\165\189\229\143\139\233\152\159\228\188\141"
    }
  },
  Championship_Recruit_List = {
    keyName = "Championship_Recruit_List",
    moduleName = "client.slua.umg.championship_india.championship_recruit_list",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Champior_Entrance_Zijian_UIPB_01.Champior_Entrance_Zijian_UIPB_01",
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\230\139\155\229\139\159\233\152\159\229\143\139"
    }
  },
  Championship_Entrance_SignUp = {
    keyName = "Championship_Entrance_SignUp",
    moduleName = "client.slua.umg.championship_india.championship_entrance_signup",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Champior_Entrance_Signup_UIPB.Champior_Entrance_Signup_UIPB",
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\230\138\165\229\144\141\229\133\165\229\143\163"
    }
  },
  Championship_Select_Area = {
    keyName = "Championship_Select_Area",
    moduleName = "client.slua.umg.championship_india.championship_select_area",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Sponsor_Popup_Select_UIBP.Sponsor_Popup_Select_UIBP",
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\230\138\165\229\144\141\232\181\155\229\140\186\233\128\137\230\139\169"
    }
  },
  Championship_Result_Popup = {
    keyName = "Championship_Result_Popup",
    moduleName = "client.slua.umg.championship_india.championship_result_popup",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Champion_Enter_Successful_promotion_UIBP.Champion_Enter_Successful_promotion_UIBP",
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\232\181\155\228\186\139\230\153\139\231\186\167\229\188\185\231\170\151"
    }
  },
  Championship_India_FloatTips_UIBP = {
    keyName = "Championship_India_FloatTips_UIBP",
    moduleName = "client.slua.umg.tournament.Championship_India_FloatTips_UIBP",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_India_FloatTips_UIBP_NEW.Championship_India_FloatTips_UIBP_NEW",
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\229\137\141\229\190\128\230\160\135\231\173\190"
    }
  },
  Championship_India_Popup01_UIBP = {
    keyName = "Championship_India_Popup01_UIBP",
    moduleName = "client.slua.umg.tournament.Championship_India_Popup01_UIBP",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_India_Popup01_UIBP_NEW.Championship_India_Popup01_UIBP_NEW",
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\230\175\148\232\181\155\229\137\141\232\191\155\229\133\165\230\136\152\230\150\151\229\188\185\231\170\151"
    }
  },
  Championship_India_Popup_UIBP = {
    keyName = "Championship_India_Popup_UIBP",
    moduleName = "client.slua.umg.tournament.Championship_India_Popup_UIBP",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_India_Popup_UIBP_2.Championship_India_Popup_UIBP_2",
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\230\138\165\229\144\141"
    }
  },
  Championship_India_QuickTips_UIBP = {
    keyName = "Championship_India_QuickTips_UIBP",
    moduleName = "client.slua.umg.tournament.Championship_India_QuickTips_UIBP",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_India_QuickTips_UIBP_NEW.Championship_India_QuickTips_UIBP_NEW",
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\230\143\144\231\164\186\230\160\135\231\173\190"
    }
  },
  egame_entry = {
    keyName = "egame_entry",
    moduleName = "client.slua.umg.tournament.egame_entry",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_Entrance_Bounty_UIBP.Championship_Entrance_Bounty_UIBP",
    uiStat = {
      name = "\232\181\155\228\186\139-\229\133\165\229\143\163"
    }
  },
  qualifying_match = {
    keyName = "qualifying_match",
    moduleName = "client.slua.umg.tournament.qualifying_match",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_Bounty_UIBP.Championship_Bounty_UIBP",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155-\228\184\187\231\149\140\233\157\162"
    }
  },
  qualifying_rank = {
    keyName = "qualifying_rank",
    moduleName = "client.slua.umg.tournament.qualifying_rank",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_Bounty_Rank_UIBP.Championship_Bounty_Rank_UIBP",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155-\230\142\146\229\144\141"
    }
  },
  qualifying_regist = {
    keyName = "qualifying_regist",
    moduleName = "client.slua.umg.tournament.qualifying_regist",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_Bounty_Register_UIBP.Championship_Bounty_Register_UIBP",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155-\230\179\168\229\134\140"
    }
  },
  qualifying_winner = {
    keyName = "qualifying_winner",
    moduleName = "client.slua.umg.tournament.qualifying_winner",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_Bounty_Winning_name_UIBP.Championship_Bounty_Winning_name_UIBP",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155-\229\144\141\229\141\149"
    }
  },
  tournament_buy_india_ticket = {
    keyName = "tournament_buy_india_ticket",
    moduleName = "client.slua.umg.tournament.tournament_buy_india_ticket",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_India_Buy_IndiaTicket_BP.Championship_India_Buy_IndiaTicket_BP",
    uiStat = {
      name = "\233\148\166\230\160\135\232\181\155-\232\180\173\228\185\176\229\143\130\232\181\155\229\136\184"
    }
  },
  tournament_history_record = {
    keyName = "tournament_history_record",
    moduleName = "client.slua.umg.tournament.tournament_history_record",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_India_NewHistory_UIBP.Championship_India_NewHistory_UIBP",
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\229\142\134\229\143\178\232\174\176\229\189\149"
    }
  },
  tournament_introduce = {
    keyName = "tournament_introduce",
    moduleName = "client.slua.umg.tournament.tournament_introduce",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_India_NewIntroduce_UIBP.Championship_India_NewIntroduce_UIBP",
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\232\181\155\228\186\139\228\187\139\231\187\141"
    }
  },
  tournament_main = {
    keyName = "tournament_main",
    moduleName = "client.slua.umg.tournament.tournament_main",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_India_New_UIBP.Championship_India_New_UIBP",
    jumpModuleID = BP_ENUM_MODULE_TOURNAMENT_MAIN,
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\228\184\187\231\149\140\233\157\162"
    }
  },
  tournament_teamup = {
    keyName = "tournament_teamup",
    moduleName = "client.slua.umg.tournament.tournament_teamup",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/Championship_India/Championship_India_Prepare_UIBP.Championship_India_Prepare_UIBP",
    jumpModuleID = BP_ENUM_MODULE_TOURNAMENT_TEAM_UP,
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\231\187\132\233\152\159"
    }
  },
  allstar_invite_list = {
    keyName = "allstar_invite_list",
    moduleName = "client.slua.umg.esport.allstar.match.allstar_invite_list",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/TournamentTeam/Lobby_Team_RecruitmentPopup_UIBP.Lobby_Team_RecruitmentPopup_UIBP",
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\233\130\128\232\175\183\229\136\151\232\161\168\231\149\140\233\157\162"
    }
  },
  esport_team_create = {
    keyName = "esport_team_create",
    moduleName = "client.slua.umg.esport.esport_team.esport_team_create",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/TournamentTeam/Lobby_Team_Create_UIBP.Lobby_Team_Create_UIBP",
    jumpModuleID = BP_ENUM_MODULE_ALLIANCE_MAIN_PANEL,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\229\136\155\229\187\186\233\152\159\228\188\141"
    }
  },
  esport_apply_list = {
    keyName = "esport_apply_list",
    moduleName = "client.slua.umg.esport.esport_team.esport_apply_list",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/TournamentTeam/Lobby_Team_ApplyPopup_UIBP.Lobby_Team_ApplyPopup_UIBP",
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\231\148\179\232\175\183\229\136\151\232\161\168\231\149\140\233\157\162"
    }
  },
  esport_recruit_list = {
    keyName = "esport_recruit_list",
    moduleName = "client.slua.umg.esport.esport_team.esport_recruit_list",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/TournamentTeam/Lobby_Team_RecruitmentPopup_UIBP.Lobby_Team_RecruitmentPopup_UIBP",
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\230\139\155\229\139\159\231\149\140\233\157\162"
    }
  },
  esport_team_bookmark = {
    keyName = "esport_team_bookmark",
    moduleName = "client.slua.umg.esport.esport_team.esport_team_bookmark",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/TournamentTeam/Lobby_Team_BookMark_UIBP.Lobby_Team_BookMark_UIBP",
    jumpModuleID = BP_ENUM_MODULE_ALLIANCE_MAIN_PANEL,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\233\152\159\228\188\141\233\161\181\231\173\190"
    }
  },
  esport_team_homepage = {
    keyName = "esport_team_homepage",
    moduleName = "client.slua.umg.esport.esport_team.esport_team_homepage",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/TournamentTeam/Lobby_Team_HomePage_UIBP.Lobby_Team_HomePage_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\233\152\159\228\188\141\228\184\187\233\161\181"
    }
  },
  esport_team_history = {
    keyName = "esport_team_history",
    moduleName = "client.slua.umg.esport.esport_team.esport_team_history",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/TournamentTeam/Lobby_Team_History_UIBP.Lobby_Team_History_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\233\152\159\228\188\141\229\142\134\229\143\178"
    }
  },
  esport_team_other = {
    keyName = "esport_team_other",
    moduleName = "client.slua.umg.esport.esport_team.esport_team_other",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/TournamentTeam/LobbyTeam_Other_UIBP.LobbyTeam_Other_UIBP",
    asy = true,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\228\187\150\228\186\186\233\152\159\228\188\141"
    }
  },
  esport_select_team_flag = {
    keyName = "esport_select_team_flag",
    moduleName = "client.slua.umg.esport.esport_team.esport_select_team_flag",
    path = "/Game/MultiRegion/Content/IN/UMG/UI_BP/TournamentTeam/Alliance_Guidon_BP.Alliance_Guidon_BP",
    asy = true,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\233\128\137\230\139\169\230\136\152\233\152\159\230\151\151\229\184\156"
    }
  }
}
return esport_ui_configs