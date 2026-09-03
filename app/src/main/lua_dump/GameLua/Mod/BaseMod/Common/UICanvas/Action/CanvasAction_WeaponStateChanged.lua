local CanvasAction_WeaponStateChanged = {
  sActionName = "CanvasAction_WeaponStateChanged"
}
function CanvasAction_WeaponStateChanged:BindEvent()
  if not self.Config.Show and not self.Config.Hide then
    return
  end
  self:OnWeaponChanged()
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTTYPE_PLAYEREVENT_WEAPONSTATE_CHANGE, self.OnWeaponChanged, self)
end
function CanvasAction_WeaponStateChanged:UnbindEvent()
  self:RemoveCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTTYPE_PLAYEREVENT_WEAPONSTATE_CHANGE)
end
function CanvasAction_WeaponStateChanged:OnWeaponChanged()
  local UGameplayStatics = import("GameplayStatics")
  local uPlayerController = UGameplayStatics.GetPlayerController(CGameState, 0)
  if slua.isValid(uPlayerController) then
    local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
    if slua.isValid(uPlayerCharacter) then
      local uWeaponManagerComp = uPlayerCharacter:GetWeaponManager()
      if slua.isValid(uWeaponManagerComp) then
        local CurWeaponSlot = uWeaponManagerComp:GetCurrentUsingPropSlot()
        if self.Config.Show then
          self.bIsShow = self:HasValue(self.Config.Show, CurWeaponSlot)
        elseif self.Config.Hide then
          self.bIsShow = not self:HasValue(self.Config.Hide, CurWeaponSlot)
        end
        if self.bIsShow and self.Config.FuncName ~= nil then
          local _, ReturnValue = self:CallUIRootFunction(self.Config.FuncName, CurWeaponSlot, uWeaponManagerComp)
          self.bIsShow = ReturnValue
        end
      end
    end
  end
  self:UpdateCanvasShow()
end
local class = require("class")
local CanvasActionBase = require("GameLua.Mod.BaseMod.Common.UICanvas.Action.CanvasActionBase")
local CCanvasAction_WeaponStateChanged = class(CanvasActionBase, nil, CanvasAction_WeaponStateChanged)
return CCanvasAction_WeaponStateChanged