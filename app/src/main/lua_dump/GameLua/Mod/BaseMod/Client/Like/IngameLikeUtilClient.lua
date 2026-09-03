local IngameLikeUtilClient = {}
local RP_OPEN_MODE = {
  101,
  102,
  103,
  401,
  402,
  403,
  111,
  112,
  113,
  411,
  412,
  413,
  703,
  713,
  723,
  733,
  1703,
  1713,
  2703,
  2713
}
function IngameLikeUtilClient.IsLikeSwitchOpen()
  if BP_ENUM_Like_INGAME_SWITCH and LobbySystem and LobbySystem.CheckOpen and not LobbySystem.CheckOpen(BP_ENUM_Like_INGAME_SWITCH) then
    return false
  end
  return true
end
function IngameLikeUtilClient.GetTeammateCount()
  local PlayerState = IngameLikeUtilClient.GetMyPlayerState()
  if not slua.isValid(PlayerState) or not PlayerState.GetTeamMatePlayerStateList then
    return 0
  end
  local TeammatePlayerState = PlayerState:GetTeamMatePlayerStateList({}, true)
  if TeammatePlayerState == nil then
    return 0
  end
  local count = 0
  for _, _ in pairs(TeammatePlayerState) do
    count = count + 1
  end
  return count
end
function IngameLikeUtilClient.GetTeammateNameByUID(UID)
  if not UID then
    return
  end
  local PlayerState = IngameLikeUtilClient.GetMyPlayerState()
  if not slua.isValid(PlayerState) then
    return
  end
  local TeammatePlayerState = PlayerState:GetTeamMatePlayerStateList({}, true)
  if TeammatePlayerState == nil then
    return nil
  end
  for _, Teammatestate in pairs(TeammatePlayerState) do
    if Teammatestate and Teammatestate.UID == UID then
      return Teammatestate.PlayerName
    end
  end
  return nil
end
function IngameLikeUtilClient.GetTeammateUIDByPlayerKey(PlayerKey)
  local PlayerState = IngameLikeUtilClient.GetMyPlayerState()
  if not slua.isValid(PlayerState) then
    return
  end
  local TeammatePlayerState = PlayerState:GetTeamMatePlayerStateList({}, true)
  if TeammatePlayerState == nil then
    return nil
  end
  for _, Teammatestate in pairs(TeammatePlayerState) do
    if Teammatestate and Teammatestate.PlayerKey == PlayerKey then
      return Teammatestate.UID
    end
  end
  return nil
end
function IngameLikeUtilClient.GetTeammateIndexByPlayerUID(UID)
  local PlayerState = IngameLikeUtilClient.GetMyPlayerState()
  if not slua.isValid(PlayerState) then
    return
  end
  local TeammatePlayerState = PlayerState:GetTeamMatePlayerStateList({}, true)
  if TeammatePlayerState == nil then
    return nil
  end
  for Index, Teammatestate in pairs(TeammatePlayerState) do
    if Teammatestate and Teammatestate.UID == UID then
      return Index + 1
    end
  end
  return nil
end
function IngameLikeUtilClient.GetItemNameByItemID(ItemID)
  if not ItemID or type(ItemID) ~= "number" then
    return ""
  end
  local uItemData = CDataTable.GetTableData("Item", ItemID)
  local ItemName = uItemData and uItemData.ItemName or ""
  return ItemName
end
function IngameLikeUtilClient.IsSelfAlive()
  local MyPlayerState = IngameLikeUtilClient.GetMyPlayerState()
  if not slua.isValid(MyPlayerState) then
    return
  end
  return Game:IsPlayerAlive(MyPlayerState.PlayerKey)
end
function IngameLikeUtilClient.HasAliveTeammate(bExcludeSelf)
  local PlayerState = IngameLikeUtilClient.GetMyPlayerState()
  if not slua.isValid(PlayerState) or not PlayerState.GetTeamMatePlayerStateList then
    return
  end
  local TeammatePlayerState = PlayerState:GetTeamMatePlayerStateList({}, bExcludeSelf or true)
  if TeammatePlayerState == nil then
    return
  end
  for _, Teammatestate in pairs(TeammatePlayerState) do
    if Teammatestate and not Game:IsPlayerAlive(Teammatestate.PlayerKey) then
      return true
    end
  end
  return false
end
function IngameLikeUtilClient.GetMyPlayerState()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  return uPlayerController.PlayerState
end
function IngameLikeUtilClient.ParseLikeMsg(Message, LikeCfg)
  if not LikeCfg then
    print(bWriteLog and "[IngameLikeUtilClient] invalid like config")
    return
  end
  local PlayerState = IngameLikeUtilClient.GetMyPlayerState()
  if not slua.isValid(PlayerState) then
    print(bWriteLog and "[IngameLikeUtilClient] invalid playerstate")
    return
  end
  if not LikeCfg.TipMessageID then
    print(bWriteLog and "[IngameLikeUtilClient] no tip msg")
    return
  end
  local Msg = LocUtil.GetLocalizeResStr(LikeCfg.TipMessageID)
  if not LikeCfg.TipMessageStyle then
    return Msg
  end
  local Replace0, Replace1, Replace2
  if LikeCfg.TipMessageStyle == 1 then
    if PlayerState.PlayerKey == Message.PlayerKey then
      Replace0 = LocUtil.GetLocalizeResStr(10008)
      Replace1 = IngameLikeUtilClient.GetTeammateNameByUID(Message.OtherPlayerUID)
    elseif PlayerState.UID == Message.OtherPlayerUID then
      local UID = IngameLikeUtilClient.GetTeammateUIDByPlayerKey(Message.PlayerKey)
      Replace0 = IngameLikeUtilClient.GetTeammateNameByUID(UID)
      Replace1 = LocUtil.GetLocalizeResStr(10008)
    else
      local UID = IngameLikeUtilClient.GetTeammateUIDByPlayerKey(Message.PlayerKey)
      Replace0 = IngameLikeUtilClient.GetTeammateNameByUID(UID)
      Replace1 = IngameLikeUtilClient.GetTeammateNameByUID(Message.OtherPlayerUID)
    end
  elseif LikeCfg.TipMessageStyle == 2 then
    if PlayerState.PlayerKey == Message.PlayerKey then
      Replace0 = LocUtil.GetLocalizeResStr(10008)
      Replace1 = IngameLikeUtilClient.GetItemNameByItemID(Message.ItemID)
      Replace2 = IngameLikeUtilClient.GetTeammateNameByUID(Message.OtherPlayerUID)
    elseif PlayerState.UID == Message.OtherPlayerUID then
      local UID = IngameLikeUtilClient.GetTeammateUIDByPlayerKey(Message.PlayerKey)
      Replace0 = IngameLikeUtilClient.GetTeammateNameByUID(UID)
      Replace1 = IngameLikeUtilClient.GetItemNameByItemID(Message.ItemID)
      Replace2 = LocUtil.GetLocalizeResStr(10008)
    else
      local UID = IngameLikeUtilClient.GetTeammateUIDByPlayerKey(Message.PlayerKey)
      Replace0 = IngameLikeUtilClient.GetTeammateNameByUID(UID)
      Replace1 = IngameLikeUtilClient.GetItemNameByItemID(Message.ItemID)
      Replace2 = IngameLikeUtilClient.GetTeammateNameByUID(Message.OtherPlayerUID)
    end
  elseif LikeCfg.TipMessageStyle == 0 then
    if PlayerState.PlayerKey == Message.PlayerKey then
      Replace0 = LocUtil.GetLocalizeResStr(10008)
    else
      local UID = IngameLikeUtilClient.GetTeammateUIDByPlayerKey(Message.PlayerKey)
      Replace0 = IngameLikeUtilClient.GetTeammateNameByUID(UID)
    end
  end
  if Replace0 then
    Msg = string.gsub(Msg, "{0}", Replace0)
  end
  if Replace1 then
    Msg = string.gsub(Msg, "{1}", Replace1)
  end
  if Replace2 then
    Msg = string.gsub(Msg, "{2}", Replace2)
  end
  return Msg
end
function IngameLikeUtilClient.CheckIsRpGiveOpen()
  local IngameLikeUtilClient = require("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
  local team_mate_num = IngameLikeUtilClient.GetTeammateCount()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not UnknowPassSystem or not UnknowPassSystem.IsInCurSession then
    log(bWriteLog and "[CL]IngameLikeUtilClient:CheckIsOpen rp switch close")
    return false
  elseif not UnknowPassSystem or not UnknowPassSystem.IsBuyElite then
    log(bWriteLog and "[CL]IngameLikeUtilClient:CheckIsOpen rp buy close")
    return false
  elseif not (DataMgr and DataMgr.season_id) or DataMgr.season_id < 20 then
    log(bWriteLog and "[CL]IngameLikeUtilClient:CheckIsOpen SeasonID close = " .. tostring(DataMgr.season_id))
    return false
  elseif not (LobbySystem and LobbySystem.CheckOpen) or not LobbySystem.CheckOpen(BP_ENUM_RP_GIVE_INGAME_SWITCH) then
    log(bWriteLog and "[CL]IngameLikeUtilClient:CheckIsOpen SeasonID Menu Close")
    return false
  elseif not team_mate_num or team_mate_num < 1 then
    log(bWriteLog and "[CL]IngameLikeUtilClient:CheckIsOpen SeasonID TeamSize Close =" .. tostring(team_mate_num))
    return false
  elseif slua.isValid(uPlayerController) and uPlayerController.IsSpectator and (uPlayerController:IsSpectator() or uPlayerController.bIsForReplay) then
    log(bWriteLog and "[CL]IngameLikeUtilClient:CheckIsOpen ob close")
    return false
  end
  if slua.isValid(uPlayerController) and uPlayerController.IsInPetSpectator and uPlayerController:IsInPetSpectator() then
    log(bWriteLog and "[CL]IngameLikeUtilClient:CheckIsOpen IsInPetSpectator close")
    return false
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    return false
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if LogicUGC:IsUGCGameMod() then
    log(bWriteLog and "[DeanJYT] IngameLikeUtilClient.CheckIsRpGiveOpen in ugc mode, should not show")
    return false
  end
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  local game_mode = logic_enter_game:GetSubModeId() or 1001
  if tonumber(game_mode) >= 22107 and tonumber(game_mode) <= 22112 then
    log(bWriteLog and "[CL]IngameLikeUtilClient:CheckIsOpen Open")
    return true
  end
  log(bWriteLog and "IngameLikeUtilClient:CheckIsOpen mode = " .. tostring(game_mode))
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local modeid = logic_mode_selection:GetCurSelectInfo()
  if not modeid then
    return false
  end
  for k, v in ipairs(RP_OPEN_MODE) do
    if v == modeid then
      return true
    end
  end
  return false
end
return IngameLikeUtilClient