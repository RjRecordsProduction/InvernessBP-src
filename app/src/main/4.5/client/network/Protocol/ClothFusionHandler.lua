local NetManager = require("client.network.comm.NetManager")
local ClothFusionHandler = {}
function ClothFusionHandler.send_get_taluo_change_wear_info_req()
  NetManager.SendPkg(1539441159)
end
function ClothFusionHandler.on_get_taluo_change_wear_info_rsp(err_code, info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  LogicFusionModule:SetFusionRecord(info)
end
function ClothFusionHandler.on_taluo_change_wear_info_ntf(info)
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  LogicFusionModule:SetFusionRecord(info)
end
function ClothFusionHandler.send_set_taluo_change_wear_info_req(period_id, pre_item_id, current_item_id)
  NetManager.SendPkg(794770567, period_id, pre_item_id, current_item_id)
end
function ClothFusionHandler.on_set_taluo_change_wear_info_rsp(err_code, info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  LogicFusionModule:SetFusionRecord(info)
end
return ClothFusionHandler