local InteractiveFruitActor = {}
function InteractiveFruitActor:ctor()
  self.TotalCount = 1
end
function InteractiveFruitActor:ReceiveBeginPlay()
  log(bWriteLog and "InteractiveFruitActor:ReceiveBeginPlay")
  InteractiveFruitActor.__super.ReceiveBeginPlay(self)
  self.EatFruitAudioPath = "/Game/Library/Res/Actors/FruitPickup/WwiseEvent/EvoBase_WildFruit_410/Play_EvoBase_WildFruit_Eat.Play_EvoBase_WildFruit_Eat"
  self.ShakingAudioPath = "/Game/Library/Res/Actors/FruitPickup/WwiseEvent/EvoBase_WildFruit_410/Play_EvoBase_WildFruit_Leaves.Play_EvoBase_WildFruit_Leaves"
  self.SurpriseAudioPath = "/Game/Library/Res/Actors/FruitPickup/WwiseEvent/EvoBase_WildFruit_410/Play_EvoBase_WildFruit_TreasureBox.Play_EvoBase_WildFruit_TreasureBox"
  self.PlaySoundId = 0
  self.SurpriseTipsID = -1
end
function InteractiveFruitActor:MustCheckResultAfterServerClick(Character, Result, uComponent)
  log(bWriteLog and "InteractiveFruitActor:MustCheckResultAfterServerClick, Result = " .. tostring(Result))
  log(bWriteLog and "InteractiveFruitActor:MustCheckResultAfterServerClick", Character)
  InteractiveFruitActor.__super.MustCheckResultAfterServerClick(self, Character, Result, uComponent)
end
function InteractiveFruitActor:OnRep_TotalCount()
  log(bWriteLog and "InteractiveFruitActor:OnRep_TotalCount, TotalCount = " .. tostring(self.TotalCount))
  if slua.isValid(self.FruitMesh) and self.TotalCount <= 0 then
    self.FruitMesh:SetVisibility(false, false)
  end
end
function InteractiveFruitActor:OnStartedSkillAction(Character)
  log(bWriteLog and "InteractiveFruitActor:OnStartedSkillAction", Character)
  if not self.hasAuthority and self.EatFruitAudioPath then
    log(bWriteLog and "InteractiveFruitActor:OnStartedSkillAction, PlayAudioByPath = ", self.EatFruitAudioPath)
    self.PlaySoundId = self:PlayAudioByPath(self.EatFruitAudioPath)
  end
end
function InteractiveFruitActor:OnStoppedSkillAction(Character, Reason, SkillId, Component)
  if not self.hasAuthority and self.PlaySoundId > 0 then
    local AkGameplayStatics = import("AkGameplayStatics")
    AkGameplayStatics.StopPlayingID(self.PlaySoundId)
    self.PlaySoundId = 0
  end
end
function InteractiveFruitActor:MustCheckResultAfterSkillFinished(Character, Result, Component)
  InteractiveFruitActor.__super.MustCheckResultAfterSkillFinished(self, Character, Result, Component)
  log(bWriteLog and "InteractiveFruitActor:MustCheckResultAfterSkillFinished, self.hasAuthority = " .. tostring(self.hasAuthority))
  if Result == false then
    return
  end
  Component = Component or self:GetInteractiveComponent()
  if self.hasAuthority and self.BP_ProduceDropItemComponent then
    math.randomseed(os.time())
    local SurpriseRND = math.random()
    if SurpriseRND <= self.SurpriseProbability then
      local PlanRND = math.random()
      log_format(bWriteLog and "InteractiveFruitActor:MustCheckResultAfterSkillFinished, Bingo is true. SurpriseRND:%s, PlanRND:%s ", tostring(SurpriseRND), tostring(PlanRND))
      for ProduceID, Data in pairs(self.DropItemPlan) do
        local TipsID = math.tointeger(Data.X)
        local Probability = Data.Y
        if PlanRND <= Probability then
          self.BP_ProduceDropItemComponent.          self.Surprise          log(bWriteLog and "InteractiveFruitActor:MustCheckResultAfterSkillFinished, ProduceID = " .. tostring(ProduceID) .. " TipsID = " .. tostring(TipsID))
          break
        else
          PlanRND = PlanRND - Probability
        end
      end
      Character:ClientRPC_ShowEffectAfterFruitBingo(self.ShakingAudioPath, self.SurpriseAudioPath, self.SurpriseTipsID)
      self:SetStartAngleByRotation()
      self:GenerateItems(Character)
    else
      log_format(bWriteLog and "InteractiveFruitActor:MustCheckResultAfterSkillFinished, Bingo is false. SurpriseRND:%s ", tostring(SurpriseRND))
    end
  else
    self:CloseUI(Component)
  end
end
function InteractiveFruitActor:SetStartAngleByRotation()
  local Rotation = self:K2_GetActorRotation()
  log(bWriteLog and "InteractiveFruitActor:SetStartAngleByRotation, Rotation = " .. tostring(Rotation:ToString()))
  local Angle = Rotation.Yaw
  if Angle < 0 then
    Angle = 360 + Angle
  end
  local FinalAngle = math.floor(Angle) + self.BP_ProduceDropItemComponent.StartAngle
  while FinalAngle < 0 do
    FinalAngle = FinalAngle + 360
  end
  FinalAngle = math.fmod(FinalAngle, 360)
  self.BP_ProduceDropItemComponent.StartAngle = FinalAngle
end
function InteractiveFruitActor:GenerateItems(Character)
  if self.BP_ProduceDropItemComponent then
    local FDropPropData = import("DropPropData")
    local uDropDataStruct = slua.Array(UEnums.EPropertyClass.Struct, FDropPropData)
    self.BP_ProduceDropItemComponent:SetCharacterOwner(Character)
    local boxName, resultArray = self.BP_ProduceDropItemComponent:GenerateDropItemByCfg(uDropDataStruct)
    self.BP_ProduceDropItemComponent:SetCharacterOwner(nil)
    if resultArray == nil or resultArray:Num() <= 0 then
      log(bWriteLog and "InteractiveFruitActor:GenerateItems, resultArray = " .. tostring(resultArray))
      return
    end
    local FirstItem = resultArray:Get(0)
    if FirstItem == nil then
      log(bWriteLog and "InteractiveFruitActor:GenerateItems, FirstItem = nil")
      return
    end
    log(bWriteLog and "InteractiveFruitActor:GenerateItems, num = " .. tostring(resultArray:Num()))
    self.BP_ProduceDropItemComponent:StartDropWithDropData(self.Object, nil, resultArray)
  else
    log(bWriteLog and "InteractiveFruitActor:GenerateItems, BP_ProduceDropItemComponent = nil")
  end
end
local class = require("class")
local base = require("GameLua.Mod.BaseMod.GamePlay.Actor.InteractiveActorTemplate")
local CInteractiveFruitActor = class(base, nil, InteractiveFruitActor)
return CInteractiveFruitActor