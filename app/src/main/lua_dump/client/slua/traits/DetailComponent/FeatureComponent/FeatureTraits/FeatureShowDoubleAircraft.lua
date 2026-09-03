local FeatureShowDoubleAircraft = {}
local Trait = require("common.trait")
local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
local TFeatureShowDoubleAircraft = Trait(Trait.TraitPrototype, nil, FeatureShowDoubleAircraft)
function FeatureShowDoubleAircraft:ShowDoubleAircraft(data)
  self.glideID = tonumber(data.config.PathOne)
  print(bWriteLog and "FeatureShowDoubleAircraft:ShowDoubleAircraft self.glideID" .. tostring(self.glideID))
  self:NotifyOtherFeatureStop(data)
  local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
  local GlideSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GlideSystem)
  GlideSystem:EnterGlideScene(66, ModelDisplayer.GetShowingAvatar(), true)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Display(self.glideID, true)
end
function FeatureShowDoubleAircraft:HideDoubleAircraft()
  log(bWriteLog and "FeatureShowDoubleAircraft:HideDoubleAircraft self.glideID" .. tostring(self.glideID))
  if not self.glideID or self.glideID <= 0 then
    return
  end
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Display(self.glideID, false)
  self.glideID = -1
  local GlideSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GlideSystem)
  GlideSystem:ExitGlideScene(66)
end
return TFeatureShowDoubleAircraft