local NetManager = require("client.network.comm.NetManager")
local TableDataHandler = {}
function TableDataHandler.send_client_table_batch_req(datatableMap, reqKey)
  NetManager.SendPkg(254751271, datatableMap, reqKey)
end
function TableDataHandler.on_client_table_batch_rsp(res, tables, reqKey)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  BasicDataServerTable:on_client_table_batch_rsp(res, tables, reqKey)
end
function TableDataHandler.send_service_table_req(table_name, key)
  NetManager.SendPkg(199494139, table_name, key)
end
function TableDataHandler.on_service_table_rsp(err, result)
end
return TableDataHandler