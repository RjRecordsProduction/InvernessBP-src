local FeatureUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureUtil")
local ActorBase = {}
local utility = require("common.utility")
local xpcallHandle = utility.ErrorMessageHandler
function ActorBase:ctor()
  self._isDisposed = false
end
function ActorBase:_PostConstruct()
  FeatureUtil.ForEachFeatureCall(self, "_PostConstruct")
end
function ActorBase:ReceiveBeginPlay()
  self._isDisposed = false
  xpcall(self.OnReceiveBeginPlay, xpcallHandle, self)
  FeatureUtil.ForEachFeatureCall(self, "ReceiveBeginPlay")
end
function ActorBase:ReceiveEndPlay(EndReason, bClearTable)
  xpcall(self.OnReceiveEndPlay, xpcallHandle, self, EndReason, bClearTable)
  local EEndPlayReason = import("EEndPlayReason")
  if self._isDisposed == false then
    FeatureUtil.ForEachFeatureCall(self, "ReceiveEndPlay", EndReason)
    if EndReason == EEndPlayReason.Destroyed then
      self.Features = {}
    end
    self:Dispose()
  end
  if bClearTable ~= false and EndReason == EEndPlayReason.Destroyed then
    slua.ClearTable(self)
  end
  self._isDisposed = true
end
function ActorBase:OnReceiveBeginPlay()
end
function ActorBase:OnReceiveEndPlay()
end
local ENetRole = import("ENetRole")
function ActorBase:IsAuthority()
  return self.Role == ENetRole.ROLE_Authority
end
function ActorBase:IsAutonomousProxy()
  return self.Role == ENetRole.ROLE_AutonomousProxy
end
function ActorBase:IsSimulated()
  return self.Role == ENetRole.ROLE_SimulatedProxy
end
function ActorBase:IsStandalone()
  if self.bIsStandalone == nil and slua.isValid(self.Object) then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    self.bIsStandalone = UKismetSystemLibrary.IsStandalone(self.Object)
  end
  return self.bIsStandalone == true
end
function ActorBase:IsDedicatedServer()
  if self.bIsDedicatedServer == nil and slua.isValid(self.Object) then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    self.bIsDedicatedServer = UKismetSystemLibrary.IsDedicatedServer(self.Object)
  end
  return self.bIsDedicatedServer == true
end
function ActorBase:AddFeature(TypeName, FeatureInstanceName)
  if FeatureInstanceName == nil then
    FeatureInstanceName = TypeName
  end
  if self[FeatureInstanceName] ~= nil then
    print(bWriteLog and string.format("ActorBase:AddFeature(%s, %s) feature has exist, return", TypeName, FeatureInstanceName))
    return
  end
  print(bWriteLog and string.format("ActorBase:AddFeature(%s, %s)", TypeName, FeatureInstanceName))
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local DynamicLuaFeatureConfig = GamePlayTools.GetCurrentConfig("DynamicLuaFeatureConfig")
  local Config = DynamicLuaFeatureConfig[TypeName]
  assert(Config ~= nil, string.format("ActorBase:AddFeature Config(%s) is not valid", TypeName))
  local ComponentAssetPath = Config.Component
  local ComponentClass = slua.loadClass(ComponentAssetPath)
  assert(slua.isValid(ComponentClass), string.format("ActorBase:AddFeature ComponentAssetPath(%s) is not valid", ComponentAssetPath))
  assert(Game:IsChildOf(ComponentClass, import("DynamicLuaFeatureComponent")), string.format("ActorBase:AddFeature ComponentAssetPath(%s) must be subclass of DynamicLuaFeatureComponent", ComponentAssetPath))
  local uComponent = ComponentClass(self.Object, FeatureInstanceName)
  if slua.isValid(uComponent) then
    local LuaFilePath = uComponent.LuaFilePath
    local Info = import("LuaFeatureInfo")()
    Info.Name = FeatureInstanceName
    Info.    uComponent.LuaFeature    CGame:RegisterComponent(uComponent)
    print(bWriteLog and string.format("ActorBase:AddFeature {%s = %s} (Component: %s, Actor = %s)", FeatureInstanceName, LuaFilePath, ComponentAssetPath, self.Object))
  end
end
function ActorBase:EnsureDynamicFeature(TypeName)
  if self[TypeName] then
    return
  end
  print(bWriteLog and string.format("ActorBase:EnsureDynamicFeature(%s)", TypeName))
  self:AddFeature(TypeName)
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CActorBase = class(CDelegateContainer, nil, ActorBase)
return CActorBase