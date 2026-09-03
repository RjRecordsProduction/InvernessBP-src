local PandoraLogic = {
  ActReadyStateList = {},
  ActPakReadyStateList = {},
  ActRedPointStateList = {},
  BatchNotifyReadyList = {},
  CurActId = 0,
  moneyType = {
    gold = 1,
    diamond = 2,
    ticket = 3,
    fp_token = 4,
    gold_chip = 5,
    eternal_diamond = 6,
    battle_coin = 7
  },
  redIdTb = {}
}
local TableUtil = require("common.table_util")
local local local PandoraActId_Module = {
  [BP_ENUM_MODULE_PANDORA_ACTIVITY_NAVIGATOR] = "client.slua.logic.Pandora.pandora_activity_navigator"
}
local BatchKey_PandoraReady = "PandoraReadyBatch"
local BatchKey_PandoraRedPoint = "PandoraRedPointBatch"
local EventUrlJump = function(eventType, eventID, vars)
  log(bWriteLog and "PandoraLogic.EventUrlJump eventType:" .. eventType .. ",eventID:" .. eventID)
  log_tree("vars=", vars)
  local actId = tonumber(vars.actid)
  if actId == nil or actId == 0 then
    return
  end
  local pandora_common_protocol = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.pandora_common_protocol)
  pandora_common_protocol:SendShow(actId, vars)
end
function PandoraLogic.Init()
  PandoraLogic.ActReadyStateList = {}
  PandoraLogic.ActPakReadyStateList = {}
  PandoraLogic.ActRedPointStateList = {}
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PANDORA, EventUrlJump)
end
function PandoraLogic.OnLogin()
  if not GlobalData.IsIOSCheck() then
    local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
    if pandoraSystem.CheckSysOpen() then
      log(bWriteLog and "LobbySystem.on_sync_base_info PandoraSystem is open")
      pandoraSystem.Init()
    else
      log(bWriteLog and "LobbySystem.on_sync_base_info PandoraSystem is close")
    end
  end
end
function PandoraLogic.Release()
  log(bWriteLog and "PandoraLogic.Release")
  EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PANDORA, EventUrlJump)
  PandoraLogic.ActReadyStateList = {}
  PandoraLogic.ActPakReadyStateList = {}
  PandoraLogic.ActRedPointStateList = {}
  local BatchHelper = require("client.logic.Batch.BatchHelper")
  BatchHelper.Remove(BatchKey_PandoraReady)
  BatchHelper.Remove(BatchKey_PandoraRedPoint)
end
function PandoraLogic.OnPandoraReady(actId, RedMark)
  log(bWriteLog and "PandoraLogic.OnPandoraReady actId: " .. actId .. " ,RedMark: " .. tostring(RedMark))
  PandoraLogic.SetActReady(actId, true)
  local act_id = tonumber(actId)
  PandoraLogic.BeginRefreshRedPoint(act_id)
  if PandoraActId_Module[act_id] ~= nil then
    local m = require(PandoraActId_Module[act_id])
    if m and m.Init then
      m.Init()
    end
    if PandoraLogic.ActHasRedPoint(act_id) then
      BP_Panduola_RedPoint = 1
    else
      BP_Panduola_RedPoint = 0
    end
  end
  LobbySystem.refresh_activity_display_byPandora()
end
function PandoraLogic.OnPandoraEnd(actId)
  log(bWriteLog and "PandoraLogic.OnPandoraEnd")
  if actId == nil then
    return
  end
  log(bWriteLog and "PandoraLogic.OnPandoraEnd actId: " .. actId)
  PandoraLogic.SetActReady(actId, false)
  PandoraLogic.SetActPakReady(actId, false)
  PandoraLogic.SetActRedPoint(actId, false)
  LobbySystem.SetActivityIfShowByModuleId(actId)
  local act_id = tonumber(actId)
  if PandoraActId_Module[act_id] ~= nil then
    local m = require(PandoraActId_Module[act_id])
    if m and m.Release then
      m.Release()
    end
  end
end
function PandoraLogic.OnPandoraPakReady(actId)
  log(bWriteLog and "PandoraLogic.OnPandoraPakReady actId: " .. actId)
  PandoraLogic.SetActPakReady(actId, true)
end
function PandoraLogic.OnPandoraPanelClose(actId)
  log(bWriteLog and "PandoraLogic.OnPandoraPanelClose")
  if actId == nil then
    return
  end
  local ui_navigation_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ui_navigation_manager)
  ui_navigation_manager:PandoraUIPop(actId)
  log(bWriteLog and "PandoraLogic.OnPandoraPanelClose actId: " .. actId)
  local act_id = tonumber(actId)
  if PandoraActId_Module[act_id] ~= nil then
    local m = require(PandoraActId_Module[act_id])
    if m and m.Close then
      m.Close()
    end
  end
end
function PandoraLogic.SetActReady(actId, isReady)
  log(bWriteLog and "PandoraLogic.SetActReady, actId: " .. actId .. ",isReady: " .. tostring(isReady))
  PandoraLogic.ActReadyStateList[tonumber(actId)] = isReady
  PandoraLogic.BatchNotifyReadyList[tonumber(actId)] = isReady
  local BatchHelper = require("client.logic.Batch.BatchHelper")
  BatchHelper.DoOnce(BatchKey_PandoraReady, 1, PandoraLogic.ProcessBatchPandoraReady)
end
function PandoraLogic.ActIsReady(actId)
  local bIsReady = PandoraLogic.ActReadyStateList[tonumber(actId)] or false
  log(bWriteLog and string.format("PandoraLogic.ActIsReady? actId=%s, isReady=%s!", tostring(actId), tostring(bIsReady)))
  return bIsReady
end
function PandoraLogic.SetActPakReady(actId, isReady)
  log(bWriteLog and "PandoraLogic.SetActPakReady, actId: " .. actId .. ",isReady: " .. tostring(isReady))
  PandoraLogic.ActPakReadyStateList[tonumber(actId)] = isReady
end
function PandoraLogic.ActPakIsReady(actId)
  local bIsReady = PandoraLogic.ActPakReadyStateList[tonumber(actId)] or false
  log(bWriteLog and string.format("PandoraLogic.ActPakIsReady? actId=%s, isReady=%s!", tostring(actId), tostring(bIsReady)))
  return bIsReady
end
function PandoraLogic.ActIsAllReady(actId)
  return PandoraLogic.ActIsReady(actId) and PandoraLogic.ActPakIsReady(actId)
end
function PandoraLogic.ProcessBatchPandoraReady()
  local readyMap = {}
  local NeedPostReady = false
  for actId, isReady in pairs(PandoraLogic.BatchNotifyReadyList) do
    if isReady and PandoraLogic.ActIsReady(actId) then
      NeedPostReady = true
      readyMap[actId] = true
    end
  end
  if NeedPostReady then
    log_tree("ProcessBatchPandoraReady readyMap = ", readyMap)
    EventSystem:postEvent(EVENTTYPE_PANDORA, EVENTID_PANDORA_ALL_READY_BATCH_NOTIFY, readyMap)
  end
  PandoraLogic.BatchNotifyReadyList = {}
end
function PandoraLogic.SetActRedPoint(actId, redDotType)
  if not actId then
    return
  end
  local Logic_Activity_Center = require("client.slua.logic.activity.logic_activity_center")
  if Logic_Activity_Center.IsHostedActAllDone(actId) then
    redDotType = 0
    log(bWriteLog and "PandoraLogic.SetActRedPoint - Blocked red dot for all-done actId:" .. tostring(actId))
  end
  redDotType = tonumber(redDotType) or 0
  log(bWriteLog and "PandoraLogic.SetActRedPoint, actId: " .. actId .. ", redDotType: " .. tostring(redDotType))
  actId = tonumber(actId)
  PandoraLogic.ActRedPointStateList[actId] = redDotType
  PandoraLogic.redIdTb[actId] = 1
  PandoraLogic.BeginRefreshRedPoint()
end
function PandoraLogic.BeginRefreshRedPoint(id)
  if id then
    id = tonumber(id)
    PandoraLogic.redIdTb[id] = 1
  end
  local BatchHelper = require("client.logic.Batch.BatchHelper")
  BatchHelper.DoOnce(BatchKey_PandoraRedPoint, 1, PandoraLogic.BatchRefreshActRedPoint)
end
function PandoraLogic.BatchRefreshActRedPoint()
  local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  PandoraLogic.UpdateRedPoint()
  local changeList = {
    idList = {},
    typeList = {}
  }
  local idList = changeList.idList
  for id, _ in pairs(PandoraLogic.redIdTb) do
    if PandoraLogic.ActPakIsReady(id) and PandoraLogic.ActIsReady(id) then
      id = pandoraSystem.pandora2Id[id]
      if id then
        idList[id] = true
        local LogicMultiBannerActRed = require("client.slua.logic.activity.LogicMultiBannerActRed")
        local success, bindMap = LogicMultiBannerActRed.GetBindActId(id)
        if success then
          idList = TableUtil.MergeTable(idList, bindMap)
        end
      end
    end
  end
  if next(idList) then
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changeList)
  end
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_PANDORA_UPDATE_RED_POINT)
  PandoraLogic.redIdTb = {}
end
function PandoraLogic.ActHasRedPoint(actId)
  local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
  local redDotType = PandoraLogic.ActRedPointStateList[tonumber(actId)] and PandoraLogic.ActRedPointStateList[tonumber(actId)] or ActivityMacros.RedDotType.None
  log(bWriteLog and "PandoraLogic.ActHasRedPoint, actId: " .. actId .. " ,redDotType: " .. tostring(redDotType))
  if not PandoraLogic.ActPakIsReady(actId) or not PandoraLogic.ActIsReady(actId) then
    return false
  end
  return redDotType ~= ActivityMacros.RedDotType.None
end
function PandoraLogic.GetRedDotType(actId)
  local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
  local redDotType = PandoraLogic.ActRedPointStateList[tonumber(actId)] and PandoraLogic.ActRedPointStateList[tonumber(actId)] or ActivityMacros.RedDotType.None
  log(bWriteLog and "PandoraLogic.ActHasRedPoint, actId: " .. actId .. " ,redDotType: " .. tostring(redDotType))
  if not PandoraLogic.ActPakIsReady(actId) or not PandoraLogic.ActIsReady(actId) then
    return ActivityMacros.RedDotType.None
  end
  return redDotType
end
function PandoraLogic.UpdateRedPoint()
  log(bWriteLog and "PandoraLogic.UpdateRedPoint")
  for k, v in pairs(PandoraLogic.ActRedPointStateList) do
    LobbySystem.LobbyRedPointUpdate(k, v == 1)
  end
end
function PandoraLogic.SetCurActId(id)
  PandoraLogic.CurActId = id
end
function PandoraLogic.GetCurActId()
  return PandoraLogic.CurActId
end
function PandoraLogic.HideCurAct()
  if PandoraLogic.CurActId ~= 0 then
    EventSystem:postEvent(EVENTTYPE_PANDORA, EVENTID_PANDORA_HIDE_CUR_ACT, PandoraLogic.CurActId)
  end
end
function PandoraLogic.CloseCurAct(actId)
  local pandora_common_protocol = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.pandora_common_protocol)
  pandora_common_protocol:SendHide(actId)
  local ui_navigation_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ui_navigation_manager)
  ui_navigation_manager:PandoraUIPop(actId)
end
return PandoraLogic