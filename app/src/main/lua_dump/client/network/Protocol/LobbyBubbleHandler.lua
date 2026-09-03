local NetManager = require("client.network.comm.NetManager")
local LobbyBubbleHandler = {}
function LobbyBubbleHandler.send_get_keep_stay_bubble_req()
  log(bWriteLog and "[mxiliu]: LobbyBubbleHandler.send_get_keep_stay_bubble_req start")
  NetManager.SendPkg(1429665767)
end
function LobbyBubbleHandler.on_get_keep_stay_bubble_rsp(err_code, act_info)
  log(bWriteLog and string.format("LobbyBubbleHandler.on_get_keep_stay_bubble_rsp. err_code=%s", tostring(err_code)))
  log_tree("LobbyBubbleHandler.on_get_keep_stay_bubble_rsp act_info = ", act_info)
  local SpecialOfferBubbleModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.SpecialOfferBubbleModule)
  if err_code ~= 0 then
    if err_code == 18090001 then
      SpecialOfferBubbleModule:SetActOpen(false)
    end
    return
  end
  SpecialOfferBubbleModule:on_get_keep_stay_bubble_rsp(act_info[1])
end
return LobbyBubbleHandler