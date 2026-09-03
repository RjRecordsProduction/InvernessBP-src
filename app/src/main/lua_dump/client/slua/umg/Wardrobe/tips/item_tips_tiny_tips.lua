local TinyTips = {}
function TinyTips:RegistEvents()
  TinyTips.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Tips_Close, self.OnCloseBtnClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_play, self.OnPlayBtnClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Use, self.OnUseBtnClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Upgrade, self.OnUpgradeBtnClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_compose, self.OnComposeBtnClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Send, self.OnSendBtnClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Decompose, self.OnDecomposeBtnClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.button_JumpToShop, self.OnJumpShopBtnClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Exchange, self.OnExchangeBtnClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Get, self.OnGetBtnClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_play_grenadeEffect, self.OnPlayGrenadeEffect, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Car_LevelUp, self.OnCarLevelUp, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_GunDIYExchange, self.OnGunDIYExchange, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_GoldenSuit, self.OnGoldenSuit, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_play_interactive_action, self.OnPlayInteractiveAction, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ShareToClub, self.OnClickShareToClub, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ChangeColor, self.OnChangeColorClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Emote, self.OnClickEmote, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ClickEmote, self.OnClickClickEmote, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Collect, self.OnClickCollect, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_VehicleCustom, self.OnClickVehicleCustom, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Package, self.OnClickPackage, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_1, self.OnClickHideFace, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ColorFollow, self.OnClickToggleColorFollow, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Detail, self.OnClickDetail, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ChangeHead, self.OnClickChangeHead, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SpecialIdle, self.OnClickSpecialIdle, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_GarageEdit, self.OnClickGarageEdit, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ThemeUpgrade, self.OnClickThemeUpgrade, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Music, self.OnClickBtnMusic, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Perform, self.OnClickBtnPerform, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Gloves, self.OnClickedButton_Gloves, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_RandomVoice, self.OnClickBtnRandomVoice, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_BattleDamage, self.OnClickBtnBattleDamage, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_AerialShow, self.OnClickAerialShow, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Equip, self.OnClickedEquip, self)
  if self.UIRoot.Button_StartUpFx then
    self:AddOnClickedEventByControl(self.UIRoot.Button_StartUpFx, self.OnClickStartUpFX, self)
  end
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_COLLECT_UNLOCK_STATE_REFRESH, self.OnCollectStateUnlock, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CLOSE_COLLECT_TIPS, self.OnCloseCollectTips, self)
  self:AddCommonEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_TOGGLE_WEAPON_SWITCH_BY_CLOTH, self.OnGetColorFollowButtonFlag, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ITEM_DATA, self.OnDataChange, self)
end
function TinyTips:OnPostInitialize()
  TinyTips.__super.OnPostInitialize(self)
  self.UIRoot.TextBlock_15:SetText(LocUtil.GetLocalizeResStr(48679))
  self.UIRoot.TextBlock_20:SetText(LocUtil.GetLocalizeResStr(65489))
end
function TinyTips:OnGunDIYExchange()
  local WeaponDiyExchangeSystem = require("client.slua.logic.weapon_diy.logic_weapon_diy_exchange")
  WeaponDiyExchangeSystem.OpenExchangeList()
end
function TinyTips:OnGoldenSuit()
  self:PlayAudio(sound_config.click_v1)
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  LogicXSuit.ShowUpgradeUI(LogicXSuit.GetPeriodByItemId(self.res_id), nil, nil, nil, true)
end
function TinyTips:OnClickClickEmote()
  self:PlayAudio(sound_config.click_v1)
  local isWearing = false
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemDataByInsID(self.ins_id)
  if itemData then
    local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
    local wearInfo = logic_wardrobe_avatar:GetCurrentWearPreview(itemData.itemSubType)
    if wearInfo then
      if logic_wardrobe_avatar:IsItemSubType_Bag_Helmet_Armor(itemData.itemSubType) then
        isWearing = wearInfo.insID == itemData.insID
      else
        isWearing = wearInfo.insID == itemData.insID and wearInfo.resID == itemData.resID
      end
    end
  end
  if not isWearing then
    log(bWriteLog and string.format("TinyTips:OnClickClickEmote - Not wearing item %s, cannot play click emote", tostring(self.res_id)))
    return
  end
  local targetExpressionID = 0
  local featuresItems = CDataTable.GetTableData("FeaturesItems", self.res_id)
  if featuresItems and featuresItems.Features ~= "" then
    local StringUtil = require("common.string_util")
    local features = StringUtil.Split(featuresItems.Features, ";")
    for _, featureIDStr in ipairs(features) do
      local featureID = tonumber(featureIDStr)
      if featureID then
        local featureCfg = CDataTable.GetTableData("FeaturesConfig", featureID)
        if featureCfg and featureCfg.FeatureType == ENUM_FeatureType.ClickEmotion and featureCfg.ExpressionID and 0 < featureCfg.ExpressionID then
          targetExpressionID = featureCfg.ExpressionID
          break
        end
      end
    end
  end
  if 0 < targetExpressionID then
    local expression_util = require("client.slua.umg.Souvenirs.Expression_Util")
    expression_util.PlayExpression(targetExpressionID)
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    TeamupHandler.send_depot_cloth_feature_trigger_req(self.ins_id)
  end
end
function TinyTips:OnClickEmote()
  self:PlayAudio(sound_config.click_v1)
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  LogicParticleEmote:ShowUnlockPropPanel(self.res_id)
end
function TinyTips:RefreshEmoteButton()
  self.UIRoot.TextBlock_Emote:SetText(LocUtil.GetLocalizeResStr(48678))
end
function TinyTips:OnClickCollect()
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  local VehicleType = VehicleCollectSystem:GetVehicleType(self.res_id)
  if VehicleType < 1 then
    log(bWriteLog and "TinyTips:RefreshCollectButton VehicleType < 1 self.res_id:" .. tostring(self.res_id))
    return
  end
  local Vars = {VehicleType = VehicleType}
  VehicleCollectSystem:OpenVehicleWorkShop(VehicleCollectSystem.ENUM_VEHICLE_SYSTEM.COLLECT, Vars)
end
function TinyTips:OnClickVehicleCustom()
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  local VehicleType = VehicleCollectSystem:GetVehicleType(self.res_id)
  local LadderCarDetailConfig = require("client.slua.logic.lobby_activity.LadderCarDetailConfig")
  local bIsMcLarenF1 = LadderCarDetailConfig.IsMcLarenF1(self.res_id)
  if bIsMcLarenF1 then
    VehicleType = 4
  elseif VehicleType < 1 then
    log(bWriteLog and "TinyTips:OnClickVehicleCustom VehicleType < 1 self.res_id:" .. tostring(self.res_id))
    return
  end
  local Vars = {
    VehicleType = VehicleType,
    JumpType = 1,
    VehicleID = self.res_id
  }
  VehicleCollectSystem:OpenVehicleWorkShop(VehicleCollectSystem.ENUM_VEHICLE_SYSTEM.COLLECT, Vars)
end
function TinyTips:RefreshCollectButton()
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  local VehicleType = VehicleCollectSystem:GetVehicleType(self.res_id)
  if VehicleType < 1 then
    log(bWriteLog and "TinyTips:RefreshCollectButton VehicleType < 1 self.res_id:" .. tostring(self.res_id))
    return
  end
  local CurNum = VehicleCollectSystem:GetOwnVehicleNumByType(VehicleType)
  local SumNum = VehicleCollectSystem:GetSumVehicleNumByType(VehicleType)
  self.UIRoot.UTRichTextBlock_Collect:SetText(LocUtil.LocalizeResFormat(49947, CurNum, SumNum))
end
function TinyTips:Refresh()
  local item_tips_util = require("client.slua.umg.Wardrobe.tips.item_tips_util")
  local itemInfo = item_tips_util:GetItemInfo(self.ins_id, self.res_id)
  if not itemInfo then
    return
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
  local LadderCarDetailConfig = require("client.slua.logic.lobby_activity.LadderCarDetailConfig")
  local eWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode()
  local DataSource = WardrobeDataManager:GetItemSource(self.ins_id)
  local useBtnValid = item_tips_util:CanUseItem(itemInfo.res_id, itemInfo.itemType, itemInfo.expireTS, itemInfo.itemSubType, itemInfo.jumpExchangeUrl)
  local exchangeBtnValid = item_tips_util:CanExchangeItem(itemInfo.jumpExchangeUrl)
  local getBtnValid = item_tips_util:CanGetItem(exchangeBtnValid, itemInfo)
  local composeBtnValid = item_tips_util:CanComposeItem(itemInfo.res_id)
  local playBtnValid = item_tips_util:CanMvpPreview(self.res_id)
  local playGrenadeEffectValid = item_tips_util:CanPlayThrowObjectEffect(self.res_id)
  local playInteractiveAction = item_tips_util:CanInteractiveActionPreview(self.res_id)
  local sendItemBtnValid = item_tips_util:CanSendItem(itemInfo.res_id)
  local jumpShopBtnValid = item_tips_util:CanJumpToShop(itemInfo.res_id, itemInfo.itemSubType, itemInfo.isSourceBook)
  local equipBtnValid = item_tips_util:CanEquipItem(itemInfo.itemSubType)
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local canUpgradeInGame = item_tips_util:CanUpgradeItemInGame(itemInfo.res_id) and not ItemUpgradeMgr:IsItemEffectMaxLevel(itemInfo.res_id)
  if itemInfo.res_id == 1107098001 and itemInfo.expireTS > 0 then
    canUpgradeInGame = false
  end
  local canUpgradeInPandora, _ = item_tips_util:CanUpgradeItemInPandora(itemInfo.res_id)
  local upgradeBtnValid = (canUpgradeInGame or canUpgradeInPandora) and DataSource == EWardrobeDataSource.Wardrobe
  local goldenSuitVaild = item_tips_util:CanShowUpgradeBtn(itemInfo.res_id, itemInfo.ins_id)
  local decomposeBtnValid = item_tips_util:CanDecomposeItem(itemInfo.res_id, itemInfo.ins_id) and not playBtnValid and not useBtnValid and not playGrenadeEffectValid and not playInteractiveAction and not goldenSuitVaild and eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.None
  local canShowEmoteButton = not decomposeBtnValid and item_tips_util:CanShowEmoteButton(itemInfo.res_id)
  local canShowClickEmoteButton = item_tips_util:CanShowClickEmoteButton(itemInfo.res_id)
  local ShowCollectButton = item_tips_util:ShowCollectJumpButton(itemInfo.res_id) and DataSource == EWardrobeDataSource.Wardrobe
  local ShowVehicleCustomButton = LadderCarDetailConfig.IsRareCar(itemInfo.res_id) and DataSource == EWardrobeDataSource.Wardrobe
  local ShowHideBagButton = item_tips_util:ShowHideBagButton(itemInfo.res_id)
  local ShowHideFaceButton = item_tips_util:ShowHideFaceButton(itemInfo.res_id)
  local ShowColorFollowButton = item_tips_util:ShowColorFollowButton(itemInfo.res_id, itemInfo.ins_id)
  local ShowButtonDetail = item_tips_util:ShowButtonDetail(itemInfo.res_id)
  local ShowButtonStartUpFx = item_tips_util:ShowButtonStartUpFX(itemInfo.res_id)
  local bShowButtonGarageEdit = eWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.FashionBag and item_tips_util:ShowButtonGarageEdit(itemInfo.res_id)
  local bShowButtonThemeUpgrade = item_tips_util:ShowButtonThemeUpgrade(itemInfo.res_id)
  local bShowButtonGloves = ModelDisplayTypeHelper.IsGloves(itemInfo.itemType, itemInfo.itemSubType)
  local bShowButtonRandomVoice = item_tips_util:ShowButtonRandomVoice(itemInfo.res_id)
  local bShowButtonBattleDamage = item_tips_util:ShowButtonBattleDamage(itemInfo.res_id)
  local bShowButtonAerialShow = item_tips_util:ShowButtonAerialShow(itemInfo.res_id)
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  local bShowButtonChangeHead = logic_suit_multi_shape:CanCurrentSuitChangeHead(itemInfo.res_id) and DataSource == EWardrobeDataSource.Wardrobe
  local LobbyIdleUnlock = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyIdleUnlock)
  local bShowButtonSpecialIdle = LobbyIdleUnlock:IsNeedShowSpecialIdleIcon(itemInfo.res_id) and DataSource == EWardrobeDataSource.Wardrobe
  local itemNameStr = itemInfo.itemName or ""
  local itemDescStr = itemInfo.itemDesc or ""
  local itemDescVis = 0 < string.len(itemDescStr)
  local UIUtil = require("client.common.ui_util")
  local remainTimeStr, remainTimeVis = UIUtil.GetItemTimeLimitText(false, self.res_id, itemInfo.expireTS)
  local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
  local bDyeSuit = logic_suit_dye:IsDyeSuit(self.res_id)
  self:SetWidgetVisible(self.UIRoot.Button_Use, useBtnValid, true)
  self:SetWidgetVisible(self.UIRoot.SizeBox_Decompose, decomposeBtnValid)
  self:SetWidgetVisible(self.UIRoot.Button_Send, sendItemBtnValid, true)
  self:SetWidgetVisible(self.UIRoot.Button_compose, composeBtnValid, true)
  self:SetWidgetVisible(self.UIRoot.button_JumpToShop, jumpShopBtnValid, true)
  self:SetWidgetVisible(self.UIRoot.Button_Upgrade, upgradeBtnValid, true)
  self:SetWidgetVisible(self.UIRoot.Button_play, playBtnValid, true)
  self:SetWidgetVisible(self.UIRoot.Button_Exchange, exchangeBtnValid, true)
  self:SetWidgetVisible(self.UIRoot.Button_Get, getBtnValid, true)
  self:SetWidgetVisible(self.UIRoot.Button_play_grenadeEffect, playGrenadeEffectValid, true)
  self:SetWidgetVisible(self.UIRoot.SizeBox_CarLevel, item_tips_util:CanCarLevelUp(itemInfo.res_id) and DataSource == EWardrobeDataSource.Wardrobe)
  self:SetWidgetVisible(self.UIRoot.Button_Emote, canShowEmoteButton, true)
  self:SetWidgetVisible(self.UIRoot.Button_ClickEmote, canShowClickEmoteButton, true)
  self:SetWidgetVisible(self.UIRoot.Button_Collect, ShowCollectButton, true)
  self:SetWidgetVisible(self.UIRoot.Button_VehicleCustom, ShowVehicleCustomButton, true)
  self:SetWidgetVisible(self.UIRoot.Button_Package, ShowHideBagButton, true)
  self:SetWidgetVisible(self.UIRoot.Button_1, ShowHideFaceButton, true)
  self:SetWidgetVisible(self.UIRoot.Button_ColorFollow, ShowColorFollowButton, true)
  self:SetWidgetVisible(self.UIRoot.Button_Detail, ShowButtonDetail, true)
  self:SetWidgetVisible(self.UIRoot.Button_ChangeHead, bShowButtonChangeHead, true)
  self:SetWidgetVisible(self.UIRoot.Button_SpecialIdle, bShowButtonSpecialIdle, true)
  self:SetWidgetVisible(self.UIRoot.Button_GarageEdit, bShowButtonGarageEdit, true)
  self:SetWidgetVisible(self.UIRoot.Button_ThemeUpgrade, bShowButtonThemeUpgrade, true)
  self:SetWidgetVisible(self.UIRoot.Button_Gloves, bShowButtonGloves, true)
  self:SetWidgetVisible(self.UIRoot.Button_RandomVoice, bShowButtonRandomVoice, true)
  self:SetWidgetVisible(self.UIRoot.Button_BattleDamage, bShowButtonBattleDamage, true)
  self:SetWidgetVisible(self.UIRoot.Button_AerialShow, bShowButtonAerialShow, true)
  self:SetWidgetVisible(self.UIRoot.Button_Equip, equipBtnValid, true)
  if self.UIRoot.Button_StartUpFx then
    self:SetWidgetVisible(self.UIRoot.Button_StartUpFx, ShowButtonStartUpFx, true)
  end
  local UIUtil = require("client.common.ui_util")
  if UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.Wardrobe, false) then
    self:ShowCollectUnlockTips(bShowButtonChangeHead, bShowButtonSpecialIdle)
  end
  if item_tips_util:CanCarLevelUp(itemInfo.res_id) then
    local carWordId = 6338
    local upgradeVehicle = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.upgradeVehicle)
    if upgradeVehicle:IsRefitVehicle(itemInfo.res_id) then
      carWordId = 49296
    end
    self.UIRoot.TextBlock_CarLevel:SetText(LocUtil.GetLocalizeResStr(carWordId))
  end
  self:SetWidgetVisible(self.UIRoot.Button_play_interactive_action, playInteractiveAction, true)
  self:SetWidgetVisible(self.UIRoot.Button_GoldenSuit, goldenSuitVaild, true)
  self:SetWidgetVisible(self.UIRoot.Button_ChangeColor, bDyeSuit and DataSource == EWardrobeDataSource.Wardrobe, true)
  local itemCfg = CDataTable.GetTableData("Item", self.res_id)
  local wardrobeMainTab = itemCfg and itemCfg.WardrobeMainTab
  local bValidMainTab = self:IsCanShareClubWardrobeMainTab(wardrobeMainTab)
  local logic_community = require("client.slua.logic.community.logic_community")
  local bShowClubShare = logic_community.GetShowEntry() and bValidMainTab and eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.None
  self:SetWidgetVisible(self.UIRoot.Panel_Share, bShowClubShare)
  local StringUtil = require("common.string_util")
  local EHorizontalAlignment = import("EHorizontalAlignment")
  self.UIRoot.TextBlock_Name:SetText(itemNameStr)
  if StringUtil.HasArChar(itemDescStr) then
    self.UIRoot.Text_Descrip.Slot:SetHorizontalAlignment(EHorizontalAlignment.HAlign_Right)
  else
    self.UIRoot.Text_Descrip.Slot:SetHorizontalAlignment(EHorizontalAlignment.HAlign_Left)
  end
  self.UIRoot.Text_Descrip:SetText(itemDescStr)
  self:SetWidgetVisible(self.UIRoot.VerticalBox_1, itemDescVis)
  self.UIRoot.TextBlock_Time:SetText(remainTimeStr)
  self:SetWidgetVisible(self.UIRoot.TextBlock_Time, remainTimeVis)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, remainTimeVis)
  self:SetWidgetVisible(self.UIRoot.TextBlock_0, false)
  self:RefreshComposeNum(composeBtnValid, itemInfo.count, itemInfo.res_id)
  if itemInfo.quality and itemInfo.quality >= 3 then
    local path = UIUtil.GetLeftBarQualityPath(itemInfo.quality)
    self:SetTexture(self.UIRoot.Image_Quality, path)
    self:SetWidgetVisible(self.UIRoot.Image_Quality, true)
  else
    self:SetWidgetVisible(self.UIRoot.Image_Quality, false)
  end
  self:SetWidgetVisible(self.UIRoot.Image_0, itemInfo.quality < 5)
  self:SetWidgetVisible(self.UIRoot.Button_GunDIYExchange, false, true)
  if canShowEmoteButton then
    self:RefreshEmoteButton()
  end
  if ShowCollectButton then
    self:RefreshCollectButton()
  end
  if ShowHideBagButton then
    self:InitHideBagButton()
    self:RefreshHideButton()
  end
  if ShowHideFaceButton then
    self:RefreshHideFaceButton()
  end
  if ShowColorFollowButton then
    self:RefreshColorFollowButton()
  end
  if equipBtnValid then
    self:RefreshEquip(itemInfo)
  end
  item_tips_util:SetItemFrom(self.UIRoot.Image_From, itemInfo.isFree)
  local showMusicButton = false
  local musicCfg = CDataTable.GetTableData("EmotionToMusic", self.res_id)
  if musicCfg then
    showMusicButton = true
  end
  self:SetWidgetVisible(self.UIRoot.Button_Music, showMusicButton, true)
  local PlayAnimationFeatureInGameGuide = require("client.slua.umg.newbie_guide.PlayAnimationFeatureInGameGuide")
  local CanShowGuide = PlayAnimationFeatureInGameGuide.CanShowPerform(self.res_id)
  self:SetWidgetVisible(self.UIRoot.Button_Perform, CanShowGuide, true)
  self.UIRoot.CanvasPanel_32:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CanvasPanel_Limit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.UTRichTextBlock_3:SetText(LocUtil.GetLocalizeResStr(88145))
  if CanShowGuide then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local HasItem = wardrobe_data:GetItemExpireTime(self.res_id)
    if HasItem == 0 then
    elseif HasItem == -1 then
      self.UIRoot.CanvasPanel_32:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    else
      self.UIRoot.CanvasPanel_Limit:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    end
  end
end
function TinyTips:OnPlayInteractiveAction()
  local itemResId = self.res_id
  log(bWriteLog and "TinyTips:OnPlayInteractiveAction")
  local logic_wardrobe_interactive_action = require("client.slua.logic.wardrobe.logic_wardrobe_interactive_action")
  local item_tips_util = require("client.slua.umg.Wardrobe.tips.item_tips_util")
  local wardrobeUI = item_tips_util:GetWardrobeUI()
  local wardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  logic_wardrobe_interactive_action.PlayInteractiveAction(itemResId, nil, function()
    local TableUtil = require("common.table_util")
    wardrobeUI.jumpPageId = TableUtil.GetTableValue(wardrobeMacro, "ENUM_WardrobePageTypeId", "ENUM_WardrobePageType_Parachute")
    wardrobeUI.jumpSubTabId = TableUtil.GetTableValue(wardrobeMacro, "ENUM_WardrobeSubTabString", "ENUM_WardrobeSubTabString_interactive_action")
    if wardrobeUI.UIRoot then
      wardrobeUI.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    end
    wardrobeUI.jumpPageId = nil
    wardrobeUI.jumpSubTabId = nil
  end)
  wardrobeUI.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyUI(false)
  self:PlayAudio(sound_config.click_v1)
end
function TinyTips:OnChangeColorClicked()
  self:PlayAudio(sound_config.click_v1)
  local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
  logic_suit_dye:EnterSuitDyeBySuitId(self.res_id, 1)
end
function TinyTips:RefreshHideButton()
  local LogicUserBattleDataManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicUserBattleDataManager)
  local bNeedHideBag = LogicUserBattleDataManager:GetHideBagSetting(self.res_id)
  if bNeedHideBag then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  end
end
function TinyTips:RefreshHideFaceButton()
  self.UIRoot.TextBlock_18:SetText(LocUtil.GetLocalizeResStr(66487))
  self.UIRoot.TextBlock_19:SetText(LocUtil.GetLocalizeResStr(66487))
  local LogicUserBattleDataManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicUserBattleDataManager)
  local bNeedHideBag = LogicUserBattleDataManager:GetHideFaceSetting(self.res_id)
  if bNeedHideBag then
    self.UIRoot.WidgetSwitcher_3:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_3:SetActiveWidgetIndex(0)
  end
end
function TinyTips:RefreshColorFollowButton(Flag)
  self:SetWidgetVisible(self.UIRoot.Button_ColorFollow, false, true)
  local WeaponDiffColorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.WeaponDiffColorModule)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local Source = wardrobe_data:GetItemSource(self.ins_id)
  local bIsUnlock = WeaponDiffColorModule:HasDiffColorPrivilege(Source)
  if bIsUnlock == nil then
    return
  end
  self:SetWidgetVisible(self.UIRoot.Button_ColorFollow, true, true)
  self:SetWidgetVisible(self.UIRoot.LockColorFollow, not bIsUnlock, false)
  local CurFlag = Flag or WeaponDiffColorModule:CheckWeaponColorFollowSwitch(self.res_id, Source)
  if CurFlag ~= nil then
    local string_util = require("common.string_util")
    local LogicArmory = require("client.logic.armory.logic_armory")
    local ItemUpgradeModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
    if CurFlag == true then
      CurFlag = 1
    else
      CurFlag = 0
    end
    local Cfg = CDataTable.GetTableByFilter("WardrobeTipColorSwitchIcon", "SuitID", tonumber(self.res_id), "Switch", tonumber(CurFlag))
    if not Cfg then
      return
    end
    local IconPath, Color
    for _, v in pairs(Cfg) do
      local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
      local TempArray = string_util.Split(v.SkinBaseIDs, "|")
      for i, id in pairs(TempArray) do
        local ResID = tonumber(id)
        local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
        local groupList = ItemUpgradeMgr:GetUpgradeGroupByItemID(ResID)
        for _, cfg in ipairs(groupList) do
          if wardrobe_data:GetHallDepotItemDataByResID(cfg.ItemID, Source) ~= nil then
            IconPath = v.IconPath
            if v.Color ~= "" then
              Color = v.Color
            end
            break
          end
        end
      end
      if IconPath then
        break
      end
    end
    if IconPath then
      self:SetTexture(self.UIRoot.Image_Icon, IconPath)
      local Brush = slua.IndexReference(self.UIRoot.Image_Icon, "Brush"):clone()
      if Color then
        local R = tonumber(string.sub(Color, 1, 2), 16) / 255.0
        local G = tonumber(string.sub(Color, 3, 4), 16) / 255.0
        local B = tonumber(string.sub(Color, 5), 16) / 255.0
        Brush.TintColor = FSlateColor(FLinearColor(R, G, B, 1))
      else
        Brush.TintColor = FSlateColor(FLinearColor(1, 1, 1, 1))
      end
      self.UIRoot.Image_Icon:SetBrush(Brush)
    end
  end
end
function TinyTips:OnDataChange(_, _, ItemData)
  if ItemData.instid == self.ins_id then
    self.res_id = ItemData.res_id
  end
end
function TinyTips:OnClickPackage()
  local LogicUserBattleDataManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicUserBattleDataManager)
  local CurrentHiddenState = LogicUserBattleDataManager:GetHideBagSetting(self.res_id)
  local bNeedHideBag = not CurrentHiddenState
  LogicUserBattleDataManager:SetHideBagData(self.res_id, bNeedHideBag)
  if bNeedHideBag then
    local AvatarHideBagConfig = CDataTable.GetTableData("AvatarHideBagConfig", self.res_id)
    if AvatarHideBagConfig and AvatarHideBagConfig.TipsId then
      ShowNotice(AvatarHideBagConfig.TipsId)
    end
  end
  local reason_str = bNeedHideBag and 1 or 0
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Wardrobe_HideBack, self.res_id, reason_str, false)
  self:RefreshHideButton()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_HIDESETTING_CHANGE)
end
function TinyTips:OnClickHideFace()
  self:PlayAudio(sound_config.click_v1)
  if not self.res_id then
    log(bWriteLog and "TinyTips:OnClickHideFace not res_id")
    return
  end
  local LogicUserBattleDataManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicUserBattleDataManager)
  local CurrentHiddenState = LogicUserBattleDataManager:GetHideFaceSetting(self.res_id)
  local bNeedHide = not CurrentHiddenState
  LogicUserBattleDataManager:SetHideFaceData(self.res_id, bNeedHide)
  if bNeedHide then
    ShowNotice(66488)
  end
  self:RefreshHideFaceButton()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_HIDESETTING_CHANGE)
end
function TinyTips:OnClickToggleColorFollow()
  self:PlayAudio(sound_config.click_v1)
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.WeaponDiffColor, false) then
    ShowNotice(34735)
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local Source = wardrobe_data:GetItemSource(self.ins_id)
  local WeaponDiffColorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.WeaponDiffColorModule)
  if not WeaponDiffColorModule:HasDiffColorPrivilege(Source) then
    ShowNotice(64356)
    return
  end
  local CurFlag = WeaponDiffColorModule:CheckWeaponColorFollowSwitch(self.res_id, Source)
  local ItemUpGradeHandler = require("client.network.Protocol.ItemUpGradeHandler")
  if CurFlag ~= nil then
    ItemUpGradeHandler.send_taluo_set_dress_change_gun_flag_req(self.res_id, not CurFlag, Source)
  end
end
function TinyTips:OnGetColorFollowButtonFlag(_, _)
  local item_tips_util = require("client.slua.umg.Wardrobe.tips.item_tips_util")
  if item_tips_util:ShowColorFollowButton(self.res_id, self.ins_id) then
    self:RefreshColorFollowButton()
  end
end
function TinyTips:OnClickDetail()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.PlayAccelerateEffect()
end
function TinyTips:OnClickStartUpFX()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.PlayVehicleStartUpEffect()
end
function TinyTips:OnClickChangeHead()
  self:PlayAudio(sound_config.click_v1)
  local LobbyIdleUnlock = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyIdleUnlock)
  self:OpenCollectUnlockTips(LobbyIdleUnlock.E_CollectType.E_Type_ChangeHead)
end
function TinyTips:OnClickSpecialIdle()
  self:PlayAudio(sound_config.click_v1)
  local LobbyIdleUnlock = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyIdleUnlock)
  self:OpenCollectUnlockTips(LobbyIdleUnlock.E_CollectType.E_Type_SpecialIdle)
end
function TinyTips:OpenCollectUnlockTips(type)
  if UIManager.GetUI(UIManager.UI_Config.Wardrobe_Avatar_Tips_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.Wardrobe_Avatar_Tips_UIBP)
  end
  local UIUtil = require("client.common.ui_util")
  local LobbyIdleUnlock = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyIdleUnlock)
  local ButtonAbsPos = {X = 0, Y = 0}
  if type == LobbyIdleUnlock.E_CollectType.E_Type_ChangeHead then
    ButtonAbsPos = UIUtil.GetWidgetViewportPos(self.UIRoot.Button_ChangeHead, 0, 0)
  elseif type == LobbyIdleUnlock.E_CollectType.E_Type_SpecialIdle then
    ButtonAbsPos = UIUtil.GetWidgetViewportPos(self.UIRoot.Button_SpecialIdle, 0, 0)
  end
  UIManager.ShowUI(UIManager.UI_Config.Wardrobe_Avatar_Tips_UIBP, self.res_id, ButtonAbsPos, type)
end
function TinyTips:OnClickGarageEdit()
  self:PlayAudio(sound_config.subTab_v1)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local isInTeam = TeamUpNewSystem.IsInTeam()
  if isInTeam then
    ShowNotice(508542)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.SportCar_Garage_Edit_UIBP)
end
function TinyTips:OnClickThemeUpgrade()
  self:PlayAudio(sound_config.click_v1)
  local JumpConfigItem
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    JumpConfigItem = CDataTable.GetTableData("ItemSourceJumpINConfig", self.res_id)
  elseif PublishRegionMacros.IsJapanOrKorea() then
    JumpConfigItem = CDataTable.GetTableData("ItemSourceJumpJKConfig", self.res_id)
  else
    JumpConfigItem = CDataTable.GetTableData("ItemSourceJumpConfig", self.res_id)
  end
  local jump_type = ""
  if JumpConfigItem then
    jump_type = JumpConfigItem.JumpType
  end
  if jump_type ~= "" then
    local jump_id = tonumber(jump_type)
    local jump_table = CDataTable.GetTableData("JumpConfig", jump_id)
    if jump_table and jump_table.JumpUrl ~= "" then
      GlobalData.JumpUrl(jump_table.JumpUrl)
    end
  end
end
function TinyTips:OnClickBtnRandomVoice()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_PLAY_RANDOM_VOICE_FEATURE)
end
function TinyTips:OnClickBtnBattleDamage()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local curAvatar = TeamAvatarManager:GetMainAvatar()
  if curAvatar == nil or curAvatar:GetModel() == nil then
    return
  end
  local ECharacterEffectTriggerCondition = import("ECharacterEffectTriggerCondition")
  if self.BattleDamageBackTimer then
    return
  end
  EventSystem:postEvent(EVENTTYPE_CHARACTER_EFFECT, EVENTID_CHARACTER_EFFECT_APPLY, curAvatar:GetModel(), ECharacterEffectTriggerCondition.LobbyDisplay_LowHealth)
  self.BattleDamageBackTimer = self:AddTimerOnce(5, function()
    self.BattleDamageBackTimer = nil
    if curAvatar == nil or curAvatar:GetModel() == nil then
      return
    end
    EventSystem:postEvent(EVENTTYPE_CHARACTER_EFFECT, EVENTID_CHARACTER_EFFECT_APPLY, curAvatar:GetModel(), ECharacterEffectTriggerCondition.LobbyDisplay_HighHealth)
  end)
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_depot_cloth_feature_trigger_req(self.ins_id)
end
function TinyTips:OnClickAerialShow()
  local LogicAerialShow = require("client.slua.logic.glider.logic_aerial_show")
  if not LogicAerialShow:CanPlayAerialShow() then
    return
  end
  local AvatarAnimInst = LogicAerialShow:GetAvatarAnimInstance(LogicAerialShow.Enum_SceneSource.Feature)
  if AvatarAnimInst then
    local Montage = LogicAerialShow:GetAvatarAnimMontage(self.res_id)
    if Montage then
      local EMontagePlayReturnType = import("EMontagePlayReturnType")
      AvatarAnimInst:Montage_Play(Montage, 1, EMontagePlayReturnType.Duration, 0)
    end
  end
  local GliderAnimInst = LogicAerialShow:GetGliderAnimInstance(LogicAerialShow.Enum_SceneSource.Feature)
  if GliderAnimInst then
    local Montage = LogicAerialShow:GetGliderAnimMontage(self.res_id)
    if Montage then
      local EMontagePlayReturnType = import("EMontagePlayReturnType")
      GliderAnimInst:Montage_Play(Montage, 1, EMontagePlayReturnType.Duration, 0)
    end
  end
end
function TinyTips:OnClickedEquip()
  self:PlayAudio(sound_config.click_v1)
  local itemId = self.res_id
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetAllHallDepotItemDataByResID(itemId)
  if itemData == nil then
    return
  end
  local ClickEffectModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ClickEffectModule)
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  local clickEffectId = ClickEffectModule:GetCurUsedEffectID()
  if clickEffectId == itemId then
    WardRobeHandler.send_depot_put_down_req(tonumber(itemData.insID))
  else
    WardRobeHandler.send_depot_put_on_req(tonumber(itemData.insID))
  end
end
function TinyTips:RefreshEquip(itemInfo)
  local ClickEffectModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ClickEffectModule)
  local clickEffectId = ClickEffectModule:GetCurUsedEffectID()
  if clickEffectId == itemInfo.res_id then
    self.UIRoot.TextBlock_Equip:SetText(LocUtil.GetLocalizeResStr(8438))
  else
    self.UIRoot.TextBlock_Equip:SetText(LocUtil.GetLocalizeResStr(6299))
  end
end
function TinyTips:OnClose()
  self:SetWidgetVisible(self.UIRoot.Button_GarageEdit, false, true)
  TinyTips.__super.OnClose(self)
end
function TinyTips:OnCollectStateUnlock(EventType, EventID, type)
  local LobbyIdleUnlock = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyIdleUnlock)
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  local bNeedShowUnlockPanel = false
  local CP_Lock
  if type == LobbyIdleUnlock.E_CollectType.E_Type_ChangeHead then
    bNeedShowUnlockPanel = logic_suit_multi_shape:NeedShowUnlockPrompt()
    CP_Lock = self.UIRoot.CP_LockChangeHead
  elseif type == LobbyIdleUnlock.E_CollectType.E_Type_SpecialIdle then
    local LobbyIdleUnlock = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyIdleUnlock)
    bNeedShowUnlockPanel = LobbyIdleUnlock:NeedShowUnlockPrompt()
    CP_Lock = self.UIRoot.CP_LockSpecialIdle
  end
  if bNeedShowUnlockPanel then
    self:SetWidgetVisible(CP_Lock, true, false)
  else
    self:SetWidgetVisible(CP_Lock, false, false)
  end
end
function TinyTips:OnCloseCollectTips()
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  local bShowButtonChangeHead = logic_suit_multi_shape:CanCurrentSuitChangeHead(self.res_id)
  local LobbyIdleUnlock = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyIdleUnlock)
  local bShowButtonSpecialIdle = LobbyIdleUnlock:IsNeedShowSpecialIdleIcon(self.res_id)
  if not bShowButtonSpecialIdle and bShowButtonChangeHead then
    self:ShowCollectUnlockTips(bShowButtonChangeHead, bShowButtonSpecialIdle)
  end
end
function TinyTips:OnClickBtnMusic()
  self:PlayAudio(sound_config.click_v1)
  local jumpMusic = function()
    self:PlayAudio(sound_config.click_v1)
    local musicCfg = CDataTable.GetTableData("EmotionToMusic", self.res_id)
    GlobalData.JumpUrl("game://?module=" .. BP_ENUM_MODULE_PUBGM_MUSIC .. "&MusicID=" .. musicCfg.MusicID)
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    LobbyAvatarManager.StopEmoteAction(DataMgr.roleData.uid)
  end
  local titleText = LocUtil.GetLocalizeResStr(69340)
  local descText = LocUtil.GetLocalizeResStr(69341)
  local jumpText = LocUtil.GetLocalizeResStr(69342)
  local tTipsParams = {
    widget = self.UIRoot.Button_Music,
    title = titleText,
    jumpText = jumpText,
    content = descText,
    jumpCallback = jumpMusic
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, tTipsParams)
end
function TinyTips:OnClickBtnPerform()
  self:PlayAudio(sound_config.click_v1)
  local titleText = LocUtil.GetLocalizeResStr(774797)
  local itemInfo = CDataTable.GetTableData("Item", self.res_id)
  local descText = LocUtil.LocalizeResFormat(774793, itemInfo.ItemName or "")
  local PlayAnimationFeatureInGameGuide = require("client.slua.umg.newbie_guide.PlayAnimationFeatureInGameGuide")
  local tTipsParams = {
    widget = self.UIRoot.Button_Perform,
    title = titleText,
    content = descText,
    performance_switch = PlayAnimationFeatureInGameGuide.performance_switch
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, tTipsParams)
end
function TinyTips:OnClickedButton_Gloves()
  self:PlayAudio(sound_config.click_v1)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  if not TeamAvatarManager.CheckHasEquipped(DataMgr.roleData.uid, self.res_id) then
    log(bWriteLog and string.format("TinyTips:OnClickedButton_Gloves not has equipped suit: %s", self.res_id))
    return
  end
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  local emoteID = logic_emote.GetCustomWeaponShowID(self.res_id)
  if emoteID then
    local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    WardrobeLogicManager:PlayMotion(emoteID)
  end
end
function TinyTips:InitHideBagButton()
  if not self.res_id then
    log(bWriteLog and "TinyTips:InitHideBagButton invalid res_id")
    return
  end
  local AvatarHideBagConfig = CDataTable.GetTableData("AvatarHideBagConfig", self.res_id)
  if not AvatarHideBagConfig then
    log(bWriteLog and "TinyTips:InitHideBagButton invalid AvatarHideBagConfig")
    return
  end
  self.UIRoot.TextBlock_2:SetText(LocUtil.GetLocalizeResStr(AvatarHideBagConfig.NameID))
  self.UIRoot.TextBlock_13:SetText(LocUtil.GetLocalizeResStr(AvatarHideBagConfig.NameID))
  if AvatarHideBagConfig.ShowBagIconPath and AvatarHideBagConfig.ShowBagIconPath ~= "" then
    self:SetTexture(self.UIRoot.Image_Package, AvatarHideBagConfig.ShowBagIconPath)
  end
  if AvatarHideBagConfig.HideBagIconPath and AvatarHideBagConfig.HideBagIconPath ~= "" then
    self:SetTexture(self.UIRoot.Image_22, AvatarHideBagConfig.HideBagIconPath)
  end
end
function TinyTips:ShowCollectUnlockTips(bShowButtonChangeHead, bShowButtonSpecialIdle)
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  local bLockChangeHeadVisible = bShowButtonChangeHead and logic_suit_multi_shape:NeedShowUnlockPrompt()
  self:SetWidgetVisible(self.UIRoot.CP_LockChangeHead, bLockChangeHeadVisible, true)
  local LobbyIdleUnlock = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyIdleUnlock)
  local bNeedShowUnlockPrompt = LobbyIdleUnlock:NeedShowUnlockPrompt()
  local bLockSpecialIdleVisible = bShowButtonSpecialIdle and bNeedShowUnlockPrompt
  self:SetWidgetVisible(self.UIRoot.CP_LockSpecialIdle, bLockSpecialIdleVisible, true)
  if bLockSpecialIdleVisible and not self.bHasShowIdleTips then
    self.bHasShowIdleTips = true
    self:AddTimerOnce(0.1, function()
      self:OpenCollectUnlockTips(LobbyIdleUnlock.E_CollectType.E_Type_SpecialIdle)
    end)
    return
  end
  if bLockChangeHeadVisible and not self.bHasShowHeadTips then
    self.bHasShowHeadTips = true
    self:AddTimerOnce(0.1, function()
      self:OpenCollectUnlockTips(LobbyIdleUnlock.E_CollectType.E_Type_ChangeHead)
    end)
  end
end
local class = require("class")
local ui_ItemTipsBase = require("client.slua.umg.Wardrobe.tips.item_tips_base")
local CTinyTips = class(ui_ItemTipsBase, nil, TinyTips)
return CTinyTips