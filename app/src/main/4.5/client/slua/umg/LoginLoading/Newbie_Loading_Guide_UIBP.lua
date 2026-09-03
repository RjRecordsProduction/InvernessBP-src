local Newbie_Loading_Guide_UIBP = {}
local loading_macro = require("client.slua.logic.loading.loading_macro")
function Newbie_Loading_Guide_UIBP:ctor()
end
function Newbie_Loading_Guide_UIBP:OnInitialize()
end
function Newbie_Loading_Guide_UIBP:RegistEvents()
end
function Newbie_Loading_Guide_UIBP:OnPostInitialize()
  self:UpdateUI()
end
function Newbie_Loading_Guide_UIBP:OnClose()
end
function Newbie_Loading_Guide_UIBP:UpdateUI()
  log(bWriteLog and "Newbie_Loading_Guide_UIBP:UpdateUI")
  self:UpdateNewbieLoadingUI()
end
function Newbie_Loading_Guide_UIBP:UpdateNewbieLoadingUI()
  local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
  local guideType = logic_newbie_mode_selection:GetLoadingGuideType()
  if guideType then
    if guideType == loading_macro.ENewbieGuideType.Train or guideType == loading_macro.ENewbieGuideType.Second then
      local NewbieLoadingConfig = CDataTable.GetTableData("NewbieLoadingConfig", 1)
      if NewbieLoadingConfig then
        self:SetWidgetVisible(self.UIRoot.CanvasPanel_Newbie, true)
        self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
        self.UIRoot.TextBlockTitle1:SetText(LocUtil.GetLocalizeResStr(NewbieLoadingConfig.Title))
        self.UIRoot.TextBlockDesc1:SetText(LocUtil.GetLocalizeResStr(NewbieLoadingConfig.Desc))
        self.UIRoot.TextBlockTip1:SetText(LocUtil.GetLocalizeResStr(NewbieLoadingConfig.Desc1))
        self.UIRoot.TextBlockTip2:SetText(LocUtil.GetLocalizeResStr(NewbieLoadingConfig.Desc2))
        self.UIRoot.TextBlockTip3:SetText(LocUtil.GetLocalizeResStr(NewbieLoadingConfig.Desc3))
        local img_path = NewbieLoadingConfig.ImgPath
        self:RefreshImageTex(self.UIRoot.ImageNewbie1, img_path)
      end
    elseif guideType == loading_macro.ENewbieGuideType.First then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Newbie, true)
      self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(1)
      for i = 2, 4 do
        local NewbieLoadingConfig = CDataTable.GetTableData("NewbieLoadingConfig", i)
        if NewbieLoadingConfig then
          self.UIRoot["TextBlockTitle" .. tostring(i)]:SetText(LocUtil.GetLocalizeResStr(NewbieLoadingConfig.Title))
          self.UIRoot["TextBlockDesc" .. tostring(i)]:SetText(LocUtil.GetLocalizeResStr(NewbieLoadingConfig.Desc))
          local img_path = NewbieLoadingConfig.ImgPath
          self:RefreshImageTex(self.UIRoot["ImageNewbie" .. tostring(i)], img_path)
        end
      end
    elseif guideType == loading_macro.ENewbieGuideType.Advanced then
      local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
      local logic_mode_mgr = require("client.slua.logic.match.logic_mode_mgr")
      local view_id = logic_mode_utils.GetViewIDByModeID(logic_mode_mgr.nInGameModeID)
      local loading_module_id = logic_newbie_mode_selection:GetLoadingID(view_id)
      log(bWriteLog and string.format("UI_Loading:UpdateNewbieLoadingUI nInGameModeID[%s] viewID[%s] loadingModuleID[%s]", tostring(logic_mode_mgr.nInGameModeID), tostring(view_id), tostring(loading_module_id)))
      if 0 < loading_module_id then
        self:SetWidgetVisible(self.UIRoot.CanvasPanel_Newbie, true)
        self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(1)
        self:UpdateNewbieLoadingUIByLoadingModuleID(loading_module_id)
      end
    end
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Newbie, false)
  end
end
function Newbie_Loading_Guide_UIBP:UpdateNewbieLoadingUIByLoadingModuleID(loading_module_id)
  log(bWriteLog and "UpdateNewbieLoadingUIByLoadingModuleID loading_module_id " .. tostring(loading_module_id))
  local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
  local loading_cfg = logic_newbie_mode_selection:GetLoadingCfgByLoadingModuleID(loading_module_id)
  log_tree("UpdateNewbieLoadingUIByLoadingModuleID loading_cfg", loading_cfg)
  if loading_cfg then
    local widget_index = 2
    for k, NewbieLoadingConfig in pairs(loading_cfg) do
      self.UIRoot["TextBlockTitle" .. tostring(widget_index)]:SetText(LocUtil.GetLocalizeResStr(NewbieLoadingConfig.Title))
      self.UIRoot["TextBlockDesc" .. tostring(widget_index)]:SetText(LocUtil.GetLocalizeResStr(NewbieLoadingConfig.Desc))
      local img_path = NewbieLoadingConfig.ImgPath
      self:RefreshImageTex(self.UIRoot["ImageNewbie" .. tostring(widget_index)], img_path)
      widget_index = widget_index + 1
    end
  end
end
function Newbie_Loading_Guide_UIBP:RefreshImageTex(imgWidget, imgPath)
  if not imgWidget then
    return
  end
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  self:SetTexture(imgWidget, imgPath, {
    sync = true,
    defaultIcon = LoadingSystem.GetDefaultPath()
  })
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Newbie_Loading_Guide_UIBP)