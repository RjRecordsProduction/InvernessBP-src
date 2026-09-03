local AuthorityFlag = {
  allfri_bit_shift = 0,
  gayfri_bit_shift = 1,
  lovers_bit_shift = 2,
  buddies_bit_shift = 3,
  bestfri_bit_shift = 4,
  self_bit_shift = 5
}
local AuthorityInfo = {
  OnlyFriend = 1,
  OnlySelf = 2,
  Public = 3
}
local logic_moment = {exceed_the_limit = false, storeTabID = nil}
local ClearData = function()
  local data = require("client.slua.logic.moment.logic_moment_data")
  data.set_my_moment_info(nil)
  data.set_fri_recent_moment_info(nil)
  data.set_moment_remind_info(nil)
  data.set_hot_moment_info(nil)
  data.set_square_moment_info(nil)
  data.clear_all_moments_info(nil)
  data.clear_other_moment_info()
  local logic_square_moment = require("client.slua.logic.moment.logic_square_moment")
  logic_square_moment.clear()
  logic_moment.exceed_the_limit = false
end
function logic_moment.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "logic_moment OnModePostSwitch nextState:" .. tostring(nextState))
  if nextState == GameStatus.Login or nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    ClearData()
  elseif GameStatus.IsInLobbyOrMainCity() then
    logic_moment.SetBattleShowMomentShareFlag(true)
  end
end
function logic_moment.SortMomentByStamp(moment_ids)
  local arr = {}
  for moment_id, timestamp in pairs(moment_ids) do
    arr[#arr + 1] = {moment_id = moment_id, timestamp = timestamp}
  end
  table.sort(arr, function(a, b)
    return a.timestamp > b.timestamp
  end)
  local retList = {}
  for i, v in ipairs(arr) do
    retList[#retList + 1] = v.moment_id
  end
  return retList
end
local profile_timer
local uidList = {}
local ref = 0
function logic_moment.AddProfileReq(uid)
  uidList[#uidList + 1] = uid
end
function logic_moment.ReleaseProfileReqTimer()
  ref = ref - 1
  if ref == 0 then
    logic_moment.DoProfileReq()
    if profile_timer then
      local time_ticker = require("common.time_ticker")
      time_ticker.RemoveTimer(profile_timer)
      profile_timer = nil
    end
  end
end
function logic_moment.BeginProfileReqTimer()
  if ref == 0 then
    local time_ticker = require("common.time_ticker")
    profile_timer = time_ticker.AddTimerLoop(0, function()
      logic_moment.DoProfileReq()
    end, TIMER_INFINITE, 1)
  end
  ref = ref + 1
end
function logic_moment.DoProfileReq()
  if 0 < #uidList then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(uidList, function(list)
      if 0 < #list then
        EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_PROFILE_FINISH)
      end
    end, Enum_PROFILE_REPORT_CFG.MOMENT)
  end
  uidList = {}
end
function logic_moment.DoFavorReq(bFavor, moment_id, owner_uid)
  if not logic_moment.IsCanOperateMoment(owner_uid, moment_id) then
    return
  end
  if type(bFavor) == "number" then
    bFavor = bFavor == 1
  end
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  local _sourceType = logic_moment.GetSourceType()
  if bFavor == false then
    logic_moment_proto.send_do_moment_like_req(moment_id, owner_uid, _sourceType)
    logic_moment.CheckAndSendSeasonLookBackTlog(moment_id)
  elseif bFavor == true then
    logic_moment_proto.send_do_moment_unlike_req(moment_id, owner_uid, _sourceType)
  end
  log(bWriteLog and "[v_ywuyuan] bFavor " .. tostring(bFavor) .. " moment_id " .. tostring(moment_id) .. " owner_uid " .. tostring(owner_uid) .. " req_source " .. tostring(_sourceType))
end
function logic_moment.DoEmojiFavorReq(bFavor, moment_id, owner_uid, emoji_id)
  if not logic_moment.IsCanOperateMoment(owner_uid, moment_id) then
    return
  end
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  local _sourceType = logic_moment.GetSourceType()
  if bFavor then
    logic_moment_proto.send_do_moment_emoji_like_req(moment_id, owner_uid, emoji_id, _sourceType)
  else
    logic_moment_proto.send_do_moment_emoji_unlike_req(moment_id, owner_uid, _sourceType)
  end
  log(bWriteLog and "[v_wllwu] logic_moment.DoEmojiFavorReq, bFavor " .. tostring(bFavor) .. " moment_id " .. tostring(moment_id) .. " owner_uid " .. tostring(owner_uid) .. " req_source " .. tostring(_sourceType) .. " emoji_id " .. tostring(emoji_id))
end
function logic_moment.ShowReplyPopUI(moment_id, owner_uid, reply_id, mention_uid)
  if not logic_moment.IsCanOperateMoment(owner_uid, moment_id) then
    return
  end
  if mention_uid and not logic_moment.IsCanOperateMoment(mention_uid, moment_id) then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.MomentReply, moment_id, owner_uid, reply_id, mention_uid)
end
function logic_moment.ShowDetailUI(moment_id, owner_id, reply_id, sub_index_id)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local moment_data = logic_moment_data.get_moment_info(moment_id)
  if moment_data and moment_data.sync_square and moment_data.sync_square == 1 or moment_data.is_wow_moment then
    log(bWriteLog and "[v_ywuyuan] square moment can operate without friendship")
  elseif not logic_moment.IsFriendOrMySelf(owner_id) then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.MomentDetail, moment_id, reply_id, sub_index_id)
end
function logic_moment.IsMySelf(uid)
  if uid ~= nil and tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    return true
  end
  return false
end
function logic_moment.IsFriendOrMySelf(uid)
  if uid ~= nil then
    if logic_moment.IsMySelf(uid) then
      return true
    else
      local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
      return LogicFriend.IsMyFriend(uid)
    end
  end
  return false
end
function logic_moment.GetAuthorityInfo(authority)
  local info = {}
  if authority == 0 then
    info.Public = true
  elseif authority & 1 << AuthorityFlag.allfri_bit_shift ~= 0 then
    info.AllFriend = true
  elseif authority & 1 << AuthorityFlag.self_bit_shift ~= 0 then
    info.OnlySelf = true
  else
    if authority & 1 << AuthorityFlag.gayfri_bit_shift ~= 0 then
      info.GayFri = true
    end
    if authority & 1 << AuthorityFlag.lovers_bit_shift ~= 0 then
      info.Lovers = true
    end
    if authority & 1 << AuthorityFlag.buddies_bit_shift ~= 0 then
      info.Buddies = true
    end
    if authority & 1 << AuthorityFlag.bestfri_bit_shift ~= 0 then
      info.BestFri = true
    end
  end
  return info
end
function logic_moment.ConvertAuthorityInfo(info)
  local authority = 0
  if info.Public then
    authority = 0
  elseif info.OnlySelf then
    authority = 1 << AuthorityFlag.self_bit_shift
  elseif info.AllFriend then
    authority = 1 << AuthorityFlag.allfri_bit_shift
  else
    if info.GayFri then
      authority = authority | 1 << AuthorityFlag.gayfri_bit_shift
    end
    if info.Lovers then
      authority = authority | 1 << AuthorityFlag.lovers_bit_shift
    end
    if info.Buddies then
      authority = authority | 1 << AuthorityFlag.buddies_bit_shift
    end
    if info.BestFri then
      authority = authority | 1 << AuthorityFlag.bestfri_bit_shift
    end
  end
  return authority
end
function logic_moment.ConvertAuthorityInfos(authorityNumber)
  local authority = 0
  if authorityNumber == AuthorityInfo.Public then
    authority = 0
  elseif authorityNumber == AuthorityInfo.OnlySelf then
    authority = 1 << AuthorityFlag.self_bit_shift
  elseif authorityNumber == AuthorityInfo.OnlyFriend then
    authority = 1 << AuthorityFlag.allfri_bit_shift
  end
  return authority
end
function logic_moment.DeleteReadRemindInfo(deleted_index)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local message_info = logic_moment_data.get_moment_remind_info()
  if message_info then
    for i, index in ipairs(deleted_index) do
      message_info[index] = nil
    end
  end
  logic_moment_data.set_moment_remind_info(message_info)
end
function logic_moment.IsLoginGuest()
  if IsEditor then
    return false
  end
  local moment_cfg = require("client.slua.logic.moment.moment_cfg")
  if moment_cfg.bForceRemoveLimit then
    return false
  end
  local channel = Client.GetLoginChannel(NetInterface)
  return channel == BP_ENUM_PLAYFORM_TOURIST
end
function logic_moment.IsCanOpenSelfMoment(showTips)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_MOMENT_SWITCH, showTips) then
    return false
  end
  if logic_moment.IsLoginGuest() then
    if showTips then
      ShowNotice(104000026)
    end
    return false
  end
  local moment_cfg = require("client.slua.logic.moment.moment_cfg")
  if not moment_cfg.IsLevelLimitEnough(showTips) then
    return false
  end
  return true
end
function logic_moment.IsCanOperateMoment(uid, moment_id)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  if logic_profile:IsPlayerChatBanned(DataMgr.roleData.uid) then
    ShowNotice(104000024)
    return
  end
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    return true
  end
  local moment_cfg = require("client.slua.logic.moment.moment_cfg")
  if not moment_cfg.IsLevelLimitEnough(true) then
    return false
  end
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local moment_data = logic_moment_data.get_moment_info(moment_id)
  if moment_data and moment_data.sync_square and moment_data.sync_square == 1 or moment_data.is_wow_moment then
    log(bWriteLog and "[v_ywuyuan] square moment can operate without friendship")
  elseif not logic_moment.IsFriendOrMySelf(uid) then
    ShowNotice(18939)
    return
  end
  return true
end
function logic_moment.EnterMomentUI(uid)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local moment_cfg = require("client.slua.logic.moment.moment_cfg")
  local TimeUtil = require("client.common.time_util")
  if LobbySocialSystem.IsSelf(uid) and moment_cfg.moment_info.ban_time >= TimeUtil.GetServerTimeInSec() then
    log(bWriteLog and "moment_cfg.moment_info.ban_time:" .. tostring(moment_cfg.moment_info.ban_time))
    ShowNotice(18931)
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  if logic_profile:IsPlayerBanned(uid) then
    ShowNotice(18945)
    return
  end
  if logic_moment.IsMySelf(uid) then
    if not logic_moment.IsCanOpenSelfMoment(true) then
      return
    end
    local logic_moment_bubble_tips = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_moment_bubble_tips)
    logic_moment_bubble_tips:ClearRecordData()
    UIManager.ShowUI(UIManager.UI_Config.MomentMain, uid)
  else
    if logic_moment.IsLoginGuest() then
      ShowNotice(104000026)
      return
    end
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    if not LogicFriend.IsMyFriend(uid) then
      logic_moment.EnterStrangerMoment(uid)
      return
    end
    log(bWriteLog and "[v_ywuyuan] logic_moment.EnterMomentUI showUI")
    UIManager.ShowUI(UIManager.UI_Config.MomentOtherMain, uid)
  end
end
function logic_moment.EnterMomentSquareUI(uid)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local moment_cfg = require("client.slua.logic.moment.moment_cfg")
  local TimeUtil = require("client.common.time_util")
  if LobbySocialSystem.IsSelf(uid) and moment_cfg.moment_info.ban_time >= TimeUtil.GetServerTimeInSec() then
    log(bWriteLog and "moment_cfg.moment_info.ban_time:" .. tostring(moment_cfg.moment_info.ban_time))
    ShowNotice(18931)
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  if logic_profile:IsPlayerBanned(uid) then
    ShowNotice(18945)
    return
  end
  if logic_moment.IsMySelf(uid) then
    local logic_moment_bubble_tips = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_moment_bubble_tips)
    logic_moment_bubble_tips:ClearRecordData()
    UIManager.ShowUI(UIManager.UI_Config.MomentSquare, uid)
  end
end
function logic_moment.EnterSelfMomentUIFromMailHyperLink(_, __, params)
  local logic_moment_replay = require("client.slua.logic.moment.logic_moment_replay")
  if logic_moment_replay and params then
    logic_moment_replay.StoreTabID(tonumber(params.TabID))
    logic_moment_replay.StoreTabID2(tonumber(params.TabID2))
    logic_moment_replay.StoreMomentDataFromLogic()
  end
  if params and params.storeTabID then
    logic_moment.storeTabID = tonumber(params.storeTabID)
  end
  logic_moment.EnterSelfMomentUI()
end
function logic_moment.EnterSelfMomentUI()
  logic_moment.EnterMomentUI(DataMgr.roleData.uid)
end
function logic_moment.EnterStrangerMoment(uid)
  local func = function()
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    if logic_profile:IsPlayerBanned(uid) then
      ShowNotice(18945)
      return
    end
    UIManager.ShowUI(UIManager.UI_Config.MomentOtherMain, uid)
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local stranger_profile = logic_profile:GetLocalProfile(uid)
  if stranger_profile then
    func()
  else
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      tonumber(uid)
    }, function()
      func()
    end, Enum_PROFILE_REPORT_CFG.MOMENT)
  end
end
function logic_moment.GetMomentStoreTabID()
  return logic_moment.storeTabID
end
function logic_moment.ClearMomentStoreTabID()
  logic_moment.storeTabID = nil
end
function logic_moment.SendMomentReq(authority, pic_url, video_url, content, domain_id, source, sync_square, sync_club, otherinfo, background_id, client_trans, is_wow_moment, at_uids)
  local moment_info = {
    authority = authority,
    pic_url = pic_url,
    video_url = video_url,
    content = content,
    domain_id = domain_id,
    source = source,
    sync_square = sync_square,
    sync_club = sync_club,
    otherinfo = otherinfo,
    background_id = background_id,
    client_trans = client_trans,
    is_wow_moment = is_wow_moment,
      }
  log_tree("SendMomentReq", moment_info)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  logic_moment_proto.send_post_moment_req(moment_info)
end
function logic_moment.ShowComplaint(uid, name, content, moment_id, comment_id, reply_id, origin_pic, thumb_pic)
  local LogicComplaint = require("client.logic.battle.logic_complaint")
  local temp = {
    momentPar = {
      uid = uid,
      name = name,
      content = content,
      moment_id = moment_id,
      comment_id = comment_id,
      reply_id = reply_id,
      origin_pic = origin_pic,
          }
  }
  LogicComplaint.ShowComplaint(LogicComplaint.EComplaintFrom.Moment, temp)
end
local otherPersonUID
function logic_moment.SetShowOtherPersonUID(uid)
  otherPersonUID = uid
end
function logic_moment.GetShowOtherPersonUID()
  if otherPersonUID then
    return otherPersonUID
  end
  return 0
end
function logic_moment.EnterOtherMomentUI(uid)
  if tonumber(uid) ~= tonumber(DataMgr.roleData.uid) and logic_moment.GetShowOtherPersonUID() == 0 then
    logic_moment.EnterMomentUI(uid)
  end
end
function logic_moment.EnterOtherSpaceFromMoment(uid, owner_uid)
  log(bWriteLog and "[wuling] MomentDetailSystem.EnterOtherSpaceFrom uid = " .. tostring(uid) .. "owner_uid  = " .. tostring(owner_uid))
  if tonumber(uid) ~= tonumber(DataMgr.roleData.uid) then
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    local SocialPersonSpaceSystem = require("client.slua.logic.lobby.Left.logic_social_person_space")
    SocialPersonSpaceSystem.EnterPersonSpace(uid, false, RoleInfoMainSystem.RoleInfoOpenFromType.Moment)
  end
end
function logic_moment.ShowMomentShare(closeCb, recoverFunc, shareConfig)
  UIManager.ShowUI(UIManager.UI_Config.watermark_share_component, {
    onShowFunc = function(share_path)
      UIManager.ShowUI(UIManager.UI_Config.MomentReleaseMessage, share_path, nil, closeCb, nil, nil, shareConfig)
      if recoverFunc and type(recoverFunc) == "function" then
        recoverFunc()
      end
    end
  })
end
function logic_moment.CheckMomentLbsOpen()
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  if LbsMgr.GetMoment() == 0 then
    log(bWriteLog and "[YW] CheckMomentLbsOpen" .. " closed")
    return false
  end
  if LbsMgr.CanSelectProvinceMyCountry(LbsMgr.SETTING_CFG_NEAR_ID) == false then
    log(bWriteLog and "[YW] CheckMomentLbsOpen CanSelectProvinceMyCountry" .. " false")
    return false
  end
  log(bWriteLog and "[YW] CheckMomentLbsOpen" .. " opened")
  return true
end
local sourceType
function logic_moment.SetSourceType(_sourceType)
  sourceType = _sourceType
end
function logic_moment.GetSourceType()
  return sourceType or 1
end
local continueFlag = false
function logic_moment.SetTlogContinueFlag(bFlag)
  continueFlag = bFlag
end
function logic_moment.CheckNotContinueFlag()
  return continueFlag == false
end
function logic_moment.CheckAndSendSeasonLookBackTlog(moment_id)
  if not moment_id then
    log(bWriteLog and "logic_moment CheckAndSendSeasonLookBackTlog invalid moment_id")
    return
  end
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local moment_data = logic_moment_data.get_moment_info(moment_id)
  local moment_macro = require("client.slua.logic.moment.moment_macro")
  if not moment_data then
    log(bWriteLog and "CheckAndSendSeasonLookBackTlog no moment_data")
    return
  end
  local tlogId
  if moment_macro.IsSeasonLookBackEntranceType(moment_data.type) then
    tlogId = TLogEventDefine.NewSeasonLookback_MomentFavor
  elseif moment_macro.IsSeasonLookBackLongImageType(moment_data.type) then
    tlogId = TLogEventDefine.NewSeasonLookback_LongImageMomentFavor
  end
  if not tlogId then
    log(bWriteLog and "CheckAndSendSeasonLookBackTlog no tlogId")
    return
  end
  log(bWriteLog and "logic_moment CheckAndSendSeasonLookBackTlog tlogId:" .. tostring(tlogId))
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(tlogId)
end
local battleShowMomentShareFlag = true
function logic_moment.SetBattleShowMomentShareFlag(bFlag)
  battleShowMomentShareFlag = bFlag
end
function logic_moment.CheckNotShowMomentShareFlag()
  return battleShowMomentShareFlag == false
end
function logic_moment.CanLimitClickMomentTabByFrequency(_sourceType)
  local moment_macro = require("client.slua.logic.moment.moment_macro")
  local data = require("client.slua.logic.moment.logic_moment_data")
  local hasData = false
  if moment_macro.ENUM_TAB_LIMIT_TYPE.SELF == _sourceType then
    hasData = data.get_my_moment_info() ~= nil
  elseif moment_macro.ENUM_TAB_LIMIT_TYPE.FRIEND == _sourceType then
    hasData = data.get_fri_recent_moment_info() ~= nil
  elseif moment_macro.ENUM_TAB_LIMIT_TYPE.HOT == _sourceType then
    hasData = data.get_hot_moment_info() ~= nil
  elseif moment_macro.ENUM_TAB_LIMIT_TYPE.OTHER == _sourceType then
    hasData = data.get_fri_recent_moment_info() ~= nil
  elseif moment_macro.ENUM_TAB_LIMIT_TYPE.SQUARE == _sourceType then
    local otherUID = logic_moment.GetShowOtherPersonUID()
    hasData = data.get_other_people_moment_info(otherUID) ~= nil
  elseif moment_macro.ENUM_TAB_LIMIT_TYPE.MESSAGE == _sourceType then
    hasData = data.get_moment_remind_info() ~= nil
  end
  log(bWriteLog and "CanLimitClickMomentTabByFrequency _sourceType" .. tostring(_sourceType) .. " hasData " .. tostring(hasData))
  if hasData == false and _sourceType ~= nil then
    local UIUtil = require("client.common.ui_util")
    return UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.MomentClick)
  end
  return true
end
function logic_moment.GetRandomTextListByShareType(shareType)
  local randomTextType = logic_moment.GetRandomTextTypeByShareType(shareType)
  log(bWriteLog and "[v_wllwu] logic_moment.GetRandomTextListByShareType, shareType is " .. tostring(shareType) .. ", randomTextType is " .. tostring(randomTextType))
  local cfg = {}
  local momentRandomTextCfg = CDataTable.GetTable("MomentRandomTextCfg")
  for k, v in pairs(momentRandomTextCfg) do
    local categoryArray = v.Category_a
    for _, intValue in pairs(categoryArray) do
      if randomTextType == intValue then
        table.insert(cfg, v.TextContent)
      end
    end
  end
  return cfg
end
function logic_moment.GetRandomTextTypeByShareType(shareType)
  local moment_macro = require("client.slua.logic.moment.moment_macro")
  if shareType == ShareSceneType.GetItem then
    return moment_macro.ENUM_MOMENT_RANDOMTEXT_TYPE.GET_ITEM
  elseif shareType == ShareSceneType.ResultData then
    return moment_macro.ENUM_MOMENT_RANDOMTEXT_TYPE.RESULT_DATA
  elseif shareType == ShareSceneType.ResultRank then
    return moment_macro.ENUM_MOMENT_RANDOMTEXT_TYPE.RESULT_RANK
  elseif shareType == ShareSceneType.WonderfulReply then
    return moment_macro.ENUM_MOMENT_RANDOMTEXT_TYPE.REPLAY
  elseif shareType == ShareSceneType.SeasonLookBack or shareType == ShareSceneType.SeasonLookBackLongPic then
    return moment_macro.ENUM_MOMENT_RANDOMTEXT_TYPE.SEASON_LOOKBACK
  elseif shareType == ShareSceneType.ManorShare then
    return moment_macro.ENUM_MOMENT_RANDOMTEXT_TYPE.MANOR
  elseif shareType == ShareSceneType.CardCollectionExchange then
    return moment_macro.ENUM_MOMENT_RANDOMTEXT_TYPE.CARD_COLLECTION_EXCHANGE
  else
    return moment_macro.ENUM_MOMENT_RANDOMTEXT_TYPE.COMMON
  end
end
return logic_moment