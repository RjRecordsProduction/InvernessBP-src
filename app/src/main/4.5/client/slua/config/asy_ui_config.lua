local base_config = require("client.slua.config.base_config")
local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
local asy_ui_config = {
  DefaultTickFrameIOS = 100,
  DefaultTickFrameAOS = 200,
  DevicePlatformName = nil
}
asy_ui_config.UIConfig = {
  [base_config.NewStoreSystem] = true,
  [base_config.GiveStoreSystem] = true,
  [base_config.NewSupplySystem] = true,
  [base_config.NewSupplySystemJK] = true,
  [base_config.AsyncXSuitSpinContainer] = true,
  [base_config.AsyncXSuitPreviewContainer] = true,
  [base_config.AsyncXSuitExchangeContainer] = true,
  [base_config.AsyncSpinContainerBack] = true,
  [base_config.AsyncSpinContainerMulti] = true,
  [base_config.AsyncSpinContainerMix] = true,
  [base_config.ExchangeContainerMix] = true,
  [base_config.ExchangeContainerBack] = true,
  [base_config.ExchangeContainerBack_Supply] = true,
  [base_config.ExchangeContainerMulti] = true,
  [base_config.AsyncSpinContainerTarotCard] = true,
  [base_config.AsyncExchangeContainerTarotCard] = true,
  [base_config.AdvertisingWheel_Main] = true,
  [base_config.SportsCarSpinContainer] = true,
  [base_config.SportsCarRewardPreviewContainer] = true,
  [base_config.ui_rank] = true,
  [base_config.Lobby_UnknowPass_UIBP_1_0_0] = true,
  [base_config.unknowpass_award] = true,
  [base_config.UnknowPass_Privilege_UIBP] = true,
  [base_config.unknowpass_exchange] = true,
  [base_config.UnknowPass_Buy_1to100_UIBP] = true,
  [base_config.unknowpass_activity_collection_page] = true,
  [base_config.UnknowPass_RecordMain_UIBP] = true,
  [base_config.UnknowPass_ActivePack_UIBP] = true,
  [base_config.unknowpass_mission_sec] = true,
  [base_config.UnknowPass_V2RewardsPreview_UIBP] = true,
  [base_config.UnknowPass_EncoreBoxLottery_New_UIBP] = true,
  [base_config.unknowpass_share] = true,
  [base_config.unknowpass_rank] = true,
  [base_config.roleinfo_main] = true,
  [base_config.wardrobe] = true,
  [base_config.Common_ItemGet_UIBP] = true,
  [base_config.ItemPreview_UIBP] = true,
  [base_config.setting_main] = true,
  [base_config.setting_uielem_layout] = true,
  [base_config.Social_Person_Space_UIBP] = true,
  [base_config.Task_LevelBP] = true,
  [base_config.PlanPH_Store_Main_UIBP] = true,
  [base_config.Lobby_SocialLobby_UIBP] = true,
  [base_config.pet_main] = true,
  [base_config.CharacterMain] = true,
  [base_config.item_upgrade] = true,
  [base_config.XSuit_Workshop_Main_UIBP] = true,
  [base_config.VehicleSystem_Main_UIBP] = true,
  [base_config.mode_selection_main] = true,
  [base_config.ActivityCenter_Main_UIBP] = true,
  [base_config.SpecialOffer_Main_UIBP] = true,
  [base_config.Lobby_Season_Badge_Item_UIBP] = true
}
function asy_ui_config.GetTickFrame()
  if asy_ui_config.DevicePlatformName == nil then
    asy_ui_config.DevicePlatformName = Client and Client.GetDevicePlatformName() or ""
  end
  if asy_ui_config.DevicePlatformName == DevicePlatformNameMacros.IOS then
    return asy_ui_config.DefaultTickFrameIOS
  end
  return asy_ui_config.DefaultTickFrameAOS
end
return asy_ui_config