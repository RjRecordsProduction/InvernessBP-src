local MapCityNameActor = {}
function MapCityNameActor:ctor(selfType)
  print(bWriteLog and "MapCityNameActor:ctor")
end
function MapCityNameActor:ReceiveBeginPlay()
  print(bWriteLog and "MapCityNameActor:ReceiveBeginPlay")
  MapCityNameActor.__super.ReceiveBeginPlay(self)
  self:SetRotationByFlightDirection()
  self:InitMaterialInstance()
  self:AdjustGraphiQuality()
  if Client then
    if not SubsystemMgr:Get("MapCityNameSubsystem") then
      local Controller = slua_GameFrontendHUD:GetPlayerController()
      Controller.BP_GameEventListener:AddCityNameActor(self)
    else
      local MapCityNameSubsystem = SubsystemMgr:Get("MapCityNameSubsystem")
      MapCityNameSubsystem:AddCityNameActor(self)
    end
    self.Location = self:K2_GetActorLocation()
  end
end
function MapCityNameActor:_PostConstruct()
  print(bWriteLog and "MapCityNameActor:_PostConstruct")
end
function MapCityNameActor:ReceiveEndPlay(EndPlayReason)
  self.MatInstanceRef = nil
  self.MatInstanceRef_Shadow = nil
  MapCityNameActor.__super.ReceiveEndPlay(self, EndPlayReason)
end
function MapCityNameActor:SetRotationByFlightDirection()
  print(bWriteLog and "MapCityNameActor:SetRotationByFlightDirection")
  if Client then
    self:AddGameTimer(1, false, function()
      local Yaw
      if not SubsystemMgr:Get("MapCityNameSubsystem") then
        local Controller = slua_GameFrontendHUD:GetPlayerController()
        Yaw = Controller.BP_GameEventListener:GetCityNameRotationYaw()
      else
        local MapCityNameSubsystem = SubsystemMgr:Get("MapCityNameSubsystem")
        Yaw = MapCityNameSubsystem:GetCityNameRotationYaw()
      end
      local Rotation = self:K2_GetActorRotation()
      Rotation.      self:K2_SetActorRotation(Rotation, false)
      self:SetActorHiddenInGame(false)
      self:OnShowActor()
    end)
  end
end
function MapCityNameActor:OnShowActor()
end
function MapCityNameActor:UpdateCityName(PlayerLocation)
  if PlayerLocation then
    local Dist = PlayerLocation.Z - self.MustFadeHeight - self.Location.Z
    if Dist > self.FadeHeight then
      self:SetMaterialInstAlpha(2.0)
    else
      Dist = FuncUtil.Clamp(Dist, 0, self.FadeHeight)
      local alphaValue = Dist / self.FadeHeight * 2
      self:SetMaterialInstAlpha(alphaValue)
      if alphaValue <= 0.0 then
        self:OnHideCityName()
      end
    end
  end
end
function MapCityNameActor:OnHideCityName()
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CMapCityNameActor = class(CActorBase, nil, MapCityNameActor)
return CMapCityNameActor