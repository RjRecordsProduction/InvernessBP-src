local InteractiveUI = {}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function InteractiveUI:ctor(selfUI, component, btnImage, textId, skillId)
  print(bWriteLog and "InteractiveUI:ctor, selfUI = " .. tostring(selfUI) .. ", component = " .. tostring(component) .. ", btnImage = " .. tostring(btnImage) .. ", textId = " .. tostring(textId) .. ", skillId = " .. tostring(skillId))
  self.  self.  self.  self.  self.lastComponent = nil
  self.lastBtnImage = nil
  self.lastTextId = nil
  self.lastSkillId = nil
end
function InteractiveUI:RegistEvents()
  InteractiveUI.__super.RegistEvents(self)
  if self.UIRoot.Button_0 then
    self:AddOnClickedEventByControl(self.UIRoot.Button_0, self.OnClickButton, self)
  end
  local UGameplayStatics = import("GameplayStatics")
  local playerController = UGameplayStatics.GetPlayerController(self.UIRoot, 0)
  if slua.isValid(playerController) then
    self:AddControlEventByControl(playerController, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnected, self)
    self:AddControlEventByControl(playerController, "OnCharacterNearDeathOrRescueingOtherNotifyDelegate", self.OnHandlePlayerDied, self)
    local character = playerController:GetPlayerCharacterSafety()
    if slua.isValid(character) then
      self:AddControlEventByControl(character, "OnHandleSkillStartDelegate", self.OnSkillStarted, self)
      self:AddControlEventByControl(character, "OnHandleSkillEndDelegate", self.OnSkillEnded, self)
    end
  end
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX, self.OnApplicationReactived, self)
  self:AddCommonEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_CAMERA_OPEN, self.OnSocialIslandCameraOpen, self)
  self:AddCommonEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_CAMERA_CLOSE, self.OnSocialIslandCameraClose, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ENTER_SELFIE_MODE, self.OnSocialIslandCameraOpen, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_EXIT_SELFIE_MODE, self.OnSocialIslandCameraClose, self)
end
function InteractiveUI:OnSkillStarted(character, skillId)
  if self.skillId == skillId then
    print(bWriteLog and "InteractiveUI:OnSkillStarted, skillId = " .. tostring(skillId))
    if self.UIRoot.Button_0 then
      self.UIRoot.Button_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function InteractiveUI:OnSkillEnded(character, reason, skillId)
  if self.skillId == skillId then
    print(bWriteLog and "InteractiveUI:OnSkillEnded, reason = " .. tostring(reason) .. ", skillId = " .. tostring(skillId))
    if self.UIRoot.Button_0 then
      self.UIRoot.Button_0:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    end
  end
end
function InteractiveUI:OnReconnected()
  print(bWriteLog and "InteractiveUI:OnReconnected")
  if not self.UIRoot or self.UIRoot:IsVisible() then
  end
end
function InteractiveUI:OnHandlePlayerDied(isNearDeath, isRescueingOther)
  print(bWriteLog and "InteractiveUI:OnHandlePlayerDied, isNearDeath = " .. tostring(isNearDeath))
  if not (self.UIRoot and self.UIRoot:IsVisible()) or isNearDeath then
  end
end
function InteractiveUI:OnApplicationReactived()
  print(bWriteLog and "InteractiveUI:OnApplicationReactived")
  if not self.UIRoot or self.UIRoot:IsVisible() then
  end
end
function InteractiveUI:OnSocialIslandCameraOpen()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_0, false)
end
function InteractiveUI:OnSocialIslandCameraClose()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_0, true)
end
function InteractiveUI:UpdateImmersiveModeUI(bIsImmersive)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_0, not bIsImmersive)
end
function InteractiveUI:OnClickButton()
  if self:IsValid(self.component) then
    if self.component.bAllowWhenCoolDown == true and self.component:IsCoolingDown() == true and self.component:GetCoolDownLeftTimeForShow() > 0 and 0 < self.component.TipsIdWhenClickedInCoolDown then
      local LeftTime = self.component:GetCoolDownLeftTimeForShow()
      IngameTipsTools.BattleNormalTipsByTextID(self.component.TipsIdWhenClickedInCoolDown, tostring(LeftTime))
      return
    end
    if self.component.GetOwner then
      local owner = self.component:GetOwner()
      if owner then
        do
          local GameplayStatics = import("GameplayStatics")
          local playerController = GameplayStatics.GetPlayerController(owner, 0)
          local character = playerController and playerController:GetPlayerCharacterSafety()
          if character and slua.isValid(character) then
            do
              local OnePass = function()
                return owner:OnClientClickInteractiveButton(character, self.component)
              end
              local TwoPass = function()
                return self.component:LuaOnClientClickInteractiveButton(character)
              end
              local ThreePass = function()
                character:ServerRPCOnClickInteractiveButton(self.component, 0)
              end
              local Status, Result = pcall(OnePass)
              if Status then
                if Result == false then
                  return
                end
              else
                Status, Result = pcall(TwoPass)
                if Status and Result == false then
                  return
                end
              end
              pcall(ThreePass)
            end
          end
        end
      end
    end
  else
    self:Hide()
  end
end
function InteractiveUI:OnClickClose()
  print(bWriteLog and "InteractiveUI:OnClickClose")
  self:CloseSelf()
end
function InteractiveUI:OnInitialize()
  InteractiveUI.__super.OnInitialize(self)
  if slua.isValid(self.UIRoot.CanvasPanel_0) then
    local UIUtil = require("client.common.ui_util")
    UIUtil.SetAdaptation(self.UIRoot.CanvasPanel_0)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_0, true)
  end
end
function InteractiveUI:OnPostInitialize()
  InteractiveUI.__super.OnPostInitialize(self)
end
function InteractiveUI:OnShow()
  print(bWriteLog and "InteractiveUI:OnShow")
  InteractiveUI.__super.OnShow(self)
  self:UpdateUI()
  if self.UIRoot.Button_0 then
    self.UIRoot.Button_0:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
end
function InteractiveUI:UpdateUI()
  if self.component == nil or slua.isValid(self.component) == false then
    return
  end
  if self.textId ~= "" and self.textId ~= self.lastTextId then
    local text = LocUtil.GetLocalizeResStr(self.textId)
    if text == "" then
      text = tostring(self.textId)
    end
    self.UIRoot.TextBlock_0:SetText(text)
  end
  if self.btnImage ~= nil and (self:IsValid(self.lastBtnImage) == false or self.btnImage ~= self.lastBtnImage) then
    local AssetPathName
    if type(self.btnImage) == "string" then
      AssetPathName = self.btnImage
    else
      AssetPathName = self.btnImage.AssetPathName
    end
    self.UIRoot.Image_0:SetBrushFromPathAsync(AssetPathName, false)
  end
end
function InteractiveUI:SetOpacity(Alpha)
  self.UIRoot.Image_0:SetOpacity(Alpha)
  self.UIRoot.TextBlock_0:SetOpacity(Alpha)
end
function InteractiveUI:Show(component, btnImage, textId, skillId)
  self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.lastComponent = self.component
  self.lastBtnImage = self.btnImage
  self.lastTextId = self.textId
  self.lastSkillId = self.skillId
  self.  self.  self.  self.  self:UpdateUI()
end
function InteractiveUI:IsShowing()
  return self.UIRoot:IsVisible()
end
function InteractiveUI:IsValid(object)
  if object == nil then
    print(bWriteLog and "InteractiveUI:IsValid, object = nil")
    return false
  elseif type(object) == "table" then
    return true
  elseif type(object) == "userdata" then
    if slua.isValid(object) then
      return true
    else
      print(bWriteLog and "InteractiveUI:IsValid, slua.isValid = false")
      return false
    end
  elseif type(object) == "boolean" then
    return object
  end
  return true
end
function InteractiveUI:Hide(component)
  if component ~= nil then
    if self.component == component then
      self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  elseif self.UIRoot then
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function InteractiveUI:Close()
  print(bWriteLog and "InteractiveUI:Close")
  self.component = nil
  self.btnImage = nil
  self.textId = nil
  self.skillId = nil
  self.lastComponent = nil
  self.lastBtnImage = nil
  self.lastTextId = nil
  self.lastSkillId = nil
  InteractiveUI.__super.Close(self)
end
function InteractiveUI:OnHide()
  print(bWriteLog and "InteractiveUI:OnHide")
  InteractiveUI.__super.OnHide(self)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CInteractiveUI = class(ui_base, nil, InteractiveUI)
return CInteractiveUI