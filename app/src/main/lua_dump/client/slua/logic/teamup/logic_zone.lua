local ZoneSystem = {
  nMinUDPPingIntervalTime = 3,
  nUDPPingIntervalTime = 15,
  nReqZoneCount = 0,
  chooseZoneTimer = nil,
  nCheckAutoChooseCount = 0,
  chooseZoneList = {},
  nChooseZoneID = 0,
  bChooseZoneFromServer = false,
  nNextChooseZoneTime = 0,
  extraPingInfo = nil,
  PingCoefficientMap = {},
  Coefficient = 1,
  BestShadowZoneId = nil
}
local C_MinUDPPingIntervalTime = 3
local C_UDPPingIntervalTime = 15
local C_UDPPingTimeoutSecond = 3
local C_NormalDelayMilliSecond = 1000
local C_MaxAutoChooseZoneDelayMilliSecond = 150
local C_MaxReqZoneCount = 5
local C_MaxReqZoneCountLimit = 10
local C_MaxCheckAutoChooseCount = 3
function ZoneSystem.setZoneId(newZoneId, reason)
  local oldZoneId = ZoneSystem.nChooseZoneID
  ZoneSystem.nChooseZoneID = newZoneId or 0
  if oldZoneId ~= ZoneSystem.nChooseZoneID then
    printf("ZoneSystem.setZoneId changed from %d to %d, reason: %s", oldZoneId, ZoneSystem.nChooseZoneID, reason or "unknown")
  end
end
ZoneSystem.Enum_ZoneID = {
  NorthAmerica = 1,
  Europe = 2,
  Asia = 3,
  SouthAmerica = 4,
  MiddleEast = 5,
  KRJP = 6
}
function ZoneSystem.InitExtraPingInfo(extraPingInfo)
  ZoneSystem.  log_tree("extraPingInfo = ", extraPingInfo)
  if type(extraPingInfo) == "table" and extraPingInfo.Coefficient and extraPingInfo.BestShadowZoneId then
    ZoneSystem.BestShadowZoneId = extraPingInfo.BestShadowZoneId
    ZoneSystem.Coefficient = extraPingInfo.Coefficient
  end
  if type(extraPingInfo) == "table" and extraPingInfo.RegionPingParam then
    local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
    if logic_zone_delay then
      logic_zone_delay.InitRegionPingParam(extraPingInfo.RegionPingParam)
    end
  end
end
function ZoneSystem.GetZoneDelay(zoneID, ms)
  if not zoneID or type(ms) ~= "number" then
    return ms
  end
  if ZoneSystem.BestShadowZoneId ~= nil then
    if ZoneSystem.BestShadowZoneId == zoneID then
      return ms
    end
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    if zoneID == ZoneSystem.nChooseZoneID then
      ms = ms * ZoneSystem.Coefficient
    end
  end
  return ms
end
function ZoneSystem.GetFirstZone()
  return ZoneSystem.chooseZoneList[1] and ZoneSystem.chooseZoneList[1].zone_id or 0
end
function ZoneSystem.GetChooseZone()
  return ZoneSystem.nChooseZoneID
end
function ZoneSystem.GetZoneIp(nZoneId)
  nZoneId = nZoneId or ZoneSystem.GetChooseZone() or 0
  if nZoneId == 0 then
    return
  end
  for _, v in pairs(ZoneSystem.chooseZoneList) do
    if nZoneId == v.zone_id then
      return v.tpingsvr_ip
    end
  end
end
function ZoneSystem.ClearData()
  ZoneSystem.nReqZoneCount = 0
  ZoneSystem.nCheckAutoChooseCount = 0
  ZoneSystem.chooseZoneList = {}
  ZoneSystem.setZoneId(0, "ClearData")
  ZoneSystem.bChooseZoneFromServer = false
  ZoneSystem.nNextChooseZoneTime = 0
  ZoneSystem.ClearTimer()
end
function ZoneSystem.SetUDPPingIntervalTime(pingSvrPars)
  if pingSvrPars then
    log(bWriteLog and "[edward][logic_zone] ZoneSystem.SetUDPPingIntervalTime from server")
    ZoneSystem.nMinUDPPingIntervalTime = pingSvrPars.MinUDPPingIntervalTime or C_MinUDPPingIntervalTime
    ZoneSystem.nUDPPingIntervalTime = pingSvrPars.UDPPingIntervalTime or C_UDPPingIntervalTime
  else
    log(bWriteLog and "[edward][logic_zone] ZoneSystem.SetUDPPingIntervalTime from client")
  end
  local UDPPingCollector = slua_GameFrontendHUD.UDPPingCollector
  UDPPingCollector:Init(ZoneSystem.nMinUDPPingIntervalTime, ZoneSystem.nUDPPingIntervalTime, C_UDPPingTimeoutSecond, C_NormalDelayMilliSecond, C_MaxAutoChooseZoneDelayMilliSecond)
end
function ZoneSystem.InitChooseZone(zone_id, next_time)
  if zone_id then
    log(bWriteLog and "[edward][logic_zone] ZoneSystem.InitChooseZone, zone_id = " .. zone_id)
    ZoneSystem.setZoneId(zone_id, "InitChooseZone - server assigned")
    ZoneSystem.bChooseZoneFromServer = true
  else
    ZoneSystem.setZoneId(0, "InitChooseZone - no server zone")
    ZoneSystem.bChooseZoneFromServer = false
  end
  if next_time then
    log(bWriteLog and "[edward][logic_zone] ZoneSystem.InitChooseZone, next_time = " .. next_time)
    ZoneSystem.nNextChooseZoneTime = next_time
  end
end
function ZoneSystem.SaveZoneList(tpingsvr_tab)
  ZoneSystem.SaveZoneListInfo(tpingsvr_tab)
  ZoneSystem.SetUDPPingZoneList()
  ZoneSystem.nReqZoneCount = 0
  if ZoneSystem.bChooseZoneFromServer then
    log(bWriteLog and "[edward][logic_zone] ZoneSystem.SaveZoneList, zone from server")
    local chooseZoneIDValid = false
    for i, v in ipairs(ZoneSystem.chooseZoneList) do
      if v.zone_id == ZoneSystem.nChooseZoneID then
        chooseZoneIDValid = true
        break
      end
    end
    local zoneID = 0
    if chooseZoneIDValid then
      zoneID = ZoneSystem.nChooseZoneID
      ZoneSystem.setZoneId(0, "SaveZoneList - before server response")
      ZoneSystem.on_select_zone_res(NetErrorCode_NONE, zoneID)
    else
      ZoneSystem.setZoneId(0, "SaveZoneList - invalid server zone")
      ZoneSystem.bChooseZoneFromServer = false
      ZoneSystem.AutoChooseZone()
    end
  else
    ZoneSystem.AutoChooseZone()
  end
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_ZONELIST_RSP)
end
function ZoneSystem.SaveZoneListInfo(tpingsvr_tab)
  log_tree("[DeanJYT] ZoneSystem.SaveZoneListInfo", tpingsvr_tab)
  if not tpingsvr_tab then
    log(bWriteLog and "[edward][logic_zone] ZoneSystem.SaveZoneListInfo, tpingsvr_tab is nil!")
    return
  end
  local isJapanOrKorea = GlobalData.IsJapanOrKorea()
  ZoneSystem.chooseZoneList = {}
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  local isRussiaArea = logic_multiple_area:IsConnectToRussiaArea()
  log(bWriteLog and "[sherlock] ZoneSystem.SaveZoneListInfo logic_multiple_area:IsConnectToRussiaArea return " .. tostring(isRussiaArea))
  log(bWriteLog and "[edward][logic_zone] ZoneSystem.SaveZoneListInfo count: " .. #tpingsvr_tab)
  for k, v in pairs(tpingsvr_tab) do
    v.watermark = v.watermark or 0
  end
  if ZoneSystem.extraPingInfo and ZoneSystem.extraPingInfo.ShowZoneOrder then
    local ShowZoneOrder = ZoneSystem.extraPingInfo.ShowZoneOrder
    log(bWriteLog and "[teddysjwu][logic_zone] sortByExtraPingInfo")
    for i, id in ipairs(ShowZoneOrder) do
      for k, v in pairs(tpingsvr_tab) do
        if v.zone_id == id then
          table.insert(ZoneSystem.chooseZoneList, v)
          tpingsvr_tab[k] = nil
          break
        end
      end
    end
    for k, id in pairs(tpingsvr_tab) do
      table.insert(ZoneSystem.chooseZoneList, id)
    end
  else
    table.sort(tpingsvr_tab, function(a, b)
      local zone_idA = a.zone_id or 0
      local zone_idB = b.zone_id or 0
      return zone_idA < zone_idB
    end)
    if not isRussiaArea then
      for k, v in pairs(tpingsvr_tab) do
        if v.zone_id == 6 and isJapanOrKorea then
          table.insert(ZoneSystem.chooseZoneList, 1, v)
        else
          table.insert(ZoneSystem.chooseZoneList, v)
        end
      end
    else
      for _, v in pairs(tpingsvr_tab) do
        if v.zone_id == 2 then
          table.insert(ZoneSystem.chooseZoneList, v)
        end
      end
      if #ZoneSystem.chooseZoneList == 0 then
        log(bWriteLog and "[sherlock] ZoneSystem.SaveZoneListInfo current zone list does contain Europe, show all for default.")
        for _, v in pairs(tpingsvr_tab) do
          table.insert(ZoneSystem.chooseZoneList, v)
        end
      end
    end
  end
end
function ZoneSystem.SetUDPPingZoneList()
  log(bWriteLog and "[edward][logic_zone] ZoneSystem.SetUDPPingZoneList")
  local UDPPingCollector = slua_GameFrontendHUD.UDPPingCollector
  for i, v in ipairs(ZoneSystem.chooseZoneList) do
    UDPPingCollector:setUDPPingServerAddress(v.tpingsvr_ip, v.tpingsvr_port, v.zone_id, v.watermark)
  end
end
local _GetMaxReqZoneCount = function()
  local cnt = C_MaxReqZoneCount
  local server_cnt = LobbySystem and LobbySystem.roleData and LobbySystem.roleData.wait_ping_retry_num
  if server_cnt and type(server_cnt) == "number" then
    cnt = math.min(server_cnt, C_MaxReqZoneCountLimit)
  end
  log(bWriteLog and "_GetMaxReqZoneCount " .. tostring(cnt))
  return cnt
end
function ZoneSystem.AutoChooseZone()
  local timer_ticker = require("common.time_ticker")
  local max_req_zone_cnt = _GetMaxReqZoneCount()
  ZoneSystem.chooseZoneTimer = timer_ticker.AddTimerLoop(0.5, function()
    if ZoneSystem.nReqZoneCount <= max_req_zone_cnt then
      ZoneSystem.nReqZoneCount = ZoneSystem.nReqZoneCount + 1
      ZoneSystem.ChooseMinPingZone()
    else
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_AUTO_CHOOSE_ZONE_END)
      ZoneSystem.autoChooseZoneFinished = true
      ZoneSystem.ClearTimer()
    end
  end, TIMER_INFINITE, 0.5)
end
function ZoneSystem.ChooseMinPingZone()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 and TeamUpNewSystem.IsTeamLeader() then
    return
  end
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if region == PublishRegionMacros.BLUEHOLE then
    print(bWriteLog and "ZoneSystem.ChooseMinPingZone BLUEHOLE force choose 3")
    ZoneSystem.AutoChooseZoneSuccess(3)
    return
  end
  local UDPPingCollector = slua_GameFrontendHUD.UDPPingCollector
  if UDPPingCollector:isAllZoneHasPingValue() or ZoneSystem.nCheckAutoChooseCount > C_MaxCheckAutoChooseCount then
    local minDelayZone = UDPPingCollector:GetMinDealyAddress()
    log(bWriteLog and "[edward][logic_zone] ZoneSystem.ChooseMinPingZone, minDelayZone = " .. minDelayZone)
    if 0 < minDelayZone then
      ZoneSystem.AutoChooseZoneSuccess(minDelayZone)
    end
  else
    ZoneSystem.nCheckAutoChooseCount = ZoneSystem.nCheckAutoChooseCount + 1
  end
end
function ZoneSystem.ClearTimer()
  if ZoneSystem.chooseZoneTimer then
    local timer_ticker = require("common.time_ticker")
    if timer_ticker.IsRunning(ZoneSystem.chooseZoneTimer) then
      timer_ticker.RemoveTimer(ZoneSystem.chooseZoneTimer)
    end
  end
  ZoneSystem.chooseZoneTimer = nil
end
function ZoneSystem.AutoChooseZoneSuccess(zone_id)
  ZoneSystem.ClearTimer()
  if not RoomSystem.IsShowWaiting() then
    log(bWriteLog and "[edward][logic_zone] ZoneSystem.AutoChooseZoneSuccess, ZoneSystem.ChooseZoneId = " .. tostring(ZoneSystem.nChooseZoneID))
    if not ZoneSystem.nChooseZoneID or ZoneSystem.nChooseZoneID == 0 then
      ZoneSystem.on_select_zone_req(zone_id)
    end
  end
  ZoneSystem.SetUDPPingIntervalTime()
end
function ZoneSystem.NotifyUDPPingChooseZone(zone_id)
  log(bWriteLog and "[edward][logic_zone] ZoneSystem.NotifyUDPPingChooseZone, zone_id = " .. tostring(zone_id))
  local zoneInfo
  for i, v in ipairs(ZoneSystem.chooseZoneList) do
    if v.zone_id == zone_id then
      zoneInfo = v
      break
    end
  end
  if zoneInfo then
    local UDPPingCollector = slua_GameFrontendHUD.UDPPingCollector
    UDPPingCollector:ChoosingZone(zone_id, zoneInfo.tpingsvr_ip)
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local IntlHelper = import("IntlHelper")
    IntlHelper.OnChoosingZone(zone_id, zoneInfo.tpingsvr_ip, "")
    ZoneSystem.UpdateVoiceURLByZoneSelected(zone_id, "")
  end
end
function ZoneSystem.ShowChangeZoneTip(zone_id)
  if not zone_id or zone_id == 0 then
    return
  end
  local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
  local serveryDelay = logic_zone_delay.GetZoneDelay(zone_id, 360, 10000)
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  local zoneName = logic_multiple_area:GetDisplayNameByZoneID(zone_id)
  local tip = LocUtil.LocalizeResFormat(7596, zoneName, serveryDelay)
  ShowNotice(tip)
end
function ZoneSystem.ShowReturnZoneTip(zone_id)
  if not zone_id or zone_id == 0 then
    return
  end
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  local zoneName = logic_multiple_area:GetDisplayNameByZoneID(zone_id)
  local tip = LocUtil.LocalizeResFormat(7597, zoneName)
  ShowNotice(tip)
end
function ZoneSystem.UpdateVoiceURLByZoneSelected(zondid, regionVoiceUrl)
  local voiceServerUrl = ""
  if regionVoiceUrl ~= nil and 0 < #regionVoiceUrl then
    voiceServerUrl = regionVoiceUrl
  else
    local cfg = CDataTable.GetTable("ZoneConfig")
    for _, v in pairs(cfg) do
      if v.ZoneID == zondid then
        voiceServerUrl = v.VoiceServer
        break
      end
    end
  end
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  logic_antsvoice_interface:SetAntsVoiceServerInfo(voiceServerUrl)
end
function ZoneSystem.OnSelectZoneRsp(ret, match_zone, next_select_time, shadow_region)
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:AddJoinTeamRoomStep(650)
  logic_chat_voice_doctor:CheckLobbyQuitRoomFlow()
  log(bWriteLog and "[edward][logic_zone] ZoneSystem.OnSelectZoneRsp, ret = " .. ret .. ", match_zone = " .. tostring(match_zone) .. ", next_select_time = " .. tostring(next_select_time))
  if next_select_time then
    ZoneSystem.nNextChooseZoneTime = next_select_time
  end
  if ret == NetErrorCode_NONE then
    ZoneSystem.NotifyUDPPingChooseZone(match_zone)
    local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
    if shadow_region then
      logic_zone_delay.SetShadowRegion(shadow_region)
    end
    local enter_guide = require("client.slua.logic.growth_project.enter_guide")
    if enter_guide.CheckIsDoing() then
      enter_guide.StopSelectZoneRspTimer()
    end
    if not ZoneSystem.nChooseZoneID or ZoneSystem.nChooseZoneID ~= match_zone then
      ZoneSystem.setZoneId(match_zone, "OnSelectZoneRsp - zone selection success")
      local logic_chat_channel_team_recruit = require("client.slua.logic.lobby_chat.logic_chat_channel_team_recruit")
      logic_chat_channel_team_recruit.curRecruitZoneID = match_zone
      local MatchSystem = require("client.slua.logic.match.logic_match")
      MatchSystem.SetCrossMatchParamByZoneList()
      local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
      MentorSystem.SetMatchOptionZone(match_zone)
      local LogicTeamUpLimit = require("client.slua.logic.teamup.logic_team_up_limit")
      LogicTeamUpLimit.send_get_single_squad_pre_team_limit_req()
    end
    local logic_promotion_mode = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_promotion_mode)
    if logic_promotion_mode then
      logic_promotion_mode:SetZoneInfo(match_zone)
    end
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    logic_chat_voice:ReconnectRoom()
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_ZONE)
  elseif ret == "nil zone" or ret == " invalid zone" then
    ShowNotice(1012)
  elseif ret == "player_matching" then
    ShowNotice(1013)
  elseif ret == "not-leader" then
    ShowNotice(1014)
  elseif ret == "select_in_cd" then
    local TimeUtil = require("client.common.time_util")
    local leftSecond = ZoneSystem.nNextChooseZoneTime - TimeUtil.GetServerTimeInSec()
    ShowNotice(LocUtil.LocalizeResFormat(7462, TimeUtil.GetTimeLengthStr(leftSecond < 0 and 0 or leftSecond, true)))
  end
  if ZoneSystem.bChooseZoneFromServer then
    ZoneSystem.bChooseZoneFromServer = false
  end
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_SELECT_ZONE_RSP, ret)
end
function ZoneSystem.OnTeamMatchZoneNotify(match_zone)
  log(bWriteLog and "[edward][logic_zone] ZoneSystem.OnTeamMatchZoneNotify, match_zone = " .. tostring(match_zone))
  local RoomSystem = require("client.logic.login.logic_room")
  local bInRoom = RoomSystem.CurrentRoomInfo and RoomSystem.CurrentRoomInfo.id
  if not bInRoom then
    ZoneSystem.setZoneId(match_zone, "OnTeamMatchZoneNotify - team zone changed")
    ZoneSystem.NotifyUDPPingChooseZone(match_zone)
    local logic_chat_channel_team_recruit = require("client.slua.logic.lobby_chat.logic_chat_channel_team_recruit")
    logic_chat_channel_team_recruit.curRecruitZoneID = match_zone
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.SetCrossMatchParamByZoneList()
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_MATCH_ZONE_NOTIFY)
  end
end
local sendReqInfo = {sendTimes = 0, state = 0}
function ZoneSystem.InitSendReqInfo()
  sendReqInfo = {sendTimes = 0, state = 0}
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.QueryZoneState, 0)
end
function ZoneSystem.query_match_zone_list_req()
  log(bWriteLog and "[edward][logic_zone] ZoneSystem.query_match_zone_list_req")
  if sendReqInfo.sendTimes and sendReqInfo.sendTimes > 5 then
    return
  end
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_query_match_zone_list()
  sendReqInfo.sendTimes = sendReqInfo.sendTimes + 1
  sendReqInfo.state = 1
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.QueryZoneState, 1)
end
function ZoneSystem.sync_match_zone_list_rsp(tpingsvr_tab)
  local enter_guide = require("client.slua.logic.growth_project.enter_guide")
  if type(tpingsvr_tab) == "table" and #tpingsvr_tab ~= 0 then
    enter_guide.StopZoneListInfoRspTimer()
  end
  log(bWriteLog and "[edward][logic_zone] ZoneSystem.sync_match_zone_list_rsp")
  ZoneSystem.SaveZoneList(tpingsvr_tab)
  sendReqInfo.state = 2
  sendReqInfo.innerCount = #ZoneSystem.chooseZoneList
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.QueryZoneState, 2)
end
function ZoneSystem.FormatZonePrintString()
  if ZoneSystem.chooseZoneList and #ZoneSystem.chooseZoneList >= 1 then
    return ""
  else
    return string.format("1%s%s", sendReqInfo.state, sendReqInfo.sendTimes)
  end
end
function ZoneSystem.on_select_zone_req(match_zone, pingShadowZone)
  local Utility = require("common.utility")
  local GameAutotest = Utility.GetGameInstanceSubsystemByName("AutoTestSubsystem")
  if slua.isValid(GameAutotest) then
    local bUIAutoTest = GameAutotest:IsUIAutoTest()
    if bUIAutoTest then
      match_zone = 1
    end
  end
  local enter_guide = require("client.slua.logic.growth_project.enter_guide")
  if enter_guide.CheckIsDoing() then
    enter_guide.StartSelectZoneRspTimer()
  end
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_on_select_zone_req(match_zone)
  if pingShadowZone then
    local ShadowZoneSystem = require("client.slua.logic.teamup.logic_shadow_zone")
    ShadowZoneSystem.PingShadowServerAtOnce(match_zone)
  end
end
function ZoneSystem.on_select_zone_res(ret, match_zone, next_select_time, shadow_region)
  ret = string.lower(ret)
  local RoomSystem = require("client.logic.login.logic_room")
  local bInRoom = RoomSystem.CurrentRoomInfo and RoomSystem.CurrentRoomInfo.id
  if not bInRoom then
    ZoneSystem.OnSelectZoneRsp(ret, match_zone, next_select_time, shadow_region)
  end
  RoomSystem.on_select_zone_rsp(ret, match_zone)
  if ret == "guest_cant_select" then
    ShowNotice(22002)
  end
end
function ZoneSystem.on_team_match_zone_notify(match_zone)
  local NetManager = require("client.network.comm.NetManager")
  if NetManager.bIsMuteMsgForReLogin and GameStatus.IsInFightingStatus() then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() and ZoneSystem.nChooseZoneID ~= 0 and (match_zone ~= ZoneSystem.nChooseZoneID or match_zone ~= RoomSystem.RoomZoneId) then
    ZoneSystem.ShowChangeZoneTip(match_zone)
  end
  local LogicTeamUpLimit = require("client.slua.logic.teamup.logic_team_up_limit")
  LogicTeamUpLimit.send_get_single_squad_pre_team_limit_req()
  ZoneSystem.OnTeamMatchZoneNotify(match_zone)
end
return ZoneSystem