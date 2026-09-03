local TopKillInfo = {
  tFatalDamageRecordCache = {}
}
function TopKillInfo:ctor(selfType)
end
function TopKillInfo:Initialize()
  print(bWriteLog and "[muidarzhang] TopKillInfo:Initialize")
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ADD_FATAL_DAMAGE_INFO, self.HandleAddNewFatalDamageInfo, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_DEATH_MATCH_UI_SETTING, self.HandleDeathMatchUISetting, self)
  self:AddControlEvent(self.Anima1, "OnAnimationFinished", self.ShowKillInfoAnimation, self)
end
function TopKillInfo:OnDestroy()
  print(bWriteLog and "[muidarzhang] TopKillInfo:OnDestroy")
  if #self.tFatalDamageRecordCache > 0 then
    print(bWriteLog and "[muidarzhang] TopKillInfo:OnDestroy, FatalDamageRecordCache not empty!")
    log_tree("FatalDamageRecordCache", self.tFatalDamageRecordCache)
    self.tFatalDamageRecordCache = {}
  end
  self:Dispose()
end
function TopKillInfo:HandleDeathMatchUISetting(_, __)
  print(bWriteLog and "[muidarzhang] TopKillInfo:HandleDeathMatchUISetting")
  self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function TopKillInfo:HandleAddNewFatalDamageInfo(_, __)
  log(bWriteLog and "[muidarzhang] TopKillInfo:HandleAddNewFatalDamageInfo")
end
function TopKillInfo:ShowKillInfoAnimation()
  if #self.tFatalDamageRecordCache > 0 then
    local uFatalDamageRecord = self.tFatalDamageRecordCache[1]
    table.remove(self.tFatalDamageRecordCache, 1)
    if self:IsTopPlatformUseSingleLineTips(uFatalDamageRecord.Causer, uFatalDamageRecord.DamageType) then
      self.WidgetSwitcher:SetActiveWidgetIndex(1)
      local sKillText = self:GetTopPlatformKilledString(uFatalDamageRecord.VictimName, uFatalDamageRecord.DamageType, -1)
      print(bWriteLog and "[muidarzhang] TopKillInfo:ShowKillInfoAnimation Killed String: " .. tostring(sKillText))
      self.TopPlatformPlayerName3:SetText(sKillText)
      self:GetTopPlatformVictimNonIcon(-1)
    else
      self.WidgetSwitcher:SetActiveWidgetIndex(0)
      local sText1 = self:GetTopPlatformCauserColoredText(uFatalDamageRecord.Causer, -1)
      print(bWriteLog and "[muidarzhang] TopKillInfo:ShowKillInfoAnimation, Causer Colored Text: " .. tostring(sText1))
      self.TopPlatformPlayerName1:SetText(sText1)
      local sText2 = self:GetTopPlatformVictimeColoredText(uFatalDamageRecord.VictimName, -1)
      print(bWriteLog and "[muidarzhang] TopKillInfo:ShowKillInfoAnimation, Victim Colored Text:" .. tostring(sText2))
      self.TopPlatformPlayerName2:SetText(sText2)
      self:GetTopPlatformCauserIcon(-1)
      self:GetTopPlatformVictimIcon(-1)
    end
    self:PlayUserWidgetAnimation(self.Anima1, 0.0, 1, 0, 1.0)
  end
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CTopKillInfo = class(CDelegateContainer, nil, TopKillInfo)
return CTopKillInfo