local Collect_Library_UIBP = {}
local C_Sub_Tab_Config = {
  {
    jumpKey = "Clothe",
    configKey = "Collect_Library_Clothe_UIBP",
    textKey = 77566,
    redKey = "clothe"
  },
  {
    jumpKey = "Gun",
    configKey = "Collect_Library_GoodWeaponCar_UIBP",
    textKey = 77490,
    redKey = "gun"
  },
  {
    jumpKey = "Vehicle",
    configKey = "Collect_Library_Vehicle_UIBP",
    textKey = 4663,
    redKey = "vehicle"
  },
  {
    jumpKey = "Pet",
    configKey = "Collect_Library_Pet_UIBP",
    textKey = 65507,
    redKey = "pet"
  }
}
C_Sub_Tab_Config[#C_Sub_Tab_Config + 1] = {
  jumpKey = "Theme",
  configKey = "Collect_Library_Theme_UIBP",
  textKey = 77491,
  redKey = "theme"
}
local GetLocalizeResStr = LocUtil.GetLocalizeResStr
local tabs
function Collect_Library_UIBP:ctor(_, subTabId, personalizeExtraData)
  self.nInitIndex = 1
  self:SetSelectTabIndex(subTabId)
  self.subUI = nil
  self.nIndex = nil
  self.end
function Collect_Library_UIBP:OnInitialize()
  Collect_Library_UIBP.__super.OnInitialize(self)
  self:PlayUserWidgetAnimation(self.UIRoot.FadeIn, 0, 1, 0, 1)
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP = self:InitHorizontalLevelOneTextTab(self.UIRoot.Common_Tab_Horizontal_LevelOne_Text_UIBP)
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:SetTextColor(FSlateColor(FLinearColor(1, 1, 1, 1)), FSlateColor(FLinearColor(1, 1, 1, 0.7)))
  tabs = {}
  for i, cfg in ipairs(C_Sub_Tab_Config) do
    tabs[#tabs + 1] = GetLocalizeResStr(cfg.textKey)
  end
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not collect_module:CanShowTheme() then
    table.remove(tabs)
  end
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:SetTabs(tabs, self.nInitIndex)
end
function Collect_Library_UIBP:RegistEvents()
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:AddOnClickedCallback(self.OnClickedLevelOneTab, self)
  local CollectHandler = require("client.network.Protocol.CollectHandler")
  CollectHandler.send_get_collect_sys_main_data_req()
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_REDDOT, self.RefreshAllRed, self)
  local collect_reddot_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_reddot_module)
  local redData = collect_reddot_module:GetLibraryAvailableRedData()
  log(bWriteLog and string.format("Collect_Library_UIBP:OnGetMainData"))
  for i, subConfig in ipairs(C_Sub_Tab_Config) do
    if subConfig.redKey then
      self:AddDataListener(redData, subConfig.redKey, self.RefreshRed, self, i)
    end
  end
end
function Collect_Library_UIBP:OnPostInitialize()
  self:OnClickedLevelOneTab(nil, self.nInitIndex)
  self:SetWidgetVisible(self.UIRoot.Common_System_Close_UIBP, false)
end
function Collect_Library_UIBP:OnClose()
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  local CollectTab = reddot_node_collect_manager:GetCollectTab()
  reddot_node_collect_manager:HideNodeAllChildNewReddot(CollectTab.collect_library, false)
  reddot_node_collect_manager:HideNodeAllChildBoxReddot(CollectTab.collect_library, false)
  Collect_Library_UIBP.__super.OnClose(self)
end
function Collect_Library_UIBP:GetDataForJumpBack()
  local UI_Config = UIManager.UI_Config
  for _, subConfig in ipairs(C_Sub_Tab_Config) do
    local cfg = UI_Config[subConfig.configKey]
    local ui = UIManager.GetUI(cfg)
    if ui then
      return ui:GetDataForJumpBack()
    end
  end
end
function Collect_Library_UIBP:SetSelectTabIndex(subTabId)
  if type(subTabId) == "string" then
    for i, subConfig in ipairs(C_Sub_Tab_Config) do
      if subConfig.jumpKey == subTabId then
        self.nInitIndex = i
        break
      end
    end
  elseif type(subTabId) == "number" then
    self.nInitIndex = subTabId
  elseif not subTabId then
    local collect_reddot_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_reddot_module)
    for i, subConfig in ipairs(C_Sub_Tab_Config) do
      if collect_reddot_module:CheckLibraryAvailableRedData(subConfig.redKey) then
        self.nInitIndex = i
        log(bWriteLog and string.format("Collect_Library_UIBP:SetSelectTabIndex. select tab with red dot. index: %s tabID: %s", i, subConfig.redKey))
        return
      end
    end
    local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
    for i, cfg in ipairs(C_Sub_Tab_Config) do
      if reddot_node_collect_manager:CheckShowNewReddot(cfg.textKey) then
        self.nInitIndex = i
        log(bWriteLog and string.format("Collect_Library_UIBP:SetSelectTabIndex. select tab with new. index: %s tabID: %s", i, cfg.textKey))
        return
      end
    end
  end
end
function Collect_Library_UIBP:OnClickedLevelOneTab(widget, index)
  log_warning(bWriteLog and "Collect_Library_UIBP:OnClickedLevelOneTab selected index: " .. tostring(index))
  if widget then
    self:PlayAudio(sound_config.tab_v1)
  end
  if self.nIndex == index then
    log_warning(bWriteLog and "  Collect_Library_UIBP:OnClickedLevelOneTab.  the same index")
    return
  end
  self.nIndex = index
  if self.subUI then
    self.subUI:CloseSelf()
  end
  local subConfig = C_Sub_Tab_Config[index]
  if not subConfig then
    log(bWriteLog and string.format("Collect_Library_UIBP:OnClickedLevelOneTab sub config is nil. index = %s", index))
    return
  end
  if self.personalizeExtraData then
    log_tree("  Collect_Library_UIBP:OnClickedLevelOneTab. personalizeExtraData ", self.personalizeExtraData)
    self.subUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_GoodWeaponCar, UIManager.UI_Config[subConfig.configKey], self.personalizeExtraData)
  else
    self.subUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_GoodWeaponCar, UIManager.UI_Config[subConfig.configKey])
  end
  self.personalizeExtraData = nil
end
function Collect_Library_UIBP:RefreshRed(i)
  log_warning(bWriteLog and "  Collect_Library_UIBP:RefreshRed.  ")
  local collect_reddot_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_reddot_module)
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  local reddot_anchor, parentNode = self.Common_Tab_Horizontal_LevelOne_Text_UIBP:GetItemReddotAnchorComponent(i)
  if not reddot_node_collect_manager:ShowNewReddot(parentNode, reddot_anchor, tabs[i]) then
    local isRed = false
    local config = C_Sub_Tab_Config[i]
    if config then
      isRed = collect_reddot_module:CheckLibraryAvailableRedData(config.redKey)
    end
    log_warning(bWriteLog and "  Collect_Library_UIBP:RefreshRed. isRed: " .. tostring(isRed))
    reddot_node_collect_manager:ShowBoxReddot(parentNode, isRed and reddot_anchor, tabs[i])
  end
end
function Collect_Library_UIBP:RefreshAllRed()
  log_warning(bWriteLog and "  Collect_Library_UIBP:RefreshAllRed.  ")
  for i = 1, #tabs do
    self:RefreshRed(i)
  end
end
local class = require("class")
local ui_base = require("GameLua.Mod.Lobby.Split.Collect.umg.CollectBase.Collect_UI_Base")
local CCollect_Library_GunC_UIBP = class(ui_base, nil, Collect_Library_UIBP)
return CCollect_Library_GunC_UIBP