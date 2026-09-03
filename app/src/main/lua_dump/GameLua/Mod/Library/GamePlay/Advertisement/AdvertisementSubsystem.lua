local AdvertisementSubsystem = {}
function AdvertisementSubsystem:OnInit()
  if not Client then
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_INIT, self.OnGameModeInit, self)
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameModeStateChangeInLua, self)
end
function AdvertisementSubsystem:OnGameModeInit()
  self:InitAdvertisementBoard()
end
function AdvertisementSubsystem:OnGameModeStateChangeInLua(_, __, sState)
  if sState then
    if sState == "ReadyState" and IsEditor then
      self:InitAdvertisementBoard()
    end
    if sState == "FightingState" then
      self:ClearImageDownLoadQueue()
    end
  end
end
function AdvertisementSubsystem:InitAdvertisementBoard()
  if Client then
    return
  end
  if not slua.isValid(CGameMode) then
    print(bWriteLog and "[YY-E] AdvertisementSubsystem:InitAdvertisement CGameMode Not Valid")
    return
  end
  local uWorld = CGameMode:GetWorld()
  if not slua.isValid(uWorld) then
    print(bWriteLog and "[YY-E] AdvertisementSubsystem:InitAdvertisement uWorld Not Valid")
    return
  end
  local LocalAdvConfigList = {}
  local OpenEditorTest = false
  if IsEditor and OpenEditorTest then
    local tTestID = {}
    local AdvertisementConfigTable = CDataTable.GetTable("AdvertisementConfig")
    if AdvertisementConfigTable ~= nil then
      for _, ID in pairs(tTestID) do
        local data = AdvertisementConfigTable[ID] or nil
        if data ~= nil then
          sandbox.LogNormal(bWriteLog and string.format("ConfigList_af loc: [%f],[%f],[%f]", data.ConfigList_af:Get(0), data.ConfigList_af:Get(1), data.ConfigList_af:Get(2)))
          sandbox.LogNormal(bWriteLog and string.format("ConfigList_af Rot: [%f],[%f],[%f]", data.ConfigList_af:Get(3), data.ConfigList_af:Get(4), data.ConfigList_af:Get(5)))
          sandbox.LogNormal(bWriteLog and string.format("ConfigList_af Scale: [%f],[%f],[%f]", data.ConfigList_af:Get(6), data.ConfigList_af:Get(7), data.ConfigList_af:Get(8)))
          local config = {}
          config.HttpImgPath = ""
          config.ResPath = data.MeshPath
          config.Loc = {
            data.ConfigList_af:Get(0),
            data.ConfigList_af:Get(1),
            data.ConfigList_af:Get(2)
          }
          config.Rot = {
            Pitch = data.ConfigList_af:Get(3) or 0,
            Yaw = data.ConfigList_af:Get(4) or 0,
            Roll = data.ConfigList_af:Get(5) or 0
          }
          config.Scale = {
            data.ConfigList_af:Get(6) or 1,
            data.ConfigList_af:Get(7) or 1,
            data.ConfigList_af:Get(8) or 1
          }
          config.Id = ID
          config.CulDistance = data.CulDistance
          table.insert(LocalAdvConfigList, config)
        end
      end
    end
  end
  if ServerDataMgr and ServerDataMgr.AdvertisementConfig and next(ServerDataMgr.AdvertisementConfig) then
    print(bWriteLog and "[YY-D] AdvertisementSubsystem:InitAdvertisement")
    LocalAdvConfigList = ServerDataMgr.AdvertisementConfig
  end
  for _, tBoardCfg in pairs(LocalAdvConfigList) do
    local Location = FVector(tBoardCfg.Loc[1], tBoardCfg.Loc[2], tBoardCfg.Loc[3])
    local Rotation = FRotator(tBoardCfg.Rot.Pitch, tBoardCfg.Rot.Yaw, tBoardCfg.Rot.Roll)
    local SpawnScale = FVector(tBoardCfg.Scale[1], tBoardCfg.Scale[2], tBoardCfg.Scale[3])
    if slua.isValid(CGameMode.AdvertisementActorBP) then
      local uAdvBoardActor = uWorld:SpawnActor(CGameMode.AdvertisementActorBP, Location, Rotation, nil)
      if slua.isValid(uAdvBoardActor) then
        uAdvBoardActor:SetActorHiddenInGame(false)
        uAdvBoardActor:SetReplicates(true)
        uAdvBoardActor:SetScale(SpawnScale)
        uAdvBoardActor:SetStaticMeshPath(tBoardCfg.ResPath)
        local UKismetSystemLibrary = import("KismetSystemLibrary")
        local softObjPath = UKismetSystemLibrary.MakeSoftObjectPath(tBoardCfg.ResPath)
        if softObjPath == nil then
          print(bWriteLog and "[YY-D] AdvertisementSubsystem:InitAdvertisement, softObjPath is nil")
          return nil
        end
        local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
        local MeshObj = STExtraBlueprintFunctionLibrary.GetAssetByAssetReference(softObjPath)
        uAdvBoardActor:SetStaticMesh(MeshObj)
        print(bWriteLog and "[YY-D] AdvertisementSubsystem:InitAdvertisement Id = " .. tBoardCfg.Id)
        uAdvBoardActor:SetId(tBoardCfg.Id)
        CGameMode.AdvActorList:Add(uAdvBoardActor)
      end
    end
  end
end
function AdvertisementSubsystem:ClearImageDownLoadQueue()
  if Client and slua_GameFrontendHUD then
    local HttpWrapper = slua_GameFrontendHUD:GetHttpWrapper()
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(uPlayerController) then
      return
    end
    if uPlayerController.bEnablePlaneBanner then
      print(bWriteLog and "[YY-D] AdvertisementSubsystem:ClearImageDownLoadQueue Exist PlaneBanner Do not Clear Queue")
      return
    end
    FuncUtil.UE4ExecuteConsoleCommand("s.EnableCompressFormatDownload 0")
    if slua.isValid(HttpWrapper) then
      print(bWriteLog and "[YY-D] AdvertisementSubsystem:ClearImageDownLoadQueue")
      HttpWrapper:CancelRequestAll(0)
      HttpWrapper:CancelRequestAll(1)
      HttpWrapper:CancelRequestAll(2)
      local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
      image_download_mgr:ClearData()
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, AdvertisementSubsystem)