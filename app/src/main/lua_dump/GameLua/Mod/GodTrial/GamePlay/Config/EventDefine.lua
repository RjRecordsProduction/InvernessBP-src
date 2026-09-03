local EventConfig = {}
function EventConfig.Init(InitFunction)
  local bShipping = Client and Client.IsShipping()
  local _ENV = {}
  InitFunction(bShipping, _ENV)
  _ENV.EVENTTYPE_GODTRIAL_NORMAL = nil
  _ENV.EVENTID_ARENA_GROOM_STATE_CHANGE = nil
  _ENV.EVENTID_CLIENT_ARENA_GOLDEN_COIN_CHANGE = nil
  _ENV.EVENTIT_SERVER_THE_DESCENDED_SKY = nil
  _ENV.EVENTIT_SERVER_THE_DESCENDED_SKY_END = nil
  _ENV.EVENTIT_SERVER_SPAWN_CENTAUR = nil
  _ENV.EVENTIT_SERVER_CENTAUR_BOSS_DIE = nil
  _ENV.EVENTIT_TRIAL_STATE_CHANGE = nil
  _ENV.EVENTID_CLIENT_ARENA_DUNGEON_HUMAN_FLOAT = nil
end
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
EventConfig.Init(GamePlayTools.InitEvent)
local ClientToDSRoute = {}
local DSToClient = {}
if Client then
  return ClientToDSRoute
else
  return DSToClient
end