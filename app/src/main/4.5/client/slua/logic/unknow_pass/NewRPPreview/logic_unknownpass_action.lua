local logic_unknownpass_action = {playActionTimer = nil}
local _cameraActionID
local _isPlaying = false
local _isAfterActionEnd = false
local _IsCanPlayAction = function()
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if not UnknowPassTunnelSystem.isShowRP then
    log(bWriteLog and "[v_wllwu] logic_unknownpass_action:_IsCanPlayAction UnknowPassTunnelSystem.isShowRP false")
    return
  end
  return true
end
local _PlayAction = function(itemID)
  local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
  PassPreviewSystem.ClearDelayZoomTimer()
  PassPreviewSystem.ShowItem(itemID, false)
  PassPreviewSystem.ClearCameraActionID()
end
local _ActionStartShow = function(bShow)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SHOW_AWARDPANEL, bShow)
  if bShow then
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SHOW_TAB)
  else
    logic_connection_waiting:Show(0, false, true)
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_HIDE_TAB)
  end
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_SHOW_LEFTDETAIL, false)
end
function logic_unknownpass_action:OnInitialize()
  logic_unknownpass_action.__super.OnInitialize(self)
  self:ClearData()
end
function logic_unknownpass_action:OnLogOut()
  self:ClearData()
end
function logic_unknownpass_action:CheckCanPlayActionByItemData(itemID, itemLevel)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.GetCurTab() ~= PassDataSystem.GetTabType().award then
    log(bWriteLog and "[v_wllwu] logic_unknownpass_action:CheckCanPlayAction GetCurTab is not award")
    return
  end
  local cfg = CDataTable.GetTableData("UnknowPassSeasonResource", UnknowPassSystem.Season)
  if not cfg then
    log(bWriteLog and "[v_wllwu] logic_unknownpass_action:CheckCanPlayAction actionCfg is nil, UnknowPassSystem.Season = " .. tostring(UnknowPassSystem.Season))
    return
  end
  if not (cfg.ItemID and not (cfg.ItemID <= 0) and cfg.itemLevel) or 0 >= cfg.itemLevel then
    log(bWriteLog and "[v_wllwu] logic_unknownpass_action:CheckCanPlayAction cfg actionInfo is nil, UnknowPassSystem.Season = " .. tostring(UnknowPassSystem.Season))
    return
  end
  itemID = itemID or 0
  if itemID ~= cfg.ItemID then
    return
  end
  itemLevel = itemLevel or 0
  if itemLevel ~= cfg.ItemLevel then
    log(bWriteLog and "[v_wllwu] logic_unknownpass_action:CheckCanPlayAction level false, level is " .. tostring(itemLevel) .. " cfgItemLevel = " .. tostring(cfg.ItemLevel))
    return
  end
  return true
end
function logic_unknownpass_action:GetCameraActionID()
  local cfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", UnknowPassSystem.Season)
  return cfg and cfg.CameraAction
end
function logic_unknownpass_action:ClearPlayTimer(timerHandle)
  if timerHandle then
    self:RemoveTimer(timerHandle)
    timerHandle = nil
  end
end
function logic_unknownpass_action:PlayCameraAction(actionID)
  if _isPlaying then
    return
  end
  self:ClearPlayTimer(self.playActionTimer)
  _cameraActionID = actionID
  _isPlaying = true
  _ActionStartShow(false)
end
function logic_unknownpass_action:OnContinuePlayAction()
  logic_connection_waiting:Hide(0)
  if not _cameraActionID or _cameraActionID <= 0 then
    self:ClearPlayTimer(self.playActionTimer)
    return
  end
  if not _IsCanPlayAction() then
    self:ClearPlayTimer(self.playActionTimer)
    return
  end
  _PlayAction(_cameraActionID)
  local cfg = CDataTable.GetTableData("UnknowPassSeasonResource", UnknowPassSystem.Season)
  local actionTime = tonumber(cfg.ActionTime)
  log(bWriteLog and "[v_wllwu] logic_unknownpass_action:OnContinuePlayAction start")
  self.playActionTimer = self:AddTimerOnce(actionTime, function()
    _cameraActionID = nil
    _isPlaying = false
    _isAfterActionEnd = true
    _ActionStartShow(true)
    log(bWriteLog and "[v_wllwu] logic_unknownpass_action:OnContinuePlayAction end")
  end)
end
function logic_unknownpass_action:OnApplicationReactivated()
  log(bWriteLog and "[v_wllwu] logic_unknownpass_action:OnApplicationReactivated")
  if _isPlaying then
    logic_connection_waiting:Hide(0)
    _cameraActionID = nil
    _isPlaying = false
    _isAfterActionEnd = true
    _ActionStartShow(true)
  end
end
function logic_unknownpass_action:OnApplicationDeactivated()
  log(bWriteLog and "[v_wllwu] logic_unknownpass_action:OnApplicationDeactivated")
  self:ClearPlayTimer(self.playActionTimer)
  local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
  PassPreviewSystem.StopAction()
end
function logic_unknownpass_action:ReInitOnReLogin()
  log(bWriteLog and "[v_wllwu] logic_unknownpass_action:ReInitOnReLogin")
  if not (_isPlaying and _cameraActionID) or _cameraActionID <= 0 then
    log(bWriteLog and "[v_wllwu] logic_unknownpass_action:ReInitOnReLogin return false")
    return
  end
  logic_connection_waiting:Hide(0)
  self:StopActionAndRecoverUI()
end
function logic_unknownpass_action:StopActionAndRecoverUI()
  self:ClearData()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.StopAction()
  _isAfterActionEnd = true
  _ActionStartShow(true)
end
function logic_unknownpass_action:IsInPlaying()
  return _isPlaying
end
function logic_unknownpass_action:IsAfterPlayAction()
  if _isAfterActionEnd then
    log(bWriteLog and "[v_wllwu] logic_unknownpass_action:GetIsAfterPlayAction _isAfterActionEnd is true")
  end
  return _isAfterActionEnd
end
function logic_unknownpass_action:ResetAfterPlayAction()
  if _isAfterActionEnd then
    log(bWriteLog and "[v_wllwu] logic_unknownpass_action:ResetAfterPlayAction")
  end
  _isAfterActionEnd = false
end
function logic_unknownpass_action:ClearData()
  self:ClearPlayTimer(self.playActionTimer)
  _cameraActionID = nil
  _isPlaying = false
  _isAfterActionEnd = false
end
local _GetActionId = function()
  local cfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", UnknowPassSystem.Season)
  if not cfg then
    log(bWriteLog and "[v_wllwu] logic_unknownpass_action:GetActionId nil, UnknowPassSystem.Season is " .. tostring(UnknowPassSystem.Season))
    return
  end
  log(bWriteLog and "[v_wllwu] logic_unknownpass_action:GetActionId is " .. tostring(cfg.CameraAction))
  return cfg.CameraAction
end
function logic_unknownpass_action:CheckActionSourceReady()
  local actionPakId = _GetActionId()
  if not actionPakId or actionPakId <= 0 then
    return true
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local dowloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {actionPakId})
  log(bWriteLog and "[v_wllwu] logic_unknownpass_action:CheckActionSourceReady dowloadState =  " .. tostring(dowloadState))
  return dowloadState == PufferConst.ENUM_DownloadState.Done
end
function logic_unknownpass_action:StartDownloadActionSource()
  local actionPakId = _GetActionId()
  if not actionPakId or actionPakId <= 0 then
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {actionPakId})
  if state == PufferConst.ENUM_DownloadState.Not then
    local params = {bAutoDownload = true}
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {actionPakId}, nil, nil, params)
  end
end
function logic_unknownpass_action:DownloadActionSource()
  if self:CheckActionSourceReady() then
    log(bWriteLog and "[v_wllwu] logic_unknownpass_action:DownloadActionSource has DownLoad ")
    return
  end
  log(bWriteLog and "[v_wllwu] logic_unknownpass_action:DownloadActionSource start")
  self:StartDownloadActionSource()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_unknownpass_action = class(CModuleBase, nil, logic_unknownpass_action)
return Clogic_unknownpass_action