local IngameLikeClientSubSystem = {lastEnterCircleIndex = -1}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local IngameLikeConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.IngameLikeConfig")
local IngameLikeUtilClient = require("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
function IngameLikeClientSubSystem:OnInit()
  print(bWriteLog and "[IngameLikeClientSubSystem] OnInit")
  self:Dispose()
  self.bIsMVP = false
  self.bNeedClientReady = false
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local uPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  self.SuspendingLikeData = {}
  self.CurMessage = {}
  self.bHasBattleResultProtectEnter = false
  self:AddControlEvent(uPlayerController, "OnGameStateChange", self.OnGameStateChange, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SYNC_CIRCILE_INFO, self.OnSyncCircleInfo, self)
  self:AddControlEvent(uPlayerController, "OnPlayerInOutWhiteCircleChangedDelegate", function(bIsPlayerInWhiteCircle)
    print(bWriteLog and "IngameLikeClientSubSystem OnPlayerInOutWhiteCircleChangedDelegate", bIsPlayerInWhiteCircle, self.bHasBattleResult)
    if self.bHasBattleResult then
      return
    end
    self:OnPlayerCircleChange(bIsPlayerInWhiteCircle)
  end)
  self:AddControlEvent(uPlayerController, "OnPlayerInOutBlueCircleChangedDelegate", function(bIsPlayerOutBlueCircle)
    print(bWriteLog and "IngameLikeClientSubSystem OnPlayerInOutBlueCircleChangedDelegate", bIsPlayerOutBlueCircle, self.bHasBattleResult)
    if self.bHasBattleResult then
      return
    end
    self:OnPlayerCircleChange(not bIsPlayerOutBlueCircle)
  end)
  self:SendReadyAfterPlayerState()
  self.IsGameFinish = false
  self:AddCommonEvent(EVENTTYPE_INGAME_SKILL, EVENTID_MVP_STATUE_SUCCESS, self.OnMvpStatueSuccess, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_REPLY_VOICE_RECOMMENDATION, self.OnQuickResponse, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_TACTICAL_MARK_WHEEL, self.OnTacticalMark, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, function()
    self.bHasBattleResult = true
  end, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_HIDE_ALL_UI, self.OnHideAllUIEvent, self)
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ENTER_PROTECT, self.OnBattleResultEnterProtect, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerQuitSpectatingForClient", self.OnPlayerQuitSpectatingForClient_Handle, self)
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  self.give_remain_times = UpassHandle.GetLargessMaxCount()
  self:OnRepPlayerState()
  self.add_friend_list = {}
  self.rp_give_time = {}
end
function IngameLikeClientSubSystem:Destroy()
  print(bWriteLog and "[IngameLikeClientSubSystem] Destroy")
  self.lastEnterCircleIndex = -1
end
function IngameLikeClientSubSystem:OnGameStateChange(State)
  if State == "FightingState" then
    print(bWriteLog and "[IngameLikeClientSubSystem] Change to Fight State")
    self:CloseAllLikeUI()
  end
end
function IngameLikeClientSubSystem:OnHideAllUIEvent()
  print(bWriteLog and "IngameLikeClientSubSystem:OnHideAllUIEvent")
  if UIManager.IsUIShow(UIManager.UI_Config_InGame.IngameLikeUIBP) then
    UIManager.HideUI(UIManager.UI_Config_InGame.IngameLikeUIBP)
  end
end
function IngameLikeClientSubSystem:OnRepPlayerState()
  if self.bHasBattleResult then
    if UIManager.UI_Config_InGame.PlayerInfoCard then
      UIManager.CloseUI(UIManager.UI_Config_InGame.PlayerInfoCard)
    end
    return
  end
  if not UIManager.UI_Config_InGame.IngameSocialUIBP or not UIManager.UI_Config_InGame.IngameTeamUIBP then
    return
  end
  if UIManager.UI_Config_InGame.IngameSocialUIBP then
    if not self:IsIngameSocialOn() then
      UIManager.CloseUI(UIManager.UI_Config_InGame.IngameSocialUIBP)
    else
      UIManager.ShowUI(UIManager.UI_Config_InGame.IngameSocialUIBP)
    end
  end
  local IngameTeamUIBP = UIManager.GetUI(UIManager.UI_Config_InGame.IngameTeamUIBP)
  if IngameTeamUIBP then
    IngameTeamUIBP:RefreshTeamList()
  end
  if self.bNeedClientReady then
    local PlayerController = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(PlayerController) then
      print(bWriteLog and "[IngameLikeClientSubSystem:OnRepPlayerState] invalid playerController")
      return
    end
    local uPlayerState = PlayerController.PlayerState
    print(bWriteLog and "IngameLikeClientSubSystem:OnRepPlayerState", uPlayerState)
    if slua.isValid(uPlayerState) then
      self:SendClientReady(PlayerController.PlayerKey, PlayerController.TeamID)
    end
  end
end
function IngameLikeClientSubSystem:OnPlayerQuitSpectatingForClient_Handle()
  self:OnRepPlayerState()
end
function IngameLikeClientSubSystem:OnBattleResultEnterProtect()
  print(bWriteLog and "IngameLikeClientSubSystem:OnBattleResultEnterProtect")
  self.bHasBattleResultProtectEnter = true
  self:OnHideAllUIEvent()
end
function IngameLikeClientSubSystem:IsUGCEdtitorMode()
  if not slua.isValid(CGameState) then
    return false
  end
  if CGameState.IsCreativeMode == nil then
    return false
  end
  local ECreativeModeGameType = import("ECreativeModeGameType")
  if not CGameState:IsCreativeMode() then
    return false
  end
  if CGameState:GetInitializeGameType() == ECreativeModeGameType.CreativeModeGameType_Editor then
    return true
  end
  return false
end
function IngameLikeClientSubSystem:IsIngameSocialOn()
  if self:IsUGCEdtitorMode() then
    print(bWriteLog and "IsIngameSocialOn UGC close")
    return false
  end
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) then
    local EGameModeCPPType = import("EGameModeType")
    if uGameState.GameModeType == EGameModeCPPType.EDeathMatchGameMode or uGameState.GameModeType == EGameModeCPPType.EXAndT then
      print(bWriteLog and "IsIngameSocialOn mode close")
      return false
    end
    if uGameState.bIsTrainingMode then
      print(bWriteLog and "IsIngameSocialOn train close")
      return false
    end
  end
  if LobbySystem and LobbySystem.CheckOpen and not LobbySystem.CheckOpen(BP_ENUM_SOCIAL_INGAME_SWITCH) then
    print(bWriteLog and "IsIngameSocialOn switch close")
    return false
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if DevicePlatformNameMacros.IsPC() then
    print(bWriteLog and "IsIngameSocialOn Platform close")
    return false
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.IsSpectatorOrDemoPlayer and uPlayerController:IsSpectatorOrDemoPlayer() then
    print(bWriteLog and "IsIngameSocialOn IsSpectatorOrDemoPlayer close")
    return false
  end
  if slua.isValid(uPlayerController) and uPlayerController.IsInPetSpectator and uPlayerController:IsInPetSpectator() then
    print(bWriteLog and "IsIngameSocialOn IsInPetSpectator close")
    return
  end
  local uPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(uPlayerState) and uPlayerState.GetTeammateCount and uPlayerState:GetTeammateCount() <= 1 then
    print(bWriteLog and "IsIngameSocialOn team size close")
    return false
  end
  print(bWriteLog and "IsIngameSocialOn team open")
  return true
end
function IngameLikeClientSubSystem:GetTeamMateList()
  local PlayerState = GameplayData.GetPlayerState()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerState) or not slua.isValid(PlayerCharacter) then
    return {}
  end
  local team_mate = {}
  self.TeamMatePlayerStateList = PlayerState:GetTeamMatePlayerStateList({}, true)
  for _, Teammatestate in pairs(self.TeamMatePlayerStateList) do
    if Teammatestate and PlayerState.UID ~= Teammatestate.UID and PlayerCharacter.STExtraPlayerState then
      local player_state = {}
      player_state.UID = Teammatestate.UID
      player_state.PlayerName = Teammatestate.PlayerName
      player_state.TeamIndex = PlayerCharacter.STExtraPlayerState:GetTeamMateIndex(Teammatestate)
      player_state.Online = not Teammatestate.isLostConnection
      table.insert(team_mate, player_state)
    end
  end
  return team_mate
end
function IngameLikeClientSubSystem:GetRemainTimes()
  return self.give_remain_times
end
function IngameLikeClientSubSystem:SendGiveRP(UID, PlayerName, RpNum)
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_upass_send_battle_largess_req(g_game_id or 0, UID)
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local PlayerState = PlayerCharacter:GetPlayerStateSafety()
  if not slua.isValid(PlayerState) then
    return {}
  end
  if slua.isValid(PlayerController) then
    local info = {}
    info.send_name = PlayerState.PlayerName
    info.receive_name = PlayerName
    info.rp_num = RpNum
    self.rp_send_  end
end
function IngameLikeClientSubSystem:OnSendGiveRPSuccess(err_code, left_send_count)
  self.give_remain_times = left_send_count
  self.give_remain_times = math.max(self.give_remain_times, 0)
  self:OnRepPlayerState()
  if self.rp_send_info then
    local type = 1
    local RpNum = self.rp_send_info.rp_num or 0
    local sender_name = self.rp_send_info.send_name or ""
    local receiver_name = self.rp_send_info.receive_name or ""
    local IngameLikeUtilClient = require("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
    local PlayerState = IngameLikeUtilClient.GetMyPlayerState()
    if err_code ~= 0 then
      type = 2
    end
    local PlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(PlayerController) and slua.isValid(PlayerState) then
      local bIsShowRpPlusTips = UnknowPassSystem and UnknowPassSystem.Season >= 59 and UnknowPassSystem.IsBuyElite and UnknowPassSystem.PassType == 2
      local NicknameColorManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NicknameColorManager)
      local NicknameColor = NicknameColorManager:GetUserData(DataMgr.roleData.uid)
      local bIsShowGoldenName = NicknameColor ~= NicknameColorManager.DEFAULT_PLAN_ID
      PlayerController.IngameLikeFeature:RPC_Server_RPGive(PlayerState.PlayerKey, type, RpNum, sender_name, receiver_name, bIsShowRpPlusTips, bIsShowGoldenName)
    end
    self.rp_send_info = nil
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_RP_TIMES, self.give_remain_times)
end
function IngameLikeClientSubSystem:ChangeCheckNotice(isCheck)
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:SetAutoReplyReq(isCheck)
end
function IngameLikeClientSubSystem:OnSyncCircleInfo()
  print(bWriteLog and "[IngameLikeClientSubSystem] OnSyncCircleInfo")
  local uGamestate = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(uGamestate) then
    print(bWriteLog and "[IngameLikeClientSubSystem] invalid gameState")
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) or not uPlayerController.GetPlayerCharacterSafety then
    print(bWriteLog and "[IngameLikeClientSubSystem] invalid playerController")
    return
  end
  local uCharacter = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uCharacter) then
    print(bWriteLog and "[IngameLikeClientSubSystem] invalid character")
    return
  end
  local characterLoc = uCharacter:K2_GetActorLocation()
  if not CGameState:IsInWhiteCircle(characterLoc) then
    return
  end
  self.lastEnterCircleIndex = uGamestate:GetCurCircleIndex()
  print(bWriteLog and "[IngameLikeClientSubSystem] auto change circle index: " .. tostring(self.lastEnterCircleIndex))
end
function IngameLikeClientSubSystem:OnPlayerCircleChange(bIsPlayerInCircle)
  print(bWriteLog and "[IngameLikeClientSubSystem] OnPlayerCircleChange: " .. tostring(bIsPlayerInCircle))
  if not bIsPlayerInCircle then
    return
  end
  local uGamestate = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(uGamestate) then
    print(bWriteLog and "[IngameLikeClientSubSystem] invalid gameState")
    return
  end
  local curCircleIndex = uGamestate:GetCurCircleIndex()
  if not curCircleIndex then
    print(bWriteLog and "[IngameLikeClientSubSystem] nil circle index")
    return
  end
  print(bWriteLog and "[IngameLikeClientSubSystem] enter circle: " .. tostring(curCircleIndex))
  if curCircleIndex <= self.lastEnterCircleIndex then
    return
  end
  self.lastEnterCircleIndex = curCircleIndex
  self:SendPlayerEnterCircle(curCircleIndex)
end
function IngameLikeClientSubSystem:SendReadyAfterPlayerState()
  print(bWriteLog and "[IngameLikeClientSubSystem] SendReadyAfterPlayerState")
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "[IngameLikeClientSubSystem] invalid playerController")
    return
  end
  local PlayerState = PlayerController.PlayerState
  if slua.isValid(PlayerState) then
    print(bWriteLog and "IngameLikeClientSubSystem:SendReadyAfterPlayerState", PlayerState)
    self:SendClientReady(PlayerController.PlayerKey, PlayerController.TeamID)
  else
    print(bWriteLog and "IngameLikeClientSubSystem:SendReadyAfterPlayerState bNeedClientReady")
    self.bNeedClientReady = true
  end
end
function IngameLikeClientSubSystem:SendClientReady(PlayerKey, TeamID)
  print(bWriteLog and "[IngameLikeClientSubSystem] SendClientReady", PlayerKey, TeamID)
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.IngameLikeFeature then
    PlayerController.IngameLikeFeature:RPC_Server_ClientReady(PlayerKey, TeamID)
  end
end
function IngameLikeClientSubSystem:SendPlayerEnterCircle(CircleIndex)
  print(bWriteLog and "[IngameLikeClientSubSystem] SendPlayerEnterCircle")
  if not IngameLikeUtilClient.HasAliveTeammate(true) then
    return
  end
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "[IngameLikeClientSubSystem] invalid playerController")
    return
  end
  PlayerController.IngameLikeFeature:RPC_Server_ClientEnterCircle(PlayerController.PlayerKey, PlayerController.TeamID, CircleIndex)
end
function IngameLikeClientSubSystem:ReceiveHideLike(ConditionID)
  print(bWriteLog and "[IngameLikeClientSubSystem] ReceiveHideLike ConditionID: " .. tostring(ConditionID))
  local IngameLikeUIBP = UIManager.GetUI(UIManager.UI_Config_InGame.IngameLikeUIBP)
  if IngameLikeUIBP and IngameLikeUIBP.CurShowingType == ConditionID then
    IngameLikeUIBP:Hide(ConditionID)
  end
end
function IngameLikeClientSubSystem:ReceiveTirggerLike(Message)
  print(bWriteLog and "[IngameLikeClientSubSystem] ReceiveTirggerLike: " .. tostring(Message.ConditionID))
  if self.bHasBattleResultProtectEnter then
    return
  end
  if not IngameLikeUtilClient.IsLikeSwitchOpen() then
    print(bWriteLog and "[IngameLikeClientSubSystem] lobby switch check failed")
    return
  end
  local PlayerState = IngameLikeUtilClient.GetMyPlayerState()
  if not slua.isValid(PlayerState) then
    print(bWriteLog and "[IngameLikeClientSubSystem] invalid playerstate")
    return
  end
  if self.IsGameFinish or self.bIsMVP then
    print(bWriteLog and "ShowIngameLikeUIBP23", Message.ConditionID)
    return
  elseif Message.ConditionID == IngameLikeConfig.Win then
    self.IsGameFinish = true
  end
  local Config = IngameLikeConfig[Message.ConditionID]
  if not Config then
    print(bWriteLog and "[IngameLikeClientSubSystem] invalid config")
    return
  end
  self:CheckShowLikeTypeText(Message)
  if not Config.bForbitChat then
    local Msg = IngameLikeUtilClient.ParseLikeMsg(Message, Config)
    if Msg then
      local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
      InGameUITools.DisplayMessageInGame(Msg)
    end
  end
  if Config.bUseStack and self.CurMessage and self.CurMessage.ConditionID and self.CurMessage.ConditionID > 0 and UIManager.IsUIShow(UIManager.UI_Config_InGame.IngameLikeUIBP) then
    self.SuspendingLikeData = self:CopyTable(self.CurMessage)
    log_tree("IngameLikeClientSubSystem:ReceiveTirggerLike cache SuspendingLikeData", self.SuspendingLikeData)
  end
  self.CurMessage = self:CopyTable(Message)
  if self.CurMessage then
    self.CurMessage.Count = self.CurMessage.Count or 0
  end
  local bCanLike = true
  if PlayerState.PlayerKey == Message.PlayerKey and not Config.bSelfCanSend then
    bCanLike = false
  end
  if bCanLike then
    self:ShowIngameLikeUIBP(Message, false)
  end
end
function IngameLikeClientSubSystem:ReceiveTriggerWatchLike(Message)
  print(bWriteLog and "[IngameLikeClientSubSystem] ReceiveTriggerWatchLike: " .. tostring(Message.ConditionID), self.bHasBattleResultProtectEnter)
  if self.bHasBattleResultProtectEnter then
    return
  end
  if not IngameLikeUtilClient.IsLikeSwitchOpen() then
    print(bWriteLog and "[IngameLikeClientSubSystem] lobby switch check failed")
    return
  end
  local PlayerState = IngameLikeUtilClient.GetMyPlayerState()
  if not slua.isValid(PlayerState) then
    print(bWriteLog and "[IngameLikeClientSubSystem] invalid playerstate")
    return
  end
  if self.IsGameFinish then
    return
  elseif Message.ConditionID == IngameLikeConfig.Win then
    self.IsGameFinish = true
  end
  local Config = IngameLikeConfig[Message.ConditionID]
  if not Config or Config.BoardcastType == IngameLikeConfig.EBoardcastType.OnlyForAlive then
    print(bWriteLog and "[IngameLikeClientSubSystem] invalid config")
    return
  end
  if self.CurMessage then
    self.CurMessage.ConditionID = Message.ConditionID
    self.CurMessage.Count = 0
  end
  local bCanLike = true
  if PlayerState.PlayerKey == Message.PlayerKey and not Config.bSelfCanSend then
    bCanLike = false
  end
  if bCanLike then
    self:ShowIngameWatchLikeUIBP(Message, false)
  end
end
function IngameLikeClientSubSystem:OnMvpStatueSuccess()
  print(bWriteLog and "IngameLikeClientSubSystem:OnMvpStatueSuccess", LobbySystem.CheckOpen(BP_ENUM_RESULT_MVP_STATUE_LIKE), self.bIsMVP)
  if LobbySystem.CheckOpen(BP_ENUM_RESULT_MVP_STATUE_LIKE) and self.bIsMVP then
    print(bWriteLog and "MVPStatueInteractUI:SendLike")
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(uPlayerController) then
      return
    end
    local IngameLikeConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.IngameLikeConfig")
    local config = IngameLikeConfig[6]
    local PlayerKey = uPlayerController:GetCurPawn().PlayerKey
    self:SendLike(PlayerKey, 6)
    local Data = CDataTable.GetTableData("IngameLikeConfigTable", config.TeamChatMessageID)
    if Data then
      local StringUtil = require("common.string_util")
      local MsgIDs = StringUtil.Split(Data.Value, " ")
      local Random = math.random(1, #MsgIDs)
      self:SendTeamChat(MsgIDs[Random], PlayerKey, config.ConditionID)
    end
  end
end
function IngameLikeClientSubSystem:OnQuickResponse(_, _, RecommendType)
  print(bWriteLog and "IngameLikeClientSubSystem:OnQuickResponse", RecommendType)
  local IngameLikeConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.IngameLikeConfig")
  local Message = {}
  Message.PlayerKey = 0
  Message.OtherPlayerUID = 0
  Message.ConditionID = IngameLikeConfig.QuickResponse
  Message.ItemID = 0
  self:ReceiveTirggerLike(Message)
end
function IngameLikeClientSubSystem:OnTacticalMark(_, _, MarkType)
  print(bWriteLog and "IngameLikeClientSubSystem:OnTacticalMark", MarkType)
  local IngameLikeConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.IngameLikeConfig")
  local Message = {}
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  Message.PlayerKey = slua.isValid(PlayerController) and PlayerController.PlayerKey or 0
  Message.OtherPlayerUID = 0
  Message.ConditionID = IngameLikeConfig.TacticalMark
  Message.ItemID = 0
  self:ReceiveTirggerLike(Message)
end
function IngameLikeClientSubSystem:SendLike(PlayerKey, ConditionID)
  print(bWriteLog and "[IngameLikeClientSubSystem] SendLike, PlayerKey: " .. tostring(PlayerKey) .. " ConditionID: " .. tostring(ConditionID))
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) or ConditionID == nil or PlayerKey == nil then
    return
  end
  uPlayerController.IngameLikeFeature:RPC_Server_Like(PlayerKey, ConditionID)
end
function IngameLikeClientSubSystem:ReceiveLike(Message)
  print(bWriteLog and "[IngameLikeClientSubSystem] ReceiveLike: " .. Message.UID, self.bIsMVP)
  if self.bIsMVP or self.bHasBattleResultProtectEnter then
    return
  end
  self:ShowIngameLikeUIBP(Message, true)
end
function IngameLikeClientSubSystem:SendRespondLike(ConditionID, UID)
  print(bWriteLog and "[IngameLikeClientSubSystem] SendRespondLike: " .. tostring(ConditionID))
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not (slua.isValid(uPlayerController) and ConditionID) or not UID then
    return
  end
  uPlayerController.IngameLikeFeature:RPC_Server_RespondLike(UID, ConditionID)
end
function IngameLikeClientSubSystem:ReceiveLikeProgress(ConditionID)
  print(bWriteLog and "[IngameLikeClientSubSystem] ReceiveLikeProgress condition: " .. tostring(ConditionID))
  if self.CurMessage and self.CurMessage.ConditionID and self.CurMessage.ConditionID == ConditionID then
    self.CurMessage.Count = self.CurMessage.Count or 0
    self.CurMessage.Count = self.CurMessage.Count + 1
    print(bWriteLog and "[IngameLikeClientSubSystem] ReceiveLikeProgress count: " .. tostring(self.CurMessage.Count))
    local bIsSoleLike = IngameLikeConfig.SoleLikeType and IngameLikeConfig.SoleLikeType[ConditionID]
    if bIsSoleLike and self.CurMessage.Count == 1 and self.PendingSoleLikeConditionID == ConditionID and self.PendingSoleLikeChatMsg then
      local HistoricalNewsUI = UIManager.GetUI(UIManager.UI_Config_InGame.HistoricalNewsUI)
      if HistoricalNewsUI then
        HistoricalNewsUI:AddGreatMark({}, self.PendingSoleLikeChatMsg, self.PendingSoleLikeContent or "")
      end
      print(bWriteLog and string.format("IngameLikeClientSubSystem:ReceiveLikeProgress - SoleLike show ConditionID:%d", ConditionID))
      self.PendingSoleLikeChatMsg = nil
      self.PendingSoleLikeContent = nil
      self.PendingSoleLikeConditionID = nil
    end
  elseif self.SuspendingLikeData and self.SuspendingLikeData.ConditionID == ConditionID then
    self.SuspendingLikeData.Count = self.SuspendingLikeData.Count or 0
    self.SuspendingLikeData.Count = self.SuspendingLikeData.Count + 1
    print(bWriteLog and "IngameLikeClientSubSystem:ReceiveLikeProgress ConditionID", self.SuspendingLikeData.ConditionID, self.SuspendingLikeData.Count)
  end
  if UIManager.IsUIShow(UIManager.UI_Config_InGame.IngameLikeUIBP) then
    local IngameLikeUIBP = UIManager.GetUI(UIManager.UI_Config_InGame.IngameLikeUIBP)
    IngameLikeUIBP:SetProgress()
  end
  if UIManager.IsUIShow(UIManager.UI_Config_InGame.Ingame_WatchLike_UIBP) then
    local Ingame_WatchLike_UIBP = UIManager.GetUI(UIManager.UI_Config_InGame.Ingame_WatchLike_UIBP)
    Ingame_WatchLike_UIBP:SetProgress()
  end
end
function IngameLikeClientSubSystem:ReceiveRpGiveNotify(Message, bIsShowRpPlusTips, bIsShowGoldenNickName)
  print(bWriteLog and "[IngameLikeClientSubSystem] ReceiveRpGiveNotify")
  local localize_id = 87400
  if bIsShowGoldenNickName and bIsShowRpPlusTips then
    localize_id = 87403
  elseif bIsShowGoldenNickName then
    localize_id = 87401
  elseif bIsShowRpPlusTips then
    localize_id = 87402
  end
  if bIsShowRpPlusTips then
    local tipsKey = 87611
    if bIsShowGoldenNickName then
      tipsKey = 87612
    end
    local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
    IngameTipsTools.BattleNormalTips(LocUtil.LocalizeResFormat(tipsKey, Message.sender_name, Message.receiver_name, tostring(Message.RpNum)))
  end
  if not FuncUtil or not LocUtil.LocalizeResFormat then
    return
  end
  local txt = LocUtil.LocalizeResFormat(localize_id, Message.sender_name, Message.receiver_name, tostring(Message.RpNum))
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  InGameUITools.DisplayMessageInGame(txt)
end
function IngameLikeClientSubSystem:ReceiveKillNumChange(Message)
  print(bWriteLog and "[IngameLikeClientSubSystem] ReceiveKillNumChange")
end
function IngameLikeClientSubSystem:SendTeamChat(MsgID, PlayerKey, ConditionID)
  print(bWriteLog and "[IngameLikeClientSubSystem] SendTeamChat")
  if not MsgID then
    print(bWriteLog and "[IngameLikeClientSubSystem] invalid msg id")
    return
  end
  if ConditionID and PlayerKey and (ConditionID == IngameLikeConfig.Start or ConditionID == IngameLikeConfig.Win) then
    PlayerKey = ""
  end
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "[[IngameLikeClientSubSystem] invalid playerController")
    return
  end
  print(bWriteLog and "[IngameLikeClientSubSystem] SendTeamChat, MsgID: " .. tostring(MsgID) .. " ConditionID: " .. tostring(ConditionID), PlayerKey)
  local ChatComponent = PlayerController:GetChatComponent()
  local bIsMultiLike = ConditionID and IngameLikeConfig.MultiLikeType and IngameLikeConfig.MultiLikeType[ConditionID]
  if bIsMultiLike and slua.isValid(ChatComponent) then
    ChatComponent.pendingMultiLikeReply = true
    print(bWriteLog and string.format("[IngameLikeClientSubSystem] SendTeamChat - set pendingMultiLikeReply ConditionID:%d", ConditionID))
  end
  local bIsSoleLikeMsg = ConditionID and IngameLikeConfig.SoleLikeType and IngameLikeConfig.SoleLikeType[ConditionID]
  if bIsSoleLikeMsg and slua.isValid(ChatComponent) then
    ChatComponent.pendingSoleLikeMsg = true
    print(bWriteLog and string.format("[IngameLikeClientSubSystem] SendTeamChat - set pendingSoleLikeMsg ConditionID:%d", ConditionID))
  end
  PlayerController:SendStringMsgWithTransform("", MsgID, 0, tostring(PlayerKey) or "0", 0, 0, true)
end
function IngameLikeClientSubSystem:ShowIngameLikeUIBP(Message, bShowShakeHand)
  local bOpenLike = self:GetSettingConfig("UseIngameLike")
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController.IngameLikeFeature:RPC_Server_LikeSwitch(bOpenLike and 1 or 0)
  end
  if not bOpenLike then
    print(bWriteLog and "[IngameLikeClientSubSystem] bOpenLike check failed")
    return
  end
  if not IngameLikeUtilClient.IsLikeSwitchOpen() then
    print(bWriteLog and "[IngameLikeClientSubSystem] lobby switch check failed")
    return
  end
  print(bWriteLog and "IngameLikeClientSubSystem:ShowIngameLikeUIBP bIsMVP", self.bIsMVP, LobbySystem.CheckOpen(BP_ENUM_RESULT_MVP_STATUE_LIKE))
  if self.bIsMVP and LobbySystem.CheckOpen(BP_ENUM_RESULT_MVP_STATUE_LIKE) then
    return
  end
  if UIManager.IsUIShow(UIManager.UI_Config_InGame.IngameLikeUIBP) then
    UIManager.HideUI(UIManager.UI_Config_InGame.IngameLikeUIBP)
  end
  local IngameLikeUIBP = UIManager.ShowUI(UIManager.UI_Config_InGame.IngameLikeUIBP)
  if IngameLikeUIBP then
    IngameLikeUIBP:RefreshView(Message, bShowShakeHand)
  end
end
function IngameLikeClientSubSystem:GetSettingConfig(PropertyName)
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return false
  end
  local Setting = SettingSubsystem:GetUserSettings_Bool(PropertyName)
  print(bWriteLog and "IngameLikeClientSubSystem:GetSettingConfig", PropertyName, Setting)
  if Setting == nil or Setting == true then
    return true
  end
  return false
end
function IngameLikeClientSubSystem:ShowIngameWatchLikeUIBP(message, bReply)
  print(bWriteLog and "[IngameLikeClientSubSystem] ShowIngameWatchLikeUIBP")
  local UseIngameLike = self:GetSettingConfig("UseIngameLike")
  if not UseIngameLike then
    print(bWriteLog and "[IngameLikeClientSubSystem] bOpenLike check failed")
    return
  end
  if not IngameLikeUtilClient.IsLikeSwitchOpen() then
    print(bWriteLog and "[IngameLikeClientSubSystem] lobby switch check failed")
    return
  end
  if UIManager.IsUIShow(UIManager.UI_Config_InGame.Ingame_WatchLike_UIBP) then
    UIManager.HideUI(UIManager.UI_Config_InGame.Ingame_WatchLike_UIBP)
  end
  local Ingame_WatchLike_UIBP = UIManager.ShowUI(UIManager.UI_Config_InGame.Ingame_WatchLike_UIBP)
  if Ingame_WatchLike_UIBP then
    Ingame_WatchLike_UIBP:RefreshView(message, bReply)
  end
end
function IngameLikeClientSubSystem:ReceiveShowOffInfo(ShowOffType)
  print(bWriteLog and "IngameLikeClientSubSystem:ReceiveShowOffInfo", ShowOffType)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOWOFF_TIPS, ShowOffType)
end
function IngameLikeClientSubSystem:HandleShowOff(ShowOffType)
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController.IngameLikeFeature:RPC_Server_ShowOff(ShowOffType)
  end
end
function IngameLikeClientSubSystem:CloseAllLikeUI()
  print(bWriteLog and "[IngameLikeClientSubSystem] CloseAllLikeUI")
  self:CloseIngameLikeUIBP()
  self:CloseIngameWatchLikeUIBP()
end
function IngameLikeClientSubSystem:CloseIngameLikeUIBP()
  print(bWriteLog and "[IngameLikeClientSubSystem] CloseUI")
  local IngameLikeUIBP = UIManager.GetUI(UIManager.UI_Config_InGame.IngameLikeUIBP)
  if not IngameLikeUIBP then
    return
  end
  IngameLikeUIBP = UIManager.HideUI(UIManager.UI_Config_InGame.IngameLikeUIBP)
end
function IngameLikeClientSubSystem:CloseIngameWatchLikeUIBP()
  print(bWriteLog and "[IngameLikeClientSubSystem] CloseIngameWatchLikeUIBP")
  local Ingame_WatchLike_UIBP = UIManager.GetUI(UIManager.UI_Config_InGame.Ingame_WatchLike_UIBP)
  if not Ingame_WatchLike_UIBP then
    return
  end
  UIManager.HideUI(UIManager.UI_Config_InGame.Ingame_WatchLike_UIBP)
end
function IngameLikeClientSubSystem:GetLikeCount()
  if self.CurMessage then
    print(bWriteLog and "IngameLikeClientSubSystem:GetLikeCount", self.CurMessage.Count)
    return self.CurMessage.Count or 0
  end
  return 0
end
function IngameLikeClientSubSystem:OnLikeUIHide()
  if self.SuspendingLikeData and self.SuspendingLikeData.ConditionID then
    log_tree("IngameLikeClientSubSystem:OnLikeUIHide recover SuspendingLikeData", self.SuspendingLikeData)
    self:ReceiveTirggerLike(self.SuspendingLikeData)
    log_tree("IngameLikeClientSubSystem:OnLikeUIHide recover CurMessage", self.CurMessage)
    if self.SuspendingLikeData.Count and self.SuspendingLikeData.Count > 0 then
      if UIManager.IsUIShow(UIManager.UI_Config_InGame.IngameLikeUIBP) then
        local IngameLikeUIBP = UIManager.GetUI(UIManager.UI_Config_InGame.IngameLikeUIBP)
        IngameLikeUIBP:SetProgress()
      end
      if UIManager.IsUIShow(UIManager.UI_Config_InGame.Ingame_WatchLike_UIBP) then
        local Ingame_WatchLike_UIBP = UIManager.GetUI(UIManager.UI_Config_InGame.Ingame_WatchLike_UIBP)
        Ingame_WatchLike_UIBP:SetProgress()
      end
    end
    self.SuspendingLikeData = {}
  end
end
function IngameLikeClientSubSystem:CopyTable(oldtable)
  local newtable = {}
  for i, v in pairs(oldtable) do
    newtable[i] = v
  end
  return newtable
end
function IngameLikeClientSubSystem:SendIngameAddFriend(uid)
  local sendEnum = BP_ENUM_ADD_FRIEND_FROM_INGAME
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.IsSpectator and (uPlayerController:IsSpectator() or uPlayerController.bIsForReplay) then
    sendEnum = BP_ENUM_ADD_FRIEND_FROM_INGAME_OB
  end
  if slua.isValid(uPlayerController) and uPlayerController.IsInPetSpectator and uPlayerController:IsInPetSpectator() then
    print(bWriteLog and "IngameLikeClientSubSystem:SendIngameAddFriend IsInPetSpectator")
    sendEnum = BP_ENUM_ADD_FRIEND_FROM_INGAME_OB
  end
  if CGameState:GetGameModeState() == "ReadyState" or CGameState:GetGameModeState() == "ActiveState" then
    sendEnum = BP_ENUM_ADD_FRIEND_FROM_INGAME_ISLAND
  end
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  logic_friend_apply:add_inner_friend_req(uid, "", sendEnum)
  self:SetHasSendAddFriendApply(uid, true)
end
function IngameLikeClientSubSystem:SetHasSendAddFriendApply(uid, bHasSendApply)
  if not uid then
    return
  end
  self.add_friend_list = self.add_friend_list or {}
  self.add_friend_list[uid] = bHasSendApply
end
function IngameLikeClientSubSystem:HasSendAddFriendApply(uid)
  self.add_friend_list = self.add_friend_list or {}
  return self.add_friend_list[uid]
end
function IngameLikeClientSubSystem:ShowPlayerCard(uid)
  self.playerCardId = uid
  local PlayerInfoCard = UIManager.ShowUI(UIManager.UI_Config_InGame.PlayerInfoCard, uid)
  PlayerInfoCard:SetPlayerInfo(uid)
end
function IngameLikeClientSubSystem:CheckShowLikeTypeText(Message)
  local bIsMultiLike = IngameLikeConfig.MultiLikeType and IngameLikeConfig.MultiLikeType[Message.ConditionID]
  local bIsSoleLike = IngameLikeConfig.SoleLikeType and IngameLikeConfig.SoleLikeType[Message.ConditionID]
  if bIsMultiLike or bIsSoleLike then
    local TypeEntry = bIsMultiLike and IngameLikeConfig.MultiLikeType[Message.ConditionID] or IngameLikeConfig.SoleLikeType[Message.ConditionID]
    local Content = ""
    local TextID = TypeEntry and TypeEntry.TextID
    if TextID and TextID ~= 0 then
      Content = LocUtil.GetLocalizeResStr(TextID) or ""
    end
    local SenderName = Message.PlayerName or ""
    local ReceiverName = ""
    if bIsSoleLike and Message.OtherPlayerUID and Message.OtherPlayerUID ~= 0 then
      local uPlayerState = IngameLikeUtilClient.GetMyPlayerState()
      if slua.isValid(uPlayerState) and uPlayerState.GetTeamMatePlayerStateList then
        local TeammateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
        for _, uTeamPS in pairs(TeammateList) do
          if slua.isValid(uTeamPS) and uTeamPS.UID == Message.OtherPlayerUID then
            ReceiverName = uTeamPS.PlayerName or ""
            break
          end
        end
        if ReceiverName == "" and uPlayerState.UID == Message.OtherPlayerUID then
          ReceiverName = uPlayerState.PlayerName or ""
        end
      end
    end
    local ChatMsg = {playerName = SenderName, receiverName = ReceiverName}
    if bIsMultiLike then
      local HistoricalNewsUI = UIManager.GetUI(UIManager.UI_Config_InGame.HistoricalNewsUI)
      if HistoricalNewsUI then
        HistoricalNewsUI:AddGreatMark({}, ChatMsg, Content)
      end
      print(bWriteLog and string.format("IngameLikeClientSubSystem:CheckShowLikeTypeText - ChatGreatUI show ConditionID:%d bIsMultiLike:true SenderName:%s ReceiverName:%s", Message.ConditionID, SenderName, ReceiverName))
    else
      self.PendingSoleLike      self.PendingSoleLike      self.PendingSoleLikeConditionID = Message.ConditionID
      print(bWriteLog and string.format("IngameLikeClientSubSystem:CheckShowLikeTypeText - SoleLike cached ConditionID:%d SenderName:%s ReceiverName:%s", Message.ConditionID, SenderName, ReceiverName))
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, IngameLikeClientSubSystem)