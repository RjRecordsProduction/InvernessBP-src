local GodTrialPlayerController = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function GodTrialPlayerController:ctor()
end
function GodTrialPlayerController:_PostConstruct()
  GodTrialPlayerController.__super._PostConstruct(self)
  if Client then
    self:AddControlEvent(self, "OnSetViewTarget", self.HandleOnSetViewTarget, self)
  end
end
function GodTrialPlayerController:ReceiveBeginPlay()
  GodTrialPlayerController.__super.ReceiveBeginPlay(self)
end
function GodTrialPlayerController:ReceiveEndPlay(EndPlayReason)
  GodTrialPlayerController.__super.ReceiveEndPlay(self, EndPlayReason)
end
function GodTrialPlayerController:HandleOnDebugQuadrupedMove(bIsRun, DirectionX, DirectionY, DirectionZ)
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local IsDevelopment = USTExtraBlueprintFunctionLibrary.IsDevelopment()
  if not GamePlayTools.IsEditor() and not IsDevelopment then
    return
  end
  if math.abs(DirectionX) <= 0.1 then
    DirectionX = 0
  end
  if math.abs(DirectionY) <= 0.2 then
    DirectionY = 0
  end
  local ErrorCode = 0
  local IsStop = math.abs(DirectionX) < 0.05 and math.abs(DirectionY) < 0.05
  if slua.isValid(CGameState.uCacheCentaur) and slua.isValid(CGameState.uCacheCentaur:GetController()) then
    ErrorCode = 1
    local uAIActionComp = CGameState.uCacheCentaur:GetController():GetComponentByClass(import("AIActionExecutionComponent"))
    if slua.isValid(uAIActionComp) then
      ErrorCode = 2
      uAIActionComp:DoActionMoveNew(IsStop, true, DirectionX, DirectionY, DirectionZ, 0)
    end
  end
  print(bWriteLog and string.format("PlayerController:HandleOnDebugQuadrupedMove bIsRun:%s DirectionX:%s DirectionY:%s DirectionZ:%s. ErrorCode:%s", tostring(bIsRun), tostring(DirectionX), tostring(DirectionY), tostring(DirectionZ), tostring(ErrorCode)))
end
function GodTrialPlayerController:HandleOnSetViewTarget(uNewTarget)
  printf("GodTrialPlayerController:HandleOnSetViewTarget PlayerKey:%u  uNewTarget:%s", self.PlayerKey, Game:GetObjName(uNewTarget))
  local uKillerTrackerClass = import("KillerTracker")
  if slua.isValid(uNewTarget) and uKillerTrackerClass and Game:IsClassOf(uNewTarget, uKillerTrackerClass) and slua.isValid(self.DeadTombBox) and slua.isValid(self.DeadTombBox.DamageCauser) and self.DeadTombBox.DamageCauser:ActorHasTag("Centaur") then
    printf("GodTrialPlayerController:HandleOnSetViewTarget 2 PlayerKey:%u", self.PlayerKey)
    self:AddTimerOnce(1, function()
      printf("GodTrialPlayerController:HandleOnSetViewTarget 3 PlayerKey:%u", self.PlayerKey)
      if slua.isValid(uNewTarget) and uNewTarget.ForceEnd then
        uNewTarget:ForceEnd()
      end
    end)
  end
end
local class = require("class")
local CPlayerController = require("GameLua.Mod.BRMod.Gameplay.Core.BRPlayerControllerBase")
local CGodTrialPlayerController = class(CPlayerController, nil, GodTrialPlayerController)
return require("combine_class").DeclareFeature(CGodTrialPlayerController, {
  {
    BattleFlagOBArmorFeature = "GameLua.ExtraModule.SkillCore.Gameplay.BattleFlag.Feature.PlayerControllerBattleFlagOBArmorFeature"
  }
}, "GodTrialPlayerController")