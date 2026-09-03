local PlacePrefabFeature = require("client.slua.logic.ugc.copilot.place_prefab_feature.place_prefab_feature")
local PrefabIconFeature = {}
PrefabIconFeature.Enum_SourceType = PlacePrefabFeature.Enum_SourceType
PrefabIconFeature.ICON_FETCH_TIMEOUT = 5.0
function PrefabIconFeature:ctor()
  print(bWriteLog and "PrefabIconFeature:ctor")
  self:ResetData()
end
function PrefabIconFeature:ResetData()
  self.PendingIconRequests = {}
  self.RequestSeq = 0
end
function PrefabIconFeature:OnInitialize()
  print(bWriteLog and "PrefabIconFeature:OnInitialize")
end
function PrefabIconFeature:GetPlacePrefabFeature()
  if self.Owner and self.Owner.PlacePrefabFeature then
    return self.Owner.PlacePrefabFeature
  end
  return nil
end
function PrefabIconFeature:GetIconInfo(SourceType, AssetID, Callback)
  self.RequestSeq = self.RequestSeq + 1
  local RequestID = self.RequestSeq
  print(bWriteLog and string.format("PrefabIconFeature:GetIconInfo - RequestID=%d, SourceType=%s, AssetID=%s", RequestID, tostring(SourceType), tostring(AssetID)))
  if not SourceType or not AssetID then
    if Callback then
      Callback({
        success = false,
        error_msg = "Missing SourceType or AssetID",
        source_type = SourceType,
        asset_id = AssetID
      })
    end
    return RequestID
  end
  self.PendingIconRequests[RequestID] = {
    SourceType = SourceType,
    AssetID = AssetID,
      }
  if SourceType == PrefabIconFeature.Enum_SourceType.Backpack then
    self:GetBackpackIcon(AssetID, Callback, RequestID)
  elseif SourceType == PrefabIconFeature.Enum_SourceType.Public then
    self:GetPublicIcon(AssetID, Callback, RequestID)
  elseif SourceType == PrefabIconFeature.Enum_SourceType.Private then
    self:GetPrivateIcon(AssetID, Callback, RequestID)
  else
    self.PendingIconRequests[RequestID] = nil
    if Callback then
      Callback({
        success = false,
        error_msg = "Invalid SourceType (must be 1=Backpack, 2=Public or 3=Private): " .. tostring(SourceType),
        source_type = SourceType,
        asset_id = AssetID
      })
    end
  end
  return RequestID
end
function PrefabIconFeature:SetPrefabIcon(UIBase, Widget, SourceType, AssetID, Options)
  Options = Options or {}
  self.RequestSeq = self.RequestSeq + 1
  local RequestID = self.RequestSeq
  print(bWriteLog and string.format("PrefabIconFeature:SetPrefabIcon - RequestID=%d, SourceType=%s, AssetID=%s", RequestID, tostring(SourceType), tostring(AssetID)))
  if not UIBase or not slua.isValid(Widget) then
    print(bWriteLog and "PrefabIconFeature:SetPrefabIcon - Invalid UIBase or Widget")
    if Options.onFailed then
      Options.onFailed("Invalid UIBase or Widget")
    end
    return RequestID
  end
  self.PendingIconRequests[RequestID] = {
    UIBase = UIBase,
    Widget = Widget,
    SourceType = SourceType,
    AssetID = AssetID,
      }
  if Options.defaultIcon and slua.isValid(Widget) then
    UIBase:SetTexture(Widget, Options.defaultIcon)
  end
  self:GetIconInfo(SourceType, AssetID, function(IconInfo)
    local Context = self.PendingIconRequests[RequestID]
    if not Context then
      print(bWriteLog and "PrefabIconFeature:SetPrefabIcon - Request cancelled: " .. tostring(RequestID))
      return
    end
    self.PendingIconRequests[RequestID] = nil
    if not slua.isValid(Context.Widget) then
      print(bWriteLog and "PrefabIconFeature:SetPrefabIcon - Widget destroyed: " .. tostring(RequestID))
      if Options.onFailed then
        Options.onFailed("Widget destroyed")
      end
      return
    end
    if not IconInfo.success then
      print(bWriteLog and "PrefabIconFeature:SetPrefabIcon - GetIconInfo failed: " .. tostring(IconInfo.error_msg))
      if Options.onFailed then
        Options.onFailed(IconInfo.error_msg)
      end
      return
    end
    if IconInfo.is_local then
      print(bWriteLog and "PrefabIconFeature:SetPrefabIcon - Setting local icon: " .. tostring(IconInfo.icon_url))
      Context.UIBase:SetTexture(Context.Widget, IconInfo.icon_url, {
        bMatchSize = Options.bMatchSize or false
      })
      if Options.onSuccess then
        Options.onSuccess(IconInfo)
      end
    else
      print(bWriteLog and "PrefabIconFeature:SetPrefabIcon - Setting network icon: " .. tostring(IconInfo.icon_url))
      local Util_UGC = require("client.slua.logic.ugc.util_ugc")
      Util_UGC.SetUGCImage(Context.UIBase, Context.Widget, IconInfo.icon_url, Options.bMatchSize or false, function()
        if Options.onSuccess then
          Options.onSuccess(IconInfo)
        end
      end, Options.onFailed, Options.imageCacheType)
    end
  end)
  return RequestID
end
function PrefabIconFeature:CancelIconRequest(RequestID)
  if RequestID and self.PendingIconRequests[RequestID] then
    self.PendingIconRequests[RequestID] = nil
    print(bWriteLog and "PrefabIconFeature:CancelIconRequest - RequestID: " .. tostring(RequestID))
  end
end
function PrefabIconFeature:CleanupAllRequests()
  local Count = 0
  for RequestID, _ in pairs(self.PendingIconRequests) do
    Count = Count + 1
  end
  self.PendingIconRequests = {}
  print(bWriteLog and "PrefabIconFeature:CleanupAllRequests - Cleaned " .. tostring(Count) .. " requests")
end
function PrefabIconFeature:GetBackpackIcon(AssetID, Callback, RequestID)
  print(bWriteLog and "PrefabIconFeature:GetBackpackIcon - AssetID: " .. tostring(AssetID))
  if not self.PendingIconRequests[RequestID] then
    return
  end
  local AssetManager = GetAssetManager and GetAssetManager() or nil
  local AssetConfig = AssetManager and AssetManager:GetAssetInfo(AssetID) or nil
  if AssetConfig then
    local bIsCustomPrefab = AssetConfig.CustomPrefab ~= nil or AssetConfig.EditPrefabModify ~= nil
    if bIsCustomPrefab then
      local IconURL = AssetManager:GetAssetURL(AssetConfig)
      self.PendingIconRequests[RequestID] = nil
      if Callback then
        Callback({
          success = IconURL ~= nil and IconURL ~= "",
          icon_url = IconURL,
          is_local = false,
          source_type = PrefabIconFeature.Enum_SourceType.Backpack,
          asset_id = AssetID,
          error_msg = (IconURL == nil or IconURL == "") and "Custom prefab icon URL not found" or nil
        })
      end
      return
    end
  end
  local CreativeModeUIUtils = require("GameLua.Mod.CreativeBase.Client.CreativeModeUIUtils")
  local IconPath = CreativeModeUIUtils.GetAssetSmallIcon(AssetID)
  self.PendingIconRequests[RequestID] = nil
  if Callback then
    Callback({
      success = IconPath ~= nil and IconPath ~= "",
      icon_url = IconPath,
      is_local = true,
      source_type = PrefabIconFeature.Enum_SourceType.Backpack,
      asset_id = AssetID,
      error_msg = (IconPath == nil or IconPath == "") and "Backpack icon not found" or nil
    })
  end
end
function PrefabIconFeature:GetPublicIcon(PrefabID, Callback, RequestID)
  print(bWriteLog and "PrefabIconFeature:GetPublicIcon - PrefabID: " .. tostring(PrefabID))
  if not self.PendingIconRequests[RequestID] then
    return
  end
  local logic_ugc_prefab_mall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
  if not logic_ugc_prefab_mall then
    self.PendingIconRequests[RequestID] = nil
    if Callback then
      Callback({
        success = false,
        error_msg = "logic_ugc_prefab_mall not available",
        source_type = PrefabIconFeature.Enum_SourceType.Public,
        asset_id = PrefabID
      })
    end
    return
  end
  local MetaInfo = logic_ugc_prefab_mall:GetPrefabMeta(PrefabID)
  if MetaInfo and MetaInfo.Meta and MetaInfo.Meta.Pic_Url then
    print(bWriteLog and "PrefabIconFeature:GetPublicIcon - Meta cached, Pic_Url: " .. tostring(MetaInfo.Meta.Pic_Url))
    self.PendingIconRequests[RequestID] = nil
    if Callback then
      Callback({
        success = true,
        icon_url = MetaInfo.Meta.Pic_Url,
        is_local = false,
        source_type = PrefabIconFeature.Enum_SourceType.Public,
        asset_id = PrefabID
      })
    end
    return
  end
  print(bWriteLog and "PrefabIconFeature:GetPublicIcon - Fetching meta for PrefabID: " .. tostring(PrefabID))
  local PlacePrefabFeatureInst = self:GetPlacePrefabFeature()
  if not PlacePrefabFeatureInst then
    self.PendingIconRequests[RequestID] = nil
    if Callback then
      Callback({
        success = false,
        error_msg = "PlacePrefabFeature not available",
        source_type = PrefabIconFeature.Enum_SourceType.Public,
        asset_id = PrefabID
      })
    end
    return
  end
  PlacePrefabFeatureInst:FetchPublicPrefabMetaManaged(PrefabID, RequestID, function(Success, FetchedMeta)
    if not self.PendingIconRequests[RequestID] then
      print(bWriteLog and "PrefabIconFeature:GetPublicIcon - Request cancelled after meta fetch")
      return
    end
    self.PendingIconRequests[RequestID] = nil
    if Success and FetchedMeta and FetchedMeta.Meta and FetchedMeta.Meta.Pic_Url then
      print(bWriteLog and "PrefabIconFeature:GetPublicIcon - Meta fetched, Pic_Url: " .. tostring(FetchedMeta.Meta.Pic_Url))
      if Callback then
        Callback({
          success = true,
          icon_url = FetchedMeta.Meta.Pic_Url,
          is_local = false,
          source_type = PrefabIconFeature.Enum_SourceType.Public,
          asset_id = PrefabID
        })
      end
    else
      print(bWriteLog and "PrefabIconFeature:GetPublicIcon - Meta fetch failed or no Pic_Url")
      if Callback then
        Callback({
          success = false,
          error_msg = "Failed to fetch public meta or no Pic_Url",
          source_type = PrefabIconFeature.Enum_SourceType.Public,
          asset_id = PrefabID
        })
      end
    end
  end)
end
function PrefabIconFeature:GetPrivateIcon(Slot, Callback, RequestID)
  print(bWriteLog and "PrefabIconFeature:GetPrivateIcon - Slot: " .. tostring(Slot))
  if not self.PendingIconRequests[RequestID] then
    return
  end
  local logic_ugc_prefab_mall_private = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private")
  if logic_ugc_prefab_mall_private:IsPrivateMetaCompleted() then
    local MetaInfo = logic_ugc_prefab_mall_private:GetPrivateMeta(Slot)
    if MetaInfo and MetaInfo.Meta and MetaInfo.Meta.Pic_Url then
      print(bWriteLog and "PrefabIconFeature:GetPrivateIcon - Meta cached, Pic_Url: " .. tostring(MetaInfo.Meta.Pic_Url))
      self.PendingIconRequests[RequestID] = nil
      if Callback then
        Callback({
          success = true,
          icon_url = MetaInfo.Meta.Pic_Url,
          is_local = false,
          source_type = PrefabIconFeature.Enum_SourceType.Private,
          asset_id = Slot
        })
      end
      return
    end
  end
  print(bWriteLog and "PrefabIconFeature:GetPrivateIcon - Fetching private meta for Slot: " .. tostring(Slot))
  local PlacePrefabFeatureInst = self:GetPlacePrefabFeature()
  if not PlacePrefabFeatureInst then
    self.PendingIconRequests[RequestID] = nil
    if Callback then
      Callback({
        success = false,
        error_msg = "PlacePrefabFeature not available",
        source_type = PrefabIconFeature.Enum_SourceType.Private,
        asset_id = Slot
      })
    end
    return
  end
  PlacePrefabFeatureInst:FetchPrivatePrefabMetaManaged(Slot, nil, function(Success, FetchedMeta)
    if not self.PendingIconRequests[RequestID] then
      print(bWriteLog and "PrefabIconFeature:GetPrivateIcon - Request cancelled after meta fetch")
      return
    end
    self.PendingIconRequests[RequestID] = nil
    if Success and FetchedMeta and FetchedMeta.Meta and FetchedMeta.Meta.Pic_Url then
      print(bWriteLog and "PrefabIconFeature:GetPrivateIcon - Meta fetched, Pic_Url: " .. tostring(FetchedMeta.Meta.Pic_Url))
      if Callback then
        Callback({
          success = true,
          icon_url = FetchedMeta.Meta.Pic_Url,
          is_local = false,
          source_type = PrefabIconFeature.Enum_SourceType.Private,
          asset_id = Slot
        })
      end
    else
      print(bWriteLog and "PrefabIconFeature:GetPrivateIcon - Meta fetch failed or no Pic_Url")
      if Callback then
        Callback({
          success = false,
          error_msg = "Failed to fetch private meta or no Pic_Url for slot: " .. tostring(Slot),
          source_type = PrefabIconFeature.Enum_SourceType.Private,
          asset_id = Slot
        })
      end
    end
  end)
end
local class = require("class")
local object = require("object")
return class(object, nil, PrefabIconFeature)