local NetManager = require("client.network.comm.NetManager")
local SocialCardBGHandler = {}
function SocialCardBGHandler.send_set_social_card_floor_req(social_card_floor_id)
  NetManager.SendPkg(1512236467, social_card_floor_id)
end
function SocialCardBGHandler.on_set_social_card_floor_rsp(ret)
  local logic_social_card_bg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_social_card_bg)
  logic_social_card_bg:on_set_social_card_floor_rsp(ret)
end
function SocialCardBGHandler.on_notify_social_card_floor(social_card_floor_id)
  printf("SocialCardBGHandler.on_notify_social_card_floor social_card_floor_id: %s", social_card_floor_id)
  local logic_social_card_bg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_social_card_bg)
  logic_social_card_bg:on_notify_social_card_floor(social_card_floor_id)
end
return SocialCardBGHandler