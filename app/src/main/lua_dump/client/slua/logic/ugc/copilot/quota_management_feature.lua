local QuotaManagementFeature = {Owner = nil}
local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local Util_UGC = require("client.slua.logic.ugc.util_ugc")
local Config_UGC_Copilot = require("client.slua.logic.ugc.copilot.config_ugc_copilot")
function QuotaManagementFeature:ctor()
  print(bWriteLog and "QuotaManagementFeature:ctor")
end
function QuotaManagementFeature:OnInitialize()
  self:DefineAndResetQuotaData()
end
function QuotaManagementFeature:DefineAndResetQuotaData()
  self.LLMQuota = {DailyLimit = 10, UsedToday = 0}
  self.lastFetchTime = nil
  if self.tipsTimer then
    self.Owner:RemoveTimer(self.tipsTimer)
    self.tipsTimer = nil
  end
end
function QuotaManagementFeature:OnClose()
  if self.tipsTimer then
    self.Owner:RemoveTimer(self.tipsTimer)
    self.tipsTimer = nil
  end
end
function QuotaManagementFeature:RegistEvents()
end
function QuotaManagementFeature:FetchLLMQuota()
  local currentTime = os.time()
  if self.LLMQuota and self.lastFetchTime then
    local timeDiff = currentTime - self.lastFetchTime
    if timeDiff < 1 then
      print(bWriteLog and "[UGC] FetchLLMQuota: 1\231\167\146\229\134\133\229\183\178\232\175\183\230\177\130\232\191\135\239\188\140\228\189\191\231\148\168\231\188\147\229\173\152\230\149\176\230\141\174")
      EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_QUOTA_UPDATE, self.LLMQuota)
      return
    end
  end
  self.lastFetchTime = currentTime
  print(bWriteLog and "[UGC] FetchLLMQuota: \229\143\145\233\128\129\230\150\176\233\133\141\233\162\157\232\175\183\230\177\130")
  self.Owner.NetworkProtocolFeature:SendGetLLMAgentDataReq()
end
function QuotaManagementFeature:OnLLMQuotaRsp(quota_data)
  if quota_data ~= nil then
    self.LLMQuota = {
      DailyLimit = quota_data.day_limit.limit,
      UsedToday = quota_data.day_limit.count or 0
    }
  end
  EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_QUOTA_UPDATE, self.LLMQuota)
end
function QuotaManagementFeature:IsLLMOutofQuota()
  if self.LLMQuota and self.LLMQuota.UsedToday < self.LLMQuota.DailyLimit then
    return false
  end
  return true
end
function QuotaManagementFeature:GetLLMQuota()
  return self.LLMQuota
end
function QuotaManagementFeature:ShowQuotaExceeded()
  print(bWriteLog and "QuotaManagementFeature:ShowQuotaExceeded")
  if self.LLMQuota == nil then
    print(bWriteLog and "LLMQuota is nil")
    return
  end
  local Template = Util_UGC.GetLocalizeResStr(Config_UGC_Copilot.Enum_UGC_System_Msg.OUT_OF_QUOTA)
  local Content = LocUtil.GeneralFormat(Template, self.LLMQuota.DailyLimit)
  ShowNotice(Content)
end
function QuotaManagementFeature:IncrementUsageCount()
  if self.LLMQuota and self.Owner:IsQuotaSysEnabled() then
    self.LLMQuota.UsedToday = self.LLMQuota.UsedToday + 1
    EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_QUOTA_UPDATE, self.LLMQuota)
  end
end
function QuotaManagementFeature:OpenLLMQuotaReqTimer()
  log(bWriteLog and "QuotaManagementFeature:OpenLLMQuotaReqTimer()")
  if self.tipsTimer then
    self.Owner:RemoveTimer(self.tipsTimer)
    self.tipsTimer = nil
  end
  self.tipsTimer = self.Owner:AddTimerOnce(2, function()
    self:OnLLMQuotaReq()
  end)
end
function QuotaManagementFeature:OnLLMQuotaReq()
  log(bWriteLog and "QuotaManagementFeature:OnLLMQuotaReq()")
  self:FetchLLMQuota()
end
local class = require("class")
local object = require("object")
return class(object, nil, QuotaManagementFeature)