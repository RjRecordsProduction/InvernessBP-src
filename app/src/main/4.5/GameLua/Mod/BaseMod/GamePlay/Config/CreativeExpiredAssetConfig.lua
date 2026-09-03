local CreativeExpiredAssetConfig = {
  NextVersionExpiredAssetSet = {},
  CurVersionExpiredAssetSet = {},
  BLUEHOLE_CurVersionExpiredAssetSet = {},
  ExpiredAssetEditorPath = "/Game/Mod/CreativeEdit/Arts_PlayerBluePrints/OfflineObject/BP_CreativeModeEditorActor_OfflineObject.BP_CreativeModeEditorActor_OfflineObject_C"
}
local NextVersionExpiredAssetId = {}
local SeasonOnlyConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.CreativeModeAssetSeasonOnlyConfig")
for AssetId, _ in pairs(SeasonOnlyConfig.SeasonOnlyAssetSet) do
  table.insert(NextVersionExpiredAssetId, AssetId)
end
local CurVersionExpiredAssetId = {}
local BLUEHOLE_CurVersionExpiredAssetId = {}
if not IsEditor then
  table.insert(CurVersionExpiredAssetId, 3101090)
  table.insert(BLUEHOLE_CurVersionExpiredAssetId, 3101090)
end
local delayPublish = {}
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
if PublishRegionMacros.IsBLUEHOLE() then
  delayPublish = CDataTable.GetTable("UGCDelayPublishConfigBluehole")
  for _, assetInfo in pairs(delayPublish) do
    local assetId = assetInfo.AssetId
    if assetId and assetInfo.IsResourceAllowedInPak == 0 then
      table.insert(BLUEHOLE_CurVersionExpiredAssetId, assetId)
    end
  end
else
  delayPublish = CDataTable.GetTable("UGCDelayPublishConfig")
  for _, assetInfo in pairs(delayPublish) do
    local assetId = assetInfo.AssetId
    if assetId and assetInfo.IsResourceAllowedInPak == 0 then
      table.insert(CurVersionExpiredAssetId, assetId)
    end
  end
end
for _, assetId in pairs(NextVersionExpiredAssetId) do
  CreativeExpiredAssetConfig.NextVersionExpiredAssetSet[assetId] = true
end
for _, assetId in pairs(BLUEHOLE_CurVersionExpiredAssetId) do
  CreativeExpiredAssetConfig.BLUEHOLE_CurVersionExpiredAssetSet[assetId] = true
end
for _, assetId in pairs(CurVersionExpiredAssetId) do
  CreativeExpiredAssetConfig.CurVersionExpiredAssetSet[assetId] = true
end
local ExpiredAssetIds
if ModuleManager ~= nil and Client ~= nil then
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  ExpiredAssetIds = LogicUGC:GetExpiredAssetIds()
else
  ExpiredAssetIds = {}
end
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
if PublishRegionMacros.IsBLUEHOLE() then
  for _, assetId in pairs(ExpiredAssetIds) do
    CreativeExpiredAssetConfig.BLUEHOLE_CurVersionExpiredAssetSet[assetId] = true
  end
else
  for _, assetId in pairs(ExpiredAssetIds) do
    CreativeExpiredAssetConfig.CurVersionExpiredAssetSet[assetId] = true
  end
end
if gTestItemExpiredItem then
  CreativeExpiredAssetConfig.CurVersionExpiredAssetSet[3101054] = true
end
function CreativeExpiredAssetConfig.GetUGCAssetParamPublishCfg()
  if CreativeExpiredAssetConfig._UGCAssetParamPublishCfgCache then
    return CreativeExpiredAssetConfig._UGCAssetParamPublishCfgCache
  end
  local BaseCfg = CDataTable.GetTable("UGCAssetParamPublishCfg")
  local bIsBluehole = false
  local ok, PublishRegionMacros = pcall(require, "client.slua.config.ClientMacros.PublishRegionMacros")
  if ok and PublishRegionMacros then
    bIsBluehole = PublishRegionMacros.IsBLUEHOLE()
  end
  if bIsBluehole then
    local BlueholeCfg = CDataTable.GetTable("UGCAssetParamPublishCfgBluehole")
    if BlueholeCfg then
      local MergedCfg = {}
      if BaseCfg then
        for ID, ResInfo in pairs(BaseCfg) do
          MergedCfg[ID] = ResInfo
        end
      end
      for ID, ResInfo in pairs(BlueholeCfg) do
        MergedCfg[ID] = ResInfo
      end
      CreativeExpiredAssetConfig._UGCAssetParamPublishCfgCache = MergedCfg
      return MergedCfg
    end
  end
  CreativeExpiredAssetConfig._UGCAssetParamPublishCfgCache = BaseCfg
  return BaseCfg
end
function CreativeExpiredAssetConfig.IsNextVersionExpired(assetId)
  return CreativeExpiredAssetConfig.NextVersionExpiredAssetSet[assetId]
end
local TestDsUnAuthorizedAsset = {}
function CreativeExpiredAssetConfig.IsCurVersionExpired(assetId, bSkipUnAuthor)
  if CreativeExpiredAssetConfig.CurVersionExpiredAssetSet[assetId] then
    return true
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() and CreativeExpiredAssetConfig.BLUEHOLE_CurVersionExpiredAssetSet[assetId] then
    return true
  end
  if CreativeExpiredAssetConfig.IsExclusiveIPExpiredAsset(assetId) then
    return true
  end
  if not bSkipUnAuthor then
    if Client == nil then
      if TestDsUnAuthorizedAsset[assetId] == true then
        print(bWriteLog and "CreativeExpiredAssetConfig.IsCurVersionExpired IsUnAuthorizedAsset assetId:" .. tostring(assetId))
        return true
      end
    elseif ModuleManager ~= nil then
      local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
      if LogicUGC:IsUGCEditMod() then
        local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
        if LogicUGCAuthor:IsUnAuthorizedAsset(assetId) then
          print(bWriteLog and "CreativeExpiredAssetConfig.IsCurVersionExpired IsUnAuthorizedAsset assetId:" .. tostring(assetId))
          return true
        end
      end
    end
  end
  return false
end
for k, v in pairs(CreativeExpiredAssetConfig.CurVersionExpiredAssetSet) do
  print(bWriteLog and "CreativeExpiredAssetConfig CurVersionExpiredAssetSet , k = " .. k)
end
function CreativeExpiredAssetConfig.AdditionalUnAuthorizedAsset(OutAssetSet)
  if Client == nil then
    for assetId, v in pairs(TestDsUnAuthorizedAsset) do
      OutAssetSet[assetId] = true
    end
  elseif ModuleManager ~= nil then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    if LogicUGC:IsUGCEditMod() then
      local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
      local UnAuthorizedAssetIDList = LogicUGCAuthor:GetUnAuthorizedAssetIDList()
      for i = 1, #UnAuthorizedAssetIDList do
        OutAssetSet[UnAuthorizedAssetIDList[i]] = true
      end
    end
  end
  return OutAssetSet
end
function CreativeExpiredAssetConfig.GetCurVersionExpiredAssetSet(bContainUnAuthorizedAsset)
  if bContainUnAuthorizedAsset == true then
    local OutAssetSet = DeepCopy(CreativeExpiredAssetConfig.CurVersionExpiredAssetSet)
    OutAssetSet = CreativeExpiredAssetConfig.AdditionalUnAuthorizedAsset(OutAssetSet)
    return OutAssetSet
  end
  return CreativeExpiredAssetConfig.CurVersionExpiredAssetSet
end
function CreativeExpiredAssetConfig.GetBlueholeCurVersionExpiredAssetSet(bContainUnAuthorizedAsset)
  if bContainUnAuthorizedAsset == true then
    local OutAssetSet = DeepCopy(CreativeExpiredAssetConfig.BLUEHOLE_CurVersionExpiredAssetSet)
    OutAssetSet = CreativeExpiredAssetConfig.AdditionalUnAuthorizedAsset(OutAssetSet)
    return OutAssetSet
  end
  return CreativeExpiredAssetConfig.BLUEHOLE_CurVersionExpiredAssetSet
end
function CreativeExpiredAssetConfig.GetExpiredResourceIDList()
  local _ExpiredIDTable = {}
  local TableUtil = require("common.table_util")
  local CreativeExpiredAssetConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.CreativeExpiredAssetConfig")
  if ServerDataMgr and ServerDataMgr.ds_expired_resource_ids then
    _ExpiredIDTable = TableUtil.MergeTable(_ExpiredIDTable, ServerDataMgr.ds_expired_resource_ids)
  else
    print(bWriteLog and "CreativeExpiredAssetConfig:GetExpiredResourceIDList ServerDataMgr.ds_expired_resource_ids is nil")
    if IsEditor then
    end
  end
  local UnAuthorizedAssetParameterIDList = CreativeExpiredAssetConfig.GetUnAuthorizedAssetParameterIDList()
  for k, UnAuthorizedID in pairs(UnAuthorizedAssetParameterIDList) do
    if not TableUtil.IsInTable(_ExpiredIDTable, UnAuthorizedID) then
      table.insert(_ExpiredIDTable, UnAuthorizedID)
    end
  end
  local ExclusiveIPExpiredIDList = CreativeExpiredAssetConfig.GetExclusiveIPExpiredIDList()
  for _, ExpiredID in pairs(ExclusiveIPExpiredIDList) do
    if not TableUtil.IsInTable(_ExpiredIDTable, ExpiredID) then
      table.insert(_ExpiredIDTable, ExpiredID)
    end
  end
  log_tree("CreativeExpiredAssetConfig.GetExpiredResourceIDList _ExpiredIDTable:", _ExpiredIDTable)
  return _ExpiredIDTable
end
function CreativeExpiredAssetConfig.GetExclusiveIPExpiredIDList()
  local ExclusiveIPExpiredIDList = {}
  local CurrentModTemplateId
  local GameParameterMgr = GetGameParameterManager and GetGameParameterManager() or nil
  if GameParameterMgr then
    local ModTemplateIdParam = GameParameterMgr:GetGameParameter("ModTemplateId")
    if ModTemplateIdParam then
      CurrentModTemplateId = ModTemplateIdParam.Value
    end
  end
  if not CurrentModTemplateId or CurrentModTemplateId == 0 then
    if IsEditor then
      print(bWriteLog and "CreativeExpiredAssetConfig.GetExclusiveIPExpiredIDList - Cannot get ModTemplateId, skip ExclusiveIP check")
    end
    return ExclusiveIPExpiredIDList
  end
  print(bWriteLog and "CreativeExpiredAssetConfig.GetExclusiveIPExpiredIDList - CurrentModTemplateId: " .. tostring(CurrentModTemplateId))
  local AssetParamPublishCfg = CreativeExpiredAssetConfig.GetUGCAssetParamPublishCfg()
  for ID, ResInfo in pairs(AssetParamPublishCfg) do
    local ExclusiveIPTemplateIDStr = ResInfo.ExclusiveIPTemplateID
    if ExclusiveIPTemplateIDStr and ExclusiveIPTemplateIDStr ~= "" then
      local bMatchCurrentTemplate = false
      for TemplateIdStr in string.gmatch(ExclusiveIPTemplateIDStr, "%d+") do
        local TemplateId = tonumber(TemplateIdStr)
        if TemplateId and TemplateId == CurrentModTemplateId then
          bMatchCurrentTemplate = true
          break
        end
      end
      if not bMatchCurrentTemplate then
        table.insert(ExclusiveIPExpiredIDList, ID)
        print(bWriteLog and "CreativeExpiredAssetConfig.GetExclusiveIPExpiredIDList - ExclusiveIP expired, ID: " .. tostring(ID) .. " ExclusiveIPTemplateID: " .. tostring(ExclusiveIPTemplateIDStr))
      end
    end
  end
  log_tree("CreativeExpiredAssetConfig.GetExclusiveIPExpiredIDList ExclusiveIPExpiredIDList:", ExclusiveIPExpiredIDList)
  return ExclusiveIPExpiredIDList
end
local ExclusiveIPAssetCache, ExclusiveIPAssetCacheModTemplateId
function CreativeExpiredAssetConfig.IsExclusiveIPExpiredAsset(assetId)
  local CurrentModTemplateId
  local GameParameterMgr = GetGameParameterManager and GetGameParameterManager() or nil
  if GameParameterMgr then
    local ModTemplateIdParam = GameParameterMgr:GetGameParameter("ModTemplateId")
    if ModTemplateIdParam then
      CurrentModTemplateId = ModTemplateIdParam.Value
    end
  end
  if not CurrentModTemplateId or CurrentModTemplateId == 0 then
    return false
  end
  print(bWriteLog and "CreativeExpiredAssetConfig.IsExclusiveIPExpiredAsset - CurrentModTemplateId: " .. tostring(CurrentModTemplateId))
  if ExclusiveIPAssetCache ~= nil and ExclusiveIPAssetCacheModTemplateId ~= CurrentModTemplateId then
    print(bWriteLog and "CreativeExpiredAssetConfig.IsExclusiveIPExpiredAsset - ModTemplateId changed from " .. tostring(ExclusiveIPAssetCacheModTemplateId) .. " to " .. tostring(CurrentModTemplateId) .. ", rebuilding cache")
    ExclusiveIPAssetCache = nil
    ExclusiveIPAssetCacheModTemplateId = nil
  end
  if ExclusiveIPAssetCache == nil then
    ExclusiveIPAssetCache = {}
    ExclusiveIPAssetCacheModTemplateId = CurrentModTemplateId
    local delayPublishCfg = {}
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsBLUEHOLE() then
      delayPublishCfg = CDataTable.GetTable("UGCDelayPublishConfigBluehole")
    else
      delayPublishCfg = CDataTable.GetTable("UGCDelayPublishConfig")
    end
    for _, assetInfo in pairs(delayPublishCfg) do
      local ExclusiveIPTemplateIDStr = assetInfo.ExclusiveIPTemplateID
      if ExclusiveIPTemplateIDStr and tostring(ExclusiveIPTemplateIDStr) ~= "" and tostring(ExclusiveIPTemplateIDStr) ~= "0" then
        local bMatchCurrentTemplate = false
        for TemplateIdStr in string.gmatch(tostring(ExclusiveIPTemplateIDStr), "%d+") do
          local TemplateId = tonumber(TemplateIdStr)
          if TemplateId and TemplateId == CurrentModTemplateId then
            bMatchCurrentTemplate = true
            break
          end
        end
        if not bMatchCurrentTemplate then
          local aid = assetInfo.AssetId or assetInfo.AssetID
          if aid then
            ExclusiveIPAssetCache[aid] = true
          end
        end
      end
    end
    print(bWriteLog and "CreativeExpiredAssetConfig.IsExclusiveIPExpiredAsset - Cache built with ModTemplateId: " .. tostring(CurrentModTemplateId))
  end
  return ExclusiveIPAssetCache[assetId] == true
end
function CreativeExpiredAssetConfig.GetAuthorizedAssetParameterIDList()
  local AuthorizedAssetParameterIDList = {}
  if ServerDataMgr ~= nil and ServerDataMgr.ugc_resource_whitelist ~= nil then
    local TableUtil = require("common.table_util")
    AuthorizedAssetParameterIDList = TableUtil.MergeTable(AuthorizedAssetParameterIDList, ServerDataMgr.ugc_resource_whitelist)
  else
    print(bWriteLog and "CreativeExpiredAssetConfig.GetAuthorizedAssetParameterIDList ServerDataMgr.ugc_resource_whitelist is nil")
    if IsEditor then
      table.insert(AuthorizedAssetParameterIDList, 2)
    end
  end
  return AuthorizedAssetParameterIDList
end
function CreativeExpiredAssetConfig.GetUnAuthorizedAssetParameterIDList()
  local UnAuthorizedAssetParameterIDList = {}
  local bIsEditorMode = false
  if ModuleManager ~= nil and Client ~= nil then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    if LogicUGC ~= nil and LogicUGC:IsUGCEditMod() then
      bIsEditorMode = true
    end
  elseif ServerDataMgr ~= nil then
    if ServerDataMgr:IsUGCModEdit() then
      bIsEditorMode = true
    end
  elseif slua.isValid(CGameState) and not CGameState:IsOfficialGame() then
    bIsEditorMode = true
  end
  if not bIsEditorMode then
    print(bWriteLog and "CreativeExpiredAssetConfig.GetUnAuthorizedAssetParameterIDList bIsEditorMode is false")
    return UnAuthorizedAssetParameterIDList
  end
  local AuthorizedAssetParameterIDList = CreativeExpiredAssetConfig.GetAuthorizedAssetParameterIDList()
  local TableUtil = require("common.table_util")
  local Cfg = CreativeExpiredAssetConfig.GetUGCAssetParamPublishCfg()
  for ID, ResInfo in pairs(Cfg) do
    if ResInfo.AuthorizedAssetParam == 1 and not TableUtil.IsInTable(AuthorizedAssetParameterIDList, ID) then
      table.insert(UnAuthorizedAssetParameterIDList, ID)
    end
  end
  log_tree("CreativeExpiredAssetConfig.GetUnAuthorizedAssetParameterIDList UnAuthorizedAssetParameterIDList:", UnAuthorizedAssetParameterIDList)
  return UnAuthorizedAssetParameterIDList
end
return CreativeExpiredAssetConfig