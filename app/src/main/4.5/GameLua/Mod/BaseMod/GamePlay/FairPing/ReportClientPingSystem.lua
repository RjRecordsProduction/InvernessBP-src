local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ReportClientPingSystem = {}
function ReportClientPingSystem:ctor()
  self.TickInterval = 10
  self.ReportPingTimer = nil
end
function ReportClientPingSystem:_PostConstruct()
end
function ReportClientPingSystem:OnInit()
  self:OnRoomTypeChange()
  if EVENTTYPE_INGAME and EVENTID_GAMESTATE_ROOMTYPECHANGE then
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_GAMESTATE_ROOMTYPECHANGE, self.OnRoomTypeChange, self)
  end
end
function ReportClientPingSystem:OnRoomTypeChange()
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return
  end
  if self.ReportPingTimer then
    self:RemoveGameTimer(self.ReportPingTimer)
    self.ReportPingTimer = nil
  end
  if GameState.RoomType ~= "match" then
    return
  end
  self.ReportPingTimer = self:AddGameTimer(self.TickInterval, true, function()
    self:ReportPing()
  end)
end
function ReportClientPingSystem:ReportPing()
  if Client then
    self:ClientReportPing()
  else
    self:DsReportPing()
  end
end
function ReportClientPingSystem:ClientReportPing()
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) then
    return
  end
  local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
  local RealPing = PlayerState.Ping * 4
  local DisplayPing = PlayerState.Ping - 13
  DisplayPing = FuncUtil.Clamp(DisplayPing, 5, 255) * 4
  DisplayPing = logic_zone_delay.AdjustPingRange(DisplayPing)
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.RoomType == "match" then
    DisplayPing = RealPing
  end
  if PlayerState.ReportClientPing then
    PlayerState:ReportClientPing(RealPing, DisplayPing)
  end
end
function ReportClientPingSystem:DsReportPing()
  local GameLuaAPI = import("/Script/ShadowTrackerExtra.GameLuaAPI")
  local PingInfosTable = {}
  local PlayerContollerArray = Game:GetAllPlayerControllers()
  for _, PlayerContoller in pairs(PlayerContollerArray) do
    if slua.isValid(PlayerContoller) and slua.isValid(PlayerContoller.PlayerState) and PlayerContoller.PlayerState.UID and PlayerContoller.PlayerState.UID > 0 then
      local PlayerState = PlayerContoller.PlayerState
      if PlayerState.ClientPing == 0 or PlayerState.ClientDisplayPing == 0 then
        return
      end
      local IPAndPort = GameLuaAPI.GetAddrAsString(PlayerContoller)
      if IPAndPort ~= "" then
        local PingInfoTable = {
          PlayerState:GetUIDString(),
          IPAndPort,
          PlayerState.ClientDisplayPing,
          PlayerState.ClientPing
        }
        table.insert(PingInfosTable, table.concat(PingInfoTable, ","))
      end
    end
  end
  if #PingInfosTable == 0 then
    return
  end
  local NetManager = require("client.network.comm.NetManager")
  local TimeUtil = require("client.common.time_util")
  local CurrentTime = TimeUtil.GetServerTimeInSec()
  local PingInfosString = table.concat(PingInfosTable, "|")
  NetUtil.SendPacket("ds_report_player_ping_match", CurrentTime, PingInfosString)
end
local class = require("class")
local CSubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(CSubsystemBase, nil, ReportClientPingSystem)