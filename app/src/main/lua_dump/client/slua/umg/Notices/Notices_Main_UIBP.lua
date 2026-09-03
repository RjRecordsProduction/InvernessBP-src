local Notices_Main_UIBP = {}
local NoticesConst = require("client.logic.Notice.NoticesConst")
function Notices_Main_UIBP:ctor(_, noticeScene)
  self.NoticeScene = noticeScene
  self.CurSubUI = nil
  self.WaitingJumpRsp = false
end
function Notices_Main_UIBP:OnPostInitialize()
  log(bWriteLog and string.format("Notices_Main_UIBP:OnPostInitialize. NoticeScene:%s", tostring(self.NoticeScene)))
  self:PushSeq()
end
function Notices_Main_UIBP:OnAndroidBack()
  local handle = false
  if self.CurSubUI and not self.CurSubUI:IsAsyncLoading() and self.CurSubUI.OnAndroidBack then
    handle = self.CurSubUI:OnAndroidBack()
  end
  if not handle then
    self:PushSeq()
  end
end
function Notices_Main_UIBP:OnSeqEnd()
  log(bWriteLog and string.format("Notices_Main_UIBP:OnSeqEnd. NoticeScene:%s", tostring(self.NoticeScene)))
  local NoticesModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NoticesModule)
  NoticesModule:OnSeqEnd()
  self:CloseSelf()
end
function Notices_Main_UIBP:PushSeq()
  if self.WaitingJumpRsp then
    log(bWriteLog and "Notices_Main_UIBP:PushSeq. WaitingJumpRsp is true.")
    return
  end
  local NoticesModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NoticesModule)
  local SeqData = NoticesModule:GetSeqNextData(self.NoticeScene)
  if not SeqData then
    log(bWriteLog and string.format("Notices_Main_UIBP:PushSeq. SeqData is nil, NoticeScene:%s, call OnSeqEnd", tostring(self.NoticeScene)))
    self:OnSeqEnd()
    return
  end
  local UIConfig = SeqData.UIConfig
  if not UIConfig then
    log(bWriteLog and string.format("Notices_Main_UIBP:PushSeq. UIConfig is nil, NoticeScene:%s", tostring(self.NoticeScene)))
    return
  end
  local noticeData = SeqData.Data
  log(bWriteLog and string.format("Notices_Main_UIBP:PushSeq. NoticeScene:%s, UIConfig:%s", tostring(self.NoticeScene), tostring(UIConfig)))
  if self.CurSubUI then
    self.CurSubUI:Close()
    self.CurSubUI = nil
  end
  self.CurSubUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_Content, UIConfig, noticeData)
end
function Notices_Main_UIBP:JumpUrl(noticeData)
  if self.WaitingJumpRsp then
    log(bWriteLog and "Notices_Main_UIBP:JumpUrl. WaitingJumpRsp is true.")
    return
  end
  if self.CurSubUI then
    self.CurSubUI:Close()
    self.CurSubUI = nil
  end
  if noticeData.MsgUrl == "" then
    log(bWriteLog and "Notices_Main_UIBP:JumpUrl. MsgUrl is empty.")
    return
  end
  gem_report_utils.ReportLobbyClickEvent(gem_report_utils.SubEventName_FaceSlap, gem_report_utils.GetReportParam(noticeData.MsgId, noticeData.MsgUrl, true))
  local TLogReasonStrTable = gem_report_utils.GetReportParamTable(noticeData.MsgId, noticeData.MsgUrl, true)
  TLogReasonStrTable.event_name = gem_report_utils.SubEventName_FaceSlap
  TLogReasonStrTable.scene = "FaceSlap_Click"
  local TLogReasonStr = json.encode(TLogReasonStrTable)
  ClientSendTLogReport(TLogEventDefine.ExposureEntrance, 0, TLogReasonStr)
  log(bWriteLog and "TLog new format, Notices_Main_UIBP:JumpUrl, reason : " .. tostring(0) .. " reasonStr : " .. tostring(TLogReasonStr))
  local url = noticeData.MsgUrl
  local JumpUtils = require("client.logic.store.jump_utils")
  if JumpUtils.IsHttpOrHttpsJumpUrl(url) then
    local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
    url = webModule:AddParameterByPersonalInfo(url)
    if noticeData.ExternalWebview and noticeData.ExternalWebview == 1 then
      Client.LaunchUrl(url)
    else
      GlobalData.JumpUrl(url)
    end
    self:CloseSelf()
    return
  end
  self.WaitingJumpRsp = false
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(url)
  local moduleId = tonumber(params.module or 0)
  if JumpUtils.IsStoreCrateJumpModule(moduleId) and not JumpUtils.bGetJumpMap then
    if moduleId == BP_ENUM_MODULE_SUPPLY then
      url = url .. "&from=" .. StoreConst.source_NoticeJumpToCrate
    end
    self.WaitingJumpRsp = true
    JumpUtils.RequestJumpMapInfo(false, function()
      if self and slua.isValid(self.UIRoot) then
        self.WaitingJumpRsp = false
        GlobalData.JumpUrl(url)
        self:CloseSelf()
      else
        log(bWriteLog and "Notices_Main_UIBP:JumpUrl RSP, not UI")
      end
    end)
  else
    GlobalData.JumpUrl(url)
    self:CloseSelf()
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
local CNotices_Main_UIBP = class(UIBase, nil, Notices_Main_UIBP)
return CNotices_Main_UIBP