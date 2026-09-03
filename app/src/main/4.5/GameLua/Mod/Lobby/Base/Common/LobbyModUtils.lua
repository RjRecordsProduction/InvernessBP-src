local LobbyModUtils = {}
local local local local local StringUtil = require("common.string_util")
local PufferConst = require("client.slua.logic.download.puffer_const")
local common_download_handler = require("client.slua.common.common_download_handler")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local table_pack = table.pack
local table_unpack = table.unpack
local table_insert = table.insert
local local LobbyModUtils.Enum_Mod_Name = {
  EName_NewCharacter = "NewCharacter",
  EName_Collect = "Collect",
  EName_CollectBadge = "CollectBadge",
  EName_Home = "Home",
  EName_CardCollection = "CardCollection",
  BlackFriday = "BlackFriday",
  EName_NewbieActivity = "NewbieActivity",
  EName_ModeSelection = "ModeSelection",
  AssemblyComeBack = "AssemblyComeBack",
  EName_OpeningTrain = "OpeningTrain",
  EName_NewSeason = "NewSeason",
  EName_WoW = "WoW",
  EName_WoWHall = "NewSeason"
}
function RequireMod(moduleName)
  local result, res = pcall(require, moduleName)
  return res
end
function RequireModDownload(moduleName, CallBack)
  if not moduleName or moduleName == "" or not StringUtil.StrFind(moduleName, ".") then
    return nil
  end
  local ModName = LobbyModUtils.GetModNameByModuleName(moduleName)
  if not ModName then
    return
  end
  if LobbyModUtils.IsModDownloaded(ModName) then
    local result, res = pcall(require, moduleName)
    if result then
      if CallBack then
        CallBack(res)
      end
      return res
    end
    return nil
  end
  LobbyModUtils.DownloadMod(ModName, function()
    local result, res = pcall(require, moduleName)
    if result then
      if CallBack then
        CallBack(res)
      end
      return res
    end
  end)
  log(bWriteLog and "RequireModDownload not Download moduleName: " .. tostring(moduleName))
  return nil
end
function LobbyModUtils.CreateDownloadUIByModKey(Modkey, ParentWidget, extraParams)
  local ResList = LobbyModUtils.GetModResList(Modkey)
  if not ResList or #ResList <= 0 then
    return
  end
  common_download_handler.CreateDownloadUI(PufferConst.ENUM_DownloadType.ODPAK, ResList, ParentWidget, extraParams)
end
function LobbyModUtils.CreateDownloadUIByModKeyReturnUIBase(Modkey, uiBase, ParentWidget, extraParams)
  local ResList = LobbyModUtils.GetModResList(Modkey)
  if not ResList or #ResList <= 0 then
    return
  end
  common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.ODPAK, ResList, uiBase, ParentWidget, extraParams)
end
function LobbyModUtils.IsModDownloaded(Modkey)
  local ResList = LobbyModUtils.GetModResList(Modkey)
  if not ResList or #ResList <= 0 then
    return true
  end
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, ResList)
  return state == PufferConst.ENUM_DownloadState.Done
end
function LobbyModUtils.DownloadMod(Modkey, CallBack)
  local ResList = LobbyModUtils.GetModResList(Modkey)
  if not ResList or #ResList <= 0 then
    return
  end
  local params = {bFirst = true}
  PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, ResList, nil, CallBack, params)
end
function LobbyModUtils.GetModResList(Modkey)
  local key2List = LobbyModUtils.Modkey2ResList
  if not key2List then
    LobbyModUtils.Modkey2ResList = {}
    key2List = LobbyModUtils.Modkey2ResList
  end
  if key2List[Modkey] then
    return key2List[Modkey]
  end
  local ResList = {}
  key2List[Modkey] = ResList
  local LModCfg = CDataTable.GetTableData("LobbyModConfig", Modkey)
  if not (LModCfg and LModCfg.ResPath) or LModCfg.ResPath == "" then
    return ResList
  end
  table_insert(ResList, LModCfg.ResPath)
  if not LModCfg.DependMod_an then
    return ResList
  end
  for _, v in pairs(LModCfg.DependMod_an) do
    LModCfg = CDataTable.GetTableData("LobbyModConfig", v)
    if LModCfg and LModCfg.ResPath and LModCfg.ResPath ~= "" then
      table_insert(ResList, LModCfg.ResPath)
    end
  end
  return ResList
end
function LobbyModUtils.GetSplitModuleDownload(ModuleConfig, CallBack)
  if not ModuleConfig or not ModuleConfig.ModuleName then
    return nil
  end
  local ModName = LobbyModUtils.GetModNameByModuleName(ModuleConfig.ModuleName)
  if not ModName then
    return nil
  end
  local ModuleSystem
  if LobbyModUtils.IsModDownloaded(ModName) then
    ModuleSystem = ModuleManager.GetModule(ModuleConfig)
    if CallBack then
      CallBack(ModuleSystem)
    end
    return ModuleSystem
  end
  LobbyModUtils.DownloadMod(ModName, function()
    ModuleSystem = ModuleManager.GetModule(ModuleConfig)
    if CallBack then
      CallBack(ModuleSystem)
    end
  end)
  return ModuleSystem
end
function LobbyModUtils.GetSplitTableData(ModType, ModName, TableName, Key, CallBack)
  local Res
  if LobbyModUtils.IsModDownloaded(ModName) then
    Res = CDataTable.GetSplitTableData(ModType, ModName, TableName, Key)
    if CallBack then
      CallBack(Res)
    end
  end
  LobbyModUtils.DownloadMod(ModName, function()
    Res = CDataTable.GetSplitTableData(ModType, ModName, TableName, Key)
    if CallBack then
      CallBack(Res)
    end
  end)
  return Res
end
function LobbyModUtils.GetSplitTable(ModType, ModName, TableName, CallBack)
  local Res
  if LobbyModUtils.IsModDownloaded(ModName) then
    Res = CDataTable.GetSplitTable(ModType, ModName, TableName)
    if CallBack then
      CallBack(Res)
    end
    return Res
  end
  LobbyModUtils.DownloadMod(ModName, function()
    Res = CDataTable.GetSplitTable(ModType, ModName, TableName)
    if CallBack then
      CallBack(Res)
    end
  end)
  return nil
end
function LobbyModUtils.GetSplitTableByFilter(ModType, ModName, TableName, CallBack, ...)
  local Res
  if LobbyModUtils.IsModDownloaded(ModName) then
    Res = CDataTable.GetSplitTableByFilter(ModType, ModName, TableName, ...)
    if CallBack then
      CallBack(Res)
    end
    return Res
  end
  local Arg = table_pack(...)
  LobbyModUtils.DownloadMod(ModName, function()
    Res = CDataTable.GetSplitTableByFilter(ModType, ModName, TableName, table_unpack(Arg))
    if CallBack then
      CallBack(Res)
    end
  end)
  return nil
end
function LobbyModUtils.GetSplitTableDataByFilter(ModType, ModName, TableName, CallBack, ...)
  local Res
  if LobbyModUtils.IsModDownloaded(ModName) then
    Res = CDataTable.GetSplitTableDataByFilter(ModType, ModName, TableName, ...)
    if CallBack then
      CallBack(Res)
    end
    return Res
  end
  local Arg = table_pack(...)
  LobbyModUtils.DownloadMod(ModName, function()
    Res = CDataTable.GetSplitTableDataByFilter(ModType, ModName, TableName, table_unpack(Arg))
    if CallBack then
      CallBack(Res)
    end
  end)
  return nil
end
function LobbyModUtils.GetModNameByModuleName(ModuleName)
  if not ModuleName or ModuleName == "" then
    return nil
  end
  local module2Mod = LobbyModUtils.ModuleName2ModName
  if not module2Mod then
    LobbyModUtils.ModuleName2ModName = {}
    module2Mod = LobbyModUtils.ModuleName2ModName
  end
  if module2Mod[ModuleName] then
    return module2Mod[ModuleName]
  end
  local MList = StringUtil.Split(ModuleName, ".")
  if not MList or #MList < 5 then
    return nil
  end
  local ModName = MList[5]
  local LModCfg = CDataTable.GetTableData("LobbyModConfig", ModName)
  if not LModCfg then
    return nil
  end
  module2Mod[ModuleName] = ModName
  return ModName
end
return LobbyModUtils