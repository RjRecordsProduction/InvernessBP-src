BattleCallbacks = {}
local bTest = false
function BattleCallbacks:OnGameModeCreate()
  print(bWriteLog and "BattleCallbacks:OnGameModeCreate()")
  if bTest and Client.IsEditor() then
    require("GameLua.Mod.BaseMod.Client.BattleHandler")
    local params = {}
    params.bTest = true
    params.PlayerUID = 10000
    BattleHandler.SyncNewBattlePlayer(params)
    return false
  end
  return true
end
function BattleCallbacks:OnPostLoadMap()
  print(bWriteLog and "BattleCallbacks:OnPostLoadMap()")
end
function BattleCallbacks:OnGameEnd()
  print(bWriteLog and "BattleCallbacks:OnGameEnd()")
  local params = {}
  params.PlayerUID = DataMgr.roleData.uid
  params.PlayerType = "Normal"
  params.Reason = 0
  require("GameLua.Mod.BaseMod.Client.BattleHandler")
  BattleHandler.SyncBattlePlayerExit(params)
  BattleHandler.SyncGameExit()
end
function BattleCallbacks:OnGenerateAIPlayerParam(playerKey, playerType)
  print(bWriteLog and "BattleCallbacks:OnGenerateAIPlayerParam()", playerKey, playerType)
  require("GameLua.Mod.BaseMod.Client.BattleHandler")
  BattleHandler.RandomGenerateAIPlayerParams(playerKey, playerType)
end
function BattleCallbacks:OnPlayerDestroyed(uid)
  print(bWriteLog and "BattleCallbacks:OnPlayerDestroyed()" .. uid)
end
function BattleCallbacks:OnGameModeStateChanged(sGameModeState)
  print(bWriteLog and "BattleCallbacks:OnGameModeStateChanged(): " .. sGameModeState)
end
local class = require("class")
local object = require("object")
local CBattleCallbacks = class(object, nil, BattleCallbacks)
return CBattleCallbacks