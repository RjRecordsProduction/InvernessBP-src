local NetManager = require("client.network.comm.NetManager")
local SpecialOfferHandler = {}
function SpecialOfferHandler.send_get_commercial_showpage_req()
  NetManager.SendPkg(734050522)
end
function SpecialOfferHandler.on_notify_commercial_showpage_rsp(ret_tb)
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  special_offer_module:OnGetAllData(ret_tb)
end
function SpecialOfferHandler.on_notify_commercial_showpage_info_one(activity_id, value)
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  special_offer_module:OnGetOneData(activity_id, value)
end
return SpecialOfferHandler