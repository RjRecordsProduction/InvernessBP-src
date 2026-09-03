local QuickSignItemMarkUI = {}
function QuickSignItemMarkUI:ShowSelf(Loc, bOldStyle, IsSelfMark, IconPath, BGPath, IconOutPath, BGOutPath, ArrowPath)
  if self.bOldStyle ~= bOldStyle then
    self:SetStyle(bOldStyle)
  end
  self:SetWorldPos(Loc)
  self.  if IconPath ~= "" then
    self.Image_Icon_Inner:SetBrushfromPathAsync(IconPath, false)
    self.Image_Icon_Inner:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  if BGPath ~= "" then
    self.Image_BG_Inner:SetBrushfromPathAsync(BGPath, false)
    self.Image_BG_Inner:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  if IconOutPath ~= "" then
    self.Image_Icon_Outer:SetBrushfromPathAsync(IconOutPath, false)
    self.Image_Icon_Outer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  if BGOutPath ~= "" then
    self.Image_BG_Outer:SetBrushfromPathAsync(BGOutPath, false)
    self.Image_BG_Outer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  self.Image_arrow:SetBrushfromPathAsync(ArrowPath, false)
  self.Image_Effect:SetBrushfromPathAsync(BGPath, false)
  self.BgPath = BGPath
  self:AfterShow(bOldStyle)
end
function QuickSignItemMarkUI:LuaOnCurrentShowTypeChange(CurType)
  if CurType == 1 then
    self.WidgetSwitcher_Content:SetActiveWidgetIndex(0)
    self:OnChangeOutScreenState(false)
  elseif CurType == 2 then
    self.WidgetSwitcher_Content:SetActiveWidgetIndex(1)
    self:OnChangeOutScreenState(true)
  end
end
local class = require("class")
local QuickSignMarkUI = require("GameLua.Mod.BaseMod.Client.QuickSignUI.QuickSignMarkUI")
return class(QuickSignMarkUI, nil, QuickSignItemMarkUI)