local NGActionShowEntireUI = {}
function NGActionShowEntireUI:ctor(selfType, Params)
  self.UIConfigName = Params.UIConfigName
end
function NGActionShowEntireUI:RunAction(InGuideID)
  NGActionShowEntireUI.__super.RunAction(self, InGuideID)
  log(bWriteLog and "Debug NewbieGuide: NGActionShowEntireUI RunAction")
  if UIManager and not UIManager.IsUIShow(UIManager.UI_Config_InGame[self.UIConfigName]) then
    UIManager.ShowUI(UIManager.UI_Config_InGame[self.UIConfigName])
  end
  return true
end
function NGActionShowEntireUI:EndAction()
  NGActionShowEntireUI.__super.EndAction(self)
  log(bWriteLog and "Debug NewbieGuide: NGActionShowEntireUI EndAction")
  if UIManager and UIManager.UI_Config_InGame[self.UIConfigName] and UIManager.GetUI(UIManager.UI_Config_InGame[self.UIConfigName]) then
    UIManager.HideUI(UIManager.UI_Config_InGame[self.UIConfigName])
  end
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNGActionShowEntireUI = class(CObject, nil, NGActionShowEntireUI)
return CNGActionShowEntireUI