PandoraProtocolLayer = {}
local local local local local getMicroseconds = slua.getMicroseconds
local local 
function PandoraProtocolLayer.SendCmd(sendTable)
  if IsEditor then
    log(bWriteLog and " PandoraProtocolLayer not sendCmd because in Editor")
    return
  end
  if not BP_Panduola_Init then
    log(bWriteLog and "PandoraProtocolLayer.SendCmd Pandora is not initialized")
    return
  end
  local _beginTime = getMicroseconds()
  local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
  local HostedConst = require("client.slua.logic.HostedProtoBridge.HostedConst")
  HostedProtoBridge:OnSendMessage(HostedConst.HostedType.Pandora, sendTable)
  log(bWriteLog and string.format("TimeTracer PandoraProtocolLayer SendCmd:%s time: [%.3fms] ", tostring(sendTable.type), (getMicroseconds() - _beginTime) / 1000))
end
function PandoraProtocolLayer.OnPandoraCallback(jsonStr)
  local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
  local HostedConst = require("client.slua.logic.HostedProtoBridge.HostedConst")
  HostedProtoBridge:OnReceiveMessage(HostedConst.HostedType.Pandora, "0", jsonStr)
end
return PandoraProtocolLayer