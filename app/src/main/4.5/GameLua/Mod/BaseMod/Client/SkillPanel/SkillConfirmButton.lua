local UGameplayStatics = import("GameplayStatics")
local SkillConfirmButton = {}
function SkillConfirmButton:ctor(selfType)
end
function SkillConfirmButton:OnInitialize()
  SkillConfirmButton.__super.OnInitialize(self)
  print(bWriteLog and "SkillConfirmButton:OnInitialize()")
end
function SkillConfirmButton:RegistEvents()
  SkillConfirmButton.__super.RegistEvents(self)
  print(bWriteLog and "SkillConfirmButton:RegistEvents()")
  self:AddControlEventByControl(self.UIRoot.Button_Confirm, "OnPressed", self.OnPressedButtonConfirm, self)
  self:AddCommonEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_SHOW_CONFIRM_BUILD_BTN, self.OnShowBtn, self)
  self:AddCommonEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_HIDE_CONFIRM_BUILD_BTN, self.OnHideBtn, self)
end
function SkillConfirmButton:OnPressedButtonConfirm()
  print(bWriteLog and "SkillConfirmButton:OnPressedButtonConfirm")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "SkillConfirmButton:OnPressedButtonConfirm uPlayerCharacter is not valid")
    return
  end
  local SkillManager = uPlayerCharacter:GetSkillManager()
  if slua.isValid(SkillManager) then
    print(bWriteLog and "SkillConfirmButton:OnPressedButtonConfirm uPlayerCharacter TriggerStringEvent SkillID " .. tostring(SkillManager:GetCurSkillID()))
    SkillManager:TriggerStringEvent(SkillManager:GetCurSkillID(), "OnClickConfirm")
  end
end
function SkillConfirmButton:OnShowBtn(_, _, uPlayerCharacter)
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter:IsLocallyControlled() then
    print(bWriteLog and "SkillConfirmButton:OnShowCanvelBtn")
    self.UIRoot.CanvasPanel_Confirm:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function SkillConfirmButton:OnHideBtn(_, _, uPlayerCharacter)
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter:IsLocallyControlled() then
    print(bWriteLog and "SkillConfirmButton:OnHideConfirmBtn")
    self.UIRoot.CanvasPanel_Confirm:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
local class = require("class")
local SkillButtonSlotBase = require("GameLua.Mod.BaseMod.Client.SkillPanel.SkillButtonSlotBase")
return class(SkillButtonSlotBase, nil, SkillConfirmButton)