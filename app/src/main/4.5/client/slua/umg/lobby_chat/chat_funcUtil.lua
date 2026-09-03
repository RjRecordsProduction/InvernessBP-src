local ChatFuncUtil = {}
local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
local StatusConfig = {}
local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
function ChatFuncUtil.CreateMemberListBp(channel, ui)
  local chatConfig = require("client.slua.umg.lobby_chat.chat_ui_config")
  local memberList = ui:CreateChildWindowWithLuaAndBpPath(chatConfig.channel[channel].memberListAttachRoot, nil, chatConfig.channel[channel].memberListModuleName, chatConfig.channel[channel].memberListBpPath)
  return memberList
end
function ChatFuncUtil.InitMemberStatusCfg()
  StatusConfig = {
    [chat_macro.ENUM_STATUS.IDLE] = {
      localResId = 4020,
      color = FLMacros.C_Colors.GREEN
    },
    [chat_macro.ENUM_STATUS.TEAM] = {
      localResId = 1213,
      color = FLMacros.C_Colors.YELLOW
    },
    [chat_macro.ENUM_STATUS.GAME] = {
      localResId = 9911106,
      color = FLMacros.C_Colors.YELLOW
    },
    [chat_macro.ENUM_STATUS.OFFLINE] = {
      localResId = 1212,
      color = FLMacros.C_Colors.STATE_WHITE,
      text = LocUtil.GetLocalizeResStr(1212)
    },
    [chat_macro.ENUM_STATUS.ROOM] = {
      localResId = 4019,
      color = FLMacros.C_Colors.YELLOW
    },
    [chat_macro.ENUM_STATUS.WATCH] = {
      localResId = 6880,
      color = FLMacros.C_Colors.YELLOW
    },
    [chat_macro.ENUM_STATUS.CONNECT_FAIL_WITH_LOBBY] = {
      localResId = 5044,
      color = FLMacros.C_Colors.GRAY
    },
    [chat_macro.ENUM_STATUS.IN_ILANG_IDLE] = {
      localResId = 9561,
      color = FLMacros.C_Colors.STATE_BLUE
    },
    [chat_macro.ENUM_STATUS.IN_LOCAL_ILANG_IDLE] = {
      localResId = 9563,
      color = FLMacros.C_Colors.STATE_BLUE
    },
    [chat_macro.ENUM_STATUS.IN_ILANG_TEAM] = {
      localResId = 9562,
      color = FLMacros.C_Colors.YELLOW
    },
    [chat_macro.ENUM_STATUS.IN_LOCAL_ILANG_TEAM] = {
      localResId = 9564,
      color = FLMacros.C_Colors.YELLOW
    },
    [chat_macro.ENUM_STATUS.TPLAN_IDLE] = {
      localResId = 35189,
      color = FLMacros.C_Colors.STATE_BLUE
    },
    [chat_macro.ENUM_STATUS.TPLAN_TEAM] = {
      localResId = 35189,
      color = FLMacros.C_Colors.YELLOW
    },
    [chat_macro.ENUM_STATUS.FREE] = {
      localResId = 77775,
      color = FLMacros.C_Colors.GREEN
    },
    [chat_macro.ENUM_STATUS.BUSY] = {
      localResId = 77776,
      color = FLMacros.C_Colors.RED
    },
    [chat_macro.ENUM_STATUS.HIDING] = {
      localResId = 1212,
      color = FLMacros.C_Colors.GRAY
    },
    [chat_macro.ENUM_STATUS.DONOTBOTHER] = {
      localResId = 773310,
      color = FLMacros.C_Colors.RED
    },
    [chat_macro.ENUM_STATUS.ANNIVERSARY1300] = {
      localResId = 13550,
      color = FLMacros.C_Colors.YELLOW
    },
    [chat_macro.ENUM_STATUS.WOW_IDLE] = {
      localResId = 77105,
      color = FLMacros.C_Colors.STATE_BLUE
    },
    [chat_macro.ENUM_STATUS.WOW_TEAM] = {
      localResId = 77105,
      color = FLMacros.C_Colors.YELLOW
    },
    [chat_macro.ENUM_STATUS.MAINCITY_IDLE] = {
      localResId = 655642,
      color = FLMacros.C_Colors.STATE_BLUE
    },
    [chat_macro.ENUM_STATUS.MAINCITY_TEAM] = {
      localResId = 655642,
      color = FLMacros.C_Colors.YELLOW
    },
    [chat_macro.ENUM_STATUS.COLLECTION_HALL] = {
      localResId = 880060095,
      color = FLMacros.C_Colors.STATE_GREEN
    }
  }
end
function ChatFuncUtil.GetStatus(player)
  if StatusConfig == nil or next(StatusConfig) == nil then
    ChatFuncUtil.InitMemberStatusCfg()
  end
  local statusKey = chat_macro.ENUM_STATUS.OFFLINE
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(player.uid)
  if not status then
    return StatusConfig[statusKey]
  end
  local online = status.online
  log(bWriteLog and string.format("ChatFuncUtil.GetStatus teamState:%s socialland_type:%s ", tostring(status.teamState), tostring(status.socialland_type)))
  local isTeam = false
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if online == 0 then
    statusKey = chat_macro.ENUM_STATUS.OFFLINE
  elseif online == 2 then
    statusKey = chat_macro.ENUM_STATUS.CONNECT_FAIL_WITH_LOBBY
  elseif PlayerStatusUtil.IsIdle(status) then
    if status.tplan_type == 1 then
      statusKey = chat_macro.ENUM_STATUS.TPLAN_IDLE
    else
      statusKey = chat_macro.ENUM_STATUS.IDLE
    end
  elseif PlayerStatusUtil.IsTeam(status) then
    if status.tplan_type == 1 then
      statusKey = chat_macro.ENUM_STATUS.TPLAN_TEAM
    else
      statusKey = chat_macro.ENUM_STATUS.TEAM
    end
    isTeam = true
  elseif PlayerStatusUtil.IsBattle(status) then
    statusKey = chat_macro.ENUM_STATUS.GAME
    if PlayerStatusUtil.ISLANDIdle(status) then
      if status.socialland_type == 1 then
        statusKey = chat_macro.ENUM_STATUS.IN_ILANG_IDLE
      else
        statusKey = chat_macro.ENUM_STATUS.IN_LOCAL_ILANG_IDLE
      end
    elseif PlayerStatusUtil.ISLANDInTeam(status) then
      if status.socialland_type == 1 then
        statusKey = chat_macro.ENUM_STATUS.IN_ILANG_IDLE
        isTeam = true
      else
        statusKey = chat_macro.ENUM_STATUS.IN_LOCAL_ILANG_IDLE
        isTeam = true
      end
    elseif PlayerStatusUtil.IsMainCityIdle(status) then
      statusKey = chat_macro.ENUM_STATUS.MAINCITY_IDLE
    elseif PlayerStatusUtil.IsMainCityTeam(status) then
      statusKey = chat_macro.ENUM_STATUS.MAINCITY_TEAM
      isTeam = true
    elseif PlayerStatusUtil.WoWIdle(status) then
      statusKey = chat_macro.ENUM_STATUS.WOW_IDLE
    elseif PlayerStatusUtil.WoWInTeam(status) then
      statusKey = chat_macro.ENUM_STATUS.WOW_TEAM
      isTeam = true
    elseif status.game_sub_mode == 10080 then
      local text = LocUtil.GetLocalizeResStr(100042)
      StatusConfig[chat_macro.ENUM_STATUS.GAME].      return StatusConfig[chat_macro.ENUM_STATUS.GAME]
    elseif PlayerStatusUtil.IsInCollectionHall(status) then
      statusKey = chat_macro.ENUM_STATUS.COLLECTION_HALL
    elseif status.gameBeginTime then
      local TimeUtil = require("client.common.time_util")
      local text = TimeUtil.GetOpenedTimeStr(TimeUtil.GetServerTimeInSec() - status.gameBeginTime)
      local ModeName = DataMgr.GetModeName(status.game_sub_mode)
      print(bWriteLog and string.format(" ChatFuncUtil.GetStatus ModeName:%s text:%s currentTeamAmount:%s maxTeamAmount:%s", ModeName, text, status.currentTeamAmount, status.maxTeamAmount))
      text = LocUtil.LocalizeResFormat(13121, ModeName, text, status.currentTeamAmount, status.maxTeamAmount)
      StatusConfig[chat_macro.ENUM_STATUS.GAME].      return StatusConfig[chat_macro.ENUM_STATUS.GAME]
    end
  elseif PlayerStatusUtil.IsRoom(status) then
    statusKey = chat_macro.ENUM_STATUS.ROOM
  elseif PlayerStatusUtil.IsWatch(status) then
    statusKey = chat_macro.ENUM_STATUS.WATCH
  elseif PlayerStatusUtil.IsFree(status) then
    statusKey = chat_macro.ENUM_STATUS.FREE
  elseif PlayerStatusUtil.IsBusy(status) then
    statusKey = chat_macro.ENUM_STATUS.BUSY
  elseif PlayerStatusUtil.IsStealth(status) then
    statusKey = chat_macro.ENUM_STATUS.HIDING
  elseif PlayerStatusUtil.IsDoNotBother(status) then
    statusKey = chat_macro.ENUM_STATUS.DONOTBOTHER
  end
  local resId = StatusConfig[statusKey].localResId
  local statusText = ""
  if isTeam and status.currentTeamAmount and status.maxTeamAmount then
    statusText = string.format("%s %s/%s", LocUtil.GetLocalizeResStr(resId), status.currentTeamAmount, status.maxTeamAmount)
  elseif statusKey == chat_macro.ENUM_STATUS.OFFLINE then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local lastOnlineTime = logic_profile:GetLastOnlineTime(player.uid)
    local TimeUtil = require("client.common.time_util")
    if lastOnlineTime then
      statusText = TimeUtil.GetLastOnlineTimeStr(lastOnlineTime)
    else
      statusText = TimeUtil.GetLastOnlineTimeStr(TimeUtil.GetServerTimeInSec() - 604800)
    end
  else
    statusText = LocUtil.GetLocalizeResStr(resId)
  end
  log(bWriteLog and "ChatFuncUtil.GetStatus statusKey = " .. tostring(statusKey))
  StatusConfig[statusKey].text = statusText
  return StatusConfig[statusKey]
end
function ChatFuncUtil.GetChatRoomAndIslandStatus(player)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(player.uid)
  if not status then
    return
  end
  local online = player.online
  if StatusConfig == nil or next(StatusConfig) == nil then
    ChatFuncUtil.InitMemberStatusCfg()
  end
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  local statusKey = chat_macro.ENUM_STATUS.OFFLINE
  if online == 0 then
    statusKey = chat_macro.ENUM_STATUS.OFFLINE
  elseif online == 2 then
    statusKey = chat_macro.ENUM_STATUS.CONNECT_FAIL_WITH_LOBBY
  elseif PlayerStatusUtil.IsIdle(player) then
    statusKey = chat_macro.ENUM_STATUS.IDLE
  elseif PlayerStatusUtil.IsTeam(player) then
    statusKey = chat_macro.ENUM_STATUS.TEAM
  elseif PlayerStatusUtil.IsBattle(player) then
    if status.gameBeginTime then
      local TimeUtil = require("client.common.time_util")
      local text = TimeUtil.GetOpenedTimeStr(TimeUtil.GetServerTimeInSec() - status.gameBeginTime)
      log_tree("player", player)
      local ModeName = DataMgr.GetModeName(status.game_sub_mode)
      text = LocUtil.LocalizeResFormat(13121, ModeName, text, player.currentTeamAmount, player.maxTeamAmount)
      StatusConfig[chat_macro.ENUM_STATUS.GAME].      return StatusConfig[chat_macro.ENUM_STATUS.GAME]
    end
    statusKey = chat_macro.ENUM_STATUS.GAME
  elseif PlayerStatusUtil.IsRoom(player) then
    statusKey = chat_macro.ENUM_STATUS.ROOM
  elseif PlayerStatusUtil.IsWatch(player) then
    statusKey = chat_macro.ENUM_STATUS.WATCH
  elseif PlayerStatusUtil.IsFree(player) then
    statusKey = chat_macro.ENUM_STATUS.FREE
  elseif PlayerStatusUtil.IsBusy(player) then
    statusKey = chat_macro.ENUM_STATUS.BUSY
  elseif PlayerStatusUtil.IsStealth(player) then
    statusKey = chat_macro.ENUM_STATUS.HIDING
  elseif PlayerStatusUtil.IsDoNotBother(status) then
    statusKey = chat_macro.ENUM_STATUS.DONOTBOTHER
  end
  local resId = StatusConfig[statusKey].localResId
  local statusText = ""
  statusText = LocUtil.GetLocalizeResStr(resId)
  StatusConfig[statusKey].text = statusText
  return StatusConfig[statusKey]
end
function ChatFuncUtil.GetMemberStatisData(key)
  return StatusConfig[key]
end
function ChatFuncUtil.ParseIslandBroadcastMsg(msg, show_in)
  log_tree("ParseIslandBroadcastMsg:", msg)
  local txt = ""
  local pb = require("pb")
  if msg.msgType == chat_macro.SocialIslandBroadcastMsgType_Present then
    if msg.bIsSelfReceiver then
      local sTipContent = LocUtil.LocalizeResFormat(7634, msg.sSenderName, msg.nGiftCount)
      local sPattern = "PopularityGift"
      txt = string.gsub(sTipContent, sPattern, sPattern .. msg.nGiftType)
    else
      local present = msg.presented
      local itemCfg = CDataTable.GetTableData("Item", present.item_id)
      if itemCfg then
        txt = LocUtil.LocalizeResFormat(9553, present.receiver_name, present.sender_name, itemCfg.ItemName, present.item_count)
      end
    end
  elseif msg.msgType == chat_macro.SocialIslandBroadcastMsgType_EnterIsland then
    local alias_id = msg.enterIsland.alias_id or 0
    local aliasRank = msg.enterIsland.alias_rank or 0
    local AliasCfg = CDataTable.GetTableData("AliasCfg", alias_id)
    if 0 < aliasRank and AliasCfg and AliasCfg.AliasType == 7 then
      txt = FuncUtil.GenEnterBroadcastMsg(alias_id, msg.enterIsland.player_name, aliasRank)
    else
      txt = LocUtil.LocalizeResFormat(9554, msg.enterIsland.player_name)
    end
  elseif msg.msgType == chat_macro.SocialIslandBroadcastMsgType_TargetShooting then
    txt = ChatFuncUtil.GetTargetShootingText(msg.targetShooting.player_name, msg.targetShooting.score, show_in)
  elseif msg.msgType == chat_macro.SocialIslandBroadcastMsgType_Get_Alias then
    local getAliasType = msg.getAliasType
    local cfg = CDataTable.GetTableData("SocialIslandAliasCfg", getAliasType.alias_id)
    if cfg then
      txt = LocUtil.LocalizeResFormat(10120, getAliasType.player_name, cfg.AliasName)
    end
  elseif msg.msgType == chat_macro.SocialIslandBroadcastMsgType_Build_Redpacket then
    local BornIslandRedpacketConfig = require("GameLua.Activity.IG2000.GamePlay.Config.BornIslandRedpacketConfig")
    local RedpacketItemCfg = BornIslandRedpacketConfig[msg.extraParam2]
    if RedpacketItemCfg and RedpacketItemCfg.BuildBoardcastID then
      txt = LocUtil.LocalizeResFormat(RedpacketItemCfg.BuildBoardcastID, msg.extraParam1)
    end
  elseif msg.msgType == chat_macro.SocialIslandBroadcastMsgType_Snatch_Redpacket then
    local BornIslandRedpacketConfig = require("GameLua.Activity.IG2000.GamePlay.Config.BornIslandRedpacketConfig")
    local RedpacketItemCfg = BornIslandRedpacketConfig[msg.extraParam2]
    if RedpacketItemCfg and RedpacketItemCfg.SnatchBoardcastID then
      txt = LocUtil.LocalizeResFormat(RedpacketItemCfg.SnatchBoardcastID, msg.extraParam1)
    end
  elseif msg.msgType == chat_macro.SocialIslandBroadcastMsgType_PHome_Jacpot then
    local PHomeStoreProxy = require("client.slua.logic.homestore.PHomeStoreProxy")
    txt = PHomeStoreProxy:GetJackpotBroadcastText(msg)
  end
  log(bWriteLog and "ParseIslandBroadcastMsg txt:" .. txt)
  return txt
end
function ChatFuncUtil.GetTargetShootingText(player_name, score, show_in)
  local txt = ""
  local island_macro = require("GameLua.Mod.SocialIsland.Client.IslandMacro")
  if score < island_macro.Target_Shooting_Calculate_Star_Score then
    txt = LocUtil.LocalizeResFormat(9555, player_name, score)
  else
    local star_base_score = island_macro.Target_Shooting_Star_Base_Score
    if show_in == island_macro.ENUM_Broadcast_Msg_Show_In.MainUI then
      txt = LocUtil.LocalizeResFormat(10124, player_name, star_base_score, ChatFuncUtil.GetTargetShootingStarNum(score))
    elseif show_in == island_macro.ENUM_Broadcast_Msg_Show_In.Island_Chat then
      txt = LocUtil.LocalizeResFormat(10125, player_name, star_base_score, ChatFuncUtil.GetTargetShootingStarNum(score))
    end
  end
  return txt
end
function ChatFuncUtil.GetTargetShootingStarNum(score)
  local island_macro = require("GameLua.Mod.SocialIsland.Client.IslandMacro")
  if score >= island_macro.Target_Shooting_Calculate_Star_Score then
    return math.floor((score - island_macro.Target_Shooting_Star_Base_Score) / island_macro.Target_Shooting_One_Star_Score)
  end
  return 0
end
function ChatFuncUtil.IsIslandBroadcastMsg(msgType)
  if msgType == chat_macro.SocialIslandBroadcastMsgType_Present or msgType == chat_macro.SocialIslandBroadcastMsgType_EnterIsland or msgType == chat_macro.SocialIslandBroadcastMsgType_TargetShooting or msgType == chat_macro.SocialIslandBroadcastMsgType_Get_Alias or msgType == chat_macro.SocialIslandBroadcastMsgType_Build_Redpacket or msgType == chat_macro.SocialIslandBroadcastMsgType_PHome_Jacpot or msgType == chat_macro.SocialIslandBroadcastMsgType_Snatch_Redpacket then
    return true
  end
  return false
end
function ChatFuncUtil.CanHideMsgAndHead(msgType)
  local hide = ChatFuncUtil.IsIslandBroadcastMsg(msgType)
  if msgType == chat_macro.changeRoomTipsMsgType or msgType == chat_macro.corpsNewsMsgType or msgType == chat_macro.OpenBlackMsgType or msgType == chat_macro.ModifyRecruitFilter or hide or msgType == chat_macro.ClubChatTipsMsgType or msgType == chat_macro.ClubRecentMsgType or msgType == chat_macro.proundHornMsgType or msgType == chat_macro.FriendRecruitType or msgType == chat_macro.ChatSecurityRemind or msgType == chat_macro.SupportTopicOptionMsgType or msgType == chat_macro.ChatRoomSendGiftMsgType or msgType == chat_macro.Notify then
    hide = true
  else
    hide = false
  end
  return hide
end
return ChatFuncUtil