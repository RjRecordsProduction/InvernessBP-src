local mode_switch_util = {}
local PreStatus = "None"
local local local local local local local utility = require("common.utility")
local xpcallHandle = utility.ErrorMessageHandler
local OnUIModePreSwitch = function(preState, nextState)
  log(bWriteLog and "mode_switch_util OnUIModePreSwitch preState " .. tostring(preState) .. " nextState " .. tostring(nextState))
  if preState == GameStatus.Fighting and nextState == GameStatus.Lobby and Client.EnableLobbyEntry() then
    require("client.common.event.EventProxy")
    EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, {pre = preState, current = nextState})
    return
  end
  EventSystem:postEvent(EVENTTYPE_OLD_WIDGET, EVENTID_PRE_CLOSE_ALL_UI)
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.Stop()
  xpcall(ui_jump_manager.Clear, xpcallHandle)
  UIManager.ClearOnModePreSwitch(preState, nextState)
  require("client.common.event.EventProxy")
  EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, {pre = preState, current = nextState})
end
local bFirstLogin = false
local OnUIModePreSwitchEnd = function(preState, nextState)
  log(bWriteLog and "mode_switch_util OnUIModePreSwitchEnd preState " .. preState .. " nextState " .. nextState)
  EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH_END, nextState)
  collectgarbage("collect")
end
local OnUIModePreSwitchLobbyEntry = function(preState, nextState)
  log(bWriteLog and "mode_switch_util OnUIModePreSwitchLobbyEntry nextState: " .. tostring(nextState))
  EventSystem:postEvent(EVENTTYPE_OLD_WIDGET, EVENTID_PRE_CLOSE_ALL_UI)
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.Stop()
  xpcall(ui_jump_manager.Clear, xpcallHandle)
  UIManager.ClearOnModePreSwitch(GameStatus.Fighting, GameStatus.Lobby)
  EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH_LOBBY_ENTRY, {
    pre = GameStatus.Fighting,
    current = GameStatus.Lobby
  })
end
local OnUIModePostSwitchLobbyEntry = function(preState, nextState)
  log(bWriteLog and "mode_switch_util OnUIModePostSwitchLobbyEntry preState: " .. tostring(preState) .. " nextState: " .. tostring(nextState))
  EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH_LOBBY_ENTRY, {pre = PreStatus, current = nextState})
end
local OnUIModePostSwitchStart = function(preState, nextState)
  log(bWriteLog and "mode_switch_util OnUIModePostSwitchStart gameStatus " .. nextState)
  local TablePreCache = require("GameLua.GameCore.Main.TablePreCache")
  TablePreCache.Init(nextState)
  local logic_leak_check = RequireBlackList("blacklist.slua.logic.lobby.logic_leak_check")
  if logic_leak_check then
    xpcall(logic_leak_check.CheckLeak, xpcallHandle, PreStatus, nextState)
  end
  EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH_START, {pre = PreStatus, current = nextState})
end
local OnUIModePostSwitch = function(preState, nextState)
  log(bWriteLog and "mode_switch_util OnUIModePostSwitch preState " .. tostring(preState) .. " nextState " .. tostring(nextState))
  local ok, Entry = pcall(require, "client.slua.config.status." .. string.lower(nextState))
  if Entry then
    xpcall(Entry, xpcallHandle)
  end
  if Client.IsDevelopment() then
    local LuaAPITimeTracer = RequireBlackList("blacklist.editor.runtime_check.LuaAPITimeTracer")
    if LuaAPITimeTracer then
      LuaAPITimeTracer.StopTracer()
    end
  end
  EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, {pre = preState, current = nextState})
  PreStatus = nextState
end
function mode_switch_util.Init()
  local game_frontend_hud = require("game_frontend_hud")
  game_frontend_hud.SetPreSwitchGameStatusListener(OnUIModePreSwitch)
  game_frontend_hud.SetPreSwitchGameStatusEndListener(OnUIModePreSwitchEnd)
  game_frontend_hud.SetPreSwitchLobbyEntryListener(OnUIModePreSwitchLobbyEntry)
  game_frontend_hud.SetPostSwitchLobbyEntryListener(OnUIModePostSwitchLobbyEntry)
  game_frontend_hud.SetPostSwitchGameStatusStartListener(OnUIModePostSwitchStart)
  game_frontend_hud.SetPostSwitchGameStatusListener(OnUIModePostSwitch)
end
return mode_switch_util