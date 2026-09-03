local NetManager = require("client.network.comm.NetManager")
local AceImprintHandler = {}
function AceImprintHandler.send_get_ace_imprint_detail_req(target_uid)
  log_format("AceImprintHandler.send_get_ace_imprint_detail_req. target_uid=%s", target_uid)
  NetManager.SendPkg(536618631, target_uid)
end
function AceImprintHandler.on_get_ace_imprint_detail_rsp(res, target_uid, data_new, progress_info)
  log_tree("on_get_ace_imprint_detail_rsp", {
    res,
    target_uid,
    data_new,
    progress_info
  })
  local AceImprintLogic = require("client.logic.season.AceImprintLogic")
  AceImprintLogic.on_get_ace_imprint_detail_rsp(res, target_uid, data_new, progress_info)
end
function AceImprintHandler.send_set_show_ace_imprint_req(base_id, ace_show_type)
  log(bWriteLog and "AceImprintHandler.send_set_show_ace_imprint_req base_id = " .. tostring(base_id) .. " ace_show_type = " .. tostring(ace_show_type))
  NetManager.SendPkg(1010368423, base_id, ace_show_type)
end
function AceImprintHandler.on_set_show_ace_imprint_rsp(err)
  log(bWriteLog and "AceImprintHandler.on_set_show_ace_imprint_rsp err = " .. tostring(err))
  local AceImprintLogic = require("client.logic.season.AceImprintLogic")
  AceImprintLogic.on_set_show_ace_imprint_rsp(err)
end
function AceImprintHandler.send_ace_imprint_light_up_req()
  NetManager.SendPkg(700464743)
end
function AceImprintHandler.on_ace_imprint_light_up_rsp(err_code, progress_info)
  log(bWriteLog and "AceImprintHandler.on_ace_imprint_light_up_rsp err_code:" .. tostring(err_code))
  local AceImprintLogic = require("client.logic.season.AceImprintLogic")
  AceImprintLogic.on_ace_imprint_light_up_rsp(err_code, progress_info)
end
function AceImprintHandler.send_make_up_ace_imprint_req()
  NetManager.SendPkg(973341139)
end
function AceImprintHandler.on_make_up_ace_imprint_rsp(make_up_tbl, summary)
  log_tree(bWriteLog and "AceImprintHandler.on_make_up_ace_imprint_rsp make_up_tbl:", make_up_tbl)
  log_tree(bWriteLog and "AceImprintHandler.on_make_up_ace_imprint_rsp summary:", summary)
  local AceImprintLogic = require("client.logic.season.AceImprintLogic")
  AceImprintLogic.on_make_up_ace_imprint_rsp(make_up_tbl, summary)
end
return AceImprintHandler