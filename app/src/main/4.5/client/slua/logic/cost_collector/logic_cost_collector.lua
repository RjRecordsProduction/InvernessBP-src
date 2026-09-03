local logic_cost_collector = {
  startTimeMap = {},
  isolatedStartTimeMap = {},
  EVENT_KEYS = {
    BEFORE_SPLASH = "\231\153\187\229\189\149-\229\144\175\229\138\168\229\136\176\233\151\170\229\177\143\229\138\168\231\148\187\232\128\151\230\151\182",
    SPLASH = "\231\153\187\229\189\149-\233\151\170\229\177\143\233\152\182\230\174\181",
    UPDATE = "\231\153\187\229\189\149-\230\155\180\230\150\176\233\152\182\230\174\181",
    LOGIN = "\231\153\187\229\189\149-\231\153\187\229\189\149\233\152\182\230\174\181",
    CHOOSE_SERVER = "\231\153\187\229\189\149-\233\128\137\230\156\141\233\152\182\230\174\181",
    CONNECT_SERVER = "\232\191\155\229\133\165\229\164\167\229\142\133-\232\191\158\230\156\141",
    LOAD_MAP = "\232\191\155\229\133\165\229\164\167\229\142\133-\229\136\135\230\141\162\229\156\176\229\155\190",
    CREATE_AVATAR = "\232\191\155\229\133\165\229\164\167\229\142\133-\229\136\155\229\187\186Avatar",
    CREATE_MAIN_UI = "\232\191\155\229\133\165\229\164\167\229\142\133-\229\136\155\229\187\186\228\184\187UI"
  },
  ISOLATED_EVENT_NAMES = {
    PufferJsonPostProcess = "Cost_PufferJsonPostProcess",
    WaitConnectToGate = "Cost_WaitConnectToGate",
    WaitLoginRsp = "Cost_WaitLoginRsp",
    WaitSyncBaseInfo = "Cost_WaitSyncBaseInfo",
    ProcessSyncBaseInfo = "Cost_ProcessSyncBaseInfo",
    LoadLobbyMap = "Cost_LoadLobbyMap",
    ProcessWardrobeData = "Cost_ProcessWardrobeData",
    ProcessActivityData = "Cost_ProcessActivityData",
    OpenWardrobeUI = "Cost_OpenWardrobeUI",
    OpenActivityUI = "Cost_OpenActivityUI",
    OpenRPUI = "Cost_OpenRPUI"
  }
}
local GEM_EVENT_KEY_MAP = {
  [logic_cost_collector.EVENT_KEYS.BEFORE_SPLASH] = 190300,
  [logic_cost_collector.EVENT_KEYS.SPLASH] = 190400,
  [logic_cost_collector.EVENT_KEYS.UPDATE] = 190500,
  [logic_cost_collector.EVENT_KEYS.LOGIN] = 190600,
  [logic_cost_collector.EVENT_KEYS.CHOOSE_SERVER] = 190700,
  [logic_cost_collector.EVENT_KEYS.CONNECT_SERVER] = 190800,
  [logic_cost_collector.EVENT_KEYS.LOAD_MAP] = 190900,
  [logic_cost_collector.EVENT_KEYS.CREATE_AVATAR] = 191000,
  [logic_cost_collector.EVENT_KEYS.CREATE_MAIN_UI] = 191100
}
local COLLECT_FORMAT = "CollectName:[%s]|CollectTime:[%.0fms]"
function logic_cost_collector:Initialize()
  self._bLoginCostReported = false
  self:ClearData()
end
function logic_cost_collector:ClearData()
  self.startTimeMap = {}
  self._reportedIsolatedEventMap = {}
  self._isolatedCostForReport = {}
end
function logic_cost_collector:OnPostSwitchGameStatus(preState, nextState)
  if self._bLoginCostReported then
    return
  end
  if preState ~= GameStatus.Login or nextState ~= GameStatus.Lobby then
    return
  end
  self:_ReportIsolatedLoginCost()
end
function logic_cost_collector:MarkEventStart(keyName)
  if not keyName then
    return
  end
  if not self.startTimeMap then
    return
  end
  self.startTimeMap[keyName] = slua.getMiliseconds()
end
function logic_cost_collector:MarkEventEnd(keyName)
  if not keyName then
    return
  end
  if not self.startTimeMap then
    return
  end
  local startTime = self.startTimeMap[keyName]
  if type(startTime) ~= "number" then
    log_warning(bWriteLog and "Event end but no start time record for keyName: " .. tostring(keyName))
    return
  end
  self:_ReportCost(keyName, slua.getMiliseconds() - startTime)
  log(bWriteLog and string.format("[Test][Duration] logic_cost_collector Cost Event: %s, Start: %d, End: %d", keyName, startTime, slua.getMiliseconds()))
  self.startTimeMap[keyName] = nil
end
function logic_cost_collector:MarkTransition(fromEventKey, toEventKey)
  self:MarkEventEnd(fromEventKey)
  self:MarkEventStart(toEventKey)
end
function logic_cost_collector:ReportElapsedTimeAfterLaunch(keyName)
  local startTime = slua.getGStartTime() * 1000
  local current = Client.GetTimeInMiliSeconds()
  local cost = current - startTime
  log(bWriteLog and string.format("logic_cost_collector:ReportElapsedTimeAfterLaunch startTime: %f, current: %f, cost: %f", startTime, current, cost))
  self:_ReportCost(keyName, cost)
end
function logic_cost_collector:MarkIsolatedEventStart(keyName)
  if not keyName then
    return
  end
  if not self.isolatedStartTimeMap then
    self.isolatedStartTimeMap = {}
  end
  self.isolatedStartTimeMap[keyName] = slua.getMiliseconds()
end
function logic_cost_collector:MarkIsolatedEventEnd(keyName)
  if not keyName then
    return
  end
  if not self.isolatedStartTimeMap then
    return
  end
  local startTime = self.isolatedStartTimeMap[keyName]
  if type(startTime) ~= "number" then
    log_warning(bWriteLog and "Event end but no start time record for isolated event keyName: " .. tostring(keyName))
    return
  end
  local now = slua.getMiliseconds()
  local cost = now - startTime
  if not self._isolatedCostForReport then
    self._isolatedCostForReport = {}
  end
  self._isolatedCostForReport[keyName] = cost
  log(bWriteLog and string.format("[Test][Duration] logic_cost_collector isolated event Cost Event: %s, Start: %d, End: %d, cost: %d", keyName, startTime, now, cost))
  self.isolatedStartTimeMap[keyName] = nil
end
function logic_cost_collector:_ReportCost(keyName, cost)
  if not keyName or not cost then
    return
  end
  local startTime = slua.getGStartTime() * 1000
  local current = Client.GetTimeInMiliSeconds()
  local totalCost = current - startTime
  local gemEventID = GEM_EVENT_KEY_MAP[keyName]
  if gemEventID then
    local param = {
      tostring(gemEventID),
      tostring(totalCost),
      tostring(cost)
    }
    Client.GEMReportSubEvent(GameFrontendHUD, "PufferEvent", "LoginCost", param)
  end
end
function logic_cost_collector:_ReportIsolatedLoginCost()
  log(bWriteLog and "logic_cost_collector:_ReportIsolatedLoginCost")
  if self._bLoginCostReported then
    return
  end
  if not self._isolatedCostForReport or not next(self._isolatedCostForReport) then
    return
  end
  local param = {
    tostring(self._isolatedCostForReport[logic_cost_collector.ISOLATED_EVENT_NAMES.PufferJsonPostProcess] or 0),
    tostring(self._isolatedCostForReport[logic_cost_collector.ISOLATED_EVENT_NAMES.WaitLoginRsp] or 0),
    tostring(self._isolatedCostForReport[logic_cost_collector.ISOLATED_EVENT_NAMES.WaitSyncBaseInfo] or 0),
    tostring(self._isolatedCostForReport[logic_cost_collector.ISOLATED_EVENT_NAMES.ProcessSyncBaseInfo] or 0),
    tostring(self._isolatedCostForReport[logic_cost_collector.ISOLATED_EVENT_NAMES.LoadLobbyMap] or 0)
  }
  Client.GEMReportSubEvent(GameFrontendHUD, "PufferEvent", "LoginCost360", param)
  self._bLoginCostReported = true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicCostCollector = class(CModuleBase, nil, logic_cost_collector)
return CLogicCostCollector