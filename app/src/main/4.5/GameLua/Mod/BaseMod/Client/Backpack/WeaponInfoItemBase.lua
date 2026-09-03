local WeaponInfoItemBase = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local UBackpackUtils = import("BackpackUtils")
local UAvatarUtils = import("AvatarUtils")
local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
local AvatarDIYUtils = import("AvatarDIYUtils")
local ScriptHelperClient = import("ScriptHelperClient")
local UEPathUtilityMethods = import("UEPathUtilityMethods")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local EWeaponAttachmentSocketType = import("EWeaponAttachmentSocketType")
local EBattleItemAdditionalDataType = import("EBattleItemAdditionalDataType")
function WeaponInfoItemBase:ctor()
  self.WeaponSlot = 0
end
function WeaponInfoItemBase:OnInitialize()
  print(bWriteLog and "WeaponInfoItemBase:OnInitialize")
  self:InitItemArray()
  for _, ArrayElement in pairs(self.SlotItemArray) do
    ArrayElement[self:GetWeaponInfoName()] = self.UIRoot
    ArrayElement.TextBlock_FittingName:SetColorAndOpacity(FSlateColor(FLinearColor(1.0, 1.0, 1.0, 0.47)))
    self:AddControlEventByControl(ArrayElement, "ItemBeDragBegin", self.FittingItemBeDragBegin, self)
    self:AddControlEventByControl(ArrayElement, "ItemBeDragCancel", self.FittingItemBeDragCancel, self)
  end
  local UIRoot = self.UIRoot
  UIRoot.TextBlock_WeaponName:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  UIRoot.Image_WeaponIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  UIRoot.FitingSlotItem_Bullet_BP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function WeaponInfoItemBase:RegistEvents()
  self:AddControlEventByControl(self.UIRoot, "OnTouchStartedImplementation", self.OnTouchStarted, self)
  self:AddControlEventByControl(self.UIRoot, "OnTouchEndedImplementation", self.OnTouchEnded, self)
  self:AddControlEventByControl(self.UIRoot, "OnDragDetectedImplementation", self.OnDragDetected, self)
end
function WeaponInfoItemBase:FittingItemBeDragBegin(ItemData, DragOrigin)
  self.UIRoot.ItemBeDragBegin:BroadCast(ItemData, DragOrigin)
end
function WeaponInfoItemBase:FittingItemBeDragCancel()
  self.UIRoot.ItemBeDragCancelled:BroadCast()
end
function WeaponInfoItemBase:OnDragCancelled(PointerEvent, Operation)
  self.UIRoot.ItemBeDragCancelled:BroadCast()
end
function WeaponInfoItemBase:OnDragDetected()
  local UIRoot = self.UIRoot
  if self.bHasStartedTouchIn and self.BattleData and self.BattleData.DefineID.TypeSpecificID ~= 0 then
    UIRoot.ItemBeDragBegin:BroadCast(self.BattleData, self.DragOrigin)
    local BackPackDragWidget = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName("/Game/BluePrints/ControlInput/MainBackPackUI/Item/BackPackDragWidget_BP.BackPackDragWidget_BP_C", self.UIRoot)
    BackPackDragWidget:SetPic(UIRoot.Image_WeaponIcon.Brush)
    UIRoot.OnDragDetectedResult = UIRoot:CreateDragDropOpt(BackPackDragWidget, self.BattleData, self.DragOrigin, EBattleItemAdditionalDataType.None)
  else
    UIRoot.OnDragDetectedResult = nil
  end
end
function WeaponInfoItemBase:InitItemArray()
  self.SlotItemArray = {}
  local tSlotItems = self:GetCurrentWeaponItemArray()
  for nSlotIndex, uSlotBluePrint in pairs(tSlotItems) do
    local SlotItemUI = require(GamePlayTools.GetModPath(true, "Client.Backpack.FittingSlotItemUI", true))()
    SlotItemUI:InitWithWidget(uSlotBluePrint)
    self.SlotItemArray[#self.SlotItemArray + 1] = SlotItemUI
  end
end
function WeaponInfoItemBase:GetCurrentWeaponItemArray()
  print(bWriteLog and "WeaponInfoItemBase:GetCurrentWeaponItemArray error, Need Check override")
  return {}
end
function WeaponInfoItemBase:OnTouchStarted(MyGeometry, InTouchEvent)
  self.bHasStartedTouchIn = true
  self:HighLightBG(true)
end
function WeaponInfoItemBase:HighLightBG(IsHighLight)
  if IsHighLight and self.BattleData and self.BattleData.DefineID.TypeSpecificID ~= 0 then
    self.UIRoot.Image_SelectedStatus:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Image_SelectedStatus:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function WeaponInfoItemBase:UpdateWeaponAppearanceInfo(TypeSpecificID, BattleData, DragOrigin)
  print(bWriteLog and "WeaponInfoItemBase:UpdateWeaponAppearanceInfo TypeSpecificID:" .. TypeSpecificID)
  local BattleDataTemp = BattleData:clone()
  self.BattleData = BattleDataTemp
  self.UIRoot.BattleData = BattleDataTemp
  self.  self.UIRoot.  self.TypeSpecificIDTemp = TypeSpecificID
  self.ItemID = TypeSpecificID
  self.UIRoot.ItemID = TypeSpecificID
  local UIRoot = self.UIRoot
  UIRoot.BulletBox:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  UIRoot.WeaponDurabilityBox:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local ItemData = CDataTable.GetTableData("Item", TypeSpecificID)
  if TypeSpecificID == 0 or not ItemData then
    print(bWriteLog and string.format("WeaponInfoItemBase:UpdateWeaponAppearanceInfo TypeSpecificID ==0 or not ItemData WeaponSlot:%s", tostring(self.WeaponPropSlot)))
    UIRoot.Image_WeaponIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:UpdateWeaponAttachment()
    UIRoot.Image_BlankMainSlot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Quality = 0
    self:UpdateQuality()
    UIRoot.TextBlock_WeaponName:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    UIRoot.Image_BlankMainSlot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Quality = ItemData.ItemQuality or 0
    self:UpdateQuality()
    UIRoot.Image_WeaponIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    local BackPackFunctionLibrary = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
    local WeaponIDOrAvatarID, DIYPlanID = BackPackFunctionLibrary.GetWeaponAvatarRes(TypeSpecificID, BattleDataTemp.AdditionalData)
    UIRoot.TextBlock_WeaponName:SetText(ItemData.ItemName)
    UIRoot.TextBlock_WeaponName:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.WeaponIDOrAvatarID = WeaponIDOrAvatarID or 0
    self:InitGunHitInfoTag()
    local WeaponAvatarData = CDataTable.GetTableData("Item", WeaponIDOrAvatarID)
    local SetAvatarIcon = false
    if AvatarDIYUtils.IsWeaponDIYAvatarItem(WeaponIDOrAvatarID) then
      print(bWriteLog and "WeaponInfoItemBase:UpdateWeaponAppearanceInfo IsWeaponDIYAvatarItem true WeaponIDOrAvatarID:" .. WeaponIDOrAvatarID)
      local uPlayerCharacter = GameplayData.GetPlayerCharacter()
      if slua.isValid(uPlayerCharacter) then
        local WeaponDIYIconPath = ScriptHelperClient.GetWeaponDIYIconPath(uPlayerCharacter.PlayerUID, WeaponIDOrAvatarID, tostring(WeaponIDOrAvatarID) .. "-" .. DIYPlanID, false, 512, 256)
        print(bWriteLog and "WeaponInfoItemBase:UpdateWeaponAppearanceInfo WeaponDIYIconPath:" .. WeaponDIYIconPath)
        if WeaponDIYIconPath and ScriptHelperClient.GetFileSizeOnDisk(WeaponDIYIconPath) >= 1 then
          local LoadTexture = import("LoadTexture")
          local texture = LoadTexture.GetTexture2DFromDiskFile(WeaponDIYIconPath)
          if texture and slua.isValid(texture) then
            SetAvatarIcon = true
            UIRoot.Image_WeaponIcon:SetBrushFromTexture(texture, false)
          end
        end
      end
    end
    print(bWriteLog and "WeaponInfoItemBase:UpdateWeaponAppearanceInfo 22", SetAvatarIcon)
    if not SetAvatarIcon and WeaponAvatarData then
      local LogicUserBattleDataManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicUserBattleDataManager)
      local IsAvatarResPathExist = LogicUserBattleDataManager:HasBigIconDownloaded(WeaponIDOrAvatarID)
      if IsAvatarResPathExist then
        SetAvatarIcon = true
        print(bWriteLog and "WeaponInfoItemBase:UpdateWeaponAppearanceInfo 33", WeaponAvatarData.ItemBigIcon)
        UIRoot.Image_WeaponIcon:SetBrushFromPathAsync(WeaponAvatarData.ItemBigIcon, false)
      end
    end
    if not SetAvatarIcon then
      print(bWriteLog and "WeaponInfoItemBase:UpdateWeaponAppearanceInfo 44", ItemData.ItemBigIcon)
      UIRoot.Image_WeaponIcon:SetBrushFromPathAsync(ItemData.ItemBigIcon, false)
    end
    self:BindWeaponChangeEvent()
    self:UpdateBullet()
    self:UpdateWeaponDurability()
    self:UpdateWeaponAttachment()
  end
end
function WeaponInfoItemBase:UpdateWeaponAttachment()
  self:UpdateSlotVisibility()
  print(bWriteLog and "WeaponInfoItemBase:UpdateWeaponAttachment WeaponSlot:" .. self.WeaponSlot)
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  for ArrayIndex, ArrayElement in pairs(slua.IndexReference(self.BattleData, "Associations")) do
    local AssociationTargetDefineID = slua.IndexReference(ArrayElement, "AssociationTargetDefineID"):clone()
    if ArrayElement.AssociationName ~= "Parent" and AssociationTargetDefineID.Type == 2 then
      local TypeSpecificID = AssociationTargetDefineID.TypeSpecificID
      local ItemTableData = CDataTable.GetTableData("Item", TypeSpecificID)
      if ItemTableData and ItemTableData.ItemSubType ~= 418 then
        local Socket = UBackpackUtils.getSocketByAttachResID(TypeSpecificID)
        if BackpackConfig.SlotNameList[Socket] then
          self.SlotItemArray[BackpackConfig.Socket2Index[Socket]]:UpdateSlotItem(TypeSpecificID, AssociationTargetDefineID, self.DragOrigin, EBattleItemAdditionalDataType.None)
        end
      end
    end
  end
  self:UpdateWeaponDefaultAttachment()
end
function WeaponInfoItemBase:UpdateSlotVisibility()
  print(bWriteLog and "WeaponInfoItemBase:UpdateSlotVisibility WeaponSlot:" .. self.WeaponSlot)
  for _, tSlotItem in pairs(self.SlotItemArray) do
    tSlotItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  local nItemID = slua.IndexReference(self.BattleData, "DefineID").TypeSpecificID
  if nItemID ~= 0 then
    local BRSupportSocketList = UAvatarUtils.GetWeaponSupportSocket(self.ItemID)
    for _, nBRSupportSocketIndex in pairs(BRSupportSocketList) do
      local nBRSlotNameID = BackpackConfig.SlotNameList[nBRSupportSocketIndex]
      if nBRSlotNameID then
        local BRSlotItem = self.SlotItemArray[BackpackConfig.Socket2Index[nBRSupportSocketIndex]]
        if BRSlotItem then
          BRSlotItem:ResetSlotIcon(false, nBRSupportSocketIndex, nBRSlotNameID, BackpackConfig.SlotChatText[nBRSupportSocketIndex], self)
        end
        if nBRSupportSocketIndex == EWeaponAttachmentSocketType.ACCore then
          self:UpdateCoreSlot()
        end
      end
    end
  end
end
function WeaponInfoItemBase:UpdateCoreSlot()
  print(bWriteLog and "WeaponInfoItemBase:UpdateCoreSlot, Need Check override")
end
function WeaponInfoItemBase:InitGunHitInfoTag()
  print(bWriteLog and "WeaponInfoItemBase:InitGunHitInfoTag, Need Check override")
end
function WeaponInfoItemBase:GetCurrentWeapon()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) or not slua.isValid(uPlayerCharacter:GetWeaponManager()) then
    print(bWriteLog and "MainWeaponInfoItemUI:GetCurrentWeapon failed, uPlayerCharacter or WeaponManager is not valid")
    return
  end
  local uWeaponManager = uPlayerCharacter:GetWeaponManager()
  return uWeaponManager:GetInventoryWeaponByPropSlot(self.WeaponSlot)
end
function WeaponInfoItemBase:UpdateWeaponDefaultAttachment()
  if not self.bShowDefaultAttachment then
    return
  end
  print(bWriteLog and "WeaponInfoItemBase:UpdateWeaponDefaultAttachment WeaponSlot: " .. self.WeaponSlot)
  local nCurWeaponID = self.BattleData.DefineID.TypeSpecificID
  local nCurWeaponBPID = UBackpackUtils.GetBPIDByResID(nCurWeaponID)
  local uCurWeaponDefaultAttachmentList = slua.Array(UEnums.EPropertyClass.Int)
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  uCurWeaponDefaultAttachmentList = UAvatarUtils.GetWeaponAvatarDefaultAttachment(nCurWeaponBPID, uCurWeaponDefaultAttachmentList, false)
  local tCurWeaponAttachmentSocket2ID = {}
  for index = 1, self.BattleData.Associations:Num() do
    local uItemAssociation = self.BattleData.Associations:Get(index - 1)
    if uItemAssociation.AssociationName ~= "Parent" and uItemAssociation.AssociationTargetDefineID.Type == 2 then
      local nAttachmentID = uItemAssociation.AssociationTargetDefineID.TypeSpecificID
      local nAttachmentSocket = UBackpackUtils.getSocketByAttachResID(nAttachmentID)
      tCurWeaponAttachmentSocket2ID[nAttachmentSocket] = nAttachmentID
    end
  end
  local ItemDefineID = FItemDefineIDDefault()
  for index = 1, uCurWeaponDefaultAttachmentList:Num() do
    local nAttachmentID = uCurWeaponDefaultAttachmentList:Get(index - 1)
    if 0 < nAttachmentID then
      local nSocket = UBackpackUtils.getSocketByAttachResID(nAttachmentID)
      if tCurWeaponAttachmentSocket2ID[nSocket] == nil then
        if BackpackConfig.Socket2Index[nSocket] and 0 <= BackpackConfig.Socket2Index[nSocket] then
          local uSlotItemUI = self.SlotItemArray[BackpackConfig.Socket2Index[nSocket]]
          if uSlotItemUI then
            ItemDefineID.Type = 2
            ItemDefineID.TypeSpecificID = nAttachmentID
            uSlotItemUI:SetEnableFitingSlot(false)
            uSlotItemUI:UpdateSlotItem(nAttachmentID, ItemDefineID, self.DragOrigin, EBattleItemAdditionalDataType.None)
          end
        end
      elseif BackpackConfig.Socket2Index[nSocket] and 0 <= BackpackConfig.Socket2Index[nSocket] then
        local uSlotItemUI = self.SlotItemArray[BackpackConfig.Socket2Index[nSocket]]
        if uSlotItemUI then
          uSlotItemUI:SetEnableFitingSlot(true)
        end
      end
    end
  end
end
function WeaponInfoItemBase:SetBackpackShowDefaultAttachment(bShow)
  self.bShowDefaultAttachment = bShow
end
function WeaponInfoItemBase:OnTouchEnded(MyGeometry, MouseEvent)
  if self.bHasStartedTouchIn then
    self.bHasStartedTouchIn = false
    self:HighLightBG(false)
    self.UIRoot.ItemBeClicked:BroadCast()
    EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_WEAPON_ITEM_CLICKED, self.TypeSpecificIDTemp, self.BattleData)
  end
  local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
  local Handle = WidgetBlueprintLibrary.Handled()
  local Replay = WidgetBlueprintLibrary.ReleaseMouseCapture(Handle)
  return Replay
end
function WeaponInfoItemBase:HighLightAttachSlot(defineID)
  local highDefineID = defineID
  local IsGunSupportAttachByRes = UAvatarUtils.IsGunSupportAttachByRes(highDefineID.TypeSpecificID, self.ItemID or 0, false, EWeaponAttachmentSocketType.GunPoint)
  local BackpackConfig = GamePlayTools.GetCurrentConfig("BackpackConfig")
  if IsGunSupportAttachByRes then
    local Socket = UBackpackUtils.getSocketByAttachResID(highDefineID.TypeSpecificID)
    local IsWeaponAttachSocketEnable = UAvatarUtils.IsWeaponAttachSocketEnable(self.ItemID, Socket)
    if IsWeaponAttachSocketEnable and BackpackConfig.SlotNameList[Socket] then
      self.SlotItemArray[BackpackConfig.Socket2Index[Socket]]:HighLightSocket(true, highDefineID)
    end
  end
end
function WeaponInfoItemBase:ResetHighLightAttachSlot()
  local ItemDefineID = FItemDefineIDDefault()
  for ArrayIndex, ArrayElement in pairs(self.SlotItemArray) do
    ArrayElement:HighLightSocket(false, ItemDefineID)
  end
  local UIRoot = self.UIRoot
  UIRoot.FitingSlotItem_Bullet_BP:HighLightSocket(false, ItemDefineID)
  UIRoot.CanvasPanel_FobbidenReloadTips:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
end
function WeaponInfoItemBase:UpdateUsingSlot(slot)
  self.WeaponPropSlot = slot
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if Game:IsValid(uPlayerCharacter) then
    local WeaponManager = uPlayerCharacter:GetWeaponManager()
    local ShieldWeaponSlot = WeaponManager:GetShieldWeaponSlot()
    if WeaponManager:GetCurrentUsingPropSlot() == slot or WeaponManager:GetPropSlotByLogicSocket(ShieldWeaponSlot) == slot then
      self.UIRoot.TextBlock_UsingTips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.TextBlock_UsingTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function WeaponInfoItemBase:UpdateBullet()
  local UIRoot = self.UIRoot
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not Game:IsValid(uPlayerCharacter) then
    return
  end
  local uWeapon = self:GetCurrentWeapon()
  if not Game:IsValid(uWeapon) then
    print(bWriteLog and "WeaponInfoItemBase:UpdateBullet Error, uWeapon is not valid")
    return
  end
  UIRoot.BulletBox:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  if uWeapon:GetReloadWithNoCostFromEntity() then
    UIRoot.TextBlock_CurrentNumberOfBullets:SetText(tostring(uWeapon:GetCurrentBulletNumInClip(0)))
  else
    UIRoot.TextBlock_CurrentNumberOfBullets:SetText(tostring(uWeapon:GetCurrentBulletNumInClip(0)))
  end
  local WeaponEntityComp = uWeapon.WeaponEntityComp
  if Game:IsValid(WeaponEntityComp) then
    local uBackpackComponent = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(uPlayerCharacter)
    if Game:IsValid(uBackpackComponent) then
      local AvailableBulletsNumInBackpackByDefineID = UAvatarUtils.GetAvailableBulletsNumInBackpackByDefineID(uBackpackComponent, WeaponEntityComp.BulletType)
      if uWeapon:GetReloadWithNoCostFromEntity() then
        UIRoot.TextBlock_MaxNumberOfBullets:SetText("\226\136\158")
      else
        UIRoot.TextBlock_MaxNumberOfBullets:SetText(tostring(AvailableBulletsNumInBackpackByDefineID))
      end
      local TypeSpecificID = 0
      if WeaponEntityComp.BulletType and WeaponEntityComp.BulletType.TypeSpecificID then
        TypeSpecificID = WeaponEntityComp.BulletType.TypeSpecificID
      end
      if TypeSpecificID ~= 0 then
        local BulletItemTable = CDataTable.GetTableData("Item", TypeSpecificID)
        if BulletItemTable then
          UIRoot.TextBlock_BulletName:SetText(BulletItemTable.ItemName)
        else
          print(bWriteLog and string.format("WeaponInfoItemBase:UpdateBullet [Error] BulletID:%d", TypeSpecificID))
          UIRoot.TextBlock_BulletName:SetText("")
        end
      else
        UIRoot.TextBlock_BulletName:SetText("")
      end
    end
  end
end
function WeaponInfoItemBase:StartReloadBullet(ReloadTime)
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    local WeaponManager = uPlayerCharacter:GetWeaponManager()
    if slua.isValid(WeaponManager) and WeaponManager:GetCurrentUsingPropSlot() == self.WeaponPropSlot then
      self.UIRoot.FitingSlotItem_Bullet_BP:StartReloadAnim(ReloadTime)
    end
  end
end
function WeaponInfoItemBase:HandleReloadFinish()
  self.UIRoot.FitingSlotItem_Bullet_BP:HandleReloadFinish()
end
function WeaponInfoItemBase:ForbidReloadTips()
  if self.ItemID ~= 0 then
    self.UIRoot.CanvasPanel_FobbidenReloadTips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:AddGameTimer(2, false, function()
      self:HideReloadTips()
    end)
  end
end
function WeaponInfoItemBase:HideReloadTips()
  self.UIRoot.CanvasPanel_FobbidenReloadTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function WeaponInfoItemBase:BackpackOpenNotify()
end
function WeaponInfoItemBase:UpdateQuality()
  local AffixClientSubSystem = SubsystemMgr:Get("AffixClientSubSystem")
  if AffixClientSubSystem then
    local HasAffixID = AffixClientSubSystem:HasAffix(slua.IndexReference(self.BattleData, "AdditionalData"))
    if HasAffixID then
      self.Quality = 8
    end
  end
  local BackPackFunctionLibrary = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
  BackPackFunctionLibrary.UpdataQualityColorAndBG(self.Quality, self.UIRoot.Image_Quality, self.UIRoot.Image_QualityBG)
  if self.Quality > 0 then
    self.UIRoot.Image_WeaponNameBG:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.Image_WeaponNameBG:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  end
end
function WeaponInfoItemBase:BindWeaponChangeEvent()
  local uWeapon = self:GetCurrentWeapon()
  if not Game:IsValid(uWeapon) then
    print(bWriteLog and "MainWeaponInfoItemUI:BindWeaponChangeEvent Error, uWeapon is not valid")
  end
  self:AddControlEventByControl(uWeapon, "OnCurBulletChange", self.UpdateBullet, self)
  self:AddControlEventByControl(uWeapon, "OnWeaponShootDelegate", self.UpdateBullet, self)
  self:AddControlEventByControl(uWeapon, "OnWeaponDurabilityChangedDelegate", self.UpdateWeaponDurability, self)
end
function WeaponInfoItemBase:UpdateWeaponDurability()
  local IsEnableWeaponDurability = STExtraModLogicSwitchLibrary.IsEnableWeaponDurability()
  if not IsEnableWeaponDurability then
    self.UIRoot.WeaponDurabilityBox:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local uWeapon = self:GetCurrentWeapon()
  if not Game:IsValid(uWeapon) then
    print(bWriteLog and "MainWeaponInfoItemUI:UpdateWeaponDurability Error, uWeapon is not valid Weaponslot: " .. self.WeaponSlot)
    return
  end
  local UIRoot = self.UIRoot
  UIRoot.WeaponDurabilityBox:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  local ConstantWeaponDurabilityFromEntity = uWeapon:GetConstantWeaponDurabilityFromEntity()
  local WeaponDurability = uWeapon:GetWeaponDurability()
  local GlobalBattleUIFunctionLibrary = import("/Game/UMG/UI_Utility/GlobalBattleUIFunctionLibrary.GlobalBattleUIFunctionLibrary_C")
  local OutColor, Status = GlobalBattleUIFunctionLibrary.GetDurabilityColorConfig(WeaponDurability, ConstantWeaponDurabilityFromEntity, self.UIRoot)
  UIRoot.TextCurDurability:SetColorAndOpacity(OutColor)
  UIRoot.TextCurDurability:SetText(tostring(WeaponDurability))
  local WeaponEntityComp = uWeapon.WeaponEntityComp
  if Game:IsValid(WeaponEntityComp) then
    self.UIRoot.TextMaxDurability:SetText(tostring(WeaponEntityComp.ConstantWeaponDurability))
  end
end
function WeaponInfoItemBase:ShowBezelTips()
  print(bWriteLog and "WeaponInfoItemBase:ShowBezelTips Error, this function should be override")
end
function WeaponInfoItemBase:OnClose()
  print(bWriteLog and "WeaponInfoItemBase:OnClose")
  if self.SlotItemArray then
    for k, v in ipairs(self.SlotItemArray) do
      v[self:GetWeaponInfoName()] = nil
      v:Close()
    end
  end
  local Util = require("client.slua_ui_framework.util")
  self.SlotItemArray = nil
  WeaponInfoItemBase.__super.OnClose(self)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, WeaponInfoItemBase)