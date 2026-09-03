local NGConditionIsInGameStatus = {}
function NGConditionIsInGameStatus:ctor(selfType, Params)
  self.CheckGameStatusList = Params.LegalGameStat or {}
end
function NGConditionIsInGameStatus:CheckConditionOK(...)
  local bSuperOk = NGConditionIsInGameStatus.__super.CheckConditionOK(self, ...)
  if not bSuperOk then
    return false
  end
  local uGamestate = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(uGamestate) then
    return false
  end
  local CurGameState = uGamestate:GetGameModeState()
  log(bWriteLog and "Debug NewbieGuide: NGConditionIsInGameStatus CheckConditionOK " .. CurGameState)
  local TableUtil = require("common.table_util")
  local FindRes = TableUtil.Find(self.CheckGameStatusList, CurGameState)
  return FindRes ~= -1
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionIsInGameStatus = class(CObject, nil, NGConditionIsInGameStatus)
return CNGConditionIsInGameStatus