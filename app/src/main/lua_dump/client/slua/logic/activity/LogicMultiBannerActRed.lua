local LogicMultiBannerActRed = {}
local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
local StringUtil = require("common.string_util")
local JumpUtils = require("client.logic.store.jump_utils")
local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
function LogicMultiBannerActRed.HasAllSubBannerRed(actData, actId)
  local Red = false
  local RedDotType = ActivityMacros.RedDotType.None
  if not actId then
    log(bWriteLog and string.format("LogicMultiBannerActRed.HasAllSubBannerRed. actId:%s isn't valid", tostring(actId)))
    return Red, RedDotType
  end
  if not actData then
    actData = ActivityNewSystem.GetActivityByID(actId)
    if not actData then
      log(bWriteLog and string.format("LogicMultiBannerActRed.HasAllSubBannerRed. no data actId=%s", tostring(actId)))
      return Red, RedDotType
    end
  end
  for _, subAct in ipairs(actData.List) do
    Red, RedDotType = LogicMultiBannerActRed.HasSubBannerRed(subAct.ID, subAct)
    if Red then
      return Red, RedDotType
    end
  end
  return Red, RedDotType
end
function LogicMultiBannerActRed.HasSubBannerRed(actId, subAct)
  local SubBannerNewRed = LogicMultiBannerActRed.HasSubBannerNewRed(actId, subAct)
  log(bWriteLog and string.format("LogicMultiBannerActRed.HasSubBannerRed. actId=%s, SubBannerNewRed=%s", tostring(actId), tostring(SubBannerNewRed)))
  if SubBannerNewRed then
    return true, ActivityMacros.RedDotType.New
  end
  local SubBannerPandoraRed = LogicMultiBannerActRed.HasSubBannerPandoraRed(actId, subAct)
  log(bWriteLog and string.format("LogicMultiBannerActRed.HasSubBannerRed. actId=%s, SubBannerPandoraRed=%s", tostring(actId), tostring(SubBannerPandoraRed)))
  if SubBannerPandoraRed then
    return true, ActivityMacros.RedDotType.Normal
  end
  return false, ActivityMacros.RedDotType.None
end
function LogicMultiBannerActRed.HasSubBannerNewRed(actId, subAct)
  local subActId = subAct.ID
  if not (actId and actId ~= 0 and subActId) or subActId == 0 then
    return false
  end
  local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
  return ActivityRedDot.CheckNewRedDot(subActId)
end
local PandoraBindCache = {}
function LogicMultiBannerActRed.HasSubBannerPandoraRed(actId, subAct)
  if not (actId and actId ~= 0 and subAct and subAct.ID) or subAct.ID == 0 then
    log(bWriteLog and "LogicMultiBannerActRed.HasSubBannerPandoraRed. actId or subAct isn't valid!")
    return false
  end
  local JumpUrl = subAct.ImgLink
  if not JumpUrl or JumpUrl == "" then
    log(bWriteLog and "LogicMultiBannerActRed.HasSubBannerPandoraRed. JumpUrl isn't valid")
    return false
  end
  if not JumpUtils.IsPanDoraJumpUrl(JumpUrl) then
    log(bWriteLog and "LogicMultiBannerActRed.HasSubBannerPandoraRed. isn't pandora jump url")
    return false
  end
  local pandora_system = require("client.slua.logic.Pandora.pandora_system")
  local params = StringUtil.ParseURLParams(JumpUrl)
  local pandoraId = tonumber(params.actid)
  local targetActId = pandora_system.pandora2Id[pandoraId]
  log(bWriteLog and string.format("LogicMultiBannerActRed.HasSubBannerPandoraRed. targetActId=%s, pandoraId=%s", tostring(targetActId), tostring(pandoraId)))
  if not targetActId or not pandoraId then
    return false
  end
  if not PandoraBindCache[targetActId] then
    PandoraBindCache[targetActId] = {}
  end
  PandoraBindCache[targetActId][actId] = 1
  return pandora_system.ActHasRedPoint(pandoraId, targetActId)
end
function LogicMultiBannerActRed.GetBindActId(actId)
  local result = {}
  local flag = false
  if not PandoraBindCache[actId] then
    return flag, result
  end
  local bindMap = PandoraBindCache[actId]
  for bindActId, _ in pairs(bindMap) do
    result[tonumber(bindActId)] = true
    flag = true
  end
  return flag, result
end
return LogicMultiBannerActRed