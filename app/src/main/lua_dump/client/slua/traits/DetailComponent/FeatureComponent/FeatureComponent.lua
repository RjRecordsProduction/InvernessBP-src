local FeatureComponent = {}
local Trait = require("common.trait")
local UIBase = require("client.slua_ui_framework.base")
local Traits = {
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureAccelerateEffect"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureDeadBox"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureHitEffect"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureKillBroadcast"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureMusic"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeaturePetEmotion"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeaturePetFeature"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureRaceCar"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureRedEmotion"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureRedIdle"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureStandbyEmotion"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureTips"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureTire"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureVideo"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureVoice"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureVoiceAudition"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureWeaponEmotion"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureWildState"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeaturePlaneNotice"),
  require("client.slua.traits.DetailComponent.AvatarDisplay.TWeaponAutoRotate"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureBornIslandThrow"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureCollectUnlock"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureWingman"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureShow3D"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeaturePerformanceSwitch"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureVehicleStartUpEffect"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureGoldenAction"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeaturePanDefenseEffect"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureSwitchWeaponEffect"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureAliasEnterBroadcast"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureVehicleSwift"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureVehicleAccessoryEffect"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureRandomVoice"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureChangeColorWeapon"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureCartoonStyle"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureBattleDamage"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureAerialShow"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureShowDoubleAircraft"),
  require("client.slua.traits.DetailComponent.FeatureComponent.FeatureTraits.FeatureCombineFeature")
}
local CDetailComponentMain = Trait.TraitClass(UIBase, nil, FeatureComponent, Traits)
local StoreUtils = require("client.slua.logic.store.utils.store_utils")
local StringUtil = require("common.string_util")
local local C_FeatureFuncList = {
  [ENUM_FeatureType.HitEffect] = {
    execute = "PlayHitEffect",
    stop = "StopHitEffect"
  },
  [ENUM_FeatureType.KillBroadcast] = {
    execute = "PlayKillBroadcast",
    stop = "StopKillBroadcast"
  },
  [ENUM_FeatureType.KillBroadcastFull] = {
    execute = "PlayKillBroadcastFull",
    stop = "StopKillBroadcastFull"
  },
  [ENUM_FeatureType.Emotion] = {
    execute = "PlayFeatureEmotion",
    stop = ""
  },
  [ENUM_FeatureType.DeadBox] = {
    execute = "PlayDeadBox",
    stop = "RestoreDeadBox"
  },
  [ENUM_FeatureType.WeaponEmotion] = {
    execute = "PlayWeaponEmotion",
    stop = "StopWeaponEmotion"
  },
  [ENUM_FeatureType.Voice] = {execute = "", stop = "StopVoice"},
  [ENUM_FeatureType.PetEmotion] = {
    execute = "PlayPetEmotion",
    stop = ""
  },
  [ENUM_FeatureType.Glide] = {execute = "PlayGlide", stop = ""},
  [ENUM_FeatureType.Video] = {
    execute = "PlayVideoPure",
    stop = ""
  },
  [ENUM_FeatureType.Grenade] = {execute = "", stop = ""},
  [ENUM_FeatureType.Idle] = {
    execute = "UnEquipeWeapon",
    stop = ""
  },
  [ENUM_FeatureType.Music] = {
    execute = "PlayMusicFeature",
    stop = "StopMusicFeature"
  },
  [ENUM_FeatureType.Display] = {
    execute = "DisplayOnly",
    stop = ""
  },
  [ENUM_FeatureType.DeadShow] = {
    execute = "PlayDeadShow",
    stop = "RestoreDeadShow"
  },
  [ENUM_FeatureType.RaceCarEnterTeamShow] = {
    execute = "PlayRaceCarEnterTeamShow",
    stop = "StopRaceCarEnterTeamShow"
  },
  [ENUM_FeatureType.DispalyTips] = {
    execute = "ShowFeatureTips",
    stop = ""
  },
  [ENUM_FeatureType.ShowComplianceTips] = {
    execute = "ShowComplianceTips",
    stop = ""
  },
  [ENUM_FeatureType.WeaponWildState] = {
    execute = "PlayWeaponWildState",
    stop = "StopWeaponWildState"
  },
  [ENUM_FeatureType.AvatarStandby] = {
    execute = "PlayAvatarStandbyEmotion",
    stop = "StopAvatarStandbyEmotion"
  },
  [ENUM_FeatureType.VoiceAuditionHall] = {
    execute = "ShowVoicePackInfoHall",
    stop = ""
  },
  [ENUM_FeatureType.VoiceAuditionBattle] = {
    execute = "ShowVoicePackInfoBattle",
    stop = ""
  },
  [ENUM_FeatureType.VoiceAuditionDefault] = {
    execute = "ShowVoicePackInfoDefault",
    stop = ""
  },
  [ENUM_FeatureType.Tire] = {
    execute = "PlayTireEffect",
    stop = "StopTireEffect"
  },
  [ENUM_FeatureType.PetColor] = {
    execute = "PlayPetFeature",
    stop = ""
  },
  [ENUM_FeatureType.Accelerate] = {
    execute = "PlayAccelerateEffect",
    stop = "StopAccelerateEffect"
  },
  [ENUM_FeatureType.PlaneNotice] = {
    execute = "PlayPlaneNotice",
    stop = "StopPlaneNotice"
  },
  [ENUM_FeatureType.BornIslandThrow] = {
    execute = "DisplayBornIslandThrow",
    stop = "StopBornIslandThrow"
  },
  [ENUM_FeatureType.GoldenSuitChangeHead] = {
    execute = "ShowCollectUnlockTips",
    stop = "StopCollectUnlockTips"
  },
  [ENUM_FeatureType.WingmanEnterTeamShow] = {
    execute = "PlayWingmanEnterTeamShow",
    stop = "StopWingmanEnterTeamShow"
  },
  [ENUM_FeatureType.DispalyTipsAndContent] = {
    execute = "ShowFeatureTipsAndContent",
    stop = ""
  },
  [ENUM_FeatureType.SpecialIdle] = {
    execute = "ShowCollectUnlockTips",
    stop = "StopCollectUnlockTips"
  },
  [ENUM_FeatureType.Show3D] = {execute = "Show3D", stop = "Stop3D"},
  [ENUM_FeatureType.PerformanceSitch] = {
    execute = "OnClickBtnPerform",
    stop = ""
  },
  [ENUM_FeatureType.VehicleStartUpEffect] = {
    execute = "PlayVehicleStartUpEffect",
    stop = "StopVehicleStartUpEffect"
  },
  [ENUM_FeatureType.GoldenAction] = {
    execute = "GoldenAction",
    stop = "StopGoldenAction"
  },
  [ENUM_FeatureType.PanDefenseEffect] = {
    execute = "PlayDefenseEffect",
    stop = "StopDefenseEffect"
  },
  [ENUM_FeatureType.SwitchWeaponEffect] = {
    execute = "PlaySwitchWeaponEffect",
    stop = "StopSwitchWeaponEffect"
  },
  [ENUM_FeatureType.EnterBroadcast] = {
    execute = "PlayEnterBroadcast",
    stop = "StopEnterBroadcast"
  },
  [ENUM_FeatureType.SwiftEffect] = {
    execute = "PlaySwiftEffect",
    stop = "StopSwiftEffect"
  },
  [ENUM_FeatureType.VehicleAccessoryAccel] = {
    execute = "PlayVehicleAccessoryEffect",
    stop = "StopVehicleAccessoryEffect"
  },
  [ENUM_FeatureType.RandomVoice] = {
    execute = "PlayRandomVoice",
    stop = "StopRandomVoice"
  },
  [ENUM_FeatureType.ChangeColorWeapon] = {
    execute = "ShowChangeColorWeapon",
    stop = "StopChangeColorWeapon"
  },
  [ENUM_FeatureType.CartoonStyle] = {
    execute = "ChangeCartoonStyle",
    stop = ""
  },
  [ENUM_FeatureType.BattleDamage] = {
    execute = "PlayBattleDamage",
    stop = "StopBattleDamage"
  },
  [ENUM_FeatureType.AerialShow] = {
    execute = "PlayAerialShow",
    stop = "StopAerialShow"
  },
  [ENUM_FeatureType.DoubleAircraftShow] = {
    execute = "ShowDoubleAircraft",
    stop = "HideDoubleAircraft"
  },
  [ENUM_FeatureType.FeatureListVideo] = {
    execute = "PlayVideoPure",
    stop = "StopVideoPure"
  },
  [ENUM_FeatureType.ClickEmotion] = {
    execute = "PlayFeatureEmotion",
    stop = ""
  },
  [ENUM_FeatureType.VideoEmote] = {
    execute = "PlayFeatureVideoEmote",
    stop = "StopVideoPure"
  },
  [ENUM_FeatureType.CombineFeature] = {
    execute = "ShowCombineFeature",
    stop = "HideCombineFeature"
  }
}
local cullFeatureType = {
  [ENUM_FeatureType.Video] = true,
  [ENUM_FeatureType.Voice] = true,
  [ENUM_FeatureType.ShowComplianceTips] = true
}
local hidePopFeatureType = {
  [ENUM_FeatureType.VoiceAuditionDefault] = true
}
function FeatureComponent:ctor(selfType, initData)
  self.initData = initData or {}
  self.curScene = nil
  self.curFeaturesItemID = 0
  self.featureList = {}
  self.AutoFeatureList = {}
  self.extraData = {}
  self.videoEndPlayEmotionHandle = nil
  self.firstLines = nil
  self.nCurShowModelId = nil
  self.hasSelectStatus = nil
  self._setFeaturesPromise = nil
  self.specialFeatureList = nil
  self.normalFeatureList = nil
  self.allShowFeatureList = nil
  self:InitFeatureComponentSwitch(self.initData.switches, self.initData.curScene)
end
function FeatureComponent:RegistEvents()
  self.LoopScrollGrid_SpeFeature = self:InitChildClassScrollBox(self.UIRoot.LoopScrollGrid_SpeFeature, "client.slua.traits.DetailComponent.FeatureComponent.FeatureItemUIBP", true)
  self.LoopScrollGrid_Feature = self:InitChildClassScrollBox(self.UIRoot.LoopScrollGrid_Feature, "client.slua.traits.DetailComponent.FeatureComponent.FeatureItemUIBP")
  self:AddCommonEvent(EVENTTYPE_STORE_BTNEVENT, EVENTID_STORE_ONCLICK_WEAPON_BUTTON, self.OnStopWeaponEmotion, self)
  self:AddCommonEvent(EVENTTYPE_STORE_BTNEVENT, EVENTID_STORE_CAR_PLAYDOOR_ANIM, self.OnPlayDoorAnim, self)
  self:AddCommonEvent(EVENTTYPE_STORE_BTNEVENT, EVENTID_DETAIL_CLEAR_OTHER_FEATURE, self.OnNotifyOtherFeatureStop, self)
  self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_SHOW_MAIN_UI_ANIMATION, self.OnAutoPlayLoopEmotion, self)
  self:AddCommonEvent(EVENTTYPE_KEY_DESIGN_POINT, EVENTID_KEY_DESIGN_POINT_OPEN, self.OnKDPUIOpen, self)
  self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_REF_PRE_RESTORE, self.PreResetStore, self)
  self:AddCommonEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, self.OneVideoEndPlayEmotion, self)
  self:AddCommonEvent(EVENTTYPE_STORE_BTNEVENT, EVENTID_STORE_CAR_MODEL_LOADED, self.OnStoreCarModelLoaded, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_feature_pop, self.OnClickFeaturePop, self)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  if not ModelDisplayer._showingData then
    ModelDisplayer.Init()
  end
  self:AddDataListener(ModelDisplayer._showingData, "showModelId", self.OnModelChanged, self)
  local curAvatar = ModelDisplayer.GetShowingAvatar()
  if curAvatar and curAvatar:GetModel() then
    self:AddControlEventByControl(curAvatar:GetModel(), "OnChangeEquipment", self.OnAvatarEquipmentChange, self)
  end
end
function FeatureComponent:OnPostInitialize()
  FeatureComponent.__super.OnPostInitialize(self)
  self:InitOffsetInfo()
  if self._setFeaturesPromise then
    self._setFeaturesPromise:Resolve()
  end
end
function FeatureComponent:InitOffsetInfo()
  self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot:SetPadding(FMargin(0, 15, 0, 5))
end
function FeatureComponent:PreResetStore()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.StopAction()
end
function FeatureComponent:OnClose()
  self._setFeaturesPromise = nil
  self.AutoFeatureList = nil
  self.videoEndPlayEmotionHandle = nil
end
function FeatureComponent:StopAllFeatureSync(close, dontStopAction, isClearData, clearFeaturesItemID)
  if not self:IsAsyncLoading() then
    self:StopAllFeature(close, dontStopAction, isClearData, clearFeaturesItemID)
  end
  if isClearData or clearFeaturesItemID then
    self._setFeaturesPromise = nil
  end
end
function FeatureComponent:SetFeatures(itemID, itemType, itemSubType, featuresItems, extra)
  log_warning(bWriteLog and "  FeatureComponent:SetFeatures.  ")
  if not self:IsAsyncLoading() then
    self:InitFeatures(itemID, itemType, itemSubType, featuresItems, extra)
    return
  end
  local Promise = require("common.Promise")
  self._setFeaturesPromise = Promise.new()
  self._setFeaturesPromise:Then(function()
    log(bWriteLog and string.format("FeatureComponent:SetFeatures promise executed."))
    self:InitFeatures(itemID, itemType, itemSubType, featuresItems, extra)
  end, function(reason)
    log(bWriteLog and string.format("FeatureComponent:SetFeatures promise reason : %s", reason))
  end)
end
function FeatureComponent:RemoveSingleFeatureData(featureType)
  if not self:IsAsyncLoading() then
    if not self.featureList then
      return
    end
    local idx
    for i, v in ipairs(self.featureList) do
      if v.config and v.config.featureType == featureType then
        self:StopFeature(v)
        idx = i
      end
    end
    if idx then
      table.remove(self.featureList, idx)
    end
  end
end
function FeatureComponent:CustomizedSwitches(switches, curScene)
  self:InitFeatureComponentSwitch(switches, curScene)
end
function FeatureComponent:GetCurrentFeatureItemID()
  return self.curFeaturesItemID
end
function FeatureComponent:GetShowFeatures()
  return self.specialFeatureList, self.normalFeatureList, self.allShowFeatureList
end
function FeatureComponent:InitOneLineFeature(features, itemType, itemSubType, outVFeatureList)
  if not self.switchConfig then
    self:InitFeatureComponentSwitch(self.initData.switches, self.initData.curScene)
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  local shieldByIN = PublishRegionMacros.IsBLUEHOLE() and ModelDisplayTypeHelper.IsKillCounter(itemSubType)
  local logic_store_enter_feature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_store_enter_feature)
  local autoConfig = logic_store_enter_feature:GetAutoEmotionWeightConfig(self.switchConfig.sacredSuitAutoEnterEmotion)
  local isLow = Client.GetMemorySize() < HDmpveRemote.HDmpveRemoteConfigGetInt("HideLobbySpinVideo", 0)
  for _, feature in ipairs(features) do
    local featureID = feature.FeatureID
    local cfg = CDataTable.GetTableData("FeaturesConfig", tonumber(featureID))
    if not cfg then
    elseif StoreUtils.CheckExcludeForCurRegion(cfg) then
      log(bWriteLog and "[tinghaohu]StoreDetail:InitOneLineFeature, featureId = " .. tostring(featureID) .. " exclude current region.")
    elseif not self:CheckAccessoryMeets(cfg) then
      log(bWriteLog and "FeatureComponent:InitOneLineFeature, accessory requirement for featureId " .. tostring(featureID) .. " is not meet.")
    else
      local data = StoreUtils.GetFeatureData(cfg, itemType, itemSubType, self.extraData.bEnableCameraAnim, feature.minLv)
      if data and next(data) then
        data.        self.featureList[#self.featureList + 1] = data
        local featureType = data.config.FeatureType
        if data.btnIcon ~= "" and not cullFeatureType[featureType] and (not isLow or featureType ~= ENUM_FeatureType.Video) then
          outVFeatureList[#outVFeatureList + 1] = data
          self.allShowFeatureList[#self.allShowFeatureList + 1] = data
        end
        if featureType == ENUM_FeatureType.Video and not isLow and self.switchConfig.skipAutoPlayVideo and not shieldByIN then
          self.AutoFeatureList[#self.AutoFeatureList + 1] = data
        end
        if featureType == ENUM_FeatureType.VideoEmote and logic_store_enter_feature:CheckEmotionAutoPlay(data.config.DescID, self.oldDescID, autoConfig) then
          self.oldDescID = data.config.DescID
          self.AutoFeatureList[#self.AutoFeatureList + 1] = data
        end
        if featureType == ENUM_FeatureType.Emotion and logic_store_enter_feature:CheckEmotionAutoPlay(data.config.DescID, self.oldDescID, autoConfig) then
          self.oldDescID = data.config.DescID
          self.AutoFeatureList[#self.AutoFeatureList + 1] = data
        end
        if featureType == ENUM_FeatureType.PetEmotion then
          self.AutoFeatureList[#self.AutoFeatureList + 1] = data
        end
        if featureType == ENUM_FeatureType.Glide then
          self.AutoFeatureList[#self.AutoFeatureList + 1] = data
        end
        if featureType == ENUM_FeatureType.Tire then
          self.TireFeatureData = data
        end
        if featureType == ENUM_FeatureType.Voice then
          self:InitFeatureVoiceList(data)
        end
        data.curFeaturesItemID = self.curFeaturesItemID
      end
    end
  end
end
function FeatureComponent:InitFeatures(itemID, itemType, itemSubType, featuresItems, extra)
  print(bWriteLog and "FeatureComponent:InitFeatures", itemID)
  self.extraData = extra or {}
  self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local dontStopAction = self.extraData.dontStopAction
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsEmotion(itemType) then
    dontStopAction = true
  end
  self:StopAllFeature(true, dontStopAction, true, true)
  self.curFeaturesItemID = itemID
  self.AutoFeatureList = {}
  self.firstLines = nil
  self.featureList = {}
  self.oldDescID = 0
  self.specialFeatureList = {}
  self.normalFeatureList = {}
  self.allShowFeatureList = {}
  self:InitFeatureData(featuresItems, itemType, itemSubType)
  if self.extraData.canExecuteAutoPlay ~= false then
    self:ExecuteAutoPlay()
  end
  self:SetLoopSize()
  self.LoopScrollGrid_SpeFeature:SetData(self.specialFeatureList)
  self.LoopScrollGrid_Feature:SetData(self.normalFeatureList)
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_SPECIAL_FEATURE, self.featureList)
end
function FeatureComponent:InitFeatureData(featuresItems, itemType, itemSubType)
  local featureCache = {}
  local SFeatures = {}
  local Features = {}
  for index, featuresItem in pairs(featuresItems) do
    local features = featuresItem.SFeatures ~= "" and StringUtil.Split(featuresItem.SFeatures, ";") or {}
    log_warning(bWriteLog and "  FeatureComponent:InitFeatures. featuresItem.Features: " .. tostring(featuresItem.Features))
    log_warning(bWriteLog and "  FeatureComponent:InitFeatures. featuresItem.SFeatures: " .. tostring(featuresItem.SFeatures))
    for _, featureID in ipairs(features) do
      local FeatureID = tonumber(featureID)
      if FeatureID and not featureCache[FeatureID] then
        table.insert(SFeatures, {FeatureID = FeatureID, minLv = index})
        featureCache[FeatureID] = #Features
      elseif FeatureID then
        local curMinLv = Features[featureCache[FeatureID]].minLv
        Features[featureCache[FeatureID]].minLv = index < curMinLv and index or curMinLv
      end
    end
    features = featuresItem.Features ~= "" and StringUtil.Split(featuresItem.Features, ";") or {}
    for _, featureID in ipairs(features) do
      local FeatureID = tonumber(featureID)
      if FeatureID and not featureCache[FeatureID] then
        table.insert(Features, {FeatureID = FeatureID, minLv = index})
        featureCache[FeatureID] = #Features
      elseif FeatureID then
        local curMinLv = Features[featureCache[FeatureID]].minLv
        Features[featureCache[FeatureID]].minLv = index < curMinLv and index or curMinLv
      end
    end
  end
  if next(SFeatures) then
    self:InitOneLineFeature(SFeatures, itemType, itemSubType, self.specialFeatureList)
    for _, v in ipairs(self.specialFeatureList) do
      v.bIsSpeFeature = true
    end
  end
  if next(Features) then
    self:InitOneLineFeature(Features, itemType, itemSubType, self.normalFeatureList)
  end
end
function FeatureComponent:_ApplyLoopScrollGridSize(loopData, loopScrollGridWidget)
  if not loopScrollGridWidget then
    return
  end
  local len = #loopData
  local size = loopScrollGridWidget.Slot:GetSize()
  if len == 0 then
    size.X = 0
    loopScrollGridWidget.Slot:SetSize(size)
    return
  end
  local ItemSize = loopScrollGridWidget.ItemSize
  local Padding = loopScrollGridWidget.Padding
  local itemWidth = ItemSize.X + Padding.X
  local width = 0
  if 3 < len then
    width = itemWidth * 3 + itemWidth / 2 - 4
  else
    width = itemWidth * len
  end
  size.X = width
  loopScrollGridWidget.Slot:SetSize(size)
end
function FeatureComponent:SetLoopSize()
  local UIRoot = self.UIRoot
  self:SetWidgetVisible(UIRoot.Button_feature_pop, false)
  self:_ApplyLoopScrollGridSize(self.specialFeatureList, UIRoot.LoopScrollGrid_SpeFeature)
  self:_ApplyLoopScrollGridSize(self.normalFeatureList, UIRoot.LoopScrollGrid_Feature)
  local totalShown = #self.specialFeatureList + #self.normalFeatureList
  if totalShown == 0 then
    log_warning(bWriteLog and "  FeatureComponent:SetLoopSize.  no Feature")
    return
  end
  local bHideFeaturePop = false
  for _, v in ipairs(self.allShowFeatureList) do
    if hidePopFeatureType[v.config.FeatureType] then
      bHideFeaturePop = true
      break
    end
  end
  if not bHideFeaturePop then
    self:SetWidgetVisible(UIRoot.Button_feature_pop, true, true)
  end
  if #self.specialFeatureList == 0 then
    self:SetWidgetVisible(UIRoot.LoopScrollGrid_SpeFeature, false)
  else
    self:SetWidgetVisible(UIRoot.LoopScrollGrid_SpeFeature, true)
  end
  log_warning(bWriteLog and "  FeatureComponent:SetLoopSize. not self.extraData.hideFeatureUI: " .. tostring(not self.extraData.hideFeatureUI))
  if not self.extraData.hideFeatureUI then
    self:SetWidgetVisible(UIRoot.CanvasPanel_Root, true)
  end
end
function FeatureComponent:InitFeatureComponentSwitch(switches, curScene)
  self.switchConfig = {}
  local ConstDetail = require("client.slua.traits.DetailComponent.ConstDetail")
  for i, v in pairs(ConstDetail.DetailCompDefaultConfig.DetailFeatureCompConfig) do
    self.switchConfig[i] = v
  end
  if switches then
    for i, v in pairs(self.switchConfig) do
      if switches[i] ~= nil then
        self.switchConfig[i] = switches[i]
      end
    end
  end
  self.end
function FeatureComponent:CheckAccessoryMeets(featureCfg)
  if not featureCfg then
    return false
  end
  if not featureCfg.DependAccIDs or featureCfg.DependAccIDs == "" then
    return true
  end
  local bMeets = true
  bMeets = false
  local DependAccIDList = StringUtil.Split(featureCfg.DependAccIDs, ";")
  for _, dependAccIDStr in ipairs(DependAccIDList) do
    local dependAccID = tonumber(dependAccIDStr)
    if self.curFeaturesItemID == dependAccID then
      bMeets = true
      break
    end
    if self.extraData and self.extraData.AccessoryList and dependAccID and self.extraData.AccessoryList[dependAccID] then
      bMeets = true
      break
    end
  end
  return bMeets
end
function FeatureComponent:ExecuteAutoPlay()
  log_tree("self.AutoFeatureList", self.AutoFeatureList)
  if not self.AutoFeatureList or not next(self.AutoFeatureList) then
    return
  end
  local logic_store_enter_feature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_store_enter_feature)
  local videoCfg = false
  local emotionCfg = false
  local videoEmoteCfg = false
  local showItemList = self.extraData.itemList or {}
  local curLevel = 1
  for level, itemID in ipairs(showItemList) do
    if itemID == self.curFeaturesItemID then
      curLevel = level
      break
    end
  end
  for i, data in ipairs(self.AutoFeatureList) do
    if curLevel >= data.minLv then
      local _type = data.config.FeatureType
      if _type == ENUM_FeatureType.PetEmotion then
        self:AddTimerOnce(0.2, function()
          StoreUtils.OnClickPetAction(data.config.StoreClickAction)
        end)
      elseif _type == ENUM_FeatureType.Glide then
        logic_store_enter_feature:ExecuteAutoEmotion(data, self.curFeaturesItemID)
      elseif _type == ENUM_FeatureType.Emotion then
        emotionCfg = data
      elseif _type == ENUM_FeatureType.Video then
        videoCfg = data
      elseif _type == ENUM_FeatureType.VideoEmote then
        videoEmoteCfg = data
      end
    end
  end
  local skipFullScreen = self.switchConfig.skipAutoEnterEmotionFullScreen == false
  if (emotionCfg or videoEmoteCfg) and videoCfg then
    if logic_store_enter_feature:JudgeVideoAutoPlay(videoCfg) then
      local success = logic_store_enter_feature:PlayFeatureVideo(videoCfg, false, self.switchConfig.closeDirectly, self.switchConfig.bVideoRestoreMusic)
      if success then
        logic_store_enter_feature:MarkAutoplayHasBeenTriggered(videoCfg.config.ID)
        self.videoEndPlayEmotionHandle = {
          videoPath = videoCfg.config.Video,
          playHandle = function()
            if emotionCfg then
              logic_store_enter_feature:ExecuteAutoEmotion(emotionCfg, self.curFeaturesItemID, false, true, true)
            else
              logic_store_enter_feature:PlayFeatureVideoEmote(videoEmoteCfg, false)
            end
          end
        }
      end
    elseif emotionCfg then
      logic_store_enter_feature:ExecuteAutoEmotion(emotionCfg, self.curFeaturesItemID, false, true, skipFullScreen)
    else
      logic_store_enter_feature:PlayFeatureVideoEmote(videoEmoteCfg, skipFullScreen)
    end
  elseif videoCfg then
    if logic_store_enter_feature:JudgeVideoAutoPlay(videoCfg) then
      local success = logic_store_enter_feature:PlayFeatureVideo(videoCfg, false, self.switchConfig.closeDirectly, self.switchConfig.bVideoRestoreMusic)
      if success then
        logic_store_enter_feature:MarkAutoplayHasBeenTriggered(videoCfg.config.ID)
      end
    end
  elseif emotionCfg then
    logic_store_enter_feature:ExecuteAutoEmotion(emotionCfg, self.curFeaturesItemID, false, false, skipFullScreen)
  elseif videoEmoteCfg then
    logic_store_enter_feature:PlayFeatureVideoEmote(videoEmoteCfg, skipFullScreen)
  end
end
function FeatureComponent:StopAllFeature(close, dontStopAction, isClearData, clearFeaturesItemID)
  log_warning(bWriteLog and "  FeatureComponent:StopAllFeature.  ")
  self.videoEndPlayEmotionHandle = nil
  for i, v in ipairs(self.featureList) do
    self:StopFeature(v, close, dontStopAction)
  end
  if clearFeaturesItemID then
    self.curFeaturesItemID = 0
  end
  if isClearData then
    self.featureList = {}
  end
end
function FeatureComponent:StopEmotion()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  if ModelDisplayer.GetShowingAvatar() then
    ModelDisplayer.GetShowingAvatar():StopAction()
  end
end
function FeatureComponent:StopFeature(data, close, dontStopAction)
  self:RemoveAllFeatureTimer()
  if data and data.config.FeatureType then
    local featureFunc = C_FeatureFuncList[data.config.FeatureType]
    if featureFunc and featureFunc.stop and featureFunc.stop ~= "" then
      if self[featureFunc.stop] and type(self[featureFunc.stop]) == "function" then
        self[featureFunc.stop](self, close, dontStopAction)
      else
        log_error("StopFeature : This feature has no action, please check logic of show or config!!!" .. tostring(data.config.FeatureType))
      end
    elseif dontStopAction then
    else
      self:StopEmotion()
    end
  end
end
function FeatureComponent:NotifyOtherFeatureStop(data)
  if data == nil then
    return
  end
  log(bWriteLog and string.format("StoreDetail:NotifyOtherFeatureStop, data.featureType:%s", data.config.FeatureType))
  for _, v in pairs(self.featureList) do
    if data.config.FeatureType ~= v.config.FeatureType then
      self:StopFeature(v)
    end
  end
end
function FeatureComponent:OnClickFeatureItem(widget, data)
  if data and data.config.FeatureType then
    local featureFunc = C_FeatureFuncList[data.config.FeatureType]
    if featureFunc and featureFunc.execute and featureFunc.execute ~= "" then
      if self[featureFunc.execute] and type(self[featureFunc.execute]) == "function" then
        self[featureFunc.execute](self, data, widget)
        self:SelectDataLater()
        self:HandleTLog(data)
      else
        log_error("OnClickFeatureItem : This feature has no action, please check logic of show or config!!!" .. tostring(data.config.FeatureType))
      end
    end
  end
end
function FeatureComponent:OnStopWeaponEmotion()
  for i, data in pairs(self.featureList) do
    if data.config.FeatureType == ENUM_FeatureType.WeaponEmotion or data.config.FeatureType == ENUM_FeatureType.AvatarStandby or data.config.FeatureType == ENUM_FeatureType.PanDefenseEffect then
      self:StopFeature(data)
    end
  end
end
function FeatureComponent:OnPlayDoorAnim()
  log(bWriteLog and "StoreDetail Event OnPlayDoorAnim")
  self:StopTireEffect()
  self:StopAccelerateEffect()
  self:StopSwiftEffect()
end
function FeatureComponent:OnNotifyOtherFeatureStop(_, _, data)
  self:NotifyOtherFeatureStop(data)
end
function FeatureComponent:OnAutoPlayLoopEmotion()
  for i, data in pairs(self.featureList) do
    if data.config.FeatureType == ENUM_FeatureType.WeaponEmotion then
      local logic_store_enter_feature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_store_enter_feature)
      logic_store_enter_feature:ExecuteAutoEmotion(data, self.curFeaturesItemID)
    end
  end
end
function FeatureComponent:OnKDPUIOpen(_, _)
  self:StopAllFeature()
end
function FeatureComponent:OnClickFeaturePop()
  self:PlayAudio(sound_config.click_v1)
  self:StopKillBroadcastFull(true)
  UIManager.ShowUI(UIManager.UI_Config.store_feature_popup, self.allShowFeatureList, self.curFeaturesItemID)
end
function FeatureComponent:OneVideoEndPlayEmotion(_, _, videoPath)
  if self.videoEndPlayEmotionHandle and videoPath == self.videoEndPlayEmotionHandle.videoPath then
    self.videoEndPlayEmotionHandle.playHandle()
  end
  self.videoEndPlayEmotionHandle = nil
end
function FeatureComponent:OnModelChanged(_, itemId)
  log_warning(bWriteLog and "  FeatureComponent:OnModelChanged. itemId: " .. tostring(itemId))
  self.nCurShowModelId = itemId
  if self.bGoldenActionTriggered then
    self.bGoldenActionTriggered = false
    self:RefreshFeatureListByModelID()
  else
    self:SelectDataLater()
  end
end
function FeatureComponent:SelectDataLater()
  self.LoopScrollGrid_SpeFeature:RefreshAllItems()
  self.LoopScrollGrid_Feature:RefreshAllItems()
end
function FeatureComponent:RefreshFeatureListByModelID()
  if not self.nCurShowModelId then
    return
  end
  log(bWriteLog and "  FeatureComponent:SelectDataLater. nCurShowModelId: " .. tostring(self.nCurShowModelId))
  local itemID = self.nCurShowModelId
  local featuresItem = CDataTable.GetTableData("FeaturesItems", itemID)
  if not featuresItem then
    log(bWriteLog and "  FeatureComponent:SelectDataLater. no FeaturesItems config for itemID: " .. tostring(itemID))
    return
  end
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if not itemCfg then
    log(bWriteLog and "  FeatureComponent:SelectDataLater. no Item config for itemID: " .. tostring(itemID))
    return
  end
  local oldCanExecuteAutoPlay = self.extraData.canExecuteAutoPlay
  local oldDontStopAction = self.extraData.dontStopAction
  self.extraData.canExecuteAutoPlay = false
  self.extraData.dontStopAction = true
  self:SetFeatures(itemID, itemCfg.ItemType, itemCfg.ItemSubType, {
    [1] = featuresItem
  }, self.extraData)
  self.extraData.canExecuteAutoPlay = oldCanExecuteAutoPlay
  self.extraData.dontStopAction = oldDontStopAction
end
function FeatureComponent:HandleTLog(data)
  local ItemCfg = CDataTable.GetTableData("FeaturesItems", self.curFeaturesItemID)
  if ItemCfg and ItemCfg.NeedTlog == 1 then
    local id = data.config.ID
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.StoreFeature, self.curFeaturesItemID, tostring(id))
  end
end
function FeatureComponent:OnAvatarEquipmentChange()
  self:_UpdateHoldingTarotWeapon()
end
function FeatureComponent:_UpdateHoldingTarotWeapon()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local curAvatar = ModelDisplayer.GetShowingAvatar()
  if not curAvatar then
    return
  end
  local curModel = curAvatar:GetModel()
  if not curModel then
    return
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local curClothID = curModel:GetEquipmentInfoBySlot(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  if curClothID == 0 then
    log(bWriteLog and "FeatureComponent:_UpdateHoldingTarotWeapon Failed to get cloth id")
    return
  end
  local curWeapon = curModel:GetCurUsingWeapon()
  local curWeaponID
  if slua.isValid(curWeapon) then
    curWeaponID = curWeapon:GetItemDefineID().TypeSpecificID
    if not curWeaponID then
      return
    end
    local Cfg = CDataTable.GetTableDataByFilter("WeaponSwitchByClothCfg", "SrcSkinID", curWeaponID)
    if not Cfg then
      return
    end
  else
    return
  end
  local WeaponDiffColorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.WeaponDiffColorModule)
  local dstWeaponID = WeaponDiffColorModule:FindTargetWeaponResID(curClothID, curWeaponID)
  if self.SwitchAnimOptimizeTimer then
    self:RemoveTimer(self.SwitchAnimOptimizeTimer)
    self.SwitchAnimOptimizeTimer = nil
  end
  local TempEmoteEquipmentMap = curAvatar.EmoteEquipmentMap
  curAvatar.EmoteEquipmentMap = {}
  curModel:CharEquipWeaponByResId(dstWeaponID)
  curAvatar.EmoteEquipmentMap = TempEmoteEquipmentMap
end
function FeatureComponent:RemoveAllFeatureTimer()
  self:RemoveAllTimer()
  local logic_store_enter_feature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_store_enter_feature)
  logic_store_enter_feature:RemoveAllFeatureTimer()
end
function FeatureComponent:GetRealShowItemIdAndLv()
  local parentUI = self:GetParentUI()
  if parentUI and parentUI.GetRealShowItemIdAndLv then
    return parentUI:GetRealShowItemIdAndLv()
  end
end
return CDetailComponentMain