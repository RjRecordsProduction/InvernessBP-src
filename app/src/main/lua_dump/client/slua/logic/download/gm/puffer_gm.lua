local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local PufferGM = {
  ErrorTasks = {},
  ENUM_DownloadStateStr = {
    [PufferConst.ENUM_DownloadState.Done] = "\229\183\178\228\184\139\232\189\189",
    [PufferConst.ENUM_DownloadState.Download] = "\228\184\139\232\189\189\228\184\173",
    [PufferConst.ENUM_DownloadState.Pause] = "\230\154\130\229\129\156",
    [PufferConst.ENUM_DownloadState.Not] = "\230\156\170\228\184\139\232\189\189",
    [PufferConst.ENUM_DownloadState.Error] = "\228\184\139\232\189\189\233\148\153\232\175\175",
    [PufferConst.ENUM_DownloadState.Wait] = "\231\173\137\229\190\133\228\184\173"
  }
}
function PufferGM.ShowDownloadErrorTips()
  local title = LocUtil.GetLocalizeResStr(5077)
  local tips = PufferGM.GetErrorString()
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 2, title, tips)
end
function PufferGM.GetErrorString()
  local result = ""
  if not PufferDownloader.InitSuccess then
    result = string.format("\228\184\139\232\189\189\229\136\157\229\167\139\229\140\150\229\164\177\232\180\165\239\188\140\232\175\183\229\136\135\230\141\162\231\189\145\231\187\156\230\136\150\233\135\141\229\144\175\230\184\184\230\136\143\239\188\140\233\148\153\232\175\175\231\160\129\239\188\154%s", tostring(PufferDownloader.InitErrorCode))
    return result
  end
  if next(PufferGM.ErrorTasks) then
    for pakName, task in pairs(PufferGM.ErrorTasks) do
      local str = string.format("Pak\239\188\154%s \n", pakName)
      if task.itemID and task.itemID > 0 then
        str = str .. string.format("\231\137\169\229\147\129ID\239\188\154%s \n", task.itemID)
      end
      if task.path and task.path ~= "" then
        str = str .. string.format("\232\147\157\229\155\190\232\183\175\229\190\132\239\188\154%s \n", task.path)
      end
      str = str .. string.format("\233\148\153\232\175\175\231\160\129\239\188\154%s \n", task.errorCode)
      if task.errorCode == 1 or task.errorCode == -1 then
        if task.downloadType == PufferConst.ENUM_DownloadType.ODPAK or task.downloadType == PufferConst.ENUM_DownloadType.ODPACK then
          str = str .. string.format("\232\167\163\229\134\179\230\150\185\230\179\149\239\188\154\230\163\128\230\159\165\230\152\175\229\144\166\229\138\160\229\175\134\232\181\132\230\186\144\239\188\140\232\139\165\228\184\141\230\152\175\229\138\160\229\175\134\232\181\132\230\186\144\239\188\140\229\136\153\232\129\148\231\179\187\231\155\184\229\133\179PM\230\155\180\230\150\176GCloud Puffer\232\181\132\230\186\144 \n")
        else
          str = str .. string.format("\232\167\163\229\134\179\230\150\185\230\179\149\239\188\154\228\191\174\229\164\141\226\128\148\226\128\148\230\129\162\229\164\141\229\136\157\229\167\139\232\174\190\231\189\174 \n")
        end
      end
      result = result .. str
    end
  end
  return result
end
function PufferGM.ShowDownloadInfoByItemID(itemID)
  local title = LocUtil.GetLocalizeResStr(5077)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  local paths = PufferODPakManager:GetBPPathsByItemID(itemID, itemCfg)
  local cSize, tSize = PufferODPakManager:GetSizeByItemID(itemID)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  local tips = string.format("\231\137\169\229\147\129ID\239\188\154%s, %s \229\164\167\229\176\143\239\188\154%.2fMB/%.2fMB \231\155\184\229\133\179\232\147\157\229\155\190\232\183\175\229\190\132\239\188\154\n", tostring(itemID), itemCfg and itemCfg.ItemName or " ", cSize / PufferConst.MB, tSize / PufferConst.MB)
  for _, path in pairs(paths) do
    local pakName = PufferManager.GetPakName(path)
    if pakName ~= "" then
      local state = PufferODPakManager:GetStateByPakName(pakName)
      tips = tips .. string.format("\232\147\157\229\155\190\232\183\175\229\190\132%s\n%s\239\188\154%s\n", path, pakName, PufferGM.ENUM_DownloadStateStr[state])
      if PufferGM.ErrorTasks[pakName] then
        tips = tips .. string.format("\233\148\153\232\175\175\231\160\129\239\188\154%s \n", PufferGM.ErrorTasks[pakName].errorCode)
      end
    else
      tips = tips .. string.format("%s: \230\156\170\230\139\134\229\136\134\n", path)
    end
  end
  PufferManager.InitResourcePatchCfg()
  local version = PufferManager.resourcePatchCfg[itemID]
  if version then
    local puffer_res_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
    local resKey = PufferConst.PUFFERPATCH .. "_" .. version .. ".pak"
    local state = puffer_res_manager:GetState(resKey)
    tips = tips .. string.format("Patch\231\137\136\230\156\172: %s\n%s\239\188\154%s\n", version, resKey, PufferGM.ENUM_DownloadStateStr[state])
  end
  log(bWriteLog and "PufferGM.ShowDownloadInfoByItemID. tips = " .. tostring(tips))
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 1, title, tips)
end
function PufferGM.ShowDownloadInfoByMapKey(mapKey)
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  if not PufferMapManager.MapPaks[mapKey] then
    ShowDevNotice("###mapKey\228\184\141\229\173\152\229\156\168")
    return
  end
  local title = LocUtil.GetLocalizeResStr(5077)
  local tips = string.format("\229\156\176\229\155\190Key\239\188\154%s, \231\155\184\229\133\179pak\239\188\154\n", tostring(mapKey))
  local mapList = PufferMapManager:GetDependMapFiles(mapKey, 0, 0)
  local allDepends = {}
  for k, v in pairs(mapList) do
    local mapData = PufferMapManager.MapPaks[v]
    if mapData then
      allDepends[v] = mapData.pakName
      for kk, vv in pairs(mapData.depends) do
        allDepends[kk] = vv
      end
    end
  end
  local list1 = {}
  local list2 = {}
  for k, v in pairs(allDepends) do
    local state = PufferConst.ENUM_DownloadState.Done
    local data = {}
    if PufferMapManager.MapPaks[k] then
      state = PufferMapManager:GetState(k, true)
      data = {
        key = k,
        stateStr = PufferGM.ENUM_DownloadStateStr[state],
        pakName = PufferMapManager.MapPaks[k].pakName
      }
    else
      state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {k})
      data = {
        key = tostring(v),
        stateStr = PufferGM.ENUM_DownloadStateStr[state],
        pakName = k
      }
    end
    if state ~= PufferConst.ENUM_DownloadState.Done then
      table.insert(list1, data)
    else
      table.insert(list2, data)
    end
  end
  for _, v in pairs(list1) do
    tips = tips .. string.format("\228\190\157\232\181\150\232\181\132\230\186\144 %s %s\n%s\n", v.key, v.stateStr, v.pakName)
  end
  for _, v in pairs(list2) do
    tips = tips .. string.format("\228\190\157\232\181\150\232\181\132\230\186\144 %s %s\n%s\n", v.key, v.stateStr, v.pakName)
  end
  log_tree("list1 = ", list1)
  log_tree("list2 = ", list2)
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 1, title, tips)
end
function PufferGM.DeleteODPakByItemID(ItemID)
  local GCPufferDownloader = slua_GameFrontendHUD:GetPufferDownloader()
  if not slua.isValid(GCPufferDownloader) then
    print(bWriteLog and string.format("PufferGM.DeleteODPakByItemID failed ItemID:%d", ItemID))
    return false, "", false, ""
  end
  local UBackpackUtils = import("BackpackUtils")
  local StringUtil = require("common.string_util")
  local DefineID = UBackpackUtils.GetItemDefineIDByItemID(ItemID)
  function deleteODPak(ItemID, HandlePath)
    local tParamTable = StringUtil.Split(HandlePath, ".")
    print(bWriteLog and string.format("PufferGM.DeleteODPakByItemID deleteODPak ItemID:%d, HandlePath:%s", ItemID, HandlePath))
    if tParamTable and 0 < #tParamTable then
      local sHandlePathName = tParamTable[1]
      local sODPakName = GCPufferDownloader:GetODPakName(sHandlePathName)
      local sODPakFilePath = string.format("%sPaks/%s", Client.ProjectSavedDir(), sODPakName)
      print(bWriteLog and string.format("PufferGM.DeleteODPakByItemID deleteODPak ItemID:%d, ODPakFilePath:%s", ItemID, sODPakFilePath))
      if sODPakName ~= "" then
        if Client.FullPathFileExist(sODPakFilePath) and Client.DeleteFile(sODPakFilePath) then
          print(bWriteLog and string.format("PufferGM.DeleteODPakByItemID deleteODPak Success ItemID:%d", ItemID))
          return true, sODPakName
        end
        return false, sODPakName
      end
    else
      print(bWriteLog and string.format("PufferGM.DeleteODPakByItemID has not . failed, ItemID:%d", ItemID))
    end
    return false, ""
  end
  local sHandlePath = UBackpackUtils.GetBattleItemHandlePath(DefineID, false, false)
  local bHandleDelete, sODPakName = deleteODPak(ItemID, sHandlePath)
  local sLobbyHandlePath = UBackpackUtils.GetBattleItemHandlePath(DefineID, true, true)
  if sLobbyHandlePath ~= "" and sLobbyHandlePath ~= sHandlePath then
    local bLobbyHandleDelete, sLobbyPakName = deleteODPak(ItemID, sLobbyHandlePath)
    return bHandleDelete, sODPakName, bLobbyHandleDelete, sLobbyPakName
  else
    return bHandleDelete, sODPakName, bHandleDelete, sODPakName
  end
end
function PufferGM.ShowUGCAssetDownloadInfo(AssetID, bCheckDepend)
  local Title = LocUtil.GetLocalizeResStr(5077)
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  local PakSize = PufferUGCPakManager:GetSizeByAssetID(AssetID, not bCheckDepend)
  local Tips = string.format("\231\137\169\228\187\182ID\239\188\154%s, Size\239\188\154%.2f MB\n\n", tostring(AssetID), tonumber(PakSize))
  local Paths = PufferUGCPakManager:_GetResourcesPath(AssetID)
  for _, Path in pairs(Paths) do
    local PakName = PufferManager.GetPakName(Path)
    if PakName ~= "" then
      local state = PufferUGCPakManager:GetStateByPakName(PakName)
      Tips = Tips .. string.format("\232\147\157\229\155\190\232\183\175\229\190\132%s\n PakName\239\188\154%s, done\239\188\154%s\n", Path, PakName, PufferGM.ENUM_DownloadStateStr[state])
      if PufferGM.ErrorTasks[PakName] then
        Tips = Tips .. string.format("\233\148\153\232\175\175\231\160\129\239\188\154%s \n", PufferGM.ErrorTasks[PakName].errorCode)
      end
    else
      Tips = Tips .. string.format("\232\147\157\229\155\190\232\183\175\229\190\132%s\239\188\154\230\156\170\230\139\134\229\136\134\n", Path)
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 1, Title, Tips)
end
function PufferGM.ShowVirtualPackDownloadInfo(PackID)
  local Title = LocUtil.GetLocalizeResStr(5077)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local CurSize, PackSize = PufferODPakManager:GetSizeByPackID(PackID)
  local Tips = string.format("\229\136\134\229\140\133ID\239\188\154%s, Size\239\188\154%.2f MB, \229\183\178\228\184\139\232\189\189\239\188\154%.2f MB\n\n", tostring(PackID), tonumber(PackSize), tonumber(CurSize))
  if PufferODPakManager.ODPaks then
    local PackInfo = PufferODPakManager.ODPaks[PackID]
    if PackInfo and PackInfo.isVirtual then
      for PakName, PakInfo in pairs(PackInfo.paks) do
        Tips = Tips .. string.format([[
PakName:%s
 totalSize:%.2f, curSize:%.2f, done:%s
]], PakName, PakInfo.cSize, PakInfo.tSize, tostring(PakInfo.state == 3))
      end
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 1, Title, Tips)
end
function PufferGM.ShowFeatureDownloadInfo(FeatureID)
  local Title = LocUtil.GetLocalizeResStr(5077)
  local Tips = ""
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local PakNames = PufferODPakManager:GetPakNamesByFeatureID(FeatureID)
  if PakNames then
    local PakName = next(PakNames)
    local PakSize = PufferODPakManager:GetSizeByPakName(PakName)
    local PakState = PufferODPakManager:GetStateByPakName(PakName)
    Tips = string.format("\229\133\131\231\180\160ID\239\188\154%s,PakName: %s Size\239\188\154%.2f MB, done\239\188\154%s", FeatureID, tostring(PakName), tonumber(PakSize), tostring(PakState))
  else
    Tips = "\230\178\161\230\156\137\232\175\165\231\142\169\230\179\149\229\133\131\231\180\160ID"
  end
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 1, Title, Tips)
end
function PufferGM.ShowActivityDownloadInfo(activityID)
  local logic_lobby_mid_banner = require("client.slua.logic.lobby.Mid.logic_lobby_mid_banner")
  local data
  local list = logic_lobby_mid_banner.GetLobbyBannerList()
  activityID = tonumber(activityID)
  if list then
    for k, v in pairs(list) do
      if v.ID == activityID then
        data = v
        break
      end
    end
  end
  if not data then
    list = logic_lobby_mid_banner.GetPHomeBannerList()
    if list then
      for k, v in pairs(list) do
        if v.ID == activityID then
          data = v
          break
        end
      end
    end
  end
  local Title = LocUtil.GetLocalizeResStr(5077)
  local Tips = ""
  if not data then
    Tips = "\230\178\161\230\156\137\230\137\190\229\136\176\229\175\185\229\186\148\231\154\132\230\180\187\229\138\168"
  else
    local pakNames = {}
    local handleFunc = function(path)
      local pakName = PufferManager.GetPakName(data.BPPath)
      local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
        data.BPPath
      }, true)
      pakNames[data.BPPath] = {pakName = pakName, state = state}
    end
    local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
    local handleIDFunc = function(itemID)
      local itemPaks = PufferODPakManager:GetPakNamesByItemID(itemID)
      for pakName, v in pairs(itemPaks) do
        handleFunc(pakName)
      end
    end
    if data.BPPath and data.BPPath ~= "" then
      handleFunc(data.BPPath)
      handleIDFunc(PufferConst.ActivityAudioItemID)
    end
    if data.Depends and data.Depends ~= "" then
      local StringUtil = require("common.string_util")
      local splitRet = StringUtil.Split(data.Depends, "|")
      for i, v in pairs(splitRet) do
        if tonumber(v) then
          handleIDFunc(tonumber(v))
        elseif StringUtil.Ends(tostring(v), ".mp4") then
          handleFunc(DataMgr.GetVideoDownloadPath(v))
        else
          handleFunc(v)
        end
      end
    end
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local downloadList = PufferManager.GetDownloadListByModuleIDActivityID(tonumber(data.module), tonumber(data.activityid))
    if next(downloadList) then
      for _, v in pairs(downloadList) do
        handleFunc(v)
      end
    end
    Tips = "\230\180\187\229\138\168ID\239\188\154" .. activityID .. "\n"
    if next(pakNames) then
      for k, v in pairs(pakNames) do
        Tips = Tips .. "" .. tostring(k) .. "\n" .. v.pakName .. " " .. tostring(v.state)
      end
    else
      Tips = Tips .. "\230\178\161\230\156\137\228\190\157\232\181\150\232\181\132\230\186\144"
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 1, Title, Tips)
end
return PufferGM