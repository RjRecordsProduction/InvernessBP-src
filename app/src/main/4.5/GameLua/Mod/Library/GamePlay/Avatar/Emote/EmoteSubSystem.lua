local EmoteSubSystem = {}
local EmoteConfig = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.EmoteConfig")
function EmoteSubSystem:ctor()
  self.reports = {}
  self.DanceActorList = {}
  self.mode = nil
  self.bLocalPawnIsDancing = nil
end
function EmoteSubSystem:OnInit()
  self:AddGameTimer(120, true, function()
    self:SendDanceRecords()
  end)
  self:AddGameTimer(0.5, true, function()
    self:CheckLocalPawnIsDancing()
  end)
end
function EmoteSubSystem:CheckLocalPawnIsDancing()
  local LbLocalPawnIsDancingTemp = false
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local CurrentPawn = PlayerController:GetCurPawn()
    if slua.isValid(CurrentPawn) then
      LbLocalPawnIsDancingTemp = self:IsInDanceTogether(CurrentPawn)
    end
  end
  if self.bLocalPawnIsDancing == LbLocalPawnIsDancingTemp then
    return
  end
  self.bLocalPawnIsDancing = LbLocalPawnIsDancingTemp
  if LbLocalPawnIsDancingTemp then
    self:LocalPawnEnterDancing()
  else
    self:LocalPawnExitDancing()
  end
end
function EmoteSubSystem:LocalPawnEnterDancing()
  print(bWriteLog and "EmoteSubSystem:LocalPawnEnterDancing")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:LuaHideJoystickWidgetWithTag("LocalPawnEnterDancing")
  end
end
function EmoteSubSystem:LocalPawnExitDancing()
  print(bWriteLog and "EmoteSubSystem:LocalPawnExitDancing")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:LuaShowJoystickWidgetWithTag("LocalPawnEnterDancing")
  end
end
function EmoteSubSystem:InitMode()
  if self.mode then
    return
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.IsSocialIslandMode(true) then
    self.mode = 2
  elseif self:IsInBornIsland() then
    self.mode = 1
  end
end
function EmoteSubSystem:IsInBornIsland()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) then
    local CurGameState = uGameState:GetGameModeState()
    return CurGameState == "ReadyState" or CurGameState == "ActiveState"
  end
  return false
end
function EmoteSubSystem:RecordDanceTLog(character, IsCreat)
  if not slua.isValid(character) then
    print(bWriteLog and "EmoteSubSystem RecordDanceTLog character is not Valid")
    return
  end
  local playerController = character:GetPlayerControllerSafety()
  if not slua.isValid(playerController) then
    print(bWriteLog and "EmoteSubSystem RecordDanceTLog playerController is not Valid")
    return
  end
  local openid = playerController.PlayerOpenID
  local uid = playerController.UID
  self:InitMode()
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local report = {
    openid = openid,
    uid = uid,
    isLeader = IsCreat,
    mode = self.mode,
    time = serverTime,
    game_id = g_game_id
  }
  log_tree("EmoteSubSystem RecordDanceTLog", report)
  table.insert(self.reports, report)
end
function EmoteSubSystem:SendDanceRecords()
  if not self.reports or not next(self.reports) then
    return
  end
  log_tree("EmoteSubSystem SendDanceRecords", self.reports)
  if NetUtil then
    NetUtil.SendPacket("ReportDanceTogetherFlow", self.reports)
  end
  self.reports = {}
end
function EmoteSubSystem:RegisterDanceActor(DanceActor)
  if not slua.isValid(DanceActor) then
    return
  end
  print(bWriteLog and "EmoteSubSystem RegisterDanceActor")
  if self:IsRepeatDanceTogetherActor(DanceActor) then
    return
  end
  table.insert(self.DanceActorList, DanceActor)
end
function EmoteSubSystem:UnRegisterDanceActor(DanceActor)
  for _Index, _DanceActor in pairs(self.DanceActorList) do
    if DanceActor == _DanceActor then
      print(bWriteLog and "EmoteSubSystem UnRegisterDanceActor Remove Index" .. tostring(_Index))
      table.remove(self.DanceActorList, _Index)
      return
    end
  end
end
function EmoteSubSystem:IsInDanceTogether(Character)
  self.DanceActorList = self.DanceActorList or {}
  for _, DanceActor in pairs(self.DanceActorList) do
    if slua.isValid(DanceActor) then
      local JoinerList = DanceActor.BP_DanceTogetherManagerComponent:GetJoinerList()
      for _Index, _Character in pairs(JoinerList) do
        if Character == _Character then
          print(bWriteLog and "EmoteSubSystem IsInDanceTogether true")
          return true
        end
      end
    end
  end
  print(bWriteLog and "EmoteSubSystem IsInDanceTogether false")
  return false
end
function EmoteSubSystem:IsInPreDanceList(Character)
  for _, DanceActor in pairs(self.DanceActorList) do
    if slua.isValid(DanceActor) then
      local PreDanceList = DanceActor.BP_DanceTogetherManagerComponent:GetPreDanceList()
      for _Index, _Character in pairs(PreDanceList) do
        if Character == _Character then
          print(bWriteLog and "EmoteSubSystem IsInPreDanceList true")
          return true
        end
      end
    end
  end
  return false
end
function EmoteSubSystem:IsInPreListOrDanceList(Character)
  if self:IsInDanceTogether(Character) or self:IsInPreDanceList(Character) then
    return true
  end
  return false
end
function EmoteSubSystem:IsRepeatDanceTogetherActor(DanceActor)
  for _, _DanceActor in pairs(self.DanceActorList) do
    if _DanceActor == DanceActor then
      print(bWriteLog and "EmoteSubSystem IsRepeatDanceTogetherActor")
      return true
    end
  end
  return false
end
function EmoteSubSystem:TryPlayMovableEmote(InEmoteID, InPawn)
  if not InPawn or not slua.isValid(InPawn) then
    return false
  end
  if InEmoteID == nil then
    return false
  end
  if not self:IsMovableEmote(InEmoteID) then
    return false
  end
  print(bWriteLog and "EmoteSubSystem:TryPlayMovableEmote TriggerEntrySkillWithParams")
  local LeaderSkillID = EmoteConfig.ForwardEmoteConfig.LeaderSkillID
  Game:SetSkillBlackboardValue(InPawn, LeaderSkillID, UEnums.EBlackBoardKeyType.Int, "EmoteID", InEmoteID)
  InPawn:TriggerEntrySkillWithParams(LeaderSkillID, {"EmoteID"}, true)
  return true
end
function EmoteSubSystem:IsMovableEmote(InEmoteID)
  if EmoteConfig and EmoteConfig.ForwardEmoteConfig.ForwardEmoteID[InEmoteID] then
    return true
  end
  return false
end
function EmoteSubSystem:IsEmoteDriver(InEmoteID)
  if EmoteConfig and EmoteConfig.ForwardEmoteConfig.EmoteDriverModeID[InEmoteID] then
    return true
  end
  return false
end
function EmoteSubSystem:OnRelease()
  log_tree("EmoteSubSystem self.reports", self.reports)
  self:SendDanceRecords()
  self:LocalPawnExitDancing()
  EmoteSubSystem.__super.OnRelease(self)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, EmoteSubSystem)