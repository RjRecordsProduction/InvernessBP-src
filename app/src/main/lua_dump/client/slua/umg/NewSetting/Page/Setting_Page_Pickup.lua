local Setting_Page_Pickup = {}
local SettingSharedUtils = require("client.logic.NewSetting.SettingSharedUtils")
local UIUtil = require("client.common.ui_util")
local WeaponTypeDisplayOrder = {
  1,
  3,
  2,
  4,
  5,
  6,
  7,
  9
}
local ModTab = {
  Classic = 1,
  Season = 2,
  TPlan = 3
}
local GetItemName = function(ItemID)
  local ItemConfig = CDataTable.GetTableData("Item", ItemID)
  return UIUtil.GetLocalizationString(ItemConfig and ItemConfig.ItemName or "")
end
local GetArmorySimpDesc = function(ItemID)
  local WeaponDescCfg = CDataTable.GetTableData("ArmoryDescConfig", ItemID)
  return WeaponDescCfg and UIUtil.GetLocalizationString(WeaponDescCfg.ArmorySimpleDesc) or ""
end
local CollectItemData = function(DataArray, ItemIDList, bTPlan)
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  for Index, ID in ipairs(ItemIDList) do
    local PickupCountSetting = CDataTable.GetTableData("PickUpCountSetting", ID)
    if PickupCountSetting then
      local MaxCount = bTPlan and 1000 or PickupCountSetting.PickUpMaxCount
      local Data = DataArray[Index] or {}
      Data.      Data.Text = GetItemName(ID)
      Data.SubText = ""
      Data.Max = MaxCount
      Data.Min = 0
      Data.Value = SettingSharedUtils.GetUserAutoLootCount(SettingConfig, ID, bTPlan)
      DataArray[Index] = Data
    end
  end
end
local LoadItemData = function(LoopScrollBox, ItemIDList, ...)
  CollectItemData(LoopScrollBox:GetSetData(), ItemIDList, ...)
  LoopScrollBox:SetData(LoopScrollBox:GetSetData())
end
local SaveUserValue = function(LoopScrollBox, PickupSettingMap)
  local DataArray = LoopScrollBox:GetSetData()
  local Len = #DataArray
  for i = 1, Len do
    local data = DataArray[i]
    if data.ID and data.Value then
      PickupSettingMap:Add(data.ID, data.Value)
    end
  end
end
local BuildRecommendMap = function(recommendItems)
  local map = {}
  if recommendItems then
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    for _, item in ipairs(recommendItems) do
      local currentValue = SettingSharedUtils.GetUserAutoLootCount(SettingConfig, item.id)
      if currentValue ~= item.recommendValue then
        map[item.id] = item.recommendValue
      end
    end
  end
  return map
end
local MarkHighlightInScrollBox = function(loopScrollBox, recommendMap)
  if not loopScrollBox then
    return
  end
  local dataArray = loopScrollBox:GetSetData()
  local changed = false
  for _, data in ipairs(dataArray) do
    local recommendValue = recommendMap[data.ID]
    local shouldHighlight = recommendValue ~= nil
    if data.bHighlight ~= shouldHighlight then
      data.bHighlight = shouldHighlight
      data.RecommendValue = recommendValue
      changed = true
    end
  end
  if changed then
    loopScrollBox:SetData(dataArray)
  end
end
local ClearHighlightInScrollBox = function(loopScrollBox)
  if not loopScrollBox then
    return
  end
  local dataArray = loopScrollBox:GetSetData()
  local changed = false
  for _, data in ipairs(dataArray) do
    if data.bHighlight then
      data.bHighlight = false
      data.RecommendValue = nil
      changed = true
    end
  end
  if changed then
    loopScrollBox:SetData(dataArray)
  end
end
local BuildTrackableItemSet = function()
  local set = {}
  for _, id in ipairs(SettingSharedUtils.AidList) do
    set[id] = true
  end
  for _, id in ipairs(SettingSharedUtils.ThrowList) do
    set[id] = true
  end
  for _, id in ipairs(SettingSharedUtils.ScopeList) do
    set[id] = true
  end
  return set
end
function Setting_Page_Pickup:OnInitialize()
  Setting_Page_Pickup.__super.OnInitialize(self)
  self.bLoadStackByFrame = false
  self:SetWidgetVisible(self.UIRoot.VerticalBox_Sliders, false)
  self._adjustedItemSet = {}
  self._robotTipsTriggered = false
  self._trackableItemSet = BuildTrackableItemSet()
  self:InitItemWithWidget(self.UIRoot.Setting_Title_Ammo, {
    UI = UIManager.UI_Config.Setting_Title,
    Text = 4301686
  })
  self:InitItemWithWidget(self.UIRoot.Setting_Title_AC, {
    UI = UIManager.UI_Config.Setting_Title,
    Text = 29929,
    Help = 29930
  })
  self:InitItemWithWidget(self.UIRoot.Setting_Title_Aid, {
    UI = UIManager.UI_Config.Setting_Title,
    Text = 29933
  })
  self:InitItemWithWidget(self.UIRoot.Setting_Title_Throw, {
    UI = UIManager.UI_Config.Setting_Title,
    Text = 29934
  })
  self:InitItemWithWidget(self.UIRoot.Setting_Title_Scope, {
    UI = UIManager.UI_Config.Setting_Title,
    Text = 29935
  })
  local TabList = {
    ModTab.Classic
  }
  local ModTabText = {
    [ModTab.Classic] = LocUtil.GetLocalizeResStr(110244),
    [ModTab.TPlan] = LocUtil.GetLocalizeResStr(11625),
    [ModTab.Season] = LocUtil.GetLocalizeResStr(24798)
  }
  self.Common_Tab_Ammo = self:InitHorizontalSmallTextTab(self.UIRoot.Common_Tab_Ammo)
  local ItemLuaClass = "client.slua.umg.NewSetting.Pickup.Setting_Pickup_Item"
  self.LoopScrollBox_Ammo = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Ammo, ItemLuaClass)
  self.LoopScrollBox_Aid = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Aid, ItemLuaClass)
  self.LoopScrollBox_Throw = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Throw, ItemLuaClass)
  self.LoopScrollBox_Scope = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Scope, ItemLuaClass)
  local logic_xmission_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_entrance)
  if logic_xmission_entrance:IsTxMissionOpen() and not IsWoWEditor then
    table.insert(TabList, ModTab.TPlan)
  end
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local bShowSink = GameMainConfig.GetModType() == "Sink2"
  if bShowSink then
    self.LoopScrollBox_AC = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_AC, ItemLuaClass)
  end
  local TabTextList = {}
  for i, k in ipairs(TabList) do
    TabTextList[i] = ModTabText[k]
  end
  self.CommonTab_Mod = self:InitHorizontalLevelTwoTextTab(self.UIRoot.CommonTab_Mod, {bDarkMode = true})
  self.CommonTab_Mod:SetTabs(TabTextList)
  self.CommonTab_Mod:AddOnClickedCallback(function(_self, widget, index)
    self:SwitchModTab(TabList[index], true)
  end)
  self.Mod  self:SwitchModTab(ModTab.Classic)
  self.CurrentModTab = ModTab.Classic
  SettingSharedUtils.SetSeasonAutoLoot()
end
function Setting_Page_Pickup:RegistEvents()
  self:AddControlEventByControl(self.UIRoot.btn_Recoverydefault, "OnClicked", self.OnClickRecoveryDefault, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_SWITCHER_EXPAND, self.OnSwitcherExpand, self)
  self:AddCommonEvent(EVENTTYPE_SMARTASSISTANT, EVENTID_SA_ROBOT_PREVIEW, self.OnRobotPreview, self)
  self:AddCommonEvent(EVENTTYPE_SMARTASSISTANT, EVENTID_SA_ROBOT_APPLY, self.OnRobotApply, self)
  self:AddCommonEvent(EVENTTYPE_SMARTASSISTANT, EVENTID_SA_ROBOT_UNDO, self.OnRobotUndo, self)
end
function Setting_Page_Pickup:OnClose()
  if not GameStatus.IsInLobbyOrMainCity() then
    print(bWriteLog and "Setting_Page_Pickup:Close ClearItemUsefulCache ", slua.isValid(CGameWorld))
    if slua.isValid(CGameWorld) then
      local BackpackUtils = import("BackpackUtils")
      BackpackUtils.ClearAllItemUsefulCache(CGameWorld)
    end
  end
  self:SaveCurrentModTab()
  self:CloseSmartAssistantRobotTips()
  Setting_Page_Pickup.__super.OnClose(self)
end
function Setting_Page_Pickup:CloseSmartAssistantRobotTips()
  if UIManager.GetUI(UIManager.UI_Config.SmartAssistant_RobotTips01_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.SmartAssistant_RobotTips01_UIBP)
  end
end
function Setting_Page_Pickup:OnStackLoaded()
  self.UIRoot.ScrollBox_Stack:AddChild(self.UIRoot.VerticalBox_Sliders)
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  self:SetWidgetVisible(self.UIRoot.VerticalBox_Sliders, SettingModule:GetOptionValue("AutoPickupSwitcher"))
  local LogicSA = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  local ui = UIManager.GetUI(UIManager.UI_Config.SmartAssistant_RobotTips01_UIBP)
  if ui then
    local isInPreview, highlightIDs = LogicSA:GetPickupPreviewState()
    if isInPreview and highlightIDs then
      self._bRobotPreviewing = true
      self._robotRecommendMap = highlightIDs
      MarkHighlightInScrollBox(self.LoopScrollBox_Ammo, highlightIDs)
      MarkHighlightInScrollBox(self.LoopScrollBox_Aid, highlightIDs)
      MarkHighlightInScrollBox(self.LoopScrollBox_Throw, highlightIDs)
      MarkHighlightInScrollBox(self.LoopScrollBox_Scope, highlightIDs)
      if self.LoopScrollBox_AC then
        MarkHighlightInScrollBox(self.LoopScrollBox_AC, highlightIDs)
      end
      self:ScrollToFirstHighlightItem(highlightIDs)
      return
    end
  end
  local directSceneType = LogicSA:ConsumeDirectPreviewSceneType()
  if directSceneType == 1 then
    self._robotTipsTriggered = true
    self:TryShowRobotTips(true)
    return
  end
end
function Setting_Page_Pickup:TryShowRobotTips(bDirectPreview)
  printf("Setting_Page_Pickup:TryShowRobotTips bDirectPreview:%s", tostring(bDirectPreview))
  local LogicSA = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  local isInCD, remainSec = LogicSA:IsRobotInCD(1)
  if isInCD then
    printf("Setting_Page_Pickup:TryShowRobotTips scene:1 in CD, remain:%ss, skip", remainSec)
    return
  end
  local cachedData = LogicSA:GetCachedRecommendData(1)
  if cachedData then
    printf("Setting_Page_Pickup:TryShowRobotTips using cached data")
    self:_HandleRecommendData(cachedData, bDirectPreview)
    return
  end
  local SmartAssistantHandler = require("client.network.Protocol.SmartAssistantHandler")
  SmartAssistantHandler.send_load_auto_equipment_req(1):Then(function(err_code, sceneType, recom_items)
    if not slua.isValid(self.UIRoot) then
      printf("Setting_Page_Pickup:TryShowRobotTips UI already destroyed, skip")
      return
    end
    local recommendData = LogicSA:GetCachedRecommendData(sceneType or 1)
    if not recommendData then
      printf("[WARN] Setting_Page_Pickup:TryShowRobotTips no cached data after rsp")
      return
    end
    self:_HandleRecommendData(recommendData, bDirectPreview)
  end)
end
function Setting_Page_Pickup:_HandleRecommendData(recommendData, bDirectPreview)
  if not (recommendData and recommendData.items) or #recommendData.items <= 0 then
    printf("Setting_Page_Pickup:_HandleRecommendData no recommend data, skip")
    return
  end
  local LogicSA = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  if not LogicSA:HasDiffWithLocalSettings(recommendData) then
    printf("Setting_Page_Pickup:_HandleRecommendData no diff with local settings, skip robot")
    return
  end
  printf("Setting_Page_Pickup:_HandleRecommendData diff found, ShowUI bDirectPreview:%s", tostring(bDirectPreview))
  UIManager.ShowUI(UIManager.UI_Config.SmartAssistant_RobotTips01_UIBP, recommendData, bDirectPreview or false)
end
function Setting_Page_Pickup:OnSwitcherExpand(_, __, key, bExpand)
  if key == "AutoPickupSwitcher" then
    local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
    self:SetWidgetVisible(self.UIRoot.VerticalBox_Sliders, SettingModule:GetOptionValue("AutoPickupSwitcher"))
  end
end
function Setting_Page_Pickup:SaveCurrentModTab()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if self.CurrentModTab == ModTab.Classic then
    SaveUserValue(self.LoopScrollBox_Ammo, SettingConfig.PickUpCountSetting)
    SaveUserValue(self.LoopScrollBox_Aid, SettingConfig.PickUpCountSetting_Drug)
    SaveUserValue(self.LoopScrollBox_Throw, SettingConfig.PickUpCountSetting_ThrowObj)
    SaveUserValue(self.LoopScrollBox_Scope, SettingConfig.PickUpCountSetting_MultipleMirror)
    if self.LoopScrollBox_AC then
      self:SaveACCount()
    end
  elseif self.CurrentModTab == ModTab.TPlan then
    SaveUserValue(self.LoopScrollBox_Ammo, SettingConfig.BulletPickUpCountSetting_XT)
    SaveUserValue(self.LoopScrollBox_Aid, SettingConfig.Drug_PickUpCountSetting_XT)
    SaveUserValue(self.LoopScrollBox_Throw, SettingConfig.ThrowObj_PickUpCountSetting_XT)
    SaveUserValue(self.LoopScrollBox_Scope, SettingConfig.MultipleMirror_PickUpCountSetting_XT)
  elseif self.CurrentModTab == ModTab.Season then
    SaveUserValue(self.LoopScrollBox_Season, SettingConfig.PickUpCountSetting_Season)
  end
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function Setting_Page_Pickup:SaveACCount()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local DataArray = self.LoopScrollBox_AC:GetSetData()
  local Len = #DataArray
  for i = 1, Len do
    local data = DataArray[i]
    if data.ID and data.Value then
      SettingConfig.DefaultACCount:Set(data.ID, data.Value)
    end
  end
end
function Setting_Page_Pickup:SwitchModTab(CurrentSelectTabType, bPlayClickSound)
  if self.CurrentModTab == CurrentSelectTabType then
    return
  end
  self:SaveCurrentModTab()
  self.CurrentModTab = CurrentSelectTabType
  if self.CurrentModTab == ModTab.Classic then
    self.UIRoot.WidgetSwitcher_ModeSetting:SetActiveWidgetIndex(0)
    local TextList = {}
    for _, i in ipairs(WeaponTypeDisplayOrder) do
      table.insert(TextList, LocUtil.GetLocalizeResStr(SettingSharedUtils.WeaponTypeName[i]))
    end
    self.Common_Tab_Ammo:SetTabs(TextList)
    self.Common_Tab_Ammo:AddOnClickedCallback(self.RefreshClassicGunSliders, self)
  elseif self.CurrentModTab == ModTab.TPlan then
    self.UIRoot.WidgetSwitcher_ModeSetting:SetActiveWidgetIndex(0)
    local TextList = {
      "9mm",
      "7.62",
      "5.56",
      LocUtil.GetLocalizeResStr(4064),
      ".45",
      "5.7",
      ".300",
      ".50",
      LocUtil.GetLocalizeResStr(51422)
    }
    self.Common_Tab_Ammo:SetTabs(TextList)
    self.Common_Tab_Ammo:AddOnClickedCallback(self.RefreshTPlanAmmoSliders, self)
  elseif self.CurrentModTab == ModTab.Season then
    self.UIRoot.WidgetSwitcher_ModeSetting:SetActiveWidgetIndex(1)
  end
  self:RefreshPickupSliders()
  if bPlayClickSound then
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudio(sound_config.click_v1)
  end
end
function Setting_Page_Pickup:RefreshPickupSliders()
  if self.CurrentModTab == ModTab.Classic then
    self:RefreshClassicGunSliders(nil, self.Common_Tab_Ammo:GetSelectedIndex())
    LoadItemData(self.LoopScrollBox_Aid, SettingSharedUtils.AidList)
    LoadItemData(self.LoopScrollBox_Throw, SettingSharedUtils.ThrowList)
    LoadItemData(self.LoopScrollBox_Scope, SettingSharedUtils.ScopeList)
  elseif self.CurrentModTab == ModTab.TPlan then
    self:RefreshTPlanAmmoSliders(nil, self.Common_Tab_Ammo:GetSelectedIndex())
    LoadItemData(self.LoopScrollBox_Aid, SettingSharedUtils.AidList, true)
    LoadItemData(self.LoopScrollBox_Throw, SettingSharedUtils.ThrowList, true)
    LoadItemData(self.LoopScrollBox_Scope, SettingSharedUtils.ScopeList, true)
  elseif self.CurrentModTab == ModTab.Season then
    self:RefreshSeasonSliders()
  end
end
function Setting_Page_Pickup:RefreshClassicGunSliders(widget, index)
  if self.Common_Tab_Ammo._last_index ~= index then
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    SaveUserValue(self.LoopScrollBox_Ammo, SettingConfig.PickUpCountSetting)
    if self.LoopScrollBox_AC then
      self:SaveACCount()
    end
  end
  local DataArray = self.LoopScrollBox_Ammo:GetSetData()
  local LastSize = #DataArray
  local Index = 1
  local _WeaponType = WeaponTypeDisplayOrder[index]
  local _ArmoryTable = CDataTable.GetTableByFilter("ArmoryConfig", "WeaponType", _WeaponType)
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  for key, Row in pairs(_ArmoryTable) do
    if not SettingSharedUtils.IgnoreWeapon[Row.WeaponID] then
      local PickupCountSetting = CDataTable.GetTableData("PickUpCountSetting", key)
      if PickupCountSetting then
        local Data = DataArray[Index] or {}
        Data.ID = Row.WeaponID
        Data.Text = GetArmorySimpDesc(Row.WeaponID)
        Data.SubText = GetItemName(Row.BulletID)
        Data.Max = PickupCountSetting.PickUpMaxCount
        Data.Min = 0
        Data.Value = SettingSharedUtils.GetUserAutoLootCount(SettingConfig, Row.WeaponID)
        DataArray[Index] = Data
        Index = Index + 1
      end
    end
  end
  for i = Index, LastSize do
    DataArray[i] = nil
  end
  self.LoopScrollBox_Ammo:SetData(DataArray)
  self.Common_Tab_Ammo._last_  if self.LoopScrollBox_AC then
    local LuaArrayIndex = _WeaponType
    self.UIRoot.VerticalBox_AC:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.LoopScrollBox_AC:SetData({
      {
        ID = LuaArrayIndex,
        Text = LocUtil.GetLocalizeResStr(87908),
        SubText = "",
        Max = SettingConfig.MaxACCount:Get(LuaArrayIndex),
        Min = 0,
        Value = SettingConfig.DefaultACCount:Get(LuaArrayIndex)
      }
    })
  else
    self.UIRoot.VerticalBox_AC:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Setting_Page_Pickup:RefreshTPlanAmmoSliders(widget, index)
  if self.Common_Tab_Ammo._last_index ~= index then
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    SaveUserValue(self.LoopScrollBox_Ammo, SettingConfig.BulletPickUpCountSetting_XT)
  end
  local DataArray = self.LoopScrollBox_Ammo:GetSetData()
  local LastSize = #DataArray
  local NewSize = #SettingSharedUtils.TPlanAmmoTable[index]
  CollectItemData(DataArray, SettingSharedUtils.TPlanAmmoTable[index])
  for i = NewSize + 1, LastSize do
    DataArray[i] = nil
  end
  self.LoopScrollBox_Ammo:SetData(DataArray)
  self.Common_Tab_Ammo._last_  self.UIRoot.VerticalBox_AC:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function Setting_Page_Pickup:RefreshSeasonSliders()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local DataArray = self.LoopScrollBox_Season:GetSetData()
  for Index, ID in ipairs(self.SeasonItemIDList) do
    local Value = SettingConfig.PickUpCountSetting_Season:Get(ID)
    local SeasonPickUpCountSetting = CDataTable.GetTableData("SeasonPickUpCountSetting", ID)
    if SeasonPickUpCountSetting and Value then
      local Data = DataArray[Index] or {}
      Data.      Data.Text = GetItemName(ID)
      Data.Desc = SeasonPickUpCountSetting.Description
      Data.Icon = SeasonPickUpCountSetting.IconPath
      Data.Max = SeasonPickUpCountSetting.PickUpMaxCount
      Data.Min = 0
      Data.      DataArray[Index] = Data
    end
  end
  self.LoopScrollBox_Season:SetData(DataArray)
end
function Setting_Page_Pickup:OnClickRecoveryDefault()
  self:PlayAudio(sound_config.click_v1)
  local ConfirmReset = function()
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    local UGameplayStatics = import("GameplayStatics")
    local SettingConfigClass = import("/Game/BluePrints/Config/SettingConfig.SettingConfig_C")
    local DefaultSettingConfig = UGameplayStatics.CreateSaveGameObject(SettingConfigClass)
    if self.CurrentModTab == ModTab.Classic then
      SettingConfig.PickUpCountSetting = DefaultSettingConfig.PickUpCountSetting
      SettingConfig.PickUpCountSetting_Drug = DefaultSettingConfig.PickUpCountSetting_Drug
      SettingConfig.PickUpCountSetting_ThrowObj = DefaultSettingConfig.PickUpCountSetting_ThrowObj
      SettingConfig.PickUpCountSetting_MultipleMirror = DefaultSettingConfig.PickUpCountSetting_MultipleMirror
      SettingConfig.DefaultACCount = DefaultSettingConfig.DefaultACCount
      SettingConfig.LimitViscidityBomb = 2
      slua_GameFrontendHUD:FinishModifyUserSettings()
    elseif self.CurrentModTab == ModTab.Season then
      SettingConfig.PickUpCountSetting_Season = DefaultSettingConfig.PickUpCountSetting_Season
      SettingSharedUtils.SetSeasonAutoLoot()
      slua_GameFrontendHUD:FinishModifyUserSettings()
    elseif self.CurrentModTab == ModTab.TPlan then
      SettingConfig.BulletPickUpCountSetting_XT = DefaultSettingConfig.BulletPickUpCountSetting_XT
      SettingConfig.Drug_PickUpCountSetting_XT = DefaultSettingConfig.Drug_PickUpCountSetting_XT
      SettingConfig.NormalInfilling_PickUpCountSetting_XT = DefaultSettingConfig.NormalInfilling_PickUpCountSetting_XT
      SettingConfig.HalloweenInfilling_PickUpCountSetting_XT = DefaultSettingConfig.HalloweenInfilling_PickUpCountSetting_XT
      SettingConfig.ThrowObj_PickUpCountSetting_XT = DefaultSettingConfig.ThrowObj_PickUpCountSetting_XT
      SettingConfig.MultipleMirror_PickUpCountSetting_XT = DefaultSettingConfig.MultipleMirror_PickUpCountSetting_XT
      slua_GameFrontendHUD:FinishModifyUserSettings()
    end
    self:RefreshPickupSliders()
    SettingConfigClass = nil
    DefaultSettingConfig = nil
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(116016), ConfirmReset, nil)
end
function Setting_Page_Pickup:OnItemValueChanged(itemID)
  if self._robotTipsTriggered then
    return
  end
  if self.CurrentModTab ~= ModTab.Classic then
    return
  end
  if not self._trackableItemSet[itemID] then
    return
  end
  self._adjustedItemSet[itemID] = true
  local count = 0
  for _ in pairs(self._adjustedItemSet) do
    count = count + 1
  end
  if 2 <= count then
    self._robotTipsTriggered = true
    self:TryShowRobotTips()
  end
end
function Setting_Page_Pickup:OnRobotPreview(_, __, sceneType, bEnter, recommendItems)
  if sceneType ~= 1 then
    return
  end
  local LogicSA = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  if bEnter and recommendItems then
    local recommendMap = BuildRecommendMap(recommendItems)
    MarkHighlightInScrollBox(self.LoopScrollBox_Ammo, recommendMap)
    MarkHighlightInScrollBox(self.LoopScrollBox_Aid, recommendMap)
    MarkHighlightInScrollBox(self.LoopScrollBox_Throw, recommendMap)
    MarkHighlightInScrollBox(self.LoopScrollBox_Scope, recommendMap)
    if self.LoopScrollBox_AC then
      MarkHighlightInScrollBox(self.LoopScrollBox_AC, recommendMap)
    end
    self:ScrollToFirstHighlightItem(recommendMap)
    self._bRobotPreviewing = true
    self._robotRecommendMap = recommendMap
    LogicSA:SetPickupPreviewState(true, recommendMap)
  else
    self:ClearAllHighlight()
    self._bRobotPreviewing = false
    self._robotRecommendMap = nil
    LogicSA:SetPickupPreviewState(false, nil)
  end
end
function Setting_Page_Pickup:OnRobotApply(_, __, sceneType, recommendItems, backupData)
  if sceneType ~= 1 then
    return
  end
  self:ClearAllHighlight()
  self._bRobotPreviewing = false
  self._robotRecommendMap = nil
  local LogicSA = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  LogicSA:SetPickupPreviewState(false, nil)
  self:RefreshPickupSliders()
end
function Setting_Page_Pickup:OnRobotUndo(_, __, sceneType, backupData)
  if sceneType ~= 1 then
    return
  end
  self:RefreshPickupSliders()
end
function Setting_Page_Pickup:ClearAllHighlight()
  ClearHighlightInScrollBox(self.LoopScrollBox_Ammo)
  ClearHighlightInScrollBox(self.LoopScrollBox_Aid)
  ClearHighlightInScrollBox(self.LoopScrollBox_Throw)
  ClearHighlightInScrollBox(self.LoopScrollBox_Scope)
  if self.LoopScrollBox_AC then
    ClearHighlightInScrollBox(self.LoopScrollBox_AC)
  end
end
function Setting_Page_Pickup:ScrollToFirstHighlightItem(recommendMap)
  local scrollBoxes = {
    self.LoopScrollBox_Ammo,
    self.LoopScrollBox_Aid,
    self.LoopScrollBox_Throw,
    self.LoopScrollBox_Scope
  }
  for _, scrollBox in ipairs(scrollBoxes) do
    if scrollBox then
      local dataArray = scrollBox:GetSetData()
      for i, data in ipairs(dataArray) do
        if recommendMap[data.ID] and self.UIRoot.ScrollBox_Stack then
          local parentWidget = scrollBox._widget or scrollBox.UIRoot
          if parentWidget then
            self:AddTimerLoop(0, function()
              if slua.isValid(self.UIRoot) then
                self.UIRoot.ScrollBox_Stack:ScrollWidgetIntoView(parentWidget, false, UEnums.EDescendantScrollDestination.TopOrLeft)
              end
            end, 2, 0)
            return
          end
        end
      end
    end
  end
end
local class = require("class")
local Setting_StackContainer = require("client.slua.umg.NewSetting.Page.Setting_StackContainer")
return class(Setting_StackContainer, nil, Setting_Page_Pickup)