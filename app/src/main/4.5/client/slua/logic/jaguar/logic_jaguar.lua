local JaguarSystem = {item_table = nil}
function JaguarSystem.OnLogin()
  if not Client.IsJaguar() then
    return
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.jaguar_filter_item_table, JaguarSystem.OnConfigCompleted)
end
function JaguarSystem.OnConfigCompleted(tableName, data)
  JaguarSystem.item_table = data
end
function JaguarSystem.IsFilter(item_id)
  return false
end
return JaguarSystem