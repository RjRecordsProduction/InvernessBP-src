local PeakGame_RankSmall_Name_Star_UIBP = {}
function PeakGame_RankSmall_Name_Star_UIBP:ctor(_, RankTextColor, RankTextShadowColor, RankFontInfo)
  self.  self.  self.end
function PeakGame_RankSmall_Name_Star_UIBP:OnInitialize()
  PeakGame_RankSmall_Name_Star_UIBP.__super.OnInitialize(self)
end
function PeakGame_RankSmall_Name_Star_UIBP:OnPostInitialize()
  PeakGame_RankSmall_Name_Star_UIBP.__super.OnPostInitialize(self)
end
function PeakGame_RankSmall_Name_Star_UIBP:OnClose()
  PeakGame_RankSmall_Name_Star_UIBP.__super.OnClose(self)
end
function PeakGame_RankSmall_Name_Star_UIBP:SetPeakRankIntegral(peakSegment)
  log(bWriteLog and "PeakGame_RankSmall_Name_Star_UIBP:SetPeakRankIntegral peakSegment = " .. tostring(peakSegment))
  if not peakSegment then
    log(bWriteLog and "PeakGame_RankSmall_Name_Star_UIBP:SetPeakRankIntegral no segment or no subui")
    return
  end
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local segmentCfg = LogicPeakGameUtil.GetPeakRankTableData(peakSegment)
  if not segmentCfg then
    log(bWriteLog and "PeakGame_RankSmall_Name_Star_UIBP:SetPeakRankIntegral no segmentCfg")
    return
  end
  self.UIRoot.TextBlock_Rank:SetText(segmentCfg.Name)
  self:SetRankFontStyle(self.UIRoot.TextBlock_Rank)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Star, false, false)
  if segmentCfg.StarNum > 0 then
    self:SetRankStarShow(segmentCfg)
  end
end
local class = require("class")
local PeakGame_RankSmall_Sub_Base_UIBP = require("client.slua.component.peakgame.PeakGame_RankSmall_Sub_Base_UIBP")
local CPeakGame_RankSmall_Name_Star_UIBP = class(PeakGame_RankSmall_Sub_Base_UIBP, nil, PeakGame_RankSmall_Name_Star_UIBP)
return CPeakGame_RankSmall_Name_Star_UIBP