local BattleKillBroadcastSubSystem = {}
function BattleKillBroadcastSubSystem:CopyKillOrPutDownMessageDataUserDataToLuaTable(messageData)
  local msgData = BattleKillBroadcastSubSystem.__super.CopyKillOrPutDownMessageDataUserDataToLuaTable(self, messageData)
  if not msgData.bIamVictim then
    msgData.VictimPlayerName = LocUtil.GetLocalizeResStr(48350)
  end
  return msgData
end
local class = require("class")
local SubsystemBase = require("GameLua.Mod.BaseMod.Client.BattleKillBroadcast.BattleKillBroadcastSubSystem")
return class(SubsystemBase, nil, BattleKillBroadcastSubSystem)