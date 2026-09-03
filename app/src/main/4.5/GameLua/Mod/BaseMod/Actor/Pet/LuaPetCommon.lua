local LuaPetCommon = {}
function LuaPetCommon:OnRefreshPetLevelInfo()
  self.Super:OnRefreshPetLevelInfo()
  self:SetupFightPetParams()
end
local Class = require("class")
local CLuaPetBase = require("GameLua.Mod.BaseMod.Actor.Pet.LuaPetBase")
local CLuaPetCommon = Class(CLuaPetBase, nil, LuaPetCommon)
return CLuaPetCommon