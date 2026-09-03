local Collect_Road_UIBP = {}
local CollectHandler = require("client.network.Protocol.CollectHandler")
local local local seasonIndex = 2
local seasonOpenPreviewIndex = 38
local inheritLevel = 99
local tabs1
local tabMarkIcon = {
  [1] = {
    select = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Common_Tab_Career_Selected_png.Common_Tab_Career_Selected_png",
    unSelect = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Common_Tab_Career_png.Common_Tab_Career_png"
  },
  [2] = {
    select = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Common_Tab_Season_Selected_png.Common_Tab_Season_Selected_png",
    unSelect = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Common_Tab_Season_png.Common_Tab_Season_png"
  }
}
local defaultSelectedTabIcon = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Lanse_png.Common_Btn_Lv2_Lanse_png"
local C_CareerHighestLevel = 101
function Collect_Road_UIBP:ctor(_, initTab, personalizeExtraData)
  log_tree("  Collect_Road_UIBP:ctor. initTab ", initTab)
  self.nTab = nil
  self.data = nil
  self.tCareerHighestLevelReward = nil
  self.nLevel = 0
  self.nProgress = 0
  self.jumpInfo = personalizeExtraData
  self.nProgressMain = 0
  self.bLock = false
  self.initTab = tonumber(initTab)
  self.NListMaxLevel = 1
  self.nUid = DataMgr.roleData.uid
end
function Collect_Road_UIBP:OnInitialize()
  self.extendedScrollGrid = self:InitExtendedScrollGrid(self.UIRoot.ExtendedLoopScrollGrid_0, {
    "GameLua.Mod.Lobby.Split.Collect.umg.Road.Item.Collect_RLevel_Item_UIBP",
    "GameLua.Mod.Lobby.Split.Collect.umg.Road.Item.Collect_Road_HighestLevel_Item_UIBP"
  })
  self.LoopScrollBox_0 = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_0, "GameLua.Mod.Lobby.Split.Collect.umg.Road.Item.Collect_RLevel_Item_UIBP")
  self.LoopScrollBox_1 = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_1, "GameLua.Mod.Lobby.Split.Collect.umg.Road.Item.Collect_RLevel_Item_UIBP")
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP = self:InitHorizontalLevelOneTextTab(self.UIRoot.Common_Tab_Horizontal_LevelOne_Text_UIBP)
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:SetTabFixedWidth(309)
  tabs1 = {
    LocUtil.GetLocalizeResStr(77464),
    LocUtil.GetLocalizeResStr(77465)
  }
  self.initTab = self:SetSelectTabIndex()
  log_warning(bWriteLog and "  Collect_Road_UIBP:OnInitialize. self.initTab: " .. tostring(self.initTab))
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:SetTabBgIcon({selected = defaultSelectedTabIcon})
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:SetTabs(tabs1, self.initTab)
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:SetTabMarkIcon(tabMarkIcon)
end
function Collect_Road_UIBP:SetSelectTabIndex()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if collect_module:SeasonIsHide() then
    log_warning(bWriteLog and "  Collect_Road_UIBP:SetSelectTabIndex.  is locked")
    return 1
  end
  if self.jumpInfo and self.jumpInfo.openTab then
    log(bWriteLog and string.format("Collect_Road_UIBP:SetSelectTabIndex jumpInfo.openTab : %s", self.jumpInfo.openTab))
    return tonumber(self.jumpInfo.openTab) or 1
  else
    local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
    local curLevel = collect_module.curLevels
    local collect_reddot_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_reddot_module)
    for i = 1, #tabs1 do
      local isRed = collect_reddot_module:IsRedOneRoad(curLevel[i], i)
      if isRed then
        return i
      end
    end
    local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
    for i = 1, #tabs1 do
      if reddot_node_collect_manager:CheckShowNewReddot(tabs1[i]) then
        log(bWriteLog and string.format("Collect_Road_UIBP:SetSelectTabIndex reddot_node_collect_manager i: %s", i))
        return i
      end
    end
  end
  return 1
end
function Collect_Road_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_0, self.OnClickButton_Help, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Rank, self.OnClickButton_Rank, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Get, self.OnClickButton_Get, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Setting, self.OnClickButton_Setting, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Season, self.OnClickButton_Season, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Lock, self.OnClickButton_Lock, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_IntergralSource, self.OnClickButton_IntergralSource, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Inherit, self.OnButtonClick_Inherit, self)
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:AddOnClickedCallback(self.OnClickedLevelOneTab, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Score, self.OnClickButton_Score, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_SEASON_UPDATE, self.RefreshLockInfo, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_PRIVILEGE_DATA_REFRESH, self.RefreshBadge, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_MAIN_DATA, self.UpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_DETAIL_DATA, self.ShowSpecialNum, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_INHERIT_BUTTON_REFRESH, self.OnInheritChange, self)
end
function Collect_Road_UIBP:OnPostInitialize()
  self:ResetAnim()
  self:AddTimerOnce(0.1, function()
    self:PlayUserWidgetAnimation(self.UIRoot.FadeIn, 0, 1, 0, 1)
  end)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  CollectHandler.send_get_collect_sys_main_data_req()
  CollectHandler.send_get_collect_detail_req(self.nUid, 1)
  self:RefreshSeasonReviewButton()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local show = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectRoad)
  if not show or show == 0 then
    local collect_guide_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_guide_cfg")
    local tAllShow = {collect_guide_cfg}
    local common_config = require("client.slua.common.common_config")
    if not common_config:IsBlockingPopupTip() then
      UIManager.ShowUI(UIManager.UI_Config.Common_Popup_Reward_Base, nil, tAllShow)
    end
    PlayerPrefsSystem.SaveTableToFile_N(1, PlayerPrefsSystem.ePlayerPrefsType.eCollectRoad)
  end
  local UIRoot = self.UIRoot
  local GetLocalizeResStr = LocUtil.GetLocalizeResStr
  UIRoot.TextBlock_0:SetText(GetLocalizeResStr(77637))
  UIRoot.TextBlock_Help:SetText(GetLocalizeResStr(77466))
  UIRoot.TextBlock_Setting:SetText(GetLocalizeResStr(77467))
  UIRoot.TextBlock_All:SetText(GetLocalizeResStr(77468))
  UIRoot.TextBlock_5:SetText(GetLocalizeResStr(77468))
  UIRoot.TextBlock_Season:SetText(GetLocalizeResStr(77473))
  UIRoot.TextBlock_1:SetText(GetLocalizeResStr(77680))
  local url = collect_module.rankUrl
  local showBtn = url and url ~= ""
  self:SetWidgetVisible(UIRoot.Button_Rank, showBtn, true)
  if self.jumpInfo and self.jumpInfo.showPopUp then
    UIManager.ShowUI(UIManager.UI_Config.Collect_Popup_CareerIntergral_UIBP)
  end
  self:AddTimerOnce(1, function()
    local logic_special_offer_material = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_special_offer_material)
    logic_special_offer_material:GetMaterialGiftsDataReq()
  end)
  self:ShowCommercializeComponent()
  self:SetDefaultCountBoard()
  self:ShowSpecialNum()
end
function Collect_Road_UIBP:Close()
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  reddot_node_collect_manager:ClearCacheRemoveRedDot()
  self:CloseCommercializeComponent()
  self:ResetAnim()
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  local CollectTab = reddot_node_collect_manager:GetCollectTab()
  reddot_node_collect_manager:HideNodeAllChildNewReddot(CollectTab.collect_level)
  reddot_node_collect_manager:HideNodeAllChildBoxReddot(CollectTab.collect_level)
  Collect_Road_UIBP.__super.Close(self)
end
function Collect_Road_UIBP:OnClickButton_Score()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.Collect_Popup_Score_UIBP, self.nTab)
end
function Collect_Road_UIBP:OnClickedLevelOneTab(widget, index, bIgnoreRedDot)
  log_warning(bWriteLog and "Collect_Road_UIBP:OnClickedLevelOneTab selected index: " .. tostring(index))
  if widget then
    self:PlayAudio(sound_config.tab_v1)
  end
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  if not bIgnoreRedDot then
    reddot_node_collect_manager:ClearCacheRemoveRedDot()
    reddot_node_collect_manager:RemoveReddot(tabs1[index])
  else
    reddot_node_collect_manager:CacheRemoveRedDot(tabs1[index])
  end
  if self.nTab == index then
    return
  end
  self.nTab = index
  local switchIndex = 0
  if index == 2 then
    switchIndex = 1
  end
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(switchIndex)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  self:RefreshSeasonReviewButton()
  self.loop = self.extendedScrollGrid
  local configs = {}
  if index == collect_module.collect_cfg.Sys2Index.Season then
    configs = collect_module:GetSplitTableByFilter("NewCollectSeasonLevel", collect_module.E_ColCfgMode.JK, "SeasonID", tonumber(DataMgr.season_id))
    if not configs then
      log(bWriteLog and string.format("Collect_Road_UIBP:OnClickedLevelOneTab NewCollectSeasonLevel config is nil, season id = %s.", DataMgr.season_id))
      configs = {}
    end
    self.loop = self.LoopScrollBox_1
  else
    configs = collect_module:GetSplitTable("CollectLevel", collect_module.E_ColCfgMode.JK)
  end
  local len = 0
  local list = prealloctable(4, 0)
  for _, cfg in pairs(configs) do
    if cfg.Drop1 and cfg.Drop1 ~= 0 then
      if self:CheckRewardHighestLevel(cfg, index) then
        self.tCareerHighestLevelReward = cfg
      else
        len = len + 1
        list[len] = cfg
      end
    end
  end
  self.data = list
  if 0 < #list then
    self.NListMaxLevel = list[#list].Level
  else
    self.NListMaxLevel = 1
  end
  self.loop:SetData(list)
  self:SetCareerRewardsHighestLevel(index)
  log_warning(bWriteLog and "  Collect_Road_UIBP:OnClickedLevelOneTab. self.NListMaxLevel: " .. tostring(self.NListMaxLevel))
  self:RefreshGetAllBtn()
end
function Collect_Road_UIBP:SetCareerRewardsHighestLevel(index)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if index == collect_module.collect_cfg.Sys2Index.Level and self.tCareerHighestLevelReward then
    log(bWriteLog and string.format("Collect_Road_UIBP:SetCareerRewardsHighestLevel tCareerHighestLevelReward: %s", self.tCareerHighestLevelReward))
    self.loop:SetSubData(C_CareerHighestLevel - 1, {
      self.tCareerHighestLevelReward
    })
  end
end
function Collect_Road_UIBP:CheckRewardHighestLevel(cfg, index)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if index == collect_module.collect_cfg.Sys2Index.Level then
    return cfg.Level == C_CareerHighestLevel
  end
  return false
end
function Collect_Road_UIBP:RefreshSeasonReviewButton()
  local isShow = false
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if region ~= PublishRegionMacros.BLUEHOLE then
    local season = collect_module:GetSeasonId()
    log(bWriteLog and string.format("Collect_Road_UIBP:RefreshSeasonReviewButton DataMgr.season_id = %s, season = %s", DataMgr.season_id, season))
    if season >= seasonOpenPreviewIndex then
      isShow = true
    end
  end
  self:SetWidgetVisible(self.UIRoot.Button_Season, self.nTab == collect_module.collect_cfg.Sys2Index.Season and isShow, true)
end
function Collect_Road_UIBP:OnClickButton_Season()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.Collect_Season_UIBP)
end
function Collect_Road_UIBP:OnClickButton_Lock()
  self:PlayAudio(sound_config.click_v1)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not collect_module:CheckSeasonConfig() then
    ShowNotice(101706)
    return
  end
  ShowNotice(77534)
end
function Collect_Road_UIBP:OnClickButton_IntergralSource()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.Collect_Popup_CareerIntergral_UIBP)
end
function Collect_Road_UIBP:OnClickButton_Setting()
  self:PlayAudio(sound_config.click_v1)
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  local SettingMacro = require("client.slua.logic.setting.setting_macro")
  SettingUtil.Enter("PrivacyAndSocial", {
    jumpKey = "DoubleShowCollectLevel"
  })
end
function Collect_Road_UIBP:OnClickButton_Help()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.HelpTip, 0, LocUtil.GetLocalizeResStr(77538), LocUtil.GetLocalizeResStr(77539))
end
function Collect_Road_UIBP:OnClickButton_Rank()
  self:PlayAudio(sound_config.click_v1)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  GlobalData.JumpUrl(collect_module.rankUrl)
end
function Collect_Road_UIBP:OnClickButton_Get()
  self:PlayAudio(sound_config.click_v1)
  log_warning(bWriteLog and "  Collect_Road_UIBP:OnClickButton_Get. self.nTab: " .. tostring(self.nTab))
  local ModCollectHandler = RequireMod("GameLua.Mod.Lobby.Split.Collect.ModCollectHandler")
  ModCollectHandler.send_batch_take_collect_level_award_req(self.nTab):Then(function(_, _, res_list, awards)
    log_tree("  Collect_Road_UIBP:OnClickButton_Get.   res_list ", res_list)
    local collect_award_module = ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.collect_award_module)
    collect_award_module:OnGetDropBatch(self.nTab, awards)
    collect_award_module:ShowGet(res_list, function()
      if slua.isValid(self.UIRoot) then
        local bGetInherit = #awards >= inheritLevel and 0 < #res_list and #awards - #res_list < inheritLevel
        self:RefreshInheritBtnWithGetAward(self.nTab, bGetInherit and inheritLevel or 0)
      end
    end)
    local _ = self.UIRoot and self:OnGetAll()
  end)
end
function Collect_Road_UIBP:OnClickButton_Library()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.Collect_Library_UIBP)
end
function Collect_Road_UIBP:OnChooseOneItem(index, subIndex, itemData)
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.StoreCollectionBtn) then
    return
  end
  local status = itemData.status
  local itemId = itemData.itemId
  local num = itemData.num
  local time = itemData.time
  local price = itemData.price
  local priceType = itemData.priceType
  local PurchaseCond = itemData.PurchaseCond
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  log_warning(bWriteLog and "  Collect_Road_UIBP:OnChooseOneItem. index: " .. tostring(index))
  if status == ActivityProgressStatus.Done then
    log_warning(bWriteLog and "  Collect_Road_UIBP:OnChooseOneItem. self.nTab: " .. tostring(self.nTab))
    local ModCollectHandler = RequireMod("GameLua.Mod.Lobby.Split.Collect.ModCollectHandler")
    ModCollectHandler.send_take_collect_level_award_req(self.nTab, index, subIndex):Then(function(_, _, _)
      log_warning(bWriteLog and "  Collect_Road_UIBP:OnChooseOneItem. res_list: ")
      self:OnGetDrop(itemId, num, time, index, subIndex)
      if self.UIRoot then
        if self.nTab == collect_module.collect_cfg.Sys2Index.Level then
          if index == C_CareerHighestLevel then
            self.loop:RefreshSubItem(C_CareerHighestLevel - 1, 1)
          else
            self.loop:RefreshItem(index)
          end
        else
          self.loop:RefreshItem(index)
        end
      end
    end)
  elseif status == ActivityProgressStatus.Done_Not then
    self:AskBuy(index, subIndex, itemId, num, time, price, priceType, PurchaseCond)
  else
    self:OpenAwardPreview(index, subIndex)
  end
end
function Collect_Road_UIBP:OpenAwardPreview(index, subIndex)
  local previewItemList = self.data
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local progress = self.nProgressMain
  if self.nTab == collect_module.collect_cfg.Sys2Index.Season then
    progress = self.nProgress
  elseif self.tCareerHighestLevelReward then
    table.insert(previewItemList, self.tCareerHighestLevelReward)
  end
  local data = {
    index = index,
    subIndex = subIndex,
    list = previewItemList,
    level = collect_module.curLevels[self.nTab],
    progress = progress,
    sysId = self.nTab
  }
  UIManager.ShowUI(UIManager.UI_Config.Collect_Award_Preview_UIBP, data)
end
function Collect_Road_UIBP:OnButtonClick_Inherit()
  self:PlayAudio(sound_config.click_v1)
  local collect_inherit_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_inherit_data)
  local bEntry, uid, mail = collect_inherit_data:CheckCanUseResourceShar()
  if bEntry then
    collect_inherit_data:ShowInheritPupupOrInvitedPage(uid, mail)
  else
    collect_inherit_data:ShowExplainTip(self.UIRoot.CanvasPanel_InheritTips)
  end
end
function Collect_Road_UIBP:RefreshLockInfo()
  local lock
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if collect_module:SeasonIsHide() then
    log_warning(bWriteLog and "  Collect_Road_UIBP:RefreshLockInfo.  is locked")
    lock = true
  end
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:SetChildLock(seasonIndex, lock, lock)
  self:SetWidgetVisible(self.UIRoot.Button_Lock, lock, true)
end
function Collect_Road_UIBP:OnGetAll()
  self:RefreshGetAllBtn()
  self.loop:RefreshAllItems()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if self.nTab == collect_module.collect_cfg.Sys2Index.Level then
    self.loop:RefreshAllSubItems(C_CareerHighestLevel - 1)
  end
end
function Collect_Road_UIBP:RefreshGetAllBtn()
  local switcherIndex = 1
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collect_reddot_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_reddot_module)
  local tab = self.nTab
  local curLevel = collect_module.curLevels[tab]
  local showGetAllBtn, targetJumpLevel = false, 0
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  if tab == collect_cfg.Sys2Index.Season then
    showGetAllBtn, targetJumpLevel = collect_reddot_module:GetSeasonClaimableOrClaimedAward(curLevel)
  else
    showGetAllBtn, targetJumpLevel = collect_reddot_module:GetCareerClaimableOrClaimedAward(curLevel)
  end
  if showGetAllBtn then
    switcherIndex = 0
  end
  self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(switcherIndex)
  self:SetWidgetVisible(self.UIRoot.Button_Get, true, showGetAllBtn)
  self:RefreshRed()
  if self.jumpInfo and self.jumpInfo.extraTab and self.jumpInfo.extraTab.toIndex then
    targetJumpLevel = tonumber(self.jumpInfo.extraTab.toIndex)
  end
  if targetJumpLevel and 0 < targetJumpLevel then
    log(bWriteLog and string.format("Collect_Road_UIBP:RefreshGetAllBtn targetJumpLevel = %s", targetJumpLevel))
    self.loop:ScrollToCenter(targetJumpLevel)
  end
end
function Collect_Road_UIBP:ShowCollect()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collect_data = collect_module.collect_data
  log_tree("  Collect_Road_UIBP:ShowCollect. collect_data ", collect_data)
  local CollectLevelCfg = collect_module:GetSplitTable("CollectLevel", collect_module.E_ColCfgMode.JK)
  local score = collect_data.total_score
  local preScore, nextScore = 0, 0
  local curLevel, levelName, nextLevel, maxLevel, l, nextName = 1, "", 1, 1, 1, ""
  for level, v in pairs(CollectLevelCfg) do
    nextScore = v.Score
    nextLevel = tonumber(level)
    l = v.Dan
    nextName = v.DanDesc
    if score >= nextScore then
      preScore = nextScore
    else
      curLevel = nextLevel
      levelName = nextName
      break
    end
  end
  if score >= nextScore then
    curLevel = nextLevel
    levelName = nextName
  end
  for level, _ in pairs(CollectLevelCfg) do
    maxLevel = tonumber(level)
  end
  log_warning(bWriteLog and "  Collect_Road_UIBP:ShowCollect. maxLevel: " .. tostring(maxLevel))
  log_warning(bWriteLog and "  Collect_Road_UIBP:ShowCollect. nextScore: " .. tostring(nextScore))
  log_warning(bWriteLog and "  Collect_Road_UIBP:ShowCollect. score: " .. tostring(score))
  log_warning(bWriteLog and "  Collect_Road_UIBP:ShowCollect. preScore: " .. tostring(preScore))
  local root = self.UIRoot
  root.UTRichTextBlock_Name:SetText(LocUtil.LocalizeResFormat(77535, curLevel, levelName))
  local tScore
  if curLevel ~= maxLevel then
    tScore = LocUtil.LocalizeResFormat(6830, score, nextScore)
  else
    tScore = tostring(score)
  end
  root.Text_Score:SetText(tScore)
  collect_module:SetOneLevel(collect_module.collect_cfg.Sys2Index.Level, curLevel)
  local str = LocUtil.LocalizeResFormat(77463, nextScore - score, math.min(curLevel + 1, maxLevel))
  root.UTRichTextBlock_0:SetText(str)
  self:SetWidgetVisible(root.UTRichTextBlock_0, curLevel ~= maxLevel)
  self.nProgressMain = 1
  if curLevel ~= maxLevel then
    self.nProgressMain = (score - preScore) / (nextScore - preScore)
  end
  root.Process_Score:SetPercent(self.nProgressMain)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  self.UIRoot.Collect_Level_Item_UIBP:InitExquisiteCollectBadge(DataMgr.roleData.uid, {
    seasonLevel = collect_module.curLevels[collect_cfg.Sys2Index.Season],
    rank = l,
    totalLevel = curLevel,
    animationType = collect_cfg.E_CollectBadge_AnimaType.None
  })
end
function Collect_Road_UIBP:ShowSeasonCollect()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local season = collect_module:GetSeasonId()
  local CollectLevelCfg = collect_module:GetSplitTableByFilter("NewCollectSeasonLevel", collect_module.E_ColCfgMode.JK, "SeasonID", tonumber(DataMgr.season_id))
  if not CollectLevelCfg then
    log(bWriteLog and string.format("Collect_Road_UIBP:ShowSeasonCollect NewCollectSeasonLevel config is nil, saeson id = %s.", DataMgr.season_id))
    CollectLevelCfg = {}
  end
  local TableUtil = require("common.table_util")
  local score = TableUtil.GetTableValue(collect_module.collect_data.season_score, season) or 0
  local preScore, nextScore, maxScore = 0, 0, 0
  local curLevel, levelName, nextLevel, maxLevel = 0, "", 1, 1
  for _, v in pairs(CollectLevelCfg) do
    if v.MinScore and v.MinScore and score < v.MinScore then
      nextScore = v.MinScore
      break
    end
    nextScore = v.Score
    nextLevel = tonumber(v.Level)
    if score >= nextScore then
      preScore = nextScore
    else
      curLevel = nextLevel
      levelName = v.DanDesc
      break
    end
  end
  for _, v in pairs(CollectLevelCfg) do
    maxLevel = tonumber(v.Level)
    maxScore = v.MinScore
  end
  self.nProgress = (score - preScore) / (nextScore - preScore)
  if score >= maxScore then
    curLevel = maxLevel
    self.nProgress = 1
  end
  log_warning(bWriteLog and "  Collect_Road_UIBP:ShowSeasonCollect. maxLevel: " .. tostring(maxLevel))
  log_warning(bWriteLog and "  Collect_Road_UIBP:ShowSeasonCollect. maxScore: " .. tostring(maxScore))
  log_warning(bWriteLog and "  Collect_Road_UIBP:ShowSeasonCollect. curLevel: " .. tostring(curLevel))
  log_warning(bWriteLog and "  Collect_Road_UIBP:ShowSeasonCollect. score: " .. tostring(score))
  collect_module:SetOneLevel(collect_module.collect_cfg.Sys2Index.Season, curLevel)
  local root = self.UIRoot
  local tScore
  if curLevel ~= maxLevel then
    tScore = LocUtil.LocalizeResFormat(6830, score, nextScore)
  else
    tScore = tostring(score)
  end
  root.TextBlock_8:SetText(tScore)
  log_warning(bWriteLog and "  Collect_Road_UIBP:ShowSeasonCollect. self.nProgress: " .. tostring(self.nProgress))
  root.ProgressBar_0:SetPercent(self.nProgress)
  local str = LocUtil.LocalizeResFormat(77474, nextScore - score, math.min(curLevel + 1, maxLevel))
  root.UTRichTextBlock_1:SetText(str)
  self:SetWidgetVisible(root.UTRichTextBlock_1, curLevel ~= maxLevel)
end
function Collect_Road_UIBP:OnGetDrop(itemId, num, time, index, subIndex)
  log_warning(bWriteLog and "  Collect_Road_UIBP:OnGetItem. itemId: " .. tostring(itemId))
  local itemList = {
    {
      res_id = itemId,
      count = num,
      valid_hours = time
    }
  }
  local collect_award_module = ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.collect_award_module)
  collect_award_module:OnGetDrop(self.nTab, index, subIndex)
  collect_award_module:ShowGet(itemList, function()
    if slua.isValid(self.UIRoot) then
      self:RefreshInheritBtnWithGetAward(self.nTab, index)
    end
  end)
  local _ = self.UIRoot and self:RefreshGetAllBtn()
end
function Collect_Road_UIBP:AskBuy(index, subIndex, itemId, num, time, price, priceType, PurchaseCond)
  if PurchaseCond and 0 < PurchaseCond then
    local collect_limit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_limit_module)
    if not collect_limit_module:CheckBuyPrivilegeEffective() then
      ShowNotice(48260)
      return
    end
  end
  local data = {
    itemId = itemId,
    nSysId = self.nTab,
    index = index,
    subIndex = subIndex,
    priceType = priceType,
    price = price,
    num = num,
    callback = function()
      self:OnGetDrop(itemId, num, time, index, subIndex)
      local _ = self.UIRoot and self.loop:RefreshItem(index)
    end
  }
  local collect_award_module = ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.collect_award_module)
  collect_award_module:BuyAward(data)
end
function Collect_Road_UIBP:UpdateUI()
  log(bWriteLog and "Collect_Road_UIBP:UpdateUI")
  self:SetWidgetVisible(self.UIRoot.Button_Score, true, true)
  local lock
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if collect_module:SeasonIsHide() then
    log_warning(bWriteLog and "  Collect_Road_UIBP:OnInitialize.  is locked")
    lock = true
    self.initTab = 1
  end
  log_warning(bWriteLog and "  Collect_Road_UIBP:OnInitialize. self.initTab: " .. tostring(self.initTab))
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:SetTabs(tabs1, self.initTab)
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:SetChildLock(seasonIndex, lock, lock)
  self:SetWidgetVisible(self.UIRoot.Button_Lock, lock, true)
  self:ShowSeasonCollect()
  self:ShowCollect()
  self:OnClickedLevelOneTab(nil, self.initTab or 1, true)
  self:UpdateBackGround()
  self:RefreshRed()
  self:RefreshInheritBtn()
  if self.jumpInfo and self.jumpInfo.extraTab and self.jumpInfo.extraTab.rewardIndex then
    local index, subIndex
    index = tonumber(self.jumpInfo.extraTab.rewardIndex)
    subIndex = tonumber(self.jumpInfo.extraTab.rewardSubIndex) or 1
    log(bWriteLog and string.format("Collect_Road_UIBP:UpdateUI jumpInfo : index = %d, subIndex = %d", index, subIndex))
    self:OpenAwardPreview(index, subIndex)
  end
  self.jumpInfo = nil
end
function Collect_Road_UIBP:OnInheritChange()
  self:RefreshInheritBtn()
end
function Collect_Road_UIBP:RefreshInheritBtn(bGetInherit)
  local collect_inherit_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_inherit_data)
  local bShowInheritButton = collect_inherit_data:CheckCanShowInheritEntrance(bGetInherit)
  self:SetWidgetVisible(self.UIRoot.Button_Inherit, bShowInheritButton, true)
  if bShowInheritButton then
    collect_inherit_data:ReOpenPopupPage()
  end
  if bGetInherit then
    self:CreateChildWindow(self.UIRoot.CanvasPanel_InheritTips, UIManager.UI_Config.collect_inherit_tip)
    collect_inherit_data:ShowOperationTip()
  end
end
function Collect_Road_UIBP:RefreshInheritBtnWithGetAward(tab, level)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if tab == collect_module.collect_cfg.Sys2Index.Level and level == inheritLevel then
    self:RefreshInheritBtn(true)
  end
end
function Collect_Road_UIBP:RefreshRed()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collect_reddot_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_reddot_module)
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  local curLevel = collect_module.curLevels
  for i = 1, #tabs1 do
    local reddot_anchor, parentNode = self.Common_Tab_Horizontal_LevelOne_Text_UIBP:GetItemReddotAnchorComponent(i)
    if not reddot_node_collect_manager:ShowNewReddot(parentNode, reddot_anchor, tabs1[i]) then
      local isRed = collect_reddot_module:IsRedOneRoad(curLevel[i], i)
      reddot_node_collect_manager:ShowBoxReddot(parentNode, isRed and reddot_anchor, tabs1[i])
    end
  end
end
function Collect_Road_UIBP:UpdateBackGround()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local path = "/Game/Mod/Lobby/Split/Collect/Texture/Collect_Bg01.Collect_Bg01"
  local maskPath = "/Game/Mod/Lobby/Split/Collect/Texture/Collect_Bg01_Maske.Collect_Bg01_Maske"
  local season = collect_module:GetSeasonId()
  local TableUtil = require("common.table_util")
  local score = TableUtil.GetTableValue(collect_module.collect_data.season_score, season) or 0
  local _, light = collect_module:GetSeasonLevelByScore(score)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  local collect_data = profile and profile.collect_data
  local collect_badge_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_badge_module)
  if light and collect_badge_module:CheckCanLightBadge(DataMgr.roleData.uid, collect_data) then
    path = "/Game/Mod/Lobby/Split/Collect/Texture/Collect_Bg02.Collect_Bg02"
    maskPath = "/Game/Mod/Lobby/Split/Collect/Texture/Collect_Bg02_Maske.Collect_Bg02_Maske"
  end
  self:SetTexture(self.UIRoot.Image_Bg, path)
  self:SetTexture(self.UIRoot.Image_Maske, maskPath)
end
function Collect_Road_UIBP:ResetAnim()
  if not self.UIRoot then
    return
  end
  self:PlayUserWidgetAnimation(self.UIRoot.FadeIn, 0, 1, 1, 1000)
end
function Collect_Road_UIBP:RefreshBadge()
  self:UpdateBackGround()
  self:ShowCollect()
end
function Collect_Road_UIBP:ShowCommercializeComponent()
  local logic_community_commercial = require("client.slua.logic.community.logic_community_commercial")
  if not logic_community_commercial.CheckCommercialComponentAdded(TLogEventDefine.CollectMain) then
    self.commercialComponent = self:CreateChildWindow(self.UIRoot.CanvasPanel_Commercial, UIManager.UI_Config.community_commercial_uibp, TLogEventDefine.CollectMain)
  end
end
function Collect_Road_UIBP:CloseCommercializeComponent()
  if self.commercialComponent then
    self.commercialComponent:CloseSelf()
    self.commercialComponent = nil
  end
end
function Collect_Road_UIBP:GetJumpSourceInformation()
  local isShow = UIManager.IsUIShow(UIManager.UI_Config.Collect_Popup_CareerIntergral_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Collect_Popup_CareerIntergral_UIBP)
  return isShow
end
local class = require("class")
local ui_base = require("GameLua.Mod.Lobby.Split.Collect.umg.Road.Collect_JumpBase")
local CCollect_Road_UIBP = class(ui_base, nil, Collect_Road_UIBP)
return CCollect_Road_UIBP