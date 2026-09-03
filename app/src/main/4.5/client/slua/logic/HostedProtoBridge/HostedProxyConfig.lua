local HostedConst = require("client.slua.logic.HostedProtoBridge.HostedConst")
local HostedProxyConfig = {
  [HostedConst.HostedType.Pandora] = {
    logicName = "client.slua.logic.Pandora.pandora_v2_adapter",
    sendFunc = "PandoraSendCmd",
    toSelf = true
  },
  [HostedConst.HostedType.Gamelet] = {
    modulePath = "CommonModuleConfig",
    moduleName = "logic_gamelet_interface",
    sendFunc = "SendMessageToApp"
  }
}
return HostedProxyConfig