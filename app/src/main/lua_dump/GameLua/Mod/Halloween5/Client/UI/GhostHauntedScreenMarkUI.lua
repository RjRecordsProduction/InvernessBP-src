local CommonScreenMarkUI = {
  TickInterval = 0.1,
  FinishTime = 20,
  LifeTime = 20
}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local UKismetMathLibrary = import("KismetMathLibrary")
function CommonScreenMarkUI:ctor()
  print(bWriteLog and string.format("CommonScreenMarkUI:ctor"))
end
function CommonScreenMarkUI:OnDestroy()
  self:Dispose()
end
function CommonScreenMarkUI:OnActorBindUI(BindActor)
  print(bWriteLog and string.format("CommonScreenMarkUI:OnLocationBindUI %s", BindActor))
  self:ResetUI()
end
function CommonScreenMarkUI:OnActorUnbindUI(Loc)
  self:TryRemoveNamedGameTimer("TickTimer")
end
function CommonScreenMarkUI:OnLocationBindUI(Loc)
  print(bWriteLog and string.format("CommonScreenMarkUI:OnLocationBindUI %s", Loc:ToString()))
  self:ResetUI()
end
function CommonScreenMarkUI:OnLocationUnbindUI(Loc)
  self:TryRemoveNamedGameTimer("TickTimer")
end
function CommonScreenMarkUI:ResetUI()
end
function CommonScreenMarkUI:RefreshUI()
  if self.LifeTime > 0 then
    local CurrentTime = GamePlayTools.GetServerWorldTimeSeconds()
    local RestTime = self.LifeTime - CurrentTime
    if RestTime < 0 then
      RestTime = 0
    end
    if 0 < RestTime then
      self.Text_Time:SetText(string.format("00:%02d", math.floor(RestTime)))
    end
  end
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, CommonScreenMarkUI)