local ThemeTaskFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
ThemeTaskFeature.ServerRPC.TryUseReward = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Bool
  }
}
ThemeTaskFeature.ClientRPC.TaskComplete = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function ThemeTaskFeature:ctor()
  self.RewardStateMap = {}
  self.GroupSelectMap = {}
  self.TaskActionMap = {}
  self.GroupSelectTimeMap = {}
  local FRewardStateStruct = import("ThemeRewardStateInfo")
  self.RewardStateData = slua.Array(UEnums.EPropertyClass.Struct, FRewardStateStruct)
  self.AutoTriggerRewardList = slua.Array(UEnums.EPropertyClass.Int)
  self.NeedRepRewardIDs = {}
  self.bIsEditorTest = true
end
function ThemeTaskFeature:_PostConstruct()
  print(bWriteLog and "ThemeTaskFeature:_PostConstruct")
  ThemeTaskFeature.__super._PostConstruct(self)
  local ThemeTaskConfig = GamePlayTools.GetCurrentConfig("ThemeTaskConfig")
  if ThemeTaskConfig and ThemeTaskConfig.GroupTaskAction then
    for Group, GroupTaskAction in pairs(ThemeTaskConfig.GroupTaskAction) do
      for Reward, RewardTaskAction in pairs(GroupTaskAction) do
        for ActionName, tConfig in pairs(RewardTaskAction) do
          if self.TaskActionMap[ActionName] == nil then
            local ActionModuleName = string.format("GameLua.Mod.Library.GamePlay.Task.ThemeTask.Action.ThemeTaskAction_%s", ActionName)
            local ActionModule = require(ActionModuleName)
            if not ActionModule.bCharacterSimulate then
              local ActionInst = ActionModule()
              self.TaskActionMap[ActionName] = ActionInst
              ActionInst:OnInitialize()
            end
          end
        end
      end
    end
  end
  if ThemeTaskConfig and ThemeTaskConfig.AutoTriggerReward then
    for RewardID, RewardAction in pairs(ThemeTaskConfig.AutoTriggerReward) do
      for ActionName, tConfig in pairs(RewardAction) do
        if self.TaskActionMap[ActionName] == nil then
          local ActionModuleName = string.format("GameLua.Mod.Library.GamePlay.Task.ThemeTask.Action.ThemeTaskAction_%s", ActionName)
          local ActionModule = require(ActionModuleName)
          if not ActionModule.bCharacterSimulate then
            local ActionInst = ActionModule()
            self.TaskActionMap[ActionName] = ActionInst
            ActionInst:OnInitialize()
            print(bWriteLog and "ThemeTaskFeature:_PostConstruct", ActionName)
          end
        end
        if self.TaskActionMap[ActionName].RunEvn == "Client" or self.TaskActionMap[ActionName].RunEvn == "Both" then
          self.NeedRepRewardIDs[RewardID] = true
        end
      end
    end
  end
end
function ThemeTaskFeature:ReceiveBeginPlay()
  print(bWriteLog and "ThemeTaskFeature:ReceiveBeginPlay")
  ThemeTaskFeature.__super.ReceiveBeginPlay(self)
end
function ThemeTaskFeature:InitTaskIDIPSwitch()
  if not Client then
    local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
    local ThemeTaskConfig = GamePlayTools.GetCurrentConfig("ThemeTaskConfig")
    if ThemeTaskConfig and ThemeTaskConfig.TaskIDIPSwitch then
      self.TaskIDIPSwitch = ServerPlayerDataMgr.GetPlayerExtendAttribute(self.Owner.UID, ThemeTaskConfig.TaskIDIPSwitch) or 0
      print(bWriteLog and string.format("ThemeTaskFeature:InitTaskIDIPSwitch UID:%d TaskIDIPSwitch%d:%d", self.Owner.UID, ThemeTaskConfig.TaskIDIPSwitch, self.TaskIDIPSwitch))
    end
  end
end
function ThemeTaskFeature:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "ThemeTaskFeature:ReceiveEndplay")
  for ActionName, ActionInst in pairs(self.TaskActionMap) do
    ActionInst:OnRelease()
  end
  self.TaskActionMap = nil
  ThemeTaskFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function ThemeTaskFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local FRewardStateStruct = import("ThemeRewardStateInfo")
  return {
    {
      "RewardStateData",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Array,
      FRewardStateStruct
    },
    {
      "TaskIDIPSwitch",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "AutoTriggerRewardList",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    }
  }
end
function ThemeTaskFeature:TaskComplete(TaskID)
  if not self:CheckIsMatch() and self:CheckIsEnableSubModeID() then
    UIManager.ShowUI(UIManager.UI_Config_InGame.ThemeTaskCompleteTips, TaskID)
  end
end
function ThemeTaskFeature:OnRep_RewardStateData()
  print(bWriteLog and "ThemeTaskFeature:OnRep_RewardStateData")
  local ThemeTaskConfig = GamePlayTools.GetCurrentConfig("ThemeTaskConfig")
  local ThemeTaskRewardInfoTable = CDataTable.GetTable("ThemeTaskRewardInfo")
  for Index, Data in pairs(self.RewardStateData) do
    if ThemeTaskConfig and Data.State == ThemeTaskConfig.RewardState.Select then
      local RewardDataCfg = ThemeTaskRewardInfoTable[Data.ID]
      if RewardDataCfg then
        local GroupID = RewardDataCfg.GroupID
        local LastSelect = self.GroupSelectMap[GroupID]
        if LastSelect ~= Data.ID then
          self.GroupSelectMap[GroupID] = Data.ID
          self:ChangeGroupSelectTimeMap(GroupID, Data.LastUseTimeStamp)
          self:UseReward(GroupID, Data.ID, LastSelect)
        end
      end
    elseif ThemeTaskConfig and Data.State == ThemeTaskConfig.RewardState.UnSelect then
      local RewardDataCfg = ThemeTaskRewardInfoTable[Data.ID]
      if RewardDataCfg then
        local GroupID = RewardDataCfg.GroupID
        local LastSelect = self.GroupSelectMap[GroupID]
        if LastSelect and LastSelect == Data.ID then
          self.GroupSelectMap[GroupID] = nil
          self:ChangeGroupSelectTimeMap(GroupID, Data.LastUseTimeStamp)
          self:UseReward(GroupID, nil, LastSelect)
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_REWARDSTATE_CHANGE)
end
function ThemeTaskFeature:OnRep_AutoTriggerRewardList()
  for Index, RewardID in pairs(self.AutoTriggerRewardList) do
    print(bWriteLog and "ThemeTaskFeature:OnRep_AutoTriggerRewardList", RewardID)
    self:TriggerAutoReward(RewardID)
  end
end
function ThemeTaskFeature:CheckIsEnableSubModeID()
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModeID = GameMainConfig.GetModeID()
  local ThemeTaskConfig = GamePlayTools.GetCurrentConfig("ThemeTaskConfig")
  if ThemeTaskConfig and ThemeTaskConfig.EnableSubModeIDList then
    local TableUtil = require("common.table_util")
    if TableUtil.Find(ThemeTaskConfig.EnableSubModeIDList, ModeID) == -1 then
      return false
    end
  end
  local uPlayerController = self.Owner:GetOwner()
  if slua.isValid(uPlayerController) and uPlayerController.RoomMode ~= 0 then
    return false
  end
  return true
end
function ThemeTaskFeature:CheckIsMatch()
  local USTExtraGameInstance = import("STExtraGameInstance")
  local uGameInstance = USTExtraGameInstance.GetInstance()
  local MatchModeList = {
    111,
    112,
    113,
    411,
    412,
    413
  }
  if not slua.isValid(uGameInstance) then
    return false
  end
  local TableUtil = require("common.table_util")
  local MainModeID = uGameInstance:GetMainModeID()
  if TableUtil.Find(MatchModeList, MainModeID) ~= -1 then
    return true
  else
    return false
  end
end
function ThemeTaskFeature:InitRewardState()
  print(bWriteLog and "ThemeTaskFeature:InitRewardState")
  if self.bInit == true then
    print(bWriteLog and "ThemeTaskFeature:InitRewardState Already")
    return
  end
  if not self.Owner or self.Owner.GeneralCounterKey == nil or self.Owner.GeneralCounterKey == nil then
    print(bWriteLog and "ThemeTaskFeature:InitRewardState self.Owner is nil")
    return
  end
  if self.Owner.GeneralCounterKey:Num() ~= self.Owner.GeneralCounterValue:Num() then
    print(bWriteLog and "ThemeTaskFeature:InitRewardState self.Owner GeneralCounterKey num is error")
    return
  end
  local ThemeTaskConfig = GamePlayTools.GetCurrentConfig("ThemeTaskConfig")
  if ThemeTaskConfig == nil then
    print(bWriteLog and "ThemeTaskFeature:InitRewardState ThemeTaskConfig is nil")
    return
  end
  local RewardData = CDataTable.GetTable("ThemeTaskRewardInfo")
  local FRewardStateStruct = import("ThemeRewardStateInfo")
  for _, RewardInfo in pairs(RewardData) do
    local RewardID = RewardInfo.ID
    local CanUse = false
    local State = ThemeTaskConfig.RewardState.Lock
    local LastUseTimeStamp = -1.0
    if self.bIsEditorTest then
      CanUse = true
      State = ThemeTaskConfig.RewardState.UnSelect
    end
    local RewardState = FRewardStateStruct()
    RewardState.ID = RewardID
    RewardState.    RewardState.    self.RewardStateData:Add(RewardState)
    self.RewardStateMap[RewardID] = {
      CanUse = CanUse,
      State = State,
      LastUseTimeStamp = LastUseTimeStamp,
      Index = self.RewardStateData:Num() - 1
    }
  end
  self.bInit = true
  local ThemeTaskInfoTable = CDataTable.GetTable("ThemeTaskInfo")
  for Index, TLogID in pairs(self.Owner.GeneralCounterKey) do
    local CurProgress = self.Owner.GeneralCounterValue:Get(Index)
    local TaskID = self:GetTaskIDByTLogID(TLogID)
    if TaskID ~= -1 then
      local GrowDataCfg = ThemeTaskInfoTable[TaskID]
      if not GrowDataCfg then
        print(bWriteLog and "ThemeTaskFeature:InitRewardState GrowDataCfg is nil")
        return
      end
      if self.RewardStateMap[GrowDataCfg.RewardID] and CurProgress >= GrowDataCfg.AimProgress then
        self.RewardStateMap[GrowDataCfg.RewardID].CanUse = true
        self.RewardStateMap[GrowDataCfg.RewardID].State = ThemeTaskConfig.RewardState.UnSelect
        self:ChangeRewardStateData(self.RewardStateMap[GrowDataCfg.RewardID].Index, self.RewardStateMap[GrowDataCfg.RewardID].State, -1.0)
      end
    end
  end
  if self.Owner then
    self:AddControlEvent(self.Owner, "OnCharacterOwnerUpdate", self.InitGroupSelect, self)
  end
end
function ThemeTaskFeature:InitGroupSelectState()
  print(bWriteLog and "ThemeTaskFeature:InitGroupSelectState")
  if not self.Owner or not self.Owner.UID then
    print(bWriteLog and "ThemeTaskFeature:InitRewardState Cant get UID")
    return
  end
  local nUID = self.Owner.UID
  local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local ThemeRewardData = ServerPlayerDataMgr.GetPlayerProgressFromServer(nUID, ExtendAttribute.ThemeRewardData)
  if ThemeRewardData == nil or ThemeRewardData.MetaData == nil or ThemeRewardData.GroupSelectData == nil then
    print(bWriteLog and "ThemeTaskFeature:InitGroupSelectState ThemeRewardData is nil")
    return
  end
  local sDataDSVersion = ThemeRewardData.MetaData.DSVersion
  if sDataDSVersion == nil or sDataDSVersion == "" then
    print(bWriteLog and "ThemeTaskFeature:InitGroupSelectState sDataDSVersion is error")
    return
  end
  local sBigDataDSVersion = self:GetDSVersion(sDataDSVersion)
  local sNowDSVersion = Server.GetDSAppVersion()
  local sBigNowDSVersion = self:GetDSVersion(sNowDSVersion)
  if sBigDataDSVersion ~= sBigNowDSVersion then
    print(bWriteLog and "ThemeTaskFeature:InitGroupSelectState DSVersion is not equal")
    return
  end
  for GroupID, RewardID in pairs(ThemeRewardData.GroupSelectData) do
    if self.RewardStateMap[RewardID] and self.RewardStateMap[RewardID].CanUse then
      self.GroupSelectMap[GroupID] = RewardID
    end
  end
end
function ThemeTaskFeature:InitGroupSelect()
  print(bWriteLog and "ThemeTaskFeature:InitGroupSelect")
  if self.bInitGroupSelect then
    print(bWriteLog and "ThemeTaskFeature:InitGroupSelect Ready")
    return
  end
  self.bInitGroupSelect = true
  self:InitGroupSelectState()
  local ThemeTaskConfig = GamePlayTools.GetCurrentConfig("ThemeTaskConfig")
  if ThemeTaskConfig == nil then
    print(bWriteLog and "ThemeTaskFeature:InitRewardState ThemeTaskConfig is nil")
    return
  end
  for GroupID, GroupSelect in pairs(self.GroupSelectMap) do
    if self.RewardStateMap[GroupSelect] then
      self:UseReward(GroupID, GroupSelect, nil)
      self.RewardStateMap[GroupSelect].State = ThemeTaskConfig.RewardState.Select
      self:ChangeRewardStateData(self.RewardStateMap[GroupSelect].Index, self.RewardStateMap[GroupSelect].State, -1.0)
      self:ChangeGroupSelectTimeMap(GroupID, -1.0)
    end
  end
  local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local uPlayerState = self.Owner.Object
  local playerInfo = ServerPlayerDataMgr.GetPlayerInfo(tonumber(uPlayerState.UID))
  local RewardsIDs = {}
  if playerInfo and playerInfo.ext_takein_list then
    log_tree(bWriteLog and "ThemeTaskFeature:InitGroupSelect ext_takein_list", playerInfo.ext_takein_list)
    for Index, Reward in pairs(playerInfo.ext_takein_list) do
      if type(Reward) == "number" then
        table.insert(RewardsIDs, Reward)
      elseif type(Reward) == "table" then
        for _, RewardID in pairs(Reward) do
          if type(RewardID) == "number" then
            table.insert(RewardsIDs, RewardID)
          end
        end
      end
    end
  end
  for Index, RewardID in pairs(RewardsIDs) do
    print(bWriteLog and "ThemeTaskFeature:InitGroupSelect TriggerAutoReward", RewardID, self.NeedRepRewardIDs[RewardID])
    self:TriggerAutoReward(RewardID)
    if not Client and self.NeedRepRewardIDs[RewardID] then
      self.AutoTriggerRewardList:Add(RewardID)
    end
  end
end
function ThemeTaskFeature:CheckTaskIDIPSwitch(TaskID)
  local ThemeTaskConfig = GamePlayTools.GetCurrentConfig("ThemeTaskConfig")
  if ThemeTaskConfig ~= nil and ThemeTaskConfig.TaskIDIPEnableMap ~= nil then
    local TaskIDEnable = ThemeTaskConfig.TaskIDIPEnableMap[TaskID]
    if TaskIDEnable ~= nil then
      if TaskIDEnable == (self.TaskIDIPSwitch == 1) then
        return true
      else
        return false
      end
    end
  end
  return true
end
function ThemeTaskFeature:GetGrowData()
  if self:CheckIsMatch() or not self:CheckIsEnableSubModeID() then
    return {}
  end
  local ServerRecordGrowData = {}
  local uPlayerState = self.Owner.Object
  if slua.isValid(uPlayerState) and uPlayerState.GeneralCounterKey and uPlayerState.GeneralCounterValue and uPlayerState.ThemeTaskFeature and uPlayerState.GeneralCounterKey:Num() == uPlayerState.GeneralCounterValue:Num() then
    for Index, ID in pairs(uPlayerState.GeneralCounterKey) do
      local CurProgress = uPlayerState.GeneralCounterValue:Get(Index)
      local TaskID = self:GetTaskIDByTLogID(ID)
      if TaskID ~= -1 then
        ServerRecordGrowData[TaskID] = CurProgress
      end
    end
  end
  local GrowData = {}
  local GrowDataMap = {}
  local AllDataCfg = CDataTable.GetTable("ThemeTaskInfo")
  for _, TaskInfo in pairs(AllDataCfg) do
    if TaskInfo.ID > 0 and self:CheckTaskIDIPSwitch(TaskInfo.ID) and 0 < TaskInfo.AimProgress then
      local ID = TaskInfo.ID
      local AimProgress = TaskInfo.AimProgress
      local CurProgress = ServerRecordGrowData[ID] or 0
      local CurPercent = 0
      if AimProgress < CurProgress then
        CurProgress = AimProgress
      end
      if AimProgress ~= 0 then
        CurPercent = CurProgress / AimProgress
      end
      local PerGrowData = {
        ID = TaskInfo.ID,
        PreTaskID = TaskInfo.PreTaskID,
        CurPercent = CurPercent,
        CurProgress = CurProgress,
        AimProgress = AimProgress,
        ShouldHide = TaskInfo.ShouldHide
      }
      table.insert(GrowData, PerGrowData)
      GrowDataMap[PerGrowData.ID] = PerGrowData
    end
  end
  for _, OneGrowData in pairs(GrowData) do
    OneGrowData.LockState = false
    if OneGrowData.PreTaskID ~= 0 and GrowDataMap[OneGrowData.PreTaskID] then
      local PreGrowData = GrowDataMap[OneGrowData.PreTaskID]
      if PreGrowData.CurProgress < PreGrowData.AimProgress then
        OneGrowData.LockState = true
      end
    end
  end
  return GrowData, GrowDataMap
end
function ThemeTaskFeature:GeneralCountChanged(InTLogID, CurCnt)
  local TaskID = self:GetTaskIDByTLogID(InTLogID)
  if TaskID == -1 then
    return
  end
  if not self.Owner then
    print(bWriteLog and "ThemeTaskFeature:GeneralCountChanged self.Owner is nil")
    return
  end
  local ThemeTaskConfig = GamePlayTools.GetCurrentConfig("ThemeTaskConfig")
  if ThemeTaskConfig == nil then
    print(bWriteLog and "ThemeTaskFeature:GeneralCountChanged ThemeTaskConfig is nil")
    return
  end
  local RecordGrowData = 0
  for Index, TLogID in pairs(self.Owner.GeneralCounterKey) do
    if TLogID == InTLogID then
      RecordGrowData = self.Owner.GeneralCounterValue:Get(Index)
      break
    end
  end
  local CurProgress = CurCnt
  local TaskInfo = CDataTable.GetTableData("ThemeTaskInfo", TaskID)
  if CurProgress >= TaskInfo.AimProgress and self.RewardStateMap[TaskInfo.RewardID] and not self.RewardStateMap[TaskInfo.RewardID].CanUse then
    self.RewardStateMap[TaskInfo.RewardID].CanUse = true
    self.RewardStateMap[TaskInfo.RewardID].State = ThemeTaskConfig.RewardState.New
    self.RewardStateMap[TaskInfo.RewardID].LastUseTimeStamp = -1.0
    self:ChangeRewardStateData(self.RewardStateMap[TaskInfo.RewardID].Index, self.RewardStateMap[TaskInfo.RewardID].State, -1.0)
    if TaskInfo.ShouldHide == 0 then
      self:TaskComplete(TaskID)
    end
  end
end
function ThemeTaskFeature:GetDSVersion(sDSVersion)
  print(bWriteLog and "ThemeTaskFeature:GetDSVersion sDSVersion = " .. sDSVersion)
  local string_util = require("common.string_util")
  local verList = string_util.Split(sDSVersion, ".")
  if #verList ~= 4 then
    return ""
  end
  local ver = verList[1] .. "." .. verList[2] .. "." .. verList[3]
  print(bWriteLog and "ThemeTaskFeature:GetDSVersion ver = " .. ver)
  return ver
end
function ThemeTaskFeature:ChangeRewardStateData(Index, State, TimeStamp)
  if Index < 0 or Index >= self.RewardStateData:Num() then
    return
  end
  local RewardStateData = self.RewardStateData
  local RewardState = RewardStateData:Get(Index)
  RewardState.  RewardState.LastUse  RewardStateData:Set(Index, RewardState)
  self.end
function ThemeTaskFeature:GetCharaterFeature()
  if Client then
    return
  end
  local CharacterOwner = self.Owner.CharacterOwner
  if slua.isValid(CharacterOwner) then
    return CharacterOwner.ThemeTaskFeature
  end
end
function ThemeTaskFeature:ConstructTLogIDMapTaskID()
  self.TLogIDMapTaskID = {}
  local ThemeTaskDataCfgs = CDataTable.GetTable("ThemeTaskInfo")
  for _, DataCfg in pairs(ThemeTaskDataCfgs) do
    self.TLogIDMapTaskID[DataCfg.TLogID] = DataCfg.ID
  end
end
function ThemeTaskFeature:UseReward(GroupID, RewardID, PreRewardID)
  print(bWriteLog and string.format("ThemeTaskFeature:UseReward GroupID=%d, RewardID=%d, PreRewardID=%d", GroupID, RewardID or -1, PreRewardID or -1))
  local ThemeTaskConfig = GamePlayTools.GetCurrentConfig("ThemeTaskConfig")
  if ThemeTaskConfig == nil then
    print(bWriteLog and "ThemeTaskFeature:UseReward ThemeTaskConfig is nil")
    return
  end
  if not ThemeTaskConfig.GroupTaskAction then
    print(bWriteLog and "ThemeTaskFeature:UseReward ThemeTaskConfig.GroupTaskAction is nil")
    return
  end
  local GroupTaskAction = ThemeTaskConfig.GroupTaskAction[GroupID]
  if not GroupTaskAction then
    print(bWriteLog and "ThemeTaskFeature:UseReward GroupTaskAction is nil")
    return
  end
  if PreRewardID then
    local PreRewardTaskAction = GroupTaskAction[PreRewardID]
    if PreRewardTaskAction then
      for ActionName, tConfig in pairs(PreRewardTaskAction) do
        if self.TaskActionMap[ActionName] ~= nil and self.TaskActionMap[ActionName]:IsAllowToRun(self.Owner.Object) then
          self.TaskActionMap[ActionName]:UnSelect(PreRewardID, tConfig, self.Owner)
        end
      end
    end
  end
  if RewardID then
    local RewardTaskAction = GroupTaskAction[RewardID]
    if RewardTaskAction then
      for ActionName, tConfig in pairs(RewardTaskAction) do
        if self.TaskActionMap[ActionName] ~= nil and self.TaskActionMap[ActionName]:IsAllowToRun(self.Owner.Object) then
          self.TaskActionMap[ActionName]:Select(RewardID, tConfig, self.Owner.Object)
        end
      end
    end
  end
  local CharacterFeature = self:GetCharaterFeature()
  if CharacterFeature and not Client then
    CharacterFeature:UseReward(GroupID, RewardID, PreRewardID)
  end
end
function ThemeTaskFeature:TriggerAutoReward(RewardID)
  print(bWriteLog and string.format("ThemeTaskFeature:TriggerAutoReward RewardID=%d", RewardID or -1))
  local ThemeTaskConfig = GamePlayTools.GetCurrentConfig("ThemeTaskConfig")
  if ThemeTaskConfig == nil or ThemeTaskConfig.AutoTriggerReward == nil or ThemeTaskConfig.AutoTriggerReward[RewardID] == nil then
    print(bWriteLog and "ThemeTaskFeature:TriggerAutoReward ThemeTaskConfig is nil")
    return
  end
  if RewardID then
    local RewardTaskAction = ThemeTaskConfig.AutoTriggerReward[RewardID]
    if RewardTaskAction then
      for ActionName, tConfig in pairs(RewardTaskAction) do
        if self.TaskActionMap[ActionName] ~= nil and self.TaskActionMap[ActionName]:IsAllowToRun(self.Owner.Object) then
          self.TaskActionMap[ActionName]:Select(RewardID, tConfig, self.Owner.Object)
        end
      end
    end
  end
  local CharacterFeature = self:GetCharaterFeature()
  if CharacterFeature and not Client then
    CharacterFeature:TriggerAutoReward(RewardID)
  end
end
function ThemeTaskFeature:ChangeGroupSelectTimeMap(GroupID, TimeStamp)
  if self.GroupSelectTimeMap[GroupID] == nil or TimeStamp > self.GroupSelectTimeMap[GroupID] then
    self.GroupSelectTimeMap[GroupID] = TimeStamp
  end
end
function ThemeTaskFeature:TryUseReward(RewardID, bSelect)
  print(bWriteLog and string.format("ThemeTaskFeature:TryUseReward RewardID=%d, bSelect=%s", RewardID, bSelect and "true" or "false"))
  local RewardDataCfg = CDataTable.GetTableData("ThemeTaskRewardInfo", RewardID)
  if RewardDataCfg == nil then
    return
  end
  if self.RewardStateMap == nil or self.RewardStateMap[RewardID] == nil then
    return
  end
  local ThemeTaskConfig = GamePlayTools.GetCurrentConfig("ThemeTaskConfig")
  if ThemeTaskConfig == nil then
    print(bWriteLog and "ThemeTaskFeature:TryUseReward ThemeTaskConfig is nil")
    return
  end
  local uPlayerCharacter = self.Owner:GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter:IsCastingSkill() and ThemeTaskConfig.CastingSkillForbidUseID then
    local bForbid = ThemeTaskConfig.CastingSkillForbidUseID[RewardID]
    if bForbid then
      print(bWriteLog and "ThemeTaskFeature:TryUseReward ThemeTaskConfig is bForbid")
      return
    end
  end
  if (bSelect == nil or bSelect == true) and self.RewardStateMap[RewardID].State == ThemeTaskConfig.RewardState.Select then
    print(bWriteLog and "ThemeTaskFeature:TryUseReward Already Select")
    return
  end
  if not self.bIsEditorTest and not self.RewardStateMap[RewardID].CanUse then
    return
  end
  if self:IsRewardSelectInCDTime(RewardID) then
    print(bWriteLog and "ThemeTaskFeature:TryUseReward In CDTime")
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    return
  end
  local NowTime = uGameState:GetServerWorldTimeSeconds()
  local GroupID = RewardDataCfg.GroupID
  if bSelect == nil or bSelect == true then
    local LastSelect = self.GroupSelectMap[GroupID]
    if LastSelect and LastSelect == RewardID then
      return
    end
    self:UseReward(GroupID, RewardID, LastSelect)
    if LastSelect and self.RewardStateMap[LastSelect] then
      self.RewardStateMap[LastSelect].State = ThemeTaskConfig.RewardState.UnSelect
      self.RewardStateMap[LastSelect].LastUseTimeStamp = NowTime
      self:ChangeRewardStateData(self.RewardStateMap[LastSelect].Index, self.RewardStateMap[LastSelect].State, NowTime)
    end
    self.GroupSelectMap[RewardDataCfg.GroupID] = RewardID
    self.RewardStateMap[RewardID].State = ThemeTaskConfig.RewardState.Select
    self.RewardStateMap[RewardID].LastUseTimeStamp = NowTime
    self:ChangeRewardStateData(self.RewardStateMap[RewardID].Index, self.RewardStateMap[RewardID].State, NowTime)
    self:ChangeGroupSelectTimeMap(GroupID, NowTime)
    if RewardDataCfg.TLogID and self.Owner and self.Owner.AddGeneralCount then
      self.Owner:AddGeneralCount(RewardDataCfg.TLogID, 1, false)
    end
  else
    local LastSelect = self.GroupSelectMap[GroupID]
    if LastSelect and LastSelect ~= RewardID then
      return
    end
    self:UseReward(GroupID, nil, LastSelect)
    if LastSelect and self.RewardStateMap[LastSelect] then
      self.GroupSelectMap[GroupID] = nil
      self.RewardStateMap[LastSelect].State = ThemeTaskConfig.RewardState.UnSelect
      self.RewardStateMap[RewardID].LastUseTimeStamp = NowTime
      self:ChangeRewardStateData(self.RewardStateMap[LastSelect].Index, self.RewardStateMap[LastSelect].State, NowTime)
      self:ChangeGroupSelectTimeMap(GroupID, NowTime)
    end
  end
end
function ThemeTaskFeature:GetTaskIDByTLogID(TLogID)
  if self.TLogIDMapTaskID == nil then
    self:ConstructTLogIDMapTaskID()
  end
  if self.TLogIDMapTaskID[TLogID] == nil then
    return -1
  end
  return self.TLogIDMapTaskID[TLogID]
end
function ThemeTaskFeature:HasRewardSeleted(RewardID)
  for GroupID, GroupSelectRewardID in pairs(self.GroupSelectMap) do
    if RewardID == GroupSelectRewardID then
      return true
    end
  end
  return false
end
function ThemeTaskFeature:IsRewardSelectInCDTime(RewardID)
  print(bWriteLog and "ThemeTaskFeature:IsRewardSelectInCDTime RewardID = ", RewardID)
  if self.bIsEditorTest == true then
    return false
  end
  local ThemeTaskConfig = GamePlayTools.GetCurrentConfig("ThemeTaskConfig")
  if ThemeTaskConfig ~= nil then
    local RewardDataCfg = CDataTable.GetTableData("ThemeTaskRewardInfo", RewardID)
    if RewardDataCfg ~= nil then
      local GroupID = RewardDataCfg.GroupID
      local GameplayData = require("GameLua.GameCore.Data.GameplayData")
      local uGameState = GameplayData.GetGameState()
      if slua.isValid(uGameState) then
        local NowTime = uGameState:GetServerWorldTimeSeconds()
        if ThemeTaskConfig.GroupSelectCD and ThemeTaskConfig.GroupSelectCD[GroupID] > 0 then
          local nCDTime = ThemeTaskConfig.GroupSelectCD[GroupID]
          if self.GroupSelectTimeMap[GroupID] and nCDTime > NowTime - self.GroupSelectTimeMap[GroupID] then
            print(bWriteLog and "ThemeTaskFeature:IsRewardSelectInCDTime In CDTime")
            return true
          end
        end
      end
    end
  end
  print(bWriteLog and "ThemeTaskFeature:IsRewardSelectInCDTime not In CDTime")
  return false
end
function ThemeTaskFeature:OnRep_TaskIDIPSwitch()
  print(bWriteLog and "ThemeTaskFeature:OnRep_TaskIDIPSwitch")
  self.Owner:OnRep_GeneralCounterValue()
end
function ThemeTaskFeature:GetDanceRewardState()
  local ThemeTaskConfig = GamePlayTools.GetCurrentConfig("ThemeTaskConfig")
  if ThemeTaskConfig == nil then
    print(bWriteLog and "ThemeTaskFeature:GetDanceRewardState ThemeTaskConfig is nil")
    return
  end
  for _, RewardState in pairs(self.RewardStateData) do
    local RewardID = RewardState.ID
    local RewardState = RewardState.State
    if RewardID == ThemeTaskConfig.DanceRewardID then
      if RewardState ~= ThemeTaskConfig.RewardState.Lock then
        return true
      else
        return false
      end
    end
  end
  return false
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, ThemeTaskFeature)