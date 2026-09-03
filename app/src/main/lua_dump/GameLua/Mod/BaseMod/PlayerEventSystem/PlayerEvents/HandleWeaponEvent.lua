local HandleWeaponEvent = {}
local UGameplayStatics = import("GameplayStatics")
function HandleWeaponEvent:ctor(selfType)
end
function HandleWeaponEvent:HandleSwitchWeapon(EventType, EventID, PlayerKey)
end
function HandleWeaponEvent:HandleChangeWeaponAttachment(EventType, EventID, PlayerKey, TargetWeaponSlot, AttachmentID, bEquip)
end
function HandleWeaponEvent:HandleInitWeapon(nEventType, nEventID, nPlayerKey, uWeapon)
  if self.bIsClient then
  else
    self.EventActionMgr:TriggerPlayerEvent(nPlayerKey, nEventType, nEventID, uWeapon)
  end
  local WeaponSystem = require("GameLua.GameCore.Module.Weapon.WeaponSystem")
  WeaponSystem:InitWeapon(uWeapon)
end
function HandleWeaponEvent:QueryWeaponEventData(nPlayerKey)
  if self.bIsClient and slua.isValid(self.GameState) then
    local PlayerController = UGameplayStatics.GetPlayerController(self.GameState, 0)
    if slua.isValid(PlayerController) and PlayerController.PlayerKey == nPlayerKey then
      local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
      if slua.isValid(PlayerCharacter) then
        local CurWeapon = PlayerCharacter:GetCurrentShootWeapon()
        if slua.isValid(CurWeapon) then
          return self.EventDataMgr:GetData(EVENTTYPE_PLAYEREVENT_WEAPON), PlayerCharacter, CurWeapon
        end
      end
    end
  end
  return nil, nil, nil
end
function HandleWeaponEvent:HandleWeaponsScope(nEventType, nEventID, nPlayerKey, bScopeIn)
end
function HandleWeaponEvent:HandleWeaponClear(nEventType, nEventID, nPlayerKey)
  if self.bIsClient and slua.isValid(self.GameState) then
    local PlayerController = UGameplayStatics.GetPlayerController(self.GameState, 0)
    if slua.isValid(PlayerController) and PlayerController.PlayerKey == nPlayerKey then
      local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
      if slua.isValid(PlayerCharacter) then
        local WeaponEventData = self.EventDataMgr:GetData(nEventType)
        if WeaponEventData then
          WeaponEventData:HandleWeaponClear(self, PlayerCharacter)
        end
      end
    end
  end
end
local class = require("class")
local CEventBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.HandleEventBase")
local CHandleWeaponEvent = class(CEventBase, nil, HandleWeaponEvent)
return CHandleWeaponEvent