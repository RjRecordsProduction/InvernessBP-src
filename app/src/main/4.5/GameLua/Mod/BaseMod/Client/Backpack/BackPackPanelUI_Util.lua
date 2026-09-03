local BackPackPanelUI = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackPanelUI_Define")
local BackpackUtils = import("BackpackUtils")
local STExtraGameStateBase = import("STExtraGameStateBase")
local GameplayStatics = import("GameplayStatics")
local STExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
local EGameModeType = import("EGameModeType")
function BackPackPanelUI:IsInReadyStateOrSocialIsland()
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) then
    local CurGameState = uGameState:GetGameModeState()
    return CurGameState == "ReadyState" or CurGameState == "ActiveState" or uGameState.GameModeType == 18
  end
end
function BackPackPanelUI:IsInReadyState()
  local AsSTExtraGameStateBase = GameplayStatics.GetGameState(self.UIRoot)
  if Game:IsClassOf(AsSTExtraGameStateBase, STExtraGameStateBase) then
    if slua.isValid(AsSTExtraGameStateBase) then
      local State = AsSTExtraGameStateBase:GetGameModeState()
      return State == "ReadyState" or State == "ActiveState"
    else
      return false
    end
  else
    print(bWriteLog and "Get gamestatebase failed")
    return false
  end
end
function BackPackPanelUI:IsWarGameMode()
  local uGameState = GameplayStatics.GetGameState(self.UIRoot)
  if Game:IsClassOf(uGameState, STExtraGameStateBase) then
    return uGameState.GameModeType == EGameModeType.EWarGameMode
  else
    return false
  end
end
function BackPackPanelUI:IsInfectionGameMode()
  local uGameState = GameplayStatics.GetGameState(self.UIRoot)
  if Game:IsClassOf(uGameState, STExtraGameStateBase) then
    return uGameState.GameModeType == EGameModeType.EPVEInfectionGameMode
  else
    return false
  end
end
function BackPackPanelUI:IsMeleeWeapon(ItemData)
  local ItemSubType = BackpackUtils.GetItemSubType(ItemData.DefineID.TypeSpecificID)
  return ItemSubType == 108 and not ItemData.bEquipping
end
function BackPackPanelUI:IsTPlanMod()
  return STExtraModLogicSwitchLibrary.IsEnableWeaponAttachmentBindToWeapon()
end
function BackPackPanelUI:IsSinkMod()
  if self.IsSinkMode then
    return true
  end
  local uCurGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uCurGameState) and uCurGameState.WeatherSinkBackType and uCurGameState:WeatherSinkBackType() then
    self.IsSinkMode = true
    return true
  end
  return false
end
function BackPackPanelUI:IsInAllItemFilterMode()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData:GetGameState()
  local STExtraGameStateBase = import("STExtraGameStateBase")
  local EGameModeType = import("EGameModeType")
  if not slua.isValid(uGameState) or not Game:IsClassOf(uGameState, STExtraGameStateBase) then
    return false
  end
  local GameModeType = uGameState.GameModeType
  log(bWriteLog and "BackPackPanelUI:IsInAllItemFilterMode: CurGameModeType " .. uGameState.GameModeType)
  if GameModeType == EGameModeType.ETypicalGameMode or GameModeType == EGameModeType.EFourInOneGameMode or GameModeType == EGameModeType.ESocialIsland or GameModeType == EGameModeType.ETraining or GameModeType == EGameModeType.ECreativeModeGameMode then
    return true
  end
  return false
end