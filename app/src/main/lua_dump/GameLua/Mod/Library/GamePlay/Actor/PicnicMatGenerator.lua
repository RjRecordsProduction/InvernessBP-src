local ASTExtraBaseCharacter = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
local UTSkillStopReason = import("UTSkillStopReason")
local UAkGameplayStatics = import("AkGameplayStatics")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PicnicMatGenerator = {}
function PicnicMatGenerator:ctor()
end
function PicnicMatGenerator:ReceiveBeginPlay()
  printf("PicnicMatGenerator:ReceiveBeginPlay")
  PicnicMatGenerator.__super.ReceiveBeginPlay(self)
  if self:HasAuthority() then
    self:AddGameTimer(0.1, false, function()
      local Loc = self:K2_GetActorLocation()
      local Rot = self:K2_GetActorRotation()
      if self.bAlwaysGenerate or math.random() <= self.GenerateRateProbability then
        print(bWriteLog and string.format("PicnicMatGenerator:ReceiveBeginPlay Generate Succeed at %.0f,%.0f,%.0f", Loc.X, Loc.Y, Loc.Z))
        if slua.isValid(CGameWorld) then
          self.SpawnedActor = CGameWorld:SpawnActor(self.ActorClass, Loc, Rot, nil)
          if slua.isValid(self.SpawnedActor) then
            self.SpawnedActor.GenerateRateProbability = self.GenerateRateProbability
            self.SpawnedActor.bAlwaysGenerate = self.bAlwaysGenerate
          end
        end
      else
        print(bWriteLog and string.format("PicnicMatGenerator:ReceiveBeginPlay Generate Failed at %.0f,%.0f,%.0f", Loc.X, Loc.Y, Loc.Z))
      end
    end)
  end
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CPicnicMatGeneratorCalss = class(CActorBase, nil, PicnicMatGenerator)
return CPicnicMatGeneratorCalss