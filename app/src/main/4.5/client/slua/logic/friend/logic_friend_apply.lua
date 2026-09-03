local logic_friend_apply = {}
function logic_friend_apply:DefineAndResetData()
  self.applyMap = {}
  self.applyCnt = 0
end
function logic_friend_apply:add_inner_friend_op_req(friUid, op, msg, extend_info)
  log(bWriteLog and "logic_friend_apply:add_inner_friend_op_req: " .. friUid .. " op: " .. op)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  friUid = tonumber(friUid)
  local applyData = self:GetApplyData(friUid)
  local source
  if applyData then
    source = applyData.source or applyData.fromId
  end
  extend_info = extend_info or {}
  extend_info.  if GameStatus.IsInMainCity() then
    extend_info.sceneType = 2
  else
    extend_info.sceneType = 1
  end
  local FriendApplyHandler = require("client.network.Protocol.FriendApplyHandler")
  FriendApplyHandler.send_add_inner_friend_op_req(friUid, op, msg, extend_info)
  if op == 1 then
    local StatManager = import("StatManager")
    StatManager.GetInstance():ReportEventWithParam(12, {
      friend_openid = tostring(friUid)
    }, true)
  end
end
function logic_friend_apply:proc_get_addfriend_reqlist_rsp(res, uid, addfriend_reqlist)
  log(bWriteLog and "logic_friend_apply:proc_get_addfriend_reqlist_rsp res = " .. res)
  log_tree("addfriend_reqlist = ", addfriend_reqlist)
  self.applyMap = {}
  self.applyCnt = 0
  local uidList = {}
  for uid, v in pairs(addfriend_reqlist) do
    uid = tonumber(uid)
    table.insert(uidList, uid)
    log(bWriteLog and "logic_friend_apply:proc_get_addfriend_reqlist_rsp is_dirty_cn = " .. tostring(v.is_dirty_cn))
    if v.is_dirty_cn then
      local config = CDataTable.GetTableData("FriendApplyConfig", 21)
      if config then
        v.applyMsg = config.DefaultWords
      else
        log(bWriteLog and "on_get_addfriend_reqlist_rsp config is nil")
        v.applyMsg = ""
      end
    end
    log(bWriteLog and "logic_friend_apply:proc_get_addfriend_reqlist_rsp applyMsg = " .. tostring(v.applyMsg))
    local data = {
      uid = uid,
      op = v.op,
      applyMsg = v.applyMsg,
      createTime = v.createTime,
      source = v.source,
      can_be_hidden = v.can_be_hidden,
      mutual_friends_cnt = v.mutual_friends_cnt or 0
    }
    if data.source == "20018" then
      data.applyMsg = LocUtil.GetLocalizeResStr(23578)
    end
    self.applyMap[uid] = data
    self.applyCnt = self.applyCnt + 1
  end
  table.sort(uidList, function(a, b)
    return self.applyMap[a].mutual_friends_cnt > self.applyMap[b].mutual_friends_cnt
  end)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(uidList, LogicFriend.on_batch_get_profile_rsp, Enum_PROFILE_REPORT_CFG.FRIEND_LIST)
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE)
end
function logic_friend_apply:batch_add_inner_friend_op_req(op)
  if op == 1 then
    local friend_const = require("client.slua.logic.friend.friend_const")
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local innerList = LogicFriend.GetInnerList()
    if self.applyCnt + #innerList >= friend_const.Friend_Max_Num then
      ShowNotice(689308)
      return
    end
  end
  local list = {}
  local extend_info = {}
  for uid, applyData in pairs(self.applyMap) do
    table.insert(list, uid)
    extend_info[uid] = applyData.source or applyData.fromId
  end
  if GameStatus.IsInMainCity() then
    extend_info.sceneType = 2
  else
    extend_info.sceneType = 1
  end
  local FriendApplyHandler = require("client.network.Protocol.FriendApplyHandler")
  FriendApplyHandler.send_batch_add_inner_friend_op_req(list, op, extend_info)
  if op == 1 then
    for _, friUid in ipairs(list) do
      local StatManager = import("StatManager")
      StatManager.GetInstance():ReportEventWithParam(12, {
        friend_openid = tostring(friUid)
      }, true)
    end
  end
end
function logic_friend_apply:batch_add_friend_req(uidList, msg, from, msgId, extendInfo)
  log(bWriteLog and string.format("logic_friend_apply:batch_add_friend_req msg:%s from:%s", msg, tostring(from)))
  log_tree("logic_friend_apply:batch_add_friend_req uid_list = ", uidList)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local friend_const = require("client.slua.logic.friend.friend_const")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local innerList = LogicFriend.GetInnerList()
  if #innerList >= friend_const.Friend_Max_Num then
    ShowNotice(689308)
    return
  end
  if msg == nil or msg == "" then
    msg = self:GetApplyMsg(msgId)
  end
  extendInfo = extendInfo or {}
  if GameStatus.IsInMainCity() then
    extendInfo.sceneType = "MainCity"
  end
  local FriendApplyHandler = require("client.network.Protocol.FriendApplyHandler")
  FriendApplyHandler.send_batch_add_friend_req(uidList, msg, from, extendInfo)
  if GameStatus.IsInMainCity() then
    log(bWriteLog and "logic_friend_apply:batch_add_friend_req IsInMainCity = true")
    local logic_main_city_achievement_task_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_achievement_task_report")
    logic_main_city_achievement_task_report.ReportAddFriendInMainCity(uidList)
  end
end
function logic_friend_apply:proc_batch_add_inner_friend_op_rsp(error, result, op)
  log(bWriteLog and "logic_friend_apply:proc_batch_add_inner_friend_op_rsp error = " .. error)
  if error == "timeout" then
    ShowNotice(5000109)
    return
  end
  if error ~= NetErrorCode_NONE then
    return
  end
  if op == 0 then
    self.applyMap = {}
    self.applyCnt = 0
  else
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    for uid, res in pairs(result) do
      log(bWriteLog and "logic_friend_apply:proc_batch_add_inner_friend_op_rsp uid = " .. tostring(uid) .. "error = " .. error)
      if res == NetErrorCode_NONE then
        local friendData = self:GetApplyData(uid)
        LogicFriend.AddInnerFriend(uid)
        if friendData then
          LogicFriend.AddSource(uid, friendData.source)
        end
        if friendData and friendData.source == BP_ENUM_ADD_FRIEND_FROM_FRIEND_RECRUITMENT then
          local ChatHandler = require("client.network.Protocol.ChatHandler")
          local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
          local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
          local channelType = chat_macro.Channel.channelPrivate
          local msg = {}
          msg.          msg.text = LocUtil.GetLocalizeResStr(43390)
          local TimeUtil = require("client.common.time_util")
          msg.sendTime = TimeUtil.GetServerTimeInSec()
          msg.msgType = chat_macro.FriendRecruitType
          local msgId = chat_main.CacheMsg(msg)
          ChatHandler.send_chat_req(uid, chat_macro.Channel.channelPrivate, msgId, msg)
        end
      elseif res == "full" then
        ShowNotice(689308)
      elseif res == "invalid" then
        self:DelApplyList(uid)
        EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE)
      elseif res == "busy" then
        ShowNotice(501087)
      elseif res == "processing" then
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE)
end
function logic_friend_apply:add_inner_friend_req(uid, msg, from, msgId, extendInfo)
  log(bWriteLog and string.format("logic_friend_apply:add_inner_friend_req uid:%s msg:%s from:%s msgId:%s", tostring(uid), msg, tostring(from), tostring(msgId)))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local friend_const = require("client.slua.logic.friend.friend_const")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local innerList = LogicFriend.GetInnerList()
  if #innerList >= friend_const.Friend_Max_Num then
    ShowNotice(689308)
    return
  end
  if msg == nil or msg == "" then
    msg = self:GetApplyMsg(msgId)
  end
  extendInfo = extendInfo or {}
  if GameStatus.IsInMainCity() then
    extendInfo.sceneType = 2
  else
    extendInfo.sceneType = 1
  end
  local FriendApplyHandler = require("client.network.Protocol.FriendApplyHandler")
  FriendApplyHandler.send_add_inner_friend_req(uid, msg, from, extendInfo)
  local StatManager = import("StatManager")
  StatManager.GetInstance():ReportEventWithParam(11, {
    friend_openid = tostring(uid)
  }, true)
  if GameStatus.IsInMainCity() then
    log(bWriteLog and "logic_friend_apply:add_inner_friend_req IsInMainCity = true")
    local logic_main_city_achievement_task_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_achievement_task_report")
    logic_main_city_achievement_task_report.ReportAddFriendInMainCity({uid})
  end
end
function logic_friend_apply:proc_add_inner_friend_notify(add_req_friend, msg, msgcreateTime, from, is_dirty_cn, can_be_hidden, mutual_friends_cnt)
  log(bWriteLog and "logic_friend_apply:proc_add_inner_friend_notify from = " .. tostring(from))
  if is_dirty_cn then
    local config = CDataTable.GetTableData("FriendApplyConfig", 21)
    if config then
      msg = config.DefaultWords
    else
      msg = ""
    end
  end
  local data = {
    uid = tonumber(add_req_friend),
    op = -1,
    applyMsg = msg,
    createTime = msgcreateTime,
    fromId = from,
    can_be_hidden = can_be_hidden,
    mutual_friends_cnt = mutual_friends_cnt or 0
  }
  if not self.applyMap[data.uid] then
    self.applyCnt = self.applyCnt + 1
  end
  self.applyMap[data.uid] = data
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetFriendProfiles(Enum_PROFILE_REPORT_CFG.FRIEND_ADD, {add_req_friend}, LogicFriend.on_batch_get_profile_rsp)
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE)
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INNERADD_NOTIFY, add_req_friend)
  local logic_recommend_friend = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_recommend_friend)
  logic_recommend_friend:OnNotifyAddFriend(add_req_friend, msg, from)
  if from == BP_ENUM_ADD_FRIEND_FROM_INGAME or from == BP_ENUM_ADD_FRIEND_FROM_INGAME_OB or from == BP_ENUM_ADD_FRIEND_FROM_INGAME_ISLAND then
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    local is_ob = false
    if slua.isValid(uPlayerController) and uPlayerController.IsSpectator and (uPlayerController:IsSpectator() or uPlayerController.bIsForReplay) then
      is_ob = true
    end
    if slua.isValid(uPlayerController) and uPlayerController.IsInPetSpectator and uPlayerController:IsInPetSpectator() then
      print(bWriteLog and "LogicFriend.on_add_inner_friend_notify IsInPetSpectator")
      is_ob = true
    end
    if is_ob or CGameState and CGameState.GetGameModeState and (CGameState:GetGameModeState() == "ReadyState" or CGameState:GetGameModeState() == "ActiveState") then
      if UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.IngameFriendPop then
        UIManager.ShowUI(UIManager.UI_Config_InGame.IngameFriendPop, data)
      end
    else
      local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
      local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
      if MainControlBaseUI and MainControlBaseUI.QuickMenu then
        MainControlBaseUI.QuickMenu:OnAddFriendReq(nil, data.uid)
      end
    end
  end
end
function logic_friend_apply:proc_auto_add_inner_friend_notify(uid)
  log(bWriteLog and "logic_friend_apply:proc_auto_add_inner_friend_notify uid: " .. tostring(uid))
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if LogicFriend.IsInnerFriend(uid) then
    return
  end
  LogicFriend.AddInnerFriend(uid)
end
function logic_friend_apply:proc_add_inner_friend_op_rsp(res, friUid, op)
  log(bWriteLog and "logic_friend_apply:proc_add_inner_friend_op_rsp res: " .. tostring(res) .. " op: " .. tostring(op) .. " friUid: " .. tostring(friUid))
  if res == "fri_not_exist" then
    local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
    if not logic_friend_blacklist:IsBlacklist(friUid) then
      ShowNotice(200024)
    end
    self:DelApplyList(friUid)
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE)
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SHIELD_COMMON_COMMENT)
    return
  end
  if res == "fri_already" then
    ShowNotice(200007)
    self:DelApplyList(friUid)
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE)
    return
  end
  if res == "fri_list_full" then
    ShowNotice(200008)
    return
  end
  if res ~= NetErrorCode_NONE then
    return
  end
  if op == 1 then
    local friendData = self:GetApplyData(friUid)
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    LogicFriend.AddInnerFriend(friUid)
    if friendData and LogicFriend.AddSource then
      LogicFriend.AddSource(friUid, friendData.source)
    end
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(friUid)
    if profile then
      local str = LocUtil.LocalizeResFormat(200014, profile.nickName)
      ShowNotice(str)
    end
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetRankProfiles(Enum_PROFILE_REPORT_CFG.FRIEND_ADD, {friUid})
    if friendData and friendData.source == BP_ENUM_ADD_FRIEND_FROM_FRIEND_RECRUITMENT then
      local ChatHandler = require("client.network.Protocol.ChatHandler")
      local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
      local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
      local channelType = chat_macro.Channel.channelPrivate
      local msg = {}
      msg.      msg.text = LocUtil.GetLocalizeResStr(43390)
      local TimeUtil = require("client.common.time_util")
      msg.sendTime = TimeUtil.GetServerTimeInSec()
      msg.msgType = chat_macro.FriendRecruitType
      local msgId = chat_main.CacheMsg(msg)
      ChatHandler.send_chat_req(friUid, chat_macro.Channel.channelPrivate, msgId, msg)
    end
    if not GameStatus.IsInLobbyOrMainCity() then
      local SingleTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
      if not SingleTrainTool.IsSelfInTraining() and not GameStatus.IsCollectionHallMode() then
        UIManager.ShowUI(UIManager.UI_Config.friend_remark, friUid)
      end
    end
  else
    self:DelApplyList(friUid)
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE)
end
function logic_friend_apply:GetApplyList()
  local list = {}
  for _, v in pairs(self.applyMap) do
    table.insert(list, v)
  end
  table.sort(list, function(a, b)
    return a.mutual_friends_cnt > b.mutual_friends_cnt
  end)
  return list
end
function logic_friend_apply:GetApplyData(uid)
  if not self.applyMap[uid] then
    return nil
  end
  return self.applyMap[uid]
end
function logic_friend_apply:GetApplyCnt()
  return self.applyCnt
end
function logic_friend_apply:DelApplyList(uid)
  if not self.applyMap[uid] then
    return
  end
  self.applyMap[uid] = nil
  self.applyCnt = self.applyCnt - 1 or 0
end
function logic_friend_apply:GetApplyMsg(msgId)
  local msg = ""
  local msgConfig = CDataTable.GetTableData("FriendApplyConfig", msgId)
  if msgConfig then
    msg = msgConfig.DefaultWords
  end
  if msg == nil or msg == "" then
    msg = LocUtil.GetLocalizeResStr(200006)
  end
  return msg
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_friend_apply = class(CModuleBase, nil, logic_friend_apply)
return Clogic_friend_apply