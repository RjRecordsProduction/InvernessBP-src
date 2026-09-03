local NetManager = require("client.network.comm.NetManager")
local CentauriHandler = {}
function CentauriHandler.send_report_reject_charge(rc_type)
  NetManager.SendPkg(1713396748, rc_type)
end
function CentauriHandler.on_report_reject_charge_rsp(reportResult)
  CentauriManager.on_report_reject_charge(reportResult)
end
function CentauriHandler.send_imobile_notify_client_charge(num)
  NetManager.SendPkg(1892549758, num)
end
function CentauriHandler.send_wow_notify_client_charge()
  log(bWriteLog and "send_wow_notify_client_charge")
  NetManager.SendPkg(1193171812)
end
return CentauriHandler