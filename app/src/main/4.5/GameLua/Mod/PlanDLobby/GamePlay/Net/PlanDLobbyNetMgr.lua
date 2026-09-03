local PlanDLobbyNetMgr = {}
function PlanDLobbyNetMgr.OnEnterMod()
  local NetManager = require("client.network.comm.NetManager")
  local ModNetConfig = require("GameLua.Mod.PlanDLobby.GamePlay.Net.NetConfig")
  ModNetConfig.Init()
  local ModRsp2IDConfig = require("GameLua.Mod.PlanDLobby.GamePlay.Net.NetRsp2IndexConfig")
  NetManager.AppendModConfig(ModNetConfig.msgMap, ModRsp2IDConfig, ModNetConfig.reconnectMsgMap, "GameLua.Mod.PlanDLobby.GamePlay.Net.Protocol")
  log(bWriteLog and "PlanDLobbyNetMgr:OnEnterMod - net config appended")
end
function PlanDLobbyNetMgr.OnLeaveMod()
  local NetManager = require("client.network.comm.NetManager")
  NetManager.RemoveModConfig()
  log(bWriteLog and "PlanDLobbyNetMgr:OnLeaveMod - net config removed")
end
return PlanDLobbyNetMgr