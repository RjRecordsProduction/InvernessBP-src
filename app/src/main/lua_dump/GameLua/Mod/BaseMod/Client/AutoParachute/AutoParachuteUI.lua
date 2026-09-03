local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local AutoParachuteUI = {}
local EFollowState = import("EFollowState")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function AutoParachuteUI:ctor()
  print(bWriteLog and "AutoParachuteUI:ctor")
  self.AutoParachuteTips = nil
  self.AutoParachuteSafeDist = 150000
  self.AutoParachuteRecoveryHandle = nil
end
function AutoParachuteUI:OnInitialize()
  print(bWriteLog and "AutoParachuteUI:OnInitialize")
  self:InitData()
  self:InitAutoParachuteTips()
end
function AutoParachuteUI:InitData()
  print(bWriteLog and "AutoParachuteUI:InitData")
  self.AutoParachuteWidgetSwitcher = self.UIRoot.WidgetSwitcher_0
end
function AutoParachuteUI:RegistEvents()
  print(bWriteLog and "AutoParachuteUI:RegistEvents")
  self:AddOnClickedEventByControl(self.UIRoot.BtnAutoParachute, self.OnBtnAutoParachuteClicked, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_CANCEL_AUTOPARACHUTE, self.CancelAutoParachute, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_INTERRUPT_AUTOPARACHUTE, self.OnInterruptAutoParachute, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_AUTOPARACHUTE_LOCATION_CHANGE, self.OnAutoParachuteLocationChange, self)
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ENTER_PROTECT, self.OnHideAllUI, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_AutoJump, self, "AutoParachuteUI_CanvasPanel_AutoJump")
end
function AutoParachuteUI:OnPostInitialize()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MaincontrolBaseUI = InGameUITools.GetMainControlBaseUI()
  if MaincontrolBaseUI and MaincontrolBaseUI.CanvasPanel_0 then
    MaincontrolBaseUI.CanvasPanel_0:AddChild(self.UIRoot)
    self.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
    self.UIRoot.Slot:SetOffsets(FMargin(0, 0, 0, 0))
  end
end
function AutoParachuteUI:OnBtnAutoParachuteClicked()
  print(bWriteLog and "AutoParachuteUI:OnBtnAutoParachuteClicked")
  if self:IsAutoParachuteEnable() then
    self:ActivateAutoParachute(false)
  else
    self:ActivateAutoParachute(true)
  end
end
function AutoParachuteUI:OnShow()
  EventSystem:postEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_PARACHUTING_SHOW_AUTOPARACHUTE_BTN)
  EventSystem:postEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_PLAYER_GUIDE_MAPMARK)
end
function AutoParachuteUI:EnableAutoParachute(bEnable)
  local AutoParachuteSubsystem = SubsystemMgr:Get("AutoParachuteSubsystem")
  AutoParachuteSubsystem:EnableAutoParachute(bEnable)
  if bEnable then
    self:ShowAutoParachuteTips()
    self:CheckTargetLocation()
  else
    self:HidAutoParachuteTips()
  end
end
function AutoParachuteUI:IsAutoParachuteEnable()
  local AutoParachuteSubsystem = SubsystemMgr:Get("AutoParachuteSubsystem")
  return AutoParachuteSubsystem:IsAutoParachuteEnable()
end
function AutoParachuteUI:GetTargetLocation()
  local AutoParachuteSubsystem = SubsystemMgr:Get("AutoParachuteSubsystem")
  return AutoParachuteSubsystem:GetTargetLocation()
end
function AutoParachuteUI:ActivateAutoParachute(bActivate)
  print(bWriteLog and "AutoParachuteUI:ActivateAutoParachute", bActivate)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPlayerState = uPlayerController:GetCurPlayerState()
    if slua.isValid(uPlayerState) then
      if bActivate then
        local MapMarkLocation = slua.IndexReference(uPlayerState, "MapMark"):clone()
        MapMarkLocation.Z = 0
        if 0 < MapMarkLocation:Size() then
          if slua.isValid(self.AutoParachuteWidgetSwitcher) then
            self.AutoParachuteWidgetSwitcher:SetActiveWidgetIndex(1)
          end
          self:EnableAutoParachute(true)
          local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
          if slua.isValid(uPlayerCharacter) and uPlayerCharacter.FollowState == EFollowState.Follower then
            print(bWriteLog and "AutoParachuteUI:ActivateAutoParachute Cancel Follow")
            uPlayerCharacter:CancelFollow()
            IngameTipsTools.BattleNormalTipsByTextID(24216)
          end
        else
          IngameTipsTools.BattleNormalTipsByTextID(24213)
        end
      else
        if slua.isValid(self.AutoParachuteWidgetSwitcher) then
          self.AutoParachuteWidgetSwitcher:SetActiveWidgetIndex(0)
        end
        self:EnableAutoParachute(false)
      end
    end
  else
    print(bWriteLog and "AutoParachuteUI:ActivateAutoParachute uPlayerController is invalid")
  end
end
function AutoParachuteUI:CancelAutoParachute()
  print(bWriteLog and "AutoParachuteUI:CancelAutoParachute")
  if self:IsAutoParachuteEnable() then
    IngameTipsTools.BattleNormalTipsByTextID(24217)
  end
  self:ActivateAutoParachute(false)
end
function AutoParachuteUI:InitAutoParachuteTips()
  print(bWriteLog and "AutoParachuteUI:InitAutoParachuteTips")
  self.AutoParachuteTips = self.UIRoot.Canvas_AutoParachuteTips
  if slua.isValid(self.UIRoot.Text_Tips) then
    self.UIRoot.Text_Tips:SetText(LocUtil.GetLocalizeResStr(24212))
  end
end
function AutoParachuteUI:ShowAutoParachuteTips()
  if slua.isValid(self.AutoParachuteTips) then
    self.AutoParachuteTips:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  end
end
function AutoParachuteUI:HidAutoParachuteTips()
  if slua.isValid(self.AutoParachuteTips) then
    self.AutoParachuteTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function AutoParachuteUI:OnInterruptAutoParachute(EventType, EventID, bInterrupt)
  print(bWriteLog and string.format("AutoParachuteUI:OnInterruptAutoParachute bInterrupt:%s", bInterrupt))
  if bInterrupt then
    if self.AutoParachuteRecoveryHandle ~= nil then
      self:RemoveTimer(self.AutoParachuteRecoveryHandle)
      self.AutoParachuteRecoveryHandle = nil
    end
    self:HidAutoParachuteTips()
  elseif self.AutoParachuteRecoveryHandle == nil then
    self.AutoParachuteRecoveryHandle = self:AddTimer(0.2, function()
      if self:IsAutoParachuteEnable() then
        self:ShowAutoParachuteTips()
      end
      self.AutoParachuteRecoveryHandle = nil
    end)
  end
end
function AutoParachuteUI:OnAutoParachuteLocationChange(EventType, EventID, AutoParachuteLocation)
  self:CheckTargetLocation()
end
function AutoParachuteUI:OnHideAllUI()
  print(bWriteLog and "AutoParachuteUI:OnHideAllUI")
  self:Close()
end
function AutoParachuteUI:CheckTargetLocation()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    if uPlayerController:IsAutoParachuteEnable() and uPlayerController:IsInPlane() then
      local AutoParachuteTargetLocation = self:GetTargetLocation()
      if AutoParachuteTargetLocation == nil then
        print(bWriteLog and "AutoParachuteUI:CheckTargetLocation AutoParachuteTargetLocation is invalid")
        return
      end
      local uPlayerState = uPlayerController:GetCurPlayerState()
      local uPlayerCharacter = uPlayerController:GetCurPlayerCharacter()
      if slua.isValid(uPlayerState) and slua.isValid(uPlayerCharacter) then
        local JumpPlanePos = uPlayerState:GetAutoParachuteJumpPlaneLoc()
        if JumpPlanePos:Size() > 0 then
          local PlayerLocation = uPlayerCharacter:K2_GetActorLocation()
          local Player2DLocation = FVector2D(PlayerLocation.X, PlayerLocation.Y)
          local Target2Dlocation = FVector2D(AutoParachuteTargetLocation.X, AutoParachuteTargetLocation.Y)
          local AirplaneForward2D = uPlayerState:GetAirplaneForward2D()
          local TargetForward2D = (Target2Dlocation - Player2DLocation):GetSafeNormal(0)
          local Direction = FVector2D.DotProduct(AirplaneForward2D, TargetForward2D)
          if 0 < Direction then
            local AriplaneStopPos = uPlayerState:GetAirplaneStopLoc()
            local AriplaneStop2DPos = FVector2D(AriplaneStopPos.X, AriplaneStopPos.Y)
            local JumpPosDist = FVector2D.Distance(Player2DLocation, JumpPlanePos)
            local AriplaneStopPosDist = FVector2D.Distance(Player2DLocation, AriplaneStop2DPos)
            if JumpPosDist < AriplaneStopPosDist then
              self:CheckTargetLocationForAutoJumpPos(Target2Dlocation, JumpPlanePos)
            else
              self:CheckTargetLocationForAutoJumpPos(Target2Dlocation, AriplaneStop2DPos)
            end
          elseif uPlayerController.bCanJump then
            self:CheckTargetLocationForAutoJumpPos(Target2Dlocation, Player2DLocation)
          else
            local AriplaneStartPos = uPlayerState:GetAirplaneStartLoc()
            self:CheckTargetLocationForAutoJumpPos(Target2Dlocation, FVector2D(AriplaneStartPos.X, AriplaneStartPos.Y))
          end
        end
      end
    end
  else
    print(bWriteLog and "AutoParachuteUI:CheckTargetLocation uPlayerController is invalid")
  end
end
function AutoParachuteUI:CheckTargetLocationForAutoJumpPos(Target2DLocation, AutoJump2DLocation)
  local Dist = FVector2D.Distance(AutoJump2DLocation, Target2DLocation)
  print(bWriteLog and string.format("AutoParachuteUI:CheckTargetLocation Dist:%s Target2DLocation:[%s, %s] AutoJump2DLocation:[%s, %s]", Dist, Target2DLocation.X, Target2DLocation.Y, AutoJump2DLocation.X, AutoJump2DLocation.Y))
  if Dist > self.AutoParachuteSafeDist then
    IngameTipsTools.BattleNormalTipsByTextID(24214)
  end
end
function AutoParachuteUI:OnClose()
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_AutoJump)
end
local class = require("class")
local object = require("client.slua_ui_framework.base")
local CAutoParachuteUI = class(object, nil, AutoParachuteUI)
return CAutoParachuteUI