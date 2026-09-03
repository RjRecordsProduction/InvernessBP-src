local Season_WeaponStrength_Display_UIBP = {}
function Season_WeaponStrength_Display_UIBP:ctor(_, IsSelf)
  self.b  self.data = nil
  self.selectType = 0
  self.TabId = 1
end
function Season_WeaponStrength_Display_UIBP:OnInitialize()
  self.LoopScrollBox_Content = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Content, "client.slua.umg.Season_WeaponStrength.Item.Season_WeaponStrength_Display_Item_UIBP")
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP = self:InitHorizontalLevelOneTextTab(self.UIRoot.Common_Tab_Horizontal_LevelOne_Text_UIBP)
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:SetTextColor(FSlateColor(FLinearColor(1, 1, 1, 1)), FSlateColor(FLinearColor(1, 1, 1, 0.7)))
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local tabs1
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    tabs1 = {
      LocUtil.GetLocalizeResStr(68946),
      LocUtil.GetLocalizeResStr(68956)
    }
  else
    local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
    local bLabel = LbsMgr.CanSelectProvinceMyCountry(LbsMgr.SETTING_CFG_WARZONE_ID)
    local bOpen = LobbySystem.CheckOpen(LbsMgr.LABEL_SWITCH_WWARZONE)
    if bLabel and bOpen then
      tabs1 = {
        LocUtil.GetLocalizeResStr(68946),
        LocUtil.GetLocalizeResStr(68957),
        LocUtil.GetLocalizeResStr(68956),
        LocUtil.GetLocalizeResStr(85387)
      }
    else
      tabs1 = {
        LocUtil.GetLocalizeResStr(68946),
        LocUtil.GetLocalizeResStr(68957),
        LocUtil.GetLocalizeResStr(68956)
      }
    end
  end
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:SetTabs(tabs1)
  self.Season_WeaponStrength_Title_UIBP = self.UIRoot.Season_WeaponStrength_Title_UIBP
  self.Common_ComboBox_UIBP_WeaponStrength = self:InitCommonComboBoxNew(self.UIRoot.Common_ComboBox_UIBP_Season)
end
function Season_WeaponStrength_Display_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Rule, self.OnClickedShowRuleButton, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Rank, self.OnClickButton_Rank, self)
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:AddOnClickedCallback(self.OnClickedLevelOneTab, self)
  self:AddOnClickedEventByControl(self.Season_WeaponStrength_Title_UIBP.Button_WSDetail, self.OnClickedWSDetailButton_Title, self)
  self.Common_ComboBox_UIBP_WeaponStrength:SetRefreshOptionCallback(self.OnRefresWeaPonStrengthCallback, self)
  self.Common_ComboBox_UIBP_WeaponStrength:SetSelectOptionCallback(self.OnSelectWeaPonStrengthCallback, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_WEAPONSTRENGTH_ALIAS_GET_SELECT_ALIAS_LIST, self.UpdateTitleAlis, self)
  self:AddCommonEvent(EVENTTYPE_WEAPONSTRENGTH, EVENTID_SEASON_WEAPONSTRENGTH_DATA_RSP, self.UpdateUI, self)
end
function Season_WeaponStrength_Display_UIBP:OnPostInitialize()
  self:UpdateUI()
  if not self.bIsSelf then
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      tonumber(RoleInfoSystem.CurShowPlayerInfoUid)
    }, function(list)
      self:OnGetProfileCallBack(list)
    end, Enum_PROFILE_REPORT_CFG.ROLE_INFO, 0, false)
  else
    local logic_roleinfo_title = require("client.slua.logic.roleInfo.logic_roleinfo_title")
    logic_roleinfo_title.get_alias_list()
    local logic_roleInfo_weaponstrength_title_select = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_weaponstrength_title_select)
    logic_roleInfo_weaponstrength_title_select:send_get_show_weapon_alias_req()
  end
end
function Season_WeaponStrength_Display_UIBP:OnClose()
end
function Season_WeaponStrength_Display_UIBP:OnClickedLevelOneTab(widget, index)
  log(bWriteLog and "Season_WeaponStrength_Display_UIBP:OnClickedLevelOneTab selected index: " .. tostring(index))
  self:PlayAudio(sound_config.tab_v1)
  self.TabId = index
  self:FilterList(self.TabId, self.selectType)
end
function Season_WeaponStrength_Display_UIBP:OnClickButton_Rank()
  log(bWriteLog and "Season_WeaponStrength_Display_UIBP:OnClickButton_Rank")
  self:PlayAudio(sound_config.click_v1)
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local RankConfig = require("client.slua.logic.rank.rank_config")
  RankDataMgr.SetRankSelectType(RankConfig.RankSelectEnum.weapon_usage_score)
  GlobalData.JumpUrl("game://?module=" .. BP_ENUM_MODULE_RANK .. "&to=weapon_usage_score")
end
function Season_WeaponStrength_Display_UIBP:OnClickedWSDetailButton_Title()
  log(bWriteLog and "Season_WeaponStrength_Display_UIBP:OnClickedWSDetailButton_Title")
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.WeaponStrength_Title_Select_Popup_UIBP)
end
function Season_WeaponStrength_Display_UIBP:OnClickedShowRuleButton()
  log(bWriteLog and "Season_WeaponStrength_Display_UIBP:OnClickedShowRuleButton")
  self:PlayAudio(sound_config.click_v1)
  local allinfo = {
    [1] = {
      tab = LocUtil.GetLocalizeResStr(6067),
      textInfo = {
        {
          content1 = LocUtil.LocalizeFormatConcatenation(68967),
          type = 1
        },
        {
          content1 = "WeaponStrength_Segment_Chart_UIBP",
          type = 4
        }
      },
      title = LocUtil.GetLocalizeResStr(68943),
      ruleSortPriority = 4
    }
  }
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_two, allinfo)
end
function Season_WeaponStrength_Display_UIBP:OnGetProfileCallBack(list)
  log(bWriteLog and "Season_WeaponStrength_Display_UIBP:OnGetProfileCallBack")
  if list and next(list) then
    local showAlisInfo = list[1].show_weapon_alias_info
    self:UpdateAlis(showAlisInfo)
  else
    log(bWriteLog and "Season_WeaponStrength_Display_UIBP:OnGetProfileCallBack list is nil")
  end
end
function Season_WeaponStrength_Display_UIBP:UpdateUI()
  log(bWriteLog and "Season_WeaponStrength_Display_UIBP:UpdateUI")
  local logic_weaponstrength_tool = require("client.slua.umg.Season_WeaponStrength.logic_weaponstrength_tool")
  local logic_weapon_strength = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_weapon_strength)
  local profiledata
  if logic_weapon_strength.bIsfake then
    log(bWriteLog and "Season_WeaponStrength_Display_UIBP:UpdateUI logic_weapon_strength.bIsfake is true")
    profiledata = logic_weapon_strength.weapon_power_data_fake
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    local profile = logic_profile:GetLocalProfile(tonumber(RoleInfoSystem.CurShowPlayerInfoUid))
    if profile and profile.weapon_power_data then
      profiledata = profile.weapon_power_data
    else
      log(bWriteLog and "Season_WeaponStrength_Display_UIBP:UpdateUI profiledata is nil")
    end
  end
  if profiledata and profiledata.history_weapon_power_table then
    local ContentList = {}
    local index = 1
    for key, value in pairs(profiledata.history_weapon_power_table) do
      local newContent = {
        [key] = value
      }
      table.insert(ContentList, newContent)
    end
    self.data = ContentList
  else
    log(bWriteLog and "Season_WeaponStrength_Display_UIBP:UpdateUI profiledata is nil or history_weapon_power_table is nil")
  end
  if self.data and next(self.data) then
    self.UIRoot.WidgetSwitcher_State:SetActiveWidgetIndex(0)
    self:FilterList(self.TabId, self.selectType)
  else
    self.UIRoot.WidgetSwitcher_State:SetActiveWidgetIndex(1)
    self:SetWidgetVisible(self.UIRoot.GridPanel_Empty, true)
    self.UIRoot.TextBlock_Null:SetText(LocUtil.GetLocalizeResStr(505021))
  end
  self.UIRoot.TextBlock_GlobalHonor:SetText(LocUtil.GetLocalizeResStr(68221))
  self.UIRoot.TextBlock_CountryHonor:SetText(LocUtil.GetLocalizeResStr(68222))
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    self:SetWidgetVisible(self.UIRoot.VerticalBox_Global, false)
  else
    self:SetWidgetVisible(self.UIRoot.VerticalBox_Global, true)
  end
  self.UIRoot.TextBlock_GlobalHonorNum:SetText(logic_weaponstrength_tool.CalculateGlobalHonorTotal(self.data) or 0)
  self.UIRoot.TextBlock_CountryHonorNum:SetText(logic_weaponstrength_tool.CalculateRegionHonorTotal(self.data) or 0)
  local logic_wardrobe_gun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  local types = logic_wardrobe_gun:GetGunTypeArray()
  local weaponTypecfg = CDataTable.GetTable("WeaponStrengthWeaponType")
  local useTypes = {}
  for i = 1, #types do
    if weaponTypecfg[types[i].TypeID] then
      local content = {
        TypeID = types[i].TypeID,
        TypeName = types[i].TypeName
      }
      table.insert(useTypes, content)
    end
  end
  table.sort(useTypes, function(a, b)
    return a.TypeID < b.TypeID
  end)
  table.insert(useTypes, 1, {
    TypeID = 0,
    TypeName = LocUtil.GetLocalizeResStr(7509)
  })
  self.Common_ComboBox_UIBP_WeaponStrength:SetData(useTypes, 1)
  if self.bIsSelf then
    local logic_roleInfo_weaponstrength_title_select = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_weaponstrength_title_select)
    local selectData = logic_roleInfo_weaponstrength_title_select:GetSaveSelectAliasList_Weapon()
    self:UpdateAlis(selectData)
  end
  self.UIRoot.TextBlock_Rank:SetText(LocUtil.GetLocalizeResStr(68227))
  self.UIRoot.TextBlock_Rule:SetText(LocUtil.GetLocalizeResStr(6067))
end
function Season_WeaponStrength_Display_UIBP:OnRefresWeaPonStrengthCallback(widget, data, index, selectIndex)
  log(bWriteLog and "Season_WeaponStrength_Display_UIBP:OnRefresWeaPonStrengthCallback")
  local text = data.TypeName
  if text then
    widget.TextBlock_ItemName:SetText(text)
  end
end
function Season_WeaponStrength_Display_UIBP:OnSelectWeaPonStrengthCallback(widget, data, index, selectIndex)
  log(bWriteLog and "Season_WeaponStrength_Display_UIBP:OnSelectWeaPonStrengthCallback")
  self:PlayAudio(sound_config.click_v1)
  local text = data.TypeName
  if text then
    widget.TextBlock_ItemName:SetText(text)
  end
  self.selectType = data.TypeID
  self:FilterList(self.TabId, self.selectType)
end
function Season_WeaponStrength_Display_UIBP:FilterList(TabID, selectType)
  log(bWriteLog and "Season_WeaponStrength_Display_UIBP:FilterList tabID: " .. tostring(TabID) .. " selectType: " .. tostring(selectType))
  if not self.data then
    log(bWriteLog and "Season_WeaponStrength_Display_UIBP:FilterList data is nil")
    return
  end
  local logic_weaponstrength_tool = require("client.slua.umg.Season_WeaponStrength.logic_weaponstrength_tool")
  local newList = logic_weaponstrength_tool.FilterWeapons(self.data, self.TabId, self.selectType)
  if newList and next(newList) then
    self.UIRoot.WidgetSwitcher_State:SetActiveWidgetIndex(0)
    self.LoopScrollBox_Content:RefreshAllItems(newList)
  else
    self.UIRoot.WidgetSwitcher_State:SetActiveWidgetIndex(1)
    self:SetWidgetVisible(self.UIRoot.GridPanel_Empty, true)
    self.UIRoot.TextBlock_Null:SetText(LocUtil.GetLocalizeResStr(505021))
  end
end
function Season_WeaponStrength_Display_UIBP:UpdateAlis(AlisInfo)
  log(bWriteLog and "Season_WeaponStrength_Display_UIBP:UpdateAlis")
  log_tree("Season_WeaponStrength_Display_UIBP:UpdateAlis =", AlisInfo)
  local aliasText
  if AlisInfo and next(AlisInfo) then
    local key, value = next(AlisInfo)
    aliasText = FuncUtil.Gen_title(key, AlisInfo[key].rank, AlisInfo[key].ext_info, AlisInfo[key].rank_id)
  else
    AlisInfo = nil
  end
  if AlisInfo then
    local key, value = next(AlisInfo)
    self.UIRoot.Season_WeaponStrength_Title_UIBP.WidgetSwitcher_State:SetActiveWidgetIndex(1)
    self.UIRoot.Season_WeaponStrength_Title_UIBP.Title_UIBP:SetAliasInfo(key, aliasText, "", "", 0, 0)
  else
    self.UIRoot.Season_WeaponStrength_Title_UIBP.WidgetSwitcher_State:SetActiveWidgetIndex(0)
    self.UIRoot.Season_WeaponStrength_Title_UIBP.TextBlock_Empty:SetText(LocUtil.GetLocalizeResStr(68219))
  end
  if self.bIsSelf then
    self:SetWidgetVisible(self.UIRoot.Season_WeaponStrength_Title_UIBP, true)
    self:SetWidgetVisible(self.UIRoot.Season_WeaponStrength_Title_UIBP.Image_SettingIcon, true)
    self:SetWidgetVisible(self.UIRoot.Season_WeaponStrength_Title_UIBP.Button_WSDetail, true, true)
    self:SetWidgetVisible(self.UIRoot.Image_VerticalLine, true)
  else
    if not AlisInfo then
      self:AddTimerOnce(0.1, function()
        self:SetWidgetVisible(self.UIRoot.Season_WeaponStrength_Title_UIBP, false)
        self:SetWidgetVisible(self.UIRoot.Image_VerticalLine, false)
      end)
    end
    self:SetWidgetVisible(self.UIRoot.Season_WeaponStrength_Title_UIBP, true)
    self:SetWidgetVisible(self.UIRoot.Season_WeaponStrength_Title_UIBP.Image_SettingIcon, false)
    self:SetWidgetVisible(self.UIRoot.Season_WeaponStrength_Title_UIBP.Button_WSDetail, false)
    self:SetWidgetVisible(self.UIRoot.Image_VerticalLine, true)
  end
end
function Season_WeaponStrength_Display_UIBP:UpdateTitleAlis()
  log(bWriteLog and "Season_WeaponStrength_Display_UIBP:UpdateTitleAlis")
  local logic_roleInfo_weaponstrength_title_select = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_weaponstrength_title_select)
  local selectData = logic_roleInfo_weaponstrength_title_select:GetSaveSelectAliasList_Weapon()
  self:UpdateAlis(selectData)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Season_WeaponStrength_Display_UIBP)