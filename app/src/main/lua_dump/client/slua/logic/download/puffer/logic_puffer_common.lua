local StringUtil = require("common.string_util")
local logic_puffer_common = {
  FILE_LIST_NAME = "PufferFileList.json",
  FILE_LIST_PB_NAME = "PufferFileList.pb",
  PufferFileListJson = {},
  PufferFileMd5 = nil,
  FILE_MD5_LEN = 200,
  PufferFileItemData = {},
  PufferVersionMatchAppVersion = false,
  PufferContentInited = false,
  USFInited = false,
  PufferFileListUseNewFormat = nil
}
function logic_puffer_common.ProcessDownloadEifsInBase()
  local ui_util = require("client.common.ui_util")
  local gameInstance = ui_util.GetGameInstance()
  local enable = HDmpveRemote.HDmpveRemoteConfigGetBool("DownloadEifsInBase", false)
  local val = enable and 1 or 0
  local level = gameInstance:GetDeviceLevel()
  if level == 0 then
    log_format("logic_puffer_common.ProcessDownloadEifsInBase. is low")
    val = 0
  end
  log_format("logic_puffer_common.ProcessDownloadEifsInBase. val=%s", val)
  gameInstance:ExecuteCMD("Download.DownloadEifsInBase", val)
end
function logic_puffer_common.GetPufferFileListName()
  if logic_puffer_common.PufferFileListUseNewFormat == nil then
    logic_puffer_common.PufferFileListUseNewFormat = HDmpveRemote.HDmpveRemoteConfigGetBool("PufferFileListUseNewFormat", false)
  end
  return logic_puffer_common.PufferFileListUseNewFormat and logic_puffer_common.FILE_LIST_PB_NAME or logic_puffer_common.FILE_LIST_NAME
end
function logic_puffer_common.ReadPufferFileListContent(force)
  log_format("logic_puffer_common.ReadPufferFileListContent. force=%s", force)
  local fileName = logic_puffer_common.GetPufferFileListName()
  local md5ContentLen = logic_puffer_common.FILE_MD5_LEN
  local fileContent = ""
  local data
  if logic_puffer_common.PufferFileListUseNewFormat then
    local filePath = PufferInterface.DOWNLOAD_DIR_RELATIVE .. fileName
    local ScriptHelperClient = import("ScriptHelperClient")
    fileContent = ScriptHelperClient.LoadFileToArray(filePath)
  else
    local filePath = Client.ProjectSavedDir() .. PufferInterface.DOWNLOAD_DIR_RELATIVE .. fileName
    if Client.IsFileExistsWithOutPakCheck(filePath .. "test") then
      log_format("logic_puffer_common.ReadPufferFileListContent. read puffer test")
      fileContent = GCPufferDownloader.ReadFile(Puffer, fileName .. "test")
    else
      log_format("logic_puffer_common.ReadPufferFileListContent. read puffer")
      if Puffer then
        fileContent = GCPufferDownloader.ReadFile(Puffer, fileName)
      else
        local isFileExist = Client.IsFileExistsWithOutPakCheck(filePath)
        log_format("logic_puffer_common.ReadPufferFileListContent. isFileExist=%s", isFileExist)
        if isFileExist then
          fileContent = Client.LoadFileToStringByFullPath(filePath)
        end
      end
    end
  end
  local MD5 = ""
  if md5ContentLen < string.len(fileContent) then
    local startTime = slua.getMiliseconds()
    MD5 = Client.MD5HashAnsiString(string.sub(fileContent, 0, md5ContentLen))
    local endTime = slua.getMiliseconds()
    log_format("logic_puffer_common.ReadPufferFileListContent. PufferFileMd5 cost time = %s", endTime - startTime)
  else
    MD5 = nil
  end
  if not force and logic_puffer_common.PufferFileMd5 == MD5 then
    log_format("logic_puffer_common.ReadPufferFileListContent. same MD5")
    return
  end
  logic_puffer_common.PufferFileMd5 = MD5
  log_format("logic_puffer_common.ReadPufferFileListContent. handle file content")
  if logic_puffer_common.PufferFileListUseNewFormat then
    local pb = require("pb")
    local protoc = require("protoc")
    protoc.LoadFile("puffer/PufferFileList.pb")
    local startTime = slua.getMiliseconds()
    local ret, pbData = xpcall(function()
      return pb.decode("Puffer.PufferFileList", fileContent)
    end, function(err)
      logic_puffer_common.PufferFileMd5 = nil
      log_error("logic_puffer_common.ReadPufferFileListContent. pb decode error: %s", err)
      return {}
    end)
    data = pbData
    log_format("logic_puffer_common.ReadPufferFileListContent. costTime=%s", slua.getMiliseconds() - startTime)
    local diff_list = data.diff_list
    if diff_list then
      for key, val in pairs(diff_list) do
        diff_list[key] = val.data
      end
    end
    local check_list = data.check_list
    if check_list then
      for key, val in pairs(check_list) do
        check_list[key] = val.data
      end
    end
  else
    data = json.decode(fileContent) or {}
  end
  logic_puffer_common.PufferFileListJson = data
end
function logic_puffer_common.ReadPufferFileListJson()
  log_format("logic_puffer_common.ReadPufferFileListJson.")
  if next(logic_puffer_common.PufferFileListJson) then
    return logic_puffer_common.PufferFileListJson
  end
  local startTime = slua.getMiliseconds()
  logic_puffer_common.ReadPufferFileListContent(true)
  local pufferListJson = logic_puffer_common.PufferFileListJson
  local endTime = slua.getMiliseconds()
  log_format("logic_puffer_common.ReadPufferFileListJson. cost time = %s", endTime - startTime)
  if pufferListJson and pufferListJson.tasknum then
    local num = tonumber(pufferListJson.tasknum)
    if 0 < num then
      local basePath = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE
      for i = 1, num do
        local fileName = string.format("PufferFileList_%s.json", i)
        local fullPath = basePath .. fileName
        if Client.IsFileExistsWithOutPakCheck(fullPath) then
          local file = GCPufferDownloader.ReadFile(Puffer, fileName)
          local extraJson = json.decode(file) or {}
          for ODPackID, data in pairs(extraJson.ODPaks) do
            if not pufferListJson.ODPaks[ODPackID] then
              pufferListJson.ODPaks[ODPackID] = data
            else
              pufferListJson.ODPaks[ODPackID].size = pufferListJson.ODPaks[ODPackID].size + data.size
              for _, pakName in pairs(data.fileList) do
                table.insert(pufferListJson.ODPaks[ODPackID].fileList, pakName)
              end
            end
          end
        end
      end
    end
  end
  local version = logic_puffer_common.PufferFileListJson.version
  log_format("logic_puffer_common.ReadPufferFileListJson. version=%s", version)
  if version == nil then
    logic_puffer_common.PufferFileListJson = {}
  else
    local version_util = require("client.common.version_util")
    logic_puffer_common.PufferVersionMatchAppVersion = version_util.CompareVersionStandard(version, Client.GetApplicationVersion()) == 0
    if not logic_puffer_common.PufferVersionMatchAppVersion then
      log_error("PufferInterface.ReadPufferFileListJson jsonVersion < appVersion")
      logic_puffer_common.PufferFileListJson = {}
    end
  end
  if version and logic_puffer_common.PufferFileListJson.PipeLineID then
    Client.SetPufferBuildInfo(tostring(logic_puffer_common.PufferFileListJson.PipeLineID), tostring(logic_puffer_common.PufferFileListJson.BuildNo))
  end
  return logic_puffer_common.PufferFileListJson
end
function logic_puffer_common._HandlePufferContent()
  log_format("logic_puffer_common._HandlePufferContent.")
  local ODPaksNameToConHash = {}
  if nil == logic_puffer_common.PufferFileListJson then
    log_format("logic_puffer_common._HandlePufferContent return for nil == PufferInterface.PufferFileListJson")
    return ODPaksNameToConHash
  end
  local ODPaks = logic_puffer_common.PufferFileListJson.ODPaks
  if nil == ODPaks then
    log_format("logic_puffer_common._HandlePufferContent return for nil == ODPaks")
    return ODPaksNameToConHash
  end
  local start = slua.getMiliseconds()
  for packID, v1 in pairs(ODPaks) do
    packID = tonumber(packID)
    if packID then
      local fileList = v1.fileList
      local list = {}
      if fileList then
        if logic_puffer_common.PufferFileListUseNewFormat then
          for _, v in ipairs(fileList) do
            local pakName = v.name
            ODPaksNameToConHash[pakName] = v.hash
          end
        else
          for _, str in ipairs(fileList) do
            local TmpPakInfo = StringUtil.Split(str, "|")
            local TmpPakInfoNum = #TmpPakInfo
            local pakName = ""
            if 1 <= TmpPakInfoNum then
              pakName = TmpPakInfo[1]
            end
            local size = 0
            if 2 <= TmpPakInfoNum then
              size = tonumber(TmpPakInfo[2])
            end
            local ConOrgHash = "0505050505050505050505050505050505050505"
            if 3 <= TmpPakInfoNum then
              ConOrgHash = TmpPakInfo[3]
            end
            local data = {name = pakName, size = size}
            table.insert(list, data)
            ODPaksNameToConHash[pakName] = ConOrgHash
          end
        end
      end
      logic_puffer_common.PufferFileItemData[packID] = list
    end
  end
  local USFEnableUpdatePkgMapType = HDmpveRemote.HDmpveRemoteConfigGetInt("USFEnableUpdatePkgMapType", 0)
  log_format("logic_puffer_common._HandlePufferContent. USFEnableUpdatePkgMapType=%s", USFEnableUpdatePkgMapType)
  if USFEnableUpdatePkgMapType ~= 0 then
    local conhash_list = logic_puffer_common.PufferFileListJson.conhash_list
    log_tree("logic_puffer_common._HandlePufferContent conhash_list = ", conhash_list)
    if conhash_list ~= nil then
      for PkgName, ContentHash in pairs(conhash_list) do
        ODPaksNameToConHash[PkgName] = ContentHash
      end
    end
  end
  logic_puffer_common.HandleKickOutList(ODPaksNameToConHash)
  local costTime = slua.getMiliseconds() - start
  log_format("logic_puffer_common._HandlePufferContent. costTime=%s", costTime)
  return ODPaksNameToConHash
end
function logic_puffer_common.HandleKickOutList(hashList)
  log_format("logic_puffer_common.HandleKickOutList. begin")
  if not next(hashList) then
    return
  end
  local kickOutList = logic_puffer_common._GetKickOutList()
  log_tree("logic_puffer_common.HandleKickOutList. kickOutList = ", kickOutList)
  for pakName, v in pairs(kickOutList) do
    if hashList[pakName] then
      hashList[pakName] = "0505050505050505050505050505050505050505"
      log_format("logic_puffer_common.HandleKickOutList. pakName=%s", pakName)
    end
  end
  logic_puffer_common._KickOutList = nil
end
function logic_puffer_common._GetKickOutList()
  log_format("logic_puffer_common.HandleKickOutList. begin")
  if logic_puffer_common._KickOutList then
    log_format("logic_puffer_common._GetKickOutList. from cache")
    return logic_puffer_common._KickOutList
  end
  local kickOutList = {
    ["ODPaks/001e081923ac78518677b7cd19dd27bda4e110d8.pak"] = true
  }
  local USFSKickoutPkgName = HDmpveRemote.HDmpveRemoteConfigGetString("USFSKickoutPkgName", "")
  if USFSKickoutPkgName ~= "" then
    local tempList = StringUtil.Split(USFSKickoutPkgName, ",")
    for _, KickPkgInfo in pairs(tempList) do
      local PkgName = KickPkgInfo
      if string.find(KickPkgInfo, "/Game/") then
        PkgName = Client.GetODPakName(KickPkgInfo)
      else
        PkgName = "ODPaks/" .. KickPkgInfo .. ".pak"
      end
      log_format("logic_puffer_common.GetKickOutList. from USFSKickoutPkgName PkgName=%s", PkgName)
      kickOutList[PkgName] = true
      Client.USFSDeletePkg_V2(PkgName)
    end
  end
  for i = 1, 20 do
    local USFSKickoutPkgName = HDmpveRemote.HDmpveRemoteConfigGetString("USFSKickoutPkgName_" .. i, "")
    if USFSKickoutPkgName ~= "" then
      local tempList = StringUtil.Split(USFSKickoutPkgName, ",")
      for _, KickPkgInfo in pairs(tempList) do
        local PkgName = KickPkgInfo
        if string.find(KickPkgInfo, "/Game/") then
          PkgName = Client.GetODPakName(KickPkgInfo)
        else
          PkgName = "ODPaks/" .. KickPkgInfo .. ".pak"
        end
        log_format("logic_puffer_common.GetKickOutList. from USFSKickoutPkgName PkgName=%s", PkgName)
        kickOutList[PkgName] = true
        Client.USFSDeletePkg_V2(PkgName)
      end
    end
  end
  local CSCKickOutCommCRC_ini = HDmpveRemote.HDmpveRemoteConfigGetInt("CSCKickOutCommCRC_ini", 0)
  if CSCKickOutCommCRC_ini == 1 then
    local ScriptHelperClient = import("ScriptHelperClient")
    local data = ScriptHelperClient.LoadFileToArrayByFullPath(Client.ProjectDir() .. "Config/CommCRC.ini")
    if data then
      data = StringUtil.Split(data, "\n")
      for _, Info in pairs(data) do
        local PkgName = string.gsub(Info, "[\n\r]", "")
        if PkgName ~= "" then
          PkgName = "ODPaks/" .. PkgName .. ".pak"
          kickOutList[PkgName] = true
          log_format("logic_puffer_common.GetKickOutList. from CommCRC.ini PkgName=%s", PkgName)
        end
      end
    end
  end
  logic_puffer_common._KickOutList = kickOutList
  log_format("logic_puffer_common._GetKickOutList. end")
  return logic_puffer_common._KickOutList
end
function logic_puffer_common.InitPakList(id, fileList, callback)
  log_format("logic_puffer_common.InitPakList. id: %s", id)
  if not id then
    return
  end
  local PufferFileItemDataArr
  if logic_puffer_common.PufferFileListUseNewFormat then
    PufferFileItemDataArr = fileList
  else
    PufferFileItemDataArr = logic_puffer_common.PufferFileItemData[id]
  end
  if PufferFileItemDataArr then
    for k, v in pairs(PufferFileItemDataArr) do
      callback(v.name, v.size / 1024, nil)
    end
  else
    for _, v1 in ipairs(fileList) do
      local TmpPakInfo = StringUtil.Split(v1, "|")
      local TmpPakInfoNum = #TmpPakInfo
      local pakName = ""
      if 1 <= TmpPakInfoNum then
        pakName = TmpPakInfo[1]
      end
      local size = 0
      if 2 <= TmpPakInfoNum then
        size = tonumber(TmpPakInfo[2]) / 1024
      end
      local ConOrgHash = "0505050505050505050505050505050505050505"
      if 3 <= TmpPakInfoNum then
        ConOrgHash = TmpPakInfo[3]
      end
      callback(pakName, size, ConOrgHash)
    end
  end
end
function logic_puffer_common.USFCacheInitProcess()
  log_format("logic_puffer_common.USFCacheInitProcess")
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  local CacheSysContextStartSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("USFSCacheSysContextStart", 1)
  if CacheSysContextStartSwitch == 1 and Client.GetAndroidSOVersion() ~= 32 and Client.GetMemorySize() >= 4 then
    log_format("logic_puffer_common.USFCacheInitProcess CacheSysContextStartSwitch==1 open CSC initialize()")
    local USFSCollectPkgMaxNum = HDmpveRemote.HDmpveRemoteConfigGetInt("USFSCollectPkgMaxNum", 1200)
    log_format("logic_puffer_common.USFCacheInitProcess r.CSCCollectPkgMaxNum: %s", USFSCollectPkgMaxNum)
    gameInstance:ExecuteCMD("r.CSCCollectPkgMaxNum", USFSCollectPkgMaxNum)
    local USFSCacheSysWriteOnceStart = HDmpveRemote.HDmpveRemoteConfigGetInt("USFSCacheSysWriteOnceStart", 99)
    log_format("logic_puffer_common.USFCacheInitProcess r.CacheSysWriteOnceStart: %s", USFSCacheSysWriteOnceStart)
    gameInstance:ExecuteCMD("r.CacheSysWriteOnceStart", USFSCacheSysWriteOnceStart)
    local USFSCSCCollectUseRawData = HDmpveRemote.HDmpveRemoteConfigGetInt("USFSCSCCollectUseRawData", 1)
    log_format("logic_puffer_common.USFCacheInitProcess r.CSCCollectUseRawData: %s", USFSCSCCollectUseRawData)
    gameInstance:ExecuteCMD("r.CSCCollectUseRawData", USFSCSCCollectUseRawData)
    local USFCSCDataErrorAutoClear = HDmpveRemote.HDmpveRemoteConfigGetInt("USFCSCDataErrorAutoClear", 1)
    log_format("logic_puffer_common.USFCacheInitProcess r.CSCDataErrorAutoClear: %s", USFCSCDataErrorAutoClear)
    gameInstance:ExecuteCMD("r.CSCDataErrorAutoClear", USFCSCDataErrorAutoClear)
    local USFUpdateUseRawFileHandle = HDmpveRemote.HDmpveRemoteConfigGetInt("USFUpdateUseRawFileHandle", 0)
    log_format("logic_puffer_common.USFCacheInitProcess r.UpdateUseRawFileHandle: %s", USFUpdateUseRawFileHandle)
    gameInstance:ExecuteCMD("r.UpdateUseRawFileHandle", USFUpdateUseRawFileHandle)
    local USFCSCUsePkgDiffFunc = HDmpveRemote.HDmpveRemoteConfigGetInt("USFCSCUsePkgDiffFunc", 1)
    log_format("logic_puffer_common.USFCacheInitProcess r.CSCUsePkgDiffFunc: %s", USFCSCUsePkgDiffFunc)
    gameInstance:ExecuteCMD("r.CSCUsePkgDiffFunc", USFCSCUsePkgDiffFunc)
    local USFCSCPakFileBinDiff = HDmpveRemote.HDmpveRemoteConfigGetInt("USFCSCPakFileBinDiff", 0)
    log_format("logic_puffer_common.USFCacheInitProcess r.CSCPakFileBinDiff: %s", USFCSCPakFileBinDiff)
    gameInstance:ExecuteCMD("r.CSCPakFileBinDiff", USFCSCPakFileBinDiff)
    local USFCSCDiffUpgradeCfgParseSync = HDmpveRemote.HDmpveRemoteConfigGetInt("USFCSCDiffUpgradeCfgParseSync", 1)
    log_format("logic_puffer_common.USFCacheInitProcess r.CSCDiffUpgradeCfgParseSync: %s", USFCSCDiffUpgradeCfgParseSync)
    gameInstance:ExecuteCMD("r.CSCDiffUpgradeCfgParseSync", USFCSCDiffUpgradeCfgParseSync)
    local USFCacheSysContextOpenReadStage = HDmpveRemote.HDmpveRemoteConfigGetInt("USFCacheSysContextOpenReadStage", 2)
    log_format("VersionUpdateUI:OnUpdateFinished r.CacheSysContextOpenReadStage: %s", USFCacheSysContextOpenReadStage)
    gameInstance:ExecuteCMD("r.CacheSysContextOpenReadStage", USFCacheSysContextOpenReadStage)
    local USFGCacheSysWriteCapacity = HDmpveRemote.HDmpveRemoteConfigGetInt("USFGCacheSysWriteCapacity", 20)
    log_format("logic_puffer_common.USFCacheInitProcess r.GCacheSysWriteCapacity: %s", USFGCacheSysWriteCapacity)
    gameInstance:ExecuteCMD("r.GCacheSysWriteCapacity", USFGCacheSysWriteCapacity)
    local USFCSCHeaderPakTotalSizeCheck = HDmpveRemote.HDmpveRemoteConfigGetInt("USFCSCHeaderPakTotalSizeCheck", 1)
    log_format("logic_puffer_common.USFCacheInitProcess r.CSCHeaderPakTotalSizeCheck: %s", USFCSCHeaderPakTotalSizeCheck)
    gameInstance:ExecuteCMD("r.CSCHeaderPakTotalSizeCheck", USFCSCHeaderPakTotalSizeCheck)
    local USFCSCUpdatePkgDirectory = HDmpveRemote.HDmpveRemoteConfigGetInt("USFCSCUpdatePkgDirectory", 1)
    log_format("logic_puffer_common.USFCacheInitProcess r.CSCUpdatePkgDirectory: %s", USFCSCUpdatePkgDirectory)
    gameInstance:ExecuteCMD("r.CSCUpdatePkgDirectory", USFCSCUpdatePkgDirectory)
    local USFCSCDiffUpgradeFinishAtPkgUpdate = HDmpveRemote.HDmpveRemoteConfigGetInt("USFCSCDiffUpgradeFinishAtPkgUpdate", 0)
    log_format("logic_puffer_common.USFCacheInitProcess r.CSCDiffUpgradeFinishAtPkgUpdate: %s", USFCSCDiffUpgradeFinishAtPkgUpdate)
    gameInstance:ExecuteCMD("r.CSCDiffUpgradeFinishAtPkgUpdate", USFCSCDiffUpgradeFinishAtPkgUpdate)
    local USFCSCDiffUpgradeSkipExist = HDmpveRemote.HDmpveRemoteConfigGetInt("USFCSCDiffUpgradeSkipExist", 1)
    log_format("logic_puffer_common.USFCacheInitProcess r.CSCDiffUpgradeSkipExist: %s", USFCSCDiffUpgradeSkipExist)
    gameInstance:ExecuteCMD("r.CSCDiffUpgradeSkipExist", USFCSCDiffUpgradeSkipExist)
    local USFCSCClearUpdateQueueWait = HDmpveRemote.HDmpveRemoteConfigGetInt("USFCSCClearUpdateQueueWait", 0)
    log_format("logic_puffer_common.USFCacheInitProcess r.CSCClearUpdateQueueWait: %s", USFCSCClearUpdateQueueWait)
    gameInstance:ExecuteCMD("r.CSCClearUpdateQueueWait", USFCSCClearUpdateQueueWait)
    local USFCSCInitializeAsync = HDmpveRemote.HDmpveRemoteConfigGetInt("USFCSCInitializeAsync", 0)
    log_format("logic_puffer_common.USFCacheInitProcess r.CSCInitializeAsync: %s", USFCSCInitializeAsync)
    gameInstance:ExecuteCMD("r.CSCInitializeAsync", USFCSCInitializeAsync)
    local PlatformFileHandleUseCache = HDmpveRemote.HDmpveRemoteConfigGetInt("PlatformFileHandleUseCache", 1)
    log_format("logic_puffer_common.USFCacheInitProcess r.PlatformFileHandleUseCache: %s", PlatformFileHandleUseCache)
    gameInstance:ExecuteCMD("r.PlatformFileHandleUseCache", PlatformFileHandleUseCache)
    local CSCClearLocalODPakFiles = HDmpveRemote.HDmpveRemoteConfigGetInt("CSCClearLocalODPakFiles", 1)
    log_format("logic_puffer_common.USFCacheInitProcess r.CSCClearLocalODPakFiles: %s", CSCClearLocalODPakFiles)
    gameInstance:ExecuteCMD("r.CSCClearLocalODPakFiles", CSCClearLocalODPakFiles)
    local CSCUseFindFileInOnDemandPakName = HDmpveRemote.HDmpveRemoteConfigGetInt("CSCUseFindFileInOnDemandPakName", 1)
    log_format("logic_puffer_common.USFCacheInitProcess r.UseFindFileInOnDemandPakName: %s", CSCUseFindFileInOnDemandPakName)
    gameInstance:ExecuteCMD("r.UseFindFileInOnDemandPakName", CSCUseFindFileInOnDemandPakName)
    local USFSUncompressPkgNameList = HDmpveRemote.HDmpveRemoteConfigGetString("USFSUncompressPkgNameList", "")
    log_format("logic_puffer_common.USFCacheInitProcess USFSUncompressPkgNameList: %s", USFSUncompressPkgNameList)
    local StringUtil = require("common.string_util")
    local tempList = StringUtil.Split(USFSUncompressPkgNameList, ",")
    if 0 < #tempList then
      Client.UpdatePkgCompressionInfo(tempList, "0")
    end
    local USFCSCOpenDebugInfoLevel = HDmpveRemote.HDmpveRemoteConfigGetInt("USFCSCOpenDebugInfoLevel", 5)
    log_format("logic_puffer_common.USFCacheInitProcess r.CSCOpenDebugInfoLevel: %s", USFCSCOpenDebugInfoLevel)
    gameInstance:ExecuteCMD("r.CSCOpenDebugInfoLevel", USFCSCOpenDebugInfoLevel)
    Client.USFSCacheSysContextStart()
  end
  local TDMCanEnableRagdoll = HDmpveRemote.HDmpveRemoteConfigGetInt("TDMCanEnableRagdoll", -1)
  if 0 <= TDMCanEnableRagdoll then
    log_format("logic_puffer_common.USFCacheInitProcess chara.CanEnableRagdoll: %s", TDMCanEnableRagdoll)
    gameInstance:ExecuteCMD("chara.CanEnableRagdoll", TDMCanEnableRagdoll)
    log_format("logic_puffer_common.USFCacheInitProcess p.UsedSimulation: %s", TDMCanEnableRagdoll)
    gameInstance:ExecuteCMD("p.UsedSimulation", TDMCanEnableRagdoll)
  end
end
function logic_puffer_common.USFCacheUpgradeDiffProcess()
  log_format("logic_puffer_common.USFCacheUpgradeDiffProcess.")
  local USFUpgradeAtUpdateFinished = HDmpveRemote.HDmpveRemoteConfigGetBool("UFSInitOnUpdateFinished", true)
  if not USFUpgradeAtUpdateFinished then
    log_format("logic_puffer_common.USFCacheUpgradeDiffProcess. USFUpgradeAtUpdateFinished return")
    return
  end
  if logic_puffer_common.PufferContentInited and logic_puffer_common.PufferVersionMatchAppVersion then
    log_format("logic_puffer_common.USFCacheUpgradeDiffProcess. inited return")
    return
  end
  logic_puffer_common.ReadPufferFileListJson()
  local USFCrcInfoList = logic_puffer_common._HandlePufferContent()
  local USFSCacheSysContexInit = HDmpveRemote.HDmpveRemoteConfigGetInt("USFSCacheSysContexInit", 1)
  log_format("logic_puffer_common.USFCacheUpgradeDiffProcess. USFSCacheSysContexInit=%s", USFSCacheSysContexInit)
  if USFSCacheSysContexInit == 1 and next(USFCrcInfoList) then
    Client.USFSCacheSysContexInit(USFCrcInfoList)
  end
  log_format("logic_puffer_common.USFCacheUpgradeDiffProcess. diff")
  local ArrayData = {}
  ArrayData[1] = "ShadowTrackerExtra/Content/Paks/res_cachesyspkgdiffmini_obb.pak"
  Client.USFSCacheSysContextUpdatePkgDiff(ArrayData)
  logic_puffer_common.PufferContentInited = true
  log_format("logic_puffer_common.USFCacheUpgradeDiffProcess. end")
end
function logic_puffer_common.USFCacheInitProcessPreDownload()
  log_format("logic_puffer_common.USFCacheInitProcessPreDownload.")
  if logic_puffer_common.USFInited then
    log_format("logic_puffer_common.USFCacheInitProcessPreDownload. Inited return")
    return
  end
  logic_puffer_common.USFInited = true
  local PufferODPakDelList = require("client.slua.logic.download.puffer.odpak.puffer_odpak_del_once")
  PufferODPakDelList.DeleteSYSOldFiles()
  logic_puffer_common.USFCacheInitProcess()
  logic_puffer_common.USFCacheUpgradeDiffProcess()
end
return logic_puffer_common