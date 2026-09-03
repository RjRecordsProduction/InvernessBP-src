local pool_controller = {}
function pool_controller:OnInitialize()
  self:AddTimerLoop(5, function()
    self:ClearPoolIfNeed()
  end, TIMER_INFINITE, 2)
end
function pool_controller:ClearPoolIfNeed()
  local ClearHandle = function(bNeedClear)
    self:ClearPool(bNeedClear)
  end
  local gc_util = require("common.gc_util")
  if gc_util.IsNeedClearUIPool() then
    ClearHandle(true)
  end
end
function pool_controller:ClearPool(bMinPoolObjectNum)
  if not IsEditor and bMinPoolObjectNum then
    local UScriptHelperClient = import("ScriptHelperClient")
    local ObjectNum = UScriptHelperClient.GetObjectArrayNum()
    log_shipping_client("pool_controller:ClearPool. ObjectNum: " .. tostring(ObjectNum))
    local memoryStatus = Client.GetMemoryStats()
    log_shipping_client("pool_controller:ClearPool. UsedPhysical: " .. tostring(memoryStatus.UsedPhysical / 1024 / 1024))
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