local lua_daily_gift = {}
function lua_daily_gift:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_SHARE, EVENTID_SHARECOMPONENT_UPDATE_DAILY_GIFT, self.SetSelfVisibility, self)
end
function lua_daily_gift:OnPostInitialize()
  self:SetArrow()
  self:SetSelfVisibility()
  self.UTRichTextBlock_Tips:SetText(LocUtil.LocalizeResFormat(62135, 10))
end
function lua_daily_gift:SetArrow()
  if self.ArrowPosition and self.ArrowPosition >= 0 and self.ArrowPosition <= 7 then
    self["Arrow_" .. self.ArrowPosition]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function lua_daily_gift:SetSelfVisibility()
  if self:IsShowDailyGiftLabel() then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function lua_daily_gift:GetShareRewardCfg()
  local tAllRewardCfg = {}
  local uAllCfg = CDataTable.GetTable("ClientSponsorAwardCfg")
  if not uAllCfg then
    return tAllRewardCfg
  end
  local TimeUtil = require("client.common.time_util")
  local StringUtil = require("common.string_util")
  local sAppId = Client.GetITopGameId()
  local nCurTime = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(uAllCfg) do
    local bAppIsShow = false
    local tAllAppId = StringUtil.Split(v.AppId, ";")
    for _, sId in ipairs(tAllAppId) do
      if sId == sAppId then
        bAppIsShow = true
        break
      end
    end
    local bTimeIsShow = false
    local nStartTime = TimeUtil.TimeStringToUnixstamp(v.StartTime)
    local nEndTime = TimeUtil.TimeStringToUnixstamp(v.EndTime)
    if nCurTime >= nStartTime and nCurTime <= nEndTime then
      bTimeIsShow = true
    end
    if bAppIsShow and bTimeIsShow then
      table.insert(tAllRewardCfg, v)
    end
  end
  return tAllRewardCfg
end
function lua_daily_gift:IsShowDailyGiftLabel()
  local TimeUtil = require("client.common.time_util")
  local ShareMgr = require("client.logic.share.share_logic")
  local tAllRewardCfg = self:GetShareRewardCfg()
  if #tAllRewardCfg <= 0 then
    return false
  end
  if ShareMgr.SponsorAward.reward_cnt == 0 or TimeUtil.FormatTime_YMD(ShareMgr.SponsorAward.refresh_time) ~= TimeUtil.FormatTime_YMD(TimeUtil.GetServerTimeInSec()) then
    return true
  else
    return false
  end
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, lua_daily_gift)