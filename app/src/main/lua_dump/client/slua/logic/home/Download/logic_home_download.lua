local logic_home_download = {
  HomeChileModuleType = {HomeShopType = 1, HomeEntranceMainUIType = 2},
  HomeShopMap = "map_planph_3"
}
function logic_home_download.PauseHomeSource(downloadTypeInfo)
  log(bWriteLog and "logic_home_download.PauseHomeSource")
  if not downloadTypeInfo then
    log(bWriteLog and "logic_home_download.PauseHomeSource downloadTypeInfo is not valid")
    return
  end
  log_tree(bWriteLog and "logic_home_download.PauseHomeSource downloadTypeInfo is valid", downloadTypeInfo)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  for downloadType, keyList in pairs(downloadTypeInfo) do
    PufferManager.Pause(downloadType, keyList)
  end
end
function logic_home_download.DownloadHomeSource(downloadTypeInfo, callback)
  log_tree(WriteLog and "logic_home_download.DownloadHomeSource", downloadTypeInfo)
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  for downloadType, keyList in pairs(self.downloadTypeInfo) do
    PufferManager.Download(downloadType, keyList, PufferTlog.Enum_TLog_From.LobbyEntrance, callback)
  end
end
function logic_home_download.PauseHomeChileModuleSource(HomeChileModuleType)
  log(bWriteLog and string.format("logic_home_download.PauseHomeChileModuleSource, HomeChileModuleType.%s", HomeChileModuleType))
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if HomeChileModuleType == logic_home_download.HomeChileModuleType.HomeShopType then
    PufferManager.Pause(PufferConst.ENUM_DownloadType.MAP, {
      logic_home_download.HomeShopMap
    })
  elseif HomeChileModuleType == logic_home_download.HomeChileModuleType.HomeEntranceMainUIType then
    local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
    local Modkey = LobbyModUtils.Enum_Mod_Name.EName_Home
    local ResList = LobbyModUtils.GetModResList(Modkey)
    if not ResList or #ResList <= 0 then
      log(bWriteLog and "logic_home_download.DownloadHomeChileModuleSource ResList is not valid")
      return
    end
    PufferManager.Pause(PufferConst.ENUM_DownloadType.ODPAK, ResList)
  end
end
function logic_home_download.DownloadHomeChileModuleSource(HomeChileModuleType, callback)
  log(bWriteLog and string.format("logic_home_download.DownloadHomeChileModuleSource, HomeChileModuleType.%s", HomeChileModuleType))
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if HomeChileModuleType == logic_home_download.HomeChileModuleType.HomeShopType then
    local realCallback = function()
      if callback then
        callback()
      end
      local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
      PufferMapManager:MountMapPak(logic_home_download.HomeShopMap)
    end
    PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {
      logic_home_download.HomeShopMap
    }, PufferTlog.Enum_TLog_From.LobbyEntrance, realCallback)
  elseif HomeChileModuleType == logic_home_download.HomeChileModuleType.HomeEntranceMainUIType then
    local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
    local Modkey = LobbyModUtils.Enum_Mod_Name.EName_Home
    local ResList = LobbyModUtils.GetModResList(Modkey)
    if not ResList or #ResList <= 0 then
      log(bWriteLog and "logic_home_download.DownloadHomeChileModuleSource ResList is not valid")
      return
    end
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, ResList, PufferTlog.Enum_TLog_From.LobbyEntrance, callback)
  end
end
function logic_home_download.GetChildModuleDownloadList(HomeChileModuleType)
  log(bWriteLog and string.format("logic_home_download.GetChildModuleDownloadList, HomeChileModuleType.%s", HomeChileModuleType))
  local downloadList = {}
  if HomeChileModuleType == logic_home_download.HomeChileModuleType.HomeShopType then
    local StoreMap = logic_home_download.HomeShopMap
    downloadList = {StoreMap}
    local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
    if not LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.EName_Home) then
      log(bWriteLog and "logic_home_download.GetChildModuleDownloadList Home is not downloaded")
      logic_home_download.GetHomePageSourceList(downloadList)
    end
  elseif HomeChileModuleType == logic_home_download.HomeChileModuleType.HomeEntranceMainUIType then
    logic_home_download.GetHomePageSourceList(downloadList)
  end
  log_tree(bWriteLog and "logic_home_download.GetChildModuleDownloadList", downloadList)
  return downloadList
end
function logic_home_download.GetHomePageSourceList(downloadList)
  local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
  local Modkey = LobbyModUtils.Enum_Mod_Name.EName_Home
  local ResList = LobbyModUtils.GetModResList(Modkey)
  if not ResList or #ResList <= 0 then
    log(bWriteLog and "logic_home_download.GetChildModuleDownloadList ResList is not valid")
  else
    for i, v in pairs(ResList) do
      downloadList[#downloadList + 1] = v
    end
  end
end
function logic_home_download.CheckHomeChildModuleReady(HomeChileModuleType, gotoFuc)
  local downloaded = false
  local downloadSize = 0
  local PlanPH_Download_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_Download_Tools")
  if HomeChileModuleType == logic_home_download.HomeChileModuleType.HomeShopType then
    downloaded, downloadSize = PlanPH_Download_Tools.CheckDownloadReady(logic_home_download.HomeShopMap)
    local homeDownloaded, homeDownloadSize = PlanPH_Download_Tools.CheckHomeODPAKDownloadReady()
    downloadSize = downloadSize + homeDownloadSize
    if downloaded then
      log(bWriteLog and "logic_home_download.CheckHomeChildModuleReady gotoFuc is function")
      local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
      PufferMapManager:MountMapPak(logic_home_download.HomeShopMap)
    end
    downloaded = downloaded and homeDownloaded
  elseif HomeChileModuleType == logic_home_download.HomeChileModuleType.HomeEntranceMainUIType then
    downloaded, downloadSize = PlanPH_Download_Tools.CheckHomeODPAKDownloadReady()
  end
  if downloaded then
    if gotoFuc and type(gotoFuc) == "function" then
      gotoFuc()
    else
      log(bWriteLog and "logic_home_download.CheckHomeChildModuleReady gotoFuc is not function")
    end
  else
    UIManager.ShowUI(UIManager.UI_Config.Home_Download_Store_Popup_UIBP, HomeChileModuleType, downloadSize, gotoFuc)
  end
  return downloaded, downloadSize
end
function logic_home_download.GetHomeMapPakSize(uID, callback)
  log(bWriteLog and "logic_home_download.GetHomeMapPakSize", uID)
  local logic_home_detail = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_detail)
  logic_home_detail:SendGetManorUseItems(uID, function(ReturnUid, use_items)
    log(bWriteLog and string.format("logic_home_download.GetHomeMapPakSize, uID.%s, ReturnUid\239\188\154%s", uID, ReturnUid))
    if uID ~= ReturnUid then
      log(bWriteLog and "logic_home_download.GetHomeMapPakSize uID ~= ReturnUid")
      return
    end
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local downloadTypeInfo = {}
    local use_items_arr = {}
    if use_items and next(use_items) then
      local index = 1
      for itemID, _ in pairs(use_items) do
        use_items_arr[index] = itemID
        index = index + 1
        local type = PufferManager.GetDownloadType(itemID) or PufferConst.ENUM_DownloadType.ODPAK
        if not downloadTypeInfo[type] then
          downloadTypeInfo[type] = {itemID}
        else
          table.insert(downloadTypeInfo[type], itemID)
        end
      end
    end
    local curSize = 0
    local totalSize = 0
    local state = PufferConst.ENUM_DownloadState.Done
    for downloadType, keyList in pairs(downloadTypeInfo) do
      local TempCurSize, TempTotalSize = PufferManager.GetSize(downloadType, keyList)
      curSize = curSize + TempCurSize
      totalSize = totalSize + TempTotalSize
      if PufferManager.GetState(downloadType, keyList) ~= PufferConst.ENUM_DownloadState.Done then
        state = PufferConst.ENUM_DownloadState.Not
      end
    end
    local leftSize = totalSize - curSize
    if state == PufferConst.ENUM_DownloadState.Done then
      leftSize = -1
    end
    if callback and type(callback) == "function" then
      callback(leftSize, downloadTypeInfo, use_items_arr, use_items)
    else
      log(bWriteLog and "logic_home_download.GetHomeMapPakSize callback is not valid")
    end
  end)
end
function logic_home_download.CheckHomeDownloadedDone(uID, gotoFuc)
  log(bWriteLog and "logic_home_download.CheckHomeDownloadedDone", uID)
  if not uID then
    log(bWriteLog and "logic_home_download.CheckHomeDownloadedDone uID is not valid")
    uID = DataMgr.roleData.uid
  end
  logic_home_download.GetHomeMapPakSize(uID, function(leftSize, downloadTypeInfo, use_items_arr, items_arr)
    log(bWriteLog and "logic_home_download.CheckHomeDownloadedDone, leftSize:%s", leftSize)
    local DownloadData = {
      downloadSize = leftSize,
      use_items = use_items_arr,
      downloadHomeTypeInfo = downloadTypeInfo,
      GotoFunc = gotoFuc,
          }
    if DownloadData.downloadSize > 0 then
      UIManager.ShowUI(UIManager.UI_Config.Home_Download_Entrance_Popup_UIBP, uID, DownloadData)
    elseif gotoFuc and type(gotoFuc) == "function" then
      gotoFuc(DownloadData)
    else
      log(bWriteLog and "logic_home_download.CheckHomeDownloadedDone gotoFuc is not function")
      local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
      if logic_home_switch:CheckHomeLimit(true) then
        log(bWriteLog and "logic_home_download.CheckHomeDownloadedDone CheckHomeLimit")
        return
      end
      local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
      logic_home_entry:EntryVisitHome(tonumber(uID))
    end
  end)
end
function logic_home_download.GetDownloadReward()
  local isHomeVersionAwardGet = false
  local manor_visit_info = LobbySystem.roleData.manor_visit_info
  if manor_visit_info and manor_visit_info.award_time then
    isHomeVersionAwardGet = true
  end
  if isHomeVersionAwardGet then
    log(bWriteLog and "logic_home_download.GetDownloadReward has got reward")
    return {}
  end
  local logic_lobby_home_entry_item = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_lobby_home_entry_item)
  local info = logic_lobby_home_entry_item:GetShowInfo()
  log_tree(bWriteLog and "logic_home_download.GetDownloadReward info = ", info)
  if info.bShow and info.redModule == logic_lobby_home_entry_item.eRedDotModule.VersionAward then
    log(bWriteLog and "logic_home_download.GetDownloadReward VersionAward")
  else
    log(bWriteLog and "logic_home_download.GetDownloadReward not VersionAward")
    return {}
  end
  if info.cfgText.RewardID == 0 then
    log(bWriteLog and "logic_home_download.GetDownloadReward RewardID is 0")
    return {}
  end
  local rewardList = logic_lobby_home_entry_item:GetEnterHomeRewardList(info.cfgText.RewardID)
  return rewardList
end
function logic_home_download.GetDownloadSizeStr(size)
  log(bWriteLog and string.format("logic_home_download.GetDownloadSizeStr, size:%s", size))
  local PufferConst = require("client.slua.logic.download.puffer_const")
  size = size / PufferConst.MB
  if size < 0.1 then
    size = 0.1
  end
  local sizeStr = string.format("%.1f", size)
  return sizeStr
end
return logic_home_download