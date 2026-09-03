local RankSmall_Name_Star_UIBP = {}
function RankSmall_Name_Star_UIBP:ctor()
end
function RankSmall_Name_Star_UIBP:OnInitialize()
  RankSmall_Name_Star_UIBP.__super.OnInitialize(self)
end
function RankSmall_Name_Star_UIBP:OnPostInitialize()
  RankSmall_Name_Star_UIBP.__super.OnPostInitialize(self)
end
function RankSmall_Name_Star_UIBP:OnClose()
  RankSmall_Name_Star_UIBP.__super.OnClose(self)
end
function RankSmall_Name_Star_UIBP:SetSpecifiedStarNumText(starNum)
  log(bWriteLog and "RankSmall_Name_Star_UIBP:SetSpecifiedStarNumText starNum = " .. tostring(starNum))
  self.UIRoot.TextBlock_Star:SetText(starNum)
end
local class = require("class")
local RankSmall_Sub_Base_UIBP = require("client.slua.umg.rankIntegral.RankSmall_Sub_Base_UIBP")
local CRankSmall_Name_Star_UIBP = class(RankSmall_Sub_Base_UIBP, nil, RankSmall_Name_Star_UIBP)
return CRankSmall_Name_Star_UIBP