local CreativeManagerTools = {}
local ESTExtraManagerInitPhase = import("ESTExtraManagerInitPhase")
local ESTExtraManagerType = import("ESTExtraManagerType")
local ToolInGameInitialize = false
local CurCallBackID = 0
local InitializeCallBackMap = {}
local DelegateContainer, CallAllManagerInitializeCompleteInit, _bIsStandalone
local ReplicateCompleteCallBackMap = {}
local _ManagerMap = {}
function CreativeManagerTools:GetInstanceManager()
  return self:GetManager(ESTExtraManagerType.ManagerType_Instance)
end
function CreativeManagerTools:InGameInit(bIsDs)
  print(bWriteLog and "CreativeManagerTools:Init ToolInGameInitialize:" .. tostring(ToolInGameInitialize) .. " bIsDs:" .. tostring(bIsDs))
  if ToolInGameInitialize then
    return
  end
  ToolInGameInitialize = true
  local delegate_container = require("common.delegate_container")
  DelegateContainer = delegate_container()
  _bIsStandalone = nil
  local Utility = require("common.utility")
  local uCreativeWorldSubSystem = Utility.GetWorldSubsystemByName("CreativeWorldSubSystem")
  print(bWriteLog and "CreativeManagerTools uCreativeWorldSubSystem:" .. tostring(uCreativeWorldSubSystem))
  local uInGameManagerCenter
  if slua.isValid(uCreativeWorldSubSystem) then
    uInGameManagerCenter = uCreativeWorldSubSystem:GetManagerCenter()
  end
  print(bWriteLog and "CreativeManagerTools uInGameManagerCenter:" .. tostring(uInGameManagerCenter))
  if slua.isValid(uInGameManagerCenter) and uInGameManagerCenter:GetIsBeginPlayEnded() then
    self:_OnManagerCenterBeginPlayEnded()
  else
    DelegateContainer:AddCommonEvent(EVENTTYPE_CREATIVE, EVENTID_ON_IN_GAME_MGR_CENTER_BEGIN_PLAY_ENDED, self._OnManagerCenterBeginPlayEnded, self)
  end
  if not bIsDs then
    DelegateContainer:AddCommonEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, self._OnPreSwitch, self)
  end
end
function CreativeManagerTools:InGameRelease()
  print(bWriteLog and "CreativeManagerTools:InGameRelease")
  ToolInGameInitialize = false
  self:ClearCreativeIngameManager()
  CurCallBackID = 0
  InitializeCallBackMap = {}
  _bIsStandalone = nil
  if DelegateContainer then
    DelegateContainer:Dispose()
    DelegateContainer = nil
  end
  ReplicateCompleteCallBackMap = {}
  CallAllManagerInitializeCompleteInit = nil
end
function CreativeManagerTools:_OnPreSwitch(_, _, status)
  printf(bWriteLog and "CreativeManagerTools._OnPreSwitch %s -> %s", status.pre, status.current)
  if status.pre == status.current and status.current == GameStatus.Fighting then
    self:InGameRelease()
  end
end
function CreativeManagerTools:_OnManagerCenterBeginPlayEnded(_, __)
  print(bWriteLog and "CreativeManagerTools:_OnManagerCenterBeginPlayEnded")
  if CallAllManagerInitializeCompleteInit == nil then
    CallAllManagerInitializeCompleteInit = true
    local AllCallbacks = {}
    for CallBackID, handle in pairs(InitializeCallBackMap) do
      table.insert(AllCallbacks, handle)
    end
    InitializeCallBackMap = {}
    for i = 1, #AllCallbacks do
      AllCallbacks[i]()
    end
    local InstanceManager = self:GetInstanceManager()
    if slua.isValid(InstanceManager) and InstanceManager:IsInstanceDataTreeReplicateComplete() then
      self._OnInstanceTreeReplicateComplete()
    else
      DelegateContainer:AddCommonEvent(EVENTTYPE_CREATIVE, EVENTID_ON_INSTANCE_TREE_REPLICATE_COMPLETE, self._OnInstanceTreeReplicateComplete, self)
    end
  end
end
function CreativeManagerTools:GetGameParameterManager()
  return self:GetManager(ESTExtraManagerType.ManagerType_GameParameter)
end
function CreativeManagerTools:GenerateCallBackID()
  local newListenerId = CurCallBackID
  CurCallBackID = CurCallBackID + 1
  return newListenerId
end
function CreativeManagerTools:AddCreativeManagerInitializeCallBack(handleFunc, ...)
  print(bWriteLog and "CreativeManagerTools:AddCreativeManagerInitializeCallBack")
  local CallBackID = self:GenerateCallBackID()
  local common = require("client.slua_ui_framework.common")
  local args = table.pack(...)
  local handle = function(...)
    return common.CallCombinationArgs(handleFunc, args, ...)
  end
  if CallAllManagerInitializeCompleteInit == true then
    handle()
    return nil
  else
    InitializeCallBackMap[CallBackID] = handle
    return CallBackID
  end
end
function CreativeManagerTools:RemoveCreativeManagerInitializeCallBack(CallBackID)
  print(bWriteLog and "CreativeManagerTools:RemoveCreativeManagerInitializeCallBack CallBackID:" .. tostring(CallBackID))
  if InitializeCallBackMap[CallBackID] then
    InitializeCallBackMap[CallBackID] = nil
  end
end
function CreativeManagerTools:_OnInstanceTreeReplicateComplete(_, __)
  local _  ReplicateCompleteCallBackMap = {}
  local CommonUtility = require("common.utility")
  for CallBackID, handle in pairs(_ReplicateCompleteCallBackMap) do
    local CallSuc = xpcall(handle, CommonUtility.ErrorMessageHandler)
    if not CallSuc then
      print(bWriteLog and "CreativeManagerTools:_OnInstanceTreeReplicateComplete CallHandle Xpcall CallBackID:" .. tostring(CallBackID))
    end
  end
end
function CreativeManagerTools:AddInstanceDataTreeReplicateCompleteCallBack(handleFunc, ...)
  print(bWriteLog and "CreativeManagerTools:AddInstanceDataTreeReplicateCompleteCallBack")
  local CallBackID = self:GenerateCallBackID()
  local common = require("client.slua_ui_framework.common")
  local args = table.pack(...)
  local handle = function(...)
    return common.CallCombinationArgs(handleFunc, args, ...)
  end
  if self:InstanceDataTreeIsReplicateComplete() then
    handle()
    return -1
  else
    ReplicateCompleteCallBackMap[CallBackID] = handle
    return CallBackID
  end
end
function CreativeManagerTools:RemoveInstanceDataTreeReplicateCompleteCallBack(CallBackID)
  print(bWriteLog and "CreativeManagerTools:RemoveInstanceDataTreeReplicateCompleteCallBack CallBackID:" .. tostring(CallBackID))
  if ReplicateCompleteCallBackMap[CallBackID] then
    ReplicateCompleteCallBackMap[CallBackID] = nil
  end
end
function CreativeManagerTools:InstanceDataTreeIsReplicateComplete()
  local InstanceManager = self:GetInstanceManager()
  if slua.isValid(InstanceManager) and InstanceManager:IsInstanceDataTreeReplicateComplete() then
    return true
  end
  return false
end
function CreativeManagerTools:RegisterCreativeManager(ManagerType, Manager)
  print(bWriteLog and "CreativeManagerTools:RegisterCreativeManager ManagerType:" .. tostring(ManagerType) .. " Manager:" .. tostring(Manager) .. " _ManagerMap:" .. tostring(_ManagerMap))
  if _ManagerMap[ManagerType] ~= nil then
    print(bWriteLog and "CreativeManagerTools Cover Register")
  end
  _ManagerMap[ManagerType] = Manager
end
function CreativeManagerTools:UnRegisterCreativeManager(ManagerType)
  print(bWriteLog and "CreativeManagerTools:UnRegisterCreativeManager ManagerType:" .. tostring(ManagerType) .. " _ManagerMap:" .. tostring(_ManagerMap))
  if _ManagerMap[ManagerType] ~= nil then
    _ManagerMap[ManagerType] = nil
  else
    print(bWriteLog and "CreativeManagerTools Manager Not Exist")
  end
end
function CreativeManagerTools:IsStandalone()
  if _bIsStandalone == nil and slua.isValid(CGameMode) then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    _bIsStandalone = UKismetSystemLibrary.IsStandalone(CGameMode)
  end
  return _bIsStandalone == true
end
local NonIngameManagerMap = {}
function CreativeManagerTools:ClearCreativeIngameManager()
  print(bWriteLog and "CreativeManagerTools:ClearCreativeIngameManager _ManagerMap:" .. tostring(_ManagerMap))
  local ClearManagerTypeList = {}
  for ManagerType, v in pairs(_ManagerMap) do
    if NonIngameManagerMap[ManagerType] ~= true then
      table.insert(ClearManagerTypeList, ManagerType)
    end
  end
  for i = 1, #ClearManagerTypeList do
    local ClearManagerType = ClearManagerTypeList[i]
    _ManagerMap[ClearManagerType] = nil
  end
end
function CreativeManagerTools:GetManager(ManagerType)
  if _ManagerMap[ManagerType] then
    return _ManagerMap[ManagerType]
  end
  return nil
end
function _G:GetBinaryDataManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_BinaryData)
end
function _G:GetAssetManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_Asset)
end
function _G:GetInstanceManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_Instance)
end
function _G:GetNavigationManager()
  local NavigationManager = CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_Navigation)
  if slua.isValid(NavigationManager) then
    return NavigationManager
  end
  local CCreativeModeNavigationManager = import("CreativeModeNavigationManager")
  return CCreativeModeNavigationManager.Get(CGameWorld)
end
function _G:GetCustomParameterManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_CustomParameter)
end
function _G:GetGridLevelsManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_GridLevels)
end
function _G:GetModDataCheckManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_ModDataCheck)
end
function _G:GetPhysicsManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_Physics)
end
function _G:GetObjectManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_Object)
end
function _G:GetPoolManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_Pool)
end
function _G:GetSceneQueryManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_SceneQuery)
end
function _G:GetStreamingManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_Streaming)
end
function _G:GetGameParameterManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_GameParameter)
end
function _G:GetObjectStateManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_ObjectState)
end
function _G:GetGroupManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_Group)
end
function _G:GetLoadManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_Load)
end
function _G:GetSpawnManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_Spawn)
end
function _G:GetAdaptiveSchedulingManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_AdaptiveScheduling)
end
function _G:GetWebSocketManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_WebSocket)
end
function _G:GetOfflineBuildManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_OfflineBuild)
end
function _G:GetCreativeWoWManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_CreativeWoW)
end
function _G:GetCreativeLuaVMManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_LuaVMM)
end
function _G:GetCreativeLuaSignalManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_LuaSignal)
end
function _G:GetCreativeLuaCodeManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_Code)
end
function _G:GetBlockyLuaManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_BlockyLua)
end
function _G:GetCreativeTraitManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_CreativeTrait)
end
function _G:GetCreativeEntityManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_CreativeEntity)
end
function _G:GetCreativeSpawnManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_Spawn)
end
function _G:GetCreativePerfManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_CreativePerf)
end
function _G:GetOctreeSyncManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_OctreeSync)
end
function _G:GetCreativeModeGameTaskManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_CreativeTask)
end
function _G:GetCreativeActorDataManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_ActorData)
end
function _G:GetCustomActorManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_CustomActor)
end
function _G:GetParentChildManager()
  return CreativeManagerTools:GetManager(ESTExtraManagerType.ManagerType_ParentChild)
end
return CreativeManagerTools