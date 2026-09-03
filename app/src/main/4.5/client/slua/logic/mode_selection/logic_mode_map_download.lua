local logic_mode_map_download = {}
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
function logic_mode_map_download:OnInitialize()
  logic_mode_map_download.__super.OnInitialize(self)
end
function logic_mode_map_download:OnLogin(bReLogin)
end
function logic_mode_map_download:OnPreSwitchGameStatus(preState, nextState)
end
function logic_mode_map_download:GetMapKeyListByViewId(viewId)
  if not viewId then
    log_error("logic_mode_map_download:GetMapKeyListByViewId viewId is nil")
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewData = logic_mode_selection:GetSubviewInfoBySubviewID(viewId)
  if not viewData then
    log_error(string.format("logic_mode_map_download:GetMapKeyListByViewId viewData is nil for viewId: %s", tostring(viewId)))
    return
  end
  local   local mapKeyList = self:GetMapKeyListByViewData(viewData)
  return mapKeyList
end
function logic_mode_map_download:GetMapKeyListByViewData(viewData)
  if not viewData or not viewData.options then
    return nil, nil
  end
  if viewData.map_download and viewData.map_download == 1 then
    return {
      "Baltic_Main"
    }, {Baltic_Main = true}
  end
  local mapKeyDict = {}
  local mapCfgData
  if viewData.id == 0 then
    return {
      "Baltic_Main"
    }, {Baltic_Main = true}
  end
  local defaultModeID = viewData.options.team_type[viewData.options.default_person][viewData.options.default_team_size]
  local maps = viewData.options.team_type_maps[defaultModeID] or {}
  for k, v in pairs(maps) do
    mapCfgData = CDataTable.GetTableData("Map", v)
    if mapCfgData then
      mapKeyDict[mapCfgData.MapKey] = true
    end
  end
  local mapKeyList = {}
  for k, v in pairs(mapKeyDict) do
    table.insert(mapKeyList, k)
  end
  return mapKeyList, mapKeyDict
end
function logic_mode_map_download:GetMapIdListByViewData(viewData)
  if not viewData or not viewData.options then
    return nil, nil
  end
  local mapKeyDict = {}
  local mapCfgData
  local defaultModeID = viewData.options.team_type[viewData.options.default_person][viewData.options.default_team_size]
  local maps = viewData.options.team_type_maps[defaultModeID]
  for k, v in pairs(maps) do
    mapCfgData = CDataTable.GetTableData("Map", v)
    if mapCfgData then
      mapKeyDict[v] = true
    end
  end
  local mapIdList = {}
  for k, v in pairs(mapKeyDict) do
    table.insert(mapIdList, k)
  end
  return mapIdList
end
function logic_mode_map_download:GetMapListSize(mapKeyList)
  local curSize, totalSize, dependSize, dependTotal = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, mapKeyList)
  return curSize, totalSize, dependSize, dependTotal
end
function logic_mode_map_download:GetMapListState(mapKeyList)
  return PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, mapKeyList)
end
function logic_mode_map_download:GetMapListStateSkipDepend(mapKeyList)
  return PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, mapKeyList, true)
end
function logic_mode_map_download:GetHadLoadMapListByTabId(tabId)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local subViewInfo = logic_mode_selection:GetTabInfoByTabID(tabId)
  local subviewIdList = subViewInfo and subViewInfo.sub_views or {}
  local downloadViewList = {}
  for i, v in ipairs(subviewIdList) do
    local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(v) or {}
    local mapkeyList = self:GetMapKeyListByViewData(viewInfo) or {}
    local state = self:GetMapListState(mapkeyList)
    if state == ENUM_DownloadState.Done then
      table.insert(downloadViewList, v)
    end
  end
  return downloadViewList
end
function logic_mode_map_download:GetMapIdListByTabId()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local subviewIdList = logic_mode_selection:GetAllTabInfo() or {}
  if not subviewIdList or not next(subviewIdList) then
    return
  end
  local TableUtil = require("common.table_util")
  local downloadViewList = {}
  for k, v in pairs(subviewIdList) do
    if not downloadViewList[k] then
      downloadViewList[k] = {}
    end
    for i, viewId in ipairs(v) do
      local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(viewId)
      if viewInfo then
        local mapIdList = self:GetMapIdListByViewData(viewInfo)
        if mapIdList and next(mapIdList) then
          TableUtil.TableConcat(downloadViewList[k], mapIdList)
        end
      end
    end
  end
  return downloadViewList
end
function logic_mode_map_download:DownloadMapKeyList(mapKeyList, b4GNotDownload)
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local extraData = {bAutoDownload = b4GNotDownload}
  PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, mapKeyList, PufferTlog.Enum_TLog_From.ModeSelect, nil, extraData)
end
function logic_mode_map_download:PausedMapKeyList(mapKeyList)
  PufferManager.Pause(PufferConst.ENUM_DownloadType.MAP, mapKeyList)
  ShowNotice(34993)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_mode_map_download = class(CModuleBase, nil, logic_mode_map_download)
return Clogic_mode_map_download