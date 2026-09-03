Enums_GuidGroup = {
  Normal = 0,
  EntireMap = 1,
  PopTips = 2,
  Backpack = 3,
  BackpackSaftyBox = 4,
  UITips = 5,
  Parachute = 6,
  Unique = 99
}
local NewbieGuideMgr = {
  bIgnoreReceiveSvrData = false,
  bReceiveSvrData = false,
  bRunningNewbieGuide = false,
  CurRunningNewbieGuideGroup = {},
  bInit = false,
  DelegateContainer = nil,
  EnableGuideItemTable = {},
  uNewbieGuideComponent = nil,
  GuideCanvasMap = {},
  ServerData = {},
  ServerBackFlowPlayerData = {},
  CurrentGuideConfig = {}
}
function NewbieGuideMgr.Init()
  if NewbieGuideMgr.bInit then
    return
  end
  NewbieGuideMgr.bInit = true
  local DelegateContainerC = require("common.delegate_container")
  NewbieGuideMgr.DelegateContainer = DelegateContainerC()
  log(bWriteLog and "Debug NewbieGuide: NewbieGuideMgr.Init")
  EventSystem:registEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_REGIST_ATTACH_PANEL, NewbieGuideMgr.AddGuideCanvas)
end
function NewbieGuideMgr.AddGuideCanvas(_, _, GuideCanvas)
  if slua.isValid(GuideCanvas) then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    local GuideCanvasKey = UKismetSystemLibrary.GetObjectName(GuideCanvas)
    NewbieGuideMgr.GuideCanvasMap[GuideCanvasKey] = GuideCanvas
    log(bWriteLog and "NewbieGuideMgr AddGuideCanvas:" .. GuideCanvasKey)
  end
end
function NewbieGuideMgr.HandleEnterGame()
  log(bWriteLog and "Debug NewbieGuide: HandleEnterGame")
  NewbieGuideMgr.DelegateContainer:AddCommonEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_BEGIN, NewbieGuideMgr.HandleGuideBegin)
  NewbieGuideMgr.DelegateContainer:AddCommonEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_END, NewbieGuideMgr.HandleGuideEnd)
  NewbieGuideMgr.DelegateContainer:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, NewbieGuideMgr.OnGameModeStateChangeInLua)
  if not Client then
    return
  end
  if not NewbieGuideMgr.bReceiveSvrData and not NewbieGuideMgr.bIgnoreReceiveSvrData and not Client.IsEditor() then
    return
  end
  local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
  if not ClientGameMain then
    return
  end
  NewbieGuideMgr.CurrentGuideConfig = ClientGameMain.GetCurrentConfig("NewbieGuideConfig")
  if type(NewbieGuideMgr.CurrentGuideConfig) == "string" then
    NewbieGuideMgr.CurrentGuideConfig = require(NewbieGuideMgr.CurrentGuideConfig)
  end
  if not NewbieGuideMgr.CurrentGuideConfig then
    return
  end
  local NewbieGuideItemC = require("GameLua.GameCore.Module.NewbieGuide.NewbieGuideItem")
  for ID, GuideConfigItem in pairs(NewbieGuideMgr.CurrentGuideConfig) do
    local ItemCfg = CDataTable.GetTableData("WeakGuideSubKeyCfg", ID)
    if ItemCfg and NewbieGuideMgr.CheckCanEnbableGuide(true, ID, GuideConfigItem, true) and GuideConfigItem then
      local GuideItem = NewbieGuideItemC(ID, GuideConfigItem)
      if GuideItem.bLegal then
        NewbieGuideMgr.EnableGuideItemTable[ID] = GuideItem
      end
    else
    end
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    sandbox.LogError("playercontroller is nil")
    return
  end
  NewbieGuideMgr.uNewbieGuideComponent = uPlayerController.NewbieComponent
  EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_ENTER_GAME)
  NewbieGuideMgr.DelegateContainer:AddTimer(0, function(...)
    while true do
      coroutine.yield(2)
      EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_TICK_GUIDE_CHECK)
    end
  end)
  log(bWriteLog and "Debug NewbieGuide: HandleEnterGame Success")
end
function NewbieGuideMgr.HandleExitGame()
  log(bWriteLog and "Debug NewbieGuide: HandleExitGame")
  if NewbieGuideMgr.DelegateContainer then
    NewbieGuideMgr.DelegateContainer:Dispose()
  end
  for index, GuideItem in pairs(NewbieGuideMgr.EnableGuideItemTable) do
    log(bWriteLog and "Debug NewbieGuide: HandleExitGame Clear:" .. tostring(index))
    GuideItem:Clear()
  end
  if NewbieGuideMgr.ServerData then
    for ID, Value in pairs(NewbieGuideMgr.ServerData) do
      Value.SingleRoundTriggerNumber = 0
    end
  end
  NewbieGuideMgr.EnableGuideItemTable = {}
  NewbieGuideMgr.uNewbieGuideComponent = nil
  NewbieGuideMgr.GuideCanvasMap = {}
  NewbieGuideMgr.CurrentGuideConfig = {}
  NewbieGuideMgr.CurRunningNewbieGuideGroup = {}
  NewbieGuideMgr.bIgnoreReceiveSvrData = false
end
function NewbieGuideMgr.HandleGuideBegin(_, __, NewbieGuideID, GuideGroup)
  log(bWriteLog and "Debug NewbieGuide: Begin Guide, NewbieGuideID:" .. tostring(NewbieGuideID) .. " GuideGroup:" .. GuideGroup)
  local TableUtil = require("common.table_util")
  local bFindRes = TableUtil.Find(NewbieGuideMgr.CurRunningNewbieGuideGroup, GuideGroup)
  if bFindRes < 0 then
    table.insert(NewbieGuideMgr.CurRunningNewbieGuideGroup, GuideGroup)
  end
  NewbieGuideMgr.bRunningNewbieGuide = true
  local GuideItem = NewbieGuideMgr.EnableGuideItemTable[NewbieGuideID]
  if GuideItem and GuideItem.SyncGuideDataAtStart then
    log(bWriteLog and "Debug NewbieGuide: Begin Guide, StartSyncGuideDataToServer ,NewbieGuideID:" .. tostring(NewbieGuideID))
    NewbieGuideMgr.StartSyncGuideDataToServer(NewbieGuideID, "TimeOut")
  end
  if IsEditor then
    ShowNotice("(Editor Only) NewbieGuideID = " .. tostring(NewbieGuideID))
  end
end
function NewbieGuideMgr.HandleGuideEnd(_, __, NewbieGuideID, GuideGroup, EndType)
  log(bWriteLog and "Debug NewbieGuide: End Guide NewbieGuideID:" .. tostring(NewbieGuideID) .. " GuideGroup:" .. tostring(GuideGroup) .. ",TypeL:" .. tostring(EndType))
  if EndType == "WaitingInterrupt" then
    return
  end
  local TableUtil = require("common.table_util")
  local bFindRes = TableUtil.Find(NewbieGuideMgr.CurRunningNewbieGuideGroup, GuideGroup)
  if bFindRes ~= -1 then
    table.remove(NewbieGuideMgr.CurRunningNewbieGuideGroup, bFindRes)
  end
  NewbieGuideMgr.bRunningNewbieGuide = false
  local GuideItem = NewbieGuideMgr.EnableGuideItemTable[NewbieGuideID]
  if GuideItem then
    if not GuideItem.SyncGuideDataAtStart then
      log(bWriteLog and "Debug NewbieGuide: HandleGuideEnd ,StartSyncGuideDataToServer,NewbieGuideID:" .. tostring(NewbieGuideID))
      NewbieGuideMgr.StartSyncGuideDataToServer(NewbieGuideID, EndType)
    end
    if NewbieGuideMgr.CurrentGuideConfig and not NewbieGuideMgr.CheckCanEnbableGuide(false, NewbieGuideID, NewbieGuideMgr.CurrentGuideConfig[NewbieGuideID], false) then
      GuideItem:Clear()
      NewbieGuideMgr.EnableGuideItemTable[NewbieGuideID] = nil
    end
  end
end
function NewbieGuideMgr.CheckCanEnbableGuide(bCheckLv, ID, GuideConfig, bCheckTotalRound)
  if Client.IsMatchVersion and Client.IsMatchVersion() then
    print(bWriteLog and "NewbieGuide_Debug_Msg: CheckCanEnbableGuide ID = ", ID, " MatchVersion")
    return
  end
  print(bWriteLog and "NewbieGuide_Debug_Msg: CheckCanEnbableGuide ID = ", ID)
  if not GuideConfig or not ID then
    return false
  end
  if GuideConfig.bEnable == false then
    return false
  end
  if NewbieGuideMgr.bIgnoreReceiveSvrData then
    print(bWriteLog and "NewbieGuide_Debug_Msg: CheckCanEnbableGuide ID = ", ID, " bIgnoreReceiveSvrData", NewbieGuideMgr.bIgnoreReceiveSvrData)
    return true
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.IsSpectator and (uPlayerController:IsSpectator() or uPlayerController.bIsForReplay) then
    print(bWriteLog and "NewbieGuide_Debug_Msg: CheckCanEnbableGuide ID = ", ID, " IsSpectator")
    return false
  end
  local BackFlowMaxTriggerNum
  if NewbieGuideMgr.ServerBackFlowPlayerData then
    BackFlowMaxTriggerNum = NewbieGuideMgr.ServerBackFlowPlayerData[ID]
  end
  if bCheckLv and BackFlowMaxTriggerNum == nil then
    local MinPlayerLv = GuideConfig.MinPlayerLv or 0
    local MaxPlayerLv = GuideConfig.MaxPlayerLv or 5
    local CurrentLv = 1
    if DataMgr and DataMgr.roleData and DataMgr.roleData.level then
      CurrentLv = DataMgr.roleData.level
    end
    if MinPlayerLv > CurrentLv or MaxPlayerLv < CurrentLv then
      print(bWriteLog and "NewbieGuide_Debug_Msg: CheckCanEnbableGuide ID = ", ID, " LevelCheck false")
      return false
    end
  end
  local TotalTriggerRound = GuideConfig.TotalTriggerRound or 3
  local EndExtraNumber = GuideConfig.EndExtraNumber
  local SingleRoundNumber = GuideConfig.SingleRoundTriggerNumber
  local SvrData = NewbieGuideMgr.ServerData[ID]
  if SvrData == nil then
    return true
  end
  SvrData.TotalTriggerRound = SvrData.TotalTriggerRound or 0
  SvrData.SingleRoundTriggerNumber = SvrData.SingleRoundTriggerNumber or 0
  SvrData.EndExtraNumber = SvrData.EndExtraNumber or 0
  if BackFlowMaxTriggerNum and BackFlowMaxTriggerNum <= SvrData.TotalTriggerRound then
    print(bWriteLog and "NewbieGuide_Debug_Msg: CheckCanEnbableGuide ID = ", ID, " BackFlowMaxTriggerNum")
    return false
  end
  if bCheckTotalRound and (TotalTriggerRound < SvrData.TotalTriggerRound or SvrData.SingleRoundTriggerNumber == 0 and SvrData.TotalTriggerRound == TotalTriggerRound) then
    print(bWriteLog and "NewbieGuide_Debug_Msg: CheckCanEnbableGuide ID = ", ID, " SingleRoundTriggerNumber")
    return false
  end
  if EndExtraNumber and EndExtraNumber <= SvrData.EndExtraNumber then
    print(bWriteLog and "NewbieGuide_Debug_Msg: CheckCanEnbableGuide ID = ", ID, " EndExtraNumber")
    return false
  end
  if SingleRoundNumber and SingleRoundNumber <= SvrData.SingleRoundTriggerNumber then
    print(bWriteLog and "NewbieGuide_Debug_Msg: CheckCanEnbableGuide ID = ", ID, " SingleRoundNumber")
    return false
  end
  return true
end
function NewbieGuideMgr.CheckCanRunGuide(GuideItem)
  if not slua.isValid(NewbieGuideMgr.uNewbieGuideComponent) then
    return false
  end
  if not NewbieGuideMgr.uNewbieGuideComponent:GetIsAllowLuaNewGuide() and GuideItem.GuideGroup == Enums_GuidGroup.Normal then
    log(bWriteLog and "Debug NewbieGuide: CheckCanRunGuide false CPP Guide Ban, GuideID:" .. tostring(GuideItem.ID))
    return false
  end
  if not NewbieGuideMgr.CheckCanEnbableGuide(false, GuideItem.ID, NewbieGuideMgr.CurrentGuideConfig[GuideItem.ID], true) then
    return false
  end
  if GuideItem.GuideGroup == Enums_GuidGroup.Unique then
    return true
  end
  local TableUtil = require("common.table_util")
  local bFindRes = TableUtil.Find(NewbieGuideMgr.CurRunningNewbieGuideGroup, GuideItem.GuideGroup)
  log(bWriteLog and "Debug NewbieGuide: CheckCanRunGuide GuideID:" .. tostring(GuideItem.ID) .. " GuideGroup:" .. GuideItem.GuideGroup .. " bFindRes:" .. bFindRes)
  return bFindRes == -1
end
function NewbieGuideMgr.ClearCacheServerData()
  log(bWriteLog and "NewbieGuideMgr ClearCacheServerData")
  NewbieGuideMgr.ServerData = {}
  NewbieGuideMgr.ServerBackFlowPlayerData = {}
end
function NewbieGuideMgr.HandleGetServerData(InSerVerData, BackFlowPlayerData)
  NewbieGuideMgr.bReceiveSvrData = true
  if NewbieGuideMgr.ServerData == nil then
    NewbieGuideMgr.ServerData = {}
  end
  if InSerVerData then
    for ID, Value in pairs(InSerVerData) do
      local val_is_table = type(Value) == "table"
      if val_is_table then
        local SvrData = {}
        SvrData.TotalTriggerRound = Value.Num or 0
        SvrData.EndExtraNumber = Value.ExtraNum or 0
        SvrData.SingleRoundTriggerNumber = 0
        NewbieGuideMgr.ServerData[ID] = SvrData
      end
    end
  end
  if BackFlowPlayerData then
    NewbieGuideMgr.Server  end
end
function NewbieGuideMgr.StartSyncGuideDataToServer(NewbieGuideID, EndType)
  if NewbieGuideMgr.ServerData[NewbieGuideID] == nil then
    NewbieGuideMgr.ServerData[NewbieGuideID] = {}
    NewbieGuideMgr.ServerData[NewbieGuideID].TotalTriggerRound = 0
    NewbieGuideMgr.ServerData[NewbieGuideID].EndExtraNumber = 0
    NewbieGuideMgr.ServerData[NewbieGuideID].SingleRoundTriggerNumber = 0
  end
  local GuideSvrData = NewbieGuideMgr.ServerData[NewbieGuideID]
  if GuideSvrData then
    GuideSvrData.SingleRoundTriggerNumber = GuideSvrData.SingleRoundTriggerNumber + 1
    if GuideSvrData.SingleRoundTriggerNumber == 1 then
      GuideSvrData.bNeedSyncToSvr = true
      GuideSvrData.TotalTriggerRound = GuideSvrData.TotalTriggerRound + 1
    end
    if EndType == "RecieveEndEventExtra" then
      GuideSvrData.bNeedSyncToSvr = true
      if GuideSvrData.EndExtraNumber == nil then
        GuideSvrData.EndExtraNumber = 0
      end
      GuideSvrData.EndExtraNumber = GuideSvrData.EndExtraNumber + 1
    end
    local Playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
    if not NewbieGuideMgr.SingleRoundCountTable then
      NewbieGuideMgr.SingleRoundCountTable = {}
    end
    NewbieGuideMgr.SingleRoundCountTable[NewbieGuideID] = GuideSvrData.SingleRoundTriggerNumber
    Playerprefs.SaveTableToFile_N(NewbieGuideMgr.SingleRoundCountTable, Playerprefs.ePlayerPrefsType.NewbieGuideSingleRoundCount)
  end
  NewbieGuideMgr.SyncGuideDataToServer(NewbieGuideID)
end
function NewbieGuideMgr.GuideHasData(NewbieGuideID)
  return NewbieGuideMgr.ServerData[NewbieGuideID] ~= nil
end
function NewbieGuideMgr.SyncGuideDataToServer(ID)
  local NeedSyncData = {}
  local ServerDataItem = NewbieGuideMgr.ServerData[ID]
  if ServerDataItem == nil then
    return
  end
  if not ServerDataItem.bNeedSyncToSvr then
    return
  end
  local DataItem = {}
  DataItem.Num = ServerDataItem.TotalTriggerRound
  DataItem.ExtraNum = ServerDataItem.EndExtraNumber
  local BackFlowMaxTriggerNum
  if NewbieGuideMgr.ServerBackFlowPlayerData then
    BackFlowMaxTriggerNum = NewbieGuideMgr.ServerBackFlowPlayerData[ID]
  end
  if BackFlowMaxTriggerNum then
    local GuideConfig = NewbieGuideMgr.CurrentGuideConfig[ID]
    if GuideConfig and GuideConfig.EndExtraNumber and ServerDataItem.EndExtraNumber >= GuideConfig.EndExtraNumber then
      log(bWriteLog and "NewbieGuideMgr.SyncGuideDataToServer Guide:" .. tostring(ID) .. " Is learned by player.")
      DataItem.IsLearned = true
    end
  end
  NeedSyncData[ID] = DataItem
  ServerDataItem.bNeedSyncToSvr = false
  NewbieGuideMgr.ServerData[ID] = ServerDataItem
  local NewbieGuideHandler = require("client.network.Protocol.NewbieGuideHandler")
  if NewbieGuideHandler then
    NewbieGuideHandler.send_save_weak_guidance_conditions_req(NeedSyncData)
  end
  log_tree("NeedSyncData", NeedSyncData)
end
function NewbieGuideMgr.OnGameModeStateChangeInLua(_, __, sState)
  print(bWriteLog and "NewbieGuideMgr.OnGameModeStateChangeInLua" .. sState)
  if sState then
    local Playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
    if sState == "ReadyState" then
      Playerprefs.SaveTableToFile_N({}, Playerprefs.ePlayerPrefsType.NewbieGuideSingleRoundCount)
    elseif sState == "FightingState" then
      NewbieGuideMgr.SingleRoundCountTable = Playerprefs.LoadFileToTable_N(Playerprefs.ePlayerPrefsType.NewbieGuideSingleRoundCount)
      if not NewbieGuideMgr.SingleRoundCountTable then
        NewbieGuideMgr.SingleRoundCountTable = {}
      end
      for ID, Value in pairs(NewbieGuideMgr.SingleRoundCountTable) do
        if NewbieGuideMgr.ServerData[ID] == nil then
          NewbieGuideMgr.ServerData[ID] = {}
        end
        NewbieGuideMgr.ServerData[ID].SingleRoundTriggerNumber = Value
      end
    end
  end
end
return NewbieGuideMgr