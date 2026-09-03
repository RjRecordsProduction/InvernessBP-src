local logic_touch_transmission = {TouchTransmissionInst = nil, HandleTransmissionResultCallback = nil}
local TransmissionFileType = {
  OBB = "1",
  PAK = "2",
  ALL = "3"
}
function logic_touch_transmission:Init()
  log(bWriteLog and "logic_touch_transmission:Init")
  if self.TouchTransmissionInst == nil then
    local version_update_ui = UIManager.GetUI(UIManager.UI_Config.version_update)
    if version_update_ui then
      version_update_ui:TouchTransMissionStart()
    end
    local TouchTransmission = import("TouchTransmission")
    self.TouchTransmissionInst = TouchTransmission.GetInstance()
    self.TouchTransmissionInst:Initialize()
    self.TouchTransmissionInst.OnTransmissionComplete:Clear()
    self.TouchTransmissionInst.OnTransmissionComplete:Add(function(retjson)
      log(bWriteLog and "logic_touch_transmission:OnTransmissionComplete: " .. retjson)
      self:HandleTransmissionResult(json.decode(retjson))
    end)
  end
end
function logic_touch_transmission:Uninit()
  log(bWriteLog and "logic_touch_transmission:Uninit")
  if self.TouchTransmissionInst ~= nil then
    self.TouchTransmissionInst.OnTransmissionComplete:Clear()
    local TouchTransmissionCls = import("TouchTransmission")
    TouchTransmissionCls.UnInitialize()
  end
  self.TouchTransmissionInst = nil
end
function logic_touch_transmission:GetTouchTransmissionInst()
  if self.TouchTransmissionInst == nil then
    self:Init()
  end
  return self.TouchTransmissionInst
end
function logic_touch_transmission:HandleTransmissionResult(ret)
  log(bWriteLog and "logic_touch_transmission:HandleTransmissionResult")
  if ret == nil then
    if self.HandleTransmissionResultCallback ~= nil then
      self.HandleTransmissionResultCallback()
    end
    return
  end
  if ret.cmd == "onResult" then
    local version_update_ui = UIManager.GetUI(UIManager.UI_Config.version_update)
    if version_update_ui then
      version_update_ui:TouchTransMissionEnd(ret.err)
    end
    if self.HandleTransmissionResultCallback ~= nil then
      self.HandleTransmissionResultCallback()
    end
  elseif ret.cmd == "onProgress" then
    log(bWriteLog and string.format("logic_touch_transmission:HandleTransmissionResult - onProgress: %s, %.2fM, %.2fM", ret.cur_file, ret.copiedBytes / 1024 / 1024, ret.totalBytes / 1024 / 1024))
    local version_update_ui = UIManager.GetUI(UIManager.UI_Config.version_update)
    if version_update_ui then
      version_update_ui:TouchTransMissionProgress(ret.copiedBytes, ret.totalBytes)
    end
  else
    log(bWriteLog and string.format("logic_touch_transmission:HandleTransmissionResult - unknown cmd: %s", ret.cmd))
  end
end
function logic_touch_transmission:HandleReceivedPakFiles(callback)
  log(bWriteLog and "logic_touch_transmission:HandleReceivedPakFiles")
  self.HandleTransmissionResultCallback = callback
  if self:IsTransmissionAvailable(false) == false then
    log(bWriteLog and "logic_touch_transmission:HandleReceivedPakFiles - Transmission not available, skip execution")
    self:HandleTransmissionResult(nil)
    return
  end
  local params = {
    fileType = TransmissionFileType.PAK
  }
  local TouchTransmissionInstance = self:GetTouchTransmissionInst()
  TouchTransmissionInstance:HandleReceivedPakFiles(json.encode(params))
end
function logic_touch_transmission:GenTransisionIndexFile()
  if self:IsTransmissionAvailable(true) == false then
    log(bWriteLog and "logic_touch_transmission:GenTransisionIndexFile - Transmission not available, skip execution")
    return
  end
  local jsonFile = string.format("Paks/%s", "transmission.json")
  local currentAppVersion = Client.GetNativeVersion()
  local existingFileContent = Client.LoadFileToString(jsonFile)
  if existingFileContent ~= nil and existingFileContent ~= "" then
    local success, existingJson = pcall(json.decode, existingFileContent)
    if success and existingJson and existingJson.ver == currentAppVersion then
      log(bWriteLog and string.format("logic_touch_transmission:GenTransisionIndexFile - transmission.json exists and version %s matches current version, skip refresh", currentAppVersion))
      return
    end
  end
  local TimeUtil = require("client.common.time_util")
  local startTime = TimeUtil.GetMiliseconds()
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local appPackageName = UKismetSystemLibrary.GetGameBundleId()
  local fileUriAuthority = string.format("%s.touch_transmission.fileprovider", appPackageName)
  local fileUriPathName = "external_files"
  local fileList = {}
  local fileIdCounter = 0
  local basePakFileList = PufferInterface.ReturnSplitMiniPakFilelist()
  if basePakFileList ~= nil then
    for k, v in ipairs(basePakFileList) do
      log(bWriteLog and "logic_touch_transmission:GenTransisionIndexFile: " .. v)
      local filePath = string.format("%sPaks/%s", Client.ProjectSavedDir(), v)
      log(bWriteLog and "logic_touch_transmission:GenTransisionIndexFile filePath:", filePath)
      local fileSize = Client.GetFileSizeOnDiskBytes(filePath)
      if 0 < fileSize then
        fileIdCounter = fileIdCounter + 1
        local fielUri = string.format("content://%s/%s/%s", fileUriAuthority, fileUriPathName, v)
        local fileInfo = {
          id = fileIdCounter,
          fileUri = fielUri,
          size = fileSize
        }
        table.insert(fileList, fileInfo)
      else
        log(bWriteLog and string.format("logic_touch_transmission:GenTransisionIndexFile file %s size is 0", v))
      end
    end
    local pufferInfoJson = "PufferFileList.json"
    local filePath = string.format("%sPaks/%s", Client.ProjectSavedDir(), pufferInfoJson)
    local fileSize = Client.GetFileSizeOnDiskBytes(filePath)
    if 0 < fileSize then
      fileIdCounter = fileIdCounter + 1
      local fielUri = string.format("content://%s/%s/%s", fileUriAuthority, fileUriPathName, pufferInfoJson)
      local fileInfo = {
        id = fileIdCounter,
        fileUri = fielUri,
        size = fileSize
      }
      table.insert(fileList, fileInfo)
    end
  end
  local obbFileInfo = logic_touch_transmission:GetObbFileInfo()
  if obbFileInfo ~= nil then
    fileIdCounter = fileIdCounter + 1
    obbFileInfo.id = fileIdCounter
    table.insert(fileList, obbFileInfo)
  end
  local hash = self:CalculateFilesHash(fileList)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local AppBundleName = UKismetSystemLibrary.GetGameBundleId()
  local resType = "nil"
  local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
  if PufferResManager ~= nil then
    if PufferResManager:HaveBasetexmd() then
      resType = "md"
    elseif PufferResManager:HaveBasetexld() then
      resType = "ld"
    end
  end
  local jsonObject = {
    ver = currentAppVersion,
    hash = hash,
    app = AppBundleName,
    res = resType,
    files = fileList
  }
  log_tree("logic_touch_transmission:GenTransisionIndexFile", jsonObject)
  local timeSpan = TimeUtil.GetMiliseconds() - startTime
  log(bWriteLog and "logic_touch_transmission:GenTransisionIndexFile timespan: " .. tostring(jsonObject))
  local jsonFile = string.format("Paks/%s", "transmission.json")
  Client.SaveStringToFile(json.encode(jsonObject), jsonFile)
end
function logic_touch_transmission:GetObbFileInfo()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.Android then
    log(bWriteLog and "logic_touch_transmission:GetObbFileInfo - Not Android platform, skip execution")
    return nil
  end
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local AppBundleName = UKismetSystemLibrary.GetGameBundleId()
  local obbPath = Client.GetObbFilePath()
  local AppVersionCode = Client.GetApplicationVersion()
  local VersionCode
  if AppVersionCode then
    VersionCode = string.match(AppVersionCode, "[^.]+$")
  end
  local obbFileName = string.format("main.%s.%s.obb", VersionCode or "0", AppBundleName or "unknown")
  local obbFilePath = string.format("%s/%s", obbPath, obbFileName)
  local obbfileSize = Client.GetFileSizeOutsideSandbox(obbFilePath)
  log(bWriteLog and string.format("logic_touch_transmission:GetObbFileInfo obbFilePath: %s, obbfileSize3: %d", obbFilePath, obbfileSize))
  if 0 < obbfileSize then
    local obbFileUri = string.format("content://%s/%s/%s", string.format("%s.touch_transmission.fileprovider", AppBundleName), "obb_files", obbFileName)
    local fileInfo = {fileUri = obbFileUri, size = obbfileSize}
    return fileInfo
  end
  return nil
end
function logic_touch_transmission:IsTransmissionAvailable(skipCheckOSVersion)
  skipCheckOSVersion = skipCheckOSVersion or false
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.Android then
    log(bWriteLog and "logic_touch_transmission:IsTransmissionAvailable - Not Android platform, skip execution")
    return false
  end
  if skipCheckOSVersion == false then
    local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
    local OSMajorVersion = device_module:GetOSMajorVersion()
    log(bWriteLog and string.format("logic_touch_transmission:HandleReceivedPakFiles - OSMajorVersion: %d", OSMajorVersion))
    if OSMajorVersion < 16 then
      log(bWriteLog and "logic_touch_transmission:HandleReceivedPakFiles - OS major version < 16, skip execution")
      return false
    end
  end
  local DisableTrans = HDmpveRemote.HDmpveRemoteConfigGetBool("DisableTouchTransmission", false)
  if DisableTrans then
    log(bWriteLog and "logic_touch_transmission:IsTransmissionAvailable - DisableTouchTransmission is true, skip execution")
    return false
  end
  return true
end
local extractFileName = function(filePath)
  if filePath == nil or filePath == "" then
    return nil
  end
  local lastIndex = filePath:match("^.*()[/\\]")
  if lastIndex then
    return filePath:sub(lastIndex + 1)
  else
    return filePath
  end
end
function logic_touch_transmission:CalculateFilesHash(filePaths)
  if filePaths == nil or #filePaths == 0 then
    log(bWriteLog and "logic_touch_transmission:CalculateFilesHash - File paths list is nil or empty")
    return nil
  end
  local sortedFiles = {}
  for i, fileInfo in ipairs(filePaths) do
    if fileInfo ~= nil then
      table.insert(sortedFiles, fileInfo)
    end
  end
  table.sort(sortedFiles, function(a, b)
    return (a.id or 0) < (b.id or 0)
  end)
  local concatenatedNames = {}
  for i, fileInfo in ipairs(sortedFiles) do
    if fileInfo == nil or fileInfo.fileUri == nil or fileInfo.fileUri == "" then
      log(bWriteLog and "logic_touch_transmission:CalculateFilesHash - Skip empty file path")
    else
      local fileName = extractFileName(fileInfo.fileUri)
      if fileName == nil or fileName == "" then
        log(bWriteLog and string.format("logic_touch_transmission:CalculateFilesHash - Failed to extract file name from: %s", fileInfo))
      else
        log(bWriteLog and string.format("logic_touch_transmission:CalculateFilesHash - Processing file[id=%d]: %s", fileInfo.id or 0, fileName))
        table.insert(concatenatedNames, fileName)
      end
    end
  end
  local concatenatedString = table.concat(concatenatedNames)
  local hexString = Client.SHA256(concatenatedString)
  log(bWriteLog and string.format("logic_touch_transmission:CalculateFilesHash - Calculated files %s hash: %s", concatenatedString, hexString))
  return hexString
end
function logic_touch_transmission:OnLogin()
  self:GenTransisionIndexFile()
end
function logic_touch_transmission:GetTransmissionResType()
  local resType = 0
  if self:GetTouchTransmissionInst() ~= nil then
    local rawJson = self:GetTouchTransmissionInst():GetTransmissionRawJsonContent()
    log(bWriteLog and string.format("logic_touch_transmission:GetTransmissionResType - rawJson: %s", rawJson))
    if rawJson == nil or rawJson == "" then
      return resType
    end
    local json = json.decode(rawJson)
    if json == nil then
      return resType
    end
    if json.res == "md" then
      resType = 1
    elseif json.res == "ld" then
      resType = 2
    end
  end
  log(bWriteLog and string.format("logic_touch_transmission:GetTransmissionResType - resType: %d", resType))
  return resType
end
return logic_touch_transmission