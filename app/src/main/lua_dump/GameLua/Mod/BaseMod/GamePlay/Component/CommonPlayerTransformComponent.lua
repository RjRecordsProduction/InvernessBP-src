local CommonTransformConfig = require("GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.Config.CommonBornLandTransformConfig")
local CommonPlayerTransformComponent = {}
function CommonPlayerTransformComponent:ServerChooseHeroCheck(HeroID, force)
  print(bWriteLog and "CommonPlayerTransformComponent:ServerChooseHeroCheck:" .. tostring(HeroID))
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local CommonFightTransformConfig = GamePlayTools.GetCurrentConfig("CommonFightTransformConfig")
  if Client or not slua.isValid(self.OwnerActor) then
    return false
  end
  if self.OwnerActor.ModTransformMgrFeature and self.OwnerActor.ModTransformMgrFeature.ServerChooseHeroCheck then
    return self.OwnerActor.ModTransformMgrFeature:ServerChooseHeroCheck(HeroID, force)
  end
  if HeroID == 0 then
    return true
  end
  if self:GetHeroID() ~= 0 then
    if slua.isValid(self.OwnerActor) and self.OwnerActor.ClientDisplayGameTipWithMsgID then
      self.OwnerActor:ClientDisplayGameTipWithMsgID(48532)
    end
    print(bWriteLog and "CommonPlayerTransformComponent:ServerChooseHeroCheck CanntChange InHeroID:" .. tostring(self:GetHeroID()))
    return false
  end
  local Pawn = self:GetCharacter()
  local EPawnState = import("EPawnState")
  if CommonFightTransformConfig:CheckFightTransform(HeroID) and Pawn:AllowState(CommonFightTransformConfig.CommonransformConfig[HeroID].TransformPawnState, true) then
    print(bWriteLog and "CommonPlayerTransformComponent:ServerChooseHeroCheck CurrentStates:" .. tostring(Pawn.CurrentStates))
    return true
  end
  if CommonTransformConfig:CheckCommonBornlandTransform(HeroID) then
    local EGameModeType = import("EGameModeType")
    if CGameState and (CGameState:GetGameModeState() == "ReadyState" or CGameState.GameModeType == EGameModeType.ESocialIsland) then
      local EPawnState = import("EPawnState")
      local Pawn = self.OwnerActor:GetPlayerCharacterSafety()
      if not slua.isValid(Pawn) then
        return false
      end
      local uPlayerState = Pawn:GetPlayerStateSafety()
      if slua.isValid(uPlayerState) and uPlayerState.IsInteractiveStateIdle and not uPlayerState:IsInteractiveStateIdle() then
        print(bWriteLog and "CommonPlayerTransformComponent:ServerChooseHeroCheck IsInteractiveStateIdle not allow")
        if slua.isValid(self.OwnerActor) and self.OwnerActor.ClientDisplayGameTipWithMsgID then
          self.OwnerActor:ClientDisplayGameTipWithMsgID(48532)
        end
        return false
      end
      if slua.isValid(Pawn.SwimComponet) and Pawn.SwimComponet:IsEnterWaterSuface() then
        print(bWriteLog and "ZNQ6thPlayerTransformComponent:ServerChooseHeroCheck inwarter")
        if slua.isValid(self.OwnerActor) and self.OwnerActor.ClientDisplayGameTipWithMsgID then
          self.OwnerActor:ClientDisplayGameTipWithMsgID(48532)
        end
        return false
      end
      if CommonTransformConfig:CheckCommonBornlandTransform(HeroID) and not Pawn:AllowState(EPawnState.Variation, true) then
        print(bWriteLog and "CommonPlayerTransformComponent:ServerChooseHeroCheck CurrentStates:" .. tostring(Pawn.CurrentStates))
        if slua.isValid(self.OwnerActor) and self.OwnerActor.ClientDisplayGameTipWithMsgID then
          self.OwnerActor:ClientDisplayGameTipWithMsgID(48532)
        end
        return false
      end
      return true
    end
    if slua.isValid(self.OwnerActor) and self.OwnerActor.ClientDisplayGameTipWithMsgID then
      self.OwnerActor:ClientDisplayGameTipWithMsgID(48532)
    end
  end
  if slua.isValid(self.OwnerActor) and self.OwnerActor.ClientDisplayGameTipWithMsgID then
    self.OwnerActor:ClientDisplayGameTipWithMsgID(48532)
  end
  return false
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.Library.GamePlay.Component.PlayerTransformComponent")
local CCharacterCarryBackComponent = class(CActorComponentBase, nil, CommonPlayerTransformComponent)
return CCharacterCarryBackComponent