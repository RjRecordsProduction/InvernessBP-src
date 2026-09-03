local logic_team_add_score_card = {}
function logic_team_add_score_card:OnInitialize()
  local wardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  self.CardResIdList = {
    [wardrobeMacro.ENUM_WardrobePropResId.TEAM_ADD_SCORE_CARD_5] = true,
    [wardrobeMacro.ENUM_WardrobePropResId.TEAM_ADD_SCORE_CARD_10] = true,
    [wardrobeMacro.ENUM_WardrobePropResId.TEAM_ADD_SCORE_CARD_20] = true,
    [wardrobeMacro.ENUM_WardrobePropResId.TEAM_Limit_ADD_SCORE_CARD_5] = true,
    [wardrobeMacro.ENUM_WardrobePropResId.TEAM_Limit_ADD_SCORE_CARD_10] = true,
    [wardrobeMacro.ENUM_WardrobePropResId.TEAM_Limit_ADD_SCORE_CARD_20] = true,
    [wardrobeMacro.ENUM_WardrobePropResId.TEAM_Protect_Card] = true,
    [wardrobeMacro.ENUM_WardrobePropResId.TEAM_Protect_Card_UnLimit] = true
  }
end
function logic_team_add_score_card:GetScoreCardNum(resId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local count = 0
  local expireTS = 0
  local itemDataList = wardrobe_data:GetHallDepotItemListByResIDValidExpireTime(resId)
  if itemDataList and next(itemDataList) and itemDataList[1] then
    expireTS = itemDataList[1].expireTS
  end
  for _, itemData in ipairs(itemDataList) do
    count = count + itemData.count
    if itemData.expireTS and expireTS > itemData.expireTS then
      expireTS = itemData.expireTS
    end
  end
  log(bWriteLog and "logic_team_add_score_card:GetScoreCardNum count = " .. tostring(count) .. " expireTS = " .. tostring(expireTS))
  return count, expireTS
end
function logic_team_add_score_card:HasValidTeamAddScoreCard(resId)
  local count = self:GetScoreCardNum(resId)
  return 0 < count
end
function logic_team_add_score_card:IsDefaultUseTeamAddScoreCard(resId)
  log(bWriteLog and " logic_team_add_score_card.IsDefaultUseTeamAddScoreCard")
  if not resId then
    log(bWriteLog and " logic_team_add_score_card.IsDefaultUseSeasonAddScoreCard no itemResId")
    return false
  end
  return self.CardResIdList[resId]
end
function logic_team_add_score_card:HasLimitTeamAddScoreCard()
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  if not serverTime then
    return false
  end
  local wardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local _, expireTS1 = self:GetScoreCardNum(wardrobeMacro.ENUM_WardrobePropResId.TEAM_Limit_ADD_SCORE_CARD_5)
  local __, expireTS2 = self:GetScoreCardNum(wardrobeMacro.ENUM_WardrobePropResId.TEAM_Limit_ADD_SCORE_CARD_10)
  local ___, expireTS3 = self:GetScoreCardNum(wardrobeMacro.ENUM_WardrobePropResId.TEAM_Limit_ADD_SCORE_CARD_20)
  return expireTS1 ~= 0 and serverTime < expireTS1 or expireTS2 ~= 0 and serverTime < expireTS2 or expireTS3 ~= 0 and serverTime < expireTS3
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_team_add_score_card)