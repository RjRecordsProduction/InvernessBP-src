local LogicGameletRedPoint = {
  GameletActId = {},
  AppId2ActId = {},
  GameletAct2Red = {},
  BatchRefreshRedPointTb = {},
  BatchRefreshReadyTb = {}
}
local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
local BatchKey_RedPoint = "GameletRedPointBatch"
local BatchKey_ActReady = "GameletActReadyBatch"
function LogicGameletRedPoint:OnLogOut()
  local BatchHelper = require("client.logic.Batch.BatchHelper")
  BatchHelper.Remove(BatchKey_RedPoint)
  BatchHelper.Remove(BatchKey_ActReady)
end
function LogicGameletRedPoint:SaveGameletActId(actId, appId)
  if not (actId and appId) or appId == 0 then
    return
  end
  log_format("LogicGameletRedPoint:SaveGameletActId. actId=%s, appId=%s ", tostring(actId), tostring(appId))
  self.GameletActId[actId] = 1
  self.AppId2ActId[appId] = actId
end
function LogicGameletRedPoint:UpdateRedPoint(appId, redDotType)
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  if ActivityCenterModule:IsHostedActAllDone(appId) then
    redDotType = 0
  end
  local actId = self:GetActIdByAppId(appId)
  if not actId then
    log_format("LogicGameletRedPoint:UpdateRedPoint. appId=%s, redDotType=%s , has not actId", tostring(appId), tostring(redDotType))
    return
  end
  self.GameletAct2Red[actId] = {
    appId = appId,
    redDotType = tonumber(redDotType) or 0
  }
  self.BatchRefreshRedPointTb[actId] = 1
  local BatchHelper = require("client.logic.Batch.BatchHelper")
  BatchHelper.DoOnce(BatchKey_RedPoint, 1, self.BatchRefreshRedPoint, self)
end
function LogicGameletRedPoint:GetRed(actId)
  local RedInfo = self.GameletAct2Red[actId]
  if not RedInfo then
    return
  end
  local Red = RedInfo.redDotType ~= ActivityMacros.RedDotType.None
  return Red, RedInfo.redDotType
end
function LogicGameletRedPoint:BatchRefreshRedPoint()
  local logic_gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
  for actId, redInfo in pairs(self.GameletAct2Red) do
    LobbySystem.LobbyRedPointUpdate(actId, redInfo.redDotType ~= 0)
  end
  local changeList = {
    idList = {},
    typeList = {}
  }
  local idList = changeList.idList
  for id, _ in pairs(self.BatchRefreshRedPointTb) do
    local info = self.GameletAct2Red[id]
    if info and logic_gamelet_interface:IsInterfaceReady(info.appId) then
      idList[tonumber(id)] = true
    end
  end
  if next(idList) then
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changeList)
  end
  self.BatchRefreshRedPointTb = {}
end
function LogicGameletRedPoint:IsActivityCenterGamelet(appId)
  return self.AppId2ActId[tonumber(appId)] ~= nil
end
function LogicGameletRedPoint:UpdateGameletActReady(appId)
  if not appId then
    return
  end
  local actId = self.AppId2ActId[tonumber(appId)] or 0
  self.BatchRefreshReadyTb[appId] = actId
  local BatchHelper = require("client.logic.Batch.BatchHelper")
  BatchHelper.DoOnce(BatchKey_ActReady, 1, self.BatchRefreshReady, self)
end
function LogicGameletRedPoint:BatchRefreshReady()
  local appIdMap = {}
  local NeedPost = false
  for appId, actId in pairs(self.BatchRefreshReadyTb) do
    NeedPost = true
    appIdMap[tonumber(appId)] = true
  end
  if NeedPost then
    EventSystem:postEvent(EVENTTYPE_GAMELET, EVENTID_GAMELET_ACT_CENTER_READY_UPDATED, appIdMap)
  end
  self.BatchRefreshReadyTb = {}
end
function LogicGameletRedPoint:GetActIdByAppId(appId)
  if not appId or appId == 0 then
    return nil
  end
  return self.AppId2ActId[tonumber(appId)]
end
return LogicGameletRedPoint