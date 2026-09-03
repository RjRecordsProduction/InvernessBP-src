local NetManager = require("client.network.comm.NetManager")
local LobbyPingReportHandler = {}
function LobbyPingReportHandler.send_report_lobby_ping(report_type, networkType, uploadSeq, lostPackRate, avgNoOutlier, stdNoOutlier, numNoOutlier, HeartNum)
  log(bWriteLog and "LobbyPingReportHandler.send_report_lobby_ping" .. " reportType: " .. tostring(report_type) .. " networkType: " .. tostring(networkType) .. " uploadSeq: " .. tostring(uploadSeq) .. " lostRate: " .. tostring(lostPackRate) .. " avgNoOutlier: " .. tostring(avgNoOutlier) .. " stdNoOutlier: " .. tostring(stdNoOutlier) .. " numNoOutlier: " .. tostring(numNoOutlier) .. " HeartNum: " .. tostring(HeartNum))
  NetManager.SendPkg(516985564, report_type, networkType, uploadSeq, lostPackRate, avgNoOutlier, stdNoOutlier, numNoOutlier, HeartNum)
end
function LobbyPingReportHandler.on_report_lobby_ping_rsp(report_type)
  log(bWriteLog and "LobbyPingReportHandler.on_report_lobby_ping_rsp report_type: " .. report_type)
end
return LobbyPingReportHandler