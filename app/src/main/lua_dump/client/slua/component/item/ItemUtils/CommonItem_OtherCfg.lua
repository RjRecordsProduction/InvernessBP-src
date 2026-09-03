local CommonItem_OtherCfg = {
  tSpecialItemShowJumpCfg = {
    [1024] = {
      sJumpClickTxtKey = 9018,
      fJumpCallback = function()
        local Theme_TreasureHuntingTask02_UIBP = UIManager.GetUI(UIManager.UI_Config.Theme_TreasureHuntingTask02_UIBP)
        if Theme_TreasureHuntingTask02_UIBP then
          Theme_TreasureHuntingTask02_UIBP:CloseSelf()
        end
        local store_uc_direct_purchase_gift_popup = UIManager.GetUI(UIManager.UI_Config.store_uc_direct_purchase_gift_popup)
        if store_uc_direct_purchase_gift_popup then
          store_uc_direct_purchase_gift_popup:CloseSelf()
        end
        local CardCollection_DailyTask_Popup_UIBP = UIManager.GetUI(UIManager.UI_Config.CardCollection_DailyTask_Popup_UIBP)
        if CardCollection_DailyTask_Popup_UIBP then
          CardCollection_DailyTask_Popup_UIBP:CloseSelf()
        end
        local CardCollection_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.CardCollection_Main_UIBP)
        if CardCollection_Main_UIBP then
          CardCollection_Main_UIBP:CloseSelf()
        end
        local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
        ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_THEME_SYSTEM, {tab = "exchange"})
      end
    }
  }
}
return CommonItem_OtherCfg