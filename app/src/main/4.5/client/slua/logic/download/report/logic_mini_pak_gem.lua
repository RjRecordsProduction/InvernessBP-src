local Logic_Mini_Pak_Gem = {
  bIsGary = false,
  tNeedGem = {},
  nSizeBeforeLobby = 0,
  nCurSize = 0,
  isNotLobby = true,
  cSaveSize = nil,
  sProjectSavedDir = nil
}
local SavedFileUtil = import("SavedFileUtil")
local PufferConst = require("client.slua.logic.download.puffer_const")
local Enum_Log = {
  Instal = gem_report_utils.Mini_Pak_Instal,
  Base = gem_report_utils.Mini_Pak_Base_End,
  ShaderEnd = gem_report_utils.Mini_Pak_Shader_End,
  LobbyEnd = gem_report_utils.Mini_Pak_Lobby_End,
  LobbyDel = gem_report_utils.Mini_Pak_Lobby_Del,
  LoginDel = gem_report_utils.Mini_Pak_Login_Del,
  ReturnLogin = gem_report_utils.Mini_Pak_Return_Login,
  LobbyRadom = gem_report_utils.Mini_Pak_Lobby_Radom
}
function Logic_Mini_Pak_Gem.ReportGemLog(sKey)
  printf("Logic_Mini_Pak_Gem.ReportGemLog. sKey=%s", tostring(sKey))
  Logic_Mini_Pak_Gem.SetCurDownloadSize(sKey)
end
function Logic_Mini_Pak_Gem.StartReport()
  local nUid = DataMgr.roleData.uid
  if Logic_Mini_Pak_Gem.isNotLobby then
    return
  end
  if not Logic_Mini_Pak_Gem.bIsGary then
    log(bWriteLog and "GemBGaryClose")
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tLocalCacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMiniGem) or {}
  if tLocalCacheData and next(tLocalCacheData) and Logic_Mini_Pak_Gem.bIsGary then
    for i, v in ipairs(tLocalCacheData) do
      gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_CommonEvent, v.key, v.space, nUid)
      log(bWriteLog and "StartReport v.key " .. tostring(v.key) .. "Size" .. tostring(v.space))
    end
    tLocalCacheData = {}
    PlayerPrefsSystem.SaveTableToFile_N(tLocalCacheData, PlayerPrefsSystem.ePlayerPrefsType.eMiniGem)
  end
  if Logic_Mini_Pak_Gem.tNeedGem and next(Logic_Mini_Pak_Gem.tNeedGem) and Logic_Mini_Pak_Gem.bIsGary then
    for k, v in pairs(Logic_Mini_Pak_Gem.tNeedGem) do
      gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_CommonEvent, v.key, v.space, nUid)
      log(bWriteLog and "StartReport v.key " .. tostring(v.key) .. "Size" .. tostring(v.space))
    end
    Logic_Mini_Pak_Gem.tNeedGem = {}
  end
end
function Logic_Mini_Pak_Gem.OnModePostSwitch(_, __, gamestatus)
  if gamestatus.current == GameStatus.Lobby then
    Logic_Mini_Pak_Gem.isNotLobby = false
    if not Logic_Mini_Pak_Gem.cSaveSize then
      local nDownloadSize = Logic_Mini_Pak_Gem.GetDownloadCacheData()
      Logic_Mini_Pak_Gem.cSaveSize = Logic_Mini_Pak_Gem.nSizeBeforeLobby - nDownloadSize
      log(bWriteLog and "cSaveSize Has Init Size:" .. tostring(Logic_Mini_Pak_Gem.cSaveSize))
    end
    Logic_Mini_Pak_Gem.StartReport()
  else
    Logic_Mini_Pak_Gem.isNotLobby = true
  end
end
function Logic_Mini_Pak_Gem.SetCurDownloadSize(sKey)
  if Logic_Mini_Pak_Gem.isNotLobby then
    Logic_Mini_Pak_Gem.GetLocalSavaData(function(size)
      printf("Logic_Mini_Pak_Gem.SetCurDownloadSize. size=%s", tostring(size))
      Logic_Mini_Pak_Gem.nCurSize = size
      Logic_Mini_Pak_Gem.nSizeBeforeLobby = size
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local tLocalCacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMiniGem) or {}
      local data = {}
      data.key = Enum_Log[sKey]
      data.space = Logic_Mini_Pak_Gem.nCurSize
      if type(tLocalCacheData) ~= "table" then
        tLocalCacheData = {}
      end
      table.insert(tLocalCacheData, data)
      PlayerPrefsSystem.SaveTableToFile_N(tLocalCacheData, PlayerPrefsSystem.ePlayerPrefsType.eMiniGem)
      Logic_Mini_Pak_Gem.StartReport()
    end)
  else
    local nDownloadSize = Logic_Mini_Pak_Gem.GetDownloadCacheData()
    Logic_Mini_Pak_Gem.nCurSize = Logic_Mini_Pak_Gem.cSaveSize + nDownloadSize
    log(bWriteLog and "After Lobby Need Read DownloaderCacheData" .. tostring(Logic_Mini_Pak_Gem.nCurSize))
    Logic_Mini_Pak_Gem.tNeedGem[sKey] = {}
    Logic_Mini_Pak_Gem.tNeedGem[sKey].key = Enum_Log[sKey]
    Logic_Mini_Pak_Gem.tNeedGem[sKey].space = Logic_Mini_Pak_Gem.nCurSize
    Logic_Mini_Pak_Gem.StartReport()
  end
end
function Logic_Mini_Pak_Gem.GetDownloadCacheData()
  local Logic_Lobby_Download = require("client.slua.logic.download.logic_lobby_downloader")
  local tList = Logic_Lobby_Download.GetLobbyDownloadInfo()
  local size = 0
  for i, v in ipairs(tList) do
    size = size + v.curSize
  end
  return size
end
function Logic_Mini_Pak_Gem.OnGetDirSizeRet(_, dirSize)
  if dirSize == nil then
    return
  end
  log(bWriteLog and "Logic_Mini_Pak_Gem.OnGetDirSizeRet. dirSize: " .. tostring(dirSize))
  if Logic_Mini_Pak_Gem.OnGetSizeCallback then
    local callback = Logic_Mini_Pak_Gem.OnGetSizeCallback
    Logic_Mini_Pak_Gem.OnGetSizeCallback = nil
    if callback then
      callback(dirSize)
    end
  end
end
function Logic_Mini_Pak_Gem.GetLocalSavaData(callback)
  log(bWriteLog and "Logic_Mini_Pak_Gem.GetLocalSavaData.")
  Logic_Mini_Pak_Gem.sProjectSavedDir = Logic_Mini_Pak_Gem.sProjectSavedDir or Client.ProjectSavedDir()
  local dir = Logic_Mini_Pak_Gem.sProjectSavedDir .. PufferDownloader.DOWNLOAD_DIR_RELATIVE
  Logic_Mini_Pak_Gem.OnGetSizeCallback = callback
  SavedFileUtil.GetDirSizeAsync(dir, true, Logic_Mini_Pak_Gem.OnGetDirSizeRet)
end
return Logic_Mini_Pak_Gem