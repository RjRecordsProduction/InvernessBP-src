local UIControlSubSystem = {}
function UIControlSubSystem:ctor()
  self.CurrentRecoverLayout = {}
  self.CurrentRecoverConfig = {}
end
function UIControlSubSystem:EnterNoUIMode(Config)
  print(bWriteLog and "[DanceTogether] EnterNoUIMode")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "[DanceTogether][Error] UIControlSubSystem:EnterNoUIMode uPlayerController is not Valid ")
    return
  end
  log_tree("[DanceTogether] UIControlSubSystem Config", Config)
  self:HideMainUI(Config)
  if uPlayerController.bPCInputSwitcher == true then
    self.HasChangedPCInputSwitcher = true
    uPlayerController.bPCInputSwitcher = false
  end
  uPlayerController:ShowTouchInterface(false)
  self:SetCrossHairVisible(false)
end
function UIControlSubSystem:ExitNoUIMode()
  print(bWriteLog and "[DanceTogether] ExitNoUIMode")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "[Dancetogether][Error] UIControlSubSystem ExitNoUIMode uPlayerController is not Valid")
    return
  end
  self:RecoverMainUI()
  if self.HasChangedPCInputSwitcher then
    uPlayerController.bPCInputSwitcher = true
    self.HasChangedPCInputSwitcher = false
  end
  uPlayerController:ShowTouchInterface(true)
  self:SetCrossHairVisible(true)
end
function UIControlSubSystem:SetCrossHairVisible(bShow)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "[DanceTogether][Error] UIControlSubSystem:SetCrossHairVisible uPlayerController is not Valid ")
    return
  end
  local PlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "[DanceTogether][Error] UIControlSubSystem:SetCrossHairVisible PlayerCharacter is not Valid ")
    return
  end
  PlayerCharacter.bIsHideCrossHairType = not bShow
end
function UIControlSubSystem:HideMainUI(Config)
  self.CurrentRecoverLayout = {}
  self.CurrentRecoverConfig = {}
  self:MoveGloadContainer(UIContainers.Bottom)
  self:MoveGloadContainer(UIContainers.Default)
  if Config and Config.NoHideWidget then
    for key, Config in pairs(Config.NoHideWidget) do
      local ui = UIManager.GetUI(Config)
      if ui and slua.isValid(ui.UIRoot) then
        local CurrentTranslation = ui.UIRoot.RenderTransform.Translation:clone()
        self.CurrentRecoverConfig[Config.keyName] = CurrentTranslation
        ui.UIRoot:SetRenderTranslation(FVector2D(20000, 0))
      end
    end
  end
end
function UIControlSubSystem:MoveGloadContainer(ContainerName)
  local frontendUtils = slua_GameFrontendHUD:GetUtils()
  if not frontendUtils then
    print(bWriteLog and "[DanceTogether][Error] UIControlSubSystem:HideMainUI not frontendUtils ")
    return
  end
  local BottomContainer = frontendUtils:GetGlobalUIContainer(ContainerName)
  if BottomContainer and BottomContainer.CanvasContainer then
    self:MoveAwayUI(BottomContainer.CanvasContainer)
  else
    print(bWriteLog and "[DanceTogether][Error] UIControlSubSystem:MoveGloadContainer ContainerName is not Valid :" .. tostring(ContainerName))
  end
end
function UIControlSubSystem:MoveAwayUI(UIRef)
  if not slua.isValid(UIRef) then
    print(bWriteLog and "[DanceTogether][Error] UIControlSubSystem:MoveAwayUI UIRef is not Valid ")
    return
  end
  local CurrentTranslation = UIRef.RenderTransform.Translation:clone()
  self.CurrentRecoverLayout[UIRef] = CurrentTranslation
  UIRef:SetRenderTranslation(FVector2D(-20000, 0))
end
function UIControlSubSystem:RecoverMainUI()
  for Widget, Translation in pairs(self.CurrentRecoverLayout) do
    if slua.isValid(Widget) then
      Widget:SetRenderTranslation(Translation)
    end
  end
  for keyName, Translation in pairs(self.CurrentRecoverConfig) do
    local config = UIManager.GetConfigByKey(keyName)
    if config then
      local ui = UIManager.GetUI(config)
      if ui and slua.isValid(ui.UIRoot) then
        ui.UIRoot:SetRenderTranslation(Translation)
      end
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, UIControlSubSystem)