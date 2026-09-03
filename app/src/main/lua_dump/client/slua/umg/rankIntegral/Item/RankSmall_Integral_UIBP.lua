local RankSmall_Integral_UIBP = {}
function RankSmall_Integral_UIBP:ctor()
end
function RankSmall_Integral_UIBP:OnInitialize()
  RankSmall_Integral_UIBP.__super.OnInitialize(self)
end
function RankSmall_Integral_UIBP:OnPostInitialize()
  RankSmall_Integral_UIBP.__super.OnPostInitialize(self)
end
function RankSmall_Integral_UIBP:OnClose()
  RankSmall_Integral_UIBP.__super.OnClose(self)
end
local class = require("class")
local RankSmall_Sub_Base_UIBP = require("client.slua.umg.rankIntegral.RankSmall_Sub_Base_UIBP")
local CRankSmall_Integral_UIBP = class(RankSmall_Sub_Base_UIBP, nil, RankSmall_Integral_UIBP)
return CRankSmall_Integral_UIBP