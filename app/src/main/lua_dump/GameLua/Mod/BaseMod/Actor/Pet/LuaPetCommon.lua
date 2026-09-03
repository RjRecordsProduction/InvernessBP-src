local LuaPetCommon = {}
function LuaPetCommon:OnRefreshPetLevelInfo()
  self.Super:OnRefreshPetLevelInfo()
  self:SetupFightPetParams()
end
function LuaPetCommon:SetupFightPetParams()
  LuaPetCommon.__super.SetupFightPetParams(self)
  local FightPetParamsCfg = self.FightPetParamsCfg
  if not FightPetParamsCfg then
    return
  end
  local SwimOffsetLocation = self:ParseStrToFVector(FightPetParamsCfg.SwimOffsetLocation, FVector.ZeroVector)
  self.SwimOffset = SwimOffsetLocation
  local SwimCheckLocation = self:ParseStrToFVector(FightPetParamsCfg.SwimCheckLocation, FVector.ZeroVector)
  local SwimCheckRotation = self:ParseStrToFRotator(FightPetParamsCfg.SwimCheckRotation, FRotator.ZeroRotator)
  local SwimCheckScale = self:ParseStrToFVector(FightPetParamsCfg.SwimCheckScale, FVector.OneVector)
  if slua.isValid(self.SwimCheck) then
    self.SwimCheck:K2_SetRelativeTransform(FTransform(SwimCheckRotation, SwimCheckLocation, SwimCheckScale), false, nil, false)
  end
end
local Class = require("class")
local CLuaPetBase = require("GameLua.Mod.BaseMod.Actor.Pet.LuaPetBase")
local CLuaPetCommon = Class(CLuaPetBase, nil, LuaPetCommon)
return CLuaPetCommon