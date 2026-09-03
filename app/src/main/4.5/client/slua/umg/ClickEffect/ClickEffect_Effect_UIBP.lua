local ClickEffect_Effect_UIBP = {}
function ClickEffect_Effect_UIBP:ctor(_, EffectItemID)
  self.  self.IsPreview = false
  self.IsPlaying = false
  self.SetPreviewScale = false
  self.ClickEffectCfg = nil
end
function ClickEffect_Effect_UIBP:RegistEvents()
  self:AddOnAnimationFinishedEvent("click", self.OnPlayClickAnimationEnd, self)
end
function ClickEffect_Effect_UIBP:OnPostInitialize()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Effect, false)
  self.ClickEffectCfg = CDataTable.GetTableData("ClickEffectConfig", self.EffectItemID)
  if not self.ClickEffectCfg then
    return
  end
  local renderScale = self.ClickEffectCfg.UsedScaleRatio_f or 1
  self.UIRoot.CanvasPanel_Effect:SetRenderScale(FVector2D(renderScale, renderScale))
end
function ClickEffect_Effect_UIBP:OnClose()
  self:StopAnimationIfPlaying()
end
function ClickEffect_Effect_UIBP:OnPlayClickAnimationEnd()
  if self.UIRoot and slua.isValid(self.UIRoot) then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Effect, false)
  end
  self.isPlaying = false
  if self.IsPreview then
    local cfg = self.ClickEffectCfg
    if cfg then
      local delayCD = cfg.PreviewCD_f
      self:AddTimerOnce(delayCD, function()
        self:SetWidgetVisible(self.UIRoot.CanvasPanel_Effect, true)
        self:PlayUserWidgetAnimation(self.UIRoot.click, 0, 1, 0, 1)
      end)
    end
  end
end
function ClickEffect_Effect_UIBP:PlayEffect(pos, isPreview)
  self:StopAnimationIfPlaying()
  self.IsPreview = isPreview or false
  if not self.IsPreview then
    self.IsPlaying = true
    self.UIRoot.CanvasPanel_Effect.Slot:SetPosition(pos)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Effect, true)
    self:PlayUserWidgetAnimation(self.UIRoot.click, 0, 1, 0, 1)
  else
    if not self.SetPreviewScale then
      local ClickEffectCfg = self.ClickEffectCfg
      if ClickEffectCfg then
        local PreviewScaleRatio = ClickEffectCfg.PreviewScaleRatio_f == 0 and 1 or ClickEffectCfg.PreviewScaleRatio_f
        self.UIRoot.CanvasPanel_Effect:SetRenderScale(FVector2D(PreviewScaleRatio, PreviewScaleRatio))
        self.SetPreviewScale = true
      end
    end
    self:AddTimerOnce(0.05, function()
      local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
      local Geometry = self.UIRoot:GetCachedGeometry()
      local LocalSize = SlateBlueprintLibrary.GetLocalSize(Geometry)
      local pos = FVector2D(LocalSize.X / 2, LocalSize.Y / 2)
      self.UIRoot.CanvasPanel_Effect.Slot:SetPosition(pos)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Effect, true)
      self:PlayUserWidgetAnimation(self.UIRoot.click, 0, 1, 0, 1)
    end)
  end
end
function ClickEffect_Effect_UIBP:StopAnimationIfPlaying()
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
local CClickEffect_Effect_UIBP = class(UIBase, nil, ClickEffect_Effect_UIBP)
return CClickEffect_Effect_UIBP