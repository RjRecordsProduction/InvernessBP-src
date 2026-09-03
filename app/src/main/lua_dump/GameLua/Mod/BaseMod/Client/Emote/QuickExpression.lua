local AvatarUtils = import("AvatarUtils")
local BackpackUtils = import("BackpackUtils")
local STExtraUIUtils = import("STExtraUIUtils")
local util = require("client.slua_ui_framework.util")
local audio_util = require("client.common.audio_util")
local AkGameplayStatics = import("AkGameplayStatics")
local KismetMathLibrary = import("KismetMathLibrary")
local KismetInputLibrary = import("KismetInputLibrary")
local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local NO_PET = 48672
local PET_INVISIBLE = 48670
local HIDE_TRANSLATION = FVector2D(-20000, 0)
local QuickExpression = {}
local EShowState = {
  None = 0,
  Expression = 1,
  PetExpression = 2,
  Bubble = 3,
  Collection = 4,
  Flaunt = 5
}
local IgnoreEmoteConfig = {
  [12219241] = true,
  [12219243] = true,
  [12219359] = true,
  [12219360] = true,
  [12219440] = true,
  [12219601] = true,
  [12220038] = true,
  [12220100] = true,
  [12220101] = true,
  [12220102] = true,
  [12220349] = true,
  [12220370] = true,
  [12220501] = true
}
function QuickExpression:ctor()
  self.ItemDefineIDTemp = FItemDefineIDDefault()
  self.CurrentIndex = 0
  self.ItemInTheRing = {}
  self.ClothBackpackItem = {}
  self.AllLimitEmoteList = {}
  self.ItemIDToImagePathMap = {}
  self.LoadImageHandleTable = {}
  self.StartPressPoint = FVector2D(0, 0)
  self.bHasInitExpression = false
  self.CurrentShowState = EShowState.None
  self.IndexToPetExpression = {}
  self.uBubbleIDList = {}
  self.CurEmotePage = 0
  self.CurrentRecoverLayout = {}
  self.CollectionList = {}
  self.FlauntList = {}
  self.PetExhibitIndex = -1
  self.RefreshCDInfoTimer = nil
  self._nWeaponShowEmoteID = 0
end
function QuickExpression:Dispose()
  if self.RefreshCDInfoTimer then
    self:RemoveTimer(self.RefreshCDInfoTimer)
    self.RefreshCDInfoTimer = nil
  end
  QuickExpression.__super.Dispose(self)
end
function QuickExpression:SetCanShowSelfieButton(bShow)
  print(bWriteLog and "QuickExpression:SetCanShowSelfieButton", bShow)
  if not bShow then
    if self.CurrentRecoverLayout.Button_Selfie == nil then
      self.CurrentRecoverLayout.Button_Selfie = self.Button_Selfie.RenderTransform.Translation:clone()
    end
    if self.CurrentRecoverLayout.Button_CheckGun == nil then
      self.CurrentRecoverLayout.Button_CheckGun = self.Button_CheckGun.RenderTransform.Translation:clone()
    end
    self.Button_Selfie:SetRenderTranslation(HIDE_TRANSLATION)
    self.Button_CheckGun:SetRenderTranslation(HIDE_TRANSLATION)
  elseif self.CurrentRecoverLayout.Button_Selfie then
    self.Button_Selfie:SetRenderTranslation(self.CurrentRecoverLayout.Button_Selfie)
    self.Button_CheckGun:SetRenderTranslation(self.CurrentRecoverLayout.Button_CheckGun)
  end
end
function QuickExpression:Tick(MyGeometry, InDeltaTime)
  if not self.IsClothDirty then
    return
  end
  self:RefreshEmote()
  self.IsClothDirty = false
end
function QuickExpression:Initialize()
  self:InitExpression()
end
function QuickExpression:InitExpression()
  if self.bHasInitExpression then
    return
  end
  self.bHasInitExpression = true
  self:MakeWidgetArray()
  self:GetEmoteImagePalthMap()
  self.ButtonLength = 90
  local Geometry = self.BorderEX_Ring:GetCachedGeometry()
  self.RingCenter = SlateBlueprintLibrary.GetAbsolutePosition(Geometry)
  local CanvasSlot = WidgetLayoutLibrary.SlotAsCanvasSlot(self.BorderEX_Ring)
  if CanvasSlot then
    local SlotSize = CanvasSlot:GetSize()
    self.RingLength = SlotSize.X
    self.InnerCircleRadius = KismetMathLibrary.FTrunc((SlotSize.Y - self.ButtonLength * 2) / 2)
    self.SectorButtonDegree = 360 / self.EmoteImageArray:Num()
    self.SectorButtonHalfDegree = self.SectorButtonDegree * 0.5
  end
  self:BackpackReceive()
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.GetPlayerCharacterSafety then
    local Character = PlayerController:GetPlayerCharacterSafety()
    if Character and slua.isValid(Character) and Character.GetWeaponManager then
      local WeaponManager = Character:GetWeaponManager()
      if slua.isValid(WeaponManager) then
        self:AddControlEvent(WeaponManager, "ChangeCurrentUsingWeaponDelegate", self.HandleChangeCurrentUsingWeapon, self)
      end
    end
  end
  self:AddControlEvent(self.Button_CheckGun, "OnClicked", self.OnButtonCheckGun, self)
  self:AddControlEvent(self.Button_ChangeAvatarForm, "OnClicked", self.OnButtonChangeAvatarForm, self)
  self:AddControlEvent(self.Button_Transfiguration, "OnClicked", self.OnButtonButton_Transfiguration, self)
  self:AddControlEvent(self.Button_Selfie, "OnClicked", self.OnButton_SelfieClick, self)
  self:AddControlEvent(self.Button_PetFeature, "OnClicked", self.OnButtonPetFeature, self)
  self:AddControlEvent(self.Button_XSuit, "OnClicked", self.OnButtonXSuitEmote, self)
  self:AddControlEvent(self.Button_Bubble_01, "OnClicked", self.OnButtonBubble, self)
  self:AddControlEvent(self.Button_Bubble_02, "OnClicked", self.OnButtonBubble, self)
  self:AddControlEvent(self.Button_EmoteOrPet_01, "OnClicked", self.OnButtonEmoteOrPet, self)
  self:AddControlEvent(self.Button_EmoteOrPet_02, "OnClicked", self.OnButtonEmoteOrPet, self)
  self:AddControlEvent(self.Button_CollectionOrFlaunt_01, "OnClicked", self.OnButtonCollectionOrFlaunt, self)
  self:AddControlEvent(self.Button_CollectionOrFlaunt_02, "OnClicked", self.OnButtonCollectionOrFlaunt, self)
  self:AddControlEvent(self.Button_ShowPet, "OnClicked", self.OnButtonShowPet, self)
  self:AddControlEvent(self.Button_Left, "OnClicked", self.OnButtonLeft, self)
  self:AddControlEvent(self.Button_Right, "OnClicked", self.OnButtonRight, self)
  self:AddControlEvent(self.Button_SubTypeSwitch, "OnClicked", self.OnButtonSubTypeSwitchClick, self)
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  SettingSubsystem:RegisterUserSettingsDelegate_Bool("OpenMyPet", function()
    self:RefreshPetExpression()
  end)
  SettingSubsystem:RegisterUserSettingsDelegate_Bool("OpenMyPetFPP", function()
    self:RefreshPetExpression()
  end)
  self.WidgetSwitcher_CollectionOrFlaunt:SetActiveWidgetIndex(1)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_AVATAR, EVENTID_LOCAL_PLAYEREVENT_AVATAR_ALL_MESH_LOADED, self.OnAvatarAllMeshLoaded, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_WEAPON_SHOW_CHANGE, self.OnCustomWeaponShowChange, self)
end
function QuickExpression:OnCustomWeaponShowChange()
  self:RefreshCheckGunBtnState()
end
function QuickExpression:OnButtonLeft()
  print(bWriteLog and "QuickExpression:OnButtonLeft", self.CurEmotePage)
  if self.CurEmotePage > 0 then
    self.CurEmotePage = self.CurEmotePage - 1
    self:RefreshCirclePanel()
  end
end
function QuickExpression:OnButtonRight()
  print(bWriteLog and "QuickExpression:OnButtonRight", self.CurEmotePage)
  self.CurEmotePage = self.CurEmotePage + 1
  self:RefreshCirclePanel()
end
function QuickExpression:OnButtonEmoteOrPet()
  print(bWriteLog and "QuickExpression:OnButtonEmoteOrPet", self.CurrentShowState)
  if self.WidgetSwitcher_EmoteOrPet:GetActiveWidgetIndex() == 1 then
    self.CurrentShowState = EShowState.PetExpression
  else
    self.CurrentShowState = EShowState.Expression
  end
  self:RefreshCirclePanel()
end
function QuickExpression:OnButtonBubble()
  print(bWriteLog and "QuickExpression:OnButtonBubble", self.CurrentShowState)
  self.CurrentShowState = EShowState.Bubble
  self:RefreshCirclePanel()
end
function QuickExpression:OnButtonCollectionOrFlaunt()
  print(bWriteLog and "QuickExpression:OnButtonCollectionOrFlaunt", self.CurrentShowState)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    self.CurrentShowState = EShowState.Flaunt
  elseif self.WidgetSwitcher_CollectionOrFlaunt:GetActiveWidgetIndex() == 1 then
    self.CurrentShowState = EShowState.Flaunt
  else
    self.CurrentShowState = EShowState.Collection
  end
  self:RefreshCirclePanel()
end
function QuickExpression:OnButtonShowPet()
  print(bWriteLog and "QuickExpression:OnButtonShowPet")
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return false
  end
  SettingSubsystem:SetUserSettings_Bool("OpenMyPetFPP", true)
  SettingSubsystem:SetUserSettings_Bool("OpenMyPet", true)
end
function QuickExpression:OnAvatarAllMeshLoaded()
  print(bWriteLog and "QuickExpression:OnAvatarAllMeshLoaded")
  self:RefreshTransformButton()
  self:RefreshXSuitEmoteButton()
end
function QuickExpression:MakeWidgetArray()
  for i = 1, 12 do
    local Suffix = ""
    if i < 10 then
      Suffix = table.concat({0, i})
    else
      Suffix = table.concat({i})
    end
    local ImageName = table.concat({
      "Image_EX_Ring_",
      Suffix
    })
    local SwitchName = table.concat({
      "WidgetSwitcherEX",
      Suffix
    })
    local TextName = table.concat({
      "Text_EX_Ring_",
      Suffix
    })
    local LockName = table.concat({
      "Image_Lock_",
      Suffix
    })
    local SwitcherName = table.concat({
      "WidgetSwitcher_",
      Suffix
    })
    local CDPanelName = table.concat({
      "CanvasPanel_CD_",
      Suffix
    })
    local CDTextName = table.concat({
      "TextBlock_CD_",
      Suffix
    })
    if self[ImageName] then
      self.EmoteImageArray:Add(self[ImageName])
    end
    if self[SwitchName] then
      self.SlotSwitcherArray:Add(self[SwitchName])
    end
    if self[TextName] then
      self.EmoteNameArray:Add(self[TextName])
    end
    if self[LockName] then
      self.LockImageArray:Add(self[LockName])
    end
    if self[LockName] then
      self.EmoteEffectSwitcherArray:Add(self[SwitcherName])
    end
    if self[CDPanelName] then
      self.CDPanelArray:Add(self[CDPanelName])
    end
    if self[CDTextName] then
      self.CDTextArray:Add(self[CDTextName])
    end
  end
end
function QuickExpression:BackpackReceive()
  self:RefreshEmote()
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SINGLE_ITEM_UPDATED_EMOTE_22, self.RefreshEmote, self)
end
function QuickExpression:RefreshCirclePanel()
  print(bWriteLog and "QuickExpression:RefreshCirclePanel", self.CurrentShowState)
  local PC = slua_GameFrontendHUD:GetPlayerController()
  self.WidgetSwitcher_Bubble:SetActiveWidgetIndex(0)
  self.WidgetSwitcher_Pet:SetActiveWidgetIndex(0)
  self.WidgetSwitcher_Emote:SetActiveWidgetIndex(0)
  self.WidgetSwitcher_Collection:SetActiveWidgetIndex(0)
  self.WidgetSwitcher_Flaunt:SetActiveWidgetIndex(0)
  for _, EmoteEffectSwitcher in pairs(self.EmoteEffectSwitcherArray) do
    if slua.isValid(EmoteEffectSwitcher) then
      EmoteEffectSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  for _, LockImg in pairs(self.LockImageArray) do
    if LockImg then
      LockImg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  for _, CDPanel in pairs(self.CDPanelArray) do
    if CDPanel then
      CDPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  if not self.RefreshCDInfoTimer then
    self.RefreshCDInfoTimer = self:AddTimerLoop(0, function()
      self:RefreshCDInternal()
    end, TIMER_INFINITE, 1)
  end
  if slua.isValid(PC) and PC.IsInPetSpectator and PC:IsInPetSpectator() then
    self.CanvasPanel_Pages:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.CurrentShowState = EShowState.PetExpression
  else
    self.CanvasPanel_Pages:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if self:IsSocialIsland() then
      self.Button_Bubble_01:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      self.Button_Bubble_02:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      self.CanvasPanel_BubblePage:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Button_Bubble_01:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.Button_Bubble_02:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.CanvasPanel_BubblePage:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  if self:NeedHidePetExpression() then
    print(bWriteLog and "NeedHidePetExpressionNeedHidePetExpression")
  end
  self.WidgetSwitcher_Center:SetActiveWidgetIndex(0)
  if slua.isValid(PC) and PC.IsInPetSpectator and PC:IsInPetSpectator() then
    self.WidgetSwitcher_Center:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.WidgetSwitcher_Center:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if IngameSelfieSubsystem and IngameSelfieSubsystem.bIsIngameSelfieMode then
    self.Button_CheckGun:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.Button_CheckGun:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
  self.Button_Left:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.Button_Right:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.CurrentShowState == EShowState.Expression then
    self.WidgetSwitcher_Emote:SetActiveWidgetIndex(1)
    self:RefreshEmote()
  elseif self.CurrentShowState == EShowState.Bubble then
    self.WidgetSwitcher_Bubble:SetActiveWidgetIndex(1)
    self:RefreshBubble()
  elseif self.CurrentShowState == EShowState.PetExpression then
    self.WidgetSwitcher_Pet:SetActiveWidgetIndex(1)
    self:RefreshPetExpression()
  elseif self.CurrentShowState == EShowState.Collection then
    self.WidgetSwitcher_Collection:SetActiveWidgetIndex(1)
    self:RefreshCollection()
  elseif self.CurrentShowState == EShowState.Flaunt then
    self.WidgetSwitcher_Flaunt:SetActiveWidgetIndex(1)
    self:RefreshFlaunt()
  end
  self:RefreshSwitchButtonState()
  self:FeatureButtonRefresh()
end
function QuickExpression:RefreshBubble()
  print(bWriteLog and "QuickExpression:RefreshBubble")
  GameplaySysMgr = require("GameLua.Mod.BaseMod.GamePlay.Core.GameplaySysMgr")
  local uIslandBubbleEmoteSys = GameplaySysMgr.GetSysByName("IslandBubbleEmoteSys")
  if uIslandBubbleEmoteSys ~= nil then
    self.uBubbleIDList = uIslandBubbleEmoteSys:GetBubbleIdList()
    log_tree("uBubbleIDList:", self.uBubbleIDList)
    for _, EmoteName in pairs(self.EmoteNameArray) do
      if EmoteName then
        EmoteName:SetText("")
      end
    end
    for _, SlotSwitcher in pairs(self.SlotSwitcherArray) do
      if SlotSwitcher then
        SlotSwitcher:SetActiveWidgetIndex(1)
      end
    end
    for Index, ID in pairs(self.uBubbleIDList) do
      local EmoteImage = self.EmoteImageArray:Get(Index - 1)
      local SlotSwitcher = self.SlotSwitcherArray:Get(Index - 1)
      local EmoteName = self.EmoteNameArray:Get(Index - 1)
      local sIconPath = uIslandBubbleEmoteSys:GetBubbleIconPath(ID)
      if EmoteImage and SlotSwitcher and EmoteName and sIconPath then
        SlotSwitcher:SetActiveWidgetIndex(0)
        local uiUtil = require("client.slua_ui_framework.util")
        uiUtil.SetTexture(EmoteImage, sIconPath, {sync = false})
        EmoteImage:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
      end
    end
  end
end
function QuickExpression:RefreshPetExpression()
  if self.CurrentShowState ~= EShowState.PetExpression then
    return
  end
  self:RefreshPetInfo()
  print(bWriteLog and "QuickExpression:RefreshPetExpression", self.PetID, self.bShowMyPet)
  for _, EmoteName in pairs(self.EmoteNameArray) do
    if EmoteName then
      EmoteName:SetText("")
    end
  end
  for _, SlotSwitcher in pairs(self.SlotSwitcherArray) do
    if SlotSwitcher then
      SlotSwitcher:SetActiveWidgetIndex(1)
    end
  end
  if not self.PetID or self.PetID <= 0 then
    self.WidgetSwitcher_Center:SetActiveWidgetIndex(1)
    if self:IsPlanPHMode() then
      self.Text_Pet:SetText(LocUtil.GetLocalizeResStr(655424))
    elseif self:IsCollectionMode() then
      self.Text_Pet:SetText(LocUtil.GetLocalizeResStr(880060105))
    else
      self.Text_Pet:SetText(LocUtil.GetLocalizeResStr(NO_PET))
    end
    self.Button_ShowPet:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  if not self.bShowMyPet then
    self.WidgetSwitcher_Center:SetActiveWidgetIndex(1)
    self.Text_Pet:SetText(LocUtil.GetLocalizeResStr(PET_INVISIBLE))
    self.Button_ShowPet:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    return
  end
  self.WidgetSwitcher_Center:SetActiveWidgetIndex(0)
  if self.CurPetExpressionList and 0 < #self.CurPetExpressionList then
    for Index, v in pairs(self.CurPetExpressionList) do
      if Index - 1 >= self.EmoteImageArray:Num() then
        break
      end
      local EmoteImage = self.EmoteImageArray:Get(Index - 1)
      local SlotSwitcher = self.SlotSwitcherArray:Get(Index - 1)
      local EmoteName = self.EmoteNameArray:Get(Index - 1)
      local PetActionData = CDataTable.GetTableData("PetActionTable", v.ID)
      if EmoteImage and SlotSwitcher and EmoteName and PetActionData then
        SlotSwitcher:SetActiveWidgetIndex(0)
        local uiUtil = require("client.slua_ui_framework.util")
        local PetActionID = PetActionData.PetActionID
        local UIUtil = require("client.common.ui_util")
        local icon, bHasAddKnownMissing, isDefaultIcon = UIUtil.GetItemSmallIcon(PetActionID, EmoteImage)
        print(bWriteLog and "QuickExpression:RefreshPetExpression Index", PetActionID, icon, bHasAddKnownMissing, isDefaultIcon)
        if isDefaultIcon then
          print(bWriteLog and "QuickExpression:RefreshPetExpression not exist", Index)
          local defaultPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Download_png.Common_Icon_Download_png"
          uiUtil.SetTexture(EmoteImage, defaultPath, {sync = false})
        else
          local params = {sync = false, bHasAddKnownMissing = bHasAddKnownMissing}
          uiUtil.SetTexture(EmoteImage, icon, params)
        end
        self.IndexToPetExpression[Index] = v.ID
        if v.IsLocked then
          EmoteImage:SetColorAndOpacity(FLinearColor(1, 1, 1, 0.5))
          local LockImg = self.LockImageArray:Get(Index - 1)
          if LockImg then
            LockImg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          end
        else
          EmoteImage:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
          local LockImg = self.LockImageArray:Get(Index - 1)
          if LockImg then
            LockImg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          end
        end
      end
    end
  end
end
function QuickExpression:IsPlanPHMode()
  local CurGameModeID = Client.GetGameModeID(GameFrontendHUD)
  log(bWriteLog and "QuickExpression:IsPlanPHMode CurGameModeID = " .. tostring(CurGameModeID))
  local home_macros = require("client.slua.logic.home.home_macros")
  if tostring(CurGameModeID) == tostring(home_macros.Home_SubMode.Visit) then
    return true
  end
  return false
end
function QuickExpression:IsCollectionMode()
  log(bWriteLog and "QuickExpression:IsCollectionMode")
  return GameStatus.IsCollectionHallMode()
end
function QuickExpression:RefreshCollection()
  print(bWriteLog and "QuickExpression:RefreshCollection", self.CurrentShowState)
  if self.CurrentShowState ~= EShowState.Collection then
    return
  end
  self:RefreshCollectionList()
  log_tree(bWriteLog and "RefreshCollectionList:", self.CollectionList)
  for _, EmoteName in pairs(self.EmoteNameArray) do
    if EmoteName then
      EmoteName:SetText("")
    end
  end
  for _, SlotSwitcher in pairs(self.SlotSwitcherArray) do
    if SlotSwitcher then
      SlotSwitcher:SetActiveWidgetIndex(1)
    end
  end
  for Index, ID in pairs(self.CollectionList) do
    if 12 < Index then
      break
    end
    local EmoteImage = self.EmoteImageArray:Get(Index - 1)
    local SlotSwitcher = self.SlotSwitcherArray:Get(Index - 1)
    local EmoteName = self.EmoteNameArray:Get(Index - 1)
    local UIUtil = require("client.common.ui_util")
    local sIconPath = UIUtil.GetItemSmallIcon(ID)
    if EmoteImage and SlotSwitcher and EmoteName and sIconPath then
      SlotSwitcher:SetActiveWidgetIndex(0)
      local uiUtil = require("client.slua_ui_framework.util")
      uiUtil.SetTexture(EmoteImage, sIconPath, {sync = false})
      EmoteImage:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
    end
  end
end
function QuickExpression:RefreshEmote(_, _, uBackPackComp)
  print(bWriteLog and "QuickExpression:RefreshEmote", self.CurrentShowState)
  if self.CurrentShowState ~= EShowState.Expression then
    return
  end
  local PC = self:GetOwningPlayer()
  if not PC or not slua.isValid(PC) then
    return
  end
  if not uBackPackComp or not slua.isValid(uBackPackComp) then
    uBackPackComp = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(PC)
  end
  if not uBackPackComp or not slua.isValid(uBackPackComp) then
    return
  end
  local QuickExpressionUtils = require("GameLua.Mod.BaseMod.Client.Emote.QuickExpressionUtils")
  self.ClothBackpackItem = QuickExpressionUtils.GetClothBackpackItem()
  local tShowEmoteList, nWeaponEmoteId = QuickExpressionUtils.GetShowExpressionList()
  local MainCity_GamePlay_Tools = require("GameLua.Mod.MainCity.Tools.MainCity_GamePlay_Tools")
  if MainCity_GamePlay_Tools.IsInMainCity() then
    tShowEmoteList = MainCity_GamePlay_Tools.GetExpressionItems()
  end
  self._nWeaponShowEmoteID = nWeaponEmoteId
  self.AllLimitEmoteList = {}
  local ImageNum = self.EmoteImageArray:Num()
  local EmoteNameNum = self.EmoteNameArray:Num()
  self.ItemInTheRing = {}
  self.CurrentIndex = 0
  for _, SlotSwitcher in pairs(self.SlotSwitcherArray) do
    if SlotSwitcher then
      SlotSwitcher:SetActiveWidgetIndex(1)
    end
  end
  local bCanPageLeft = false
  local bCanPageRight = false
  for idx, Data in pairs(tShowEmoteList) do
    local TypeSpecificID = Data.DefineID.TypeSpecificID
    local ShowEffectState = 0
    local nLevel = PC.PlayEmoteFeature.EmoteLevelMap[TypeSpecificID]
    local EmoteConfig = CDataTable.GetTableData("ParticleEmoteCfg", TypeSpecificID)
    if nLevel and EmoteConfig and nLevel >= EmoteConfig.Level then
      local EffectEmoteID = EmoteConfig.EmoteIDLevel2
      if PC.PlayEmoteFeature.ClientCacheShowEmoteEffect and EffectEmoteID then
        TypeSpecificID = EffectEmoteID
        ShowEffectState = 2
      else
        ShowEffectState = 1
      end
    end
    local EmotionConfig = CDataTable.GetTableData("EmotionLimitCfg", TypeSpecificID)
    if EmotionConfig and EmotionConfig.EmotionID then
      self.AllLimitEmoteList[EmotionConfig.EmotionID] = true
    end
    local Name = Data.Name or ""
    print(bWriteLog and "QuickExpression:RefreshEmote idx", idx, self.ItemInTheRing[TypeSpecificID], IgnoreEmoteConfig[TypeSpecificID])
    if not self.ItemInTheRing[TypeSpecificID] and not IgnoreEmoteConfig[TypeSpecificID] then
      local Path = self.ItemIDToImagePathMap[TypeSpecificID]
      if Path then
        local ItemIndex = self.CurrentIndex - self.CurEmotePage * ImageNum
        self.ItemInTheRing[TypeSpecificID] = ItemIndex
        self.CurrentIndex = self.CurrentIndex + 1
        print(bWriteLog and "QuickExpression:RefreshEmote CurrentIndex", self.CurrentIndex, ItemIndex, ImageNum)
        if ItemIndex < 0 then
          bCanPageLeft = true
        elseif ImageNum <= ItemIndex then
          bCanPageRight = true
        else
          local EmoteImage = self.EmoteImageArray:Get(ItemIndex)
          local uiUtil = require("client.slua_ui_framework.util")
          uiUtil.SetTexture(EmoteImage, Path, {sync = false})
          local EffectSwitcher = self.EmoteEffectSwitcherArray:Get(ItemIndex)
          if ShowEffectState == 1 then
            EffectSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            EffectSwitcher:SetActiveWidgetIndex(0)
          elseif ShowEffectState == 2 then
            EffectSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            EffectSwitcher:SetActiveWidgetIndex(1)
          else
            EffectSwitcher:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          end
          EmoteImage:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
          local Switcher = self.SlotSwitcherArray:Get(ItemIndex)
          Switcher:SetActiveWidgetIndex(0)
          local UIUtil = require("client.common.ui_util")
          local LocalizationString = UIUtil.GetLocalizationString(Name)
          local TextWidget = self.EmoteNameArray:Get(ItemIndex)
          TextWidget:SetText(LocalizationString)
        end
      else
        sandbox.LogNormal(bWriteLog and "Can not find image path, id is: ", TypeSpecificID)
      end
    end
  end
  if bCanPageLeft and 0 < self.CurEmotePage then
    self.Button_Left:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
  if bCanPageRight then
    self.Button_Right:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
  for _, Data in pairs(tShowEmoteList) do
    local TypeSpecificID = Data.DefineID.TypeSpecificID
    self:SetEmoteColorState(TypeSpecificID)
  end
  print(bWriteLog and "QuickExpression:RefreshEmote End", self.CurrentIndex, #tShowEmoteList)
end
function QuickExpression:OnMouseButtonDownOnBorder(geometry, mouseEvent)
  local LocalSize = SlateBlueprintLibrary.GetLocalSize(geometry)
  local ScreenPosition = KismetInputLibrary.PointerEvent_GetScreenSpacePosition(mouseEvent)
  local LocalPosition = SlateBlueprintLibrary.AbsoluteToLocal(geometry, ScreenPosition)
  local RingCenterToClickPoint = FVector2D(0, 0)
  RingCenterToClickPoint.X = LocalPosition.X - LocalSize.X * 0.5
  RingCenterToClickPoint.Y = LocalPosition.Y - LocalSize.Y * 0.5
  local RingCenterToClickPointDist = math.sqrt(RingCenterToClickPoint.X * RingCenterToClickPoint.X + RingCenterToClickPoint.Y * RingCenterToClickPoint.Y)
  if RingCenterToClickPointDist > self.InnerCircleRadius and RingCenterToClickPointDist <= self.InnerCircleRadius + self.ButtonLength then
    local bIsRight = 0 < RingCenterToClickPoint.X
    if bIsRight then
      self.ClockWiseOffset = KismetMathLibrary.DegAcos(-RingCenterToClickPoint.Y / RingCenterToClickPointDist)
    else
      self.ClockWiseOffset = 360 - KismetMathLibrary.DegAcos(-RingCenterToClickPoint.Y / RingCenterToClickPointDist)
    end
    if 0 < self.SectorButtonDegree then
      self.SectorButtonNum = KismetMathLibrary.FFloor((self.ClockWiseOffset + self.SectorButtonHalfDegree) / self.SectorButtonDegree)
      if self.SectorButtonNum == self.EmoteImageArray:Num() then
        self.SectorButtonNum = 0
      end
      self:OnClickItem(self.SectorButtonNum)
    end
  end
  return WidgetBlueprintLibrary.Handled()
end
function QuickExpression:OnClickItem(Index)
  print(bWriteLog and "QuickExpression:OnClickItem", Index, self.CurrentShowState)
  if self.CurrentShowState == EShowState.Expression then
    self:TryToPlayEmote(Index)
  elseif self.CurrentShowState == EShowState.PetExpression then
    self:TryToPlayPetExpression(Index)
  elseif self.CurrentShowState == EShowState.Bubble then
    self:TryToPlayBubble(Index)
  elseif self.CurrentShowState == EShowState.Collection then
    self:TryToPlayCollection(Index)
  elseif self.CurrentShowState == EShowState.Flaunt then
    self:TryToPlayFlaunt(Index)
  end
end
function QuickExpression:TryToPlayBubble(Index)
  if self.uBubbleIDList == nil then
    return
  end
  local ID = self.uBubbleIDList[Index + 1]
  print(bWriteLog and "QuickExpression:TryToPlayBubble", Index, ID)
  if ID then
    local uIslandBubbleEmoteSys = GameplaySysMgr.GetSysByName("IslandBubbleEmoteSys")
    if uIslandBubbleEmoteSys ~= nil then
      uIslandBubbleEmoteSys:ReqDoBubbleEmote(ID)
    end
  end
  self:ShowOrHideRing(false)
end
function QuickExpression:TryToPlayPetExpression(Index)
  if self.IndexToPetExpression == nil then
    return
  end
  local ID = self.IndexToPetExpression[Index + 1]
  local PC = slua_GameFrontendHUD:GetPlayerController()
  print(bWriteLog and "QuickExpression:TryToPlayPetExpression " .. tostring(Index) .. ", " .. tostring(ID))
  if slua.isValid(PC) and ID then
    local IsLocked = true
    local nMasterSkillID
    for _, v in pairs(self.CurPetExpressionList) do
      if v.ID == ID then
        IsLocked = v.IsLocked
        nMasterSkillID = v.MasterSkillID
        break
      end
    end
    if IsLocked then
      print(bWriteLog and "QuickExpression:TryToPlayPetExpression IsLocked!! " .. ID)
      IngameTipsTools.BattleNormalTipsByTextID(48775)
      return
    end
    if not self:GetIsEmoteExist(ID) then
      print(bWriteLog and "QuickExpression:OnClickItemWidget PetExpression not exist!! " .. ID)
      IngameTipsTools.BattleNormalTipsByTextID(43005)
      self.ED_QuickExpressShowHide:BroadCast(false)
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOW_OR_HIDE_QUICK_EXPRESSION, false)
      self:ShowOrHideRing(false)
      return
    end
    if PC.IsInPetSpectator and PC:IsInPetSpectator() and PC:GetPetSpectatorComp() and PC:GetPetSpectatorComp().PetSpectatorPawn then
      print(bWriteLog and "QuickExpression:TryToPlayPetExpression IsInPetSpectator" .. ID)
      local ESpectatorPetStateMsgType = import("ESpectatorPetStateMsgType")
      PC:GetPetSpectatorComp().PetSpectatorPawn:LocalHandleSpectatorPetStateMsg(ESpectatorPetStateMsgType.SpectatorPetMsgPlayEmoteMotage, ID)
    else
      local uCurPawn = PC:GetCurPawn()
      if slua.isValid(uCurPawn) and slua.isValid(uCurPawn.PetComponent_BP) and slua.isValid(uCurPawn.PetComponent_BP.PetPawn) then
        local EPetState = import("EPetState")
        if uCurPawn.PetComponent_BP.PetPawn:PetHasState(EPetState.PetParachute) or uCurPawn.PetComponent_BP.PetPawn:PetHasState(EPetState.PetSwimming) or uCurPawn.PetComponent_BP.PetPawn:PetHasState(EPetState.PetSleeping) or uCurPawn.PetComponent_BP.PetPawn:PetHasState(EPetState.PetPlayingFeature) then
          print(bWriteLog and "QuickExpression:OnClickItemWidget pet state is forbidden!")
          IngameTipsTools.BattleNormalTipsByTextID(49084)
          return
        end
      end
      if nMasterSkillID ~= nil and 0 < nMasterSkillID then
        print(bWriteLog and "QuickExpression:OnClickItem Master trigger skill", nMasterSkillID)
        if slua.isValid(uCurPawn) then
          local SkillManager = uCurPawn:GetSkillManager()
          if slua.isValid(SkillManager) then
            local uSkill = SkillManager:GetSkill(nMasterSkillID)
            if uSkill and not uSkill:IsCDOK(SkillManager, -1) then
              local nCD = uSkill:GetCoolDownTime(SkillManager, 0)
              local bUseNewSkillCD = uSkill.bUseNewSkillCD
              print(bWriteLog and string.format("QuickExpression:OnClickItem failed to trigger Master skill:%d : InCD, nCD:%s. bUseNewSkillCD:%s", nMasterSkillID, tostring(nCD), tostring(bUseNewSkillCD)))
              IngameTipsTools.BattleNormalTipsByTextID(7108)
              return
            end
          end
        end
      end
      PC:PlaySpecifiedPetAnimation(ID)
    end
    self:ShowOrHideRing(false)
  end
end
function QuickExpression:TryToPlayEmote(EmoteIndex)
  local EmoteID
  for ID, Index in pairs(self.ItemInTheRing) do
    if Index == EmoteIndex then
      Emote    end
  end
  if not EmoteID then
    return
  end
  if EmoteID == self._nWeaponShowEmoteID then
    local QuickExpressionUtils = require("GameLua.Mod.BaseMod.Client.Emote.QuickExpressionUtils")
    QuickExpressionUtils.TryPlayWeaponShowEmote()
    self:ShowOrHideRing(false)
    return
  end
  local bIsExist = self:GetIsEmoteExist(EmoteID)
  if not bIsExist then
    IngameTipsTools.BattleNormalTipsByTextID(27679)
    self.ED_QuickExpressShowHide:BroadCast(false)
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOW_OR_HIDE_QUICK_EXPRESSION, false)
    self:ShowOrHideRing(false)
    return
  end
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    return
  end
  local PlayerController = self:GetOwningPlayer()
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  local bEmoteIsBan, TipsID = logic_emote.CheckEmoteIsBan(EmoteID)
  if bEmoteIsBan and PlayerController and PlayerController.DisplayGameTipWithMsgID then
    PlayerController:DisplayGameTipWithMsgID(TipsID)
    return
  end
  local bIsWearingEmoteLimitCloth, TipsID = self:CheckIsWearingEmoteLimitCloth(EmoteID)
  local bIsInLimitEmoteList = self.AllLimitEmoteList[EmoteID]
  local bCanPlayEmote = false
  if not bIsInLimitEmoteList or bIsInLimitEmoteList and bIsWearingEmoteLimitCloth then
    bCanPlayEmote = true
  elseif PlayerController and PlayerController.DisplayGameTipWithMsgID then
    PlayerController:DisplayGameTipWithMsgID(6036)
    return
  end
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if logic_emote.CheckIsDanceTogetherEmote(EmoteID) then
    print(bWriteLog and "QuickExpression Play Together Emote")
    bCanPlayEmote = false
    logic_emote.TriggerDanceBuildSkill(EmoteID)
  end
  if bCanPlayEmote then
    self:PlayEmoteInternal(EmoteID)
    local ClientTLogUtil = require("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil")
    ClientTLogUtil.ReportCommonTLogDataByBRPhase(215, 215, tostring(EmoteID), 1)
  elseif TipsID and 0 < TipsID then
    IngameTipsTools.BattleNormalTipsByTextID(TipsID)
  end
  self:ShowOrHideRing(false)
end
function QuickExpression:TryToPlayCollection(EmoteIndex)
  local EmoteID = -1
  if EmoteIndex and 0 <= EmoteIndex then
    EmoteID = self.CollectionList[EmoteIndex + 1]
  end
  print(bWriteLog and "QuickExpression:TryToPlayCollection", EmoteIndex, EmoteID)
  if EmoteID and 0 < EmoteID then
    self:PlayEmoteInternal(EmoteID)
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uPlayerState = GameplayData.GetPlayerState()
    if slua.isValid(uPlayerState) and uPlayerState.RPC_ServerAddGeneralCount then
      uPlayerState:RPC_ServerAddGeneralCount(11041, 1, false)
    end
    self:ShowOrHideRing(false)
  end
end
function QuickExpression:PlayEmoteInternal(EmoteID)
  print(bWriteLog and "QuickExpression:PlayEmoteInternal", EmoteID)
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not (OwningActor and slua.isValid(OwningActor)) or not OwningActor.OnPlayEmote then
    return
  end
  local bIsMovableEmote = false
  local EmoteSubSystem = SubsystemMgr:Get("EmoteSubSystem")
  if EmoteSubSystem then
    bIsMovableEmote = EmoteSubSystem:TryPlayMovableEmote(EmoteID, OwningActor)
  end
  if not bIsMovableEmote then
    local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
    logic_emote.PlayEmote(OwningActor, EmoteID)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_OLD_EXPRESSION_PLAY_EMOTE)
  local PC = slua_GameFrontendHUD:GetPlayerController()
  if PC ~= nil and slua.isValid(PC) then
    PC:CastUIMsg("UIMsg_CloseQuickExpressionRing", "ingame")
  end
  if self.ED_QuickExpressShowHide then
    self.ED_QuickExpressShowHide:BroadCast(false)
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOW_OR_HIDE_QUICK_EXPRESSION, false)
  end
end
function QuickExpression:GetEmoteImagePalthMap()
  local PC = self:GetOwningPlayer()
  if not (PC and slua.isValid(PC) and PC.EmoteItemIDToImagePathMap) or not PC.EmoteItemIDToImageBattlePathMap then
    return
  end
  for Key, Path in pairs(PC.EmoteItemIDToImagePathMap) do
    local BattlePath = PC.EmoteItemIDToImageBattlePathMap:Get(Key)
    if BattlePath then
      self.ItemIDToImagePathMap[Key] = BattlePath
    else
      self.ItemIDToImagePathMap[Key] = Path
    end
  end
end
function QuickExpression:PlayRedClothAudio(ItemID)
  local ItemRecord = CDataTable.GetTableData("Item", ItemID)
  if not ItemRecord then
    return
  end
  if ItemRecord.ItemID == 0 or ItemRecord.RedEmotionSoundPath == "" then
  end
  self.VoiceDelegate = util.GetAssetAsync(ItemRecord.RedEmotionSoundPath, function(AkEvent)
    if AkEvent then
      self:OnLoadSoundFromPath(AkEvent)
    end
  end)
end
function QuickExpression:OnLoadSoundFromPath(Audio)
  if not Audio or not slua.isValid(Audio) then
    return
  end
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    return
  end
  local Location = OwningActor:K2_GetActorLocation()
  local UIUtil = require("client.common.ui_util")
  AkGameplayStatics.PostEventAtLocation(Audio, Location, FRotator(0), "", UIUtil.GetGameInstance())
end
function QuickExpression:RefreshEmoteWhenShow()
  if not self.CanvasPanel_Root then
    return
  end
  local bIsVisible = self.CanvasPanel_Root:IsVisible()
  if bIsVisible then
    self.IsClothDirty = true
  end
end
function QuickExpression:ShowHideRing(IsShow)
  self:ShowOrHideRing(IsShow)
end
function QuickExpression:CheckIsWearingEmoteLimitCloth(EmoteID)
  local EmoteData = CDataTable.GetTableData("EmotionLimitCfg", EmoteID)
  local TipsID = 0
  if EmoteData then
    TipsID = EmoteData.TipsID
    local ItemIDArray = EmoteData.ItemID_a
    if EmoteData.IsShow then
      local bCanPlay = true
      for _, ItemID in pairs(ItemIDArray) do
        if not self.ClothBackpackItem[ItemID] then
          bCanPlay = false
        end
      end
      return bCanPlay, TipsID
    else
      for _, ItemID in pairs(ItemIDArray) do
        if self.ClothBackpackItem[ItemID] then
          return true
        end
      end
    end
  end
  return false, TipsID
end
function QuickExpression:SetEmoteColorState(EmoteID)
  if not self.AllLimitEmoteList[EmoteID] then
    return
  end
  local Index = self.ItemInTheRing[EmoteID]
  if not Index then
    return
  end
  local ImageNum = self.EmoteImageArray:Num()
  if Index < 0 or Index >= ImageNum then
    return
  end
  local Image = self.EmoteImageArray:Get(Index)
  local bIsEmoteExist = self:GetIsEmoteExist(EmoteID)
  local FinalColor = FLinearColor(0.49, 0.49, 0.49, 1.0)
  if bIsEmoteExist then
    local ColorA = KismetMathLibrary.HSVToRGB(0.0, 0.0, 0.2, 1.0)
    local ColorB = KismetMathLibrary.HSVToRGB(0.0, 0.0, 1.0, 1.0)
    local bIsEmoteLimit = self:CheckIsWearingEmoteLimitCloth(EmoteID)
    local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
    local bIsEmoteIsBan, TipsID = logic_emote.CheckEmoteIsBan(EmoteID)
    FinalColor = ColorB
    if not bIsEmoteLimit or bIsEmoteIsBan then
      FinalColor = ColorA
    end
  end
  Image:SetColorAndOpacity(FinalColor)
end
function QuickExpression:IsBornisland()
  local GameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(GameState) or not GameState.GetGameModeState then
    return false
  end
  return GameState:GetGameModeState() == "ReadyState"
end
function QuickExpression:CheckPlayEmote(EmoteIndex)
  return true
end
function QuickExpression:HideRing()
  self:ShowOrHideRing(false)
end
function QuickExpression:GetIsEmoteExist(DefineID)
  self.ItemDefineIDTemp.Type = 22
  self.ItemDefineIDTemp.TypeSpecificID = DefineID
  return BackpackUtils.IsBattleItemHandleExist(self.ItemDefineIDTemp, true, false, false)
end
function QuickExpression:ShowOrHideRing(IsShow)
  audio_util.PlayAudio("/Game/WwiseEvent/UI_hall/Play_UI_click2.Play_UI_click2")
  if not IsShow then
    if self.CurrentShowState == EShowState.None then
      return
    end
    self.LastShowState = self.CurrentShowState
    self.CurrentShowState = EShowState.None
    print(bWriteLog and "QuickExpression:ShowOrHideRing LastShowState close", self.LastShowState, self.CurrentShowState)
    if self:IsHide() then
      return
    end
    self.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local PC = slua_GameFrontendHUD:GetPlayerController()
    if PC ~= nil and slua.isValid(PC) then
      PC:CastUIMsg("UIMsg_CloseQuickExpressionRing", "ingame")
    end
    self:RefreshTransformButton()
    return
  end
  self.CurrentShowState = self.LastShowState or EShowState.Expression
  print(bWriteLog and "QuickExpression:ShowOrHideRing LastShowState open", self.LastShowState, self.CurrentShowState)
  self.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if self.ED_QuickExpressBtnClick then
    self.ED_QuickExpressBtnClick:BroadCast()
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_QUICK_EXPRESSION_CLICK)
  self:GetEmoteImagePalthMap()
  self:RefreshCirclePanel()
  self:PlayUserWidgetAnimation(self.open, 0, 1, 0, 1)
end
function QuickExpression:IsHide()
  return self.CanvasPanel_Root:GetVisibility() == UEnums.ESlateVisibility.Collapsed
end
function QuickExpression:FeatureButtonRefresh()
  log(bWriteLog and "[DeanJYT] QuickExpression:FeatureButtonRefresh")
  self:RefreshCheckGunBtnState()
  self:RefreshChangeAvatarFormBtnState()
  self:RefreshTransformButton()
  self:RefreshSelfieButton()
  self:RefreshPetButton()
  self:RefreshXSuitEmoteButton()
end
function QuickExpression:RefreshCheckGunBtnState()
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if logic_emote.bCustomWeaponShow then
    if self.WidgetSwitcher_Check then
      self.WidgetSwitcher_Check:SetActiveWidgetIndex(1)
    end
  elseif self.WidgetSwitcher_Check then
    self.WidgetSwitcher_Check:SetActiveWidgetIndex(0)
  end
  local CheckGunState = self:GetCurrentCheckGunState()
  print(bWriteLog and "QuickExpression:RefreshCheckGunBtnState", CheckGunState)
  if self.HalfAlpha_LColor == nil then
    self.HalfAlpha_LColor = FLinearColor(1.0, 1.0, 1.0, 0.5)
    self.HalfAlpha_SColor = FSlateColor(FLinearColor(1.0, 1.0, 1.0, 0.5))
    self.FullAlpha_LColor = FLinearColor(1.0, 1.0, 1.0, 1.0)
    self.FullAlpha_SColor = FSlateColor(FLinearColor(1.0, 1.0, 1.0, 1.0))
  end
  if not self.Image_CheckGun or not self.TextBlock_CheckGun then
    return
  end
  if CheckGunState == -1 or CheckGunState == 2 or CheckGunState == 3 then
    self.Image_CheckGun:SetColorAndOpacity(self.HalfAlpha_LColor)
    self.TextBlock_CheckGun:SetColorAndOpacity(self.HalfAlpha_SColor)
  else
    self.Image_CheckGun:SetColorAndOpacity(self.FullAlpha_LColor)
    self.TextBlock_CheckGun:SetColorAndOpacity(self.FullAlpha_SColor)
  end
end
function QuickExpression:HandleChangeCurrentUsingWeapon()
  self:RefreshCheckGunBtnState()
end
function QuickExpression:OnButtonCheckGun()
  self:ShowOrHideRing(false)
  QuickExpression.TryDoCheckGun(self)
end
function QuickExpression:GetCurrentCheckGunState()
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    print(bWriteLog and "QuickExpression:GetCurrentCheckGunState Error 1")
    return -1
  end
  local OwningController = OwningActor:GetPlayerControllerSafety()
  if not OwningController or not slua.isValid(OwningController) then
    print(bWriteLog and "QuickExpression:GetCurrentCheckGunState Error 2")
    return -1
  end
  if not OwningActor.GetCurrentWeapon then
    print(bWriteLog and "QuickExpression:GetCurrentCheckGunState Error 3")
    return -1
  end
  local Weapon = OwningActor:GetCurrentWeapon()
  if not slua.isValid(Weapon) or not slua.isValid(Weapon.WeaponAvatarComponent) then
    return 2
  end
  local EWeaponAttachmentSocketType = import("EWeaponAttachmentSocketType")
  local ECharSpecialLevelSequenceType = import("ECharSpecialLevelSequenceType")
  local WeaponAvatarID = Weapon.WeaponAvatarComponent:GetEquippedItemDefineID(EWeaponAttachmentSocketType.MasterGun).TypeSpecificID
  if WeaponAvatarID <= 0 then
    print(bWriteLog and "QuickExpression:GetCurrentCheckGunState Error A WeaponAvatarID =", WeaponAvatarID)
    WeaponAvatarID = Weapon:GetItemDefineID().TypeSpecificID
  end
  if WeaponAvatarID <= 0 then
    print(bWriteLog and "QuickExpression:GetCurrentCheckGunState Error B WeaponAvatarID =", WeaponAvatarID)
    return -1
  end
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if PhotoGrapherSubSystem and PhotoGrapherSubSystem.bIsPhotoGrapherMode then
    return 1
  end
  local WeaponShowSkillID = 1014433
  if OwningActor.GetSkillManager then
    local SkillMgr = OwningActor:GetSkillManager()
    if Game:IsValid(SkillMgr) and SkillMgr:IsCastingSkillID(WeaponShowSkillID) then
      return 1
    end
  end
  local WeaponAvatarBPID = AvatarUtils.GetBPIDByResID(WeaponAvatarID)
  local WeaponBaseBPID = AvatarUtils.GetWeaponAvatarParentID(WeaponAvatarBPID, false)
  local AvatarHandle = Weapon.WeaponAvatarComponent:GetEquippedHandle(EWeaponAttachmentSocketType.MasterGun)
  local bHasDIYWeaponCheck = false
  if AvatarHandle and slua.isValid(AvatarHandle) and AvatarHandle.WeaponSpecialLevelSequenceList then
    for i, SequenceData in pairs(AvatarHandle.WeaponSpecialLevelSequenceList) do
      if SequenceData.LevelSequenceType == ECharSpecialLevelSequenceType.ECharSpecLvSeq_WeaponCheck then
        local LevelSequenceConfig = SequenceData.LevelSequenceConfig
        if not LevelSequenceConfig or 0 >= LevelSequenceConfig.LevelSequenceDuration then
          print(bWriteLog and "QuickExpression:GetCurrentCheckGunState Error C LevelSequenceConfig =", LevelSequenceConfig)
          return 3
        end
        if LevelSequenceConfig.SequenceActorTemplate:IsNull() or LevelSequenceConfig.LevelSequence:ToSoftObjectPath():IsNull() then
          print(bWriteLog and "QuickExpression:GetCurrentCheckGunState Error D null SequenceActorTemplate or LevelSequence")
          return 3
        end
        bHasDIYWeaponCheck = true
        break
      end
    end
  end
  if not bHasDIYWeaponCheck then
    local WeaponCheckSkillData = CDataTable.GetTableData("WeaponCheckSkill", WeaponBaseBPID)
    if not WeaponCheckSkillData or WeaponCheckSkillData.LevelSequencePath == "" then
      return 3
    end
  end
  if not (OwningActor.CurrentStates == 1 << UEnums.EPawnState.Stand and OwningActor.IsHandleInFold) or OwningActor:IsHandleInFold() then
    return 1
  end
  return 0, WeaponAvatarBPID
end
function QuickExpression:TryDoCheckGun()
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    return
  end
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if logic_emote.bCustomWeaponShow and logic_emote.CustomWeaponShowEmoteID > 0 then
    print(bWriteLog and "QuickExpression:TryDoCheckGun bCustomWeaponShow EmoteID:", logic_emote.CustomWeaponShowEmoteID)
    logic_emote.PlayEmote(OwningActor, logic_emote.CustomWeaponShowEmoteID)
    return
  end
  local CheckGunState, WeaponAvatarBPID = QuickExpression.GetCurrentCheckGunState()
  if CheckGunState ~= 0 then
    local OwningController = OwningActor:GetPlayerControllerSafety()
    if OwningController and slua.isValid(OwningController) and OwningController.DisplayGameTipWithMsgID then
      if CheckGunState == 1 then
        OwningController:DisplayGameTipWithMsgID(44556)
      elseif CheckGunState == 2 then
        OwningController:DisplayGameTipWithMsgID(43600)
      elseif CheckGunState == 3 then
        OwningController:DisplayGameTipWithMsgID(43601)
      else
        print(bWriteLog and "QuickExpression:TryDoCheckGun State", CheckGunState)
      end
    end
    return
  end
  local CheckGunSkillID = 1014405
  local SkillMgr = OwningActor:GetSkillManager()
  if Game:IsValid(SkillMgr) and SkillMgr:IsCastingSkillID(CheckGunSkillID) then
    return
  end
  print(bWriteLog and "QuickExpression:TryDoCheckGun", WeaponAvatarBPID)
  OwningActor:ForceSyncMovementState()
  OwningActor:TriggerEntrySkillWithID(CheckGunSkillID, true)
  local ClientTLogManager = SubsystemMgr:Get("ClientTLogManager")
  if ClientTLogManager then
    ClientTLogManager:AddValueByKey("PlayerUseWeaponCheckFlow", WeaponAvatarBPID, 1)
  end
end
function QuickExpression.GetAvatarFormState(OwningActor)
  local uAvatarComp2 = OwningActor:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    return 0
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local AvatarDesc = uAvatarComp2:GetAvatarSlotDesc(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local AvatarItem = AvatarDesc.ItemDefineID
  local Source = AvatarDesc.CustomInfo.ColorID
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local AvatarPeriod = XSuitUtil:GetPeriodByItemId(AvatarItem.TypeSpecificID)
  if not AvatarPeriod then
    return 0
  end
  local CurState = uAvatarComp2:GetCurAvatarState(AvatarPeriod, Source)
  local MainCity_GamePlay_Tools = require("GameLua.Mod.MainCity.Tools.MainCity_GamePlay_Tools")
  if MainCity_GamePlay_Tools.IsInMainCity() then
    local cfg = XSuitUtil:GetCfgByItemId(AvatarItem.TypeSpecificID)
    if cfg then
      if cfg and cfg.second_item_id then
        CurState = 1
      else
        CurState = 2
      end
      local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
      local nextState = CurState == 1 and 2 or 1
      if not LogicXSuit.CheckUnlockState(AvatarPeriod, nextState, Source) then
        print(bWriteLog and "SkillAction_ChangeAvatarForm:LuaRealDoAction IsInMainCity not unlock ")
        return 0
      end
      print(bWriteLog and "SkillAction_ChangeAvatarForm:LuaRealDoAction IsInMainCity CurState = " .. tostring(CurState))
    end
  end
  return CurState
end
function QuickExpression.GetAvatarFormIcon(OwningActor)
  local uAvatarComp2 = OwningActor:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    return nil
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local AvatarItem = uAvatarComp2:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local Icon = XSuitUtil:GetStateIcon(AvatarItem.TypeSpecificID)
  return Icon
end
function QuickExpression:RefreshChangeAvatarFormBtnState()
  print(bWriteLog and "QuickExpression:RefreshChangeAvatarFormBtnState")
  if self.ChangeAvatarFormCDTimer then
    self:RemoveTimer(self.ChangeAvatarFormCDTimer)
    self.ChangeAvatarFormCDTimer = nil
  end
  self.Button_ChangeAvatarForm:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    return
  end
  local CurState = QuickExpression.GetAvatarFormState(OwningActor)
  if CurState == 0 then
    return
  end
  local Icon = QuickExpression.GetAvatarFormIcon(OwningActor)
  if not Icon then
    return
  end
  self.Button_ChangeAvatarForm:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  util.SetTexture(self.Image_ChangeAvatarForm, Icon, {sync = false})
  self.ChangeAvatarFormCDTimer = self:AddTimerLoop(0, function()
    self:TickChangeAvatarFormCD()
  end, TIMER_INFINITE, 0.2)
end
function QuickExpression:TickChangeAvatarFormCD()
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not slua.isValid(OwningActor) then
    return
  end
  if not slua.isValid(OwningActor.SkillManager) then
    return
  end
  local SkillCDs = OwningActor.SkillManager:GetSkillBaseData(1014419).SkillCDs
  local AvatarChangeCDObject
  if SkillCDs:Num() >= 1 then
    AvatarChangeCDObject = SkillCDs:Get(0)
  end
  if not slua.isValid(AvatarChangeCDObject) then
    return
  end
  if slua.isValid(self.Image_CDTime) then
    local nMaxTime = AvatarChangeCDObject:GetMaxTime()
    local nCurTime = AvatarChangeCDObject:GetCurrentTime()
    local nProgressRate = nCurTime / nMaxTime
    local ImageMaterial = self.Image_CDTime:GetDynamicMaterial()
    if slua.isValid(ImageMaterial) then
      self.Image_CDTime:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      ImageMaterial:SetScalarParameterValue("Mask_Percent", nProgressRate)
    end
  end
end
function QuickExpression:RefreshTransformButton()
  print(bWriteLog and "QuickExpression:RefreshTransformButton")
  if self.ChangeDragonFormCDTimer then
    self:RemoveTimer(self.ChangeDragonFormCDTimer)
    self.ChangeDragonFormCDTimer = nil
  end
  if self:IsHide() then
    return
  end
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    return
  end
  local AvatarChangeFormSubsystem = SubsystemMgr:Get("AvatarChangeFormSubsystem")
  if AvatarChangeFormSubsystem then
    local config = AvatarChangeFormSubsystem:CheckChangeFormCondition(OwningActor)
    if config then
      self.Button_Transfiguration:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      local stateCfg = CDataTable.GetTableData("ClothingStateConfig", config.AfterClothID)
      local BattleIcon = stateCfg and stateCfg.BattleIcon
      if BattleIcon then
        util.SetTexture(self.Image_50, BattleIcon)
      elseif config.ActionType == 0 then
        util.SetTexture(self.Image_50, "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_Transfiguration_png.ZD_Icon_Transfiguration_png")
      else
        util.SetTexture(self.Image_50, "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_Transfiguration_02_png.ZD_Icon_Transfiguration_02_png")
      end
      if GlobalData.IsJapanOrKorea() then
        local bUnlock = AvatarChangeFormSubsystem:GetUnlockState(OwningActor)
        if bUnlock then
          self.Image_mask:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          self.Image_lock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        else
          self.Image_mask:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          self.Image_lock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
      else
        self.Image_mask:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.Image_lock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
      self.ChangeDragonFormCDTimer = self:AddTimerLoop(0, function()
        self:TickChangeDragonFormCD()
      end, TIMER_INFINITE, 0.2)
    else
      self.Button_Transfiguration:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    self.Button_Transfiguration:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function QuickExpression:TickChangeDragonFormCD()
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not slua.isValid(OwningActor) then
    return
  end
  if not slua.isValid(OwningActor.SkillManager) then
    return
  end
  local SkillCDs = OwningActor.SkillManager:GetSkillBaseData(1014419).SkillCDs
  local AvatarChangeCDObject
  if SkillCDs:Num() >= 1 then
    AvatarChangeCDObject = SkillCDs:Get(0)
  end
  if not slua.isValid(AvatarChangeCDObject) then
    return
  end
  if slua.isValid(self.Image_53) then
    local nMaxTime = AvatarChangeCDObject:GetMaxTime()
    local nCurTime = AvatarChangeCDObject:GetCurrentTime()
    local nProgressRate = nCurTime / nMaxTime
    local ImageMaterial = self.Image_53:GetDynamicMaterial()
    if slua.isValid(ImageMaterial) then
      self.Image_53:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      ImageMaterial:SetScalarParameterValue("Mask_Percent", nProgressRate)
    end
  end
end
function QuickExpression:RefreshSelfieButton()
  log(bWriteLog and "[DeanJYT] QuickExpression:RefreshSelfieButton")
  if not LobbySystem.CheckOpen(BP_ENUM_MODULE_SELFIE_SWITCH) then
    self.Button_Selfie:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if not IngameSelfieSubsystem then
    self.Button_Selfie:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    log(bWriteLog and "[DeanJYT] QuickExpression:RefreshSelfieButton cannot get IngameSelfieSubsystem")
    return
  end
  if not IngameSelfieSubsystem:CheckModeCanEnterSelfie() or IngameSelfieSubsystem:GetIsInSelfieMode() then
    log(bWriteLog and "[DeanJYT] QuickExpression:RefreshSelfieButton hide selfie button")
    self.Button_Selfie:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    log(bWriteLog and "[DeanJYT] QuickExpression:RefreshSelfieButton show selfie button")
    self.Button_Selfie:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
end
function QuickExpression:CheckIsSpecialPet()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return false
  end
  local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayerCharacter) or not slua.isValid(uPlayerCharacter.PetComponent_BP) then
    return false
  end
  local PetID = uPlayerCharacter.PetComponent_BP.PetInfo.PetId
  if PetID == 50023 or PetID == 50024 then
    print(bWriteLog and "QuickExpression:CheckIsSpecialPet is special Pet")
    return true
  end
  print(bWriteLog and "QuickExpression:CheckIsSpecialPet is not special ")
  return false
end
function QuickExpression:RefreshPetButton()
  local RetrivePetButton = function()
    local bIsSpecialPet = self:CheckIsSpecialPet()
    if bIsSpecialPet and self.CurrentShowState == EShowState.PetExpression then
      self.Button_PetFeature:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    else
      self.Button_PetFeature:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  RetrivePetButton()
  self:AddTimerLoop(2, function()
    RetrivePetButton()
  end, 5, 1)
end
function QuickExpression:OnButtonChangeAvatarForm()
  self:ShowOrHideRing(false)
  self:ChangeAvatarForm()
end
function QuickExpression:OnButtonButton_Transfiguration()
  self:ShowOrHideRing(false)
  local OwningActor = GameplayData.GetPlayerCharacter()
  local AvatarChangeFormSubsystem = SubsystemMgr:Get("AvatarChangeFormSubsystem")
  if AvatarChangeFormSubsystem then
    AvatarChangeFormSubsystem:TryTransform(OwningActor)
  end
end
function QuickExpression:OnButton_SelfieClick()
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if not IngameSelfieSubsystem then
    log(bWriteLog and "[DeanJYT] QuickExpression:OnButton_SelfieClick cannot get IngameSelfieSubsystem")
    return
  end
  if false == require("GameLua.Mod.SocialIsland.GamePlay.SI_BattleInterface").SocialIslandEmoteCheck() then
    return
  end
  IngameSelfieSubsystem:EnterSelfie()
end
function QuickExpression:OnButtonPetFeature()
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if not PhotoGrapherSubSystem then
    log(bWriteLog and "[HZA] QuickExpression:OnButtonPetFeature cannot get PhotoGrapherSubSystem")
    return
  end
  if PhotoGrapherSubSystem:CheckIsInVehicle() then
    ShowNotice(49084)
    return
  end
  PhotoGrapherSubSystem:PlayPetFeature()
  if self.ShowOrHideRing then
    self:ShowOrHideRing(false)
  end
end
function QuickExpression:CanShowXSuitEmote(LuaObject)
  print(bWriteLog and "QuickExpression:CanShowXSuitEmote")
  if (not self.IsSocialIsland or not self:IsSocialIsland()) and (not LuaObject or not LuaObject:IsSocialIsland()) and (not self.IsBornisland or not self:IsBornisland()) and (not LuaObject or not LuaObject:IsBornisland()) and (not self.IsMainCity or not self:IsMainCity()) and (not LuaObject or not LuaObject:IsMainCity()) then
    print(bWriteLog and "QuickExpression:CanShowXSuitEmote not IsSocialIsland or IsBornisland")
    return false
  end
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    print(bWriteLog and "QuickExpression:CanShowXSuitEmote not OwningActor")
    return false
  end
  local uAvatarComp2 = OwningActor:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    print(bWriteLog and "QuickExpression:CanShowXSuitEmote not uAvatarComp2")
    return false
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) or not uPlayerController.CommerFeature then
    print(bWriteLog and "QuickExpression:CanShowXSuitEmote not uPlayerController")
    return false
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local AvatarItem = uAvatarComp2:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local Period = XSuitUtil:GetPeriodByItemId(AvatarItem.TypeSpecificID)
  if Period and 0 < Period then
    local LowLevelEffect = require("GameLua.Activity.Commercialize.GamePlay.XSuit.LowLevelEffect")
    local UnLockLevel = XSuitUtil:GetUnLockLevelByFeature(AvatarItem.TypeSpecificID, Period, uPlayerController.CommerFeature.XSuitUnlockLevelList)
    local bValid = XSuitUtil:IsValidXSuitEffect(AvatarItem.TypeSpecificID, LowLevelEffect.BornIslandAction, UnLockLevel)
    print(bWriteLog and "QuickExpression:CanShowXSuitEmote bValid=" .. tostring(bValid) .. " TypeSpecificID=" .. tostring(AvatarItem.TypeSpecificID) .. " Period=" .. tostring(Period) .. " UnLockLevel=" .. tostring(UnLockLevel))
    return bValid
  end
  local BornIslandAction = XSuitUtil:GetBornIslandActionByItemID(AvatarItem.TypeSpecificID, uAvatarComp2)
  print(bWriteLog and "QuickExpression:CanShowXSuitEmote BornIslandAction:" .. tostring(BornIslandAction))
  return 0 < BornIslandAction
end
function QuickExpression:RefreshXSuitEmoteButton()
  local canShow = self:CanShowXSuitEmote()
  if canShow then
    self.Button_XSuit:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    local action = self:GetBornIslandAction()
    if action ~= 0 then
      local UIUtil = require("client.common.ui_util")
      util.SetTexture(self.Image_51, UIUtil.GetItemBigIcon(action), {sync = false})
    end
  else
    self.Button_XSuit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.CurrentShowState == EShowState.PetExpression then
    self.Button_XSuit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function QuickExpression:GetBornIslandAction()
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    return 0
  end
  local uAvatarComp2 = OwningActor:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    return 0
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local AvatarItem = uAvatarComp2:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  return XSuitUtil:GetBornIslandActionByItemID(AvatarItem.TypeSpecificID, uAvatarComp2)
end
function QuickExpression:OnButtonXSuitEmote(LuaObject)
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    print(bWriteLog and "QuickExpression:OnButtonXSuitEmote not OwningActor")
    return
  end
  local uAvatarComp2 = OwningActor:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    print(bWriteLog and "QuickExpression:OnButtonXSuitEmote not uAvatarComp2")
    return
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local AvatarItem = uAvatarComp2:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local XSuitUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitUtil")
  local BornIslandAction = XSuitUtil:GetBornIslandActionByItemID(AvatarItem.TypeSpecificID, uAvatarComp2)
  if BornIslandAction == 0 then
    print(bWriteLog and "QuickExpression:OnButtonXSuitEmote BornIslandAction == 0")
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) or not uPlayerController.CommerFeature then
    print(bWriteLog and "QuickExpression:OnButtonXSuitEmote not uPlayerController")
    return
  end
  local LowLevelEffect = require("GameLua.Activity.Commercialize.GamePlay.XSuit.LowLevelEffect")
  local Period = XSuitUtil:GetPeriodByItemId(AvatarItem.TypeSpecificID)
  if Period and 0 < Period then
    local UnLockLevel = XSuitUtil:GetUnLockLevelByFeature(AvatarItem.TypeSpecificID, Period, uPlayerController.CommerFeature.XSuitUnlockLevelList)
    local bValid = XSuitUtil:IsValidXSuitEffect(AvatarItem.TypeSpecificID, LowLevelEffect.BornIslandAction, UnLockLevel)
    if not bValid then
      print(bWriteLog and "QuickExpression:OnButtonXSuitEmote not bValid")
      return
    end
  end
  if self.PlayEmoteInternal then
    self:PlayEmoteInternal(BornIslandAction)
  else
    LuaObject:PlayEmoteInternal(BornIslandAction)
  end
  if self.ShowOrHideRing then
    self:ShowOrHideRing(false)
  end
end
function QuickExpression:ChangeAvatarForm()
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    return
  end
  local CurState = QuickExpression.GetAvatarFormState(OwningActor)
  if CurState == 0 then
    return
  end
  local ChangeAvatarFormSkillID = 1014419
  local SkillMgr = OwningActor:GetSkillManager()
  if Game:IsValid(SkillMgr) and SkillMgr:IsCastingSkillID(ChangeAvatarFormSkillID) then
    return
  end
  print(bWriteLog and "QuickExpression:ChangeAvatarForm", ChangeAvatarFormSkillID)
  OwningActor:TriggerEntrySkillWithID(ChangeAvatarFormSkillID, true)
end
function QuickExpression:OnDestroy()
  self:Dispose()
end
function QuickExpression:RefreshCollectionList()
  if self.bCollectionInited then
    return
  end
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController.PlayEmoteFeature then
    return
  end
  local CollectionEmoteMap = PlayerController.PlayEmoteFeature.CollectionEmoteMap
  if not CollectionEmoteMap then
    return
  end
  for EmoteID, _ in pairs(CollectionEmoteMap) do
    table.insert(self.CollectionList, EmoteID)
    IgnoreEmoteConfig[EmoteID] = true
    self.bCollectionInited = true
  end
  table.sort(self.CollectionList, function(a, b)
    return a < b
  end)
end
function QuickExpression:RefreshPetInfo()
  local PetID, PetLevel = self:GetCurPet()
  local bShowMyPet = self:GetShowMyPet()
  local IsInPetSpectator = false
  local PC = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PC) and PC.IsInPetSpectator and PC:IsInPetSpectator() then
    IsInPetSpectator = true
  end
  local bNeedUpdate = false
  if self.IsInPetSpectator ~= IsInPetSpectator then
    self.    bNeedUpdate = true
  end
  print(bWriteLog and "QuickExpression:RefreshPetInfo", self.PetID, PetID, self.PetLevel, PetLevel, bShowMyPet, bNeedUpdate)
  if self.PetID == PetID and self.PetLevel == PetLevel and self.bShowMyPet == bShowMyPet and not bNeedUpdate then
    return
  end
  self.  self.  self.CurPetExpressionList = {}
  self.  print(bWriteLog and "QuickExpression:RefreshPetInfo1", self.PetID, self.PetLevel, self.bShowMyPet)
  if (not self.PetID or self.PetID <= 0 or not self.bShowMyPet) and not bNeedUpdate then
    return
  end
  print(bWriteLog and "QuickExpression:RefreshPetInfo IsSpectator")
  local StringUtil = require("common.string_util")
  for _, v in pairs(CDataTable.GetTable("PetActionTable")) do
    if self.PetID == v.PetID then
      print(bWriteLog and "QuickExpression:RefreshPetInfo CanPlayInBattle", v.CanPlayInBattle, IsInPetSpectator)
      if not (v.CanPlayInBattle ~= 1 and (v.CanPlayInBattle ~= 2 or IsInPetSpectator)) or v.CanPlayInBattle == 3 and IsInPetSpectator then
        local bMatchDress = true
        if v.DependingClothesID and v.DependingClothesID ~= "" then
          local DependingClothesIDList = StringUtil.Split(v.DependingClothesID, "|")
          if DependingClothesIDList and next(DependingClothesIDList) then
            bMatchDress = self:IsAvatarRequirementMatch(DependingClothesIDList)
          end
        end
        if bMatchDress then
          table.insert(self.CurPetExpressionList, {
            ID = v.PetActionID,
            IsLocked = true,
            SortKey = v.SortKey,
            MasterSkillID = v.MasterSkillID
          })
        end
      end
    end
  end
  if #self.CurPetExpressionList <= 0 then
    return
  end
  table.sort(self.CurPetExpressionList, function(a, b)
    return a.SortKey < b.SortKey
  end)
  local ConfigID = 10000 * PetID + PetLevel
  local PetLevelConfig = CDataTable.GetTableData("PetLevelTable", ConfigID)
  local AllAction = StringUtil.Split(PetLevelConfig.AllAction, "|")
  local EmoteIsUnLocked = function(EmoteID)
    if AllAction and 0 < #AllAction then
      for _, ID in pairs(AllAction) do
        if EmoteID == tonumber(ID) then
          return true
        end
      end
    end
  end
  for _, v in pairs(self.CurPetExpressionList) do
    v.IsLocked = not EmoteIsUnLocked(v.ID)
  end
end
function QuickExpression:GetCurPet()
  local PC = slua_GameFrontendHUD:GetPlayerController()
  if not PC or not slua.isValid(PC) then
    return
  end
  if PC.IsInPetSpectator and PC:IsInPetSpectator() then
    local PlayerPetSpectatorComponent = PC:GetPetSpectatorComp()
    if slua.isValid(PlayerPetSpectatorComponent) then
      local PetInfo = PlayerPetSpectatorComponent:GetPetInfo(PlayerPetSpectatorComponent:GetCurrentSpectatorPetID())
      if PetInfo then
        return PetInfo.PetID, PetInfo.PetLevel
      end
    end
  end
  local uPlayerPawn = PC:GetPlayerCharacterSafety()
  if slua.isValid(uPlayerPawn) and slua.isValid(uPlayerPawn.PetComponent_BP) and slua.isValid(uPlayerPawn.PetComponent_BP.PetPawn) then
    local RealPetPawn = uPlayerPawn.PetComponent_BP.PetPawn
    local PetID = RealPetPawn.PetLevelInfo.PetId
    local PetLevel = RealPetPawn.PetLevelInfo.PetLevel
    return PetID, PetLevel
  end
end
function QuickExpression:GetShowMyPet()
  local PC = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PC) and PC.IsInPetSpectator and PC:IsInPetSpectator() then
    local PlayerPetSpectatorComponent = PC:GetPetSpectatorComp()
    if slua.isValid(PlayerPetSpectatorComponent) and PlayerPetSpectatorComponent:GetPetInfo(PlayerPetSpectatorComponent:GetCurrentSpectatorPetID()) then
      return true
    end
  end
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return false
  end
  if slua.isValid(PC) then
    local uPlayerPawn = PC:GetPlayerCharacterSafety()
    if uPlayerPawn then
      if uPlayerPawn.IsFPP then
        return SettingSubsystem:GetUserSettings_Bool("OpenMyPetFPP")
      else
        return SettingSubsystem:GetUserSettings_Bool("OpenMyPet")
      end
    end
  end
  return false
end
function QuickExpression:IsSocialIsland()
  local UGameplayStatics = import("GameplayStatics")
  local uGameState = UGameplayStatics.GetGameState(self)
  if slua.isValid(uGameState) and uGameState.IsNonePlayerOnIsland then
    return true
  end
  return false
end
function QuickExpression:IsMainCity()
  return GameStatus.IsInMainCity()
end
function QuickExpression:IsAvatarRequirementMatch(RequireAvatarList)
  if not RequireAvatarList or not next(RequireAvatarList) then
    return true
  end
  local CurrentPetInfo
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    CurrentPetInfo = uPlayerController:GetCurrentPetInfo()
  end
  if CurrentPetInfo and CurrentPetInfo.PetAvatarList then
    for _, v in pairs(CurrentPetInfo.PetAvatarList) do
      local DressAvatarIDStr = tostring(v)
      for __, RequireAvatarItemID in pairs(RequireAvatarList) do
        if DressAvatarIDStr == RequireAvatarItemID then
          return true
        end
      end
    end
  end
  return false
end
function QuickExpression:RefreshSwitchButtonState()
  if self.CurrentShowState == EShowState.Bubble then
    self.CanvasPanel_SubTypeSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() and (self.CurrentShowState == EShowState.Collection or self.CurrentShowState == EShowState.Flaunt) then
    self.CanvasPanel_SubTypeSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self.CanvasPanel_SubTypeSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if self.CurrentShowState == EShowState.Expression then
    if self:NeedHidePetExpression() then
      self.CanvasPanel_SubTypeSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      self.WidgetSwitcher_1:SetActiveWidgetIndex(0)
    end
  elseif self.CurrentShowState == EShowState.PetExpression then
    self.WidgetSwitcher_1:SetActiveWidgetIndex(1)
  elseif self.CurrentShowState == EShowState.Collection then
    self.WidgetSwitcher_1:SetActiveWidgetIndex(2)
  elseif self.CurrentShowState == EShowState.Flaunt then
    self.WidgetSwitcher_1:SetActiveWidgetIndex(3)
  end
end
function QuickExpression:OnButtonSubTypeSwitchClick()
  print(bWriteLog and "QuickExpression:OnButtonSubTypeSwitchClick", self.CurrentShowState)
  if self.CurrentShowState == EShowState.Expression then
    self.CurrentShowState = EShowState.PetExpression
    self.WidgetSwitcher_EmoteOrPet:SetActiveWidgetIndex(1)
  elseif self.CurrentShowState == EShowState.PetExpression then
    self.CurrentShowState = EShowState.Expression
    self.WidgetSwitcher_EmoteOrPet:SetActiveWidgetIndex(0)
  elseif self.CurrentShowState == EShowState.Collection then
    self.CurrentShowState = EShowState.Flaunt
    self.WidgetSwitcher_CollectionOrFlaunt:SetActiveWidgetIndex(1)
  elseif self.CurrentShowState == EShowState.Flaunt then
    self.CurrentShowState = EShowState.Collection
    self.WidgetSwitcher_CollectionOrFlaunt:SetActiveWidgetIndex(0)
  end
  self:RefreshCirclePanel()
end
function QuickExpression:RefreshFlauntList()
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  local ItemList = logic_emote.GetFlauntEmote()
  if self:NeedHidePetExpression() then
    local ItemListExcludePet = {}
    for _, itemID in pairs(ItemList) do
      if not logic_emote.CheckIsPetExhibitionEmote(itemID) then
        ItemListExcludePet[#ItemListExcludePet + 1] = itemID
      end
    end
    self.FlauntList = ItemListExcludePet
  else
    self.FlauntList = ItemList
  end
end
function QuickExpression:RefreshFlaunt()
  print(bWriteLog and "QuickExpression:RefreshFlaunt", self.CurrentShowState)
  if self.CurrentShowState ~= EShowState.Flaunt then
    return
  end
  self:RefreshFlauntList()
  log_tree(bWriteLog and "RefreshFlaunt:", self.FlauntList)
  for _, EmoteName in pairs(self.EmoteNameArray) do
    if EmoteName then
      EmoteName:SetText("")
    end
  end
  for _, SlotSwitcher in pairs(self.SlotSwitcherArray) do
    if SlotSwitcher then
      SlotSwitcher:SetActiveWidgetIndex(1)
    end
  end
  local EmoteCount = self.EmoteImageArray:Num()
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  for Index, ID in pairs(self.FlauntList) do
    if Index <= EmoteCount then
      local EmoteImage = self.EmoteImageArray:Get(Index - 1)
      local SlotSwitcher = self.SlotSwitcherArray:Get(Index - 1)
      local EmoteName = self.EmoteNameArray:Get(Index - 1)
      local UIUtil = require("client.common.ui_util")
      local sIconPath = UIUtil.GetItemSmallIcon(ID)
      if EmoteImage and SlotSwitcher and EmoteName and sIconPath then
        SlotSwitcher:SetActiveWidgetIndex(0)
        local uiUtil = require("client.slua_ui_framework.util")
        uiUtil.SetTexture(EmoteImage, sIconPath, {sync = false})
        EmoteImage:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
      end
    end
    if logic_emote.CheckIsPetExhibitionEmote(ID) then
      self.PetExhibit    end
  end
end
function QuickExpression:TryToPlayFlaunt(Index)
  local EmoteID = -1
  if Index and 0 <= Index then
    EmoteID = self.FlauntList[Index + 1]
  end
  print(bWriteLog and "QuickExpression:TryToPlayFlaunt", Index, EmoteID)
  if EmoteID and 0 < EmoteID then
    local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
    if logic_emote.CheckIsPetExhibitionEmote(EmoteID) then
      if logic_emote.CheckCanUsePetExhibitionEmote() then
        if 0 >= logic_emote.GetPetExhibitRemainCD() then
          self:TryPlayPetExhibitAction()
        end
      else
        ShowNotice(530022)
      end
    else
      self:PlayEmoteInternal(EmoteID)
    end
    self:ShowOrHideRing(false)
  end
end
function QuickExpression:TryPlayPetExhibitAction()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if PlayerCharacter and slua.isValid(PlayerCharacter) then
    if PlayerCharacter:AllowState(UEnums.EPawnState.PlayEmote, true) then
      PlayerCharacter:TriggerEntrySkillWithID(1014668, true)
    else
      ShowNotice(82212)
    end
  else
    print(bWriteLog and "QuickExpression:PlayPetExhibitAction PlayerCharacter is invalid.")
  end
end
function QuickExpression:RefreshCDInternal()
  if self.PetExhibitIndex > 0 then
    local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
    local RemainCD = 0
    if self.CurrentShowState == EShowState.Flaunt then
      RemainCD = logic_emote.GetPetExhibitRemainCD()
    end
    if self.CDPanelArray then
      local CDPanel = self.CDPanelArray:Get(self.PetExhibitIndex - 1)
      if slua.isValid(CDPanel) then
        CDPanel:SetWidgetVisibility(0 < RemainCD and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed)
      end
    end
    if self.CDTextArray then
      local CDText = self.CDTextArray:Get(self.PetExhibitIndex - 1)
      if slua.isValid(CDText) then
        CDText:SetText(tostring(math.floor(RemainCD)))
      end
    end
  end
end
function QuickExpression:NeedHidePetExpression()
  local PC = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PC) and PC.NeedHidePetExpression and PC:NeedHidePetExpression() then
    return true
  end
  return false
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, QuickExpression)