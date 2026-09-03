local NetManager = require("client.network.comm.NetManager")
local RoleInfoBGHandler = {}
function RoleInfoBGHandler.on_notify_social_info_bg(bg_ids)
  log_tree("RoleInfoBGHandler.on_notify_social_info_bg bg_ids", bg_ids)
  if bg_ids then
    local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
    logic_roleInfo_background:on_notify_social_info_bg(bg_ids[ENUM_ITEM_SUBTYPE.RoleInfoBG])
    local logic_roleInfo_opening = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_opening)
    logic_roleInfo_opening:on_notify_social_info_bg(bg_ids[ENUM_ITEM_SUBTYPE.PersonalOpening])
  end
end
function RoleInfoBGHandler.send_set_social_info_bg_req(subtype, bg_id)
  log(bWriteLog and "RoleInfoBGHandler.send_set_social_info_bg_req subtype = " .. tostring(subtype) .. ", bg_id = " .. tostring(bg_id))
  NetManager.SendPkg(605003559, subtype, bg_id)
end
function RoleInfoBGHandler.on_set_social_info_bg_rsp(res, subtype, bg_id)
  log(bWriteLog and "RoleInfoBGHandler.on_set_social_info_bg_rsp res = " .. tostring(res) .. ", subtype = " .. tostring(subtype) .. ", bg_id = " .. tostring(bg_id))
  if subtype == ENUM_ITEM_SUBTYPE.RoleInfoBG then
    local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
    logic_roleInfo_background:on_set_social_info_bg_rsp(res, bg_id)
  elseif subtype == ENUM_ITEM_SUBTYPE.PersonalOpening then
    local logic_roleInfo_opening = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_opening)
    logic_roleInfo_opening:on_set_social_info_bg_rsp(res, bg_id)
  end
end
return RoleInfoBGHandler