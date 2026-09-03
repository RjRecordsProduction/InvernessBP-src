local gc_util = {}
GnMaxClearObjectNum = 400000
local utility = require("common.utility")
function gc_util.IsNeedDropAvatarFeature(DropLevel)
  local iEnableDropAvtarFeature = HDmpveRemote.HDmpveRemoteConfigGetInt("iEnableDropAvtarFeature", 0)
  if iEnableDropAvtarFeature <= 0 then
    log(bWriteLog and string.format("gc_util.IsNeedDropAvatarFeature return false of iEnableDropAvtarFeature is 0"))
    return false
  end
  local totalPhysicalMem = Client.GetMemorySize()
  if 4 < totalPhysicalMem then
    log(bWriteLog and string.format("gc_util.IsNeedDropAvatarFeature return false of totalPhysicalMem is %s", tostring(totalPhysicalMem)))
    return false
  end
  if not gc_util.IsNeedClearUIPool() then
    log(bWriteLog and string.format("gc_util.IsNeedDropAvatarFeature return false of IsNeedClearUIPool is false"))
    return false
  end
  if DropLevel > iEnableDropAvtarFeature then
    return false
  end
  return true
end
function gc_util.IsNeedClearUIPool()
  local bDisableClearUIPool = HDmpveRemote.HDmpveRemoteConfigGetBool("DisableClearUIPool", false)
  if bDisableClearUIPool then
    log_shipping_client(string.format("gc_util.IsNeedClearUIPool return false of bDisableClearUIPool:%s", tostring(bDisableClearUIPool)))
    return false
  end
  local UScriptHelperClient = import("ScriptHelperClient")
  local ObjectNum = UScriptHelperClient.GetObjectArrayNum()
  if GnMaxClearObjectNum <= 0 or ObjectNum > GnMaxClearObjectNum then
    log_shipping_client(string.format("gc_util.IsNeedClearUIPool return true of ObjectNum:%s\239\188\140GnMaxClearObjectNum:%s", tostring(ObjectNum), tostring(GnMaxClearObjectNum)))
    return true
  end
  local memoryStatus = Client.GetMemoryStats()
  local totalPhysicalMem = Client.GetMemorySize()
  local usedPhysical = memoryStatus.UsedPhysical / 1024.0 / 1024.0
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    local threshold = totalPhysicalMem * 150 + HDmpveRemote.HDmpveRemoteConfigGetInt("IOSGCThreshold", 700)
    if usedPhysical > threshold then
      log_shipping_client(string.format("gc_util.IsNeedClearUIPool IOS return true of totalPhysicalMem:%s\239\188\140usedPhysical:%s", tostring(totalPhysicalMem), tostring(usedPhysical)))
      return true
    end
  elseif totalPhysicalMem <= 4 then
    local threshold = 500 + 200 * totalPhysicalMem
    if Client.GetAndroidSOVersion() == 32 and totalPhysicalMem < 4 then
      threshold = threshold - 100
    end
    if usedPhysical > threshold then
      log_shipping_client(string.format("gc_util.IsNeedClearUIPool android <=4G return true of totalPhysicalMem:%s\239\188\140usedPhysical:%s", tostring(totalPhysicalMem), tostring(usedPhysical)))
      return true
    end
  elseif usedPhysical > 900 + 100 * totalPhysicalMem then
    log_shipping_client(string.format("gc_util.IsNeedClearUIPool android >4G return true of totalPhysicalMem:%s\239\188\140usedPhysical:%s", tostring(totalPhysicalMem), tostring(usedPhysical)))
    return true
  end
  return false
end
function gc_util.GCByMaxObjectOrMemory()
  if IsEditor then
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local UIUtil = require("client.common.ui_util")
  if Client.GetMemorySize() <= Client.LowMemoryInGB() then
    if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.LowGCByObjectOrMemory, false) then
      return
    end
  elseif not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.GCByObjectOrMemory, false) then
    return
  end
  local ClearHandle = function(bNeedClear)
    if bNeedClear then
      log_shipping_client(string.format("gc_util.GCByMaxObjectOrMemory GC bNeedClear = true"))
      local pool_controller = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.pool_controller)
      xpcall(pool_controller.ClearPool, utility.ErrorMessageHandler, pool_controller, true)
      EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_AVATAR, EVENTID_PLAYEREVENT_AVATAR_CLEAR_HANDLER_POOL)
      if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseBodySetupInSprite") then
        Client.MemOption(27)
      end
      if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseBodySetupInPaperTileMap", false) then
        Client.MemOption(28)
      end
      gc_util.FullGC()
    end
  end
  if gc_util.IsNeedClearUIPool() then
    ClearHandle(true)
  end
end
function gc_util.FullGC()
  log_shipping_client("gc_util.FullGC")
  if Client then
    local BusinessHelper = import("BusinessHelper")
    BusinessHelper.FullGC()
  else
    collectgarbage("collect")
    local KismetSystemLibrary = import("KismetSystemLibrary")
    KismetSystemLibrary.CollectGarbage()
  end
end
function gc_util.init()
  if Client and Client.IsDevelopment() then
    local __    
    function collectgarbage(what)
      if what == "collect" then
        log(bWriteLog and string.format("collectgarbage. what=collect"))
      end
      local result = __collectgarbage(what)
      if what == "collect" then
        log(bWriteLog and string.format("collectgarbage end. what=collect"))
      end
      return result
    end
  end
end
gc_util.init()
return gc_util