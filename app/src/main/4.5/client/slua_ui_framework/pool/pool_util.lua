local pool_util = {}
local openUIPool = true
function pool_util.SkipUIPool()
  if HDmpveRemote.HDmpveRemoteConfigGetBool("EnableLobbySpinPool", true) then
    return
  end
  log(bWriteLog and "pool_util.SkipUIPool.  ")
  openUIPool = false
end
function pool_util.ReUseUIPool()
  log(bWriteLog and "pool_util.ReUseUIPool.  ")
  openUIPool = true
end
function pool_util.CanUseUIPool()
  log(bWriteLog and "pool_util.CanUseUIPool. openUIPool: " .. tostring(openUIPool))
  return openUIPool
end
return pool_util