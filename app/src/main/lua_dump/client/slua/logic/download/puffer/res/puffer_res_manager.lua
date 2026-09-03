local PufferResManager = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
function PufferResManager:DefineAndResetData()
  self.ResPaks = {}
  self.VulkanShaderData = nil
  self.bHaveInitLobbyRes = false
  self.LobbyResKeyList = {}
  self.LobbyResMap = {}
  self.bFromLogin = false
end
function PufferResManager:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_PRE_FINISH, self.OnLoadingPreFinish, self)
end
function PufferResManager:OnLoadingPreFinish()
  printf("PufferResManager:OnLoadingPreFinish.")
  if not IsWoWEditor then
    return
  end
  if self.bFromLogin then
    printf("PufferResManager:OnLoadingPreFinish. self.bHaveInitLobbyRes=%s", tostring(self.bHaveInitLobbyRes))
    if not self.bHaveInitLobbyRes then
      self:InitLobbyResPaks()
    end
  end
end
function PufferResManager:OnPostSwitchGameStatus(pre, next)
  if not IsWoWEditor then
    return
  end
  log(bWriteLog and string.format("PufferResManager:OnPostSwitchGameStatus. pre=%s, next=%s", pre, next))
  self.bFromLogin = false
  if next == GameStatus.Login then
    self.bHaveInitLobbyRes = false
  elseif next == GameStatus.Lobby and pre == GameStatus.Login then
    self.bFromLogin = true
  end
end
function PufferResManager:InitResPaks()
  log(bWriteLog and string.format("PufferResManager:InitResPaks"))
  local pufferList = PufferDownloader.GetPufferFileListJson()
  if pufferList.version_mapping == nil then
    log(bWriteLog and string.format("PufferResManager:InitResPaks GetPufferFileListJson = nil"))
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local fitShaderName = ""
  local isFitVersion = PublishRegionMacros.IsFITVersion()
  if isFitVersion then
    local APILevel = tostring(Client.GetCurrentRHILevel(GameFrontendHUD))
    if string.find(APILevel, "ES2") then
      fitShaderName = PufferConst.FIT_ES2SHADER
    else
      fitShaderName = PufferConst.FIT_ES3SHADER
    end
    log(bWriteLog and "PufferResManager:InitResPaks. fitShaderName = " .. tostring(fitShaderName))
  end
  local isNameMatch = function(pakDefaultName)
    if string.find(pakDefaultName, PufferConst.RES_FILE_PREFIX) then
      return true
    elseif isFitVersion and string.find(pakDefaultName, fitShaderName) then
      return true
    end
    return false
  end
  local StringUtil = require("common.string_util")
  for pakDefaultName, _ in pairs(pufferList.version_mapping) do
    if isNameMatch(pakDefaultName) then
      local ret = StringUtil.Split(pakDefaultName, "_")
      local resKey = string.format("%s_%s", ret[1], ret[2])
      local pakName = string.format("%s_%s.pak", resKey, Client.GetApplicationVersion())
      pakName = PufferDownloader.GetRealFilename(pakName)
      local totalSize = PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, pakName)
      local skip = false
      if resKey == "res_maptexmd" and totalSize < 0.2 * PufferConst.MB then
        skip = true
      elseif resKey == "res_basetexld" or resKey == "res_basetexmd" or resKey == "res_es2shader" or resKey == "res_es3shader" then
        skip = true
      elseif resKey == "res_audiohigh" and 2 > Client.GetDeviceMaxSupportSoundEffect() then
        skip = true
      elseif resKey == PufferConst.RES_VULKAN_SHADER and (not LobbySystem.CheckVulkanWhiteListEnable() or not Client.IsSupportVulkan()) then
        self.VulkanShaderData = {totalSize = totalSize, pakName = pakName}
        skip = true
      elseif resKey == "res_umgtexmd" and self:HaveBasetexmd() then
        log(bWriteLog and string.format("PufferResManager:InitResPaks skip:%s", resKey))
        skip = true
      elseif resKey == "res_baltichd" then
        local ERenderQuality = import("ERenderQuality")
        local UIUtil = require("client.common.ui_util")
        local GameInstance = UIUtil.GetGameInstance()
        if GameInstance then
          local level = GameInstance:GetDeviceMaxSupportLevel()
          log(bWriteLog and "PufferResManager:InitResPaks GetDeviceMaxSupportLevel = " .. tostring(level))
          if level < ERenderQuality.ULTRAHIGHDEFINITION or level == ERenderQuality.VERYSMOOTH then
            skip = true
          end
        end
      elseif isFitVersion and resKey == fitShaderName then
        resKey = PufferConst.FIT_SHADER_KEY
      end
      if not skip then
        self.ResPaks[resKey] = self:InitResData(totalSize, pakName)
      end
    end
  end
  log_tree("PufferResManager:InitResPaks self.ResPaks = ", self.ResPaks)
  self:InitPufferPatch()
end
function PufferResManager:InitResData(totalSize, pakName)
  local data = {}
  data.  data.percent = 0
  data.  if Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR .. pakName) then
    data.state = PufferConst.ENUM_DownloadState.Done
    data.percent = 1000
    data.curSize = data.totalSize
  else
    data.state = PufferConst.ENUM_DownloadState.Not
    data.percent = 0
    data.curSize = 0
  end
  return data
end
function PufferResManager:ReInitVulkanShader()
  if self.ResPaks[PufferConst.RES_VULKAN_SHADER] == nil and Client.IsSupportVulkan() and LobbySystem.CheckVulkanWhiteListEnable() and self.VulkanShaderData then
    log(bWriteLog and "PufferResManager:ReInitVulkanShader.")
    self.ResPaks[PufferConst.RES_VULKAN_SHADER] = self:InitResData(self.VulkanShaderData.totalSize, self.VulkanShaderData.pakName)
  end
end
function PufferResManager:InitPufferPatch()
  log(bWriteLog and string.format("PufferResManager:InitPufferPatch"))
  local pufferList = PufferDownloader.GetPufferFileListJson()
  if pufferList.version_mapping == nil then
    log(bWriteLog and string.format("PufferResManager:InitPufferPatch GetPufferFileListJson = nil"))
    return
  end
  if pufferList.res_ver and pufferList.version then
    local StringUtil = require("common.string_util")
    local res_ver_arr = StringUtil.Split(pufferList.res_ver, ".")
    local res_ver = tonumber(res_ver_arr and res_ver_arr[4]) or 0
    res_ver_arr[4] = nil
    local stringList = StringUtil.Split(pufferList.version, ".")
    local base_ver = tonumber(stringList[4]) or 0
    local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
    if Client.GetAOSSHOP() == AOSSHOPMacros.Amazon or GlobalData.IsJapanOrKorea() and Client.GetAOSSHOP() == AOSSHOPMacros.Samsung then
      base_ver = base_ver + 1000
      res_ver = res_ver + 1000
    end
    local patchData = {}
    patchData.state = PufferConst.ENUM_DownloadState.Done
    patchData.totalSize = 0
    patchData.curSize = 0
    patchData.downloadingSize = 0
    self.ResPaks[PufferConst.PUFFERPATCH] = patchData
    local key = "LoginDownloadTimeSwitch"
    local startTime = slua.getMiliseconds()
    if FuncUtil.GetHDmpveRemoteConfig(key, false) then
      local versionMap = {}
      local localFiles = {}
      local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
      for _, filename in pairs(ret) do
        localFiles[filename] = true
        local prefix, versionNo = PufferDownloader.ParsePakName(filename)
        if prefix ~= nil and versionNo ~= nil then
          if versionMap[prefix] ~= nil then
            if 0 < PufferDownloader.CompareVersion(versionNo, versionMap[prefix]) then
              versionMap[prefix] = versionNo
            end
          else
            versionMap[prefix] = versionNo
          end
        end
      end
      for thirdVersion = 0, 2 do
        res_ver_arr[3] = tostring(thirdVersion)
        local prefix = table.concat(res_ver_arr, ".")
        for i = base_ver, res_ver do
          local patchName = PufferConst.PUFFERPATCH .. "_" .. prefix .. "." .. tostring(i) .. ".pak"
          if not localFiles[patchName] then
            local fileName = self:GetFileName(patchName, pufferList, versionMap)
            log(bWriteLog and "PufferResManager:InitPufferPatch. fileName = " .. tostring(fileName))
            local fileSize = GCPufferDownloader.GetFileSizeCompressed(Puffer, fileName)
            if 0 < fileSize then
              base_ver = i
              local data = {}
              data.state = PufferConst.ENUM_DownloadState.Not
              data.curSize = 0
              data.percent = 0
              data.totalSize = fileSize
              data.pakName = patchName
              self.ResPaks[patchName] = data
              patchData.state = PufferConst.ENUM_DownloadState.Not
              patchData.totalSize = fileSize + patchData.totalSize
              local fileNamePak = string.format("%s(%s)|", tostring(patchName), tostring(fileSize))
              Client.AddAttachFileString("pakname", false, fileNamePak)
              log_format("PufferResManager:InitPufferPatch patchName = %s, totalSize = %s", tostring(patchName), tostring(fileSize))
            end
          else
            base_ver = i
          end
        end
      end
    else
      for thirdVersion = 0, 2 do
        res_ver_arr[3] = tostring(thirdVersion)
        local prefix = table.concat(res_ver_arr, ".")
        for i = base_ver, res_ver do
          local patchName = PufferConst.PUFFERPATCH .. "_" .. prefix .. "." .. tostring(i) .. ".pak"
          local path = Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR .. patchName
          if not Client.IsFileExistsWithOutPakCheck(path) then
            local fileSize = PufferDownloader.GetFileSizeCompressed(Puffer, patchName)
            if 0 < fileSize then
              base_ver = i
              self.ResPaks[patchName] = {}
              self.ResPaks[patchName].state = PufferConst.ENUM_DownloadState.Not
              self.ResPaks[patchName].curSize = 0
              self.ResPaks[patchName].percent = 0
              self.ResPaks[patchName].totalSize = fileSize
              self.ResPaks[patchName].pakName = patchName
              patchData.state = PufferConst.ENUM_DownloadState.Not
              patchData.totalSize = fileSize + patchData.totalSize
              local fileNamePak = tostring(patchName) .. string.format("(%s)|", tostring(fileSize))
              Client.AddAttachFileString("pakname", false, fileNamePak)
              log(bWriteLog and "PufferResManager:InitPufferPatch patchName = " .. patchName .. " totalSize = " .. tostring(fileSize))
            end
          end
        end
      end
    end
    local endTime = slua.getMiliseconds()
    log(bWriteLog and "PufferResManager:InitPufferPatch. costTime = " .. tostring(endTime - startTime))
  end
end
function PufferResManager:InitLobbyResPaks()
  if not IsWoWEditor then
    return
  end
  log(bWriteLog and "PufferResManager:InitLobbyResPaks")
  self.LobbyResKeyList = {}
  local FilterPakMap = {
    res_es2shader = true,
    map_zznq8th = true,
    map_maincity = true
  }
  local StringUtil = require("common.string_util")
  local PakFileList = GCPufferDownloader.ReturnSplitLobbyPakFileList()
  for _, PakDefaultName in ipairs(PakFileList) do
    log(bWriteLog and "PufferResManager:InitLobbyResPaks PakDefaultName = " .. PakDefaultName)
    local Ret = StringUtil.Split(PakDefaultName, "_")
    local ResKey = string.format("%s_%s", Ret[1], Ret[2])
    if not FilterPakMap[ResKey] then
      local PakName = string.format("%s_%s.pak", ResKey, Client.GetApplicationVersion())
      PakName = PufferDownloader.GetRealFilename(PakName)
      local TotalSize = PufferInterface.GetFileSizeCompressed(PakName)
      log(bWriteLog and "PufferResManager:InitLobbyResPaks TotalSize = " .. TotalSize)
      self.ResPaks[ResKey] = self:InitResData(TotalSize, PakName)
      table.insert(self.LobbyResKeyList, ResKey)
      self.LobbyResMap[ResKey] = self.ResPaks[ResKey]
    end
  end
  self.bHaveInitLobbyRes = true
end
function PufferResManager:GetFileName(fileName, fileListJson, versionMap)
  local diffList = fileListJson.diff_list or {}
  local downloadFilename = fileName
  local targetFilePrefix, targetFileVersionNo = PufferDownloader.ParsePakName(fileName)
  if targetFilePrefix == nil or targetFileVersionNo == nil then
    return nil
  end
  local oldVersion = versionMap[targetFilePrefix]
  if oldVersion then
    if diffList[oldVersion] then
      downloadFilename = diffList[oldVersion][fileName]
    end
    if downloadFilename == nil then
      downloadFilename = fileName
    end
  end
  return downloadFilename
end
function PufferResManager:CheckHighAudio()
  local level = Client.GetSoundEffectQuality()
  log(bWriteLog and string.format("PufferResManager:GetSoundEffectQuality :%s", level))
  if level == 2 and self:GetState("res_audiohigh") ~= PufferConst.ENUM_DownloadState.Done then
    local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
    for _, filename in pairs(ret) do
      if string.find(filename, "res_audiohigh_") then
        return
      end
    end
    Client.SetSoundEffectQuality(1)
    local title = LocUtil.GetLocalizeResStr(110115)
    local content = LocUtil.LocalizeResFormat("7757")
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, content)
  end
end
function PufferResManager:HaveBasetexmd()
  local fileName = "res_basetexmd_" .. Client.GetApplicationVersion() .. ".pak"
  local realFileName = PufferDownloader.GetRealFilename(fileName)
  if Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR .. realFileName) then
    return true
  else
    return false
  end
end
function PufferResManager:HaveBasetexld()
  local fileName = "res_basetexld_" .. Client.GetApplicationVersion() .. ".pak"
  local realFileName = PufferDownloader.GetRealFilename(fileName)
  if Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR .. realFileName) then
    return true
  else
    return false
  end
end
function PufferResManager:IsRes(key)
  if self.ResPaks[key] then
    return true
  end
  return false
end
function PufferResManager:GetStateByKeyList(downloadType, keyList, bSkipDepends, bSkipVidepDepends)
  local result = PufferConst.ENUM_DownloadState.Done
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  for _, v in pairs(keyList) do
    local state = self:GetState(v)
    result = PufferManager.GetMixDownloadState(result, state)
  end
  return result
end
function PufferResManager:GetState(resKey)
  if not PufferDownloader.PufferJsonDownloadReturn then
    local pakName = resKey .. "_" .. Client.GetApplicationVersion() .. ".pak"
    pakName = PufferDownloader.GetRealFilename(pakName)
    if Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. pakName) then
      return PufferConst.ENUM_DownloadState.Done
    else
      return PufferConst.ENUM_DownloadState.Not
    end
  end
  local res = self.ResPaks[resKey]
  if not res then
    return PufferConst.ENUM_DownloadState.Done
  end
  return res.state
end
function PufferResManager:GetSizeByKeyList(downloadType, keyList, bSkipDepends)
  local curSize = 0
  local totalSize = 0
  for _, v in pairs(keyList) do
    local cSize, tSize = self:GetSize(v)
    curSize = curSize + cSize
    totalSize = totalSize + tSize
  end
  return curSize, totalSize
end
function PufferResManager:GetSize(resKey)
  local res = self.ResPaks[resKey]
  if not res then
    return 0, 0
  end
  if resKey == PufferConst.PUFFERPATCH then
    return res.curSize + res.downloadingSize, res.totalSize
  else
    return res.curSize, res.totalSize
  end
end
function PufferResManager:GetAllResCurSize()
  local curSize = 0
  for i, v in pairs(self.ResPaks) do
    if v then
      curSize = curSize + v.curSize
    end
  end
  curSize = curSize / PufferConst.MB
  log(bWriteLog and string.format("PufferResManager:GetAllResCurSize :%s", curSize))
  return curSize
end
function PufferResManager:GetPercentByKeyList(resKeyList)
  local cSize, tSize = self:GetSizeByKeyList(PufferConst.ENUM_DownloadType.RES, resKeyList)
  if tSize == 0 then
    return 1000
  end
  return cSize / tSize * 1000
end
function PufferResManager:GetHighestPufferPatchName()
  local HighestPak = ""
  local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
  for _, filename in pairs(ret) do
    if string.find(filename, PufferConst.PUFFERPATCH) and (HighestPak == "" or filename > HighestPak) then
      HighestPak = filename
    end
  end
  log(bWriteLog and string.format("PufferResManager:GetHighestPufferPatchName :%s", HighestPak))
  return HighestPak
end
function PufferResManager:GetLowestNotDownloadPufferPatch()
  local minimumPakName = ""
  local patternStr = string.format("%s_", PufferConst.PUFFERPATCH)
  for pakName, v in pairs(self.ResPaks) do
    if string.find(pakName, patternStr) and v.state ~= PufferConst.ENUM_DownloadState.Done and (minimumPakName == "" or pakName < minimumPakName) then
      minimumPakName = pakName
    end
  end
  return minimumPakName
end
function PufferResManager:GetPakName(resKey)
  if self.ResPaks[resKey] then
    return self.ResPaks[resKey].pakName
  end
  return nil
end
function PufferResManager:AutoDownloadPufferPatch()
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  PufferManager.Download(PufferConst.ENUM_DownloadType.RES, {
    PufferConst.PUFFERPATCH
  })
  self:ShowDownloadPufferPatchTips()
end
function PufferResManager:ShowDownloadPufferPatchTips()
  if Client.IsReleaseVersion(NetInterface) then
    return
  end
  if PufferDownloader.IsAllPufferFileListJsonTaskReturn() then
    return
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.RES, {
    PufferConst.PUFFERPATCH
  })
  if state == PufferConst.ENUM_DownloadState.Done then
    return
  end
  local title = LocUtil.GetLocalizeResStr(101001)
  local msg = "\229\134\133\231\189\145\230\143\144\231\164\186\239\188\154\229\164\167\229\142\133patch\232\191\152\230\156\170\228\184\139\232\189\189\231\187\147\230\157\159\239\188\140\229\143\175\232\131\189\229\175\188\232\135\180\229\156\176\229\155\190\227\128\129\229\149\134\228\184\154\229\140\150\232\181\132\230\186\144\227\128\129\229\164\167\229\142\133UI\231\179\187\231\187\159\229\188\130\229\184\184"
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, title, msg)
end
function PufferResManager:ShowRestartTips()
  if Client.IsReleaseVersion(NetInterface) then
    return
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.RES, {
    PufferConst.PUFFERPATCH
  })
  if state ~= PufferConst.ENUM_DownloadState.Done then
    return
  end
  local title = LocUtil.GetLocalizeResStr(101001)
  local msg = "\229\134\133\231\189\145\230\143\144\231\164\186\239\188\154\229\164\167\229\142\133patch\229\183\178\228\184\139\232\189\189\229\174\140\230\175\149\239\188\140\233\135\141\229\144\175\231\148\159\230\149\136\239\188\136\228\184\141\233\135\141\229\144\175\231\154\132\229\189\177\229\147\141\239\188\154\229\143\175\232\131\189\229\175\188\232\135\180\229\156\176\229\155\190\227\128\129\229\149\134\228\184\154\229\140\150\232\181\132\230\186\144\227\128\129\229\164\167\229\142\133UI\231\179\187\231\187\159\229\188\130\229\184\184\239\188\137"
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, msg, function()
    Client.RestartGame()
  end, nil, "\233\135\141\229\144\175\230\184\184\230\136\143")
end
function PufferResManager:IsFitShaderExist()
  return self:GetState(PufferConst.FIT_SHADER_KEY) == PufferConst.ENUM_DownloadState.Done
end
function PufferResManager:IsLobbyResCompleted(bToDownloadCenter)
  if IsEditor then
    return true
  end
  if not IsWoWEditor then
    return true
  end
  local bIsCompleted = self:GetStateByKeyList(PufferConst.ENUM_DownloadType.RES, self.LobbyResKeyList) == PufferConst.ENUM_DownloadState.Done
  if not bIsCompleted and bToDownloadCenter then
    local URL = string.format("game://?module=%d&bShowWarningPopUp=1", BP_ENUM_MODULE_DOWNLOADER)
    GlobalData.JumpGameUrl(URL)
  end
  return bIsCompleted
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CPufferResManager = class(CModuleBase, nil, PufferResManager)
return CPufferResManager