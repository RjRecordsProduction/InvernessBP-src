local headshot_module = {}
function headshot_module:GetAvatarIconCfg(nRedId)
  local sAvatarIconPath
  local tItemCfg = CDataTable.GetTableData("Item", nRedId) or {}
  if tItemCfg.ItemType == ENUM_ITEM_TYPE.HeadBorder then
    sAvatarIconPath = self:GetFrameDynamicIconAndCheckDownload(nRedId)
  elseif tItemCfg.ItemType == ENUM_ITEM_TYPE.HeadIcon then
    sAvatarIconPath = self:GetDynamicIconAndCheckDownload(nRedId)
  end
  return sAvatarIconPath ~= "" and sAvatarIconPath
end
function headshot_module:CheckDynamicIconByID(ID, successCallback)
  local cfg = CDataTable.GetTableData("Headportrait", ID)
  if not cfg then
    return false
  end
  local dynamicIconPath = cfg.DynamicIcon
  if dynamicIconPath and dynamicIconPath ~= "" then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {dynamicIconPath})
    if state ~= PufferConst.ENUM_DownloadState.Done then
      local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {dynamicIconPath}, PufferTlog.Enum_TLog_From.Auto, successCallback)
      return false
    end
    return true
  end
  return false
end
function headshot_module:GetDynamicIconAndCheckDownload(ID)
  local cfg = CDataTable.GetTableData("Headportrait", ID)
  if not cfg then
    return ""
  end
  local dynamicIconPath = cfg.DynamicIcon
  if dynamicIconPath and dynamicIconPath ~= "" then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {dynamicIconPath})
    if state ~= PufferConst.ENUM_DownloadState.Done then
      return ""
    end
    return dynamicIconPath
  end
  return ""
end
function headshot_module:GetDynamicIconByID(ID)
  local cfg = CDataTable.GetTableData("Headportrait", ID)
  if not cfg then
    return ""
  end
  local dynamicIconPath = cfg.DynamicIcon
  if dynamicIconPath and dynamicIconPath ~= "" then
    return dynamicIconPath
  end
  return ""
end
function headshot_module:CheckFrameDynamicIconByID(ID, successCallback)
  local cfg = CDataTable.GetTableData("AvatarFrame", ID)
  if not cfg then
    return false
  end
  local dynamicIconPath = cfg.DynamicIcon
  if dynamicIconPath and dynamicIconPath ~= "" then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {dynamicIconPath})
    if state ~= PufferConst.ENUM_DownloadState.Done then
      local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {dynamicIconPath}, PufferTlog.Enum_TLog_From.Auto, successCallback)
      return false
    end
    return true
  end
  return false
end
function headshot_module:GetFrameDynamicIconAndCheckDownload(ID)
  local cfg = CDataTable.GetTableData("AvatarFrame", ID)
  if not cfg then
    return ""
  end
  local dynamicIconPath = cfg.DynamicIcon
  if dynamicIconPath and dynamicIconPath ~= "" then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {dynamicIconPath})
    if state ~= PufferConst.ENUM_DownloadState.Done then
      return ""
    end
    return dynamicIconPath
  end
  return ""
end
function headshot_module:GetFrameDynamicIconByID(ID)
  local cfg = CDataTable.GetTableData("AvatarFrame", ID)
  if not cfg then
    return ""
  end
  local dynamicIconPath = cfg.DynamicIcon
  if dynamicIconPath and dynamicIconPath ~= "" then
    return dynamicIconPath
  end
  return ""
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, headshot_module)
return CModuleTemplate