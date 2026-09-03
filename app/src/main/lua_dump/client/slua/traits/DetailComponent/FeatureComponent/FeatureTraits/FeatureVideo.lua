local FeatureVideo = {}
local Trait = require("common.trait")
local TFeatureVideo = Trait(Trait.TraitPrototype, nil, FeatureVideo)
function FeatureVideo:PlayVideoPure(data, widget)
  local logic_store_enter_feature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_store_enter_feature)
  local result = logic_store_enter_feature:PlayFeatureVideo(data, true, self.switchConfig.closeDirectly, self.switchConfig.bVideoRestoreMusic)
  if result == true then
    self:NotifyOtherFeatureStop(data)
  end
  return result
end
function FeatureVideo:PlayFeatureVideoEmote(data)
  local logic_store_enter_feature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_store_enter_feature)
  local result = logic_store_enter_feature:PlayFeatureVideoEmote(data)
  if result == true then
    self:NotifyOtherFeatureStop(data)
  end
end
function FeatureVideo:StopVideoPure()
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  VideoLibrary.StopVideoPure()
end
return TFeatureVideo