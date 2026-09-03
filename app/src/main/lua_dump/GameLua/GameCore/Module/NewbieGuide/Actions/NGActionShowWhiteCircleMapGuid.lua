local NGActionShowWhiteCircleMapGuid = {}
function NGActionShowWhiteCircleMapGuid:ctor(selfType, Params)
  self.uMarkAction = nil
  self.LastWhiteCirleIndex = -1
  self.RuningCircleEventID = EventSystem:registEventWithConditions(EVENTTYPE_INGAME, EVENTID_INGAME_SYNC_CIRCILE_INFO, {
    [1] = 2
  }, function()
    self.LastWhiteCirleIndex = -1
  end)
end
function NGActionShowWhiteCircleMapGuid:RunAction(InGuideID)
  NGActionShowWhiteCircleMapGuid.__super.RunAction(self, InGuideID)
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) then
    if self.LastWhiteCirleIndex == uGameState.CurCircleWave then
      return false
    end
    self.LastWhiteCirleIndex = uGameState.CurCircleWave
    local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
    if self.uMarkAction == nil then
      self.uMarkAction = InGameMarkTools.ClientAddMapMark(44, uGameState.WhiteCircle, 1)
    else
      InGameMarkTools.ShowMapMark(self.uMarkAction)
      InGameMarkTools.UpdateMapMarkLocation(self.uMarkAction, FVector(uGameState.WhiteCircle.X, uGameState.WhiteCircle.Y, 0))
    end
  end
  return true
end
function NGActionShowWhiteCircleMapGuid:EndAction()
  NGActionShowWhiteCircleMapGuid.__super.EndAction(self)
  if self.uMarkAction ~= nil then
    local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
    InGameMarkTools.HideMapMark(self.uMarkAction)
  end
end
function NGActionShowWhiteCircleMapGuid:Clear()
  NGActionShowWhiteCircleMapGuid.__super.Clear(self)
  EventSystem:UnregistEventByID(self.RuningCircleEventID)
  self:EndAction()
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNGActionShowWhiteCircleMapGuid = class(CObject, nil, NGActionShowWhiteCircleMapGuid)
return CNGActionShowWhiteCircleMapGuid