local lua_common_title_base = {}
function lua_common_title_base:GetParentPanel()
  return self.DynamicIcon_Root
end
function lua_common_title_base:FinishedProduct(AliasID, bpPatch, title)
  log(bWriteLog and string.format("lua_common_title_base:FinishedProduct. bpPatch=%s, title=%s", tostring(bpPatch), tostring(title)))
  self._ccacheBPPatch = bpPatch
  self._ccacheTitle = title
  if self._childUI then
    self._childUI:Close()
    self._childUI = nil
  end
  local parentPanel = self:GetParentPanel()
  parentPanel:ClearChildren()
  self.icon_nation:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  parentPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self._childUI = self:CreateChildWindowWithBpPath(parentPanel, UIManager.UI_Config.Lobby_RoleInfo_EffectSkin_Item_UIBP, bpPatch)
  self._childUI.UIRoot.title:SetText(title)
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, lua_common_title_base)