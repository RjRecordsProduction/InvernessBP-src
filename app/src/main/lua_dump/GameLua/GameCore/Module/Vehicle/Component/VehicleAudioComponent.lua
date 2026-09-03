local UKismetSystemLibrary = import("KismetSystemLibrary")
local VehicleAudioComponent = {}
function VehicleAudioComponent:ctor()
end
function VehicleAudioComponent:ReceiveBeginPlay()
  VehicleAudioComponent.__super.ReceiveBeginPlay(self)
end
function VehicleAudioComponent:InitConfig(AudioConfig)
  print(bWriteLog and "VehicleAudioComponent:InitConfig", UKismetSystemLibrary.GetDisplayName(self:GetOwner()))
  if CGame and AudioConfig and next(AudioConfig) then
    for AudioType, Entry in pairs(AudioConfig) do
      local ClassName, Params = table.unpack(Entry)
      local AudioClass = import(ClassName)
      local Audio = CGame:NewObjectFromClass(self, AudioClass, "None")
      if slua.isValid(Audio) and Params.LuaFilePath then
        Audio:BindLua(Params.LuaFilePath)
      end
      for Key, Value in pairs(Params) do
        if type(Value) == "table" then
          if Value and next(Value) then
            for _, Items in pairs(Value) do
              if type(Items) == "table" then
                if Items and next(Items) then
                  local FAudioConfigWithTipsClass = import("AudioConfigWithTips")
                  local AudioConfigWithTips = FAudioConfigWithTipsClass()
                  for ItemKey, ItemValue in pairs(Items) do
                    AudioConfigWithTips[ItemKey] = ItemValue
                  end
                  Audio[Key]:Add(AudioConfigWithTips)
                end
              else
                Audio[Key] = Value
                break
              end
            end
          end
        else
          Audio[Key] = Value
        end
      end
      self:RegisterAudio(AudioType, Audio)
    end
  end
end
local class = require("class")
local CActorComponent = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
return class(CActorComponent, nil, VehicleAudioComponent)