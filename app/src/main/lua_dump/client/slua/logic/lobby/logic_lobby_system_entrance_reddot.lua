local logic_lobby_system_entrance_reddot = {res_reddot_data = nil}
function logic_lobby_system_entrance_reddot.proc_reddot_list_rsp(list)
  log(bWriteLog and "logic_lobby_system_entrance_reddot.proc_reddot_list_rsp")
  log_tree("list = ", list)
  logic_lobby_system_entrance_reddot.res_reddot_data = list
end
function logic_lobby_system_entrance_reddot.HasRedDot()
  return false
end
return logic_lobby_system_entrance_reddot