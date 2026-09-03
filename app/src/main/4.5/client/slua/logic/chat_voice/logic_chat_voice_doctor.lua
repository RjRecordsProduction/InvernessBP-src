local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local xqueue = require("client.common.uibase.xqueue")
local Enum_AntsVoiceRoomType = logic_chat_voice_const.Enum_AntsVoiceRoomType
local Enum_OperationErrorCode = logic_chat_voice_const.Enum_OperationErrorCode
local HDmpveVoiceCompleteCode = logic_chat_voice_const.HDmpveVoiceCompleteCode
local logic_chat_voice_doctor = {
  joined_voice_room_list = nil,
  enable_report_team_room = nil,
  enable_report_lbs_room = nil,
  enable_report_leak = nil,
  enable_fix_voice_room_leak = nil,
  join_team_room_flow_switcher = -1,
  quit_team_room_flow_switcher = -1,
  join_team_room_opera_flow_queue = nil,
  clear_opera_flow_after_onjoin = nil,
  enable_room_id_check = nil,
  enable_joinroom_failed_check = nil
}
function logic_chat_voice_doctor:JoinRoomFailed(code, room)
  if code == Enum_OperationErrorCode.AlreadyInRoomError then
    self:AddJoinedRoom(room, Enum_AntsVoiceRoomType.LobbyTeam)
  end
  if self:EnableReportTeamRoom() then
    local ParamTable = {}
    table.insert(ParamTable, tostring(code))
    table.insert(ParamTable, tostring(room))
    self:ReportGemEvent("JoinRoom", ParamTable)
  end
  if logic_chat_voice_doctor.enable_joinroom_failed_check == nil then
    logic_chat_voice_doctor.enable_joinroom_failed_check = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableJoinRoomFaileCheck", 0)
  end
  if logic_chat_voice_doctor.enable_joinroom_failed_check == 1 then
    self:AddJoinTeamRoomStep(1700)
    self:AddJoinTeamRoomStep(code)
    self:CheckJoinTeamFlow()
  end
end
function logic_chat_voice_doctor:OnJoinRoom(code, room, member)
  if code == HDmpveVoiceCompleteCode.JoinRoomSucc then
    self:AddJoinedRoom(room, Enum_AntsVoiceRoomType.LobbyTeam)
  end
  if self:EnableReportTeamRoom() then
    local ParamTable = {}
    table.insert(ParamTable, tostring(code))
    table.insert(ParamTable, tostring(room))
    table.insert(ParamTable, tostring(member))
    self:ReportGemEvent("OnJoinRoom", ParamTable)
  end
  if logic_chat_voice_doctor.clear_opera_flow_after_onjoin == nil then
    logic_chat_voice_doctor.clear_opera_flow_after_onjoin = HDmpveRemote.HDmpveRemoteConfigGetInt("ClearOperaFlowAfterJoin", 1)
  end
  if logic_chat_voice_doctor.clear_opera_flow_after_onjoin == 1 then
    self:ClearJoinTeamRoomSteps()
  end
end
function logic_chat_voice_doctor:QuitRoomFailed(code, room)
  if self:EnableReportTeamRoom() then
    local ParamTable = {}
    table.insert(ParamTable, tostring(code))
    table.insert(ParamTable, tostring(room))
    self:ReportGemEvent("QuitRoom", ParamTable)
  end
end
function logic_chat_voice_doctor:OnQuitRoom(code, room, member, voiceurl, record_data)
  if code == HDmpveVoiceCompleteCode.QuitRoomSucc then
    self:RemoveJoinedRoom(room)
  end
  if self:EnableReportTeamRoom() then
    local ParamTable = {}
    voiceurl = string.gsub(voiceurl, "udp://", "")
    voiceurl = string.gsub(voiceurl, ":", ";")
    voiceurl = string.gsub(voiceurl, "|", "/")
    table.insert(ParamTable, tostring(code))
    table.insert(ParamTable, tostring(room))
    table.insert(ParamTable, tostring(member))
    table.insert(ParamTable, tostring(record_data))
    table.insert(ParamTable, tostring(voiceurl))
    self:ReportGemEvent("OnQuitRoom", ParamTable)
  end
  self:CheckJoinVoiceRoomLeak()
end
function logic_chat_voice_doctor:OnJoinLbsRoom(code, room, member)
  if code == HDmpveVoiceCompleteCode.JoinRoomSucc then
    self:AddJoinedRoom(room, Enum_AntsVoiceRoomType.BattleLBS)
  end
  if self:EnableReportLBSRoom() then
    local ParamTable = {}
    table.insert(ParamTable, tostring(code))
    table.insert(ParamTable, tostring(room))
    table.insert(ParamTable, tostring(member))
    self:ReportGemEvent("OnJoinLbsRoom", ParamTable)
  end
end
function logic_chat_voice_doctor:OnQuitLbsRoom(code, room, member, voiceurl, record_data)
  if code == HDmpveVoiceCompleteCode.QuitRoomSucc then
    self:RemoveJoinedRoom(room)
  end
  if self:EnableReportLBSRoom() then
    local ParamTable = {}
    table.insert(ParamTable, tostring(code))
    table.insert(ParamTable, tostring(room))
    table.insert(ParamTable, tostring(member))
    table.insert(ParamTable, tostring(record_data))
    table.insert(ParamTable, tostring(voiceurl))
    self:ReportGemEvent("OnQuitLbsRoom", ParamTable)
  end
  self:CheckJoinVoiceRoomLeak()
end
function logic_chat_voice_doctor:ReportGemEvent(SubEvent, ParamTable)
  Client.GEMReportSubEvent(GameFrontendHUD, "GVoiceGemEvent", SubEvent, ParamTable)
end
function logic_chat_voice_doctor:ReportAntsVoiceRoomLeakEvent(SubEvent, ParamTable)
  Client.GEMReportSubEvent(GameFrontendHUD, "GVoiceRoomLeakEvent", SubEvent, ParamTable)
end
function logic_chat_voice_doctor:AddJoinedRoom(room_id, type)
  log(bWriteLog and string.format("[WSL] logic_chat_voice_doctor:AddJoinedRoom  %s", room_id))
  if self.joined_voice_room_list == nil then
    self.joined_voice_room_list = {}
  end
  local TimeUtil = require("client.common.time_util")
  local join_time = TimeUtil.OSTime()
  local room_info = {
    room_id = room_id,
    room_type = type,
      }
  table.insert(self.joined_voice_room_list, room_info)
end
function logic_chat_voice_doctor:RemoveJoinedRoom(room_id)
  log(bWriteLog and string.format("[WSL] logic_chat_voice_doctor:RemoveJoinedRoom  %s", room_id))
  if self.joined_voice_room_list ~= nil then
    local found_room_index
    for i = 1, #self.joined_voice_room_list do
      local room_info = self.joined_voice_room_list[i]
      if room_info.room_id == room_id then
        found_room_index = i
        break
      end
    end
    if found_room_index ~= nil then
      log(bWriteLog and string.format("[WSL] logic_chat_voice_doctor:RemoveJoinedRoom# %d", found_room_index))
      table.remove(self.joined_voice_room_list, found_room_index)
    end
  end
end
function logic_chat_voice_doctor:CheckJoinVoiceRoomLeak()
  if self.joined_voice_room_list == nil then
    return
  end
  local leak_voiceid_list = {}
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local cur_team_room_name = logic_antsvoice_interface:GetTeamRoomName()
  local cru_lbs_room_name = logic_antsvoice_interface:GetLbsRoomName()
  for i = 1, #self.joined_voice_room_list do
    local room_info = self.joined_voice_room_list[i]
    if room_info.room_type == Enum_AntsVoiceRoomType.BattleLBS then
      if self:IsEmptyRoomId(cru_lbs_room_name) == true or cru_lbs_room_name ~= room_info.room_id then
        table.insert(leak_voiceid_list, room_info.room_id)
      end
    elseif room_info.room_type == Enum_AntsVoiceRoomType.LobbyTeam and (self:IsEmptyRoomId(cur_team_room_name) == true or cur_team_room_name ~= room_info.room_id) then
      table.insert(leak_voiceid_list, room_info.room_id)
    end
  end
  local voice_room_leak_len = #leak_voiceid_list
  if 0 < voice_room_leak_len then
    if self.enable_report_leak == nil then
      self.enable_report_leak = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableReportVoiceRoomLeak", true)
    end
    if self.enable_report_leak == true then
      local room_str = table.concat(leak_voiceid_list, ",")
      local ParamTable = {
        tostring(voice_room_leak_len),
        room_str
      }
      self:ReportAntsVoiceRoomLeakEvent("RoomLeak", ParamTable)
      log(bWriteLog and string.format("[WSL] logic_chat_voice_doctor:CheckJoinVoiceRoomLeak antsvoice room leak %s %s", tostring(#leak_voiceid_list), room_str))
    end
    while 0 < voice_room_leak_len do
      local leak_room_id = leak_voiceid_list[1]
      log(bWriteLog and string.format("[WSL] logic_chat_voice_doctor:CheckJoinVoiceRoomLeak antsvoice room leak#1 %s", leak_room_id))
      if self.enable_fix_voice_room_leak == nil then
        self.enable_fix_voice_room_leak = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableFixVoiceRoomLeak", false)
      end
      if self.enable_fix_voice_room_leak == true then
        logic_antsvoice_interface:QuitVoiceRoom(leak_room_id)
      end
      local to_remove_index = 0
      for i = 1, #self.joined_voice_room_list do
        local room_info = self.joined_voice_room_list[i]
        if room_info ~= nil and room_info.room_id == leak_room_id then
          to_remove_index = i
          break
        end
      end
      if to_remove_index ~= 0 then
        table.remove(self.joined_voice_room_list, to_remove_index)
      end
      table.remove(leak_voiceid_list, 1)
      voice_room_leak_len = #leak_voiceid_list
    end
  end
end
function logic_chat_voice_doctor:IsEmptyRoomId(room_id)
  if room_id == nil or room_id == "" or room_id == logic_chat_voice_const.NO_TEAM_ROOM_ROOM_NAME or room_id == logic_chat_voice_const.NO_LBS_ROOM_ROOM_NAME then
    return true
  else
    return false
  end
end
function logic_chat_voice_doctor:EnableReportTeamRoom()
  if self.enable_report_team_room == nil then
    self.enable_report_team_room = false
    local remoteConfig = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableReportTeamRoomDeviceLevel", 1)
    local UIUtil = require("client.common.ui_util")
    local GameInst = UIUtil.GetGameInstance()
    if slua.isValid(GameInst) and remoteConfig <= GameInst:GetExactDeviceLevel() then
      self.enable_report_team_room = true
    end
  end
  return self.enable_report_team_room
end
function logic_chat_voice_doctor:EnableReportLBSRoom()
  if self.enable_report_lbs_room == nil then
    self.enable_report_lbs_room = false
    local remoteConfig = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableReportLBSRoomDeviceLevel", 1)
    local UIUtil = require("client.common.ui_util")
    local GameInst = UIUtil.GetGameInstance()
    if slua.isValid(GameInst) and remoteConfig <= GameInst:GetExactDeviceLevel() then
      self.enable_report_lbs_room = true
    end
  end
  return self.enable_report_lbs_room
end
function logic_chat_voice_doctor:AddJoinTeamRoomStep(step_id)
  log(bWriteLog and "logic_chat_voice_doctor:AddJoinTeamRoomStep: " .. tostring(step_id))
  if type(step_id) == "number" then
    local EnableRecordQuitRoom = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableRecordQuitRoom", true)
    if not EnableRecordQuitRoom and 600 < step_id and step_id < 700 then
      return
    end
  end
  if self:EnableJoinTeamRoomFlow() == false then
    return
  end
  if logic_chat_voice_doctor.join_team_room_opera_flow_queue == nil then
    logic_chat_voice_doctor.join_team_room_opera_flow_queue = xqueue.Create(30)
  end
  logic_chat_voice_doctor.join_team_room_opera_flow_queue:Push(step_id)
end
function logic_chat_voice_doctor:ClearJoinTeamRoomSteps()
  log(bWriteLog and "logic_chat_voice_doctor:ClearJoinTeamRoomSteps")
  if self:EnableJoinTeamRoomFlow() == false then
    return
  end
  if logic_chat_voice_doctor.join_team_room_opera_flow_queue ~= nil then
    logic_chat_voice_doctor.join_team_room_opera_flow_queue:Clear()
  end
end
function logic_chat_voice_doctor:CheckJoinTeamFlow()
  log(bWriteLog and "logic_chat_voice_doctor:CheckJoinTeamFlow")
  if self:EnableJoinTeamRoomFlow() == false then
    return
  end
  local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
  if logic_team_up.GetTeamNum() <= 1 then
    log(bWriteLog and "logic_chat_voice_doctor:CheckJoinTeamFlow: return by logic_team_up.GetTeamNum()")
    return
  end
  if logic_chat_voice_doctor.join_team_room_opera_flow_queue == nil or logic_chat_voice_doctor.join_team_room_opera_flow_queue:Len() <= 0 then
    log(bWriteLog and "logic_chat_voice_doctor:CheckJoinTeamFlow: return by opera flow len")
    return
  end
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local cur_team_room_name = logic_antsvoice_interface:GetTeamRoomName()
  if logic_chat_voice_doctor.enable_room_id_check == nil then
    logic_chat_voice_doctor.enable_room_id_check = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableVoiceDoctorRoomIdCheck", 1)
  end
  if logic_chat_voice_doctor.enable_room_id_check == 1 and string.find(cur_team_room_name, tostring(g_game_id), 1, true) ~= nil then
    log(bWriteLog and "logic_chat_voice_doctor:CheckJoinTeamFlow: return by room id contain gameid")
    return
  end
  local flow_str = table.concat(logic_chat_voice_doctor.join_team_room_opera_flow_queue.dataList, ",")
  local ParamTable = {}
  table.insert(ParamTable, tostring(g_game_id))
  table.insert(ParamTable, tostring(cur_team_room_name))
  table.insert(ParamTable, tostring(flow_str))
  self:ReportGemEvent("NotInBattleVoiceRoom", ParamTable)
  self:ClearJoinTeamRoomSteps()
end
function logic_chat_voice_doctor:CheckLobbyQuitRoomFlow()
  log(bWriteLog and "logic_chat_voice_doctor:CheckLobbyQuitRoomFlow")
  if self:EnableQuitTeamRoomFlow() == false then
    return
  end
  local timer_ticker = require("common.time_ticker")
  timer_ticker.AddTimerOnce(3, function()
    if not GameStatus.IsInLobbyOrMainCity() then
      log(bWriteLog and "[WSL] logic_chat_voice_doctor:CheckLobbyQuitRoomFlow: return by GameStatus.GetGameStatus() ~= GameStatus.Lobby")
      return
    end
    local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
    if logic_team_up.GetTeamNum() > 1 then
      log(bWriteLog and "[WSL] logic_chat_voice_doctor:CheckLobbyQuitRoomFlow: return by logic_team_up.GetTeamNum() > 1")
      return
    end
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    local cur_team_room_name = logic_antsvoice_interface:GetTeamRoomName()
    local StringUtil = require("common.string_util")
    if StringUtil.Starts(cur_team_room_name, "pubg_chat_") or cur_team_room_name == "" or cur_team_room_name == "no_teamroom" then
      log(bWriteLog and "[WSL] logic_chat_voice_doctor:CheckLobbyQuitRoomFlow: return by cur_team_room_name not match")
      return
    end
    local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
    local curRoomID = logic_chat_voice_data_manager:GetCurRoomID()
    if logic_chat_voice_doctor == nil or logic_chat_voice_doctor.join_team_room_opera_flow_queue == nil or logic_chat_voice_doctor.join_team_room_opera_flow_queue:Len() <= 0 then
      log(bWriteLog and "logic_chat_voice_doctor:CheckLobbyQuitRoomFlow: return by opera flow len")
      return
    end
    local flow_str = table.concat(logic_chat_voice_doctor.join_team_room_opera_flow_queue.dataList, ",")
    local ParamTable = {}
    table.insert(ParamTable, tostring(curRoomID))
    table.insert(ParamTable, tostring(cur_team_room_name))
    table.insert(ParamTable, tostring(flow_str))
    self:ReportGemEvent("LobbyVoiceRoomLeak", ParamTable)
    self:ClearJoinTeamRoomSteps()
  end)
end
function logic_chat_voice_doctor:EnableJoinTeamRoomFlow()
  if logic_chat_voice_doctor.join_team_room_flow_switcher == -1 then
    logic_chat_voice_doctor.join_team_room_flow_switcher = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableRecordJoinTeamRoomFlow", 0)
  end
  if logic_chat_voice_doctor.join_team_room_flow_switcher == 1 then
    return true
  end
  return false
end
function logic_chat_voice_doctor:EnableQuitTeamRoomFlow()
  if logic_chat_voice_doctor.quit_team_room_flow_switcher == -1 then
    logic_chat_voice_doctor.quit_team_room_flow_switcher = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableRecordQuitTeamRoomFlow", 0)
  end
  if logic_chat_voice_doctor.quit_team_room_flow_switcher == 1 then
    return true
  end
  return false
end
return logic_chat_voice_doctor