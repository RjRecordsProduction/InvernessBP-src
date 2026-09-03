local KismetMathLibrary = import("KismetMathLibrary")
local VehicleDisplayActor = {}
function VehicleDisplayActor:ReceiveBeginPlay()
  VehicleDisplayActor.__super.ReceiveBeginPlay(self)
  if self.hasAuthority then
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, self.OnGameFighting, self)
  elseif slua.isValid(CGameState) and CGameState.GetGameModeState and CGameState:GetGameModeState() == "FightingState" then
    self:SetActorHiddenInGame(true)
    self:SetActorEnableCollision(false)
    self:SetActorTickEnabled(false)
  end
end
function VehicleDisplayActor:OnGameFighting()
  if self.hasAuthority and slua.isValid(self.Object) then
    self:K2_DestroyActor()
    print(bWriteLog and "VehicleDisplayActor:OnGameFighting, Destroy Actor")
  end
end
function VehicleDisplayActor:MustCheckResultAfterSkillFinished(Character, Result, Component)
  VehicleDisplayActor.__super.MustCheckResultAfterSkillFinished(self, Character, Result, Component)
  print(bWriteLog and "VehicleDisplayActor:MustCheckResultAfterSkillFinished, self.hasAuthority = " .. tostring(self.hasAuthority) .. ", Result = " .. tostring(Result))
  if Result == false then
    return
  end
  Component = Component or self:GetInteractiveComponent()
  if not self.hasAuthority then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
    if slua.isValid(MainControlBaseUI) then
      MainControlBaseUI:ShowEntireMapWindow()
      local EntireMapUIConfig = UIManager.UI_Config_InGame.EntireMapWindow
      local EntireMapUI = UIManager.GetUI(EntireMapUIConfig)
      if EntireMapUI then
        EntireMapUI:SelectGameGuide(true)
        local GameGuideUIMain = UIManager.GetUI(UIManager.UI_Config_InGame.GameGuideUIMain)
        if GameGuideUIMain and self.DisplayItemID then
          print(bWriteLog and "VehicleDisplayActor:MustCheckResultAfterSkillFinished, DisplayItemID = ", self.DisplayItemID)
          GameGuideUIMain:ShowSelectItem(self.DisplayItemID)
        end
      end
    end
    self:CloseUI(Component)
  end
end
local class = require("class")
local CInteractiveActorTemplate = require("GameLua.Mod.BaseMod.GamePlay.Actor.InteractiveActorTemplate")
local CVehicleDisplayActor = class(CInteractiveActorTemplate, nil, VehicleDisplayActor)
return CVehicleDisplayActor