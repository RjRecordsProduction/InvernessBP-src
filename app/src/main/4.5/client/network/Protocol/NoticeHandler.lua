local NetManager = require("client.network.comm.NetManager")
local NoticeHandler = {}
function NoticeHandler.send_get_bulletin_list_req()
  NetManager.SendPkg(66711623)
end
function NoticeHandler.on_get_bulletin_list_rsp(bulletin_list)
  local NoticeSystem = require("client.slua.logic.activity.logic_activitycenter_notice")
  NoticeSystem.OnGetNoticeData(bulletin_list)
end
function NoticeHandler.send_take_bulletin_award_req(id)
  NetManager.SendPkg(1713852655, id)
end
function NoticeHandler.on_take_bulletin_award_rsp(err_code, id)
  local NoticeSystem = require("client.slua.logic.activity.logic_activitycenter_notice")
  NoticeSystem.OnGetReward(err_code, id)
end
return NoticeHandler