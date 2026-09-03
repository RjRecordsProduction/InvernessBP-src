local BasicSkillsMenuBP = require("GameLua.Mod.BaseMod.Client.Skill.BasicSkillsMenuBP_Config")
function BasicSkillsMenuBP:OnInitialize()
  print(bWriteLog and "BasicSkillsMenuBP:OnInitialize")
  self:InitVariables()
  self.bEnableSearchOtherComp = nil
end
function BasicSkillsMenuBP:OnShow()
  print(bWriteLog and "BasicSkillsMenuBP:OnShow")
end
function BasicSkillsMenuBP:OnClose()
  print(bWriteLog and "BasicSkillsMenuBP:OnClose")
  if slua.isValid(self.UIRoot.Image_Breath) then
    self.UIRoot.Image_Breath:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.UpdateNearDeathTimer ~= nil then
    self:RemoveGameTimer(self.UpdateNearDeathTimer)
    self.UpdateNearDeathTimer = nil
  end
  if self.UpdateTireRepairBtnTimer ~= nil then
    self:RemoveGameTimer(self.UpdateTireRepairBtnTimer)
    self.UpdateTireRepairBtnTimer = nil
  end
  if self.UpdateCarryBackBtnTimer ~= nil then
    self:RemoveGameTimer(self.UpdateCarryBackBtnTimer)
    self.UpdateCarryBackBtnTimer = nil
  end
  self.CurBus = nil
  self.LoopScrollBoxInteract = nil
  self.CurrentInteractItemDataMap = {}
  self.InteractItemDataPool = nil
  self.LoopScrollBoxOperation = nil
  self.CurrentOperationsTypes = nil
  self.CurrentSkills = {}
  self.BtnVisibleFlags = {}
end
function BasicSkillsMenuBP:InitVariables()
  print(bWriteLog and "BasicSkillsMenuBP:InitVariables")
  self.UpdateCarryBackBtnTimer = nil
  self.UpdateNearDeathTimer = nil
  self.UpdateBreathInterval = 0.2
  self.UpdateTireRepairBtnTimer = nil
  self.UpdateTireRepairBtnInterval = 0.2
  self.CachedStore = nil
  self.nCaptiveCancelFailShowTime = 1
  self.bCanShowCaptiveBtnByCaptiveFail = true
  self.CommonBtnType = 0
  self.MegaOperatorCD = 2
  self.MegaOperatorTimer = 0
  self.OpenDoorMode = 1
  self.CanEnterVehicle = false
  self.ColdVisible = false
  self.CurBus = nil
  self.bCanShowCaptiveBtnByCaptiveFail = true
  self.bRacingCanEnterVehicle = true
  self.LoopScrollBoxInteract = self:InitScrollBox(self.UIRoot.LoopScrollBox_Interact)
  self.LoopScrollBoxInteract:SetRefreshItemCallback(self.OnRefreshItem, self, false)
  self.LoopScrollBoxInteract:AddItemWidgetChildEvent("Button_Item", "OnClicked", self.OnClickInteractItem, self)
  self.LoopScrollBoxInteract:AddItemWidgetChildEvent("Button_Item", "OnPressed", self.OnPressInteractItem, self)
  self.CurrentInteractItemDataMap = {}
  self.InteractItemDataPool = {}
  self.LoopScrollBoxOperation = self:InitScrollBox(self.UIRoot.LoopScrollBox_Operation)
  self.LoopScrollBoxOperation:SetRefreshItemCallback(self.OnRefreshItem, self, true)
  self.LoopScrollBoxOperation:AddItemWidgetChildEvent("Button_Item", "OnClicked", self.OnClickOperationItem, self)
  self.CurrentOperationsTypes = {}
  self.CurrentSkills = {}
  self.BtnVisibleFlags = {}
  self.CarryCharacter = nil
  self.CarryPlayerTombBox = nil
  if BasicSkillsMenuBP.bNewVersionDoor then
    self.UIRoot.WidgetSwitcher_Door:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_Door:SetActiveWidgetIndex(0)
  end
  local IntlHelper = import("IntlHelper")
  self.UIRoot.TextBlock_PutDownDeadBox:SetText(IntlHelper.GetLocalizationStringWithID(86796))
  self.UIRoot.Image_PutDownDeadBox:SetBrushFromPathAsync("/Game/Arts/UI/Atlas/BattleUI/General_Ver2/Frames/ZD_icon_LayDown80x80_png.ZD_icon_LayDown80x80_png", true)
end