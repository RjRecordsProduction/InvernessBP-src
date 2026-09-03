local UGameplayStatics = import("GameplayStatics")
local SkillCancelButton = {}
function SkillCancelButton:ctor(selfType)
end
function SkillCancelButton:OnInitialize()
  SkillCancelButton.__super.OnInitialize(self)
  print(bWriteLog and "SkillCancelButton:OnInitialize()")
end
function SkillCancelButton:RegistEvents()
  SkillCancelButton.__super.RegistEvents(self)
  print(bWriteLog and "SkillCancelButton:RegistEvents()")
  self:AddControlEventByControl(self.UIRoot.Button_Cancel, "OnPressed", self.OnPressedButtonCancel, self)
  self:AddCommonEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_SHOW_CANCEL_BUILD_BTN, self.OnShowCancelBtn, self)
  self:AddCommonEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_HIDE_CANCEL_BUILD_BTN, self.OnHideCancelBtn, self)
end
function SkillCancelButton:OnPressedButtonCancel()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    uPlayerCharacter:TouchCancelSkillLock()
    if self.TriggerType == "RequestCancel" then
      local EUAESkillEvent = import("EUAESkillEvent")
      uPlayerCharacter:TriggerCustomEvent(EUAESkillEvent.PlayerRequestCancel, -1)
    else
      local UTSkillStopReason = import("UTSkillStopReason")
      uPlayerCharacter:StopAllSkills(UTSkillStopReason.SkillStopReason_Interrupted)
    end
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local ShootingUIPanel = InGameUITools.GetShootingUIPanelLuaClass()
  if not Game:IsValid(ShootingUIPanel) then
    return
  end
  if ShootingUIPanel then
    ShootingUIPanel:RecordThrowGrenadeBtnState(-1)
  end
end
function SkillCancelButton:OnShowCancelBtn(_, _, uPlayerCharacter, SkillID, Params)
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter:IsLocallyControlled() then
    print(bWriteLog and "SkillCancelButton:OnShowCanvelBtn")
    self.UIRoot.CanvasPanel_Cancel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if Params and Params.CancelType == "White" then
      if slua.isValid(self.UIRoot.CanvasPanel_1) then
        self.UIRoot.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
      if slua.isValid(self.UIRoot.CanvasPanel_0) then
        self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    else
      if slua.isValid(self.UIRoot.CanvasPanel_1) then
        self.UIRoot.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
      if slua.isValid(self.UIRoot.CanvasPanel_0) then
        self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
    end
    if Params and Params.TriggerType == "RequestCancel" then
      self.TriggerType = "RequestCancel"
    else
      self.TriggerType = nil
    end
  end
end
function SkillCancelButton:OnHideCancelBtn(_, _, uPlayerCharacter)
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter:IsLocallyControlled() then
    print(bWriteLog and "SkillCancelButton:OnHideCancelBtn")
    self.UIRoot.CanvasPanel_Cancel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
local class = require("class")
local SkillButtonSlotBase = require("GameLua.Mod.BaseMod.Client.SkillPanel.SkillButtonSlotBase")
return class(SkillButtonSlotBase, nil, SkillCancelButton)