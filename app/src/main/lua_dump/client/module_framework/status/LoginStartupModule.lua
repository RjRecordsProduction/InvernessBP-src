local ModuleLobbyConfig = require("client.module_framework.lobby.ModuleConfig")
local ModuleCommonConfig = require("client.module_framework.common.ModuleConfig")
local ModuleList = {
  ModuleLobbyConfig.level_unlock_manager,
  ModuleCommonConfig.newbie_download_module,
  ModuleLobbyConfig.audio_system,
  ModuleCommonConfig.logic_gamelet_interface,
  ModuleLobbyConfig.logic_reddot_limitation,
  ModuleCommonConfig.LogicSmartAssistant,
  ModuleCommonConfig.LogicSmartHousekeeper,
  ModuleCommonConfig.LogicPHomeStore,
  ModuleCommonConfig.LogicUserBattleDataManager,
  ModuleCommonConfig.NewFaceSlapSystem,
  ModuleCommonConfig.AdjustSystem,
  ModuleCommonConfig.PushSystem,
  ModuleCommonConfig.LocalPushSystem,
  ModuleLobbyConfig.Libya_module,
  ModuleLobbyConfig.GlideSystem,
  ModuleCommonConfig.logic_home_loading,
  ModuleCommonConfig.store_supply_manager,
  ModuleCommonConfig.NicknameColorManager,
  ModuleCommonConfig.logic_home_joint,
  ModuleCommonConfig.logic_card_collection,
  ModuleLobbyConfig.logic_main_city_enter,
  ModuleLobbyConfig.logic_main_city_music,
  ModuleCommonConfig.passive_resource_downloader,
  ModuleCommonConfig.pool_controller,
  ModuleCommonConfig.logic_post_switch_popup
}
return ModuleList