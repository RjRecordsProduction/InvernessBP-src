local PlaneCharacterBase = {}
function PlaneCharacterBase:ReceiveBeginPlay()
  print(bWriteLog and "PlaneCharacterBase:ReceiveBeginPlay")
  PlaneCharacterBase.__super.ReceiveBeginPlay(self)
  if Client then
    self.bCanShowBanner = false
    self.playingID = 0
    self:PlayOrStopAudio(true)
    if slua.isValid(self.PlaneAvatarComponent_BP) then
      self:AddControlEvent(self.PlaneAvatarComponent_BP, "PlaneAvatarEqiuped", self.OnPlaneAvatarEqiuped, self)
    end
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_HIDE, self.HidePlaneMesh, self)
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_SHOW, self.ShowPlaneMesh, self)
    self:AddGameTimer(1, false, function()
      self:CheckControllerViewTarget()
    end)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_CREATE, self)
end
function PlaneCharacterBase:CheckControllerViewTarget()
  if self and self.RootComponent and slua.isValid(self.RootComponent) then
    local ChildComponent = self.RootComponent.AttachChildren or {}
    local CharacterClass = import("STExtraPlayerCharacter")
    local ENetRole = import("ENetRole")
    for k, v in pairs(ChildComponent) do
      if v and slua.isValid(v) then
        local ChildActor = v:GetOwner()
        if ChildActor and slua.isValid(ChildActor) and Game:IsClassOf(ChildActor, CharacterClass) and ChildActor.bEnsure == false and ChildActor.Role == ENetRole.ROLE_AutonomousProxy then
          local Controller = ChildActor:GetPlayerControllerSafety()
          if Controller and slua.isValid(Controller) and Controller.ThePlane == nil then
            Controller.ThePlane = self.Object
            Controller:OnRep_Plane()
            print(bWriteLog and "PlaneCharacterBase:CheckControllerViewTarget, PlayerKey = " .. tostring(ChildActor.PlayerKey))
          end
          break
        end
      end
    end
  end
end
function PlaneCharacterBase:ReceiveEndPlay(_)
  print(bWriteLog and "PlaneCharacterBase:ReceiveEndPlay()")
  if Client then
    self:PlayOrStopAudio(false)
  end
  PlaneCharacterBase.__super.ReceiveEndPlay(self, _)
end
function PlaneCharacterBase:HidePlaneMesh()
  print(bWriteLog and "PlaneCharacterBase:HidePlaneMesh")
  if slua.isValid(self.StaticMesh) then
    print(bWriteLog and "PlaneCharacterBase:HidePlaneMesh 1")
    self.StaticMesh:SetHiddenInGame(true, true)
  end
end
function PlaneCharacterBase:ShowPlaneMesh()
  print(bWriteLog and "PlaneCharacterBase:ShowPlaneMesh")
  if slua.isValid(self.StaticMesh) then
    print(bWriteLog and "PlaneCharacterBase:ShowPlaneMesh 1")
    self.StaticMesh:SetHiddenInGame(false, true)
    self:CheckNeedShowBannerAndShow()
  end
end
function PlaneCharacterBase:PlayOrStopAudio(IsPlay)
  local audio_util = require("client.common.audio_util")
  print(bWriteLog and "PlaneCharacterBase:PlayOrStopAudio IsPlay:", IsPlay)
  if IsPlay then
    if self.playingID == 0 then
      local SoundPath = "/Game/WwiseEvent/Directing/Directing_Intro_Step01_Aircraft.Directing_Intro_Step01_Aircraft"
      audio_util.PlayAudioByActorAsync(SoundPath, self.Object, function(AKID)
        self.playingID = AKID
      end, true)
    end
  elseif self.playingID and 0 < self.playingID then
    audio_util.StopSound(self.playingID)
    self.playingID = 0
  end
end
function PlaneCharacterBase:OnPlaneAvatarEqiuped()
  if slua.isValid(self.StaticMesh) and self.StaticMesh.bHiddenInGame then
    local uComponentClass = import("/Script/Engine.ParticleSystemComponent")
    local uTargetArray = self:GetComponentsByTag(uComponentClass, "AvatarParticles")
    for _, Comp in pairs(uTargetArray) do
      Comp:SetHiddenInGame(true, true)
    end
    print(bWriteLog and "PlaneCharacterBase:OnPlaneAvatarEqiuped  self.StaticMesh.bHiddenInGame:true")
  end
end
function PlaneCharacterBase:CanShowPlaneBannerAndTexture()
  print(bWriteLog and "PlaneCharacterBase:CanShowPlaneBannerAndTexture self.bCanShowBanner:", self.bCanShowBanner)
  return self.bCanShowBanner
end
function PlaneCharacterBase:CheckNeedShowBannerAndShow()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.bEnablePlaneBanner and slua.isValid(self.BannerTexture) and self.HttpPlaneBannerLeftImgPath then
    self.bCanShowBanner = true
    self:OnRequestImgSuccess(self.BannerTexture, self.HttpPlaneBannerLeftImgPath)
    self:ClearImageResquest()
  end
end
function PlaneCharacterBase:ClearImageResquest()
  if Client and slua_GameFrontendHUD then
    local HttpWrapper = slua_GameFrontendHUD:GetHttpWrapper()
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(uPlayerController) then
      return
    end
    if uPlayerController.bEnablePlaneBanner then
      FuncUtil.UE4ExecuteConsoleCommand("s.EnableCompressFormatDownload 0")
      if slua.isValid(HttpWrapper) then
        print(bWriteLog and "PlaneCharacterBase:ClearImageResquest [YY-D] ClearImageDownLoadQueue")
        HttpWrapper:CancelRequestAll(0)
        HttpWrapper:CancelRequestAll(1)
        HttpWrapper:CancelRequestAll(2)
      end
      print(bWriteLog and "PlaneCharacterBase:ClearImageResquest [YY-D] ClearImageDownLoadQueue Clear Queue")
      return
    end
  end
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CPlaneCharacterBase = class(object, nil, PlaneCharacterBase)
return CPlaneCharacterBase