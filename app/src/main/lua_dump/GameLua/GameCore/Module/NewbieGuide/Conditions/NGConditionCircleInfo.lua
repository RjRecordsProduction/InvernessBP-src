local ECircleState = {
  SafeZoneTips = 0,
  BlueCirclePreWarning = 1,
  BlueCircleRun = 2,
  NoCircleInfo = 3
}
local NewbieGuideConditionBlueCircle = {}
function NewbieGuideConditionBlueCircle:ctor(selfType, Params)
  self.NeedCircleStat = Params.LegalCircleStat or {}
  self.MinBlueCircleIndex = Params.MinBlueCircleIndex or 0
  self.MaxBlueCircleIndex = Params.MaxBlueCircleIndex or 100
end
function NewbieGuideConditionBlueCircle:CheckConditionOK(...)
  log(bWriteLog and "Debug NewbieGuide: NewbieGuideConditionBlueCircle CheckConditionOK, MinINdex:" .. self.MinBlueCircleIndex .. " MaxIndex:" .. self.MaxBlueCircleIndex)
  local bSuperOk = NewbieGuideConditionBlueCircle.__super.CheckConditionOK(self, ...)
  if not bSuperOk then
    return false
  end
  local uGamestate = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(uGamestate) then
    return false
  end
  local CurrentCircleStat = uGamestate:GetCurCircleState()
  if CurrentCircleStat == nil then
    return false
  end
  local TableUtil = require("common.table_util")
  local bFindStatus = TableUtil.Find(self.NeedCircleStat, CurrentCircleStat)
  if bFindStatus < 0 then
    return false
  end
  local CurrentCirlceIndex = uGamestate:GetCurCircleIndex()
  if CurrentCirlceIndex and CurrentCirlceIndex >= self.MinBlueCircleIndex and CurrentCirlceIndex <= self.MaxBlueCircleIndex then
    log(bWriteLog and "Debug NewbieGuide: NewbieGuideConditionBlueCircle CheckConditionOK: true")
    return true
  end
  return false
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNewbieGuideConditionBlueCircle = class(CObject, nil, NewbieGuideConditionBlueCircle)
return CNewbieGuideConditionBlueCircle