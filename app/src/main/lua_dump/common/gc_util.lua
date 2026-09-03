local gc_util = {}
local MaxGCObjectNum = 400000
local MaxGCMemory = 300
GnMaxClearObjectNum = 300000
GnMaxClearMemory = 450
GbUIClearAlgorithm = false
local utility = require("common.utility")
local LuaAsyncTasksSubsystem
if GbUIClearAlgorithm then
  LuaAsyncTasksSubsystem = utility.GetGameInstanceSubsystemByName("LuaAsyncTasksSubsystem")
else
  LuaAsyncTasksSubsystem = utility.GetGameInstanceSubsystemByName("LuaAsyncTaskSubsystem")
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
  local iMaxGCObjectNum = HDmpveRemote.HDmpveRemoteConfigGetInt("iMaxGCObjectNum", MaxGCObjectNum)
  local iMaxGCMemory = HDmpveRemote.HDmpveRemoteConfigGetInt("iMaxGCMemory", MaxGCMemory)
  local ClearHandle = function(bNeedClear)
    if bNeedClear then
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
      log(bWriteLog and string.format("gc_util.GCByMaxObjectOrMemory GC"))
    end
  end
  if not GbUIClearAlgorithm then
    LuaAsyncTasksSubsystem:IsNeedClear(slua_GameFrontendHUD, ClearHandle)
  else
    LuaAsyncTasksSubsystem:IsNeedClear(iMaxGCMemory, iMaxGCObjectNum, ClearHandle)
  end
end
function gc_util.FullGC()
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