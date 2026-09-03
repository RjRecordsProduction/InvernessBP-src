local logic_return_activity = {}
local C_MaxAutoPopTaskUINum = 1
local C_AutoCloseTaskUITime = 5
local C_DailyReward = 8
local specialItemList, scoreRewardList, todayAutoPopTaskTimes, lastAutoPopTime
local lastReqTaskList = 0
local isFightingToLobby, firstBattleGuideShow, returnGuideMatch, isTeamupGuideShow, interactFriends, interactDataList
local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
local _InitData = function()
  specialItemList = nil
  scoreRewardList = nil
  lastAutoPopTime = nil
  todayAutoPopTaskTimes = nil
  lastReqTaskList = 0
  firstBattleGuideShow = nil
  returnGuideMatch = nil
  isTeamupGuideShow = nil
  interactFriends = nil
  interactDataList = nil
end
local _GetRejoinStartIime = function()
  local TableUtil = require("common.table_util")
  return TableUtil.GetTableValue(DataMgr.roleData, "back_user_data", "rejoin_start_time") or 0
end
local _GetAllRewardList = function()
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  local configList = logic_longline_task.GetLevelRewardConfig()
  if not next(configList) then
    log(bWriteLog and " logic_return_activity:_GetAllRewardList configList is nil")
    return
  end
  local newList = {}
  for k, v in pairs(configList) do
    local TableUtil = require("common.table_util")
    local info = TableUtil.CopyTable(v)
    info.level = k
    table.insert(newList, info)
  end
  table.sort(newList, function(a, b)
    return a.level < b.level
  end)
  return newList
end
local _InitTodayPopTaskTimesByRecord = function()
  if todayAutoPopTaskTimes ~= nil then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnActivityAutoPopTask)
  if not (saveData and saveData.lastAutoPopTime) or not saveData.todayAutoPopTaskTimes then
    todayAutoPopTaskTimes = 0
    lastAutoPopTime = 0
    return
  end
  lastAutoPopTime = saveData.lastAutoPopTime
  local curTime = TimeUtil.GetServerTimeInSec()
  todayAutoPopTaskTimes = TimeUtil.IsSameDay(lastAutoPopTime, curTime) and saveData.todayAutoPopTaskTimes or 0
  log(bWriteLog and " _InitTodayPopTaskTimesByRecord, todayAutoPopTaskTimes : " .. tostring(todayAutoPopTaskTimes) .. " lastAutoPopTime = " .. tostring(lastAutoPopTime))
end
function logic_return_activity:_OnRecvChatMsg(_, _, msg)
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  if msg and msg.content and msg.content and msg.content.msgType == chat_macro.friendComebackMsgType then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerChatCache) or {}
    if not saveData[msg.sender_uid] then
      saveData[msg.sender_uid] = {}
    end
    saveData[msg.sender_uid][msg.content.sendTime] = msg.content.other
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerChatCache)
  end
end
function logic_return_activity:GetChatMsgCache(msg)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerChatCache) or {}
  local uid = tonumber(msg.sender_uid)
  if not saveData[uid] then
    return nil
  end
  if not saveData[uid][msg.send_time] then
    return nil
  end
  return saveData[uid][msg.send_time]
end
function logic_return_activity:OnLogin()
  self:ReqGetTaskList()
end
function logic_return_activity:OnLogOut()
  _InitData()
  if self.TeamUpGuideTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.TeamUpGuideTimer)
  end
end
function logic_return_activity:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_CUMULATIVE_ROLEINFO_INTERACT_RECORD, self.OnInteractRecordRsp, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_RETURN_FB_SLAP, self.ShowFBUI, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_RETURN_SIGN_SLAP, self.ShowSignRewardUI, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_RETURN_RECHARGE_REBATE_SLAP, self.ShowRebateUI, self)
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_ON_RECV_CHATMSG, self._OnRecvChatMsg, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_RETURN_GUIDE_SLAP, self.ShowGuideUI, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_RETURN_RECOMMEND_PANEL, self.ShowRecFriendUI, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_RETURN_FB_GUIDE_SLAP, self.ShowFBGuideUI, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_RETURN_MODE_SELECT_SLAP, self.ShowModeSelectUI, self)
end
function logic_return_activity:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and string.format("logic_return_activity:OnPreSwitchGameStatus preState[%s] nextState[%s]", preState, nextState))
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() and self.TeamUpGuideTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.TeamUpGuideTimer)
  end
  if nextState == GameStatus.Lobby then
    local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
    if logic_return_activity_utils.IsActInProgress() then
      local preloadLoadingTable = CDataTable.GetTable("ReturnLoadingConfig")
      local logic_return_activity_first_battle = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_first_battle)
      logic_return_activity_first_battle:ReqFirstBattleConfig()
    end
  end
  if nextState == GameStatus.Fighting then
    self.bIsAfterFighting = false
  end
end
function logic_return_activity:OnPreSwitchGameStatus(preState, nextState)
  if GameStatus.IsPreSwitchEnterFightingFromLobbyOrMainCity(preState, nextState) then
    self.bIsAfterFighting = true
  end
end
function logic_return_activity:ShowRecFriendUI()
  log(bWriteLog and "logic_return_activity:ShowRecFriendUI")
  if not self.bIsAfterFighting then
    log(bWriteLog and "logic_return_activity:ShowRecFriendUI bIsAfterFighting is nil")
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "logic_return_activity:ShowRecFriendUI IsInXMission")
    return
  end
  local common_config = require("client.slua.common.common_config")
  if common_config:IsBlockingPopupTip() then
    log(bWriteLog and "logic_return_activity:ShowRecFriendUI UI responsiveness testing")
    return
  end
  local logic_return_activity_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_guide)
  local guideCfg = logic_return_activity_guide:GetGuideConifg()
  if guideCfg.pop_frd_recommand == 0 then
    log(bWriteLog and "logic_player_return_slap.CanSlapRecommendFriend return of guideCfg.pop_frd_recommand == 0")
    return false
  end
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logic_return_activity_utils.IsActInProgress() then
    log(bWriteLog and "logic_return_activity:ShowRecFriendUI Activity is not open")
    return
  end
  if not DataMgr.roleData.back_user_data.is_friend_recommend then
    log(bWriteLog and "logic_return_activity:ShowRecFriendUI is_friend_recommend is not open")
    return
  end
  local TimeUtil = require("client.common.time_util")
  local startTime = tonumber(DataMgr.roleData.back_user_data.rejoin_start_time)
  local days = math.ceil((TimeUtil.GetServerTimeInSec() - startTime) / 86400)
  if 7 < days then
    log(bWriteLog and "logic_return_activity:ShowRecFriendUI Return days > 7")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local bIsDifferentDate = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eAddRecBackUserShowTime, true)
  if not bIsDifferentDate then
    log(bWriteLog and "logic_return_activity:ShowRecFriendUI Is same day")
    return
  end
  PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eAddRecBackUserShowTime, false)
  UIManager.ShowUI(UIManager.UI_Config.ReturnActivity_Friends_Recommend, true)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Old_Friend_Care_RecommendFriend_UI_Show)
end
function logic_return_activity:ShowTeamUpPopup()
  local common_config = require("client.slua.common.common_config")
  if common_config:IsBlockingPopupTip() then
    log(bWriteLog and "logic_return_activity:ShowTeamUpPopup UI responsiveness testing")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local isShowCheckBox = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerTeamUpGuide, true, 3)
  if not isShowCheckBox then
    return
  end
  if isTeamupGuideShow then
    return
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local msgData = {
    msg = LocUtil.LocalizeResFormat(45003),
    styleType = CommonMsgBoxMgr.SHOW_TYPE_FOUR,
    btnOK = LocUtil.LocalizeResFormat(45481),
    btnCancel = LocUtil.LocalizeResFormat(45480),
    clickOkCallback = function(isCheck)
      if not TeamPlatformSystem.CanRecruit() then
        return
      end
      local logic_recruit_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_recruit_new)
      logic_recruit_new:OpenSendRecruitUI()
      log(bWriteLog and "tlog_report_utils.ReportTLogEvent id = " .. tostring(TLogEventDefine.ReturnActivityGuideSelect))
      log(bWriteLog and "tlog_report_utils.ReportTLogEvent reason = " .. tostring(1))
      log(bWriteLog and "tlog_report_utils.ReportTLogEvent reason = " .. tostring("Recruit"))
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.ReturnActivityGuideSelect, 1, "Recruit")
      if not isCheck then
        return
      end
      PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerTeamUpGuide, false, 3)
    end,
    clickCancelCallback = function(isCheck)
      if LobbySystem.isInMatch then
        ShowNotice(110017)
        return
      end
      local condition = TeamPlatformSystem.GetChatFilterCondition(true)
      local logic_team_platform_proto = require("client.slua.logic.teamup.logic_team_platform_proto")
      logic_team_platform_proto.send_quick_join_team_conscribe_req(condition)
      log(bWriteLog and "tlog_report_utils.ReportTLogEvent id = " .. tostring(TLogEventDefine.ReturnActivityGuideSelect))
      log(bWriteLog and "tlog_report_utils.ReportTLogEvent reason = " .. tostring(1))
      log(bWriteLog and "tlog_report_utils.ReportTLogEvent reason = " .. tostring("QuickJoin"))
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.ReturnActivityGuideSelect, 1, "QuickJoin")
      if not isCheck then
        return
      end
      PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerTeamUpGuide, false, 3)
    end,
    clickCloseCallback = function(isCheck)
      log(bWriteLog and "tlog_report_utils.ReportTLogEvent id = " .. tostring(TLogEventDefine.ReturnActivityGuideSelect))
      log(bWriteLog and "tlog_report_utils.ReportTLogEvent reason = " .. tostring(1))
      log(bWriteLog and "tlog_report_utils.ReportTLogEvent reason = " .. tostring("Close"))
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.ReturnActivityGuideSelect, 1, "Close")
      if not isCheck then
        return
      end
      PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerTeamUpGuide, false, 3)
    end,
    extraData = {
      isShowCheckBox = true,
      checkBoxText = LocUtil.LocalizeResFormat(45004)
    }
  }
  CommonMsgBoxMgr.Show(msgData.styleType, "", msgData.msg, msgData.clickOkCallback, msgData.clickCancelCallback, msgData.btnOK, msgData.btnCancel, msgData.extraData)
  isTeamupGuideShow = true
  log(bWriteLog and "tlog_report_utils.ReportTLogEvent id = " .. tostring(TLogEventDefine.ReturnActivityGuideType))
  log(bWriteLog and "tlog_report_utils.ReportTLogEvent reason = " .. tostring(3))
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.ReturnActivityGuideType, 3)
end
function logic_return_activity:IsNeedShowLoadingGuide(main_mode)
  if main_mode then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    if logic_mode_selection:CheckIsSelectedThemeView(nil) then
      log(bWriteLog and "logic_return_activity:IsNeedShowLoadingGuide theme mode, skip")
      return false
    end
    if not logic_mode_selection:IsClassicRankMode(main_mode) and not logic_mode_selection:IsClassicMatchMode(main_mode) then
      log(bWriteLog and "logic_return_activity:IsNeedShowLoadingGuide not classic mode, skip")
      return false
    end
  end
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logic_return_activity_utils.IsNewActOpen() then
    log(bWriteLog and "logic_return_activity:IsNeedShowLoadingGuide is not newActOpen")
    return
  end
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  if LoadingSystem.GetToLobby() then
    log(bWriteLog and "logic_return_activity:IsNeedShowLoadingGuide is not toFighting")
    return
  end
  local caseID = DataMgr.roleData and DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.loading_plan_id
  if not caseID then
    log(bWriteLog and "logic_return_activity:IsNeedShowLoadingGuide caseID is invaild")
    return
  end
  local data = self:GetLoadingDataByCaseID(caseID)
  if not data then
    log(bWriteLog and "logic_return_activity:IsNeedShowLoadingGuide data is invaild")
    return
  end
  return true
end
function logic_return_activity:OldFriendGiftMailReceive(mail_info)
  if not mail_info then
    return
  end
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  if mail_info.opt.subtype ~= MailMacro.Enum_Mail_SubType.OldFriendGift then
    return
  end
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local TimeUtil = require("client.common.time_util")
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  local msg = {
    text = LocUtil.GetLocalizeResStr(47423),
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.chatNormalMsgType,
    channelType = chat_macro.Channel.channelPrivate
  }
  local msgId = chat_main.CacheMsg(msg)
  ChatHandler.send_chat_req(mail_info.opt.sender_uid, chat_macro.Channel.channelPrivate, msgId, msg)
end
function logic_return_activity:GetInteractFriendList()
  local friends = {}
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  for _, data in ipairs(interactFriends or {}) do
    if LogicFriend.IsMyFriend(data.uid) then
      table.insert(friends, data)
    end
  end
  table.sort(friends, function(a, b)
    local teamNumA = a.interactData and a.interactData.teamup_num or 0
    local teamNumB = b.interactData and b.interactData.teamup_num or 0
    return teamNumA > teamNumB
  end)
  return friends
end
local isForceUpdateFriend = false
function logic_return_activity:IsNeedUpdateInteractFrd()
  local frdRecordData = DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.friend_record_data
  if not frdRecordData then
    log(bWriteLog and "logic_return_activity:IsNeedUpdateInteractFrd is not open")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnFriendRecordUpdate) or {}
  if not saveData[DataMgr.roleData.uid] then
    saveData[DataMgr.roleData.uid] = true
    isForceUpdateFriend = true
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eReturnFriendRecordUpdate)
    return true
  end
  local TimeUtil = require("client.common.time_util")
  if frdRecordData.update_time ~= 0 and TimeUtil.IsSameDay(frdRecordData.update_time, TimeUtil.GetServerTimeInSec()) then
    log(bWriteLog and "logic_return_activity:IsNeedUpdateInteractFrd count is same day no need update")
    return false
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local TableUtil = require("common.table_util")
  local isNeedUpdate = false
  if TableUtil.CountTable(frdRecordData.frd_list) < DataMgr.roleData.back_user_data.friend_record_cfg.show_num then
    log(bWriteLog and "logic_return_activity:IsNeedUpdateInteractFrd count is less then 5 need update")
    isNeedUpdate = true
  end
  for uid, _ in pairs(frdRecordData.frd_list) do
    if not LogicFriend.IsMyFriend(uid) then
      log(bWriteLog and "logic_return_activity:IsNeedUpdateInteractFrd not my friend need update")
      isNeedUpdate = true
      break
    end
  end
  return isNeedUpdate
end
function logic_return_activity:OnInteractRecordRsp(_, _, resUId, resData)
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logic_return_activity_utils.IsNewActOpen() then
    return
  end
  if not UIManager.GetUI(UIManager.UI_Config.ReturnActivity_Reward_UIBP) and not UIManager.GetUI(UIManager.UI_Config.ReturnActivity_WelcomeBack_UIBP) then
    return
  end
  if not interactDataList then
    return
  end
  if resUId then
    interactDataList[resUId] = resData
  end
  if interactFriends and interactFriends[#interactFriends] and interactFriends[#interactFriends].uid and resUId and resUId ~= interactFriends[#interactFriends].uid then
    log(bWriteLog and string.format("UpdateInteractFriendList, resUId:%s", resUId))
    return
  end
  if not self:IsNeedUpdateInteractFrd() then
    for _, data in ipairs(interactFriends) do
      data.interactData = interactDataList[data.uid] and interactDataList[data.uid].data or interactDataList[data.uid]
    end
    EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_LOBBY_COME_BACK_INTERACT_FRD_REDDOT)
    return
  end
  local frdRecordData = DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.friend_record_data
  if not frdRecordData then
    log(bWriteLog and "logic_return_activity:UpdateInteractFriendList is not open")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerFrdRecord) or {}
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if saveData[DataMgr.roleData.uid] and saveData[DataMgr.roleData.uid].time and nowTime > saveData[DataMgr.roleData.uid].time then
    PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerFrdRecord)
  end
  local uids = {}
  for _, data in ipairs(interactFriends) do
    data.interactData = interactDataList[data.uid] and interactDataList[data.uid].data or interactDataList[data.uid]
    if not (not isForceUpdateFriend and frdRecordData.frd_list[data.uid] and frdRecordData.frd_list[data.uid][1]) or frdRecordData.frd_list[data.uid][1] == 0 then
      uids[data.uid] = {
        data.interactData and data.interactData.recent_play_date or 0,
        data.interactData and data.interactData.teamup_num or 0
      }
    else
      uids[data.uid] = {
        frdRecordData.frd_list[data.uid][1],
        frdRecordData.frd_list[data.uid][2]
      }
    end
    local returnFirstTeamupDate = saveData[DataMgr.roleData.uid] and saveData[DataMgr.roleData.uid].uids and saveData[DataMgr.roleData.uid].uids[data.uid] and saveData[DataMgr.roleData.uid].uids[data.uid][3]
    if returnFirstTeamupDate then
      uids[data.uid][3] = returnFirstTeamupDate
    end
  end
  local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
  PlayerReturnHandler.send_backuser_active_frd_sync_req(uids)
  isForceUpdateFriend = false
end
function logic_return_activity:CheckInteractFriendList()
  local logic_season_config = require("client.logic.season.logic_season_config")
  local SeasonCfg = logic_season_config.GetSeasonConfig(DataMgr.season_id - 1)
  if not SeasonCfg then
    logic_season_config.SendSeasonConfigReq(DataMgr.season_id - 1)
    log(bWriteLog and "Return_FriendRecord_UIBP:UpdateLeftUI SeasonCfg is not invaild")
  end
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  interactDataList = {}
  if not self:IsNeedUpdateInteractFrd() then
    local frdList = DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.friend_record_data and DataMgr.roleData.back_user_data.friend_record_data.frd_list
    interactFriends = {}
    if not frdList then
      return
    end
    for uid, _ in pairs(frdList) do
      local interactData = logic_friend_interact_record:GetCumulativeInteractRecordData(uid) or {}
      local info = {uid = uid, interactData = interactData}
      table.insert(interactFriends, info)
    end
    table.sort(interactFriends, function(a, b)
      return (a.interactData.teamup_num or 0) > (b.interactData.teamup_num or 0)
    end)
    for _, data in ipairs(interactFriends) do
      logic_friend_interact_record:RequestCumulativeInteractDataForPlayer(data.uid)
    end
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local TableUtil = require("common.table_util")
  local TimeUtil = require("client.common.time_util")
  local friends = LogicFriend.GetInnerList()
  local serverTime = TimeUtil.GetServerTimeInSec()
  local interval = 1209600
  interactFriends = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, uid in ipairs(friends) do
    local proflie = logic_profile:GetLocalProfile(uid)
    local lastLoginTime = proflie and proflie.lastLoginTime
    if lastLoginTime then
      log(bWriteLog and string.format("UpdateInteractFriendList, proflie.lastLoginTime:%s", TimeUtil.FormatTime_YMD(proflie.lastLoginTime)))
    end
    if lastLoginTime and interval >= serverTime - lastLoginTime then
      local interactData = logic_friend_interact_record:GetCumulativeInteractRecordData(uid) or {}
      if interactData.add_friend_date and interactData.add_friend_date < DataMgr.roleData.back_user_data.rejoin_start_time then
        local info = {uid = uid, interactData = interactData}
        table.insert(interactFriends, info)
      end
    end
  end
  if #interactFriends == 0 then
    EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_LOBBY_COME_BACK_INTERACT_FRD_CHANGE)
    return
  end
  table.sort(interactFriends, function(a, b)
    return (a.interactData.teamup_num or 0) > (b.interactData.teamup_num or 0)
  end)
  if 5 < #interactFriends then
    interactFriends = TableUtil.TableSlice(interactFriends, 1, 5)
  end
  for _, data in ipairs(interactFriends) do
    logic_friend_interact_record:RequestCumulativeInteractDataForPlayer(data.uid)
  end
end
function logic_return_activity:GetLoadingDataByCaseID(caseID)
  if not caseID or caseID == 0 then
    log(bWriteLog and "logic_return_activity:GetLoadingDataByCaseID id = " .. tostring(caseID) .. "is invalid")
    return
  end
  local cfg = {}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerLoading) or {}
  local uid = DataMgr.roleData.uid
  if not saveData[uid] then
    saveData[uid] = {}
  end
  local loadingConfig = CDataTable.GetTable("ReturnLoadingConfig")
  for _, data in ipairs(loadingConfig or {}) do
    if not cfg[data.caseID] then
      cfg[data.caseID] = {}
    end
    if not saveData[uid][data.slapID] then
      saveData[uid][data.slapID] = {}
      saveData[uid][data.slapID].showCount = 0
      cfg[data.caseID][#cfg[data.caseID] + 1] = data
    elseif saveData[uid][data.slapID].showCount < data.showCount then
      cfg[data.caseID][#cfg[data.caseID] + 1] = data
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerLoading)
  log_tree(bWriteLog and "logic_return_activity:GetLoadingDataByCaseID cfg", cfg)
  if #cfg == 0 then
    log(bWriteLog and "logic_return_activity:GetLoadingDataByCaseID cfg == {} id = " .. tostring(caseID))
    return
  end
  if not cfg[caseID] or #cfg[caseID] == 0 then
    log(bWriteLog and "logic_return_activity:GetLoadingDataByCaseID cfg[" .. tostring(caseID) .. "] == {}")
    return
  end
  local randomNum = math.random(1, #cfg[caseID])
  return cfg[caseID][randomNum]
end
function logic_return_activity:ReportReturnGuideMatch()
  if not returnGuideMatch then
    return
  end
  returnGuideMatch = false
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  log(bWriteLog and "tlog_report_utils.ReportTLogEvent id = " .. tostring(TLogEventDefine.ReturnActivityGuideMatch))
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.ReturnActivityGuideMatch)
end
function logic_return_activity:TeamUpGuideShow()
  local userData = DataMgr.roleData.back_user_data
  if not userData then
    log(bWriteLog and "logic_return_activity:TeamUpGuideShow is not backuser")
    return false
  end
  if self.TeamUpGuideTimer then
    return
  end
  local cfg = CDataTable.GetTableData("ReturnParamsConfig", "teamup_waitingtime")
  local time = cfg and cfg.ParamValue and tonumber(cfg.ParamValue)
  local time_ticker = require("common.time_ticker")
  self.TeamUpGuideTimer = time_ticker.AddTimerLoop(0, function()
    log(bWriteLog and "logic_return_activity:TeamUpGuideShow time = " .. tostring(time))
    local isAndroidStackEmpty = UIManager.IsAndroidStackEmpty()
    local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
    local isSlapDone = NewFaceSlapSystem:IsSlapEnd()
    local page = Lobby_Main_Control.curPage
    local isInTeam = TeamUpNewSystem.IsInTeam()
    local isDoneOtherGuide = not self:GetLobbySelectGuideShow()
    if isAndroidStackEmpty and isSlapDone and page == ENUM_LobbyPageType.Mid and not isInTeam and isDoneOtherGuide then
    else
      time = tonumber(cfg.ParamValue)
      return
    end
    if time <= 0 then
      time_ticker.RemoveTimer(self.TeamUpGuideTimer)
      self.TeamUpGuideTimer = nil
      self:ShowTeamUpPopup()
    end
    time = time - 5
  end, 0, 5)
end
function logic_return_activity:GetIsReturnGuideMatch()
  return returnGuideMatch
end
function logic_return_activity:SetIsReturnGuideMatch(value)
  returnGuideMatch = value
end
function logic_return_activity:GetLobbySelectGuideShow()
  local userData = DataMgr.roleData.back_user_data
  if not userData then
    log(bWriteLog and "logic_return_activity:GetLobbySelectGuideShow is not backuser")
    return false
  end
  if self:GetLobbyFirstBattleGuideShow() then
    log(bWriteLog and "logic_return_activity:GetLobbySelectGuideShow is FirstBattleGuideShow")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerSelectGuide) or {}
  if cfg[DataMgr.roleData.back_user_data.rejoin_start_time] then
    log(bWriteLog and "logic_return_activity:GetLobbySelectGuideShow is have open select award")
    return false
  end
  local bIsDifferentDate = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerSelectGuide, true)
  if not bIsDifferentDate then
    log(bWriteLog and "logic_return_activity:GetLobbySelectGuideShow is show today")
    return
  end
  return true
end
function logic_return_activity:GetLobbyFirstBattleGuideShow()
  local userData = DataMgr.roleData.back_user_data
  if not userData then
    log(bWriteLog and "logic_return_activity:GetLobbyFirstBattleGuideShow is not backuser")
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bLevelUnlockSwitchOpen = level_unlock_util:IsSwitchOpen()
  if bLevelUnlockSwitchOpen then
    local menuInfo = logic_mode_selection:GetMenuInfo() or {}
    if next(menuInfo) and DataMgr.roleData.level < menuInfo.sub_menus[1].level_limit then
      log(bWriteLog and "logic_return_activity:GetLobbyFirstBattleGuideShow is lock")
      return false
    end
  end
  if userData.daily_battle_data.status ~= 0 then
    log(bWriteLog and "logic_return_activity:GetLobbyFirstBattleGuideShow - daily_battle_data status is not 0, return false")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local judgeStr = GameStatus.IsInMainCity() and PlayerPrefsSystem.ePlayerPrefsType.ReturnPlayerFirstBattleGuideMainCity or PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerFirstBattleGuide
  local bIsDifferentDate = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(judgeStr, true)
  if not bIsDifferentDate then
    log(bWriteLog and "logic_return_activity:GetLobbyFirstBattleGuideShow already shown today")
    return false
  end
  log(bWriteLog and "logic_return_activity:GetLobbyFirstBattleGuideShow show guide")
  return true
end
local jumpState
function logic_return_activity:GetModeJumpState()
  return jumpState
end
function logic_return_activity:SetModeJumpState(state)
  jumpState = state
end
function logic_return_activity:GetAbtestConfig()
  if DataMgr and DataMgr.roleData and DataMgr.roleData.back_user_data then
    return DataMgr.roleData.back_user_data.client_guide_abtest_cfg
  end
  return nil
end
function logic_return_activity:GetLeftMenuList()
  local tabList = {}
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  if logic_return_activity_utils.IsTabMenuOpen(return_activity_macro.Enum_MenuID.Interact, true) and DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.friend_record_data and next(self:GetInteractFriendList()) then
    table.insert(tabList, return_activity_macro.Enum_MenuID.Interact)
  end
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  if AssemblyActivitySystem.HasActivity() then
    table.insert(tabList, return_activity_macro.Enum_MenuID.Assembly)
  end
  return tabList
end
function logic_return_activity:GetMenuList()
  local tabList = {}
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  table.insert(tabList, return_activity_macro.Enum_MenuID.NewLevelReward)
  if logic_return_activity_utils.IsTabMenuOpen(return_activity_macro.Enum_MenuID.DailySignIn) then
    table.insert(tabList, return_activity_macro.Enum_MenuID.DailySignIn)
  end
  local logic_return_activity_first_battle = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_first_battle)
  if logic_return_activity_first_battle:IsShowEntry() then
    table.insert(tabList, return_activity_macro.Enum_MenuID.FirstBattle)
  end
  if logic_return_activity_utils.IsTabMenuOpen(return_activity_macro.Enum_MenuID.RankGoal) then
    table.insert(tabList, return_activity_macro.Enum_MenuID.RankGoal)
  elseif logic_return_activity_utils.IsGameRewardOpen() then
    table.insert(tabList, return_activity_macro.Enum_MenuID.Privilege)
  end
  if logic_return_activity_utils.IsTabMenuOpen(return_activity_macro.Enum_MenuID.Discount) and DataMgr.roleData.back_user_data.topup_rebate_plan_id then
    table.insert(tabList, return_activity_macro.Enum_MenuID.Discount)
  end
  if logic_return_activity_utils.IsTabMenuOpen(return_activity_macro.Enum_MenuID.Newpost) then
    table.insert(tabList, return_activity_macro.Enum_MenuID.Newpost)
  end
  local logic_player_return_login = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_player_return_login)
  local questionnaire_activity_id = tonumber(logic_player_return_login:GetQuestionnaireActivityId())
  log(bWriteLog and "logic_return_activity:GetMenuList questionnaire_activity_id is " .. tostring(questionnaire_activity_id))
  if questionnaire_activity_id and questionnaire_activity_id ~= 0 then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    local activity = ActivityNewSystem.GetActivityByID(questionnaire_activity_id)
    if activity and next(activity) then
      log_tree("logic_return_activity:GetMenuList Questionnaire data", activity)
      local TimeUtil = require("client.common.time_util")
      local now = TimeUtil.GetServerTimeInSec()
      if now > activity.StartTime and now < activity.EndTime then
        table.insert(tabList, return_activity_macro.Enum_MenuID.Questionnaire)
      end
    end
  end
  return tabList
end
function logic_return_activity:GetItemInfoBySelectIndex(itemMap, index)
  if type(itemMap) ~= "table" or not index then
    return
  end
  for k, v in pairs(itemMap) do
    if v.index == index then
      v.item_id = k
      return v
    end
  end
  return nil
end
function logic_return_activity:GetSpecialItemList()
  if specialItemList ~= nil and 0 < #specialItemList then
    return specialItemList
  end
  local configList = _GetAllRewardList()
  if not configList or #configList <= 0 then
    log(bWriteLog and " logic_return_activity:GetSpecialItemList configList is nil")
    return
  end
  specialItemList = {}
  local totalScore = 0
  for i = 1, #configList do
    local itemData = configList[i]
    local score = itemData.score or 0
    if itemData.special_display == 1 then
      local TableUtil = require("common.table_util")
      local rewardData = TableUtil.CopyTable(itemData)
      rewardData.level = itemData.level
      rewardData.score = totalScore
      table.insert(specialItemList, rewardData)
    end
    totalScore = totalScore + score
  end
  return specialItemList
end
function logic_return_activity:Get310RewardItemList()
  if specialItemList ~= nil and 0 < #specialItemList then
    return specialItemList
  end
  local configList = _GetAllRewardList()
  if not configList or #configList <= 0 then
    log(bWriteLog and " logic_return_activity:GetSpecialItemList configList is nil")
    return
  end
  specialItemList = {}
  local totalScore = 0
  for i = 1, #configList do
    local itemData = configList[i]
    local score = itemData.score or 0
    local TableUtil = require("common.table_util")
    local rewardData = TableUtil.CopyTable(itemData)
    rewardData.level = itemData.level
    rewardData.score = totalScore
    table.insert(specialItemList, rewardData)
    totalScore = totalScore + score
  end
  table.remove(specialItemList, 1)
  return specialItemList
end
function logic_return_activity:Get310SelectedRewardList()
  local selectRewardList = {}
  local rewardList = self:Get310RewardItemList()
  local isNewVersion = false
  for k, v in ipairs(rewardList or {}) do
    if v.select_default == 2 or v.select_default == 3 then
      isNewVersion = true
    end
    if v.select_default == 1 or v.select_default == 2 or v.select_default == 3 then
      for k1, v1 in pairs(v.items) do
        table.insert(selectRewardList, {
          level = k,
          priority = v.select_default,
          item_id = k1,
          num = v1.num,
          valid_hours = v1.valid_hours
        })
      end
    end
  end
  table.sort(selectRewardList, function(a, b)
    if a.priority == b.priority then
      return a.level < b.level
    else
      return a.priority > b.priority
    end
  end)
  return selectRewardList, isNewVersion
end
function logic_return_activity:Get400ARewardItemList()
  if self.reward_item_list then
    return self.reward_item_list
  end
  local TableUtil = require("common.table_util")
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  self.reward_item_list = {}
  local back_user_data = LobbySystem.roleData and LobbySystem.roleData.back_user_data
  if not back_user_data or not back_user_data.longline_select_items then
    log("logic_return_activity:Get400ARewardItemList back_user_data or longline_select_items is nil, return empty list")
    return self.reward_item_list
  end
  table.insert(self.reward_item_list, TableUtil.CopyTable(back_user_data.longline_select_items[0]))
  self.reward_item_list[1].level = 0
  for index, v in ipairs(back_user_data.longline_select_items) do
    local data = TableUtil.CopyTable(v)
    data.level = index
    table.insert(self.reward_item_list, data)
  end
  local total_score = 0
  for _, v in ipairs(self.reward_item_list) do
    v.start_score = total_score
    v.end_score = total_score + v.score
    total_score = total_score + v.score
  end
  self.reward_item_list[#self.reward_item_list].is_last = true
  return self.reward_item_list
end
function logic_return_activity:Get400ASpecialRewardItemList()
  log(bWriteLog and "logic_return_activity:Get400ASpecialRewardItemList. start getting special reward list")
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  local curLevel = logic_longline_task.curLevel
  local specialRewardList = {}
  local rewardList = self:Get400ARewardItemList()
  if not rewardList or #rewardList == 0 then
    log_warning_format("logic_return_activity:Get400ASpecialRewardItemList. reward list is empty, curLevel:%s", curLevel)
    return specialRewardList
  end
  local foundTeamReward, lastTeamReward
  local specialDisplayItems = {}
  for _, rewardItem in ipairs(rewardList) do
    if next(rewardItem.team_reward) then
      lastTeamReward = rewardItem
      local bIReceived = logic_longline_task.totalSummaryData and logic_longline_task.totalSummaryData.team_battle_reward_status and logic_longline_task.totalSummaryData.team_battle_reward_status[rewardItem.level]
      if not foundTeamReward and not bIReceived then
        foundTeamReward = rewardItem
        log_format("logic_return_activity:Get400ASpecialRewardItemList. found incomplete team reward, level:%s status:%s curLevel:%s", rewardItem.level, rewardStatus, curLevel)
      end
    end
    if rewardItem.special_display == 1 then
      table.insert(specialDisplayItems, rewardItem)
    end
  end
  if foundTeamReward then
    table.insert(specialRewardList, foundTeamReward)
    log_format("logic_return_activity:Get400ASpecialRewardItemList. added incomplete team reward, level:%s", foundTeamReward.level)
  elseif lastTeamReward then
    table.insert(specialRewardList, lastTeamReward)
    log_format("logic_return_activity:Get400ASpecialRewardItemList. all team rewards completed, added last team reward, level:%s", lastTeamReward.level)
  else
    log(bWriteLog and "logic_return_activity:Get400ASpecialRewardItemList. no team rewards found in reward list")
  end
  for _, item in ipairs(specialDisplayItems) do
    table.insert(specialRewardList, item)
  end
  log_format("logic_return_activity:Get400ASpecialRewardItemList. completed, total special rewards:%s curLevel:%s", #specialRewardList, curLevel)
  return specialRewardList
end
function logic_return_activity:GetSuitWithVehicleItemList(rewardList)
  if type(rewardList) ~= "table" or #rewardList <= 0 then
    log(bWriteLog and " logic_return_activity:GetSuitWithVehicleItemList rewardList error")
    return
  end
  local suitIdList = {}
  local vehicleIdList = {}
  local weaponIdList = {}
  for i = 1, #rewardList do
    local itemId = rewardList[i].item_id
    local itemCfg = CDataTable.GetTableData("Item", itemId)
    if itemCfg ~= nil then
      local temp = {itemID = itemId}
      if itemCfg.ItemType == ENUM_ITEM_TYPE.Extra or itemCfg.ItemType == ENUM_ITEM_TYPE.Backpack then
        table.insert(suitIdList, temp)
      elseif itemCfg.ItemType == ENUM_ITEM_TYPE.Aircraft_Skin or itemCfg.ItemType == ENUM_ITEM_TYPE.Vehicle then
        table.insert(vehicleIdList, temp)
      elseif itemCfg.ItemType == ENUM_ITEM_TYPE.Weapon then
        table.insert(weaponIdList, temp)
      end
    end
  end
  return suitIdList, vehicleIdList, weaponIdList
end
function logic_return_activity:EnterMainUI(menuId, bFromClick)
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logic_return_activity_utils.IsActInProgress() then
    log(bWriteLog and " logic_return_activity:EnterMainUI activity end ")
    ShowNotice(4002)
    EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_CLOSE)
    return
  end
  local logic_main_city_music = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_music)
  logic_main_city_music:OnReturnShow()
  if bFromClick then
    local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
    local ParamTable = ui_show_queue_config.GetParamTable(nil, "Click")
    UIManager.ShowUI(UIManager.UI_Config.ReturnActivity_Main_UIBP, menuId, ParamTable)
  else
    UIManager.ShowUI(UIManager.UI_Config.ReturnActivity_Main_UIBP, menuId)
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local TimeUtil = require("client.common.time_util")
  if TimeUtil.IsSameDay(TimeUtil.GetServerTimeInSec(), DataMgr.roleData.back_user_data.rejoin_start_time) then
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.ReturnActivityMain, 1)
  else
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.ReturnActivityMain, 2)
  end
end
function logic_return_activity:GetRedDataByMenuId(menuId)
  if not menuId then
    return
  end
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local menuInfo = return_activity_macro.MenuEntranceInfoList[menuId]
  if not menuInfo or not menuInfo.red_node_name then
    log(bWriteLog and " logic_return_activity:GetRedDataByMenuId menuInfo is nil, menuId = " .. tostring(menuId))
    return
  end
  local ReturnRedpointData = require("client.slua.logic.return_activity.logic_return_activity_redpoint_data")
  return ReturnRedpointData.GetRedDataByNodeName(menuInfo.red_node_name)
end
function logic_return_activity:IsAllDayTaskRewardReceived()
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  local taskList = logic_longline_task.GetDayTaskListData()
  if type(taskList) ~= "table" or next(taskList) == nil then
    log(bWriteLog and " logic_return_activity:IsAllDayTaskRewardReceived taskList is nil")
    return true
  end
  for _, v in pairs(taskList) do
    if v.status ~= logic_longline_task.E_Reward_State.HasGot then
      return false
    end
  end
  return true
end
function logic_return_activity:IsAllSignRewardReceived()
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local TableUtil = require("common.table_util")
  local curDay = TableUtil.GetTableValue(logic_player_return.login_reward_info, "cur_day") or 0
  local gotIndexList = TableUtil.GetTableValue(logic_player_return.login_reward_info, "got_indexs") or {}
  if #gotIndexList ~= C_DailyReward and curDay > #gotIndexList then
    return false
  end
  return true
end
function logic_return_activity:AutoPopReturnGiftUI(promise)
  local topUIName = UIManager.GetTopUIName()
  if topUIName ~= UIManager.UI_Config.ReturnActivity_Main_UIBP.keyName then
    promise:Resolve()
    return
  end
  if not self:CheckShowReturnGiftUI() then
    log(bWriteLog and " logic_return_activity:AutoPopTaskUI AllDayTaskRewardReceived")
    promise:Resolve()
    return false
  end
  UIManager.ShowUI(UIManager.UI_Config.Return_Packs_Popup_UIBP, promise)
end
function logic_return_activity:AutoPopTaskUI(promise)
  if self:IsAllDayTaskRewardReceived() then
    log(bWriteLog and " logic_return_activity:AutoPopTaskUI AllDayTaskRewardReceived")
    promise:Resolve()
    return false
  end
  _InitTodayPopTaskTimesByRecord()
  if todayAutoPopTaskTimes >= C_MaxAutoPopTaskUINum then
    log(bWriteLog and " logic_return_activity:AutoPopTaskUI todayAutoPopTaskTimes reach limited")
    promise:Resolve()
    return false
  end
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  self:OpenUIByMenuId(return_activity_macro.Enum_MenuID.Task, C_AutoCloseTaskUITime, promise)
  local TimeUtil = require("client.common.time_util")
  lastAutoPopTime = TimeUtil.GetServerTimeInSec()
  todayAutoPopTaskTimes = todayAutoPopTaskTimes + 1
  local cfg = {lastAutoPopTime = lastAutoPopTime, todayAutoPopTaskTimes = todayAutoPopTaskTimes}
  log(bWriteLog and " logic_return_activity.AutoPopTaskUI, todayAutoPopTaskTimes : " .. tostring(todayAutoPopTaskTimes) .. " lastAutoPopTime = " .. tostring(lastAutoPopTime))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eReturnActivityAutoPopTask)
end
function logic_return_activity:AutoPopSignUI()
  local topUIName = UIManager.GetTopUIName()
  if topUIName ~= UIManager.UI_Config.ReturnActivity_Reward_UIBP.keyName then
    return
  end
  if self:IsAllSignRewardReceived() then
    log(bWriteLog and " logic_return_activity:AutoPopTaskUI AllDayTaskRewardReceived")
    return false
  end
  UIManager.ShowUI(UIManager.UI_Config.ReturnActivity_7days_UIBP)
end
function logic_return_activity:GetDayTaskList()
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  local taskInfo = logic_longline_task.GetDayTaskListData()
  local taskList = {}
  for k, v in pairs(taskInfo) do
    v.task_no = k
    table.insert(taskList, v)
  end
  if 0 < #taskList then
    table.sort(taskList, function(a, b)
      return a.task_no < b.task_no
    end)
  end
  return taskList
end
function logic_return_activity:GetDayTaskTitle(taskType, para1, para2)
  log(bWriteLog and " logic_return_activity:GetDayTaskTitle, para1 = " .. tostring(para1))
  log(bWriteLog and " logic_return_activity:GetDayTaskTitle, para2 = " .. tostring(para2))
  para1 = para1 or 0
  para2 = para2 or 0
  local des = ""
  local taskItem = CDataTable.GetTableData("ComeBackTask", taskType)
  if not taskItem then
    log(bWriteLog and " logic_return_activity:GetDayTaskTitle taskItem is nil, taskType = " .. tostring(taskType))
    return des
  end
  local strId = taskItem.showText
  if strId == "" or para1 == 0 then
    log(bWriteLog and " logic_return_activity:GetDayTaskTitle strId is nil, taskType = " .. tostring(taskType))
    return des
  end
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  if taskType == return_activity_macro.Enum_DayTaskType.SurviveTime then
    para1 = math.ceil(para1 / 60)
  end
  if para2 ~= 0 then
    des = LocUtil.LocalizeResFormat(strId, para1, para2)
  else
    des = LocUtil.LocalizeResFormat(strId, para1)
  end
  if taskType == return_activity_macro.Enum_DayTaskType.TeamUp then
    local isLongLine = self:ReturnActivityABTest()
    if isLongLine then
      des = LocUtil.LocalizeResFormat(86321, des)
    end
  end
  return des
end
function logic_return_activity:RefreshDayTaskList()
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if TimeUtil.IsSameDay(nowTime, lastReqTaskList) then
    return
  end
  log(bWriteLog and " logic_return_activity RefreshDayTaskList")
  self:ReqGetTaskList()
end
function logic_return_activity:OpenUIByMenuId(menuId, ...)
  if not menuId then
    return
  end
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local menuInfo = return_activity_macro.MenuEntranceInfoList[menuId]
  if not menuInfo or not menuInfo.uiConfig then
    log(bWriteLog and " logic_return_activity:OpenUIByMenuId menuInfo is nil, menuId is " .. tostring(menuId))
    return
  end
  UIManager.ShowUI(menuInfo.uiConfig, ...)
end
function logic_return_activity:CloseAllUI()
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local menuEntranceInfoList = return_activity_macro.MenuEntranceInfoList
  for _, menuEntranceInfo in pairs(menuEntranceInfoList or {}) do
    local ui_module = menuEntranceInfo.ui_module
    if ui_module then
      local ui = UIManager.GetUI(UIManager.UI_Config[ui_module])
      if ui then
        UIManager.CloseUI(UIManager.UI_Config[ui_module])
      end
    end
  end
end
function logic_return_activity:ShowFBUI()
  local logic_player_return_slap = require("client.slua.logic.player_return.logic_player_return_slap")
  if not logic_player_return_slap.CanShowFBUI() then
    log(bWriteLog and "logic_return_activity:ShowFBUI can't show ui")
    return
  end
  if not self.isShowFBSlap then
    UIManager.ShowUI(UIManager.UI_Config.ReturnActivity_First_UIBP)
    self.isShowFBSlap = true
  end
end
function logic_return_activity:ShowSignRewardUI()
  UIManager.ShowUI(UIManager.UI_Config.ReturnActivity_7days02_UIBP)
end
function logic_return_activity:ShowRebateUI()
  UIManager.ShowUI(UIManager.UI_Config.Return_Packs_Popup_UIBP)
end
function logic_return_activity:ShowModeSelectUI()
  UIManager.ShowUI(UIManager.UI_Config.Return_ModeSelect_UIBP)
end
function logic_return_activity:ShowFBGuideUI()
  UIManager.ShowUI(UIManager.UI_Config.ReturnActivity_Openning_Page_Slap_UIBP)
end
function logic_return_activity:ShowGuideUI()
  local logic_return_activity_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_guide)
  logic_return_activity_guide:ShowNewGuide()
end
function logic_return_activity:CheckShowReturnGiftUI()
  if not DataMgr.roleData.back_user_data then
    return false
  end
  local chestID = DataMgr.roleData.back_user_data.welcome_gift_dropid
  if not chestID then
    return false
  end
  return true
end
function logic_return_activity:CheckShowReturnGuide()
  local logic_player_return_slap = require("client.slua.logic.player_return.logic_player_return_slap")
  if not logic_player_return_slap.bIsShowReturnFlag then
    log(bWriteLog and "logic_return_activity:CheckShowReturnGuide return of logic_player_return_slap.bIsShowReturnFlag is false")
    return
  end
  local logic_return_activity_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_guide)
  if not logic_return_activity_guide:HasValidGuideUI() then
    log(bWriteLog and "logic_return_activity:CheckShowReturnGuide return of HasValidGuideUI is false")
    return false
  end
  return true
end
function logic_return_activity:ReturnActivityABTest()
  local bIsA = false
  if LobbySystem.roleData.back_user_data and LobbySystem.roleData.back_user_data.longline_select_items then
    for _, v in pairs(LobbySystem.roleData.back_user_data.longline_select_items) do
      if v.team_cnt and v.team_cnt > 0 then
        bIsA = true
        break
      end
    end
  end
  log(bWriteLog and string.format("logic_return_activity:ReturnActivityABTest bIsA = %s", tostring(bIsA)))
  return bIsA
end
function logic_return_activity:IsMultipleChoicePlan()
  local bIsNewPlan = false
  if LobbySystem.roleData.back_user_data and LobbySystem.roleData.back_user_data.longline_select_items then
    for _, v in pairs(LobbySystem.roleData.back_user_data.longline_select_items) do
      if v.select_items and next(v.select_items) then
        bIsNewPlan = true
        break
      end
    end
  end
  log(bWriteLog and string.format("logic_return_activity:IsMultipleChoicePlan bIsNewPlan = %s", tostring(bIsNewPlan)))
  return bIsNewPlan
end
function logic_return_activity:IsReturnTimeOK(saveData)
  if not saveData then
    return false
  end
  local recordTime = saveData.rejoinStartTime or 0
  local curRejoinTime = _GetRejoinStartIime()
  if recordTime ~= curRejoinTime then
    log(bWriteLog and " logic_return_activity:IsReturnTimeOK, recordTime = " .. tostring(recordTime) .. " curRejoinTime = " .. tostring(curRejoinTime))
    return false
  end
  return true
end
function logic_return_activity:UpdateNewPostEnterSaveData()
  local info = {
    isEnter = true,
    rejoinStartTime = _GetRejoinStartIime()
  }
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(info, PlayerPrefsSystem.ePlayerPrefsType.eReturnActivityNewPostEnter)
  local ReturnRedpointData = require("client.slua.logic.return_activity.logic_return_activity_redpoint_data")
  ReturnRedpointData:ClearNewArrivalsFirstEnterRedData()
end
function logic_return_activity:GetInitialAnimIndex()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnActivityAnimIndexRecord)
  if not saveData or not self:IsReturnTimeOK(saveData) then
    return
  end
  return tonumber(saveData.animIndex)
end
function logic_return_activity:UpdateAnimIndexSaveData(index)
  local info = {
    animIndex = index,
    rejoinStartTime = _GetRejoinStartIime()
  }
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(info, PlayerPrefsSystem.ePlayerPrefsType.eReturnActivityAnimIndexRecord)
end
function logic_return_activity:CheckAutoReplyMsg(messageList)
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local msgData
  for i = #messageList, 1, -1 do
    local tempMsgData = messageList[i]
    if tempMsgData.msgType == chat_macro.friendComebackMsgType and tempMsgData.sender_uid ~= DataMgr.roleData.uid then
      msgData = tempMsgData
      break
    end
  end
  if not msgData then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerAutoReplyMsg) or {}
  if saveData and saveData[msgData.sender_uid] and saveData[msgData.sender_uid][msgData.send_time] then
    return false
  end
  if not saveData[msgData.sender_uid] then
    saveData[msgData.sender_uid] = {}
  end
  saveData[msgData.sender_uid][msgData.send_time] = true
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerAutoReplyMsg)
  return true
end
function logic_return_activity:ReqGetTaskList()
  local TimeUtil = require("client.common.time_util")
  lastReqTaskList = TimeUtil.GetServerTimeInSec()
  local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
  PlayerReturnHandler.send_backuser_get_task_list_req()
end
function logic_return_activity:FetchAllMessage()
  log(bWriteLog and " logic_return_activity:FetchAllMessage")
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logic_return_activity_utils.IsActInProgress() then
    log(bWriteLog and " logic_return_activity:FetchAllMessage activity end ")
    return
  end
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local openMenuIdList = self:GetLeftMenuList()
  if 0 < #openMenuIdList then
    for i = 1, #openMenuIdList do
      local menuId = openMenuIdList[i]
      local menuInfo = return_activity_macro.MenuEntranceInfoList[menuId]
      if menuInfo and menuInfo.red_dot_require_func ~= nil then
        menuInfo.red_dot_require_func()
      end
    end
  end
  local isDayTaskOpen = logic_return_activity_utils.IsTabMenuOpen(return_activity_macro.Enum_MenuID.Task)
  if isDayTaskOpen then
    self:RefreshDayTaskList()
  end
end
function logic_return_activity:send_backuser_get_friend_recommend_req()
  local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
  PlayerReturnHandler.send_backuser_get_friend_recommend_req()
end
function logic_return_activity:on_backuser_get_friend_recommend_res(ret, is_friend_recommend)
  log(bWriteLog and "logic_return_activity:on_backuser_get_friend_recommend_res ret = " .. tostring(ret))
  log(bWriteLog and "logic_return_activity:on_backuser_get_friend_recommend_res is_friend_recommend = " .. tostring(is_friend_recommend))
  if ret ~= 0 then
    return
  end
  if DataMgr.roleData and DataMgr.roleData.back_user_data then
    DataMgr.roleData.back_user_data.is_friend_recommend = false
  end
end
function logic_return_activity:on_backuser_active_frd_sync_res(ret, uid_info_list)
  log(bWriteLog and "logic_return_activity:on_backuser_active_frd_sync_res ret = " .. tostring(ret))
  log_tree(bWriteLog and "logic_return_activity:on_backuser_active_frd_sync_res uid_info_list", uid_info_list)
  DataMgr.roleData.back_user_data.friend_record_data.frd_list = uid_info_list
  local TimeUtil = require("client.common.time_util")
  DataMgr.roleData.back_user_data.friend_record_data.update_time = TimeUtil.GetServerTimeInSec()
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_LOBBY_COME_BACK_INTERACT_FRD_CHANGE)
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_LOBBY_COME_BACK_INTERACT_FRD_REDDOT)
end
function logic_return_activity:on_backuser_frd_active_reward_res(ret, frd_uid, itemlist)
  log(bWriteLog and "logic_return_activity:on_backuser_frd_active_reward_res ret = " .. tostring(ret))
  log_tree(bWriteLog and "logic_return_activity:on_backuser_frd_active_reward_res itemlist", itemlist)
  log(bWriteLog and "logic_return_activity:on_backuser_frd_active_reward_res frd_uid = " .. tostring(frd_uid))
  DataMgr.roleData.back_user_data.friend_record_data.got_indexs[frd_uid] = true
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  local list = {}
  for itemId, num in pairs(itemlist) do
    local data = {res_id = itemId, count = num}
    table.insert(list, data)
    logic_longline_task.curScore = logic_longline_task.curScore + num
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(list)
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_LOBBY_COME_BACK_INTERACT_FRD_CHANGE)
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_LOBBY_COME_BACK_INTERACT_FRD_REDDOT)
end
function logic_return_activity:on_back_user_score_change_notify(ret_level, ret_score)
  log(bWriteLog and " logic_return_activity:on_back_user_score_change_notify, ret_level is:" .. tostring(ret_level) .. "; ret_score = " .. tostring(ret_score))
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  if ret_level then
    logic_longline_task.curLevel = ret_level
  end
  if ret_score then
    logic_longline_task.curScore = ret_score
  end
  EventSystem:postEvent(EVENTTYPE_LONGLINE_TASK, EVENTID_LONGLINE_TASK_UPDATE_REWARD)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_return_activity = class(CModuleBase, nil, logic_return_activity)
return Clogic_return_activity