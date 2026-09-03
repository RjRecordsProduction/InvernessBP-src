local NGActionGuideMarkParacheCanOpen = {}
function NGActionGuideMarkParacheCanOpen:ctor(selfType, Params)
end
function NGActionGuideMarkParacheCanOpen:RunAction(InGuideID)
  NGActionGuideMarkParacheCanOpen.__super.RunAction(self, InGuideID)
  log(bWriteLog and "Debug NewbieGuide: NGActionGuideMarkParacheCanOpen RunAction")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    uPlayerCharacter.bGuideMarkParacheCanOpen = true
  end
  return true
end
function NGActionGuideMarkParacheCanOpen:EndAction()
  NGActionGuideMarkParacheCanOpen.__super.EndAction(self)
  log(bWriteLog and "Debug NewbieGuide: NGActionGuideMarkParacheCanOpen EndAction")
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNGActionGuideMarkParacheCanOpen = class(CObject, nil, NGActionGuideMarkParacheCanOpen)
return CNGActionGuideMarkParacheCanOpen