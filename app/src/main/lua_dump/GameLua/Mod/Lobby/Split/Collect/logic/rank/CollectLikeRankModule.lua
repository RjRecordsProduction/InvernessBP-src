local CollectLikeRankModule = {}
function CollectLikeRankModule:DefineAndResetData()
  CollectLikeRankModule.__super.DefineAndResetData(self)
end
function CollectLikeRankModule:CustomizeDerivedConfig()
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local nRankId = RankConfig.ScoreType.collect_upvote_rating
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    nRankId = RankConfig.ScoreType.collect_upvote_rating_jpkr
  end
  self.rankID = nRankId
  self.userRankMark = "CollectLikeRank"
  self.profileScene = Enum_PROFILE_REPORT_CFG.COLLECT_LIKE_RANK
  self.rankAwardName = nil
end
function CollectLikeRankModule:ResetSelfRealScore(rank_info)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  rank_info.score = collect_module:GetLikeCount() or 0
end
local class = require("class")
local collect_rank_module = require("GameLua.Mod.Lobby.Base.Collect.logic.rank.collect_rank_module_base")
local CCollectLikeRankModule = class(collect_rank_module, nil, CollectLikeRankModule)
return CCollectLikeRankModule