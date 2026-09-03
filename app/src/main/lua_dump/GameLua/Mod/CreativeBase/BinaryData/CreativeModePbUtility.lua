local CreativeModePbUtility = {}
local CreativeBinaryDataVersionConfig = require("GameLua.Mod.CreativeBase.BinaryData.Config.CreativeBinaryDataVersionConfig")
local PbFilePath = "gamesrv_ds/ugc_binary_data.pb"
local HistoricalPbFilePath = "gamesrv_ds/binary_historicalversion/ugc_binary_data_%s.pb"
local DevHistoricalPbFilePath = "gamesrv_ds/binary_devhistoricalversion/ugc_binary_data_%s.pb"
local PBPackage = "gamesrv_ds"
local HistoricalPBPackage = "gamesrv_ds.binarydata_%s"
local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
local protoFileCache = true
function CreativeModePbUtility.SetProtoFileCache(cache)
  if protoFileCache ~= cache then
    print(bWriteLog and "CreativeModePbUtility.SetProtoFileCache cache: " .. tostring(cache))
    protoFileCache = cache
  end
end
local loaded = {}
function CreativeModePbUtility.LoadFile(fileName)
  if loaded[fileName] then
    return
  end
  local pb = require("pb")
  pb.loadfile(fileName)
  if protoFileCache then
    loaded[fileName] = true
  end
end
CreativeModePbUtility.LoadFile("gamesrv_ds/ugc_binary_base.pb")
function CreativeModePbUtility.DeepCopy(tOrigin)
  local tCopy = {}
  for key, value in pairs(tOrigin) do
    if type(value) == "table" then
      value = CreativeModePbUtility.DeepCopy(value)
    end
    tCopy[key] = value
  end
  return tCopy
end
function CreativeModePbUtility.ToStringEx(value)
  if type(value) == "table" then
    return CreativeModePbUtility.TableToStr(value)
  elseif type(value) == "string" then
    value = string.gsub(value, "\\", "\\\\")
    value = string.gsub(value, "'", "\\'")
    value = string.gsub(value, "\n", "")
    value = string.gsub(value, "\r", "")
    return "'" .. value .. "'"
  else
    return tostring(value)
  end
end
function CreativeModePbUtility.TableToStr(t)
  if t == nil then
    return ""
  end
  local retstr = "{"
  local i = 1
  for key, value in pairs(t) do
    local signal = ","
    if i == 1 then
      signal = ""
    end
    if key == i then
      retstr = retstr .. signal .. CreativeModePbUtility.ToStringEx(value)
    elseif type(key) == "number" or type(key) == "string" then
      retstr = retstr .. signal .. "[" .. CreativeModePbUtility.ToStringEx(key) .. "]=" .. CreativeModePbUtility.ToStringEx(value)
    elseif type(key) == "userdata" then
      retstr = retstr .. signal .. "*s" .. CreativeModePbUtility.TableToStr(getmetatable(key)) .. "*e" .. "=" .. CreativeModePbUtility.ToStringEx(value)
    else
      retstr = retstr .. signal .. key .. "=" .. CreativeModePbUtility.ToStringEx(value)
    end
    i = i + 1
  end
  retstr = retstr .. "}"
  return retstr
end
function CreativeModePbUtility.StrToTable(str)
  if str == nil or type(str) ~= "string" then
    return str
  end
  return load("return " .. str)()
end
function CreativeModePbUtility.GetPbFilePath(binaryVersion)
  if binaryVersion == nil then
    return PbFilePath
  end
  if binaryVersion == CreativeBinaryDataVersionConfig.CurVersion then
    return PbFilePath
  end
  local bVersionExists = false
  for k, v in pairs(CreativeBinaryDataVersionConfig.HistoricalVersion) do
    if v == binaryVersion then
      bVersionExists = true
      break
    end
  end
  if bVersionExists then
    return string.format(HistoricalPbFilePath, tostring(binaryVersion))
  else
    return PbFilePath
  end
end
function CreativeModePbUtility.GetHistoricalDevPbPath(binaryVersion)
  if binaryVersion == CreativeBinaryDataVersionConfig.DevVersion then
    return nil
  end
  local bVersionExists = false
  for k, v in pairs(CreativeBinaryDataVersionConfig.HistoricalDevVersion) do
    if v == binaryVersion then
      bVersionExists = true
      break
    end
  end
  if bVersionExists then
    return string.format(DevHistoricalPbFilePath, tostring(binaryVersion)), string.format(HistoricalPBPackage, tostring(binaryVersion))
  else
    return nil
  end
end
function CreativeModePbUtility.GetPBPackage(binaryVersion)
  if binaryVersion == nil then
    return PBPackage
  end
  if binaryVersion == CreativeBinaryDataVersionConfig.CurVersion then
    return PBPackage
  end
  local bVersionExists = false
  for k, v in pairs(CreativeBinaryDataVersionConfig.HistoricalVersion) do
    if v == binaryVersion then
      bVersionExists = true
      break
    end
  end
  if bVersionExists then
    return string.format(HistoricalPBPackage, tostring(binaryVersion))
  else
    return PBPackage
  end
end
function CreativeModePbUtility.BinaryPackToPbBuffer(binary, binaryVersion)
  if binary == nil then
    return nil
  end
  CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath(binaryVersion))
  local pb = require("pb")
  local copyBinary = CreativeModePbUtility.DeepCopy(binary)
  copyBinary = CreativeModePbUtility.PackInstanceID(copyBinary)
  copyBinary = CreativeModePbUtility.PackSubParameters(copyBinary)
  local MessageFullName = CreativeModePbUtility.GetPBPackage(binaryVersion) .. ".binary_info"
  local buffer = pb.encode(MessageFullName, copyBinary)
  return buffer
end
function CreativeModePbUtility.CustomPrefabPackToPbBuffer(ChildrenInstanceData, BinaryVersion)
  if ChildrenInstanceData == nil then
    return nil
  end
  local InstanceTree = {}
  for _, Instance in pairs(ChildrenInstanceData) do
    InstanceTree[Instance.InstanceId] = Instance
  end
  local BinaryInfo = {InstanceTree = InstanceTree, BinaryVersion = BinaryVersion}
  CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath(BinaryVersion))
  local pb = require("pb")
  local CopyBinary = CreativeModePbUtility.DeepCopy(BinaryInfo)
  CopyBinary = CreativeModePbUtility.PackInstanceID(CopyBinary)
  local MessageFullName = CreativeModePbUtility.GetPBPackage(BinaryVersion) .. ".binary_info"
  local Buffer = pb.encode(MessageFullName, CopyBinary)
  return Buffer
end
function CreativeModePbUtility.PbBufferUnPackToCustomPrefab(Buffer, BinaryVersion)
  if Buffer == nil then
    return nil
  end
  CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath(BinaryVersion))
  local pb = require("pb")
  local MessageFullName = CreativeModePbUtility.GetPBPackage(BinaryVersion) .. ".binary_info"
  local BinaryInfo = pb.decode(MessageFullName, Buffer)
  local ChildrenInstanceData = {}
  for InstanceId, Instance in pairs(BinaryInfo.InstanceTree) do
    Instance.InstanceId = tostring(InstanceId)
    table.insert(ChildrenInstanceData, Instance)
  end
  return ChildrenInstanceData
end
function CreativeModePbUtility.PackInstanceID(binary)
  local instanceTree = binary.InstanceTree
  if instanceTree ~= nil then
    local uintInstanceTree = {}
    for instanceIdStr, instanceInfo in pairs(instanceTree) do
      local uintInstanceId = tonumber(instanceIdStr)
      uintInstanceTree[uintInstanceId] = instanceInfo
    end
    binary.InstanceTree = uintInstanceTree
  end
  return binary
end
function CreativeModePbUtility.PackSubParameters(binary)
  local gameParameterMaps = binary.GameParameterData
  if gameParameterMaps ~= nil then
    for k, gameParameterMap in pairs(gameParameterMaps) do
      for key, value in pairs(gameParameterMap) do
        CreativeModePbUtility.PackOneSubParameters(value)
      end
    end
  end
  return binary
end
function CreativeModePbUtility.PackOneSubParameters(GameParameterValue)
  if GameParameterValue.SubParameters ~= nil then
    GameParameterValue.SubParameters = CreativeModePbUtility.ToStringEx(GameParameterValue.SubParameters)
  end
end
function CreativeModePbUtility.PbBufferUnPackToBinary(buffer, binaryVersion)
  if buffer == nil then
    return nil
  end
  CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath(binaryVersion))
  local pb = require("pb")
  local MessageFullName = CreativeModePbUtility.GetPBPackage(binaryVersion) .. ".binary_info"
  local binary = pb.decode(MessageFullName, buffer)
  binary = CreativeModePbUtility.UnPackInstanceID(binary)
  binary = CreativeModePbUtility.UnPackSubParameters(binary)
  binary = CreativeModePbUtility.AssignmentOmitData(binary)
  return binary
end
function CreativeModePbUtility.DevPbBufferUpToLatest(buffer, binaryVersion, ReleaseVer)
  local bIsShipping = true
  local STExtraGameplayStatics = import("STExtraGameplayStatics")
  if STExtraGameplayStatics then
    bIsShipping = STExtraGameplayStatics.IsShipping()
    if bIsShipping then
      error("CreativeModePbUtility.BinaryPackToDevPbBuffer only in dev")
      return nil
    end
  end
  if buffer == nil then
    return nil
  end
  local PbPath, MessageFullName = CreativeModePbUtility.GetHistoricalDevPbPath(binaryVersion)
  if not PbPath then
    print(bWriteLog and "CreativeModePbUtility:DevPbBufferUpToLatest no historical version. ver: " .. tostring(binaryVersion))
    return nil
  end
  local pb = require("pb")
  local Ok, Readbytes = pb.loadfile(PbPath)
  if not Ok then
    error("pb\229\141\143\232\174\174\228\184\141\229\144\136\230\179\149, \230\151\160\230\179\149\229\138\160\232\189\189:" .. tostring(PbPath) .. ", Readbytes = " .. tostring(Readbytes))
    return nil
  end
  local Binary = pb.decode(MessageFullName .. ".binary_info", buffer)
  print(bWriteLog and "CreativeModePbUtility:DevPbBufferUpToLatest decode ok.")
  if Binary then
    CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath(ReleaseVer))
    local Buffer = pb.encode(CreativeModePbUtility.GetPBPackage(ReleaseVer) .. ".binary_info", Binary)
    print(bWriteLog and "CreativeModePbUtility:DevPbBufferUpToLatest encode ok.")
    return Buffer
  end
  return nil
end
function CreativeModePbUtility.UnPackInstanceID(binary)
  local instanceTree = binary.InstanceTree
  if instanceTree ~= nil then
    local strInstanceTree = {}
    for instanceId, instanceInfo in pairs(instanceTree) do
      local strInstanceId = tostring(instanceId)
      strInstanceTree[strInstanceId] = instanceInfo
    end
    binary.InstanceTree = strInstanceTree
  end
  return binary
end
function CreativeModePbUtility.UnPackSubParameters(binary)
  local gameParameterMaps = binary.GameParameterData
  if gameParameterMaps ~= nil then
    for k, gameParameterMap in pairs(gameParameterMaps) do
      for key, value in pairs(gameParameterMap) do
        CreativeModePbUtility.UnPackOneSubParameters(value)
      end
    end
  end
  return binary
end
function CreativeModePbUtility.UnPackOneSubParameters(ParameterValue)
  if ParameterValue.SubParameters ~= nil then
    ParameterValue.SubParameters = CreativeModePbUtility.StrToTable(ParameterValue.SubParameters)
  end
end
function CreativeModePbUtility.AssignmentOmitData(binary)
  local instanceTree = binary.InstanceTree
  if instanceTree ~= nil then
    for instancId, instanceInfo in pairs(instanceTree) do
      if instanceInfo.InstanceId == nil or instanceInfo.InstanceId == 0 then
        instanceInfo.InstanceId = instancId
      end
    end
  end
  local gameParameterMaps = binary.GameParameterData
  if gameParameterMaps ~= nil then
    for k, gameParameterMap in pairs(gameParameterMaps) do
      for key, value in pairs(gameParameterMap) do
        value.ParameterKey = key
      end
    end
  end
  return binary
end
function CreativeModePbUtility.InstancePackToPbBuffer(instanceInfo)
  if instanceInfo == nil then
    return nil
  end
  CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath())
  local pb = require("pb")
  local copyInstanceInfo = CreativeModePbUtility.DeepCopy(instanceInfo)
  local MessageFullName_InstanceInfo = CreativeModePbUtility.GetPBPackage() .. ".instance_info"
  local buffer = pb.encode(MessageFullName_InstanceInfo, copyInstanceInfo)
  return buffer
end
function CreativeModePbUtility.InstanceTruncatePackToPbBuffer(instanceInfo)
  if instanceInfo == nil then
    return nil
  end
  CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath())
  local pb = require("pb")
  local copyInstanceInfo = CreativeModePbUtility.DeepCopy(instanceInfo)
  copyInstanceInfo.Transform = nil
  local MessageFullName_InstanceInfo = CreativeModePbUtility.GetPBPackage() .. ".instance_info"
  local buffer = pb.encode(MessageFullName_InstanceInfo, copyInstanceInfo)
  return buffer
end
function CreativeModePbUtility.DeepCompareTables(Table1, Table2)
  if Table2 == nil then
    return Table1
  end
  local Result = {}
  local function CompareRecursive(T1, T2, R)
    if type(T1) ~= "table" or type(T2) ~= "table" then
      return
    end
    for Key, Value in pairs(T1) do
      if type(Value) == "table" then
        if type(T2[Key]) ~= "table" then
          R[Key] = Value
        else
          R[Key] = {}
          CompareRecursive(Value, T2[Key], R[Key])
          if next(R[Key]) == nil then
            R[Key] = nil
          end
        end
      elseif T2[Key] == nil and (Value == "" or Value == 0 or Value == false) then
      elseif T2[Key] ~= Value then
        R[Key] = Value
      end
    end
  end
  CompareRecursive(Table1, Table2, Result)
  Result.AssetId = Table2.AssetId
  return Result
end
function CreativeModePbUtility.UnPackToInstance(buffer, instanceId)
  local begintime = slua.getMiliseconds()
  if buffer == nil then
    return nil
  end
  CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath())
  local pb = require("pb")
  local MessageFullName_InstanceInfo = CreativeModePbUtility.GetPBPackage() .. ".instance_info"
  local instanceInfo = pb.decode(MessageFullName_InstanceInfo, buffer)
  if instanceInfo.InstanceId == nil then
    instanceInfo.InstanceId = instanceId
  end
  return instanceInfo
end
function CreativeModePbUtility.GameParameterValuePackToBuffer(MsgName, ValueTable)
  if ValueTable == nil then
    return nil
  end
  CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath())
  local pb = require("pb")
  local copyValueTable = CreativeModePbUtility.DeepCopy(ValueTable)
  CreativeModePbUtility.PackOneSubParameters(copyValueTable)
  local MessageFullName = CreativeModePbUtility.GetPBPackage() .. "." .. MsgName
  local buffer = pb.encode(MessageFullName, copyValueTable)
  return buffer
end
function CreativeModePbUtility.UnPackToGameParameterValue(MsgName, Buffer)
  local begintime = slua.getMiliseconds()
  if Buffer == nil then
    return nil
  end
  CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath())
  local pb = require("pb")
  local MessageFullName = CreativeModePbUtility.GetPBPackage() .. "." .. MsgName
  local ValueTable = pb.decode(MessageFullName, Buffer)
  CreativeModePbUtility.UnPackOneSubParameters(ValueTable)
  return ValueTable
end
function CreativeModePbUtility.PackLogicObjectParameters(Table)
  local buffer = require("pb.buffer").new()
  local Res, IndexArray, CannotToPBTable = xpcall(CreativeModePbUtility._PackLogicObjectParameters, CreativeModePbUtility.UGCPbErrorMessageHandler, buffer, Table)
  local PBStr
  if Res then
    PBStr = buffer:result()
  else
    PBStr = ""
    IndexArray = {}
    CannotToPB  end
  buffer:delete()
  return IndexArray, PBStr, CannotToPBTable
end
function CreativeModePbUtility._PackLogicObjectParameters(Buffer, Table)
  CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath())
  local pb = require("pb")
  local CreativeModeCustomPbMapConfig = require("GameLua.Mod.CreativeBase.BinaryData.CreativeModeCustomPbMapConfig")
  local CannotToPBTable = {}
  local IndexArray = {}
  for key, value in pairs(Table) do
    local Info = CreativeModeCustomPbMapConfig.KeyInfoMap[key]
    if Info then
      if string.len(Info) > 1 then
        local SpecialTable = CreativeModePbUtility._SpecialToEncode(key, value)
        local BufferStr = pb.encode(Info, SpecialTable)
        Buffer:pack("s", BufferStr)
      else
        Buffer:pack(Info, value)
      end
      table.insert(IndexArray, CreativeModeCustomPbMapConfig.KeyIndexMap[key])
    else
      print(bWriteLog and "CreativeModePbUtility._PackLogicObjectParameters \230\178\161\230\156\137", key)
      CannotToPBTable[key] = value
    end
  end
  return IndexArray, CannotToPBTable
end
function CreativeModePbUtility._SpecialToEncode(InKey, InValue)
  local CreativeModeCustomPbMapConfig = require("GameLua.Mod.CreativeBase.BinaryData.CreativeModeCustomPbMapConfig")
  if CreativeModeCustomPbMapConfig.KeyIsArray[InKey] then
    return {overrides = InValue}
  end
  if type(InValue) == "table" then
    for key, value in pairs(InValue) do
      local TempValue = CreativeModePbUtility._SpecialToEncode(InKey .. "." .. key, value)
      InValue[key] = TempValue
    end
  end
  return InValue
end
function CreativeModePbUtility.UnPackLogicObjectParameters(IndexArray, PBStr)
  if PBStr == nil or PBStr == "" then
    return {}
  end
  local slice = require("pb.slice").new(PBStr)
  local Res, Table = xpcall(CreativeModePbUtility._UnPackLogicObjectParameters, CreativeModePbUtility.UGCPbErrorMessageHandler, slice, IndexArray)
  if not Res then
    Table = {}
  end
  slice:delete()
  return Table
end
function CreativeModePbUtility._UnPackLogicObjectParameters(Slice, IndexArray)
  CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath())
  local pb = require("pb")
  local CreativeModeCustomPbMapConfig = require("GameLua.Mod.CreativeBase.BinaryData.CreativeModeCustomPbMapConfig")
  local Table = {}
  for key, value in pairs(IndexArray) do
    local StrKey = CreativeModeCustomPbMapConfig.IndexKeyMap[value]
    local Info = CreativeModeCustomPbMapConfig.KeyInfoMap[StrKey]
    local TempValue
    if string.len(Info) > 1 then
      TempValue = Slice:unpack("s")
      TempValue = pb.decode(Info, TempValue)
      if type(TempValue) == "table" then
        if TempValue.overrides then
          TempValue = TempValue.overrides
        else
          CreativeModePbUtility._SpecialToDecode(TempValue)
        end
      end
    else
      TempValue = Slice:unpack(Info)
    end
    Table[StrKey] = TempValue
  end
  return Table
end
function CreativeModePbUtility._SpecialToDecode(InValue)
  for key, value in pairs(InValue) do
    if type(value) == "table" then
      if value.overrides then
        InValue[key] = value.overrides
      else
        CreativeModePbUtility._SpecialToDecode(value)
      end
    end
  end
end
function CreativeModePbUtility.PackFunctionList(functionsTable)
  if functionsTable == nil then
    return nil
  end
  local pb = require("pb")
  local buffer = pb.encode("gamesrv_ds.instance_info_event_infos", functionsTable)
  return buffer
end
function CreativeModePbUtility.UnPackFunctionList(functionsBuffer)
  if functionsBuffer == nil then
    return nil
  end
  local pb = require("pb")
  local functionsTable = pb.decode("gamesrv_ds.instance_info_event_infos", functionsBuffer)
  return functionsTable
end
function CreativeModePbUtility.PackCustomParameterValue(ValueTable)
  if ValueTable == nil then
    return nil
  end
  local pb = require("pb")
  local buffer = pb.encode("gamesrv_ds.custom_parameter_value", ValueTable)
  return buffer
end
function CreativeModePbUtility.UnPackCustomParameterValue(valueBuffer)
  if valueBuffer == nil then
    return nil
  end
  local pb = require("pb")
  local ValueTable = pb.decode("gamesrv_ds.custom_parameter_value", valueBuffer)
  return ValueTable
end
function CreativeModePbUtility.UGCPbErrorMessageHandler(msg, category)
  local UGCErrorMsg = ""
  if ServerDataMgr then
    local uid = ServerDataMgr:GetUGCModOwner() or 0
    local slot = ServerDataMgr:GetUGCModCurrentEditSlot() or -1
    local modid = ServerDataMgr:GetUGCModID() or -1
    UGCErrorMsg = string.format("uid:%s slot:%s modid:%s", uid, slot, modid)
    sandbox.LogError(UGCErrorMsg)
  end
  msg = msg .. "\n" .. UGCErrorMsg
  local CommonUtility = require("common.utility")
  CommonUtility.ErrorMessageHandler(msg, category)
end
local base64CharTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
function CreativeModePbUtility.base64encode(data)
  return (data:gsub(".", function(x)
    local r, b = "", x:byte()
    for i = 8, 1, -1 do
      r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
    end
    return r
  end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
    if #x < 6 then
      return ""
    end
    local c = 0
    for i = 1, 6 do
      c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
    end
    return base64CharTable:sub(c + 1, c + 1)
  end) .. ({
    "",
    "==",
    "="
  })[#data % 3 + 1]
end
function CreativeModePbUtility.base64decode(data)
  data = string.gsub(data, "[^" .. base64CharTable .. "=]", "")
  return (data:gsub(".", function(x)
    if x == "=" then
      return ""
    end
    local r, f = "", base64CharTable:find(x) - 1
    for i = 6, 1, -1 do
      r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
    end
    return r
  end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
    if #x ~= 8 then
      return ""
    end
    local c = 0
    for i = 1, 8 do
      c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0)
    end
    return string.char(c)
  end))
end
local EnableBlockyLuaAstJsonPack = false
local bUsePbPackAstJson = true
local bEnableCompress = true
local bUseZSTDCompress = true
function CreativeModePbUtility.BufferCompressData(Buffer)
  if bEnableCompress and Buffer ~= nil and Buffer ~= "" then
    local UCreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
    local CompressSuc = false
    local CompressedData = ""
    if bUseZSTDCompress then
      CompressSuc, CompressedData = UCreativeModeBlueprintLibrary.ZSTDCompressData(Buffer, CompressedData, 19)
    else
      CompressSuc, CompressedData = UCreativeModeBlueprintLibrary.Lz4CompressData(Buffer, CompressedData)
    end
    if CompressSuc then
      Buffer = CompressedData
    end
  end
  return Buffer
end
function CreativeModePbUtility.DecompressData(Buffer)
  if bEnableCompress and Buffer ~= nil and Buffer ~= "" then
    local UCreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
    local DecompressSuc = false
    local DecompressData = ""
    if bUseZSTDCompress then
      DecompressSuc, DecompressData = UCreativeModeBlueprintLibrary.ZSTDDecompressData(Buffer, DecompressData)
    else
      DecompressSuc, DecompressData = UCreativeModeBlueprintLibrary.DecompressData(Buffer, DecompressData)
    end
    if DecompressSuc then
      Buffer = DecompressData
    end
  end
  return Buffer
end
function CreativeModePbUtility.BlockyLuaAstTablePackToPbBuffer(AstTable, binaryVersion)
  if AstTable == nil then
    return nil
  end
  if not EnableBlockyLuaAstJsonPack then
    local json = require("common.json_util")
    local AstJson = json.encode(AstTable)
    return CreativeModePbUtility.BufferCompressData(AstJson)
  elseif bUsePbPackAstJson then
    CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath(binaryVersion))
    local pb = require("pb")
    local MessageFullName_blockylua_ast_message = CreativeModePbUtility.GetPBPackage(binaryVersion) .. ".blockylua_blockygraphdata_serializedata"
    local buffer = pb.encode(MessageFullName_blockylua_ast_message, AstTable)
    return CreativeModePbUtility.BufferCompressData(buffer)
  else
    local buffer = slua.LuaArchiverEncode(LuaStateWrapper, AstTable)
    return CreativeModePbUtility.BufferCompressData(buffer)
  end
end
function CreativeModePbUtility.UnPackToBlockyLuaAstTable(buffer, binaryVersion)
  if buffer == nil then
    return nil
  end
  if buffer == "" then
    return {}
  end
  buffer = CreativeModePbUtility.DecompressData(buffer)
  if not EnableBlockyLuaAstJsonPack then
    local json = require("common.json_util")
    return json.decode(buffer)
  elseif bUsePbPackAstJson then
    CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath(binaryVersion))
    local pb = require("pb")
    local MessageFullName_blockylua_ast_message = CreativeModePbUtility.GetPBPackage(binaryVersion) .. ".blockylua_blockygraphdata_serializedata"
    local AstTable = pb.decode(MessageFullName_blockylua_ast_message, buffer)
    return AstTable
  else
    local AstTable = slua.LuaArchiverDecode(LuaStateWrapper, buffer) or {}
    return AstTable
  end
end
function CreativeModePbUtility.BlockyLuaAstContentPackToSaveBuffer(AstContent, binaryVersion)
  if AstContent == nil then
    return nil
  end
  if AstContent == "" then
    return AstContent
  end
  if not EnableBlockyLuaAstJsonPack then
    return CreativeModePbUtility.BufferCompressData(AstContent)
  end
  local pb = require("pb")
  local json = require("common.json_util")
  local Suc, AstTable = xpcall(json.decode, CreativeModePbUtility.UGCPbErrorMessageHandler, AstContent)
  if Suc then
    return CreativeModePbUtility.BlockyLuaAstTablePackToPbBuffer(AstTable, binaryVersion)
  else
    return CreativeModePbUtility.BufferCompressData(AstContent)
  end
end
function CreativeModePbUtility.UnPackToBlockyLuaAstContent(SaveBuffer, binaryVersion)
  if SaveBuffer == nil then
    return nil
  end
  if SaveBuffer == "" then
    return SaveBuffer
  end
  if not EnableBlockyLuaAstJsonPack then
    return CreativeModePbUtility.DecompressData(SaveBuffer)
  end
  local AstTable = CreativeModePbUtility.UnPackToBlockyLuaAstTable(SaveBuffer, binaryVersion)
  local json = require("common.json_util")
  local AstJson = json.encode(AstTable)
  return AstJson
end
function CreativeModePbUtility.LuaCodeInfoPackToBuffer(LuaCodeInfo)
  if LuaCodeInfo == nil then
    return nil
  end
  CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath())
  local pb = require("pb")
  local copyLuaCodeInfo = CreativeModePbUtility.DeepCopy(LuaCodeInfo)
  local MessageFullName_LuaCodeInfo = CreativeModePbUtility.GetPBPackage() .. ".luacode_info"
  local buffer = pb.encode(MessageFullName_LuaCodeInfo, copyLuaCodeInfo)
  return buffer
end
function CreativeModePbUtility.UnPackToLuaCodeInfo(buffer)
  if buffer == nil then
    return nil
  end
  CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath())
  local pb = require("pb")
  local MessageFullName_LuaCodeInfo = CreativeModePbUtility.GetPBPackage() .. ".luacode_info"
  local LuaCodeInfo = pb.decode(MessageFullName_LuaCodeInfo, buffer)
  return LuaCodeInfo
end
CreativeModePbUtility.ProtoMessageMap = {
  BatchEditInstanceInfo = "batch_edit_instance_info",
  BatchPullGameParameterInfo = "batch_pull_game_parameter_info",
  BatchPullInstanceInfo = "batch_pull_instance_info",
  BlockyLuaPresetExtraDataInfo = "blockylua_preset_extra_data_info",
  DataTransferRPCCallInfo = "data_transfer_rpc_call_info",
  GeneralValueInfo = "Value",
  PrefabMallMetaBinInfo = "prefab_mall_meta_bin_cache_info",
  CustomAssetCacheInfo = "custom_asset_cache_info",
  CustomAssetCacheMetaInfo = "custom_asset_cache_meta_info",
  BinaryDataUploadToAssetCenterInfo = "binary_data_upload_to_asset_center_info",
  InGameCustomAssetKeyMappingValue = "game_parameters_ingamecustomassetkeymapping_value",
  ActorEditorActorInfo = "actor_info",
  ActorEditorComponentInfo = "component_info",
  CreativeFileInfo = "creative_file_info",
  MapScriptInfo = "map_script_info"
}
function CreativeModePbUtility.TablePackToPbBufferByMsg(table, msg, binaryVersion, SkipDeepCopy, EnCodeDefaultValues)
  if table == nil then
    return nil
  end
  CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath(binaryVersion))
  local pb = require("pb")
  local copy  if SkipDeepCopy ~= true then
    copytable = CreativeModePbUtility.DeepCopy(table)
  end
  local MessageFullName = CreativeModePbUtility.GetPBPackage(binaryVersion) .. "." .. msg
  if EnCodeDefaultValues == true then
    pb.option("encode_default_values")
  end
  local buffer = pb.encode(MessageFullName, copytable)
  if EnCodeDefaultValues == true then
    pb.option("no_encode_default_values")
  end
  return buffer
end
function CreativeModePbUtility.UnPackToTableByMsg(buffer, msg, binaryVersion, NoDefaultValues)
  if buffer == nil then
    return nil
  end
  CreativeModePbUtility.LoadFile(CreativeModePbUtility.GetPbFilePath(binaryVersion))
  local pb = require("pb")
  local MessageFullName = CreativeModePbUtility.GetPBPackage(binaryVersion) .. "." .. msg
  if NoDefaultValues == true then
    pb.option("no_default_values")
  end
  local success, result = pcall(pb.decode, MessageFullName, buffer)
  if NoDefaultValues == true then
    pb.option("auto_default_values")
  end
  if not success then
    log_error_format("Protobuf decode failed: Result = %s", result)
    return nil
  end
  return result
end
function CreativeModePbUtility._NewTable(TablePool)
  if TablePool ~= nil then
    return TablePool:Get()
  end
  return {}
end
function CreativeModePbUtility.GenerateGeneralValue(Value, TablePool)
  local GeneralValue = CreativeModePbUtility._NewTable(TablePool)
  local ValueType = type(Value)
  if ValueType == "nil" then
    GeneralValue.NilValue = true
  elseif ValueType == "boolean" then
    GeneralValue.Bool  elseif ValueType == "number" then
    if math.type(Value) == "integer" then
      GeneralValue.LongInt    else
      GeneralValue.Float    end
  elseif ValueType == "string" then
    GeneralValue.String  elseif ValueType == "table" then
    local TableValue = CreativeModePbUtility._NewTable(TablePool)
    local Elements = CreativeModePbUtility._NewTable(TablePool)
    TableValue.    for K, V in pairs(Value) do
      local KeyValueInfo = CreativeModePbUtility._NewTable(TablePool)
      local KGeneralValue = CreativeModePbUtility.GenerateGeneralValue(K, TablePool)
      local VGeneralValue = CreativeModePbUtility.GenerateGeneralValue(V, TablePool)
      KeyValueInfo.Key = KGeneralValue
      KeyValueInfo.Value = VGeneralValue
      table.insert(Elements, KeyValueInfo)
    end
    GeneralValue.  else
    print(bWriteLog and "CreativeModePbUtility.GenerateGeneralValue: ValueType is not supported")
  end
  return GeneralValue
end
function CreativeModePbUtility.RestoreGeneralValue(GeneralValue)
  if GeneralValue == nil then
    return nil
  end
  if type(GeneralValue) == "table" then
    local GeneralValueKey, GeneralValueValue
    local Type = GeneralValue.kind
    if Type ~= nil then
      GeneralValueKey = Type
      GeneralValueValue = GeneralValue[Type]
    else
      for Key, Value in pairs(GeneralValue) do
        GeneralValue        GeneralValue        break
      end
    end
    if GeneralValueKey ~= nil and GeneralValueValue ~= nil then
      if GeneralValueKey == "NilValue" then
        return nil
      elseif GeneralValueKey == "TableValue" then
        local Elements = GeneralValueValue.Elements
        GeneralValueValue.Elements = nil
        if Elements ~= nil then
          for i = 1, #Elements do
            local KeyValueInfo = Elements[i]
            local Key = CreativeModePbUtility.RestoreGeneralValue(KeyValueInfo.Key)
            local Value = CreativeModePbUtility.RestoreGeneralValue(KeyValueInfo.Value)
            GeneralValueValue[Key] = Value
          end
        end
        return GeneralValueValue
      else
        return GeneralValueValue
      end
    end
  else
    return GeneralValue
  end
  return nil
end
function CreativeModePbUtility.LuaValuePackToBuff(LuaValue)
  local GeneralValue = CreativeModePbUtility.GenerateGeneralValue(LuaValue)
  return CreativeModePbUtility.TablePackToPbBufferByMsg(GeneralValue, CreativeModePbUtility.ProtoMessageMap.GeneralValueInfo, nil, true)
end
function CreativeModePbUtility.UnPackToLuaValue(Buff)
  local GeneralValue = CreativeModePbUtility.UnPackToTableByMsg(Buff, CreativeModePbUtility.ProtoMessageMap.GeneralValueInfo)
  return CreativeModePbUtility.RestoreGeneralValue(GeneralValue)
end
function CreativeModePbUtility.GetPbDiff(MsgName, OldPb, NewPb)
  local _result, Diff = pcall(CreativeModePbUtility._GetPbDiff, MsgName, OldPb, NewPb)
  if not _result then
    return nil
  end
  return Diff
end
function CreativeModePbUtility._GetPbDiff(MsgName, OldPb, NewPb)
  local OldTable = CreativeModePbUtility.UnPackToGameParameterValue(MsgName, OldPb)
  local NewTable = CreativeModePbUtility.UnPackToGameParameterValue(MsgName, NewPb)
  local MsgFullName = string.format("%s.%s", CreativeModePbUtility.GetPBPackage(), MsgName)
  local PbTableDiff = require("GameLua.Mod.CreativeBase.BinaryData.CreativeModeTableDiff2")
  local Diff = PbTableDiff.TableDiff2(MsgFullName, OldTable, NewTable)
  return Diff
end
function CreativeModePbUtility.TableRevertByDiff(MsgName, OldPb, Diff)
  local _result, NewPb = pcall(CreativeModePbUtility._TableRevertByDiff, MsgName, OldPb, Diff)
  if not _result then
    return nil
  end
  return NewPb
end
function CreativeModePbUtility._TableRevertByDiff(MsgName, OldPb, Diff)
  local OldTable = CreativeModePbUtility.UnPackToGameParameterValue(MsgName, OldPb)
  local MsgFullName = string.format("%s.%s", CreativeModePbUtility.GetPBPackage(), MsgName)
  local PbTableDiff = require("GameLua.Mod.CreativeBase.BinaryData.CreativeModeTableDiff2")
  local NewTable = PbTableDiff.TableRevert(MsgFullName, OldTable, Diff)
  local NewPb = CreativeModePbUtility.GameParameterValuePackToBuffer(MsgName, NewTable)
  return NewPb
end
return CreativeModePbUtility