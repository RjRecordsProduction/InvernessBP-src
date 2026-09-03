local logic_wardrobe_card = {
  vs_team_rating_protect_times_card = 0,
  weapon_exp_card_rate_plus = 0,
  weapon_exp_card_expire_time = 0
}
function logic_wardrobe_card:InitArenaTimesCard(ratingShieldData)
  local oldTimes = self.vs_team_rating_protect_times_card
  local TableUtil = require("common.table_util")
  self.vs_team_rating_protect_times_card = TableUtil.GetTableValue(ratingShieldData, "arena_times_card", "is_effect") and TableUtil.GetTableValue(ratingShieldData, "arena_times_card", "card_instid") or 0
  if oldTimes ~= self.vs_team_rating_protect_times_card then
    local ui_doublecard_tips = UIManager.GetUI(UIManager.UI_Config.lobby_doublecard_buff_panel)
    if ui_doublecard_tips and ui_doublecard_tips:IsShow() then
      local logic_wardrobe_card = require("client.slua.logic.wardrobe.logic_wardrobe_card")
      ui_doublecard_tips:ShowArenaTimesCard()
    end
  end
end
function logic_wardrobe_card:HasVSTeamRatingProtectTimesCard()
  if self.vs_team_rating_protect_times_card ~= 0 then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    return 0 < wardrobe_data:GetItemCountByInsID(self.vs_team_rating_protect_times_card)
  end
  return false
end
function logic_wardrobe_card:GetVSTeamRatingProtectTimesCardCount()
  if self:HasVSTeamRatingProtectTimesCard() then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    return wardrobe_data:GetItemCountByInsID(self.vs_team_rating_protect_times_card)
  end
  return 0
end
function logic_wardrobe_card:InitWeaponExpCard(doubleCard)
  if not doubleCard then
    return
  end
  local oldPlus = self.weapon_exp_card_rate_plus
  local oldExpireTime = self.weapon_exp_card_expire_time
  self.weapon_exp_card_rate_plus = doubleCard.weapon_exp_card_rate_plus or 0
  self.weapon_exp_card_expire_time = doubleCard.weapon_exp_card_expire_time or 0
  if oldPlus ~= self.weapon_exp_card_rate_plus or oldExpireTime ~= self.weapon_exp_card_expire_time then
    local ui_doublecard_tips = UIManager.GetUI(UIManager.UI_Config.lobby_doublecard_buff_panel)
    if ui_doublecard_tips and ui_doublecard_tips:IsShow() then
      local logic_wardrobe_card = require("client.slua.logic.wardrobe.logic_wardrobe_card")
      ui_doublecard_tips:ShowArenaWeaponExpCard()
    end
  end
end
function logic_wardrobe_card:HasVSTeamWeaponExpCard()
  local TimeUtil = require("client.common.time_util")
  return self.weapon_exp_card_expire_time ~= 0 and self.weapon_exp_card_expire_time > TimeUtil.GetServerTimeInSec()
end
function logic_wardrobe_card:GetVSTeamWeaponExpCardRatePlus()
  return self.weapon_exp_card_rate_plus
end
function logic_wardrobe_card:GetWeaponExpCardTimeStr()
  local TimeUtil = require("client.common.time_util")
  local remainTime = self.weapon_exp_card_expire_time - TimeUtil.GetServerTimeInSec()
  return TimeUtil.FormatCountDownTime_DH_or_HM(remainTime, true)
end
function logic_wardrobe_card:GetWeaponExpCardExpireTime()
  return self.weapon_exp_card_expire_time
end
function logic_wardrobe_card:CanPutOnCard(instId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(instId)
  if itemInfo == nil then
    return false
  end
  local wardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if itemInfo.resID == wardrobeMacro.ENUM_WardrobePropResId.VS_TEAM_RATING_PROTECT_TIMES_CARD and not self:IsCardPutOn(instId) then
    return true
  end
  return false
end
function logic_wardrobe_card:IsCardPutOn(instId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(instId)
  if itemInfo == nil then
    return false
  end
  instId = tonumber(instId)
  return instId == self.vs_team_rating_protect_times_card
end
return logic_wardrobe_card