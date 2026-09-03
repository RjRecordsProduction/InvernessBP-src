local logic_friend_reserve = {}
local Enum_ReserveState = {
  Waiting = 1,
  Agree = 2,
  Refuse = 3
}
logic_friend_reserve.local ErrorCodeConfig = {
  err_friend_appointment_not_inner_fri = 100090001,
  err_friend_appointment_intimacy_not_enough = 100090002,
  err_friend_appointment_friend_not_in_game = 100090003,
  err_friend_appointment_client_ver_not_same = 100090004,
  err_friend_appointment_pre_team_limit = 100090005,
  err_friend_appointment_waiting_reply = 100090006,
  err_friend_appointment_too_many_invite = 100090007,
  err_friend_appointment_too_many_accept = 100090008,
  err_friend_appointment_not_in_game = 100090009,
  err_friend_appointment_in_refuse_cd = 100090010,
  err_friend_appointment_enter_waiting = 100090011
}
logic_friend_reserve.local ErrorCodeTips = {
  [ErrorCodeConfig.err_friend_appointment_not_inner_fri] = 509012,
  [ErrorCodeConfig.err_friend_appointment_intimacy_not_enough] = 200054,
  [ErrorCodeConfig.err_friend_appointment_friend_not_in_game] = 110016,
  [ErrorCodeConfig.err_friend_appointment_client_ver_not_same] = 501128,
  [ErrorCodeConfig.err_friend_appointment_pre_team_limit] = 27192,
  [ErrorCodeConfig.err_friend_appointment_waiting_reply] = 44049,
  [ErrorCodeConfig.err_friend_appointment_too_many_invite] = 11455,
  [ErrorCodeConfig.err_friend_appointment_too_many_accept] = 100110020,
  [ErrorCodeConfig.err_friend_appointment_not_in_game] = 29408,
  [ErrorCodeConfig.err_friend_appointment_in_refuse_cd] = 110011
}
local C_BlackPinkGameModeID = 26001
local C_ReqIntervalTime = 120
local C_AddMsgNotifyInGameInterval = 30
local C_ReserveFriendInterTime = 180
local guideShowed, isInitedCacheData, reserveMsgList, reserveFriendInfo
local bSingleGameOpen = true
local lastReqTime = 0
local receiveOtherReserveMsg, popAnswerTipsList, popReserveTipsList, chatEntranceTipUidList, receiveFriendInviteUid
local isNeedInquiryHistoryData = true
local lastTimeNotifyChatMsgInGame = 0
local isForceUpdateNow
local _InitLocalSaveData = function()
  if isInitedCacheData then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFriendReserve)
  if saveData and saveData.newestVersionShowed then
    guideShowed = true
  end
  isInitedCacheData = true
end
local _InitData = function()
  log(bWriteLog and "logic_friend_reserve _InitData")
  lastReqTime = 0
  receiveOtherReserveMsg = nil
  popAnswerTipsList = nil
  popReserveTipsList = nil
  isInitedCacheData = nil
  chatEntranceTipUidList = nil
  receiveFriendInviteUid = nil
  lastTimeNotifyChatMsgInGame = 0
end
local _ClearDataWhenGoFight = function()
  log(bWriteLog and "logic_friend_reserve _ClearDataWhenGoFight")
  receiveOtherReserveMsg = nil
  popAnswerTipsList = nil
  popReserveTipsList = nil
  chatEntranceTipUidList = nil
  receiveFriendInviteUid = nil
end
local _GetReserveFriendCdTime = function()
  local ParamsConfig = CDataTable.GetTableData("TeamupQuickMsgParamsConfig", "appointment_send_wait_sec")
  if not ParamsConfig then
    return C_ReserveFriendInterTime
  end
  log(bWriteLog and "[v_wllwu] _GetReserveFriendCdTime = " .. tostring(ParamsConfig.Value))
  return ParamsConfig.Value
end
local _GetRefusedFriendCdTime = function()
  local ParamsConfig = CDataTable.GetTableData("TeamupQuickMsgParamsConfig", "appointment_refuse_cd")
  if not ParamsConfig then
    return C_ReserveFriendInterTime
  end
  log(bWriteLog and "[v_wllwu] _GetRefusedFriendCdTime = " .. tostring(ParamsConfig.Value))
  return ParamsConfig.Value
end
function logic_friend_reserve:OnInitialize()
  logic_friend_reserve.__super.OnInitialize(self)
  self.nAllowReserveFlag = 0
end
function logic_friend_reserve:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_BATTLE_APPOINTMENT_POPUP, self.PopNextTips, self)
end
function logic_friend_reserve:OnLogin(bReLogin)
end
function logic_friend_reserve:OnLogOut()
  _InitData()
end
function logic_friend_reserve:OnPreSwitchGameStatus(preState, nextState)
  if GameStatus.IsPreSwitchEnterFightingFromLobbyOrMainCity(preState, nextState) then
    log(bWriteLog and "[v_wllwu] logic_friend_reserve:OnPreSwitchGameStatus ClearDataWhenGoFight")
    _ClearDataWhenGoFight()
  elseif nextState == GameStatus.Lobby then
    isNeedInquiryHistoryData = true
  end
end
function logic_friend_reserve:OnPostSwitchGameStatus(preState, nextState)
end
function logic_friend_reserve:InquiryHistoryReserveInfoReq()
  if not isNeedInquiryHistoryData then
    return
  end
  isNeedInquiryHistoryData = false
  self:GetHistoryReserveInfoReq()
end
function logic_friend_reserve:IsSingleGameReserveOpen()
  return bSingleGameOpen
end
function logic_friend_reserve:GetFriendIntimacyValue()
  local ParamsConfig = CDataTable.GetTableData("TeamupQuickMsgParamsConfig", "appointment_intimacy")
  if not ParamsConfig then
    log(bWriteLog and "[v_wllwu] logic_friend_reserve:GetFriendIntimacyValue ParamsConfig is nil")
    return
  end
  return ParamsConfig.Value
end
function logic_friend_reserve:IsCanReserve(uid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local playerData = LogicFriend.GetFriendData(uid)
  if not playerData then
    return false
  end
  local isIntimacyLimit = self:GetFriendIntimacyValue() or 0
  if not playerData.intimacy or isIntimacyLimit > playerData.intimacy then
    return false
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(uid)
  if not status then
    log(bWriteLog and "logic_friend_reserve:IsCanReserve not status data")
    return false
  end
  local logic_island_status = require("GameLua.Mod.SocialIsland.Client.IslandStatusLogic")
  local type = logic_island_status:CheckIslandStatus(status.socialland_type, status.game_id, status.land_id)
  if type == logic_island_status.ENUM_ISLAND_STATUS.ME_ON_ISLAND or type == logic_island_status.ENUM_ISLAND_STATUS.ON_DIFFERENT_ISLAND or type == logic_island_status.ENUM_ISLAND_STATUS.ON_SAME_ISLAND then
    return false
  end
  if status.cwow_type and status.cwow_type == 1 then
    return false
  end
  return true
end
function logic_friend_reserve:GetReserveGuideFriendIndex(friendList)
  log(bWriteLog and "logic_friend_reserve:GetReserveGuideFriendIndex")
  if not friendList or #friendList <= 0 then
    log(bWriteLog and "logic_friend_reserve:GetReserveGuideFriendIndex no friendList")
    return
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  for index, friendData in ipairs(friendList) do
    local status = PlayerStatusMgr:GetStatusData(friendData.uid)
    if status and status.online ~= 0 and LogicFriend.IsFriendReserveSwitchOpen(friendData.uid) and PlayerStatusUtil.IsBattle(status) and status.socialland_type == 0 and status.cwow_type == 0 then
      local home_macros = require("client.slua.logic.home.home_macros")
      if status.game_sub_mode ~= C_BlackPinkGameModeID and status.game_sub_mode ~= home_macros.Home_SubMode.Visit then
        local state = LogicFriend.GetReserveState(friendData.uid)
        if state == 1 then
          log(bWriteLog and "[v_wllwu] logic_friend_reserve:GetReserveGuideFriendIndex return " .. tostring(index))
          return index
        end
      end
    end
  end
  return nil
end
function logic_friend_reserve:IsReserveGuideShowed()
  _InitLocalSaveData()
  return guideShowed
end
function logic_friend_reserve:IsShowReserveMsgItem(uid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if not LogicFriend.IsFriendReserveSwitchOpen(uid) then
    log(bWriteLog and "[v_wllwu] logic_friend_reserve:IsShowReserveMsgItem friendReserveSwitch is Close, uid = " .. tostring(uid))
    return
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(uid)
  if not status then
    return
  end
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if status.online == 0 or status.socialland_type ~= 0 or status.cwow_type ~= 0 or PlayerStatusUtil.IsMainCity(status) or PlayerStatusUtil.IsInCollectionHall(status) then
    return
  end
  if status.teamState ~= 2 then
    log(bWriteLog and "[v_wllwu] logic_friend_reserve:IsShowReserveMsgItem player is not in game")
    if self:IsReserveSuccess(uid) then
      log(bWriteLog and "[v_wllwu] logic_friend_reserve:IsShowReserveMsgItem ReserveSuccess, uid = " .. tostring(uid))
      return true
    end
    return false
  end
  if not reserveFriendInfo or not reserveFriendInfo[uid] then
    local home_macros = require("client.slua.logic.home.home_macros")
    if status.game_sub_mode ~= C_BlackPinkGameModeID and status.game_sub_mode ~= home_macros.Home_SubMode.Visit and self:IsCanReserve(uid) then
      return true
    end
  else
    return true
  end
  return nil
end
function logic_friend_reserve:UpdateReserveGuideData()
  if guideShowed then
    return
  end
  guideShowed = true
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = {newestVersionShowed = true}
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eFriendReserve)
end
function logic_friend_reserve:GetReserveMsgList()
  if reserveMsgList and 0 < #reserveMsgList then
    return reserveMsgList
  end
  reserveMsgList = {}
  local configs = CDataTable.GetTable("ReserveMsgConfig")
  for _, data in pairs(configs) do
    local msg = {
      id = data.ID,
      key = data.Key,
      isDefault = data.IsDefault
    }
    table.insert(reserveMsgList, msg)
  end
  return reserveMsgList
end
function logic_friend_reserve:GetDefaultReserveMsg()
  local msgList = self:GetReserveMsgList()
  if not msgList or #msgList <= 0 then
    return
  end
  for _, v in ipairs(msgList) do
    if v.isDefault == 1 then
      return v
    end
  end
  return nil
end
function logic_friend_reserve:GetStrByMsgId(msg_id)
  if not msg_id then
    return
  end
  local msgList = self:GetReserveMsgList()
  if not msgList then
    return
  end
  for _, v in ipairs(msgList) do
    if v.id == msg_id then
      return LocUtil.GetLocalizeResStr(v.key)
    end
  end
  return nil
end
function logic_friend_reserve:SendChatReserveMsg(uid, msgStr, isGameResultReserveMsg)
  if not msgStr or msgStr == "" then
    return
  end
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  if not logic_chat_channel_friend.CanSendMsg(uid) then
    log(bWriteLog and "[v_wllwu] logic_friend_reserve:SendChatReserveMsg cannot SendMsg")
    return
  end
  local msg = logic_chat_channel_friend.GetAndSetNormalMsg(msgStr)
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  msg.isReserveMsg = true
  msg.  logic_chat_channel_friend.SendChatReq(msg, uid)
end
function logic_friend_reserve:UpdateStateAfterReserve(uid, msg_id, from)
  if not reserveFriendInfo then
    reserveFriendInfo = {}
  end
  local TimeUtil = require("client.common.time_util")
  local time = TimeUtil.GetServerTimeInSec()
  if reserveFriendInfo[uid] then
    reserveFriendInfo[uid].status = Enum_ReserveState.Waiting
    reserveFriendInfo[uid].msg_id = time
    reserveFriendInfo[uid].    reserveFriendInfo[uid].    return
  end
  reserveFriendInfo[uid] = {
    status = Enum_ReserveState.Waiting,
    msg_id = msg_id,
    time = time,
      }
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RESERVE_STATUS_CHANGE)
end
function logic_friend_reserve:AddFriendUidWhenInviteMe(uid)
  if not receiveFriendInviteUid then
    receiveFriendInviteUid = {}
  end
  receiveFriendInviteUid[uid] = true
end
function logic_friend_reserve:IsFriendInvitedMe(uid)
  return receiveFriendInviteUid and receiveFriendInviteUid[uid]
end
function logic_friend_reserve:OnGetOtherReserveInvite(uid, from)
  if not receiveOtherReserveMsg then
    receiveOtherReserveMsg = {}
  end
  receiveOtherReserveMsg[uid] = from
end
function logic_friend_reserve:GetOtherReserveFrom(uid)
  if not uid then
    return
  end
  return receiveOtherReserveMsg and receiveOtherReserveMsg[uid]
end
function logic_friend_reserve:DeleteOtherReserveRecord(uid)
  if not receiveOtherReserveMsg or not receiveOtherReserveMsg[uid] then
    return
  end
  receiveOtherReserveMsg[uid] = nil
end
function logic_friend_reserve:CheckCanReserve(uid, isShowTips)
  if not reserveFriendInfo or not reserveFriendInfo[uid] then
    log(bWriteLog and "[v_wllwu] logic_friend_reserve:CheckCanReserve 111")
    return true
  end
  local time = reserveFriendInfo[uid].time or 0
  if time == 0 then
    log(bWriteLog and "[v_wllwu] logic_friend_reserve:CheckCanReserve 222")
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local cd = _GetReserveFriendCdTime()
  local leftTime = cd - (nowTime - time)
  if 0 < leftTime then
    log(bWriteLog and string.format("[v_wllwu] logic_friend_reserve.CheckCanReserve 333(%s, %s, %s)", tostring(nowTime), tostring(time), tostring(leftTime)))
    if isShowTips then
      ShowNotice(LocUtil.LocalizeResFormat(44052, leftTime))
    end
    return false
  end
  return true
end
function logic_friend_reserve:IsReserveSuccess(uid)
  local state = self:GetReserveState(uid)
  return state == Enum_ReserveState.Agree
end
function logic_friend_reserve:GetReserveState(uid)
  if not reserveFriendInfo or not reserveFriendInfo[uid] then
    return
  end
  if type(reserveFriendInfo[uid]) ~= "table" then
    return
  end
  local status = reserveFriendInfo[uid].status
  if status == Enum_ReserveState.Refuse then
    local time = reserveFriendInfo[uid].time
    local TimeUtil = require("client.common.time_util")
    local nowTime = TimeUtil.GetServerTimeInSec()
    local cd = _GetRefusedFriendCdTime()
    if cd <= nowTime - time then
      return
    end
  end
  return status, reserveFriendInfo[uid].result
end
function logic_friend_reserve:GetReserveInfoByUid(uid)
  if not reserveFriendInfo or not reserveFriendInfo[uid] then
    return
  end
  return reserveFriendInfo[uid]
end
function logic_friend_reserve:UpdateFriendReserveState(uid, reserveInfo, result)
  if not uid or not reserveInfo then
    return
  end
  if type(reserveInfo) == "number" then
    if reserveFriendInfo and reserveFriendInfo[uid] then
      reserveFriendInfo[uid] = nil
    end
  elseif type(reserveInfo) == "table" then
    log_tree(bWriteLog and "[v_wllwu] logic_friend_reserve:UpdateFriendReserveState", reserveInfo)
    if not reserveFriendInfo then
      reserveFriendInfo = {}
    end
    reserveInfo.    reserveFriendInfo[uid] = reserveInfo
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RESERVE_STATUS_CHANGE)
end
function logic_friend_reserve:OnGetFriendAnswer(uid, result, from)
  if result ~= 0 and result ~= 1 then
    return
  end
  if not self:IsCanInvite(uid) then
    return
  end
  local strId = result == 1 and 44050 or 44051
  local reserveInfo = {
    content = LocUtil.GetLocalizeResStr(strId),
    uid = uid,
    uiType = 1,
    from = from,
      }
  self:PopFriendAnswerNotifyTips(reserveInfo)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if profile then
    ShowNotice(LocUtil.LocalizeResFormat(110123, profile.nickName))
  end
end
function logic_friend_reserve:PopFriendAnswerNotifyTips(msg)
  log_tree("logic_friend_reserve:PopFriendAnswerNotifyTips msg = ", msg)
  if not popAnswerTipsList then
    popAnswerTipsList = {}
  end
  table.insert(popAnswerTipsList, msg)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_POST_SWITCH_BATTLE_APPOINTMENT_POPUP)
end
function logic_friend_reserve:OnFriendCompleteGame(uid, from)
  if reserveFriendInfo and reserveFriendInfo[uid] then
    log(bWriteLog and "[v_wllwu] logic_friend_reserve:OnFriendCompleteGame, resetState uid = " .. tostring(uid))
    reserveFriendInfo[uid] = nil
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RESERVE_STATUS_CHANGE)
  end
  if not self:IsCanInvite(uid) then
    return
  end
  local reserveInfo = {
    content = LocUtil.GetLocalizeResStr(44041),
    uid = uid,
    uiType = 2,
      }
  self:PopReserveTeamNotifyTips(reserveInfo)
end
function logic_friend_reserve:OnGetAllAgreeResreveInfo(friendList)
  if not friendList or #friendList <= 0 then
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, v in pairs(friendList) do
    if self:IsCanInvite(v.friUid) then
      local profile = logic_profile:GetLocalProfile(v.friUid)
      local content = LocUtil.LocalizeResFormat(9082, profile.nickName)
      local reserveInfo = {
        content = content,
        uid = v.friUid,
        uiType = 2,
        from = self:GetReservedFrom(v.from)
      }
      EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_POST_SWITCH_BATTLE_APPOINTMENT_POPUP)
      self:PopReserveTeamNotifyTips(reserveInfo)
    end
  end
end
function logic_friend_reserve:AddReserveMsgNotifyInGame(chatMsg)
  if not bSingleGameOpen then
    log(bWriteLog and "[v_wllwu] logic_friend_reserve:AddReserveMsgNotifyInGame bSingleGameOpen false")
    return
  end
  if not (chatMsg and not chatMsg.selfMsg and chatMsg.content) or not chatMsg.content.isReserveMsg then
    return
  end
  if lastTimeNotifyChatMsgInGame then
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    if curTime - lastTimeNotifyChatMsgInGame < C_AddMsgNotifyInGameInterval then
      log(bWriteLog and "[v_wllwu] logic_friend_reserve:AddReserveMsgNotifyInGame Interval return")
      return
    end
  end
  local txt = LocUtil.LocalizeResFormat(44044, chatMsg.name, chatMsg.msg)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  InGameUITools.DisplayMessageInGame(txt)
end
function logic_friend_reserve:PopReserveTeamNotifyTips(msg)
  if not popReserveTipsList then
    popReserveTipsList = {}
  end
  table.insert(popReserveTipsList, msg)
  local logic_post_switch_popup = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_post_switch_popup)
  logic_post_switch_popup:TryExecuteOne(BP_ENUM_MODULE_BATTLE_APPOINTMENT_POPUP)
end
function logic_friend_reserve:IsCanInvite(uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    log(bWriteLog and "[v_wllwu] logic_friend_reserve:IsCanInvite, profile is nil, uid = " .. tostring(uid))
    return false
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(uid)
  if not status then
    log(bWriteLog and "[v_wllwu] logic_friend_reserve:IsCanInvite, status is nil, uid = " .. tostring(uid))
    return false
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
    for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
      if tonumber(k) == uid then
        log(bWriteLog and "[v_wllwu] logic_friend_reserve:IsCanInvite in Teeam, uid = " .. tostring(uid))
        return false
      end
    end
  end
  return true
end
function logic_friend_reserve:PopNextTips()
  log(bWriteLog and "[v_wllwu] logic_friend_reserve:PopNextTips enter")
  if IsWoWEditor then
    return
  end
  if popReserveTipsList and 0 < #popReserveTipsList and popAnswerTipsList and 0 < #popAnswerTipsList then
    for i, v in ipairs(popReserveTipsList) do
      for ii = #popAnswerTipsList, 1, -1 do
        if popAnswerTipsList[ii].uid == v.uid then
          log(bWriteLog and "[v_wllwu] logic_friend_reserve:PopNextTips data is repeated, delete uid = " .. tostring(v.uid) .. " index = " .. tostring(ii))
          table.remove(popAnswerTipsList, ii)
        end
      end
    end
  end
  if (not popReserveTipsList or #popReserveTipsList <= 0) and (not popAnswerTipsList or #popAnswerTipsList <= 0) then
    log(bWriteLog and "[v_wllwu] logic_friend_reserve:PopNextTips return 2")
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInTeam() and not TeamUpNewSystem.CanInvite() then
    log(bWriteLog and "[v_wllwu] logic_friend_reserve:PopNextTips return 3")
    popReserveTipsList = nil
    popAnswerTipsList = nil
    return
  end
  if popAnswerTipsList and 0 < #popAnswerTipsList then
    UIManager.ShowUI(UIManager.UI_Config.Team_Appoint_Result_Tip_UIBP, popAnswerTipsList[1])
    table.remove(popAnswerTipsList, 1)
  elseif popReserveTipsList and 0 < #popReserveTipsList then
    UIManager.ShowUI(UIManager.UI_Config.Team_Appoint_Result_Tip_UIBP, popReserveTipsList[1])
    table.remove(popReserveTipsList, 1)
  end
end
function logic_friend_reserve:CloseReserveTipsUI()
  log(bWriteLog and "[v_wllwu] logic_friend_reserve:CloseReserveTipsUI")
  local Team_Appoint_Result_Tip_UIBP = UIManager.GetUI(UIManager.UI_Config.Team_Appoint_Result_Tip_UIBP)
  if Team_Appoint_Result_Tip_UIBP and Team_Appoint_Result_Tip_UIBP:IsShow() then
    log(bWriteLog and "logic_friend_reserve:CloseReserveTipsUI Team_Appoint_Result_Tip_UIBP IsShow")
    popAnswerTipsList = nil
    popReserveTipsList = nil
    UIManager.CloseUI(UIManager.UI_Config.Team_Appoint_Result_Tip_UIBP)
  end
end
function logic_friend_reserve:GetReservedFrom(from)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local reserveFrom = TeamUpNewSystem.E_InviteFromType.FriendReserveList
  if from == TeamUpNewSystem.E_InviteFromType.SwtichModeAppointment then
    reserveFrom = TeamUpNewSystem.E_InviteFromType.SwtichModeFriendReserveList
  end
  return reserveFrom
end
function logic_friend_reserve:UpdateChatEntranceTips(uid)
  if chatEntranceTipUidList and chatEntranceTipUidList[uid] then
    return
  end
  chatEntranceTipUidList = chatEntranceTipUidList or {}
  chatEntranceTipUidList[uid] = true
  log(bWriteLog and "[v_wllwu] logic_friend_reserve:UpdateChatEntranceTips " .. tostring(uid))
  local logic_chat_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_entrance)
  logic_chat_entrance:SetUnreadFriendReserveChatMsgCount(1, uid, true, true)
end
function logic_friend_reserve:HandleErrorCode(errorCode)
  log(bWriteLog and "[v_wllwu] logic_friend_reserve:HandleErrorCode " .. tostring(errorCode))
  if errorCode and ErrorCodeTips[errorCode] then
    ShowNotice(ErrorCodeTips[errorCode])
  end
end
function logic_friend_reserve:SetForceUpdateReserveData()
  isForceUpdateNow = true
  log(bWriteLog and "[v_wllwu] logic_friend_reserve:SetForceUpdateReserveData")
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RESERVE_FORCEUPDATE_DATA)
end
function logic_friend_reserve:proc_modify_friend_appointment_privacy_rsp(privacy)
  self.nAllowReserveFlag = privacy
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RESERVE_SWITCH_SYNC)
end
function logic_friend_reserve:GetHistoryReserveInfoReq()
  log(bWriteLog and "[v_wllwu] logic_friend_reserve:GetHistoryReserveInfoReq send_get_appointment_friend_req, isForceUpdateNow = " .. tostring(isForceUpdateNow))
  local nowTime = FuncUtil.GetServerTimeInSec()
  if not isForceUpdateNow and nowTime - lastReqTime < C_ReqIntervalTime then
    return
  end
  lastReqTime = nowTime
  isForceUpdateNow = false
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_get_appointment_friend_req()
end
function logic_friend_reserve:OnGetHistoryReserveInfoReq(err_code, send_friends, auto_reply)
  log(bWriteLog and "[v_wllwu] logic_friend_reserve:OnGetHistoryReserveInfoReq, err_code = " .. tostring(err_code) .. ",auto_reply = " .. tostring(auto_reply))
  if err_code ~= 0 then
    return
  end
  log_tree(bWriteLog and "[v_wllwu] logic_friend_reserve:OnGetHistoryReserveInfoReq, ", send_friends)
  reserveFriendInfo = send_friends
  self:UpdateSingleGameSwitchByRes(auto_reply)
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RESERVE_STATUS_CHANGE)
end
function logic_friend_reserve:SetAutoReplyReq(isAutoRefuse)
  log(bWriteLog and "[v_wllwu] logic_friend_reserve:SetAutoReplyReq, isAutoRefuse = " .. tostring(isAutoRefuse))
  if isAutoRefuse == not bSingleGameOpen then
    return
  end
  local res
  if isAutoRefuse then
    res = 0
  end
  bSingleGameOpen = not isAutoRefuse
  log(bWriteLog and "[v_wllwu] logic_friend_reserve:SetAutoReplyReq res = " .. tostring(res))
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_appointment_friend_auto_reply_req(res)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SingleReserveSwitchClick, isAutoRefuse and 0 or 1)
end
function logic_friend_reserve:OnChangeAutoReplyReq(err_code, res)
  log(bWriteLog and "[v_wllwu] logic_friend_reserve:OnChangeAutoReplyReq, err_code = " .. tostring(err_code) .. " res = " .. tostring(res))
  if err_code ~= 0 then
    return
  end
  self:UpdateSingleGameSwitchByRes(res)
end
function logic_friend_reserve:UpdateSingleGameSwitchByRes(res)
  if res ~= nil then
    bSingleGameOpen = res ~= 0
  else
    bSingleGameOpen = true
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if uPlayerController and slua.isValid(uPlayerController) and uPlayerController.CastUIMsg then
    uPlayerController:CastUIMsg("UIMsg_NotifyAppointmentChange", "ingame")
  end
end
function logic_friend_reserve:NotifyFriends(friends)
  log_tree(bWriteLog and "[v_wllwu] logic_friend_reserve:NotifyFriends", friends)
  if not friends or not next(friends) then
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  for uid, _ in pairs(friends) do
    if LogicFriend.IsMyFriend(uid) then
      self:SendChatReserveMsg(uid, LocUtil.GetLocalizeResStr(44040), true)
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_friend_reserve = class(CModuleBase, nil, logic_friend_reserve)
return Clogic_friend_reserve