local pak_util = {}
local local local local string_gsub = string.gsub
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
function pak_util.IsFileExist(path)
  if not path or path == "" then
    return false
  end
  local StringUtil = require("common.string_util")
  local PathList = StringUtil.Split(path, ".")
  local ResPath = PathList[1]
  local bExist = Client.IsGameFileExistsWithPakCheck(ResPath)
  return bExist
end
function pak_util.IsMapExist(path)
  if IsEditor and not slua_GameFrontendHUD.bEnableEditorPufferDownload then
    return true
  end
  if not path or path == "" then
    return false
  end
  local filepath = Client.ConvertGamePathToRelativeFilePath(path)
  filepath = string_gsub(filepath, "%.uasset", ".umap")
  local bExist = Client.IsFileExistsWithPakCheckMatchExt(filepath)
  log(bWriteLog and string.format("pak_util.IsMapExist filepath = %s, bExist = %s", filepath, tostring(bExist)))
  return bExist
end
function pak_util.IsPufferDownloaded(path)
  if not Client then
    return true
  end
  if PublishRegionMacros.IsFITVersion() then
    return pak_util.IsFileExist(path)
  end
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local state = PufferODPakManager:GetStateByPath(path)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  return state == PufferConst.ENUM_DownloadState.Done
end
function pak_util.IsVideoFileExist(path)
  if not path or path == "" then
    return false
  end
  local videoPath = DataMgr.GetVideoDownloadPath(path)
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  local fileName, ext = VideoLibrary.GetFileNameAndExtension(videoPath)
  local filePath = Client.ConvertGamePathToRelativeFilePath(videoPath)
  filePath = string_gsub(filePath, "%.uasset", ext)
  local bExist = Client.IsFileExistsWithPakCheckMatchExt(filePath)
  return bExist
end
function pak_util.CheckAndDownloadWithCallback(path, callback)
  if pak_util.IsPufferDownloaded(path) then
    return callback and callback()
  else
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    return PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {path}, nil, callback)
  end
end
function pak_util.GetResPathListFromTable(TableName, ColNames, Key, ExtraParam)
  if type(TableName) ~= "string" or Key == nil then
    return {}
  end
  local CfgTable = CDataTable.GetTableData(TableName, Key)
  if not CfgTable then
    return {}
  end
  ExtraParam = ExtraParam or {}
  local StringUtil = require("common.string_util")
  local PathList = {}
  for _, Col in pairs(ColNames) do
    local Path = CfgTable[Col]
    Path = ExtraParam.bRemoveSuffix and StringUtil.Split(Path, ".")[1] or Path
    if Path then
      table.insert(PathList, Path)
    end
  end
  return PathList
end
function pak_util.IsPufferDownloadedByPathList(PathList, bPassiveDownload)
  bPassiveDownload = bPassiveDownload or false
  local bDownloaded = true
  if bPassiveDownload then
    local passive_resource_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.passive_resource_downloader)
    bDownloaded = passive_resource_downloader:CheckResourceHasBeenDownloaded(PathList)
  else
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local State = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, PathList)
    bDownloaded = State == PufferConst.ENUM_DownloadState.Done
  end
  return bDownloaded
end
function pak_util.IsTextureDownloadedByPath(path, bPassiveDownload)
  bPassiveDownload = bPassiveDownload or false
  local bDownloaded = true
  if bPassiveDownload then
    local passive_resource_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.passive_resource_downloader)
    bDownloaded = passive_resource_downloader:CheckTextureHasBeenDownloaded(path)
  else
    bDownloaded = pak_util.IsPufferDownloaded(path)
  end
  return bDownloaded
end
function pak_util.IsRelatedPakExistByItemID(itemID)
  if IsEditor and not slua_GameFrontendHUD.bEnableEditorPufferDownload then
    return true
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local Paks = PufferManager.GetPakNamesByItemID(itemID)
  for PakName, _ in pairs(Paks) do
    if PakName ~= "" then
      local FullPath = Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR .. PakName
      local bPakExist = Client.IsFileExistsWithOutPakCheck(FullPath)
      if not bPakExist then
        return false
      end
    end
  end
  return true
end
return pak_util