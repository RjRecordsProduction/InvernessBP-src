local AdvertisementActorBase = {}
function AdvertisementActorBase:ctor()
end
function AdvertisementActorBase:_PostConstruct()
  print(bWriteLog and "[YY-D] AdvertisementActorBase:_PostConstruct")
  AdvertisementActorBase.__super._PostConstruct(self)
  if Client then
    self:InitImageDownloadUtil()
    if IsEditor then
    end
  end
  self.bRelevantForNetworkReplays = true
  self:MarkNetDormancyForReplay(true, false)
end
function AdvertisementActorBase:OnRep_MeshPath()
  if self.StaticMeshPath and self.StaticMeshPath ~= "" then
    print(bWriteLog and "[YY-D] AdvertisementActorBase:OnRep_MeshPath")
    local Util = require("client.slua_ui_framework.util")
    Util.GetAssetAsync(self.StaticMeshPath, function(uMesh)
      if slua.isValid(uMesh) and self.SetStaticMesh then
        print(bWriteLog and "[YY-D] AdvertisementActorBase:OnRep_MeshPath LoadMesh Finish")
        self:SetStaticMesh(uMesh)
        self:OnClientLoadMesh()
      else
        print(bWriteLog and "[YY-E] AdvertisementActorBase:OnRep_MeshPath InValid uMesh or self.SetStaticMesh")
      end
    end)
  end
end
function AdvertisementActorBase:OnClientLoadMesh()
end
function AdvertisementActorBase:OnRep_Id()
  print(bWriteLog and "[YY-D] AdvertisementActorBase:OnRep_Id")
  local UrlPath = self:GetAdvImageUrlById(self.Id)
  if UrlPath and UrlPath ~= "" then
    local StringUtil = require("common.string_util")
    local UrlPathList = StringUtil.Split(UrlPath, "|")
    if UrlPathList and next(UrlPathList) then
      self:DownLoadImages(UrlPathList)
    end
  else
    print(bWriteLog and "[YY-E] AdvertisementActorBase:OnRep_Id Url is nil")
  end
end
function AdvertisementActorBase:DownLoadImages(UrlPathList)
end
function AdvertisementActorBase:GetAdvImageUrlById(nId)
  print(bWriteLog and "[YY-D] AdvertisementActorBase:GetAdvImageUrlById Id = " .. nId)
  local GameInstance
  if slua_GameFrontendHUD then
    GameInstance = slua_GameFrontendHUD:GetGameInstance()
  end
  if slua.isValid(GameInstance) and slua.isValid(GameInstance.ClientBaseInfo) and slua.isValid(GameInstance.ClientBaseInfo.AdvConfig) then
    local sPath = GameInstance.ClientBaseInfo.AdvConfig:Get(nId)
    if sPath ~= nil then
      print(bWriteLog and "[YY-D] AdvertisementActorBase:GetAdvImageUrlById sPath = " .. sPath)
    end
    return sPath
  end
end
function AdvertisementActorBase:OnRequestImgSuccess(uTexture, RequestedURL)
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CAdvertisementActorBase = class(CActorBase, nil, AdvertisementActorBase)
return CAdvertisementActorBase