local SkelMeshLODManager = {}
local ELODDropResult_Success = 0
local ELODDropResult_AlreadyInRequestedState = 3
local ELODDropResult_CPUDataUnavailable = 6
local MAX_COMMIT_RETRIES = 5
local _UKismetSystemLibrary
local _GetAssetName = function(asset)
  if not asset then
    return "nil"
  end
  if not _UKismetSystemLibrary then
    _UKismetSystemLibrary = import("KismetSystemLibrary")
  end
  if _UKismetSystemLibrary and _UKismetSystemLibrary.GetObjectName then
    local ok, name = pcall(_UKismetSystemLibrary.GetObjectName, asset)
    if ok and name then
      return name
    end
  end
  return tostring(asset)
end
local _bEnabled = true
local _bSkipInEditor = true
local _IsActive = function()
  if _bSkipInEditor and IsEditor then
    return false
  end
  return _bEnabled
end
function SkelMeshLODManager:DefineAndResetData()
  log(bWriteLog and "SkelMeshLODManager:DefineAndResetData")
  self._TrackedMeshes = {}
  self._PendingCommitAssets = {}
  self._commitTimerScheduled = false
end
function SkelMeshLODManager:OnInitialize()
  log(bWriteLog and "SkelMeshLODManager:OnInitialize")
end
function SkelMeshLODManager:_FlushPendingCommit()
  self._commitTimerScheduled = false
  local pending = self._PendingCommitAssets
  if not pending then
    return
  end
  local hasRemaining = false
  for asset, retriesLeft in pairs(pending) do
    if not (asset and slua.isValid(asset)) or type(asset.CommitPendingDropReleases) ~= "function" then
      if asset ~= nil then
        pending[asset] = nil
      end
    else
      asset:CommitPendingDropReleases()
      local stillPending = type(asset.HasPendingDropRelease) == "function" and asset:HasPendingDropRelease()
      if stillPending and 1 < retriesLeft then
        pending[asset] = retriesLeft - 1
        hasRemaining = true
      else
        if stillPending then
          log(bWriteLog and string.format("[WARN] SkelMeshLODManager:_FlushPendingCommit gave up on %s after %d retries", _GetAssetName(asset), MAX_COMMIT_RETRIES))
        end
        pending[asset] = nil
      end
    end
  end
  if hasRemaining and not self._commitTimerScheduled then
    self._commitTimerScheduled = true
    self:AddTimerOnce(0, function()
      self:_FlushPendingCommit()
    end)
  end
end
function SkelMeshLODManager:OnDestroy()
  log(bWriteLog and "SkelMeshLODManager:OnDestroy")
  self._TrackedMeshes = nil
  self._PendingCommitAssets = nil
  self._commitTimerScheduled = false
end
function SkelMeshLODManager:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and string.format("SkelMeshLODManager:OnPreSwitchGameStatus pre=%s next=%s tracked=%d", tostring(preState), tostring(nextState), self:_GetTrackedCount()))
  self:_ReleaseAll()
end
function SkelMeshLODManager:SetEnabled(bEnable)
  local newVal = bEnable ~= false
  if newVal == _bEnabled then
    return
  end
  _bEnabled = newVal
  log(bWriteLog and string.format("SkelMeshLODManager:SetEnabled %s tracked=%d (note: existing drops are NOT auto-restored)", tostring(_bEnabled), self:_GetTrackedCount()))
end
function SkelMeshLODManager:IsEnabled()
  return _bEnabled
end
function SkelMeshLODManager:DropAndTrack(SkMeshAsset, lodIndices)
  if not _IsActive() then
    return {}
  end
  if not slua.isValid(SkMeshAsset) or not SkMeshAsset.DropSpecificLOD then
    return {}
  end
  if type(lodIndices) ~= "table" or #lodIndices == 0 then
    return {}
  end
  local droppedList = {}
  local savedBytes = 0
  local hasFootprint = type(SkMeshAsset.GetLODVRAMFootprint) == "function"
  local hasIsDropped = type(SkMeshAsset.IsLODDropped) == "function"
  local totalBefore = 0
  local lodInfo = SkMeshAsset.LODInfo
  local numLODs = lodInfo and lodInfo:Num() or 0
  if hasFootprint and 0 < numLODs then
    for i = 0, numLODs - 1 do
      totalBefore = totalBefore + (SkMeshAsset:GetLODVRAMFootprint(i) or 0)
    end
  end
  for _, idx in ipairs(lodIndices) do
    local before = hasFootprint and SkMeshAsset:GetLODVRAMFootprint(idx) or 0
    local wasDropped = hasIsDropped and SkMeshAsset:IsLODDropped(idx) or false
    local rc = SkMeshAsset:DropSpecificLOD(idx)
    if rc == ELODDropResult_Success or rc == ELODDropResult_AlreadyInRequestedState then
      table.insert(droppedList, idx)
      if rc == ELODDropResult_Success then
        savedBytes = savedBytes + (before or 0)
      end
      log(bWriteLog and string.format("SkelMeshLODManager:DropAndTrack lod=%d on %s before=%.2f KiB wasAlreadyDropped=%s rc=%d", idx, _GetAssetName(SkMeshAsset), (before or 0) / 1024.0, tostring(wasDropped), rc))
    else
      log(bWriteLog and string.format("SkelMeshLODManager:DropAndTrack DropSpecificLOD(%d) on %s returned %d (wasAlreadyDropped=%s)", idx, _GetAssetName(SkMeshAsset), rc, tostring(wasDropped)))
    end
  end
  if 0 < #droppedList then
    self._TrackedMeshes = self._TrackedMeshes or {}
    local existing = self._TrackedMeshes[SkMeshAsset]
    if existing then
      local seen = {}
      for _, v in ipairs(existing) do
        seen[v] = true
      end
      for _, v in ipairs(droppedList) do
        if not seen[v] then
          table.insert(existing, v)
          seen[v] = true
        end
      end
    else
      self._TrackedMeshes[SkMeshAsset] = droppedList
    end
    local pct = 0 < totalBefore and savedBytes / totalBefore * 100.0 or 0.0
    log(bWriteLog and string.format("SkelMeshLODManager:DropAndTrack %s lods=%d tracked=%d saved=%.2f KiB / total=%.2f KiB (%.1f%%)", _GetAssetName(SkMeshAsset), #droppedList, #(self._TrackedMeshes[SkMeshAsset] or {}), savedBytes / 1024.0, totalBefore / 1024.0, pct))
    if type(SkMeshAsset.CommitPendingDropReleases) == "function" then
      self._PendingCommitAssets = self._PendingCommitAssets or {}
      self._PendingCommitAssets[SkMeshAsset] = MAX_COMMIT_RETRIES
      if not self._commitTimerScheduled then
        self._commitTimerScheduled = true
        self:AddTimerOnce(0, function()
          self:_FlushPendingCommit()
        end)
      end
    end
  end
  return droppedList
end
function SkelMeshLODManager:RestoreAndUntrack(SkMeshAsset)
  if not _IsActive() then
    return false
  end
  if not self._TrackedMeshes then
    return false
  end
  if not slua.isValid(SkMeshAsset) or not SkMeshAsset.RestoreSpecificLOD then
    return false
  end
  local droppedList = self._TrackedMeshes[SkMeshAsset]
  if not droppedList then
    return false
  end
  for _, lodIdx in ipairs(droppedList) do
    local rc = SkMeshAsset:RestoreSpecificLOD(lodIdx)
    if rc == ELODDropResult_Success or rc == ELODDropResult_AlreadyInRequestedState then
    elseif rc == ELODDropResult_CPUDataUnavailable then
      log(bWriteLog and string.format("SkelMeshLODManager:RestoreAndUntrack RestoreSpecificLOD(%d) on %s: CPUDataUnavailable (one-way Drop, expected in cooked)", lodIdx, _GetAssetName(SkMeshAsset)))
    else
      log(bWriteLog and string.format("SkelMeshLODManager:RestoreAndUntrack RestoreSpecificLOD(%d) on %s returned %d", lodIdx, _GetAssetName(SkMeshAsset), rc))
    end
  end
  self._TrackedMeshes[SkMeshAsset] = nil
  log(bWriteLog and string.format("SkelMeshLODManager:RestoreAndUntrack %s", _GetAssetName(SkMeshAsset)))
  return true
end
function SkelMeshLODManager:PunchLODHoles(SkMeshAsset, holeIndices, residentLODIndex, numLODs)
  if not _IsActive() then
    return {}
  end
  if not slua.isValid(SkMeshAsset) then
    return {}
  end
  if type(holeIndices) ~= "table" or #holeIndices == 0 then
    return {}
  end
  local filtered = {}
  for _, idx in ipairs(holeIndices) do
    local ok = type(idx) == "number" and 0 <= idx
    if ok and residentLODIndex ~= nil and idx == residentLODIndex then
      ok = false
    end
    if ok and numLODs ~= nil and numLODs <= idx then
      ok = false
    end
    if ok then
      table.insert(filtered, idx)
    end
  end
  if #filtered == 0 then
    return {}
  end
  return self:DropAndTrack(SkMeshAsset, filtered)
end
function SkelMeshLODManager:KeepOnlyLODs(SkMeshAsset, keepIndices)
  if not _IsActive() then
    return {}
  end
  if not slua.isValid(SkMeshAsset) then
    return {}
  end
  if type(keepIndices) ~= "table" then
    return {}
  end
  local lodInfo = SkMeshAsset.LODInfo
  if not lodInfo then
    return {}
  end
  local numLODs = lodInfo:Num()
  if numLODs <= 1 then
    return {}
  end
  local keepSet = {}
  local validKeepCount = 0
  for _, k in ipairs(keepIndices) do
    if type(k) == "number" and 0 <= k and k < numLODs and not keepSet[k] then
      keepSet[k] = true
      validKeepCount = validKeepCount + 1
    end
  end
  if validKeepCount == 0 then
    log(bWriteLog and string.format("SkelMeshLODManager:KeepOnlyLODs skipped: empty keep set on %s (numLODs=%d)", _GetAssetName(SkMeshAsset), numLODs))
    return {}
  end
  local toDrop = {}
  for i = 0, numLODs - 1 do
    if not keepSet[i] then
      table.insert(toDrop, i)
    end
  end
  if #toDrop == 0 then
    return {}
  end
  return self:DropAndTrack(SkMeshAsset, toDrop)
end
function SkelMeshLODManager:KeepCurrentLODOfComponent(MeshComponent)
  if not _IsActive() then
    return {}
  end
  if not slua.isValid(MeshComponent) then
    return {}
  end
  local SkMeshAsset = MeshComponent.SkeletalMesh
  if not slua.isValid(SkMeshAsset) then
    return {}
  end
  local residentLOD
  local forced = MeshComponent.ForcedLodModel
  if type(forced) == "number" and 0 < forced then
    residentLOD = forced - 1
  elseif type(MeshComponent.PredictedLODLevel) == "number" then
    residentLOD = MeshComponent.PredictedLODLevel
  elseif MeshComponent.GetPredictedLODLevel then
    local ok, v = pcall(function()
      return MeshComponent:GetPredictedLODLevel()
    end)
    if ok and type(v) == "number" then
      residentLOD = v
    end
  end
  if type(residentLOD) ~= "number" or residentLOD < 0 then
    residentLOD = 0
  end
  return self:KeepOnlyLODs(SkMeshAsset, {residentLOD})
end
function SkelMeshLODManager:DumpTracked()
  if not self._TrackedMeshes then
    log("SkelMeshLODManager:DumpTracked (no tracked meshes)")
    return
  end
  local meshCount = 0
  local totalSaved = 0
  log("==== SkelMeshLODManager:DumpTracked ====")
  for asset, dropped in pairs(self._TrackedMeshes) do
    if slua.isValid(asset) then
      meshCount = meshCount + 1
      local meshSaved = 0
      local meshTotal = 0
      local lods = {}
      local hasFootprint = type(asset.GetLODVRAMFootprint) == "function"
      local hasIsDropped = type(asset.IsLODDropped) == "function"
      local lodInfo = asset.LODInfo
      local numLODs = lodInfo and lodInfo:Num() or 0
      if hasFootprint and 0 < numLODs then
        for i = 0, numLODs - 1 do
          meshTotal = meshTotal + (asset:GetLODVRAMFootprint(i) or 0)
        end
      end
      for _, idx in ipairs(dropped) do
        local mark = hasIsDropped and asset:IsLODDropped(idx) and "*" or ""
        table.insert(lods, tostring(idx) .. mark)
        if hasFootprint then
          meshSaved = meshSaved + (asset:GetLODVRAMFootprint(idx) or 0)
        end
      end
      log(string.format("  [%s] dropped=[%s] residual-tracked=%.2f KiB total-mesh=%.2f KiB", _GetAssetName(asset), table.concat(lods, ","), meshSaved / 1024.0, meshTotal / 1024.0))
      totalSaved = totalSaved + meshSaved
    end
  end
  log(string.format("==== %d mesh(es); residual-footprint total=%.2f MiB (entries with * are still dropped) ====", meshCount, totalSaved / 1048576.0))
end
function SkelMeshLODManager:_GetTrackedCount()
  if not self._TrackedMeshes then
    return 0
  end
  local n = 0
  for _ in pairs(self._TrackedMeshes) do
    n = n + 1
  end
  return n
end
function SkelMeshLODManager:_ReleaseAll()
  if not self._TrackedMeshes then
    return
  end
  for asset, _ in pairs(self._TrackedMeshes) do
    self._TrackedMeshes[asset] = nil
  end
  self._TrackedMeshes = {}
  self._PendingCommitAssets = {}
  self._commitTimerScheduled = false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, SkelMeshLODManager)