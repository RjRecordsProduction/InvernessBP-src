local NGActionShowGameGuideEntrance = {}
function NGActionShowGameGuideEntrance:ctor(selfType, Params)
end
function NGActionShowGameGuideEntrance:RunAction(InGuideID)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not slua.isValid(MainControlBaseUI) then
    return false
  end
  MainControlBaseUI.Button_GameGuide:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  return true
end
function NGActionShowGameGuideEntrance:EndAction()
  NGActionShowGameGuideEntrance.__super.EndAction(self)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not slua.isValid(MainControlBaseUI) then
    return false
  end
  MainControlBaseUI.Button_GameGuide:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNGActionShowGameGuideEntrance = class(CObject, nil, NGActionShowGameGuideEntrance)
return CNGActionShowGameGuideEntrance