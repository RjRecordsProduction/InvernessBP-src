local ProtoBufUtility = {}
local CreativeBinaryDataVersionConfig = require("common.ProtoBuf.CreativeBinaryDataVersionConfig")
local PbFilePath = "gamesrv_ds/ugc_binary_data.pb"
local HistoricalPbFilePath = "gamesrv_ds/binary_historicalversion/ugc_binary_data_%s.pb"
local DevHistoricalPbFilePath = "gamesrv_ds/binary_devhistoricalversion/ugc_binary_data_%s.pb"
local PBPackage = "gamesrv_ds"
local HistoricalPBPackage = "gamesrv_ds.binarydata_%s"
local protoFileCache = true
local loaded = {}
function ProtoBufUtility.LoadFile(fileName)
  if loaded[fileName] then
    return
  end
  local pb = require("pb")
  pb.loadfile(fileName)
  if protoFileCache then
    loaded[fileName] = true
  end
end
ProtoBufUtility.LoadFile("gamesrv_ds/ugc_binary_base.pb")
function ProtoBufUtility.DeepCopy(tOrigin)
  local tCopy = {}
  for key, value in pairs(tOrigin) do
    if type(value) == "table" then
      value = ProtoBufUtility.DeepCopy(value)
    end
    tCopy[key] = value
  end
  return tCopy
end
function ProtoBufUtility.GetPbFilePath(binaryVersion)
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
function ProtoBufUtility.GetPBPackage(binaryVersion)
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
ProtoBufUtility.ProtoMessageMap = {
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
function ProtoBufUtility.TablePackToPbBufferByMsg(table, msg, binaryVersion, SkipDeepCopy, EnCodeDefaultValues)
  if table == nil then
    return nil
  end
  ProtoBufUtility.LoadFile(ProtoBufUtility.GetPbFilePath(binaryVersion))
  local pb = require("pb")
  local copy  if SkipDeepCopy ~= true then
    copytable = ProtoBufUtility.DeepCopy(table)
  end
  local MessageFullName = ProtoBufUtility.GetPBPackage(binaryVersion) .. "." .. msg
  if EnCodeDefaultValues == true then
    pb.option("encode_default_values")
  end
  local buffer = pb.encode(MessageFullName, copytable)
  if EnCodeDefaultValues == true then
    pb.option("no_encode_default_values")
  end
  return buffer
end
function ProtoBufUtility.UnPackToTableByMsg(buffer, msg, binaryVersion, NoDefaultValues)
  if buffer == nil then
    return nil
  end
  ProtoBufUtility.LoadFile(ProtoBufUtility.GetPbFilePath(binaryVersion))
  local pb = require("pb")
  local MessageFullName = ProtoBufUtility.GetPBPackage(binaryVersion) .. "." .. msg
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
return ProtoBufUtility