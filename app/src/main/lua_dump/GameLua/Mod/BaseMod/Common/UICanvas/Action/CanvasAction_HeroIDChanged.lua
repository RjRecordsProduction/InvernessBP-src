local CanvasAction_HeroIDChanged = {
  sActionName = "CanvasAction_HeroIDChanged"
}
function CanvasAction_HeroIDChanged:BindEvent()
  if EVENTTYPE_ROLEPLAY_NORMAL and EVENTID_LOCAL_HERO_ID_CHANGED then
    self:AddCommonEvent(EVENTTYPE_ROLEPLAY_NORMAL, EVENTID_LOCAL_HERO_ID_CHANGED, self.OnHeroIDChanged, self)
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPlayerCharacter = uPlayerController:GetCurPlayerCharacter()
    if not slua.isValid(uPlayerCharacter) then
      return
    end
    if uPlayerCharacter and uPlayerCharacter.HeroPropFeature then
      local CurrentHeroID = uPlayerCharacter.HeroPropFeature:GetCurrentHeroID()
      self:OnHeroIDChanged(_, _, CurrentHeroID)
    end
  end
end
function CanvasAction_HeroIDChanged:UnbindEvent()
  if EVENTTYPE_ROLEPLAY_NORMAL and EVENTID_LOCAL_HERO_ID_CHANGED then
    self:RemoveCommonEvent(EVENTTYPE_ROLEPLAY_NORMAL, EVENTID_LOCAL_HERO_ID_CHANGED)
  end
end
function CanvasAction_HeroIDChanged:OnHeroIDChanged(_, _, CurrentHeroID)
  if bWriteLog then
    print(bWriteLog and "CanvasAction_HeroIDChanged:OnHeroIDChanged: ", CurrentHeroID)
  end
  if self.Config.Show then
    self.bIsShow = self:HasValue(self.Config.Show, CurrentHeroID)
  elseif self.Config.Hide then
    self.bIsShow = not self:HasValue(self.Config.Hide, CurrentHeroID)
  end
  self:UpdateCanvasShow()
end
local class = require("class")
local CanvasActionBase = require("GameLua.Mod.BaseMod.Common.UICanvas.Action.CanvasActionBase")
return class(CanvasActionBase, nil, CanvasAction_HeroIDChanged)