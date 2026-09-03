local Config_UGC_Copilot = require("client.slua.logic.ugc.copilot.config_ugc_copilot")
local GenerateModelFeature = {Owner = nil}
local ActionsConfig = require("GameLua.Mod.CreativeBase.Gameplay.Config.EditActionTypesConfig")
local ActionsType = ActionsConfig.Actions
function GenerateModelFeature:ctor()
  print(bWriteLog and "GenerateModelFeature:ctor")
  self:ResetData()
end
function GenerateModelFeature:ResetData()
  self.DownLoadDatas = {}
  self.RemoteBinDatas = {}
  self.GenModSaveCount = {}
  self.AssetSavingMap = {}
  self.IconCache = {}
end
function GenerateModelFeature:HandleResourceFinishNtf(ResultCode, Data)
  print(bWriteLog and "GenerateModelFeature:HandleResourceFinishNtf")
  if ResultCode ~= 0 then
    return
  end
  if nil == Data then
    return
  end
  local ModelGenTypes = {
    [Config_UGC_Copilot.Enum_Copilot_MessageType.PrimitiComboGen] = true,
    [Config_UGC_Copilot.Enum_Copilot_MessageType.VoxelModGen] = true,
    [Config_UGC_Copilot.Enum_Copilot_MessageType.ImgModGen] = true
  }
  if not ModelGenTypes[Data.type] then
    return
  end
  if Data.content == nil or type(Data.content) ~= "table" or #Data.content < 1 then
    return
  end
  local FirstModelData = Data.content[1]
  if FirstModelData == nil then
    return
  end
  local CreativeEditTLogSubsystem = SubsystemMgr:Get("CreativeEditTLogSubsystem")
  if CreativeEditTLogSubsystem then
    CreativeEditTLogSubsystem:MarkAnEditAction(ActionsType.AIGCModelGenerated)
    if Data.type == Config_UGC_Copilot.Enum_Copilot_MessageType.ImgModGen then
      CreativeEditTLogSubsystem:MarkAnEditAction(ActionsType.AIGCSimpleModelGeneratedByImage)
    elseif Data.type == Config_UGC_Copilot.Enum_Copilot_MessageType.VoxelModGen then
      CreativeEditTLogSubsystem:MarkAnEditAction(ActionsType.AIGCPixelModelGeneratedByImage)
    else
      CreativeEditTLogSubsystem:MarkAnEditAction(ActionsType.AIGCModelGeneratedByText)
    end
  end
  local IsMovingWindowShow = UIManager.IsUIShow(UIManager.UI_Config_InGame.CreativeCopilot_DraggableCopilotWindow)
  if IsMovingWindowShow then
    return
  end
  local SubSystem = SubsystemMgr:Get("AICopilotSubSystem")
  SubSystem:SetDraggableTips(LocUtil.LocalizeResFormat(97000044, FirstModelData.name))
end
function GenerateModelFeature:GetGenModelCompleteDesc(DataContent)
  if not DataContent or type(DataContent) ~= "table" or #DataContent < 1 then
    return ""
  end
  local FirstModelData = DataContent[1]
  if FirstModelData == nil then
    return ""
  end
  return LocUtil.LocalizeResFormat(97000049, #DataContent, FirstModelData.name)
end
function GenerateModelFeature:GetGenModelCompleteSearchDesc(DataContent)
  if not DataContent or type(DataContent) ~= "table" or #DataContent < 1 then
    return ""
  end
  local FirstModelData = DataContent[1]
  if FirstModelData == nil then
    return ""
  end
  return LocUtil.GetLocalizeResStr(97001101)
end
function GenerateModelFeature:OnInitialize()
end
function GenerateModelFeature:RegistEvents()
  if not self.Owner then
    print(bWriteLog and "GenerateModelFeature:RegistEvents - Owner not available")
    return
  end
  self.Owner:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PREFAB_MALL_PRIVATE_SAVE_UPDATE, self.OnSaveToPrivateMallCallback, self)
  print(bWriteLog and "GenerateModelFeature:RegistEvents - EVENTID_UGC_PREFAB_MALL_PRIVATE_SAVE_UPDATE")
end
function GenerateModelFeature:AssetSavingHandler(CustomAssetData, SavingType)
  if nil == CustomAssetData or nil == CustomAssetData.id then
    return
  end
  if Config_UGC_Copilot.Enum_Copilot_AssetSavingType.Saving == SavingType then
    print(bWriteLog and "GenerateModelFeature:AssetSavingHandler - Saving")
    self.AssetSavingMap[CustomAssetData.id] = true
  elseif Config_UGC_Copilot.Enum_Copilot_AssetSavingType.HasSaved == SavingType or Config_UGC_Copilot.Enum_Copilot_AssetSavingType.Error == SavingType then
    print(bWriteLog and "GenerateModelFeature:AssetSavingHandler - HasSaved or Error")
    self.AssetSavingMap[CustomAssetData.id] = nil
  end
end
function GenerateModelFeature:GetAssetSavingType(CustomAssetData)
  if nil == CustomAssetData or nil == CustomAssetData.id then
    return Config_UGC_Copilot.Enum_Copilot_AssetSavingType.Error
  end
  local logic_ugc_prefab_mall_asset_mgr = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_asset_mgr")
  local MetaInfo = logic_ugc_prefab_mall_asset_mgr:GetMyPrefabMallMetaByAiID(CustomAssetData.id)
  if MetaInfo then
    print(bWriteLog and "GenerateModelFeature:GetAssetSavingType - HasSaved")
    return Config_UGC_Copilot.Enum_Copilot_AssetSavingType.HasSaved
  end
  if self.AssetSavingMap[CustomAssetData.id] == true then
    print(bWriteLog and "GenerateModelFeature:GetAssetSavingType - Saving")
    return Config_UGC_Copilot.Enum_Copilot_AssetSavingType.Saving
  end
  print(bWriteLog and "GenerateModelFeature:GetAssetSavingType - ToSave")
  return Config_UGC_Copilot.Enum_Copilot_AssetSavingType.ToSave
end
function GenerateModelFeature:InitAssetData(DataContent, TraceID)
  if not (DataContent and DataContent.path) or DataContent.path == "" then
    return
  end
  local SyncData = function(CustomAssetData)
    local logic_ugc_prefab_mall_asset_mgr = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_asset_mgr")
    local MetaInfo = logic_ugc_prefab_mall_asset_mgr:GetMyPrefabMallMetaByAiID(DataContent.id)
    if MetaInfo then
      print(bWriteLog and "GenerateModelFeature:InitAssetData MetaInfo.Name = " .. tostring(MetaInfo.Name))
      CustomAssetData.CustomName = MetaInfo.Name
      CustomAssetData.CustomAssetKey = MetaInfo.CustomAssetKey
      CustomAssetData.AssetID = MetaInfo.AssetId
    end
    CustomAssetData.    return CustomAssetData
  end
  local CustomAssetData = self.RemoteBinDatas[DataContent.path]
  if CustomAssetData ~= nil then
    return SyncData(CustomAssetData)
  end
  local LogicUGCMall = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall")
  CustomAssetData = {
    type = LogicUGCMall.ENUM_PREFAB_TYPE.PREFAB,
    desc = ""
  }
  setmetatable(CustomAssetData, {__index = DataContent})
  SyncData(CustomAssetData)
  self.RemoteBinDatas[DataContent.path] = CustomAssetData
  return self.RemoteBinDatas[DataContent.path]
end
function GenerateModelFeature:OnPreCheck()
end
function GenerateModelFeature:AddAssetData(RemoteData)
  if not RemoteData or not RemoteData.path then
    return
  end
  self.RemoteBinDatas[RemoteData.path] = RemoteData
end
function GenerateModelFeature:CancelGetAssetData(UUID)
  local ResBucketModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_resbucket)
  ResBucketModule:CancelFetchUrl(UUID)
end
function GenerateModelFeature:GetPrefabIcon(ObjectKey, CompleteCb)
  local idPart = string.match(ObjectKey, "^(%d+)_icon$")
  if idPart then
    local PrefabId = tonumber(idPart)
    if PrefabId and 0 < PrefabId then
      local logic_ugc_prefab_mall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
      logic_ugc_prefab_mall:GetPrefabMetaCallBack(PrefabId, function(MetaInfo)
        if MetaInfo then
          self:DownloadByUrl(MetaInfo.Meta.Pic_Url, ObjectKey, CompleteCb)
          return
        end
      end)
    end
  end
end
function GenerateModelFeature:GetPrefabBinTable(ObjectKey, CompleteCb)
  local PrefabId = tonumber(ObjectKey)
  if PrefabId and 0 < PrefabId then
    local logic_ugc_prefab_mall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
    logic_ugc_prefab_mall:GetPrefabMetaBin(PrefabId, function(MetaInfo)
      if MetaInfo then
        self.DownLoadDatas[ObjectKey] = MetaInfo.BinTable
        if CompleteCb then
          CompleteCb(Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.Success, self.DownLoadDatas[ObjectKey])
        end
        return
      end
    end)
  end
end
function GenerateModelFeature:GetAssetData(Bucket, ObjectKey, CompleteCb)
  print(bWriteLog and "GenerateModelFeature:GetAssetData")
  if not CompleteCb then
    return
  end
  if not ObjectKey then
    if CompleteCb then
      CompleteCb(Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.Data_Error)
    end
    return
  end
  if self.DownLoadDatas[ObjectKey] then
    if CompleteCb then
      CompleteCb(Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.Success, self.DownLoadDatas[ObjectKey])
    end
    return
  end
  if Bucket and Bucket == "" and ObjectKey and ObjectKey ~= "" then
    if string.find(ObjectKey, "_icon") then
      self:GetPrefabIcon(ObjectKey, CompleteCb)
    else
      self:GetPrefabBinTable(ObjectKey, CompleteCb)
    end
    return
  end
  local ResBucketModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_resbucket)
  print(bWriteLog and "GenerateModelFeature:GetAssetData GetDownloadUrl Begin Get")
  local UUID = ResBucketModule:GetDownloadUrl(Bucket, {ObjectKey}, function(URLs, Succeed, Session)
    print(bWriteLog and "GenerateModelFeature:GetAssetData GetDownloadUrl Callback " .. tostring(Succeed))
    if Succeed then
      for key, URL in pairs(URLs) do
        self:DownloadByUrl(URL, ObjectKey, CompleteCb)
      end
    else
      if CompleteCb then
        CompleteCb(Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.URL_Error)
      end
      self:DownloadAssetCallback(Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.URL_Error)
    end
  end)
  return UUID
end
function GenerateModelFeature:CancelGetIconURL(UUIDTable)
  if not UUIDTable then
    return
  end
  if UUIDTable.GameTimer then
    Game:ClearTimer(UUIDTable.GameTimer)
    UUIDTable.GameTimer = nil
  end
  if UUIDTable.UUID then
    self:CancelGetAssetData(UUIDTable.UUID)
    UUIDTable.UUID = nil
  end
end
function GenerateModelFeature:GetIconURLWrapper(Bucket, ObjectKey, CompleteCb)
  local UUIDTable = {}
  UUIDTable.GameTimer = Game:SetTimer(1 + math.random(0, 1), false, function()
    UUIDTable.UUID = self:GetIconURL(Bucket, ObjectKey, CompleteCb)
  end)
  return UUIDTable
end
function GenerateModelFeature:GetIconURL(Bucket, ObjectKey, CompleteCb)
  print(bWriteLog and "GenerateModelFeature:GetDownloadUrl")
  if not CompleteCb then
    return
  end
  if not ObjectKey then
    if CompleteCb then
      CompleteCb(Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.Data_Error)
    end
    return
  end
  local TimeUtil = require("client.common.time_util")
  local CurTime = TimeUtil.GetServerTimeInSec()
  local Cache = self.IconCache[ObjectKey]
  if Cache then
    local TimeOut = Cache.TimeOut or -1
    if CurTime < TimeOut and Cache.URL and #Cache.URL > 0 then
      print(bWriteLog and "GenerateModelFeature:GetDownloadUrl ObjectKey:" .. tostring(ObjectKey) .. " Use Cache TimeRemain:" .. tostring(TimeOut - CurTime) .. " URL:" .. tostring(Cache.URL))
      CompleteCb(Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.Success, Cache.URL)
      return
    end
  end
  print(bWriteLog and "GenerateModelFeature:GetDownloadUrl ObjectKey:" .. tostring(ObjectKey) .. " CacheMiss")
  print(bWriteLog and "GenerateModelFeature:GetDownloadUrl Begin Get")
  local ResBucketModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_resbucket)
  local UUID = ResBucketModule:GetDownloadUrl(Bucket, {ObjectKey}, function(URLs, Succeed, Session)
    print(bWriteLog and "GenerateModelFeature:GetDownloadUrl Callback " .. tostring(Succeed))
    if Succeed then
      for key, URL in pairs(URLs) do
        self.IconCache[ObjectKey] = {
          TimeOut = TimeUtil.GetServerTimeInSec() + (600 + math.random(0, 50)),
                  }
      end
      for key, URL in pairs(URLs) do
        CompleteCb(Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.Success, URL)
      end
    else
      if CompleteCb then
        CompleteCb(Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.URL_Error)
      end
      self:DownloadAssetCallback(Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.URL_Error)
    end
  end)
  return UUID
end
function GenerateModelFeature:GetDownloadUrl(Bucket, ObjectKey, CompleteCb)
  print(bWriteLog and "GenerateModelFeature:GetDownloadUrl")
  if not CompleteCb then
    return
  end
  if not ObjectKey then
    if CompleteCb then
      CompleteCb(Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.Data_Error)
    end
    return
  end
  print(bWriteLog and "GenerateModelFeature:GetDownloadUrl Begin Get")
  local ResBucketModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_resbucket)
  local UUID = ResBucketModule:GetDownloadUrl(Bucket, {ObjectKey}, function(URLs, Succeed, Session)
    print(bWriteLog and "GenerateModelFeature:GetDownloadUrl Callback " .. tostring(Succeed))
    if Succeed then
      for key, URL in pairs(URLs) do
        CompleteCb(Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.Success, URL)
      end
    else
      if CompleteCb then
        CompleteCb(Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.URL_Error)
      end
      self:DownloadAssetCallback(Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.URL_Error)
    end
  end)
  return UUID
end
function GenerateModelFeature:DownloadAssetCallback(RspType, AWSRsp)
end
function GenerateModelFeature:DownloadByUrl(URL, ObjectKey, CompleteCb)
  print(bWriteLog and "GenerateModelFeature:DownloadByUrl")
  if not CompleteCb then
    return
  end
  if self.DownLoadDatas[ObjectKey] then
    if CompleteCb then
      CompleteCb(Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.Success, self.DownLoadDatas[ObjectKey])
    end
    return
  end
  print(bWriteLog and "GenerateModelFeature:DownloadByUrl Begin Download")
  local AWSHelper = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AWSHelper)
  AWSHelper:DownloadBinary(URL, function(AWSRsp)
    local RspType = Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.Download_Error
    if AWSRsp then
      local bOK = AWSRsp:IsOK()
      if bOK == true then
        local RemoteBinData = self.RemoteBinDatas[ObjectKey]
        if RemoteBinData ~= nil then
          local logic_ugc_prefab_mall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
          self.DownLoadDatas[ObjectKey] = logic_ugc_prefab_mall:BinStringToBinTable(AWSRsp:GetContent(), RemoteBinData.data_version or 10001)
        else
          self.DownLoadDatas[ObjectKey] = AWSRsp:GetContent()
        end
        RspType = Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.Success
      end
    end
    print(bWriteLog and "GenerateModelFeature:DownloadByUrl Callback " .. tostring(RspType))
    if CompleteCb then
      CompleteCb(RspType, self.DownLoadDatas[ObjectKey])
    end
    self:DownloadAssetCallback(RspType, self.DownLoadDatas[ObjectKey])
  end)
end
function GenerateModelFeature:SaveModel(CustomAssetData, Callback)
  print(bWriteLog and "GenerateModelFeature:SaveModel")
  local AllComplete = function()
    local BinData = self.DownLoadDatas[CustomAssetData.path]
    local IconData = self.DownLoadDatas[CustomAssetData.icon]
    if BinData ~= nil and IconData ~= nil then
      print(bWriteLog and "GenerateModelFeature:SaveModel Send To PrivateMall")
      local LogicUGCMallPrivate = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private")
      local ai_session_id = CustomAssetData.id
      if CustomAssetData.PrefabId and CustomAssetData.PrefabId > 0 then
        ai_session_id = nil
      end
      LogicUGCMallPrivate:SaveToMyPrivate(CustomAssetData.name, IconData, CustomAssetData.desc or "", BinData, CustomAssetData.type, {ai_session_id = ai_session_id, show_error_tips = true}, function(ErrorCode, MetaInfo)
        print(bWriteLog and "LogicUGCMallPrivate:SaveToMyPrivate Callback " .. tostring(ErrorCode))
        if ErrorCode ~= 0 then
          self:AssetSavingHandler(CustomAssetData, Config_UGC_Copilot.Enum_Copilot_AssetSavingType.Error)
          if Callback then
            Callback(ErrorCode, MetaInfo)
          end
          return
        end
        local CustomAssetKey = MetaInfo and MetaInfo.custom_asset_key or ""
        if self.Owner and self.Owner.MessageHandler then
          local LinkStr = string.format("id=\"WoWHelper\" style=\"WOW_Aihelper_Suggest\" url=\"game_creativemode://module=%s itemId=%s\"", Config_UGC_Copilot.Enum_Copilot_MessageType.PrimitiComboGen, CustomAssetKey)
          self.Owner.MessageHandler:SimulateAIResponse({ret = 0}, "100", LocUtil.LocalizeResFormat(97001056, LinkStr))
        end
        self:AssetSavingHandler(CustomAssetData, Config_UGC_Copilot.Enum_Copilot_AssetSavingType.HasSaved)
        local RemoteData = self.RemoteBinDatas[CustomAssetData.path]
        if RemoteData and MetaInfo then
          RemoteData.CustomAssetKey = MetaInfo.custom_asset_key
          RemoteData.CustomName = MetaInfo.name
        end
        if self.GenModSaveCount and CustomAssetData.TraceID then
          if self.GenModSaveCount[CustomAssetData.TraceID] == nil then
            self.GenModSaveCount[CustomAssetData.TraceID] = 0
          end
          self.GenModSaveCount[CustomAssetData.TraceID] = self.GenModSaveCount[CustomAssetData.TraceID] + 1
        end
        local CreativeEditTLogSubsystem = SubsystemMgr:Get("CreativeEditTLogSubsystem")
        if CreativeEditTLogSubsystem then
          CreativeEditTLogSubsystem:MarkAnEditAction(ActionsType.AIGCModelSaved)
        end
        if Callback then
          Callback(ErrorCode, MetaInfo)
        end
      end)
    end
  end
  self:AssetSavingHandler(CustomAssetData, Config_UGC_Copilot.Enum_Copilot_AssetSavingType.Saving)
  local AssetComplete = false
  local IconComplete = false
  self:GetAssetData(CustomAssetData.bucket, CustomAssetData.path, function(RspType, AWSRsp)
    AssetComplete = RspType == Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.Success
    print(bWriteLog and "GenerateModelFeature:SaveModel GetAssetData path " .. tostring(AssetComplete))
    if IconComplete and AssetComplete then
      AllComplete()
    end
  end)
  self:GetAssetData(CustomAssetData.bucket, CustomAssetData.icon, function(RspType, AWSRsp)
    IconComplete = RspType == Config_UGC_Copilot.Enum_Copilot_GetAssetRspType.Success
    print(bWriteLog and "GenerateModelFeature:SaveModel GetAssetData icon " .. tostring(IconComplete))
    if IconComplete and AssetComplete then
      AllComplete()
    end
  end)
end
function GenerateModelFeature:RequestPlace(CustomAssetKey)
  self.RequestPlaceList = self.RequestPlaceList or {}
  self.RequestPlaceList[CustomAssetKey] = true
end
function GenerateModelFeature:OnSaveToPrivateMallCallback(_, __, Slot)
  local LogicUGCMallPrivate = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private")
  if self.RequestPlaceList == nil then
    return
  end
  local MetaInfo = LogicUGCMallPrivate:GetPrivateMeta(Slot)
  if MetaInfo == nil or MetaInfo.Meta == nil then
    return
  end
  if MetaInfo.Meta.CustomAssetKey == nil then
    return
  end
  local CustomAssetKey = MetaInfo.Meta.CustomAssetKey
  if not self.RequestPlaceList or not self.RequestPlaceList[CustomAssetKey] then
    return
  end
  self.RequestPlaceList[CustomAssetKey] = nil
  local AssetID = MetaInfo.Meta.AssetId
  local logic_ugc_prefab_mall_asset_mgr = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_asset_mgr")
  logic_ugc_prefab_mall_asset_mgr:PutDown(AssetID, function(_, asset_id)
    EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_HIDE_MOVABLE_WINDOW)
    EventSystem:postEvent(EVENTTYPE_CREATIVE, EVENTID_EDIT_BACKPACK_USE_AM, asset_id)
  end, {SilentPutDown = true})
end
local class = require("class")
local object = require("object")
return class(object, nil, GenerateModelFeature)