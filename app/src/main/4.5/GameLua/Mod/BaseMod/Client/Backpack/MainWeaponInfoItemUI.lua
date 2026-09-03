local MainWeaponInfoItemUI = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local UEPathUtilityMethods = import("UEPathUtilityMethods")
local UBackpackUtils = import("BackpackUtils")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function MainWeaponInfoItemUI:ctor()
  self.bNeedShowWeaponFeature = false
  self.WeaponFeatureData = nil
  self.bShowingWeaponFeature = false
  self.bHasInitialized = false
  self.bShowFeatureUI = true
  self.RefreshInterval = 0.05
  self.TickTimer = nil
  self.bIsChecked = true
  self.SwitchButton = nil
  self.Text_CD = nil
  self.ModWeaponUI = {}
end
GEnableWeaponACCoreSlot = false
function MainWeaponInfoItemUI:OnInitialize()
  MainWeaponInfoItemUI.__super.OnInitialize(self)
  local UIRoot = self.UIRoot
  UIRoot.CanvasPanel_2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  UIRoot.CanvasPanel_3:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.ModType = GameMainConfig.GetModType()
  self.MapType = GameMainConfig.GetMapType()
  local PlayerLabelHandler = require("client.network.Protocol.PlayerLabelHandler")
  self.bNeedShowWeaponFeature = PlayerLabelHandler.oldplayer_flag ~= true
  print(bWriteLog and "MainWeaponInfoItemUI:OnInitialize PlayerLabelHandler.oldplayer_flag:" .. tostring(PlayerLabelHandler.oldplayer_flag))
  print(bWriteLog and "MainWeaponInfoItemUI:OnInitialize self.bNeedShowWeaponFeature:" .. tostring(self.bNeedShowWeaponFeature))
  self:HideWeaponFeatureData()
  UIRoot.CanvasPanel_Detail:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:InitModWeapon()
end
function MainWeaponInfoItemUI:GetCurrentWeaponItemArray()
  local UIRoot = self.UIRoot
  return {
    UIRoot.FitingSlotItem_BP,
    UIRoot.FitingSlotItem_BP_C_0,
    UIRoot.FitingSlotItem_BP_C_1,
    UIRoot.FitingSlotItem_BP_C_2,
    UIRoot.FitingSlotItem_BP_C_3,
    UIRoot.FitingSlotItem_BP_C_4,
    UIRoot.FitingSlotItem_BP_C_5,
    UIRoot.FitingSlotItem_BP_C_6
  }
end
function MainWeaponInfoItemUI:RegistEvents()
  MainWeaponInfoItemUI.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot.Button_0, "OnPressed", self.OnClickedButton, self)
  self:AddControlEventByControl(self.UIRoot.Button_Detail, "OnPressed", self.OnClickedDetailButton, self)
  self:RegisterWeaponUpgradeEvent()
  self:RegisterModWeaponEvent()
end
function MainWeaponInfoItemUI:RegisterWeaponUpgradeEvent()
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_UPGRADEINFO_CHANGE, self.HandleWeaponUpdateUpgradeInfo, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_UPGRADEINFO_START, self.OnWeaponUpgradeStart, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_SWITCHWEAPON, self.OnWeaponSwitched, self)
  local UIRoot = self.UIRoot
  UIRoot.Image_6:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.MapType == "Livik" then
    UIRoot.Image_SpecialIconBG:SetBrushfromPathAsync("/Game/Mod/Livik/Textures/Livik_icon_XT_02.Livik_icon_XT_02", false)
    UIRoot.Image_SpecialIcon:SetBrushfromPathAsync("/Game/Mod/Livik/Textures/Atlas/Frames/Livik_icon_XT_02_png.Livik_icon_XT_02_png", false)
  end
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "CharacterDataReady", function()
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if not slua.isValid(uPlayerCharacter) then
      return
    end
    local uSkillManager = uPlayerCharacter:GetSkillManager()
    if not slua.isValid(uSkillManager) then
      return
    end
    self:AddControlEventByControl(uSkillManager, "SkillStopEvent", self.HandleOnSkillStop, self)
  end)
end
function MainWeaponInfoItemUI:RegisterModWeaponEvent()
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_MOD_WEAPON_USE_SKIN_COOLDOWN, self.Cooldown, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_MOD_WEAPON_USE_SKIN_COOLDOWN_END, self.OnCooldownEnd, self)
  self:AddControlEventByControl(self.SwitchButton, "OnPressed", self.OnClickedButtonModSkin, self)
end
function MainWeaponInfoItemUI:InitModWeapon()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    self.bIsChecked = PlayerController.bUseModWeaponSkin
  end
  self.SwitchButton = self.UIRoot.Button_1
  self.SwitchButton:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.ProgressBar = self.UIRoot.ProgressBar_Mask
  self.ProgressBar:SetPercent(0)
  self.Text_CD = self.UIRoot.TextBlock_Time
  self.Text_CD:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:SetButtonStatus(self.bIsChecked)
end
function MainWeaponInfoItemUI:SetButtonStatus(bStatus)
  if bStatus then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  end
end
function MainWeaponInfoItemUI:OnClickedButtonModSkin()
  local bUse = not self.bIsChecked
  EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_MOD_WEAPON_USE_SKIN_CLICKED, bUse)
end
function MainWeaponInfoItemUI:Cooldown(_, _, Cooldown)
  if self:CanShowSwitchButton() then
    self.SwitchButton:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  self.bIsChecked = not self.bIsChecked
  self:SetButtonStatus(self.bIsChecked)
  self.TickNum = 0
  self.CooldownTime = Cooldown
  self.TickInterval = math.floor(1 / self.RefreshInterval)
  self.Text_CD:SetText(string.format("%ds", Cooldown))
  self.Text_CD:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  if self.TickTimer then
    self:RemoveGameTimer(self.TickTimer)
    self.TickTimer = nil
  end
  self.TickTimer = self:AddGameTimer(self.RefreshInterval, true, function()
    self:TickCD()
  end)
end
function MainWeaponInfoItemUI:OnCooldownEnd(_, _)
  self.ProgressBar:SetPercent(0)
  self.SwitchButton:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.Text_CD:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:RemoveGameTimer(self.TickTimer)
  self.TickTimer = nil
  if not self:CanShowSwitchButton() then
    self.SwitchButton:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function MainWeaponInfoItemUI:TickCD()
  self.TickNum = self.TickNum + 1
  local RemainTime = self.CooldownTime - self.TickNum / self.TickInterval
  if self.TickNum % self.TickInterval == 0 then
    self.Text_CD:SetText(string.format("%ds", RemainTime))
  end
  local Percent = RemainTime / self.CooldownTime
  self.ProgressBar:SetPercent(Percent)
end
function MainWeaponInfoItemUI:CanShowSwitchButton()
  local ModWeaponConfig = GamePlayTools.GetCurrentConfig("ModWeaponConfig")
  local Weapon = self:GetCurrentWeapon()
  if Weapon then
    local DefineID = Weapon:GetItemDefineID()
    local ItemID = DefineID.TypeSpecificID
    if ModWeaponConfig and ModWeaponConfig[ItemID] then
      local Config = ModWeaponConfig[ItemID]
      if Config.bSwitchModSkin then
        return true
      end
    end
  end
  return false
end
function MainWeaponInfoItemUI:HideSinkSlotVisiblity()
  local UIRoot = self.UIRoot
  UIRoot.FitingSlotItem_BP_C_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  UIRoot.CanvasPanel_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  UIRoot.Image_6:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.DefineID = nil
end
function MainWeaponInfoItemUI:UpdateWeaponUpgradeInfo(Weapon)
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local WeaponUpgradeUI = UIManager.GetUI(UIManager.UI_Config_InGame.WeaponUpgradeUI)
  if WeaponUpgradeUI then
    WeaponUpgradeUI:SetParentAndWeaponID(self, Weapon)
    WeaponUpgradeUI:PlayFinishAnimation()
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local BackpackUI = InGameUITools.GetBackpackUI()
  if BackpackUI and BackpackUI:GetVisibility() == UEnums.ESlateVisibility.Collapsed then
    uPlayerController:DisplayGameTipWithMsgID(37279)
    if WeaponUpgradeUI then
      WeaponUpgradeUI:Hide()
    end
  end
  local UpgradeItem = FItemDefineID(ENUM_ITEM_TYPE.Medicine, Weapon:GetUpgradeInfoID())
  local ShootingUIPanelLuaClass = InGameUITools.GetShootingUIPanelLuaClass()
  if ShootingUIPanelLuaClass then
    ShootingUIPanelLuaClass:ShowWeaponEquipAttachmentAnim(self.WeaponSlot, UpgradeItem, true)
  end
end
function MainWeaponInfoItemUI:UpdateCoreSlot()
  if GEnableWeaponACCoreSlot then
    self.UIRoot.FitingSlotItem_BP_C_6:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    self.UIRoot.FitingSlotItem_BP_C_6:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function MainWeaponInfoItemUI:OnWeaponUpgradeStart(_, _, uPlayer, SkillID, LuaTable, BBLuaTable)
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if uPlayerCharacter ~= uPlayer then
    return
  end
  local SkillSlot = BBLuaTable.WeaponSlot
  local UpgradeItemID = BBLuaTable.UpgradeItemID
  self.UIRoot.Image_6:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:HighLightBG(false)
  local CurrentWeapon = self:GetCurrentWeapon()
  if CurrentWeapon == nil then
    print(bWriteLog and "MainWeaponInfoItemUI:OnWeaponUpgradeStart CheckCurrentWeapon failed", UpgradeItemID, SkillSlot)
    return
  end
  self.SkillLock = true
  local WeaponUpgradeSubSystem = SubsystemMgr:Get("WeaponUpgradeSubSystem")
  if SkillSlot ~= self.WeaponSlot then
    print(bWriteLog and "MainWeaponInfoItemUI:OnWeaponUpgradeStart CheckSlot failed", self.WeaponSlot, SkillSlot, UpgradeItemID, SkillID)
    return
  end
  self.  local WeaponUpgradeUI = UIManager.GetUI(UIManager.UI_Config_InGame.WeaponUpgradeUI)
  WeaponUpgradeUI = WeaponUpgradeUI or UIManager.ShowUI(UIManager.UI_Config_InGame.WeaponUpgradeUI)
  WeaponUpgradeUI:SetParentAndWeaponID(self, CurrentWeapon)
  WeaponUpgradeUI:ShowAnim()
end
function MainWeaponInfoItemUI:OnWeaponUpgradeUIFinished()
  self:InitGunHitInfoTag()
  self:PlayUserWidgetAnimation(self.UIRoot.Anim_Final, 0, 1, 0, 1)
end
function MainWeaponInfoItemUI:InitGunHitInfoTag()
  print(bWriteLog and "MainWeaponInfoItemUI:InitGunHitInfoTag WeaponSlot: " .. self.WeaponSlot)
  local UIRoot = self.UIRoot
  UIRoot.Image_SpecialIconEX:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  UIRoot.Image_SpecialIconBG:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  UIRoot.Image_SpecialIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  UIRoot.CanvasPanel_2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  UIRoot.CanvasPanel_3:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local CurrentWeapon = self:GetCurrentWeapon()
  if not slua.isValid(CurrentWeapon) or not CurrentWeapon.HasUpgrade then
    print(bWriteLog and "MainWeaponInfoItemUI:InitGunHitInfoTag CheckCurrentWeapon failed WeaponSlot:" .. self.WeaponSlot)
    return
  end
  if not CurrentWeapon:HasUpgrade() then
    return
  end
  print(bWriteLog and "MainWeaponInfoItemUI:InitGunHitInfoTag CurrentWeapon:HasUpgrade WeaponSlot: " .. self.WeaponSlot)
  UIRoot.CanvasPanel_2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  UIRoot.CanvasPanel_3:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  UIRoot.Image_SpecialIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  UIRoot.Image_SpecialIconBG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function MainWeaponInfoItemUI:HighLightUpgradeWeapon(DefineID)
  self.DefineID = nil
  if not DefineID then
    return
  end
  if DefineID.Type ~= 6 then
    return
  end
  if self.SkillLock then
    return
  end
  local CurrentWeapon = self:GetCurrentWeapon()
  if not slua.isValid(CurrentWeapon) then
    return
  end
  local WeaponUpgradeSubSystem = SubsystemMgr:Get("WeaponUpgradeSubSystem")
  if WeaponUpgradeSubSystem:IsUpgradeValid(CurrentWeapon, DefineID.TypeSpecificID) then
    self.DefineID = DefineID:clone()
    self.UIRoot.Image_6:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:HighLightBG(true)
  end
end
function MainWeaponInfoItemUI:OnClickedButton()
  if not self.DefineID then
    return
  end
  local CurrentWeapon = self:GetCurrentWeapon()
  if not slua.isValid(CurrentWeapon) then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(uPlayerController) then
    return
  end
  local FBattleItemUseTarget = import("BattleItemUseTarget")
  local UseTarget = FBattleItemUseTarget()
  UseTarget.TargetDefineID = CurrentWeapon:GetItemDefineID()
  uPlayerController:ServerUseItem(self.DefineID, UseTarget, 1)
end
function MainWeaponInfoItemUI:OnClickedDetailButton()
  if self.bShowFeatureUI then
    self:HideWeaponFeatureData()
  else
    self:ShowWeaponFeatureData()
  end
  self.bShowFeatureUI = not self.bShowFeatureUI
end
function MainWeaponInfoItemUI:ResetUpgradeWeapon()
  self.UIRoot.Image_6:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:HighLightBG(false)
  self.DefineID = nil
end
function MainWeaponInfoItemUI:HandleWeaponUpdateUpgradeInfo(_, _, Weapon)
  if Weapon == self:GetCurrentWeapon() then
    self:UpdateWeaponUpgradeInfo(Weapon)
    self:ResetUpgradeWeapon()
  end
  self.DefineID = nil
  self.SkillID = nil
  self.SkillLock = false
end
function MainWeaponInfoItemUI:HandleOnSkillStop(SkillID, StopReason)
  print(bWriteLog and "MainWeaponInfoItemUI:HandleOnSkillStop SkillID=" .. SkillID .. " StopReason:" .. StopReason)
  if SkillID == self.SkillID then
    local WeaponUpgradeUI = UIManager.GetUI(UIManager.UI_Config_InGame.WeaponUpgradeUI)
    if WeaponUpgradeUI then
      WeaponUpgradeUI:HideByInterrupt()
    end
    self.SkillID = nil
  end
  self.SkillLock = false
end
function MainWeaponInfoItemUI:InterruptCurrentUpgrade()
  if not self.SkillID then
    return
  end
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    return
  end
  local uSkillManager = uPlayerCharacter:GetSkillManager()
  if not slua.isValid(uSkillManager) then
    return
  end
  local UTSkillStopReason = import("UTSkillStopReason")
  uSkillManager:StopSkill(self.SkillID, UTSkillStopReason.SkillStopReason_Interrupted)
end
function MainWeaponInfoItemUI:OnWeaponSwitched(_, _, PlayerKey)
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if PlayerKey ~= uPlayerController.PlayerKey then
    return
  end
  self:InterruptCurrentUpgrade()
end
function MainWeaponInfoItemUI:CheckIsAvatarItemIconExists(AvatarItemID)
  local ItemPathExist = false
  local AvatarItemData = CDataTable.GetTableData("Item", AvatarItemID)
  if AvatarItemData then
    if Client.IsJaguar() then
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {AvatarItemID})
      if state == PufferConst.ENUM_DownloadState.Done then
        ItemPathExist = true
      end
    else
      ItemPathExist = UEPathUtilityMethods.IsAvatarResPathExist(AvatarItemData.ItemSmallIcon)
    end
  end
  return ItemPathExist
end
function MainWeaponInfoItemUI:GetWeaponInfoName()
  return "parentWeaponInfo"
end
function MainWeaponInfoItemUI:UpdateWeaponAppearanceInfo(TypeSpecificID, BattleData, DragOrigin)
  MainWeaponInfoItemUI.__super.UpdateWeaponAppearanceInfo(self, TypeSpecificID, BattleData, DragOrigin)
  local ItemData = CDataTable.GetTableData("Item", TypeSpecificID)
  local UIRoot = self.UIRoot
  UIRoot.CanvasPanel_Detail:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if TypeSpecificID == 0 or not ItemData then
    UIRoot.CanvasPanel_2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    UIRoot.CanvasPanel_3:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    UIRoot.Text_Undownload:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    UIRoot.Button_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:HideWeaponFeatureData()
    self:UpdateKillCounter(false)
  else
    local IsBattleItemHandleExist = false
    local BackPackFunctionLibrary = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
    local LogicUserBattleDataManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicUserBattleDataManager)
    local WeaponIDOrAvatarID, DIYPlanID = BackPackFunctionLibrary.GetWeaponAvatarRes(TypeSpecificID, self.BattleData.AdditionalData)
    if WeaponIDOrAvatarID then
      local WeaponAvatarData = CDataTable.GetTableData("Item", WeaponIDOrAvatarID)
      local ItemDefineID = FItemDefineID(WeaponAvatarData.ItemType, WeaponIDOrAvatarID)
      IsBattleItemHandleExist = UBackpackUtils.IsBattleItemHandleExist(ItemDefineID, true, false, false)
    end
    if IsBattleItemHandleExist and LogicUserBattleDataManager:HasBigIconDownloaded(WeaponIDOrAvatarID) then
      UIRoot.Text_Undownload:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      UIRoot.Text_Undownload:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      UIRoot.Text_Undownload:SetText(LocUtil.LocalizeResFormat(756099))
    end
    UIRoot.Button_0:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
    print(bWriteLog and "MainWeaponInfoItemUI:UpdateWeaponAppearanceInfo self.ModType:" .. self.ModType)
    if self.ModType and not BackpackConfig.tHideWeaponFeatureMods[self.ModType] then
      self.WeaponFeatureData = CDataTable.GetTableData("WeaponFeature", TypeSpecificID)
      if self.WeaponFeatureData then
        if self.bNeedShowWeaponFeature then
          self:ShowWeaponFeatureDesc(true)
        else
          self:ShowWeaponFeatureDesc(false)
        end
      else
        self:HideWeaponFeatureData()
      end
    else
      self:HideWeaponFeatureData()
    end
    self:UpdateKillCounter(true)
  end
  self:UpdateModWeaponUI(TypeSpecificID)
end
function MainWeaponInfoItemUI:UpdateModWeaponUI(TypeSpecificID)
  if self:CanShowSwitchButton() then
    self.SwitchButton:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    self.SwitchButton:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  for ItemID, ModWeaponLabel in pairs(self.ModWeaponUI) do
    if ModWeaponLabel and ItemID ~= TypeSpecificID then
      ModWeaponLabel:Close()
      self.ModWeaponUI[ItemID] = nil
    end
  end
  local ModWeaponConfig = GamePlayTools.GetCurrentConfig("ModWeaponConfig")
  if ModWeaponConfig and ModWeaponConfig[TypeSpecificID] and ModWeaponConfig[TypeSpecificID].LabelUIConfig then
    if not self.ModWeaponUI[TypeSpecificID] then
      self.ModWeaponUI[TypeSpecificID] = nil
    end
    local ModWeaponLabel = self.ModWeaponUI[TypeSpecificID]
    if ModWeaponLabel then
      ModWeaponLabel:HitTestInvisible()
    else
      local WeaponConfig = ModWeaponConfig[TypeSpecificID]
      local LabelUIConfig = WeaponConfig.LabelUIConfig
      local ModLabelCanvas = self.UIRoot.CanvasPanel_ModTitle
      if LabelUIConfig and ModLabelCanvas then
        local LabelConfig = UIManager.UI_Config_InGame[LabelUIConfig]
        if LabelConfig then
          ModWeaponLabel = self:CreateChildWindow(ModLabelCanvas, LabelConfig, 3)
          self.ModWeaponUI[TypeSpecificID] = ModWeaponLabel
        end
      end
    end
  end
end
function MainWeaponInfoItemUI:UpdateKillCounter(bShow)
  local KillCounterUISubsystem = SubsystemMgr:Get("KillCounterUISubsystem")
  if not KillCounterUISubsystem or not KillCounterUISubsystem:CheckSupportKCUI() then
    bShow = false
  end
  if bShow then
    local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
    local curEquipedKillCounter = LogicKillCounter:GetMyEquipedKillCounterId(self.ItemID)
    if not curEquipedKillCounter then
      self.UIRoot.CanvasPanel_KillCounter:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
      return
    end
    if not self.KillCounterUI then
      self.KillCounterUI = UIManager.ShowUI(UIManager.UI_Config_InGame.MainWeaponKillCounter, self.ItemID, self.WeaponIDOrAvatarID, self)
      self.UIRoot.CanvasPanel_KillCounter.Slot:SetLayer(1)
    else
      self.KillCounterUI:UpdateWeaponID(self.ItemID, self.WeaponIDOrAvatarID)
    end
    self.UIRoot.CanvasPanel_KillCounter:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.CanvasPanel_KillCounter:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
end
function MainWeaponInfoItemUI:ShowWeaponFeatureDesc(bIsNewPlayer)
  if not self.WeaponFeatureData then
    print(bWriteLog and "MainWeaponInfoItemUI:ShowWeaponFeatureByWeaponID self.WeaponFeatureData invalid self.ItemID:" .. tostring(self.ItemID))
    return
  end
  local UIRoot = self.UIRoot
  if self.bShowFeatureUI then
    self:ShowWeaponFeatureData()
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_WEAPONDETIAL_BACKPACK_WeaponFeature_HAS_SHOWED)
  else
    self:HideWeaponFeatureData()
  end
  UIRoot.CanvasPanel_Detail:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local nFeatureNums = self.WeaponFeatureData.WeaponFeatureIDList_a:Num()
  local CurFeatureIDList = self.WeaponFeatureData.WeaponFeatureIDList_a
  if not bIsNewPlayer and self.WeaponFeatureData.WeaponFeatureIDList2_a then
    CurFeatureIDList = self.WeaponFeatureData.WeaponFeatureIDList2_a
    nFeatureNums = self.WeaponFeatureData.WeaponFeatureIDList2_a:Num()
  end
  if nFeatureNums ~= 0 then
    self.UIRoot.Text_Undownload.Slot:SetPadding(FMargin(25, 40 + nFeatureNums * 25, 0, 0))
  else
    self.UIRoot.Text_Undownload.Slot:SetPadding(FMargin(25, 90, 0, 0))
  end
  for nIndex = 1, 4 do
    local WeaponFeatureDescItem = UIRoot["WeaponFeatureDescItem" .. nIndex]
    if WeaponFeatureDescItem then
      if nIndex < nFeatureNums + 1 then
        local nWeaponFeatureID = CurFeatureIDList:Get(nIndex - 1)
        WeaponFeatureDescItem:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
        WeaponFeatureDescItem.TextBlock_WeaponFeatureDesc:SetText(LocUtil.LocalizeResFormat(nWeaponFeatureID))
        local FeatureColorData = CDataTable.GetTableData("WeaponFeatureColor", nWeaponFeatureID)
        if FeatureColorData then
          local Color = self:StrToColor(FeatureColorData.FeatureColor)
          WeaponFeatureDescItem.Image_BG:SetColorAndOpacity(Color)
        end
      else
        WeaponFeatureDescItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
end
function MainWeaponInfoItemUI:HideWeaponFeatureData()
  local UIRoot = self.UIRoot
  UIRoot.Vertical_WeaponFeature:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  UIRoot.Image_Detail:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
end
function MainWeaponInfoItemUI:ShowWeaponFeatureData()
  local UIRoot = self.UIRoot
  UIRoot.Vertical_WeaponFeature:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  UIRoot.Image_Detail:SetColorAndOpacity(FLinearColor(0.905882, 0.521569, 0.082353, 1))
end
function MainWeaponInfoItemUI:StrToColor(colorStr)
  if not colorStr then
    return FLinearColor(0.2, 0.2, 0.2, 1)
  end
  if not string.find(colorStr, "{") and not string.find(colorStr, "}") then
    colorStr = "{" .. colorStr .. "}"
  end
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local colorVector = GamePlayTools.StrToTable(colorStr)
  local r = colorVector[1] and colorVector[1] / 255 or 0
  local g = colorVector[2] and colorVector[2] / 255 or 0
  local b = colorVector[3] and colorVector[3] / 255 or 0
  local a = colorVector[4] and colorVector[4] / 255 or 1
  return FLinearColor(r, g, b, a)
end
function MainWeaponInfoItemUI:ShowBezelTips(nSocketType)
  print(bWriteLog and "MainWeaponInfoItemUI:ShowBezelTips nSocketType" .. nSocketType)
  local WeaponBezelInfoUI = UIManager.GetUI(UIManager.UI_Config_InGame.WeaponBezelInfoUI)
  if not WeaponBezelInfoUI then
    WeaponBezelInfoUI = UIManager.ShowUI(UIManager.UI_Config_InGame.WeaponBezelInfoUI, self.WeaponSlot, nSocketType)
  else
    WeaponBezelInfoUI:SetWeaponSlot(self.WeaponSlot, nSocketType)
  end
  return WeaponBezelInfoUI
end
function MainWeaponInfoItemUI:OnClose()
  print(bWriteLog and "MainWeaponInfoItemUI:OnClose")
  MainWeaponInfoItemUI.__super.OnClose(self)
  if self.KillCounterUI then
    self.KillCounterUI:Close()
    self.KillCounterUI = nil
  end
  for ItemID, WeaponUI in pairs(self.ModWeaponUI) do
    if WeaponUI then
      WeaponUI:Close()
    end
  end
  self.ModWeaponUI = nil
end
local class = require("class")
local WeaponInfoItemBase = require("GameLua.Mod.BaseMod.Client.Backpack.WeaponInfoItemBase")
return class(WeaponInfoItemBase, nil, MainWeaponInfoItemUI)