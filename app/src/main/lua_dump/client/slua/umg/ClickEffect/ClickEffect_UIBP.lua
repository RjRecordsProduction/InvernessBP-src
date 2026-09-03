local ClickEffect_UIBP = {}
function ClickEffect_UIBP:ctor(_, effectItemID)
  self.HideEffectHandler = nil
  self.EffectItemID = effectItemID or 0
  self.EffectUI = nil
  self.ClickCD = 0
  self.LastClickTime = nil
end
function ClickEffect_UIBP:OnInitialize()
  self:RefreshClickEffect()
end
function ClickEffect_UIBP:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_GET_CLICK_POSITION, self.PlayEffect, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_CLICK_ANIMATION_HIDE, self.HideEffect, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_CLICK_EFFECT_CHANGED, self.OnChangeEffect, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_PRE_BEGIN, self.OnEnterLoading, self)
end
function ClickEffect_UIBP:PlayEffect(_, __, pos)
  if not self.EffectUI then
    return
  end
  if self.ClickCD ~= 0 then
    local TimeUtil = require("client.common.time_util")
    local CurrentTime = TimeUtil.GetServerTimeInSec()
    if not self.LastClickTime then
      self.LastClickTime = CurrentTime
    elseif CurrentTime - self.LastClickTime < self.ClickCD then
      return
    else
      self.LastClickTime = TimeUtil.GetServerTimeInSec()
    end
  end
  self.EffectUI:PlayEffect(pos)
end
function ClickEffect_UIBP:HideEffect()
  self:Collapsed()
  if self.HideEffectHandler then
    self:RemoveTimer(self.HideEffectHandler)
    self.HideEffectHandler = nil
  end
  self.HideEffectHandler = self:AddTimerOnce(0.5, function()
    self:SelfHitTestInvisible()
  end)
end
function ClickEffect_UIBP:OnChangeEffect(_, __, effectItemID)
  if self.EffectItemID == effectItemID then
    return
  end
  self.EffectItemID = effectItemID or 0
  self:RefreshClickEffect()
end
function ClickEffect_UIBP:OnEnterLoading()
  if self.EffectUI then
    self.EffectUI:StopAnimationIfPlaying()
  end
end
function ClickEffect_UIBP:RefreshClickEffect()
  if self.EffectUI then
    self.EffectUI:Close()
    self.EffectUI = nil
  end
  local cfg = CDataTable.GetTableDataByFilter("ClickEffectConfig", "ItemID", self.EffectItemID)
  if not cfg then
    return
  end
  self.ClickCD = cfg.ClickCD_f or 0
  self.EffectUI = self:CreateChildWindowWithBpPath(self.UIRoot.CanvasPanel_Content, UIManager.UI_Config.ClickEffect_Effect_UIBP, cfg.EffectPath, self.EffectItemID)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
local CClickEffect_UIBP = class(UIBase, nil, ClickEffect_UIBP)
return CClickEffect_UIBP