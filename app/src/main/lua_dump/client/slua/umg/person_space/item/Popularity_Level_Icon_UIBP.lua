local Popularity_Level_Icon_UIBP = {}
function Popularity_Level_Icon_UIBP.GetPopularityLevelTexture(level)
  log(bWriteLog and "Popularity_Level_Icon_UIBP.GetPopularityLevelTexture level = " .. tostring(level))
  local GiftIconColor = CDataTable.GetTable("GiftIconColor")
  local info = GiftIconColor[level]
  if not info then
    log(bWriteLog and "Popularity_Level_Icon_UIBP:GetPopularityLevelTexture invalid level")
  end
  return GiftIconColor[level].RangeRoundIcon
end
function Popularity_Level_Icon_UIBP:SetData(level)
  log(bWriteLog and "Popularity_Level_Icon_UIBP:SetData level = " .. tostring(level))
  if not level or level < 0 then
    log(bWriteLog and "Popularity_Level_Icon_UIBP:SetData invalid params")
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local switchID = FuncUtil.Clamp(level, 0, 7)
  self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.WidgetSwitcher_0:SetActiveWidgetIndex(switchID)
  self["TextBlock_" .. tostring(switchID)]:SetText("Lv." .. tostring(level))
  local util = require("client.slua_ui_framework.util")
  util.SetTexture(self["Image_" .. tostring(switchID)], Popularity_Level_Icon_UIBP.GetPopularityLevelTexture(level))
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, Popularity_Level_Icon_UIBP)