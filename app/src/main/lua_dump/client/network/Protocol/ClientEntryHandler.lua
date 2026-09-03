local NetManager = require("client.network.comm.NetManager")
local ClientEntryHandler = {}
function ClientEntryHandler.on_on_send_client_data(datalen, data)
  NetUtil.OnTssRsp(datalen, data)
end
function ClientEntryHandler.on_game_unusual_end(gameID, reason)
  NetUtil.OnDSServerConnectionErrorNotify(gameID, reason)
end
function ClientEntryHandler.on_sync_time(serverTime)
  NetUtil.sync_time(serverTime)
  LobbySystem.InitCrossDayHandle()
end
function ClientEntryHandler.on_please_relogin(relogin_seconds, reason)
  NetUtil.OnChangeLobbyServerNotify(relogin_seconds, reason)
end
function ClientEntryHandler.send_giveup_enter_game(is_player_exit_battle_initiatively)
  NetManager.SendPkg(1846350206, is_player_exit_battle_initiatively)
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if MatchSystem.bKrJpRematch then
    MatchSystem.bShowCrossNotice = true
  end
end
function ClientEntryHandler.send_refresh_wx_atk(accessToken)
  NetManager.SendPkg(1597155612, accessToken)
end
function ClientEntryHandler.send_report_player_bind_info(bind_fb, bind_gc, bind_gp)
  NetManager.SendPkg(932092249, bind_fb, bind_gc, bind_gp)
end
function ClientEntryHandler.send_report_unrealnet_event(g_game_id, EventType, EventMessage)
  NetManager.SendPkg(1999351726, g_game_id, EventType, EventMessage)
end
function ClientEntryHandler.send_report_unrealnet_exception(g_game_id, ExceptionType, ErrorMessage)
  NetManager.SendPkg(347409151, g_game_id, ExceptionType, ErrorMessage)
end
return ClientEntryHandler