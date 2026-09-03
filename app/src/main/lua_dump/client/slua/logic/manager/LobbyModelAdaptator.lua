local LobbyModelAdaptator = {}
local local local local local local ModelBaseCfgCache = {}
local SMALL_NUMBER = 1.0E-6
local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
local WeaponModelMgrHelper = require("client.slua.logic.manager.WeaponModelSubLogic.WeaponModelMgrHelper")
local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
local GetAdaptOriginID = function(ItemID)
  local OriginID = WeaponModelMgrHelper.GetRealResIdEnhance(ItemID, true)
  if OriginID == ItemID then
    local ItemCfg = CDataTable.GetTableData("Item", ItemID)
    if ItemCfg and ModelDisplayTypeHelper._IsIcon3D(ItemCfg.ItemType, ItemCfg.ItemSubType, ItemID) then
      OriginID = 1000
    end
  end
  return OriginID
end
local CheckArrayNum = function(Array, Num)
  return #Array == Num
end
function LobbyModelAdaptator:ctor(_)
  self.UIRestrictBox = nil
  self.LastActor = nil
  self.GetUIRestrictZoneFunc = nil
  self.GetUIRestrictZoneType = nil
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_VIEWPORT_SIZE_CHANGED, self.OnViewportSizeChanged, self)
end
function LobbyModelAdaptator:OnViewportSizeChanged(_, _, _, _)
  log(bWriteLog and "LobbyModelAdaptator OnViewportSizeChanged")
  local full_preview_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.full_preview_module)
  if full_preview_module:IsWeaponShow() then
    return true
  end
  self:SetUIRestrictZone()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.RefreshWeaponLocation()
end
function LobbyModelAdaptator:RegistGetUIRestrictZoneFunc(Func, Type)
  self.GetUIRestrictZone  self.GetUIRestrictZone  self:SetUIRestrictZone()
end
function LobbyModelAdaptator:SetUIRestrictZone()
  if not self.GetUIRestrictZoneFunc then
    return
  end
  local Zone = self.GetUIRestrictZoneFunc(self.GetUIRestrictZoneType)
  if not Zone then
    return
  end
  self:SetUIRestrictZoneInner(Zone.L, Zone.R, Zone.U, Zone.D)
end
function LobbyModelAdaptator:SetUIRestrictZoneInner(L, R, U, D)
  if self.UIRestrictBox == nil then
    self.UIRestrictBox = {}
  end
  self.UIRestrictBox.  self.UIRestrictBox.  self.UIRestrictBox.  self.UIRestrictBox.end
local AddPos = function(originalPos, offsetPos)
  local x, y, z = offsetPos.X, offsetPos.Y, offsetPos.Z
  if x then
    originalPos.X = originalPos.X + x
  end
  if y then
    originalPos.Y = originalPos.Y + y
  end
  if z then
    originalPos.Z = originalPos.Z + z
  end
end
function LobbyModelAdaptator:TriggerAdapt(ItemID, Actor, bForceInRareScene, Location)
  if not slua.isValid(Actor) then
    log_warning("LobbyModelAdaptator:TriggerAdapt Actor Not Valid")
    return false
  end
  if self.UIRestrictBox == nil then
    log_warning("LobbyModelAdaptator:TriggerAdapt UIRestrictBox Not Valid")
    return false
  end
  local BaseCfg = self:GetModelBaseCfg(ItemID)
  if not BaseCfg then
    log_warning("LobbyModelAdaptator:TriggerAdapt No Basecfg")
    return false
  end
  Actor:K2_SetActorRotation(FRotator(0, 0, 0), false)
  local SubActor = Actor.SubActor
  if slua.isValid(SubActor) then
    local Scale = tonumber(BaseCfg.Scale)
    if Scale > SMALL_NUMBER then
      SubActor:SetActorScale3D(FVector(Scale, Scale, Scale))
    end
    SubActor:K2_SetActorRotation(BaseCfg.Rotator, false)
  end
  self:CorrectCenterOffset(ItemID, Actor)
  local RealUIRestrictBox = {
    L = self.UIRestrictBox.L,
    R = self.UIRestrictBox.R,
    U = self.UIRestrictBox.U,
    D = self.UIRestrictBox.D
  }
  local UIUtil = require("client.common.ui_util")
  local ScreenPixelSize = UIUtil.GetViewportSize()
  local DPI = UIUtil.GetViewportScale()
  log(bWriteLog and "LobbyModelAdaptator DPI" .. tostring(DPI))
  local ScreenX = ScreenPixelSize.X / DPI
  local ScreenY = ScreenPixelSize.Y / DPI
  local RestrictionZoneCenterPixelPosX = 0.5 * DPI * (RealUIRestrictBox.L + ScreenX - RealUIRestrictBox.R)
  local RestrictionZoneCenterPixelPosY = 0.5 * DPI * (RealUIRestrictBox.U + ScreenY - RealUIRestrictBox.D)
  local RestrictionZoneCenterPixelPos = FVector2D(RestrictionZoneCenterPixelPosX, RestrictionZoneCenterPixelPosY)
  local ZoneCenterWorldLocation, ZoneCenterWorldDirection = UIUtil.DeprojectScreenToWorldFast(RestrictionZoneCenterPixelPos)
  local RestrictZoneScreenRect = {
    X1 = DPI * RealUIRestrictBox.L,
    X2 = ScreenPixelSize.X - DPI * RealUIRestrictBox.R,
    Y1 = DPI * RealUIRestrictBox.U,
    Y2 = ScreenPixelSize.Y - DPI * RealUIRestrictBox.D
  }
  local RestrictZoneScreenRectX = RestrictZoneScreenRect.X2 - RestrictZoneScreenRect.X1
  local RestrictZoneScreenRectY = RestrictZoneScreenRect.Y2 - RestrictZoneScreenRect.Y1
  local RealRestricZoneX, RealRestricZoneY
  RealRestricZoneY = RestrictZoneScreenRectY
  RealRestricZoneX = RestrictZoneScreenRectX
  local ItemStandardOccupyZoneCfg = BaseCfg.ZoneRatio
  local ActualRect = {
    X = RealRestricZoneX * ItemStandardOccupyZoneCfg.XRatio,
    Y = RealRestricZoneY * ItemStandardOccupyZoneCfg.YRatio
  }
  local NewLocation
  local ZoneUseY = BaseCfg.ZoneUseY
  if Location then
    New  elseif not ZoneUseY or ZoneUseY == 0 then
    local SamplePointL = {
      X = RestrictionZoneCenterPixelPosX - 0.5 * ActualRect.X,
      Y = RestrictionZoneCenterPixelPosY
    }
    local SamplePointR = {
      X = RestrictionZoneCenterPixelPosX + 0.5 * ActualRect.X,
      Y = RestrictionZoneCenterPixelPosY
    }
    local WorldLocationL, WorldDirectionL = UIUtil.DeprojectScreenToWorldFast(FVector2D(SamplePointL.X, SamplePointL.Y))
    local WorldLocationR, WorldDirectionR = UIUtil.DeprojectScreenToWorldFast(FVector2D(SamplePointR.X, SamplePointR.Y))
    local Len = FVector.Distance(WorldLocationL, WorldLocationR)
    local ItemAABB = BaseCfg.AABB
    local LenRatio = Len / ItemAABB.X
    local PlayerController = slua_GameFrontendHUD:GetPlayerController()
    local CameraLocation = PlayerController:GetViewTarget():K2_GetActorLocation()
    local Delta = FVector(ZoneCenterWorldLocation.X - CameraLocation.X, ZoneCenterWorldLocation.Y - CameraLocation.Y, ZoneCenterWorldLocation.Z - CameraLocation.Z)
    NewLocation = CameraLocation + FVector(Delta.X / LenRatio, Delta.Y / LenRatio, Delta.Z / LenRatio)
    log(bWriteLog and "LobbyModelAdaptator useX SamplePointLX : " .. SamplePointL.X .. "SamplePointRX: " .. SamplePointL.Y)
    log(bWriteLog and "LobbyModelAdaptator  useX SamplePointR: " .. SamplePointR.X .. "SamplePointR: " .. SamplePointR.Y)
  else
    local SamplePointL = {
      X = RestrictionZoneCenterPixelPosX,
      Y = RestrictionZoneCenterPixelPosY - 0.5 * ActualRect.Y
    }
    local SamplePointR = {
      X = RestrictionZoneCenterPixelPosX,
      Y = RestrictionZoneCenterPixelPosY + 0.5 * ActualRect.Y
    }
    local WorldLocationL, WorldDirectionL = UIUtil.DeprojectScreenToWorldFast(FVector2D(SamplePointL.X, SamplePointL.Y))
    local WorldLocationR, WorldDirectionR = UIUtil.DeprojectScreenToWorldFast(FVector2D(SamplePointR.X, SamplePointR.Y))
    local Len = FVector.Distance(WorldLocationL, WorldLocationR)
    local ItemAABB = BaseCfg.AABB
    local LenRatio = Len / ItemAABB.Y
    local PlayerController = slua_GameFrontendHUD:GetPlayerController()
    local CameraLocation = PlayerController:GetViewTarget():K2_GetActorLocation()
    local Delta = FVector(ZoneCenterWorldLocation.X - CameraLocation.X, ZoneCenterWorldLocation.Y - CameraLocation.Y, ZoneCenterWorldLocation.Z - CameraLocation.Z)
    NewLocation = CameraLocation + FVector(Delta.X / LenRatio, Delta.Y / LenRatio, Delta.Z / LenRatio)
    log(bWriteLog and "LobbyModelAdaptator useY SamplePointLX : " .. SamplePointL.X .. "SamplePointRX: " .. SamplePointL.Y)
    log(bWriteLog and "LobbyModelAdaptator  useY SamplePointR: " .. SamplePointR.X .. "SamplePointR: " .. SamplePointR.Y)
  end
  local RLocation = BaseCfg.RLocation
  if RLocation then
    AddPos(NewLocation, RLocation)
  end
  Actor:K2_SetActorLocation(NewLocation, false, nil, false)
  return true
end
function LobbyModelAdaptator:CorrectCenterOffset(ItemID, Actor)
  local ModelBaseCfg = self:GetModelBaseCfg(ItemID)
  if not ModelBaseCfg then
    return false
  end
  local SubActor = Actor.SubActor
  if slua.isValid(SubActor) then
    SubActor:K2_SetActorRelativeLocation(FVector(ModelBaseCfg.CenterOffset.X, ModelBaseCfg.CenterOffset.Y, ModelBaseCfg.CenterOffset.Z), false, nil, false)
  end
  return true
end
function LobbyModelAdaptator:GetModelBaseCfg(ItemID)
  local OriginID = GetAdaptOriginID(ItemID)
  if OriginID == ItemID then
    local ItemCfg = CDataTable.GetTableData("Item", ItemID)
    if ItemCfg then
      local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
      if ModelDisplayTypeHelper._IsIcon3D(ItemCfg.ItemType, ItemCfg.ItemSubType, ItemID) then
        OriginID = 1000
      end
    end
  end
  if ModelBaseCfgCache[OriginID] then
    return ModelBaseCfgCache[OriginID]
  end
  local OriginCfg = CDataTable.GetTableData("LobbyModelAdaptBaseCfg", OriginID)
  if OriginCfg == nil then
    ShowDevNotice("###[\228\187\133Dev\231\148\159\230\149\136] \229\164\167\229\142\133\230\168\161\229\158\139\228\189\141\231\189\174\233\128\130\233\133\141\232\161\168\230\178\161\233\133\141 ID:" .. tostring(OriginID))
    log(bWriteLog and "LobbyModelAdaptator GetModelBaseCfg Error, No Cfg In Table, ItemID:" .. OriginID)
    return nil
  end
  local Ret = {}
  local StringUtil = require("common.string_util")
  local ZoneRatioArray = StringUtil.Split(OriginCfg.ZoneRatio, "|")
  if not CheckArrayNum(ZoneRatioArray, 2) then
    log(bWriteLog and "LobbyModelAdaptator GetModelBaseCfg Error, Fail To Parse Zone Ratio, ItemID:" .. OriginID)
    ZoneRatioArray = {0.9, 0.9}
  end
  Ret.ZoneRatio = {
    XRatio = tonumber(ZoneRatioArray[1]),
    YRatio = tonumber(ZoneRatioArray[2])
  }
  local Scale = tonumber(OriginCfg.Scale)
  local AABBArray = StringUtil.Split(OriginCfg.AABB, "|")
  if not CheckArrayNum(AABBArray, 2) then
    log(bWriteLog and "LobbyModelAdaptator GetModelBaseCfg Error, Fail To Parse AABBArray, ItemID:" .. OriginID)
    AABBArray = {40, 20}
  end
  Ret.AABB = {
    X = tonumber(AABBArray[1]) * Scale,
    Y = tonumber(AABBArray[2]) * Scale
  }
  local CenterOffset = StringUtil.Split(OriginCfg.CenterOffset, "|")
  if not CheckArrayNum(CenterOffset, 3) then
    log(bWriteLog and "LobbyModelAdaptator GetModelBaseCfg Error, Fail To Parse CenterOffset, ItemID:" .. OriginID)
    CenterOffset = {
      0,
      0,
      0
    }
  end
  Ret.CenterOffset = {
    X = tonumber(CenterOffset[1]) * Scale,
    Y = tonumber(CenterOffset[2]) * Scale,
    Z = tonumber(CenterOffset[3]) * Scale
  }
  Ret.  Ret.ZoneUseY = OriginCfg.ZoneUseY
  local RotatorArray = StringUtil.Split(OriginCfg.Rotator, "|")
  if not CheckArrayNum(RotatorArray, 3) then
    log(bWriteLog and "LobbyModelAdaptator GetModelBaseCfg Error, Fail To Parse RotatorArray, ItemID:" .. OriginID)
    RotatorArray = {
      0,
      0,
      0
    }
  end
  local KismetMathLibrary = import("KismetMathLibrary")
  Ret.Rotator = KismetMathLibrary.MakeRotator(tonumber(RotatorArray[1]), tonumber(RotatorArray[2]), tonumber(RotatorArray[3]))
  local VehOffset = StringUtil.Split(OriginCfg.VehOffset, "|")
  if not CheckArrayNum(VehOffset, 3) then
    log(bWriteLog and "LobbyModelAdaptator GetModelBaseCfg Error, Fail To Parse VehOffset, ItemID:" .. OriginID)
    VehOffset = {
      0,
      0,
      0
    }
  end
  Ret.VehOffset = {
    X = tonumber(VehOffset[1]),
    Y = tonumber(VehOffset[2]),
    Z = tonumber(VehOffset[3])
  }
  Ret.VehScale = tonumber(OriginCfg.VehScale)
  local VehRotator = StringUtil.Split(OriginCfg.VehRotator, "|")
  if not CheckArrayNum(VehRotator, 3) then
    log(bWriteLog and "LobbyModelAdaptator GetModelBaseCfg Error, Fail To Parse VehRotator, ItemID:" .. OriginID)
    VehRotator = {
      0,
      0,
      0
    }
  end
  Ret.VehRotator = KismetMathLibrary.MakeRotator(tonumber(VehRotator[1]), tonumber(VehRotator[2]), tonumber(VehRotator[3]))
  local RLocationArray = StringUtil.Split(OriginCfg.RLocation, "|")
  if CheckArrayNum(RLocationArray, 3) then
    Ret.RLocation = {
      X = tonumber(RLocationArray[1]),
      Y = tonumber(RLocationArray[2]),
      Z = tonumber(RLocationArray[3])
    }
  end
  ModelBaseCfgCache[OriginID] = Ret
  return Ret
end
function LobbyModelAdaptator:TryAdaptVehicleInGarage(ItemID, Actor, bForceInRareScene)
  if not slua.isValid(Actor) then
    return
  end
  if not slua.isValid(Actor.DefaultSceneRoot) then
    return
  end
  local AdaptCfg = self:GetModelBaseCfg(ItemID)
  if not AdaptCfg then
    return
  end
  local Parent = Actor.DefaultSceneRoot:GetAttachParent()
  local LadderCarDetailConfig = require("client.slua.logic.lobby_activity.LadderCarDetailConfig")
  if bForceInRareScene or LadderCarDetailConfig.IsRareCar(ItemID) or slua.isValid(Parent) then
    local SubActor = Actor.SubActor
    if slua.isValid(SubActor) then
      local Scale = tonumber(AdaptCfg.VehScale)
      if Scale and Scale > SMALL_NUMBER then
        SubActor:SetActorScale3D(FVector(Scale, Scale, Scale))
      end
      SubActor:K2_SetActorRelativeLocation(FVector(0, 0, 0), false, nil, false)
      Actor:K2_SetActorRelativeRotation(FRotator(0, 0, 0), false, nil, false)
      SubActor:K2_SetActorRelativeRotation(FRotator(0, 0, 0), false, nil, false)
    end
  end
  if not slua.isValid(Parent) then
    return
  end
  local Owner = Parent:GetOwner()
  if not slua.isValid(Owner) then
    return
  end
  if Owner:ActorHasTag("VehicleAttachPoint") then
    Actor:K2_SetActorRelativeLocation(FVector(AdaptCfg.VehOffset.X, AdaptCfg.VehOffset.Y, AdaptCfg.VehOffset.Z), false, nil, false)
    Actor:K2_SetActorRelativeRotation(FRotator(AdaptCfg.VehRotator.Pitch, AdaptCfg.VehRotator.Yaw, AdaptCfg.VehRotator.Roll), false, nil, false)
  end
end
function LobbyModelAdaptator:Destroy()
  self:Dispose()
end
local class = require("class")
local object = require("common.delegate_container")
local CLobbyModelAdaptator = class(object, nil, LobbyModelAdaptator)
return CLobbyModelAdaptator