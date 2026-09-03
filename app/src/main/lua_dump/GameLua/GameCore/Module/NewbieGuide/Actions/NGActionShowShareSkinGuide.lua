local NGActionShowShareSkinGuide = {}
function NGActionShowShareSkinGuide:RunAction(InGuideID)
  NGActionShowShareSkinGuide.__super.RunAction(self, InGuideID)
  print(bWriteLog and string.format(" NGActionShowShareSkinGuide:RunAction InGuideID:%s", InGuideID))
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBase = InGameUITools.GetMainControlBaseUI()
  if slua.isValid(MainControlBase) then
    MainControlBase:ShowOrHideBackPackBtnTips(true, {
      Text1 = LocUtil.GetLocalizeResStr(47189)
    })
  end
  return true
end
function NGActionShowShareSkinGuide:EndAction()
  NGActionShowShareSkinGuide.__super.EndAction(self)
  print(bWriteLog and " NGActionShowShareSkinGuide:EndAction")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBase = InGameUITools.GetMainControlBaseUI()
  if slua.isValid(MainControlBase) then
    MainControlBase:ShowOrHideBackPackBtnTips(false)
  end
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNGActionShowShareSkinGuide = class(CObject, nil, NGActionShowShareSkinGuide)
return CNGActionShowShareSkinGuide