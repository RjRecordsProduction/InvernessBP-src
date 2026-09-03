local NetManager = require("client.network.comm.NetManager")
local DoubleCardHandler = {}
function DoubleCardHandler.on_sync_double_card_info(cardInfo)
  local DoubleCardSystem = require("client.logic.double_card.logic_double_card")
  DoubleCardSystem.OnSyncDoubleCardInfo(cardInfo)
end
function DoubleCardHandler.on_rating_card_change_notify(ratingShieldData)
  log(bWriteLog and "DoubleCardHandler.on_rating_card_change_notify")
  local DoubleCardSystem = require("client.logic.double_card.logic_double_card")
  DoubleCardSystem.OnSyncRatingCardInfo(ratingShieldData)
end
function DoubleCardHandler.send_get_rating_protect_list_req()
  log(bWriteLog and "DoubleCardHandler.send_get_rating_protect_list_req")
  NetManager.SendPkg(223901519)
end
function DoubleCardHandler.on_get_rating_protect_list_rsp(protect_info)
  log(bWriteLog and "DoubleCardHandler.on_get_rating_protect_list_rsp")
  log_tree("protect_info = ", protect_info)
  local logic_rating_card_buff_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_rating_card_buff_mgr)
  logic_rating_card_buff_mgr:OnGetRatingtProtectData(protect_info)
end
function DoubleCardHandler.on_notify_rating_protect_list(protect_info)
  log_tree("on_notify_rating_protect_list protect_info", protect_info)
  local logic_rating_card_buff_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_rating_card_buff_mgr)
  logic_rating_card_buff_mgr:OnGetRatingtProtectData(protect_info)
end
function DoubleCardHandler.send_get_add_rating_list_req()
  log(bWriteLog and "DoubleCardHandler.send_get_add_rating_list_req")
  NetManager.SendPkg(772431735)
end
function DoubleCardHandler.on_get_add_rating_list_rsp(add_rating_info)
  log(bWriteLog and "DoubleCardHandler.on_get_add_rating_list_rsp")
  log_tree("add_rating_info = ", add_rating_info)
  local logic_rating_card_buff_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_rating_card_buff_mgr)
  logic_rating_card_buff_mgr:OnGetAddScoreData(add_rating_info)
end
function DoubleCardHandler.on_notify_add_rating_list(add_rating_info)
  log_tree("on_notify_add_rating_list add_rating_info", add_rating_info)
  local logic_rating_card_buff_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_rating_card_buff_mgr)
  logic_rating_card_buff_mgr:OnGetAddScoreData(add_rating_info)
end
function DoubleCardHandler.send_get_tdm_rank_protect_info_req(uid)
  NetManager.SendPkg(1357369099, uid)
end
function DoubleCardHandler.on_get_tdm_rank_protect_info_rsp(err_code, protect_info)
  local logic_tdm_rating_protect = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_tdm_rating_protect)
  logic_tdm_rating_protect:proc_get_tdm_rank_protect_info_rsp(err_code, protect_info)
end
return DoubleCardHandler