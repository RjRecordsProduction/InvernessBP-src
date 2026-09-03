local PeakGame_RankSmall_Integral_UIBP = {}
function PeakGame_RankSmall_Integral_UIBP:ctor(_, RankTextColor, RankTextShadowColor, RankFontInfo)
  self.  self.  self.end
function PeakGame_RankSmall_Integral_UIBP:OnInitialize()
  PeakGame_RankSmall_Integral_UIBP.__super.OnInitialize(self)
end
function PeakGame_RankSmall_Integral_UIBP:OnPostInitialize()
  PeakGame_RankSmall_Integral_UIBP.__super.OnPostInitialize(self)
end
function PeakGame_RankSmall_Integral_UIBP:OnClose()
  PeakGame_RankSmall_Integral_UIBP.__super.OnClose(self)
end
function PeakGame_RankSmall_Integral_UIBP:SetPeakRankIntegral(peakSegment)
  log(bWriteLog and "PeakGame_RankSmall_Integral_UIBP:SetPeakRankIntegral peakSegment = " .. tostring(peakSegment))
  if not peakSegment then
    log(bWriteLog and "PeakGame_RankSmall_Integral_UIBP:SetPeakRankIntegral no segment or no subui")
    return
  end
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local segmentCfg = LogicPeakGameUtil.GetPeakRankTableData(peakSegment)
  if not segmentCfg then
    log(bWriteLog and "PeakGame_RankSmall_Integral_UIBP:SetPeakRankIntegral no segmentCfg")
    return
  end
  self:SetTexture(self.UIRoot.Image_Icon, segmentCfg.SmallIcon, {sync = false})
end
local class = require("class")
local PeakGame_RankSmall_Sub_Base_UIBP = require("client.slua.component.peakgame.PeakGame_RankSmall_Sub_Base_UIBP")
local CPeakGame_RankSmall_Integral_UIBP = class(PeakGame_RankSmall_Sub_Base_UIBP, nil, PeakGame_RankSmall_Integral_UIBP)
return CPeakGame_RankSmall_Integral_UIBP