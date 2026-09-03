local red_point_manager = {}
local E_NODE_QUEUE_MARK = {BLACK = 1, WHITE = 2}
function red_point_manager:DefineAndResetData()
  self.nodeQueue = {
    [E_NODE_QUEUE_MARK.BLACK] = {},
    [E_NODE_QUEUE_MARK.WHITE] = {}
  }
  self.mark = E_NODE_QUEUE_MARK.BLACK
  self.refreshTimer = nil
end
function red_point_manager:OnDestroy()
  if self.refreshTimer then
    self:RemoveTimer(self.refreshTimer)
    self.refreshTimer = nil
  end
  self.nodeQueue = nil
end
function red_point_manager:OnPreSwitchGameStatus(_pre, _next)
  log(bWriteLog and string.format("red_point_manager:OnPreSwitchGameStatus _pre = %s, _next = %s", _pre, _next))
  if GameStatus.IsPreSwitchEnterFightingFromLobbyOrMainCity(_pre, _next) then
    log(bWriteLog and string.format("red_point_manager:OnPreSwitchGameStatus start stop."))
    if self.refreshTimer then
      self:RemoveTimer(self.refreshTimer)
      self.refreshTimer = nil
    end
  end
end
function red_point_manager:OnPostSwitchGameStatus(_pre, _next)
  log(bWriteLog and string.format("red_point_manager:OnPostSwitchGameStatus _pre = %s, _next = %s", _pre, _next))
  if _next == GameStatus.Lobby then
    self:StartTick()
  elseif GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting(_pre, _next) then
    self:StartTick()
  end
end
function red_point_manager:StartTick()
  log(bWriteLog and string.format("red_point_manager:OnPostSwitchGameStatus start polling."))
  if self.refreshTimer then
    self:RemoveTimer(self.refreshTimer)
    self.refreshTimer = nil
  end
  local TimeTicker = require("common.time_ticker")
  self.refreshTimer = self:AddTimerLoop(0, function()
    self.mark = self.mark == E_NODE_QUEUE_MARK.BLACK and E_NODE_QUEUE_MARK.WHITE or E_NODE_QUEUE_MARK.BLACK
    self:TickPoint()
  end, TIMER_INFINITE, TimeTicker.NEXT_FRAME)
end
function red_point_manager:TickPoint()
  local nodes = self.nodeQueue[self.mark] or {}
  for node, diff in pairs(nodes) do
    node:_ExecuteRedPointRefresh(diff)
    nodes[node] = nil
  end
end
function red_point_manager:InsertNode(node, diff)
  diff = diff or 0
  local queue = self.nodeQueue[self.mark == E_NODE_QUEUE_MARK.BLACK and E_NODE_QUEUE_MARK.WHITE or E_NODE_QUEUE_MARK.BLACK]
  if queue[node] then
    queue[node] = queue[node] + diff
  else
    queue[node] = diff
  end
end
function red_point_manager:GenerateRedPointTree(tree, name)
  if type(tree) ~= "table" then
    return
  end
  local RedPointNode = require("client.slua.logic.wardrobe.redPoint.red_point_node")
  local root = RedPointNode(nil, name)
  local function addNode(r, key, branches)
    r = RedPointNode(r, key)
    if type(branches) ~= "table" then
      return
    end
    for _key, _branches in pairs(branches) do
      addNode(r, _key, _branches)
    end
  end
  for _key, _branches in pairs(tree) do
    addNode(root, _key, _branches)
  end
  return root
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, red_point_manager)
return CModuleTemplate