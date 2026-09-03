local logic_ugc_loading = {}
function logic_ugc_loading:IsCreativeLoading()
  return self.LoadingExitTimerID ~= 0
end
function logic_ugc_loading:SetLoadingDisable(disable)
  print(bWriteLog and "logic_ugc_loading:SetLoadingDisable disable:" .. tostring(disable))
  self.LoadingDisable = disable
end
function logic_ugc_loading:CheckLoadingCanSetToComplete()
  if self:IsCreativeLoading() then
    NetUtil.OnEnterBattleStageDelegate("CreativeLoadMap")
    return false
  end
  return true
end
function logic_ugc_loading:DefineAndResetData()
  print(bWriteLog and "logic_ugc_loading:DefineAndResetData")
  self.LoadingExitTimerID = 0
  self.LoadingDisable = false
end
function logic_ugc_loading:OnInitialize()
  logic_ugc_loading.__super.OnInitialize(self)
  print(bWriteLog and "logic_ugc_loading:OnInitialize")
end
function logic_ugc_loading:OnPreSwitchGameStatus(preState, nextState)
  print(bWriteLog and "logic_ugc_loading:OnPreSwitchGameStatus")
  if nextState == GameStatus.Lobby and preState == GameStatus.Fighting then
    self:OnClientFightingToLobby()
  end
end
function logic_ugc_loading:OnPostSwitchGameStatus(preState, nextState)
  print(bWriteLog and "logic_ugc_loading:OnPostSwitchGameStatus preState:" .. tostring(preState) .. " nextState:" .. tostring(nextState))
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    if LogicUGC:IsUGCGameMod() then
      self:StartCreativeLoading()
    end
  end
end
function logic_ugc_loading:OnLogin(bReLogin)
  print(bWriteLog and "logic_ugc_loading:OnLogin")
end
function logic_ugc_loading:OnLogOut()
  print(bWriteLog and "logic_ugc_loading:OnLogOut")
end
function logic_ugc_loading:OnClientFightingToLobby()
  print(bWriteLog and "logic_ugc_loading:OnClientFightingToLobby")
  self:EndCreativeLoading(false)
end
function logic_ugc_loading:StartCreativeLoading()
  if self.LoadingDisable then
    print(bWriteLog and "logic_ugc_loading:StartCreativeLoading LoadingDisable")
    return
  end
  if self:IsCreativeLoading() then
    print(bWriteLog and "logic_ugc_loading:StartCreativeLoading LoadingExitTimerID ~= 0")
    return
  end
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  print(bWriteLog and "logic_ugc_loading:StartCreativeLoading Begin LoadingSystem.IsShowing() " .. tostring(LoadingSystem.IsShowing()))
  LoadingSystem.ShowLoading(false)
  local CreativeLoadingTimeout = 120
  local LoadingTickInterval = 0.2
  local DelayEndLoading = 1
  self.LoadingExitTimerID = self:AddGameTimer(LoadingTickInterval, true, function()
    local InstanceManager
    if GetInstanceManager then
      InstanceManager = GetInstanceManager()
    else
      print(bWriteLog and "function GetInstanceManager is nil")
    end
    if slua.isValid(InstanceManager) and InstanceManager:IsInstanceDataTreeReplicateComplete() then
      if DelayEndLoading <= 0 then
        self:EndCreativeLoading(false)
      else
        DelayEndLoading = DelayEndLoading - LoadingTickInterval
      end
    else
      CreativeLoadingTimeout = CreativeLoadingTimeout - LoadingTickInterval
      if CreativeLoadingTimeout <= 0 then
        self:EndCreativeLoading(true)
      end
    end
  end)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_RECORD_UOBJECT, "StartLoading")
end
function logic_ugc_loading:EndCreativeLoading(isTimeOut)
  print(bWriteLog and "logic_ugc_loading:EndCreativeLoading isTimeOut:" .. tostring(isTimeOut) .. " LoadingExitTimerID:" .. tostring(self.LoadingExitTimerID))
  if self:IsCreativeLoading() then
    local InstanceManager
    if GetInstanceManager then
      InstanceManager = GetInstanceManager()
    end
    local bInstanceMgrIsValid = InstanceManager ~= nil and slua.isValid(InstanceManager)
    local ModBinInstanceCount = -1
    local InstanceContainerNodeNum = 0
    local InstanceDataNodeNum = 0
    local RPCReplicatedInstanceContainerSeq = 0
    local ReplicatTreeLoadTime = 0
    local DataTreeLoadTime = 0
    local TotalLoadTime = 0
    if bInstanceMgrIsValid then
      ModBinInstanceCount = InstanceManager:GetModBinInstanceCount()
      InstanceContainerNodeNum = InstanceManager:GetInstanceContainerCount()
      InstanceDataNodeNum = InstanceManager:GetInstanceDataTreeCount()
      RPCReplicatedInstanceContainerSeq = InstanceManager.RPCReplicatedInstanceContainerSeq
      local StartDownloadMapTimeStamp = InstanceManager.StartDownloadMapTimeStamp
      local CompleteDownloadReplicatTreeTimeStamp = InstanceManager.CompleteDownloadReplicatTreeTimeStamp
      local CompleteDownloadDataNodeTreeTimeStamp = InstanceManager.CompleteDownloadDataNodeTreeTimeStamp
      ReplicatTreeLoadTime = CompleteDownloadReplicatTreeTimeStamp - StartDownloadMapTimeStamp
      DataTreeLoadTime = CompleteDownloadDataNodeTreeTimeStamp - CompleteDownloadReplicatTreeTimeStamp
      TotalLoadTime = CompleteDownloadDataNodeTreeTimeStamp - StartDownloadMapTimeStamp
    else
      ModBinInstanceCount = -2
    end
    local InitBinaryDataSize = -1
    local BinaryDataMgr
    if GetBinaryDataManager then
      BinaryDataMgr = GetBinaryDataManager()
    end
    if BinaryDataMgr ~= nil and slua.isValid(BinaryDataMgr) then
      InitBinaryDataSize = BinaryDataMgr:GetInitBinaryDataSize()
    end
    local ReportMsg = "ModBinInstanceCount:" .. tostring(ModBinInstanceCount) .. " InstanceContainerNodeNum:" .. tostring(InstanceContainerNodeNum) .. " InstanceDataNodeNum:" .. tostring(InstanceDataNodeNum)
    ReportMsg = ReportMsg .. " ReplicatTreeLoadTime:" .. tostring(ReplicatTreeLoadTime) .. " DataTreeLoadTime:" .. tostring(DataTreeLoadTime) .. " TotalLoadTime:" .. tostring(TotalLoadTime)
    ReportMsg = ReportMsg .. " InitBinaryDataSize:" .. tostring(InitBinaryDataSize) .. ";"
    local SubType = ""
    if 1048576 < InitBinaryDataSize then
      SubType = SubType .. "MapSizeMoreThan1MB;"
    elseif 524288 < InitBinaryDataSize then
      SubType = SubType .. "MapSizeMoreThan512KB;"
    elseif 262144 < InitBinaryDataSize then
      SubType = SubType .. "MapSizeMoreThan256KB;"
    elseif 131072 < InitBinaryDataSize then
      SubType = SubType .. "MapSizeMoreThan128KB;"
    end
    if 0 < RPCReplicatedInstanceContainerSeq then
      SubType = SubType .. "RPCReplicatEnable;"
    end
    local bUDPDataTransferState = "UDPDataTransferEnable;"
    if slua.isValid(CGameState) and CGameState.GetUDPDataTransferSwitch ~= nil then
      if CGameState:GetUDPDataTransferSwitch() ~= true then
        bUDPDataTransferState = "UDPDataTransferDisable;"
      end
    else
      bUDPDataTransferState = "UDPDataTransferDisableNotState;"
    end
    SubType = SubType .. bUDPDataTransferState
    if isTimeOut then
      if ModBinInstanceCount < 0 then
        SubType = SubType .. "BinInstanceCountLoadFail;"
      elseif InstanceContainerNodeNum < ModBinInstanceCount then
        SubType = SubType .. "ReplicatNodeLoadFail;"
      elseif InstanceDataNodeNum < ModBinInstanceCount then
        SubType = SubType .. "DataNodeLoadFail;"
      end
      UnrealNet.HandleNetworkExceptionReport("EnterCreativeLoadingFail", SubType, ReportMsg)
    else
      if 3 < ReplicatTreeLoadTime then
        SubType = SubType .. "ReplicatTreeLoadMoreThian3s;"
      end
      if 15 < DataTreeLoadTime then
        SubType = SubType .. "DataTreeLoadMoreThan15s;"
      elseif 10 < DataTreeLoadTime then
        SubType = SubType .. "DataTreeLoadMoreThan10s;"
      elseif 5 < DataTreeLoadTime then
        SubType = SubType .. "DataTreeLoadMoreThan5s;"
      end
      if 25 < TotalLoadTime then
        SubType = SubType .. "MapLoadMoreThan23s;"
      elseif 18 < TotalLoadTime then
        SubType = SubType .. "MapLoadMoreThan18s;"
      elseif 12 < TotalLoadTime then
        SubType = SubType .. "MapLoadMoreThan13s;"
      elseif 8 < TotalLoadTime then
        SubType = SubType .. "MapLoadMoreThan8s;"
      end
      UnrealNet.HandleNetworkExceptionReport("EnterCreativeLoadingSucc", SubType, ReportMsg)
    end
    self:RemoveGameTimer(self.LoadingExitTimerID)
    self.LoadingExitTimerID = 0
    if isTimeOut then
      local LoadingSystem = require("client.slua.logic.loading.logic_loading")
      LoadingSystem.ShowLoading(true)
      LobbySystem.ReturnToLobby()
      local NetManager = require("client.network.comm.NetManager")
      if not NetManager.bConnected and LobbySystem.CheckOpen(BP_ENUM_IS_QUERY_PLAYER_STETE_AFTER_LOADING) then
        local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
        login_module:reqLoginLobby(true, Enum_LOGIN_REPORT_CFG.LOAD_TIMEOUT)
      else
        local MatchSystem = require("client.slua.logic.match.logic_match")
        MatchSystem.SetQueryPlayerFlag(true)
      end
    else
      NetUtil.OnEnterBattleStageDelegate("EnterBattleSuccess")
      EventSystem:postEvent(EVENTTYPE_WOW_EDITOR, EVENTID_WOW_EDITOR_ENTER_EDITOR_COMPLETE)
    end
    print(bWriteLog and "CreativeLoading ReportMsg:" .. tostring(ReportMsg) .. " SubType:" .. tostring(SubType))
  end
  print(bWriteLog and "logic_ugc_loading:EndCreativeLoading end")
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_RECORD_UOBJECT, "EndLoading")
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_LOADING_FINISH, isTimeOut)
end
function logic_ugc_loading:ReportLoadingExceState(SubEvent, para1, para2, para3)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  gem_report_utils.ReportEventDelayInBattle(gem_report_utils.EventName_Creative, SubEvent, para1, para2, para3)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGC = class(CModuleBase, nil, logic_ugc_loading)
return CLogicUGC