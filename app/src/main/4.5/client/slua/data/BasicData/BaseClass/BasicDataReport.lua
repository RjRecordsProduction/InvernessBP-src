local BasicDataReport = {}
function BasicDataReport:ReportImmediate(...)
  local Params = table.pack(...)
  if not Params or not next(Params) then
    log_error("BasicDataReport:ReportImmediate Params = nil")
    return
  end
  self:OnImmediateReqMsg(...)
end
function BasicDataReport:ReportDelay(...)
  local Params = table.pack(...)
  if not Params or not next(Params) then
    log_error("BasicDataReport:ReportDelay Params = nil")
    return nil
  end
  self:_SendReqMsg(...)
end
function BasicDataReport:OnMergeReqMsg(...)
end
function BasicDataReport:OnImmediateReqMsg(...)
end
function BasicDataReport:OnSendBatchReqMsg(...)
end
function BasicDataReport:_BatchReqMsg()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if not login_module.bIsInitLogin then
    return
  end
  BasicDataReport.__super._BatchReqMsg(self)
end
function BasicDataReport:OnLogin()
  if self._batchReqKeyTable and next(self._batchReqKeyTable) then
    self:_BatchReqMsg()
  end
end
local class = require("class")
local CModuleBase = require("client.slua.data.BasicData.BaseClass.BasicDataBatchClass")
local CBasicDataReport = class(CModuleBase, nil, BasicDataReport)
return CBasicDataReport