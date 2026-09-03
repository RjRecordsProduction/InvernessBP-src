local logic_backend_translation = {
  transTable = {}
}
function logic_backend_translation.ResetData()
  log(bWriteLog and "[DeanJYT] logic_backend_translation.ResetData")
  logic_backend_translation.transTable = {}
end
function logic_backend_translation.RequestBackendTranlationPatch()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.translation_server_patch_table, logic_backend_translation.OnGetTransPatchTable)
end
function logic_backend_translation.OnGetTransPatchTable(tableName, data)
  log_tree("[DeanJYT] logic_backend_translation.OnGetTransPatchTable data = ", data)
  if type(data) ~= "table" then
    log(bWriteLog and "[DeanJYT] logic_backend_translation.OnGetTransPatchTable data invalid")
    return
  end
  local newTransTable = {}
  local curTransTable = logic_backend_translation.transTable
  local language = Client.GetCurrentLanguage()
  for i, j in pairs(data) do
    newTransTable[i] = j[language]
  end
  local bNeedRepalceTable = false
  for k, v in pairs(newTransTable) do
    if not curTransTable[k] or curTransTable[k] ~= v then
      bNeedRepalceTable = true
      break
    end
  end
  if not bNeedRepalceTable then
    return
  end
  logic_backend_translation.transTable = newTransTable
  Client.SetExtraLocalizationMap(newTransTable)
end
return logic_backend_translation