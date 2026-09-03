local NGActionBackPackGuide = {}
function NGActionBackPackGuide:RunAction(InGuideID, TextID)
  NGActionBackPackGuide.__super.RunAction(self, InGuideID)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBase = InGameUITools.GetMainControlBaseUI()
  if slua.isValid(MainControlBase) and TextID then
    print(bWriteLog and "[spike] NGActionBackPackGuide:RunAction InGuideID:", InGuideID)
    MainControlBase:ShowOrHideBackPackBtnTips(true, {
      Text1 = LocUtil.GetLocalizeResStr(TextID)
    })
  end
  return true
end
function NGActionBackPackGuide:EndAction()
  NGActionBackPackGuide.__super.EndAction(self)
  print(bWriteLog and "[spike] NGActionBackPackGuide:EndAction")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBase = InGameUITools.GetMainControlBaseUI()
  if slua.isValid(MainControlBase) then
    MainControlBase:ShowOrHideBackPackBtnTips(false)
  end
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNGActionBackPackGuide = class(CObject, nil, NGActionBackPackGuide)
return CNGActionBackPackGuide