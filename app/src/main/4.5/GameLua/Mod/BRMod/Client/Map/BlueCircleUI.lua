local BlueCircleUI = {}
local STExtraMapFunctionLibrary = import("STExtraMapFunctionLibrary")
local UGameplayStatics = import("GameplayStatics")
function BlueCircleUI:ctor(selfType)
  printf("BlueCircleUI:ctor")
  self.TickRat = 0.5
  self.BlueCircleScale2D = FVector2D(1, 1)
  self.bHasClosedCustomCircle = false
  self.bIsClosed = false
  self._LastAppliedScale = -1
  self._LastAppliedCoordX = nil
  self._LastAppliedCoordY = nil
  self._LastFullRingVis = nil
  self._LastRingFXVis = nil
end
function BlueCircleUI:_SetVisCached(UI, IsShow, CacheKey)
  if self[CacheKey] == IsShow then
    return
  end
  self[CacheKey] = IsShow
  self:SetVisible(UI, IsShow)
end
function BlueCircleUI:OnInitialize()
  printf("BlueCircleUI:OnInitialize")
end
function BlueCircleUI:OnPostInitialize()
  printf("BlueCircleUI:OnPostInitialize")
  BlueCircleUI.__super.OnPostInitialize(self)
  self:InitColor(self.UIRoot.BlueFullImage)
  self:InitColor(self.UIRoot.blueImage1)
  self:InitColor(self.UIRoot.blueImage2)
  self:InitColor(self.UIRoot.blueImage3)
  self:InitColor(self.UIRoot.blueImage4)
end
function BlueCircleUI:RegistEvents()
  print(bWriteLog and "BlueCircleUI:RegistEvents")
  BlueCircleUI.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_CHANGE_MAP_TEXTURE, self.HandlechangeMap, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_CHANGE_MAP_TEXTURE_WITHOUT_TAGS, self.HandlechangeMap, self)
end
function BlueCircleUI:Close()
  printf("BlueCircleUI:Close")
  self.bIsClosed = true
  BlueCircleUI.__super.Close(self)
end
function BlueCircleUI:BindMapUIBase(MapUI)
  if not MapUI then
    print(bWriteLog and "BlueCircleUI:BindMapUIBase - MapUI is nil")
    return
  end
  self.MapUIBase = MapUI.CurrentMapUI
  self.  self.RealTimeInfo = slua.IndexReference(self.MapUIBase, "MapRealTimeInfoC")
  self:BindLuaObjEvent(MapUI, "OnEntireMapOpen", self.OnEnterMap, self)
  self:BindLuaObjEvent(MapUI, "OnChangeMapSize", self.OnMapSizeReset, self)
end
function BlueCircleUI:InitUI(ParentUI)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_REFRESHMAPLEGEND_WITHLAYER, self.HandleChangeMapTexture, self)
  self:RefreshSelfVisibility()
  local UIUtil = require("client.common.ui_util")
  local uGameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
  if slua.isValid(uGameState) and uGameState.BlueCircle then
    self.InBlueCircle = slua.IndexReference(uGameState, "BlueCircle")
  end
  if ParentUI and ParentUI.UIRoot and ParentUI.UIRoot.CommonFunctionAddPanel then
    self:SetVisible(self.UIRoot, true)
    ParentUI:AttachChildWindow("CommonFunctionAddPanel", self)
    self.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
    self.UIRoot.Slot:SetOffsets(FMargin(0, 0, 0, 0))
    self:OnMapSizeReset()
    if not self.TickWidgetTimer and self:IsNeedTick() then
      self.TickWidgetTimer = self:AddGameTimer(self.TickRat, true, function()
        self:TickWidget()
      end)
    end
  else
    self:SetVisible(self.UIRoot, false)
  end
end
function BlueCircleUI:IsNeedTick()
  if self.MapUI.bIsShow then
    return true
  else
    return false
  end
end
function BlueCircleUI:OnMapSizeReset()
  local bIsSizeSame = self.CurrentSize ~= nil and self.CurrentSize == self.MapUIBase.MapImageExtentC
  local bIsCenterSame = self.CurrentCenter ~= nil and self.CurrentCenter == self.MapUIBase.LevelLandScapeCenterC
  if bIsSizeSame and bIsCenterSame then
    return
  end
  self.CurrentSize = self.MapUIBase.MapImageExtentC
  self.CurrentCenter = self.MapUIBase.LevelLandScapeCenterC
  self.UIRoot.Border_RingFX.Slot:SetSize(FVector2D(self.CurrentSize, self.CurrentSize))
  self:CommonTick()
end
function BlueCircleUI:TickWidget()
  self:CommonTick()
end
function BlueCircleUI:CommonTick()
  if not self.bIsClosed then
    local UIUtil = require("client.common.ui_util")
    local uGameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
    if not slua.isValid(uGameState) or not uGameState.GetCurCircleWave then
      return
    end
    if not slua.isValid(self.InBlueCircle) then
      if slua.isValid(slua.IndexReference(uGameState, "BlueCircle")) then
        self.InBlueCircle = slua.IndexReference(uGameState, "BlueCircle")
      end
      if not self.InBlueCircle then
        print(bWriteLog and "BlueCircleUI:CommonTick - self.InBlueCircle is nil")
        return
      end
    end
    if uGameState:GetCurCircleWave() <= -1 or self.InBlueCircle:IsZero() then
      self:_SetVisCached(self.UIRoot.Border_FullRing, false, "_LastFullRingVis")
      self:_SetVisCached(self.UIRoot.Border_RingFX, false, "_LastRingFXVis")
    elseif self.InBlueCircle.Z < 1000.0 then
      self:_SetVisCached(self.UIRoot.Border_FullRing, true, "_LastFullRingVis")
      self:_SetVisCached(self.UIRoot.Border_RingFX, false, "_LastRingFXVis")
    else
      self:_SetVisCached(self.UIRoot.Border_FullRing, false, "_LastFullRingVis")
      self:_SetVisCached(self.UIRoot.Border_RingFX, true, "_LastRingFXVis")
      if not slua.isValid(self.MapUIBase) or not slua.isValid(self.RealTimeInfo) then
        return
      end
      local BlueCircleScale
      BlueCircleScale = self.RealTimeInfo.BlueCircleRadius * self.MapUIBase.ImageBlueCircleScale
      if self._LastAppliedScale ~= BlueCircleScale then
        self.BlueCircleScale2D.X = BlueCircleScale
        self.BlueCircleScale2D.Y = BlueCircleScale
        self.UIRoot.Border_RingFX:SetRenderScale(self.BlueCircleScale2D)
        self._LastAppliedScale = BlueCircleScale
      end
      local Coord = self.RealTimeInfo.BlueCircleCoord
      if self._LastAppliedCoordX ~= Coord.X or self._LastAppliedCoordY ~= Coord.Y then
        self.UIRoot.Border_RingFX:SetRenderTranslation(Coord)
        self._LastAppliedCoordX = Coord.X
        self._LastAppliedCoordY = Coord.Y
      end
      if not self.bHasClosedCustomCircle and BlueCircleScale ~= 0 then
        self.bHasClosedCustomCircle = true
        self.MapUI:CloseCustomBlueWidget()
      end
    end
  end
end
function BlueCircleUI:SetVisible(UI, IsShow)
  if IsShow then
    UI:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    UI:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function BlueCircleUI:InitColor(BlueImage)
  local UIUtil = require("client.common.ui_util")
  local uGameFrontendHUD = UIUtil.GetGameFrontendHUD()
  local ColorBlindnessMgr = uGameFrontendHUD:GetColorBlindnessMgr()
  if not slua.isValid(ColorBlindnessMgr) then
    print(bWriteLog and "BlueCircleUI:InitColor FAILED Case ColorBlindnessMgr is Not Valid")
    return
  end
  ColorBlindnessMgr:AddImage(BlueImage, FLinearColor(1, 1, 1, 1), 1)
end
function BlueCircleUI:OnMapShow(_, __, IsShowEntireMap)
  print(bWriteLog and "BlueCircleUI:OnMapShow " .. tostring(IsShowEntireMap) .. " : " .. tostring(self.MapUI.bIsMiniMap))
  if IsShowEntireMap ~= self.MapUI.bIsMiniMap then
    self:CommonTick()
  end
end
function BlueCircleUI:HandlechangeMap()
  self:CommonTick()
end
function BlueCircleUI:OnEnterMap(isEntireMap)
  print(bWriteLog and "BlueCircleUI:OnEnterMap \239\188\154 " .. tostring(isEntireMap) .. "  : " .. tostring(self.MapUI.bIsMiniMap))
  if isEntireMap ~= self.MapUI.bIsMiniMap then
    self.MapUIBase:ReCalMapInfoC()
    self:TickWidget()
    if not self.TickWidgetTimer then
      self.TickWidgetTimer = self:AddGameTimer(self.TickRat, true, function()
        self:TickWidget()
      end)
    end
  elseif self.TickWidgetTimer then
    self:RemoveGameTimer(self.TickWidgetTimer)
    self.TickWidgetTimer = nil
  end
end
function BlueCircleUI:HandleChangeMapTexture()
  self:RefreshSelfVisibility()
end
function BlueCircleUI:RefreshSelfVisibility()
  local CanShow = self:CanShow()
  print(bWriteLog and string.format("BlueCircleUI:RefreshSelfVisibility CanShow = %s", CanShow))
  if CanShow == nil then
    return
  end
  self:SetVisible(self.UIRoot.CanvasPanel_Root, CanShow)
  self:CommonTick()
end
function BlueCircleUI:CanShow()
  print(bWriteLog and "BlueCircleUI:CanShow in")
  local MapIconSubsystem = SubsystemMgr:Get("MapIconSubsystem")
  if not MapIconSubsystem then
    print(bWriteLog and "BlueCircleUI:CanShow PlayerCharacter MapIconSubsystem nil")
    return
  end
  local PlayerCharacter
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uOwnerActorController = GameplayData.GetPlayerController()
  if slua.isValid(uOwnerActorController) and uOwnerActorController.IsSpectator and uOwnerActorController:IsSpectator() then
    PlayerCharacter = uOwnerActorController:GetCurPawn()
  else
    PlayerCharacter = GameplayData.GetPlayerCharacter()
  end
  if not (PlayerCharacter and slua.isValid(PlayerCharacter)) or PlayerCharacter.bNotShowBlueCircleUI == nil then
    print(bWriteLog and "BlueCircleUI:CanShow PlayerCharacter nil")
    return
  end
  print(bWriteLog and "BlueCircleUI:CanShow in" .. tostring(PlayerCharacter.bNotShowBlueCircleUI) .. tostring(MapIconSubsystem.bBaltic))
  if PlayerCharacter.bNotShowBlueCircleUI and not MapIconSubsystem.bBaltic then
    return false
  else
    return true
  end
end
function BlueCircleUI:IsDungeonCanShowBlueCircle()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerState = GameplayData.GetPlayerState()
  local IsInDungeon = slua.isValid(uPlayerState) and uPlayerState.IsInDungeon and uPlayerState:IsInDungeon()
  if IsInDungeon then
  end
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.Map.MapWidget.MapWidgetBase")
local CBlueCircleUI = class(UIBase, nil, BlueCircleUI)
return CBlueCircleUI