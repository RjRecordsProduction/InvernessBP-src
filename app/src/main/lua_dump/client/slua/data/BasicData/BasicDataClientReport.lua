local BasicDataClientReport = {}
local domainStr = FuncUtil.GetDomainByID(3366005) or ""
local TypeCfg = {
  [1] = {
    cdn_url = domainStr .. "/pubg/tools/xpcall/",
    is_count = true
  },
  [2] = {
    cdn_url = domainStr .. "/pubg/tools/capability/",
    is_shipping = true
  },
  [3] = {
    cdn_url = domainStr .. "/pubg/tools/vehicle/",
    is_battle_open = true,
    is_count = true,
    is_editor = true
  },
  [4] = {
    cdn_url = domainStr .. "/pubg/tools/memory/",
    is_shipping = false,
    is_battle_open = true
  },
  [5] = {
    cdn_url = domainStr .. "/pubg/tools/syncloadasset/",
    is_shipping = false,
    is_battle_open = false
  },
  [6] = {
    cdn_url = domainStr .. "/pubg/tools/interfaceConfig/",
    is_shipping = false,
    is_battle_open = false,
    is_editor = true,
    is_release = false
  }
}
function BasicDataClientReport:Init()
  self.reportRate = 100
  self.switchKey = "ClientReportServer"
  self.whiteKey = "ClientReportServerWhite"
  local ToolReportUtil = require("client.slua.logic.report.ToolReportUtil")
  self.isReleaseVer = ToolReportUtil:IsReleaseVersion()
  self.isShipping = Client.IsShipping()
  self.isWhite = ToolReportUtil:IsWhite(self.whiteKey)
  self.bSwitch = ToolReportUtil:GetReportSwitch(self.switchKey, self.reportRate)
  self.isEditor = _G.IsEditor
  log(bWriteLog and string.format("BasicDataClientReport.Init isReleaseVer=%s isWhite=%s bSwitch=%s ", tostring(self.isReleaseVer), tostring(self.isWhite), tostring(self.bSwitch)))
end
function BasicDataClientReport:ReInit()
  self:Init()
end
function BasicDataClientReport:ReportImmediate(ReportType, Error_Str)
  if self:_IsCanReport(ReportType, Error_Str) then
    return
  end
  BasicDataClientReport.__super.ReportImmediate(self, ReportType, Error_Str)
end
function BasicDataClientReport:ReportDelay(ReportType, Error_Str)
  if self:_IsCanReport(ReportType, Error_Str) then
    return
  end
  BasicDataClientReport.__super.ReportDelay(self, ReportType, Error_Str)
end
function BasicDataClientReport:OnSendBatchReqMsg(errorList, _)
  if not errorList or type(errorList) ~= "table" or #errorList <= 0 then
    log_error("BasicDataClientReport:OnSendBatchReqMsg errorList = nil ")
    return
  end
  local ClientErrorHandler = require("client.network.Protocol.ClientErrorReportHandler")
  local ToolReportUtil = require("client.slua.logic.report.ToolReportUtil")
  local versionInfo = ToolReportUtil:GetPackageInfo()
  ClientErrorHandler.send_client_tools_batch_report_req(versionInfo, errorList)
end
function BasicDataClientReport:OnImmediateReqMsg(ReportType, Error_Str)
  local ToolReportUtil = require("client.slua.logic.report.ToolReportUtil")
  Error_Str = ToolReportUtil:ReParseError(Error_Str, ReportType)
  local cfg = TypeCfg[ReportType]
  local errorList = {
    cdn = cfg.cdn_url,
    err = {}
  }
  table.insert(errorList.err, {
    error = Error_Str,
    is_count = cfg.is_count
  })
  self:OnSendBatchReqMsg(errorList)
end
function BasicDataClientReport:OnMergeReqMsg(ReportType, Error_Str)
  local bExist = false
  local cfg = TypeCfg[ReportType]
  for _, v in pairs(self._batchReqKeyTable) do
    if v.cdn_url == cfg.cdn_url then
      local bSameErr = false
      v.err = v.err or {}
      for _, vv in pairs(v.err) do
        if vv and vv.error == error then
          bSameErr = true
          break
        end
      end
      if not bSameErr then
        table.insert(v.err, {
          error = Error_Str,
          is_count = cfg.is_count
        })
      end
      bExist = true
      break
    end
  end
  if not bExist then
    local reqData = {
      cdn_url = cfg.cdn_url,
      err = {}
    }
    table.insert(reqData.err, {
      error = Error_Str,
      is_count = cfg.is_count
    })
    table.insert(self._batchReqKeyTable, reqData)
  end
end
function BasicDataClientReport:_IsCanReport(ReportType, Error_Str)
  if not (Error_Str and ReportType) or type(Error_Str) ~= "string" or Error_Str == "" then
    log(bWriteLog and string.format("BasicDataClientReport:_IsCanReport return false ReportType[%s], Error_Str[%s]", tostring(ReportType), tostring(Error_Str)))
    return false
  end
  local cfg = TypeCfg[ReportType]
  if not cfg then
    log(bWriteLog and string.format("BasicDataClientReport:_IsCanReport return false ReportType[%s], cfg is nil ", tostring(ReportType)))
    return false
  end
  if self.isWhite then
    log(bWriteLog and string.format("BasicDataClientReport:_IsCanReport false ReportType[%s], isWhite is true ", tostring(ReportType)))
    return true
  end
  if not self.bSwitch then
    log(bWriteLog and string.format("BasicDataClientReport:_IsCanReport return false ReportType[%s], bSwitch is false ", tostring(ReportType)))
    return false
  end
  if not cfg.is_release and self.isReleaseVer then
    log(bWriteLog and string.format("BasicDataClientReport:_IsCanReport return false ReportType[%s], IsReleaseVersion is true ", tostring(ReportType)))
    return false
  end
  if not cfg.is_battle_open and GameStatus.InCombatActiveState() then
    log(bWriteLog and string.format("BasicDataClientReport:_IsCanReport return false ReportType[%s], is_battle_open is false ", tostring(ReportType)))
    return false
  end
  if not cfg.is_editor and self.isEditor then
    log(bWriteLog and string.format("BasicDataClientReport:_IsCanReport return false ReportType[%s], isEditor is true ", tostring(ReportType)))
    return false
  end
  if cfg.is_shipping and not self.isShipping then
    log(bWriteLog and string.format("BasicDataClientReport:_IsCanReport return false ReportType[%s], IsShipping is false ", tostring(ReportType)))
    return false
  end
  return true
end
local class = require("class")
local CModuleBase = require("client.slua.data.BasicData.BaseClass.BasicDataReport")
local CBasicDataClientReport = class(CModuleBase, nil, BasicDataClientReport)
return CBasicDataClientReport