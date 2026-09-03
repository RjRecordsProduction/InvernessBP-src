local TableArchiver = {}
function TableArchiver.SaveData(Table, CompressionFlag)
  if Table then
    local encodedData = slua.LuaArchiverEncode(LuaStateWrapper, Table)
    if encodedData and encodedData ~= "" then
      return encodedData
    end
  end
end
function TableArchiver.LoadData(Data, CompressionFlag)
  return slua.LuaArchiverDecode(LuaStateWrapper, Data)
end
function TableArchiver.SaveFile(FilePath, Table, CompressionFlag)
  local encodedData = TableArchiver.SaveData(Table, CompressionFlag)
  if encodedData then
    local ScriptHelperClient = import("ScriptHelperClient")
    ScriptHelperClient.SaveArrayToFile(encodedData, FilePath)
    return encodedData
  end
end
function TableArchiver.LoadFile(FilePath, CompressionFlag)
  local ScriptHelperClient = import("ScriptHelperClient")
  if ScriptHelperClient.IsFileExistByFileName(FilePath) then
    local Data = ScriptHelperClient.LoadFileToArray(FilePath)
    return TableArchiver.LoadData(Data, CompressionFlag)
  end
end
return TableArchiver