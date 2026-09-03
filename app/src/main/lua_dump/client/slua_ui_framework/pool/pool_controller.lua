local pool_controller = {}
local LuaAsyncTaskSubsystem
local utility = require("common.utility")
if GbUIClearAlgorithm then
  LuaAsyncTaskSubsystem = utility.GetGameInstanceSubsystemByName("LuaAsyncTasksSubsystem")
else
  LuaAsyncTaskSubsystem = utility.GetGameInstanceSubsystemByName("LuaAsyncTaskSubsystem")
end
function pool_controller:OnInitialize()
  self:AddTimerLoop(5, function()
    self:ClearPoolIfNeed()
  end, TIMER_INFINITE, 2)
end
function pool_controller:ClearPoolIfNeed()
  local ClearHandle = function(bNeedClear)
    self:ClearPool(bNeedClear)
  end
  if GbUIClearAlgorithm then
    LuaAsyncTaskSubsystem:IsNeedClear(GnMaxClearMemory, GnMaxClearObjectNum, ClearHandle)
  else
    LuaAsyncTaskSubsystem:IsNeedClear(slua_GameFrontendHUD, ClearHandle)
  end
end
function pool_controller:ClearPool(bMinPoolObjectNum)
  if not IsEditor and bMinPoolObjectNum then
    local UScriptHelperClient = import("ScriptHelperClient")
    local ObjectNum = UScriptHelperClient.GetObjectArrayNum()
    log_shipping_client("pool_controller:ClearPool. ObjectNum: " .. tostring(ObjectNum))
    local memoryStatus = Client.GetMemoryStats()
    log_shipping_client("pool_controller:ClearPool. UsedPhysical: " .. tostring(memoryStatus.UsedPhysical / 1024 / 1024))
    log_shipping_client("pool_controller:ClearPool. AvailablePhysical: " .. tostring(memoryStatus.AvailablePhysical / 1024 / 1024))
    log_shipping_client("pool_controller:ClearPool. TotalPhysical: " .. tostring(memoryStatus.TotalPhysical / 1024 / 1024))
  end
  local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
  local pools = EUIConfigPoolType.GetModuleList()
  for _, onePool in pairs(pools) do
    local pool = onePool.pool
    if pool.totalPoolObjectNum > pool.minPoolObjectNum and bMinPoolObjectNum then
      pool:_ReleasePoolToNum(pool.minPoolObjectNum)
    elseif pool.totalPoolObjectNum > pool.maxPoolObjectNum then
      pool:_ReleasePoolToNum(pool.maxPoolObjectNum)
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Cpool_controller = class(CModuleBase, nil, pool_controller)
return Cpool_controller