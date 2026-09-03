local collect_rank_total_module = {}
function collect_rank_total_module:CustomizeDerivedConfig()
  if GlobalData.IsJapanOrKorea() then
    self.rankID = 73007
  else
    self.rankID = 73005
  end
  self.userRankMark = "CollectTotalPersonRank"
  self.profileScene = Enum_PROFILE_REPORT_CFG.COLLECT_RANK_TOT
end
local class = require("class")
local collect_rank_module = require("GameLua.Mod.Lobby.Base.Collect.logic.rank.collect_rank_module_base")
local CModuleTemplate = class(collect_rank_module, nil, collect_rank_total_module)
return CModuleTemplate