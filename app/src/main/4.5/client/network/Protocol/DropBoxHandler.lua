local NetManager = require("client.network.comm.NetManager")
local DropBoxHandler = {}
function DropBoxHandler.send_get_content_by_chestids(chest_id_list, key, BoxDetail)
  NetManager.SendPkg(297731772, chest_id_list, key, BoxDetail)
end
function DropBoxHandler.on_get_content_by_chestids_rsp(res, key, chest_list)
  if res ~= NetErrorCode_NONE and tonumber(res) ~= 18080001 then
    log_error("DropBoxHandler.on_get_content_by_chestids_rsp error reason : " .. res)
    return
  end
  local BasicDataChestTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataChestTable)
  BasicDataChestTable:on_get_content_by_chestids_rsp(res, key, chest_list)
end
function DropBoxHandler.send_get_content_by_dropids(drop_id_list, key)
  NetManager.SendPkg(541713612, drop_id_list, key)
end
function DropBoxHandler.on_get_content_by_dropids_rsp(res, key, drop_list)
  if res ~= NetErrorCode_NONE then
    log_error("on_get_content_by_dropids_rsp error reason : " .. res)
    return
  end
  local BasicDataDropTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataDropTable)
  BasicDataDropTable:on_get_content_by_dropids_rsp(key, drop_list)
end
function DropBoxHandler.send_get_realtime_probability_req(chest_id, module_type, sub_module_type, group_id)
  NetManager.SendPkg(81103527, chest_id, module_type, sub_module_type, group_id)
end
function DropBoxHandler.on_get_realtime_probability_rsp(err_code, probability_list, chest_id, module_type, sub_module_type)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local BasicDataProbabilityTable = require("client.slua.data.BasicData.BasicDataRealtimeProbabilityTable")
  BasicDataProbabilityTable:on_get_realtime_probability_rsp(probability_list, chest_id, module_type, sub_module_type)
end
return DropBoxHandler