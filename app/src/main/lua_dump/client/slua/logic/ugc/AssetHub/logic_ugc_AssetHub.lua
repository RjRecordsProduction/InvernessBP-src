local Logic_UGC_AssetHub = {
  PublicMaxStorage = 20,
  bAutoClean = false,
  AutoCleanStrategy = 1,
  bWaitCleanStorage = false,
  DownloadSeqCaches = {}
}
local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
local C_OptionPublicMinStorage = 20
local C_OptionPublicMaxStorage = 1024
local C_PublicMinStorage = 10
local _SystemSwitch = true
local E_ManualCleanStrategy = {Inactive = 1, All = 2}
Logic_UGC_AssetHub.local E_AutoCleanStrategy = {All = 1, Time = 2}
Logic_UGC_AssetHub.
function Logic_UGC_AssetHub:DefineAndResetData()
  self.CustomAssetManager = nil
  self.PublicStorage = nil
  self.PublicAssetList = nil
  self.PublicAssetMap = nil
  self.PrivacyAssetMap = nil
  self.bPrefabMallDataInit = false
  self.PrefabMallDataInitTimer = nil
end
function Logic_UGC_AssetHub:OnInitialize()
  print(bWriteLog and "Logic_UGC_AssetHub:OnInitialize")
  self:InitCustomAssetManager()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Option = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAssetHubCacheOption)
  if Option then
    self.bAutoClean = Option.bAutoClean
    self.AutoCleanStrategy = Option.AutoCleanStrategy
    self.PublicMaxStorage = Option.PublicMaxStorage
  end
end
function Logic_UGC_AssetHub:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PREFAB_MALL_FIRST_META_COMPLETE, self.OnPrefabMallDataRsp, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PREFAB_MALL_META_SILENT_UPDATES, self.OnPrefabMallDataUpdate, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PREFAB_MALL_PRIVATE_META_UPDATES, self.OnPrefabMallDataUpdate, self)
end
function Logic_UGC_AssetHub:OnLogin(bReLogin)
  print(bWriteLog and "Logic_UGC_AssetHub:OnLogin bReLogin:" .. tostring(bReLogin))
end
function Logic_UGC_AssetHub:OnLogOut()
  print(bWriteLog and "Logic_UGC_AssetHub:OnLogOut")
end
function Logic_UGC_AssetHub:OnPreSwitchGameStatus(preState, nextState)
end
function Logic_UGC_AssetHub:OnPostSwitchGameStatus(preState, nextState)
  if preState ~= GameStatus.Login and preState ~= GameStatus.Createrole or nextState == GameStatus.Lobby then
  end
end
function Logic_UGC_AssetHub:OnDestroy()
  print(bWriteLog and "Logic_UGC_AssetHub:OnDestroy")
  self:DestroyCustomAssetManager()
end
function Logic_UGC_AssetHub:GetOptionMaxStorage()
  return C_OptionPublicMaxStorage
end
function Logic_UGC_AssetHub:GetOptionMinStorage()
  return C_OptionPublicMinStorage
end
function Logic_UGC_AssetHub:GetAssetState(LoaderType, ModInfo)
  if not _SystemSwitch then
    return PufferConst.ENUM_DownloadState.Done
  end
  if LoaderType == UGCMacros.ENUM_DownloaderType.ModCopy then
    return self:_GetModAssetState(ModInfo)
  elseif LoaderType == UGCMacros.ENUM_DownloaderType.MyWork then
    return self:_GetModAssetState(ModInfo)
  elseif LoaderType == UGCMacros.ENUM_DownloaderType.Template then
    return self:_GetTemplateAssetState(ModInfo)
  elseif LoaderType == UGCMacros.ENUM_DownloaderType.ModList then
    return self:_GetModListAssetState(ModInfo)
  end
  return PufferConst.ENUM_DownloadState.Done
end
function Logic_UGC_AssetHub:GetAssetSize(LoaderType, ModInfo)
  if not _SystemSwitch then
    return 0, 0
  end
  if LoaderType == UGCMacros.ENUM_DownloaderType.ModCopy then
    return self:_GetModAssetSize(ModInfo)
  elseif LoaderType == UGCMacros.ENUM_DownloaderType.MyWork then
    return self:_GetModAssetSize(ModInfo)
  elseif LoaderType == UGCMacros.ENUM_DownloaderType.Template then
    return self:_GetTemplateAssetSize(ModInfo)
  elseif LoaderType == UGCMacros.ENUM_DownloaderType.ModList then
    return self:_GetModListAssetSize(ModInfo)
  end
  return 0, 0
end
function Logic_UGC_AssetHub:Download(LoaderType, ModInfo)
  if not _SystemSwitch then
    return true
  end
  if LoaderType == UGCMacros.ENUM_DownloaderType.ModCopy then
    return self:_DownloadModAsset(ModInfo)
  elseif LoaderType == UGCMacros.ENUM_DownloaderType.MyWork then
    return self:_DownloadModAsset(ModInfo)
  elseif LoaderType == UGCMacros.ENUM_DownloaderType.Template then
    return self:_DownloadTemplateAsset(ModInfo)
  elseif LoaderType == UGCMacros.ENUM_DownloaderType.ModList then
    return self:_DownloadModListAsset(ModInfo)
  end
  return true
end
function Logic_UGC_AssetHub:Pause(LoaderType, ModInfo)
  if not _SystemSwitch then
    return
  end
  if LoaderType == UGCMacros.ENUM_DownloaderType.ModCopy then
    self:_PauseModAsset(ModInfo)
  elseif LoaderType == UGCMacros.ENUM_DownloaderType.MyWork then
    self:_PauseModAsset(ModInfo)
  elseif LoaderType == UGCMacros.ENUM_DownloaderType.Template then
    self:_PauseTemplateAsset(ModInfo)
  elseif LoaderType == UGCMacros.ENUM_DownloaderType.ModList then
    self:_PauseModListAsset(ModInfo)
  end
end
function Logic_UGC_AssetHub:GetAssetStateByList(AssetList)
  if not _SystemSwitch then
    return PufferConst.ENUM_DownloadState.Done
  end
  return self:_GetStateOuter(AssetList)
end
function Logic_UGC_AssetHub:GetAssetSizeByList(AssetList)
  if not _SystemSwitch then
    return 0, 0
  end
  local cSize, tSize = self:_GetSizeOuter(AssetList)
  cSize = cSize / PufferConst.MB
  tSize = tSize / PufferConst.MB
  return cSize, tSize
end
function Logic_UGC_AssetHub:DownloadList(AssetList, DownloadSeqKey)
  if not _SystemSwitch then
    return true
  end
  if not DownloadSeqKey or DownloadSeqKey == "" then
    return false
  end
  local Result, DownloadSeq = self:_DownloadAssetOuter(AssetList)
  if not Result then
    self.DownloadSeqCaches[DownloadSeqKey] = DownloadSeq
  end
  return Result
end
function Logic_UGC_AssetHub:PauseList(DownloadSeqKey)
  if not _SystemSwitch then
    return
  end
  if self.DownloadSeqCaches[DownloadSeqKey] then
    self:_PauseAssetOuter(DownloadSeqKey)
    self.DownloadSeqCaches[DownloadSeqKey] = nil
  end
end
function Logic_UGC_AssetHub:PauseAll()
  if self.CustomAssetManager then
    self.CustomAssetManager:ForceCancelAllDownload()
  end
end
function Logic_UGC_AssetHub:ShowCleanPopup()
  if self:_IsStorageEmpty() then
    local Title = LocUtil.GetLocalizeResStr(33200)
    local Content = LocUtil.GetLocalizeResStr(468890037)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, Title, Content)
  else
    local Title = LocUtil.GetLocalizeResStr(33200)
    local Content = LocUtil.GetLocalizeResStr(468890035)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, Title, Content, function()
      UIManager.ShowUI(UIManager.UI_Config.UGC_AssetHub_Cleanup_Popup_UIBP)
    end)
  end
end
function Logic_UGC_AssetHub:ManualCleanStorage(Strategy)
  if IsWoWEditor then
    return true
  end
  if not _SystemSwitch then
    return false
  end
  if not self.bPrefabMallDataInit then
    print(bWriteLog and "Logic_UGC_AssetHub:ManualCleanStorage bPrefabMallDataInit is false")
    return false
  end
  if Strategy == E_ManualCleanStrategy.Inactive then
    if self.CustomAssetManager then
      local TimeUtil = require("client.common.time_util")
      local AllCacheList = self:_GetPublicAssetList(true)
      local CleanList = {}
      local CleanMap = {}
      for _, Cache in ipairs(AllCacheList) do
        if not TimeUtil.WithinInNDay(Cache.LoadTimestamp, 7) then
          table.insert(CleanList, Cache.AssetKey)
          CleanMap[Cache.AssetKey] = true
        end
      end
      if 0 < #CleanList then
        self:_CleanCacheList(CleanList, CleanMap)
      end
    end
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_ASSETHUB_CLEANUP)
    return true
  else
    self:_CleanAllCache(true)
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_ASSETHUB_CLEANUP)
    return true
  end
end
function Logic_UGC_AssetHub:AutoCleanStorage(LoaderType, ModInfo)
  if IsWoWEditor then
    return true
  end
  if not _SystemSwitch then
    return false
  end
  if not self.bAutoClean then
    local cSize, tSize = self:GetAssetSize(LoaderType, ModInfo)
    local NeedSize = tSize - cSize
    print(bWriteLog and "Logic_UGC_AssetHub:AutoCleanStorage, Manual Check, NeedSize = ", NeedSize)
    if not self:_CheckStorageEnough(NeedSize) then
      return false, true
    end
    return true
  end
  if not self.bPrefabMallDataInit then
    print(bWriteLog and "Logic_UGC_AssetHub:ManualCleanStorage bPrefabMallDataInit is false")
    return true
  end
  local Result = false
  local AllStorageBefore = self:GetPublicStorage()
  if self.AutoCleanStrategy == E_AutoCleanStrategy.All then
    self:_CleanAllCache()
    Result = true
  else
    local cSize, tSize = self:GetAssetSize(LoaderType, ModInfo)
    local NeedSize = tSize - cSize
    Result = self:_CleanOverCache(NeedSize, ModInfo)
  end
  if Result then
    local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
    if UGCTLogReport then
      UGCTLogReport:ReportDelay(TLogEventDefine.UGC_AssetHub_Auto_Trigger)
      local AllStorageAfter = self:GetPublicStorage()
      local cleanedSize = AllStorageBefore - AllStorageAfter
      local sizeReportStr = string.format("%.2f", cleanedSize)
      UGCTLogReport:ReportDelay(TLogEventDefine.UGC_AssetHub_Auto_Trigger_Size, 0, sizeReportStr)
      local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
      local freeSpace = PufferDeleteManager.GetDeviceFreeSpace() / 1000
      local spaceReportStr = string.format("%.2f_%.2f", freeSpace, AllStorageAfter)
      UGCTLogReport:ReportDelay(TLogEventDefine.UGC_AssetHub_Auto_Trigger_Space, 0, spaceReportStr)
    end
    if not self:_CheckStorageEnough(0) then
      return false, true
    end
    return true
  else
    return false
  end
end
function Logic_UGC_AssetHub:GetPublicStorage(bManual)
  local PublicStorage = self:_GetPublicStorage(bManual)
  return PublicStorage / PufferConst.MB
end
function Logic_UGC_AssetHub:GetAllAndInactiveStorage()
  local TimeUtil = require("client.common.time_util")
  local AllCacheList = self:_GetPublicAssetList()
  local AllStorage = 0
  local InactiveStorage = 0
  for _, Cache in ipairs(AllCacheList) do
    AllStorage = AllStorage + Cache.AssetSize
    if not TimeUtil.WithinInNDay(Cache.LoadTimestamp, 7) then
      InactiveStorage = InactiveStorage + Cache.AssetSize
    end
  end
  return AllStorage / PufferConst.MB, InactiveStorage / PufferConst.MB
end
function Logic_UGC_AssetHub:GetPublicAndPrivacyStorage()
  local PrivacyCustomAssetMap
  local LogicUGCPrefabMall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
  if LogicUGCPrefabMall.FirsMyMetaCompleted or self.bPrefabMallDataInit then
    local logic_ugc_prefab_mall_custom = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_custom")
    PrivacyCustomAssetMap = logic_ugc_prefab_mall_custom:GetMyAllCustomKeyMap()
  else
    PrivacyCustomAssetMap = {}
    LogicUGCPrefabMall:ReqMyShareAndFavoriteMeta()
    if self.PrefabMallDataInitTimer then
      self:RemoveTimer(self.PrefabMallDataInitTimer)
      self.PrefabMallDataInitTimer = nil
    end
    self.PrefabMallDataInitTimer = self:AddTimerOnce(10, function()
      print(bWriteLog and "Logic_UGC_AssetHub:GetPublicAndPrivacyStorage Error")
      self:OnPrefabMallDataRsp()
    end)
  end
  local AllCacheList = self.CustomAssetManager:GetCustomAssetCacheMetaList()
  local PublicStorage = 0
  local PrivacyStorage = 0
  for _, Cache in ipairs(AllCacheList) do
    if PrivacyCustomAssetMap[Cache.AssetKey] then
      PrivacyStorage = PrivacyStorage + Cache.AssetSize
    else
      PublicStorage = PublicStorage + Cache.AssetSize
    end
  end
  return PublicStorage / PufferConst.MB, PrivacyStorage / PufferConst.MB
end
function Logic_UGC_AssetHub:SaveOption(bAutoClean, AutoCleanStrategy, PublicMaxStorage)
  if bAutoClean ~= nil then
    self.  end
  if AutoCleanStrategy ~= nil then
    self.  end
  local OldPublicMaxStorage = self.PublicMaxStorage
  if PublicMaxStorage ~= nil then
    self.  end
  local Option = {
    bAutoClean = self.bAutoClean,
    AutoCleanStrategy = self.AutoCleanStrategy,
    PublicMaxStorage = self.PublicMaxStorage
  }
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(Option, PlayerPrefsSystem.ePlayerPrefsType.eAssetHubCacheOption)
  if self.bAutoClean and self.AutoCleanStrategy == E_AutoCleanStrategy.Time and OldPublicMaxStorage > self.PublicMaxStorage and not self:_IsStorageEnough(0) then
    self:_CleanOverCache(0)
  end
end
function Logic_UGC_AssetHub:GetModSeqKeyByTeam(uid)
  return uid .. "_0"
end
function Logic_UGC_AssetHub:OnGetAllMetaKeyRsp()
end
function Logic_UGC_AssetHub:OnPrefabMallDataRsp()
  print(bWriteLog and "Logic_UGC_AssetHub:OnPrefabMallDataRsp")
  self.bPrefabMallDataInit = true
  self.PublicStorage = nil
  self.PublicAssetList = nil
  self.PublicAssetMap = nil
  self.PrivacyAssetMap = nil
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_ASSETHUB_DATA_UPDATE)
  if self.PrefabMallDataInitTimer then
    self:RemoveTimer(self.PrefabMallDataInitTimer)
    self.PrefabMallDataInitTimer = nil
  end
end
function Logic_UGC_AssetHub:OnPrefabMallDataUpdate()
  print(bWriteLog and "Logic_UGC_AssetHub:OnPrefabMallDataUpdate")
  self.PublicStorage = nil
  self.PublicAssetList = nil
  self.PublicAssetMap = nil
  self.PrivacyAssetMap = nil
end
function Logic_UGC_AssetHub:_GetPublicAssetList(bManual)
  if not _SystemSwitch then
    return {}
  end
  if not self.CustomAssetManager then
    return {}
  elseif not self.PublicAssetList or bManual then
    local PrivacyCustomAssetMap
    local LogicUGCPrefabMall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
    if LogicUGCPrefabMall.FirsMyMetaCompleted or self.bPrefabMallDataInit then
      local logic_ugc_prefab_mall_custom = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_custom")
      PrivacyCustomAssetMap = logic_ugc_prefab_mall_custom:GetMyAllCustomKeyMap()
    else
      PrivacyCustomAssetMap = {}
      LogicUGCPrefabMall:ReqMyShareAndFavoriteMeta()
      if self.PrefabMallDataInitTimer then
        self:RemoveTimer(self.PrefabMallDataInitTimer)
        self.PrefabMallDataInitTimer = nil
      end
      self.PrefabMallDataInitTimer = self:AddTimerOnce(10, function()
        print(bWriteLog and "Logic_UGC_AssetHub:_GetPublicAssetList Error")
        self:OnPrefabMallDataRsp()
      end)
    end
    local AllCacheList = self.CustomAssetManager:GetCustomAssetCacheMetaList()
    local PublicAssetList = {}
    local PublicAssetMap = {}
    local PrivacyAssetMap = {}
    for _, Cache in ipairs(AllCacheList) do
      if not PrivacyCustomAssetMap[Cache.AssetKey] then
        table.insert(PublicAssetList, Cache)
        PublicAssetMap[Cache.AssetKey] = true
      end
    end
    self.    self.    self.  end
  return self.PublicAssetList
end
function Logic_UGC_AssetHub:_GetPublicStorage(bManual)
  if IsWoWEditor then
    if not self.PublicStorage then
      self.PublicStorage = 0
    end
    return self.PublicStorage
  end
  if not self.PublicStorage or bManual then
    local AllCacheList = self:_GetPublicAssetList(bManual)
    local Storage = 0
    for _, Cache in ipairs(AllCacheList) do
      Storage = Storage + Cache.AssetSize
    end
    self.Public  end
  return self.PublicStorage
end
function Logic_UGC_AssetHub:_IsStorageEmpty()
  return self:_GetPublicStorage() * PufferConst.MB < C_PublicMinStorage * PufferConst.MB
end
function Logic_UGC_AssetHub:_GetFreeStorage()
  local FreeSpace = PufferDeleteManager.GetDeviceFreeSpace()
  print(bWriteLog and "Logic_UGC_AssetHub:_GetFreeStorage", FreeSpace)
  local RealFreeSpace = FreeSpace - UGCMacros.GAME_NEED_MIN_STORAGE
  if RealFreeSpace < 0 then
    RealFreeSpace = 0
  end
  return RealFreeSpace
end
function Logic_UGC_AssetHub:_GetMaxFreeStorage()
  local FreeStorage = self:_GetFreeStorage()
  return math.min(FreeStorage, self.PublicMaxStorage)
end
function Logic_UGC_AssetHub:_IsStorageEnough(FileSize)
  if IsEditor then
    return true
  end
  local FreeStorage = self:_GetFreeStorage()
  if self:_GetPublicStorage() > FreeStorage * PufferConst.MB + FileSize then
    print(bWriteLog and "Logic_UGC_AssetHub:_IsStorageEnough FreeStorage = ", FreeStorage)
    return false
  end
  return true
end
function Logic_UGC_AssetHub:_UpdatePublicAssets(Asset)
  if not Asset then
    log(bWriteLog and "Logic_UGC_AssetHub:_UpdatePublicAssets: Asset is nil")
    return
  end
  if not (self.PublicAssetList and self.PublicAssetMap) or not self.PrivacyAssetMap then
    log(bWriteLog and "Logic_UGC_AssetHub:_UpdatePublicAssets: PublicAssetList or PublicAssetMap or PrivacyAssetMap is nil")
    return
  end
  local AssetKey = Asset.AssetKey
  if self.PublicAssetMap[AssetKey] then
    log(bWriteLog and "Logic_UGC_AssetHub:_UpdatePublicAssets, Public Exist")
    return
  end
  if self.PrivacyAssetMap[AssetKey] then
    log(bWriteLog and "Logic_UGC_AssetHub:_UpdatePublicAssets, Privacy Exist")
    return
  end
  table.insert(self.PublicAssetList, Asset)
  self.PublicAssetMap[AssetKey] = true
  self.PublicStorage = self:_GetPublicStorage() + Asset.AssetSize
end
function Logic_UGC_AssetHub:_GetModDepends(ModInfo)
  if not ModInfo then
    return nil
  end
  local TableUtil = require("common.table_util")
  if ModInfo.ResList then
    return TableUtil.GetTableValue(ModInfo, "CustomAssetList")
  else
    return TableUtil.GetTableValue(ModInfo, "setting", "custom_asset_key_list")
  end
end
function Logic_UGC_AssetHub:_GetModSeqKey(ModInfo)
  if not ModInfo then
    return nil
  end
  local SeqKey
  if ModInfo.ResList then
    SeqKey = "T_" .. ModInfo.ID
  elseif ModInfo.mod_id then
    SeqKey = ModInfo.mod_id
  else
    SeqKey = tostring(ModInfo.base.uid) .. "_" .. tostring(ModInfo.base.slot)
  end
  return SeqKey
end
function Logic_UGC_AssetHub:_GetStateOuter(Depends)
  if not Depends then
    return PufferConst.ENUM_DownloadState.Done
  end
  local State = PufferConst.ENUM_DownloadState.Done
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if self.CustomAssetManager then
    for i, AssetKey in ipairs(Depends) do
      local TempState = self.CustomAssetManager:GetCustomAssetDownloadState(AssetKey)
      State = PufferManager.GetMixDownloadState(State, TempState)
    end
  end
  return State
end
function Logic_UGC_AssetHub:_GetModAssetState(ModInfo)
  if not (ModInfo and ModInfo.base) or not ModInfo.base.template_id then
    return PufferConst.ENUM_DownloadState.Done
  end
  local Depends = self:_GetModDepends(ModInfo)
  local State = self:_GetStateOuter(Depends)
  return State
end
function Logic_UGC_AssetHub:_GetTemplateAssetState(TemplateInfo)
  if not (TemplateInfo and TemplateInfo.ID) or not TemplateInfo.MapID then
    return PufferConst.ENUM_DownloadState.Done
  end
  local Depends = self:_GetModDepends(TemplateInfo)
  local State = self:_GetStateOuter(Depends)
  return State
end
function Logic_UGC_AssetHub:_GetModListAssetState(ModList)
  local State = PufferConst.ENUM_DownloadState.Done
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  for k, ModInfo in pairs(ModList) do
    local TempState = self:_GetModAssetState(ModInfo)
    State = PufferManager.GetMixDownloadState(State, TempState)
  end
  return State
end
function Logic_UGC_AssetHub:_GetSizeOuter(Depends)
  if not Depends then
    return 0, 0
  end
  local cSize, tSize = 0, 0
  if self.CustomAssetManager then
    for i, AssetKey in ipairs(Depends) do
      local Size = self.CustomAssetManager:GetCustomAssetSize(AssetKey)
      tSize = tSize + Size
      if self.CustomAssetManager:CustomAssetIsCacheed(AssetKey) then
        cSize = cSize + Size
      end
    end
  end
  return cSize, tSize
end
function Logic_UGC_AssetHub:_GetModAssetSize(ModInfo)
  if not (ModInfo and ModInfo.base) or not ModInfo.base.template_id then
    return 0, 0
  end
  local Depends = self:_GetModDepends(ModInfo)
  local cSize, tSize = self:_GetSizeOuter(Depends)
  cSize = cSize / PufferConst.MB
  tSize = tSize / PufferConst.MB
  return cSize, tSize
end
function Logic_UGC_AssetHub:_GetTemplateAssetSize(TemplateInfo)
  if not (TemplateInfo and TemplateInfo.ID) or not TemplateInfo.MapID then
    return 0, 0
  end
  local Depends = self:_GetModDepends(TemplateInfo)
  local cSize, tSize = self:_GetSizeOuter(Depends)
  cSize = cSize / PufferConst.MB
  tSize = tSize / PufferConst.MB
  return cSize, tSize
end
function Logic_UGC_AssetHub:_GetModListAssetSize(ModList)
  local cSize, tSize = 0, 0
  for k, ModInfo in pairs(ModList) do
    local cSizeSub, tSizeSub = self:_GetModAssetSize(ModInfo)
    cSize = cSize + cSizeSub
    tSize = tSize + tSizeSub
  end
  return cSize, tSize
end
function Logic_UGC_AssetHub:_DownloadAssetOuter(Depends)
  if not Depends then
    return true
  end
  if self.CustomAssetManager then
    if self:_GetStateOuter(Depends) == PufferConst.ENUM_DownloadState.Done then
      return true
    end
    local DownloadSeq = self.CustomAssetManager:DownloadCustomAssetList(Depends, function(bSuccess, DownloadMap)
      log(bWriteLog and "Logic_UGC_AssetHub:_DownloadAssetOuter download done")
      if self.CustomAssetManager and DownloadMap then
        for AssetKey, v in pairs(DownloadMap) do
          local State = self.CustomAssetManager:GetCustomAssetDownloadState(AssetKey)
          if State == PufferConst.ENUM_DownloadState.Done then
            local CustomAssetCacheInfo = self.CustomAssetManager:GetCustomAssetCacheMetaInfo(AssetKey)
            if CustomAssetCacheInfo then
              self:_UpdatePublicAssets(CustomAssetCacheInfo)
            end
          end
        end
      end
    end)
    return false, DownloadSeq
  end
  return true
end
function Logic_UGC_AssetHub:_DownloadModAsset(ModInfo)
  if not (ModInfo and ModInfo.base) or not ModInfo.base.template_id then
    return false
  end
  local SeqKey = self:_GetModSeqKey(ModInfo)
  local Depends = self:_GetModDepends(ModInfo)
  local Result, DownloadSeq = self:_DownloadAssetOuter(Depends)
  if not Result then
    self.DownloadSeqCaches[SeqKey] = DownloadSeq
  end
  return Result
end
function Logic_UGC_AssetHub:_DownloadTemplateAsset(TemplateInfo)
  if not (TemplateInfo and TemplateInfo.ID) or not TemplateInfo.MapID then
    return false
  end
  local Depends = self:_GetModDepends(TemplateInfo)
  local Result = self:_DownloadAssetOuter(Depends)
  return Result
end
function Logic_UGC_AssetHub:_DownloadModListAsset(ModList)
  local Result = true
  for k, ModInfo in pairs(ModList) do
    local TempResult = self:_DownloadModAsset(ModInfo)
    if not TempResult then
      Result = false
    end
  end
  return Result
end
function Logic_UGC_AssetHub:_PauseAssetOuter(DownloadSeq)
  if self.CustomAssetManager then
    local Result, CancelMap = self.CustomAssetManager:CancelDownloadAsset(DownloadSeq)
    if CancelMap then
      for AssetKey, v in pairs(CancelMap) do
        local State = self.CustomAssetManager:GetCustomAssetDownloadState(AssetKey)
        if State == PufferConst.ENUM_DownloadState.Done then
          local CustomAssetCacheInfo = self.CustomAssetManager:GetCustomAssetCacheMetaInfo(AssetKey)
          if CustomAssetCacheInfo then
            self:_UpdatePublicAssets(CustomAssetCacheInfo)
          end
        end
      end
    end
  end
end
function Logic_UGC_AssetHub:_GetDownloadSeq(ModInfo)
  local SeqKey = self:_GetModSeqKey(ModInfo)
  return self.DownloadSeqCaches[SeqKey], SeqKey
end
function Logic_UGC_AssetHub:_PauseModAsset(ModInfo)
  if not (ModInfo and ModInfo.base) or not ModInfo.base.template_id then
    return
  end
  local Seq, SeqKey = self:_GetDownloadSeq(ModInfo)
  if Seq then
    self:_PauseAssetOuter(Seq)
    self.DownloadSeqCaches[SeqKey] = nil
  end
end
function Logic_UGC_AssetHub:_PauseTemplateAsset(TemplateInfo)
  if not (TemplateInfo and TemplateInfo.ID) or not TemplateInfo.MapID then
    return
  end
  local Seq, SeqKey = self:_GetDownloadSeq(TemplateInfo)
  if Seq then
    self:_PauseAssetOuter(Seq)
    self.DownloadSeqCaches[SeqKey] = nil
  end
end
function Logic_UGC_AssetHub:_PauseModListAsset(ModList)
  for k, ModInfo in pairs(ModList) do
    self:_PauseModAsset(ModInfo)
  end
end
function Logic_UGC_AssetHub:_CheckStorageEnough(FileSize)
  if self:_IsStorageEnough(FileSize) then
    return true
  end
  self:ShowCleanPopup()
  return false
end
function Logic_UGC_AssetHub:_CleanAllCache(bManual)
  if not _SystemSwitch then
    return
  end
  if self.CustomAssetManager then
    local AllCacheList = self:_GetPublicAssetList(bManual)
    local CleanList = {}
    for _, Cache in ipairs(AllCacheList) do
      table.insert(CleanList, Cache.AssetKey)
    end
    self.CustomAssetManager:DeleteCacheCustomAssetList(CleanList)
    self.PublicStorage = nil
    self.PublicAssetList = nil
    self.PublicAssetMap = nil
  end
end
function Logic_UGC_AssetHub:_CleanOverCache(NeedSize, ModInfo)
  if self.CustomAssetManager then
    local LeftSize = self.PublicMaxStorage * PufferConst.MB - self:_GetPublicStorage()
    NeedSize = NeedSize * PufferConst.MB
    print(bWriteLog and "Logic_UGC_AssetHub:_CleanOverCache LeftSize = ", LeftSize)
    print(bWriteLog and "Logic_UGC_AssetHub:_CleanOverCache NeedSize = ", NeedSize)
    if LeftSize > NeedSize then
      return true
    end
    local FilterMap = {}
    if ModInfo then
      local Depends = self:_GetModDepends(ModInfo)
      for _, AssetKey in ipairs(Depends) do
        FilterMap[AssetKey] = true
      end
    end
    local PublicAssetList = self:_GetPublicAssetList()
    table.sort(PublicAssetList, function(a, b)
      return a.LoadTimestamp > b.LoadTimestamp
    end)
    local DeleteSize = NeedSize - LeftSize
    print(bWriteLog and "Logic_UGC_AssetHub:_CleanOverCache DeleteSize = ", DeleteSize)
    local Size = 0
    local CleanList = {}
    local CleanMap = {}
    for i = #PublicAssetList, 1, -1 do
      local Cache = PublicAssetList[i]
      if not FilterMap[Cache.AssetKey] then
        Size = Size + Cache.AssetSize
        print(bWriteLog and "[edward] Logic_UGC_AssetHub:_CleanOverCache, ", i, Cache.AssetKey)
        table.insert(CleanList, Cache.AssetKey)
        CleanMap[Cache.AssetKey] = true
        if DeleteSize <= Size then
          break
        end
      end
    end
    if 0 < #CleanList then
      self:_CleanCacheList(CleanList, CleanMap)
    end
    return true
  end
  return false
end
function Logic_UGC_AssetHub:_CleanCacheList(CleanList, CleanMap)
  if not CleanList or not CleanMap then
    return
  end
  self.CustomAssetManager:DeleteCacheCustomAssetList(CleanList)
  self:_GetPublicAssetList()
  if self.PublicAssetList then
    for i = #self.PublicAssetList, 1, -1 do
      local Cache = self.PublicAssetList[i]
      local AssetKey = Cache.AssetKey
      if CleanMap[AssetKey] then
        self.PublicStorage = self.PublicStorage - Cache.AssetSize
        table.remove(self.PublicAssetList, i)
        if self.PublicAssetMap then
          self.PublicAssetMap[AssetKey] = nil
        end
      end
    end
  end
  if self.PublicStorage < 0 then
    self.PublicStorage = 0
  end
  print(bWriteLog and "Logic_UGC_AssetHub:_CleanCacheList PublicStorage = ", self.PublicStorage)
end
function Logic_UGC_AssetHub:InitCustomAssetManager()
  print(bWriteLog and "Logic_UGC_AssetHub:InitCustomAssetManager CustomAssetManager:" .. tostring(self.CustomAssetManager))
  if slua.isValid(self.CustomAssetManager) then
    return
  end
  local CustomAssetUtil = require("common.CustomAsset.CustomAssetUtil")
  local InOuter
  if IsEditor and DataMgr.roleData.uid == "" then
    InOuter = CGameWorld
  else
    local UIUtil = require("client.common.ui_util")
    InOuter = UIUtil.GetGameInstance()
  end
  self.CustomAssetManager = CustomAssetUtil.CreateCustomAssetManager(InOuter)
  CustomAssetMgr = self.CustomAssetManager
end
function Logic_UGC_AssetHub:DestroyCustomAssetManager()
  print(bWriteLog and "Logic_UGC_AssetHub:DestroyCustomAssetManager")
  local CustomAssetUtil = require("common.CustomAsset.CustomAssetUtil")
  CustomAssetUtil.DestroyCustomAssetManager(self.CustomAssetManager)
  self.CustomAssetManager = nil
  CustomAssetMgr = nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_UGC_AssetHub = class(CModuleBase, nil, Logic_UGC_AssetHub)
return CLogic_UGC_AssetHub