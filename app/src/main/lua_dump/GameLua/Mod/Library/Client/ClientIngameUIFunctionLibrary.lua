local ClientIngameUIFunctionLibrary = {}
function ClientIngameUIFunctionLibrary.GetInputControlPanel()
  print(bWriteLog and "ClientIngameUIFunctionLibrary.GetInputControlPanel")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  return InGameUITools.GetMainControlPanelTochButton()
end
function ClientIngameUIFunctionLibrary.QuickSignMsgToString(Msg)
  print(bWriteLog and "ClientIngameUIFunctionLibrary.QuickSignMsgToString")
  local Res = string.format("MsgID:%s Player:%s ConfigKey:%s ParamString:%s ActorGUID:%s", Msg.MsgID, Msg.PlayerName, Msg.ConfigKey, Msg.ParamString, tostring(Msg.BindActorGuid))
  return Res
end
function ClientIngameUIFunctionLibrary.CheckResultsNeedHideTitle()
  print(bWriteLog and "ClientIngameUIFunctionLibrary.CheckResultsNeedHideTitle")
  local EGameModeType = import("EGameModeType")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return false
  end
  local GameModeType = GameState.GameModeType or 0
  return GameModeType == EGameModeType.EHeavyWeaponGameMode
end
function ClientIngameUIFunctionLibrary.CheckNeedToShowBetaTips()
  print(bWriteLog and "ClientIngameUIFunctionLibrary.CheckNeedToShowBetaTips")
  local EGameModeType = import("EGameModeType")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return false
  end
  local GameModeType = GameState.GameModeType or 0
  return GameModeType == EGameModeType.EFourInOneGameMode
end
function ClientIngameUIFunctionLibrary.NeedShowVeteran()
  print(bWriteLog and "ClientIngameUIFunctionLibrary.NeedShowVeteran")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uEMentorPlayerType = import("EMentorPlayerType")
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uCurPlayerState = uPlayerController:GetCurPlayerState()
    if slua.isValid(uCurPlayerState) then
      local eMentorPlayerType = uCurPlayerState:GetMentorPlayerType()
      if eMentorPlayerType and eMentorPlayerType ~= uEMentorPlayerType.MPT_NormalPlayer then
        return true
      end
    end
  end
  return false
end
function ClientIngameUIFunctionLibrary.GetEntireMapLevelScale()
  print(bWriteLog and "ClientIngameUIFunctionLibrary.GetEntireMapLevelScale")
  return 0.002438
end
function ClientIngameUIFunctionLibrary.SnapPercentToInt(Unit, Percentage)
  print(bWriteLog and "ClientIngameUIFunctionLibrary.SnapPercentToInt")
  local Tmp = math.tointeger(Unit * 100)
  local Index = math.tointeger(Percentage / Unit)
  local Stage = Tmp * Index
  return Stage, Index
end
function ClientIngameUIFunctionLibrary.MinMaxToPercenteage(Min, Max, Cur)
  print(bWriteLog and "ClientIngameUIFunctionLibrary.MinMaxToPercenteage")
  return FuncUtil.Clamp(Cur, Min, Max)
end
function ClientIngameUIFunctionLibrary.GetPlayerVeteranIconPath(PlayerState)
  print(bWriteLog and "ClientIngameUIFunctionLibrary.GetPlayerVeteranIconPath")
  if not slua.isValid(PlayerState) then
    return
  end
  local VeteranLevel = PlayerState:GetVeteranPlayerLevel()
  local Path = ClientIngameUIFunctionLibrary.GetPlayerVeteranIconPathByLevel(VeteranLevel)
  print(bWriteLog and "ClientIngameUIFunctionLibrary.GetPlayerVeteranIconPath:" .. Path)
  return Path
end
function ClientIngameUIFunctionLibrary.GetPlayerVeteranIconPathByLevel(VeteranLevel)
  print(bWriteLog and "ClientIngameUIFunctionLibrary.GetPlayerVeteranIconPathByLevel")
  if VeteranLevel == 0 then
    return "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_duiyou_laodaixin_hui_1_png.ZD_icon_duiyou_laodaixin_hui_1_png"
  else
    local nIndex = FuncUtil.Clamp(VeteranLevel + 1, 2, 6)
    return string.format("/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_duiyou_laodaixin0%d_png.ZD_icon_duiyou_laodaixin0%d_png", nIndex, nIndex)
  end
end
function ClientIngameUIFunctionLibrary.CanBorrowVehicle(Vehicle)
  print(bWriteLog and "ClientIngameUIFunctionLibrary.CanBorrowVehicle")
  if Vehicle and slua.isValid(Vehicle) then
    local COwnerShipComponent = import("/Script/ShadowTrackerExtra.OwnershipComponent")
    local uOwnerShipComp = Vehicle:GetComponentByClass(COwnerShipComponent)
    if uOwnerShipComp and slua.isValid(uOwnerShipComp) then
      return uOwnerShipComp:CanBorrow()
    end
  end
  return false
end
return ClientIngameUIFunctionLibrary