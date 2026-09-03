local BackpackUtils = import("BackpackUtils")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local AkGameplayStatics = import("AkGameplayStatics")
local STExtraUIUtils = import("STExtraUIUtils")
local KismetMathLibrary = import("KismetMathLibrary")
local CustomType = require("client.logic.setting.CustomType")
local UIDataProcessingFunctionLibrary = import("UIDataProcessingFunctionLibrary")
local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
local EPetState = import("EPetState")
local FPetMontageData = import("PetMontageData")
local ESpectatorPetStateMsgType = import("ESpectatorPetStateMsgType")
local GameplayStatics = import("GameplayStatics")
local EGameModeType = import("EGameModeType")
local EPaintDecalTargetValidationType = import("EPaintDecalTargetValidationType")
local UKismetMathLibrary = import("KismetMathLibrary")
local util = require("client.slua_ui_framework.util")
local UIUtil = require("client.common.ui_util")
local StringUtil = require("common.string_util")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GameplaySysMgr = require("GameLua.Mod.BaseMod.GamePlay.Core.GameplaySysMgr")
local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
local QuickExpression = require("GameLua.Mod.BaseMod.Client.Emote.QuickExpression")
local ItemConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.ItemConfig")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local QuickExpressionDecalSubPanel = {}
local ShowState = {
  None = 0,
  Decal = 1,
  Expression = 2,
  Bubble = 3,
  IslandExpression = 4,
  Holography = 5,
  PetExpression = 6,
  Collection = 7,
  Flaunt = 8,
  PetBubble = 9,
  SpectatorPetBubble = 10,
  MiniTvExpression = 11
}
local NO_EXPRESSION = 36707
local NO_DECAL = 36708
local NO_BUBBLE = 36709
local NO_HOLOGRAPHY = 39153
local NO_PET = 48672
local PET_INVISIBLE = 48670
local NO_COLLECTION = 66692
local HOLOGRAPHY_SKILL_ID = 1014064
local NO_MINITV_EXPRESSION = 87377
local NO_MINITV = 87378
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
local PHomePaintDecalWhiteList = {}
function QuickExpressionDecalSubPanel:ctor()
  print(bWriteLog and "QuickExpressionDecalSubPanel:ctor")
  self.CurrentShowState = ShowState.None
  self.ItemDefineIDTemp = FItemDefineIDDefault()
  self.AllLimitEmoteList = {}
  self.ClothBackpackItem = {}
  self.GreyColor = FLinearColor(0.49, 0.49, 0.49, 1.0)
  self.ColorA = KismetMathLibrary.HSVToRGB(0.0, 0.0, 0.2, 1.0)
  self.ColorB = KismetMathLibrary.HSVToRGB(0.0, 0.0, 1.0, 1.0)
  self.EmoteDecalArray = slua.Array(UEnums.EPropertyClass.Int)
  self.EmoteDecalArray:Add(UEnums.EBackpackItemType.Emote)
  self.EmoteDecalArray:Add(UEnums.EBackpackItemType.Decal)
  self.PetID = -1
  self.PetLevel = -1
  self.CurPetExpressionList = {}
  self.CollectionList = {}
  self.bShowMyPet = false
  self.QuickExpressionDecalItemList = {}
  self.WeaponShowEmoteID = 0
  self.bShowBottom = true
  self.bShowDecal = true
  self.bInitMiniTvExpressionList = false
  self.MiniTvExpressionList = {}
  self.bShowMiniTv = false
end
function QuickExpressionDecalSubPanel:OnClose()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnClose")
  if self.OnEnterBattleEventHandle then
    EventSystem:UnregistEventByID(self.OnEnterBattleEventHandle)
    self.OnEnterBattleEventHandle = nil
  end
  for Index, Value in ipairs(self.QuickExpressionDecalItemList) do
    Value:Close()
  end
  self.QuickExpressionDecalItemList = nil
  QuickExpressionDecalSubPanel.__super.OnClose(self)
end
function QuickExpressionDecalSubPanel:OnInitialize()
  local QuickExpressionDecalUI = UIManager.GetUI(UIManager.UI_Config_InGame.QuickExpressionDecalUI)
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnInitialize, " .. tostring(QuickExpressionDecalUI))
  if QuickExpressionDecalUI then
    self:AttachToPanel(QuickExpressionDecalUI.UIRoot.CanvasPanel_2)
  end
  self.LastCloseShowState = ShowState.None
  if self:IsSocialIsland() then
    self.LastEmoteState = ShowState.IslandExpression
  else
    self.LastEmoteState = ShowState.Expression
  end
  self.LastMoreState = ShowState.Decal
  self.UIRoot.CanvasPanel_ShowState:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if not self:IsSocialIsland() then
    self.UIRoot.WidgetSwitcher_Bubble:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if not self:HasEquipHolography() then
    self.UIRoot.WidgetSwitcher_Hologram:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif self:IsSocialIsland() then
    self.UIRoot.WidgetSwitcher_Hologram:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif self:IsMainCity() then
    self.UIRoot.WidgetSwitcher_Hologram:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif self:IsTypicalGameMode() then
    self.UIRoot.WidgetSwitcher_Hologram:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.OnEnterBattleEventHandle = EventSystem:registEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, self.OnEnterBattle, self)
  else
    self.UIRoot.WidgetSwitcher_Hologram:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local bCanShowPetBubble = self:CanShowPetBubblePanel()
  if bCanShowPetBubble then
    self.UIRoot.CanvasPanel_PetBubble:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.CanvasPanel_PetBubble:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function QuickExpressionDecalSubPanel:RegistEvents()
  print(bWriteLog and "QuickExpressionDecalSubPanel:RegistEvents")
  self:AddControlEventByControl(self.UIRoot.Button_2, "OnClicked", self.OnButtonHolography, self)
  self:AddControlEventByControl(self.UIRoot.Button_0, "OnClicked", self.OnButtonExpression, self)
  self:AddControlEventByControl(self.UIRoot.Button_20, "OnClicked", self.OnButtonCollection, self)
  self:AddControlEventByControl(self.UIRoot.Button_24, "OnClicked", self.OnButtonMore, self)
  self:AddControlEventByControl(self.UIRoot.Button_28, "OnClicked", self.OnButtonPlayerExpression, self)
  self:AddControlEventByControl(self.UIRoot.Button_6, "OnClicked", self.OnButtonBubble, self)
  self:AddControlEventByControl(self.UIRoot.Button_8, "OnClicked", self.OnButtonDecal, self)
  self:AddControlEventByControl(self.UIRoot.Button_4, "OnClicked", self.OnButtonPetExpression, self)
  self:AddControlEventByControl(self.UIRoot.Button_PhotoEdit, "OnClicked", self.OnButton_PhotoEditClick, self)
  self:AddControlEventByControl(self.UIRoot.Button_ShowPet, "OnClicked", self.OnButtonShowPet, self)
  self:AddControlEventByControl(self.UIRoot.Button_10, "OnClicked", self.OnButtonPetBubble, self)
  self:AddControlEventByControl(self.UIRoot.Button_12, "OnClicked", self.OnButtonSpectatorPetBubble, self)
  self:AddControlEventByControl(self.UIRoot.Button_14, "OnClicked", self.OnButtonMiniTvExpression, self)
  self:AddControlEventByControl(self.UIRoot.Button_ShowRobot, "OnClicked", self.OnButtonShowMiniTv, self)
  self:AddControlEventByControl(self.UIRoot.Button_Flaunt_UnSelect, "OnClicked", self.OnButtonFlaunt_UnSelect, self)
  self:AddControlEventByControl(self.UIRoot.Button_Collection_UnSelect, "OnClicked", self.OnButtonCollection_UnSelect, self)
  self.UpdateItemArr = slua.Array(UEnums.EPropertyClass.Int)
  if ItemConfig.ItemID2Emote and self.UpdateItemArr then
    for ItemID, _ in pairs(ItemConfig.ItemID2Emote) do
      print(bWriteLog and "QuickExpressionDecalSubPanel UpdateItemArr ItemID", ItemID)
      self.UpdateItemArr:Add(ItemID)
    end
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_ITEM_LIST, function(_, _, uBackpackComponent)
    if not slua.isValid(uBackpackComponent) then
      return
    end
    if uBackpackComponent:IsItemListUpdatedHasSomeItemTypes(self.EmoteDecalArray) then
      self:RefreshGridPanel()
    end
    if uBackpackComponent:IsItemListUpdatedHasSomeItems(self.UpdateItemArr) then
      self:RefreshItemEmoteInfo(uBackpackComponent)
    end
  end)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) and PlayerCharacter.GetWeaponManager then
    local WeaponManager = PlayerCharacter:GetWeaponManager()
    if slua.isValid(WeaponManager) then
      self:AddControlEventByControl(WeaponManager, "ChangeCurrentUsingWeaponDelegate", self.HandleChangeCurrentUsingWeapon, self)
    end
  end
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem then
    SettingSubsystem:RegisterUserSettingsDelegate_Bool("OpenMyPet", function()
      self:RefreshPetExpression()
    end)
    SettingSubsystem:RegisterUserSettingsDelegate_Bool("OpenMyPetFPP", function()
      self:RefreshPetExpression()
    end)
    SettingSubsystem:RegisterUserSettingsDelegate_Bool("ShowMiniTvInFighting", function()
      self:RefreshMiniTvExpression()
    end)
  end
  self:AddControlEventByControl(self.UIRoot.Button_CheckGun, "OnClicked", self.OnButtonCheckGun, self)
  self:AddControlEventByControl(self.UIRoot.Button_ChangeAvatarForm, "OnClicked", self.OnButtonChangeAvatarForm, self)
  self:AddControlEventByControl(self.UIRoot.Button_Transfiguration, "OnClicked", self.OnButtonTransfiguration, self)
  self:AddControlEventByControl(self.UIRoot.Button_PetFeature, "OnClicked", self.OnButtonPetFeature, self)
  self:AddControlEventByControl(self.UIRoot.Button_XSuit, "OnClicked", self.OnButtonXSuitEmote, self)
  self:AddControlEventByControl(self.UIRoot.Button_Robot, "OnClicked", self.OnButtonMiniTvBubbleExpression, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_PRE_ENTER_SELFIE_MODE, self.OnPreEnterSelfie, self)
  self:AddControlEventByControl(self.UIRoot.CheckBox_ShowEffects, "OnCheckStateChanged", self.OnCheckShowEffects, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_AVATAR, EVENTID_LOCAL_PLAYEREVENT_AVATAR_ALL_MESH_LOADED, self.OnAvatarAllMeshLoaded, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_WEAPON_SHOW_CHANGE, self.OnCustomWeaponShowChange, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_AVATAR, EVENTID_PLAYEREVENT_AVATAR_MESH_EQUIPPED, self.OnClothChange, self)
end
function QuickExpressionDecalSubPanel:OnCustomWeaponShowChange()
  self:RefreshCheckGunBtnState()
end
function QuickExpressionDecalSubPanel:OnPostInitialize()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnPostInitialize")
  local EWidgetVisible = import("EWidgetVisible")
  self.UIRoot:SetWidgetRender(EWidgetVisible.ForceVisible)
  self:RefreshAndSaveRed()
end
function QuickExpressionDecalSubPanel:OnShow()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnShow")
  local UIUtil = require("client.common.ui_util")
  UIUtil.SetAdaptiveLayout(self.UIRoot, UEnums.EAdaptiveLayout.Outside)
  self:SetAutoSize(true)
  local GameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(GameState) and GameState.GetGameModeState then
    local CurGameState = GameState:GetGameModeState()
    print(bWriteLog and "QuickExpressionDecalSubPanel:OnShow CurGameState", CurGameState)
    if CurGameState == "FightingState" then
      self.HasEnterBattle = true
    end
  end
  self:RefreshMiniTvShowSwitch()
  self:OpenContent()
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if IngameSelfieSubsystem and IngameSelfieSubsystem.CheckPhotoEditButtonState then
    log(bWriteLog and "QuickExpressionDecalSubPanel:OnShow CheckPhotoEditButtonState")
    IngameSelfieSubsystem:CheckPhotoEditButtonState(self.UIRoot.Button_PhotoEdit, self.UIRoot.Image_PhotoEditReddot)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_NEW_EXPANDPANEL_MUTEX, self)
end
function QuickExpressionDecalSubPanel:OnHide()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnHide")
  self:CloseContent()
end
function QuickExpressionDecalSubPanel:OpenContent()
  if self.LastCloseShowState ~= ShowState.None then
    self.CurrentShowState = self.LastCloseShowState
  elseif self:IsSocialIsland() then
    self.CurrentShowState = ShowState.IslandExpression
  else
    self.CurrentShowState = ShowState.Expression
  end
  print(bWriteLog and "QuickExpressionDecalSubPanel:OpenContent, " .. self.CurrentShowState)
  self:RefreshGridPanel()
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_QUICK_EXPRESSION_DECAL_CLICK)
  EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_ADD_VALUE_TLOG, "IndividualClickNum", 1)
  self.UIRoot:InvalidateLayoutAndVolatility()
  self.UIRoot:ForceLayoutPrepass()
  self:ShowChangeFormGuide2()
end
function QuickExpressionDecalSubPanel:CloseContent()
  print(bWriteLog and "QuickExpressionDecalSubPanel:CloseContent, " .. self.CurrentShowState)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    PlayerCharacter:DoDetectPaintDecalTarget(false, 0)
  end
  if self.CurrentShowState ~= ShowState.None then
    self.LastCloseShowState = self.CurrentShowState
    self.CurrentShowState = ShowState.None
  end
  self:RefreshChangeAvatarFormBtnState(false)
  self:RefreshTransformButton()
  local QuickExpressionDecalUI = UIManager.GetUI(UIManager.UI_Config_InGame.QuickExpressionDecalUI)
  if QuickExpressionDecalUI then
    QuickExpressionDecalUI:CloseCommonPart()
  end
end
function QuickExpressionDecalSubPanel:OnAvatarAllMeshLoaded()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnAvatarAllMeshLoaded")
  self:RefreshTransformButton()
  self:ShowChangeFormGuide2()
  self:RefreshXSuitEmoteButton()
end
function QuickExpressionDecalSubPanel:OnCheckShowEffects(bShow)
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnCheckShowEffects" .. tostring(bShow))
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    if self.CurrentShowState == ShowState.Expression then
      if PlayerController.PlayEmoteFeature then
        PlayerController.PlayEmoteFeature:SetShowEmoteEffect(bShow)
      end
      self:RefreshExpression()
    elseif self.CurrentShowState == ShowState.IslandExpression then
      if PlayerController.PlayEmoteFeature then
        PlayerController.PlayEmoteFeature:SetShowEmoteEffect(bShow)
      end
      self:RefreshIslandExpression()
    end
  end
end
function QuickExpressionDecalSubPanel:OnPreEnterSelfie()
  log(bWriteLog and "[DeanJYT] QuickExpressionDecalSubPanel:OnPreEnterSelfie")
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if IngameSelfieSubsystem and IngameSelfieSubsystem.CheckPhotoEditButtonState then
    IngameSelfieSubsystem:CheckPhotoEditButtonState(self.UIRoot.Button_PhotoEdit, self.UIRoot.Image_PhotoEditReddot)
  end
end
function QuickExpressionDecalSubPanel:GetShowMyPet()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.IsInPetSpectator and PlayerController:IsInPetSpectator() and PlayerController.InitialPetInfo then
    return true
  end
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return false
  end
  if slua.isValid(PlayerController) then
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) then
      if PlayerCharacter.IsFPP then
        return SettingSubsystem:GetUserSettings_Bool("OpenMyPetFPP")
      else
        return SettingSubsystem:GetUserSettings_Bool("OpenMyPet")
      end
    end
  end
  return false
end
function QuickExpressionDecalSubPanel:OnButtonHolography()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonHolography" .. self.CurrentShowState)
  if self.CurrentShowState ~= ShowState.Holography then
    self.CurrentShowState = ShowState.Holography
    self:RefreshGridPanel()
  end
end
function QuickExpressionDecalSubPanel:OnButtonExpression()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonExpression" .. self.CurrentShowState)
  if self.CurrentShowState ~= self.LastEmoteState then
    self.CurrentShowState = self.LastEmoteState
    self:RefreshGridPanel()
  end
end
function QuickExpressionDecalSubPanel:OnButtonPlayerExpression()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonPlayerExpression" .. self.CurrentShowState)
  if self:IsSocialIsland() then
    if self.CurrentShowState ~= ShowState.IslandExpression then
      self.CurrentShowState = ShowState.IslandExpression
      self:RefreshGridPanel()
    end
  elseif self.CurrentShowState ~= ShowState.Expression then
    self.CurrentShowState = ShowState.Expression
    self:RefreshGridPanel()
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.IsInPetSpectator and PlayerController:IsInPetSpectator() then
    ShowNotice(30121)
  end
end
function QuickExpressionDecalSubPanel:OnButtonMore()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonMore" .. self.CurrentShowState, self.LastMoreState)
  if self.CurrentShowState ~= self.LastMoreState then
    self.CurrentShowState = self.LastMoreState
    self:RefreshGridPanel()
  end
  self:RefreshAndSaveRed(true)
end
function QuickExpressionDecalSubPanel:RefreshAndSaveRed(hide)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if hide then
    self:SetWidgetVisible(self.UIRoot.Image_MoreRedPoint, false)
    log(bWriteLog and "  QuickExpressionDecalUI:RefreshAndSaveRed.  hide")
    PlayerPrefsSystem.SaveTableToFile_N(1, PlayerPrefsSystem.ePlayerPrefsType.ePetActionInBattleRed)
    return
  end
  local show = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePetActionInBattleRed)
  log(bWriteLog and "  QuickExpressionDecalSubPanel:RefreshAndSaveRed. loaded show: " .. tostring(show))
  if not show or show == 0 then
    local PlayerController = GameplayData.GetPlayerController()
    show = PlayerController.CommerFeature.bHasPetBubblePrivilege or false
  else
    show = false
  end
  log(bWriteLog and "  QuickExpressionDecalSubPanel:RefreshAndSaveRed. show: " .. tostring(show))
  self:SetWidgetVisible(self.UIRoot.Image_MoreRedPoint, show)
end
function QuickExpressionDecalSubPanel:OnButtonBubble()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonBubble" .. self.CurrentShowState)
  if self.CurrentShowState ~= ShowState.Bubble then
    self.CurrentShowState = ShowState.Bubble
    self:RefreshGridPanel()
  end
end
function QuickExpressionDecalSubPanel:OnButtonDecal()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonDecal" .. self.CurrentShowState)
  if self.CurrentShowState ~= ShowState.Decal then
    self.CurrentShowState = ShowState.Decal
    self:RefreshGridPanel()
  end
end
function QuickExpressionDecalSubPanel:OnButtonPetExpression()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonPetExpression" .. self.CurrentShowState)
  if self.CurrentShowState ~= ShowState.PetExpression then
    print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonPetExpression PetID:" .. tostring(self.PetID) .. ", bShowMyPet:" .. tostring(self.bShowMyPet))
    self.CurrentShowState = ShowState.PetExpression
    self:RefreshGridPanel()
  end
end
function QuickExpressionDecalSubPanel:OnButtonShowPet()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonShowPet")
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return false
  end
  SettingSubsystem:SetUserSettings_Bool("OpenMyPetFPP", true)
  SettingSubsystem:SetUserSettings_Bool("OpenMyPet", true)
end
function QuickExpressionDecalSubPanel:OnButton_PhotoEditClick()
  print(bWriteLog and "[DeanJYT] QuickExpressionDecalSubPanel:OnButton_PhotoEditClick")
  local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
  if not IngameSelfieSubsystem then
    print(bWriteLog and "[DeanJYT] QuickExpressionDecalSubPanel:OnButton_PhotoEditClick cannot get IngameSelfieSubsystem")
    return
  end
  IngameSelfieSubsystem:OnButton_PhotoEditClick(self.UIRoot.Image_PhotoEditReddot)
  self:CloseContent()
end
function QuickExpressionDecalSubPanel:OnButtonCollection()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonCollection" .. self.CurrentShowState)
  if self.CurrentShowState ~= ShowState.Flaunt then
    self.CurrentShowState = ShowState.Flaunt
    self:RefreshGridPanel()
  end
end
function QuickExpressionDecalSubPanel:OnButtonFlaunt_UnSelect()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonFlaunt_UnSelect" .. self.CurrentShowState)
  if self.CurrentShowState ~= ShowState.Flaunt then
    self.CurrentShowState = ShowState.Flaunt
    self:RefreshGridPanel()
  end
end
function QuickExpressionDecalSubPanel:OnButtonCollection_UnSelect()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonCollection_UnSelect" .. self.CurrentShowState)
  if self.CurrentShowState ~= ShowState.Collection then
    self.CurrentShowState = ShowState.Collection
    self:RefreshGridPanel()
  end
end
function QuickExpressionDecalSubPanel:SetShowState(showState)
  print(bWriteLog and "QuickExpressionDecalSubPanel:SetShowState set = " .. showState .. " current = " .. self.CurrentShowState)
  if self.CurrentShowState ~= showState then
    self.CurrentShowState = showState
    self:RefreshGridPanel()
  end
end
function QuickExpressionDecalSubPanel:OnClickItem(ID)
  if not ID or ID <= 0 then
    return
  end
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.InteractiveCommon) then
    printf("QuickExpressionDecalSubPanel:OnClickItem in CD")
    return false
  end
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem, CurrentShowState:" .. self.CurrentShowState .. ", ID:" .. ID)
  if self.CurrentShowState == ShowState.Decal then
    if not self:GetIsItemHandleExist(23, ID) then
      print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem Decal not exist!! " .. ID)
      IngameTipsTools.BattleNormalTipsByTextID(43005)
      return
    end
    if self:RequirPaint(ID) then
      print(bWriteLog and "QuickExpressionDecalUI\230\136\144\229\138\159\229\150\183\230\188\134tlog")
      EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_ADD_VALUE_TLOG, "DecalClickNum", 1)
    end
  elseif self.CurrentShowState == ShowState.Holography then
    self:TryToThrowHolography(ID)
  elseif self.CurrentShowState == ShowState.Expression then
    self:TryToPlayEmote(ID)
  elseif self.CurrentShowState == ShowState.Bubble then
    if ID ~= nil then
      local uIslandBubbleEmoteSys = GameplaySysMgr.GetSysByName("IslandBubbleEmoteSys")
      if uIslandBubbleEmoteSys ~= nil then
        uIslandBubbleEmoteSys:ReqDoBubbleEmote(ID)
        EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_ADD_VALUE_TLOG, "BubbleClickNum", 1)
      end
    end
  elseif self.CurrentShowState == ShowState.IslandExpression then
    if ID == self.WeaponShowEmoteID then
      self:TryPlayWeaponShowEmote()
    else
      local uEmoteActionSys = GameplaySysMgr.GetSysByName("EmoteActionSys")
      if uEmoteActionSys ~= nil and uEmoteActionSys:TryPlayEmote(ID) then
        EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_ADD_VALUE_TLOG, "ExpressionClickNum", 1)
      end
    end
  elseif self.CurrentShowState == ShowState.PetExpression then
    local uMontageData = FPetMontageData()
    uMontageData.AnimationAssetId = ID
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) and ID then
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
        print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem PetExpression IsLocked!! " .. ID)
        IngameTipsTools.BattleNormalTipsByTextID(48775)
        return
      end
      if not self:GetIsEmoteExist(ID) then
        print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem PetExpression not exist!! " .. ID)
        IngameTipsTools.BattleNormalTipsByTextID(43005)
        return
      end
      if PlayerController.IsInPetSpectator and PlayerController:IsInPetSpectator() and PlayerController:GetPetSpectatorComp() and PlayerController:GetPetSpectatorComp().PetSpectatorPawn then
        print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem IsInPetSpectator " .. ID)
        PlayerController:GetPetSpectatorComp().PetSpectatorPawn:LocalHandleSpectatorPetStateMsg(ESpectatorPetStateMsgType.SpectatorPetMsgPlayEmoteMotage, ID)
      else
        local uCurPawn = PlayerController:GetCurPawn()
        if slua.isValid(uCurPawn) and slua.isValid(uCurPawn.PetComponent_BP) and slua.isValid(uCurPawn.PetComponent_BP.PetPawn) and (uCurPawn.PetComponent_BP.PetPawn:PetHasState(EPetState.PetParachute) or uCurPawn.PetComponent_BP.PetPawn:PetHasState(EPetState.PetSwimming) or uCurPawn.PetComponent_BP.PetPawn:PetHasState(EPetState.PetSleeping) or uCurPawn.PetComponent_BP.PetPawn:PetHasState(EPetState.PetPlayingFeature)) then
          print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem pet state is forbidden!")
          IngameTipsTools.BattleNormalTipsByTextID(49084)
          return
        end
        if nMasterSkillID ~= nil and 0 < nMasterSkillID then
          print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem Master trigger skill", nMasterSkillID)
          if slua.isValid(uCurPawn) then
            local SkillManager = uCurPawn:GetSkillManager()
            if slua.isValid(SkillManager) then
              local uSkill = SkillManager:GetSkill(nMasterSkillID)
              if uSkill and not uSkill:IsCDOK(SkillManager, -1) then
                local nCD = uSkill:GetCoolDownTime(SkillManager, 0)
                local bUseNewSkillCD = uSkill.bUseNewSkillCD
                print(bWriteLog and string.format("QuickExpressionDecalSubPanel:OnClickItem failed to trigger skill:%d : InCD, nCD:%s. bUseNewSkillCD:%s", nMasterSkillID, tostring(nCD), tostring(bUseNewSkillCD)))
                IngameTipsTools.BattleNormalTipsByTextID(7108)
                return
              end
            end
          end
        end
        PlayerController:PlaySpecifiedPetAnimation(ID)
      end
    end
  elseif self.CurrentShowState == ShowState.Collection then
    self:PlayEmoteInternal(ID, true)
  elseif self.CurrentShowState == ShowState.Flaunt then
    if not logic_emote.CheckIsPetExhibitionEmote(ID) then
      self:PlayEmoteInternal(ID, true)
    elseif logic_emote.CheckCanUsePetExhibitionEmote() then
      self:TryPlayPetExhibitAction()
    else
      ShowNotice(530022)
    end
  elseif self.CurrentShowState == ShowState.PetBubble or self.CurrentShowState == ShowState.SpectatorPetBubble then
    local PlayerController = GameplayData.GetPlayerController()
    if ID and slua.isValid(PlayerController) then
      if PlayerController.IsInPetSpectator and PlayerController:IsInPetSpectator() then
        local uPetSpectatorPawn = PlayerController:GetPetSpectatorComp() and PlayerController:GetPetSpectatorComp().PetSpectatorPawn
        local PetBubbleComponent_BP = slua.isValid(uPetSpectatorPawn) and uPetSpectatorPawn.PetBubbleComponent_BP
        if slua.isValid(PetBubbleComponent_BP) then
          if slua.isValid(PetBubbleComponent_BP) then
            PetBubbleComponent_BP:InvokePetBubble(ID)
          else
            print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem current player is spectator, but can not find PetBubbleComponent_BP")
          end
        end
      else
        if not PlayerController:CanShowMyPet() then
          IngameTipsTools.BattleNormalTipsByTextID(49084)
          return
        end
        local uCurPawn = PlayerController:GetCurPawn()
        if slua.isValid(uCurPawn) then
          if slua.isValid(uCurPawn.PetComponent_BP) and slua.isValid(uCurPawn.PetComponent_BP.PetPawn) and (uCurPawn.PetComponent_BP.PetPawn:PetHasState(EPetState.PetParachute) or uCurPawn.PetComponent_BP.PetPawn:PetHasState(EPetState.PetSwimming) or uCurPawn.PetComponent_BP.PetPawn:PetHasState(EPetState.PetSleeping) or uCurPawn.PetComponent_BP.PetPawn:PetHasState(EPetState.PetPlayingFeature)) then
            print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem pet state is forbidden!")
            IngameTipsTools.BattleNormalTipsByTextID(49084)
            return
          end
          local petId = 0
          if 0 <= PlayerController.UsingAdditionalPetIndex and PlayerController.AdditionalPetInfo:Num() > PlayerController.UsingAdditionalPetIndex then
            local petInfo = PlayerController.AdditionalPetInfo:Get(PlayerController.UsingAdditionalPetIndex)
            petId = petInfo and petInfo.PetId or 0
          else
            petId = PlayerController.InitialPetInfo.PetId or 0
          end
          if petId == 0 or petId == 50001 then
            IngameTipsTools.BattleNormalTipsByTextID(49084)
            return
          end
          if uCurPawn.PetExhibitFeature then
            uCurPawn.PetExhibitFeature:RPC_Server_ReqPetBubble(ID)
          else
            print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem PetExhibitFeature is not valid")
          end
        end
      end
    end
  elseif self.CurrentShowState == ShowState.MiniTvExpression then
    local uMontageData = FPetMontageData()
    uMontageData.AnimationAssetId = ID
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) and ID then
      local nMasterSkillID
      for _, v in pairs(self.MiniTvExpressionList) do
        if v.ID == ID then
          nMasterSkillID = v.MasterSkillID
          break
        end
      end
      if not self:GetIsEmoteExist(ID) then
        print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem MiniTvExpression not exist!! " .. ID)
        IngameTipsTools.BattleNormalTipsByTextID(43005)
        return
      end
      if PlayerController.IsInPetSpectator and PlayerController:IsInPetSpectator() and PlayerController:GetPetSpectatorComp() and PlayerController:GetPetSpectatorComp().PetSpectatorPawn then
        print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem IsInPetSpectator " .. ID)
      else
        local uCurPawn = PlayerController:GetCurPawn()
        if slua.isValid(uCurPawn) and slua.isValid(uCurPawn.PetComponent_BP) then
          local MiniTvPawn = uCurPawn.PetComponent_BP:GetMiniTVPawn()
          if slua.isValid(MiniTvPawn) and (MiniTvPawn:PetHasState(EPetState.PetParachute) or MiniTvPawn:PetHasState(EPetState.PetSwimming) or MiniTvPawn:PetHasState(EPetState.PetSleeping) or MiniTvPawn:PetHasState(EPetState.PetPlayingFeature)) then
            print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem mini tv state is forbidden!")
            IngameTipsTools.BattleNormalTipsByTextID(87380)
            return
          end
        end
        if nMasterSkillID ~= nil and 0 < nMasterSkillID then
          print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem Master trigger skill", nMasterSkillID)
          if slua.isValid(uCurPawn) then
            local SkillManager = uCurPawn:GetSkillManager()
            if slua.isValid(SkillManager) then
              local uSkill = SkillManager:GetSkill(nMasterSkillID)
              if uSkill and not uSkill:IsCDOK(SkillManager, -1) then
                local nCD = uSkill:GetCoolDownTime(SkillManager, 0)
                local bUseNewSkillCD = uSkill.bUseNewSkillCD
                print(bWriteLog and string.format("QuickExpressionDecalSubPanel:OnClickItem mini tv expression failed to trigger skill:%d : InCD, nCD:%s. bUseNewSkillCD:%s", nMasterSkillID, tostring(nCD), tostring(bUseNewSkillCD)))
                IngameTipsTools.BattleNormalTipsByTextID(7108)
                return
              end
            end
          end
        end
        PlayerController:PlaySpecifiedPetAnimation(ID, true)
        local PS = uCurPawn.GetPlayerStateSafety and uCurPawn:GetPlayerStateSafety()
        if slua.isValid(PS) and PS.RPC_ServerAddGeneralCount then
          PS:RPC_ServerAddGeneralCount(12025, 1, false)
          print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem RPC_ServerAddGeneralCount 12025")
        else
          print(bWriteLog and "[WARN] QuickExpressionDecalSubPanel:OnClickItem RPC_ServerAddGeneralCount 12025 failed")
        end
      end
    end
  end
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItem CloseContent, CurrentShowState" .. self.CurrentShowState)
  self:CloseContent()
end
function QuickExpressionDecalSubPanel:RequirPaint(Index)
  local Success = false
  if Index == -1 then
    self:CloseContent()
  else
    if not self:CanPaintDecal(Index) then
      log(bWriteLog and "QuickExpressionDecalSubPanel:RequirPaint: Can not paint decal..")
      return
    end
    local Interactive = self:IsInInteractiveState()
    if not Interactive then
      local PlayerCharacter = GameplayData.GetPlayerCharacter()
      if slua.isValid(PlayerCharacter) then
        PlayerCharacter:DoDetectPaintDecalTarget(false, Index)
        self:CloseContent()
      end
    end
  end
  return Success
end
function QuickExpressionDecalSubPanel:HandleChangeCurrentUsingWeapon()
  self:RefreshCheckGunBtnState()
  if self.CurrentShowState == ShowState.Expression then
    print(bWriteLog and "QuickExpressionDecalSubPanel:HandleChangeCurrentUsingWeapon Refresh Expression")
    self:AddGameTimer(0.6, false, function()
      self:RefreshExpression()
    end)
  elseif self.CurrentShowState == ShowState.IslandExpression then
    self:AddGameTimer(0.6, false, function()
      self:RefreshIslandExpression()
    end)
  end
end
function QuickExpressionDecalSubPanel:RefreshItemEmoteInfo(uBackpackComponent)
  for _, itemID in pairs(self.UpdateItemArr) do
    local ItemCount = uBackpackComponent:GetItemCountByItemSpecialID(itemID)
    print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshItemEmoteInfo", itemID, ItemCount)
  end
end
function QuickExpressionDecalSubPanel:RefreshGridPanel()
  local PlayerController = GameplayData.GetPlayerController()
  local bShowHologram = self:HasEquipHolography() and (self:IsSocialIsland() or self:IsTypicalGameMode() and not self.HasEnterBattle or self:IsMainCity())
  print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshGridPanel, ", self:HasEquipHolography(), self.HasEnterBattle, self:IsSocialIsland(), self:IsTypicalGameMode(), self:IsMainCity())
  if not bShowHologram then
    if self.CurrentShowState == ShowState.Holography then
      self.CurrentShowState = ShowState.Expression
    end
    if self.LastMoreState == ShowState.Holography then
      self.LastMoreState = ShowState.Decal
    end
  end
  print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshGridPanel, " .. self.CurrentShowState, self.LastMoreState, bShowHologram)
  self.UIRoot.CanvasPanel_ShowState:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if self.CurrentShowState == ShowState.IslandExpression or self.CurrentShowState == ShowState.Expression or self.CurrentShowState == ShowState.PetExpression or self.CurrentShowState == ShowState.SpectatorPetBubble or self.CurrentShowState == ShowState.MiniTvExpression then
    self.UIRoot.CanvasPanel_Expression:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.CanvasPanel_More:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_Collection:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif self.CurrentShowState == ShowState.Collection or self.CurrentShowState == ShowState.Flaunt then
    self.UIRoot.CanvasPanel_Expression:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_More:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_Collection:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.CanvasPanel_Expression:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_More:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.CanvasPanel_Collection:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    self.UIRoot.WidgetSwitcher_Sub_Collection:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.WidgetSwitcher_Sub_Collection:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  if slua.isValid(PlayerController) and PlayerController.IsInPetSpectator and PlayerController:IsInPetSpectator() then
    print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshGridPanel IsInPetSpectator")
    if self.CurrentShowState ~= ShowState.SpectatorPetBubble then
      self.CurrentShowState = ShowState.PetExpression
    end
    self.UIRoot.CanvasPanel_More:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_ShowState:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_Expression:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.CanvasPanel_bottom:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    self.UIRoot.WidgetSwitcher_Hologram:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.WidgetSwitcher_Expression:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.WidgetSwitcher_Decal:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.WidgetSwitcher_Bubble:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.WidgetSwitcher_PetExpression:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.WidgetSwitcher_SpectatorPetBubble:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_PlayerExpression:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_PetExpression:SetActiveWidgetIndex(0)
    local bCanShowPetBubble = self:CanShowPetBubblePanel()
    if bCanShowPetBubble then
      self.UIRoot.WidgetSwitcher_SpectatorPetBubble:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.WidgetSwitcher_SpectatorPetBubble:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    self.UIRoot.WidgetSwitcher_Robot:SetActiveWidgetIndex(0)
  else
    if self.bShowBottom then
      self.UIRoot.CanvasPanel_bottom:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.CanvasPanel_bottom:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if bShowHologram then
      self.UIRoot.WidgetSwitcher_Hologram:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.WidgetSwitcher_Hologram:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if not self:IsSocialIsland() then
      self.UIRoot.WidgetSwitcher_Bubble:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      self.UIRoot.WidgetSwitcher_Bubble:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.bShowDecal then
      self.UIRoot.WidgetSwitcher_Decal:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.WidgetSwitcher_Decal:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    self.UIRoot.WidgetSwitcher_Expression:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.WidgetSwitcher_Hologram:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_Expression:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_Decal:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_Bubble:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_PetExpression:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_Collection:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_More:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_PlayerExpression:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_PetBubble:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_SpectatorPetBubble:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_SpectatorPetBubble:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.WidgetSwitcher_Robot:SetActiveWidgetIndex(0)
  end
  if self.bShowMiniTvExpressionTab then
    self.UIRoot.WidgetSwitcher_Robot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.WidgetSwitcher_Robot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self.UIRoot.CanvasPanel_ShowEffects:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.WrapBox_List:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  if slua.isValid(PlayerController) and PlayerController.NeedHidePetExpression and PlayerController:NeedHidePetExpression() then
    self.UIRoot.WidgetSwitcher_PetExpression:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    if self.CurrentShowState == ShowState.Decal then
      PlayerCharacter:DoDetectPaintDecalTarget(true, 0)
    else
      PlayerCharacter:DoDetectPaintDecalTarget(false, 0)
    end
  end
  if self.CurrentShowState == ShowState.None then
    self:CloseContent()
  elseif self.CurrentShowState == ShowState.Holography then
    self.UIRoot.WidgetSwitcher_Hologram:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_More:SetActiveWidgetIndex(1)
    self.LastMoreState = self.CurrentShowState
    self:RefreshHolography()
  elseif self.CurrentShowState == ShowState.Decal then
    self.UIRoot.WidgetSwitcher_Decal:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_More:SetActiveWidgetIndex(1)
    self.LastMoreState = self.CurrentShowState
    self:RefreshDecalItems()
  elseif self.CurrentShowState == ShowState.Expression then
    self.UIRoot.WidgetSwitcher_Expression:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_PlayerExpression:SetActiveWidgetIndex(1)
    self.LastEmoteState = self.CurrentShowState
    self:RefreshExpression()
  elseif self.CurrentShowState == ShowState.Bubble then
    self.UIRoot.WidgetSwitcher_Bubble:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_More:SetActiveWidgetIndex(1)
    self.LastMoreState = self.CurrentShowState
    self:RefreshBubble()
  elseif self.CurrentShowState == ShowState.IslandExpression then
    self.UIRoot.WidgetSwitcher_Expression:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_PlayerExpression:SetActiveWidgetIndex(1)
    self.LastEmoteState = self.CurrentShowState
    self:RefreshIslandExpression()
  elseif self.CurrentShowState == ShowState.PetExpression then
    self.UIRoot.WidgetSwitcher_Expression:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_PetExpression:SetActiveWidgetIndex(1)
    self.LastEmoteState = self.CurrentShowState
    self:RefreshPetExpression()
  elseif self.CurrentShowState == ShowState.Collection then
    self.UIRoot.WidgetSwitcher_Collection:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_Sub_Collection:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_Sub_Flaunt:SetActiveWidgetIndex(0)
    self:RefreshCollection()
  elseif self.CurrentShowState == ShowState.Flaunt then
    self.UIRoot.WidgetSwitcher_Collection:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_Sub_Collection:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_Sub_Flaunt:SetActiveWidgetIndex(1)
    self:RefreshFlaunt()
  elseif self.CurrentShowState == ShowState.PetBubble then
    self.UIRoot.WidgetSwitcher_PetBubble:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_More:SetActiveWidgetIndex(1)
    self.LastMoreState = self.CurrentShowState
    self:RefreshPetBubble()
  elseif self.CurrentShowState == ShowState.SpectatorPetBubble then
    self.UIRoot.WidgetSwitcher_Expression:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_SpectatorPetBubble:SetActiveWidgetIndex(1)
    self.LastMoreState = self.CurrentShowState
    self:RefreshPetBubble()
  elseif self.CurrentShowState == ShowState.MiniTvExpression then
    self.UIRoot.WidgetSwitcher_Expression:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_Robot:SetActiveWidgetIndex(1)
    self.LastShowState = self.CurrentShowState
    self:RefreshMiniTvExpression()
  end
  self:FeatureButtonRefresh()
end
function QuickExpressionDecalSubPanel:RefreshHolography()
  local HolographyList = self:GetEquipHolography()
  print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshHolography Num:" .. tostring(HolographyList and HolographyList:Num()))
  if HolographyList then
    for Index, ItemData in pairs(HolographyList) do
      local Item = self:GetQuickExpressionDecalItemByIndex(Index + 1)
      if Item then
        Item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        Item:Show()
        Item:RefreshData(ItemData, -1)
      end
    end
    self:HideRestBlocks(HolographyList:Num())
  else
    self:HideRestBlocks(0)
  end
end
function QuickExpressionDecalSubPanel:GetDecalItems()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    log(bWriteLog and "QuickExpressionDecalSubPanel:GetDecalItems uPlayerController is nil")
    return nil
  end
  local BackPackComp = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(uPlayerController)
  if not slua.isValid(BackPackComp) then
    log(bWriteLog and "QuickExpressionDecalSubPanel:GetDecalItems BackPackComp is nil")
    return nil
  end
  local DecalItemArr = BackpackUtils.GetDecalItemInBackpack(BackPackComp)
  local DecalItemArrTable = {}
  for Index, Data in pairs(DecalItemArr) do
    DecalItemArrTable[Index + 1] = Data
  end
  return DecalItemArrTable
end
function QuickExpressionDecalSubPanel:RefreshDecalItems()
  print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshDecalItems")
  local DecalItemArr = self:GetDecalItems()
  if not DecalItemArr then
    log(bWriteLog and "QuickExpressionDecalSubPanel:RefreshDecalItems DecalItemArr is nil")
    return
  end
  local DecalNum = #DecalItemArr
  print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshDecalItems, " .. DecalNum)
  for Index, ItemData in pairs(DecalItemArr) do
    local Item = self:GetQuickExpressionDecalItemByIndex(Index)
    if ItemData and Item then
      Item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      Item:Show()
      Item:RefreshData(ItemData.DefineID.TypeSpecificID, ItemData.Count)
    end
  end
  self:HideRestBlocks(DecalNum)
  self.UIRoot.CanvasPanel_List:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function QuickExpressionDecalSubPanel:GetExpressionItems()
  local QuickExpressionUtils = require("GameLua.Mod.BaseMod.Client.Emote.QuickExpressionUtils")
  local EmoteItemsTable, _ = QuickExpressionUtils.GetShowExpressionList()
  return EmoteItemsTable
end
function QuickExpressionDecalSubPanel:GetParticleEmoteID(baseEmoteID)
  local PlayerController = GameplayData.GetPlayerController()
  local nLevel = PlayerController.PlayEmoteFeature.EmoteLevelMap[baseEmoteID]
  local EmoteConfig = CDataTable.GetTableData("ParticleEmoteCfg", baseEmoteID)
  if nLevel and EmoteConfig and nLevel >= EmoteConfig.Level then
    return EmoteConfig.EmoteIDLevel2
  end
  return nil
end
function QuickExpressionDecalSubPanel:RefreshExpression()
  local EmoteItemsTable = self:GetExpressionItems()
  if not EmoteItemsTable then
    log(bWriteLog and "QuickExpressionDecalSubPanel:RefreshExpression EmoteItemsTable is nil!")
    return
  end
  local QuickExpressionUtils = require("GameLua.Mod.BaseMod.Client.Emote.QuickExpressionUtils")
  local nState, nEmoteID = QuickExpressionUtils.GetCurrentWeaponShowEmoteState()
  local nWeaponEmoteId = QuickExpressionUtils.GetWeaponShowEmoteID()
  self.ClothBackpackItem = QuickExpressionUtils.GetClothBackpackItem()
  self.WeaponShowEmoteID = nWeaponEmoteId
  local ShowEmoteCount = 0
  local bShowEffectBut = false
  local PlayerController = GameplayData.GetPlayerController()
  for Index, Data in ipairs(EmoteItemsTable) do
    local TypeSpecificID = Data.DefineID.TypeSpecificID
    print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshExpression", Index, TypeSpecificID)
    if IgnoreEmoteConfig[TypeSpecificID] then
      print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshExpression ignore, " .. TypeSpecificID)
    else
      local ShowEffectState = 0
      local effectEmoteID = self:GetParticleEmoteID(TypeSpecificID)
      if effectEmoteID then
        bShowEffectBut = true
        if PlayerController.PlayEmoteFeature.ClientCacheShowEmoteEffect then
          log(bWriteLog and string.format("QuickExpressionDecalSubPanel:RefreshExpression replace effect emote [%s]->[%s]", tostring(TypeSpecificID), tostring(effectEmoteID)))
          TypeSpecificID = effectEmoteID
          ShowEffectState = 2
        else
          ShowEffectState = 1
        end
      end
      local EmotionConfig = CDataTable.GetTableData("EmotionLimitCfg", TypeSpecificID)
      if EmotionConfig and EmotionConfig.EmotionID then
        self.AllLimitEmoteList[EmotionConfig.EmotionID] = true
      end
      local Item = self:GetQuickExpressionDecalItemByIndex(Index)
      if Item then
        if ShowEffectState == 1 then
          Item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          Item.UIRoot.WidgetSwitcher_Effect:SetActiveWidgetIndex(0)
        elseif ShowEffectState == 2 then
          Item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          Item.UIRoot.WidgetSwitcher_Effect:SetActiveWidgetIndex(1)
        else
          Item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
        if Data.bWeaponShow then
          Item.UIRoot.Image_Weapon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        else
          Item.UIRoot.Image_Weapon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
        Item:Show()
        Item:RefreshData(TypeSpecificID, -1)
        print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshExpression, " .. tostring(TypeSpecificID) .. ", " .. tostring(self.AllLimitEmoteList[TypeSpecificID]))
        if self.AllLimitEmoteList[TypeSpecificID] then
          local bIsEmoteExist = self:GetIsEmoteExist(TypeSpecificID)
          local FinalColor = self.GreyColor
          if bIsEmoteExist then
            local bIsEmoteLimit = self:CheckIsWearingEmoteLimitCloth(TypeSpecificID)
            local bIsEmoteBan, TipsID = logic_emote.CheckEmoteIsBan(TypeSpecificID)
            FinalColor = self.ColorB
            if not bIsEmoteLimit or bIsEmoteBan then
              FinalColor = self.ColorA
            end
            print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshExpression, " .. tostring(bIsEmoteLimit) .. ", " .. tostring(bIsEmoteBan))
          end
          Item:SetImageColor(FinalColor)
        end
        ShowEmoteCount = ShowEmoteCount + 1
      end
    end
  end
  self:HideRestBlocks(ShowEmoteCount)
  if 0 < ShowEmoteCount and bShowEffectBut then
    self.UIRoot.CanvasPanel_ShowEffects:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if PlayerController.PlayEmoteFeature.ClientCacheShowEmoteEffect then
      self.UIRoot.CheckBox_ShowEffects:SetCheckedState(UEnums.ECheckBoxState.Checked)
    else
      self.UIRoot.CheckBox_ShowEffects:SetCheckedState(UEnums.ECheckBoxState.Unchecked)
    end
  end
end
function QuickExpressionDecalSubPanel:RefreshBubble()
  print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshBubble")
  self:RefreshEmoteActionSys()
  local uIslandBubbleEmoteSys = GameplaySysMgr.GetSysByName("IslandBubbleEmoteSys")
  if uIslandBubbleEmoteSys ~= nil then
    self.uBubbleIDList = uIslandBubbleEmoteSys:GetBubbleIdList()
    if bWriteLog then
      log_tree("QuickExpressionDecalSubPanel:RefreshBubble", self.uBubbleIDList)
    end
    for Index, ID in pairs(self.uBubbleIDList) do
      local Item = self:GetQuickExpressionDecalItemByIndex(Index)
      if Item then
        Item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        Item:Show()
        Item:RefreshData(ID, -1)
      end
    end
    self:HideRestBlocks(#self.uBubbleIDList)
  end
end
function QuickExpressionDecalSubPanel:RefreshIslandExpression()
  print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshIslandExpression")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController.PlayEmoteFeature then
    return
  end
  if bWriteLog then
    log_tree("QuickExpressionDecalSubPanel:RefreshExpression", PlayerController.PlayEmoteFeature.EmoteLevelMap)
  end
  self:RefreshEmoteActionSys()
  local uEmoteActionSys = GameplaySysMgr.GetSysByName("EmoteActionSys")
  if uEmoteActionSys ~= nil then
    self.uEmoteIDList = uEmoteActionSys:GetEmoteList()
    if bWriteLog then
      log_tree("uEmoteIDList:", self.uEmoteIDList)
    end
    local EmoteCnt = 0
    local bShowEffectBut = false
    self.WeaponShowEmoteID = 0
    self.ClothEmoteID = 0
    local QuickExpressionUtils = require("GameLua.Mod.BaseMod.Client.Emote.QuickExpressionUtils")
    local State, EmoteID = QuickExpressionUtils.GetCurrentWeaponShowEmoteState()
    if State == 0 or State == 1 then
      print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshIslandExpression hasWeaponShowEmote ")
      self.WeaponShow      table.insert(self.uEmoteIDList, 1, self.WeaponShowEmoteID)
    end
    local ClothEmoteID = QuickExpressionUtils.GetClothEmoteID()
    if ClothEmoteID and 0 < ClothEmoteID then
      print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshIslandExpression hasClothEmote ID:" .. tostring(ClothEmoteID))
      self.      table.insert(self.uEmoteIDList, 1, ClothEmoteID)
    end
    for Index, ID in pairs(self.uEmoteIDList) do
      if IgnoreEmoteConfig[ID] then
        print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshIslandExpression ignore, " .. ID)
      else
        local ShowEffectState = 0
        local nLevel = PlayerController.PlayEmoteFeature.EmoteLevelMap[ID]
        local EmoteConfig = CDataTable.GetTableData("ParticleEmoteCfg", ID)
        if nLevel and EmoteConfig and nLevel >= EmoteConfig.Level then
          bShowEffectBut = true
          local EffectEmoteID = EmoteConfig.EmoteIDLevel2
          if PlayerController.PlayEmoteFeature.ClientCacheShowEmoteEffect and EffectEmoteID then
            ID = EffectEmoteID
            ShowEffectState = 2
          else
            ShowEffectState = 1
          end
        end
        local Item = self:GetQuickExpressionDecalItemByIndex(Index)
        print(bWriteLog and "RefreshIslandExpression, " .. Index .. ", " .. ID .. "," .. ShowEffectState)
        if Item then
          if ShowEffectState == 1 then
            Item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            Item.UIRoot.WidgetSwitcher_Effect:SetActiveWidgetIndex(0)
          elseif ShowEffectState == 2 then
            Item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            Item.UIRoot.WidgetSwitcher_Effect:SetActiveWidgetIndex(1)
          else
            Item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          end
          Item:Show()
          Item:RefreshData(ID, -1)
          if Index == 1 and self.WeaponShowEmoteID ~= 0 then
            Item.UIRoot.Image_Weapon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          else
            Item.UIRoot.Image_Weapon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          end
          EmoteCnt = EmoteCnt + 1
        end
      end
    end
    self:HideRestBlocks(EmoteCnt)
    if 0 < EmoteCnt and bShowEffectBut then
      self.UIRoot.CanvasPanel_ShowEffects:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      if PlayerController.PlayEmoteFeature.ClientCacheShowEmoteEffect then
        self.UIRoot.CheckBox_ShowEffects:SetCheckedState(UEnums.ECheckBoxState.Checked)
      else
        self.UIRoot.CheckBox_ShowEffects:SetCheckedState(UEnums.ECheckBoxState.Unchecked)
      end
    end
  end
end
function QuickExpressionDecalSubPanel:RefreshPetExpression()
  self:RefreshPetInfo()
  print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshPetExpression, " .. tostring(self.PetID) .. ", " .. tostring(self.PetLevel) .. ", " .. tostring(self.bShowMyPet))
  if not self.PetID or self.PetID <= 0 or not self.bShowMyPet then
    self:HideRestBlocks(0)
    return
  end
  local EmoteCnt = 0
  for Index, v in pairs(self.CurPetExpressionList) do
    local Item = self:GetQuickExpressionDecalItemByIndex(Index)
    if Item then
      Item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      Item:Show()
      Item:RefreshData(v.ID, -1, true, v.IsLocked)
      EmoteCnt = EmoteCnt + 1
    end
  end
  self:HideRestBlocks(EmoteCnt)
end
function QuickExpressionDecalSubPanel:RefreshCollection()
  self:RefreshCollectionList()
  if #self.CollectionList == 0 then
    self:HideRestBlocks(0)
    return
  end
  local EmoteCnt = 0
  for Index, ID in pairs(self.CollectionList) do
    local Item = self:GetQuickExpressionDecalItemByIndex(Index)
    if Item then
      Item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      Item:Show()
      Item:RefreshData(ID, -1, false)
      EmoteCnt = EmoteCnt + 1
    end
  end
  self:HideRestBlocks(EmoteCnt)
end
function QuickExpressionDecalSubPanel:RefreshFlaunt()
  local ItemList = logic_emote.GetFlauntEmote()
  local EmoteCnt = 0
  for Index, ID in pairs(ItemList) do
    local Item = self:GetQuickExpressionDecalItemByIndex(Index)
    if Item then
      Item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      Item:Show()
      Item:RefreshData(ID, -1, false)
      EmoteCnt = EmoteCnt + 1
    end
  end
  local LogStr = "QuickExpressionDecalSubPanel:RefreshFlaunt ItemList: "
  for _, v in pairs(ItemList) do
    LogStr = LogStr .. tostring(v) .. " "
  end
  print(bWriteLog and LogStr)
  self:HideRestBlocks(EmoteCnt)
end
function QuickExpressionDecalSubPanel:RefreshEmoteActionSys()
  local uEmoteActionSys = GameplaySysMgr.GetSysByName("EmoteActionSys")
  if uEmoteActionSys ~= nil then
    uEmoteActionSys:Refresh()
  end
end
function QuickExpressionDecalSubPanel:GetQuickExpressionDecalItemByIndex(Index)
  print(bWriteLog and "QuickExpressionDecalSubPanel:GetQuickExpressionDecalItemByIndex Index:", Index)
  local StartIndex = #self.QuickExpressionDecalItemList
  while Index > StartIndex do
    print(bWriteLog and "QuickExpressionDecalSubPanel:GetQuickExpressionDecalItemByIndex,", StartIndex, Index)
    local Item = self:CreateChildWindow(self.UIRoot.WrapBox_List, UIManager.UI_Config_InGame.QuickExpressionDecalItem)
    Item:SetData(function(TypeSpecificID)
      print(bWriteLog and "QuickExpressionDecalSubPanel:OnClickItemWidgets, " .. TypeSpecificID)
      self:OnClickItem(TypeSpecificID)
    end, Index)
    table.insert(self.QuickExpressionDecalItemList, Item)
    StartIndex = StartIndex + 1
  end
  return self.QuickExpressionDecalItemList[Index]
end
function QuickExpressionDecalSubPanel:HideRestBlocks(ShowNum)
  if not self or not self.UIRoot then
    return
  end
  print(bWriteLog and "QuickExpressionDecalSubPanel:HideRestBlocks" .. ShowNum)
  local HideWidgets = function(ShowNum, EmptyNum)
    for i = ShowNum + 1, math.max(EmptyNum, #self.QuickExpressionDecalItemList) do
      if EmptyNum >= i then
        local Item = self:GetQuickExpressionDecalItemByIndex(i)
        if Item then
          Item:Show()
          Item:RefreshData(-1, -1)
        end
      else
        local Item = self.QuickExpressionDecalItemList[i]
        if Item then
          Item:Collapsed()
        end
      end
    end
  end
  self.UIRoot.ScrollBox_0.SizeY = 200
  if ShowNum <= 0 then
    self.UIRoot.WrapBox_List:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_ShowPet:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_ShowRobot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if self.CurrentShowState == ShowState.Expression or self.CurrentShowState == ShowState.IslandExpression then
      self.UIRoot.TextBlock_Emty:SetText(LocUtil.GetLocalizeResStr(NO_EXPRESSION))
    elseif self.CurrentShowState == ShowState.Bubble then
      self.UIRoot.TextBlock_Emty:SetText(LocUtil.GetLocalizeResStr(NO_BUBBLE))
    elseif self.CurrentShowState == ShowState.Decal then
      self.UIRoot.TextBlock_Emty:SetText(LocUtil.GetLocalizeResStr(NO_DECAL))
    elseif self.CurrentShowState == ShowState.Holography then
      self.UIRoot.TextBlock_Emty:SetText(LocUtil.GetLocalizeResStr(NO_HOLOGRAPHY))
    elseif self.CurrentShowState == ShowState.PetExpression then
      if not self.PetID or 0 >= self.PetID then
        if self:IsPlanPHMode() then
          self.UIRoot.TextBlock_Emty:SetText(LocUtil.GetLocalizeResStr(655424))
        elseif self:IsCollectionMode() then
          self.UIRoot.TextBlock_Emty:SetText(LocUtil.GetLocalizeResStr(880060105))
        else
          self.UIRoot.TextBlock_Emty:SetText(LocUtil.GetLocalizeResStr(NO_PET))
        end
      elseif not self.bShowMyPet then
        self.UIRoot.TextBlock_Emty:SetText(LocUtil.GetLocalizeResStr(PET_INVISIBLE))
        self.UIRoot.CanvasPanel_ShowPet:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
    elseif self.CurrentShowState == ShowState.Collection then
      self.UIRoot.TextBlock_Emty:SetText(LocUtil.GetLocalizeResStr(NO_COLLECTION))
    elseif self.CurrentShowState == ShowState.PetBubble then
      self.UIRoot.TextBlock_Emty:SetText(LocUtil.GetLocalizeResStr(NO_BUBBLE))
    elseif self.CurrentShowState == ShowState.SpectatorPetBubble then
      self.UIRoot.TextBlock_Emty:SetText(LocUtil.GetLocalizeResStr(NO_BUBBLE))
    elseif self.CurrentShowState == ShowState.MiniTvExpression then
      if self.bShowMiniTv then
        self.UIRoot.TextBlock_Emty:SetText(LocUtil.GetLocalizeResStr(NO_MINITV_EXPRESSION))
      else
        self.UIRoot.TextBlock_Emty:SetText(LocUtil.GetLocalizeResStr(NO_MINITV))
        self.UIRoot.CanvasPanel_ShowRobot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
    end
    self.UIRoot.VerticalBox_Empty:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.WrapBox_List:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    local RowNum = math.ceil(ShowNum / 4)
    self.UIRoot.VerticalBox_Empty:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local EmptyNum = RowNum * 4
    HideWidgets(ShowNum, EmptyNum)
    local TargetSizeY = math.min(RowNum * 60, 200)
    local originSize = self.UIRoot.ScrollBox_0.Slot:GetSize()
    self.UIRoot.ScrollBox_0.Slot:SetSize(FVector2D(originSize.X, TargetSizeY))
    print(bWriteLog and "QuickExpressionDecalSubPanel:HideRestBlocks", TargetSizeY, originSize.X, originSize.Y)
  end
end
function QuickExpressionDecalSubPanel:TryToThrowHolography(ID)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.GetPlayerCharacterSafety then
    local uPawn = PlayerController:GetPlayerCharacterSafety()
    print(bWriteLog and "QuickExpressionDecalSubPanel:TryToThrowHolography ID:" .. tostring(ID))
    if slua.isValid(uPawn) then
      local SkillMgr = uPawn:GetSkillManager()
      if slua.isValid(SkillMgr) then
        SkillMgr:SetValueAsInt(HOLOGRAPHY_SKILL_ID, "ItemID", ID)
        uPawn:TriggerEntrySkillWithParams(HOLOGRAPHY_SKILL_ID, {"ItemID"}, true)
      else
        print(bWriteLog and "QuickExpressionDecalSubPanel:TryToThrowHolography not SkillMgr")
      end
    else
      print(bWriteLog and "QuickExpressionDecalSubPanel:TryToThrowHolography not uPawn")
    end
  end
end
function QuickExpressionDecalSubPanel:TryToPlayEmote(EmoteID)
  if not EmoteID then
    return
  end
  local QuickExpressionUtils = require("GameLua.Mod.BaseMod.Client.Emote.QuickExpressionUtils")
  if EmoteID == self.WeaponShowEmoteID then
    QuickExpressionUtils.TryPlayWeaponShowEmote()
    return
  end
  local character = GameplayData.GetPlayerCharacter()
  if GameStatus.IsPHomeMode(true) and slua.isValid(character) and character.CharacterMovement and character.CharacterMovement:IsFlying() then
    log(bWriteLog and "QuickExpressionDecalSubPanel:TryToPlayEmote. isFlying")
    return
  end
  local bIsExist = self:GetIsEmoteExist(EmoteID)
  print(bWriteLog and "TryToPlayEmote, " .. EmoteID .. ", " .. tostring(bIsExist))
  if not bIsExist then
    IngameTipsTools.BattleNormalTipsByTextID(27679)
    return
  end
  local Clothes2EmoteCfg = CDataTable.GetTableData("Clothes2EmoteCfg", EmoteID)
  local limited, resId
  if Clothes2EmoteCfg then
    limited = true
    if slua.isValid(character) then
      local CharacterAvatarComp2_BP = character.CharacterAvatarComp2_BP
      local ItemID_a = Clothes2EmoteCfg.ItemID_a
      for _, id in pairs(ItemID_a) do
        if CharacterAvatarComp2_BP:IsItemHasEquipped(id) then
          limited = false
          break
        else
          resId = Clothes2EmoteCfg.tipsId
        end
      end
    end
  end
  if limited then
    IngameTipsTools.BattleNormalTipsByTextID(resId)
    return
  end
  local OwningActor = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if not OwningActor or not slua.isValid(OwningActor) then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  local bEmoteIsBan, TipsID = logic_emote.CheckEmoteIsBan(EmoteID)
  if bEmoteIsBan and PlayerController and PlayerController.DisplayGameTipWithMsgID then
    PlayerController:DisplayGameTipWithMsgID(TipsID)
    return
  end
  self.ClothBackpackItem = QuickExpressionUtils.GetClothBackpackItem()
  local bIsWearingEmoteLimitCloth, TipsID = self:CheckIsWearingEmoteLimitCloth(EmoteID)
  local bIsInLimitEmoteList = self.AllLimitEmoteList[EmoteID]
  local bCanPlayEmote = false
  if not bIsInLimitEmoteList or bIsInLimitEmoteList and bIsWearingEmoteLimitCloth then
    bCanPlayEmote = true
  elseif PlayerController and PlayerController.DisplayGameTipWithMsgID then
    PlayerController:DisplayGameTipWithMsgID(6036)
    return
  end
  if logic_emote.CheckIsDanceTogetherEmote(EmoteID) then
    print(bWriteLog and "QuickExpressionDecalSubPanel Play Together Emote")
    bCanPlayEmote = false
    logic_emote.TriggerDanceBuildSkill(EmoteID)
  end
  if bCanPlayEmote then
    self:PlayEmoteInternal(EmoteID, false)
  elseif TipsID and 0 < TipsID then
    IngameTipsTools.BattleNormalTipsByTextID(TipsID)
  end
end
function QuickExpressionDecalSubPanel:TryPlayWeaponShowEmote()
  local OwningActor = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if not OwningActor or not slua.isValid(OwningActor) then
    return
  end
  local QuickExpressionUtils = require("GameLua.Mod.BaseMod.Client.Emote.QuickExpressionUtils")
  local State, EmoteID = QuickExpressionUtils.GetCurrentWeaponShowEmoteState()
  if State ~= 0 then
    local OwningController = OwningActor:GetPlayerControllerSafety()
    if OwningController and slua.isValid(OwningController) and OwningController.DisplayGameTipWithMsgID and State == 1 then
      OwningController:DisplayGameTipWithMsgID(30121)
    else
    end
    return
  end
  local WeaponShowSkillID = 1014433
  local SkillMgr = OwningActor:GetSkillManager()
  if Game:IsValid(SkillMgr) and SkillMgr:IsCastingSkillID(WeaponShowSkillID) then
    return
  end
  OwningActor:ForceSyncMovementState()
  OwningActor:TriggerEntrySkillWithID(WeaponShowSkillID, true)
end
function QuickExpressionDecalSubPanel:PlayEmoteInternal(EmoteID, bIsCollection)
  local OwningActor = GameplayData.GetPlayerCharacter()
  if not OwningActor or not slua.isValid(OwningActor) then
    OwningActor = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
    if not OwningActor or not slua.isValid(OwningActor) then
      return
    end
  end
  print(bWriteLog and "QuickExpressionDecalSubPanel:PlayEmoteInternal EmoteID = " .. tostring(EmoteID))
  local CoopEmoteUtil = require("GameLua.Activity.Commercialize.GamePlay.CoopEmote.CoopEmoteUtil")
  if CoopEmoteUtil.IsCoopEmote(EmoteID) then
    if OwningActor.CoopEmoteCharFeature and OwningActor.CoopEmoteCharFeature:IsInCoopEmote() then
      print(bWriteLog and "QuickExpressionDecalSubPanel:PlayEmoteInternal already in coop emote")
      ShowNotice(44711)
      return
    end
    if OwningActor.GetPlayEmoteComponent then
      local uPlayEmoteComp = OwningActor:GetPlayEmoteComponent()
      if slua.isValid(uPlayEmoteComp) then
        uPlayEmoteComp.CoopEmoteTargetOffset = CoopEmoteUtil.GetCoopEmoteTarget(EmoteID)
      end
    end
    if OwningActor.CheckCanBeginPlayCoopEmote and not OwningActor:CheckCanBeginPlayCoopEmote() then
      print(bWriteLog and "QuickExpressionDecalSubPanel:PlayEmoteInternal CheckCanBeginPlayCoopEmote false")
      ShowNotice(44709)
      return
    end
    local UEPathUtilityMethods = import("UEPathUtilityMethods")
    for _, v in pairs(CoopEmoteUtil.GetAllRelateEmote(EmoteID)) do
      local EmoteHandlePath = OwningActor:GetEmoteHandlePath(v)
      local ItemPathExist = UEPathUtilityMethods.IsAvatarResPathExist(EmoteHandlePath)
      if not ItemPathExist then
        ShowNotice(66932)
        print(bWriteLog and "QuickExpressionDecalSubPanel:PlayEmoteInternal not ItemPathExist. EmoteHandlePath:" .. EmoteHandlePath)
        return
      end
    end
  end
  local bIsMovableEmote = false
  local EmoteSubSystem = SubsystemMgr:Get("EmoteSubSystem")
  if EmoteSubSystem then
    bIsMovableEmote = EmoteSubSystem:TryPlayMovableEmote(EmoteID, OwningActor)
    if bIsMovableEmote then
      print(bWriteLog and "QuickExpressionDecalUI TryPlayMovableEmote \230\136\144\229\138\159\229\129\154\232\161\168\230\131\133tlog")
      EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_ADD_VALUE_TLOG, "ExpressionSuccessNum", 1)
      return true
    end
  end
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if logic_emote.PlayEmote(OwningActor, EmoteID) then
    print(bWriteLog and "QuickExpressionDecalUI\230\136\144\229\138\159\229\129\154\232\161\168\230\131\133tlog")
    local PS = OwningActor:GetPlayerStateSafety()
    if bIsCollection then
      if slua.isValid(PS) and PS.RPC_ServerAddGeneralCount then
        PS:RPC_ServerAddGeneralCount(11041, 1, false)
      end
    else
      EventSystem:postEvent(EVENTTYPE_CLIENT_TLOG, EVENTID_ADD_VALUE_TLOG, "ExpressionSuccessNum", 1)
    end
    if EmoteID == 12220288 and slua.isValid(PS) and PS.RPC_ServerAddGeneralCount then
      PS:RPC_ServerAddGeneralCount(467, 1, false)
    end
    return true
  end
end
function QuickExpressionDecalSubPanel:CheckIsWearingEmoteLimitCloth(EmoteID)
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
function QuickExpressionDecalSubPanel:GetIsEmoteExist(DefineID)
  return self:GetIsItemHandleExist(22, DefineID)
end
function QuickExpressionDecalSubPanel:GetIsItemHandleExist(ItemType, DefineID)
  self.ItemDefineIDTemp.Type = ItemType
  self.ItemDefineIDTemp.TypeSpecificID = DefineID
  local isSupportDownload = GameStatus.InSupportDownloadState()
  return BackpackUtils.IsBattleItemHandleExist(self.ItemDefineIDTemp, not isSupportDownload, false, false)
end
function QuickExpressionDecalSubPanel:IsSocialIsland()
  local GameState = GameplayData.GetGameState()
  if slua.isValid(GameState) and GameState.IsNonePlayerOnIsland then
    return true
  end
  return false
end
function QuickExpressionDecalSubPanel:IsMainCity()
  return GameStatus.IsInMainCity()
end
function QuickExpressionDecalSubPanel:IsPlanPHMode()
  log(bWriteLog and "QuickExpressionDecalSubPanel:IsPlanPHMode")
  local CurGameModeID = Client.GetGameModeID(GameFrontendHUD)
  log(bWriteLog and "QuickExpressionDecalSubPanel:IsPlanPHMode CurGameModeID = " .. tostring(CurGameModeID))
  local home_macros = require("client.slua.logic.home.home_macros")
  if tostring(CurGameModeID) == tostring(home_macros.Home_SubMode.Visit) then
    return true
  end
  return false
end
function QuickExpressionDecalSubPanel:IsCollectionMode()
  log(bWriteLog and "QuickExpressionDecalSubPanel:IsCollectionMode")
  return GameStatus.IsCollectionHallMode()
end
function QuickExpressionDecalSubPanel:IsBornisland()
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) or not GameState.GetGameModeState then
    return false
  end
  return GameState:GetGameModeState() == "ReadyState"
end
function QuickExpressionDecalSubPanel:HasEquipHolography()
  local HolographyList = self:GetEquipHolography()
  return HolographyList and HolographyList:Num() > 0
end
function QuickExpressionDecalSubPanel:GetEquipHolography()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController.CommerFeature then
    return nil
  end
  print(bWriteLog and "QuickExpressionDecalSubPanel:GetEquipHolography UID:" .. tostring(PlayerController.UID))
  if not PlayerController.CommerFeature.HolographyList then
    return nil
  end
  return PlayerController.CommerFeature.HolographyList
end
function QuickExpressionDecalSubPanel:IsTypicalGameMode()
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    print(bWriteLog and "QuickExpressionDecalSubPanel: not uGameSt0ate")
    return false
  end
  if uGameState.GameModeType == EGameModeType.ETypicalGameMode or uGameState.GameModeType == EGameModeType.EFourInOneGameMode then
    return true
  end
  print(bWriteLog and "QuickExpressionDecalSubPanel: not TypicalGameMode " .. tostring(uGameState.GameModeType))
  return false
end
function QuickExpressionDecalSubPanel:OnEnterBattle()
  print(bWriteLog and "QuickExpressionDecalSubPanel: OnEnterBattle")
  self.HasEnterBattle = true
  self.UIRoot.WidgetSwitcher_Hologram:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.LastCloseShowState == ShowState.Holography then
    self.LastCloseShowState = ShowState.None
  end
  if self.LastMoreState == ShowState.Holography then
    self.LastMoreState = ShowState.Decal
  end
  self:CloseContent()
end
function QuickExpressionDecalSubPanel:IsInInteractiveState()
  return false
end
function QuickExpressionDecalSubPanel:CanPaintDecal(ID)
  if not self:CheckPHomeCanPaintDecal(ID) then
    return false
  end
  return true
end
function QuickExpressionDecalSubPanel:CheckPHomeCanPaintDecal(ID)
  log(bWriteLog and "QuickExpressionDecalSubPanel:CheckPHomeCanPaintDecal ID:" .. tostring(ID))
  if GameStatus.IsInFightingStatus() then
    local bIsInSocialIslandStoreBuilding = false
    if GameStatus.IsSocialIslandMode() then
      local PHomeClientSys = GameplaySysMgr.GetSysByName("PHomeClientSys")
      if PHomeClientSys and PHomeClientSys:IsMyselfInStoreBuilding() then
        bIsInSocialIslandStoreBuilding = true
      end
      log(bWriteLog and "QuickExpressionDecalSubPanel:RequirPaint: In social island, in store building = " .. tostring(bIsInSocialIslandStoreBuilding))
    end
    local bIsForbidInPHome = false
    if GameStatus.IsPHomeMode(true) then
      if not PHomePaintDecalWhiteList[ID] then
        bIsForbidInPHome = true
      end
      log(bWriteLog and "QuickExpressionDecalSubPanel:RequirPaint: In PHome, forbid paint=" .. tostring(bIsForbidInPHome))
    end
    local bIsForbidInCollectionHall = GameStatus.IsCollectionHallMode(true)
    if bIsForbidInCollectionHall then
      log(bWriteLog and "QuickExpressionDecalSubPanel:RequirPaint: In CollectionHall, forbid paint")
    end
    if bIsInSocialIslandStoreBuilding or bIsForbidInPHome or bIsForbidInCollectionHall then
      log(bWriteLog and "QuickExpressionDecalSubPanel:RequirPaint Forbid paint: bIsInSocialIslandStoreBuilding=" .. tostring(bIsInSocialIslandStoreBuilding) .. ", bIsForbidInPHome=" .. tostring(bIsForbidInPHome) .. ", bIsForbidInCollectionHall=" .. tostring(bIsForbidInCollectionHall))
      local PlayerController = GameplayData.GetPlayerController()
      PlayerController:DisplayGameTipWithMsgID(69731)
      self:CloseContent()
      return false
    end
  end
  return true
end
function QuickExpressionDecalSubPanel:FeatureButtonRefresh()
  self:RefreshCheckGunBtnState()
  self:RefreshChangeAvatarFormBtnState(true)
  self:RefreshTransformButton()
  self:RefreshPetButton()
  self:RefreshXSuitEmoteButton()
end
function QuickExpressionDecalSubPanel:RefreshCheckGunBtnState()
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if logic_emote.bCustomWeaponShow then
    self.UIRoot.WidgetSwitcher_Check:SetActiveWidgetIndex(1)
    self.UIRoot.TextBlock_CheckGun:SetText(LocUtil.GetLocalizeResStr(49511))
  else
    self.UIRoot.WidgetSwitcher_Check:SetActiveWidgetIndex(0)
    self.UIRoot.TextBlock_CheckGun:SetText(LocUtil.GetLocalizeResStr(43770))
  end
  local CheckGunState = QuickExpression.GetCurrentCheckGunState(self.UIRoot)
  print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshCheckGunBtnState, " .. CheckGunState)
  if self.HalfAlpha_LColor == nil then
    self.HalfAlpha_LColor = FLinearColor(1.0, 1.0, 1.0, 0.5)
    self.HalfAlpha_SColor = FSlateColor(FLinearColor(1.0, 1.0, 1.0, 0.5))
    self.FullAlpha_LColor = FLinearColor(1.0, 1.0, 1.0, 1.0)
    self.FullAlpha_SColor = FSlateColor(FLinearColor(1.0, 1.0, 1.0, 1.0))
  end
  if CheckGunState == -1 or CheckGunState == 2 or CheckGunState == 3 then
    self.UIRoot.Image_CheckGun:SetColorAndOpacity(self.HalfAlpha_LColor)
    self.UIRoot.TextBlock_CheckGun:SetColorAndOpacity(self.HalfAlpha_SColor)
  else
    self.UIRoot.Image_CheckGun:SetColorAndOpacity(self.FullAlpha_LColor)
    self.UIRoot.TextBlock_CheckGun:SetColorAndOpacity(self.FullAlpha_SColor)
  end
end
function QuickExpressionDecalSubPanel:RefreshChangeAvatarFormBtnState(IsShow)
  print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshChangeAvatarFormBtnState, " .. tostring(IsShow))
  if self.ChangeAvatarFormCDTimer then
    self:RemoveTimer(self.ChangeAvatarFormCDTimer)
    self.ChangeAvatarFormCDTimer = nil
  end
  if not IsShow then
    return
  end
  self.UIRoot.Button_ChangeAvatarForm:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local OwningActor = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
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
  self.UIRoot.Button_ChangeAvatarForm:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self:SetTexture(self.UIRoot.Image_ChangeAvatarForm, Icon, {sync = false})
  self.ChangeAvatarFormCDTimer = self:AddTimerLoop(0, function()
    self:TickChangeAvatarFormCD()
  end, TIMER_INFINITE, 0.2)
end
function QuickExpressionDecalSubPanel:RefreshTransformButton()
  print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshTransformButton")
  if self.ChangeDragonFormCDTimer then
    self:RemoveTimer(self.ChangeDragonFormCDTimer)
    self.ChangeDragonFormCDTimer = nil
  end
  local OwningActor = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if not OwningActor or not slua.isValid(OwningActor) then
    print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshTransformButton OwningActor is invalid")
    return
  end
  local AvatarChangeFormSubsystem = SubsystemMgr:Get("AvatarChangeFormSubsystem")
  if AvatarChangeFormSubsystem then
    local config = AvatarChangeFormSubsystem:CheckChangeFormCondition(OwningActor)
    if config then
      self.UIRoot.Button_Transfiguration:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      local stateCfg = CDataTable.GetTableData("ClothingStateConfig", config.AfterClothID)
      local BattleIcon = stateCfg and stateCfg.BattleIcon
      if BattleIcon then
        self:SetTexture(self.UIRoot.Image_29, BattleIcon)
      elseif config.ActionType == 0 then
        self:SetTexture(self.UIRoot.Image_29, "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_Transfiguration_png.ZD_Icon_Transfiguration_png")
      else
        self:SetTexture(self.UIRoot.Image_29, "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_Transfiguration_02_png.ZD_Icon_Transfiguration_02_png")
      end
      if GlobalData.IsJapanOrKorea() then
        local bUnlock = AvatarChangeFormSubsystem:GetUnlockState(OwningActor)
        if bUnlock then
          self.UIRoot.CanvasPanel_Mask:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          self.UIRoot.Image_lock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        else
          self.UIRoot.CanvasPanel_Mask:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          self.UIRoot.Image_lock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
      else
        self.UIRoot.CanvasPanel_Mask:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.Image_lock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
      self.ChangeDragonFormCDTimer = self:AddTimerLoop(0, function()
        self:TickChangeDragonFormCD()
      end, TIMER_INFINITE, 0.2)
    else
      self.UIRoot.Button_Transfiguration:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    self.UIRoot.Button_Transfiguration:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function QuickExpressionDecalSubPanel:TickChangeDragonFormCD()
  local OwningActor = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
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
  if slua.isValid(self.UIRoot.Image_17) then
    local nMaxTime = AvatarChangeCDObject:GetMaxTime()
    local nCurTime = AvatarChangeCDObject:GetCurrentTime()
    local nProgressRate = nCurTime / nMaxTime
    local ImageMaterial = self.UIRoot.Image_17:GetDynamicMaterial()
    if slua.isValid(ImageMaterial) then
      self.UIRoot.Image_17:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      ImageMaterial:SetScalarParameterValue("Mask_Percent", nProgressRate)
    end
  end
end
function QuickExpressionDecalSubPanel:RefreshPetButton()
  local RetrivePetButton = function()
    local bIsSpecialPet = QuickExpression.CheckIsSpecialPet(self.UIRoot)
    if bIsSpecialPet and self.CurrentShowState == ShowState.PetExpression then
      self.UIRoot.Button_PetFeature:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    else
      self.UIRoot.Button_PetFeature:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  RetrivePetButton()
  self:AddTimerLoop(2, function()
    RetrivePetButton()
  end, 5, 1)
end
function QuickExpressionDecalSubPanel:RefreshXSuitEmoteButton()
  local canShow = QuickExpression.CanShowXSuitEmote(self.UIRoot, self)
  if canShow then
    self.UIRoot.Button_XSuit:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    local action = QuickExpression.GetBornIslandAction(self.UIRoot)
    if action ~= 0 then
      self:SetTexture(self.UIRoot.Image_30, UIUtil.GetItemSmallIcon(action), {sync = false})
    end
  else
    self.UIRoot.Button_XSuit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.CurrentShowState == ShowState.PetExpression then
    self.UIRoot.Button_XSuit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function QuickExpressionDecalSubPanel:TickChangeAvatarFormCD()
  local OwningActor = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
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
  if slua.isValid(self.UIRoot.Image_CDTime) then
    local nMaxTime = AvatarChangeCDObject:GetMaxTime()
    local nCurTime = AvatarChangeCDObject:GetCurrentTime()
    local nProgressRate = nCurTime / nMaxTime
    local ImageMaterial = self.UIRoot.Image_CDTime:GetDynamicMaterial()
    if slua.isValid(ImageMaterial) then
      self.UIRoot.Image_CDTime:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      ImageMaterial:SetScalarParameterValue("Mask_Percent", nProgressRate)
    end
  end
end
function QuickExpressionDecalSubPanel:OnButtonCheckGun()
  self:CloseContent()
  QuickExpression.TryDoCheckGun(self.UIRoot)
end
function QuickExpressionDecalSubPanel:OnButtonChangeAvatarForm()
  self:CloseContent()
  QuickExpression.ChangeAvatarForm(self.UIRoot)
end
function QuickExpressionDecalSubPanel:OnButtonTransfiguration()
  self:CloseContent()
  local state = self.UIRoot.CanvasPanel_Guide2:GetVisibility()
  if state ~= UEnums.ESlateVisibility.Collapsed then
    local AvatarChangeFormSubsystem = SubsystemMgr:Get("AvatarChangeFormSubsystem")
    if AvatarChangeFormSubsystem then
      AvatarChangeFormSubsystem:UpdateGuideState(2)
    end
  end
  self.UIRoot.CanvasPanel_Guide2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local OwningActor = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  local AvatarChangeFormSubsystem = SubsystemMgr:Get("AvatarChangeFormSubsystem")
  if AvatarChangeFormSubsystem then
    AvatarChangeFormSubsystem:TryTransform(OwningActor)
  end
end
function QuickExpressionDecalSubPanel:OnButtonPetFeature()
  self:CloseContent()
  QuickExpression.OnButtonPetFeature(self.UIRoot)
end
function QuickExpressionDecalSubPanel:OnButtonXSuitEmote()
  self:CloseContent()
  QuickExpression.OnButtonXSuitEmote(self.UIRoot, self)
end
function QuickExpressionDecalSubPanel:RefreshPetInfo()
  local PetID, PetLevel = self:GetCurPet()
  local bShowMyPet = self:GetShowMyPet()
  local IsInPetSpectator = false
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.IsInPetSpectator and PlayerController:IsInPetSpectator() then
    IsInPetSpectator = true
  end
  local bNeedUpdate = false
  if self.IsInPetSpectator ~= IsInPetSpectator then
    self.    bNeedUpdate = true
  end
  if bWriteLog then
    print("QuickExpressionDecalSubPanel:RefreshPetInfo", self.PetID, PetID, self.PetLevel, PetLevel, bShowMyPet, bNeedUpdate)
  end
  if self.PetID == PetID and self.PetLevel == PetLevel and bShowMyPet == self.bShowMyPet and not bNeedUpdate then
    return
  end
  self.  self.  self.CurPetExpressionList = {}
  self.  if bWriteLog then
    print("QuickExpressionDecalSubPanel:RefreshPetInfo1", self.PetID, self.PetLevel, self.bShowMyPet)
  end
  if (not self.PetID or self.PetID <= 0 or not self.bShowMyPet) and not bNeedUpdate then
    return
  end
  for _, v in pairs(CDataTable.GetTable("PetActionTable")) do
    if self.PetID == v.PetID then
      print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshPetInfo CanPlayInBattle, " .. v.CanPlayInBattle .. ", " .. tostring(IsInPetSpectator))
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
function QuickExpressionDecalSubPanel:RefreshCollectionList()
  print(bWriteLog and "QuickExpressionDecalSubPanel:RefreshCollectionList", self.bCollectionInited)
  if self.bCollectionInited then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController.PlayEmoteFeature then
    return
  end
  local CollectionEmoteList = PlayerController.PlayEmoteFeature.CollectionList
  if not CollectionEmoteList then
    return
  end
  for Idx, EmoteID in pairs(CollectionEmoteList) do
    table.insert(self.CollectionList, EmoteID)
    IgnoreEmoteConfig[EmoteID] = true
  end
  table.sort(self.CollectionList, function(a, b)
    return a < b
  end)
  self.bCollectionInited = true
end
function QuickExpressionDecalSubPanel:GetCurPet()
  local PlayerController = GameplayData.GetPlayerController()
  if not PlayerController or not slua.isValid(PlayerController) then
    return
  end
  if PlayerController.IsInPetSpectator and PlayerController:IsInPetSpectator() and PlayerController.GetPetSpectatorComp then
    local PlayerPetSpectatorComponent = PlayerController:GetPetSpectatorComp()
    if slua.isValid(PlayerPetSpectatorComponent) and PlayerPetSpectatorComponent.PetSpectatorPawn and PlayerPetSpectatorComponent.PetSpectatorPawn.PetLevelInfo then
      local PetID = PlayerPetSpectatorComponent.PetSpectatorPawn.PetLevelInfo.PetId
      local PetLevel = PlayerPetSpectatorComponent.PetSpectatorPawn.PetLevelInfo.PetLevel
      print(bWriteLog and "QuickExpressionDecalSubPanel:GetCurPet IsInPetSpectator, " .. PetID .. ", " .. PetLevel)
      return PetID, PetLevel
    end
  end
  local uPlayerPawn = PlayerController:GetPlayerCharacterSafety()
  if slua.isValid(uPlayerPawn) and slua.isValid(uPlayerPawn.PetComponent_BP) and slua.isValid(uPlayerPawn.PetComponent_BP.PetPawn) then
    local RealPetPawn = uPlayerPawn.PetComponent_BP.PetPawn
    local PetID = RealPetPawn.PetLevelInfo.PetId
    local PetLevel = RealPetPawn.PetLevelInfo.PetLevel
    print(bWriteLog and "QuickExpressionDecalSubPanel:GetCurPet, " .. PetID .. ", " .. PetLevel)
    return PetID, PetLevel
  end
end
function QuickExpressionDecalSubPanel:ShowChangeFormGuide2()
  print(bWriteLog and "QuickExpressionDecalSubPanel:ShowChangeFormGuide2")
  local OwningActor = STExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self.UIRoot)
  if not OwningActor or not slua.isValid(OwningActor) then
    self.UIRoot.CanvasPanel_Guide2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    print(bWriteLog and "QuickExpressionDecalSubPanel:ShowChangeFormGuide2 OwningActor is invalid")
    return
  end
  local AvatarChangeFormSubsystem = SubsystemMgr:Get("AvatarChangeFormSubsystem")
  if AvatarChangeFormSubsystem then
    local bShow = AvatarChangeFormSubsystem:GetGuideState(OwningActor, 2)
    print(bWriteLog and "QuickExpressionDecalSubPanel:ShowChangeFormGuide2 bShow = " .. tostring(bShow))
    if bShow then
      self.UIRoot.TextBlock_Guide2:SetText(LocUtil.GetLocalizeResStr(49721))
      self.UIRoot.CanvasPanel_Guide2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      AvatarChangeFormSubsystem:UpdateShowGuideNum()
    else
      self.UIRoot.CanvasPanel_Guide2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    self.UIRoot.CanvasPanel_Guide2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function QuickExpressionDecalSubPanel:SetElementVisibility(bNeedShowButtom, bNeedShowDecal)
  print(bWriteLog and "QuickExpressionDecalSubPanel:SetElementVisibility", bNeedShowButtom, bNeedShowDecal)
  if self.bShowBottom ~= bNeedShowButtom or self.bShowDecal ~= bNeedShowDecal then
    self.bShowBottom = bNeedShowButtom
    self.bShowDecal = bNeedShowDecal
    if self.CurrentShowState ~= ShowState.None then
      self:RefreshGridPanel()
    end
  end
end
function QuickExpressionDecalSubPanel:IsAvatarRequirementMatch(RequireAvatarList)
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
function QuickExpressionDecalSubPanel:TryPlayPetExhibitAction()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if PlayerCharacter and slua.isValid(PlayerCharacter) and PlayerCharacter.PetExhibitFeature then
    if PlayerCharacter:AllowState(UEnums.EPawnState.PlayEmote, true) then
      PlayerCharacter.PetExhibitFeature:RPC_Server_CancelPetExhibit()
      self:AddGameTimer(0.5, false, function()
        PlayerCharacter:TriggerEntrySkillWithID(1014668, true)
      end)
    else
      ShowNotice(82212)
    end
  else
    print(bWriteLog and "QuickExpressionDecalSubPanel:PlayPetExhibitAction PlayerCharacter is invalid.")
  end
end
function QuickExpressionDecalSubPanel:CanShowPetBubblePanel()
  local bResult = false
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    bResult = PlayerController.CommerFeature and PlayerController.CommerFeature.bHasPetBubblePrivilege
  end
  log(bWriteLog and "QuickExpressionDecalSubPanel:CanShowPetBubblePanel " .. tostring(bResult))
  return bResult
end
function QuickExpressionDecalSubPanel:OnButtonPetBubble()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonPetBubble " .. self.CurrentShowState)
  if self.CurrentShowState ~= ShowState.PetBubble then
    self.CurrentShowState = ShowState.PetBubble
    self:RefreshGridPanel()
  end
end
function QuickExpressionDecalSubPanel:OnButtonSpectatorPetBubble()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonSpectatorPetBubble " .. self.CurrentShowState)
  if self.CurrentShowState ~= ShowState.SpectatorPetBubble then
    self.CurrentShowState = ShowState.SpectatorPetBubble
    self:RefreshGridPanel()
  end
end
function QuickExpressionDecalSubPanel:RefreshPetBubble()
  log(bWriteLog and "QuickExpressionDecalSubPanel:RefreshPetBubble")
  local PlayerController = GameplayData.GetPlayerController()
  local PetBubbleIDList
  if slua.isValid(PlayerController) then
    PetBubbleIDList = PlayerController.CommerFeature and PlayerController.CommerFeature.PetBubbleIDList
  end
  if PetBubbleIDList then
    local BubbleCount = PetBubbleIDList:Num()
    for Index = 0, BubbleCount - 1 do
      local BubbleItemID = PetBubbleIDList:Get(Index)
      local Item = self:GetQuickExpressionDecalItemByIndex(Index + 1)
      if Item then
        Item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        Item:Show()
        Item:RefreshData(BubbleItemID, -1)
      end
    end
    self:HideRestBlocks(BubbleCount)
  else
    self:HideRestBlocks(0)
  end
end
function QuickExpressionDecalSubPanel:OnClothChange()
  self:RefreshExpression()
  return
end
function QuickExpressionDecalSubPanel:OnButtonMiniTvExpression()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonMiniTvExpression " .. self.CurrentShowState)
  if self.CurrentShowState ~= ShowState.MiniTvExpression then
    self.CurrentShowState = ShowState.MiniTvExpression
    self:RefreshGridPanel()
  end
end
function QuickExpressionDecalSubPanel:PrepareMiniTvExpressionList()
  if self.bInitMiniTvExpressionList then
    return
  end
  self.bInitMiniTvExpressionList = true
  self.MiniTvExpressionList = {}
  local PlayerController = GameplayData.GetPlayerController()
  local MiniTVActionIDList = PlayerController.CommerFeature and PlayerController.CommerFeature.MiniTVActionIDList
  if MiniTVActionIDList then
    for _, v in pairs(MiniTVActionIDList) do
      local MasterSkillID
      local PetActionCfg = CDataTable.GetTableDataByFilter("PetActionTable", "PetActionID", v)
      if PetActionCfg then
        MasterSkillID = PetActionCfg.MasterSkillID
        self.MiniTvExpressionList[#self.MiniTvExpressionList + 1] = {
          ID = v,
          IsLocked = false,
          SortKey = PetActionCfg.SortKey,
                  }
      end
    end
  end
end
function QuickExpressionDecalSubPanel:RefreshMiniTvExpression()
  log(bWriteLog and "QuickExpressionDecalSubPanel:RefreshMiniTvExpression")
  self:RefreshMiniTvShowSwitch()
  self:PrepareMiniTvExpressionList()
  if not self.bShowMiniTv or #self.MiniTvExpressionList <= 0 then
    self:HideRestBlocks(0)
    return
  end
  local EmoteCnt = 0
  for Index, v in pairs(self.MiniTvExpressionList) do
    local Item = self:GetQuickExpressionDecalItemByIndex(Index)
    if Item then
      Item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      Item:Show()
      Item:RefreshData(v.ID, -1, true, v.IsLocked)
      EmoteCnt = EmoteCnt + 1
    end
  end
  self:HideRestBlocks(EmoteCnt)
end
function QuickExpressionDecalSubPanel:RefreshMiniTvShowSwitch()
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  self.bShowMiniTv = SettingModule:GetOptionValue("ShowMiniTvInFighting")
  print(bWriteLog and "QuickExpressionDecalSubPanel:QuickExpressionDecalSubPanel bShowMiniTv:", tostring(self.bShowMiniTv))
  local MiniTvType = self:GetMiniTvType()
  local MiniTvUtil = require("GameLua.Mod.BaseMod.Actor.Pet.MiniTvUtil")
  self.bShowMiniTvExpressionTab = MiniTvType == MiniTvUtil.ENUM_MINITV_TYPE.Standalone
  self.bShowMiniTvBubbleExpression = self.bShowMiniTv and MiniTvType == MiniTvUtil.ENUM_MINITV_TYPE.AttachedToPet
  if self.bShowMiniTvBubbleExpression then
    self.UIRoot.Button_Robot:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    self.UIRoot.Button_Robot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function QuickExpressionDecalSubPanel:OnButtonShowMiniTv()
  print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonShowMiniTv")
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return false
  end
  SettingSubsystem:SetUserSettings_Bool("ShowMiniTvInFighting", true)
end
function QuickExpressionDecalSubPanel:GetMiniTvType()
  print(bWriteLog and "QuickExpressionDecalSubPanel:GetMiniTvType")
  local MiniTvUtil = require("GameLua.Mod.BaseMod.Actor.Pet.MiniTvUtil")
  local MiniTvType = MiniTvUtil.ENUM_MINITV_TYPE.None
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.IsInPetSpectator and PlayerController:IsInPetSpectator() then
    MiniTvType = MiniTvUtil.ENUM_MINITV_TYPE.None
  else
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) and slua.isValid(PlayerCharacter.PetComponent_BP) then
      MiniTvType = PlayerCharacter.PetComponent_BP:GetMiniTvType()
    end
  end
  return MiniTvType
end
function QuickExpressionDecalSubPanel:OnButtonMiniTvBubbleExpression()
  print(bWriteLog and "[mini_tv] QuickExpressionDecalSubPanel:OnButtonMiniTvBubbleExpression")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.IsInPetSpectator and PlayerController:IsInPetSpectator() then
  else
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) and PlayerCharacter.PetExhibitFeature then
      local PetActionID = self:GetRandomUnlockedPetActionID()
      print(bWriteLog and "[mini_tv] OnButtonMiniTvBubbleExpression PetActionID: " .. tostring(PetActionID))
      if not PetActionID then
        IngameTipsTools.BattleNormalTipsByTextID(530002)
        return
      end
      PlayerCharacter.PetExhibitFeature:RPC_Server_ReqMiniTvInteraction(PetActionID)
      local PS = PlayerCharacter.GetPlayerStateSafety and PlayerCharacter:GetPlayerStateSafety()
      if slua.isValid(PS) and PS.RPC_ServerAddGeneralCount then
        print(bWriteLog and "QuickExpressionDecalSubPanel:OnButtonMiniTvBubbleExpression RPC_ServerAddGeneralCount 12024")
        PS:RPC_ServerAddGeneralCount(12024, 1, false)
      else
        print(bWriteLog and "[WARN] QuickExpressionDecalSubPanel:OnButtonMiniTvBubbleExpression RPC_ServerAddGeneralCount 12024 failed")
      end
    end
  end
  self:CloseContent()
end
function QuickExpressionDecalSubPanel:GetRandomUnlockedPetActionID()
  if not self.CurPetExpressionList or not next(self.CurPetExpressionList) then
    self:RefreshPetInfo()
  end
  if not self.CurPetExpressionList or not next(self.CurPetExpressionList) then
    print(bWriteLog and "[mini_tv] GetRandomUnlockedPetActionID: CurPetExpressionList is empty")
    return nil
  end
  local UnlockedActions = {}
  for _, v in pairs(self.CurPetExpressionList) do
    if not v.IsLocked then
      table.insert(UnlockedActions, v.ID)
    end
  end
  if #UnlockedActions <= 0 then
    print(bWriteLog and "[mini_tv] GetRandomUnlockedPetActionID: no unlocked actions")
    return nil
  end
  local RandomIndex = math.random(#UnlockedActions)
  return UnlockedActions[RandomIndex]
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, QuickExpressionDecalSubPanel)