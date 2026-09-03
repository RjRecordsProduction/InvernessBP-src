local RecommendHandler = {
  BatchItems = {},
  BatchItemIDList = {},
  BatchPathList = {},
  AutoBatchPathList = {},
  AutoDownloadList = {},
  RecommendDownloadNewPlayerSwitch = false,
  RecommendDownloadOldPlayerSwitch = false,
  RecommendDeleteSwitch = false,
  HaveRecommendPufferPatch = false,
  HaveTryDownloadBatch = false,
  TimerPreDownloadPaks = nil,
  TimerPopUpDownload = nil,
  TimerDeletePak = nil,
  WaitDeleteMap = {},
  BattleItems = {},
  TimerDownloadBattleItems = nil,
  BattleItemsPriorityConst = 0,
  TimeLastSort = 0,
  nextPopUpTime = 0
}
local screenInput, timer
local time_ticker = require("common.time_ticker")
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
function RecommendHandler.Init()
  log(bWriteLog and string.format("RecommendHandler.Init"))
  RecommendHandler.InitBattleItemsPriorityConst()
  RecommendHandler.InitAutoDownloadTimer()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  time_ticker.AddTimerOnce(40, function()
    if PufferSwitch.CanAutoDownload() and login_module.ClientBasicCfg and login_module.ClientBasicCfg.AutoDownloadBundle100001 then
      local space = Client.GetDeviceFreeSpace()
      if 1000 < space then
        local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
        LogicPufferBundle.DownloadBundle(100001, true)
      end
    end
  end)
  if not RecommendHandler.TimerPreDownloadPaks then
    RecommendHandler.TimerPreDownloadPaks = time_ticker.AddTimerLoop(180, function()
      RecommendHandler.HaveTryDownloadBatch = false
      RecommendHandler.PreDownloadPaks()
    end, TIMER_INFINITE, 180)
  end
end
function RecommendHandler.InitAutoDownloadTimer()
  if not RecommendHandler.TimerPopUpDownload then
    RecommendHandler.TimerPopUpDownload = time_ticker.AddTimerLoop(30, function()
      RecommendHandler.AutoDownloadPaksByPriority()
    end, TIMER_INFINITE, 30)
  end
end
function RecommendHandler.Destroy()
  if screenInput then
    screenInput:Shutdown()
    screenInput = nil
  end
  if RecommendHandler.TimerDeletePak then
    time_ticker.RemoveTimer(RecommendHandler.TimerDeletePak)
    RecommendHandler.TimerDeletePak = nil
  end
  if RecommendHandler.TimerPreDownloadPaks then
    time_ticker.RemoveTimer(RecommendHandler.TimerPreDownloadPaks)
    RecommendHandler.TimerPreDownloadPaks = nil
  end
  if RecommendHandler.TimerPopUpDownload then
    time_ticker.RemoveTimer(RecommendHandler.TimerPopUpDownload)
    RecommendHandler.TimerPopUpDownload = nil
  end
  if RecommendHandler.TimerDownloadBattleItems then
    time_ticker.RemoveTimer(RecommendHandler.TimerDownloadBattleItems)
    RecommendHandler.TimerDownloadBattleItems = nil
  end
  if timer then
    time_ticker.RemoveTimer(timer)
    timer = nil
  end
end
function RecommendHandler.OnGameStateChange(eventType, eventID, vars)
  log(bWriteLog and "RecommendHandler.OnGameStateChange " .. tostring(vars.current) .. "  " .. tostring(vars.pre))
  if vars.current == GameStatus.Lobby then
    RecommendHandler.Init()
  else
    RecommendHandler.Destroy()
  end
  if vars.current == GameStatus.Lobby and vars.pre == GameStatus.Fighting then
    RecommendHandler.AutoDownloadPaksByPriority()
    time_ticker.AddTimerOnce(2, function()
      RecommendHandler.DownloadBattleItems()
    end)
  end
  if vars.current == GameStatus.Lobby and vars.pre ~= GameStatus.Fighting then
    RecommendHandler.HaveRecommendPufferPatch = false
    RecommendHandler.ResetRecommendCD()
    local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eForceRepair)
    if data and data.repairTime > 0 then
      local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
      BasicDataTLogReport:ReportImmediate(TLogEventDefine.Repair, 0, tostring(data.repairTime))
      data.repairTime = 0
      PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eForceRepair)
    end
    time_ticker.AddTimerOnce(2, function()
      RecommendHandler.ReqBatchDownload()
      RecommendHandler.ReqAutoDownloadCfg()
      RecommendHandler.ReqAutoDownloadDiffMap()
    end)
  end
end
function RecommendHandler.OnUCChange(uc1, uc2)
  if 0 < uc1 and uc1 ~= uc2 then
    local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRecommendDownload)
    data = data or {}
    local TimeUtil = require("client.common.time_util")
    data.nLastPay = TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "RecommendHandler.OnUCChange nLastPay = " .. data.nLastPay)
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eRecommendDownload)
  end
end
function RecommendHandler.OnMatchSuccess(sub_mode)
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local mapkey = MatchModeMgrSystem.GetMapKeyBySubMode(sub_mode)
  if mapkey then
    local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRecommendDownload)
    data = data or {}
    if not data.lastPlayMap then
      data.lastPlayMap = {}
    end
    local TimeUtil = require("client.common.time_util")
    data.lastPlayMap[mapkey] = TimeUtil.GetServerTimeInSec()
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eRecommendDownload)
  end
end
function RecommendHandler.InitBattleItemsPriorityConst()
  local version = Client.GetApplicationVersion()
  local StringUtil = require("common.string_util")
  local ret = StringUtil.Split(version, ".")
  local v1, v2 = ret[1], ret[2]
  RecommendHandler.BattleItemsPriorityConst = (tonumber(v1) * 1000 + tonumber(v2) * 100) / 3
  log(bWriteLog and "RecommendHandler.InitBattleItemsPriorityConst BattleItemsPriorityConst = " .. tostring(RecommendHandler.BattleItemsPriorityConst))
end
function RecommendHandler.AddBattleItem(itemID)
  if not itemID or itemID == 0 then
    return
  end
  local count = RecommendHandler.BattleItems[itemID]
  if not count then
    count = 1
  else
    count = count + 1
  end
  RecommendHandler.BattleItems[itemID] = count
  log(bWriteLog and string.format("RecommendHandler.AddBattleItem itemID:%s times:%s", tostring(itemID), tostring(count)))
end
function RecommendHandler.DownloadBattleItems()
  log(bWriteLog and "RecommendHandler.DownloadBattleItems")
  if not RecommendHandler.BattleItems or not next(RecommendHandler.BattleItems) then
    log(bWriteLog and "RecommendHandler.DownloadBattleItems BattleItems empty")
    return
  end
  if RecommendHandler.TimerDownloadBattleItems then
    return
  end
  RecommendHandler.TimerDownloadBattleItems = time_ticker.AddTimerLoop(0, function()
    local retItemID = 0
    local maxPriority = 0
    if not RecommendHandler.BattleItems or not next(RecommendHandler.BattleItems) then
      return
    end
    for itemID, v in pairs(RecommendHandler.BattleItems) do
      local priority = RecommendHandler.GetDownloadPriority(itemID, v)
      if maxPriority <= priority then
        maxPriority = priority
        retItemID = itemID
      end
    end
    if 0 < retItemID then
      RecommendHandler.BattleItems[retItemID] = nil
      local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
      local extraData = {bAutoDownload = true}
      log(bWriteLog and "RecommendHandler.DownloadBattleItems itemID = " .. tostring(retItemID))
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {retItemID}, PufferTlog.Enum_TLog_From.Battle, nil, extraData)
    end
  end, TIMER_INFINITE, 2)
end
function RecommendHandler.GetDownloadPriority(itemID, recordTime)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if not itemCfg then
    log(bWriteLog and "RecommendHandler.GetDownloadPriority itemID = " .. tostring(itemID))
    return 0
  end
  if not recordTime then
    return 0
  end
  local quality = itemCfg.ItemQuality or 0
  local version = itemCfg.ResSeprateType or 0
  return quality * version + recordTime * RecommendHandler.BattleItemsPriorityConst
end
function RecommendHandler.ResetRecommendCD()
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRecommendDownload)
  data = data or {}
  data.nLastTrigger = 0
  data.haveShow = {}
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eRecommendDownload)
end
function RecommendHandler.ReqAutoDownloadCfg()
  log(bWriteLog and string.format("RecommendHandler.ReqAutoDownloadCfg"))
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.client_auto_download_cfg, RecommendHandler.ReqAutoDownloadCfgCallBack)
end
function RecommendHandler.ReqAutoDownloadCfgCallBack(tableName, data)
  log(bWriteLog and string.format("RecommendHandler.ReqAutoDownloadCfgCallBack"))
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  data = BasicDataServerTable:GetCacheData(data_config_marco.client_auto_download_cfg)
  RecommendHandler.InitAutoDownloadCfg(data)
end
function RecommendHandler.InitAutoDownloadCfg(data)
  if not data then
    return
  end
  RecommendHandler.AutoDownloadList = {}
  local newbeeTime = 604800
  local TimeUtil = require("client.common.time_util")
  local time = TimeUtil.GetServerTimeInSec() - DataMgr.registertime
  log(bWriteLog and string.format("RecommendHandler.InitAutoDownloadCfg registertime:%s", tostring(DataMgr.registertime)))
  local isNewbie = false
  if newbeeTime > time then
    isNewbie = true
  end
  local space = Client.GetDeviceFreeSpace()
  for key, v in pairs(data) do
    local pak = {}
    local keyList = {}
    local StringUtil = require("common.string_util")
    for _, id in pairs(StringUtil.Split(key, "|")) do
      if tonumber(id) then
        table.insert(keyList, tonumber(id))
      else
        table.insert(keyList, id)
      end
    end
    pak.    pak.pakType = v.resource_type
    pak.    if isNewbie then
      if space < 3000 then
        pak.downloadPriority = v.newbie_download_priority
      else
        pak.downloadPriority = v.newbie_left_capacity
      end
    elseif space < 3000 then
      pak.downloadPriority = v.old_user_download_priority
    else
      pak.downloadPriority = v.old_user_left_capacity
    end
    log(bWriteLog and string.format("RecommendHandler.InitAutoDownloadCfg key:%s downloadPriority:%s resource_name:%s", key, tostring(pak.downloadPriority), v.resource_name))
    if pak.downloadPriority > 0 then
      pak.levelCond = v.level_cond
      pak.needPopUP = v.is_notify == 1 or false
      pak.name = LocUtil.LocalizeResFormat(v.resource_name)
      table.insert(RecommendHandler.AutoDownloadList, pak)
    end
  end
  table.sort(RecommendHandler.AutoDownloadList, function(a, b)
    return a.downloadPriority > b.downloadPriority
  end)
  log(bWriteLog and "RecommendHandler.InitAutoDownloadCfg")
  RecommendHandler.nextPopUpTime = 0
  local popData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePopUpDownload)
  if popData and popData.nextPopUpTime then
    RecommendHandler.nextPopUpTime = popData.nextPopUpTime
  end
  RecommendHandler.AutoDownloadPaksByPriority()
end
function RecommendHandler.AutoDownloadPaksByPriority()
  if PufferSwitch.BanAutoDownload then
    return
  end
  if not Client.IsJaguar() then
    return
  end
  if FuncUtil.GetServerTimeInSec() < RecommendHandler.nextPopUpTime then
    log(bWriteLog and string.format("RecommendHandler.AutoDownloadPaksByPriority not next day:%s", RecommendHandler.nextPopUpTime))
    return
  end
  if not PufferDownloader.PufferJsonDownloadReturn then
    log(bWriteLog and "RecommendHandler.AutoDownloadPaksByPriority PufferJsonDownloadReturn = false")
    return
  end
  if not next(RecommendHandler.AutoDownloadList) then
    log(bWriteLog and "RecommendHandler.AutoDownloadPaksByPriority AutoDownloadList empty")
    return
  end
  if not DataMgr.roleData then
    log(bWriteLog and string.format("RecommendHandler.AutoDownloadPaksByPriority roleData nil"))
    return
  end
  local level = DataMgr.roleData.level
  log(bWriteLog and string.format("RecommendHandler.AutoDownloadPaksByPriority level:%s", level))
  for _, v in pairs(RecommendHandler.AutoDownloadList) do
    if not v.isNewbie or level >= v.levelCond then
      local state = PufferManager.GetState(v.pakType, v.keyList)
      if state == PufferConst.ENUM_DownloadState.Download then
        log(bWriteLog and "RecommendHandler.AutoDownloadPaksByPriority downloading key = " .. tostring(v.keyList[1]))
        return
      elseif state ~= PufferConst.ENUM_DownloadState.Done then
        if PufferSwitch.CanAutoDownload() then
          log(bWriteLog and "RecommendHandler.AutoDownloadPaksByPriority Download key " .. tostring(v.keyList[1]))
          local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
          PufferManager.Download(v.pakType, v.keyList, PufferTlog.Enum_TLog_From.AutoDownloadCfg)
          return
        elseif v.needPopUP and v.isNewbie then
          v.needPopUP = false
          local desc = ""
          if v.resource_type == PufferConst.ENUM_DownloadType.MAP then
            local mapCfg = CDataTable.GetTableData("MapPakTable", v.keyList[1])
            if mapCfg then
              v.name = mapCfg.name
              desc = mapCfg.mapDesc
            end
          elseif v.resource_type == PufferConst.ENUM_DownloadType.RES then
            local resCfg = CDataTable.GetTableData("ResPakTable", v.keyList[1])
            if resCfg then
              v.name = resCfg.ResName
              desc = resCfg.ResDesc
            end
          else
            desc = LocUtil.LocalizeResFormat(7416)
          end
          RecommendHandler.PopUpDownloadPak(v.keyList[1], v.name, desc, v.pakType)
          return
        end
      end
    end
  end
end
function RecommendHandler.PopUpDownloadPak(key, name, desc, pakType)
  log(bWriteLog and string.format("RecommendHandler.PopUpDownloadPak key:%s, resource_type:%s", key, pakType))
  local path = ""
  if pakType == PufferConst.ENUM_DownloadType.ODPAK then
    path = "/Game/UMG/Texture_200/Atlas/Download/Frames/DL_Icon_Resource_png.DL_Icon_Resource_png"
  elseif pakType == PufferConst.ENUM_DownloadType.MAP then
    path = "/Game/UMG/Texture_200/Atlas/Download/Frames/DL_Icon_Classic_png.DL_Icon_Classic_png"
  else
    path = "/Game/UMG/Texture_200/Atlas/Download/Frames/DL_Icon_Recommend_png.DL_Icon_Recommend_png"
  end
  local jumpInfo = {}
  jumpInfo.texturePath = "/Game/UMG/Texture/Lobby_NoAtlas/UnknowPass/Koi/Koi_Tips_icon_Chicken.Koi_Tips_icon_Chicken"
  function jumpInfo.callback()
    local info = {key = key}
    UIManager.ShowUI(UIManager.UI_Config.Download_Main_UIBP, info)
  end
  function jumpInfo.cancelCallback()
    local TimeUtil = require("client.common.time_util")
    local time = TimeUtil.GetTodayStartTimestamp() + 86400
    local data = {}
    data.nextPopUpTime = time
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.ePopUpDownload)
    RecommendHandler.nextPopUpTime = time
  end
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  RightPopSystem.CommonPopupDownload(name, desc, path, jumpInfo, 10)
end
function RecommendHandler.AskDownloadBankPack()
  log(bWriteLog and "RecommendHandler.AskDownloadBankPack")
  if not GlobalData.IsJapanOrKorea() then
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  if not PufferDownloader.PufferJsonDownloadReturn then
    return
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.ClientBasicCfg and not login_module.ClientBasicCfg.AskDownloadBankPackSwitch then
    log(bWriteLog and "RecommendHandler.AskDownloadBankPack() switch off")
    return
  end
  if RecommendHandler.HaveShowBankDownload then
    return
  end
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPACK, {
    PufferConst.EODPackID.Audio
  })
  if state == PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "RecommendHandler.AskDownloadBankPack AudioPack is done")
    return
  end
  local title = LocUtil.GetLocalizeResStr(7385)
  local content
  if Client.HasActiveWifi() then
    content = LocUtil.GetLocalizeResStr(11688)
  else
    content = LocUtil.GetLocalizeResStr(11689)
  end
  local clickOkCallback = function()
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPACK, {
      PufferConst.EODPackID.Audio
    }, PufferTlog.Enum_TLog_From.JKBankPak)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, content, clickOkCallback)
  RecommendHandler.HaveShowBankDownload = true
end
function RecommendHandler.AutoDownload()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.ClientBasicCfg and PufferDownloader.PufferJsonDownloadReturn then
    log(bWriteLog and "PufferDownloader.RecommendHandler AutoDownload")
    time_ticker.AddTimerOnce(4, function()
      RecommendHandler.DownloadEquipment()
      local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
      NewFaceSlapSystem:ShowFaceSlapByID(BP_ENUM_MODULE_DOWNLOAD_VOICE_BANK)
    end)
    time_ticker.AddTimerOnce(10, function()
      if PufferSwitch.BanAutoDownload then
        return
      end
      local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
      if PufferDeleteManager.IsGameSizeNeedAlert() then
        log(bWriteLog and "RecommendHandler.AutoDownload() IsGameSizeNeedAlert")
        return
      end
      if PufferDeleteManager.IsShowDeleteUI() then
        log(bWriteLog and "RecommendHandler.AutoDownload() IsShowDeleteUI")
        return
      end
      local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
      PufferResManager:AutoDownloadPufferPatch()
      if login_module.ClientBasicCfg and PufferSwitch.GetMapsAutoDownloadAllSwitch() then
        local map1 = login_module.ClientBasicCfg.AutoDownloadMaps1
        local map2 = login_module.ClientBasicCfg.AutoDownloadMaps2
        local maps = {}
        if map1 and map1 ~= "" then
          table.insert(maps, map1)
        end
        if map2 and map2 ~= "" then
          table.insert(maps, map2)
        end
        if next(maps) then
          local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
          if logic_mode_selection:GetViewDictionary() then
            for k, v in pairs(maps) do
              if not logic_mode_selection:CheckMapKeyNeedDownload(v) then
                log(bWriteLog and string.format("RecommendHandler.AutoDownload skip:%s", v))
                maps[k] = nil
              end
            end
          end
          local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
          for k, v in pairs(maps) do
            if PufferMapManager:HaveDeleted(v) then
              log(bWriteLog and string.format("RecommendHandler.AutoDownload map have been deleted skip:%s", v))
              maps[k] = nil
            end
          end
          local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
          local extraData = {bAutoDownload = true}
          PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, maps, PufferTlog.Enum_TLog_From.Auto, nil, extraData)
        end
      end
      local extra = {bAutoDownload = true}
      PufferManager.Download(PufferConst.ENUM_DownloadType.RES, {
        "res_maptexmd"
      }, nil, nil, extra)
      RecommendHandler.PreDownloadPaks()
      RecommendHandler.AutoDownloadHLOD()
      local logic_language_download = require("client.slua.logic.download.recommend.logic_language_download")
      logic_language_download.AutoDownloadCurrentLanguage()
      local smart_download_monitor = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.smart_download_monitor)
      smart_download_monitor:RecoverSmartDownloadQueue(extra)
    end)
  end
end
function RecommendHandler.AutoDownloadHLOD()
  if PufferSwitch.CanAutoDownload() then
    local params = {bSkipPopUp = true}
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPACK, {
      PufferConst.EODPackID.HLOD
    }, nil, nil, params)
  end
end
function RecommendHandler.ReqAutoDownloadDiffMap()
  log_format("RecommendHandler.ReqAutoDownloadDiffMap")
  local VersionUtil = require("client.common.version_util")
  local curVersion = VersionUtil.GetCurVersionNumber()
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDownloadDiffMapInfo) or {}
  log_tree("RecommendHandler.ReqAutoDownloadDiffMap. data = ", data)
  if data.version == curVersion then
    log_format("RecommendHandler.ReqAutoDownloadDiffMap. version is same, return")
    return
  end
  data.version = curVersion
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eDownloadDiffMapInfo)
  if not PufferSwitch.CanAutoDownload() then
    log_format("RecommendHandler.ReqAutoDownloadDiffMap. CanAutoDownload return")
    return
  end
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local diffMaps = {}
  for mapKey, mapData in pairs(PufferMapManager.MapPaks) do
    if mapData.isDiff then
      table.insert(diffMaps, mapKey)
    end
  end
  log_tree("RecommendHandler.ReqAutoDownloadDiffMap. diffMaps = ", diffMaps)
  if next(diffMaps) then
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    local params = {bSkipPopUp = true}
    PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, diffMaps, PufferTlog.Enum_TLog_From.Auto, nil, params)
  end
  log_format("RecommendHandler.ReqAutoDownloadDiffMap. end")
end
function RecommendHandler.ReqBatchDownload()
  log(bWriteLog and string.format("RecommendHandler.ReqBatchDownload"))
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.brd_table_new, RecommendHandler.BatchDownloadCallBack)
end
function RecommendHandler.BatchDownloadCallBack(tableName, data)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  data = BasicDataServerTable:GetCacheData(data_config_marco.brd_table_new)
  if not data then
    return
  end
  log(bWriteLog and string.format("RecommendHandler.BatchDownloadCallBack"))
  RecommendHandler.PaksDownloadTime = {}
  RecommendHandler.BatchItemIDList = {}
  RecommendHandler.AutoBatchPathList = {}
  RecommendHandler.AutoResList = {}
  RecommendHandler.ForceDownloadList = {}
  local videoPre = "RP_PRIME_"
  local language = Client.GetCurrentLanguage()
  local videoName = videoPre .. language
  local preVersion = DataMgr.GetPreVersion(Client.GetApplicationVersion())
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local beginTimeMap = {}
  local forceDownloadList = {}
  for i, v in pairs(data) do
    local itemID = tonumber(i)
    local begin_time = v.begin_time
    if begin_time and 0 < begin_time then
      if itemID then
        RecommendHandler.PaksDownloadTime[itemID] = begin_time
      else
        RecommendHandler.PaksDownloadTime[i] = begin_time
        local pakName = PufferManager.GetPakName(i)
        if pakName ~= "" then
          RecommendHandler.PaksDownloadTime[pakName] = begin_time
        end
      end
    end
    local path = i
    if not itemID and not string.find(i, "/Game/") then
      path = DataMgr.GetVideoDownloadPath(i)
    end
    if (preVersion == v.version or v.version == "") and 0 < begin_time and curTime > begin_time and curTime < v.end_time then
      if v.force == 1 then
        if itemID then
          table.insert(forceDownloadList, itemID)
        elseif string.find(i, "res_") then
        else
          table.insert(forceDownloadList, path)
        end
      else
        if itemID then
          RecommendHandler.BatchItemIDList[itemID] = begin_time
        elseif string.find(i, "res_") then
          table.insert(RecommendHandler.AutoResList, i)
        else
          local ODPakName = PufferManager.GetPakName(path)
          if ODPakName ~= "" then
            if string.find(i, videoPre) then
              if string.find(i, videoName) then
                RecommendHandler.AutoBatchPathList[i] = v
              end
            else
              RecommendHandler.AutoBatchPathList[i] = v
            end
          end
        end
        beginTimeMap[begin_time] = 1
      end
    end
  end
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  for begin_time, v in pairs(beginTimeMap) do
    local date = TimeUtil.GetDateByUnixTime(begin_time)
    local packID = date.year * 10000 + date.month * 100 + date.day
    local pakNames = PufferODPakManager:GetPakNamesByODPakID(packID)
    if pakNames and next(pakNames) then
      log(bWriteLog and "RecommendHandler.BatchDownloadCallBack. packID = " .. tostring(packID))
      for packPakName, _ in pairs(pakNames) do
        RecommendHandler.BatchItemIDList[packPakName] = begin_time
      end
    end
  end
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  log_tree("RecommendHandler.BatchDownloadCallBack. forceDownloadList = ", forceDownloadList)
  if next(forceDownloadList) then
    if PufferDownloader.InitSuccess then
      time_ticker.AddTimerOnce(2, function()
        printf("RecommendHandler.BatchDownloadCallBack. delay download forceDownloadList")
        PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, forceDownloadList, PufferTlog.Enum_TLog_From.Auto)
      end)
    else
      RecommendHandler.ForceDownloadList = forceDownloadList
      EventSystem:registEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_JSON_POSTPROCESS, RecommendHandler.OnPufferInited)
      printf("RecommendHandler.BatchDownloadCallBack. regist event")
    end
  end
  RecommendHandler.PreDownloadPaks()
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  LogicPufferBundle.InitBundle()
end
function RecommendHandler.OnPufferInited()
  printf("RecommendHandler.OnPufferInited.")
  if RecommendHandler.ForceDownloadList and next(RecommendHandler.ForceDownloadList) then
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, RecommendHandler.ForceDownloadList, PufferTlog.Enum_TLog_From.Auto)
    RecommendHandler.ForceDownloadList = nil
  end
  EventSystem:unregistEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_JSON_POSTPROCESS)
end
function RecommendHandler.PreDownloadPaks()
  log(bWriteLog and "RecommendHandler.PreDownloadPaks 1")
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if not login_module.ClientBasicCfg or not PufferDownloader.PufferJsonDownloadReturn then
    log(bWriteLog and "RecommendHandler.PreDownloadPaks return 1")
    return
  end
  if RecommendHandler.HaveTryDownloadBatch or PufferSwitch.GetPreDownloadBatchSwitch() == false then
    log(bWriteLog and "RecommendHandler.PreDownloadPaks HaveTryDownloadBatch = " .. tostring(RecommendHandler.HaveTryDownloadBatch))
    log(bWriteLog and "RecommendHandler.PreDownloadPaks GetPreDownloadBatchSwitch = " .. tostring(PufferSwitch.GetPreDownloadBatchSwitch()))
    return
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local data = BasicDataServerTable:GetCacheData(data_config_marco.brd_table_new)
  if not data then
    log(bWriteLog and "RecommendHandler.PreDownloadPaks data = nil")
    return
  end
  if not PufferSwitch.CanAutoDownload() then
    log(bWriteLog and "RecommendHandler.PreDownloadPaks. autodownload return")
    return
  end
  local paths = {}
  for path, v in pairs(RecommendHandler.AutoBatchPathList) do
    v.    table.insert(paths, v)
  end
  if 1 < #paths then
    local TimeUtil = require("client.common.time_util")
    table.sort(paths, function(a, b)
      local timeA = a.begin_time - TimeUtil.GetServerTimeInSec()
      local timeB = b.begin_time - TimeUtil.GetServerTimeInSec()
      if 0 <= timeA and 0 <= timeB then
        return timeA > timeB
      end
      if 0 <= timeA and timeB < 0 then
        return false
      end
      if timeA < 0 and 0 <= timeB then
        return true
      end
      if timeA < 0 and timeB < 0 then
        return timeA < timeB
      end
    end)
  end
  local downloadPathLimit = 2
  local downloadNum = 0
  local downloadList = {}
  for _, v in pairs(paths) do
    local path = v.path
    if path then
      local keyList = {path}
      local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, keyList)
      if state ~= PufferConst.ENUM_DownloadState.Done then
        table.insert(downloadList, path)
        downloadNum = downloadNum + 1
        if downloadPathLimit <= downloadNum then
          break
        end
      else
        RecommendHandler.AutoBatchPathList[path] = nil
      end
    end
  end
  local items = {}
  local itemList = {}
  local cnt = 0
  for i, v in pairs(RecommendHandler.BatchItemIDList) do
    local dowloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {i})
    if dowloadState ~= PufferConst.ENUM_DownloadState.Done then
      items[i] = v
      table.insert(itemList, i)
      cnt = cnt + 1
      if 4 <= cnt then
        break
      end
    else
      RecommendHandler.BatchItemIDList[i] = nil
    end
  end
  log_tree("RecommendHandler.PreDownloadPaks itemList = ", items)
  if next(downloadList) or next(items) or RecommendHandler.AutoResList and next(RecommendHandler.AutoResList) then
    RecommendHandler.HaveTryDownloadBatch = true
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, downloadList, PufferTlog.Enum_TLog_From.PreDownload)
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, itemList, PufferTlog.Enum_TLog_From.PreDownload)
    PufferManager.Download(PufferConst.ENUM_DownloadType.RES, RecommendHandler.AutoResList)
  end
end
function RecommendHandler.DownloadEquipment()
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  HallThemeUtils.UpdateThemeVehicleShow()
  local vehicleID = HallThemeUtils.GetThemeVehicleItemId()
  log(bWriteLog and "RecommendHandler.DownloadEquipment vehicleID = " .. tostring(vehicleID))
  if 0 < vehicleID then
    local callback = function()
      HallThemeUtils.ShowThemeVehicle()
    end
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {vehicleID}, nil, callback)
  end
  local tAllNeedDownloadRes = {}
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local bag_pendants = fashionbag_data:GetBagPendants()
  for k, v in pairs(bag_pendants) do
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(k)
    if itemData then
      table.insert(tAllNeedDownloadRes, itemData.resID)
    end
  end
  local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
  local bagInfo = fashionbag_data:GetKnapsackExtInfoByIndex(nUseWearBagIndex)
  if bagInfo ~= nil then
    local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    local originalResID = wardrobeLogic:GetItemResId(bagInfo.helmet_skin)
    local helmetSkinResID = DataMgr.GetEquipmentItemIDByResID(bagInfo.helmet_level, originalResID)
    log(bWriteLog and "RecommendHandler.DownloadEquipment originalResID = " .. tostring(originalResID) .. " helmetSkinResID = " .. tostring(helmetSkinResID))
    local helmetItemInfo = wardrobe_data:GetHallDepotItemDataByResID(originalResID)
    if helmetItemInfo ~= nil then
      table.insert(tAllNeedDownloadRes, originalResID)
    end
    originalResID = wardrobeLogic:GetItemResId(bagInfo.bag_skin)
    local bagSkinResID = DataMgr.GetEquipmentItemIDByResID(bagInfo.bag_level, originalResID)
    log(bWriteLog and "RecommendHandler.DownloadEquipment originalResID = " .. tostring(originalResID) .. " bagSkinResId = " .. tostring(bagSkinResID))
    local bagItemInfo = wardrobe_data:GetHallDepotItemDataByResID(originalResID)
    if bagItemInfo ~= nil then
      table.insert(tAllNeedDownloadRes, originalResID)
    end
  end
  local nWeaponItemId = DataMgr.GetCurrentWeaponID()
  if nWeaponItemId and 0 < nWeaponItemId then
    table.insert(tAllNeedDownloadRes, nWeaponItemId)
  end
  if DataMgr.Extra_Weapon_Info_List then
    for _, v in pairs(DataMgr.Extra_Weapon_Info_List) do
      local nExtraWeaponItemId = DataMgr.GerExtraWeaponID(v.weapon_id, v.skin_id, v.is_using_recommend, v.cur_use_plan)
      if nExtraWeaponItemId and 0 < nExtraWeaponItemId then
        table.insert(tAllNeedDownloadRes, nExtraWeaponItemId)
      end
    end
  end
  local WearInfo = AvatarData.GetWearInfo()
  for _, v in pairs(WearInfo) do
    local nItemId = v.ItemID
    if nItemId then
      log(bWriteLog and "RecommendHandler.DownloadEquipment wear = " .. tostring(nItemId))
      table.insert(tAllNeedDownloadRes, nItemId)
    end
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_PLAYER_MODE_DOWNLOAD_UI, tAllNeedDownloadRes)
end
return RecommendHandler