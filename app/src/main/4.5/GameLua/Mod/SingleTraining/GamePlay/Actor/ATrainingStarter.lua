local ATrainingStarter = {}
function ATrainingStarter:ctor(selfType)
  self.AIMachineID = 16001
  self.ShootingMachineID = 16002
  self.BombMachineID = 16003
  self.IsShowingUI = false
end
function ATrainingStarter:IsAIMachine()
  return self.MachineID == self.AIMachineID
end
function ATrainingStarter:IsShootingMachine()
  return self.MachineID == self.ShootingMachineID
end
function ATrainingStarter:IsBombMachine()
  return self.MachineID == self.BombMachineID
end
function ATrainingStarter:ReceiveBeginPlay()
  ATrainingStarter.__super.ReceiveBeginPlay(self)
  if self.hasAuthority == false then
    self.NewBie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_SINGLETRAIN, self.MachineID)
    if slua.isValid(self.LightParticleSystem) and slua.isValid(self.TargetParticleSystem) then
      if self.NewBie then
        self.LightParticleSystem:SetVisibility(true, true)
        self.TargetParticleSystem:SetVisibility(true, true)
      else
        self.LightParticleSystem:SetVisibility(false, true)
        self.TargetParticleSystem:SetVisibility(false, true)
      end
    end
  end
end
function ATrainingStarter:OnClientShowInteractiveUI(show, component)
  component = component or self:GetInteractiveComponent()
  if CGameState and slua.isValid(CGameState) then
    if show and not CGameState.bIsTraining then
      self:ShowUI(component)
    else
      self:CloseUI(component)
    end
  end
end
function ATrainingStarter:ShowUI(component)
  if self.IsShowingUI == false then
    component = component or self:GetInteractiveComponent()
    if UIManager.UI_Config_InGame.SingleTrainingInteractiveUI == nil then
      return
    end
    self.IsShowingUI = true
    local ui = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTrainingInteractiveUI)
    if ui ~= nil then
      if component then
        ui:Show(component, component.BtnImage, component.TextId, component.SkillId)
      else
        print(bWriteLog and "ATrainingStarter:ShowUI, component = nil")
      end
    elseif component then
      UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTrainingInteractiveUI, component, component.BtnImage, component.TextId, component.SkillId)
    else
      print(bWriteLog and "ATrainingStarter:ShowUI, component = nil")
    end
  end
end
function ATrainingStarter:CloseUI(component)
  if self.IsShowingUI == true then
    self.IsShowingUI = false
    component = component or self:GetInteractiveComponent()
    if not UIManager.UI_Config_InGame or not UIManager.UI_Config_InGame.SingleTrainingInteractiveUI then
      return
    end
    local ui = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTrainingInteractiveUI)
    if ui then
      ui:Hide(component)
    end
    if self:IsAIMachine() then
      local ui1 = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_AIRule)
      if ui1 then
        UIManager.HideUI(UIManager.UI_Config_InGame.SingleTraining_AIRule)
      end
      local ui2 = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_AI_FightMode)
      if ui2 then
        UIManager.HideUI(UIManager.UI_Config_InGame.SingleTraining_AI_FightMode)
      end
    elseif self:IsShootingMachine() then
      local ui1 = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_ShootingRule)
      if ui1 then
        UIManager.HideUI(UIManager.UI_Config_InGame.SingleTraining_ShootingRule)
      end
      local ui2 = UIManager.GetUI(UIManager.UI_Config_InGame.SingleShootingTrainModeSelect)
      if ui2 then
        UIManager.HideUI(UIManager.UI_Config_InGame.SingleShootingTrainModeSelect)
      end
    elseif self:IsBombMachine() then
      local ui1 = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_ThrowBomRule)
      if ui1 then
        UIManager.HideUI(UIManager.UI_Config_InGame.SingleTraining_ThrowBomRule)
      end
      local ui2 = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_ThrowBomb_FightMode)
      if ui2 then
        UIManager.HideUI(UIManager.UI_Config_InGame.SingleTraining_ThrowBomb_FightMode)
      end
    end
  end
end
local Class = require("class")
local CInteractiveActorBase = require("GameLua.Mod.BaseMod.GamePlay.Actor.AInteractiveActorBase")
local ATrainingStarterClass = Class(CInteractiveActorBase, nil, ATrainingStarter)
return ATrainingStarterClass