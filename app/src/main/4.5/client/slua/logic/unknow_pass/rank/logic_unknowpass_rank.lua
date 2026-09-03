local RankConfig = require("client.slua.logic.rank.rank_config")
local RankSelectEnum = RankConfig.RankSelectEnum
local RegionEnum = RankConfig.RegionEnum
local UnknowPassRankSystem = {
  top_1w_score = 1,
  sSeasonName = "",
  sSeasonTime = "",
  sRankSelfBelow1wDisplay = "",
  tAliasInfo = {
    aliasId = 0,
    roleNation = "",
    quality = 0,
    pathUrl = "",
    title = "",
    rank_id = 0,
    dynamicTitlePath = ""
  }
}
function UnknowPassRankSystem.SwitchRankRegionData(bIsFriend)
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  RankDataMgr.SetRankRegionType(bIsFriend and RegionEnum.friend or RegionEnum.all)
  RankDataMgr.SetRankSelectType(RankSelectEnum.upass)
  local RankNetHandler = require("client.slua.logic.rank.rank_net_handler")
  RankNetHandler.ReqFetchRankData(1)
end
function UnknowPassRankSystem.GetUPassRankInfoSelf(tRankInfo)
  local TableUtil = require("common.table_util")
  local infoSelf = TableUtil.CopyTable(tRankInfo)
  infoSelf.vaild = true
  infoSelf.content3 = UnknowPassSystem.Data.base.acc_score
  infoSelf.is_buy = UnknowPassSystem.Data.base.is_buy
  infoSelf.keep_buy = UnknowPassSystem.GetKeeyBuy()
  infoSelf.cur_value = UnknowPassSystem.GetCurValue()
  infoSelf.upass_level = UnknowPassSystem.Level
  infoSelf.pass_type = UnknowPassSystem.PassType
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local region = RankDataMgr.GetRankRegionType()
  if region == RegionEnum.friend then
    UnknowPassRankSystem.sRankSelfBelow1wDisplay = RankDataMgr.GetRankInfoSelf().no
  else
    UnknowPassRankSystem.sRankSelfBelow1wDisplay = RankDataMgr.GetSelfBelow1wDisplay()
  end
  return infoSelf
end
function UnknowPassRankSystem.calcTopNPercentage(score, top_1w_score, rankNo)
  log(bWriteLog and "UnknowPassRankSystem.calc_topn_percentage:" .. tostring(score) .. "  1w:" .. tostring(top_1w_score) .. " no:" .. tostring(rankNo))
  if top_1w_score == nil or top_1w_score == 0 then
    return LocUtil.LocalizeResFormat(102127)
  end
  if 0 < rankNo and rankNo <= 10000 then
    return tostring(rankNo)
  end
  local middle_score = score / top_1w_score * 5 - 1
  local percentage = 1 - math.max(math.min((1 / (1 + math.exp(-0.65 * middle_score)) - 0.5) * 1.72 + 0.2585, 1), 0)
  log(bWriteLog and "UnknowPassRankSystem.calc_topn_percentage:" .. tostring(percentage))
  return LocUtil.LocalizeResFormat(108036, percentage * 100)
end
function UnknowPassRankSystem.OpenPassRankUI()
  local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
  PassPreviewSystem.HideItemModel()
  if not UIManager.IsUIShow(UIManager.UI_Config.unknowpass_rank) then
    UIManager.ShowUI(UIManager.UI_Config.unknowpass_rank)
  end
end
function UnknowPassRankSystem.ClosePassRankUI()
  UIManager.CloseUI(UIManager.UI_Config.unknowpass_rank)
end
function UnknowPassRankSystem.ShowRole(nUid)
  local SocialPersonSpaceSystem = require("client.slua.logic.lobby.Left.logic_social_person_space")
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  SocialPersonSpaceSystem.EnterPersonSpace(nUid, false, RoleInfoMainSystem.RoleInfoOpenFromType.Upass)
end
return UnknowPassRankSystem