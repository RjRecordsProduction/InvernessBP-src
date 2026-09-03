local TeammateTakeOverSubsystem = {}
local MLAIProcessUtil = require("GameLua.ExtraModule.MLAI.DS.AI.MLAIProcessUtil")
local EAIProviderType = import("EAIProviderType")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local LangToLang = logic_chat_voice_const.LangToLangID
local Enum_HDmpveVoiceEvent = logic_chat_voice_const.Enum_HDmpveVoiceEvent
local TeammateTakeOverConfig = require("GameLua.Mod.BaseMod.GamePlay.AI.TeammateTakeOverConfig")
local TableUtil = require("common.table_util")
local EPawnState = import("EPawnState")
local USubsystemBlueprintLibrary = import("SubsystemBlueprintLibrary")
local Config = require("GameLua.ExtraModule.MLAI.DS.Config.MLAIProcessConfig")
function TeammateTakeOverSubsystem:OnInit()
  if not Client then
    if not CGame:IsEditor() then
      if ServerDataMgr and ServerDataMgr.SyncGameParams and ServerDataMgr.SyncGameParams.teammate_take_over_switch == false or ServerDataMgr.SyncGameParams.teammate_take_over_switch == nil then
        print(bWriteLog and "TeammateTakeOverSubsystem:OnInit teammate_take_over_switch is false")
        return
      end
    elseif not Config or Config.EditorTeammateTakeOverTest == false then
      print(bWriteLog and "TeammateTakeOverSubsystem:OnInit Config.EditorTeammateTakeOverTest is false")
      return
    end
    print(bWriteLog and "TeammateTakeOverSubsystem:OnInit teammate_take_over_switch is true")
    local UMLAISubSystem = import("MLAISubSystem")
    if UMLAISubSystem.SetOpenBTCameraInfo then
      UMLAISubSystem.SetOpenBTCameraInfo(true)
    end
    self.RequestTakeOverTimeOutTimerTable = {}
    self.RequestTakeOverPlayerNumTable = {}
    self.RemainResponsePlayer = {}
    self.ResponseTeammateTakeOverPlayerNumInfo = {}
    self.NeedTakeOverPlayerController = {}
    self.AllocatedTakeOverTeammateController = {}
    self.PlayerToTakeOverTeammateMap = {}
    self.ResponseTakeOverResult = {}
    self.TeammateTakeOverRecord = {}
    self.bTeammateTaakeOverInit = true
    self.RecordPawnStateChangePlayer = {}
    self.AcceptAllocateTeamInfo = {}
    self.TeammateTakeOverTLog = {}
  end
  self:RegistEvent()
end
function TeammateTakeOverSubsystem:RegistEvent()
  print(bWriteLog and "TeammateTakeOverSubsystem:RegistEvent")
  if not Client then
    self:AddCommonEvent(EVENTTYPE_PLAYER, EVENTID_PLAYER_STATE_CHANGED, self.HandlePlayerStateChanged, self)
    self:AddCommonEvent(EVENTTYPE_PLAYER, EVENTID_BEGIN_SEND_BATTLE_RESULT, self.HandleOnSendPlayerBattleResult, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_JOIN, self.OnPlayerJoin, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYERSETTLEMENT_START, self.OnPlayerSettlementStart, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PRE_AI_ROUND_FLOW_SEND, self.HandlAIRoundFLowPreSend, self)
  end
end
function TeammateTakeOverSubsystem:HandleTeammateTakeOverSettting(bEnable)
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  SettingModule:SetOptionValue("TeammateTakeOver", bEnable)
end
function TeammateTakeOverSubsystem:ResponseTeammateTakeOver(nPlayerKey, nTeamID, bEnable, bOpenSwitch)
  print(bWriteLog and string.format("TeammateTakeOverSubsystem:ResponseTeammateTakeOver, nTeamID, bEnable:%s, %s,", nTeamID, bEnable))
  if self.ResponseTakeOverResult[nTeamID] == nil then
    self.ResponseTakeOverResult[nTeamID] = {}
  end
  if self.NeedTakeOverPlayerController[nTeamID] == nil or #self.NeedTakeOverPlayerController[nTeamID] == 0 then
    return
  end
  local nUID = self:GetPlayerKeyToUID(nPlayerKey)
  local DSAITLogSubsystem = SubsystemMgr:Get("DSAITLogSubsystem")
  if DSAITLogSubsystem then
    DSAITLogSubsystem:AddAIDebugInfo(nPlayerKey, 13, tostring(nTeamID) .. "-" .. tostring(bEnable) .. "-" .. tostring(bOpenSwitch))
  end
  if bEnable then
    if self.ResponseTeammateTakeOverPlayerNumInfo[nTeamID] then
      self.ResponseTeammateTakeOverPlayerNumInfo[nTeamID] = self.ResponseTeammateTakeOverPlayerNumInfo[nTeamID] + 1
    else
      self.ResponseTeammateTakeOverPlayerNumInfo[nTeamID] = 1
    end
    for _, uPlayerController in pairs(self.NeedTakeOverPlayerController[nTeamID]) do
      if uPlayerController.PlayerKey ~= nPlayerKey then
        if self.ResponseTakeOverResult[nTeamID][uPlayerController.PlayerKey] == nil then
          self.ResponseTakeOverResult[nTeamID][uPlayerController.PlayerKey] = {}
          self.ResponseTakeOverResult[nTeamID][uPlayerController.PlayerKey][1] = {nPlayerKey}
          self.ResponseTakeOverResult[nTeamID][uPlayerController.PlayerKey][2] = {}
        else
          table.insert(self.ResponseTakeOverResult[nTeamID][uPlayerController.PlayerKey][1], nPlayerKey)
        end
        table.insert(self.TeammateTakeOverTLog[uPlayerController.PlayerKey].AcceptTeammateList, nUID)
      end
    end
  else
    for _, uPlayerController in pairs(self.NeedTakeOverPlayerController[nTeamID]) do
      if uPlayerController.PlayerKey ~= nPlayerKey then
        if self.ResponseTakeOverResult[nTeamID][uPlayerController.PlayerKey] == nil then
          self.ResponseTakeOverResult[nTeamID][uPlayerController.PlayerKey] = {}
          self.ResponseTakeOverResult[nTeamID][uPlayerController.PlayerKey][1] = {}
          self.ResponseTakeOverResult[nTeamID][uPlayerController.PlayerKey][2] = {nPlayerKey}
        else
          table.insert(self.ResponseTakeOverResult[nTeamID][uPlayerController.PlayerKey][2], nPlayerKey)
        end
        if bOpenSwitch then
          table.insert(self.TeammateTakeOverTLog[uPlayerController.PlayerKey].RefuseTeammateList, nUID)
        else
          table.insert(self.TeammateTakeOverTLog[uPlayerController.PlayerKey].DisableTeammateList, nUID)
        end
      end
    end
    if self.ResponseTeammateTakeOverPlayerNumInfo[nTeamID] == nil then
      self.ResponseTeammateTakeOverPlayerNumInfo[nTeamID] = 0
    end
  end
  if self.RemainResponsePlayer[nTeamID] then
    TableUtil.Remove(self.RemainResponsePlayer[nTeamID], nPlayerKey)
  end
  log_tree(bWriteLog and "TeammateTakeOverSubsystem:ResponseTeammateTakeOver, ResponseTakeOverResult:", self.ResponseTakeOverResult)
  self:CheckTeammateShouldTakeOver(nTeamID)
end
function TeammateTakeOverSubsystem:CheckTeammateShouldTakeOver(nTeamID)
  print(bWriteLog and string.format("TeammateTakeOverSubsystem:CheckTeammateShouldTakeOver, nTeamID = %s,", nTeamID))
  if self.RequestTakeOverPlayerNumTable[nTeamID] then
    print(bWriteLog and string.format("TeammateTakeOverSubsystem:CheckTeammateShouldTakeOver nTeamID = %s, ResponseNum = %s, RequestNum = %s", tostring(nTeamID), tostring(self.ResponseTeammateTakeOverPlayerNumInfo[nTeamID]), tostring(self.RequestTakeOverPlayerNumTable[nTeamID])))
    if self.ResponseTeammateTakeOverPlayerNumInfo[nTeamID] >= self.RequestTakeOverPlayerNumTable[nTeamID] / 2.0 then
      for _, uPlayerController in pairs(self.NeedTakeOverPlayerController[nTeamID]) do
        for _, nPlayerKey in pairs(self.RemainResponsePlayer[nTeamID]) do
          table.insert(self.ResponseTakeOverResult[nTeamID][uPlayerController.PlayerKey][1], nPlayerKey)
          table.insert(self.TeammateTakeOverTLog[uPlayerController.PlayerKey].AcceptTeammateList, self:GetPlayerKeyToUID(nPlayerKey) or 0)
        end
      end
      self:TakeOverTeammateByTeamID(nTeamID)
      if self.RequestTakeOverTimeOutTimerTable[nTeamID] then
        Game:ClearTimer(self.RequestTakeOverTimeOutTimerTable[nTeamID])
        self.RequestTakeOverTimeOutTimerTable[nTeamID] = nil
      end
      self.ResponseTeammateTakeOverPlayerNumInfo[nTeamID] = 0
      self.RequestTakeOverPlayerNumTable[nTeamID] = 0
      self.RemainResponsePlayer[nTeamID] = {}
    end
  end
end
function TeammateTakeOverSubsystem:TakeOverTeammateByTeamID(nTeamID)
  print(bWriteLog and string.format("TeammateTakeOverSubsystem:TakeOverTeammateByTeamID, nTeamID:%s", nTeamID))
  if self.NeedTakeOverPlayerController[nTeamID] then
    for _, uPlayerController in pairs(self.NeedTakeOverPlayerController[nTeamID]) do
      if slua.isValid(uPlayerController) then
        self:TakeOverPlayer(uPlayerController)
        self.AcceptAllocateTeamInfo[nTeamID] = {
          Time = CGameState:GetServerWorldTimeSeconds(),
          PlayerKey = uPlayerController.PlayerKey
        }
        self.TeammateTakeOverTLog[uPlayerController.PlayerKey].TakeOverState = true
      end
    end
    self.NeedTakeOverPlayerController[nTeamID] = nil
  end
end
function TeammateTakeOverSubsystem:TakeOverPlayer(uPlayerController)
  if slua.isValid(uPlayerController) then
    local MLAIProcessSubSystem = SubsystemMgr:Get("MLAIProcessSubSystem")
    if MLAIProcessSubSystem then
      if not MLAIProcessSubSystem:IsValidMLAIGame(EAIProviderType.Type_TEG) then
        MLAIProcessSubSystem:StartGameInFightingState()
      end
      if CGameMode.SetAITakeOverState then
        CGameMode:SetAITakeOverState(uPlayerController.PlayerKey, true)
      else
        print(bWriteLog and "TeammateTakeOverSubsystem:TakeOverTeammateByTeamID, CGameMode.SetAITakeOverState is nil")
      end
      MLAIProcessSubSystem:InitTeammateMLAI(uPlayerController)
      print(bWriteLog and string.format("TeammateTakeOverSubsystem:TakeOverPlayer, uPlayerController.PlayerKey:%s", uPlayerController.PlayerKey))
    end
  end
end
function TeammateTakeOverSubsystem:HandlePlayerStateChanged(_, __, UID, InPlayerState, bIsPlayerExit, bIsAlive, ParamReason)
  print(bWriteLog and string.format("TeammateTakeOverSubsystem:HandlePlayerStateChanged, UID, InPlayerState, bIsPlayerExit, bIsAlive, ParamReason:%s, %s, %s, %s, %s,", UID, InPlayerState, bIsPlayerExit, bIsAlive, ParamReason))
  local PlayerState = string.lower(InPlayerState) or ""
  if PlayerState == "exited" or PlayerState == "connectionexception" or PlayerState == "connectiontimeout" then
    if ParamReason == "IdipBan" then
      print(bWriteLog and "TeammateTakeOverSubsystem:HandlePlayerStateChanged, ParamReason = IdipBan.")
      return
    end
    if not slua.isValid(CGameState) then
      return
    end
    local sGameModeState = CGameState:GetGameModeState()
    if sGameModeState == "FightingState" then
      local uPlayerState = CGameState:GetPlayerStateByUID(UID)
      if uPlayerState and slua.isValid(uPlayerState) then
        local uPlayerController = uPlayerState:GetOwner()
        if slua.isValid(uPlayerController) then
          local nTeamID = uPlayerController.TeamID
          local nPlayerKey = uPlayerController.PlayerKey
          self:ReassignMasters(uPlayerController)
          if not self:CheckTeammateTakeOverState(uPlayerController) then
            self:DestroyAllocatedWithTeamID(uPlayerController.TeamID, "All teammates have been exited or settled", true)
            print(bWriteLog and string.format("TeammateTakeOverSubsystem:HandlePlayerStateChanged [TeamID=%s] CheckTeammateTakeOverState is false", uPlayerController.TeamID))
            return
          end
          if uPlayerState.bHasSendBattleResult == true then
            print(bWriteLog and "TeammateTakeOverSubsystem:HandlePlayerStateChanged, uid = " .. tostring(UID) .. " bHasSendBattleResult and don't report.")
            return
          end
          self:OnPlayerNeedTakeOver(uPlayerController)
        end
      end
    end
  end
end
function TeammateTakeOverSubsystem:HandleOnSendPlayerBattleResult(_, __, nUID, sReason)
  print(bWriteLog and string.format("TeammateTakeOverSubsystem:HandleOnSendPlayerBattleResult nUID=%s, sReason=%s", tostring(nUID), tostring(sReason)))
  if nUID == nil then
    return
  end
  local uPlayerController = Game:GetPlayerControllerByUID(nUID)
  if slua.isValid(uPlayerController) then
    local nTeamID = uPlayerController.TeamID
    local nPlayerKey = uPlayerController.PlayerKey
    self:ReassignMasters(uPlayerController)
    if not self:CheckTeammateTakeOverState(uPlayerController) then
      self:DestroyAllocatedWithTeamID(uPlayerController.TeamID, "All teammates have been exited or settled", true)
    end
  end
end
function TeammateTakeOverSubsystem:DestroyAllocatedWithTeamID(nTeamID, sReason, bNotRecordFailNum)
  local MLAIProcessSubSystem = SubsystemMgr:Get("MLAIProcessSubSystem")
  if MLAIProcessSubSystem then
    local tTeamControllers = self.AllocatedTakeOverTeammateController[nTeamID]
    if tTeamControllers then
      for i = #tTeamControllers, 1, -1 do
        local uTeammatePlayerController = tTeamControllers[i]
        if slua.isValid(uTeammatePlayerController) then
          MLAIProcessSubSystem:TeammateMLAIException(tTeamControllers[i], sReason, Config.AIDestroyReason.AllTeammateExited, true, bNotRecordFailNum)
        end
      end
    end
  end
end
function TeammateTakeOverSubsystem:ReassignMasters(uPlayerController)
  if slua.isValid(uPlayerController) then
    local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
    if slua.isValid(uPlayerCharacter) and self.RecordPawnStateChangePlayer[uPlayerCharacter.PlayerKey] then
      self:RemoveControlEvent(uPlayerCharacter, "OnPawnStateEnabled")
      self.RecordPawnStateChangePlayer[uPlayerCharacter.PlayerKey] = nil
    end
    local nTeamID = uPlayerController.TeamID
    local nPlayerKey = uPlayerController.PlayerKey
    if self.ResponseTakeOverResult[nTeamID] then
      for _, tSingleResponseInfo in pairs(self.ResponseTakeOverResult[nTeamID]) do
        for _, tResponseInfo in pairs(tSingleResponseInfo) do
          TableUtil.Remove(tResponseInfo, nPlayerKey)
        end
      end
    end
    if self.PlayerToTakeOverTeammateMap[uPlayerController.PlayerKey] then
      local tTempChooseMasterList = TableUtil.DeepCloneTable(self.PlayerToTakeOverTeammateMap[uPlayerController.PlayerKey])
      self.PlayerToTakeOverTeammateMap[uPlayerController.PlayerKey] = nil
      for _, uTakeOverTeammatePlayerKey in pairs(tTempChooseMasterList) do
        local uTakeOverTeammatePlayerController = GameplayData.GetPlayerController(uTakeOverTeammatePlayerKey)
        if slua.isValid(uTakeOverTeammatePlayerController) then
          self:ChooseMaster(uTakeOverTeammatePlayerController)
        end
      end
    end
  end
end
function TeammateTakeOverSubsystem:RequestTakeOverTimeOut(nTeamID)
  local DSAITLogSubsystem = SubsystemMgr:Get("DSAITLogSubsystem")
  if DSAITLogSubsystem then
    DSAITLogSubsystem:AddAIDebugInfo(0, 13, tostring(nTeamID) .. "-" .. "RequestTakeOverTimeOut")
  end
  print(bWriteLog and string.format("TeammateTakeOverSubsystem:RequestTakeOverTimeOut, nTeamID:%s", nTeamID))
  self.RequestTakeOverPlayerNumTable[nTeamID] = 0
  self.RequestTakeOverTimeOutTimerTable[nTeamID] = nil
  self.ResponseTeammateTakeOverPlayerNumInfo[nTeamID] = 0
  self.NeedTakeOverPlayerController[nTeamID] = nil
  self.RemainResponsePlayer[nTeamID] = {}
end
function TeammateTakeOverSubsystem:SendRequestTeammateTakeOver(uPlayerState, nTeamID)
  print(bWriteLog and string.format("TeammateTakeOverSubsystem:SendRequestTeammateTakeOver, nTeamID:%s", nTeamID))
  local TeammatePlayerState = uPlayerState:GetTeamMatePlayerStateList({}, true)
  if TeammatePlayerState then
    for _, uTeammatePlayerState in pairs(TeammatePlayerState) do
      if slua.isValid(uTeammatePlayerState) and uTeammatePlayerState.TeammateTakeOverFeature and uTeammatePlayerState.TeammateTakeOverFeature.bAITakeOver == false and uTeammatePlayerState.bHasSendBattleResult == false and uTeammatePlayerState.isLostConnection == false then
        uTeammatePlayerState.TeammateTakeOverFeature:RPC_Client_RequestTeammateTakeOver()
        uTeammatePlayerState.TeammateTakeOverFeature.bHasResponse = false
        if self.RequestTakeOverPlayerNumTable[nTeamID] == nil then
          self.RequestTakeOverPlayerNumTable[nTeamID] = 1
          self.RemainResponsePlayer[nTeamID] = {
            uTeammatePlayerState.PlayerKey
          }
        else
          self.RequestTakeOverPlayerNumTable[nTeamID] = self.RequestTakeOverPlayerNumTable[nTeamID] + 1
          table.insert(self.RemainResponsePlayer[nTeamID], uTeammatePlayerState.PlayerKey)
        end
        table.insert(self.TeammateTakeOverTLog[uPlayerState.PlayerKey].RequestTeammateList, uTeammatePlayerState.UID)
      end
    end
  end
  local DSAITLogSubsystem = SubsystemMgr:Get("DSAITLogSubsystem")
  if DSAITLogSubsystem then
    DSAITLogSubsystem:AddAIDebugInfo(uPlayerState.PlayerKey, 12, tostring(self.RequestTakeOverPlayerNumTable[nTeamID]))
  end
  self.RequestTakeOverTimeOutTimerTable[nTeamID] = self:AddGameTimer(TeammateTakeOverConfig.RequestTakeOverTimeoutSec, false, function()
    self:RequestTakeOverTimeOut(nTeamID)
    self.RequestTakeOverTimeOutTimerTable[nTeamID] = nil
  end)
end
function TeammateTakeOverSubsystem:OnTeammateAllocated(uTeammatePlayerController)
  if self.bTeammateTaakeOverInit == nil or self.bTeammateTaakeOverInit == false then
    print(bWriteLog and "TeammateTakeOverSubsystem:OnTeammateAllocated, self.bTeammateTaakeOverInit is nil or false")
    return
  end
  print(bWriteLog and string.format("TeammateTakeOverSubsystem:OnTeammateAllocated, uTeammatePlayerKey:%s", tostring(uTeammatePlayerController.PlayerKey)))
  if slua.isValid(uTeammatePlayerController) then
    local uTeammatePlayerState = uTeammatePlayerController.PlayerState
    if slua.isValid(uTeammatePlayerState) and uTeammatePlayerState.TeammateTakeOverFeature then
      if self.AllocatedTakeOverTeammateController[uTeammatePlayerState.TeamID] == nil then
        self.AllocatedTakeOverTeammateController[uTeammatePlayerState.TeamID] = {uTeammatePlayerController}
      else
        table.insert(self.AllocatedTakeOverTeammateController[uTeammatePlayerState.TeamID], uTeammatePlayerController)
      end
      self.TeammateTakeOverTLog[uTeammatePlayerState.PlayerKey].AllocateResult = true
      uTeammatePlayerState.TeammateTakeOverFeature:OnTeammateTakeOver(true, false, false)
      self:AddTeammateTakeOverRecord(uTeammatePlayerController)
      self:ChooseMaster(uTeammatePlayerController)
      self:RePickWeapon(uTeammatePlayerController)
    end
    if uTeammatePlayerController.ReportAntiCheatInfo then
      uTeammatePlayerController:ReportAntiCheatInfo()
      print(bWriteLog and "TeammateTakeOverSubsystem:OnTeammateAllocated ReportAntiCheatInfo")
    else
      print(bWriteLog and "TeammateTakeOverSubsystem:OnTeammateAllocated no ReportAntiCheatInfo func")
    end
    self:SendTakeOverTLog(uTeammatePlayerController, true)
  end
end
function TeammateTakeOverSubsystem:OnTeammateDestroyRequest(uTeammatePlayerController, bIsDead, bIsAbnormal)
  if self.bTeammateTaakeOverInit == nil or self.bTeammateTaakeOverInit == false then
    print(bWriteLog and "TeammateTakeOverSubsystem:OnTeammateDestroyRequest, self.bTeammateTaakeOverInit is nil or false")
    return
  end
  print(bWriteLog and string.format("TeammateTakeOverSubsystem:OnTeammateDestroyRequest, uTeammatePlayerKey:%s IsDead:%s bIsAbnormal:%s", tostring(uTeammatePlayerController.PlayerKey), tostring(bIsDead), tostring(bIsAbnormal)))
  if slua.isValid(uTeammatePlayerController) then
    local uTeammatePlayerState = uTeammatePlayerController.PlayerState
    if slua.isValid(uTeammatePlayerState) and uTeammatePlayerState.TeammateTakeOverFeature then
      if not bIsDead or uTeammatePlayerState.bHasSendBattleResult ~= false then
        if uTeammatePlayerState.TeammateTakeOverFeature then
          uTeammatePlayerState.TeammateTakeOverFeature:OnTeammateTakeOver(false, bIsAbnormal, uTeammatePlayerState.bHasSendBattleResult)
        end
        if CGameMode.SetAITakeOverState then
          CGameMode:SetAITakeOverState(uTeammatePlayerState.PlayerKey, false)
        else
          print(bWriteLog and "TeammateTakeOverSubsystem:OnTeammateDestroyRequest, CGameMode.SetAITakeOverState is nil")
        end
      end
      if self.AllocatedTakeOverTeammateController[uTeammatePlayerController.TeamID] then
        TableUtil.Remove(self.AllocatedTakeOverTeammateController[uTeammatePlayerController.TeamID], uTeammatePlayerController)
      end
    end
    self:SendTakeOverTLog(uTeammatePlayerController, false)
  end
end
function TeammateTakeOverSubsystem:CheckTeammateTakeOverState(uPlayerController)
  if slua.isValid(uPlayerController) then
    local nTeamID = uPlayerController.TeamID
    local uPlayerState = uPlayerController.PlayerState
    local _HasGone = function(nUID)
      if slua_DSHUD and slua.isValid(slua_DSHUD:GetUtils()) then
        local uDSUtils = slua_DSHUD:GetUtils()
        local uDSPlayer = uDSUtils:FindPlayerByUID(nUID, "Normal")
        if slua.isValid(uDSPlayer) then
          local state = uDSPlayer.PlayerState
          return state == "Logout" or state == "ConnectionTimeout" or state == "ConnectionException" or state == "Exited" or state == "CheatDetected"
        end
      end
      return false
    end
    if slua.isValid(uPlayerState) then
      local TeammatePlayerState = uPlayerState:GetTeamMatePlayerStateList({}, true)
      if TeammatePlayerState then
        for _, uTeammatePlayerState in pairs(TeammatePlayerState) do
          if slua.isValid(uTeammatePlayerState) and _HasGone(uTeammatePlayerState.UID) == false and uTeammatePlayerState.bHasSendBattleResult == false then
            return true
          end
        end
      end
    end
  end
  return false
end
function TeammateTakeOverSubsystem:OnPlayerNeedTakeOver(uPlayerController)
  print(bWriteLog and string.format("TeammateTakeOverSubsystem:OnPlayerNeedTakeOver %s", uPlayerController.PlayerKey))
  if slua.isValid(uPlayerController) then
    local nTeamID = uPlayerController.TeamID
    local uPlayerState = uPlayerController.PlayerState
    if slua.isValid(uPlayerState) and self:CheckTeammateTakeOverState(uPlayerController) then
      local DSAITLogSubsystem = SubsystemMgr:Get("DSAITLogSubsystem")
      if self.AcceptAllocateTeamInfo[nTeamID] then
        print(bWriteLog and string.format("TeammateTakeOverSubsystem:OnPlayerNeedTakeOver, AcceptAllocateCD:%s", tostring(CGameState:GetServerWorldTimeSeconds() - self.AcceptAllocateTeamInfo[nTeamID].Time)))
        if math.floor(CGameState:GetServerWorldTimeSeconds() - self.AcceptAllocateTeamInfo[nTeamID].Time) < TeammateTakeOverConfig.AcceptAllocateCD then
          if DSAITLogSubsystem then
            DSAITLogSubsystem:AddAIDebugInfo(uPlayerController.PlayerKey, 12, "InAcceptAllocateCD")
          end
          self.ResponseTakeOverResult[nTeamID][uPlayerController.PlayerKey] = self.ResponseTakeOverResult[nTeamID][self.AcceptAllocateTeamInfo[nTeamID].PlayerKey]
          self.TeammateTakeOverTLog[uPlayerController.PlayerKey] = TableUtil.DeepCloneTable(self.TeammateTakeOverTLog[self.AcceptAllocateTeamInfo[nTeamID].PlayerKey])
          self:TakeOverPlayer(uPlayerController)
          return
        end
      end
      if self.NeedTakeOverPlayerController[nTeamID] then
        if DSAITLogSubsystem then
          DSAITLogSubsystem:AddAIDebugInfo(uPlayerController.PlayerKey, 12, "AddNeedTakeOver")
        end
        local tFirstNeedTakeOverTeammateTLog = self.TeammateTakeOverTLog[self.NeedTakeOverPlayerController[nTeamID][1].PlayerKey]
        self.TeammateTakeOverTLog[uPlayerController.PlayerKey] = TableUtil.DeepCloneTable(tFirstNeedTakeOverTeammateTLog)
        self.TeammateTakeOverTLog[uPlayerController.PlayerKey].TakeOverPlayer = uPlayerController.UID
        TableUtil.Remove(self.TeammateTakeOverTLog[uPlayerController.PlayerKey].RequestTeammateList, uPlayerController.UID)
        table.insert(self.NeedTakeOverPlayerController[nTeamID], uPlayerController)
        uPlayerState.TeammateTakeOverFeature:RPC_Server_ResponseTeammateTakeOver(false, true)
      else
        self.NeedTakeOverPlayerController[nTeamID] = {uPlayerController}
        self.TeammateTakeOverTLog[uPlayerController.PlayerKey] = {
          TakeOverPlayer = uPlayerController.UID,
          TimesFromStart = math.floor(CGameState:GetServerWorldTimeSeconds() - MLAIProcessUtil:GetEnterStateTime("FightingState")),
          TakeOverState = false,
          RequestTeammateList = {},
          AcceptTeammateList = {},
          RefuseTeammateList = {},
          DisableTeammateList = {},
          AllocateResult = false,
          MasterChangeRecord = {}
        }
        self:SendRequestTeammateTakeOver(uPlayerState, nTeamID)
      end
    end
  end
end
function TeammateTakeOverSubsystem:ChooseMaster(uAIPlayerController)
  log_tree("TeammateTakeOverSubsystem:ChooseMaster", self.ResponseTakeOverResult)
  local nMasterID = 0
  if slua.isValid(uAIPlayerController) then
    local nAIPlayerKey = uAIPlayerController.PlayerKey
    local uAICharacter = uAIPlayerController:GetPlayerCharacterSafety()
    local nTeamID = uAIPlayerController.TeamID
    if slua.isValid(uAICharacter) then
      local vCurrentAILocation = uAICharacter:K2_GetActorLocation()
      local tTeammateList = {}
      if self.ResponseTakeOverResult[nTeamID] and self.ResponseTakeOverResult[nTeamID][nAIPlayerKey] then
        if self.ResponseTakeOverResult[nTeamID][nAIPlayerKey][1] and 0 < #self.ResponseTakeOverResult[nTeamID][nAIPlayerKey][1] then
          tTeammateList = self.ResponseTakeOverResult[nTeamID][nAIPlayerKey][1]
          print(bWriteLog and string.format("TeammateTakeOverSubsystem:ChooseMaster: AI[%s] Use Accept Player", nAIPlayerKey))
        elseif self.ResponseTakeOverResult[nTeamID][nAIPlayerKey][2] then
          tTeammateList = self.ResponseTakeOverResult[nTeamID][nAIPlayerKey][2]
          print(bWriteLog and string.format("TeammateTakeOverSubsystem:ChooseMaster: AI[%s] Use Refuse Player", nAIPlayerKey))
        end
      end
      local tCandidates = {}
      local nMinAssignment = math.huge
      for _, nPlayerKey in ipairs(tTeammateList) do
        local nAssignmentCount = self.PlayerToTakeOverTeammateMap[nPlayerKey] and #self.PlayerToTakeOverTeammateMap[nPlayerKey] or 0
        if nMinAssignment > nAssignmentCount then
          nMinAssignment = nAssignmentCount
          tCandidates = {nPlayerKey}
        elseif nAssignmentCount == nMinAssignment then
          table.insert(tCandidates, nPlayerKey)
        end
      end
      if 0 < #tCandidates then
        local nClosestDistance = math.huge
        local nClosestPlayer = 0
        for _, nPlayerKey in ipairs(tCandidates) do
          local uPlayerCharacter = GameplayData.GetPlayerCharacter(nPlayerKey)
          if slua.isValid(uPlayerCharacter) and not uPlayerCharacter:HasState(EPawnState.Imprisonment) and vCurrentAILocation then
            local vPlayerLocation = uPlayerCharacter:K2_GetActorLocation()
            local nDistance = FVector.Distance(vCurrentAILocation, vPlayerLocation)
            if nClosestDistance > nDistance then
              nClosestDistance = nDistance
              nClosestPlayer = nPlayerKey
            end
          end
        end
        if nClosestPlayer ~= 0 then
          nMasterID = nClosestPlayer
          self.PlayerToTakeOverTeammateMap[nMasterID] = self.PlayerToTakeOverTeammateMap[nMasterID] or {}
          table.insert(self.PlayerToTakeOverTeammateMap[nMasterID], nAIPlayerKey)
        end
      end
    end
    print(bWriteLog and string.format("TeammateTakeOverSubsystem:ChooseMaster: AI[%s] assigned to Master[%s] in Team[%s]", nAIPlayerKey, nMasterID, nTeamID))
    local MLAIProcessSubSystem = SubsystemMgr:Get("MLAIProcessSubSystem")
    if MLAIProcessSubSystem then
      local MLAIControllerComponent = MLAIProcessSubSystem:GetMLAIControllerComponentWithID(nAIPlayerKey)
      if slua.isValid(MLAIControllerComponent) then
        MLAIProcessUtil:ChangeAllyMasterID(MLAIControllerComponent, nMasterID, "TeammateTakeOver")
        local DSAITLogSubsystem = SubsystemMgr:Get("DSAITLogSubsystem")
        if DSAITLogSubsystem then
          DSAITLogSubsystem:AddAIDebugInfo(nAIPlayerKey, 14, tostring(nMasterID))
        end
        table.insert(self.TeammateTakeOverTLog[nAIPlayerKey].MasterChangeRecord, {
          MasterID = self:GetPlayerKeyToUID(nMasterID) or 0,
          TimesFromStart = math.floor(CGameState:GetServerWorldTimeSeconds() - MLAIProcessUtil:GetEnterStateTime("FightingState"))
        })
        local uMasterPlayerState = GameplayData.GetPlayerState(nMasterID)
        if slua.isValid(uMasterPlayerState) and slua.isValid(uAIPlayerController.PlayerState) then
          uAIPlayerController.PlayerState.TeammateTakeOverFeature:SetAllyMasterIndex(uMasterPlayerState:GetPlayerTeamIndex())
        end
        local uPlayerCharacter = GameplayData.GetPlayerCharacter(nMasterID)
        if slua.isValid(uPlayerCharacter) then
          self.RecordPawnStateChangePlayer[uPlayerCharacter.PlayerKey] = true
          self:AddControlEvent(uPlayerCharacter, "OnPawnStateEnabled", function(PawnState)
            if slua.isValid(uPlayerCharacter) then
              local EStateType = import("EStateType")
              if PawnState == EPawnState.Imprisonment then
                local uPlayerController = uPlayerCharacter:GetPlayerControllerSafety()
                if slua.isValid(uPlayerController) then
                  self:ReassignMasters(uPlayerController)
                end
              end
            end
          end, self)
        end
        print(bWriteLog and string.format("TeammateTakeOverSubsystem:SetAllyMasterID: AI[%s] assigned to Master[%s] in Team[%s]", nAIPlayerKey, nMasterID, nTeamID))
      end
    end
  end
end
function TeammateTakeOverSubsystem:OnPlayerJoin(_, __, uPlayerCharacter)
  local GameModeState = CGameState:GetGameModeState()
  if (GameModeState == "ActiveState" or GameModeState == "ReadyState") and slua.isValid(uPlayerCharacter) then
    local uPlayerState = uPlayerCharacter:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) and uPlayerState.TeammateTakeOverFeature then
      uPlayerState.TeammateTakeOverFeature.bOpenTeammateTakeOver = true
    end
  end
end
function TeammateTakeOverSubsystem:AddTeammateTakeOverRecord(uTeammatePlayerController)
  if slua.isValid(uTeammatePlayerController) and slua.isValid(uTeammatePlayerController.PlayerState) and slua.isValid(CGameState) and self.TeammateTakeOverRecord[uTeammatePlayerController.PlayerState.UID] == nil then
    self.TeammateTakeOverRecord[uTeammatePlayerController.PlayerState.UID] = {
      StateEnum = 1,
      TimesFromStart = math.floor(CGameState:GetServerWorldTimeSeconds() - MLAIProcessUtil:GetEnterStateTime("FightingState"))
    }
  end
end
function TeammateTakeOverSubsystem:SendTakeOverTLog(uTeammatePlayerController, bTakeOver)
  if slua.isValid(uTeammatePlayerController) and slua.isValid(uTeammatePlayerController.PlayerState) then
    local uTeammatePlayerStateList = uTeammatePlayerController.PlayerState:GetTeamMatePlayerStateList({}, false)
    local uidList = {}
    for _, uTeammatePlayerState in pairs(uTeammatePlayerStateList) do
      if slua.isValid(uTeammatePlayerState) then
        table.insert(uidList, tostring(uTeammatePlayerState.UID))
      end
    end
    local TeammateUIDString = table.concat(uidList, "+")
    local TakeOverLog = {
      UID = uTeammatePlayerController.PlayerState.UID,
      OpenID = uTeammatePlayerController.PlayerState.OpenID,
      TeamID = uTeammatePlayerController.PlayerState.TeamID,
      TeammateList = TeammateUIDString,
      TakeOverState = bTakeOver and 1 or 0,
      GameTime = math.floor(CGameState:GetServerWorldTimeSeconds() - MLAIProcessUtil:GetEnterStateTime("FightingState"))
    }
    log_tree("TeammateTakeOverSubsystem:SendTakeOverTLog", TakeOverLog)
    if NetUtil then
      NetUtil.SendPacket("report_ai_take_over_teammate", TakeOverLog)
    end
  end
end
function TeammateTakeOverSubsystem:OnPlayerSettlementStart(_, __, nUID, tResult)
  if nUID and self.TeammateTakeOverRecord[nUID] then
    tResult.TakeOverAIData = self.TeammateTakeOverRecord[nUID]
    log_tree("TeammateTakeOverSubsystem:OnPlayerSettlementStart", tResult.TakeOverAIData)
  end
end
function TeammateTakeOverSubsystem:RePickWeapon(uTeammatePlayerController)
  if slua.isValid(uTeammatePlayerController) then
    local uAIBotPawn = uTeammatePlayerController:GetPlayerCharacterSafety()
    if slua.isValid(uAIBotPawn) then
      local WeaponCompCls = import("CharacterWeaponManagerComponent")
      local WeaponComp = uAIBotPawn:GetComponentByClass(WeaponCompCls)
      if slua.isValid(WeaponComp) then
        WeaponComp:OnDisconnectToClientOnServer()
      end
      local ESurviveWeaponPropSlotDef = import("ESurviveWeaponPropSlot")
      local uWeaponManager
      if uAIBotPawn.GetWeaponManager then
        uWeaponManager = uAIBotPawn:GetWeaponManager()
      end
      local ItemIdArray = slua.Array(UEnums.EPropertyClass.Int)
      local ItemList = {}
      if slua.isValid(uWeaponManager) then
        local WeaponPropSlotList = {
          ESurviveWeaponPropSlotDef.SWPS_MainShootWeapon1,
          ESurviveWeaponPropSlotDef.SWPS_MainShootWeapon2,
          ESurviveWeaponPropSlotDef.SWPS_SubShootWeapon
        }
        for CurrentIndex, SlotName in pairs(WeaponPropSlotList) do
          local uWeapon = uWeaponManager:GetInventoryWeaponByPropSlot(SlotName)
          if Game:IsValid(uWeapon) then
            local DefineID = uWeapon:GetItemDefineID()
            if slua.isValid(DefineID) and DefineID.TypeSpecificID > 0 then
              ItemIdArray:Add(DefineID.TypeSpecificID)
              table.insert(ItemList, {
                ItemID = DefineID.TypeSpecificID,
                Count = 1
              })
            end
          end
        end
      end
      if slua.isValid(uTeammatePlayerController.BackpackComponent) and 0 < ItemIdArray:Num() then
        local UBackpackUtils = import("BackpackUtils")
        print(bWriteLog and "TeammateTakeOverSubsystem:RePickWeaponDrop Current Weapon")
        UBackpackUtils.ForceDropItems(uTeammatePlayerController.BackpackComponent, ItemIdArray)
        MLAIProcessUtil:AddItemForTeammateMLAI(uTeammatePlayerController, ItemList)
      else
        print(bWriteLog and "TeammateTakeOverSubsystem:RePickWeapon Don't Have  Weapon")
      end
    end
  end
end
function TeammateTakeOverSubsystem:HandlAIRoundFLowPreSend(_, __, tAIRoundFlow)
  if self.TeammateTakeOverTLog then
    print(bWriteLog and "TeammateTakeOverSubsystem:HandlAIRoundFLowPreSend")
    for _, tTakeOverTLog in pairs(self.TeammateTakeOverTLog) do
      table.insert(tAIRoundFlow.TeammateTakeOverFlow, tTakeOverTLog)
    end
  end
end
function TeammateTakeOverSubsystem:GetPlayerKeyToUID(nPlayerKey)
  if nPlayerKey then
    local uPlayer = Game:GetPlayerByPlayerKey(nPlayerKey)
    if uPlayer and slua.isValid(uPlayer) then
      return Game:GetPlayerUID(uPlayer)
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, TeammateTakeOverSubsystem)