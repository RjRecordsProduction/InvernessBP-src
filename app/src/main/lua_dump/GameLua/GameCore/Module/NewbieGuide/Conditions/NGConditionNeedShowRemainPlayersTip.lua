local NGConditionNeedShowRemainPlayersTip = {}
function NGConditionNeedShowRemainPlayersTip:ctor(selfType)
  self.MaxPlayerNum = 0
  self.GuideCount = 0
end
function NGConditionNeedShowRemainPlayersTip:CheckConditionOK(...)
  local bSuperOk = NGConditionNeedShowRemainPlayersTip.__super.CheckConditionOK(self, ...)
  if not bSuperOk then
    return false
  end
  local uGamestate = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(uGamestate) then
    return false
  end
  local uGameModeState = uGamestate:GetGameModeState()
  if self.MaxPlayerNum == 0 or uGamestate.AlivePlayerNum > self.MaxPlayerNum then
    log(bWriteLog and "Debug NewbieGuide: NGConditionNeedShowRemainPlayersTip Ready Max:" .. self.MaxPlayerNum)
    self.MaxPlayerNum = uGamestate.AlivePlayerNum
  elseif uGameModeState == "ReadyState" then
    log(bWriteLog and "Debug NewbieGuide: NGConditionNeedShowRemainPlayersTip Is ReadyState Max:" .. self.MaxPlayerNum)
    return false
  elseif self.MaxPlayerNum - uGamestate.AlivePlayerNum >= 20 * (self.GuideCount + 1) then
    log(bWriteLog and "Debug NewbieGuide: NGConditionNeedShowRemainPlayersTip Max:" .. self.MaxPlayerNum .. " Cur:" .. uGamestate.AlivePlayerNum)
    self.GuideCount = self.GuideCount + 1
    EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_SHOW_REMAIN_PLAYERNUM_UIEFFECT)
    return true
  end
  return false
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionNeedShowRemainPlayersTip = class(CObject, nil, NGConditionNeedShowRemainPlayersTip)
return CNGConditionNeedShowRemainPlayersTip