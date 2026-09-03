local FarClassicStoreScreenMarkUI = {}
local AnimLoopTime = 3
function FarClassicStoreScreenMarkUI:Initialize()
  self:AddCommonEvent(EVENTTYPE_INGAME_CLASSICSTORE, EVENTID_INGAME_SHOW_OR_HIDE_CLASSICSTORE_BUTTON, self.ShowOrHideClassicStore, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_CLASSICSTORE, EVENTID_INGAME_CLASSICSTORE_REFIND_NEAREST_STORE, self.OnClickRefindStore, self)
end
function FarClassicStoreScreenMarkUI:OnActorBindUI(uActor)
  self:ShowAnim()
  FarClassicStoreScreenMarkUI.__super.OnActorBindUI(self, uActor)
end
function FarClassicStoreScreenMarkUI:OnLocationBindUI(Loc)
  self:ShowAnim()
  FarClassicStoreScreenMarkUI.__super.OnLocationBindUI(self, Loc)
  self.BindOutScreen = true
  self.bShowWidget = true
end
function FarClassicStoreScreenMarkUI:ShowAnim()
  if self.Anim_Enter then
    self:PlayUserWidgetAnimation(self.Anim_Enter, 0, 1, 0, 1)
    if self.Anim_Loop then
      self.Anim_Enter.OnAnimationFinished:Add(function()
        self:PlayUserWidgetAnimation(self.Anim_Loop, 0, AnimLoopTime, 0, 1)
      end)
    end
  end
end
function FarClassicStoreScreenMarkUI:ShowOrHideClassicStore(eventType, eventId, uStore, isShow)
  if isShow then
    self.bShowWidget = false
  end
end
function FarClassicStoreScreenMarkUI:OnClickRefindStore()
  if not self.bShowWidget then
    self.bShowWidget = true
  end
  self:StopAnimation()
  self:ShowAnim()
end
function FarClassicStoreScreenMarkUI:OnUpdateDistance(distance)
  if self:CheckDistanceShouldHide(distance) and (self.LastShow or self.LastShow == nil) then
    Client.RequireSlateTickEveryFrame(SlateUI_ID.FAR_CLASSIC_STORE_SCREEN_MARK)
    self.Image_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.CanvasPanel_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.CanvasPanel_vx1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.LastShow = false
  elseif not self:CheckDistanceShouldHide(distance) and not self.LastShow then
    Client.ResetSlateTickEveryFrame(SlateUI_ID.FAR_CLASSIC_STORE_SCREEN_MARK)
    self.Image_5:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_vx1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.LastShow = true
  end
end
function FarClassicStoreScreenMarkUI:CheckDistanceShouldHide(distance)
  return distance <= 2
end
function FarClassicStoreScreenMarkUI:OnDestroy()
  self:Dispose()
  FarClassicStoreScreenMarkUI.__super.OnDestroy(self)
end
local class = require("class")
local ClassicStoreScreenMarkUIBase = require("GameLua.Mod.BaseMod.Client.Store.ClassicStoreScreenMarkUI")
return class(ClassicStoreScreenMarkUIBase, nil, FarClassicStoreScreenMarkUI)