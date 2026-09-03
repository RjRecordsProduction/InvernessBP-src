local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PlayerCharacterCampFeature = {}
function PlayerCharacterCampFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "IsEnabled",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    }
  }
end
function PlayerCharacterCampFeature:ReceiveBeginPlay()
  PlayerCharacterCampFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and string.format("PlayerCharacterCampFeature:ReceiveBeginPlay"))
  if self:HasAuthority() then
    self.IsEnabled = false
    if SubsystemMgr then
      local CampSubsystem = SubsystemMgr:Get("CampSubsystem")
      if CampSubsystem then
        CampSubsystem:RegisterPlayerCharacter(self.Owner)
      end
    end
    self:BindLuaObjEvent(self.Owner, "EVENTID_INGAME_ON_PAWN_CAMP_CHANGED", self.OnPawnCampChanged, self)
  elseif self.Owner:IsLocalControlOrView() then
    self:BindLuaObjEvent(self.Owner, "EVENTID_INGAME_ON_PAWN_CAMP_CHANGED", self.OnPawnCampChanged, self)
  end
end
function PlayerCharacterCampFeature:OnPawnCampChanged(PlayerCharacter, CampId)
  self.CacheCampMates = nil
  print(bWriteLog and string.format("PlayerCharacterCampFeature:OnPawnCampChanged PlayerKey = %s, CampId = %s", PlayerCharacter.PlayerKey, CampId))
end
function PlayerCharacterCampFeature:SetCampModeEnabled(IsEnabled)
  print(bWriteLog and string.format("PlayerCharacterCampFeature:SetCampModeEnabled %s, PlayerKey = %s", IsEnabled, self.Owner.PlayerKey))
  if self.IsEnabled ~= IsEnabled then
    self.    self:RebindDelegates()
  end
end
function PlayerCharacterCampFeature:OnRep_IsEnabled(OldValue)
  print(bWriteLog and string.format("PlayerCharacterCampFeature:OnRep_IsEnabled %s, PlayerKey = %s", self.IsEnabled, self.Owner.PlayerKey))
  if OldValue ~= self.IsEnabled then
    self:RebindDelegates()
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_REFRESH_CAMP_CHAT)
  end
end
function PlayerCharacterCampFeature:RebindDelegates()
  if self.IsEnabled then
    self:AddControlEvent(self.Owner, "OnCharacterShootBulletDelegate", self.OnCharacterShootBullet, self)
  else
    self:RemoveControlEvent(self.Owner, "OnCharacterShootBulletDelegate", self.OnCharacterShootBullet, self)
  end
end
function PlayerCharacterCampFeature:OnCharacterShootBullet(Weapon, Bullet)
  if not self.CacheCampMates then
    print(bWriteLog and string.format("PlayerCharacterCampFeature:OnCharacterShootBullet %s CacheCampMates START", self.Owner:ToString()))
    self.CacheCampMates = {}
    local OwnerPlayerKey = self.Owner.PlayerKey
    local OwnerCampId = self.Owner.CampID
    local AllPlayerCharacters = GameplayData.GetAllPlayerCharacters()
    for _, CampMate in pairs(AllPlayerCharacters) do
      if slua.isValid(CampMate) and not Game:IsEnemy(CampMate, self.Owner) and CampMate.PlayerKey ~= OwnerPlayerKey then
        print(bWriteLog and string.format("PlayerCharacterCampFeature:OnCharacterShootBullet CacheCampMates %s, CampId = %s", CampMate:ToString(), OwnerCampId))
        table.insert(self.CacheCampMates, CampMate)
      end
    end
    print(bWriteLog and string.format("PlayerCharacterCampFeature:OnCharacterShootBullet %s CacheCampMates END", self.Owner:ToString()))
  end
  if not slua.isValid(Bullet) then
    return
  end
  local MeshComp = Bullet:K2_GetRootComponent()
  if slua.isValid(MeshComp) then
    for _, CampMate in ipairs(self.CacheCampMates) do
      if slua.isValid(CampMate) then
        MeshComp:IgnoreActorWhenMoving(CampMate, true)
      end
    end
  end
end
function PlayerCharacterCampFeature:ShowOrHideCampMark(bIsShow, MarkID)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CPlayerCharacterCampFeature = class(CFeatureBase, nil, PlayerCharacterCampFeature)
return require("combine_class").SetFeatureDynamic(CPlayerCharacterCampFeature)