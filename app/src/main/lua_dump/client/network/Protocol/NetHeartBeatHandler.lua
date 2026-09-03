local NetManager = require("client.network.comm.NetManager")
local NetHeartBeatHandler = {}
local logic_lobby_ping_report = require("client.slua.logic.match.logic_lobby_ping_report")
function NetHeartBeatHandler.send_heart_beat(curTime)
  NetManager.SendPkg(718633438, curTime)
  logic_lobby_ping_report.OnSendHeartbeat(curTime)
end
function NetHeartBeatHandler.on_heart_beat(key, now)
  logic_lobby_ping_report.OnReceiveHeartbeat(key)
  NetUtil.OnHeartBeatRsp(now)
end
return NetHeartBeatHandler