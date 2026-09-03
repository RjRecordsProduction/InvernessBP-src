local MainSoundVisualizationUI = {}
local slua_isValid = slua.isValid
local UGameplayStatics = import("GameplayStatics")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local SoundConfig = require("GameLua.Mod.BaseMod.Client.Config.SoundVisualizationConfig")
local SoundVisualizationType = require("GameLua.Mod.BaseMod.GamePlay.SoundVisualization.SoundVisualizationType")
function MainSoundVisualizationUI:RegistEvents()
  print(bWriteLog and "MainSoundVisualizationUI:RegistEvents")
  MainSoundVisualizationUI.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot.Anim_hit, "OnAnimationFinished", function()
    self:HideAllUI()
  end)
  self:AddControlEventByControl(self.UIRoot, "HideSelfDel", function()
    self:HideAllUI()
  end)
end
function MainSoundVisualizationUI:OnPostInitialize()
  print(bWriteLog and "MainSoundVisualizationUI:OnPostInitialize : " .. self.UIRoot.LeaveTime)
  self:InitVariables()
  self.UIRoot.CanvasPanelRoot = self.UIRoot.CanvasPanel_3
  if self.UIRoot.WidgetSwitcher_3D then
    self.UIRoot.SignCanvasPanel = self.UIRoot.WidgetSwitcher_3D
  end
  self.UIRoot.BeHitIcon = self.UIRoot.Image_2
  self.UIRoot.VoiceBG = self.UIRoot.Image_1
  self.UIRoot.VoiceIcon = self.UIRoot.Image_3
  self.UIRoot.NativeTickInterval = self.TickRate or 0.1
  self:InitColor()
  self:AttachToParent()
  if self.NeedProcessCache then
    self:ProcessCache(self.NeedProcessCache.NewCacheInfo, self.NeedProcessCache.NewCharacter)
  end
end
function MainSoundVisualizationUI:InitVariables()
  self.IconPath = {
    ShotTips = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/SoundVisualization_Icon_gunshots_png.SoundVisualization_Icon_gunshots_png",
    SlienceTips = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/SoundVisualization_Icon_xiaoyin_png.SoundVisualization_Icon_xiaoyin_png",
    MoveTips = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/SoundVisualization_Icon_footsteps_png.SoundVisualization_Icon_footsteps_png",
    VehicleTips = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/SoundVisualization_Icon_vehicle_png.SoundVisualization_Icon_vehicle_png",
    ParachuteTips = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/SoundVisualization_Icon_Fall_png.SoundVisualization_Icon_Fall_png",
    LandingTips = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/SoundVisualization_Icon_Parachute_png.SoundVisualization_Icon_Parachute_png"
  }
  self.BgPath = {
    NormalBG = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/SoundVisualization_Image_bg02_png.SoundVisualization_Image_bg02_png",
    SlienceBG = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/SoundVisualization_Image_bg04_png.SoundVisualization_Image_bg04_png"
  }
  self.BrushMap = {}
  self.ShotNoticeDistance = 6000
  self.ShotNoticeMinDistance = 1000
  self.SlienceNoticeDistance = 4000
  self.SlienceNoticeMinDistance = 1000
  self.MoveNoticeDistance = 3000
  self.MoveNoticeMinDistance = 800
  self.VehicleNoticeDistance = 10000
  self.VehicleNoticeMinDistance = 2000
  self.ParachuteAndLandingNoticeDistance = 7000
  self.ParachuteAndLandingNoticeMinDistance = 2000
  self.MinAlpha = 0.2
  self.MaxAlpha = 0.7
  self.MaxShowSpecialDistance = 150
  self.MaxShowSpecialAngle = 15
  self.TickRate = 0.0666667
  self.StayTime = 2
end
function MainSoundVisualizationUI:InitColor()
  local UIUtil = require("client.common.ui_util")
  local uGameFrontendHUD = UIUtil.GetGameFrontendHUD()
  local ColorBlindnessMgr = uGameFrontendHUD:GetColorBlindnessMgr()
  if not slua.isValid(ColorBlindnessMgr) then
    print(bWriteLog and "MainSoundVisualizationUI:InitColor FAILED Case ColorBlindnessMgr is Not Valid")
    return
  end
  ColorBlindnessMgr:AddImage(self.UIRoot.VoiceBG, FLinearColor(1, 1, 1, 1), 3)
  ColorBlindnessMgr:AddImage(self.UIRoot.VoiceIcon, FLinearColor(1, 1, 1, 1), 3)
  ColorBlindnessMgr:AddImage(self.UIRoot.Image_3D01, FLinearColor(1, 1, 1, 1), 3)
  ColorBlindnessMgr:AddImage(self.UIRoot.Image_3D02, FLinearColor(1, 1, 1, 1), 3)
  ColorBlindnessMgr:AddImage(self.UIRoot.BeHitIcon, FLinearColor(1, 1, 1, 1), 6)
end
function MainSoundVisualizationUI:AttachToParent()
  if self.AttachSuccess then
    return
  end
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.CanvasPanel_Hit then
    MainControlBaseUI.CanvasPanel_Hit:AddChild(self.UIRoot)
    self.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
    self.UIRoot.Slot:SetOffsets(FMargin(0, 0, 0, 0))
    self.AttachSuccess = true
  end
end
function MainSoundVisualizationUI:ProcessCache(cacheInfo, myCharacter)
  if not slua.isValid(self.UIRoot) then
    self.NeedProcessCache = {NewCacheInfo = cacheInfo, NewCharacter = myCharacter}
    return
  end
  self:HitTestInvisible()
  if not self.AttachSuccess then
    self:AttachToParent()
  end
  if cacheInfo.CustomVoiceKey then
    self:AddCustomVoiceKey(cacheInfo.Character, cacheInfo.PosVector, cacheInfo.IsWeapon, cacheInfo.IsSlience, myCharacter, cacheInfo.CustomVoiceKey)
    self.NeedProcessCache = nil
    return
  end
  local soundType = cacheInfo.SoundType
  if soundType == SoundVisualizationType.Shot or soundType == SoundVisualizationType.Move then
    self:AddBaseCharater(cacheInfo.Character, cacheInfo.PosVector, cacheInfo.IsWeapon, cacheInfo.IsSlience, myCharacter)
  elseif soundType == SoundVisualizationType.Vehicle then
    self:AddVehicle(cacheInfo.PosVector, myCharacter, cacheInfo.Vehicle)
  elseif soundType == SoundVisualizationType.BeHit then
    self:ShowBeHitNotice(cacheInfo.PosVector, myCharacter)
  elseif soundType == SoundVisualizationType.Parachute then
    self:AddParachute(cacheInfo.PosVector, myCharacter)
  elseif soundType == SoundVisualizationType.Landing then
    self:AddLanding(cacheInfo.PosVector, myCharacter)
  end
  self.NeedProcessCache = nil
end
function MainSoundVisualizationUI:AddCustomVoiceKey(character, posVector, IsWeapon, isSlience, myCharacter, CustomVoiceKey)
  self:AddBaseCharater(character, posVector, IsWeapon, isSlience, myCharacter)
end
function MainSoundVisualizationUI:AddBaseCharater(character, posVector, IsWeapon, isSlience, myCharacter)
  local angle = self:GetAngle(posVector, myCharacter)
  if not angle then
    self:HideAllUI()
    return
  end
  print("MainSoundVisualizationUI:AddBaseCharater Angle ", angle)
  self:SetSoundAngle(angle)
  local nowDistance = posVector:Size()
  if nowDistance <= 0 then
    nowDistance = 1
  end
  if IsWeapon then
    if isSlience then
      if nowDistance > self.SlienceNoticeDistance then
        self:HideAllUI()
        return
      end
      local alpha = self:ComputeAlpha(self.SlienceNoticeDistance, self.SlienceNoticeMinDistance, nowDistance)
      self:ShowSoundIcon(posVector, myCharacter, alpha, self.IconPath.SlienceTips, true, self.BgPath.SlienceBG)
    elseif nowDistance <= self.ShotNoticeDistance then
      local alpha = self:ComputeAlpha(self.ShotNoticeDistance, self.ShotNoticeMinDistance, nowDistance)
      self:ShowSoundIcon(posVector, myCharacter, alpha, self.IconPath.ShotTips, false, self.BgPath.NormalBG)
    else
      self:HideAllUI()
      return
    end
  elseif nowDistance <= self.MoveNoticeDistance then
    local alpha = self:ComputeAlpha(self.MoveNoticeDistance, self.MoveNoticeMinDistance, nowDistance)
    if slua.isValid(character) and character.voiceCheckInParachute then
      alpha = (character.voiceCheckDisInParachute - nowDistance) / character.voiceCheckDisInParachute
    end
    self:ShowSoundIcon(posVector, myCharacter, alpha, self.IconPath.MoveTips, false, self.BgPath.NormalBG)
  else
    self:HideAllUI()
    return
  end
  local curTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  self.UIRoot.LeaveTime = self.StayTime + curTime
  self.UIRoot.StartTime = curTime
  print(bWriteLog and "MainSoundVisualizationUI:AddBaseCharater  ", self.UIRoot.LeaveTime, " : ", self.UIRoot.StartTime)
end
function MainSoundVisualizationUI:AddVehicle(posVector, myCharacter, Vehicle)
  local angle = self:GetAngle(posVector, myCharacter)
  if not angle then
    self:HideAllUI()
    return
  end
  self:SetSoundAngle(angle)
  local nowDistance = posVector:Size()
  if nowDistance <= 0 then
    nowDistance = 1
  end
  if nowDistance > self.VehicleNoticeDistance or not angle then
    self:HideAllUI()
    return
  end
  local VehiclePath = self.IconPath.VehicleTips
  if slua.isValid(Vehicle) then
    local VehicleType = Vehicle.VehicleType
    if VehicleType and SoundConfig.SpecialVehiclVoiceIcon and SoundConfig.SpecialVehiclVoiceIcon[VehicleType] and SoundConfig.SpecialVehiclVoiceIcon[VehicleType].MainIcon then
      VehiclePath = SoundConfig.SpecialVehiclVoiceIcon[VehicleType].MainIcon
    end
  end
  local alpha = self:ComputeAlpha(self.VehicleNoticeDistance, self.VehicleNoticeMinDistance, nowDistance)
  self:ShowSoundIcon(posVector, myCharacter, alpha, VehiclePath, false, self.BgPath.NormalBG)
  local curTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  self.UIRoot.LeaveTime = self.StayTime + curTime
  self.UIRoot.StartTime = curTime
end
function MainSoundVisualizationUI:ShowBeHitNotice(posVector, myCharacter)
  local angle = self:GetAngle(posVector, myCharacter)
  if not angle then
    self:HideAllUI()
    return
  end
  self:SetSoundAngle(angle)
  self.UIRoot:SetImageVisibility(true, false)
  self.UIRoot.SignCanvasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local curTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  self.UIRoot.LeaveTime = self.StayTime + curTime
  self.UIRoot.StartTime = curTime
  self.UIRoot.bIsCanTick = true
  self:PlayUserWidgetAnimation(self.UIRoot.Anim_hit, 0, 1, 0, 1)
end
function MainSoundVisualizationUI:AddParachute(posVector, myCharacter)
  local angle = self:GetAngle(posVector, myCharacter)
  if not angle then
    self:HideAllUI()
    return
  end
  self:SetSoundAngle(angle)
  local nowDistance = posVector:Size()
  if nowDistance <= 0 then
    nowDistance = 1
  end
  if nowDistance > self.ParachuteAndLandingNoticeDistance or not angle then
    self:HideAllUI()
    return
  end
  local alpha = self:ComputeAlpha(self.ParachuteAndLandingNoticeDistance, self.ParachuteAndLandingNoticeMinDistance, nowDistance)
  self:ShowSoundIcon(posVector, myCharacter, alpha, self.IconPath.ParachuteTips, false, self.BgPath.NormalBG)
  local curTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  self.UIRoot.LeaveTime = self.StayTime + curTime
  self.UIRoot.StartTime = curTime
end
function MainSoundVisualizationUI:AddLanding(posVector, myCharacter)
  local angle = self:GetAngle(posVector, myCharacter)
  if not angle then
    self:HideAllUI()
    return
  end
  self:SetSoundAngle(angle)
  local nowDistance = posVector:Size()
  if nowDistance <= 0 then
    nowDistance = 1
  end
  if nowDistance > self.ParachuteAndLandingNoticeDistance or not angle then
    self:HideAllUI()
    return
  end
  local alpha = self:ComputeAlpha(self.ParachuteAndLandingNoticeDistance, self.ParachuteAndLandingNoticeMinDistance, nowDistance)
  self:ShowSoundIcon(posVector, myCharacter, alpha, self.IconPath.LandingTips, false, self.BgPath.NormalBG)
  local curTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  self.UIRoot.LeaveTime = self.StayTime + curTime
  self.UIRoot.StartTime = curTime
end
function MainSoundVisualizationUI:SetSoundAngle(angle)
  local nSwitcherAngle = 360 - angle
  if self.UIRoot.CanvasPanel_3 then
    self.UIRoot.CanvasPanel_3:SetRenderAngle(angle)
  end
  if self.UIRoot.WidgetSwitcher_3D then
    self.UIRoot.WidgetSwitcher_3D:SetRenderAngle(nSwitcherAngle)
  end
end
function MainSoundVisualizationUI:ShowSoundIcon(posVector, myCharacter, alpha, IconPath, bVoice, BgPath)
  local disZ = posVector.Z
  local tanAngle = self:GetAngleTan(posVector, myCharacter)
  if math.abs(disZ) > self.MaxShowSpecialDistance and tanAngle > self.MaxShowSpecialAngle then
    self.UIRoot.WidgetSwitcher_3D:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if 0 < disZ then
      self.UIRoot.Image_3D01:SetOpacity(alpha)
      self.UIRoot.WidgetSwitcher_3D:SetActiveWidgetIndex(0)
    else
      self.UIRoot.Image_3D02:SetOpacity(alpha)
      self.UIRoot.WidgetSwitcher_3D:SetActiveWidgetIndex(1)
    end
  else
    self.UIRoot.WidgetSwitcher_3D:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self.UIRoot:ShowVoiceImage(alpha, IconPath, bVoice, BgPath)
end
function MainSoundVisualizationUI:GetAngle(position, myCharacter)
  if not slua_isValid(myCharacter) then
    return nil
  end
  local playerRotation
  local Controller = myCharacter.Controller
  if slua_isValid(Controller) and slua_isValid(Controller.PlayerCameraManager) then
    playerRotation = Controller.PlayerCameraManager:GetCameraRotation()
  else
    local Vehicle = myCharacter:GetCurrentVehicle()
    if slua_isValid(Vehicle) and slua_isValid(Vehicle.Controller) and slua_isValid(Vehicle.Controller.PlayerCameraManager) then
      playerRotation = Vehicle.Controller.PlayerCameraManager:GetCameraRotation()
    else
      playerRotation = myCharacter:K2_GetActorRotation()
    end
  end
  local Direction = FVector2D(position.X, -position.Y)
  Direction:Normalize(0)
  local nowAngle = math.deg(math.acos(Direction.X))
  if -position.Y < 0 then
    nowAngle = 180 + nowAngle
  else
    nowAngle = 180 - nowAngle
  end
  self.UIRoot.VoiceAngle = nowAngle
  nowAngle = nowAngle - (playerRotation.Yaw + 90)
  self.voicePosition = position
  return nowAngle
end
function MainSoundVisualizationUI:GetAngleTan(position, myCharacter)
  local x, y, z = position.X, position.Y, position.Z
  local distance = math.sqrt(x * x + y * y + z * z)
  if distance == 0 then
    return 0
  end
  local angleRad = math.asin(math.abs(z) / distance)
  local angleDeg = math.deg(angleRad)
  if z < 0 then
    angleDeg = -angleDeg
  end
  if angleDeg < 0 then
    angleDeg = 0 - angleDeg
  end
  return angleDeg
end
function MainSoundVisualizationUI:ComputeAlpha(maxDistance, minDistance, distance)
  if minDistance and distance < minDistance then
    return self.MaxAlpha
  end
  local distanceRat = (maxDistance - distance) / maxDistance
  local alpha = FuncUtil.Clamp(distanceRat, self.MinAlpha, self.MaxAlpha)
  return alpha
end
function MainSoundVisualizationUI:HideAllUI()
  print(bWriteLog and "MainSoundVisualizationUI : HideAllUI")
  self.UIRoot.CanvasPanel_3:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.bIsCanTick = false
  local SoundVisualizationSubsystem = SubsystemMgr:Get("SoundVisualizationSubsystem")
  if SoundVisualizationSubsystem then
    SoundVisualizationSubsystem:OnUIHide(self)
  end
end
function MainSoundVisualizationUI:Close()
  printf("MainSoundVisualizationUI:Close ")
  MainSoundVisualizationUI.__super.Close(self)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
local CMainSoundVisualizationUI = class(UIBase, nil, MainSoundVisualizationUI)
return CMainSoundVisualizationUI