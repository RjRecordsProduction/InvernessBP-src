local PlayerControllerHeroPropFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function PlayerControllerHeroPropFeature:_PostConstruct()
  PlayerControllerHeroPropFeature.__super._PostConstruct(self)
  self.tRoleSkillInfo = {}
  self.BringInRoleID = 0
  self.SelectedRoleID = 0
end
function PlayerControllerHeroPropFeature:ReceiveBeginPlay()
  PlayerControllerHeroPropFeature.__super.ReceiveBeginPlay(self)
  self:InitRoleInfo()
  if not Client then
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, self.OnEnterFightState, self)
  end
end
function PlayerControllerHeroPropFeature:InitRoleInfo()
end
function PlayerControllerHeroPropFeature:GetRoleSkillInfo(RoleID)
  return self.tRoleSkillInfo[RoleID]
end
function PlayerControllerHeroPropFeature:ServerChooseHeroData(HeroID)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModeType = GameMainConfig.GetModType()
  if ModeType == "EasternRealm" then
    return
  end
  printf("debugChangeHero PlayerControllerHeroPropFeature:ServerChooseHeroData self.Owner.PlayerKey:%u, HeroID:%d", self.Owner.PlayerKey, HeroID)
  if self:IsAuthority() then
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local CommonFightTransformConfig = GamePlayTools.GetCurrentConfig("CommonFightTransformConfig")
    local uPlayerCharacter = self.Owner:GetPlayerCharacterSafety()
    if slua.isValid(uPlayerCharacter) and uPlayerCharacter.HeroPropFeature then
      local lastHeroID = uPlayerCharacter.HeroPropFeature:GetCurrentHeroID()
      if CommonFightTransformConfig:CheckFightTransform(HeroID) or CommonFightTransformConfig:CheckFightTransform(lastHeroID) then
        return self:FightRealDellServerChooseHeroData(HeroID)
      end
    end
    if not slua.isValid(self.Owner:GetPlayerTransformComponent()) then
      print(bWriteLog and "PlayerControllerHeroPropFeature:ServerChooseHeroData CanntFindPlayerTransformComponent")
      return false
    end
    if not self.Owner:GetPlayerTransformComponent():ServerChooseHeroCheck(HeroID) then
      print(bWriteLog and "PlayerControllerHeroPropFeature:ServerChooseHeroCheck CheckFail")
      return false
    end
    self.Owner:GetPlayerTransformComponent():ServerChooseHero(HeroID)
    if slua.isValid(uPlayerCharacter) and uPlayerCharacter.HeroPropFeature and uPlayerCharacter.HeroPropFeature.SetCurrentHeroID then
      uPlayerCharacter.HeroPropFeature:SetCurrentHeroID(HeroID)
      return true
    end
  end
  return false
end
function PlayerControllerHeroPropFeature:FightRealDellServerChooseHeroData(HeroID)
  local uPlayerCharacter = self.Owner:GetPlayerCharacterSafety()
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter.BeComeOtherFigureFeature and uPlayerCharacter.HeroPropFeature then
    if not uPlayerCharacter.BeComeOtherFigureFeature:ServerChooseHeroCheck(HeroID) then
      print(bWriteLog and "PlayerControllerHeroPropFeature:FightRealDellServerChooseHeroData CheckFail")
      return false
    end
    uPlayerCharacter.BeComeOtherFigureFeature:ServerChooseHero(HeroID)
    uPlayerCharacter.BeComeOtherFigureFeature:SetCurrentHeroID(HeroID)
    uPlayerCharacter.HeroPropFeature:SetCurrentHeroID(HeroID)
    self:AfterServerChooseHeroCheck(HeroID, uPlayerCharacter)
    return true
  end
  return false
end
function PlayerControllerHeroPropFeature:AfterServerChooseHeroCheck(HeroID, uPlayerCharacter)
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local CommonFightTransformConfig = GamePlayTools.GetCurrentConfig("CommonFightTransformConfig")
  if slua.isValid(uPlayerCharacter) and CommonFightTransformConfig and CommonFightTransformConfig:CheckFightTransform(HeroID) and CommonFightTransformConfig.CommonransformConfig[HeroID].bTransformToVehicle then
    local EPawnState = import("EPawnState")
    local uVehicleUser
    if self.Owner.GetVehicleUserComp then
      uVehicleUser = self.Owner:GetVehicleUserComp()
    end
    if not (uPlayerCharacter:HasState(EPawnState.DriveVehicle) and slua.isValid(uVehicleUser)) or not slua.isValid(uVehicleUser:GetVehicle()) then
      uPlayerCharacter.BeComeOtherFigureFeature:RPC_Server_DoTransfrom(false)
      print(bWriteLog and string.format("[error]PlayerControllerHeroPropFeature:AfterServerChooseHeroCheck,PlayerKey=%s,HeroID=%s", tostring(uPlayerCharacter.PlayerKey), tostring(HeroID)))
      return
    end
  end
end
PlayerControllerHeroPropFeature.ServerRPC.RPC_Server_SetRollSkillInfo = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
PlayerControllerHeroPropFeature.ClientRPC.RPC_Client_AutoSelectSkill = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function PlayerControllerHeroPropFeature:RPC_Server_SetRollSkillInfo(RoleID)
  if Client then
    return
  end
  if not self.tRoleSkillInfo[RoleID] then
    return
  end
  if Server and Server.IsShipping() then
    local uGameState = GameplayData.GetGameState()
    if not slua.isValid(uGameState) or uGameState:GetGameModeState() ~= "ReadyState" then
      return
    end
  end
  self:SetSelectedRoleID(RoleID)
  self:ServerChooseHeroData(RoleID)
  self.bAutoSelectSkill = false
end
function PlayerControllerHeroPropFeature:GetSelectedRoleID()
  if self.SelectedRoleID == nil then
    return 0
  end
  return self.SelectedRoleID
end
function PlayerControllerHeroPropFeature:SetBringInRoleID(RoleID)
  self.BringInend
function PlayerControllerHeroPropFeature:SetSelectedRoleID(RoleID, bAutoSelected)
  print(bWriteLog and "PlayerControllerHeroPropFeature:SetSelectedRoleID self.Owner.PlayerKey:" .. tostring(self.Owner.PlayerKey) .. ", RoleID:" .. tostring(RoleID) .. ", bAutoSelected:" .. tostring(bAutoSelected))
  self.Selected  if bAutoSelected then
    self:RPC_Client_AutoSelectSkill(RoleID)
    self.bAutoSelectSkill = true
  end
end
function PlayerControllerHeroPropFeature:RPC_Client_AutoSelectSkill(RoleID)
  if not Client then
    return
  end
end
function PlayerControllerHeroPropFeature:OnEnterFightState()
  if self.bAutoSelectSkill then
    Game:UIShowTips(self.Owner.PlayerKey, 43759)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerControllerHeroPropFeature)