local macro = require("client.slua.logic.lobby_chat.chat_macro")
local chat_ui_config = {
  channel = {
    [macro.Channel.channelSocialIslandChat] = {
      tabId = 1,
      channelModuleName = "client.slua.umg.lobby_chat.ui_chat_channel_social_island_chat",
      channelBpPath = macro.path.social_Island_Chat_UIBP,
      memberListBpPath = macro.path.ChatMemberList,
      memberListModuleName = "client.slua.umg.lobby_chat.ui_chat_member_list_social_island_chat",
      memberListAttachRoot = "islandMemberList",
      channelId = macro.Channel.channelSocialIslandChat,
      uiStat_name = "\232\129\138\229\164\169\233\162\145\233\129\147-\231\164\190\228\186\164\229\178\155\229\178\155\229\177\191",
      margin = FMargin(320, 60, 0, 10),
      tabSelectIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_SocialIsland_Xuanzhong_png.Common_Tab_SocialIsland_Xuanzhong_png",
      tabDefualtIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_SocialIsland_png.Common_Tab_SocialIsland_png",
      checkShowFunc = function()
        local logic_mode_mgr = require("client.slua.logic.match.logic_mode_mgr")
        return logic_mode_mgr.IsSocialIslandMode()
      end
    },
    [macro.Channel.channelGlobalManor] = {
      tabId = 2,
      channelModuleName = "client.slua.umg.lobby_chat.manor.ui_chat_channel_global_manor",
      channelBpPath = macro.path.Global_Manor_Chat_UIBP,
      channelId = macro.Channel.channelGlobalManor,
      uiStat_name = "\232\129\138\229\164\169\233\162\145\233\129\147-\229\174\182\229\155\173\228\184\150\231\149\140",
      margin = FMargin(72, 0, 0, 10),
      tabSelectIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Home_World_Xuanzhong_png.Common_Tab_Home_World_Xuanzhong_png",
      tabDefualtIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Home_World_png.Common_Tab_Home_World_png",
      checkShowFunc = function()
        local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
        if not logic_home_switch:CheckHomeSwitchOpen() then
          return false
        end
        local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
        local logic_mode_mgr = require("client.slua.logic.match.logic_mode_mgr")
        if logic_home_entry:IsPlanPHMode() or logic_mode_mgr.IsSocialIslandMode() then
          return true
        end
        return false
      end
    },
    [macro.Channel.channelCurrentManor] = {
      tabId = 3,
      channelModuleName = "client.slua.umg.lobby_chat.manor.ui_chat_channel_current_manor",
      channelBpPath = macro.path.Current_Manor_Chat_UIBP,
      memberListBpPath = macro.path.ChatMemberList,
      memberListModuleName = "client.slua.umg.lobby_chat.manor.ui_chat_member_list_current_manor",
      memberListAttachRoot = "islandMemberList",
      channelId = macro.Channel.channelCurrentManor,
      uiStat_name = "\232\129\138\229\164\169\233\162\145\233\129\147-\229\189\147\229\137\141\229\174\182\229\155\173",
      margin = FMargin(320, 0, 0, 10),
      tabSelectIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Home_Room_Xuanzhong_png.Common_Tab_Home_Room_Xuanzhong_png",
      tabDefualtIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Home_Room__png.Common_Tab_Home_Room__png",
      checkShowFunc = function()
        local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
        if logic_home_entry:IsPlanPHVisitOrEditPlanMode() then
          return true
        end
        return false
      end
    },
    [macro.Channel.channelWorld] = {
      tabId = 4,
      channelModuleName = "client.slua.umg.lobby_chat.ui_chat_channel_world",
      channelBpPath = macro.path.WorldChat_root_UIBP,
      channelId = macro.Channel.channelWorld,
      uiStat_name = "\232\129\138\229\164\169\233\162\145\233\129\147-\228\184\150\231\149\140",
      margin = FMargin(260, 0, 0, 10),
      tabSelectIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_World_Xuanzhong_png.Common_Tab_World_Xuanzhong_png",
      tabDefualtIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_World_png.Common_Tab_World_png",
      checkShowFunc = function()
        if GameStatus.IsInLobbyOrMainCity() then
          return true
        elseif GameStatus.IsInFightingStatus() then
          local logic_mode_mgr = require("client.slua.logic.match.logic_mode_mgr")
          local bSocialislandMode = logic_mode_mgr.IsSocialIslandMode()
          local bSocialislandChatSwitch = LobbySystem.CheckOpen(BP_ENUM_SOCIAL_ISLAND_CHAT_WORLD_SWITCH)
          if bSocialislandMode and not bSocialislandChatSwitch then
            log(bWriteLog and "chat_ui_config.checkShowFunc world show false social island")
            return false
          end
          local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
          local bPlanPHMode = PlanPH_GamePlay_Tools.IsPHomeMode()
          if bPlanPHMode then
            log(bWriteLog and "chat_ui_config.checkShowFunc world show false home")
            return false
          end
          return true
        else
          local gameStatus = GameStatus.GetGameStatus()
          local lastGameStatus = GameStatus.GetLastGameStatus()
          local logic_mode_mgr = require("client.slua.logic.match.logic_mode_mgr")
          local bSocialislandMode = logic_mode_mgr.IsSocialIslandMode()
          local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
          local bPlanPHMode = PlanPH_GamePlay_Tools.IsPHomeMode()
          local fmt = string.format("chat_ui_config.checkShowFunc world show false others. GameStatus:%s, lastGameStatus:%s, bSocialislandMode:%s, bPlanPHMode:%s", gameStatus, lastGameStatus, bSocialislandMode, bPlanPHMode)
          LogExceptionAndReport(fmt, 6)
          return false
        end
      end
    },
    [macro.Channel.WaitingRoom] = {
      tabId = 5,
      channelModuleName = "client.slua.umg.lobby_chat.ui_chat_channel_waiting_room",
      channelBpPath = macro.path.ChatWaitingRoom_UIBP,
      channelId = macro.Channel.WaitingRoom,
      uiStat_name = "\232\129\138\229\164\169\233\162\145\233\129\147-\232\135\170\229\174\154\228\185\137\230\136\191\233\151\180\232\129\138\229\164\169",
      margin = FMargin(72, 240, 0, 10),
      tabSelectIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Home_XuangZhong_png.Common_Tab_Home_XuangZhong_png",
      tabDefualtIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Home_png.Common_Tab_Home_png",
      checkShowFunc = function()
        local logic_mode_mgr = require("client.slua.logic.match.logic_mode_mgr")
        if logic_mode_mgr.IsSocialIslandMode() then
          printf("chat_ui_config.checkShowFunc WaitingRoom show false. IsSocialIslandMode")
          return false
        end
        local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
        local bPlanPHMode = PlanPH_GamePlay_Tools.IsPHomeMode()
        if bPlanPHMode then
          printf("chat_ui_config.checkShowFunc WaitingRoom show false. IsPHomeMode")
          return false
        end
        if UIManager.IsUIShow(UIManager.UI_Config.ui_room_waiting) or UIManager.IsUIShow(UIManager.UI_Config.UGCRoomWaitingPanel) or UIManager.IsUIShow(UIManager.UI_Config.Xmission_Room_UIBP) then
          log(bWriteLog and "macro.Channel.WaitingRoom show true")
          return true
        end
        log(bWriteLog and "macro.Channel.WaitingRoom show false")
        return false
      end
    },
    [macro.Channel.channelTeamRecruit] = {
      tabId = 6,
      channelModuleName = "client.slua.umg.lobby_chat.ui_chat_channel_team_recruit",
      channelBpPath = macro.path.TeamRecruit_root_UIBP,
      channelId = macro.Channel.channelTeamRecruit,
      uiStat_name = "\230\139\155\229\139\159\233\162\145\233\129\147-\231\187\132\233\152\159\230\139\155\229\139\159",
      margin = FMargin(72, 60, 0, 10),
      tabSelectIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Team_Xuanzhong_png.Common_Tab_Team_Xuanzhong_png",
      tabDefualtIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Team_png.Common_Tab_Team_png",
      ignoreChatMasterSwitchId = BP_ENUM_ONLY_CHAT_TEAM_RECRUIT_SWITCH,
      checkShowFunc = function()
        local modeSystem = require("client.slua.logic.match.logic_mode_mgr")
        if modeSystem.IsSocialIslandMode() and not LobbySystem.CheckOpen(BP_ENUM_SOCIAL_ISLAND_CHAT_TEAM_RECRUIT_SWITCH) then
          return false
        end
        local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
        if logic_home_entry:IsPlanPHMode() and not modeSystem.IsSocialIslandMode() then
          return false
        end
        if RoomSystem.IsTModeRoom() then
          log(bWriteLog and "macro.Channel.channelTeamRecruit show false")
          return false
        end
        return true
      end
    },
    [macro.Channel.channelPrivate] = {
      tabId = 7,
      channelModuleName = "client.slua.umg.lobby_chat.ui_chat_channel_friend",
      channelBpPath = macro.path.FriendChat_root_UIBP,
      memberListBpPath = macro.path.ChatMemberList,
      memberListModuleName = "client.slua.umg.lobby_chat.ui_chat_member_list_friend",
      memberListAttachRoot = "ChatFriendlist",
      channelId = macro.Channel.channelPrivate,
      uiStat_name = "\232\129\138\229\164\169\233\162\145\233\129\147-\229\165\189\229\143\139",
      margin = FMargin(320, 50, 0, 10),
      tabSelectIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Friend_Xuanzhong_png.Common_Tab_Friend_Xuanzhong_png",
      tabDefualtIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Friend_png.Common_Tab_Friend_png"
    },
    [macro.Channel.channelTeam] = {
      tabId = 8,
      channelModuleName = "client.slua.umg.lobby_chat.ui_chat_channel_team",
      channelBpPath = macro.path.TeamChat_root_UIBP,
      channelId = macro.Channel.channelTeam,
      uiStat_name = "\232\129\138\229\164\169\233\162\145\233\129\147-\231\187\132\233\152\159",
      margin = FMargin(72, 60, 0, 10),
      tabSelectIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_3P_Team_Xuanzhong_png.Common_Tab_3P_Team_Xuanzhong_png",
      tabDefualtIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_3P_Team_png.Common_Tab_3P_Team_png",
      checkShowFunc = function()
        local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
        if false == TeamUpNewSystem.IsInTeam() then
          return false
        end
        local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
        local bPlanPHMode = PlanPH_GamePlay_Tools.IsPHomeMode()
        if bPlanPHMode then
          printf("chat_ui_config.checkShowFunc channelTeam show false. IsPHomeMode")
          return false
        end
        return true
      end
    },
    [macro.Channel.channelCorps] = {
      tabId = 9,
      channelModuleName = "client.slua.umg.lobby_chat.ui_chat_channel_corps",
      channelBpPath = macro.path.Corps_root_UIBP,
      memberListBpPath = macro.path.ChatMemberList,
      memberListModuleName = "client.slua.umg.lobby_chat.ui_chat_member_list_corps",
      memberListAttachRoot = "ChatCorpsMemberlist",
      channelId = macro.Channel.channelCorps,
      uiStat_name = "\232\129\138\229\164\169\233\162\145\233\129\147-\229\134\155\229\155\162",
      margin = FMargin(320, 104, 0, 10),
      tabSelectIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Crops_Xuanzhong_png.Common_Tab_Crops_Xuanzhong_png",
      tabDefualtIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Crops_png.Common_Tab_Crops_png",
      checkShowFunc = function()
        local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
        if LogicTxMissionMain.IsInXMission() then
          printf("chat_ui_config.checkShowFunc channelCorps show false. IsInXMission")
          return false
        end
        local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
        if GameStatus.IsInLobbyOrMainCity() then
          return true
        elseif GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
          return true
        elseif MatchModeMgrSystem.IsSocialIslandMode() then
          return true
        else
          return false
        end
      end
    },
    [macro.Channel.channelClub] = {
      tabId = 10,
      channelModuleName = "client.slua.umg.lobby_chat.Club_Chat_UIBP",
      channelBpPath = macro.path.Club_Chat_UIBP,
      channelId = macro.Channel.channelClub,
      uiStat_name = "\232\129\138\229\164\169\233\162\145\233\129\147-\231\164\190\231\190\164",
      margin = FMargin(260, 60, 0, 10),
      tabSelectIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Club_Xuanzhong_png.Common_Tab_Club_Xuanzhong_png",
      tabDefualtIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Club_png.Common_Tab_Club_png",
      checkShowFunc = function()
        local logic_community = require("client.slua.logic.community.logic_community")
        if not LobbySystem.CheckOpen(BP_ENUM_CLUB_CHAT_SWITCH) or not logic_community.GetShowEntry() then
          return false
        end
        local modeSystem = require("client.slua.logic.match.logic_mode_mgr")
        local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
        if logic_home_entry:IsPlanPHMode() and not modeSystem.IsSocialIslandMode() then
          return false
        end
        return true
      end
    },
    [macro.Channel.channelChatRoom] = {
      tabId = 11,
      channelModuleName = "client.slua.umg.lobby_chat.chatroom.ui_chat_channel_chat_room",
      channelBpPath = macro.path.ChatRoom_UIBP,
      channelId = macro.Channel.channelChatRoom,
      uiStat_name = "\232\129\138\229\164\169\233\162\145\233\129\147-\232\129\138\229\164\169\229\174\164",
      margin = FMargin(200, 180, 0, 70),
      tabSelectIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Room_Xuanzhong_png.Common_Tab_Room_Xuanzhong_png",
      tabDefualtIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Room_png.Common_Tab_Room_png",
      checkShowFunc = function()
        local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
        if LogicTxMissionMain.IsInXMission() then
          printf("chat_ui_config.checkShowFunc channelChatRoom show false. IsInXMission")
          return false
        end
        if not LobbySystem.CheckOpen(BP_ENUM_ROOM_CHAT_SWITCH) then
          printf("chat_ui_config.checkShowFunc channelChatRoom show false. BP_ENUM_ROOM_CHAT_SWITCH")
          return false
        end
        local logic_room_match_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_room_match_voice)
        if logic_room_match_voice:IsVoiceRoom() then
          return false
        end
        if GameStatus.IsInLobbyOrMainCity() then
          return true
        end
        return false
      end
    },
    [macro.Channel.channelFlashMatchTeam] = {
      tabId = 8,
      channelModuleName = "client.slua.umg.lobby_chat.ui_chat_channel_flash_match_team",
      channelBpPath = macro.path.FlashMatchTeamChat_root_UIBP,
      channelId = macro.Channel.channelFlashMatchTeam,
      uiStat_name = "\233\151\170\233\133\141\229\176\143\233\152\159-\232\129\138\229\164\169\229\174\164",
      margin = FMargin(320, 170, 0, 10),
      tabSelectIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_TeamQuick_Xuanzhong_png.Common_Tab_TeamQuick_Xuanzhong_png",
      tabDefualtIcon = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_TeamQuick_png.Common_Tab_TeamQuick_png",
      checkShowFunc = function()
        if not GameStatus.IsInLobbyOrMainCity() then
          return false
        end
        local logic_teamquick_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_entry)
        if not logic_teamquick_entry:CheckCanShow() then
          return false
        end
        return true
      end
    }
  }
}
return chat_ui_config