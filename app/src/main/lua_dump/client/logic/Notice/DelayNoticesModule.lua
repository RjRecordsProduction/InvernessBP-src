local DelayNoticesModule = {}
function DelayNoticesModule:DefineAndResetData()
  self.PandoraMap = {}
  self.GameletMap = {}
  self.DelayNoticesList = {}
  self.ShowList = {}
  self.IndexLength = 0
end
function DelayNoticesModule:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_PANDORA, EVENTID_PANDORA_ALL_READY_BATCH_NOTIFY, self.OnPandoraReadyNotify, self)
  self:AddCommonEvent(EVENTTYPE_GAMELET, EVENTID_GAMELET_ACT_CENTER_READY_UPDATED, self.OnGameletReadyNotify, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_DELAY_NOTICES, self.RealShowNoticeUI, self)
end
function DelayNoticesModule:OnPandoraReadyNotify(_, __, readyMap)
  if not readyMap or not next(self.PandoraMap) then
    log(bWriteLog and "DelayNoticesModule:OnPandoraReadyNotify. readyMap is nil or self.PandoraMap is empty")
    return
  end
  for pandoraId, _ in pairs(readyMap) do
    if self.PandoraMap[pandoraId] then
      local index = self.PandoraMap[pandoraId]
      local noticeData = self.DelayNoticesList[index]
      self.DelayNoticesList[index] = nil
      self.PandoraMap[pandoraId] = nil
      log_format("DelayNoticesModule:OnPandoraReadyNotify. pandoraId=%s, index=%s", tostring(pandoraId), tostring(index))
      table.insert(self.ShowList, noticeData)
    end
  end
  log(bWriteLog and "DelayNoticesModule:OnPandoraReadyNotify")
  self:RealShowNoticeUI()
end
function DelayNoticesModule:OnGameletReadyNotify(_, __, appIdMap)
  if not appIdMap or not next(self.GameletMap) then
    log(bWriteLog and "DelayNoticesModule:OnGameletReadyNotify. appIdMap is nil or self.GameletMap is empty")
    return
  end
  for appId, _ in pairs(appIdMap) do
    if self.GameletMap[appId] then
      local index = self.GameletMap[appId]
      local noticeData = self.DelayNoticesList[index]
      self.DelayNoticesList[index] = nil
      self.GameletMap[appId] = nil
      log_format("DelayNoticesModule:OnGameletReadyNotify. appId=%s, index=%s", tostring(appId), tostring(index))
      table.insert(self.ShowList, noticeData)
    end
  end
  log(bWriteLog and "DelayNoticesModule:OnGameletReadyNotify")
  self:RealShowNoticeUI()
end
function DelayNoticesModule:SaveDelayNotices(notices)
  if not notices then
    return
  end
  self.IndexLength = self.IndexLength + 1
  local index = self.IndexLength
  self.DelayNoticesList[index] = notices
  local JumpUrl = notices.MsgUrl
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(JumpUrl)
  local JumpUtils = require("client.logic.store.jump_utils")
  if JumpUtils.IsPanDoraJumpUrl(JumpUrl) then
    local pandoraId = params.actid
    if pandoraId then
      log_format("DelayNoticesModule:SaveDelayNotices. SaveDelayNotices pandoraID=%s,index=%s", tostring(pandoraId), tostring(index))
      self.PandoraMap[tonumber(pandoraId)] = index
    end
  else
    local appId = params.appId
    if appId then
      log_format("DelayNoticesModule:SaveDelayNotices. SaveDelayNotices appId=%s,index=%s", tostring(appId), tostring(index))
      self.GameletMap[tonumber(appId)] = index
    end
  end
end
function DelayNoticesModule:GetShowList()
  local showList = self.ShowList
  self.ShowList = {}
  return showList
end
function DelayNoticesModule:ClearData()
  self:DefineAndResetData()
end
function DelayNoticesModule:RealShowNoticeUI()
  if not next(self.ShowList) then
    return
  end
  local NoticesModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NoticesModule)
  local NoticesConst = require("client.logic.Notice.NoticesConst")
  NoticesModule:ClearTargetNotice(NoticesConst.Scene.DelayNotices)
  NoticesModule:ShowNotice(NoticesConst.Scene.DelayNotices)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CDelayNoticesModule = class(CModuleBase, nil, DelayNoticesModule)
return CDelayNoticesModule