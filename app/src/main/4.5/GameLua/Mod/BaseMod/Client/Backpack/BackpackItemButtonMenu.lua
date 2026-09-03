local BackpackItemButtonMenu = {}
local GameplayStatics = import("GameplayStatics")
local STExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
local ESlateVisibility = import("ESlateVisibility")
function BackpackItemButtonMenu:OnInitialize()
  BackpackItemButtonMenu.__super.OnInitialize(self)
  self.Button_0 = self.UIRoot.Button_0
  self.Button_1 = self.UIRoot.Button_1
  self.Button_6 = self.UIRoot.Button_6
  self.Button_7 = self.UIRoot.Button_7
  self.Button_8 = self.UIRoot.Button_8
  self.Button_CallBack = self.UIRoot.Button_CallBack
  self.Button_CallBack_Image = self.UIRoot.Button_CallBack_Image
  self.Button_Controll = self.UIRoot.Button_Controll
  self.Button_Controll_Image = self.UIRoot.Button_Controll_Image
  self.Button_DisdropUAV_Image = self.UIRoot.Button_DisdropUAV_Image
  self.Button_DisuseUAV_Image = self.UIRoot.Button_DisuseUAV_Image
  self.Button_Drop = self.UIRoot.Button_Drop
  self.Button_Drop2 = self.UIRoot.Button_Drop2
  self.Button_Drop_Image = self.UIRoot.Button_Drop_Image
  self.Button_DropAll = self.UIRoot.Button_DropAll
  self.Button_DropAll_Image = self.UIRoot.Button_DropAll_Image
  self.Button_DropPartly = self.UIRoot.Button_DropPartly
  self.Button_DropPartly_Image = self.UIRoot.Button_DropPartly_Image
  self.Button_DropUAV2_Image = self.UIRoot.Button_DropUAV2_Image
  self.Button_DropUAV_Image = self.UIRoot.Button_DropUAV_Image
  self.Button_Equip = self.UIRoot.Button_Equip
  self.Button_Equip_Image = self.UIRoot.Button_Equip_Image
  self.Button_Use = self.UIRoot.Button_Use
  self.Button_UseUAV2_Image = self.UIRoot.Button_UseUAV2_Image
  self.Button_UseUAV_Image = self.UIRoot.Button_UseUAV_Image
  self.CanvasPanel_GuideSlot = self.UIRoot.CanvasPanel_GuideSlot
  self.DropPartlyDisableState_Image = self.UIRoot.DropPartlyDisableState_Image
  self.GridPanel_DropPartlyDisableState = self.UIRoot.GridPanel_DropPartlyDisableState
  self.GridPanel_Throw = self.UIRoot.GridPanel_Throw
  self.GridPanel_UAV_CallbackAndUse = self.UIRoot.GridPanel_UAV_CallbackAndUse
  self.GridPanel_UAV_DisdropAndDisuse = self.UIRoot.GridPanel_UAV_DisdropAndDisuse
  self.GridPanel_UAV_DropAndDisuse = self.UIRoot.GridPanel_UAV_DropAndDisuse
  self.GridPanel_UAV_DropAndUse = self.UIRoot.GridPanel_UAV_DropAndUse
  self.GridPanel_UseDisuseAvarat = self.UIRoot.GridPanel_UseDisuseAvarat
  self.GridPanel_WeaponFit = self.UIRoot.GridPanel_WeaponFit
  self.Group_DropPartly = self.UIRoot.Group_DropPartly
  self.SizeBox_Container = self.UIRoot.SizeBox_Container
  self.UnableToEquip = self.UIRoot.UnableToEquip
  self.UnableToEquip_Image = self.UIRoot.UnableToEquip_Image
  self.VerticalBox_0 = self.UIRoot.VerticalBox_0
  self.IsUseless = self.UIRoot.IsUseless
  self.MyItemData = self.UIRoot.MyItemData
  self.ParentBP = self.UIRoot.ParentBP
  self.Parent = nil
  self.CurGuideItemID = nil
end
function BackpackItemButtonMenu:RegistEvents()
  BackpackItemButtonMenu.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot.Button_Drop2, "OnClicked", self.OnClicked_Button_Drop2, self)
  self:AddControlEventByControl(self.UIRoot.Button_Drop, "OnClicked", self.OnClicked_Button_Drop, self)
  self:AddControlEventByControl(self.UIRoot.Button_CallBack, "OnClicked", self.OnClicked_Button_CallBack, self)
  self:AddControlEventByControl(self.UIRoot.Button_DropAll, "OnClicked", self.OnClicked_Button_DropAll, self)
  self:AddControlEventByControl(self.UIRoot.Button_Controll, "OnClicked", self.OnClicked_Button_Controll, self)
  self:AddControlEventByControl(self.UIRoot.Button_Equip, "OnClicked", self.OnClicked_Button_Equip, self)
  self:AddControlEventByControl(self.UIRoot.Button_0, "OnClicked", self.OnClicked_Button_0, self)
  self:AddControlEventByControl(self.UIRoot.Button_DropPartly, "OnClicked", self.OnClicked_Button_DropPartly, self)
  self:AddControlEventByControl(self.UIRoot.Button_1, "OnClicked", self.OnClicked_Button_1, self)
  self:AddControlEventByControl(self.UIRoot.Button_Use, "OnClicked", self.OnClicked_Button_Use, self)
  self:AddControlEventByControl(self.UIRoot.Button_8, "OnClicked", self.OnClicked_Button_8, self)
  self:AddControlEventByControl(self.UIRoot.Button_7, "OnClicked", self.OnClicked_Button_7, self)
  self:AddControlEventByControl(self.UIRoot.Button_6, "OnClicked", self.OnClicked_Button_6, self)
  self:AddControlEventByControl(self.UIRoot.AvartUse, "OnClicked", self.OnClicked_Button_Use, self)
  self:AddControlEventByControl(self.UIRoot.AvartDisUse, "OnClicked", self.OnClicked_Button_DisUse, self)
  if self.UIRoot.Button_Check then
    self:AddControlEventByControl(self.UIRoot.Button_Check, "OnClicked", self.OnClicked_Button_Check, self)
  end
end
function BackpackItemButtonMenu:OnClose()
  self.Parent = nil
  self.CurGuideItemID = nil
end
function BackpackItemButtonMenu:OnClicked_Button_Use()
  if self.Parent then
    self.Parent:UseItem()
  end
end
function BackpackItemButtonMenu:OnClicked_Button_DisUse()
  if self.Parent then
    self.Parent:DisUseItem()
  end
end
function BackpackItemButtonMenu:OnClicked_Button_Drop()
  if self.Parent then
    self.Parent:DropAllItem()
  end
end
function BackpackItemButtonMenu:OnClicked_Button_DropAll()
  if self.Parent then
    self.Parent:DropAllItem()
  end
end
function BackpackItemButtonMenu:OnClicked_Button_Equip()
  if not self.Parent or self.IsUseless then
  else
    self.Parent:EquipItem()
  end
end
function BackpackItemButtonMenu:OnClicked_Button_DropPartly()
  if self.Parent then
    self.Parent.UIRoot.ItemBeDropped:BroadCast(self.MyItemData, false)
  end
end
function BackpackItemButtonMenu:OnClicked_Button_1()
  if self.Parent then
    self.Parent:UseItem()
  end
end
function BackpackItemButtonMenu:OnClicked_Button_0()
  if self.Parent then
    self.Parent:DropAllItem()
  end
end
function BackpackItemButtonMenu:OnClicked_Button_CallBack()
  if self.Parent then
    self.Parent:CallBack()
  end
end
function BackpackItemButtonMenu:OnClicked_Button_Drop2()
  if self.Parent then
    self.Parent:DropAllItem()
  end
end
function BackpackItemButtonMenu:OnClicked_Button_Controll()
  if self.Parent then
    self.Parent:Controll()
  end
end
function BackpackItemButtonMenu:OnClicked_Button_6()
  local AsSTExtraPlayerController = GameplayStatics.GetPlayerController(self.UIRoot, 0)
  if Game:IsClassOf(AsSTExtraPlayerController, STExtraPlayerController) then
    AsSTExtraPlayerController:DisplayGameTipWithMsgID(930052)
  end
end
function BackpackItemButtonMenu:OnClicked_Button_7()
  local AsSTExtraPlayerController_1 = GameplayStatics.GetPlayerController(self.UIRoot, 0)
  if Game:IsClassOf(AsSTExtraPlayerController_1, STExtraPlayerController) then
    AsSTExtraPlayerController_1:DisplayGameTipWithMsgID(930053)
  end
end
function BackpackItemButtonMenu:OnClicked_Button_8()
  local AsSTExtraPlayerController_2 = GameplayStatics.GetPlayerController(self.UIRoot, 0)
  if Game:IsClassOf(AsSTExtraPlayerController_2, STExtraPlayerController) then
    AsSTExtraPlayerController_2:DisplayGameTipWithMsgID(930054)
  end
end
function BackpackItemButtonMenu:OnClicked_Button_Check()
  if not self.CurGuideItemID then
    return
  end
  local GameGuideUIUtil = require("GameLua.Mod.BaseMod.Client.Map.GameGuideUI.GameGuideUIUtil")
  local TabName = GameGuideUIUtil.GetTabNameByItemID(self.CurGuideItemID)
  print(bWriteLog and "BackpackItemButtonMenu:OnClicked_Button_Check - ItemID:" .. tostring(self.CurGuideItemID) .. ", TabName:" .. tostring(TabName))
  if TabName then
    GameGuideUIUtil.OpenGuideTargetTab(TabName)
  end
end
function BackpackItemButtonMenu:UpdateGuideButtonState(nItemID)
  local Button_Check = self.UIRoot.Button_Check
  if not Button_Check then
    return
  end
  local GameGuideUIConfigSubsystem = SubsystemMgr:Get("GameGuideUIConfigSubsystem")
  local bIsGuideItem = GameGuideUIConfigSubsystem and GameGuideUIConfigSubsystem:CheckShouldShowGuideNew(nItemID, true)
  if bIsGuideItem then
    self.CurGuideItemID = nItemID
    if self.UIRoot.TextBlock_Guide then
      self.UIRoot.TextBlock_Guide:SetText(LocUtil.LocalizeResFormat(450115))
    end
    Button_Check:SetWidgetVisibility(ESlateVisibility.Visible)
  else
    self.CurGuideItemID = nil
    Button_Check:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function BackpackItemButtonMenu:UpdateButtonState(IsUseless, MyItemData)
  self.  self.  if self.IsUseless then
    self.Button_Equip:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.UnableToEquip:SetWidgetVisibility(ESlateVisibility.Visible)
    self.Button_Use:SetIsEnabled(false)
  else
    self.Button_Equip:SetWidgetVisibility(ESlateVisibility.Visible)
    self.UnableToEquip:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.Button_Use:SetIsEnabled(true)
  end
  if self.MyItemData.Count > 1 then
    self.Button_DropPartly:SetWidgetVisibility(ESlateVisibility.Visible)
    self.GridPanel_DropPartlyDisableState:SetWidgetVisibility(ESlateVisibility.Collapsed)
  else
    self.Button_DropPartly:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.GridPanel_DropPartlyDisableState:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, BackpackItemButtonMenu)