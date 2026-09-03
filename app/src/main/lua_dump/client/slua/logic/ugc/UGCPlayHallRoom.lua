local UGCPlayHallRoom = {}
local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
local TimeUtil = require("client.common.time_util")
local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local E_UGCJoinPlayHallType = Config_UGC.E_UGCJoinPlayHallType
local E_PlayHallRoomInfoChangeOpt = Config_UGC.E_PlayHallRoomInfoChangeOpt
local E_UGCPlayHallRoomState = Config_UGC.E_UGCPlayHallRoomState
local E_UGCSmartStartHeatLevelState = Config_UGC.E_UGCSmartStartHeatLevelState
local E_UGCGameStartType = Config_UGC.E_UGCGameStartType
local RoomQuickChatCDTime = 3
local IgnoreTime = 300
local ReminderPopWindowWaitTime = 60
local ReminderPopWindowWaitTime_Room = 180
local GameJoinWaitingTime = 1.2
local bGLOBALOPEN = true
function UGCPlayHallRoom:DefineAndResetData()
  self.AllMatchInfo = nil
  self.ReminderPopWindowTimer = nil
  self.StartPlayTimer = nil
  self.CurSelectRoomID = -1
  self.LastJoinRoomReqTime = 0
  self.LastSendChatTime = 0
  self.IgnoreList = {}
  self.InviteCDList = {}
  self.LastInviteFriendTime = 0
  self.ModHotStatMap = {}
  self.StartGameCallBack = {}
  self.AllPlayerInfo = {}
  self.LastQuickStartTime = 0
  self.OnMatchSelectPostAction = {}
  self.LastSelectRoomTime = 0
  self.LastReqHotStatTime = 0
  self.QuickGameJoinWaitingTimer = nil
  self.bInPendingMatchState = false
  self.PendingMatchParamRecord = nil
  self.PendingPlayHallParamRecord = nil
  self.AutoCancelPendingMatchStateTimer = nil
end
function UGCPlayHallRoom:OnInitialize()
end
function UGCPlayHallRoom:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_MATCH_ENTER_MOD, self.onUGCMatchModSelect, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_SHOW_PLAY_HALL_ROOM_UI, self.OnShowRoomUI, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, self.OnLoadingFinish, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_BEGIN, self.OnBeginLoading, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS_MATCHING_OR_NOT, self.OnMatchUpdateStatusMatchingOrNot, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_BUY_PASS_RSP, self.OnWOWPassBuyRsp, self)
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_SUBCRIBE_TOPIC_CHANNEL_SUCCESS, self.OnSubscribeTopicChannelSuccess, self)
end
function UGCPlayHallRoom:OnLogin(bReLogin)
  print(bWriteLog and "UGCPlayHallRoom:OnLogin", bReLogin)
  local UGCMatchHandler = require("client.network.Protocol.UGCMatchHandler")
  UGCMatchHandler.send_ugc_my_play_hall_room_req()
end
function UGCPlayHallRoom:OnLogOut()
  print(bWriteLog and "UGCPlayHallRoom:OnLogOut")
  self:ClearMapHotStatReqTimerTick()
  self:ClearReminderPopWindowTimer()
  self:ClearStartPlayTick()
  self:ClearQuickGameJoinWaitingTimer()
  self:ClearPendingMatchState()
  self.MatchInfo_Login = nil
  self:ExitAllRoom()
  self:ClearUI()
  self.ModHotStatMap = {}
end
function UGCPlayHallRoom:OnPreSwitchGameStatus(preState, nextState)
  print(bWriteLog and "UGCPlayHallRoom:OnPreSwitchGameStatus", preState, nextState)
  self:ClearMapHotStatReqTimerTick()
  self:ClearStartPlayTick()
  self.MatchInfo_Login = nil
  self:ExitAllRoom()
  self:ClearUI()
  self.ModHotStatMap = {}
end
function UGCPlayHallRoom:OnLoadingFinish()
  print(bWriteLog and "UGCPlayHallRoom:OnLoadingFinish", self.MatchInfo_Login)
  if self.MatchInfo_Login then
    self:CreateAllPlayHallRoom(self.MatchInfo_Login)
    self.MatchInfo_Login = nil
  end
end
function UGCPlayHallRoom:OnBeginLoading()
  print(bWriteLog and "UGCPlayHallRoom:OnBeginLoading")
  self:ClearReminderPopWindowTimer()
  self:ClearQuickGameJoinWaitingTimer()
  self:ClearPendingMatchState()
end
function UGCPlayHallRoom:OnMatchUpdateStatusMatchingOrNot(_, _, Status)
  print(bWriteLog and "UGCPlayHallRoom:OnMatchUpdateStatusMatchingOrNot", Status, self.bCreateQuickStartReminder)
  if Status == ENUM_MatchStatus.Not then
    if self.bCreateQuickStartReminder then
      self:ClearReminderPopWindowTimer()
    end
    self:ClearQuickGameJoinWaitingTimer()
    local PendingPlayHallParamRecord = self.PendingPlayHallParamRecord
    if PendingPlayHallParamRecord then
      self.bInPendingMatchState = self:SendJoinPlayHallRoomReq(PendingPlayHallParamRecord.ModID, nil, PendingPlayHallParamRecord.Param)
      self.PendingPlayHallParamRecord = nil
    else
      self.bInPendingMatchState = false
    end
    if not self.bInPendingMatchState then
      self:ClearAutoCancelPendingMatchStateTimer()
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PENDING_MATCH_CANCEL)
    end
  elseif Status == ENUM_MatchStatus.Matching and self.PendingMatchParamRecord then
    self:StartQuickGameJoinWaiting()
    self.PendingMatchParamRecord = nil
  end
end
function UGCPlayHallRoom:OnWOWPassBuyRsp()
  print(bWriteLog and "UGCPlayHallRoom:OnWOWPassBuyRsp")
  local SelfPlayerInfo = self.AllPlayerInfo[tonumber(DataMgr.roleData.uid)]
  if SelfPlayerInfo then
    local wow_pass = SelfPlayerInfo.wow_pass
    if wow_pass then
      wow_pass.is_buy = true
      wow_pass.limit_num = wow_pass.max_limit_num
    end
  end
end
function UGCPlayHallRoom:OnPostSwitchGameStatus(preState, nextState)
end
function UGCPlayHallRoom:OnDestroy()
  print(bWriteLog and "UGCPlayHallRoom:OnDestroy")
  self:ClearMapHotStatReqTimerTick()
  self:ClearStartPlayTick()
  self.MatchInfo_Login = nil
  self:ExitAllRoom()
  self:ClearUI()
  self.ModHotStatMap = {}
end
function UGCPlayHallRoom:OnEnterGame()
  print(bWriteLog and "UGCPlayHallRoom:OnEnterGame")
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  LogicUGCMatch:SetUGCWaitingEnterGame(false)
end
function UGCPlayHallRoom:OnEnterGameFail()
  print(bWriteLog and "UGCPlayHallRoom:OnEnterGameFail")
  if self.ExitReason == "start_success" then
    self:ClearUI()
  end
end
function UGCPlayHallRoom:IsSystemOpen()
  return bGLOBALOPEN and LobbySystem.CheckOpen(92076)
end
function UGCPlayHallRoom:IsModPanelEntryOpen()
  return bGLOBALOPEN and LobbySystem.CheckOpen(92080)
end
function UGCPlayHallRoom:CreateMapHotStatReqTimerTick()
  if not self.HotStatTimer then
    self.HotStatTimer = self:AddTimerLoop(0.5, function()
      local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
      local ZoneID = ZoneSystem.nChooseZoneID
      local ModID = LogicUGCMatch:GetMatchModID()
      print(bWriteLog and "UGCPlayHallRoom:CreateMapHotStatReqTimerTick checkHotStatTimer", ModID, ZoneID)
      if ModID and 0 < ModID then
        self:SendHotStatReq(ZoneID, ModID)
      end
    end, TIMER_INFINITE, 60)
  end
end
function UGCPlayHallRoom:ClearMapHotStatReqTimerTick()
  if self.HotStatTimer then
    self:RemoveTimer(self.HotStatTimer)
  end
  self.HotStatTimer = nil
end
function UGCPlayHallRoom:OnModHotStatRsp(zone_id, mod_id, hot_stat)
  if not hot_stat then
    return
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local MatchModID = LogicUGCMatch:GetMatchModID()
  print(bWriteLog and "UGCPlayHallRoom:OnModHotStatRsp", zone_id, mod_id, MatchModID, hot_stat.start_type, hot_stat.heat_level)
  self:SetHotStatInfo(hot_stat, mod_id)
  if self.StartGameCallBack then
    local CallBack = self.StartGameCallBack[mod_id]
    if CallBack then
      CallBack(hot_stat, mod_id)
      self.StartGameCallBack[mod_id] = nil
    end
  end
  if MatchModID == mod_id then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_MATCHMOD_HOT_STAT_CHANGE, MatchModID, hot_stat)
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MOD_HOTSTAT_RSP, zone_id, mod_id, hot_stat)
end
function UGCPlayHallRoom:SetHotStatInfo(HotStat, ModID)
  print(bWriteLog and "UGCPlayHallRoom:SetHotStatInfo", ModID, HotStat.start_type, HotStat.heat_level)
  HotStat.time = TimeUtil.GetServerTimeInSec()
  self.ModHotStatMap[ModID] = HotStat
end
function UGCPlayHallRoom:onUGCMatchModSelect(_, _, MatchModID)
  print(bWriteLog and "UGCPlayHallRoom:onUGCMatchModSelect", MatchModID, self.ModHotStatMap[MatchModID])
  if self.ModHotStatMap[MatchModID] then
    log_tree(bWriteLog and "UGCPlayHallRoom:onUGCMatchModSelect HotStat", self.ModHotStatMap[MatchModID])
  end
  for Index, HandleFunc in ipairs(self.OnMatchSelectPostAction) do
    HandleFunc()
  end
  self.OnMatchSelectPostAction = {}
end
function UGCPlayHallRoom:GetModHotStatByID(ModID)
  if ModID then
    return self.ModHotStatMap[ModID]
  end
end
function UGCPlayHallRoom:GetModStartTypeByID(ModID)
  local HotStat = self:GetModHotStatByID(ModID)
  local StartType
  if HotStat then
    StartType = HotStat.start_type
  end
  return StartType or E_UGCGameStartType.Normal
end
function UGCPlayHallRoom:GetMatchModHeatLevelByID(ModID)
  local HotStat = self:GetModHotStatByID(ModID)
  local HeatLevel
  if HotStat then
    HeatLevel = HotStat.heat_level
  end
  return HeatLevel or E_UGCSmartStartHeatLevelState.QuickStart
end
function UGCPlayHallRoom:OnShowRoomUI(_, _, From)
  print(bWriteLog and "UGCPlayHallRoom:OnShowRoomUI", From)
  EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_NEWBIE_GUIDE_INTERRUPT)
  UIManager.ForceBackToLobby()
  if self.AllMatchInfo then
    local CurRoomInfo = self.AllMatchInfo[self.CurSelectRoomID]
    if CurRoomInfo then
      UIManager.ShowUI(UIManager.UI_Config.UGCMatchRoom_Main, CurRoomInfo)
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_PlayHall_Room_Click_ReturnRoom, 0, From)
    end
  end
end
function UGCPlayHallRoom:GetRoomInfo(RoomID)
  RoomID = RoomID or self.CurSelectRoomID
  if self.AllMatchInfo then
    local MatchInfo = self.AllMatchInfo[RoomID]
    if MatchInfo then
      return MatchInfo.RoomInfo
    end
  end
end
function UGCPlayHallRoom:GetRoomModeInfo(RoomID)
  RoomID = RoomID or self.CurSelectRoomID
  if not self.AllMatchInfo then
    return
  end
  local RoomInfo = self.AllMatchInfo[RoomID].RoomInfo
  if not RoomInfo then
    return
  end
  local ModID = RoomInfo.mod_id
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModInfo = LogicUGC:GetModByAllCache(tonumber(ModID))
  if ModInfo then
    return ModInfo.pub_mod_meta
  else
    local result_metatable = RoomInfo.result_metatable
    return {
      setting = result_metatable.mod_setting,
      base = {
        template_id = result_metatable.template_id
      },
      mod_id = result_metatable.ugc_pub_mod_id
    }
  end
end
function UGCPlayHallRoom:GetCurrentRoomPlayerList(RoomID)
  RoomID = RoomID or self.CurSelectRoomID
  if not self.AllMatchInfo then
    return
  end
  local MatchInfo = self.AllMatchInfo[RoomID]
  if not MatchInfo then
    log_warning(bWriteLog and "UGCPlayHallRoom:GetCurrentRoomPlayerList MatchInfo Is Nil", RoomID)
    return
  end
  return MatchInfo.MembersList
end
function UGCPlayHallRoom:IsPlayerInRoom(UID)
  if self.AllMatchInfo then
    local RoomInfo = self.AllMatchInfo[self.CurSelectRoomID].RoomInfo
    if RoomInfo then
      return RoomInfo.members[tonumber(UID)]
    end
  end
end
function UGCPlayHallRoom:GetAllRoomChatMessage(RoomID)
  RoomID = RoomID or self.CurSelectRoomID
  if not self.AllMatchInfo then
    return
  end
  local MatchInfo = self.AllMatchInfo[RoomID]
  if not MatchInfo then
    log_warning(bWriteLog and "UGCPlayHallRoom:GetCurrentRoomPlayerList MatchInfo Is Nil", RoomID)
    return
  end
  return MatchInfo.RoomChatMessage or {}
end
function UGCPlayHallRoom:GetCurrentSelectRoomID()
  return self.CurSelectRoomID
end
function UGCPlayHallRoom:GetRoomMatchInfo(RoomID)
  RoomID = RoomID or self.CurSelectRoomID
  if not self.AllMatchInfo then
    return
  end
  return self.AllMatchInfo[RoomID]
end
function UGCPlayHallRoom:GetFastestMatchInfo()
  if not self.AllMatchInfo then
    return
  end
  local FastestMatchInfo
  local Delta = 999
  for RoomID, MatchInfo in pairs(self.AllMatchInfo) do
    local MembersList = MatchInfo.MembersList or {}
    local ModInfo = self:GetRoomModeInfo(RoomID)
    local AutoStartInfo = MatchInfo.CurAutoStartInfo
    local MaxRoomPlayerNum = AutoStartInfo and AutoStartInfo.CurPlayerNum or ModInfo.setting.max_num
    if Delta > MaxRoomPlayerNum - #MembersList then
      Delta = MaxRoomPlayerNum - #MembersList
      Fastest    end
  end
  return FastestMatchInfo
end
function UGCPlayHallRoom:GetMatchNum()
  local AllMatchInfo = self.AllMatchInfo
  if not AllMatchInfo then
    return 0
  end
  local Num = 0
  for RoomID, _ in pairs(AllMatchInfo) do
    Num = Num + 1
  end
  return Num
end
function UGCPlayHallRoom:GetMatchArray()
  local AllMatchInfo = self.AllMatchInfo
  if not AllMatchInfo then
    return {}
  end
  local Array = {}
  for RoomID, MatchInfo in pairs(AllMatchInfo) do
    Array[#Array + 1] = RoomID
  end
  table.sort(Array, function(RoomIDA, RoomIDB)
    local MatchInfoA, MatchInfoB = AllMatchInfo[RoomIDA], AllMatchInfo[RoomIDB]
    return MatchInfoA.CreateTime < MatchInfoB.CreateTime
  end)
  return Array
end
function UGCPlayHallRoom:GetLongestRoom()
  local createTime, roomInfo
  for roomId, info in pairs(self.AllMatchInfo) do
    if not createTime or createTime > info.CreateTime then
      createTime = info.CreateTime
      roomInfo = info
    end
  end
  return roomInfo
end
function UGCPlayHallRoom:CreatePlayHallRoom(RoomInfo)
  if not self.AllMatchInfo then
    self.AllMatchInfo = {}
  end
  if not RoomInfo then
    log_warning("UGCPlayHallRoom:CreatePlayHallRoom RoomInfo is Nil")
    return
  end
  local RoomID = RoomInfo.ph_room_id
  if self.AllMatchInfo[RoomID] then
    print(bWriteLog and "UGCPlayHallRoom:CreatePlayHallRoom Player is Already in Room", RoomID)
    return
  end
  self.CurSelect  self.AllMatchInfo[RoomID] = {
    RoomID = RoomID,
    RoomInfo = RoomInfo,
    RoomChatMessage = {},
    CreateTime = TimeUtil.GetServerTimeInSec(),
    RecruitNum = 0
  }
  self.ExitReason = nil
  self:AddRoomPlayer(RoomID, RoomInfo.members, true)
  if RoomInfo.state == E_UGCPlayHallRoomState.Idle then
    self:CreateAutoStartTimerTick(RoomID)
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:BatchGetModInfo({
    RoomInfo.mod_id
  }, LogicUGC.C_ModListTypes.play_hall)
  local UGCMatchRoom_Main = UIManager.GetUI(UIManager.UI_Config.UGCMatchRoom_Main)
  if UGCMatchRoom_Main then
    UGCMatchRoom_Main:RefreshUI()
  else
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_CREATE, RoomInfo)
  LobbySystem.isInMatch = true
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  LogicUGCMatch:SetUGCWaitingEnterGame(true)
  self:CreateReminderPopWindow(false, RoomInfo.mod_id)
end
function UGCPlayHallRoom:CreateAllPlayHallRoom(RoomList)
  print(bWriteLog and "UGCPlayHallRoom:CreateAllPlayHallRoom")
  self:ExitAllRoom()
  for _, RoomInfo in pairs(RoomList) do
    self:CreatePlayHallRoom(RoomInfo)
  end
end
function UGCPlayHallRoom:CreateAutoStartTimerTick(RoomID)
  if not self.AllMatchInfo then
    return
  end
  self:ClearAutoStartTimerTick(RoomID)
  local MatchInfo = self.AllMatchInfo[RoomID]
  if not MatchInfo then
    log_warning(bWriteLog and "UGCPlayHallRoom:CreateAutoStartTimerTick MatchInfo is Nil!", RoomID)
    return
  end
  MatchInfo.AutoStartTimer = self:AddTimerLoop(0, function()
    local CurAutoStartInfo = self:GetCurAutoStartInfo(RoomID)
    if CurAutoStartInfo then
      MatchInfo.      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_AUTOSTART_INFO_CHANGE_TICK, RoomID, MatchInfo.CurAutoStartInfo)
      if CurAutoStartInfo.NewStageIndex ~= MatchInfo.CurStageIndex then
        MatchInfo.CurStageIndex = CurAutoStartInfo.NewStageIndex
        EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_AUTOSTART_INFO_CHANGE, RoomID, MatchInfo.CurAutoStartInfo)
      end
    end
  end, TIMER_INFINITE, 1)
end
function UGCPlayHallRoom:GetCurAutoStartInfo(RoomID)
  local MatchInfo = self.AllMatchInfo[RoomID]
  if not MatchInfo then
    return
  end
  local RoomInfo = MatchInfo.RoomInfo
  local StartConfig = RoomInfo.start_cfg
  local IdleStateBeginTime = RoomInfo.state_begin_time
  local Delta = TimeUtil.GetServerTimeInSec() - IdleStateBeginTime
  local TimeLeft, NextPlayerNum, CurPlayerNum, TimeLeftDelta, NewStageIndex
  if Delta < StartConfig.time_stage0 then
    TimeLeft, NextPlayerNum, CurPlayerNum = StartConfig.time_stage0, StartConfig.thr_stage1, StartConfig.thr_stage0
    NewStageIndex = 0
    TimeLeftDelta = StartConfig.time_stage0 - Delta
  elseif Delta < StartConfig.time_stage1 then
    TimeLeft, NextPlayerNum, CurPlayerNum = StartConfig.time_stage1 - StartConfig.time_stage0, StartConfig.thr_stage2, StartConfig.thr_stage1
    NewStageIndex = 1
    TimeLeftDelta = StartConfig.time_stage1 - Delta
  elseif Delta < StartConfig.time_stage2 then
    TimeLeft, NextPlayerNum, CurPlayerNum = StartConfig.time_stage2 - StartConfig.time_stage1, StartConfig.thr_stage3, StartConfig.thr_stage2
    NewStageIndex = 2
    TimeLeftDelta = StartConfig.time_stage2 - Delta
  elseif Delta < StartConfig.time_stage3 then
    TimeLeft, NextPlayerNum, CurPlayerNum = StartConfig.time_stage3 - StartConfig.time_stage2, StartConfig.thr_stage3, StartConfig.thr_stage3
    NewStageIndex = 3
    TimeLeftDelta = StartConfig.time_stage3 - Delta
  end
  if NewStageIndex then
    return {
      TimeLeft = TimeLeft,
      TimeLeftDelta = TimeLeftDelta,
      NextPlayerNum = NextPlayerNum,
      CurPlayerNum = CurPlayerNum,
          }
  end
end
function UGCPlayHallRoom:ClearAutoStartTimerTick(RoomID)
  if self.AllMatchInfo then
    local MatchInfo = self.AllMatchInfo[RoomID]
    if MatchInfo then
      if MatchInfo.AutoStartTimer then
        self:RemoveTimer(MatchInfo.AutoStartTimer)
      end
      MatchInfo.AutoStartTimer = nil
      MatchInfo.CurStageIndex = -1
      if MatchInfo.RecruitCDTimer then
        self:RemoveTimer(MatchInfo.RecruitCDTimer)
      end
      MatchInfo.RecruitCDTimer = nil
      MatchInfo.RecruitNum = 0
    end
  end
end
function UGCPlayHallRoom:ExitRoomByRoomID(RoomID, NotifyInfo)
  if not self.AllMatchInfo then
    return
  end
  self:ClearAutoStartTimerTick(RoomID)
  self.AllMatchInfo[RoomID] = nil
  local Reason = NotifyInfo and NotifyInfo.reason
  print(bWriteLog and "UGCPlayHallRoom:ExitRoomByRoomID", RoomID, Reason)
  local NextRoomID = next(self.AllMatchInfo)
  if NextRoomID then
    if self.CurSelectRoomID == RoomID then
      self:SelectRoom(NextRoomID)
    end
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_EXIT, RoomID, Reason)
  else
    self:ExitAllRoom(NotifyInfo)
  end
end
function UGCPlayHallRoom:ExitAllRoom(NotifyInfo)
  print(bWriteLog and "UGCPlayHallRoom:ExitAllRoom")
  local AllMatchInfo = self.AllMatchInfo
  if AllMatchInfo then
    for RoomID, _ in pairs(AllMatchInfo) do
      self:ClearAutoStartTimerTick(RoomID)
      AllMatchInfo[RoomID] = nil
    end
    LobbySystem.isInMatch = false
  end
  self:ClearReminderPopWindowTimer()
  self:ClearTipsShowTimer()
  self.AllMatchInfo = nil
  self.CurSelectRoomID = -1
  self.AllPlayerInfo = {}
  self.LastQuickStartTime = 0
  local Reason = NotifyInfo and NotifyInfo.reason
  print(bWriteLog and "UGCPlayHallRoom:ExitAllRoom", Reason)
  if Reason == "exit" then
    ShowNotice(792516)
  elseif Reason == "start_fail" then
    ShowNotice(655721)
    self:ClearStartPlayTick()
  elseif Reason == "timeout" then
    ShowNotice(77915)
    self:ClearStartPlayTick()
  elseif Reason == "start_success" then
  end
  if Reason ~= "start_success" then
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    LogicUGCMatch:SetUGCWaitingEnterGame(false)
  end
  self.Exit  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_EXIT_ALL, Reason)
end
function UGCPlayHallRoom:AddRoomPlayer(RoomID, NewPlayersMap, bInit)
  if not self.AllMatchInfo then
    return
  end
  local MatchInfo = self.AllMatchInfo[RoomID]
  if not MatchInfo then
    log_warning(bWriteLog and "UGCPlayHallRoom:AddRoomPlayer MatchInfo Is Nil", RoomID)
    return
  end
  local MembersList = self:GetCurrentRoomPlayerList(RoomID)
  MembersList = MembersList or {}
  local RoomInfo = MatchInfo.RoomInfo
  local MembersMap = RoomInfo.members
  for UID, PlayerInfo in pairs(NewPlayersMap) do
    MembersList[#MembersList + 1] = UID
    PlayerInfo.    MembersMap[UID] = PlayerInfo
    self:SetPlayerInfo(UID, PlayerInfo)
  end
  MatchInfo.  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_PLAYER_CHANGE, RoomID, NewPlayersMap, bInit)
end
function UGCPlayHallRoom:SetPlayerInfo(UID, PlayerInfo, NewRoomID)
  self.AllPlayerInfo[UID] = PlayerInfo
  for RoomID, MatchInfo in pairs(self.AllMatchInfo) do
    if MatchInfo and RoomID ~= NewRoomID then
      local RoomInfo = MatchInfo.RoomInfo
      if RoomInfo.members[UID] then
        RoomInfo.members[UID] = PlayerInfo
      end
    end
  end
  if UID == tonumber(DataMgr.roleData.uid) then
    local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
    if logic_ugc_WOWPass:IsBuyElite() then
      local wow_pass = PlayerInfo.wow_pass
      if wow_pass then
        wow_pass.is_buy = true
        wow_pass.limit_num = wow_pass.max_limit_num
      end
    end
  end
end
function UGCPlayHallRoom:RemoveRoomPlayer(RoomID, DeletePlayersMap)
  if not self.AllMatchInfo then
    return
  end
  local MatchInfo = self.AllMatchInfo[RoomID]
  if not MatchInfo then
    log_warning(bWriteLog and "UGCPlayHallRoom:RemoveRoomPlayer MatchInfo is Nil!", RoomID)
    return
  end
  local RoomInfo = MatchInfo.RoomInfo
  if RoomInfo.ph_room_id ~= RoomID then
    return
  end
  local MembersList = self:GetCurrentRoomPlayerList(RoomID)
  local MembersMap = RoomInfo.members
  for UID, _ in pairs(DeletePlayersMap) do
    MembersMap[UID] = nil
    for Index, MemberUID in ipairs(MembersList) do
      if MemberUID == UID then
        table.remove(MembersList, Index)
        break
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_PLAYER_CHANGE, RoomID)
end
function UGCPlayHallRoom:ChangeRoomState(RoomID, ChangeInfo)
  if not ChangeInfo then
    return
  end
  local MatchInfo = self.AllMatchInfo and self.AllMatchInfo[RoomID]
  if not MatchInfo then
    log_warning(bWriteLog and "UGCPlayHallRoom:ChangeRoomState MatchInfo is Nil!", RoomID)
    return
  end
  print(bWriteLog and "UGCPlayHallRoom:ChangeRoomState", RoomID, ChangeInfo.state)
  log_tree(bWriteLog and "UGCPlayHallRoom:ChangeRoomState ChangeInfo", ChangeInfo)
  local RoomInfo = MatchInfo.RoomInfo
  local State = ChangeInfo.state or E_UGCPlayHallRoomState.Default
  RoomInfo.state = State
  RoomInfo.state_begin_time = ChangeInfo.state_begin_time or 0
  RoomInfo.countdown_time = ChangeInfo.countdown_time or 0
  if State == E_UGCPlayHallRoomState.Idle then
    self:CreateAutoStartTimerTick(RoomID)
  elseif State == E_UGCPlayHallRoomState.CountDown then
    self:ClearAutoStartTimerTick(RoomID)
    self:ClearMapHotStatReqTimerTick()
    self:ClearReminderPopWindowTimer()
    self:CreateStartPlayTick(ChangeInfo.countdown_time, RoomID)
  elseif State == E_UGCPlayHallRoomState.Playing then
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_STATE_CHANGE, RoomID, State)
end
function UGCPlayHallRoom:ReceiveChatMessage(RoomID, ChatInfo)
  if not self.AllMatchInfo then
    log_warning(bWriteLog and "UGCPlayHallRoom:ReceiveChatMessage AllMatchInfo is Nil!", RoomID)
    return
  end
  local MatchInfo = self.AllMatchInfo[RoomID]
  if not MatchInfo then
    log_warning(bWriteLog and "UGCPlayHallRoom:ReceiveChatMessage MatchInfo is Nil!", RoomID)
    return
  end
  local RoomChatMessage = MatchInfo.RoomChatMessage
  RoomChatMessage[#RoomChatMessage + 1] = ChatInfo
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_NEW_CHAT, RoomID, ChatInfo)
end
function UGCPlayHallRoom:CreateStartPlayTick(CountTime, RoomID)
  self:ClearStartPlayTick()
  if not self.AllMatchInfo then
    return
  end
  local MatchInfo = self.AllMatchInfo[RoomID]
  if not MatchInfo then
    log_warning(bWriteLog and "UGCPlayHallRoom:CreateStartPlayTick MatchInfo is Nil!")
    return
  end
  self.StartTime = CountTime
  self.StartPlayTimer = self:AddTimerLoop(0, function()
    if self.StartTime <= 0 then
      UIManager.ShowUI(UIManager.UI_Config.UGCMatchRoom_Start)
    end
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_START_TICK, RoomID, self.StartTime)
    self.StartTime = self.StartTime - 1
  end, CountTime + 1, 1)
  self.StartRoomInfo = MatchInfo.RoomInfo
end
function UGCPlayHallRoom:ClearStartPlayTick()
  if self.StartPlayTimer then
    self:RemoveTimer(self.StartPlayTimer)
  end
  self.StartPlayTimer = nil
end
function UGCPlayHallRoom:ClearUI()
  print(bWriteLog and "UGCPlayHallRoom:ClearUI")
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_DESTROY_UI)
end
function UGCPlayHallRoom:QuitPlayHallMainRoomUI()
  local UGCMatchRoomMainUI = UIManager.GetUI(UIManager.UI_Config.UGCMatchRoom_Main)
  if UGCMatchRoomMainUI then
    UGCMatchRoomMainUI:QuitRoomUI()
  end
end
function UGCPlayHallRoom:SetAutoClickEntryState()
  self:AddMatchSelectPostAction(function()
    self:AutoClickMainMatchEntry()
  end)
end
function UGCPlayHallRoom:AutoClickMainMatchEntry()
  if GameStatus.IsInMainCity() then
    local mainCityMatchEntry = UIManager.GetUI(UIManager.UI_Config.MainCity_Lobby_Main_Match_Entry_UIBP)
    if mainCityMatchEntry then
      mainCityMatchEntry:OnClickButton_Entry()
    end
  else
    local Lobby_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
    if Lobby_Main_UIBP then
      local matchEntry = Lobby_Main_UIBP:GetChildUI(UIManager.UI_Config.match_new_entry)
      if matchEntry then
        matchEntry:OnClickEntry()
      end
    end
  end
end
function UGCPlayHallRoom:AutoClickMainModeEntry()
  print(bWriteLog and "UGCPlayHallRoom:AutoClickMainModeEntry")
  GlobalData.JumpUrl("game://?module=1008403&menuList=900")
end
function UGCPlayHallRoom:AddMatchSelectPostAction(Handle)
  table.insert(self.OnMatchSelectPostAction, Handle)
end
function UGCPlayHallRoom:CreateReminderPopWindow(bQuickStart, ModID)
  self:ClearReminderPopWindowTimer()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInTeam() and not TeamUpNewSystem.IsTeamLeader() then
    return
  end
  self.bCreateQuickStartReminder = bQuickStart
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  if not bQuickStart then
    print(bWriteLog and "UGCPlayHallRoom:CreateReminderPopWindow", ModID)
    self.ReminderPopWindowTimer = self:AddTimer(ReminderPopWindowWaitTime_Room, function()
      local MatchModHeatLevel = self:GetMatchModHeatLevelByID(ModID)
      print(bWriteLog and "UGCPlayHallRoom:CreateReminderPopWindow Exec", MatchModHeatLevel, ModID, ReminderPopWindowWaitTime_Room)
      if not MatchModHeatLevel then
        return
      end
      local Msg, OkBtnText, OnClickOkCallBack
      if MatchModHeatLevel == E_UGCSmartStartHeatLevelState.QuickStart then
        Msg = LocUtil.GetLocalizeResStr(792525)
        OkBtnText = LocUtil.GetLocalizeResStr(792528)
        function OnClickOkCallBack()
          local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
          local TLogStr = string.format("{ModID:%d RemindType:%d}", ModID, 1)
          tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_PlayHall_Room_Click_Recommend_PopUp_Click, 0, TLogStr)
          self:SendExitRoomReqByRoomID(nil, true)
        end
      else
        Msg = LocUtil.GetLocalizeResStr(792529)
        OkBtnText = LocUtil.GetLocalizeResStr(792530)
        function OnClickOkCallBack()
          local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
          local TLogStr = string.format("{ModID:%d RemindType:%d}", ModID, 2)
          tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_PlayHall_Room_Click_Recommend_PopUp_Click, 0, TLogStr)
          self:SendExitRoomReqByRoomID()
          self:AddTimerOnce(0, function()
            self:AutoClickMainModeEntry()
          end)
        end
      end
      CommonMsgBoxMgr.Show(4, LocUtil.GetLocalizeResStr(792526), Msg, OnClickOkCallBack, function()
      end, OkBtnText, LocUtil.GetLocalizeResStr(792527), {
        autoCloseTime = 60,
        autoCloseWithoutCallback = true,
        hideAutoCloseRemainTime = true
      })
    end)
  else
    self.ReminderPopWindowTimer = self:AddTimer(ReminderPopWindowWaitTime, function()
      local MatchModHeatLevel = self:GetMatchModHeatLevelByID(ModID)
      print(bWriteLog and "UGCPlayHallRoom:CreateReminderPopWindow Exec", MatchModHeatLevel, ModID, ReminderPopWindowWaitTime)
      CommonMsgBoxMgr.Show(4, LocUtil.GetLocalizeResStr(792526), LocUtil.GetLocalizeResStr(792531), function()
        local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
        local TLogStr = string.format("{ModID:%d RemindType:%d}", ModID or 0, 3)
        tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_PlayHall_Room_Click_Recommend_PopUp_Click, 0, TLogStr)
        self:QuitPlayHallMainRoomUI()
        LobbySystem.on_match_cancel_req()
        self:AddTimerOnce(0, function()
          local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
          LogicUGCMatch:MarkPendingBackToWoWPlayhall()
        end)
      end, function()
      end, LocUtil.GetLocalizeResStr(792532), LocUtil.GetLocalizeResStr(792527), {
        autoCloseTime = 60,
        autoCloseWithoutCallback = true,
        hideAutoCloseRemainTime = true
      })
    end)
  end
end
function UGCPlayHallRoom:ClearReminderPopWindowTimer()
  if self.ReminderPopWindowTimer then
    self:RemoveTimer(self.ReminderPopWindowTimer)
  end
  self.ReminderPopWindowTimer = nil
  self.bCreateQuickStartReminder = nil
end
function UGCPlayHallRoom:ClearTipsShowTimer()
  if self.TipsTImer then
    self:RemoveTimer(self.TipsTImer)
  end
  self.TipsTImer = nil
end
function UGCPlayHallRoom:StartRecruitCDTimer(RoomID)
  local MatchInfo = self.AllMatchInfo[RoomID]
  if not MatchInfo then
    log_warning(bWriteLog and "UGCPlayHallRoom:StartRecruitCDTimer MatchInfo is Nil!", RoomID)
    return
  end
  MatchInfo.RecruitNum = MatchInfo.RecruitNum + 1
  if MatchInfo.RecruitNum <= 3 then
    MatchInfo.RecruitCDTimer = self:AddTimerOnce(60, function()
      if MatchInfo and MatchInfo.RecruitCDTimer then
        self:RemoveTimer(MatchInfo.RecruitCDTimer)
        MatchInfo.RecruitCDTimer = nil
      end
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_RECRUIT_CD_CHANGE, RoomID)
    end)
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_RECRUIT_CD_CHANGE, RoomID)
end
function UGCPlayHallRoom:CheckRecruitCD(RoomID)
  local MatchInfo = self.AllMatchInfo[RoomID]
  if not MatchInfo then
    return false
  end
  return not MatchInfo.RecruitCDTimer
end
function UGCPlayHallRoom:CheckRecruitNum(RoomID)
  local MatchInfo = self.AllMatchInfo[RoomID]
  if MatchInfo then
    return MatchInfo.RecruitNum <= 3
  end
end
function UGCPlayHallRoom:GetCurMatchStartPlayerNumByID(RoomID)
  local MatchInfo = self:GetRoomMatchInfo(RoomID)
  if not MatchInfo then
    return
  end
  local MembersList = MatchInfo.MembersList
  local ModInfo = self:GetRoomModeInfo(RoomID)
  local AutoStartInfo = MatchInfo.CurAutoStartInfo
  local MaxRoomPlayerNum = AutoStartInfo and AutoStartInfo.CurPlayerNum or ModInfo.setting and ModInfo.setting.max_num or 0
  return #MembersList, MaxRoomPlayerNum
end
function UGCPlayHallRoom:SelectRoom(RoomID)
  print(bWriteLog and "UGCPlayHallRoom:SelectRoom", self.CurSelectRoomID, RoomID)
  if self.CurSelectRoomID == RoomID then
    return
  end
  local CurTime = TimeUtil.GetServerTimeInSec()
  local Delta = CurTime - self.LastSelectRoomTime
  if Delta < 1 then
    ShowNotice(8500487)
    return
  end
  self.CurSelect  self.LastSelectRoomTime = CurTime
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_SELECT_ROOM, RoomID)
end
function UGCPlayHallRoom:StartUGCMatch(CallBack)
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local ZoneID = ZoneSystem.nChooseZoneID
  local ModID = LogicUGCMatch:GetMatchModID()
  print(bWriteLog and "UGCPlayHallRoom:StartUGCMatch", ModID, ZoneID)
  if ModID and 0 < ModID then
    local UGCModHandler = require("client.network.Protocol.UGCModHandler")
    UGCModHandler.send_ugc_mod_hot_stat_req(ZoneID, ModID)
    self.StartGameCallBack[ModID] = CallBack
  end
end
function UGCPlayHallRoom:StartModWaiting(ModID)
  print(bWriteLog and "UGCPlayHallRoom:StartModWaiting", ModID)
  local HotStat = self:GetModHotStatByID(ModID)
  local WowPass = self:GetMemberPassInfo()
  local LimitNum = WowPass and WowPass.limit_num or 1
  if LimitNum > self:GetMatchNum() then
    local HeatLevel = HotStat and HotStat.heat_level
    if HeatLevel == E_UGCSmartStartHeatLevelState.QuickStart then
      UIManager.ShowUI(UIManager.UI_Config.UGCMatchRoom_Select_Popup, ModID)
    else
      local Logic_UGC_Share = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_share)
      local ext_info = Logic_UGC_Share:GetShareData()
      self:SendJoinPlayHallRoomReq(ModID, nil, {share_ext = ext_info})
    end
  else
    UIManager.ShowUI(UIManager.UI_Config.UGCMatchRoom_ClearRoom_Popup)
  end
end
function UGCPlayHallRoom:GetMemberInfo(UID)
  return self.AllPlayerInfo[tonumber(UID or DataMgr.roleData.uid)]
end
function UGCPlayHallRoom:GetMemberPassInfo(UID)
  local MemberInfo = self.AllPlayerInfo[tonumber(UID or DataMgr.roleData.uid)]
  if MemberInfo then
    return MemberInfo.wow_pass
  end
end
function UGCPlayHallRoom:GetTeamPassInfo()
  local PassInfo
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 and not TeamUpNewSystem.IsTeamLeader() then
    PassInfo = self:GetMemberPassInfo(TeamUpNewSystem.GetTeamLeader())
  else
    PassInfo = self:GetMemberPassInfo()
  end
  return PassInfo
end
function UGCPlayHallRoom.GetWoWPassIconPath(Profile)
  print(bWriteLog and "UGCPlayHallRoom.GetWoWPassIconPath Profile:" .. tostring(Profile))
  if Profile == nil then
    return nil
  end
  if Profile.wow_pass == nil then
    return nil
  end
  if Profile.wow_pass.is_buy then
    local BuyTimes = Profile.wow_pass.accumulate_buy_times or 1
    local WowPassSignCfgs = CDataTable.GetTable("WowPassSign")
    local CurSignCfg
    for ID, SignCfg in pairs(WowPassSignCfgs) do
      if BuyTimes >= SignCfg.AccBuyCount then
        if CurSignCfg == nil then
          Cur        elseif CurSignCfg.AccBuyCount < SignCfg.AccBuyCount then
          Cur        end
      end
    end
    if CurSignCfg ~= nil then
      return CurSignCfg.SignIconPath
    end
  end
  return nil
end
function UGCPlayHallRoom:GetRoomInfoByModID(ModID)
  if self.AllMatchInfo then
    for RoomID, MatchInfo in pairs(self.AllMatchInfo) do
      local RoomInfo = MatchInfo.RoomInfo
      if RoomInfo and RoomInfo.mod_id == ModID then
        return RoomInfo
      end
    end
  end
end
function UGCPlayHallRoom:IsInReqRoomCD()
  local CD = TimeUtil.GetServerTimeInSec() - self.LastJoinRoomReqTime
  print(bWriteLog and "UGCPlayHallRoom:IsInReqRoomCD", CD)
  return CD < 4
end
function UGCPlayHallRoom:IsInFriendInviteCD(UID)
  local Delta = TimeUtil.GetServerTimeInSec() - self.LastInviteFriendTime
  if Delta < 3 then
    return true
  end
  local LastTime = self.InviteCDList[UID]
  if LastTime then
    return TimeUtil.GetServerTimeInSec() - LastTime < 5
  end
end
function UGCPlayHallRoom:GetStartMatchModID()
  local RoomInfo = self.StartRoomInfo
  if RoomInfo then
    return RoomInfo.mod_id
  end
end
function UGCPlayHallRoom:SetPendingMatchParamRecord(ModID, Param)
  self.PendingMatchParamRecord = {ModID = ModID, Param = Param}
  self.bInPendingMatchState = true
  self:ClearAutoCancelPendingMatchStateTimer()
  self.AutoCancelPendingMatchStateTimer = self:AddTimerOnce(5, function()
    self:ClearAutoCancelPendingMatchStateTimer()
    if self.bInPendingMatchState then
      self.bInPendingMatchState = false
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PENDING_MATCH_CANCEL)
    end
  end)
end
function UGCPlayHallRoom:ClearQuickGameJoinWaitingTimer()
  if self.QuickGameJoinWaitingTimer then
    self:RemoveTimer(self.QuickGameJoinWaitingTimer)
  end
  self.QuickGameJoinWaitingTimer = nil
end
function UGCPlayHallRoom:ClearAutoCancelPendingMatchStateTimer()
  if self.AutoCancelPendingMatchStateTimer then
    self:RemoveTimer(self.AutoCancelPendingMatchStateTimer)
  end
  self.AutoCancelPendingMatchStateTimer = nil
end
function UGCPlayHallRoom:CheckPendingMatchState()
  return self.bInPendingMatchState
end
function UGCPlayHallRoom:ClearPendingMatchState()
  self.bInPendingMatchState = false
  self.PendingMatchParamRecord = nil
  self.PendingPlayHallParamRecord = nil
end
function UGCPlayHallRoom:SendJoinPlayHallRoomReq(ModID, JoinType, Param)
  print(bWriteLog and "UGCPlayHallRoom:SendJoinPlayHallRoomReq", ModID, JoinType)
  if self:IsInReqRoomCD() then
    ShowNotice(8500487)
    return
  end
  JoinType = JoinType or E_UGCJoinPlayHallType.Normal
  if self:GetRoomInfoByModID(ModID) then
    ShowNotice(655719)
    return
  else
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    local TLogStr = string.format("{ModID:%d JoinType:%d}", ModID, JoinType)
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_PlayHall_Room_ReqPlayHallRoom, 0, TLogStr)
    local UGCMatchHandler = require("client.network.Protocol.UGCMatchHandler")
    UGCMatchHandler.send_ugc_join_play_hall_room_req(ModID, JoinType, Param)
    self.LastJoinRoomReqTime = TimeUtil.GetServerTimeInSec()
    self.LastJoin    self.Last    return true
  end
end
function UGCPlayHallRoom:StartQuickGameJoinWaiting()
  print(bWriteLog and "UGCPlayHallRoom:StartQuickGameJoinWaiting Start")
  local PendingMatchParamRecord = self.PendingMatchParamRecord
  self.QuickGameJoinWaitingTimer = self:AddTimerOnce(GameJoinWaitingTime, function()
    print(bWriteLog and "UGCPlayHallRoom:StartQuickGameJoinWaiting End")
    self:ClearQuickGameJoinWaitingTimer()
    self.PendingPlayHallParamRecord = PendingMatchParamRecord
    local LobbyHandler = require("client.network.Protocol.LobbyHandler")
    LobbyHandler.send_on_match_cancel_req()
  end)
end
function UGCPlayHallRoom:SendExitRoomReqByRoomID(RoomID, ReqStart)
  print(bWriteLog and "UGCPlayHallRoom:SendExitRoomReqByRoomID", RoomID)
  local UGCMatchHandler = require("client.network.Protocol.UGCMatchHandler")
  UGCMatchHandler.send_ugc_exit_play_hall_room_req(RoomID)
  if self.AllMatchInfo then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    if RoomID then
      local RoomInfo = self.AllMatchInfo[RoomID].RoomInfo
      if RoomInfo then
        local TlogStr = string.format("{ModID:%d RoomID:%d}", RoomInfo.mod_id, RoomInfo.ph_room_id)
        tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_PlayHall_Room_Click_QuitRoom, 0, TlogStr)
      end
    else
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_PlayHall_Room_Click_QuitRoom_All)
      if ReqStart then
        self.ReqStartAfterExitAll = ReqStart
      end
    end
  end
end
function UGCPlayHallRoom:JoinPlayHallRoomRsp(ErrorCode, RoomInfo, cli_extra_info)
  print(bWriteLog and "UGCPlayHallRoom:JoinPlayHallRoomRsp", ErrorCode)
  log_tree(bWriteLog and "UGCPlayHallRoom:JoinPlayHallRoomRsp RoomInfo", RoomInfo)
  log_tree(bWriteLog and "UGCPlayHallRoom:JoinPlayHallRoomRsp cli_extra_info", cli_extra_info)
  self.bInPendingMatchState = false
  self:ClearAutoCancelPendingMatchStateTimer()
  if ErrorCode == 0 then
    if cli_extra_info and cli_extra_info.join_type == E_UGCJoinPlayHallType.Specify then
      ShowNotice(78382)
    end
    self:CreatePlayHallRoom(RoomInfo)
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    local TLogStr = string.format("{JoinRoom Success RoomID:%d ModID:%d}", RoomInfo.ph_room_id, RoomInfo.mod_id)
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_PlayHall_Room_PlayHallRoomRsp, 0, TLogStr)
    local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
    Logic_UGC_TLog:SendStartGameTLog(RoomInfo.mod_id)
    if self.BackToLobbyIfSuccess then
      UIManager.ForceBackToLobby()
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SHOW_PLAY_HALL_ROOM_UI, self.src_def or "Lobby")
    end
  else
    if self:GetRoomInfo() then
      if ErrorCode == 525112 then
        local no_mod_uids = cli_extra_info and cli_extra_info.no_mod_uids or {}
        if #no_mod_uids <= 0 then
          ShowNotice(ErrorCode)
        else
          local Tips = ""
          if #no_mod_uids == 1 then
            local NickName = LobbySystem.GetNickNameByUid(no_mod_uids[1])
            Tips = LocUtil.LocalizeResFormat(5006, NickName)
          else
            Tips = string.format(LocUtil.GetLocalizeResStr(5007), #no_mod_uids)
          end
          ShowNotice(Tips)
        end
      else
        ShowNotice(ErrorCode)
      end
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      local TLogStr = string.format("{JoinRoom ModWaiting Error %d}", ErrorCode)
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_PlayHall_Room_PlayHallRoomRsp, 0, TLogStr)
    else
      if self.LastJoinType ~= E_UGCJoinPlayHallType.Specify and ErrorCode ~= 525111 and ErrorCode ~= 525112 then
        self:SendUGCMultiMatchReq()
        if self.ShowErorrMsgForce then
          ShowNotice(ErrorCode)
        end
      elseif ErrorCode == 525111 then
        ShowNotice(ErrorCode)
      elseif ErrorCode == 525112 then
        local no_mod_uids = cli_extra_info and cli_extra_info.no_mod_uids or {}
        if #no_mod_uids <= 0 then
          ShowNotice(ErrorCode)
        else
          local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
          if TeamUpNewSystem.IsTeamLeader() and 1 < TeamUpNewSystem.GetTeamNum() then
            local Tips = ""
            if #no_mod_uids == 1 then
              local NickName = LobbySystem.GetNickNameByUid(no_mod_uids[1])
              Tips = LocUtil.LocalizeResFormat(78400, NickName)
            else
              local NickNameList = ""
              for Index = 1, #no_mod_uids do
                local NickName = LobbySystem.GetNickNameByUid(no_mod_uids[Index])
                NickNameList = NickNameList .. NickName .. " "
              end
              Tips = LocUtil.LocalizeResFormat(78400, NickNameList)
            end
            local title = LocUtil.GetLocalizeResStr(101001)
            local okLabel = LocUtil.GetLocalizeResStr(110036)
            local cancelLabel = LocUtil.GetLocalizeResStr(110035)
            local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
            CommonMsgBoxMgr.Show(2, title, Tips, function()
              LobbySystem.KickNoMapPeoplesOut()
            end, nil, okLabel, cancelLabel)
          else
            local Tips = ""
            if #no_mod_uids == 1 then
              local NickName = LobbySystem.GetNickNameByUid(no_mod_uids[1])
              Tips = string.format(LocUtil.GetLocalizeResStr(5006), NickName)
            else
              Tips = string.format(LocUtil.GetLocalizeResStr(5007), #no_mod_uids)
            end
            ShowNotice(Tips)
          end
        end
      else
        ShowNotice(ErrorCode)
      end
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      local TLogStr = string.format("{JoinRoom Error LastJoinType:%d Error:%d}", self.LastJoinType or -1, ErrorCode)
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_PlayHall_Room_PlayHallRoomRsp, 0, TLogStr)
    end
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PENDING_MATCH_CANCEL)
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAYHALL_JOIN_RESPONSE, ErrorCode, RoomInfo)
  self.BackToLobbyIfSuccess = false
  self.LastJoinModID = nil
  self.LastJoinType = nil
  self.ShowErorrMsgForce = false
end
function UGCPlayHallRoom:SendUGCMultiMatchReq()
  print(bWriteLog and "UGCPlayHallRoom:SendUGCMultiMatchReq", self.LastJoinModID)
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local ModID = self.LastJoinModID or LogicUGCMatch:GetMatchModID()
  if 0 < ModID then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local ModInfo = LogicUGC:GetModByAllCache(tonumber(ModID))
    if ModInfo then
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      local TeamNum = TeamUpNewSystem.GetTeamNum()
      if ModInfo.pub_mod_meta then
        ModInfo = ModInfo.pub_mod_meta
      end
      local Util_UGC = require("client.slua.logic.ugc.util_ugc")
      local ModTeamSize = Util_UGC.GetModTeamSize(ModInfo)
      if TeamNum > ModTeamSize then
        ShowNotice(8600142)
        return
      end
    end
    local Logic_UGC_Share = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_share)
    local share_info = Logic_UGC_Share:GetShareData()
    local UGCModHandler = require("client.network.Protocol.UGCModHandler")
    UGCModHandler.send_ugc_multi_match_req({ModID}, false, nil, nil, nil, share_info)
    self:CreateReminderPopWindow(true, ModID)
    local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
    Logic_UGC_TLog:SendStartGameTLog(ModID)
  end
end
function UGCPlayHallRoom:ExitRoomRsp(ErrorCode, RoomID)
  print(bWriteLog and "UGCPlayHallRoom:ExitRoomRsp", ErrorCode, RoomID)
  if ErrorCode ~= 0 then
    ShowNotice(ErrorCode)
    self.ReqStartAfterExitAll = nil
    return
  end
  if self.AllMatchInfo then
    if RoomID then
      self:ExitRoomByRoomID(RoomID)
    else
      self:ExitAllRoom()
    end
  end
  if self.ReqStartAfterExitAll then
    self:SendUGCMultiMatchReq()
    self.ReqStartAfterExitAll = nil
  end
end
function UGCPlayHallRoom:SendRoomQuickChat(ChatID, RoomID)
  RoomID = RoomID or self.CurSelectRoomID
  local MatchInfo = self.AllMatchInfo and self.AllMatchInfo[RoomID]
  if not MatchInfo then
    return
  end
  local CurTime = TimeUtil.GetServerTimeInSec()
  print(bWriteLog and "UGCPlayHallRoom:SendRoomQuickChat", ChatID, RoomID, CurTime - self.LastSendChatTime)
  if CurTime - self.LastSendChatTime < RoomQuickChatCDTime then
    ShowNotice(792534)
    return
  end
  local UGCMatchHandler = require("client.network.Protocol.UGCMatchHandler")
  UGCMatchHandler.send_ugc_ph_room_quick_chat_req(ChatID, RoomID)
  self.LastSendChatTime = CurTime
  local RoomInfo = MatchInfo.RoomInfo
  if RoomInfo then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    local TLogStr = string.format("{ModID:%d RoomID:%d ChatID:%d}", RoomInfo.mod_id, RoomInfo.ph_room_id, ChatID)
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_PlayHall_Room_Click_QuickChat, 0, TLogStr)
  end
end
function UGCPlayHallRoom:UGCPlayHallRoomInfoChange(OptionType, NotifyInfo)
  local RoomID = NotifyInfo.ph_room_id
  print(bWriteLog and "UGCPlayHallRoom:UGCPlayHallRoomInfoChange", RoomID, OptionType)
  log_tree("UGCPlayHallRoom:UGCPlayHallRoomInfoChange NotifyInfo", NotifyInfo)
  if OptionType == E_PlayHallRoomInfoChangeOpt.Add_Room then
    self:CreatePlayHallRoom(NotifyInfo)
  elseif OptionType == E_PlayHallRoomInfoChangeOpt.Del_Room then
    if RoomID then
      self:ExitRoomByRoomID(RoomID, NotifyInfo)
    else
      self:ExitAllRoom(NotifyInfo)
    end
  elseif OptionType == E_PlayHallRoomInfoChangeOpt.Add_Mem then
    self:AddRoomPlayer(RoomID, NotifyInfo.members)
  elseif OptionType == E_PlayHallRoomInfoChangeOpt.Del_Mem then
    self:RemoveRoomPlayer(RoomID, NotifyInfo.members)
  elseif OptionType == E_PlayHallRoomInfoChangeOpt.Change_State then
    self:ChangeRoomState(RoomID, NotifyInfo)
  elseif OptionType == E_PlayHallRoomInfoChangeOpt.QuickChat then
    self:ReceiveChatMessage(RoomID, NotifyInfo)
  else
    log_warning(bWriteLog and "UGCPlayHallRoom:UGCPlayHallRoomInfoChange OptionType Error")
  end
end
function UGCPlayHallRoom:InviteFriendToUGCPlayRoomReq(FriendUID, RoomID)
  RoomID = RoomID or self.CurSelectRoomID
  print(bWriteLog and "UGCPlayHallRoom:InviteFriendToUGCPlayRoomReq", FriendUID, RoomID)
  local UGCMatchHandler = require("client.network.Protocol.UGCMatchHandler")
  UGCMatchHandler.send_ugc_play_hall_room_invite_req(FriendUID, RoomID)
  self.LastInviteFriendTime = TimeUtil.GetServerTimeInSec()
  self.InviteCDList[FriendUID] = TimeUtil.GetServerTimeInSec()
end
function UGCPlayHallRoom:InviteFriendToUGCPlayRoomRsp(ErrorCode, RoomID)
  print(bWriteLog and "UGCPlayHallRoom:InviteFriendToUGCPlayRoomRsp", ErrorCode, RoomID)
  if ErrorCode ~= 0 then
    ShowNotice(ErrorCode)
  end
end
function UGCPlayHallRoom:ReceiveUGCPlayRoomInvitation(InviteUID, RoomID, RoomSvrID, Mod_Info)
  print(bWriteLog and "UGCPlayHallRoom:ReceiveUGCPlayRoomInvitation", InviteUID, RoomID, RoomSvrID, Mod_Info.mod_id)
  if IsWoWEditor then
    return
  end
  local LastInviteTime = self.IgnoreList[InviteUID]
  if LastInviteTime and TimeUtil.GetServerTimeInSec() - LastInviteTime <= IgnoreTime then
    return
  end
  if self.AllMatchInfo and self.AllMatchInfo[RoomID] then
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:BatchGetModInfo({
    Mod_Info.mod_id
  }, LogicUGC.C_ModListTypes.play_hall)
  local InputModInfo = {
    setting = Mod_Info.setting,
    base = {
      template_id = Mod_Info.template_id
    },
    mod_id = Mod_Info.mod_id
  }
  local RoomInfo = {RoomID = RoomID, RoomSvrID = RoomSvrID}
  UIManager.ShowUI(UIManager.UI_Config.UGCMatchRoom_InviteTip, InviteUID, InputModInfo, RoomInfo)
end
function UGCPlayHallRoom:ReplyUGCPlayRoomInvitation(ModID, RoomID, RoomSvrID, AdditionParam, ShowMsgIfFail, BackToLobbyIfSuccess)
  print(bWriteLog and "UGCPlayHallRoom:ReplyUGCPlayRoomInvitation", ModID, RoomID, RoomSvrID)
  local WowPass = self:GetMemberPassInfo()
  local LimitNum = WowPass and WowPass.limit_num or 1
  if LimitNum > self:GetMatchNum() then
    self.ShowErorrMsgForce = ShowMsgIfFail
    self.    AdditionParam = AdditionParam or {}
    self.src_def = AdditionParam.src_def
    AdditionParam.ph_room_svr_id = RoomSvrID
    AdditionParam.ph_room_id = RoomID
    AdditionParam.src_def = self.src_def
    self:SendJoinPlayHallRoomReq(ModID, E_UGCJoinPlayHallType.Specify, AdditionParam)
  else
    UIManager.ShowUI(UIManager.UI_Config.UGCMatchRoom_ClearRoom_Popup)
  end
end
function UGCPlayHallRoom:SetInvitationIgnorePlayerUID(InviteUID)
  self.IgnoreList[InviteUID] = TimeUtil.GetServerTimeInSec()
end
function UGCPlayHallRoom:CheckPlayHallRoomInfoRsp(Rooms)
  print(bWriteLog and "UGCPlayHallRoom:CheckPlayHallRoomInfoRsp")
  if Rooms and next(Rooms) then
    log_tree(bWriteLog and "UGCPlayHallRoom:CheckPlayHallRoomInfoRsp RoomInfo", Rooms)
    self.MatchInfo_Login = Rooms
  else
    self:ExitAllRoom()
  end
end
function UGCPlayHallRoom:QuickStartReq(RoomID)
  local CurTime = TimeUtil.GetServerTimeInSec()
  print(bWriteLog and "UGCPlayHallRoom:QuickStartReq", RoomID, CurTime, self.LastQuickStartTime)
  if CurTime - self.LastQuickStartTime < RoomQuickChatCDTime then
    ShowNotice(8500487)
    return
  end
  local UGCMatchHandler = require("client.network.Protocol.UGCMatchHandler")
  UGCMatchHandler.send_ugc_ph_room_quick_start_req(RoomID)
  self.LastQuickStartTime = CurTime
end
function UGCPlayHallRoom:QuickStartRsp(ErrorCode, RoomID)
  print(bWriteLog and "UGCPlayHallRoom:QuickStartRsp", ErrorCode, RoomID)
  if ErrorCode ~= 0 then
    ShowNotice(ErrorCode)
  end
end
function UGCPlayHallRoom:SendHotStatReq(ZoneID, ModID)
  print(bWriteLog and "UGCPlayHallRoom:SendHotStatReq", ZoneID, ModID, self.LastReqHotStatTime)
  local CurTime = TimeUtil.GetServerTimeInSec()
  if CurTime - self.LastReqHotStatTime < 0.3 then
    print(bWriteLog and "UGCPlayHallRoom:SendHotStatReq In CD")
    return
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_mod_hot_stat_req(ZoneID, ModID)
  self.LastReqHotStatTime = CurTime
end
function UGCPlayHallRoom:SendPlayHallRecruitReq(Param)
  local RoomID = self.CurSelectRoomID
  print(bWriteLog and "UGCPlayHallRoom:SendPlayHallRecruitReq", RoomID)
  if self:CheckRecruitCD(RoomID) and self:CheckRecruitNum(RoomID) then
    Param = Param or {}
    local UGCMatchHandler = require("client.network.Protocol.UGCMatchHandler")
    if Param.world_chat_ugc then
      local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
      local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
      local topic_id = logic_chat_channel_world.GetChannelByTopicType(chat_macro.TopicUGCType)
      if logic_chat_channel_world.CheckSubscribeChannel(topic_id) then
        function self.TopicSubscribeCallBack()
          print(bWriteLog and "UGCPlayHallRoom:SendPlayHallRecruitReq TopicChannelCallBack SendReq", Param.recruit_channel, Param.corps_channel, Param.world_chat_ugc)
          UGCMatchHandler.send_ugc_ph_recruit_req(RoomID, Param)
        end
        print(bWriteLog and "UGCPlayHallRoom:SendPlayHallRecruitReq NeedTopicSubscribe", topic_id)
        return
      end
    end
    print(bWriteLog and "UGCPlayHallRoom:SendPlayHallRecruitReq SendReq", Param.recruit_channel, Param.corps_channel, Param.world_chat_ugc)
    UGCMatchHandler.send_ugc_ph_recruit_req(RoomID, Param)
  else
    ShowNotice(100600038)
  end
end
function UGCPlayHallRoom:OnSubscribeTopicChannelSuccess(_, _, TopicID)
  print(bWriteLog and "UGCPlayHallRoom:OnSubscribeTopicChannelSuccess", TopicID)
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local topic_id = logic_chat_channel_world.GetChannelByTopicType(chat_macro.TopicUGCType)
  if TopicID == topic_id and self.TopicSubscribeCallBack then
    self.TopicSubscribeCallBack()
    self.TopicSubscribeCallBack = nil
  end
end
function UGCPlayHallRoom:SendPlayHallRecruitRsp(ErrorCode, RoomID, RetChannel)
  print(bWriteLog and "UGCPlayHallRoom:SendPlayHallRecruitRsp", ErrorCode, RoomID)
  if ErrorCode == 0 then
    local ret_recruit_channel = RetChannel.ret_recruit_channel
    local ret_corps_channel = RetChannel.ret_corps_channel
    local ret_world_chat_ugc = RetChannel.ret_world_chat_ugc
    print(bWriteLog and "UGCPlayHallRoom:SendPlayHallRecruitRsp SendRsp", ret_recruit_channel, ret_corps_channel, ret_world_chat_ugc)
    if ret_recruit_channel or ret_corps_channel or ret_world_chat_ugc then
      self:StartRecruitCDTimer(RoomID)
    end
    ShowNotice(43401)
  else
    ShowNotice(ErrorCode)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CUGCPlayHallRoom = class(CModuleBase, nil, UGCPlayHallRoom)
return CUGCPlayHallRoom