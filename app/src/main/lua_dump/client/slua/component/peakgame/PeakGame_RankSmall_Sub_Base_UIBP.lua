local PeakGame_RankSmall_Sub_Base_UIBP = {}
function PeakGame_RankSmall_Sub_Base_UIBP:ctor(_, RankTextColor, RankTextShadowColor, RankFontInfo)
  self.  self.  self.end
function PeakGame_RankSmall_Sub_Base_UIBP:OnInitialize()
end
function PeakGame_RankSmall_Sub_Base_UIBP:OnPostInitialize()
end
function PeakGame_RankSmall_Sub_Base_UIBP:OnClose()
end
function PeakGame_RankSmall_Sub_Base_UIBP:SetRankTextPrefix(prefixStr)
end
function PeakGame_RankSmall_Sub_Base_UIBP:SetPeakRankIntegral(peakSegment)
  log(bWriteLog and "PeakGame_RankSmall_Sub_Base_UIBP:SetPeakRankIntegral peakSegment = " .. tostring(peakSegment))
  self.end
function PeakGame_RankSmall_Sub_Base_UIBP:SetPeakRankCustomColor(peakSegment, textColor)
  log(bWriteLog and "PeakGame_RankSmall_Sub_Base_UIBP:SetPeakRankCustomColor")
  if not peakSegment then
    log(bWriteLog and "PeakGame_RankSmall_Sub_Base_UIBP:SetPeakRankCustomColor no segment or no subui")
    return
  end
  if not textColor then
    log(bWriteLog and "PeakGame_RankSmall_Sub_Base_UIBP:SetPeakRankCustomColor  no color")
    return
  end
  self.RankTextColor = textColor
  self:SetPeakRankIntegral(peakSegment)
end
function PeakGame_RankSmall_Sub_Base_UIBP:PlaySegmentStarAnim()
end
function PeakGame_RankSmall_Sub_Base_UIBP:SetRankStarShow(segmentCfg)
  if not segmentCfg then
    log(bWriteLog and "PeakGame_RankSmall_Sub_Base_UIBP:SetRankStarShow no param")
    return
  end
  local segUpConfig = CDataTable.GetTableData("PeakGameBigSegUpConfig", segmentCfg.IntegralType)
  if not (segUpConfig and segUpConfig.SegStarIconPath) or segUpConfig.SegStarIconPath == "" then
    log(bWriteLog and "PeakGame_RankSmall_Sub_Base_UIBP:SetRankStarShow no star to show")
    return
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Star, true)
  self.UIRoot.TextBlock_Star:SetText(segmentCfg.StarNum)
  self:SetTexture(self.UIRoot.Image_Star, segUpConfig.SegStarIconPath, {sync = false})
  self:SetRankFontStyle(self.UIRoot.TextBlock_Star)
end
function PeakGame_RankSmall_Sub_Base_UIBP:SetRankFontStyle(textWidget)
  if self.RankTextColor then
    textWidget:SetColorAndOpacity(self.RankTextColor)
  end
  if self.RankTextShadowColor and self.RankTextShadowColor.SpecifiedColor then
    textWidget:SetShadowColorAndOpacity(self.RankTextShadowColor.SpecifiedColor)
  end
  if self.RankFontInfo then
    textWidget:SetFont(self.RankFontInfo)
  end
end
function PeakGame_RankSmall_Sub_Base_UIBP:SafeSetRankNameVisible(bVisible)
  if not self.UIRoot.TextBlock_Rank then
    return
  end
  self:SetWidgetVisible(self.UIRoot.TextBlock_Rank, bVisible)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CPeakGame_RankSmall_Sub_Base_UIBP = class(ui_base, nil, PeakGame_RankSmall_Sub_Base_UIBP)
return CPeakGame_RankSmall_Sub_Base_UIBP