local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local CustomType = require("client.logic.setting.CustomType")
local EPawnState = import("EPawnState")
local ParachuteOpenUI = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function ParachuteOpenUI:ctor()
  self.nParachuteOpenUIState = UEnums.EParachuteOpenUIState.EState_None
end
function ParachuteOpenUI:OnInitialize()
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if slua.isValid(MainControlPanelTochButton) then
    MainControlPanelTochButton.MountPanelStatic:AddChild(self.UIRoot)
    self:SetAnchors(0, 0, 1, 1)
    self:SetOffsets(0, 0, 0, 0)
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.CheckParachuteOpenFeature then
    self.nParachuteOpenUIState = uPlayerController.CheckParachuteOpenFeature:GetCurrentParachuteOpenUIState()
    self:RefreshBtnBrush()
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_ON_REFRESH_PARACHUTE_UI_STATE, self.ParachuteUIStateChange, self)
    self:AddControlEventByControl(self.UIRoot.Button_OpenOrClose, "OnPressed", self.OnPressed_OpenOrClose, self)
  end
end
function ParachuteOpenUI:ParachuteUIStateChange(EventType, EventID, nParachuteOpenUIState)
  self.  self:RefreshBtnBrush()
  print(bWriteLog and "ParachuteOpenUI:ParachuteUIStateChange:", nParachuteOpenUIState)
end
function ParachuteOpenUI:RefreshBtnBrush()
  if self.nParachuteOpenUIState == UEnums.EParachuteOpenUIState.EState_ShowParachuteOpenUI then
    self.UIRoot.Image_1:SetBrushfromPathAsync("/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_Jumped_png.ZD_Icon_Jumped_png", false)
    self.UIRoot.TextBlock_SkillName:SetText(LocUtil.GetLocalizeResStr(66706))
    self.UIRoot.Image_BeSelected:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  elseif self.nParachuteOpenUIState == UEnums.EParachuteOpenUIState.EState_SlowParachuteCloseUI then
    self.UIRoot.Image_1:SetBrushfromPathAsync("/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_NoJumped_png.ZD_Icon_NoJumped_png", false)
    self.UIRoot.TextBlock_SkillName:SetText(LocUtil.GetLocalizeResStr(66707))
    self.UIRoot.Image_BeSelected:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  end
end
function ParachuteOpenUI:OnPressed_OpenOrClose()
  local uPlayerController = GameplayData.GetPlayerController()
  print(bWriteLog and "ParachuteOpenUI:OnPressed_OpenOrClose:" .. tostring(self.nParachuteOpenUIState))
  if slua.isValid(uPlayerController) and uPlayerController.CheckParachuteOpenFeature then
    local PlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
    if slua.isValid(PlayerCharacter) and PlayerCharacter:HasState(EPawnState.BoardMove) then
      print(bWriteLog and "ParachuteOpenUI:OnPressed_OpenOrClose return for BoardMove")
      return
    end
    if self.nParachuteOpenUIState == UEnums.EParachuteOpenUIState.EState_ShowParachuteOpenUI then
      if slua.isValid(PlayerCharacter) then
        print(bWriteLog and "ParachuteOpenUI:HandleParachuteStateChangedOver bParachteFromParachuteOpen true")
        PlayerCharacter.bParachteFromParachuteOpen = true
      end
      uPlayerController.CheckParachuteOpenFeature:RPC_ServerParachuteOpen()
    elseif self.nParachuteOpenUIState == UEnums.EParachuteOpenUIState.EState_SlowParachuteCloseUI then
      uPlayerController.CheckParachuteOpenFeature:RPC_ServerParachuteClose()
      if slua.isValid(PlayerCharacter) and PlayerCharacter.IsNetFPP then
        PlayerCharacter.bHaveSetParachutepersonState = false
        PlayerCharacter:SetCurrentPersonPerspective(true, false)
        PlayerCharacter:LocalSwitchPersonPerspective(true, true, true)
        PlayerCharacter.bForceChangePersonPerspective = false
        PlayerCharacter.bParachteFromParachuteOpen = false
      end
    end
  end
end
function ParachuteOpenUI:OnClose()
  print(bWriteLog and "ParachuteOpenUI:OnClose")
  ParachuteOpenUI.__super.OnClose(self)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, ParachuteOpenUI)