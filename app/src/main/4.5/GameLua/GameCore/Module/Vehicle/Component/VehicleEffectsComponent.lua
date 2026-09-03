local UKismetSystemLibrary = import("KismetSystemLibrary")
local VehicleEffectsComponent = {}
function VehicleEffectsComponent:ctor()
end
function VehicleEffectsComponent:_PostConstruct()
end
function VehicleEffectsComponent:ReceiveBeginPlay()
  VehicleEffectsComponent.__super.ReceiveBeginPlay(self)
end
function VehicleEffectsComponent:InitConfig(EffectsConfig)
  print(bWriteLog and "VehicleEffectsComponent:InitConfig", UKismetSystemLibrary.GetDisplayName(self:GetOwner()))
  if EffectsConfig and next(EffectsConfig) then
    for EffectType, Entry in pairs(EffectsConfig) do
      local ClassName, Params = table.unpack(Entry)
      local EffectClass = import(ClassName)
      local Effect = CGame:NewObjectFromClass(self, EffectClass, "None")
      if slua.isValid(Effect) then
        if Params.LuaFilePath then
          Effect:BindLua(Params.LuaFilePath)
        end
        for Key, Value in pairs(Params) do
          Effect[Key] = Value
        end
        self:RegisterEffect(EffectType, Effect)
      end
    end
  end
end
local class = require("class")
local CActorComponent = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
return class(CActorComponent, nil, VehicleEffectsComponent)