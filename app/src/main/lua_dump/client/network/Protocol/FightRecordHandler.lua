local NetManager = require("client.network.comm.NetManager")
local FightRecordHandler = {
  gangup_records = nil,
  alive_records = nil,
  classical_kill_record = nil
}
function FightRecordHandler.send_get_classical_gang_up_record_req()
  log(bWriteLog and "FightRecordHandler.send_get_classical_gang_up_record_req")
  NetManager.SendPkg(1556191079)
end
function FightRecordHandler.on_get_classical_gang_up_record_rsp(records)
  log_tree("FightRecordHandler.on_get_classical_gang_up_record_rsp records = ", records)
  FightRecordHandler.gangup_end
function FightRecordHandler.send_get_classical_alive_record_req()
  log(bWriteLog and "FightRecordHandler.send_get_classical_alive_record_req")
  NetManager.SendPkg(955295303)
end
function FightRecordHandler.on_get_classical_alive_record_rsp(records)
  log_tree("FightRecordHandler.on_get_classical_alive_record_rsp records = ", records)
  FightRecordHandler.alive_end
function FightRecordHandler.send_get_classical_kill_record_req()
  NetManager.SendPkg(1073914079)
end
function FightRecordHandler.on_get_classical_kill_record_rsp(classical_kill_record)
  log_tree("FightRecordHandler.on_get_classical_kill_record_rsp records = ", classical_kill_record)
  FightRecordHandler.end
function FightRecordHandler.send_get_classical_record_req()
  log(bWriteLog and "FightRecordHandler.send_get_classical_record_req")
  NetManager.SendPkg(779362919)
end
function FightRecordHandler.on_get_classical_record_rsp(classical_gang_up_record, classical_alive_record, classical_kill_record)
  log(bWriteLog and "FightRecordHandler.on_get_classical_record_rsp")
  log_tree("classical_gang_up_record = ", classical_gang_up_record)
  log_tree("classical_alive_record = ", classical_alive_record)
  log_tree("classical_kill_record = ", classical_kill_record)
  FightRecordHandler.gangup_records = classical_gang_up_record
  FightRecordHandler.alive_records = classical_alive_record
  FightRecordHandler.end
return FightRecordHandler