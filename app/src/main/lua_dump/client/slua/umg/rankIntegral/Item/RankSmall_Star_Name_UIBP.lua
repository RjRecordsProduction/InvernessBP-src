local RankSmall_Star_Name_UIBP = {}
local logic_rank_component = require("client.slua.umg.rankIntegral.logic.logic_rank_component")
function RankSmall_Star_Name_UIBP:ctor()
end
function RankSmall_Star_Name_UIBP:OnInitialize()
  RankSmall_Star_Name_UIBP.__super.OnInitialize(self)
end
function RankSmall_Star_Name_UIBP:OnPostInitialize()
  RankSmall_Star_Name_UIBP.__super.OnPostInitialize(self)
end
function RankSmall_Star_Name_UIBP:OnClose()
  RankSmall_Star_Name_UIBP.__super.OnClose(self)
end
function RankSmall_Star_Name_UIBP:SetSpecifiedStarNumText(starNum)
  log(bWriteLog and "RankSmall_Star_Name_UIBP:SetSpecifiedStarNumText starNum = " .. tostring(starNum))
  self.UIRoot.TextBlock_Star:SetText(starNum)
end
function RankSmall_Star_Name_UIBP:PlayResultUIStarAnim()
  if not logic_rank_component.IsSegmentStarSwitchOpen() then
    log(bWriteLog and "RankSmall_Star_Name_UIBP:PlayResultUIStarAnim not open")
    return
  end
  log(bWriteLog and "RankSmall_Star_Name_UIBP:PlayResultUIStarAnim")
  self:PlayUserWidgetAnimation(self.UIRoot.fadein, 0, 1, 0, 1)
end
function RankSmall_Star_Name_UIBP:SetRankTextPrefix(prefixStr)
  prefixStr = prefixStr or ""
  local rankCfg = FuncUtil.GetRankTableData(self.rankIntegral, self.seasonId)
  local rankName = rankCfg and rankCfg.Name or ""
  self:SafeSetText(self.UIRoot.TextBlock_Rank, prefixStr .. rankName)
end
local class = require("class")
local RankSmall_Sub_Base_UIBP = require("client.slua.umg.rankIntegral.RankSmall_Sub_Base_UIBP")
local CRankSmall_Star_Name_UIBP = class(RankSmall_Sub_Base_UIBP, nil, RankSmall_Star_Name_UIBP)
return CRankSmall_Star_Name_UIBP