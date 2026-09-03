local NGConditionNeedShowBackpackFoldTip = {}
function NGConditionNeedShowBackpackFoldTip:CheckConditionOK(...)
  local bSuperOk = NGConditionNeedShowBackpackFoldTip.__super.CheckConditionOK(self, ...)
  if not bSuperOk then
    return false
  end
  local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
  local IsTPlanMod = STExtraModLogicSwitchLibrary.IsEnableWeaponAttachmentBindToWeapon()
  if IsTPlanMod then
    print(bWriteLog and "NGConditionNeedShowBackpackFoldTip: IsTPlanMod = true, no guide")
    return false
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local BackpackUI = InGameUITools.GetBackpackUI()
  if BackpackUI and BackpackUI.BackPackItemListUI then
    if not BackpackUI.BackPackItemListUI.bIsExpand then
      print(bWriteLog and "NGConditionNeedShowBackpackFoldTip: BackpackUI.BackPackItemListUI.bIsExpand = false, no guide")
    end
    return BackpackUI.BackPackItemListUI.bIsExpand
  end
  return false
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionNeedShowBackpackFoldTip = class(CObject, nil, NGConditionNeedShowBackpackFoldTip)
return CNGConditionNeedShowBackpackFoldTip