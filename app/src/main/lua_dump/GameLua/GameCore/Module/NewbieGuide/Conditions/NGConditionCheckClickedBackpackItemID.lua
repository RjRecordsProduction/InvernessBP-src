local NGConditionCheckClickedBackpackItemID = {}
function NGConditionCheckClickedBackpackItemID:ctor(selfType, Params)
  self.CheckItemID = Params.CheckItemID or 0
  self.IsNot = Params.IsNot or false
end
function NGConditionCheckClickedBackpackItemID:CheckConditionOK(...)
  log(bWriteLog and "NGConditionCheckClickedBackpackItemID:CheckConditionOK [1]")
  local bSuperOk = NGConditionCheckClickedBackpackItemID.__super.CheckConditionOK(self, ...)
  if not bSuperOk then
    return false
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local BackPackPanelUI = InGameUITools.GetBackpackUI()
  if not BackPackPanelUI then
    log(bWriteLog and "NGConditionCheckClickedBackpackItemID:CheckConditionOK [2]")
    return false
  end
  local CurrentSelectedItem = BackPackPanelUI.CrtClickItem
  if not CurrentSelectedItem then
    log(bWriteLog and "NGConditionCheckClickedBackpackItemID:CheckConditionOK [3]")
    return false
  end
  if not CurrentSelectedItem.ItemData or not CurrentSelectedItem.ItemData.DefineID then
    log(bWriteLog and "NGConditionCheckClickedBackpackItemID:CheckConditionOK [4]")
    return false
  end
  local SelectedItemID = CurrentSelectedItem.ItemData.DefineID.TypeSpecificID
  local bMatched = SelectedItemID == self.CheckItemID
  if self.IsNot then
    bMatched = not bMatched
  end
  log(bWriteLog and "NGConditionCheckClickedBackpackItemID:CheckConditionOK [5] Condition result:" .. tostring(bMatched))
  return bMatched
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionCheckClickedBackpackItemID = class(CObject, nil, NGConditionCheckClickedBackpackItemID)
return CNGConditionCheckClickedBackpackItemID