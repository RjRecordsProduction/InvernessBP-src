local NetErrorCode = {}
local NetCodeConfig = require("client.network.comm.NetRsp2IndexConfig")
local local 
function NetErrorCode.IsHandlerLogic(sRspName, nErrorCode)
  local CodeCfg = NetCodeConfig[sRspName] and NetCodeConfig[sRspName].tipCode
  if not CodeCfg or type(nErrorCode) == "nil" or nErrorCode == 0 or nErrorCode == "ok" then
    return true
  else
    local sTipStr = ""
    local commonCfg = CDataTable.GetTableData("MSGConfigCommonNoticeTips", nErrorCode)
    local nErrorTipKey = commonCfg and commonCfg.textID or nErrorCode
    nErrorTipKey = type(CodeCfg) == "table" and CodeCfg[nErrorCode] or nErrorTipKey
    sTipStr = LocUtil.GetLocalizeResStr(nErrorTipKey)
    if sTipStr == "" then
      sTipStr = nErrorCode
    end
    ShowNotice(sTipStr)
    log(bWriteLog and "  >>> Network API on_" .. sRspName .. "   nErrorCode: " .. nErrorCode .. "   , sTipStr: " .. sTipStr .. " ,nErrorTipKey: " .. nErrorTipKey)
    return false
  end
end
return NetErrorCode