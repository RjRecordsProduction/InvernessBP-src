local NGConditionIsInStandalone = {}
function NGConditionIsInStandalone:ctor(selfType, Params)
  self.bNeedStandalone = Params.bNeedStandalone
  self.ignoreMod = Params.ignoreMod
end
function NGConditionIsInStandalone:CheckConditionOK(...)
  local bStandalone = false
  local uPlayerCharacter
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
  end
  if slua.isValid(uPlayerCharacter) then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    bStandalone = UKismetSystemLibrary.IsStandalone(uPlayerCharacter)
  end
  local check1 = bStandalone == self.bNeedStandalone
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType, _ = GameMainConfig.GetModType()
  local check2 = ModType ~= self.ignoreMod
  print(bWriteLog and "NGConditionIsInStandalone:CheckConditionOK", check1, check2)
  return check1 and check2
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionIsInStandalone = class(CObject, nil, NGConditionIsInStandalone)
return CNGConditionIsInStandalone