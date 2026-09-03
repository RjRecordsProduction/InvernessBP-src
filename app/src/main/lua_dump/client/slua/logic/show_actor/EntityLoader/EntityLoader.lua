local EntityLoader = {}
EntityLoader.Type = {
  Sync = 0,
  Async = 1,
  AsyncCallback = 2
}
function EntityLoader.Create(Entity, LoaderType)
  if not Entity then
    log_error("EntityLoader.Create Entity is nil")
    return
  end
  if LoaderType == EntityLoader.Type.Sync then
    local SyncEntityLoader = require("client.slua.logic.show_actor.EntityLoader.SyncEntityLoader")
    return SyncEntityLoader(Entity)
  elseif LoaderType == EntityLoader.Type.AsyncCallback then
    local AsyncCallbackEntityLoader = require("client.slua.logic.show_actor.EntityLoader.AsyncCallbackEntityLoader")
    return AsyncCallbackEntityLoader(Entity)
  else
    local AsyncEntityLoader = require("client.slua.logic.show_actor.EntityLoader.AsyncEntityLoader")
    return AsyncEntityLoader(Entity)
  end
end
return EntityLoader