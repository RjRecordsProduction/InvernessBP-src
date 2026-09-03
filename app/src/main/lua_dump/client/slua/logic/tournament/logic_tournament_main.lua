local logic_tournament_main = {}
function logic_tournament_main:DefineAndResetData()
  self.hasEnRoll = false
  self._isCanGetTournament = 0
  self.has_room_create_mode = false
  self.notify_player_Id = ""
  self.notify_demand_num = 0
  self.notify_cur_num = 0
  self.match_pre_time = 0
  self.curMode = -1
  self.curCost = -1
  self.curTeam = -1
  self.serverTime = 0
  self.canGetTournamentTime = 0
  self.timePassSinceSetData = 0
  self.EntranceList = nil
end
function logic_tournament_main:OnLogOut()
  self:DefineAndResetData()
end
function logic_tournament_main:OnInitialize()
  logic_tournament_main.__super.OnInitialize(self)
end
function logic_tournament_main:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_INDIA_COMPETITION, EVENTID_INDIA_CHAMPIONSHIP_NOTIFY_PLAYER, self.OnNotifyPlayerChange, self)
end
function logic_tournament_main:ShowMainUI()
  UIManager.ShowUI(UIManager.UI_Config.tournament_main)
end
function logic_tournament_main:CloseMainUI()
  UIManager.CloseUI(UIManager.UI_Config.tournament_main)
end
function logic_tournament_main:SetTournamentData(tournaments)
  self:SetItems(tournaments)
end
function logic_tournament_main:SetItems(tournaments)
  self.EntranceList = {}
  self.hasEnRoll = false
  self.has_room_create_mode = false
  local TimeUtil = require("client.common.time_util")
  local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
  self.serverTime = TimeUtil.GetServerTimeInSec()
  for k, v in pairs(tournaments) do
    local modeInfo = CDataTable.GetTableData("ModeTeamTable", v.type_data.mode_group)
    if (v.type == 1000 or v.type == 1001) and modeInfo and (self.curMode == -1 or self.curMode == tonumber(modeInfo.mapName)) and (self.curCost == -1 or self.curCost == v.type_data.cost[1702018]) and (self.curTeam == -1 or self.curTeam == v.type_data.team_size) then
      local item = {}
      item.serverData = v
      item.id = tostring(k)
      item.state = 0
      item.cost_resid = v.type_data.cost[1702018] and v.type_data.cost[1702018] or -1
      item.cost = v.type_data.cost[1006] and v.type_data.cost[1006] or -1
      item.title = v.title or 0
      item.user_state = v.user_data.enroll_state or 0
      if item.user_state == 1 then
        self.hasEnRoll = true
      end
      item.level_limit = v.type_data.level_limit
      item.earn_score = v.type_data.earn_score or 0
      item.grade = v.type_data.grade
      item.team_size = v.type_data.team_size or 0
      item.type = v.type
      item.icon_url = v.icon_url
      if v.type == 1000 then
        item.modeName = 7025
        item.enroll_count = v.type_data.enroll_count or 0
        item.enroll_limit = v.type_data.enroll_limit or 0
        item.match_players = 0
        item.human_size = 0
      elseif v.type == 1001 then
        if v.type_data.team_size == 4 then
          item.modeName = 1219
        else
          item.modeName = 1217
        end
        item.match_players = v.match_players or 0
        item.human_size = v.type_data.human_size or 0
      end
      if v.type == 1001 then
        item.start_enroll_time_str = TimeUtil.FormatTime_MD(v.type_data.start_time, true)
        if self.serverTime < v.type_data.start_time then
          item.next_state_time = v.type_data.start_time
          item.state = 1
        elseif self.serverTime > v.type_data.start_time and self.serverTime < v.type_data.close_time then
          item.next_state_time = v.type_data.close_time
          item.state = 2
          if TournamentsManager.settlement_table[k] and self.serverTime < v.type_data.close_time and v.type_data.team_size ~= 4 then
            item.state = 6
          end
        end
        if TournamentsManager.isInMatch and k == TournamentsManager.curMatchTourId and self.serverTime < v.type_data.close_time then
          item.state = 5
        end
      elseif v.type == 1000 then
        item.start_enroll_time_str = TimeUtil.FormatTime_MD(v.type_data.enroll_begTime, true)
        if self.serverTime < v.type_data.enroll_begTime then
          item.next_state_time = v.type_data.enroll_begTime
          item.state = 1
        elseif self.serverTime > v.type_data.enroll_begTime and self.serverTime < v.type_data.enroll_endTime then
          item.next_state_time = v.type_data.enroll_endTime
          item.state = 2
        elseif self.serverTime > v.type_data.enroll_endTime and self.serverTime < v.type_data.enter_time then
          item.next_state_time = v.type_data.enter_time
          item.state = 3
        elseif self.serverTime > v.type_data.enter_time and self.serverTime < v.type_data.start_time then
          item.next_state_time = v.type_data.start_time
          item.state = 4
        end
        if item.enroll_count == item.enroll_limit and item.user_state ~= 1 then
          item.user_state = 3
        end
      end
      if item.level_limit > DataMgr.roleData.level and item.user_state ~= 1 then
        item.user_state = 4
      end
      if item.state ~= 0 then
        table.insert(self.EntranceList, item)
      end
    end
    if v.type == 1002 then
      self.has_room_create_mode = true
    end
  end
  local sortFunc = function(a, b)
    if a.grade ~= b.grade then
      return a.grade > b.grade
    elseif a.type ~= b.type then
      return a.type > b.type
    else
      return a.team_size < b.team_size
    end
  end
  table.sort(self.EntranceList, sortFunc)
  self.canGetTournamentTime = 0
  EventSystem:postEvent(EVENTTYPE_INDIA_COMPETITION, EVENTID_INDIA_CHAMPIONSHIP_TOURNAMENTS_LIST, self.EntranceList)
end
function logic_tournament_main:HasRoomCreateMode()
  return self.has_room_create_mode
end
function logic_tournament_main:GetEntranceList()
  return self.EntranceList
end
function logic_tournament_main:OnNotifyPlayerChange(eventType, eventID, t_id)
  local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
  local info = TournamentsManager.tournaments[t_id]
  for _, v in ipairs(self.EntranceList) do
    if tostring(t_id) == tostring(v.id) then
      v.enroll_count = info.current_player or 0
      v.enroll_limit = info.demand_player or 0
      self.notify_demand_num = info.demand_player
      self.notify_cur_num = info.current_player
      self.notify_player_Id = tostring(t_id)
    end
  end
end
function logic_tournament_main:OnMatchResPreTime(pretime)
  self.notify_demand_num = 0
  self.notify_cur_num = 0
  self.notify_player_Id = ""
  self.match_pre_time = pretime
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_tournament_main)
return CModuleTemplate