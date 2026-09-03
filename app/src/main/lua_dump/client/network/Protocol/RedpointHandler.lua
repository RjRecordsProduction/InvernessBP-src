local NetManager = require("client.network.comm.NetManager")
local RedpointHandler = {}
function RedpointHandler.send_select_avatar(avatarId)
  NetManager.SendPkg(1707998310, avatarId)
end
function RedpointHandler.send_select_item_list(instIds)
  NetManager.SendPkg(2140608219, instIds)
end
return RedpointHandler