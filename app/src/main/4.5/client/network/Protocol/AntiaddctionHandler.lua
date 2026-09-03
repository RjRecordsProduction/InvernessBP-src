local NetManager = require("client.network.comm.NetManager")
local AntiaddctionHandler = {}
function AntiaddctionHandler.send_set_nonage_req(is_nonage)
  NetManager.SendPkg(434669799, is_nonage)
end
function AntiaddctionHandler.on_set_nonage_rsp(res, is_nonage, next_time, is_show_setting)
  local AntiaddctionSystem = require("client.logic.antiaddction.logic_antiaddction")
  AntiaddctionSystem.set_nonage_rsp(res, is_nonage, next_time, is_show_setting)
end
function AntiaddctionHandler.on_get_nonage_data_rsp(is_show, is_nonage, age, next_time, is_show_setting, pk_time, pk_status)
  local AntiaddctionSystem = require("client.logic.antiaddction.logic_antiaddction")
  AntiaddctionSystem.get_nonage_data_rsp(is_show, is_nonage, age, next_time, is_show_setting, pk_time, pk_status)
end
function AntiaddctionHandler.on_check_nonage_anti_work(ok, plan_id, anti_table, rest_time, is_login, is_bind_parent, bind_parent_url)
  local AntiaddctionSystem = require("client.logic.antiaddction.logic_antiaddction")
  AntiaddctionSystem.check_nonage_anti_work(ok, plan_id, anti_table, rest_time, is_login, is_bind_parent, bind_parent_url)
end
function AntiaddctionHandler.send_report_pakistan_minors_info_req(is_minors, minors_info)
  log(bWriteLog and "AntiaddctionHandler.send_report_pakistan_minors_info_req is_minors = " .. tostring(is_minors))
  log_tree("AntiaddctionHandler.send_report_pakistan_minors_info_req minors_info", minors_info)
  NetManager.SendPkg(392640667, is_minors, minors_info)
end
function AntiaddctionHandler.on_report_pakistan_minors_info_rsp(err_code)
  log(bWriteLog and "AntiaddctionHandler.on_report_pakistan_minors_info_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
end
return AntiaddctionHandler