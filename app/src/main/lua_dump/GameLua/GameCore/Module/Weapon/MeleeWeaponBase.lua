local MeleeWeaponBase = {}
local CustomVirtualItemHandleUtil = require("GameLua.Mod.BaseMod.GamePlay.CustomVirtualItem.Utils.CustomVirtualItemHandleUtil")
function MeleeWeaponBase:ctor(selfType)
end
function MeleeWeaponBase:ReceiveBeginPlay()
  print(bWriteLog and "MeleeWeaponBase ReceiveBeginPlay() ", self)
  self.PredictLineComp = nil
  self.Super:ReceiveBeginPlay()
  MeleeWeaponBase.__super.ReceiveBeginPlay(self)
  if slua.isValid(self.Box) and self.Box.ComponentHasTag and not self.Box:ComponentHasTag("IgnoreGunCollosion") then
    self.Box.ComponentTags:Add("IgnoreGunCollosion")
  end
end
function MeleeWeaponBase:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "MeleeWeaponBase ReceiveEndPlay()", self)
  self.PredictLineComp = nil
  self.Super:ReceiveEndPlay(EndPlayReason)
  MeleeWeaponBase.__super.ReceiveEndPlay(self)
end
function MeleeWeaponBase:GetPredictLineComp()
  if not slua.isValid(self.PredictLineComp) then
    self.PredictLineComp = self:GetComponentByClass(import("/Script/ShadowTrackerExtra.PredictLineComponent"))
  end
  return self.PredictLineComp
end
function MeleeWeaponBase:HandleWeaponAfterSpawned()
  print(bWriteLog and "MeleeWeaponBase HandleWeaponAfterSpawned", self, self:GetItemDefineID().TypeSpecificID)
  self.Super:HandleWeaponAfterSpawned()
  local CustomVirtualItemSubsystem = SubsystemMgr:Get("CustomVirtualItemSubsystem")
  local ItemID = self:GetItemDefineID().TypeSpecificID
  if CustomVirtualItemSubsystem ~= nil then
    if CustomVirtualItemSubsystem:IsExistVirtualItem(ItemID) then
      self:InitCustomWeapon(CustomVirtualItemSubsystem:GetBluePrintInfo(ItemID))
    end
    if Client and CustomVirtualItemHandleUtil.IsCustomItemID(ItemID) then
      self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CUSTOMVIRTUALITEM_INSERT, self.OnNewCustomVirtualItmeInsert, self)
    end
  end
end
function MeleeWeaponBase:OnNewCustomVirtualItmeInsert(_, __, nItemID)
  if Client and nItemID == self:GetItemDefineID().TypeSpecificID then
    local CustomVirtualItemSubsystem = SubsystemMgr:Get("CustomVirtualItemSubsystem")
    local ItemID = self:GetItemDefineID().TypeSpecificID
    if CustomVirtualItemSubsystem ~= nil and CustomVirtualItemSubsystem:IsExistVirtualItem(ItemID) then
      self:InitCustomWeapon(CustomVirtualItemSubsystem:GetBluePrintInfo(ItemID))
      if slua.isValid(self.WeaponAvatarComponent) then
        self.WeaponAvatarComponent:ClearMeshBySlot(7, true, true)
      end
      self:DelayHandleAvatarMeshChanged()
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CUSTOMVIRTUALITEM_WEAPON_SPAWN, nItemID)
    end
    self:RemoveCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CUSTOMVIRTUALITEM_INSERT)
  end
end
function MeleeWeaponBase:InitCustomWeapon(CustomConfigData)
  print(bWriteLog and "MeleeWeaponBase InitCustomWeapon", self)
  if not CustomConfigData then
    return
  end
  self.WeaponSpecialUIList = {}
  for Property, Data in pairs(CustomConfigData) do
    if self[Property] and type(self[Property]) ~= "function" then
      print(bWriteLog and "MeleeWeaponBase InitCustomWeapon", Property, type(Property))
      if type(Data) ~= "table" then
        self[Property] = Data
      else
        for SubProperty, SubData in pairs(Data) do
          if type(SubData) ~= "table" then
            self[Property][SubProperty] = SubData
          end
        end
      end
    end
  end
  if CustomConfigData.CallbackFunc and type(CustomConfigData.CallbackFunc) == "function" then
    CustomConfigData.CallbackFunc(self.Object)
  end
end
function MeleeWeaponBase:GetWeaponAvatarComponent()
  return self.WeaponAvatarComponent
end
function MeleeWeaponBase:InitWeapon()
end
function MeleeWeaponBase:IsHoldingInHand()
  local OwnerPawn = self:GetOwnerPawn()
  if Game:IsValid(OwnerPawn) and OwnerPawn.GetCurrentWeapon then
    local CurrentWeapon = OwnerPawn:GetCurrentWeapon()
    return CurrentWeapon == self.Object
  end
  return false
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CMeleeWeaponBase = class(CActorBase, nil, MeleeWeaponBase)
return CMeleeWeaponBase