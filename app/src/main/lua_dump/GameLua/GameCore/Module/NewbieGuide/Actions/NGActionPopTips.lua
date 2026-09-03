local ENGActionPopTipsType = {
  Normal = 0,
  Warning = 1,
  General = 2,
  GeneralSAP = 3
}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local NewbieGuideActionPopTips = {CONST_MIN_TIP_INTERVAL_TIME = 3.0}
function NewbieGuideActionPopTips:ctor(selfType, Params)
  self.TipID = Params.TipID or 0
  self.TextParam1 = Params.TextParam1 or ""
  self.TextParam2 = Params.TextParam2 or ""
  self.PostProcessTextFunc = Params.PostProcessTextFunc or nil
  self.TipType = Params.TipType or ENGActionPopTipsType.Normal
  self.TipIntervalTime = Params.TipIntervalTime or 10
  if self.TipIntervalTime < self.CONST_MIN_TIP_INTERVAL_TIME then
    sandbox.LogWarning("TipIntervalTime:" .. tostring(self.TipIntervalTime) .. "is larger than CONST_MIN_TIP_INTERVAL_TIME:" .. tostring(self.CONST_MIN_TIP_INTERVAL_TIME))
    self.TipIntervalTime = self.CONST_MIN_TIP_INTERVAL_TIME
  end
  self.TipMaxCount = Params.TipMaxCount or 1
  if Params.bShowTipImmediately == nil then
    self.bShowTipImmediately = true
  else
    self.bShowTipImmediately = Params.bShowTipImmediately
  end
  self.CurTipCount = 0
  self.bRunning = false
end
function NewbieGuideActionPopTips:RunAction(InGuideID)
  NewbieGuideActionPopTips.__super.RunAction(self, InGuideID)
  if self.TipIntervalTime < 3 or self.TipMaxCount < 1 or self.bRuning then
    return false
  end
  log(bWriteLog and "Debug NewbieGuide: NewbieGuideActionPopTips RunAction")
  self.bRunning = true
  if self.bShowTipImmediately then
    self:PopTips()
  end
  local time_ticker = require("common.time_ticker")
  self.TimerHandle = time_ticker.AddTimer(0, function()
    while self.bRunning and self.CurTipCount < self.TipMaxCount do
      coroutine.yield(self.TipIntervalTime)
      self:PopTips()
    end
  end)
  return true
end
function NewbieGuideActionPopTips:PopTips()
  if not self.bRunning then
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    if uPlayerController.IsSpectator and uPlayerController:IsSpectator() or uPlayerController.bIsForReplay then
      return
    end
    if uPlayerController.IsInPetSpectator and uPlayerController:IsInPetSpectator() then
      return
    end
  end
  if self.PostProcessTextFunc then
    self.TextParam1, self.TextParam2 = self.PostProcessTextFunc(self)
    print(bWriteLog and "NewbieGuideActionPopTips  func", self.TextParam1, self.TextParam2)
  end
  log(bWriteLog and "Debug NewbieGuideActionPopTipssss TextID " .. tostring(self.TipID))
  if self.TipType == ENGActionPopTipsType.Normal then
    IngameTipsTools.BattleNormalTipsByTextID(self.TipID, self.TextParam1, self.TextParam2)
  elseif self.TipType == ENGActionPopTipsType.Warning then
    IngameTipsTools.BattleWariningTipsByTextID(self.TipID, self.TextParam1, self.TextParam2)
  elseif self.TipType == ENGActionPopTipsType.General then
    IngameTipsTools.BattleGeneralTip(self.TipID, self.TextParam1, self.TextParam2)
  elseif self.TipType == ENGActionPopTipsType.GeneralSAP then
    IngameTipsTools.BattleGeneralSAPTip(self.TipID, self.TextParam1, self.TextParam2)
  else
    log(bWriteLog and "Error Tips type not support!")
  end
  self.CurTipCount = self.CurTipCount + 1
end
function NewbieGuideActionPopTips:EndAction()
  NewbieGuideActionPopTips.__super.EndAction(self)
  log(bWriteLog and "Debug NewbieGuide: NewbieGuideActionPopTips EndAction")
  self.bRunning = false
  self.CurTipCount = 0
  if self.TimerHandle then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.TimerHandle)
    self.TimerHandle = nil
  end
end
function NewbieGuideActionPopTips:Clear()
  log(bWriteLog and "Debug NewbieGuide: NewbieGuideActionPopTips Clear")
  self.bRunning = false
  self.CurTipCount = 0
  if self.TimerHandle then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.TimerHandle)
    self.TimerHandle = nil
  end
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNewbieGuideActionPopTips = class(CObject, nil, NewbieGuideActionPopTips)
return CNewbieGuideActionPopTips