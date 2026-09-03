local NetManager = require("client.network.comm.NetManager")
local ArmoryHandler = {}
function ArmoryHandler.on_get_all_skin_list_rsp(client_data, errorCode, rsp_list, if_skin_list_saved)
  local ArmorySystem = require("client.logic.armory.logic_armory")
  ArmorySystem.get_weapon_skin_list_rsp(client_data, errorCode, rsp_list, if_skin_list_saved)
end
function ArmoryHandler.send_install_weapon_skin(client_data, weapon_id, instanceID)
  NetManager.SendPkg(1548448124, client_data, weapon_id, instanceID)
end
function ArmoryHandler.on_install_weapon_skin_rsp(client_data, errorCode, weapon_id, instanceID)
  local ArmorySystem = require("client.logic.armory.logic_armory")
  ArmorySystem.install_weapon_skin_rsp(client_data, errorCode, weapon_id, instanceID)
end
function ArmoryHandler.send_uninstall_weapon_skin(client_data, weapon_id)
  NetManager.SendPkg(1204190222, client_data, weapon_id)
end
function ArmoryHandler.on_uninstall_weapon_skin_rsp(client_data, errorCode, weapon_id)
  local ArmorySystem = require("client.logic.armory.logic_armory")
  ArmorySystem.uninstall_weapon_skin_rsp(client_data, errorCode, weapon_id)
end
function ArmoryHandler.send_get_one_weapon_skin_shop_info(skin_res_id)
  NetManager.SendPkg(118304772, skin_res_id)
end
function ArmoryHandler.on_get_one_weapon_skin_shop_info_rsp(errorCode, shop_info, market_buy_info, market_detail, version)
end
return ArmoryHandler