local PeakGame_RankIntegralLevel_Style_Small_UIBP = {}
function PeakGame_RankIntegralLevel_Style_Small_UIBP:ctor()
  self.subItemUIConfig = nil
  self.subItemUI = nil
  self.RankIntegralType = nil
  self.peakSegment = nil
end
function PeakGame_RankIntegralLevel_Style_Small_UIBP:OnInitialize()
  self.RankIntegralType = self.UIRoot.RankIntegralType
end
function PeakGame_RankIntegralLevel_Style_Small_UIBP:OnPostInitialize()
  self:SetSubItemPath()
  self:ConstructRankItem()
end
function PeakGame_RankIntegralLevel_Style_Small_UIBP:OnClose()
  self.subItemUI = nil
  self.subItemUIConfig = nil
end
function PeakGame_RankIntegralLevel_Style_Small_UIBP:SetPeakRankIntegral(peakSegment)
  log(bWriteLog and "PeakGame_RankIntegralLevel_Style_Small_UIBP:SetPeakRankIntegral")
  if not peakSegment or not self.subItemUI then
    log(bWriteLog and "PeakGame_RankIntegralLevel_Style_Small_UIBP:SetPeakRankIntegral no segment or no subui")
    self:Collapsed()
    return
  end
  self.  self:SelfHitTestInvisible()
  self.subItemUI:SetPeakRankIntegral(peakSegment)
end
function PeakGame_RankIntegralLevel_Style_Small_UIBP:SetPeakRankCustomColor(peakSegment, textColor)
  log(bWriteLog and "PeakGame_RankIntegralLevel_Style_Small_UIBP:SetPeakRankIntegral")
  self:Collapsed()
  if not peakSegment or not self.subItemUI then
    log(bWriteLog and "PeakGame_RankIntegralLevel_Style_Small_UIBP:SetPeakRankIntegral no segment or no subui")
    return
  end
  if not textColor then
    log(bWriteLog and "PeakGame_RankIntegralLevel_Style_Small_UIBP:SetPeakRankIntegral  no color")
    return
  end
  self.  self:SelfHitTestInvisible()
  self.subItemUI:SetPeakRankCustomColor(peakSegment, textColor)
end
function PeakGame_RankIntegralLevel_Style_Small_UIBP:PlaySegmentStarAnim()
  if not self.subItemUI then
    log(bWriteLog and "PeakGame_RankIntegralLevel_Style_Small_UIBP:PlaySegmentStarAnim subItemUI is invalid")
    return
  end
  self.subItemUI:PlaySegmentStarAnim()
end
function PeakGame_RankIntegralLevel_Style_Small_UIBP:SetRankTextPrefix(prefixStr)
  if not self.subItemUI then
    log(bWriteLog and "PeakGame_RankIntegralLevel_Style_Small_UIBP:SetRankTextPrefix subItemUI is invalid")
    return
  end
  self.subItemUI:SetRankTextPrefix(prefixStr)
end
function PeakGame_RankIntegralLevel_Style_Small_UIBP:ChangeRankInteralColor(color)
  log(bWriteLog and "PeakGame_RankIntegralLevel_Style_Small_UIBP:ChangeRankInteralColor")
  if not self.peakSegment then
    return
  end
  if color then
    self:SetPeakRankCustomColor(self.peakSegment, color)
  end
end
function PeakGame_RankIntegralLevel_Style_Small_UIBP:SetSubItemPath()
  if not self.RankIntegralType then
    log_warning(bWriteLog and "PeakGame_RankIntegralLevel_Style_Small_UIBP:SetSubItemPath no RankIntegralType")
    return
  end
  local PeakGame_RankIntegralLevel_Config = require("client.slua.component.peakgame.PeakGame_RankIntegralLevel_Config")
  local BPTypeToUIConfigMap = PeakGame_RankIntegralLevel_Config.BPTypeToUIConfigMap
  self.subItemUIConfig = BPTypeToUIConfigMap[self.RankIntegralType]
end
function PeakGame_RankIntegralLevel_Style_Small_UIBP:ConstructRankItem()
  if not self.subItemUIConfig then
    log_error("PeakGame_RankIntegralLevel_Style_Small_UIBP:ConstructRankItem no subItemUIConfig")
    return
  end
  self.subItemUI = self:CreateChildWindow("Root", self.subItemUIConfig, self.UIRoot.RankTextColor, self.UIRoot.RankTextShadowColor, self.UIRoot.RankFontInfo)
  self.subItemUI:SetAutoSize(true)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CPeakGame_RankIntegralLevel_Style_Small_UIBP = class(ui_base, nil, PeakGame_RankIntegralLevel_Style_Small_UIBP)
return CPeakGame_RankIntegralLevel_Style_Small_UIBP