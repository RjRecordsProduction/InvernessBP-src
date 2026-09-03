local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
local logic_chat_channel_club = {}
local map_club_msg
local current_club_id = 0
local my_create_list, my_top_list, my_remain_list
local MAX_CLUB_MESSAGE_NUM = 200
local club_detail_info
local UpdateClubList = function(my_create, my_top, my_remain)
  my_create_list = my_create
  my_top_list = my_top
  my_remain_list = my_remain
end
function logic_chat_channel_club.Init()
  logic_chat_channel_club.RegisterEvent()
end
function logic_chat_channel_club.RegisterEvent()
  EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, logic_chat_channel_club.InitRedPointInfo)
end
function logic_chat_channel_club.UnRegisterEvent()
  EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, logic_chat_channel_club.InitRedPointInfo)
end
function logic_chat_channel_club.AddNewChat(chatMsg)
  local msgList = logic_chat_channel_club.GetChatMsgList(chatMsg.club_id)
  if msgList then
    if #msgList >= MAX_CLUB_MESSAGE_NUM then
      logic_chat_table_pool.Recycle(msgList[1])
      msgList:RemoveItem(1)
    end
    msgList:AppendItem(chatMsg)
  end
end
function logic_chat_channel_club.GetChatMsgList(club_id)
  if not club_id or club_id == 0 then
    return nil
  end
  if map_club_msg == nil then
    map_club_msg = {}
  end
  local msgList = map_club_msg[club_id]
  if not msgList then
    local super_list = require("common.super_list")
    msgList = super_list.Create()
    map_club_msg[club_id] = msgList
  end
  return msgList
end
function logic_chat_channel_club.SendMsg(content)
  local logic_access_restriction = require("client.logic.common.logic_access_restriction")
  if not logic_access_restriction.CheckAccessAndPopTips(logic_access_restriction.EAccessType.ClubChat) then
    return
  end
  if logic_chat_channel_club.CheckHasRightToChat() == false then
    return
  end
  local msg = {}
  msg.text = content
  local TimeUtil = require("client.common.time_util")
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = 0
  msg.quickMsg = false
  msg.club_id = logic_chat_channel_club.GetCurrentClubId()
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelClub, msgId, msg)
end
function logic_chat_channel_club.SendVoiceMsg(voiceId, length, content)
  if nil == voiceId or "" == voiceId then
    return
  end
  if logic_chat_channel_club.CheckHasRightToChat() == false then
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local msg = {}
  msg.text = content
  msg.voice = voiceId
  msg.voiceLength = length
  msg.msgType = chat_macro.VoiceChatMsgType
  msg.quickMsg = false
  msg.club_id = logic_chat_channel_club.GetCurrentClubId()
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelClub, msgId, msg)
end
function logic_chat_channel_club.SendAchivementShare(achievementShareId, finishTime)
  if logic_chat_channel_club.CheckHasRightToChat() == false then
    return
  end
  log(bWriteLog and "logic_chat_channel_club.SendAchivementShare")
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local content = LocUtil.GetLocalizeResStr("5027")
  local other = {}
  other.achievementId = achievementShareId
  other.finish_time = finishTime
  local msg = {}
  msg.text = content
  local TimeUtil = require("client.common.time_util")
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.achivementMsgType
  msg.quickMsg = false
  msg.  msg.club_id = logic_chat_channel_club.GetCurrentClubId()
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelClub, msgId, msg)
end
function logic_chat_channel_club.SendUGCShareInvite(ugcParam, extraParam)
  local satisfy = logic_chat_channel_club.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_club.SendUGCShareInvite has no right to chat")
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local msg = {}
  msg.text = extraParam.msgText
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.UGCShareMsgType
  msg.quickMsg = false
  msg.other = ugcParam
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelClub, msgId, msg)
end
function logic_chat_channel_club.SendUGCShareCollectionList(ugcParam, extraParam)
  local satisfy = logic_chat_channel_club.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_club.SendUGCShareInvite has no right to chat")
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local msg = {}
  msg.text = extraParam.msgText
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.UGCShareCollectionMsgType
  msg.quickMsg = false
  msg.other = ugcParam
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelClub, msgId, msg)
end
function logic_chat_channel_club.CheckHasRightToChat()
  if not logic_chat_channel_club.HasJoinClub() then
    ShowNotice(27601)
    return false
  end
  if logic_chat_channel_club.GetCurrentClubId() == 0 then
    ShowNotice(27602)
    return false
  end
  return true
end
function logic_chat_channel_club.ClearData()
  if map_club_msg then
    for _, v in pairs(map_club_msg) do
      logic_chat_table_pool.RecycleAll(v)
    end
    map_club_msg = nil
  end
  logic_chat_channel_club.SetCurrentClubId(0)
  UpdateClubList(nil, nil, nil)
  club_detail_info = nil
  logic_chat_channel_club.UnRegisterEvent()
end
function logic_chat_channel_club.GetClubList()
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local clubList = {}
  if my_create_list and next(my_create_list) then
    for _, v in pairs(my_create_list) do
      local TableUtil = require("common.table_util")
      local temp = TableUtil.CopyTable(v)
      temp.club_type = chat_macro.ENUM_CLUB_TYPE.MY_CREATE_CLUB
      table.insert(clubList, temp)
    end
  end
  if my_top_list and next(my_top_list) then
    for _, v in pairs(my_top_list) do
      local TableUtil = require("common.table_util")
      local temp = TableUtil.CopyTable(v)
      temp.club_type = chat_macro.ENUM_CLUB_TYPE.MY_TOP_CLUB
      table.insert(clubList, temp)
    end
  end
  if my_remain_list and next(my_remain_list) then
    for _, v in pairs(my_remain_list) do
      local TableUtil = require("common.table_util")
      local temp = TableUtil.CopyTable(v)
      temp.club_type = chat_macro.ENUM_CLUB_TYPE.MY_REMAIN_CLUB
      table.insert(clubList, temp)
    end
  end
  return clubList
end
function logic_chat_channel_club.IsMyCreateClub(club_id)
  if not club_id or club_id == 0 then
    return false
  end
  if not my_create_list then
    return false
  end
  for _, info in pairs(my_create_list) do
    if info.club_id == club_id then
      return true
    end
  end
  return false
end
function logic_chat_channel_club.IsOnTop(club_id)
  if not club_id or club_id == 0 then
    return false
  end
  if not my_top_list then
    return false
  end
  for _, info in pairs(my_top_list) do
    if info.club_id == club_id then
      return true
    end
  end
  return false
end
function logic_chat_channel_club.HasJoinClub()
  if my_create_list and next(my_create_list) then
    return true
  end
  if my_top_list and next(my_top_list) then
    return true
  end
  if my_remain_list and next(my_remain_list) then
    return true
  end
  return false
end
function logic_chat_channel_club.SetCurrentClubId(club_id)
  current_club_id = tonumber(club_id)
end
function logic_chat_channel_club.GetCurrentClubId()
  return current_club_id
end
function logic_chat_channel_club.GetClubDetailInfo(club_id)
  if club_detail_info == nil then
    return nil
  end
  return club_detail_info[club_id]
end
function logic_chat_channel_club.InitRedPointInfo()
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.ClubChatRedPoint
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  if saveData == nil or not saveData.hasGuide then
    logic_chat_channel_manager:UpdateChannelRedPoint(chat_macro.Channel.channelClub, true)
  else
    logic_chat_channel_manager:UpdateChannelRedPoint(chat_macro.Channel.channelClub, false)
  end
end
function logic_chat_channel_club.ClearRedPointInfo()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.ClubChatRedPoint
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  saveData = saveData or {}
  saveData.hasGuide = true
  PlayerPrefsSystem.SaveTableToFile_N(saveData, fileType)
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  logic_chat_channel_manager:UpdateChannelRedPoint(chat_macro.Channel.channelClub, false)
end
function logic_chat_channel_club.RemoveClubChatTips()
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  if map_club_msg then
    for _, msgList in pairs(map_club_msg) do
      for index, msg in pairs(msgList) do
        if msg.msgType == chat_macro.ClubChatTipsMsgType then
          msgList:RemoveItem(index)
          break
        end
      end
    end
  end
end
function logic_chat_channel_club.send_club_list_req()
  local ChatClubHandler = require("client.network.Protocol.ChatClubHandler")
  ChatClubHandler.send_club_list_req()
end
function logic_chat_channel_club.on_club_list_rsp(my_create, my_top, my_remain)
  UpdateClubList(my_create, my_top, my_remain)
  EventSystem:postEvent(EVENTTYPE_CHAT_CLUB, EVENTID_CHAT_CLUB_GET_LIST)
end
function logic_chat_channel_club.on_notify_user_club_list(my_create, my_top, my_remain)
  UpdateClubList(my_create, my_top, my_remain)
  EventSystem:postEvent(EVENTTYPE_CHAT_CLUB, EVENTID_CHAT_CLUB_UPDATE_LIST)
end
function logic_chat_channel_club.send_do_op_club_req(op_type, club_id)
  local ChatClubHandler = require("client.network.Protocol.ChatClubHandler")
  ChatClubHandler.send_do_op_club_req(op_type, club_id)
end
function logic_chat_channel_club.on_do_op_club_rsp(my_create, my_top, my_remain)
  UpdateClubList(my_create, my_top, my_remain)
  EventSystem:postEvent(EVENTTYPE_CHAT_CLUB, EVENTID_CHAT_CLUB_DO_OP_SUCCESS)
end
function logic_chat_channel_club.send_club_subscribe_req(club_id)
  log(bWriteLog and "logic_chat_channel_club.send_club_subscribe_req club_id:" .. tostring(club_id))
  local ChatClubHandler = require("client.network.Protocol.ChatClubHandler")
  ChatClubHandler.send_club_subscribe_req(club_id)
end
function logic_chat_channel_club.on_club_subscribe_rsp(club_id)
  log(bWriteLog and "logic_chat_channel_club.on_club_subscribe_rsp club_id:" .. tostring(club_id))
  logic_chat_channel_club.SetCurrentClubId(club_id)
  EventSystem:postEvent(EVENTTYPE_CHAT_CLUB, EVENTID_CHAT_CLUB_SUBSCRIBE_SUCCESS)
end
function logic_chat_channel_club.RequestClubDetailInfo(callback)
  local clubList = logic_chat_channel_club.GetClubList()
  if #clubList == 0 then
    callback()
    log(bWriteLog and "logic_chat_channel_club.RequestClubDetailInfo no club")
    return
  end
  local club_id_list = {}
  for _, club_profile_info in pairs(clubList) do
    table.insert(club_id_list, club_profile_info.club_id)
  end
  local logic_community = require("client.slua.logic.community.logic_community")
  local url = logic_community.GetVersionUrl() .. "/sns/club/snippet"
  local BusinessHelper = import("BusinessHelper")
  local openid = BusinessHelper.GetOpenId()
  local ticket = Client.GetWebViewTicket(NetInterface)
  local region = FuncUtil.GetAccountRegionForBP()
  local lang = Client.GetCurrentLanguage()
  local header = {
    openid = openid,
    ticket = ticket,
    region = region,
    lang = lang,
    ["Content-Type"] = "application/json",
    ["Accept-Encoding"] = "gzip"
  }
  local jsonStr = json.encode({clubId = club_id_list})
  log(bWriteLog and "logic_chat_channel_club.RequestClubDetailInfo jsonStr:" .. jsonStr)
  local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
  http_manager:Post(url, header, jsonStr, nil, function(success, data)
    log(bWriteLog and string.format("logic_chat_channel_club.RequestClubInfo success:%s, data:%s", success, data))
    local tb = json.decode(data)
    if tb and tb.club then
      club_detail_info = {}
      for _, detail_info in pairs(tb.club) do
        club_detail_info[detail_info.clubId] = detail_info
      end
      log_tree(bWriteLog and "logic_chat_channel_club.RequestClubInfo club_detail_info:", club_detail_info)
      if Client.IsReleaseVersion(NetInterface) then
        logic_chat_channel_club.FilterClubList()
      end
    end
    callback()
  end)
end
function logic_chat_channel_club.FilterClubList()
  if club_detail_info == nil then
    return
  end
  if my_create_list and next(my_create_list) then
    for k, v in pairs(my_create_list) do
      if not club_detail_info[v.club_id] then
        my_create_list[k] = nil
      end
    end
  end
  if my_top_list and next(my_top_list) then
    for k, v in pairs(my_top_list) do
      if not club_detail_info[v.club_id] then
        my_top_list[k] = nil
      end
    end
  end
  if my_remain_list and next(my_remain_list) then
    for k, v in pairs(my_remain_list) do
      if not club_detail_info[v.club_id] then
        my_remain_list[k] = nil
      end
    end
  end
end
function logic_chat_channel_club.RequestChatInfoFromClub()
  local clubId = logic_chat_channel_club.GetCurrentClubId()
  if clubId == 0 then
    log(bWriteLog and "logic_chat_channel_club.RequestChatInfoFromClub clubId zero")
    return
  end
  local logic_community = require("client.slua.logic.community.logic_community")
  local url = logic_community.GetVersionUrl() .. "/feed/chat_update"
  local BusinessHelper = import("BusinessHelper")
  local openid = BusinessHelper.GetOpenId()
  local ticket = Client.GetWebViewTicket(NetInterface)
  local region = FuncUtil.GetAccountRegionForBP()
  local lang = Client.GetCurrentLanguage()
  local header = {
    openid = openid,
    ticket = ticket,
    region = region,
    lang = lang,
    ["Content-Type"] = "application/json"
  }
  local jsonStr = json.encode({club_id = clubId})
  log(bWriteLog and "logic_chat_channel_club.RequestChatInfoFromClub jsonStr:" .. jsonStr)
  local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
  http_manager:Post(url, header, jsonStr, nil, function(success, data)
    log(bWriteLog and string.format("logic_chat_channel_club.RequestChatInfoFromClub success:%s, data:%s", success, data))
    local tb = json.decode(data)
    if tb then
      log_tree(bWriteLog and "logic_chat_channel_club.RequestChatInfoFromClub tb:", tb)
      logic_chat_channel_club.AddClubOwnerMessage(tb)
      logic_chat_channel_club.AddClubRecentMessage(tb)
    end
  end)
end
function logic_chat_channel_club.AddClubOwnerMessage(tb)
  if tonumber(tb.ownerUid) == 0 or tb.ownerText == "" then
    return
  end
  if not tb.iid or tb.iid == "" then
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local chat_content = {
    msgType = chat_macro.ClubOwnerMsgType,
    club_id = tonumber(tb.clubId),
    ownerText = tb.ownerText,
    iid = tb.iid
  }
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local send_uid = tonumber(tb.ownerUid)
  local uid = chat_main.GetIdStr(send_uid)
  local chatMsg = chat_main.SetNewChat(logic_chat_table_pool.Get(), "", chat_macro.Channel.channelClub, send_uid, uid, nil, nil, chat_content, send_uid == tonumber(DataMgr.roleData.uid))
  logic_chat_channel_club.AddNewChat(chatMsg)
end
function logic_chat_channel_club.AddClubRecentMessage(tb)
  if tonumber(tb.hotNum) == 0 then
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local chatMsg = {
    msgType = chat_macro.ClubRecentMsgType,
    club_id = tonumber(tb.clubId),
    hotNum = tonumber(tb.hotNum)
  }
  logic_chat_channel_club.AddNewChat(chatMsg)
end
return logic_chat_channel_club