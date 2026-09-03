local NGActionShowClickShareSkinGuide = {}
function NGActionShowClickShareSkinGuide:RunAction(InGuideID)
  NGActionShowClickShareSkinGuide.__super.RunAction(self, InGuideID)
  print(bWriteLog and string.format(" NGActionShowClickShareSkinGuide:RunAction InGuideID:%s", InGuideID))
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBase = InGameUITools.GetMainControlBaseUI()
  if slua.isValid(MainControlBase) then
    MainControlBase:ShowOrHideBackPackBtnTips(true, {
      Text1 = LocUtil.GetLocalizeResStr(83145)
    })
  end
  return true
end
function NGActionShowClickShareSkinGuide:EndAction()
  NGActionShowClickShareSkinGuide.__super.EndAction(self)
  print(bWriteLog and " NGActionShowClickShareSkinGuide:EndAction")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBase = InGameUITools.GetMainControlBaseUI()
  if slua.isValid(MainControlBase) then
    MainControlBase:ShowOrHideBackPackBtnTips(false)
  end
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNGActionShowClickShareSkinGuide = class(CObject, nil, NGActionShowClickShareSkinGuide)
return CNGActionShowClickShareSkinGuide