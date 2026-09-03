local BackpackUtils = import("BackpackUtils")
local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GameComponentData = require("GameLua.GameCore.Data.GameComponentData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local BackpackClothingEntryUI = {}
function BackpackClothingEntryUI:ctor()
  self.bLoaded = false
  self.BagSubType = 501
  self.CacheCapacity = 0
  self.BackpackDefaultImagePath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_beibao_0_png.ZD_icon_beibao_0_png"
  self.LevelImageMap = {
    [1] = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_zhuangbei_LV1_png.ZD_image_zhuangbei_LV1_png",
    [2] = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_zhuangbei_LV2_png.ZD_image_zhuangbei_LV2_png",
    [3] = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_zhuangbei_LV3_png.ZD_image_zhuangbei_LV3_png",
    [4] = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_zhuangbei_T_LV4_png.ZD_image_zhuangbei_T_LV4_png",
    [5] = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_zhuangbei_T_LV5_png.ZD_image_zhuangbei_T_LV5_png",
    [6] = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_zhuangbei_T_LV6_png.ZD_image_zhuangbei_T_LV6_png"
  }
  self.LevelImageMapForTPlan = {
    [1] = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_zhuangbei_T_LV1_png.ZD_image_zhuangbei_T_LV1_png",
    [2] = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_zhuangbei_T_LV2_png.ZD_image_zhuangbei_T_LV2_png",
    [3] = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_zhuangbei_T_LV3_png.ZD_image_zhuangbei_T_LV3_png",
    [4] = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_zhuangbei_T_LV4_png.ZD_image_zhuangbei_T_LV4_png",
    [5] = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_zhuangbei_T_LV5_png.ZD_image_zhuangbei_T_LV5_png",
    [6] = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_zhuangbei_T_LV6_png.ZD_image_zhuangbei_T_LV6_png"
  }
  self.BackpackLevelImageMap = {
    [1] = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_beibao_1_png.ZD_icon_beibao_1_png",
    [2] = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_beibao_2_png.ZD_icon_beibao_2_png",
    [3] = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_beibao_3_png.ZD_icon_beibao_3_png",
    [4] = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_beibao_4_png.ZD_icon_beibao_4_png",
    [5] = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_beibao_5_png.ZD_icon_beibao_5_png",
    [6] = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_beibao_6_png.ZD_icon_beibao_6_png"
  }
  self.BackpackSpecialItemIDImageMap = {
    [501201] = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_Backpack_BZB_png.ZD_Icon_Backpack_BZB_png"
  }
  self.SpecialLevelImageMap = {
    [501201] = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Image_Equipment_LV2_png.ZD_Image_Equipment_LV2_png"
  }
  self.RemindCoins = 50
  self.bPlayedRemind = false
end
function BackpackClothingEntryUI:OnInitialize()
  self.bLoaded = true
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    self:AttachToPanel(MainControlBaseUI.BackpackClothingEntryUIRoot)
    self:SetZOrder(0)
    self:SetAnchors(0, 0, 1, 1)
    self:SetOffsets(0, 0, 0, 0)
  end
end
function BackpackClothingEntryUI:RegistEvents()
  self:InitRolewearInfo()
  self:OnGameStateChange()
  self:AddUIMessageEvent("UIMsg_HideBackpackUI", self.UIMsg_HideBackpackUI, self)
  self:AddUIMessageEvent("UIMsg_ShowBackpackUI", self.UIMsg_ShowBackpackUI, self)
  self:AddControlEventByControl(self.UIRoot.BackpackButton, "OnClicked", self.OnClickBackpackButton, self)
  self:AddControlEventByControl(self.UIRoot.Button_ClothingGuide, "OnClicked", self.OnClickClothingGuide, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnGameStateChange", self.OnGameStateChange, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "NewbieShowCurGuide", self.ShowOrHideNewbieGuide, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_ITEM_LIST, self.ItemUpdate, self)
  GameComponentData.AddSelfBackpackComponentEvent(self, "ItemListUpdatedDelegate", self.UpdateBackPackCapacity, self)
  GameComponentData.AddSelfBackpackComponentEvent(self, "CapacityUpdatedDelegate", self.UpdateBackPackCapacity, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_GAMEPLAY_SYNC_PLAYERSTATE, self.HideForReplayUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_AVATAR_ON_CHANGE_WEARING_DONE, self.InitRolewearTabWrapper, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_REFRESH_COINS_NUM, self.OnRefreshCoinsNum, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_BackpackPanel, self, "CanvasPanelBackpackPanel")
  self:InitCoinsNum()
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "CharacterDataReady", function()
    self:InitCoinsNum()
    self:UpdateBackPackCapacity()
    self:UpdateBagLevel()
  end)
end
function BackpackClothingEntryUI:OnPostInitialize()
  if self.BackpackClothingBox_UIBP then
    return
  end
  local BackpackClothingBoxConfig = UIManager.UI_Config_InGame.BackpackClothingBox_UIBP
  if BackpackClothingBoxConfig then
    self.BackpackClothingBox_UIBP = self:CreateChildWindow("BackpackClothingBox", BackpackClothingBoxConfig)
  end
  self:SetWidgetVisible(self.UIRoot.MainBackPackRolewearTab.Image_lock2, false, false)
  self:SetWidgetVisible(self.UIRoot.MainBackPackRolewearTab.Image_Exchange, true, false)
  self:SetWidgetVisible(self.UIRoot.MainBackPackRolewearTab.Image_select, false, false)
  self:UpdateUsingBackpack(false)
end
function BackpackClothingEntryUI:UIMsg_ShowBackpackUI()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not MainControlBaseUI or not MainControlBaseUI:IsBackpackCollapsed() then
    return
  end
  self:OnClickBackpackButton()
end
function BackpackClothingEntryUI:UIMsg_HideBackpackUI()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not MainControlBaseUI or MainControlBaseUI:IsBackpackCollapsed() then
    return
  end
  self:OnClickBackpackButton()
end
function BackpackClothingEntryUI:ItemUpdate(_, _, BackpackComponent)
  if not slua.isValid(BackpackComponent) then
    return
  end
  if BackpackComponent:IsItemListUpdatedHasOneItemType(UEnums.EBackpackItemType.Armor) then
    self:UpdateBackPackCapacity()
    self:UpdateBagLevel()
  end
end
function BackpackClothingEntryUI:HandleItemListUpdate()
  self:UpdateBackPackCapacity()
end
function BackpackClothingEntryUI:UpdateBackPackCapacity()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local BackpackComp = PlayerController:GetBackpackComponent()
  if not slua.isValid(BackpackComp) then
    return
  end
  if BackpackComp.Capacity == 0 then
    return
  end
  local Capacity = BackpackComp.Capacity
  local OccupiedCapacity = BackpackComp.OccupiedCapacity
  self:BackPackCDBar(OccupiedCapacity / Capacity)
  if math.ceil(OccupiedCapacity) >= math.ceil(Capacity) then
    self.UIRoot.Image_FullStatus:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self.UIRoot.Image_BackPackCDBar:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  else
    self.UIRoot.Image_FullStatus:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    self.UIRoot.Image_BackPackCDBar:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function BackpackClothingEntryUI:BackPackCDBar(CD)
  if not self.UIRoot then
    return
  end
  local BackPackCDBarMaterial = self.UIRoot.Image_BackPackCDBar:GetDynamicMaterial()
  if slua.isValid(BackPackCDBarMaterial) then
    BackPackCDBarMaterial:SetScalarParameterValue("Mask_Percent", CD)
  end
end
function BackpackClothingEntryUI:UpdateBagLevel()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local BackpackComp = PlayerController:GetBackpackComponent()
  if not slua.isValid(BackpackComp) then
    return
  end
  local bHasLevel = false
  local EuqippedArmorArray = BackpackUtils.GetEuqippedArmorInBackpack(BackpackComp)
  local CDataTable_GetTableData = CDataTable.GetTableData
  for _, BattleItemData in pairs(EuqippedArmorArray) do
    local DefineID = slua.IndexReference(BattleItemData, "DefineID")
    if DefineID and DefineID.TypeSpecificID and DefineID.TypeSpecificID > 0 then
      local ItemCfg = CDataTable_GetTableData("Item", DefineID.TypeSpecificID)
      if ItemCfg and ItemCfg.ItemSubType == self.BagSubType then
        local Level = self:GetBackpackLevelByID(ItemCfg.ItemID)
        local ImageLevelPath = self:GetImageLevelMap(Level)
        if self.SpecialLevelImageMap[ItemCfg.ItemID] then
          ImageLevelPath = self.SpecialLevelImageMap[ItemCfg.ItemID]
        end
        if ImageLevelPath then
          self.UIRoot.Backpack_Level:SetBrushFromPathAsync(ImageLevelPath, false)
        end
        local BackpackImagePath = self.BackpackLevelImageMap[Level]
        if self.BackpackSpecialItemIDImageMap[DefineID.TypeSpecificID] then
          BackpackImagePath = self.BackpackSpecialItemIDImageMap[DefineID.TypeSpecificID]
        end
        if BackpackImagePath then
          self.UIRoot.BackpackImage:SetBrushFromPathAsync(BackpackImagePath, false)
        end
        bHasLevel = true
        print(bWriteLog and "BackpackClothingEntryUI:UpdateBagLevel ", Level)
        break
      end
    end
  end
  if bHasLevel then
    self.UIRoot.Backpack_Level:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  else
    self.UIRoot.Backpack_Level:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.BackpackImage:SetBrushFromPathAsync(self.BackpackDefaultImagePath, false)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_BACKPACK_LEVEL)
end
function BackpackClothingEntryUI:OverrideBackpackIcon(InIconPath)
  self.UIRoot.BackpackImage:SetBrushFromPathAsync(InIconPath, false)
end
function BackpackClothingEntryUI:GetImageLevelMap(Level)
  local CurrentLevelImageMap = self.LevelImageMap
  if STExtraModLogicSwitchLibrary.IsActiveBulletDegreeSwitch() then
    CurrentLevelImageMap = self.LevelImageMapForTPlan
  end
  return CurrentLevelImageMap[Level]
end
function BackpackClothingEntryUI:GetBackpackLevelByID(ItemID)
  return FuncUtil.Clamp(BackpackUtils.GetEquipmentLevel(ItemID), 0, 6)
end
function BackpackClothingEntryUI:OnClickClothingGuide()
  self.UIRoot.ClothingGuide:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  PlayerController:OnPressRolewearChangeBtn(0)
end
function BackpackClothingEntryUI:ShowOrHideNewbieGuide(TipsID, bShow)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or PlayerController:IsSpectator() then
    return
  end
  local ThisGuideText = CDataTable.GetTableData("GuideText", TipsID)
  if not ThisGuideText then
    return
  end
  local bOpenChangeWearing = PlayerController.bOpenChangeWearing
  if TipsID == 1039 then
    if not bOpenChangeWearing then
      self:RolewearGuideTips(bShow, ThisGuideText)
    end
  elseif TipsID == 1041 then
    if bOpenChangeWearing then
      self:RolewearGuideTips(bShow, ThisGuideText)
    end
  elseif TipsID == 1050 then
    self:ShowOrHideBackPackBtnTips(bShow, ThisGuideText)
  end
end
function BackpackClothingEntryUI:RolewearGuideTips(bShow, GuidTextStruct)
  self:SetRolewearGuide(bShow, GuidTextStruct)
end
function BackpackClothingEntryUI:BackpackRolewearGuideInfoTips(bShow, GuidTextStruct)
  self:SetBackpackRolewearGuideInfo(bShow, GuidTextStruct)
end
function BackpackClothingEntryUI:InitRolewearInfo()
  self:SetRolewearVisible(false)
  self:InitRolewearTab(false)
end
function BackpackClothingEntryUI:InitRolewearTabWrapper(_, _, bNeedCD)
  self:InitRolewearTab(bNeedCD)
  self:UpdateUsingBackpack(bNeedCD)
end
function BackpackClothingEntryUI:InitRolewearTab(bNeedCD)
  self:RefreshCD(bNeedCD)
end
function BackpackClothingEntryUI:HideForReplayUI()
  self:HideClothingBackpack()
  self.UIRoot.CanvasPanel_BackpackPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function BackpackClothingEntryUI:HideClothingBackpack()
  self.UIRoot.ClothingBackpack:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function BackpackClothingEntryUI:ShowClothingBackpack()
  self.UIRoot.ClothingBackpack:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function BackpackClothingEntryUI:OnGameStateChange()
  local GameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(GameState) then
    return
  end
  local bShow = GameState:GetGameModeState() == "ReadyState"
  self:SetRolewearVisible(bShow)
end
function BackpackClothingEntryUI:SetRolewearVisible(bShow)
  local Visibility = UEnums.ESlateVisibility.Collapsed
  local bIsSpectator = false
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    bIsSpectator = PlayerController:IsSpectatorOrDemoPlayer()
  end
  print(bWriteLog and "BackpackClothingEntryUI:SetRolewearVisible", bShow)
  if bShow and not bIsSpectator then
    Visibility = UEnums.ESlateVisibility.SelfHitTestInvisible
  end
  self.UIRoot.CanvasPanel_ClothingBackpack:SetWidgetVisibility(Visibility)
end
function BackpackClothingEntryUI:OnClickBackpackButton()
  if UIManager.UI_Config_InGame.BRTDMStoreUI then
    local BRTDMStoreUI = UIManager.GetUI(UIManager.UI_Config_InGame.BRTDMStoreUI)
    if BRTDMStoreUI and BRTDMStoreUI.UIRoot:IsVisible() then
      BRTDMStoreUI:OnClicked_Leave()
    end
  end
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    MainControlBaseUI:InterruptThrow()
    if MainControlBaseUI:IsBackpackCollapsed() then
      MainControlBaseUI:HideBuffList()
      BatttleWindowMgr.HideUI("EntireMapWindow")
      MainControlBaseUI:ShowQuickMsgInfo(false)
      EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_SHOWHIDE_BACKPACK_PANEL)
    else
      MainControlBaseUI:ShowQuickMsgInfo(true)
      EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_SHOWHIDE_BACKPACK_PANEL)
    end
  end
  self.UIRoot.BackpackClothingGuide:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.OnPressBackpackBtn then
    PlayerController:OnPressBackpackBtn()
  end
end
function BackpackClothingEntryUI:ShowOrHideBackPackBtnTips(bIsShow, GuidTextStruct)
  if bIsShow then
    self.UIRoot.UTRichTextBlock_2:SetText(GuidTextStruct.text1)
    self.UIRoot.CanvasPanel_BackPackBtnGuidTip:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.CanvasPanel_BackPackBtnGuidTip:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function BackpackClothingEntryUI:SetRolewearGuide(bShow, GuidTextStruct)
  local Visibility = UEnums.ESlateVisibility.Collapsed
  if bShow then
    Visibility = UEnums.ESlateVisibility.SelfHitTestInvisible
    self.UIRoot.RichText_ClothingTip:SetText(GuidTextStruct.text1)
  end
  self.UIRoot.ClothingGuide:SetWidgetVisibility(Visibility)
end
function BackpackClothingEntryUI:SetBackpackRolewearGuideInfo(bShow, GuidTextStruct)
  local Visibility = UEnums.ESlateVisibility.Collapsed
  if bShow then
    Visibility = UEnums.ESlateVisibility.SelfHitTestInvisible
    self.UIRoot.RichText_BackpackTip:SetText(GuidTextStruct.text1)
  end
  self.UIRoot.BackpackClothingGuide:SetWidgetVisibility(Visibility)
end
function BackpackClothingEntryUI:ShowOrHideBackpack_Border(bShow)
  local Visibility = UEnums.ESlateVisibility.Collapsed
  if bShow then
    Visibility = UEnums.ESlateVisibility.SelfHitTestInvisible
  end
  self.UIRoot.Backpack_Border:SetWidgetVisibility(Visibility)
end
function BackpackClothingEntryUI:OnClose()
  if self.bLoaded then
    HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_BackpackPanel)
  end
  if self.BackpackClothingBox_UIBP then
    self.BackpackClothingBox_UIBP:Close()
    self.BackpackClothingBox_UIBP = nil
  end
end
function BackpackClothingEntryUI:OnRefreshCoinsNum(_, _, CoinsNum)
  self.UIRoot.TextBlock_CoinsNum:SetText(tostring(CoinsNum))
  if self.LastCoins and CoinsNum > self.LastCoins then
    local CurTime = CGameState:GetServerWorldTimeSeconds()
    if not self.LastAddAnimTime or CurTime - self.LastAddAnimTime > 0.5 then
      self:PlayUserWidgetAnimation(self.UIRoot.Anim_Add, 0, 1, 0, 1)
      self.LastAddAnimTime = CurTime
    end
  end
  self:CheckPlayRemindAnim(CoinsNum)
  self.LastCoins = CoinsNum
  if CoinsNum == 0 then
    self.UIRoot.CoinsPanel:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  else
    self.UIRoot.CoinsPanel:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  end
end
function BackpackClothingEntryUI:InitCoinsNum()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    self.UIRoot.CoinsPanel:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    return
  end
  local BackpackComp = PlayerController:GetBackpackComponent()
  if not slua.isValid(BackpackComp) then
    self.UIRoot.CoinsPanel:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    return
  end
  self.LastCoins = BackpackComp.CoinsNum or 0
  self.UIRoot.TextBlock_CoinsNum:SetText(tostring(self.LastCoins))
  self:CheckPlayRemindAnim(self.LastCoins)
  if self.LastCoins == 0 then
    self.UIRoot.CoinsPanel:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  else
    self.UIRoot.CoinsPanel:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  end
end
function BackpackClothingEntryUI:CheckPlayRemindAnim(CoinsNum)
  if self.bPlayedRemind and CoinsNum < self.RemindCoins then
    self.UIRoot:StopAnimation(self.UIRoot.Anim_Remind)
    self.bPlayedRemind = false
  elseif not self.bPlayedRemind and CoinsNum >= self.RemindCoins then
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_Remind, 0, 0, 0, 1)
    self.bPlayedRemind = true
  end
end
function BackpackClothingEntryUI:UpdateUsingBackpack(bNeedCD)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local Index = PlayerController.RolewearIndex or 0
    local LogicBackpackClothUIUtil = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicBackpackClothUIUtil)
    local ShowText = LogicBackpackClothUIUtil:GetClothEntryShowNameByIndex(Index)
    self.UIRoot.MainBackPackRolewearTab.Text_index:SetText(ShowText)
    self:RefreshCD(bNeedCD)
  end
end
function BackpackClothingEntryUI:RefreshCD(bNeedCD)
  if bNeedCD then
    self.UIRoot.MainBackPackRolewearTab:CoolDown()
  else
    self.UIRoot.MainBackPackRolewearTab:ClearCoolDown()
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, BackpackClothingEntryUI)