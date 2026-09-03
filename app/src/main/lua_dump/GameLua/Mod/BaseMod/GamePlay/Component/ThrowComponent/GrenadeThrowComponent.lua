local UAESkillManagerUtils = import("UAESkillManagerUtils")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local GrenadeThrowComponent = {
  sComponentName = "GrenadeThrowComponent"
}
function GrenadeThrowComponent:ctor(selfType)
  self.NewProjectile = nil
end
function GrenadeThrowComponent:ReceiveBeginPlay()
  GrenadeThrowComponent.__super.ReceiveBeginPlay(self)
  if self.CurWeaponID and slua.isValid(self.CurWeaponID) then
    self.CurGrenadeID = self.CurWeaponID.TypeSpecificID
  end
  if Client and slua.isValid(self.Object) then
    self:AddControlEvent(self.Object, "ThrowCanceledDelegate", function()
      if slua.isValid(self.NewProjectile) then
        self:HideThrowTimeInfoPanel(self.NewProjectile)
      end
    end)
  end
end
function GrenadeThrowComponent:ReceiveEndPlay(nEndPlayReason)
  GrenadeThrowComponent.__super.ReceiveEndPlay(self, nEndPlayReason)
end
function GrenadeThrowComponent:InitializeNewProjectile(NewProjectile, bDrop, ExplosionDelay)
  self.Super:InitializeNewProjectile(NewProjectile, bDrop, ExplosionDelay)
  self.  if Client and slua.isValid(NewProjectile) and NewProjectile:IsTimerExplosionProjectile() then
    self:AddControlEvent(NewProjectile, "ProjectileExplodedDelegate", function()
      self:HideThrowTimeInfoPanel(self.NewProjectile)
    end)
    if slua.isValid(NewProjectile.Instigator) and NewProjectile.Instigator:IsLocallyControlled() then
      self:ShowThrowTimeInfoPanel(NewProjectile)
    end
  end
end
local EThrowState = import("EThrowState")
function GrenadeThrowComponent:ReceiveThrowStateChanged(NewState, PrevState)
  GrenadeThrowComponent.__super.ReceiveThrowStateChanged(self, NewState, PrevState)
  if Client then
    local OwnerPawn = self:GetOwnerPawn()
    local ENetRole = import("ENetRole")
    if not slua.isValid(OwnerPawn) or OwnerPawn.Role ~= ENetRole.ROLE_AutonomousProxy then
      return
    end
    if NewState == EThrowState.Idle then
      self:HideCancelButton()
    elseif NewState == EThrowState.Prepare then
      self:ShowCancelButton()
    elseif NewState == EThrowState.Aim then
      self:ShowCancelButton()
    elseif NewState == EThrowState.Release then
      self:HideCancelButton()
    elseif NewState == EThrowState.Drop then
      self:HideCancelButton()
    end
  end
end
function GrenadeThrowComponent:ShowThrowTimeInfoPanel(NewProjectile)
  if self.CurGrenadeID and self.CurGrenadeID > 0 then
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_CDBAR, UEnums.CDBarType.ThrowItem, {
      GrenadeID = self.CurGrenadeID,
      ThrowActor = NewProjectile
    })
  else
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_HIDE_CDBAR, UEnums.CDBarType.ThrowItem, {
      GrenadeID = self.CurGrenadeID,
      ThrowActor = NewProjectile
    })
  end
end
function GrenadeThrowComponent:HideThrowTimeInfoPanel(NewProjectile)
  print(bWriteLog and "GrenadeThrowComponent:HideThrowTimeInfoPanel CurGrenadeID=" .. self.CurGrenadeID)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_HIDE_CDBAR, UEnums.CDBarType.ThrowItem, {
    GrenadeID = self.CurGrenadeID,
    ThrowActor = NewProjectile
  })
end
function GrenadeThrowComponent:ShowCancelButton()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:BroadcastUIMessage("UIMsg_ShowCancelGrenadeThrow", 0, "", "")
  end
end
function GrenadeThrowComponent:HideCancelButton()
  local ShootingUIPanel = InGameUITools.GetShootingUIPanelLuaClass()
  if ShootingUIPanel then
    ShootingUIPanel:HideCancelGrenadeBtn()
  end
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.GamePlay.Component.ThrowComponent.BaseThrowComponent")
local CGrenadeThrowComponent = class(CActorComponentBase, nil, GrenadeThrowComponent)
return CGrenadeThrowComponent