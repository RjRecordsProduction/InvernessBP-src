local RedDotSystem = {
  dataList = {}
}
function RedDotSystem.OnLogin()
  RedDotSystem.RedDotListReq()
end
function RedDotSystem.HasRedDot(id)
  return RedDotSystem.dataList[id] and true or false
end
function RedDotSystem.UpdateRedDot(id)
end
function RedDotSystem.RedDotListReq()
  local RedDotHandler = require("client.network.Protocol.RedDotHandler")
  RedDotHandler.send_reddot_list_req()
end
function RedDotSystem.OnRedDotListRsp(list)
  RedDotSystem.dataList = list or {}
  log_tree("[chub]\229\174\137\229\133\168\228\184\173\229\191\131\231\186\162\231\130\185OnRedDotListRsp:list", list)
  local ban_reddot_data = require("client.slua.logic.ban_reddot.ban_reddot_data")
  ban_reddot_data.InitData()
  local ban_reddot_system = require("client.slua.logic.ban_reddot.ban_reddot_system")
  for id, _ in pairs(list) do
    ban_reddot_system.AddBanSystemReddot(id)
  end
end
function RedDotSystem.DismissRedDotNtf(id)
  if not RedDotSystem.dataList[id] then
    return
  end
  RedDotSystem.dataList[id] = nil
  local RedDotHandler = require("client.network.Protocol.RedDotHandler")
  RedDotHandler.send_dismiss_reddot_ntf(id)
end
function RedDotSystem.OnDisplayRedDotNtf(id, notify_time)
  log(bWriteLog and "[chub]\229\174\137\229\133\168\228\184\173\229\191\131\231\186\162\231\130\185RedDotSystem.OnDisplayRedDotNtf id = " .. id)
  log(bWriteLog and "[chub]\229\174\137\229\133\168\228\184\173\229\191\131\231\186\162\231\130\185RedDotSystem.OnDisplayRedDotNtf notify_time = " .. tostring(notify_time))
  RedDotSystem.dataList[id] = {}
  local ban_reddot_system = require("client.slua.logic.ban_reddot.ban_reddot_system")
  ban_reddot_system.AddBanSystemReddot(id)
  local BanReddotSystem = require("client.slua.logic.ban_reddot.ban_reddot_system")
  if id == BanReddotSystem.ReddotId.article then
    RedDotSystem.dataList[id].    if GameStatus.IsInLobbyOrMainCity() then
      BanReddotSystem.OpenSafeStationTips()
    end
  end
end
return RedDotSystem