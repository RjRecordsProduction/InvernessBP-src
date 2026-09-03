local EAttachUIType = {
  Newbie = 1,
  Return = 2,
  UGC_Edit = 3,
  UGC_Multi = 4
}
local loading_attach_ui_config = {
  [EAttachUIType.UGC_Edit] = {
    guideType = EAttachUIType.UGC_Edit,
    uiConfig = UIManager.UI_Config.UGCEdit_Loading_Attach_UIBP,
    priority = 40,
    showFunc = function()
      local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
      return LogicUGC:IsShowLoadingEditAttachUI()
    end
  },
  [EAttachUIType.UGC_Multi] = {
    guideType = EAttachUIType.UGC_Multi,
    uiConfig = UIManager.UI_Config.UGCMulti_Loading_Attach_UIBP,
    priority = 30,
    showFunc = function()
      local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
      return LogicUGC:IsShowLoadingMultiAttachUI()
    end
  },
  [EAttachUIType.Newbie] = {
    guideType = EAttachUIType.Newbie,
    uiConfig = UIManager.UI_Config.Newbie_Loading_Guide_UIBP,
    priority = 20,
    showFunc = function(main_mode)
      local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
      return logic_newbie_mode_selection:IsNeedShowLoadingGuide(main_mode)
    end
  },
  [EAttachUIType.Return] = {
    guideType = EAttachUIType.Newbie,
    uiConfig = UIManager.UI_Config.Return_Loading_Guide_UIBP,
    priority = 10,
    showFunc = function(main_mode)
      local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
      return logic_return_activity:IsNeedShowLoadingGuide(main_mode)
    end
  }
}
loading_attach_ui_config.return loading_attach_ui_config