local lua_common_title_uibp = {}
function lua_common_title_uibp:OnClose()
  self._childUI = nil
end
function lua_common_title_uibp:_CreateItem()
  if self._childUI then
    return
  end
  self._childUI = self:CreateChildWindow(self.CanvasPanelRoot, UIManager.UI_Config.Common_Title_UIBP)
end
function lua_common_title_uibp:SetAliasInfo(AliasID, Title, Nation, AvailableLen, RankID)
  log(bWriteLog and string.format("lua_common_title_uibp:SetAliasInfo. AliasID=%s, Title=%s, Nation=%s, AvailableLen=%s, RankID=%s", tostring(AliasID), tostring(Title), tostring(Nation), tostring(AvailableLen), tostring(RankID)))
  if not AliasID then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  if not Title or Title == "" then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:_CreateItem()
  self._childUI:SetAliasInfo(AliasID, Title, Nation, AvailableLen, RankID)
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, lua_common_title_uibp)