local Config_UGC_Copilot = require("client.slua.logic.ugc.copilot.config_ugc_copilot")
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local LLMHandler = require("client.network.Protocol.LLMHandler")
local DSL_CACHE_MAX_AGE = 604800
local DSL_CACHE_MAX_ENTRIES = 100
local DSL_CACHE_VERSION = 1
local APPLY_RESULT_REASON = {
  CustomImageWaiting = "CustomImageWaiting",
  CustomImageWaitRejected = "CustomImageWaitRejected"
}
local _LogApplyStats = function(Prefix, Stats)
  if type(Stats) ~= "table" then
    log(bWriteLog and string.format("[copilot_uigen:dsl:apply] %s | Stats=nil", Prefix))
    return
  end
  log(bWriteLog and string.format("[copilot_uigen:dsl:apply] %s | reason=%s | message=%s | mode=%s | created=%d | updated=%d | reused=%d | touched=%d | deleted=%d | canvas_synced=%d | img_waiting=%s | img_rejected=%s | img_count=%d | img_prepared=%d | img_pending=%d | img_timeout=%s | save_reason=%s", Prefix, tostring(Stats.ResultReason), tostring(Stats.ResultMessage), tostring(Stats.Mode), Stats.CreatedCount or 0, Stats.UpdatedCount or 0, Stats.ReusedCount or 0, Stats.TouchedCount or 0, Stats.DeletedCount or 0, Stats.CanvasSyncedCount or 0, tostring(Stats.CustomImageWaiting), tostring(Stats.CustomImageWaitRejected), Stats.CustomImageCount or 0, Stats.CustomImagePreparedCount or 0, Stats.CustomImagePendingCount or 0, tostring(Stats.CustomImageWaitTimedOut), tostring(Stats.SaveReason)))
end
local UIGenFeature = {Owner = nil}
function UIGenFeature:ctor()
  print(bWriteLog and "UIGenFeature:ctor")
  self:ResetData()
end
function UIGenFeature:ResetData()
  self._hasUnsavedChanges = false
  self._lastApplyTraceId = nil
  self._pendingCacheDsl = nil
  self._pendingCacheTraceId = nil
  self._pendingCacheApplyMode = nil
  self._dslCacheStore = nil
  self._dslCacheDirty = false
end
function UIGenFeature:ClearPendingState()
  self._pendingCacheDsl = nil
  self._pendingCacheTraceId = nil
  self._pendingCacheApplyMode = nil
end
function UIGenFeature:OnInitialize()
  print(bWriteLog and "UIGenFeature:OnInitialize")
  self._hasPurgedCache = false
end
function UIGenFeature:ExportCurrentDsl()
  log(bWriteLog and "[copilot_uigen:dsl:export] ExportCurrentDsl: enter")
  local ok, EditUIUtility = pcall(require, "GameLua.Mod.CreativeBase.Gameplay.Meta.CreativeModeEditUIUtility")
  if not ok or type(EditUIUtility) ~= "table" then
    log(bWriteLog and string.format("[copilot_uigen:dsl:export] ExportCurrentDsl FAILED to load CreativeModeEditUIUtility | ok=%s | type=%s", tostring(ok), type(EditUIUtility)))
    return ""
  end
  if type(EditUIUtility.ExportCurrentUIToOpenUILangSource) ~= "function" then
    log(bWriteLog and string.format("[copilot_uigen:dsl:export] ExportCurrentDsl ExportCurrentUIToOpenUILangSource is not a function | type=%s", type(EditUIUtility.ExportCurrentUIToOpenUILangSource)))
    return ""
  end
  local exportOk, dslText = pcall(EditUIUtility.ExportCurrentUIToOpenUILangSource)
  if not exportOk or type(dslText) ~= "string" then
    log(bWriteLog and string.format("[copilot_uigen:dsl:export] ExportCurrentDsl export failed or not string | export_ok=%s | dsl_text_type=%s | err=%s", tostring(exportOk), type(dslText), tostring(dslText)))
    return ""
  end
  log(bWriteLog and string.format("[copilot_uigen:dsl:export] ExportCurrentDsl SUCCESS | length=%d | first_200=%s", #dslText, string.sub(dslText, 1, 200)))
  return dslText
end
function UIGenFeature:_CanApply()
  local MainPanel = UIManager.GetUI(UIManager.UI_Config_InGame.CustomUI_MainPanel)
  return MainPanel ~= nil and MainPanel.UserCanvasCls ~= nil
end
function UIGenFeature:_TryOpenCustomUIEditorForApply()
  local topUIName = UIManager.GetTopVisibleUIName()
  if topUIName ~= "CreativeModeEditModeUI" then
    log(bWriteLog and string.format("[copilot_uigen:dsl:apply] _TryOpenCustomUIEditorForApply: topUIName=%s, skip open", tostring(topUIName)))
    return false
  end
  log(bWriteLog and "[copilot_uigen:dsl:apply] _TryOpenCustomUIEditorForApply: opening CustomUI_MainPanel")
  UIManager.ShowUI(UIManager.UI_Config_InGame.CustomUI_MainPanel)
  return true
end
function UIGenFeature:OnDslReceived(traceId, dslText, resources, cb_data)
  local applyMode = cb_data and cb_data.apply_mode or "rebuild"
  log(bWriteLog and string.format("[copilot_uigen:dsl:receive] OnDslReceived | trace_id=%s | dsl_length=%d | apply_mode=%s", tostring(traceId), tostring(dslText and #dslText or 0), tostring(applyMode)))
  if not dslText or dslText == "" then
    log(bWriteLog and "[copilot_uigen:dsl:receive] OnDslReceived DSL is empty, skip")
    return
  end
  self._pendingCacheDsl = dslText
  self._pendingCacheTraceId = traceId
  self._pendingCacheApplyMode = applyMode
  self._lastApplyTraceId = traceId
  log(bWriteLog and string.format("[copilot_uigen:dsl:cache] OnDslReceived DSL stored as pending | trace_id=%s | apply_mode=%s", tostring(traceId), tostring(applyMode)))
  local missingKeys = self:_CheckResources(resources)
  if 0 < #missingKeys then
    log(bWriteLog and string.format("[copilot_uigen:dsl:receive] OnDslReceived missing resources: %s", table.concat(missingKeys, ", ")))
  end
  self:_NotifyUIGenComplete()
end
function UIGenFeature:_ApplyDsl(dslText, mode, onCustomImageApplyComplete)
  mode = mode or "rebuild"
  local ok, EditUIUtility = pcall(require, "GameLua.Mod.CreativeBase.Gameplay.Meta.CreativeModeEditUIUtility")
  if not ok or type(EditUIUtility) ~= "table" then
    return false, "\230\151\160\230\179\149\229\138\160\232\189\189 CreativeModeEditUIUtility \230\168\161\229\157\151"
  end
  if type(EditUIUtility.ApplyOpenUILangSource) ~= "function" then
    return false, "ApplyOpenUILangSource \229\135\189\230\149\176\228\184\141\229\173\152\229\156\168\239\188\140\232\175\183\230\163\128\230\159\165\231\137\136\230\156\172"
  end
  local applyOk, Result, SymbolMap, Stats = pcall(EditUIUtility.ApplyOpenUILangSource, dslText, {
    Mode = mode,
    DeleteMissing = mode == "rebuild",
    OnCustomImageApplyComplete = onCustomImageApplyComplete
  })
  if not applyOk then
    return false, "DSL \230\184\178\230\159\147\229\188\130\229\184\184: " .. tostring(Result)
  end
  if Result ~= true then
    _LogApplyStats("_ApplyDsl non-success", Stats)
    if type(Stats) == "table" and (Stats.ResultReason == APPLY_RESULT_REASON.CustomImageWaiting or Stats.ResultReason == APPLY_RESULT_REASON.CustomImageWaitRejected) then
      return false, {
        bAsyncWaiting = true,
        Error = Stats.ResultMessage or "DSL \230\184\178\230\159\147\231\173\137\229\190\133\229\188\130\230\173\165\232\181\132\230\186\144",
              }
    end
    return false, {
      Error = Stats and Stats.ResultMessage or "DSL \230\184\178\230\159\147\229\164\177\232\180\165\239\188\136\232\175\173\230\179\149\233\148\153\232\175\175\230\136\150\231\188\186\229\176\145 root \229\163\176\230\152\142\239\188\137",
          }
  end
  _LogApplyStats("_ApplyDsl success", Stats)
  log(bWriteLog and string.format("[copilot_uigen:dsl:render] _ApplyDsl success | mode=%s", mode))
  return true, {SymbolMap = SymbolMap, Stats = Stats}
end
function UIGenFeature:_ClearCanvasBeforeApply()
  local ok, err = pcall(function()
    local CustomUISubsystem = SubsystemMgr:Get("CreateModeCustomUISubsystem")
    if not CustomUISubsystem then
      log(bWriteLog and "[copilot_uigen:dsl:render] _ClearCanvasBeforeApply: CustomUISubsystem not found")
      return
    end
    local currentCanvasId = CustomUISubsystem:GetCurrentEditCanvasId()
    log(bWriteLog and string.format("[copilot_uigen:dsl:render] _ClearCanvasBeforeApply | current_canvas_id=%s", tostring(currentCanvasId)))
    if not currentCanvasId then
      log(bWriteLog and "[copilot_uigen:dsl:render] _ClearCanvasBeforeApply: no current canvas")
      return
    end
    local children = CustomUISubsystem:GetInstanceChildren(currentCanvasId)
    if not children or #children == 0 then
      log(bWriteLog and "[copilot_uigen:dsl:render] _ClearCanvasBeforeApply: canvas is empty, no children")
    else
      log(bWriteLog and string.format("[copilot_uigen:dsl:render] _ClearCanvasBeforeApply | canvas root children count=%d", #children))
      for i, childId in ipairs(children) do
        log(bWriteLog and string.format("[copilot_uigen:dsl:render]   child[%d] = %s", i, tostring(childId)))
      end
    end
  end)
  if not ok then
    log(bWriteLog and string.format("[copilot_uigen:dsl:render] _ClearCanvasBeforeApply error: %s", tostring(err)))
  end
end
function UIGenFeature:_RefreshEditorCanvas(symbolMap)
  local ok, err = pcall(function()
    local bDisableManualRefresh = true
    if bDisableManualRefresh then
      log(bWriteLog and "[copilot_uigen:dsl:render] _RefreshEditorCanvas temporarily disabled")
    else
      local MainPanel = UIManager.GetUI(UIManager.UI_Config_InGame.CustomUI_MainPanel)
      if not MainPanel or not MainPanel.UserCanvasCls then
        log(bWriteLog and "[copilot_uigen:dsl:render] _RefreshEditorCanvas: CustomUI_MainPanel or UserCanvasCls not found, skip")
        return
      end
      local UserCanvas = MainPanel.UserCanvasCls
      UserCanvas:DestroyCustomUI()
      UserCanvas:CreateCustomUI()
      local InstanceMgr = GetInstanceManager()
      local TreeData = InstanceMgr and InstanceMgr:GetInstanceTreeData()
      if not TreeData then
        log(bWriteLog and "[copilot_uigen:dsl:render] _RefreshEditorCanvas: no TreeData")
        return
      end
      local ObjectMgr = GetObjectManager()
      local AssetManager = GetAssetManager()
      local ParentPanel = UserCanvas.UIRoot and UserCanvas.UIRoot.CanvasPanel_Widgets
      if not ParentPanel or not slua.isValid(ParentPanel) then
        log(bWriteLog and "[copilot_uigen:dsl:render] _RefreshEditorCanvas: ParentPanel invalid")
        return
      end
      UserCanvas.AsyncLoadedWidgets = UserCanvas.AsyncLoadedWidgets or {}
      local loadCount = 0
      for InstanceId, Instance in pairs(TreeData) do
        if Instance and Instance.CustomUIBase then
          local Obj = ObjectMgr and ObjectMgr:LuaGetObject(InstanceId)
          if Obj then
          elseif not UserCanvas.AsyncLoadedWidgets[InstanceId] then
            local AssetInfo = Instance.AssetId and AssetManager:GetAsset(Instance.AssetId)
            local WidgetPath = AssetInfo and AssetInfo.WidgetPath
            if WidgetPath and WidgetPath ~= "" then
              loadCount = loadCount + 1
              local CapturedId = InstanceId
              local Captured              UserCanvas.AsyncLoadedWidgets[CapturedId] = true
              slua.AsyncLoadUI(WidgetPath, function(_, Widget)
                if not Widget or not slua.isValid(Widget) then
                  UserCanvas.AsyncLoadedWidgets[CapturedId] = nil
                  return
                end
                if not ParentPanel or not slua.isValid(ParentPanel) then
                  Widget:ConditionalBeginDestroy()
                  UserCanvas.AsyncLoadedWidgets[CapturedId] = nil
                  return
                end
                ParentPanel:AddChild(Widget)
                local Widget_Slot = Widget.Slot
                if slua.isValid(Widget_Slot) then
                  Widget_Slot:SetAnchors(FAnchors(0, 0, 0, 0))
                  Widget_Slot:SetAlignment(FVector2D(0.5, 0.5))
                  Widget_Slot:SetAutoSize(true)
                end
                if Widget.UpdateInstanceData then
                  Widget:UpdateInstanceData(CapturedInstance, nil, true)
                end
                UserCanvas.AsyncLoadedWidgets[CapturedId] = Widget
              end)
            end
          end
        end
      end
      log(bWriteLog and string.format("[copilot_uigen:dsl:render] _RefreshEditorCanvas: CreateCustomUI done, manual async load count=%d", loadCount))
    end
  end)
  if not ok then
    log(bWriteLog and string.format("[copilot_uigen:dsl:render] _RefreshEditorCanvas failed: %s", tostring(err)))
  end
end
function UIGenFeature:_CheckResources(resources)
  local missingKeys = {}
  if not resources or not next(resources) then
    return missingKeys
  end
  for dslRef, customAssetKey in pairs(resources) do
    local hashId
    if CustomAssetMgr and type(CustomAssetMgr.GetHashIDByCustomAssetKey) == "function" then
      local ok, id = pcall(function()
        return CustomAssetMgr:GetHashIDByCustomAssetKey(customAssetKey)
      end)
      if ok then
        hashId = id
      end
    end
    if not hashId or type(hashId) == "number" and hashId <= 0 then
      table.insert(missingKeys, tostring(dslRef) .. " \226\134\146 " .. tostring(customAssetKey))
    end
  end
  return missingKeys
end
function UIGenFeature:_TrySave()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return false
  end
  local BinaryEditFeature = PlayerController.CreativeModeBinaryDataEditFeature
  if not slua.isValid(BinaryEditFeature) or type(BinaryEditFeature.ClientSaveMod) ~= "function" then
    return false
  end
  local ok = pcall(function()
    BinaryEditFeature:ClientSaveMod()
  end)
  return ok
end
function UIGenFeature:Save()
  if not self._hasUnsavedChanges then
    log(bWriteLog and "[copilot_uigen:dsl:render] Save: no unsaved changes")
    return true
  end
  local saveOk = self:_TrySave()
  if saveOk then
    self._hasUnsavedChanges = false
    log(bWriteLog and "[copilot_uigen:dsl:render] Save: success")
  else
    log(bWriteLog and "[copilot_uigen:dsl:render] Save: failed")
  end
  return saveOk
end
function UIGenFeature:HasUnsavedChanges()
  return self._hasUnsavedChanges or false
end
function UIGenFeature:OnDslKeyReceived(dslKey, traceId)
  log(bWriteLog and string.format("[copilot_uigen:dsl:cache] OnDslKeyReceived | dslKey=%s | trace_id=%s", tostring(dslKey), tostring(traceId)))
  if not dslKey or dslKey == "" then
    log(bWriteLog and "[copilot_uigen:dsl:cache] OnDslKeyReceived: dslKey is empty, skip")
    return
  end
  if not self._pendingCacheDsl or self._pendingCacheDsl == "" then
    log(bWriteLog and "[copilot_uigen:dsl:cache] OnDslKeyReceived: no pending DSL to cache, skip")
    return
  end
  self:_AppendDslCache(self._pendingCacheDsl, dslKey, self._pendingCacheApplyMode, self._pendingCacheTraceId or traceId)
  self._pendingCacheDsl = nil
  self._pendingCacheTraceId = nil
  self._pendingCacheApplyMode = nil
  log(bWriteLog and "[copilot_uigen:dsl:cache] OnDslKeyReceived: cache committed, pending cleared")
end
function UIGenFeature:_LoadAndMigrateDslCache()
  local store = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCWowAICopilotUIGenDslCache)
  if not store then
    return {
      version = DSL_CACHE_VERSION,
      entries = {}
    }
  end
  store.entries = store.entries or {}
  local diskVersion = store.version or 0
  if diskVersion == DSL_CACHE_VERSION then
    return store
  end
  if diskVersion < 1 then
    store.version = 1
    diskVersion = 1
    log(bWriteLog and string.format("[copilot_uigen:dsl:cache] _LoadAndMigrateDslCache: migrated v0->v1, entries preserved, count=%d", #store.entries))
  end
  PlayerPrefsSystem.SaveTableToFile_N(store, PlayerPrefsSystem.ePlayerPrefsType.eUGCWowAICopilotUIGenDslCache)
  log(bWriteLog and string.format("[copilot_uigen:dsl:cache] _LoadAndMigrateDslCache: migration saved, final version=%d", store.version))
  return store
end
function UIGenFeature:_AppendDslCache(dslText, dslKey, applyMode, traceId)
  log(bWriteLog and string.format("[copilot_uigen:dsl:cache] _AppendDslCache BEGIN | dslKey=%s | trace_id=%s | dslLength=%d | applyMode=%s", tostring(dslKey), tostring(traceId), tostring(#(dslText or "")), tostring(applyMode)))
  local SessionManager = self.Owner.SessionManager
  local store = self:_LoadAndMigrateDslCache()
  log(bWriteLog and string.format("[copilot_uigen:dsl:cache] _AppendDslCache | current entries count=%d", #store.entries))
  local newEntry = {
    mapId = SessionManager:GetMapID() or "0",
    chatId = SessionManager:GetCurrentChatID() or "",
    trace_id = traceId or "",
    dslKey = dslKey or "",
    dslText = dslText,
    applyMode = applyMode or "rebuild",
    ts = os.time()
  }
  if dslKey and dslKey ~= "" then
    for i, entry in ipairs(store.entries) do
      if entry.dslKey == dslKey then
        store.entries[i] = newEntry
        PlayerPrefsSystem.SaveTableToFile_N(store, PlayerPrefsSystem.ePlayerPrefsType.eUGCWowAICopilotUIGenDslCache)
        self._dslCacheDirty = true
        log(bWriteLog and string.format("[copilot_uigen:dsl:cache] _AppendDslCache: REPLACED existing at index=%d", i))
        return
      end
    end
  end
  table.insert(store.entries, 1, newEntry)
  local overflowCount = 0
  while #store.entries > DSL_CACHE_MAX_ENTRIES do
    table.remove(store.entries)
    overflowCount = overflowCount + 1
  end
  if 0 < overflowCount then
    log(bWriteLog and string.format("[copilot_uigen:dsl:cache] _AppendDslCache: overflow purged %d oldest entries", overflowCount))
  end
  PlayerPrefsSystem.SaveTableToFile_N(store, PlayerPrefsSystem.ePlayerPrefsType.eUGCWowAICopilotUIGenDslCache)
  self._dslCacheDirty = true
  log(bWriteLog and string.format("[copilot_uigen:dsl:cache] _AppendDslCache INSERTED | total=%d | map_id=%s | chat_id=%s | trace_id=%s", #store.entries, newEntry.mapId, newEntry.chatId, newEntry.trace_id))
end
function UIGenFeature:_PurgeExpiredDslCache()
  log(bWriteLog and "[copilot_uigen:dsl:cache] _PurgeExpiredDslCache: BEGIN")
  local store = self:_LoadAndMigrateDslCache()
  if #store.entries == 0 then
    log(bWriteLog and "[copilot_uigen:dsl:cache] _PurgeExpiredDslCache: no entries, skip")
    self._dslCacheStore = store
    self._dslCacheDirty = false
    return
  end
  local now = os.time()
  local validEntries = {}
  local purgedCount = 0
  for _, entry in ipairs(store.entries) do
    local age = now - (entry.ts or 0)
    if age <= DSL_CACHE_MAX_AGE then
      table.insert(validEntries, entry)
    else
      purgedCount = purgedCount + 1
      log(bWriteLog and string.format("[copilot_uigen:dsl:cache] _PurgeExpiredDslCache: expired dslKey=%s | age=%dh", tostring(entry.dslKey), math.floor(age / 3600)))
    end
  end
  if 0 < purgedCount then
    store.entries = validEntries
    PlayerPrefsSystem.SaveTableToFile_N(store, PlayerPrefsSystem.ePlayerPrefsType.eUGCWowAICopilotUIGenDslCache)
    log(bWriteLog and string.format("[copilot_uigen:dsl:cache] _PurgeExpiredDslCache DONE | purged=%d | remaining=%d", purgedCount, #validEntries))
  else
    log(bWriteLog and string.format("[copilot_uigen:dsl:cache] _PurgeExpiredDslCache | all entries valid | count=%d", #store.entries))
  end
  self._dslCacheStore = store
  self._dslCacheDirty = false
end
function UIGenFeature:GetDslCacheEntries()
  if not self._hasPurgedCache then
    self._hasPurgedCache = true
    self:_PurgeExpiredDslCache()
  end
  if self._dslCacheDirty or not self._dslCacheStore then
    self._dslCacheStore = self:_LoadAndMigrateDslCache()
    self._dslCacheDirty = false
    log(bWriteLog and "[copilot_uigen:dsl:cache] GetDslCacheEntries: cache MISS, reloaded from disk")
  else
    log(bWriteLog and "[copilot_uigen:dsl:cache] GetDslCacheEntries: cache HIT, reading from memory")
  end
  local store = self._dslCacheStore
  if not store.entries then
    log(bWriteLog and "[copilot_uigen:dsl:cache] GetDslCacheEntries: store empty")
    return {}
  end
  local currentMapId = self.Owner.SessionManager:GetMapID() or "0"
  local now = os.time()
  local result = {}
  for _, entry in ipairs(store.entries) do
    if entry.mapId == currentMapId and now - (entry.ts or 0) <= DSL_CACHE_MAX_AGE then
      table.insert(result, entry)
    end
  end
  log(bWriteLog and string.format("[copilot_uigen:dsl:cache] GetDslCacheEntries | mapId=%s | total=%d | matched=%d | cached=%s", currentMapId, #store.entries, #result, tostring(not self._dslCacheDirty)))
  return result
end
function UIGenFeature:GetDslCacheByKey(dslKey)
  log(bWriteLog and string.format("[copilot_uigen:dsl:cache] GetDslCacheByKey | dslKey=%s", tostring(dslKey)))
  local entries = self:GetDslCacheEntries()
  for _, entry in ipairs(entries) do
    if entry.dslKey == dslKey then
      log(bWriteLog and string.format("[copilot_uigen:dsl:cache] GetDslCacheByKey FOUND | chatId=%s | ts=%s | dslLength=%d", tostring(entry.chatId), tostring(entry.ts), #(entry.dslText or "")))
      return entry
    end
  end
  log(bWriteLog and "[copilot_uigen:dsl:cache] GetDslCacheByKey: NOT FOUND")
  return nil
end
function UIGenFeature:IsDslCacheAvailable(dslKey)
  if not dslKey or dslKey == "" then
    return false
  end
  local available = self:GetDslCacheByKey(dslKey) ~= nil
  log(bWriteLog and string.format("[copilot_uigen:dsl:cache] IsDslCacheAvailable | dslKey=%s | result=%s", dslKey, tostring(available)))
  return available
end
function UIGenFeature:_ReportApplyResult(traceId, result, reason, errMsg)
  traceId = traceId or self._lastApplyTraceId or ""
  reason = reason or result == 1 and "success" or "dsl_apply_failed"
  errMsg = errMsg or ""
  log(bWriteLog and string.format("[copilot_uigen:dsl:apply] report apply result | trace_id=%s | result=%s | reason=%s | err_msg=%s", tostring(traceId), tostring(result), tostring(reason), tostring(errMsg)))
  local ok, err = pcall(function()
    LLMHandler.send_ugc_llm_ui_apply_result_req(traceId, result, reason, errMsg)
  end)
  if not ok then
    log(bWriteLog and string.format("[copilot_uigen:dsl:apply] report apply result failed: %s", tostring(err)))
  end
end
function UIGenFeature:_BuildApplyFailureReport(resultOrErr, defaultReason)
  local errMsg = resultOrErr
  local Stats
  if type(resultOrErr) == "table" then
    errMsg = resultOrErr.Error
    Stats = resultOrErr.Stats
  end
  local reason = defaultReason or "dsl_apply_failed"
  if type(Stats) == "table" and Stats.ResultReason and Stats.ResultReason ~= "" then
    reason = Stats.ResultReason
  end
  if errMsg == nil or errMsg == "" then
    if type(Stats) == "table" and Stats.ResultMessage and Stats.ResultMessage ~= "" then
      errMsg = Stats.ResultMessage
    else
      errMsg = reason
    end
  end
  return tostring(reason), tostring(errMsg)
end
function UIGenFeature:_OnCustomImageApplyComplete(traceId, Success, SymbolMap, Stats, Extra)
  _LogApplyStats("ApplyCachedDsl custom image async complete", Stats)
  log(bWriteLog and string.format("[copilot_uigen:dsl:apply] custom image async complete | trace_id=%s | success=%s | timeout=%s", tostring(traceId), tostring(Success), tostring(Extra and Extra.bTimeout)))
  if Success then
    self:_RefreshEditorCanvas(SymbolMap)
    self._hasUnsavedChanges = true
    self:_ReportApplyResult(traceId, 1, "success", "")
    self:_ShowApplyTips(LocUtil.GetLocalizeResStr(2026060260))
    return
  end
  local reason, errMsg = self:_BuildApplyFailureReport({
    Error = Stats and Stats.ResultMessage or "custom image async apply failed",
      }, "dsl_apply_failed")
  self:_ReportApplyResult(traceId, 0, reason, errMsg)
  self:_ShowApplyTips(LocUtil.GetLocalizeResStr(2026060261))
end
function UIGenFeature:ApplyCachedDsl(dslKey, bAfterOpenEditor)
  log(bWriteLog and string.format("[copilot_uigen:dsl:apply] ApplyCachedDsl BEGIN | dslKey=%s", tostring(dslKey)))
  local entry = self:GetDslCacheByKey(dslKey)
  if not entry then
    log(bWriteLog and "[copilot_uigen:dsl:apply] ApplyCachedDsl: FAILED, cache not found")
    self:_ReportApplyResult("", 0, "cache_not_found", "DSL cache not found: " .. tostring(dslKey))
    return false
  end
  local applyMode = entry.applyMode or "rebuild"
  local traceId = entry.trace_id or entry.traceId or ""
  self._lastApplyTraceId = traceId
  log(bWriteLog and string.format("[copilot_uigen:dsl:apply] ApplyCachedDsl entry found | dsl_length=%d | chat_id=%s | trace_id=%s | apply_mode=%s", #(entry.dslText or ""), tostring(entry.chatId), tostring(traceId), tostring(applyMode)))
  if not self:_CanApply() then
    log(bWriteLog and string.format("[copilot_uigen:dsl:apply] ApplyCachedDsl: editor not ready | bAfterOpenEditor=%s", tostring(bAfterOpenEditor)))
    if not bAfterOpenEditor and self:_TryOpenCustomUIEditorForApply() then
      if self.Owner and type(self.Owner.AddGameTimer) == "function" then
        self.Owner:AddGameTimer(0, false, function()
          self:ApplyCachedDsl(dslKey, true)
        end)
        return true
      end
      log(bWriteLog and "[copilot_uigen:dsl:apply] ApplyCachedDsl: Owner.AddGameTimer unavailable, apply immediately after open")
      return self:ApplyCachedDsl(dslKey, true)
    end
    self:_ShowApplyTips(LocUtil.GetLocalizeResStr(2026060262))
    self:_ReportApplyResult(traceId, 0, "editor_not_ready", "Custom UI editor not ready")
    return false
  end
  log(bWriteLog and string.format("[copilot_uigen:dsl:apply] ApplyCachedDsl applying DSL to canvas | apply_mode=%s", applyMode))
  self:_ClearCanvasBeforeApply()
  local ok, resultOrErr = self:_ApplyDsl(entry.dslText, applyMode, function(Success, SymbolMap, Stats, Extra)
    self:_OnCustomImageApplyComplete(traceId, Success, SymbolMap, Stats, Extra)
  end)
  if ok then
    self:_RefreshEditorCanvas(resultOrErr and resultOrErr.SymbolMap)
    self._hasUnsavedChanges = true
    log(bWriteLog and string.format("[copilot_uigen:dsl:apply] ApplyCachedDsl SUCCESS | dslKey=%s", tostring(entry.dslKey)))
    self:_ReportApplyResult(traceId, 1, "success", "")
    self:_ShowApplyTips(LocUtil.GetLocalizeResStr(2026060260))
  else
    local ErrorText = resultOrErr
    local Stats
    if type(resultOrErr) == "table" then
      ErrorText = resultOrErr.Error
      Stats = resultOrErr.Stats
    end
    _LogApplyStats("ApplyCachedDsl failed detail", Stats)
    if type(resultOrErr) == "table" and resultOrErr.bAsyncWaiting == true then
      log(bWriteLog and string.format("[copilot_uigen:dsl:apply] ApplyCachedDsl: async waiting, skip result report | reason=%s | error=%s", tostring(Stats and Stats.ResultReason), tostring(ErrorText)))
      self:_ShowApplyTips(LocUtil.GetLocalizeResStr(2026060815))
    else
      log(bWriteLog and string.format("[copilot_uigen:dsl:apply] ApplyCachedDsl: FAILED, error=%s", tostring(ErrorText)))
      local reason, errMsg = self:_BuildApplyFailureReport(resultOrErr, "dsl_apply_failed")
      self:_ReportApplyResult(traceId, 0, reason, errMsg)
      self:_ShowApplyTips(LocUtil.GetLocalizeResStr(2026060261))
    end
  end
  return ok
end
function UIGenFeature:_NotifyUIGenComplete()
  local IsMovingWindowShow = UIManager.IsUIShow(UIManager.UI_Config_InGame.CreativeCopilot_DraggableCopilotWindow)
  if IsMovingWindowShow then
    return
  end
  local SubSystem = SubsystemMgr:Get("AICopilotSubSystem")
  if SubSystem then
    SubSystem:SetDraggableTips(LocUtil.GetLocalizeResStr(2026060808))
  end
end
function UIGenFeature:_ShowApplyTips(text)
  ShowNotice(text)
end
local class = require("class")
local object = require("object")
return class(object, nil, UIGenFeature)