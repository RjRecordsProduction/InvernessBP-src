local Logic_UGC_Res_Manager = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local TableUtil = require("common.table_util")
local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
Logic_UGC_Res_Manager.DownloaderType = UGCMacros.ENUM_DownloaderType
local DownloadUIType = {
  RBottom = 1,
  LoadBtn = 2,
  TeamLoadBtn = 3,
  DetailLoadBtn = 4,
  LoadMapUI = 5,
  UGCLoadMapUI = 6,
  UpdateMod = 7,
  EditPubMod = 8,
  EditModBtn = 9
}
Logic_UGC_Res_Manager.local TLogKey = {
  ClickDownload = "ClickDownload",
  ClickPause = "ClickPause",
  ClickContinue = "ClickContinue",
  LoadFinish = "LoadFinish",
  ReportWoWResSize = "ReportWoWResSize",
  DeleteMarkWoW = "DeleteMarkWoW",
  SureDeleteWoWRes = "SureDeleteWoWRes",
  InitDownload = "InitDownload"
}
Logic_UGC_Res_Manager.
function Logic_UGC_Res_Manager:OnInitialize()
  Logic_UGC_Res_Manager.__super.OnInitialize(self)
  self.modResCaches = {}
  self.modStateCaches = {}
  self.UGCAssetConfig = CDataTable.GetTable("UGCAssetConfig") or {}
  self.UGCAssetConfigIDMap = {}
  self.AssetIDIn20W = {}
  for k, v in pairs(self.UGCAssetConfig) do
    if v.ResSeprateType == PufferConst.EODPackID.WOW_20W then
      self.AssetIDIn20W[v.AssetID] = 1
    end
    if v.ID then
      self.UGCAssetConfigIDMap[v.ID] = v
    end
  end
  self.bOptimizeMapDownload = false
  self.bResListMinDepends = true
  self._trackingMods = {}
  log(bWriteLog and "Logic_UGC_Res_Manager:OnInitialize = " .. tostring(self.bResListMinDepends))
end
function Logic_UGC_Res_Manager:RegistEvents()
  Logic_UGC_Res_Manager.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self._OnPufferDownloadFinish, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_JSON_POSTPROCESS, self._OnPufferJsonPostProcess, self)
end
function Logic_UGC_Res_Manager:_OnPufferDownloadFinish()
  if not self._trackingMods then
    return
  end
  local completedMods = {}
  local expiredModIds = {}
  for modId, modInfo in pairs(self._trackingMods) do
    local state = self:GetResState(self.DownloaderType.ModCopy, modInfo)
    if state == PufferConst.ENUM_DownloadState.Done then
      completedMods[modId] = modInfo
    elseif state == PufferConst.ENUM_DownloadState.Error or state == PufferConst.ENUM_DownloadState.Not then
      expiredModIds[modId] = true
    end
  end
  for modId, modInfo in pairs(completedMods) do
    self._trackingMods[modId] = nil
    log(bWriteLog and "Logic_UGC_Res_Manager:_OnPufferDownloadFinish complete mod_id = " .. tostring(modId))
    self:_ShowDownloadCompleteTip(modInfo)
  end
  for modId, _ in pairs(expiredModIds) do
    self._trackingMods[modId] = nil
    log(bWriteLog and "Logic_UGC_Res_Manager:_OnPufferDownloadFinish expired mod_id = " .. tostring(modId))
  end
end
function Logic_UGC_Res_Manager:_ShowDownloadCompleteTip(modInfo)
  local DISPLAY_SECONDS = 10
  UIManager.ShowUI(UIManager.UI_Config.Common_RightBottom_Tip_Download_WOW, modInfo, DISPLAY_SECONDS)
end
function Logic_UGC_Res_Manager:ClearData()
  self.modResCaches = {}
  self.modStateCaches = {}
  self.localModList = nil
  self:_RemoveReportResTimer()
end
function Logic_UGC_Res_Manager:OnLogOut()
  self._trackingMods = {}
  self.bLoginReady = false
  self.bPufferReady = false
  self.bHasReportedResBitmap = false
  self:_RemoveReportUGCResBitmapTimers()
  self:ClearData()
end
function Logic_UGC_Res_Manager:OnPreSwitchGameStatus(preState, nextState)
  print(bWriteLog and "Logic_UGC_Res_Manager:OnPreSwitchGameStatus")
  if nextState == GameStatus.Lobby and preState == GameStatus.Fighting then
    print(bWriteLog and "Logic_UGC_Res_Manager:OnPreSwitchGameStatus preState is fighting,next is lobby,  Clear Cache Infos")
    self:ClearCacheInfos()
  end
  if not IsWoWEditor and not IsEditor and nextState == GameStatus.Fighting and not self.bHasReportedResBitmap then
    self:_FlushReportUGCResBitmapImmediate("OnPreSwitchGameStatus->Fighting")
  end
  self:_RemoveReportResTimer()
end
function Logic_UGC_Res_Manager:OnPostSwitchGameStatus(preState, nextState)
  if IsWoWEditor or IsEditor then
    return
  end
  print(bWriteLog and "Logic_UGC_Res_Manager.OnPostSwitchGameStatus")
  if preState == GameStatus.Login and nextState == GameStatus.Lobby then
    self.bLoginReady = true
    self:_TryReportUGCResBitmap("OnLoginSuccess")
  end
end
function Logic_UGC_Res_Manager:_OnPufferJsonPostProcess()
  if IsWoWEditor or IsEditor then
    return
  end
  self.bPufferReady = true
  self:_TryReportUGCResBitmap("OnPufferJsonPostProcess")
end
local REPORT_UGC_RES_BITMAP_DELAY_SEC = 15
local REPORT_UGC_RES_BITMAP_STEP_BUDGET_MS = 30
function Logic_UGC_Res_Manager:_TryReportUGCResBitmap(sTrigger)
  if IsWoWEditor or IsEditor then
    return
  end
  if self.bHasReportedResBitmap then
    return
  end
  if not self.bLoginReady then
    print(bWriteLog and string.format("Logic_UGC_Res_Manager:_TryReportUGCResBitmap wait login, trigger=%s", tostring(sTrigger)))
    return
  end
  if not self.bPufferReady then
    local PufferDownloader = _G.PufferDownloader
    if not PufferDownloader or not PufferDownloader.PufferJsonDownloadReturn then
      print(bWriteLog and string.format("Logic_UGC_Res_Manager:_TryReportUGCResBitmap wait puffer, trigger=%s", tostring(sTrigger)))
      return
    end
    self.bPufferReady = true
  end
  print(bWriteLog and string.format("Logic_UGC_Res_Manager:_TryReportUGCResBitmap schedule, trigger=%s", tostring(sTrigger)))
  self:_ScheduleReportUGCResBitmap(sTrigger)
end
function Logic_UGC_Res_Manager:_ScheduleReportUGCResBitmap(sTrigger)
  if self.bHasReportedResBitmap then
    return
  end
  if self.ReportUGCResBitmapDelayTimer or self.StepReportUGCResBitmapTimer then
    return
  end
  print(bWriteLog and string.format("Logic_UGC_Res_Manager:_ScheduleReportUGCResBitmap delay=%ss trigger=%s", tostring(REPORT_UGC_RES_BITMAP_DELAY_SEC), tostring(sTrigger)))
  self.ReportUGCResBitmapDelayTimer = self:AddTimer(REPORT_UGC_RES_BITMAP_DELAY_SEC, function()
    self.ReportUGCResBitmapDelayTimer = nil
    self:_StartStepReportUGCResBitmap(sTrigger)
  end)
end
function Logic_UGC_Res_Manager:_StartStepReportUGCResBitmap(sTrigger)
  if self.bHasReportedResBitmap then
    return
  end
  if self.StepReportUGCResBitmapTimer then
    self:RemoveTimer(self.StepReportUGCResBitmapTimer)
    self.StepReportUGCResBitmapTimer = nil
  end
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  if not PufferUGCPakManager then
    print(bWriteLog and "Logic_UGC_Res_Manager:_StartStepReportUGCResBitmap skip: PufferUGCPakManager nil")
    return
  end
  if not self.UGCAssetConfigIDMap or next(self.UGCAssetConfigIDMap) == nil then
    print(bWriteLog and "Logic_UGC_Res_Manager:_StartStepReportUGCResBitmap skip: UGCAssetConfigIDMap empty")
    return
  end
  local AssetList = {}
  for _, cfg in pairs(self.UGCAssetConfigIDMap) do
    local assetID = cfg and cfg.AssetID
    if assetID and 0 < assetID then
      table.insert(AssetList, assetID)
    end
  end
  local ctx = {
    AssetList = AssetList,
    Index = 0,
    DownloadedMap = {},
    Total = 0,
    Done = 0,
    Trigger = sTrigger
  }
  self._ReportBitmapCtx = ctx
  local time_ticker = require("common.time_ticker")
  self.StepReportUGCResBitmapTimer = self:AddTimer(0, function()
    local StepStartTime = slua.getMiliseconds()
    local list = ctx.AssetList
    local count = #list
    local i = ctx.Index + 1
    while count >= i do
      if ctx.Aborted or self.bHasReportedResBitmap or self._ReportBitmapCtx ~= ctx then
        return
      end
      local puffer_ugcpak_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
      if not puffer_ugcpak_manager then
        self.StepReportUGCResBitmapTimer = nil
        self._ReportBitmapCtx = nil
        return
      end
      local assetID = list[i]
      ctx.Total = ctx.Total + 1
      if puffer_ugcpak_manager:GetStateByAssetID(assetID) == PufferConst.ENUM_DownloadState.Done then
        ctx.DownloadedMap[assetID] = true
        ctx.Done = ctx.Done + 1
      end
      ctx.Index = i
      i = i + 1
      local StepEndTime = slua.getMiliseconds()
      if StepEndTime - StepStartTime > REPORT_UGC_RES_BITMAP_STEP_BUDGET_MS and count >= i then
        print(bWriteLog and "Logic_UGC_Res_Manager getAssetState STEP before yield, index= ", ctx.Index)
        coroutine.yield(time_ticker.MINIMUM_STEP_TIME)
        print(bWriteLog and "Logic_UGC_Res_Manager getAssetState STEP after yield, index= ", ctx.Index, "aborted=", ctx.Aborted)
        StepStartTime = slua.getMiliseconds()
      end
    end
    self.StepReportUGCResBitmapTimer = nil
    self:_DoReportUGCResBitmap(ctx)
  end)
end
function Logic_UGC_Res_Manager:_FlushReportUGCResBitmapImmediate(sTrigger)
  if self.bHasReportedResBitmap then
    return
  end
  local bHasDelay = self.ReportUGCResBitmapDelayTimer ~= nil
  local bHasStep = self.StepReportUGCResBitmapTimer ~= nil
  if not bHasDelay and not bHasStep then
    return
  end
  print(bWriteLog and string.format("Logic_UGC_Res_Manager:_FlushReportUGCResBitmapImmediate flush, trigger=%s bDelay=%s bStep=%s", tostring(sTrigger), tostring(bHasDelay), tostring(bHasStep)))
  if self.ReportUGCResBitmapDelayTimer then
    self:RemoveTimer(self.ReportUGCResBitmapDelayTimer)
    self.ReportUGCResBitmapDelayTimer = nil
  end
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  if not PufferUGCPakManager then
    if self._ReportBitmapCtx then
      self._ReportBitmapCtx.Aborted = true
    end
    self.StepReportUGCResBitmapTimer = nil
    self._ReportBitmapCtx = nil
    return
  end
  if not self.UGCAssetConfigIDMap or next(self.UGCAssetConfigIDMap) == nil then
    if self._ReportBitmapCtx then
      self._ReportBitmapCtx.Aborted = true
    end
    self.StepReportUGCResBitmapTimer = nil
    self._ReportBitmapCtx = nil
    return
  end
  local ctx = self._ReportBitmapCtx
  if ctx then
    ctx.Aborted = true
  else
    local AssetList = {}
    for _, cfg in pairs(self.UGCAssetConfigIDMap) do
      local assetID = cfg and cfg.AssetID
      if assetID and 0 < assetID then
        table.insert(AssetList, assetID)
      end
    end
    ctx = {
      AssetList = AssetList,
      Index = 0,
      DownloadedMap = {},
      Total = 0,
      Done = 0,
      Trigger = sTrigger,
      Aborted = false
    }
  end
  local list = ctx.AssetList
  local count = #list
  for i = ctx.Index + 1, count do
    local assetID = list[i]
    ctx.Total = ctx.Total + 1
    if PufferUGCPakManager:GetStateByAssetID(assetID) == PufferConst.ENUM_DownloadState.Done then
      ctx.DownloadedMap[assetID] = true
      ctx.Done = ctx.Done + 1
    end
    ctx.Index = i
  end
  self.StepReportUGCResBitmapTimer = nil
  self._ReportBitmapCtx = nil
  self:_DoReportUGCResBitmap(ctx)
end
function Logic_UGC_Res_Manager:_RemoveReportUGCResBitmapTimers()
  if self.ReportUGCResBitmapDelayTimer then
    self:RemoveTimer(self.ReportUGCResBitmapDelayTimer)
    self.ReportUGCResBitmapDelayTimer = nil
  end
  if self._ReportBitmapCtx then
    self._ReportBitmapCtx.Aborted = true
  end
  self.StepReportUGCResBitmapTimer = nil
  self._ReportBitmapCtx = nil
end
function Logic_UGC_Res_Manager:_DoReportUGCResBitmap(ctx)
  if self.bHasReportedResBitmap then
    self._ReportBitmapCtx = nil
    return
  end
  if not ctx then
    return
  end
  local BitmapUtil = require("client.slua.logic.ugc.PrefabMall.Config.PrefabMallBitmapUtil")
  local bitmap_data = BitmapUtil.EncodeBitmap(ctx.DownloadedMap, "UGCAssetConfig") or {}
  local maxSlot = 0
  for k, _ in pairs(bitmap_data) do
    if k > maxSlot then
      maxSlot = k
    end
  end
  local bitmap_bit_count = maxSlot * 32
  print(bWriteLog and string.format("Logic_UGC_Res_Manager:_DoReportUGCResBitmap total=%d done=%d bit_count=%d trigger=%s", ctx.Total, ctx.Done, bitmap_bit_count or 0, tostring(ctx.Trigger)))
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_ugc_report_res_bitmap_req(bitmap_data, bitmap_bit_count)
  self.bHasReportedResBitmap = true
  self._ReportBitmapCtx = nil
end
function Logic_UGC_Res_Manager:OnModInfoBatchRsp(MetaList, ListType, Param)
  if not MetaList then
    return
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local matchInfo = LogicUGCMatch:GetMatchInfo()
  if not (matchInfo and matchInfo.mod_id) or not MetaList[matchInfo.mod_id] then
    return
  end
  local ModInfo = MetaList[matchInfo.mod_id]
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  LogicUGCResManager:Send_update_client_mod_info_ByModInfo(ModInfo.pub_mod_meta)
end
function Logic_UGC_Res_Manager:CheckMatchInfoChange()
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local matchInfo = LogicUGCMatch:GetMatchInfo()
  if matchInfo == nil then
    self:_RemoveReportResTimer()
  end
end
function Logic_UGC_Res_Manager:GetStateByModID(loaderType, modID)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local modeInfo = LogicUGC:GetModByAllCache(modID)
  if modeInfo then
    return self:GetResState(loaderType, modeInfo.pub_mod_meta)
  end
  return PufferConst.ENUM_DownloadState.Not
end
function Logic_UGC_Res_Manager:IsCompleteRes(loaderType, modInfo)
  local state = self:GetResState(loaderType, modInfo)
  return state == PufferConst.ENUM_DownloadState.Done
end
function Logic_UGC_Res_Manager:GetResState(loaderType, modInfo)
  local state = PufferConst.ENUM_DownloadState.Done
  if loaderType == self.DownloaderType.ModCopy then
    state = self:_GetUGCModResState(modInfo)
  elseif loaderType == self.DownloaderType.MyWork then
    state = self:_GetUGCWorkResState(modInfo)
  elseif loaderType == self.DownloaderType.Template then
    state = self:_GetUGCTemplateResState(modInfo)
  end
  local bIsNewMeta = self:_IsNewMeta(modInfo)
  if bIsNewMeta then
    local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
    local AssetHubState = LogicUGCAssetHub:GetAssetState(loaderType, modInfo)
    state = PufferManager.GetMixDownloadState(state, AssetHubState)
  end
  return state
end
function Logic_UGC_Res_Manager:CheckStorageEnough(DownloadSize)
  if IsEditor then
    return true
  end
  local FreeStorage = PufferDeleteManager.GetDeviceFreeSpace()
  local LeftStorage = FreeStorage - UGCMacros.GAME_NEED_MIN_STORAGE - DownloadSize
  if LeftStorage <= 0 then
    local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
    if 0 >= LogicUGCAssetHub:GetPublicStorage() then
      ShowNotice(33208)
      PufferDeleteManager.ShowDeleteUI(false)
    else
      LogicUGCAssetHub:ShowCleanPopup()
    end
    return false
  end
  return true
end
function Logic_UGC_Res_Manager:DownloadRes(loaderType, modInfo, bSkipCheck)
  if not bSkipCheck then
    if PufferSwitch.BanDownload then
      log(bWriteLog and "Logic_UGC_Res_Manager:DownloadRes ban download true")
      return false
    end
    if not PufferDownloader.InitSuccess then
      PufferDownloader.ReInitializePuffer(false)
      return false
    end
    if not PufferDownloader.PufferJsonDownloadReturn then
      PufferDownloader.ReportPufferWarning()
      return false
    end
    local cSize, tSize = self:GetResSize(loaderType, modInfo)
    local unSize = tSize - cSize
    if not self:CheckStorageEnough(unSize) then
      log(bWriteLog and "Logic_UGC_Res_Manager:DownloadRes CheckStorageEnough false")
      return false
    end
  end
  local Result = false
  if loaderType == self.DownloaderType.ModCopy then
    Result = self:_DownloadModRes(modInfo)
  elseif loaderType == self.DownloaderType.MyWork then
    Result = self:_DownloadWorkRes(modInfo)
  elseif loaderType == self.DownloaderType.Template then
    Result = self:_DownloadTemplateRes(modInfo)
  end
  local bIsNewMeta = self:_IsNewMeta(modInfo)
  if bIsNewMeta then
    local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
    local bAutoClean, bBreak = LogicUGCAssetHub:AutoCleanStorage(loaderType, modInfo)
    if bAutoClean then
      local AssetHubResult = LogicUGCAssetHub:Download(loaderType, modInfo)
      if not AssetHubResult then
        Result = AssetHubResult
      end
    elseif bBreak then
      Result = false
    end
  end
  return Result
end
function Logic_UGC_Res_Manager:PauseRes(loaderType, modInfo)
  if loaderType == self.DownloaderType.ModCopy then
    self:_PauseModRes(modInfo)
  elseif loaderType == self.DownloaderType.MyWork then
    self:_PauseWorkRes(modInfo)
  elseif loaderType == self.DownloaderType.Template then
    self:_PauseTemplateRes(modInfo)
  end
  local bIsNewMeta = self:_IsNewMeta(modInfo)
  if bIsNewMeta then
    local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
    LogicUGCAssetHub:Pause(loaderType, modInfo)
  end
end
function Logic_UGC_Res_Manager:GetResSize(loaderType, modInfo)
  local cSize, tSize = 0, 0
  if loaderType == self.DownloaderType.ModCopy then
    cSize, tSize = self:_GetUGCModResSize(modInfo)
  elseif loaderType == self.DownloaderType.MyWork then
    cSize, tSize = self:_GetUGCWorkResSize(modInfo)
  elseif loaderType == self.DownloaderType.Template then
    cSize, tSize = self:_GetUGCTemplateResSize(modInfo)
  end
  local bIsNewMeta = self:_IsNewMeta(modInfo)
  if bIsNewMeta then
    local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
    local cAssetHubSize, tAssetHubSize = LogicUGCAssetHub:GetAssetSize(loaderType, modInfo)
    tSize = tSize + tAssetHubSize
    cSize = cSize + cAssetHubSize
  end
  return cSize, tSize
end
function Logic_UGC_Res_Manager:BatchGetResState(LoaderType, ModList)
  local ResultState = PufferConst.ENUM_DownloadState.Done
  local ModLoaderType = LoaderType == self.DownloaderType.ModList and self.DownloaderType.ModCopy or self.DownloaderType.Template
  for k, v in pairs(ModList) do
    local State = self:GetResState(ModLoaderType, v)
    ResultState = PufferManager.GetMixDownloadState(ResultState, State)
  end
  return ResultState
end
function Logic_UGC_Res_Manager:BatchDownloadRes(LoaderType, ModList)
  if PufferSwitch.BanDownload then
    log(bWriteLog and "Logic_UGC_Res_Manager:BatchDownloadRes ban download true")
    return false
  end
  if not PufferDownloader.InitSuccess then
    PufferDownloader.ReInitializePuffer(false)
    return false
  end
  if not PufferDownloader.PufferJsonDownloadReturn then
    PufferDownloader.ReportPufferWarning()
    return false
  end
  local cSize, tSize = self:BatchGetResSize(LoaderType, ModList)
  local unSize = tSize - cSize
  if not self:CheckStorageEnough(unSize) then
    log(bWriteLog and "Logic_UGC_Res_Manager:BatchDownloadRes CheckStorageEnough false")
    return false
  end
  local bFinish = true
  local ModLoaderType = LoaderType == self.DownloaderType.ModList and self.DownloaderType.ModCopy or self.DownloaderType.Template
  for k, v in pairs(ModList) do
    if not self:DownloadRes(ModLoaderType, v, true) then
      bFinish = false
    end
  end
  return bFinish
end
function Logic_UGC_Res_Manager:BatchPauseRes(LoaderType, ModList)
  local ModLoaderType = LoaderType == self.DownloaderType.ModList and self.DownloaderType.ModCopy or self.DownloaderType.Template
  for k, v in pairs(ModList) do
    self:PauseRes(ModLoaderType, v)
  end
end
function Logic_UGC_Res_Manager:BatchGetResSize(LoaderType, ModList)
  local cSize, tSize = 0, 0
  if LoaderType == self.DownloaderType.ModList then
    cSize, tSize = self:_GetUGCModListSize(ModList)
  elseif LoaderType == self.DownloaderType.TemplateList then
    cSize, tSize = self:_GetUGCTemplateListSize(ModList)
  end
  return cSize, tSize
end
function Logic_UGC_Res_Manager:GetPackListState(PackList, NeedEditRes)
  local State = LogicPufferBundle.GetPackListState(PackList, false)
  if NeedEditRes then
    local BasicMapState = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
      PufferConst.UGC_BASIC_MAPKEY
    })
    State = PufferManager.GetMixDownloadState(State, BasicMapState)
    local EditorMapState = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
      PufferConst.UGC_EDIT_MAPKEY
    })
    State = PufferManager.GetMixDownloadState(State, EditorMapState)
  end
  return State
end
function Logic_UGC_Res_Manager:DownloadPackList(PackList, NeedEditRes)
  LogicPufferBundle.DownloadPackList(PackList)
  if NeedEditRes then
    PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {
      PufferConst.UGC_BASIC_MAPKEY
    })
    PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {
      PufferConst.UGC_EDIT_MAPKEY
    })
  end
end
function Logic_UGC_Res_Manager:PausePackList(PackList, NeedEditRes)
  LogicPufferBundle.PausePackList(PackList)
  if NeedEditRes then
    PufferManager.Pause(PufferConst.ENUM_DownloadType.MAP, {
      PufferConst.UGC_BASIC_MAPKEY
    })
    PufferManager.Pause(PufferConst.ENUM_DownloadType.MAP, {
      PufferConst.UGC_EDIT_MAPKEY
    })
  end
end
function Logic_UGC_Res_Manager:GetPackListSize(PackList, bNeedEditRes)
  local cSize, tSize = LogicPufferBundle.GetPackListSize(PackList)
  if bNeedEditRes then
    local cMapSize, tMapSize = self:_GetUGCBasicResSize()
    cSize = cSize + cMapSize
    tSize = tSize + tMapSize
    cMapSize, tMapSize = self:_GetUGCEditResSize()
    cSize = cSize + cMapSize
    tSize = tSize + tMapSize
  end
  return cSize, tSize
end
function Logic_UGC_Res_Manager:IsCompleteUGCTemplateResByTeam(TemplateId, CustomAssetList)
  local State = self:GetUGCBundleState()
  if State ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "Logic_UGC_Res_Manager:IsCompleteUGCTemplateResByTeam UGCBundle not download")
    return false
  end
  local MapKey = self:GetUGCMapKeyByTemplateId(TemplateId)
  State = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {MapKey})
  if State ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "Logic_UGC_Res_Manager:IsCompleteUGCTemplateResByTeam mapKey not download")
    return false
  end
  if CustomAssetList then
    local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
    State = LogicUGCAssetHub:GetAssetStateByList(CustomAssetList)
    if State ~= PufferConst.ENUM_DownloadState.Done then
      log(bWriteLog and "Logic_UGC_Res_Manager:IsCompleteUGCTemplateResByTeam CustomAssetList not download")
      return false
    end
  end
  return true
end
function Logic_UGC_Res_Manager:GetUGCTemplateResStateByTeam(TemplateId, CustomAssetList)
  local MapKey = self:GetUGCMapKeyByTemplateId(TemplateId)
  local State = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {MapKey})
  if State == PufferConst.ENUM_DownloadState.Done then
    State = self:GetUGCBundleState()
    if State == PufferConst.ENUM_DownloadState.Done and CustomAssetList then
      local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
      State = LogicUGCAssetHub:GetAssetStateByList(CustomAssetList)
    end
  end
  return State
end
function Logic_UGC_Res_Manager:DownloadTemplateResByTeam(TemplateId, CustomAssetList, CustomAssetDownloadSeq)
  local cacheKey = self:_GetCacheKeyByTemplateInfoID(TemplateId)
  local cacheInfo = self:GetUGCModCacheInfo(cacheKey)
  cacheInfo.state = PufferConst.ENUM_DownloadState.Download
  local MapKey = self:GetUGCMapKeyByTemplateId(TemplateId)
  local MapState = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {MapKey})
  if MapState ~= PufferConst.ENUM_DownloadState.Done then
    PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {MapKey})
    cacheInfo.mapKey = MapKey
    log(bWriteLog and "Logic_UGC_Res_Manager:GetUGCTemplateResStateByTeam MapKey not finish:" .. MapKey)
  end
  if self:GetUGCBundleState() ~= PufferConst.ENUM_DownloadState.Done then
    cacheInfo.bundleKey = PufferConst.UGC_BUNDLE_ID
    LogicPufferBundle.DownloadBundle(PufferConst.UGC_BUNDLE_ID)
    log(bWriteLog and "Logic_UGC_Res_Manager:GetUGCTemplateResStateByTeam bundle res not finish")
  end
  if CustomAssetList then
    local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
    if LogicUGCAssetHub:GetAssetStateByList(CustomAssetList) ~= PufferConst.ENUM_DownloadState.Done then
      LogicUGCAssetHub:DownloadList(CustomAssetList, CustomAssetDownloadSeq)
      log(bWriteLog and "Logic_UGC_Res_Manager:GetUGCTemplateResStateByTeam CustomAssetList not finish")
    end
  end
end
function Logic_UGC_Res_Manager:PauseTemplateResByTeam(TemplateId, CustomAssetList, CustomAssetDownloadSeq)
  local cacheKey = self:_GetCacheKeyByTemplateInfoID(TemplateId)
  local cacheInfo = self:GetUGCModCacheInfo(cacheKey)
  cacheInfo.state = PufferConst.ENUM_DownloadState.Pause
  local cacheInfos = self.modResCaches
  local ExistOtherMapKey = false
  if cacheInfo.mapKey then
    for mK, mV in pairs(cacheInfos) do
      if mV.state == PufferConst.ENUM_DownloadState.Download and mV.mapKey == cacheInfo.mapKey then
        ExistOtherMapKey = true
        break
      end
    end
    if not ExistOtherMapKey then
      PufferManager.Pause(PufferConst.ENUM_DownloadType.MAP, {
        cacheInfo.mapKey
      })
    end
  end
  local ExistBundle = false
  if cacheInfo.bundleKey then
    for mK, mV in pairs(cacheInfos) do
      if mV.state == PufferConst.ENUM_DownloadState.Download and mV.bundleKey then
        ExistBundle = true
        break
      end
    end
    if not ExistBundle then
      LogicPufferBundle.StopDownloadBundle(PufferConst.UGC_BUNDLE_ID)
    end
  end
  if CustomAssetList and CustomAssetDownloadSeq then
    local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
    LogicUGCAssetHub:PauseList(CustomAssetDownloadSeq)
  end
end
function Logic_UGC_Res_Manager:GetUGCTemplateResSizeByTeam(TemplateId, CustomAssetList)
  local MapKey = self:GetUGCMapKeyByTemplateId(TemplateId)
  local cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {MapKey})
  cSize = cSize / PufferConst.MB
  tSize = tSize / PufferConst.MB
  local bcSize, btSize = self:GetUGCBundleSize()
  cSize = cSize + bcSize
  tSize = tSize + btSize
  if CustomAssetList then
    local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
    local ccSize, ctSize = LogicUGCAssetHub:GetAssetSizeByList(CustomAssetList)
    return cSize + ccSize, tSize + ctSize, tSize - cSize, ctSize - ccSize
  else
    return cSize, tSize, tSize - cSize, 0
  end
end
function Logic_UGC_Res_Manager:GetUGCModInfoPakSizeAndNameList(modInfo, bMyWork, bNeedEditRes)
  if not modInfo or modInfo.base == nil or modInfo.base.template_id == nil then
    return 0, 0, {}
  end
  local pakList = {}
  local MinNotDoneSize = 0.005
  local mapKey = self:GetUGCMapKeyByTemplateId(modInfo.base.template_id)
  local excludeMapKey, AllAssetIDList, AllFeatureKeyList
  if bMyWork then
    AllAssetIDList, AllFeatureKeyList = self:_GetNotPublishModResList(modInfo)
  else
    AllAssetIDList, AllFeatureKeyList = self:GetAllResList(modInfo)
    excludeMapKey = self:GetExcludeMapKey(modInfo, AllAssetIDList)
  end
  local cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {mapKey}, nil, excludeMapKey)
  cSize = cSize / PufferConst.MB
  tSize = tSize / PufferConst.MB
  if mapKey then
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:GetUGCModInfoPakSizeAndNameList mapKey =%s, cSize:%.2f, tSize:%.2f", mapKey, cSize, tSize))
    local mapConfig = CDataTable.GetTableData("MapPakTable", mapKey)
    if mapConfig and MinNotDoneSize < tSize - cSize then
      table.insert(pakList, {
        pakName = mapConfig.name,
        cSize = cSize,
        tSize = tSize,
        pakId = 0
      })
    end
  else
    log(bWriteLog and "Logic_UGC_Res_Manager:GetUGCModInfoPakSizeAndNameList mapKey is nil")
  end
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local cFeatureSize, tFeatureSize = PufferODPakManager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.ODPAK, AllFeatureKeyList)
  cSize = cSize + cFeatureSize / PufferConst.MB
  tSize = tSize + tFeatureSize / PufferConst.MB
  local PufferUGCPakManager = self:_GetPufferUGCPakManager()
  local cAssetSize, tAssetSize, idpakSizeList = PufferUGCPakManager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, AllAssetIDList, true, true)
  cSize = cSize + cAssetSize / PufferConst.MB
  tSize = tSize + tAssetSize / PufferConst.MB
  if idpakSizeList then
    for pakId, sizes in pairs(idpakSizeList) do
      local pakConfig = CDataTable.GetTableData("PakInfoTable", pakId)
      if pakConfig and MinNotDoneSize < sizes.tSize - sizes.cSize then
        table.insert(pakList, {
          pakName = pakConfig.PakName,
          cSize = sizes.cSize,
          tSize = sizes.tSize,
                  })
      end
    end
  end
  if bNeedEditRes then
    local cEditSize, tEditSize = self:_GetUGCEditResSize()
    cSize = cSize + cEditSize
    tSize = tSize + tEditSize
    if MinNotDoneSize < tEditSize - cEditSize then
      table.insert(pakList, {
        pakName = LocUtil.GetLocalizeResStr(99020001),
        cSize = cEditSize,
        tSize = tEditSize,
        pakId = 0
      })
    end
  end
  log_tree("Logic_UGC_Res_Manager:GetUGCModInfoPakSizeAndNameList pakList", pakList)
  return cSize, tSize, pakList
end
function Logic_UGC_Res_Manager:GetUGCMapKeyByTemplateId(templateId, mapID)
  local mapConfig = self:_GetUGCMapConfigByTemplateId(templateId, mapID)
  if mapConfig then
    return mapConfig.MapKey
  end
  return nil
end
function Logic_UGC_Res_Manager:GetUGCBundleSize(bIncludeMap)
  local cSize, tSize = LogicPufferBundle.GetBundleSize(PufferConst.UGC_BUNDLE_ID)
  if not bIncludeMap then
    local BasicCSize, BasicTSize = self:_GetUGCBasicResSize()
    cSize = cSize - BasicCSize
    tSize = tSize - BasicTSize
  end
  return cSize, tSize
end
function Logic_UGC_Res_Manager:GetUGCBundleState()
  local State = LogicPufferBundle.GetBundleState(PufferConst.UGC_BUNDLE_ID)
  return State
end
function Logic_UGC_Res_Manager:DownloadUGCBundle()
  LogicPufferBundle.DownloadBundle(PufferConst.UGC_BUNDLE_ID)
end
function Logic_UGC_Res_Manager:PauseUGCBundle()
  LogicPufferBundle.StopDownloadBundle(PufferConst.UGC_BUNDLE_ID)
end
function Logic_UGC_Res_Manager:_GetCacheDepends(ModInfo, bMyWork)
  if not (ModInfo and ModInfo.base) or not ModInfo.setting then
    return nil, nil
  end
  local CacheKey = self:_GetCacheKeyByModInfo(ModInfo, bMyWork)
  if CacheKey then
    local CacheInfo = self:GetUGCModCacheInfo(CacheKey)
    if ModInfo.base and CacheInfo.version == ModInfo.base.verify_time and CacheInfo.depends then
      return CacheInfo.depends, CacheInfo.dependFeatures
    else
      if ModInfo.base and ModInfo.base.template_id then
        local MapKey = self:GetUGCMapKeyByTemplateId(ModInfo.base.template_id)
        if MapKey then
          local MapPakTable = CDataTable.GetTableData("MapPakTable", MapKey)
          if MapPakTable and (MapPakTable.depends == "" or not string.find(MapPakTable.depends, "map_creativecore")) then
            log(bWriteLog and "Logic_UGC_Res_Manager:GetUGCMapKeyByTemplateId MapKey = ", MapKey)
            CacheInfo.depends = {}
            CacheInfo.dependFeatures = {}
            return CacheInfo.depends, CacheInfo.dependFeatures
          end
        end
      end
      if ModInfo.setting then
        local AssetIDList = self:GetDependIdsByIntMap(ModInfo.setting.res_list)
        local AssetParamList = self:GetDependAssetParamsByIntMap(ModInfo.setting.feature_id_list)
        CacheInfo.depends, CacheInfo.dependFeatures = self:_GetAssetIDAndFeatureList(ModInfo, AssetIDList, AssetParamList)
      else
        return Config_UGC.ForceDependAssetIDList, nil
      end
      CacheInfo.version = ModInfo.base.verify_time
      return CacheInfo.depends, CacheInfo.dependFeatures
    end
  end
  return Config_UGC.ForceDependAssetIDList, nil
end
function Logic_UGC_Res_Manager:_GetAssetIDAndFeatureList(ModInfo, AssetIDList, AssetParamList)
  local AllAssetIDMap = {}
  local AllFeatureKeyMap = {}
  for k, v in pairs(AssetIDList) do
    AllAssetIDMap[v] = true
  end
  local bIsPublishMod = self:_IsPublishMod(ModInfo)
  local PufferUGCPakManager = self:_GetPufferUGCPakManager()
  for _, AssetID in pairs(AssetIDList) do
    local DependFeatureKeys = PufferUGCPakManager:GetNecessaryFeatureDepends(AssetID)
    for k, v in pairs(DependFeatureKeys) do
      AllFeatureKeyMap[v] = true
    end
  end
  if bIsPublishMod then
    local bIsNewMeta, MetaVersion = self:_IsNewMeta(ModInfo)
    if bIsNewMeta and AssetParamList then
      local DependFeatureKeysList, DependAssetIDList = self:_GetAssetParamDepends(AssetParamList)
      for k, v in pairs(DependAssetIDList) do
        AllAssetIDMap[v] = true
      end
      for k, v in pairs(DependFeatureKeysList) do
        AllFeatureKeyMap[v] = true
      end
    else
      for _, AssetID in pairs(AssetIDList) do
        local DependFeatureKeys, DependAssetIDs = PufferUGCPakManager:GetDepends(AssetID)
        for k, v in pairs(DependAssetIDs) do
          AllAssetIDMap[v] = true
        end
        for k, v in pairs(DependFeatureKeys) do
          AllFeatureKeyMap[v] = true
        end
      end
    end
    for Version, PatchInfo in pairs(Config_UGC.BeforeVersionPatchResList) do
      if MetaVersion < Version then
        for k, v in pairs(PatchInfo.AssetIDList) do
          AllAssetIDMap[v] = true
        end
        for k, v in pairs(PatchInfo.FeatureKeyList) do
          AllFeatureKeyMap[v] = true
        end
      end
    end
    local PatchInfo = Config_UGC.PatchResList[MetaVersion]
    if PatchInfo then
      for k, v in pairs(PatchInfo.AssetIDList) do
        AllAssetIDMap[v] = true
      end
      for k, v in pairs(PatchInfo.FeatureKeyList) do
        AllFeatureKeyMap[v] = true
      end
    end
  else
    for _, AssetID in pairs(AssetIDList) do
      local DependFeatureKeys, DependAssetIDs = PufferUGCPakManager:GetDepends(AssetID)
      for k, v in pairs(DependAssetIDs) do
        AllAssetIDMap[v] = true
      end
      for k, v in pairs(DependFeatureKeys) do
        AllFeatureKeyMap[v] = true
      end
    end
  end
  for AssetID, FeatureKeys in pairs(Config_UGC.AssetDependFeatureKey) do
    if AllAssetIDMap[AssetID] then
      for k, v in pairs(FeatureKeys) do
        AllFeatureKeyMap[v] = true
      end
    end
  end
  AllFeatureKeyMap.skill_SpecialWater = true
  AllFeatureKeyMap.Skill_IceRoad = true
  local AllAssetIDList = {}
  local AllFeatureKeyList = {}
  for k, v in pairs(AllAssetIDMap) do
    table.insert(AllAssetIDList, k)
  end
  for k, v in pairs(AllFeatureKeyMap) do
    table.insert(AllFeatureKeyList, k)
  end
  return AllAssetIDList, AllFeatureKeyList
end
function Logic_UGC_Res_Manager:GetDependIdsByIntMap(resList)
  resList = resList or {}
  local bitList = {}
  local size = 32
  for k, v in pairs(resList) do
    if v and 0 < v then
      local margin = size * (k - 1)
      local tmpList = FuncUtil.Int2ByteList(v)
      if tmpList ~= nil then
        for bitKey, bitV in ipairs(tmpList) do
          bitV = bitV + margin
          table.insert(bitList, bitV)
        end
      end
    end
  end
  local idList = {}
  for k, v in ipairs(bitList) do
    local assertConfig = self.UGCAssetConfigIDMap[v]
    if assertConfig and assertConfig.AssetID then
      local CreativeExpiredAssetConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.CreativeExpiredAssetConfig")
      local bExpired = CreativeExpiredAssetConfig.IsCurVersionExpired(assertConfig.AssetID)
      if not bExpired then
        table.insert(idList, assertConfig.AssetID)
      end
    end
  end
  for k, v in pairs(Config_UGC.ForceDependAssetIDList) do
    table.insert(idList, v)
  end
  return idList
end
function Logic_UGC_Res_Manager:Send_update_client_mod_info_ByModInfo(modInfo, isTick, bReportPauseState, lastState)
  local isLoaded = false
  if modInfo.mod_id then
    if self:GetResState(self.DownloaderType.ModCopy, modInfo) == PufferConst.ENUM_DownloadState.Done then
      isLoaded = true
    end
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:Send_update_client_mod_info_ByModInfo --- is mod id:%s ,isLoaded:%s", tostring(modInfo.mod_id), tostring(isLoaded)))
  else
    if self:GetResState(self.DownloaderType.MyWork, modInfo) == PufferConst.ENUM_DownloadState.Done then
      isLoaded = true
    end
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:Send_update_client_mod_info_ByModInfo --- is not mod templateid:%d ,,isLoaded:%s", modInfo.base.template_id, tostring(isLoaded)))
  end
  local report_mod_info = {}
  local modIdStr
  if modInfo.mod_id then
    modIdStr = modInfo.mod_id
  else
    modIdStr = tostring(modInfo.base.uid) .. "_" .. tostring(modInfo.base.slot)
  end
  local cur_state = 0
  local last_state = lastState or 0
  if isLoaded then
    report_mod_info[modIdStr] = 3
    cur_state = 3
    self:_RemoveReportResTimer()
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:Send_update_client_mod_info_ByModInfo --- finish mod id:%s", modIdStr))
  else
    if bReportPauseState == nil or bReportPauseState == false then
      report_mod_info[modIdStr] = 1
      cur_state = 1
    else
      cur_state = self:GetResState(self.DownloaderType.ModCopy, modInfo)
      report_mod_info[modIdStr] = cur_state
    end
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:Send_update_client_mod_info_ByModInfo --- unfinish mod id:%s", modIdStr))
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  if isTick == nil or isTick == false then
    UGCModHandler.send_update_client_mod_info(report_mod_info)
    log(bWriteLog and "Logic_UGC_Res_Manager:Send_update_client_mod_info_ByModInfo ---")
  elseif isTick == true and (isLoaded == true or bReportPauseState == true and cur_state ~= last_state) then
    UGCModHandler.send_update_client_mod_info(report_mod_info)
  end
  log(bWriteLog and "Logic_UGC_Res_Manager:Send_update_client_mod_info_ByModInfo cur_state = " .. cur_state .. " last_state = " .. last_state .. " bReportPauseState = " .. tostring(bReportPauseState))
  if isLoaded == false then
    self:_CheckReportResState(modInfo, bReportPauseState, cur_state)
  end
end
function Logic_UGC_Res_Manager:Send_update_client_mod_info_ByTeamRes(LeaderUid, State)
  if LeaderUid then
    local ReportModInfo = {}
    local ModIDStr = tostring(LeaderUid) .. "_0"
    ReportModInfo[ModIDStr] = State
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:Send_update_client_mod_info_ByTeamRes --- State:%d, mod id:%s", State, ModIDStr))
    local UGCModHandler = require("client.network.Protocol.UGCModHandler")
    UGCModHandler.send_update_client_mod_info(ReportModInfo)
  else
    log(bWriteLog and "this leader's uid is nil")
  end
end
function Logic_UGC_Res_Manager:Send_update_client_mod_info_NewbieGuideTemplate(template_id)
  if not template_id then
    log(bWriteLog and "Logic_UGC_Res_Manager:Send_update_client_mod_info_NewbieGuideTemplate no template_id")
    return
  end
  local isLoaded = self:_IsCompleteUGCTemplateRes(template_id)
  local report_mod_info = {}
  local modIdStr = "novice_" .. tostring(template_id)
  if isLoaded then
    report_mod_info[modIdStr] = PufferConst.ENUM_DownloadState.Done
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:Send_update_client_mod_info_NewbieGuideTemplate --- finish:%s", modIdStr))
  else
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:Send_update_client_mod_info_NewbieGuideTemplate --- unfinish:%s", modIdStr))
    report_mod_info[modIdStr] = PufferConst.ENUM_DownloadState.Download
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_update_client_mod_info(report_mod_info)
end
function Logic_UGC_Res_Manager:CheckReportCurUGCModState()
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local MatchInfo = LogicUGCMatch:GetMatchInfo()
  if not MatchInfo then
    return
  end
  local ModID = MatchInfo.mod_id
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if LogicUGC:GetModIsBan(ModID) then
    return
  end
  local ModInfoList = LogicUGC:BatchGetModInfo({ModID}, LogicUGC.C_ModListTypes.UgcMatch, nil, {bNotPostEvent = true})
  if ModInfoList and next(ModInfoList) then
    self:OnModInfoBatchRsp(ModInfoList, LogicUGC.C_ModListTypes.UgcMatch)
  end
end
function Logic_UGC_Res_Manager:GetUGCModCacheInfo(cacheKey)
  local cacheInfos = self.modResCaches
  local modCacheInfo = cacheInfos[cacheKey]
  if modCacheInfo == nil then
    modCacheInfo = {
      state = PufferConst.ENUM_DownloadState.Not
    }
    local state = self.modStateCaches[cacheKey]
    if state then
      modCacheInfo.    end
    cacheInfos[cacheKey] = modCacheInfo
  end
  return modCacheInfo
end
function Logic_UGC_Res_Manager:ClearCacheInfos()
  self.modResCaches = {}
  self.modStateCaches = {}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.modStateCaches, PlayerPrefsSystem.ePlayerPrefsType.eUGCCacheLoadState)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CACHE_CLEAR)
end
function Logic_UGC_Res_Manager:GetExcludeMapKey(modInfo, idList)
  local excludeMapKey = {}
  if not self.bOptimizeMapDownload then
    return excludeMapKey
  end
  if modInfo.mod_id and idList then
    local NeedDinosaurCore = false
    local NeedDestructible = true
    for k, v in pairs(idList) do
      if v == 987654321 then
        NeedDestructible = false
      end
      if v == 3101032 or v == 3101043 then
        NeedDinosaurCore = true
      end
    end
    if not NeedDestructible then
      excludeMapKey.map_creativedestructible = true
    end
    if not NeedDinosaurCore then
      excludeMapKey.map_dinosaurcore = true
    end
    printf(bWriteLog and "Logic_UGC_Res_Manager:GetExcludeMapKey mod_id = %d, NeedDinosaurCore = %s, NeedDestructible = %s", modInfo.mod_id, NeedDinosaurCore, NeedDestructible)
  end
  return excludeMapKey
end
function Logic_UGC_Res_Manager:SendTLogUIOperate(key, modInfo, TLogFrom, extraParams, force)
  local extra = {}
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local startTimeStr = TimeUtil.OSDate("!%Y-%m-%d %H:%M:%S", serverTime)
  extra.time = startTimeStr
  if TLogFrom then
    if extraParams then
      for k, v in pairs(extraParams) do
        extra[k] = v
      end
    end
    PufferTlog.SendTLog(TLogFrom, PufferTlog.Enum_TLog_Optype.UIOperate, key, extra, force)
    return
  end
  if modInfo then
    if modInfo.mod_id then
      extra.type = "mod"
      extra.id = modInfo.mod_id
    elseif modInfo.base and modInfo.base.slot then
      extra.type = "work"
      extra.id = modInfo.base.slot
    elseif modInfo.ID then
      extra.type = "template"
      extra.id = modInfo.ID
    end
    if modInfo.setting and modInfo.setting.name then
      extra.name = modInfo.setting.name
    elseif modInfo.DefaultCreateName then
      extra.name = modInfo.DefaultCreateName
    end
    if extraParams then
      for k, v in pairs(extraParams) do
        extra[k] = v
      end
    end
    PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.UGCMode, PufferTlog.Enum_TLog_Optype.UIOperate, key, extra, force)
  end
end
function Logic_UGC_Res_Manager:SendTLogUGCResCenterOperate(key)
  local lastTime = self:_GetTlogLastTimeByKey(key)
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local isSameDay = TimeUtil.IsSameDay(lastTime, curTime)
  if isSameDay ~= true then
    local extra = {}
    PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.UGCMode, PufferTlog.Enum_TLog_Optype.UIOperate, key, extra)
    self:_SaveTlogTime(key)
  end
end
function Logic_UGC_Res_Manager:IsTemplate(ModInfo)
  if ModInfo.ResList then
    return true
  end
  return false
end
function Logic_UGC_Res_Manager:GetAllResList(ModInfo, bMyWork)
  local AllAssetIDList = {}
  local AllFeatureKeyList = {}
  if self:IsTemplate(ModInfo) then
    local IDList = self:GetDependIdsByIntMap(ModInfo.ResList)
    AllAssetIDList, AllFeatureKeyList = self:_GetAssetIDAndFeatureList(ModInfo, IDList)
  else
    AllAssetIDList, AllFeatureKeyList = self:_GetCacheDepends(ModInfo, bMyWork)
  end
  return AllAssetIDList, AllFeatureKeyList
end
function Logic_UGC_Res_Manager:GetModDownloadInfo(ModInfo, bAddAttachFile)
  local modVersion = self:_GetModVersion(ModInfo)
  print(bWriteLog and "Logic_UGC_Res_Manager:GetModDownloadInfo ModID:" .. tostring(ModInfo.mod_id) .. ",version:" .. tostring(modVersion))
  if bAddAttachFile then
    Client.AddAttachFileString("GetModDownloadInfo", true, "ModID:" .. tostring(ModInfo.mod_id) .. ",version:" .. tostring(modVersion))
  end
  local DebugInfo = ""
  local SplitChar = "|"
  if ModInfo.setting then
    local idList = self:GetDependIdsByIntMap(ModInfo.setting.res_list)
    local AssetParamList = self:GetDependAssetParamsByIntMap(ModInfo.setting.feature_id_list)
    if idList then
      DebugInfo = "res_list:("
      for k, v in pairs(idList) do
        DebugInfo = DebugInfo .. tostring(v) .. SplitChar
      end
    end
    DebugInfo = DebugInfo .. ")        "
    if AssetParamList then
      DebugInfo = DebugInfo .. "asset_param_list:("
      for k, v in pairs(AssetParamList) do
        DebugInfo = DebugInfo .. tostring(v) .. SplitChar
      end
      DebugInfo = DebugInfo .. ")        "
    end
  end
  DebugInfo = DebugInfo .. "FeatureKey State Begin:("
  local AllAssetIDList, AllFeatureKeyList = self:GetAllResList(ModInfo)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  for k, v in pairs(AllFeatureKeyList) do
    local state = PufferODPakManager:GetStateByKeyList(PufferConst.ENUM_DownloadType.ODPAK, {v})
    local info = "" .. tostring(v) .. ":" .. state
    DebugInfo = DebugInfo .. info .. SplitChar
  end
  DebugInfo = DebugInfo .. ")       AssetID State Begin:("
  local PufferUGCPakManager = self:_GetPufferUGCPakManager()
  for k, v in pairs(AllAssetIDList) do
    local state = PufferUGCPakManager:GetStateByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, {v}, true)
    local info = "" .. tostring(v) .. ":" .. state
    DebugInfo = DebugInfo .. info .. SplitChar
  end
  DebugInfo = DebugInfo .. ")"
  print(bWriteLog and "Logic_UGC_Res_Manager:GetModDownloadInfo DebugInfo:" .. DebugInfo)
  if bAddAttachFile then
    Client.AddAttachFileString("GetModDownloadInfo", false, "DebugInfo:" .. DebugInfo)
  end
  return DebugInfo
end
function Logic_UGC_Res_Manager:PrintAllFeatureKeys()
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  local Keys = PufferUGCPakManager.AllFeatureIDList
  if Keys then
    local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
    for k, v in pairs(Keys) do
      local state = PufferODPakManager:GetStateByKeyList(PufferConst.ENUM_DownloadType.ODPAK, {v})
      local cSize, tSize = PufferODPakManager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.ODPAK, {v})
      print(bWriteLog and "Logic_UGC_Res_Manager:PrintAllFeatureKeys FeatureKey:" .. tostring(v) .. ",state:" .. tostring(state) .. ",tSize:" .. tostring(tSize / PufferConst.MB))
    end
  end
end
function Logic_UGC_Res_Manager:_IsCompleteUGCModRes(modInfo)
  if not modInfo or modInfo.base == nil or modInfo.base.template_id == nil then
    log(bWriteLog and " Logic_UGC_Res_Manager:_IsCompleteUGCModRes: not modInfo or modInfo.base == nil or modInfo.base.template_id == nil")
    return false
  end
  local AllAssetIDList, AllFeatureKeyList = self:GetAllResList(modInfo)
  local excludeMapKey = self:GetExcludeMapKey(modInfo, AllAssetIDList)
  local mapKey = self:GetUGCMapKeyByTemplateId(modInfo.base.template_id)
  if mapKey == nil then
    log(bWriteLog and string.format(" Logic_UGC_Res_Manager:_IsCompleteUGCModRes: mapKey == nil template_id:%d", modInfo.base.template_id))
  else
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {mapKey}, nil, nil, excludeMapKey)
    log(bWriteLog and string.format(" Logic_UGC_Res_Manager:_IsCompleteUGCModRes mapKey:%s , state:%d", mapKey, state))
    if state ~= PufferConst.ENUM_DownloadState.Done then
      return false
    end
  end
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  if PufferODPakManager:GetStateByKeyList(PufferConst.ENUM_DownloadType.ODPAK, AllFeatureKeyList) ~= PufferConst.ENUM_DownloadState.Done then
    print(bWriteLog and " Logic_UGC_Res_Manager:_IsCompleteUGCModRes:AllFeatureKeyList not done")
    if bWriteLog then
      for k, v in pairs(AllFeatureKeyList) do
        local featureState = PufferODPakManager:GetStateByKeyList(PufferConst.ENUM_DownloadType.ODPAK, {v})
        if featureState ~= PufferConst.ENUM_DownloadState.Done then
          print(bWriteLog and " Logic_UGC_Res_Manager:_IsCompleteUGCModRes feature:%s,State:%s", v, featureState)
        end
      end
    end
    return false
  end
  print(bWriteLog and " Logic_UGC_Res_Manager:_IsCompleteUGCModRes:AllFeatureKeyList done")
  local PufferUGCPakManager = self:_GetPufferUGCPakManager()
  local state = PufferUGCPakManager:GetStateByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, AllAssetIDList, true)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    print(bWriteLog and " Logic_UGC_Res_Manager:_IsCompleteUGCModRes:AllAssetIDList not done")
    if bWriteLog then
      for k, v in pairs(AllAssetIDList) do
        local assetState = PufferUGCPakManager:GetStateByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, {v})
        if assetState ~= PufferConst.ENUM_DownloadState.Done then
          printf(bWriteLog and " Logic_UGC_Res_Manager:_IsCompleteUGCModRes asset:%s,State:%s", v, assetState)
        end
      end
    end
    return false
  end
  print(bWriteLog and " Logic_UGC_Res_Manager:_IsCompleteUGCModRes:AllAssetIDList done")
  return true
end
function Logic_UGC_Res_Manager:_GetUGCModResState(modInfo)
  if not modInfo or modInfo.base == nil or modInfo.base.template_id == nil then
    return PufferConst.ENUM_DownloadState.Not
  end
  local modIdKey = self:_GetCacheKeyByModInfo(modInfo)
  local cacheInfo = self:GetUGCModCacheInfo(modIdKey)
  if cacheInfo.state ~= PufferConst.ENUM_DownloadState.Done then
    local isLoaded = self:_IsCompleteUGCModRes(modInfo)
    if isLoaded then
      cacheInfo.state = PufferConst.ENUM_DownloadState.Done
    end
  end
  return cacheInfo.state
end
function Logic_UGC_Res_Manager:_DownloadModRes(modInfo)
  if not modInfo or modInfo.base == nil or modInfo.base.template_id == nil then
    return false
  end
  local cacheKey = self:_GetCacheKeyByModInfo(modInfo)
  if modInfo.mod_id then
    self:_AddModToLocal(modInfo.mod_id)
  end
  log(bWriteLog and string.format("Logic_UGC_Res_Manager:_DownloadModRes cacheKey = %s", cacheKey))
  local cacheInfo = self:GetUGCModCacheInfo(cacheKey)
  cacheInfo.state = PufferConst.ENUM_DownloadState.Download
  cacheInfo.version = modInfo.base.verify_time
  local AllAssetIDList, AllFeatureKeyList = self:GetAllResList(modInfo)
  local excludeMapKey = self:GetExcludeMapKey(modInfo, AllAssetIDList)
  local mapKey = self:GetUGCMapKeyByTemplateId(modInfo.base.template_id)
  local mapState = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {mapKey}, nil, nil, excludeMapKey)
  if mapState ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:_DownloadModRes download map key:%s state:%d", mapKey, mapState))
    cacheInfo.    local extraData = {}
    extraData.    PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {mapKey}, nil, nil, extraData)
  end
  local puffer_odpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_downloader)
  puffer_odpak_downloader:DownloadByKeyList(PufferConst.ENUM_DownloadType.ODPAK, AllFeatureKeyList)
  if bWriteLog then
    for k, v in pairs(AllFeatureKeyList) do
      printf("Logic_UGC_Res_Manager:_DownloadModRes FeatureKey:%s", v)
    end
  end
  local puffer_ugcpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_downloader)
  puffer_ugcpak_downloader:DownloadByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, AllAssetIDList, nil, nil, {bMinDepends = true})
  if bWriteLog then
    for k, v in pairs(AllAssetIDList) do
      printf("Logic_UGC_Res_Manager:_DownloadModRes AssetID:%s", v)
    end
  end
  local isFinish = false
  if self:_IsCompleteUGCModRes(modInfo) then
    cacheInfo.state = PufferConst.ENUM_DownloadState.Done
    isFinish = true
  end
  self:_SendDownloadTLog(modInfo, "_DownloadModRes", mapState, mapKey, nil, AllAssetIDList)
  if not isFinish and modInfo.mod_id then
    self._trackingMods[modInfo.mod_id] = modInfo
    log(bWriteLog and "Logic_UGC_Res_Manager:_DownloadModRes tracking mod_id = " .. tostring(modInfo.mod_id))
  end
  return isFinish
end
function Logic_UGC_Res_Manager:_PauseModRes(modInfo)
  if not modInfo or modInfo.base == nil or modInfo.base.template_id == nil then
    return false
  end
  local cacheKey = self:_GetCacheKeyByModInfo(modInfo)
  log(bWriteLog and string.format("Logic_UGC_Res_Manager:_PauseModRes cacheKey = %s", cacheKey))
  local cacheInfo = self:GetUGCModCacheInfo(cacheKey)
  cacheInfo.state = PufferConst.ENUM_DownloadState.Pause
  local cacheInfos = self.modResCaches
  local mapKey = cacheInfo.mapKey
  local bExistOtherMapKey = false
  if mapKey then
    for mK, mV in pairs(cacheInfos) do
      if mV.state == PufferConst.ENUM_DownloadState.Download and (mV.mapKey == mapKey or mV.bundleKey) then
        bExistOtherMapKey = true
        break
      end
    end
    if not bExistOtherMapKey then
      log(bWriteLog and "Logic_UGC_Res_Manager:_PauseModRes bExistOtherMapKey == false")
      PufferManager.Pause(PufferConst.ENUM_DownloadType.MAP, {mapKey})
    end
  end
  local ownDepends = cacheInfo.depends
  local onlyDepends = {}
  if ownDepends and 0 < #ownDepends then
    local bExistTeamRes = false
    for dKey, dValue in pairs(ownDepends) do
      local bExistOtherDepends = false
      for curKey, curValue in pairs(cacheInfos) do
        if curValue.state == PufferConst.ENUM_DownloadState.Download and curValue.bundleKey then
          bExistTeamRes = true
          break
        end
        if curValue.state == PufferConst.ENUM_DownloadState.Download and curValue.depends then
          for otherDependsKey, otherDependsValue in pairs(curValue.depends) do
            if dValue == otherDependsValue then
              bExistOtherDepends = true
              break
            end
          end
        end
        if bExistOtherDepends then
          break
        end
      end
      if bExistTeamRes then
        break
      end
      if not bExistOtherDepends then
        table.insert(onlyDepends, dValue)
      end
    end
    if not bExistTeamRes and 0 < #onlyDepends then
      local extraData = {
        bMinDepends = self:_IsPublishMod(modInfo)
      }
      PufferManager.Pause(PufferConst.ENUM_DownloadType.UGCPAK, onlyDepends, nil, nil, extraData)
      if bWriteLog then
        log(bWriteLog and "Logic_UGC_Res_Manager:_PauseModRes onlyDepends start  bMinDepends:" .. tostring(extraData.bMinDepends))
        for _k, _v in pairs(onlyDepends) do
          log(bWriteLog and string.format("Logic_UGC_Res_Manager:_PauseModRes onlyDepends v:%s", tostring(_v)))
        end
        log(bWriteLog and "Logic_UGC_Res_Manager:_PauseModRes onlyDepends end")
      end
    end
  end
  local ownFeatureKeyList = cacheInfo.dependFeatures
  local onlyFeatureKeys = {}
  if ownFeatureKeyList and 0 < #ownFeatureKeyList then
    local bExistTeamRes = false
    for _, featureKey in pairs(ownFeatureKeyList) do
      if bExistTeamRes then
        break
      end
      local bExistOtherFeatureKey = false
      for _, curValue in pairs(cacheInfos) do
        if curValue.state == PufferConst.ENUM_DownloadState.Download and curValue.bundleKey then
          bExistTeamRes = true
          break
        end
        if curValue.state == PufferConst.ENUM_DownloadState.Download and curValue.dependFeatures then
          for _, otherFeatureKey in pairs(curValue.dependFeatures) do
            if featureKey == otherFeatureKey then
              bExistOtherFeatureKey = true
              break
            end
          end
        end
        if bExistOtherFeatureKey then
          break
        end
      end
      if not bExistOtherFeatureKey then
        table.insert(onlyFeatureKeys, featureKey)
      end
    end
    if not bExistTeamRes and 0 < #onlyFeatureKeys then
      local puffer_odpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_downloader)
      puffer_odpak_downloader:PauseByKeyList(PufferConst.ENUM_DownloadType.ODPAK, onlyFeatureKeys)
      if bWriteLog then
        log(bWriteLog and "Logic_UGC_Res_Manager:_PauseModRes onlyFeatureKeys start")
        for _, _v in pairs(onlyFeatureKeys) do
          log(bWriteLog and string.format("Logic_UGC_Res_Manager:_PauseModRes onlyFeatureKeys v:%s", tostring(_v)))
        end
        log(bWriteLog and "Logic_UGC_Res_Manager:_PauseModRes onlyFeatureKeys end")
      end
    end
  end
  self:_SendPauseTLog(modInfo, "PauseModRes", bExistOtherMapKey, mapKey, onlyDepends)
  return true
end
function Logic_UGC_Res_Manager:_GetUGCModResSize(modInfo)
  if not modInfo or modInfo.base == nil or modInfo.base.template_id == nil then
    return 0, 0
  end
  local mapKey = self:GetUGCMapKeyByTemplateId(modInfo.base.template_id)
  if mapKey == nil then
  end
  if modInfo.setting and modInfo.setting.name then
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:_GetUGCModResSize start modName:%s", modInfo.setting.name))
  end
  local AllAssetIDList, AllFeatureKeyList = self:GetAllResList(modInfo)
  local excludeMapKey = self:GetExcludeMapKey(modInfo, AllAssetIDList)
  local cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {mapKey}, nil, excludeMapKey)
  cSize = cSize / PufferConst.MB
  tSize = tSize / PufferConst.MB
  if mapKey then
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:_GetUGCModResSize mapKey =%s, cSize:%.2f, tSize:%.2f", mapKey, cSize, tSize))
  else
    log(bWriteLog and "Logic_UGC_Res_Manager:_GetUGCModResSize mapKey is nil")
  end
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local cFeatureSize, tFeatureSize = PufferODPakManager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.ODPAK, AllFeatureKeyList)
  cSize = cSize + cFeatureSize / PufferConst.MB
  tSize = tSize + tFeatureSize / PufferConst.MB
  local PufferUGCPakManager = self:_GetPufferUGCPakManager()
  local cAssetSize, tAssetSize = PufferUGCPakManager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, AllAssetIDList, nil, true)
  cSize = cSize + cAssetSize / PufferConst.MB
  tSize = tSize + tAssetSize / PufferConst.MB
  return cSize, tSize
end
function Logic_UGC_Res_Manager:_GetUGCModListSize(modList)
  local cSize, tSize = self:_GetUGCBasicResSize()
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local excludeMapKey = PufferMapManager:GetMapDepends(PufferConst.UGC_BASIC_MAPKEY)
  local MapKeyDic = {}
  local AssetIDDic = {}
  local FeatureKeyDic = {}
  for k, v in pairs(modList) do
    local mapKey = self:GetUGCMapKeyByTemplateId(v.base.template_id)
    if mapKey then
      MapKeyDic[mapKey] = true
    end
    local AssetIDList, FeatureKeyList = self:GetAllResList(v)
    if AssetIDList then
      for kk, vv in pairs(AssetIDList) do
        AssetIDDic[vv] = true
      end
    end
    if FeatureKeyList then
      for kk, vv in pairs(FeatureKeyList) do
        FeatureKeyDic[vv] = true
      end
    end
  end
  local MapKeyList = TableUtil.GetKeys(MapKeyDic)
  local mcSize, mtSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, MapKeyList, false, excludeMapKey)
  cSize = cSize + mcSize / PufferConst.MB
  tSize = tSize + mtSize / PufferConst.MB
  local AllAssetIDList = TableUtil.GetKeys(AssetIDDic)
  local PufferUGCPakManager = self:_GetPufferUGCPakManager()
  local idcSize, idtSize = PufferUGCPakManager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, AllAssetIDList, nil, true)
  cSize = cSize + idcSize / PufferConst.MB
  tSize = tSize + idtSize / PufferConst.MB
  local AllFeatureKeyList = TableUtil.GetKeys(FeatureKeyDic)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local cFeatureSize, tFeatureSize = PufferODPakManager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.ODPAK, AllFeatureKeyList)
  cSize = cSize + cFeatureSize / PufferConst.MB
  tSize = tSize + tFeatureSize / PufferConst.MB
  local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
  local cAssetHubSize, tAssetHubSize = LogicUGCAssetHub:GetModListAssetSize(modList)
  cSize = cSize + cAssetHubSize
  tSize = tSize + tAssetHubSize
  return cSize, tSize
end
function Logic_UGC_Res_Manager:_IsCompleteUGCWorkRes(modInfo)
  if not modInfo or modInfo.base == nil or modInfo.base.template_id == nil then
    log(bWriteLog and " Logic_UGC_Res_Manager:_IsCompleteUGCWorkRes: not modInfo or modInfo.base == nil or modInfo.base.template_id == nil")
    return false
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local isInTeam = TeamUpNewSystem.IsInTeam()
  if isInTeam then
    if LogicPufferBundle.GetBundleState(PufferConst.UGC_BUNDLE_ID) ~= PufferConst.ENUM_DownloadState.Done then
      log(bWriteLog and " Logic_UGC_Res_Manager:_IsCompleteUGCWorkRes: UGCBundle false")
      return false
    end
  else
    local AllAssetIDList, AllFeatureKeyList = self:_GetNotPublishModResList(modInfo)
    local PufferUGCPakManager = self:_GetPufferUGCPakManager()
    if PufferUGCPakManager:GetStateByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, AllAssetIDList) ~= PufferConst.ENUM_DownloadState.Done then
      log(bWriteLog and string.format("Logic_UGC_Res_Manager:_IsCompleteUGCWorkRes: AllAssetIDList Not Done, template_id:%d", modInfo.base.template_id))
      return false
    end
    local puffer_odpak_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
    if puffer_odpak_manager:GetStateByKeyList(PufferConst.ENUM_DownloadType.ODPAK, AllFeatureKeyList) ~= PufferConst.ENUM_DownloadState.Done then
      log(bWriteLog and string.format("Logic_UGC_Res_Manager:_IsCompleteUGCWorkRes: AllFeatureKeyList Not Done, template_id:%d", modInfo.base.template_id))
      return false
    end
    if not IsWoWEditor and PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
      PufferConst.UGC_EDIT_MAPKEY
    }) ~= PufferConst.ENUM_DownloadState.Done then
      log(bWriteLog and string.format("Logic_UGC_Res_Manager:_IsCompleteUGCWorkRes: Editor Map Not Done, template_id:%d", modInfo.base.template_id))
      return false
    end
  end
  local mapKey = self:GetUGCMapKeyByTemplateId(modInfo.base.template_id)
  if mapKey == nil then
    log(bWriteLog and string.format(" Logic_UGC_Res_Manager:_IsCompleteUGCWorkRes: mapKey == nil template_id:%d", modInfo.base.template_id))
  else
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {mapKey})
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:_IsCompleteUGCWorkRes mapKey:%s ,state:%d", mapKey, state))
    if state ~= PufferConst.ENUM_DownloadState.Done then
      return false
    end
  end
  return true
end
function Logic_UGC_Res_Manager:_GetUGCWorkResState(modInfo)
  local cacheKey = self:_GetCacheKeyByModInfo(modInfo, true)
  local cacheInfo = self:GetUGCModCacheInfo(cacheKey)
  local isLoaded = self:_IsCompleteUGCWorkRes(modInfo)
  if isLoaded then
    cacheInfo.state = PufferConst.ENUM_DownloadState.Done
  elseif cacheInfo.state == PufferConst.ENUM_DownloadState.Done then
    cacheInfo.state = PufferConst.ENUM_DownloadState.Update
  end
  return cacheInfo.state
end
function Logic_UGC_Res_Manager:_DownloadWorkRes(modInfo)
  if not modInfo or modInfo.base == nil or modInfo.base.template_id == nil then
    return false
  end
  local cacheKey = self:_GetCacheKeyByModInfo(modInfo, true)
  log(bWriteLog and string.format("Logic_UGC_Res_Manager:_DownloadWorkRes cacheKey =%s", cacheKey))
  local cacheInfo = self:GetUGCModCacheInfo(cacheKey)
  cacheInfo.state = PufferConst.ENUM_DownloadState.Download
  local mapKey = self:GetUGCMapKeyByTemplateId(modInfo.base.template_id)
  local mapState = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {mapKey})
  if mapState ~= PufferConst.ENUM_DownloadState.Done then
    PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {mapKey})
    cacheInfo.    log(bWriteLog and string.format("Logic_UGC_Res_Manager:_DownloadWorkRes downloadMapKey key:%s ,state:%d", mapKey, mapState))
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local isInTeam = TeamUpNewSystem.IsInTeam()
  if not isInTeam then
    local AllAssetIDList, AllFeatureKeyList = self:_GetNotPublishModResList(modInfo)
    local puffer_ugcpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_downloader)
    puffer_ugcpak_downloader:DownloadByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, AllAssetIDList)
    local puffer_odpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_downloader)
    puffer_odpak_downloader:DownloadByKeyList(PufferConst.ENUM_DownloadType.ODPAK, AllFeatureKeyList)
    if PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
      PufferConst.UGC_EDIT_MAPKEY
    }) ~= PufferConst.ENUM_DownloadState.Done then
      PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {
        PufferConst.UGC_EDIT_MAPKEY
      })
    end
  else
    local bundleLoaded = true
    if LogicPufferBundle.GetBundleState(PufferConst.UGC_BUNDLE_ID) ~= PufferConst.ENUM_DownloadState.Done then
      log(bWriteLog and "Logic_UGC_Res_Manager:_DownloadWorkRes bundle need download")
      bundleLoaded = false
      cacheInfo.bundleKey = PufferConst.UGC_BUNDLE_ID
      LogicPufferBundle.DownloadBundle(PufferConst.UGC_BUNDLE_ID)
    else
      log(bWriteLog and "Logic_UGC_Res_Manager:_DownloadWorkRes bundle loaded")
    end
  end
  local isFinish = false
  if self:_IsCompleteUGCWorkRes(modInfo) then
    cacheInfo.state = PufferConst.ENUM_DownloadState.Done
    isFinish = true
  end
  return isFinish
end
function Logic_UGC_Res_Manager:_PauseWorkRes(modInfo)
  if not modInfo or modInfo.base == nil or modInfo.base.template_id == nil then
    return false
  end
  local cacheKey = self:_GetCacheKeyByModInfo(modInfo, true)
  log(bWriteLog and string.format("Logic_UGC_Res_Manager:_PauseWorkRes cacheKey = %s", cacheKey))
  local cacheInfo = self:GetUGCModCacheInfo(cacheKey)
  cacheInfo.state = PufferConst.ENUM_DownloadState.Pause
  local mapKey = cacheInfo.mapKey
  local bExistOtherMapKey = false
  if mapKey then
    for mK, mV in pairs(self.modResCaches) do
      if mV.state == PufferConst.ENUM_DownloadState.Download and (mV.mapKey == mapKey or mV.bundleKey) then
        bExistOtherMapKey = true
        break
      end
    end
    if not bExistOtherMapKey then
      PufferManager.Pause(PufferConst.ENUM_DownloadType.MAP, {mapKey})
    end
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local isInTeam = TeamUpNewSystem.IsInTeam()
  if not isInTeam then
    local cacheInfos = self.modResCaches
    local ownDepends = cacheInfo.depends
    local onlyDepends = {}
    if ownDepends and 0 < #ownDepends then
      local bExistTeamRes = false
      for dKey, dValue in pairs(ownDepends) do
        local bExistOtherDepends = false
        for curKey, curValue in pairs(cacheInfos) do
          if curValue.state == PufferConst.ENUM_DownloadState.Download and curValue.bundleKey then
            bExistTeamRes = true
            break
          end
          if curValue.state == PufferConst.ENUM_DownloadState.Download and curValue.depends then
            for otherDependsKey, otherDependsValue in pairs(curValue.depends) do
              if dValue == otherDependsValue then
                bExistOtherDepends = true
                break
              end
            end
          end
          if bExistOtherDepends == true then
            break
          end
        end
        if bExistTeamRes then
          break
        end
        if not bExistOtherDepends then
          table.insert(onlyDepends, dValue)
        end
      end
      if not bExistTeamRes and 0 < #onlyDepends then
        PufferManager.Pause(PufferConst.ENUM_DownloadType.UGCPAK, onlyDepends)
        if bWriteLog then
          log(bWriteLog and "Logic_UGC_Res_Manager:_PauseWorkRes onlyDepends start")
          for _k, _v in pairs(onlyDepends) do
            log(bWriteLog and string.format("Logic_UGC_Res_Manager:_PauseWorkRes onlyDepends v:%s", tostring(_v)))
          end
          log(bWriteLog and "Logic_UGC_Res_Manager:_PauseWorkRes onlyDepends end")
        end
      end
    end
    local ownFeatureKeyList = cacheInfo.dependFeatures
    local onlyFeatureKeys = {}
    if ownFeatureKeyList and 0 < #ownFeatureKeyList then
      local bExistTeamRes = false
      for _, featureKey in pairs(ownFeatureKeyList) do
        if bExistTeamRes then
          break
        end
        local bExistOtherFeatureKey = false
        for _, curValue in pairs(cacheInfos) do
          if curValue.state == PufferConst.ENUM_DownloadState.Download and curValue.bundleKey then
            bExistTeamRes = true
            break
          end
          if curValue.state == PufferConst.ENUM_DownloadState.Download and curValue.dependFeatures then
            for _, otherFeatureKey in pairs(curValue.dependFeatures) do
              if featureKey == otherFeatureKey then
                bExistOtherFeatureKey = true
                break
              end
            end
          end
          if bExistOtherFeatureKey then
            break
          end
        end
        if not bExistOtherFeatureKey then
          table.insert(onlyFeatureKeys, featureKey)
        end
      end
      if not bExistTeamRes and 0 < #onlyFeatureKeys then
        local puffer_odpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_downloader)
        puffer_odpak_downloader:PauseByKeyList(PufferConst.ENUM_DownloadType.ODPAK, onlyFeatureKeys)
        if bWriteLog then
          log(bWriteLog and "Logic_UGC_Res_Manager:_PauseWorkRes onlyFeatureKeys start")
          for _, _v in pairs(onlyFeatureKeys) do
            log(bWriteLog and string.format("Logic_UGC_Res_Manager:_PauseWorkRes onlyFeatureKeys v:%s", tostring(_v)))
          end
          log(bWriteLog and "Logic_UGC_Res_Manager:_PauseWorkRes onlyFeatureKeys end")
        end
      end
    end
    local bExistOther20W = false
    for mK, mV in pairs(self.modResCaches) do
      if mV.state == PufferConst.ENUM_DownloadState.Download and mV.packKey and mV.packKey == PufferConst.EODPackID.WOW_20W then
        bExistOther20W = true
        break
      end
    end
    if not bExistOther20W then
      LogicPufferBundle.StopDownloadPackList({
        PufferConst.EODPackID.WOW_20W
      })
      PufferManager.Pause(PufferConst.ENUM_DownloadType.MAP, {
        PufferConst.UGC_EDIT_MAPKEY
      })
    end
    return
  else
    local existOtherBundle = false
    for mK, mV in pairs(self.modResCaches) do
      if mV.state == PufferConst.ENUM_DownloadState.Download and mV.bundleKey then
        existOtherBundle = true
        break
      end
    end
    if existOtherBundle == false then
      LogicPufferBundle.StopDownloadBundle(PufferConst.UGC_BUNDLE_ID)
    end
    self:_SendPauseTLog(modInfo, "PauseWorkRes", bExistOtherMapKey, mapKey, nil, nil, existOtherBundle)
  end
  return true
end
function Logic_UGC_Res_Manager:_GetUGCWorkResSize(modInfo)
  if not modInfo or modInfo.base == nil or modInfo.base.template_id == nil then
    return 0, 0
  end
  local mapKey = self:GetUGCMapKeyByTemplateId(modInfo.base.template_id)
  local cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {mapKey})
  cSize = cSize / PufferConst.MB
  tSize = tSize / PufferConst.MB
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local isInTeam = TeamUpNewSystem.IsInTeam()
  if not isInTeam then
    local tempcSize, temptSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {
      PufferConst.UGC_EDIT_MAPKEY
    })
    cSize = cSize + tempcSize / PufferConst.MB
    tSize = tSize + temptSize / PufferConst.MB
    local AllAssetIDList, AllFeatureKeyList = self:_GetNotPublishModResList(modInfo)
    local puffer_odpak_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
    tempcSize, temptSize = puffer_odpak_manager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.ODPAK, AllFeatureKeyList)
    cSize = cSize + tempcSize / PufferConst.MB
    tSize = tSize + temptSize / PufferConst.MB
    local PufferUGCPakManager = self:_GetPufferUGCPakManager()
    tempcSize, temptSize = PufferUGCPakManager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, AllAssetIDList, nil, true)
    cSize = cSize + tempcSize / PufferConst.MB
    tSize = tSize + temptSize / PufferConst.MB
    return cSize, tSize
  else
    local bcSize, btSize = self:GetUGCBundleSize()
    cSize = cSize + bcSize
    tSize = tSize + btSize
    return cSize, tSize
  end
end
function Logic_UGC_Res_Manager:_IsCompleteUGCTemplateRes(templateId)
  local TemplateInfo = Config_UGC.GetTemplateConfigByID(templateId)
  if not TemplateInfo then
    return false
  end
  local State = self:_GetUGCTemplateResState(TemplateInfo)
  if State ~= PufferConst.ENUM_DownloadState.Done then
    return false
  end
  return true
end
function Logic_UGC_Res_Manager:_GetUGCTemplateResState(templateInfo)
  local mapKey = self:GetUGCMapKeyByTemplateId(templateInfo.ID, templateInfo.MapID)
  if mapKey == nil then
  else
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:_GetUGCTemplateResState mapkey:%s", mapKey))
  end
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {mapKey})
  log(bWriteLog and string.format("Logic_UGC_Res_Manager:_GetUGCTemplateResState map State:%d", state))
  if state == PufferConst.ENUM_DownloadState.Done and not IsWoWEditor then
    state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
      PufferConst.UGC_EDIT_MAPKEY
    })
    log(bWriteLog and " Logic_UGC_Res_Manager:_GetUGCTemplateResState creative edit state : " .. state)
  end
  if state == PufferConst.ENUM_DownloadState.Done then
    local AllAssetIDList, AllFeatureKeyList = self:_GetNotPublishModResList(templateInfo)
    local PufferUGCPakManager = self:_GetPufferUGCPakManager()
    state = PufferUGCPakManager:GetStateByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, AllAssetIDList)
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:_GetUGCTemplateResState UGCPAK state:%d", state))
    if state == PufferConst.ENUM_DownloadState.Done then
      local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
      state = PufferODPakManager:GetStateByKeyList(PufferConst.ENUM_DownloadType.ODPAK, AllFeatureKeyList)
      log(bWriteLog and string.format("Logic_UGC_Res_Manager:_GetUGCTemplateResState ODPAK state:%d", state))
    end
    if state ~= PufferConst.ENUM_DownloadState.Done and bWriteLog and AllAssetIDList then
      for k, v in pairs(AllAssetIDList) do
        local AssetState = PufferUGCPakManager:GetStateByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, {v})
        if AssetState ~= PufferConst.ENUM_DownloadState.Done then
          printf("Logic_UGC_Res_Manager:_GetUGCTemplateResState AssetID:%s,State:%s", v, AssetState)
        end
      end
    end
  end
  if state ~= PufferConst.ENUM_DownloadState.Done then
    local cacheKey = self:_GetCacheKeyByTemplateInfoID(templateInfo.ID)
    local cacheInfo = self:GetUGCModCacheInfo(cacheKey)
    state = cacheInfo.state
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:_GetUGCTemplateResState cache State:%d", state))
    if state == PufferConst.ENUM_DownloadState.Done then
      state = PufferConst.ENUM_DownloadState.Update
      cacheInfo.state = PufferConst.ENUM_DownloadState.Update
      log(bWriteLog and "Logic_UGC_Res_Manager:_GetUGCTemplateResState state is update")
    end
  end
  return state
end
function Logic_UGC_Res_Manager:_DownloadTemplateRes(templateInfo)
  local cacheKey = self:_GetCacheKeyByTemplateInfoID(templateInfo.ID)
  local mapKey = self:GetUGCMapKeyByTemplateId(templateInfo.ID, templateInfo.MapID)
  if mapKey then
    local isFinish = false
    local mapState
    local loadedBundle = true
    local idList
    local cacheInfo = self:GetUGCModCacheInfo(cacheKey)
    if self:_IsCompleteUGCTemplateRes(templateInfo.ID) then
      cacheInfo.state = PufferConst.ENUM_DownloadState.Done
      isFinish = true
      log(bWriteLog and string.format("Logic_UGC_Res_Manager:_DownloadTemplateRes res had finish , ID:%d", templateInfo.ID))
    else
      local AllAssetIDList, AllFeatureKeyList = self:_GetNotPublishModResList(templateInfo)
      idList = AllAssetIDList
      cacheInfo.depends = AllAssetIDList
      local PufferUGCPakManager = self:_GetPufferUGCPakManager()
      local idState = PufferUGCPakManager:GetStateByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, AllAssetIDList)
      if idState ~= PufferConst.ENUM_DownloadState.Done then
        log(bWriteLog and string.format("Logic_UGC_Res_Manager:_DownloadTemplateRes download idListstate:%d", idState))
        PufferManager.Download(PufferConst.ENUM_DownloadType.UGCPAK, AllAssetIDList)
      end
      local puffer_odpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_downloader)
      puffer_odpak_downloader:DownloadByKeyList(PufferConst.ENUM_DownloadType.ODPAK, AllFeatureKeyList)
      if PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
        PufferConst.UGC_EDIT_MAPKEY
      }) ~= PufferConst.ENUM_DownloadState.Done then
        log(bWriteLog and string.format("Logic_UGC_Res_Manager:_DownloadTemplateRes download creative edit"))
        PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {
          PufferConst.UGC_EDIT_MAPKEY
        })
      end
      mapState = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {mapKey})
      if mapState ~= PufferConst.ENUM_DownloadState.Done then
        PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {mapKey})
        cacheInfo.        log(bWriteLog and "Logic_UGC_Res_Manager:_DownloadTemplateRes mapkey not finish:" .. mapKey)
      end
      cacheInfo.state = PufferConst.ENUM_DownloadState.Download
      log(bWriteLog and string.format("Logic_UGC_Res_Manager:_DownloadTemplateRes res not finish , ID:%d", templateInfo.ID))
    end
    self:_SendDownloadTLog(templateInfo, "_DownloadTemplateRes", mapState, mapKey, nil, idList, nil, loadedBundle)
    return isFinish
  else
    log(bWriteLog and string.format("Logic_UGC_Res_Manager:_DownloadTemplateRes mapkey is nil , ID:%d", templateInfo.ID))
    return true
  end
end
function Logic_UGC_Res_Manager:_PauseTemplateRes(templateInfo)
  local cacheKey = self:_GetCacheKeyByTemplateInfoID(templateInfo.ID)
  if not cacheKey then
    return
  end
  local cacheInfo = self:GetUGCModCacheInfo(cacheKey)
  cacheInfo.state = PufferConst.ENUM_DownloadState.Pause
  local cacheInfos = self.modResCaches
  local bExistOtherMapKey = false
  if cacheInfo.mapKey then
    for mK, mV in pairs(cacheInfos) do
      if mV.state == PufferConst.ENUM_DownloadState.Download and mV.mapKey == cacheInfo.mapKey then
        bExistOtherMapKey = true
        break
      end
    end
    if not bExistOtherMapKey then
      PufferManager.Pause(PufferConst.ENUM_DownloadType.MAP, {
        cacheInfo.mapKey
      })
    end
  end
  local ownDepends = cacheInfo.depends
  local onlyDepends = {}
  if ownDepends and 0 < #ownDepends then
    local bExistTeamRes = false
    for dKey, dValue in pairs(ownDepends) do
      local bExistOtherDepends = false
      for curKey, curValue in pairs(cacheInfos) do
        if curValue.state == PufferConst.ENUM_DownloadState.Download and curValue.bundleKey then
          bExistTeamRes = true
          break
        end
        if curValue.state == PufferConst.ENUM_DownloadState.Download and curValue.depends then
          for otherDependsKey, otherDependsValue in pairs(curValue.depends) do
            if dValue == otherDependsValue then
              bExistOtherDepends = true
              break
            end
          end
        end
        if bExistOtherDepends then
          break
        end
      end
      if bExistTeamRes then
        break
      end
      if not bExistOtherDepends then
        table.insert(onlyDepends, dValue)
      end
    end
    if not bExistTeamRes and 0 < #onlyDepends then
      if bWriteLog then
        log(bWriteLog and "Logic_UGC_Res_Manager:_PauseTemplateRes onlyDepends start")
        for _k, _v in pairs(onlyDepends) do
          log(bWriteLog and string.format("Logic_UGC_Res_Manager:_PauseTemplateRes onlyDepends v:%s", tostring(_v)))
        end
        log(bWriteLog and "Logic_UGC_Res_Manager:_PauseTemplateRes onlyDepends end")
      end
      PufferManager.Pause(PufferConst.ENUM_DownloadType.UGCPAK, onlyDepends)
    end
  end
  local bExistOther20W = false
  for mK, mV in pairs(cacheInfos) do
    if mV.state == PufferConst.ENUM_DownloadState.Download and mV.packKey and mV.packKey == PufferConst.EODPackID.WOW_20W then
      bExistOther20W = true
      break
    end
  end
  if not bExistOther20W then
    LogicPufferBundle.StopDownloadPackList({
      PufferConst.EODPackID.WOW_20W
    })
    PufferManager.Pause(PufferConst.ENUM_DownloadType.MAP, {
      PufferConst.UGC_EDIT_MAPKEY
    })
  end
  self:_SendPauseTLog(templateInfo, "PauseTemplateRes", bExistOtherMapKey, cacheInfo.mapKey, onlyDepends, nil, nil)
end
function Logic_UGC_Res_Manager:_GetUGCTemplateResSize(templateInfo)
  local mapKey = self:GetUGCMapKeyByTemplateId(templateInfo.ID, templateInfo.MapID)
  local cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {mapKey})
  cSize = cSize / PufferConst.MB
  tSize = tSize / PufferConst.MB
  log(bWriteLog and string.format("Logic_UGC_Res_Manager:_GetUGCTemplateResSize mapkey:%s , cSize:%.2f ,tSize:%.2f", mapKey, cSize, tSize))
  local tempcSize, temptSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {
    PufferConst.UGC_EDIT_MAPKEY
  })
  cSize = cSize + tempcSize / PufferConst.MB
  tSize = tSize + temptSize / PufferConst.MB
  local AllAssetIDList, AllFeatureKeyList = self:_GetNotPublishModResList(templateInfo)
  local puffer_odpak_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  tempcSize, temptSize = puffer_odpak_manager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.ODPAK, AllFeatureKeyList)
  cSize = cSize + tempcSize / PufferConst.MB
  tSize = tSize + temptSize / PufferConst.MB
  local PufferUGCPakManager = self:_GetPufferUGCPakManager()
  tempcSize, temptSize = PufferUGCPakManager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, AllAssetIDList, nil, true)
  cSize = cSize + tempcSize / PufferConst.MB
  tSize = tSize + temptSize / PufferConst.MB
  return cSize, tSize
end
function Logic_UGC_Res_Manager:_GetUGCMapConfigByTemplateId(templateId, mapID)
  if mapID == nil then
    local templateConfig = CDataTable.GetTableData("UGCTemplateConfig", templateId)
    if templateConfig == nil then
      return nil
    end
    mapID = templateConfig.MapID
  else
    print(bWriteLog and "Logic_UGC_Res_Manager:_GetUGCMapConfigByTemplateId  have MapID " .. tostring(mapID))
  end
  local mapConfig = CDataTable.GetTableData("Map", mapID)
  if mapConfig == nil then
    return nil
  end
  return mapConfig
end
function Logic_UGC_Res_Manager:_GetUGCTemplateListSize(TemplateList)
  local cSize, tSize = self:_GetUGCBasicResSize()
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local excludeMapKey = PufferMapManager:GetMapDepends(PufferConst.UGC_BASIC_MAPKEY)
  local mapKeyDic = {}
  local idDic = {}
  local FeatureKeyDic = {}
  for i, v in ipairs(TemplateList) do
    local mapKey = self:GetUGCMapKeyByTemplateId(v.ID)
    if mapKey then
      mapKeyDic[mapKey] = true
    end
    local AllAssetIDList, AllFeatureKeyList = self:_GetNotPublishModResList(v)
    if AllAssetIDList then
      for kk, vv in pairs(AllAssetIDList) do
        idDic[vv] = true
      end
    end
    if AllFeatureKeyList then
      for kk, vv in pairs(AllFeatureKeyList) do
        FeatureKeyDic[vv] = true
      end
    end
  end
  local mapKeyList = TableUtil.GetKeys(mapKeyDic)
  local mcSize, mtSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, mapKeyList, false, excludeMapKey)
  cSize = cSize + mcSize / PufferConst.MB
  tSize = tSize + mtSize / PufferConst.MB
  local idList = TableUtil.GetKeys(idDic)
  local PufferUGCPakManager = self:_GetPufferUGCPakManager()
  local idcSize, idtSize = PufferUGCPakManager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, idList, nil, true)
  cSize = cSize + idcSize / PufferConst.MB
  tSize = tSize + idtSize / PufferConst.MB
  local FeatureKeyList = TableUtil.GetKeys(FeatureKeyDic)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local cFeatureSize, tFeatureSize = PufferODPakManager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.ODPAK, FeatureKeyList)
  cSize = cSize + cFeatureSize / PufferConst.MB
  tSize = tSize + tFeatureSize / PufferConst.MB
  local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
  local cAssetHubSize, tAssetHubSize = LogicUGCAssetHub:GetModListAssetSize(TemplateList)
  cSize = cSize + cAssetHubSize
  tSize = tSize + tAssetHubSize
  return cSize, tSize
end
function Logic_UGC_Res_Manager:_GetUGCBasicResSize()
  local cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {
    PufferConst.UGC_BASIC_MAPKEY
  })
  cSize = cSize / PufferConst.MB
  tSize = tSize / PufferConst.MB
  return cSize, tSize
end
function Logic_UGC_Res_Manager:_GetUGCEditResSize()
  local cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {
    PufferConst.UGC_EDIT_MAPKEY
  })
  cSize = cSize / PufferConst.MB
  tSize = tSize / PufferConst.MB
  return cSize, tSize
end
function Logic_UGC_Res_Manager:GetDependAssetParamsByIntMap(feature_id_list)
  feature_id_list = feature_id_list or {}
  local bitList = {}
  local size = 32
  for k, v in pairs(feature_id_list) do
    if v and 0 < v then
      local margin = size * (k - 1)
      local tmpList = FuncUtil.Int2ByteList(v)
      if tmpList ~= nil then
        for bitKey, bitV in ipairs(tmpList) do
          bitV = bitV + margin
          table.insert(bitList, bitV)
        end
      end
    end
  end
  local idList = {}
  for k, v in ipairs(bitList) do
    table.insert(idList, v)
  end
  return idList
end
function Logic_UGC_Res_Manager:_RemoveReportResTimer()
  if self.reportTimer then
    self:RemoveCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_SELECT_CHANGE)
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.reportTimer)
    self.reportTimer = nil
    self.reportModInfo = nil
    self.bReportPauseState = nil
    self.state = nil
  end
end
function Logic_UGC_Res_Manager:_GetCacheKeyByModInfo(modInfo, bMyWork)
  local cacheKey
  if modInfo then
    if modInfo.mod_id then
      if bMyWork then
        cacheKey = modInfo.mod_id .. "_update"
      else
        cacheKey = modInfo.mod_id
      end
    elseif modInfo.base.uid and modInfo.base.slot then
      cacheKey = tostring(modInfo.base.uid) .. "_" .. tostring(modInfo.base.slot)
    elseif modInfo.base.template_id then
      cacheKey = modInfo.base.template_id .. "_no_id"
    end
  else
    cacheKey = "no_cachekey"
    log(bWriteLog and "Logic_UGC_Res_Manager:_GetCacheKeyByModInfo cachekey is :no_cachekey")
  end
  return cacheKey
end
function Logic_UGC_Res_Manager:_GetCacheKeyByTemplateInfoID(templateInfoID)
  local cacheKey
  local mapKey = self:GetUGCMapKeyByTemplateId(templateInfoID)
  if mapKey ~= nil then
    cacheKey = mapKey .. tostring(templateInfoID)
  else
    cacheKey = "no_templateKey"
  end
  return cacheKey
end
function Logic_UGC_Res_Manager:_IsPublishMod(modInfo)
  if not self.bResListMinDepends then
    return false
  end
  return modInfo.mod_id ~= nil
end
function Logic_UGC_Res_Manager:_GetPufferUGCPakManager()
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  return PufferUGCPakManager
end
function Logic_UGC_Res_Manager:_GetLocalModList()
  if self.localModList == nil then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    self.localModList = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCCacheLocalMod)
    if self.localModList == nil then
      self.localModList = {}
    end
  end
  return self.localModList
end
function Logic_UGC_Res_Manager:_AddModToLocal(modId)
  local localModList = self:_GetLocalModList()
  for k, v in ipairs(localModList) do
    if v == modId then
      table.remove(localModList, k)
      break
    end
  end
  table.insert(localModList, 1, modId)
  local limit = 50
  local num = #localModList
  if limit < num then
    local surp = num - limit
    for i = 1, surp do
      table.remove(localModList, num - i + 1)
    end
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(localModList, PlayerPrefsSystem.ePlayerPrefsType.eUGCCacheLocalMod)
end
function Logic_UGC_Res_Manager:_SendDownloadTLog(modInfo, key, mapState, mapKey, idState, idList, basicLoaded, bundleLoaded)
  local tlogExtra = {}
  if modInfo then
    if modInfo.mod_id then
      tlogExtra.modid = modInfo.mod_id
    elseif modInfo.base and modInfo.base.slot then
      tlogExtra.slot = modInfo.base.slot
    elseif modInfo.id then
      tlogExtra.id = modInfo.ID
    end
    if modInfo.setting and modInfo.setting.name then
      tlogExtra.modname = modInfo.setting.name
    elseif modInfo.DefaultCreateName then
      tlogExtra.modname = modInfo.DefaultCreateName
    end
  end
  if mapState ~= PufferConst.ENUM_DownloadState.Done then
    tlogExtra.mapkey = mapKey
  end
  if idState ~= PufferConst.ENUM_DownloadState.Done then
    tlogExtra.idlist = idList
  end
  if basicLoaded == false then
    tlogExtra.basic = 1
  end
  if bundleLoaded == false then
    tlogExtra.bundle = 1
  end
  PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.UGCDownload, PufferTlog.Enum_TLog_Optype.Start, key, tlogExtra)
end
function Logic_UGC_Res_Manager:_SendPauseTLog(modInfo, key, bExistOtherMapKey, mapKey, idList, existOtherBasic, existBundle)
  local tlogExtra = {}
  if modInfo then
    if modInfo.mod_id then
      tlogExtra.modid = modInfo.mod_id
    elseif modInfo.base and modInfo.base.slot then
      tlogExtra.slot = modInfo.base.slot
    elseif modInfo.id then
      tlogExtra.id = modInfo.ID
    end
    if modInfo.setting and modInfo.setting.name then
      tlogExtra.modname = modInfo.setting.name
    elseif modInfo.DefaultCreateName then
      tlogExtra.modname = modInfo.DefaultCreateName
    end
  end
  if bExistOtherMapKey and mapKey then
    tlogExtra.mapkey = mapKey
  end
  if idList and 0 < #idList then
    tlogExtra.idlist = idList
  end
  if existOtherBasic then
    tlogExtra.basic = 1
  end
  if existBundle then
    tlogExtra.bundle = 1
  end
  PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.UGCPause, PufferTlog.Enum_TLog_Optype.Cancel, key, tlogExtra)
end
function Logic_UGC_Res_Manager:_GetTlogCacheTime()
  if self.existTimeCache == nil then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local timeCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCTLogTimeCacheKey)
    if timeCache == nil then
      timeCache = {}
    end
    self.existTimeCache = timeCache
  end
  return self.existTimeCache
end
function Logic_UGC_Res_Manager:_GetTlogLastTimeByKey(key)
  local timeCache = self:_GetTlogCacheTime()
  local lastTime = timeCache[key]
  if lastTime == nil then
    lastTime = 0
  end
  return lastTime
end
function Logic_UGC_Res_Manager:_CheckReportResState(modInfo, bReportPauseState, state)
  self.reportModInfo = modInfo
  self.  self.  if self.reportTimer == nil then
    self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_SELECT_CHANGE, self.CheckMatchInfoChange, self)
    local time_ticker = require("common.time_ticker")
    self.reportTimer = time_ticker.AddTimerLoop(1, function()
      self:Send_update_client_mod_info_ByModInfo(self.reportModInfo, true, self.bReportPauseState, self.state)
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NOTIFY_THEME_RES_INFO)
    end, TIMER_INFINITE, 1)
  end
end
function Logic_UGC_Res_Manager:_SaveTlogTime(key)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local existTimeCache = self:_GetTlogCacheTime()
  existTimeCache[key] = serverTime
  PlayerPrefsSystem.SaveTableToFile_N(existTimeCache, PlayerPrefsSystem.ePlayerPrefsType.eUGCTLogTimeCacheKey)
end
function Logic_UGC_Res_Manager:_GetModVersion(ModInfo)
  if ModInfo and ModInfo.base then
    return ModInfo.base.version or 10000
  end
  return 10000
end
function Logic_UGC_Res_Manager:_IsNewMeta(ModInfo)
  if ModInfo and ModInfo.base and ModInfo.base.template_id and ModInfo.base.template_id == 59 then
    return true, 10019
  end
  local version = self:_GetModVersion(ModInfo)
  return version >= Config_UGC.MetaWithAssetParamVersion, version
end
function Logic_UGC_Res_Manager:_GetResTypeDepends(ResTypeList)
  if ResTypeList == nil then
    return {}, {}
  end
  local DependFeatureKeysMap = {}
  local DependAssetIDsMap = {}
  for k, ResType in pairs(ResTypeList) do
    local PufferUGCPakManager = self:_GetPufferUGCPakManager()
    local AllDependFeatureKeys = PufferUGCPakManager.AllResTypeFeatureMap[ResType]
    if AllDependFeatureKeys then
      for FeatureID, v in pairs(AllDependFeatureKeys) do
        DependFeatureKeysMap[FeatureID] = true
      end
    end
    local AllDependAssetID = PufferUGCPakManager.AllResTypeAssetIDMap[ResType]
    if AllDependAssetID then
      for AssetID, v in pairs(AllDependAssetID) do
        DependAssetIDsMap[AssetID] = true
      end
    end
  end
  local DependFeatureKeys = {}
  local DependAssetIDs = {}
  for k, v in pairs(DependFeatureKeysMap) do
    table.insert(DependFeatureKeys, k)
  end
  for k, v in pairs(DependAssetIDsMap) do
    table.insert(DependAssetIDs, k)
  end
  return DependFeatureKeys, DependAssetIDs
end
function Logic_UGC_Res_Manager:_GetAssetParamDepends(AssetParamList)
  local PufferUGCPakManager = self:_GetPufferUGCPakManager()
  local DependFeatureKeysMap = {}
  local DependAssetIDMap = {}
  for k, AssetParamID in pairs(AssetParamList) do
    local AssetParamInfo = PufferUGCPakManager.AllAssetParamsMap[AssetParamID]
    if AssetParamInfo then
      for k, v in pairs(AssetParamInfo.DependFeatureIDList) do
        DependFeatureKeysMap[v] = true
      end
      for k, v in pairs(AssetParamInfo.DependAssetIDList) do
        DependAssetIDMap[v] = true
      end
      if AssetParamID == 422 then
        local resTypeFeatureMap = PufferUGCPakManager.AllResTypeFeatureMap[3]
        if resTypeFeatureMap then
          for featureKey, _ in pairs(resTypeFeatureMap) do
            DependFeatureKeysMap[featureKey] = true
          end
        end
      end
    end
  end
  local DependFeatureKeysList = {}
  local DependAssetIDList = {}
  for k, v in pairs(DependFeatureKeysMap) do
    table.insert(DependFeatureKeysList, k)
  end
  for k, v in pairs(DependAssetIDMap) do
    table.insert(DependAssetIDList, k)
  end
  return DependFeatureKeysList, DependAssetIDList
end
function Logic_UGC_Res_Manager:_GetNotPublishModResList(ModInfo)
  local AllFeatureKeyMap = {}
  local AllAssetIDMap = {}
  local CacheInfo, CacheKey
  if self:IsTemplate(ModInfo) then
    CacheKey = self:_GetCacheKeyByTemplateInfoID(ModInfo.ID)
  else
    CacheKey = self:_GetCacheKeyByModInfo(ModInfo, true)
  end
  CacheInfo = self:GetUGCModCacheInfo(CacheKey)
  if CacheInfo and CacheInfo.AllAssetIDList and CacheInfo.AllFeatureKeyList then
    return CacheInfo.AllAssetIDList, CacheInfo.AllFeatureKeyList
  end
  local DependAssetIDList1, DependFeatureKeysList1 = self:GetAllResList(ModInfo, true)
  if DependAssetIDList1 then
    for k, v in pairs(DependAssetIDList1) do
      AllAssetIDMap[v] = true
    end
  end
  if DependFeatureKeysList1 then
    for k, v in pairs(DependFeatureKeysList1) do
      AllFeatureKeyMap[v] = true
    end
  end
  if not IsWoWEditor then
    for k, v in pairs(self.AssetIDIn20W) do
      AllAssetIDMap[k] = true
    end
    local PufferUGCPakManager = self:_GetPufferUGCPakManager()
    if PufferUGCPakManager.PackFeatureList and PufferUGCPakManager.PackFeatureList[PufferConst.EODPackID.WOW_20W] then
      for k, v in pairs(PufferUGCPakManager.PackFeatureList[PufferConst.EODPackID.WOW_20W]) do
        AllFeatureKeyMap[v] = true
      end
    end
    local DependFeatureKeysList3, DependAssetIDList3 = self:_GetResTypeDepends(Config_UGC.EditorTypeDependResType)
    if DependAssetIDList3 then
      for k, v in pairs(DependAssetIDList3) do
        AllAssetIDMap[v] = true
      end
    end
    if DependFeatureKeysList3 then
      for k, v in pairs(DependFeatureKeysList3) do
        AllFeatureKeyMap[v] = true
      end
    end
  end
  local AllFeatureKeyList = {}
  for k, v in pairs(AllFeatureKeyMap) do
    table.insert(AllFeatureKeyList, k)
  end
  local AllAssetIDList = {}
  for k, v in pairs(AllAssetIDMap) do
    table.insert(AllAssetIDList, k)
  end
  if CacheInfo then
    CacheInfo.    CacheInfo.  end
  return AllAssetIDList, AllFeatureKeyList
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CResManager = class(CModuleBase, nil, Logic_UGC_Res_Manager)
return CResManager