local NetManager = require("client.network.comm.NetManager")
local FacebookHandler = {}
function FacebookHandler.send_batch_get_uid_from_openid_for_frd_req(list)
  NetManager.SendPkg(17664051, list)
end
function FacebookHandler.on_batch_get_uid_from_openid_for_frd_rsp(res, list)
  local FaceBookFriendMgr = require("client.slua.logic.come_back.logic_facebook_friend")
  FaceBookFriendMgr.batch_get_uid_from_openid_for_frd_rsp(res, list)
end
return FacebookHandler