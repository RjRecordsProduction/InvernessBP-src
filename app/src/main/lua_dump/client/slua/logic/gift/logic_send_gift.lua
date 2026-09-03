local logic_send_gift = {
  CurRecordUID = 0,
  gift_record = {},
  gift_record_summary = {},
  CacheAllGiftsTable = nil,
  useRadio = false,
  bIsHornFree = false,
  lastGiftInRoleInfoPopularity = {},
  gift_left = 50,
  daily_upvote_cnt = 0
}
local gift_const = require("client.slua.logic.gift.gift_const")
function logic_send_gift.pspace_send_gift_req(uid, gift_type, gift_count, msg, name, gift_source, corps_seq_info, club_params, battle_id, manor_party_params, extendinfo)
  log(bWriteLog and "pspace_send_gift_req:" .. tostring(gift_type) .. ",gift_count:" .. tostring(gift_count) .. ",msg:" .. tostring(msg) .. ",name:" .. tostring(name) .. ",gift_source:" .. tostring(gift_source))
  log(bWriteLog and "uid = " .. tostring(uid) .. ", battle_id = " .. tostring(battle_id))
  log_tree("logic_send_gift.pspace_send_gift_req manor_party_params = ", manor_party_params)
  local AccountAnchorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.AccountAnchorModule)
  if not AccountAnchorModule:CanSendPopularity() then
    ShowNotice(500173)
    return
  end
  if logic_send_gift.GetHallDepotGiftCount(gift_type) == 0 and logic_send_gift.IsUcGift(gift_type) then
    log(bWriteLog and "logic_send_gift.pspace_send_gift_req isUCGift")
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    if QRcodeRestrictManager:CheckUCRestrict() then
      return
    end
  end
  if GameStatus.IsInMainCity() then
    extendinfo = extendinfo or {}
    extendinfo.sceneType = "MainCity"
  end
  log_tree("logic_send_gift.pspace_send_gift_req extendinfo = ", extendinfo)
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_pspace_send_gift_req(tonumber(uid), gift_type, gift_count, msg, name, gift_source, corps_seq_info, club_params, battle_id, manor_party_params, extendinfo)
end
function logic_send_gift.HandleGiftErrorCode(err_code, gift_type)
  if err_code == 0 then
    return
  end
  if err_code == 700002 then
    ShowNotice(502001)
  elseif err_code == 540001 then
    ShowNotice(9920020)
  elseif err_code == 700001 then
    ShowNotice(9920020)
  elseif err_code == 540005 then
    local info = logic_send_gift.GetGiftData(gift_type)
    if info.PriceType == 0 then
      ShowNotice(502024)
    elseif info.PriceType == 1 then
      ShowNotice(4457)
    elseif info.PriceType == 2 then
      ShowNotice(502006)
    end
  elseif err_code == 540008 then
    local maxCorpsSendNum = 10
    ShowNotice(GlobalData.GetLocalizeStringWithNum(7932, 0, maxCorpsSendNum))
  elseif err_code == 540009 then
    ShowNotice(7933)
  elseif err_code == 540002 then
    ShowNotice(6803)
  elseif err_code == 540010 then
    ShowNotice(8038)
  elseif err_code == 540011 then
    ShowNotice(8039)
  elseif err_code == 540012 then
    return
  elseif err_code == 500167 then
    local config = logic_send_gift.GetGiftData(gift_type)
    if config and config.devote_cond then
      logic_send_gift.ShowCondTips(config.devote_cond)
    end
  elseif err_code == 540013 then
    ShowNotice(37488)
  elseif err_code == 500171 then
    ShowNotice(77871)
  elseif err_code == 13064023 then
    ShowNotice(69542)
  elseif err_code == 500174 then
    ShowNotice(1050079)
  elseif err_code == 500175 then
    ShowNotice(500175)
  elseif err_code == 500180 then
    ShowNotice(500180)
  elseif err_code == 500176 then
    ShowNotice(9910012)
  elseif err_code == 500177 then
    ShowNotice(411015)
  elseif err_code == 500178 then
    ShowNotice(13065016)
  elseif err_code == 500179 then
    ShowNotice(1050080)
  else
    ShowNotice(err_code)
  end
end
function logic_send_gift.pspace_send_gift_rsp(ok, total_devote, add_devote, gift_record, devote_rank, last_trend, gift_type, gift_count, uid, last_week_devote, msg_trend, last_high_value, gift_source, pround_info, battle_id, psmatch_team_gift)
  log(bWriteLog and "pspace_send_gift_rsp:ok" .. tostring(ok) .. ",total_devote" .. tostring(total_devote) .. ",add_devote:" .. tostring(add_devote) .. ",gift_type:" .. tostring(gift_type) .. ",gift_count:" .. tostring(gift_count) .. ",gift_source:" .. tostring(gift_source) .. ",battle_id:" .. tostring(battle_id))
  if ok ~= 0 then
    logic_send_gift.HandleGiftErrorCode(ok, gift_type)
    if logic_send_gift.useRadio then
      logic_send_gift.useRadio = false
      logic_send_gift.chatContent = ""
    end
    if logic_send_gift.bIsHornFree then
      logic_send_gift.bIsHornFree = false
    end
    return
  end
  if gift_type == 1 and gift_source == gift_const.GiftSourceType.LobbyFriend then
    log(bWriteLog and "logic_send_gift.pspace_send_gift_rsp gift_type = " .. tostring(gift_type) .. ",gift_source = " .. tostring(gift_const.GiftSourceType.LobbyFriend) .. ", logic_send_gift:send_query_quick_gift_friends_req")
    logic_send_gift:send_query_quick_gift_friends_req()
  end
  logic_send_gift.get_pop_gift_record_rsp(ok, gift_record, uid)
  logic_send_gift.ClearUpvoteGiftRecord(uid)
  if last_trend and next(last_trend) then
    local LastTrend = last_trend[#last_trend]
    local AccountAnchorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.AccountAnchorModule)
    AccountAnchorModule:AddSendPopularityValue(LastTrend.add_devote_value, LastTrend.devote_time)
  end
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.TotalPopularity = total_devote
  RoleInfoPopularitySystem.AddDevote = add_devote
  RoleInfoPopularitySystem.DevoteRank = devote_rank
  RoleInfoPopularitySystem.LastTrend = last_trend
  RoleInfoPopularitySystem.MsgTrend = msg_trend or {}
  RoleInfoPopularitySystem.GiftType = gift_type
  RoleInfoPopularitySystem.GiftCount = gift_count
  RoleInfoPopularitySystem.LastWeekDevote = last_week_devote or 0
  RoleInfoPopularitySystem.CachedUid.get_popularity = 0
  local logic_pround = require("client.slua.logic.pround.logic_pround")
  local addProundExp = logic_pround.SendGiftRsp(pround_info)
  local modeSystem = require("client.slua.logic.match.logic_mode_mgr")
  if modeSystem.IsSocialIslandMode() then
    local frontendUtils = slua_GameFrontendHUD:GetUtils()
    local container = frontendUtils:GetGlobalUIContainer(UIContainers.Top)
    local UIUtil = require("client.common.ui_util")
    local ViewportSize = UIUtil.GetViewportSize() / UIUtil.GetViewportScale()
    local ui_depth_manager = require("client.common.uibase.ui_depth_manager")
    logic_send_gift.PlayGiftAni(gift_type, gift_count, container, ViewportSize.X / 2, ViewportSize.Y / 3, ui_depth_manager.GetTopDepth() + 1)
  end
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local gift_const = require("client.slua.logic.gift.gift_const")
  if gift_type ~= collect_module.collect_cfg.voteId and not gift_const.NotShowGiveTipsSourceTypeCfg[gift_source] then
    local logic_gift_notice = require("client.slua.logic.gift.logic_gift_notice")
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    if profile then
      logic_gift_notice.ShowGiftNotice(profile.nickName, gift_type, gift_count, addProundExp)
    else
      do
        local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
        logic_profile_get_wrap.GetNormalProfiles({
          tonumber(uid)
        }, function(list)
          if 1 <= #list then
            logic_gift_notice.ShowGiftNotice(list[1].nickName, gift_type, gift_count, addProundExp)
          end
        end, Enum_PROFILE_REPORT_CFG.POP_DEVOTE)
      end
    end
  end
  logic_send_gift.TrySendGiftHorn(gift_type)
  local tb = {
    add_devote = add_devote,
    gift_type = gift_type,
    gift_count = gift_count,
    uid = uid,
    gift_source = gift_source,
      }
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_PSPACE_SEND_GIFT_RSP, tb, battle_id)
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  logic_longline_task.SaveSendGiftToReturnInfo(uid)
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  local bHomeMod = PlanPH_GamePlay_Tools.IsPHomeMode()
  log(bWriteLog and "logic_send_gift.pspace_send_gift_rsp bHomeMod = " .. tostring(bHomeMod))
  if bHomeMod then
    local LogicHomeParty = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicHomeParty)
    LogicHomeParty:SetSendGiftReceiveUid(uid)
    LogicHomeParty:SendPartyGiftUsedItems()
  end
end
function logic_send_gift.send_gift_notify_rsp(sender, receiver, gift_type, gift_count, sender_name, receiver_total_devote, gift_source, is_pay_uc, battle_id)
  log(bWriteLog and "send_gift_notify_rsp:" .. tostring(sender) .. ",receiver:" .. tostring(receiver) .. ",gift_type:" .. tostring(gift_type) .. ",gift_count:" .. tostring(gift_count) .. ",sender_name:" .. tostring(sender_name) .. ",is_pay_uc:" .. tostring(is_pay_uc))
  log(bWriteLog and "logic_send_gift.send_gift_notify_rsp battle_id = " .. tostring(battle_id))
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  local data = RoleInfoPopularitySystem.PopularitySimpleCache[tostring(receiver)]
  if data and receiver_total_devote then
    local prev_popularity = data.total_devote
    data.total_devote = receiver_total_devote
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_SIMPLE_RSP, receiver, data)
    RoleInfoPopularitySystem.update_self_popularity(receiver, prev_popularity)
  end
  if tostring(DataMgr.roleData.uid) == tostring(receiver) then
    local ChatGiftNotifySystem = require("client.slua.logic.lobby_chat.logic_chat_gift_notify")
    ChatGiftNotifySystem.AddAni({
      sender = sender,
      receiver = receiver,
      gift_type = gift_type,
      gift_count = gift_count,
          })
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    if MatchModeMgrSystem.IsSocialIslandMode(true) then
      local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
      local tMsgData = {
        sSenderName = sender_name,
        nGiftType = gift_type,
        nGiftCount = gift_count,
        bIsSelfReceiver = true,
        msgType = chat_macro.SocialIslandBroadcastMsgType_Present
      }
      local logic_island_broadcast = require("GameLua.Mod.SocialIsland.Client.IslandBroadcast")
      logic_island_broadcast:AddBroadcastMsg(tMsgData)
    end
  end
  if tonumber(receiver) == tonumber(DataMgr.roleData.uid) and GameStatus.IsInMainCity() then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.MainCity_MainCity_GetGift)
  end
  RoleInfoPopularitySystem.IsShowUCGiftReddot = RoleInfoPopularitySystem.IsShowUCGiftReddot or is_pay_uc
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_SEND_GIFT_NOTIFY_RSP, receiver, gift_type, sender, gift_count, gift_source, is_pay_uc, sender_name, battle_id)
end
function logic_send_gift.get_pop_gift_record_req(uid)
  log(bWriteLog and "[logic_send_gift] get_pop_gift_record_req" .. tostring(uid))
  if not uid then
    return
  end
  logic_send_gift.ClearGiftRecord()
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_get_pop_gift_record_req(tonumber(uid))
end
function logic_send_gift.get_pop_gift_record_rsp(err_code, gift_record, uid, gift_record_summary, pspace_collect)
  log(bWriteLog and "[logic_send_gift] get_pop_gift_record_rsp: " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  logic_send_gift.CurRecordUID = uid
  logic_send_gift.gift_record = gift_record or {}
  log_tree("logic_send_gift.get_pop_gift_record_rsp gift_record = ", gift_record)
  log_tree("logic_send_gift.get_pop_gift_record_rsp gift_record_summary = ", gift_record_summary)
  log_tree("logic_send_gift.get_pop_gift_record_rsp pspace_collect = ", pspace_collect)
  if gift_record_summary and pspace_collect then
    logic_send_gift.ParseGiftRecordSummary(gift_record_summary, pspace_collect)
  end
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_GIFT_RECORD_RSP, uid)
end
function logic_send_gift.ReqTitleProfile()
  local uidList = {}
  for k, v in pairs(logic_send_gift.gift_record_summary) do
    if v.provide_uid then
      table.insert(uidList, v.provide_uid)
    end
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(uidList, nil, Enum_PROFILE_REPORT_CFG.POP_DEVOTE)
end
function logic_send_gift.pspace_gift_config_req()
  log(bWriteLog and "[logic_send_gift] pspace_gift_config_req")
  if logic_send_gift.gift_config then
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_PSPACE_GIFT_CONFIG_RSP)
  else
    local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
    PopularityGiftHandler.send_pspace_gift_config_req()
  end
end
function logic_send_gift.pspace_gift_config_rsp(err_code, gift_config, gift_region_config)
  log(bWriteLog and "[logic_send_gift] pspace_gift_config_rsp: " .. tostring(err_code))
  log_tree("pspace_gift_config_rsp", {gift_config = gift_config, gift_region_config = gift_region_config})
  if err_code ~= NetErrorCode_NONE then
    ShowNotice(err_code)
    return
  end
  logic_send_gift.  logic_send_gift.  logic_send_gift.GetAllGiftsConfig(true)
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_PSPACE_GIFT_CONFIG_RSP)
end
function logic_send_gift.on_pspace_send_gift_limit_rsp(gift_type, gift_count, tip_text_id, params)
  log(bWriteLog and "logic_send_gift.on_pspace_send_gift_limit_rsp gift_type = " .. gift_type)
  local tipsContent = ""
  if params and next(params) then
    local paramsNum = #params
    if paramsNum == 1 then
      tipsContent = LocUtil.LocalizeResFormat(tip_text_id, params[1])
    elseif paramsNum == 2 then
      tipsContent = LocUtil.LocalizeResFormat(tip_text_id, params[1], params[2])
    elseif paramsNum == 3 then
      tipsContent = LocUtil.LocalizeResFormat(tip_text_id, params[1], params[2], params[3])
    end
  else
    tipsContent = LocUtil.GetLocalizeResStr(tip_text_id)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), tipsContent)
end
function logic_send_gift.ClearGiftRecord()
  logic_send_gift.CurRecordUID = 0
  logic_send_gift.gift_record = {}
end
function logic_send_gift.ClearUpvoteGiftRecord(uid)
  if BattleResultUI and BattleResultUI.AlreadyUpvotedUID and logic_send_gift.gift_record[11] then
    if not BattleResultUI.AlreadyUpvotedUID[tostring(uid)] then
      logic_send_gift.gift_record[11].count = 0
    elseif logic_send_gift.gift_record[11].count > 0 then
      logic_send_gift.gift_record[11].count = 1
    end
  end
end
function logic_send_gift.ClearLastGiftInfo()
  log(bWriteLog and "logic_send_gift.ClearLastGiftInfo")
  logic_send_gift.lastGiftInRoleInfoPopularity = {}
end
function logic_send_gift.ParseGiftRecordSummary(gift_record_summary, pspace_collect)
  logic_send_gift.gift_record_summary = gift_record_summary or {}
  for k, v in pairs(logic_send_gift.gift_record_summary) do
    if pspace_collect and pspace_collect[k] and pspace_collect[k].provide_uid then
      v.provide_uid = pspace_collect[k].provide_uid
    end
  end
end
function logic_send_gift.SetLastGiftInfo(giftInfo)
  logic_send_gift.lastGiftInRoleInfoPopularity = {
    uid = giftInfo.uid,
    gift_type = giftInfo.gift_type,
    gift_count = giftInfo.gift_count
  }
end
function logic_send_gift.GetLastGiftInfo()
  return logic_send_gift.lastGiftInRoleInfoPopularity
end
function logic_send_gift.GetHasSendGiftCount(GiftId, receiver_uid)
  if GiftId == gift_const.UpvoteGiftId then
    if BattleResultUI.AlreadyUpvotedUID and BattleResultUI.AlreadyUpvotedUID[tostring(receiver_uid)] then
      return 1
    else
      return 0
    end
  end
  local devote_info = logic_send_gift.gift_record[GiftId]
  local devoteCount = 0
  if devote_info then
    devoteCount = devote_info.count
  end
  return devoteCount
end
function logic_send_gift.GetMaxSendGiftCount(GiftId)
  if GiftId == gift_const.UpvoteGiftId then
    return 1
  end
  local GiftInfo = logic_send_gift.GetGiftData(GiftId)
  if not GiftInfo then
    return 0
  end
  return GiftInfo.MaxDevote
end
function logic_send_gift.GetRemainCount(GiftId, receiver_uid)
  local maxCount = math.max(logic_send_gift.GetMaxSendGiftCount(GiftId) - logic_send_gift.GetHasSendGiftCount(GiftId, receiver_uid), 0)
  return math.min(maxCount, gift_const.MaxSingleSendCount)
end
function logic_send_gift.CheckCanDevote(giftType, receiver_uid)
  log(bWriteLog and "[logic_send_gift] CheckCanDevote:" .. tostring(giftType))
  if tonumber(receiver_uid) == tonumber(DataMgr.roleData.uid) then
    log(bWriteLog and "[logic_send_gift] CheckCanDevote:IsSelf")
    return false
  end
  local GiftInfo = logic_send_gift.GetGiftData(giftType)
  if not GiftInfo then
    log(bWriteLog and "[logic_send_gift] CheckCanDevote giftID:" .. tostring(giftType) .. " no GiftInfo")
    return false
  end
  local devote_info = logic_send_gift.gift_record[giftType]
  if devote_info then
    log(bWriteLog and "[logic_send_gift] CheckCanDevote:" .. tostring(devote_info.count) .. ",MaxDevote:" .. tostring(GiftInfo.MaxDevote))
    return devote_info.count < GiftInfo.MaxDevote
  end
  return true
end
function logic_send_gift.Handle_LogOut()
  logic_send_gift.gift_config = nil
  logic_send_gift.CacheAllGiftsTable = nil
end
function logic_send_gift.TrySendGiftHorn(giftId)
  if logic_send_gift.useRadio then
    if logic_send_gift.bIsHornFree then
      logic_send_gift.SendFreeHorn(logic_send_gift.chatContent, "world_Channel")
    else
      local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
      logic_chat_channel_world.SendHornMsgByTopic(logic_send_gift.chatContent, "world_Channel")
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.HornConsume, nil, tostring(giftId))
    end
  end
  logic_send_gift.useRadio = false
  logic_send_gift.chatContent = ""
  logic_send_gift.bIsHornFree = false
end
function logic_send_gift.SendFreeHorn(content, topic)
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  local bHasRightToChat = logic_chat_channel_world.CheckHasRightToChat()
  if not bHasRightToChat then
    log(bWriteLog and "logic_send_gift.SendFreeHorn has no right to chat")
    return
  end
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local TimeUtil = require("client.common.time_util")
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  local msg = {}
  msg.text = content
  msg.  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.giftFreeHornMsgType
  local msgId = chat_main.CacheMsg(msg)
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelWorld, msgId, msg)
end
function logic_send_gift.PlayGiftAni(giftType, giftCount, widget, offsetX, offsetY, zOrder, extendedParams)
  log(bWriteLog and "PlayGiftAni:" .. tostring(giftType))
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_PLAY_ANIMATION)
  local GiftInfo = logic_send_gift.GetGiftData(giftType)
  if not GiftInfo then
    return false
  end
  local logic_gift_download = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_gift_download)
  if not logic_gift_download:IsGiftResourceDownloaded(giftType) then
    log(bWriteLog and "logic_send_gift.PlayGiftAni not downloaded, giftType = " .. tostring(giftType))
    return false
  end
  local gift_ani_ui = UIManager.ShowUIWithBpPath(UIManager.UI_Config.roleinfo_send_gift_ani, GiftInfo.GiftAni, function(AniUI)
    AniUI:Close()
  end, extendedParams)
  gift_ani_ui:SetTips(widget, offsetX, offsetY)
  gift_ani_ui:SetAutoSize(true)
  gift_ani_ui:PlayGiftAnimation()
  return true
end
function logic_send_gift.GetGiftAnimPath(gift_type, gift_count)
  local GiftInfo = logic_send_gift.GetGiftData(gift_type)
  if not GiftInfo then
    log(bWriteLog and "logic_send_gift.GetGiftAnimUI: invalid gift info with type" .. tostring(gift_type))
    return
  end
  local path = logic_send_gift.GetGiftAniByCount(GiftInfo, gift_count)
  return path
end
function logic_send_gift.GetGiftData(giftId)
  local config = logic_send_gift.GetAllGiftsConfig()
  if not config[giftId] then
    log(bWriteLog and "logic_send_gift.GetGiftData giftId:" .. tostring(giftId) .. " no GiftData")
  end
  return config[giftId]
end
function logic_send_gift.GetGiftDataByResID(resID)
  log(bWriteLog and string.format("logic_send_gift.GetGiftDataByResID, resID:%s", resID))
  local config = logic_send_gift.GetAllGiftsConfig()
  for k, v in pairs(config) do
    if v.ItemID == resID then
      return v
    end
  end
  return nil
end
function logic_send_gift.GetAllGiftsConfig(bForceRefresh)
  if not bForceRefresh and logic_send_gift.CacheAllGiftsTable ~= nil then
    return logic_send_gift.CacheAllGiftsTable
  end
  local StringUtil = require("common.string_util")
  local CacheGiftsTable = {}
  local giftTable = CDataTable.GetTable("PopularityGift")
  for i, v in pairs(giftTable) do
    local config = logic_send_gift.gift_config and logic_send_gift.gift_config[v.GiftId] or {}
    local tb = {}
    tb.GiftId = v.GiftId
    tb.ItemName = v.ItemName
    tb.GiftType = v.GiftType
    tb.HornConfig = v.HornConfig
    tb.EnableFollow = v.EnableFollow
    tb.EnableFriend = v.EnableFriend
    tb.EffectIDs = v.EffectIDs
    tb.NoticeParam = v.NoticeParam
    tb.PriceType = config.price_type or v.PriceType
    tb.Price = config.price or v.Price
    tb.popularity = config.popularity or v.popularity
    tb.ManorVote = config.manor_vote_num or v.ManorVote
    tb.MaxDevote = config.max_devote or v.MaxDevote
    tb.BuySource = config.purchase_channel or v.BuySource
    tb.BuySourceDesc = config.channel_desc or v.BuySourceDesc
    tb.ItemID = config.item_id or v.ItemID
    tb.GiftOrder = config.show_seq or v.GiftOrder
    tb.ExclusiveAccess = config.exclusive_access_channel or v.ExclusiveAccess
    tb.Intimacy = config.intimacy or v.Intimacy
    tb.CanMessage = config.is_msg or v.CanMessage
    tb.JumpModule = ""
    tb.GiftIcon = v.GiftIcon
    tb.GiftAni = v.GiftAni
    tb.GiftAni2 = v.GiftAni2
    tb.GiftAni3 = v.GiftAni3
    tb.devote_cond = config.devote_cond or logic_send_gift.ConvertDevoteCond(v.DevoteCond)
    tb.LimitItemIDs = StringUtil.Split(config.time_limit_item_ids or v.LimitItemIDs, ";")
    tb.Appid = config.client_app_id or v.Appid
    tb.EnableExchange = v.EnableExchange
    CacheGiftsTable[v.GiftId] = tb
    tb.CreativeScore = config.CreativeScore or v.CreativeScore
    tb.EnableVirtualPK = v.EnableVirtualPK
  end
  logic_send_gift.CacheAllGiftsTable = CacheGiftsTable
  return CacheGiftsTable
end
function logic_send_gift.HasGiftTableCache()
  return logic_send_gift.CacheAllGiftsTable ~= nil
end
function logic_send_gift.ConvertDevoteCond(DevoteCond)
  if not DevoteCond or DevoteCond == "" then
    return
  end
  local StringUtil = require("common.string_util")
  local devote_cond = {
    conds = {}
  }
  if string.find(DevoteCond, "|") then
    devote_cond.logic_type = 2
    local conds = StringUtil.Split(DevoteCond, "|")
    for i = 1, #conds do
      local con = conds[i]
      local conTb = StringUtil.Split(con, ":")
      table.insert(devote_cond.conds, {
        cond_type = tonumber(conTb[1]),
        param = tonumber(conTb[2])
      })
    end
  elseif string.find(DevoteCond, "&") then
    devote_cond.logic_type = 1
    local conds = StringUtil.Split(DevoteCond, "&")
    for i = 1, #conds do
      local con = conds[i]
      local conTb = StringUtil.Split(con, ":")
      table.insert(devote_cond.conds, {
        cond_type = tonumber(conTb[1]),
        param = tonumber(conTb[2])
      })
    end
  else
    devote_cond.logic_type = 1
    local conTb = StringUtil.Split(DevoteCond, ":")
    table.insert(devote_cond.conds, {
      cond_type = tonumber(conTb[1]),
      param = tonumber(conTb[2])
    })
  end
  return devote_cond
end
function logic_send_gift.IsGiftNew(giftId)
  local GiftData = logic_send_gift.GetGiftData(giftId)
  if not GiftData then
    return false
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = WardrobeData:GetHallDepotItemDataByResID(GiftData.ItemID)
  if itemData and itemData.isNew then
    return true
  end
  for _, itemId in ipairs(GiftData.LimitItemIDs) do
    local limitItemData = WardrobeData:GetHallDepotItemDataByResIDAndValidExpireTime(tonumber(itemId))
    if limitItemData and limitItemData.isNew then
      return true
    end
  end
  return false
end
function logic_send_gift.ClearGiftNew(giftId)
  local GiftData = logic_send_gift.GetGiftData(giftId)
  if not GiftData then
    return false
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = WardrobeData:GetHallDepotItemDataByResID(GiftData.ItemID)
  if itemData then
    local WardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    WardrobeLogic:wardrobe_change_item_new_status(itemData.insID)
  end
  for _, itemId in ipairs(GiftData.LimitItemIDs) do
    local limitItemData = WardrobeData:GetHallDepotItemDataByResIDAndValidExpireTime(tonumber(itemId))
    if limitItemData then
      local WardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      WardrobeLogic:wardrobe_change_item_new_status(limitItemData.insID)
    end
  end
end
function logic_send_gift.ClearAllGiftNew()
  for giftId, _ in pairs(logic_send_gift.GetAllGiftsConfig()) do
    logic_send_gift.ClearGiftNew(giftId)
  end
end
function logic_send_gift.GetGiftAniByCount(giftInfo, giftCount)
  giftCount = giftCount or 1
  if giftCount < 100 then
    return giftInfo.GiftAni
  elseif 100 <= giftCount and giftCount <= 999 then
    return giftInfo.GiftAni2 == "" and giftInfo.GiftAni or giftInfo.GiftAni2
  else
    return giftInfo.GiftAni3 == "" and giftInfo.GiftAni or giftInfo.GiftAni3
  end
end
function logic_send_gift.ShowCondTips(devote_cond)
  local CondTips = {
    [1] = {
      id = 13661,
      handle = function(cond)
        return math.floor(cond.param / 60)
      end
    },
    [2] = {
      id = 13662,
      handle = function(cond)
        return cond.param
      end
    },
    [3] = {
      id = 13663,
      handle = function(cond)
        local Segment = FuncUtil.GetRankTableData(cond.param)
        return Segment and Segment.Name or ""
      end
    },
    [4] = {
      id = 13664,
      handle = function(cond)
        return math.floor(cond.param / 3600)
      end
    },
    [5] = {
      id = 45933,
      handle = function(cond)
        return cond.param
      end
    },
    [12] = {
      id = 1050056,
      handle = function(cond)
        return cond.param
      end
    }
  }
  local tipsTb = {}
  for index, cond in ipairs(devote_cond.conds) do
    local tips = CondTips[cond.cond_type]
    tipsTb[index] = LocUtil.LocalizeResFormat(tips.id, tips.handle(cond))
  end
  local tipsContent = ""
  if #tipsTb == 1 then
    tipsContent = LocUtil.LocalizeResFormat(13665, tipsTb[1])
  elseif #tipsTb == 2 then
    if devote_cond.logic_type == 1 then
      tipsContent = LocUtil.LocalizeResFormat(13703, tipsTb[1], tipsTb[2])
    else
      tipsContent = LocUtil.LocalizeResFormat(13702, tipsTb[1], tipsTb[2])
    end
  elseif devote_cond.logic_type == 1 then
    tipsContent = LocUtil.LocalizeResFormat(1050070, tipsTb[1], tipsTb[2], tipsTb[3])
  else
    tipsContent = LocUtil.LocalizeResFormat(45932, tipsTb[1], tipsTb[2], tipsTb[3])
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, DataMgr.GetMsgByID(101001), tipsContent)
end
function logic_send_gift.GetGiftsConfig()
  local bBattleResults = not GameStatus.IsInLobbyOrMainCity()
  local CacheGiftsTable = {}
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local bIsPlanPHMode = logic_home_entry:IsPlanPHMode()
  local bIsPlanCHMode = GameStatus.IsCollectionHallMode()
  local nNeedHideGiftId = 667
  if UnknowPassSystem and UnknowPassSystem.Season >= 59 and UnknowPassSystem.PassType == 2 then
    log(bWriteLog and "logic_send_gift.GetGiftsConfig need hide normal giftId  ")
    nNeedHideGiftId = 11
  end
  for giftId, config in pairs(logic_send_gift.GetAllGiftsConfig()) do
    if config.GiftId ~= nNeedHideGiftId then
      if config.GiftId == 11 or config.GiftId == 667 then
        config.MaxDevote = 1
      end
      local modeSystem = require("client.slua.logic.match.logic_mode_mgr")
      if bBattleResults and not modeSystem.IsSocialIslandMode() and not modeSystem.IsInPlanZMode() and not bIsPlanPHMode and not bIsPlanCHMode then
        if config.ExclusiveAccess == 0 or config.ExclusiveAccess == 1 then
          CacheGiftsTable[config.GiftId] = config
        end
      elseif config.ExclusiveAccess == 0 then
        CacheGiftsTable[config.GiftId] = config
      end
    end
  end
  return CacheGiftsTable
end
function logic_send_gift.GetSendGifts(forbidMap)
  local giftTable = logic_send_gift.GetGiftsConfig()
  if giftTable == nil then
    return {}
  end
  if logic_send_gift.gift_region_config == nil then
    return {}
  end
  local gift_region_config_map = {}
  for key, value in pairs(logic_send_gift.gift_region_config) do
    if value.gift_id then
      gift_region_config_map[value.gift_id] = value
    end
  end
  local gameId = Client.GetITopGameId()
  local forbidGiftMap = forbidMap or {}
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  log(bWriteLog and "GetSendGifts:" .. tostring(login_module.sIpRegion) .. ",gameId:" .. tostring(gameId))
  local gifts = {}
  for i, v in pairs(giftTable) do
    local isAppValid = false
    if v.Appid == "" then
      isAppValid = true
    else
      local StringUtil = require("common.string_util")
      local gameIds = StringUtil.Split(v.Appid, ";")
      for _, v in pairs(gameIds) do
        if v == gameId then
          isAppValid = true
        end
      end
    end
    if isAppValid and not forbidGiftMap[v.GiftId] then
      if v.BuySource ~= 0 then
        local Count = logic_send_gift.GetHallDepotGiftCount(v.GiftId)
        if 0 < Count then
          table.insert(gifts, v)
        else
          local config = gift_region_config_map[v.GiftId]
          if config then
            local TimeUtil = require("client.common.time_util")
            local isTimeValid = config.valid_beg_time <= FuncUtil.GetServerTimeInSec() and config.valid_end_time >= TimeUtil.GetServerTimeInSec()
            local isRegionValid = config.valid_region == "" or string.find(config.valid_region, login_module.sIpRegion)
            if isTimeValid and isRegionValid then
              v.JumpModule = config.module_link or ""
              table.insert(gifts, v)
            end
          end
        end
      else
        table.insert(gifts, v)
      end
    end
  end
  table.sort(gifts, function(gift1, gift2)
    return gift1.GiftOrder < gift2.GiftOrder
  end)
  return gifts
end
function logic_send_gift.CanShowGiftGuide()
  local HaveNewbieGuide = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PSPACE_GIFT, 1)
  return DataMgr.roleData.level <= gift_const.MaxGiftGuideLevel and HaveNewbieGuide
end
function logic_send_gift.GetSortedGiftList()
  local sortedTable = {}
  for k, v in ipairs(logic_send_gift.GiftRecordSummaryRegular) do
    if not v.GiftInfo then
      log(bWriteLog and "logic_send_gift.GetSortedGiftList v.GiftInfo = nil")
      break
    end
    if v.GiftInfo.GiftType >= 1 and v.GiftInfo.GiftType <= 3 then
      table.insert(sortedTable, v)
    end
  end
  if next(sortedTable) ~= nil then
    table.sort(sortedTable, function(a, b)
      if a.TotalCount == b.TotalCount then
        return a.GiftOrder < b.GiftOrder
      end
      return a.TotalCount > b.TotalCount
    end)
  end
  return sortedTable
end
function logic_send_gift.GetGiftEffectParam(giftID, count, type)
  local giftInfo = CDataTable.GetTableData("PopularityGift", giftID)
  if not giftInfo then
    log(bWriteLog and "logic_send_gift.GetGiftEffectParam giftID:" .. tostring(giftID) .. " no giftInfo")
    return
  end
  local effectConfigs = giftInfo.EffectIDs
  if effectConfigs == "" then
    log(bWriteLog and "logic_send_gift.GetGiftEffectParam giftID:" .. tostring(giftID) .. " no effect")
    return
  end
  local StringUtil = require("common.string_util")
  local effectIDList, effectParam
  local effectIDConfigList = StringUtil.Split(effectConfigs, ";")
  local GiftEffectConfig = CDataTable.GetTableByFilter("GiftEffectConfig", "EffectType", type)
  for _, v in ipairs(effectIDConfigList) do
    if v == "" then
      break
    end
    local info = StringUtil.Split(v, ":")
    if count >= tonumber(info[1]) then
      effectIDList = StringUtil.Split(info[2], "|")
      for k, config in pairs(GiftEffectConfig) do
        for j, id in ipairs(effectIDList) do
          if config.EffectID == tonumber(id) then
            effectParam = config.Param1
            break
          end
        end
      end
    end
  end
  return effectParam
end
function logic_send_gift.GetHallDepotGiftCount(GiftId)
  local GiftData = logic_send_gift.GetGiftData(GiftId)
  if not GiftData then
    return 0, 0
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local PermanentCount = 0
  if GiftData.ItemID ~= 0 then
    PermanentCount = wardrobe_data:GetHallDepotItemCountByResID(GiftData.ItemID, true)
  end
  local LimitItemCount = 0
  for _, itemId in ipairs(GiftData.LimitItemIDs) do
    LimitItemCount = LimitItemCount + wardrobe_data:GetHallDepotItemCountByResID(tonumber(itemId), true)
  end
  local count = 0
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  local bHomeMod = PlanPH_GamePlay_Tools.IsPHomeMode()
  log(bWriteLog and "logic_send_gift.GetHallDepotGiftCount bHomeMod = " .. tostring(bHomeMod))
  if bHomeMod then
    local LogicHomeParty = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicHomeParty)
    local party_unused_items = LogicHomeParty:GetCurrPartyGiftUnUsedItems() or {}
    count = party_unused_items[GiftData.ItemID] or 0
    log(bWriteLog and "logic_send_gift.GetHallDepotGiftCount count = " .. tostring(count))
  end
  return PermanentCount + LimitItemCount + count, LimitItemCount
end
function logic_send_gift.GetHallDepotGiftLimitTime(GiftId)
  local GiftData = logic_send_gift.GetGiftData(GiftId)
  if not GiftData then
    return 0
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local nearTime = 0
  for _, itemId in ipairs(GiftData.LimitItemIDs) do
    local val = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(tonumber(itemId))
    if val and nearTime < val.expireTS then
      nearTime = val.expireTS
    end
  end
  return nearTime
end
function logic_send_gift.PlayPopularityGiftAnim(bShowManorVote)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  UIManager.ShowUI(UIManager.UI_Config.roleinfo_send_gift_ani_ex, {
    AddDevote = RoleInfoPopularitySystem.AddDevote,
    GiftCount = RoleInfoPopularitySystem.GiftCount,
    GiftType = RoleInfoPopularitySystem.GiftType,
      })
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_PLAY_ANIMATION)
end
function logic_send_gift.GetLimitTime(giftID)
  local GiftData = logic_send_gift.GetGiftData(giftID)
  if not GiftData then
    return -1
  end
  local TimeUtil = require("client.common.time_util")
  if logic_send_gift.giftEndTimeMap and logic_send_gift.giftEndTimeMap[giftID] then
    local endTime = logic_send_gift.giftEndTimeMap[giftID]
    log(bWriteLog and "logic_send_gift.GetLimitTime ID = " .. tostring(giftID) .. " endTime = " .. tostring(endTime))
    return TimeUtil.GetDeltaTimeWithCurTime(endTime)
  end
  local itemData = CDataTable.GetTableData("Item", GiftData.ItemID)
  if not itemData then
    log(bWriteLog and "logic_send_gift.GetLimitTime not config")
    return -1
  end
  local timeStr = itemData.ExTime
  if timeStr == "" then
    log(bWriteLog and "logic_send_gift.GetLimitTime not time limit gift")
    return -1
  end
  local endTime = TimeUtil.TimeStringToUnixstamp(timeStr, false)
  if not logic_send_gift.giftEndTimeMap then
    logic_send_gift.giftEndTimeMap = {}
  end
  logic_send_gift.giftEndTimeMap[giftID] = endTime
  log(bWriteLog and "logic_send_gift.GetLimitTime ID = " .. tostring(giftID) .. " endTime = " .. tostring(endTime))
  return TimeUtil.GetDeltaTimeWithCurTime(endTime)
end
function logic_send_gift.IsUcGift(giftID)
  local config = logic_send_gift.GetGiftData(giftID)
  if config and config.PriceType == 2 then
    return true
  end
  return false
end
function logic_send_gift:send_query_quick_gift_friends_req()
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_query_quick_gift_friends_req()
end
function logic_send_gift:proc_query_quick_gift_friends_rsp(errcode, friend_list, gift_record_count, daily_max_count)
  log(bWriteLog and "logic_send_gift:proc_query_quick_gift_friends_rsp: errcode =" .. tostring(errcode))
  if errcode ~= 0 then
    log(bWriteLog and "logic_send_gift:proc_query_quick_gift_friends_rsp: failed")
    return
  end
  logic_send_gift.query_quick_friends_list = friend_list or {}
  if daily_max_count and gift_record_count and logic_send_gift.gift_left then
    logic_send_gift.gift_left = daily_max_count - gift_record_count
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_FRIEND_QUERY_QUiCK_GIFT_DATA)
end
function logic_send_gift:send_friends_quick_gift_req(send_list, gift_source)
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_friends_quick_gift_req(send_list, gift_source)
end
function logic_send_gift:proc_friends_quick_gift_rsp(errcode, send_list, friend_list, gift_record_count, daily_max_count)
  log(bWriteLog and "logic_send_gift:proc_friends_quick_gift_rsp: errcode =" .. tostring(errcode))
  log_tree("send_list:", send_list)
  log_tree("friend_list:", friend_list)
  if errcode ~= 0 then
    log(bWriteLog and "logic_send_gift:proc_friends_quick_gift_rsp: failed")
    return
  end
  if friend_list then
    logic_send_gift.query_quick_friends_list = friend_list
  end
  if daily_max_count and gift_record_count and logic_send_gift.gift_left then
    logic_send_gift.gift_left = daily_max_count - gift_record_count
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_FRIEND_GIFT_SEND_SUCESSFUL)
end
function logic_send_gift:on_send_upvote_notify_rsp(sender, reciver, gift_type, name, gift_source, battle_id, upvote_cnt)
  logic_send_gift.daily_end
function logic_send_gift:GetQueryQuickFriends()
  return logic_send_gift.query_quick_friends_list
end
function logic_send_gift:GetGiftLeft()
  return logic_send_gift.gift_left
end
return logic_send_gift