local MapSoundVisualization = {}
local EGameModeCPPType = import("EGameModeType")
local SoundConfig = require("GameLua.Mod.BaseMod.Client.Config.SoundVisualizationConfig")
local SoundVisualizationType = require("GameLua.Mod.BaseMod.GamePlay.SoundVisualization.SoundVisualizationType")
function MapSoundVisualization:ctor()
  printf("MapSoundVisualization:ctor")
  self.InitFalse = true
end
function MapSoundVisualization:OnInitialize()
  printf("MapSoundVisualization:OnInitialize")
  local DataLayerSubsystem = SubsystemMgr:Get("DataLayerSubsystem")
  if DataLayerSubsystem then
    self:AddDataListener(DataLayerSubsystem:GetSuperData(), "OtherMortarEnterAimState", self.OtherMortarEnterAimState, self)
  end
end
function MapSoundVisualization:OtherMortarEnterAimState(_, bOtherMortarEnterAimState)
  local Visibility = UEnums.ESlateVisibility.HitTestInvisible
  if bOtherMortarEnterAimState then
    Visibility = UEnums.ESlateVisibility.Collapsed
  end
  if self.UIRoot.CanvasPanelRoot then
    self.UIRoot.CanvasPanelRoot:SetWidgetVisibility(Visibility)
  end
end
function MapSoundVisualization:OnPostInitialize()
  printf("MapSoundVisualization:OnPostInitialize")
  MapSoundVisualization.__super.OnPostInitialize(self)
  self:InitRootPanel()
end
function MapSoundVisualization:InitRootPanel()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if Game:IsValid(MainControlBaseUI) and Game:IsValid(MainControlBaseUI.VoiceCheckPanel) and slua.isValid(self.UIRoot) then
    self:InitVariables()
    local RootPanel = MainControlBaseUI.VoiceCheckPanel
    RootPanel:AddChild(self.UIRoot)
    self.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
    self.UIRoot.Slot:SetOffsets(FMargin(0, 0, 0, 0))
    self.UIRoot.CanvasPanelRoot = self.UIRoot.CanvasPanel_Root
    self.UIRoot.MaxSmallTipsCount = self.MaxSmallTipsCount
    self.UIRoot.MaxShowCount = self.MaxShowCount
    self.UIRoot.SliencePivot = self.SliencePivot
    self.UIRoot.SlienceAlignment = self.SlienceAlignment
    self.UIRoot.SlienceSize = self.SlienceSize
    self.UIRoot.NormalPivot = self.NormalPivot
    self.UIRoot.NormalAlignment = self.NormalAlignment
    self.UIRoot.NormalSize = self.NormalSize
    self.UIRoot.ImgAnchors = self.Anchors
    self.InitFalse = false
  else
    self.InitFalse = true
  end
end
function MapSoundVisualization:RegistEvents()
  MapSoundVisualization.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot, "OnHideImageDel", self.AfterHideImage, self)
  self:AddControlEventByControl(self.UIRoot, "OnHideImageArrayDel", self.AfterHideImageArray, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SHOW_CUSTOM_VOICE_TIPS, self.TriggerCustomVoice, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CHANGE_VOICECHECK_IMAGE_BEGIN, self.ChangeVoiceImageBegin, self)
end
function MapSoundVisualization:InitVariables()
  self.IconPath = {
    ShotTips = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_qiangsheng_island_png.ZD_icon_qiangsheng_island_png",
    SlienceTips = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_xiaoyinqi_island_png.ZD_icon_xiaoyinqi_island_png",
    ExplosionTips = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_baozha_island_png.ZD_icon_baozha_island_png",
    MoveTips = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_jiaobu_island_png.ZD_icon_jiaobu_island_png",
    VehicleTips = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_che_island_png.ZD_icon_che_island_png",
    GlassTips = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_boli_island_png.ZD_icon_boli_island_png",
    ParachuteTips = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_Fall_island_png.ZD_Icon_Fall_island_png",
    LandingTips = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_shousan_island_png.ZD_icon_shousan_island_png"
  }
  self.BrushMap = {}
  self.MaxSmallTipsCount = 24
  self.MaxShowCount = 6
  self.SmallImageList = {}
  self.ShowingImageCount = 0
  self.ExplosionNoticeDistance = 58000
  self.ShotNoticeDistance = 58000
  self.SlienceNoticeDistance = 58000
  self.MoveNoticeDistance = 4000
  self.VehicleNoticeDistance = 15000
  self.GlassNoticeDistance = 3600
  self.ParachuteAndLandingNoticeDistance = 7000
  self.SlienceHideImgCount = 3
  self.CharacterVoiceIndex = {}
  self.ShowingSlienceIndex = {}
  self.MinWeaponShowAlpha = 0
  self.NormalPivot = FVector2D(-1, 0.5)
  self.NormalAlignment = FVector2D(1, 0.5)
  self.SliencePivot = FVector2D(-0.2, 0.5)
  self.SlienceAlignment = FVector2D(1.8, 0.5)
  self.NormalSize = FVector2D(38, 38)
  self.SlienceSize = FVector2D(38, 103)
  self.Anchors = FAnchors(1, 0.5, 1, 0.5)
  self.MinAlpha = 0.1
  self.MaxAlpha = 1
end
function MapSoundVisualization:ChangeVoiceImageBegin(_, _, MoveImagePath, HighImagePath, VehicleImagePath)
  self.CacheMovePath = MoveImagePath
  self.CacheVehiclePath = VehicleImagePath
end
function MapSoundVisualization:ProcessCache(CacheInfo)
  if self.InitFalse then
    self:InitRootPanel()
  end
  if not (not self.InitFalse and self.UIRoot and CacheInfo) or not slua.isValid(self.UIRoot) then
    return
  end
  local Direction = FVector2D(CacheInfo.PosVector.X, -CacheInfo.PosVector.Y)
  if not slua.isValid(Direction) then
    return
  end
  local Index = self.UIRoot:GetImageIndex(Direction)
  if Index >= self.MaxSmallTipsCount then
    Index = self.MaxSmallTipsCount - 1
  end
  if CacheInfo.CustomVoiceKey then
    self:AddCustomVoiceKey(CacheInfo.Character, CacheInfo.PosVector, CacheInfo.ShowTime, CacheInfo.IsWeapon, CacheInfo.IsSlience, CacheInfo.Weapon, CacheInfo.IsExplosion, Index, CacheInfo.CustomVoiceKey)
    return
  end
  local SoundType = CacheInfo.SoundType
  if SoundType == SoundVisualizationType.Shot or SoundType == SoundVisualizationType.Move then
    self:AddBaseCharater(CacheInfo.Character, CacheInfo.PosVector, CacheInfo.ShowTime, CacheInfo.IsWeapon, CacheInfo.IsSlience, CacheInfo.Weapon, CacheInfo.IsExplosion, Index)
  elseif SoundType == SoundVisualizationType.Vehicle then
    self:AddVehicle(CacheInfo.Vehicle, CacheInfo.PosVector, CacheInfo.ShowTime, Index)
  elseif SoundType == SoundVisualizationType.Glass then
    self:VoiceTipAddGlassVoice(CacheInfo.PosVector, CacheInfo.ShowTime, Index)
  elseif SoundType == SoundVisualizationType.Parachute then
    self:VoiceTipAddParachuteVoice(CacheInfo.Character, CacheInfo.PosVector, CacheInfo.ShowTime, Index)
  elseif SoundType == SoundVisualizationType.Landing then
    self:VoiceTipAddLandingVoice(CacheInfo.Character, CacheInfo.PosVector, CacheInfo.ShowTime, Index)
  end
end
function MapSoundVisualization:TriggerCustomVoice(_, _, PosVector, IconPath, ShowTime, Alpha, RelevantCharacter)
  if self.InitFalse then
    self:InitRootPanel()
  end
  if not (not self.InitFalse and self.UIRoot) or IconPath == "" then
    return
  end
  local Direction = FVector2D(PosVector.X, -PosVector.Y)
  local Index = self.UIRoot:GetImageIndex(Direction)
  if Index >= self.MaxSmallTipsCount then
    Index = self.MaxSmallTipsCount - 1
  end
  if not self.SmallImageList[Index] then
    self.SmallImageList[Index] = {}
  end
  ShowTime = ShowTime or 3
  Alpha = Alpha or 1
  if slua.isValid(RelevantCharacter) then
    if not self:CheckNeedShowVocie(RelevantCharacter) then
      return
    end
    if self.CharacterVoiceIndex[RelevantCharacter] then
      self:HideImage(self.CharacterVoiceIndex[RelevantCharacter])
    end
    self.CharacterVoiceIndex[RelevantCharacter] = Index
    self.SmallImageList[Index].Character = RelevantCharacter
  end
  self:OnShowImage(Index, Alpha, IconPath, false, ShowTime)
end
function MapSoundVisualization:VoiceTipAddGlassVoice(PosVector, ShowTime, NowIndex)
  if NowIndex < 0 or NowIndex > self.MaxSmallTipsCount then
    return
  end
  local NowDistance = PosVector:Size()
  if NowDistance <= 0 then
    NowDistance = 1
  end
  if NowDistance > self.GlassNoticeDistance then
    return
  end
  local Alpha = self:ComputeAlpha(self.GlassNoticeDistance, NowDistance)
  self:OnShowImage(NowIndex, Alpha, self.IconPath.GlassTips, false, ShowTime)
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_VOICECHECK_GLASS_INFO, NowIndex, PosVector)
end
function MapSoundVisualization:AddCustomVoiceKey(Character, PosVector, ShowTime, IsWeapon, IsSlience, Weapon, isExplosion, NowIndex, CustomVoiceKey)
  self:AddBaseCharater(Character, PosVector, ShowTime, IsWeapon, IsSlience, Weapon, isExplosion, NowIndex)
end
function MapSoundVisualization:AddBaseCharater(Character, PosVector, ShowTime, IsWeapon, IsSlience, Weapon, isExplosion, NowIndex)
  print(bWriteLog and "MapSoundVisualization:AddBaseCharater IsSlience : " .. tostring(IsSlience))
  if NowIndex < 0 or NowIndex > self.MaxSmallTipsCount then
    return
  end
  if not self.SmallImageList[NowIndex] then
    self.SmallImageList[NowIndex] = {}
  end
  if slua.isValid(Character) then
    if not self:CheckNeedShowVocie(Character) then
      return
    end
    if self.CharacterVoiceIndex[Character] then
      self:HideImage(self.CharacterVoiceIndex[Character])
    end
    self.CharacterVoiceIndex[Character] = NowIndex
    self.SmallImageList[NowIndex].  end
  local WeaponID = 0
  if slua.isValid(Weapon) then
    Character = Weapon:GetOwnerPawn()
    WeaponID = Weapon:GetWeaponID()
  end
  local NowDistance = PosVector:Size()
  if NowDistance <= 0 then
    NowDistance = 1
  end
  if IsWeapon then
    if isExplosion then
      if NowDistance > self.ExplosionNoticeDistance then
        return
      end
      local Alpha = self:ComputeAlpha(self.ExplosionNoticeDistance, NowDistance)
      self:OnShowImage(NowIndex, Alpha, self.IconPath.ExplosionTips, false, ShowTime)
    elseif IsSlience then
      if NowDistance > self.SlienceNoticeDistance then
        return
      end
      local Alpha = self:ComputeAlpha(self.SlienceNoticeDistance, NowDistance)
      self:OnShowImage(NowIndex, Alpha, self.IconPath.SlienceTips, true, ShowTime)
    elseif NowDistance <= self.ShotNoticeDistance then
      local maxDistance = self:ModifyWeaponShowDistance(WeaponID, false)
      local Alpha = self:ComputeAlpha(self.ShotNoticeDistance, NowDistance, self.MinWeaponShowAlpha)
      self:OnShowImage(NowIndex, Alpha, self.IconPath.ShotTips, false, ShowTime)
    end
    if slua.isValid(Weapon) then
      self.UIRoot:CheckSendShootRPC(Weapon, PosVector, ShowTime, IsSlience)
    end
  elseif NowDistance <= self.MoveNoticeDistance then
    local Alpha = self:ComputeAlpha(self.MoveNoticeDistance, NowDistance)
    local MovePath = self.IconPath.MoveTips
    if slua.isValid(Character) and Character.voiceCheckInParachute then
      Alpha = (Character.voiceCheckDisInParachute - NowDistance) / Character.voiceCheckDisInParachute
      if self.CacheMovePath and self.CacheMovePath ~= "" then
        MovePath = self.CacheMovePath
      end
    end
    self:OnShowImage(NowIndex, Alpha, MovePath, false, ShowTime)
    if slua.isValid(Character) then
      self.UIRoot:CheckSendStepRPC(Character, PosVector, ShowTime)
    end
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_VOICECHECK_INFO, NowIndex, Character, PosVector, IsWeapon, IsSlience, WeaponID, isExplosion)
end
function MapSoundVisualization:VoiceTipAddParachuteVoice(Character, PosVector, ShowTime, NowIndex)
  if NowIndex < 0 or NowIndex > self.MaxSmallTipsCount then
    return
  end
  local NowDistance = PosVector:Size()
  if NowDistance <= 0 then
    NowDistance = 1
  end
  if NowDistance > self.ParachuteAndLandingNoticeDistance then
    return
  end
  if not self.SmallImageList[NowIndex] then
    self.SmallImageList[NowIndex] = {}
  end
  if slua.isValid(Character) then
    if not self:CheckNeedShowVocie(Character) then
      return
    end
    if self.CharacterVoiceIndex[Character] then
      self:HideImage(self.CharacterVoiceIndex[Character])
    end
    self.CharacterVoiceIndex[Character] = NowIndex
    self.SmallImageList[NowIndex].  end
  local Alpha = self:ComputeAlpha(self.ParachuteAndLandingNoticeDistance, NowDistance)
  self:OnShowImage(NowIndex, Alpha, self.IconPath.ParachuteTips, false, ShowTime)
end
function MapSoundVisualization:VoiceTipAddLandingVoice(Character, PosVector, ShowTime, NowIndex)
  if NowIndex < 0 or NowIndex > self.MaxSmallTipsCount then
    return
  end
  local NowDistance = PosVector:Size()
  if NowDistance <= 0 then
    NowDistance = 1
  end
  if NowDistance > self.ParachuteAndLandingNoticeDistance then
    return
  end
  if not self.SmallImageList[NowIndex] then
    self.SmallImageList[NowIndex] = {}
  end
  if slua.isValid(Character) then
    if not self:CheckNeedShowVocie(Character) then
      return
    end
    if self.CharacterVoiceIndex[Character] then
      self:HideImage(self.CharacterVoiceIndex[Character])
    end
    self.CharacterVoiceIndex[Character] = NowIndex
    self.SmallImageList[NowIndex].  end
  local Alpha = self:ComputeAlpha(self.ParachuteAndLandingNoticeDistance, NowDistance)
  self:OnShowImage(NowIndex, Alpha, self.IconPath.LandingTips, false, ShowTime)
end
function MapSoundVisualization:CheckNeedShowVocie(Character)
  return true
end
function MapSoundVisualization:GetRealVoiceIndex(Index)
  if Index < 1 then
    Index = Index + self.MaxSmallTipsCount
  elseif Index > self.MaxSmallTipsCount then
    Index = Index - self.MaxSmallTipsCount
  end
  return Index
end
function MapSoundVisualization:CheckHideOtherSlienceImage(iconIndex)
  if #self.ShowingSlienceIndex == 0 then
    return
  end
  for __, value in ipairs(self.ShowingSlienceIndex) do
    print(bWriteLog and "MapSoundVisualization:CheckHideOtherSlienceImage ", value, " : ", iconIndex)
    if value ~= iconIndex then
      if math.abs(value - iconIndex) <= self.SlienceHideImgCount then
        self:HideImage(value)
        return
      elseif 0 > value - self.SlienceHideImgCount and math.abs(value + self.MaxSmallTipsCount - iconIndex) <= self.SlienceHideImgCount then
        self:HideImage(value)
        return
      elseif value + self.SlienceHideImgCount > self.MaxSmallTipsCount and math.abs(value - self.MaxSmallTipsCount - iconIndex) <= self.SlienceHideImgCount then
        self:HideImage(value)
        return
      end
    end
  end
end
function MapSoundVisualization:AddVehicle(Vehicle, PosVector, ShowTime, NowIndex)
  if NowIndex < 0 or NowIndex > self.MaxSmallTipsCount then
    return
  end
  if not self.SmallImageList[NowIndex] then
    self.SmallImageList[NowIndex] = {}
  end
  local VehiclePath = self.IconPath.VehicleTips
  if slua.isValid(Vehicle) then
    local Driver = Vehicle:GetDriver()
    if not self:CheckNeedShowVocie(Driver) then
      return
    end
    local VehicleType = Vehicle.VehicleType
    if VehicleType and SoundConfig.SpecialVehiclVoiceIcon and SoundConfig.SpecialVehiclVoiceIcon[VehicleType] and SoundConfig.SpecialVehiclVoiceIcon[VehicleType].MapIcon then
      VehiclePath = SoundConfig.SpecialVehiclVoiceIcon[VehicleType].MapIcon
    end
    if slua.isValid(Driver) and Driver.voiceCheckInParachute and self.CacheVehiclePath and self.CacheVehiclePath ~= "" then
      VehiclePath = self.CacheVehiclePath
    end
    print(bWriteLog and "MapSoundVisualization:AddVehicle V: ", dump(Vehicle))
    if self.CharacterVoiceIndex[Vehicle] then
      self:HideImage(self.CharacterVoiceIndex[Vehicle])
    end
    self.CharacterVoiceIndex[Vehicle] = NowIndex
    self.SmallImageList[NowIndex].Character = Vehicle
  end
  local NowDistance = PosVector:Size()
  if NowDistance <= 0 then
    NowDistance = 1
  end
  if NowDistance > self.VehicleNoticeDistance then
    return
  end
  local Alpha = self:ComputeAlpha(self.VehicleNoticeDistance, NowDistance)
  self:OnShowImage(NowIndex, Alpha, VehiclePath, false, ShowTime)
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_VOICECHECK_VEHICLE_INFO, NowIndex, Vehicle, PosVector)
end
function MapSoundVisualization:OnShowImage(Index, Alpha, iconPath, IsSlience, ShowTime)
  print(bWriteLog and string.format("MapSoundVisualization:OnShowImage Index: %s, ShowTime: %s", tostring(Index), tostring(ShowTime)))
  if not self.SmallImageList[Index] then
    self.SmallImageList[Index] = {}
  end
  self.UIRoot:ShowImage(Index, Alpha, iconPath, IsSlience, ShowTime)
  self:SetImageProperty(IsSlience, Index)
end
function MapSoundVisualization:SetImageProperty(IsSlience, Index)
  if IsSlience then
    self:CheckHideOtherSlienceImage(Index)
    table.insert(self.ShowingSlienceIndex, 1, Index)
  end
  self.SmallImageList[Index].end
function MapSoundVisualization:ModifyWeaponShowDistance(WeaponID, IsSlience)
  self.MinWeaponShowAlpha = 0
  if IsSlience then
    return self.ShotNoticeDistance
  end
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(uGameState) or uGameState.GameModeType ~= EGameModeCPPType.EFourInOneGameMode then
    return self.ShotNoticeDistance
  end
  local weaponType = WeaponID % 1000
  if weaponType == 101 or weaponType == 102 or weaponType == 104 or weaponType == 105 or weaponType == 106 then
    self.MinWeaponShowAlpha = 0.35
    return 27000
  end
  return self.ShotNoticeDistance
end
function MapSoundVisualization:ComputeAlpha(maxDistance, distance, minAlpha)
  if minAlpha == nil then
    minAlpha = self.MinAlpha
  end
  local distanceRat = (maxDistance - distance) / maxDistance
  local Alpha = FuncUtil.Clamp(distanceRat, minAlpha, self.MaxAlpha)
  return Alpha
end
function MapSoundVisualization:GetShowIndex(position)
  local Direction = FVector2D(position.X, -position.Y)
  Direction:Normalize(0)
  local NowAngle = math.deg(math.acos(Direction.X))
  if -position.Y < 0 then
    NowAngle = 360.0 - NowAngle
  end
  local Index = NowAngle / (360 / self.MaxSmallTipsCount)
  Index = math.ceil(Index)
  return Index
end
function MapSoundVisualization:HideImage(Index)
  self.UIRoot:ShowHideImage(Index, false)
end
function MapSoundVisualization:AfterHideImageArray(IndexArray)
  if not IndexArray then
    return
  end
  for index, value in ipairs(IndexArray) do
    self:AfterHideImage(value)
  end
end
function MapSoundVisualization:AfterHideImage(Index)
  if self.SmallImageList[Index] then
    if self.SmallImageList[Index].bIsSlience then
      self:RemoveShowingSlienceIndex(Index)
    end
    if self.UIRoot.ShowingImageCount <= 0 then
      self.UIRoot.ShowingImageCount = 0
    end
    local CurCharacter = self.SmallImageList[Index].Character
    if slua.isValid(CurCharacter) and self.CharacterVoiceIndex[CurCharacter] then
      self.CharacterVoiceIndex[CurCharacter] = nil
    end
    self.SmallImageList[Index].bIsSlience = nil
    self.SmallImageList[Index].Character = nil
  end
end
function MapSoundVisualization:RemoveShowingSlienceIndex(Index)
  for key, value in pairs(self.ShowingSlienceIndex) do
    if value == Index then
      table.remove(self.ShowingSlienceIndex, key)
      break
    end
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
local CMapSoundVisualization = class(UIBase, nil, MapSoundVisualization)
return CMapSoundVisualization