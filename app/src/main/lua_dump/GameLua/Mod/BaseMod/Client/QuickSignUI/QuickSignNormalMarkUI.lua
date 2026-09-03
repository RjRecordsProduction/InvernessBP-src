local QuickSignNormalMarkUI = {}
function QuickSignNormalMarkUI:ShowSelf(Loc, bOldStyle, IsSelfMark, IconPath, BGPath, IconOutPath, BGOutPath, ArrowPath)
  if self.bOldStyle ~= bOldStyle then
    self:SetStyle(bOldStyle)
  end
  self:SetWorldPos(Loc)
  self.  if self.bIsOutScreen then
    if IconOutPath ~= "" then
      self.Image_Icon:SetBrushfromPathAsync(IconOutPath, false)
      self.Image_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    if BGOutPath ~= "" then
      self.Image_BG:SetBrushfromPathAsync(BGOutPath, false)
      self.Image_BG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    if IconPath ~= "" then
      self.Image_Icon:SetBrushfromPathAsync(IconPath, false)
      self.Image_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    if BGPath ~= "" then
      self.Image_BG:SetBrushfromPathAsync(BGPath, false)
      self.Image_BG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  self.Image_arrow:SetBrushfromPathAsync(ArrowPath, false)
  self.Image_Effect:SetBrushfromPathAsync(BGPath, false)
  self.  self.  self.  self.BgPath = BGPath
  self:AfterShow(bOldStyle)
end
function QuickSignNormalMarkUI:LuaOnCurrentShowTypeChange(CurType)
  if CurType == 1 then
    self:OnChangeOutScreenState(false)
    self.Image_BG.Slot:SetSize(self.InScreenBGSize)
    if self.BgPath then
      self.Image_BG:SetBrushfromPathAsync(self.BgPath, false)
    end
    if self.IconPath then
      self.Image_Icon:SetBrushfromPathAsync(self.IconPath, false)
    end
  elseif CurType == 2 then
    self:OnChangeOutScreenState(true)
    self.Image_BG.Slot:SetSize(self.OutScreenBGSize)
    if self.BGOutPath then
      self.Image_BG:SetBrushfromPathAsync(self.BGOutPath, false)
    end
    if self.IconOutPath then
      self.Image_Icon:SetBrushfromPathAsync(self.IconOutPath, false)
    end
  end
end
local class = require("class")
local QuickSignMarkUI = require("GameLua.Mod.BaseMod.Client.QuickSignUI.QuickSignMarkUI")
return class(QuickSignMarkUI, nil, QuickSignNormalMarkUI)