local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
local Logic_QRCodeRestrictUtils = {}
function Logic_QRCodeRestrictUtils.IsUcUseLimit(nItemId)
  nItemId = nItemId or CoinMacro.Uc
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if nItemId == CoinMacro.Uc and QRcodeRestrictManager:IsRestrictUC() then
    QRcodeRestrictManager:ShowRestrictTips()
    return true
  end
  return false
end
return Logic_QRCodeRestrictUtils