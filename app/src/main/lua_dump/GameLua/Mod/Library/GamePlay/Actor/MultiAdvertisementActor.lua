local MultiAdvertisementActor = {}
function MultiAdvertisementActor:ctor()
  self.AdvIdList = {}
  self.SwitchSequence = {}
  self.CurIndex = 0
  self.DownloadId = 1
  self.LoadMeshFinished = false
  self.ReceiveImageUrlList = false
  self.IsPlaying = false
  self.IsStarted = false
  self.MaterialPath = "/Game/Mod/EvoBase/Materials/M_ScreenSwitch.M_ScreenSwitch"
  self.DefaultAdvPath = "/Game/Assets/ScnenCommerce/Model/230FORTEST.230FORTEST"
end
function MultiAdvertisementActor:OnClientLoadMesh()
  MultiAdvertisementActor.__super.OnClientLoadMesh(self)
  if Client then
    local Util = require("client.slua_ui_framework.util")
    local UKismetMaterialLibrary = import("KismetMaterialLibrary")
    Util.GetAssetAsync(self.MaterialPath, function(uMaterial)
      if slua.isValid(uMaterial) and slua.isValid(self.StaticMeshComponent) then
        local DynamicMaterial = UKismetMaterialLibrary.CreateDynamicMaterialInstance(slua_GameFrontendHUD:GetWorld(), uMaterial)
        self.StaticMeshComponent:SetMaterial(0, DynamicMaterial)
        self.LoadMeshFinished = true
        print(bWriteLog and "[YY-D] MultiAdvertisementActor:OnClientLoadMesh")
        if self.ReceiveImageUrlList then
          self:StartImagesDownload()
        end
      else
        print(bWriteLog and "[YY-E] MultiAdvertisementActor:OnClientLoadMesh InValid uMaterial or StaticMeshComponent")
      end
    end)
  end
end
function MultiAdvertisementActor:DownLoadImages(UrlPathList)
  if not Client then
    return
  end
  print(bWriteLog and "[YY-D] MultiAdvertisementActor:OnRep_ImageList")
  for Index, sUrl in ipairs(UrlPathList) do
    if not self.AdvIdList[Index] then
      self.AdvIdList[Index] = {}
      self.AdvIdList[Index].Url = sUrl
      table.insert(self.SwitchSequence, Index)
    end
  end
  log_tree("AdvIdList", self.AdvIdList)
  self.ReceiveImageUrlList = true
  if self.LoadMeshFinished then
    self:StartImagesDownload()
  end
end
function MultiAdvertisementActor:StartImagesDownload()
  if slua_GameFrontendHUD and not self.IsStarted then
    self.IsStarted = true
    print(bWriteLog and "[YY-D] MultiAdvertisementActor:StartImagesDownload")
    local GameInstance = slua_GameFrontendHUD:GetGameInstance()
    if slua.isValid(GameInstance) then
      do
        local Util = require("client.slua_ui_framework.util")
        local UKismetMaterialLibrary = import("KismetMaterialLibrary")
        Util.GetAssetAsync(self.DefaultAdvPath, function(uTexture)
          if slua.isValid(uTexture) and slua.isValid(self.Object) then
            self:ReplaceTextureWithAnimation(uTexture)
            local nDeviceLevel = GameInstance:GetDeviceLevel()
            if 1 <= nDeviceLevel then
              self:StartPlayAdvertisement()
            end
          end
        end)
      end
    end
  end
end
function MultiAdvertisementActor:GetAdvTextureFromInstance(imgUrl)
  if Client then
    print(bWriteLog and "[YY-D] MultiAdvertisementActor:GetAdvTextureFromInstance imgUrl:" .. imgUrl)
    local GameInstance
    if slua_GameFrontendHUD then
      GameInstance = slua_GameFrontendHUD:GetGameInstance()
    end
    if slua.isValid(GameInstance) and slua.isValid(GameInstance.ClientBaseInfo) and slua.isValid(GameInstance.ClientBaseInfo.AdvTextureList) then
      local uAdvTextureList = slua.IndexReference(GameInstance, "ClientBaseInfo", "AdvTextureList")
      local uTexture = uAdvTextureList:Get(imgUrl)
      if slua.isValid(uTexture) then
        return uTexture
      end
    end
  end
end
function MultiAdvertisementActor:StartPlayAdvertisement()
  if not self.IsPlaying then
    print(bWriteLog and "[YY-D] MultiAdvertisementActor:StartPlayAdvertisement")
    self.IsPlaying = true
    self:SwitchTexture()
    self:AddGameTimer(5, true, function()
      self:SwitchTexture()
    end)
  end
end
function MultiAdvertisementActor:SwitchTexture()
  local uTexture = self:GetNextTexture()
  if slua.isValid(uTexture) and slua.isValid(self.Object) then
    print(bWriteLog and "[YY-D] MultiAdvertisementActor:SwitchTexture")
    self:ReplaceTextureWithAnimation(uTexture)
  end
end
function MultiAdvertisementActor:GetNextTexture()
  local nNextIndex = self.CurIndex + 1
  if #self.SwitchSequence > 0 then
    if nNextIndex > #self.SwitchSequence then
      nNextIndex = 1
    end
    print(bWriteLog and "[YY-D] MultiAdvertisementActor:GetNextTexture nNextIndex = " .. nNextIndex)
    if nNextIndex == self.CurIndex then
      return
    end
    local TextureID = self.SwitchSequence[nNextIndex]
    if TextureID and self.AdvIdList[TextureID].Url then
      self.CurIndex = nNextIndex
      return self:GetAdvTextureFromInstance(self.AdvIdList[nNextIndex].Url)
    end
  end
  return
end
local class = require("class")
local CAdvertisementActorBase = require("GameLua.Mod.Library.GamePlay.Actor.AdvertisementActorBase")
local CMultiAdvertisementActor = class(CAdvertisementActorBase, nil, MultiAdvertisementActor)
return CMultiAdvertisementActor