local ModelFactory = {}
local LobbyShowActorConfig = require("client.slua.logic.show_actor.common.LobbyShowActorConfig")
function ModelFactory.GetEntity(ShowType, Owner)
  if not ShowType then
    log_error("ModelFactory ShowType is nill")
    return
  end
  local Config = LobbyShowActorConfig.ModelConfig[ShowType]
  if Config and Config.LuaPath ~= "" then
    local _ActorOperatar = require(Config.LuaPath)
    assert_format(type(_ActorOperatar) == "table", "Module[%s] must be a class type!", Config.Name)
    return _ActorOperatar(Config, Owner)
  end
end
function ModelFactory.CreateShowActor(poolSize)
  local LobbyModelShowActorPool = require("client.slua.logic.show_actor.common.LobbyModelShowActorPool")
  if poolSize and 0 < poolSize then
    LobbyModelShowActorPool.SetMaxNum(poolSize)
  else
    LobbyModelShowActorPool.SetMaxNum(1)
  end
  local Actor = LobbyModelShowActorPool.GetModel()
  return Actor
end
return ModelFactory