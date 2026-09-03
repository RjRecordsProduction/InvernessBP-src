local Config_UGC_Copilot = require("client.slua.logic.ugc.copilot.config_ugc_copilot")
local PlacePrefabFeature = {Owner = nil}
PlacePrefabFeature.Enum_SourceType = {
  Backpack = 1,
  Public = 2,
  Private = 3
}
PlacePrefabFeature.Enum_PlacePrefab_ResultCode = {
  Success = 0,
  InvalidRequest = 1,
  PutDownFailed = 2,
  MetaNotFound = 3,
  MetaFetchFailed = 4,
  Timeout = 5
}
PlacePrefabFeature.META_FETCH_TIMEOUT = 10.0
PlacePrefabFeature.ITEM_PROCESS_TIMEOUT = 10.0
PlacePrefabFeature.META_POLL_INTERVAL = 0.5
function PlacePrefabFeature:ctor()
  print(bWriteLog and "PlacePrefabFeature:ctor")
  self:ResetData()
end
function PlacePrefabFeature:ResetData()
  self:CleanupAllTimers()
  self.PendingPlaceRequests = {}
  self.PendingCheckRequests = {}
  self.ActiveTimers = {}
  self.PendingPrivateMetaCallbacks = {}
  self.PrivateMetaRequestSeq = 0
  self.PendingPublicMetaQueue = {}
  self.PublicMetaBatchTimerHandle = nil
end
function PlacePrefabFeature:RegistEvents()
  if not self.Owner then
    print(bWriteLog and "PlacePrefabFeature:RegistEvents - Owner not available")
    return
  end
  self.Owner:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PREFAB_MALL_PRIVATE_META_UPDATES, self.OnPrivateMetaUpdated, self)
  print(bWriteLog and "PlacePrefabFeature:RegistEvents - Registered private meta update event")
end
function PlacePrefabFeature:OnPrivateMetaUpdated(bIsDirty)
  print(bWriteLog and "PlacePrefabFeature:OnPrivateMetaUpdated - bIsDirty: " .. tostring(bIsDirty))
  local CallbacksToProcess = {}
  for RequestID, Context in pairs(self.PendingPrivateMetaCallbacks) do
    table.insert(CallbacksToProcess, {RequestID = RequestID, Context = Context})
  end
  for _, Item in ipairs(CallbacksToProcess) do
    local RequestID = Item.RequestID
    local Context = Item.Context
    self.PendingPrivateMetaCallbacks[RequestID] = nil
    if Context.TimeoutHandle then
      self:RemoveManagedTimer(Context.TimeoutHandle)
    end
    if Context.Callback then
      print(bWriteLog and string.format("PlacePrefabFeature:OnPrivateMetaUpdated - Processing callback for RequestID=%s, Slot=%s", tostring(RequestID), tostring(Context.Slot)))
      Context.Callback(true, Context.Slot)
    end
  end
end
function PlacePrefabFeature:OnPrivateMetaTimeout(RequestID)
  print(bWriteLog and "PlacePrefabFeature:OnPrivateMetaTimeout - RequestID: " .. tostring(RequestID))
  local Context = self.PendingPrivateMetaCallbacks[RequestID]
  if not Context then
    print(bWriteLog and "PlacePrefabFeature:OnPrivateMetaTimeout - Context not found, already processed")
    return
  end
  self.PendingPrivateMetaCallbacks[RequestID] = nil
  if Context.Callback then
    Context.Callback(false, Context.Slot)
  end
end
function PlacePrefabFeature:AddManagedTimer(SeqID, Delay, bLoop, Callback)
  if not self.Owner then
    print(bWriteLog and "PlacePrefabFeature:AddManagedTimer - Owner not available")
    return nil
  end
  local TimerHandle
  if bLoop then
    if not self.Owner.AddTimerLoop then
      print(bWriteLog and "PlacePrefabFeature:AddManagedTimer - Owner.AddTimerLoop not available")
      return nil
    end
    TimerHandle = self.Owner:AddTimerLoop(Delay, Callback, 0, Delay)
  else
    if not self.Owner.AddTimerOnce then
      print(bWriteLog and "PlacePrefabFeature:AddManagedTimer - Owner.AddTimerOnce not available")
      return nil
    end
    TimerHandle = self.Owner:AddTimerOnce(Delay, Callback)
  end
  if TimerHandle then
    self.ActiveTimers[TimerHandle] = SeqID or "place_request"
    print(bWriteLog and string.format("PlacePrefabFeature:AddManagedTimer - Added timer %s for SeqID=%s", tostring(TimerHandle), tostring(SeqID)))
  end
  return TimerHandle
end
function PlacePrefabFeature:RemoveManagedTimer(TimerHandle)
  if not TimerHandle then
    return
  end
  if self.ActiveTimers[TimerHandle] then
    self.ActiveTimers[TimerHandle] = nil
    if self.Owner and self.Owner.RemoveTimer then
      self.Owner:RemoveTimer(TimerHandle)
      print(bWriteLog and "PlacePrefabFeature:RemoveManagedTimer - Removed timer: " .. tostring(TimerHandle))
    end
  end
end
function PlacePrefabFeature:CleanupTimersForSeqID(SeqID)
  if not SeqID then
    return
  end
  local TimersToRemove = {}
  for TimerHandle, AssociatedSeqID in pairs(self.ActiveTimers) do
    if AssociatedSeqID == SeqID then
      table.insert(TimersToRemove, TimerHandle)
    end
  end
  for _, TimerHandle in ipairs(TimersToRemove) do
    self:RemoveManagedTimer(TimerHandle)
  end
  if 0 < #TimersToRemove then
    print(bWriteLog and string.format("PlacePrefabFeature:CleanupTimersForSeqID - Cleaned up %d timers for SeqID=%s", #TimersToRemove, tostring(SeqID)))
  end
  self:CancelPublicMetaRequestsForSeqID(SeqID)
end
function PlacePrefabFeature:CleanupAllTimers()
  if not self.ActiveTimers then
    return
  end
  local Count = 0
  for TimerHandle, _ in pairs(self.ActiveTimers) do
    if self.Owner and self.Owner.RemoveTimer then
      self.Owner:RemoveTimer(TimerHandle)
    end
    Count = Count + 1
  end
  self.ActiveTimers = {}
  self.PublicMetaBatchTimerHandle = nil
  self.PendingPublicMetaQueue = {}
  if 0 < Count then
    print(bWriteLog and "PlacePrefabFeature:CleanupAllTimers - Cleaned up " .. tostring(Count) .. " timers")
  end
end
function PlacePrefabFeature:OnInitialize()
  print(bWriteLog and "PlacePrefabFeature:OnInitialize")
  self:StartPublicMetaBatchLoop()
end
PlacePrefabFeature.PUBLIC_META_BATCH_INTERVAL = 0.12
PlacePrefabFeature.PUBLIC_META_RETRY_REQUEST_INTERVAL = 1
local FormatIDListForLog = function(IdList)
  if not IdList or #IdList == 0 then
    return "[]"
  end
  local Result = {}
  for _, ID in ipairs(IdList) do
    table.insert(Result, tostring(ID))
  end
  return "[" .. table.concat(Result, ",") .. "]"
end
function PlacePrefabFeature:StartPublicMetaBatchLoop()
  if self.PublicMetaBatchTimerHandle then
    local time_ticker = require("common.time_ticker")
    if time_ticker.IsRunning(self.PublicMetaBatchTimerHandle) then
      return
    else
      self.PublicMetaBatchTimerHandle = nil
    end
  end
  print(bWriteLog and "PlacePrefabFeature:StartPublicMetaBatchLoop - Starting batch loop")
  self.PublicMetaBatchTimerHandle = self:AddManagedTimer(nil, PlacePrefabFeature.PUBLIC_META_BATCH_INTERVAL, true, function()
    self:ProcessPublicMetaBatchQueue()
  end)
end
function PlacePrefabFeature:StopPublicMetaBatchLoop()
  if self.PublicMetaBatchTimerHandle then
    self:RemoveManagedTimer(self.PublicMetaBatchTimerHandle)
    self.PublicMetaBatchTimerHandle = nil
    print(bWriteLog and "PlacePrefabFeature:StopPublicMetaBatchLoop - Stopped batch loop")
  end
end
function PlacePrefabFeature:ProcessPublicMetaBatchQueue()
  if not self.PendingPublicMetaQueue then
    return
  end
  local PrefabIDsToRequest = {}
  local logic_ugc_prefab_mall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
  local CurrentTime = os.time()
  for PrefabID, QueueItem in pairs(self.PendingPublicMetaQueue) do
    local MetaInfo = logic_ugc_prefab_mall and logic_ugc_prefab_mall:GetPrefabMeta(PrefabID)
    if MetaInfo then
      print(bWriteLog and "PlacePrefabFeature:ProcessPublicMetaBatchQueue - Meta already cached for PrefabID: " .. tostring(PrefabID))
      for _, CallbackInfo in ipairs(QueueItem.Callbacks) do
        if CallbackInfo.Callback then
          CallbackInfo.Callback(true, MetaInfo)
        end
      end
      self.PendingPublicMetaQueue[PrefabID] = nil
    else
      local IsInInvalidList = false
      if logic_ugc_prefab_mall and logic_ugc_prefab_mall.IsInInValidIds then
        IsInInvalidList = logic_ugc_prefab_mall:IsInInValidIds(PrefabID) and true or false
      end
      if not IsInInvalidList then
        local LastRequestTime = QueueItem.LastRequestTime or 0
        if not QueueItem.bRequested then
          table.insert(PrefabIDsToRequest, PrefabID)
          QueueItem.bRequested = true
          QueueItem.LastRequestTime = CurrentTime
        elseif CurrentTime - LastRequestTime >= PlacePrefabFeature.PUBLIC_META_RETRY_REQUEST_INTERVAL then
          table.insert(PrefabIDsToRequest, PrefabID)
          QueueItem.LastRequestTime = CurrentTime
        end
      end
    end
  end
  if bWriteLog then
    local QueueCount = 0
    for _ in pairs(self.PendingPublicMetaQueue) do
      QueueCount = QueueCount + 1
    end
  end
  if 0 < #PrefabIDsToRequest then
    print(bWriteLog and string.format("PlacePrefabFeature:ProcessPublicMetaBatchQueue - Sending batch request for %d PrefabIDs", #PrefabIDsToRequest))
    if logic_ugc_prefab_mall then
      logic_ugc_prefab_mall:ReqPrefabMetaList(PrefabIDsToRequest, logic_ugc_prefab_mall.ENUM_META_REQ_TYPE.COPILOT, {
        bSplit = false,
        isSilent = true,
        bForce = true
      })
    end
  end
  self:CheckPublicMetaQueueCallbacks()
end
function PlacePrefabFeature:CheckPublicMetaQueueCallbacks()
  if not self.PendingPublicMetaQueue then
    return
  end
  local logic_ugc_prefab_mall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
  if not logic_ugc_prefab_mall then
    return
  end
  local PrefabIDsToRemove = {}
  for PrefabID, QueueItem in pairs(self.PendingPublicMetaQueue) do
    local MetaInfo = logic_ugc_prefab_mall:GetPrefabMeta(PrefabID)
    if MetaInfo then
      print(bWriteLog and "PlacePrefabFeature:CheckPublicMetaQueueCallbacks - Meta fetched for PrefabID: " .. tostring(PrefabID))
      for _, CallbackInfo in ipairs(QueueItem.Callbacks) do
        if CallbackInfo.Callback then
          CallbackInfo.Callback(true, MetaInfo)
        end
      end
      table.insert(PrefabIDsToRemove, PrefabID)
    else
      local CurrentTime = os.time()
      if bWriteLog then
        local IsInInvalidList = logic_ugc_prefab_mall.IsInInValidIds and logic_ugc_prefab_mall:IsInInValidIds(PrefabID) and true or false
        local LastRequestTime = QueueItem.LastRequestTime or 0
        local LastRequestAge = 0 < LastRequestTime and CurrentTime - LastRequestTime or -1
        print(string.format("PlacePrefabFeature:CheckPublicMetaQueueCallbacks - Pending PrefabID=%s, callbackCount=%d, bRequested=%s, lastRequestAge=%s, isInvalid=%s", tostring(PrefabID), #QueueItem.Callbacks, tostring(QueueItem.bRequested), tostring(LastRequestAge), tostring(IsInInvalidList)))
      end
      for i = #QueueItem.Callbacks, 1, -1 do
        local CallbackInfo = QueueItem.Callbacks[i]
        if CurrentTime - CallbackInfo.StartTime > PlacePrefabFeature.META_FETCH_TIMEOUT then
          print(bWriteLog and string.format("PlacePrefabFeature:CheckPublicMetaQueueCallbacks - Timeout for PrefabID: %d, callback index: %d, waited=%ds, timeout=%ss, seq_id=%s", PrefabID, i, CurrentTime - CallbackInfo.StartTime, PlacePrefabFeature.META_FETCH_TIMEOUT, tostring(CallbackInfo.SeqID)))
          if CallbackInfo.Callback then
            CallbackInfo.Callback(false, nil)
          end
          table.remove(QueueItem.Callbacks, i)
        end
      end
      if #QueueItem.Callbacks == 0 then
        table.insert(PrefabIDsToRemove, PrefabID)
      end
    end
  end
  for _, PrefabID in ipairs(PrefabIDsToRemove) do
    self.PendingPublicMetaQueue[PrefabID] = nil
  end
end
function PlacePrefabFeature:AddToPublicMetaBatchQueue(PrefabID, SeqID, Callback)
  print(bWriteLog and string.format("PlacePrefabFeature:AddToPublicMetaBatchQueue - PrefabID: %d, SeqID: %s", PrefabID, tostring(SeqID)))
  if not self.PendingPublicMetaQueue[PrefabID] then
    self.PendingPublicMetaQueue[PrefabID] = {
      Callbacks = {},
      bRequested = false,
      LastRequestTime = 0
    }
  end
  table.insert(self.PendingPublicMetaQueue[PrefabID].Callbacks, {
    Callback = Callback,
    SeqID = SeqID,
    StartTime = os.time()
  })
  self:StartPublicMetaBatchLoop()
end
function PlacePrefabFeature:CancelPublicMetaRequestsForSeqID(SeqID)
  if not SeqID or not self.PendingPublicMetaQueue then
    return
  end
  local CancelledCount = 0
  for PrefabID, QueueItem in pairs(self.PendingPublicMetaQueue) do
    for i = #QueueItem.Callbacks, 1, -1 do
      if QueueItem.Callbacks[i].SeqID == SeqID then
        table.remove(QueueItem.Callbacks, i)
        CancelledCount = CancelledCount + 1
      end
    end
    if #QueueItem.Callbacks == 0 then
      self.PendingPublicMetaQueue[PrefabID] = nil
    end
  end
  if 0 < CancelledCount then
    print(bWriteLog and string.format("PlacePrefabFeature:CancelPublicMetaRequestsForSeqID - Cancelled %d callbacks for SeqID: %s", CancelledCount, tostring(SeqID)))
  end
end
function PlacePrefabFeature:CheckSingleAsset(AssetInfo, Callback)
  local Result = {
    source_type = AssetInfo.source_type,
    asset_id = AssetInfo.asset_id,
    real_asset_id = nil,
    available = false,
    name = AssetInfo.name,
    error_msg = nil
  }
  if not AssetInfo.source_type then
    Result.error_msg = "Missing source_type"
    Callback(Result)
    return
  end
  if not AssetInfo.asset_id then
    Result.error_msg = "Missing asset_id"
    Callback(Result)
    return
  end
  if AssetInfo.source_type == PlacePrefabFeature.Enum_SourceType.Backpack then
    self:CheckBackpackAsset(AssetInfo, Result, Callback)
  elseif AssetInfo.source_type == PlacePrefabFeature.Enum_SourceType.Public then
    self:CheckPublicAsset(AssetInfo, Result, Callback)
  elseif AssetInfo.source_type == PlacePrefabFeature.Enum_SourceType.Private then
    self:CheckPrivateAsset(AssetInfo, Result, Callback)
  else
    Result.error_msg = "Invalid source_type (must be 1=Backpack, 2=Public or 3=Private): " .. tostring(AssetInfo.source_type)
    Callback(Result)
  end
end
function PlacePrefabFeature:CheckBackpackAsset(AssetInfo, Result, Callback)
  Result.real_asset_id = AssetInfo.asset_id
  Result.available = true
  Result.name = AssetInfo.name or "Backpack Item"
  Callback(Result)
end
function PlacePrefabFeature:CheckPublicAsset(AssetInfo, Result, Callback)
  local PrefabID = AssetInfo.asset_id
  local logic_ugc_prefab_mall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
  local MetaInfo = logic_ugc_prefab_mall:GetPrefabMeta(PrefabID)
  if MetaInfo then
    Result.real_asset_id = MetaInfo.Meta.AssetId
    Result.available = true
    Result.name = Result.name or MetaInfo.Meta.Name
    Callback(Result)
    return
  end
  print(bWriteLog and "PlacePrefabFeature:CheckPublicAsset - Fetching meta for prefab_id: " .. tostring(PrefabID))
  self:FetchPublicPrefabMetaManaged(PrefabID, nil, function(Success, FetchedMeta)
    if Success and FetchedMeta then
      Result.real_asset_id = FetchedMeta.Meta.AssetId
      Result.available = true
      Result.name = Result.name or FetchedMeta.Meta.Name
    else
      Result.error_msg = "Meta fetch timeout or failed"
    end
    Callback(Result)
  end)
end
function PlacePrefabFeature:CheckPrivateAsset(AssetInfo, Result, Callback)
  local Slot = AssetInfo.asset_id
  local logic_ugc_prefab_mall_private = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private")
  if logic_ugc_prefab_mall_private:IsPrivateMetaCompleted() then
    local MetaInfo = logic_ugc_prefab_mall_private:GetPrivateMeta(Slot)
    if MetaInfo then
      Result.real_asset_id = MetaInfo.Meta.AssetId
      Result.available = true
      Result.name = Result.name or MetaInfo.Meta.Name
    else
      Result.error_msg = "Private meta not found for slot: " .. tostring(Slot)
    end
    Callback(Result)
  else
    print(bWriteLog and "PlacePrefabFeature:CheckPrivateAsset - Private meta list not loaded, fetching...")
    self:FetchPrivatePrefabMetaManaged(Slot, nil, function(Success, FetchedMeta)
      if Success and FetchedMeta then
        Result.real_asset_id = FetchedMeta.Meta.AssetId
        Result.available = true
        Result.name = Result.name or FetchedMeta.Meta.Name
      else
        Result.error_msg = "Private meta fetch failed for slot: " .. tostring(Slot)
      end
      Callback(Result)
    end)
  end
end
function PlacePrefabFeature:GenerateRequestKey(Request)
  if Request.source_type == PlacePrefabFeature.Enum_SourceType.Public and Request.asset_id then
    return "pub_" .. tostring(Request.asset_id)
  elseif Request.source_type == PlacePrefabFeature.Enum_SourceType.Private and Request.asset_id then
    return "prv_" .. tostring(Request.asset_id)
  else
    return "trace_" .. tostring(Request.trace_id or os.time())
  end
end
function PlacePrefabFeature:ValidateRequest(Request)
  if not Request then
    return false, "Request is nil"
  end
  if not Request.source_type then
    return false, "source_type is required"
  end
  if not Request.asset_id then
    return false, "asset_id is required"
  end
  if Request.source_type ~= PlacePrefabFeature.Enum_SourceType.Backpack and Request.source_type ~= PlacePrefabFeature.Enum_SourceType.Public and Request.source_type ~= PlacePrefabFeature.Enum_SourceType.Private then
    return false, "Invalid source_type (must be 1=Backpack, 2=Public or 3=Private): " .. tostring(Request.source_type)
  end
  return true, nil
end
function PlacePrefabFeature:BuildResponse(ResultCode, Request, RealAssetID, ErrorMsg)
  local Response = {
    result_code = ResultCode,
    source_type = Request and Request.source_type or nil,
    asset_id = Request and Request.asset_id or nil,
    real_asset_id = RealAssetID,
    trace_id = Request and Request.trace_id or nil,
    error_msg = ErrorMsg
  }
  return Response
end
function PlacePrefabFeature:GetCachedMetaByRequest(Request)
  if Request.source_type == PlacePrefabFeature.Enum_SourceType.Public then
    local logic_ugc_prefab_mall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
    return logic_ugc_prefab_mall:GetPrefabMeta(Request.asset_id)
  elseif Request.source_type == PlacePrefabFeature.Enum_SourceType.Private then
    local logic_ugc_prefab_mall_private = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private")
    return logic_ugc_prefab_mall_private:GetPrivateMeta(Request.asset_id)
  end
  return nil
end
function PlacePrefabFeature:FetchPublicPrefabMetaManaged(PrefabID, SeqID, Callback)
  print(bWriteLog and "PlacePrefabFeature:FetchPublicPrefabMetaManaged - PrefabID: " .. tostring(PrefabID))
  local logic_ugc_prefab_mall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
  local MetaInfo = logic_ugc_prefab_mall and logic_ugc_prefab_mall:GetPrefabMeta(PrefabID)
  if MetaInfo then
    print(bWriteLog and "PlacePrefabFeature:FetchPublicPrefabMetaManaged - Meta already cached for PrefabID: " .. tostring(PrefabID))
    if Callback then
      Callback(true, MetaInfo)
    end
    return
  end
  self:AddToPublicMetaBatchQueue(PrefabID, SeqID, Callback)
end
function PlacePrefabFeature:FetchPublicPrefabMeta(PrefabID, Callback)
  self:FetchPublicPrefabMetaManaged(PrefabID, nil, Callback)
end
function PlacePrefabFeature:EnsurePrivateMetaLoaded(SeqID, Slot, Callback)
  local logic_ugc_prefab_mall_private = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private")
  if logic_ugc_prefab_mall_private:IsPrivateMetaCompleted() then
    print(bWriteLog and "PlacePrefabFeature:EnsurePrivateMetaLoaded - Already loaded")
    if Callback then
      Callback(true, Slot)
    end
    return
  end
  print(bWriteLog and "PlacePrefabFeature:EnsurePrivateMetaLoaded - Requesting private meta list")
  self.PrivateMetaRequestSeq = (self.PrivateMetaRequestSeq or 0) + 1
  local RequestID = self.PrivateMetaRequestSeq
  local TimeoutHandle = self:AddManagedTimer(SeqID, PlacePrefabFeature.META_FETCH_TIMEOUT, false, function()
    self:OnPrivateMetaTimeout(RequestID)
  end)
  if not TimeoutHandle then
    print(bWriteLog and "PlacePrefabFeature:EnsurePrivateMetaLoaded - Failed to add timeout timer")
  end
  self.PendingPrivateMetaCallbacks[RequestID] = {
    Callback = Callback,
    SeqID = SeqID,
    TimeoutHandle = TimeoutHandle,
      }
  print(bWriteLog and string.format("PlacePrefabFeature:EnsurePrivateMetaLoaded - Added pending callback, RequestID=%d, Slot=%s", RequestID, tostring(Slot)))
  logic_ugc_prefab_mall_private:ReqPrefabMetaList()
end
function PlacePrefabFeature:FetchPrivatePrefabMetaManaged(Slot, SeqID, Callback)
  print(bWriteLog and "PlacePrefabFeature:FetchPrivatePrefabMetaManaged - Slot: " .. tostring(Slot))
  local logic_ugc_prefab_mall_private = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private")
  self:EnsurePrivateMetaLoaded(SeqID, Slot, function(Success, ReturnedSlot)
    if not Success then
      print(bWriteLog and "PlacePrefabFeature:FetchPrivatePrefabMetaManaged - Failed to load private meta list")
      if Callback then
        Callback(false, nil)
      end
      return
    end
    if SeqID and not self.PendingCheckRequests[SeqID] then
      print(bWriteLog and "PlacePrefabFeature:FetchPrivatePrefabMetaManaged - Request cancelled")
      if Callback then
        Callback(false, nil)
      end
      return
    end
    local MetaInfo = logic_ugc_prefab_mall_private:GetPrivateMeta(ReturnedSlot or Slot)
    if MetaInfo then
      print(bWriteLog and "PlacePrefabFeature:FetchPrivatePrefabMetaManaged - Meta found for slot: " .. tostring(Slot))
      if Callback then
        Callback(true, MetaInfo)
      end
    else
      print(bWriteLog and "PlacePrefabFeature:FetchPrivatePrefabMetaManaged - Meta not found for slot: " .. tostring(Slot))
      if Callback then
        Callback(false, nil)
      end
    end
  end)
end
function PlacePrefabFeature:PlacePrefabFromRequest(Request, Callback)
  print(bWriteLog and "PlacePrefabFeature:PlacePrefabFromRequest - Start")
  local IsValid, ErrorMsg = self:ValidateRequest(Request)
  if not IsValid then
    print(bWriteLog and "PlacePrefabFeature:PlacePrefabFromRequest - Invalid request: " .. tostring(ErrorMsg))
    local Response = self:BuildResponse(PlacePrefabFeature.Enum_PlacePrefab_ResultCode.InvalidRequest, Request, nil, ErrorMsg)
    self:OnPlacePrefabComplete(Response, Callback)
    return
  end
  local RequestKey = self:GenerateRequestKey(Request)
  print(bWriteLog and "PlacePrefabFeature:PlacePrefabFromRequest - RequestKey: " .. tostring(RequestKey))
  self.PendingPlaceRequests[RequestKey] = {Request = Request, Callback = Callback}
  local CachedMeta = self:GetCachedMetaByRequest(Request)
  if CachedMeta then
    print(bWriteLog and "PlacePrefabFeature:PlacePrefabFromRequest - Meta found in cache")
    local RealAssetID = CachedMeta.Meta.AssetId
    self:DoPutDown(RealAssetID, RequestKey, Request, Callback)
  elseif Request.source_type == PlacePrefabFeature.Enum_SourceType.Public then
    print(bWriteLog and "PlacePrefabFeature:PlacePrefabFromRequest - Fetching meta for PrefabID: " .. tostring(Request.asset_id))
    self:FetchPublicPrefabMeta(Request.asset_id, function(Success, MetaInfo)
      if Success and MetaInfo then
        local RealAssetID = MetaInfo.Meta.AssetId
        print(bWriteLog and "PlacePrefabFeature:PlacePrefabFromRequest - Meta fetched, RealAssetID: " .. tostring(RealAssetID))
        self:DoPutDown(RealAssetID, RequestKey, Request, Callback)
      else
        print(bWriteLog and "PlacePrefabFeature:PlacePrefabFromRequest - Meta fetch failed")
        self.PendingPlaceRequests[RequestKey] = nil
        local Response = self:BuildResponse(PlacePrefabFeature.Enum_PlacePrefab_ResultCode.MetaFetchFailed, Request, nil, "Failed to fetch meta from server")
        self:OnPlacePrefabComplete(Response, Callback)
      end
    end)
  elseif Request.source_type == PlacePrefabFeature.Enum_SourceType.Private then
    print(bWriteLog and "PlacePrefabFeature:PlacePrefabFromRequest - Private meta not in cache, fetching for slot: " .. tostring(Request.asset_id))
    self:FetchPrivatePrefabMetaManaged(Request.asset_id, nil, function(Success, FetchedMeta)
      if not self.PendingPlaceRequests[RequestKey] then
        print(bWriteLog and "PlacePrefabFeature:PlacePrefabFromRequest - Request cancelled after private meta fetch")
        return
      end
      if Success and FetchedMeta then
        local RealAssetID = FetchedMeta.Meta.AssetId
        print(bWriteLog and "PlacePrefabFeature:PlacePrefabFromRequest - Private meta fetched, RealAssetID: " .. tostring(RealAssetID))
        self:DoPutDown(RealAssetID, RequestKey, Request, Callback)
      else
        print(bWriteLog and "PlacePrefabFeature:PlacePrefabFromRequest - Private meta fetch failed for slot: " .. tostring(Request.asset_id))
        self.PendingPlaceRequests[RequestKey] = nil
        local Response = self:BuildResponse(PlacePrefabFeature.Enum_PlacePrefab_ResultCode.MetaNotFound, Request, nil, "Private library meta not found for slot: " .. tostring(Request.asset_id))
        self:OnPlacePrefabComplete(Response, Callback)
      end
    end)
  end
end
function PlacePrefabFeature:DoPutDown(RealAssetID, RequestKey, Request, Callback)
  print(bWriteLog and "PlacePrefabFeature:DoPutDown - RealAssetID: " .. tostring(RealAssetID))
  local logic_ugc_prefab_mall_asset_mgr = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_asset_mgr")
  logic_ugc_prefab_mall_asset_mgr:PutDown(RealAssetID, function(ReturnedAssetId)
    local bPutDownSuccess = ReturnedAssetId ~= nil
    print(bWriteLog and string.format("PlacePrefabFeature:DoPutDown - callback, ReturnedAssetId=%s, success=%s", tostring(ReturnedAssetId), tostring(bPutDownSuccess)))
    if RequestKey and self.PendingPlaceRequests[RequestKey] then
      self.PendingPlaceRequests[RequestKey] = nil
    end
    local ResultCode = bPutDownSuccess and PlacePrefabFeature.Enum_PlacePrefab_ResultCode.Success or PlacePrefabFeature.Enum_PlacePrefab_ResultCode.PutDownFailed
    local ErrorMsg
    if not bPutDownSuccess then
      ErrorMsg = "PutDown operation failed"
    end
    local FinalAssetId = ReturnedAssetId or RealAssetID
    local Response = self:BuildResponse(ResultCode, Request, FinalAssetId, ErrorMsg)
    self:OnPlacePrefabComplete(Response, Callback)
  end, {SilentPutDown = true})
end
function PlacePrefabFeature:OnPlacePrefabComplete(Response, Callback)
  print(bWriteLog and string.format("PlacePrefabFeature:OnPlacePrefabComplete - result_code: %s, real_asset_id: %s, trace_id: %s", tostring(Response.result_code), tostring(Response.real_asset_id), tostring(Response.trace_id)))
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_PLACE_PREFAB_COMPLETE, Response)
  if Callback then
    Callback(Response)
  end
end
function PlacePrefabFeature:PlacePublicPrefab(PrefabID, TraceID, Callback)
  local Request = {
    source_type = PlacePrefabFeature.Enum_SourceType.Public,
    asset_id = PrefabID,
    trace_id = TraceID
  }
  self:PlacePrefabFromRequest(Request, Callback)
end
function PlacePrefabFeature:PlacePrivatePrefab(Slot, TraceID, Callback)
  local Request = {
    source_type = PlacePrefabFeature.Enum_SourceType.Private,
    asset_id = Slot,
    trace_id = TraceID
  }
  self:PlacePrefabFromRequest(Request, Callback)
end
function PlacePrefabFeature:CancelPlaceRequest(RequestKey)
  if RequestKey and self.PendingPlaceRequests[RequestKey] then
    print(bWriteLog and "PlacePrefabFeature:CancelPlaceRequest - RequestKey: " .. tostring(RequestKey))
    self.PendingPlaceRequests[RequestKey] = nil
  end
end
function PlacePrefabFeature:IsPendingPlace(RequestKey)
  return RequestKey and self.PendingPlaceRequests[RequestKey] ~= nil
end
function PlacePrefabFeature:HandleCheckAsset(CheckAssetData, Callback)
  print(bWriteLog and "PlacePrefabFeature:HandleCheckAsset - Start")
  local SeqID = CheckAssetData.seq_id
  local Categories = CheckAssetData.categories or {}
  local UserSelections = CheckAssetData.user_selections
  local Response = {
    seq_id = SeqID,
    type = "check_asset",
    cancelled = false,
    selected = {}
  }
  if #Categories == 0 then
    print(bWriteLog and "PlacePrefabFeature:HandleCheckAsset - No categories")
    if Callback then
      Callback(Response)
    end
    return
  end
  local SelectedItems = {}
  for i, CategoryData in ipairs(Categories) do
    local CategoryName = CategoryData.category
    local Items = CategoryData.items or {}
    if 0 < #Items then
      local SelectedIndex = 1
      if UserSelections and UserSelections[i] then
        SelectedIndex = UserSelections[i]
        if SelectedIndex < 1 or SelectedIndex > #Items then
          print(bWriteLog and string.format("PlacePrefabFeature:HandleCheckAsset - Invalid user selection index %d for category %s (max %d), using default 1", SelectedIndex, tostring(CategoryName), #Items))
          SelectedIndex = 1
        end
      end
      local SelectedItem = Items[SelectedIndex]
      table.insert(SelectedItems, {
        category = CategoryName,
        selected_id = SelectedItem.id,
        selected_type = SelectedItem.type
      })
      print(bWriteLog and string.format("PlacePrefabFeature:HandleCheckAsset - Category %s: selected index %d (id=%s, type=%s)", tostring(CategoryName), SelectedIndex, tostring(SelectedItem.id), tostring(SelectedItem.type)))
    end
  end
  if #SelectedItems == 0 then
    print(bWriteLog and "PlacePrefabFeature:HandleCheckAsset - No items selected")
    if Callback then
      Callback(Response)
    end
    return
  end
  local Context = {
    SeqID = SeqID,
    Callback = Callback,
    Response = Response,
    SelectedItems = SelectedItems,
    TotalCount = #SelectedItems,
    CompletedCount = 0,
    ItemResults = {},
    ItemCompleted = {},
    bFinished = false
  }
  self.PendingCheckRequests[SeqID] = Context
  local OnItemComplete = function(Category, Success, RealAssetID, ErrorMsg)
    if Context.ItemCompleted[Category] then
      print(bWriteLog and "PlacePrefabFeature:HandleCheckAsset - Item already completed: " .. tostring(Category))
      return
    end
    Context.ItemCompleted[Category] = true
    Context.CompletedCount = Context.CompletedCount + 1
    Context.ItemResults[Category] = {
      success = Success,
      real_asset_id = RealAssetID,
      error_msg = ErrorMsg
    }
    print(bWriteLog and string.format("PlacePrefabFeature:HandleCheckAsset - Item complete: %s, success=%s, completed=%d/%d", tostring(Category), tostring(Success), Context.CompletedCount, Context.TotalCount))
    if Context.CompletedCount >= Context.TotalCount then
      self:FinalizeCheckAsset(Context)
    end
  end
  print(bWriteLog and "PlacePrefabFeature:HandleCheckAsset - Processing " .. tostring(Context.TotalCount) .. " items")
  for _, Selection in ipairs(SelectedItems) do
    self:ProcessSingleCheckAssetItemWithTimeout(Context, Selection, OnItemComplete)
  end
end
function PlacePrefabFeature:FinalizeCheckAsset(Context)
  if Context.bFinished then
    return
  end
  Context.bFinished = true
  local SeqID = Context.SeqID
  print(bWriteLog and "PlacePrefabFeature:FinalizeCheckAsset - SeqID: " .. tostring(SeqID))
  self:CleanupTimersForSeqID(SeqID)
  self.PendingCheckRequests[SeqID] = nil
  local Response = Context.Response
  for _, Selection in ipairs(Context.SelectedItems) do
    local Result = Context.ItemResults[Selection.category]
    table.insert(Response.selected, {
      category = Selection.category,
      selected_id = Selection.selected_id,
      success = Result and Result.success or false,
      real_asset_id = Result and Result.real_asset_id or nil
    })
  end
  if Context.Callback then
    Context.Callback(Response)
  end
end
function PlacePrefabFeature:ProcessSingleCheckAssetItemWithTimeout(Context, Selection, OnComplete)
  local Category = Selection.category
  local SeqID = Context.SeqID
  local TimeoutHandle = self:AddManagedTimer(SeqID, PlacePrefabFeature.ITEM_PROCESS_TIMEOUT, false, function()
    print(bWriteLog and "PlacePrefabFeature:ProcessSingleCheckAssetItemWithTimeout - Timeout for category: " .. tostring(Category))
    OnComplete(Category, false, nil, "Item process timeout")
  end)
  local OnCompleteWithTimeoutCancel = function(Cat, Success, RealAssetID, ErrorMsg)
    if TimeoutHandle then
      self:RemoveManagedTimer(TimeoutHandle)
      TimeoutHandle = nil
    end
    OnComplete(Cat, Success, RealAssetID, ErrorMsg)
  end
  self:ProcessSingleCheckAssetItem(Context, Selection, OnCompleteWithTimeoutCancel)
end
function PlacePrefabFeature:ProcessSingleCheckAssetItem(Context, Selection, OnComplete)
  local Category = Selection.category
  local AssetID = Selection.selected_id
  local AssetType = Selection.selected_type
  local SeqID = Context.SeqID
  print(bWriteLog and string.format("PlacePrefabFeature:ProcessSingleCheckAssetItem - category=%s, id=%s, type=%s", tostring(Category), tostring(AssetID), tostring(AssetType)))
  if not self.PendingCheckRequests[SeqID] then
    print(bWriteLog and "PlacePrefabFeature:ProcessSingleCheckAssetItem - Request cancelled")
    OnComplete(Category, false, nil, "Request cancelled")
    return
  end
  if AssetType == PlacePrefabFeature.Enum_SourceType.Backpack then
    print(bWriteLog and "PlacePrefabFeature:ProcessSingleCheckAssetItem - Backpack, directly return success, AssetID: " .. tostring(AssetID))
    OnComplete(Category, true, AssetID, nil)
  elseif AssetType == PlacePrefabFeature.Enum_SourceType.Public then
    local logic_ugc_prefab_mall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
    local MetaInfo = logic_ugc_prefab_mall:GetPrefabMeta(AssetID)
    if MetaInfo then
      local RealAssetID = MetaInfo.Meta.AssetId
      print(bWriteLog and "PlacePrefabFeature:ProcessSingleCheckAssetItem - Public meta cached, RealAssetID: " .. tostring(RealAssetID))
      self:DoPutDownForCheckAsset(SeqID, RealAssetID, AssetType, Category, OnComplete)
    else
      print(bWriteLog and "PlacePrefabFeature:ProcessSingleCheckAssetItem - Fetching public meta for: " .. tostring(AssetID))
      self:FetchPublicPrefabMetaManaged(AssetID, SeqID, function(Success, FetchedMeta)
        if not self.PendingCheckRequests[SeqID] then
          print(bWriteLog and "PlacePrefabFeature:ProcessSingleCheckAssetItem - Request cancelled after meta fetch")
          OnComplete(Category, false, nil, "Request cancelled")
          return
        end
        if Success and FetchedMeta then
          local RealAssetID = FetchedMeta.Meta.AssetId
          print(bWriteLog and "PlacePrefabFeature:ProcessSingleCheckAssetItem - Public meta fetched, RealAssetID: " .. tostring(RealAssetID))
          self:DoPutDownForCheckAsset(SeqID, RealAssetID, AssetType, Category, OnComplete)
        else
          print(bWriteLog and "PlacePrefabFeature:ProcessSingleCheckAssetItem - Public meta fetch failed")
          OnComplete(Category, false, nil, "Meta fetch failed")
        end
      end)
    end
  elseif AssetType == PlacePrefabFeature.Enum_SourceType.Private then
    local logic_ugc_prefab_mall_private = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private")
    if logic_ugc_prefab_mall_private:IsPrivateMetaCompleted() then
      local MetaInfo = logic_ugc_prefab_mall_private:GetPrivateMeta(AssetID)
      if MetaInfo then
        local RealAssetID = MetaInfo.Meta.AssetId
        print(bWriteLog and "PlacePrefabFeature:ProcessSingleCheckAssetItem - Private meta found, RealAssetID: " .. tostring(RealAssetID))
        self:DoPutDownForCheckAsset(SeqID, RealAssetID, AssetType, Category, OnComplete)
      else
        print(bWriteLog and "PlacePrefabFeature:ProcessSingleCheckAssetItem - Private meta not found for slot: " .. tostring(AssetID))
        OnComplete(Category, false, nil, "Private meta not found for slot: " .. tostring(AssetID))
      end
    else
      print(bWriteLog and "PlacePrefabFeature:ProcessSingleCheckAssetItem - Private meta list not loaded, fetching...")
      self:FetchPrivatePrefabMetaManaged(AssetID, SeqID, function(Success, FetchedMeta)
        if not self.PendingCheckRequests[SeqID] then
          print(bWriteLog and "PlacePrefabFeature:ProcessSingleCheckAssetItem - Request cancelled after private meta fetch")
          OnComplete(Category, false, nil, "Request cancelled")
          return
        end
        if Success and FetchedMeta then
          local RealAssetID = FetchedMeta.Meta.AssetId
          print(bWriteLog and "PlacePrefabFeature:ProcessSingleCheckAssetItem - Private meta fetched, RealAssetID: " .. tostring(RealAssetID))
          self:DoPutDownForCheckAsset(SeqID, RealAssetID, AssetType, Category, OnComplete)
        else
          print(bWriteLog and "PlacePrefabFeature:ProcessSingleCheckAssetItem - Private meta fetch failed for slot: " .. tostring(AssetID))
          OnComplete(Category, false, nil, "Private meta fetch failed")
        end
      end)
    end
  else
    print(bWriteLog and "PlacePrefabFeature:ProcessSingleCheckAssetItem - Invalid asset type: " .. tostring(AssetType))
    OnComplete(Category, false, nil, "Invalid asset type")
  end
end
function PlacePrefabFeature:DoPutDownForCheckAsset(SeqID, RealAssetID, AssetType, Category, OnComplete)
  print(bWriteLog and string.format("PlacePrefabFeature:DoPutDownForCheckAsset - RealAssetID=%s, AssetType=%s, Category=%s", tostring(RealAssetID), tostring(AssetType), tostring(Category)))
  if not self.PendingCheckRequests[SeqID] then
    print(bWriteLog and "PlacePrefabFeature:DoPutDownForCheckAsset - Request cancelled")
    OnComplete(Category, false, nil, "Request cancelled")
    return
  end
  local logic_ugc_prefab_mall_asset_mgr = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_asset_mgr")
  logic_ugc_prefab_mall_asset_mgr:PutDown(RealAssetID, function(ReturnedAssetId)
    local bPutDownSuccess = ReturnedAssetId ~= nil
    print(bWriteLog and string.format("PlacePrefabFeature:DoPutDownForCheckAsset - callback, Category=%s, ReturnedAssetId=%s, success=%s", tostring(Category), tostring(ReturnedAssetId), tostring(bPutDownSuccess)))
    local ErrorMsg
    if not bPutDownSuccess then
      ErrorMsg = "PutDown failed"
    end
    local FinalAssetId = ReturnedAssetId or RealAssetID
    OnComplete(Category, bPutDownSuccess, FinalAssetId, ErrorMsg)
  end, {SilentPutDown = true})
end
function PlacePrefabFeature:CancelCheckAsset(SeqID, Callback)
  print(bWriteLog and "PlacePrefabFeature:CancelCheckAsset - SeqID: " .. tostring(SeqID))
  self:CleanupTimersForSeqID(SeqID)
  local Context = self.PendingCheckRequests[SeqID]
  self.PendingCheckRequests[SeqID] = nil
  local Response = {
    seq_id = SeqID,
    type = "check_asset",
    cancelled = true,
    selected = {}
  }
  if Callback then
    Callback(Response)
  end
end
local class = require("class")
local object = require("object")
return class(object, nil, PlacePrefabFeature)