local VehicleMusicComponent = {}
local UGameplayStatics = import("GameplayStatics")
local ENetRole = import("ENetRole")
function VehicleMusicComponent:ctor(SelfType)
end
function VehicleMusicComponent:ReceiveBeginPlay()
  VehicleMusicComponent.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "VehicleMusicComponent:ReceiveBeginPlay, bEnbaleAvatarMusic is ", self.bEnableAvatarMusic)
  if GameStatus.IsPHomeMode() then
    log(bWriteLog and "VehicleMusicComponent:ReceiveBeginPlay GameStatus.IsPHomeMode")
    local PlanPH_Wedding_Utils = require("GameLua.Mod.PlanPH.Gameplay.Activity.Wedding.PlanPH_Wedding_Utils")
    if Client and PlanPH_Wedding_Utils.HasWedding() then
      log(bWriteLog and "VehicleMusicComponent:ReceiveBeginPlay PlanPH_Wedding_Utils.HasWedding")
      self.bEnableAvatarMusic = false
      self.bVehicleMusicEnabled = false
      self.bWeddingVehicle = true
    end
  end
end
function VehicleMusicComponent:ReceiveEndPlay()
  VehicleMusicComponent.__super.ReceiveEndPlay(self)
  print(bWriteLog and "VehicleMusicComponent:ReceiveEndPlay ")
end
function VehicleMusicComponent:_PostConstruct()
  local uVehicle = self:GetOwner()
  if not slua.isValid(uVehicle) then
    return
  end
  local VehicleSeat = uVehicle:GetVehicleSeats()
  if not slua.isValid(VehicleSeat) then
    return
  end
  print(bWriteLog and "VehicleMusicComponent:_PostConstruct ")
  if Client then
    self:AddControlEvent(uVehicle, "OnClientEnterVehicleEvent", self.ClientHandleCharacterEnter, self)
    self:AddControlEvent(uVehicle, "OnClientExitVehicleEvent", self.ClientHandleCharacterExit, self)
    self:AddControlEvent(uVehicle, "OnClientChangeVehicleSeatEvent", self.ClientHandleCharacterChangeSeat, self)
    self:AddControlEvent(uVehicle, "OnVehicleHealthStateChanged", self.HandleHealthStateChanged, self)
    self:AddControlEvent(self, "OnSongChanged", self.HandleOnSongChanged, self)
    if uVehicle.GetAvatarComponent then
      local AvatarComp = uVehicle:GetAvatarComponent()
      if slua.isValid(AvatarComp) then
        self:AddControlEvent(AvatarComp, "VehicleLoadedFPPMesh", self.ClientHandleAvatarChanged, self, false)
        self:AddControlEvent(AvatarComp, "VehicleAvatarEqiuped", self.ClientHandleAvatarChanged, self, false)
      end
    end
    if uVehicle.GetAdvanceAvatarComponent then
      local AdvanceAvatarComp = uVehicle:GetAdvanceAvatarComponent()
      if slua.isValid(AdvanceAvatarComp) then
        self:AddControlEvent(AdvanceAvatarComp, "OnAvatarAllMeshLoaded", self.ClientHandleAvatarChanged, self, true)
      end
    end
  end
end
function VehicleMusicComponent:OnDestroyed()
  print(bWriteLog and "VehicleMusicComponent:OnDestroyed")
  self:Dispose()
  VehicleMusicComponent.__super.OnDestroyed(self)
end
function VehicleMusicComponent:HandleHealthStateChanged(NewHealthState)
  local ESTExtraVehicleHealthState = import("ESTExtraVehicleHealthState")
  if NewHealthState == ESTExtraVehicleHealthState.VHS_Destroyed then
    print(bWriteLog and "VehicleMusicComponent:VehicleState Destroy, Stop Current Music ")
    self:StopCurrentMusic()
  end
end
function VehicleMusicComponent:ClientHandleCharacterChangeSeat(uInCharacter, uOldSeat, uNewSeat)
  local uVehicle = self:GetOwner()
  if not slua.isValid(uVehicle) or not slua.isValid(uInCharacter) then
    print(bWriteLog and "VehicleMusicComponent:ClientHandleCharacterChangeSeat Fail, uVehicle or Player is invalid")
    return
  end
  print(bWriteLog and "VehicleMusicComponent:ClientHandleCharacterEnter, uOldSeat, uNewSeat", uOldSeat, uNewSeat)
  self:ClientHandleCharacterEnter(uInCharacter, uNewSeat)
end
function VehicleMusicComponent:ClientHandleCharacterEnter(uInCharacter, nSeatType)
  local uVehicle = self:GetOwner()
  if not slua.isValid(uVehicle) or not slua.isValid(uInCharacter) then
    print(bWriteLog and "VehicleMusicComponent:ClientHandleCharacterEnter Fail, uVehicle or Player is invalid")
    return
  end
  local uController = uInCharacter:GetPlayerControllerSafety()
  if not uController or not uController:GetVehicleUserComp() then
    print(bWriteLog and "VehicleMusicComponent:ClientHandleCharacterEnter Fail, uController is invalid")
    return
  end
  if self.bWeddingVehicle then
    log(bWriteLog and "VehicleMusicComponent:ClientHandleCharacterEnter bWeddingVehicle")
    return
  end
  local VehicleUser = uController:GetVehicleUserComp()
  local bEnablePlayDefault = VehicleUser.bPlayMusicEnabled
  local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
  local bIsDriver = nSeatType == ESTExtraVehicleSeatType.ESeatType_DriversSeat
  if not bIsDriver then
    print(bWriteLog and "VehicleMusicComponent:ClientHandleCharacterEnter, not driver")
    self:LuaInitDefaultMusicList(uInCharacter)
    if self.ServerPlayingAvatarMusicID == -1 then
      if bEnablePlayDefault then
        self:StartPlayVehicleMusic(true)
      end
    else
      self:LoadAvatarMusicInfo(self.ServerPlayingAvatarMusicID)
      print(bWriteLog and "VehicleMusicComponent:ClientHandleCharacterEnter, not driver ServerPlayingAvatarMusicID ID is ", self.ServerPlayingAvatarMusicID)
      self:AsyncPlayMusic(self.ServerPlayingAvatarMusicID)
    end
    return
  end
  local bPlayMusicList = self:CheckCanUseMusicList(uController, uVehicle)
  print(bWriteLog and "VehicleMusicComponent:ClientHandleCharacterEnter, isNowAvatar, bEnableAvatarMusic", bPlayMusicList, self.bEnableAvatarMusic)
  if not bPlayMusicList then
    print(bWriteLog and "VehicleMusicComponent:ClientHandleCharacterEnter Play defaultMusic")
    self:LuaInitDefaultMusicList(uInCharacter)
    if bEnablePlayDefault then
      self:StartPlayVehicleMusic(true)
    end
  else
    local bLoadSuccess = self:LuaInitAvatarMusicList(uInCharacter)
    print(bWriteLog and "VehicleMusicComponent:ClientHandleCharacterEnter, Driver, Load avatarmusic list result:", bLoadSuccess)
    if bLoadSuccess then
      self:StartPlayVehicleMusic(false)
    else
      print(bWriteLog and "VehicleMusicComponent:ClientHandleCharacterEnter Avatarmusic load fail, play default music")
      self:LuaInitDefaultMusicList(uInCharacter)
      if bEnablePlayDefault then
        self:StartPlayVehicleMusic(true)
      end
    end
  end
end
function VehicleMusicComponent:ClientHandleCharacterExit(uInCharacter, _)
  if not slua.isValid(uInCharacter) then
    print(bWriteLog and "VehicleMusicComponent:ClientHandleCharacterExit Fail,  Player is invalid")
    return
  end
  if self.bWeddingVehicle then
    log(bWriteLog and "VehicleMusicComponent:ClientHandleCharacterExit bWeddingVehicle")
    return
  end
  print(bWriteLog and "VehicleMusicComponent:ClientHandleCharacterExit, StopCurrentMusic")
  self:StopCurrentMusic()
end
function VehicleMusicComponent:ClientHandleAvatarChanged(bIsAdvancedAvatar)
  local uVehicle = self:GetOwner()
  if not slua.isValid(uVehicle) or not slua.isValid(uVehicle:GetAvatarComponent()) then
    return
  end
  local uSelfController = UGameplayStatics.GetPlayerController(self, 0)
  if not slua.isValid(uSelfController) or not uSelfController.GetPlayerCharacterSafety then
    return
  end
  local uSelfPlayerCharacter = uSelfController:GetPlayerCharacterSafety()
  if not slua.isValid(uSelfPlayerCharacter) or uSelfPlayerCharacter:GetCurrentVehicle() ~= uVehicle then
    return
  end
  local AvatarComp = uVehicle:GetAvatarComponent()
  local AdvanceAvatarComp = uVehicle:GetAdvanceAvatarComponent()
  local nClientAvatarID = 0
  if bIsAdvancedAvatar and slua.isValid(AdvanceAvatarComp) then
    nClientAvatarID = AdvanceAvatarComp.VehicleSkinID
  elseif not bIsAdvancedAvatar and slua.isValid(AvatarComp) then
    nClientAvatarID = AvatarComp:GetCurrentAvatarID()
  end
  print(bWriteLog and "VehicleMusicComponent:ClientHandleAvatarChanged, bIsAdvancedAvatar", bIsAdvancedAvatar, nClientAvatarID)
  if self.LastClientAvatarID == nClientAvatarID then
    print(bWriteLog and "VehicleMusicComponent:ClientHandleAvatarChanged return, FPP <-> TPP ", nClientAvatarID)
    return
  end
  local bIsDriver = Game:IsDriver(uSelfPlayerCharacter)
  if not bIsDriver then
    print(bWriteLog and "VehicleMusicComponent:ClientHandleAvatarChanged, not driver")
    self:LuaInitDefaultMusicList(uSelfPlayerCharacter)
    if self.ServerPlayingAvatarMusicID == -1 and not self.bIsCurrentDefaultMusic then
      self:StartPlayVehicleMusic(true)
    end
    self.LastClientAvatarID = nClientAvatarID
    return
  end
  local bPlayMusicList = self:CheckCanUseMusicList(uSelfController, uVehicle, nClientAvatarID)
  print(bWriteLog and "VehicleMusicComponent:ClientHandleAvatarChanged bPlayMusicList ", bPlayMusicList, self.bIsCurrentDefaultMusic, self.bEnableAvatarMusic)
  if not bPlayMusicList and not self.bIsCurrentDefaultMusic then
    print(bWriteLog and "VehicleMusicComponent:ClientHandleAvatarChanged better->default ")
    self:LuaInitDefaultMusicList(uSelfPlayerCharacter)
    self:StartPlayVehicleMusic(true)
  elseif bPlayMusicList and self.bIsCurrentDefaultMusic and uVehicle:IsAutonomousProxy() then
    print(bWriteLog and "VehicleMusicComponent:ClientHandleAvatarChanged default->better ")
    local bSuccess = self:LuaInitAvatarMusicList(uSelfPlayerCharacter)
    if bSuccess then
      self:StartPlayVehicleMusic(false)
    end
  end
  self.LastClientAvatarID = nClientAvatarID
end
function VehicleMusicComponent:LuaInitDefaultMusicList(uInCharacter)
  local uVehicle = self:GetOwner()
  if not (not Server and slua.isValid(uInCharacter)) or not slua.isValid(uVehicle) then
    return
  end
  local uController = uInCharacter:GetPlayerControllerSafety()
  if not slua.isValid(uController) or not uController.DefaultVehicleMusic then
    return
  end
  print(bWriteLog and "VehicleMusicComponent:LuaInitDefaultMusicList" .. uController.DefaultVehicleMusic:Num())
  if uController.DefaultVehicleMusic:Num() ~= self.DefaultMusicInfoMap:Num() then
    local MusicList = {}
    for _, MusicID in pairs(uController.DefaultVehicleMusic) do
      local SongEntry = CDataTable.GetTableData("DefaultVehicleMusic", MusicID)
      if SongEntry and SongEntry.SongEvent then
        local SongInfoEntry = {
          SongID = MusicID,
          SongEvent = SongEntry.SongEvent,
          SongDuration = SongEntry.SongDuration
        }
        table.insert(MusicList, SongInfoEntry)
      end
      print(bWriteLog and "VehicleMusicComponent:LuaInitDefaultMusicList, DefaultMusicID loaded" .. MusicID)
    end
    self:InitDefaultMusicList(MusicList)
  end
end
function VehicleMusicComponent:LuaInitAvatarMusicList(uInCharacter)
  local Vehicle = self:GetOwner()
  if not (not Server and slua.isValid(uInCharacter)) or not slua.isValid(Vehicle) then
    return false
  end
  local uController = uInCharacter:GetPlayerControllerSafety()
  if not slua.isValid(uController) or not uController.VehicleMusicList then
    return false
  end
  local logic_pubgm_music_download = require("client.slua.logic.pubgm_music.logic_pubgm_music_download")
  local MusicList = {}
  print(bWriteLog and "VehicleMusicComponent:LuaInitAvatarMusicList, Load VehicleMusic" .. uController.VehicleMusicList:Num())
  for _, MusicID in pairs(uController.VehicleMusicList) do
    if logic_pubgm_music_download.GetMusicDownloadStateByID(MusicID) == ENUM_DownloadState.Done then
      local SongEntry = CDataTable.GetTableData("VehicleMusic", MusicID)
      local ItemEntry = CDataTable.GetTableData("Item", MusicID)
      if SongEntry then
        local Name = ""
        if ItemEntry then
          Name = ItemEntry.ItemName
        end
        local SongInfoEntry = {
          SongID = MusicID,
          SongName = Name,
          SongDuration = SongEntry.SongDuration,
          SongEvent = SongEntry.SongEvent
        }
        table.insert(MusicList, SongInfoEntry)
        print(bWriteLog and "VehicleMusicComponent:LuaInitAvatarMusicList, Insert VehicleMusic", MusicID, Name, SongEntry.SongDuration, SongEntry.SongEvent)
      end
      print(bWriteLog and "VehicleMusicComponent:LuaInitAvatarMusicList, Load VehicleMusic", MusicID)
    else
      print(bWriteLog and "VehicleMusicComponent:LuaInitAvatarMusicList, Music has not load", MusicID)
    end
  end
  if not next(MusicList) then
    print(bWriteLog and "VehicleMusicComponent:LuaInitAvatarMusicList, no file loaded ")
    return false
  end
  self:InitAvatarMusicList(MusicList)
  return true
end
function VehicleMusicComponent:LoadAvatarMusicInfo(nMusicID)
  print(bWriteLog and "VehicleMusicComponent:LoadAvatarMusicInfo, Music ID is", nMusicID)
  local logic_pubgm_music_download = require("client.slua.logic.pubgm_music.logic_pubgm_music_download")
  local AudioEvents = {}
  if logic_pubgm_music_download.GetMusicDownloadStateByID(nMusicID) ~= ENUM_DownloadState.Done then
    print(bWriteLog and "VehicleMusicComponent:LoadAvatarMusicInfo has not downloaded", nMusicID)
    return
  end
  local SongEntry = CDataTable.GetTableData("VehicleMusic", nMusicID)
  local ItemEntry = CDataTable.GetTableData("Item", nMusicID)
  if SongEntry then
    local Name = ""
    if ItemEntry then
      Name = ItemEntry.ItemName
    end
    local SongInfoEntry = {
      SongID = nMusicID,
      SongName = Name,
      SongDuration = SongEntry.SongDuration,
      SongEvent = SongEntry.SongEvent
    }
    table.insert(AudioEvents, SongInfoEntry)
  end
  if not next(AudioEvents) then
    print(bWriteLog and "VehicleMusicComponent:LoadAvatarMusicInfo, Load fail, ID is ", nMusicID)
  end
  self.bIsCurrentDefaultMusic = false
  self:InitAvatarMusicList(AudioEvents)
end
function VehicleMusicComponent:HandleOnSongChanged()
  EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_VEHICLE, EVENTID_VEHICLE_SONG_CHANGED, self:GetOwner())
end
function VehicleMusicComponent:CheckCanUseMusicList(uPlayerController, uVehicle, carId)
  if not slua.isValid(uVehicle) or not slua.isValid(uPlayerController) then
    print(bWriteLog and "VehicleMusicComponent:CheckCanUseMusicList Fail, uVehicle or uPlayerController is invalid")
    return
  end
  local carId = carId or uVehicle.ClientUsedAvatarID
  if not carId then
    print(bWriteLog and "VehicleMusicComponent:CheckCanUseMusicList carId is invalid")
    return
  end
  local bIsSocialIslandVehicle = uVehicle.IsSocialIslandVehicle and uVehicle:IsSocialIslandVehicle()
  if uVehicle.bIsBornIslandVehicle and not bIsSocialIslandVehicle then
    print(bWriteLog and "VehiclePlateLicenseUtil.CheckCanUseMusicList bIsBornIslandVehicle")
    return
  end
  local bUseAvatarVehicleMusic = uVehicle:IsCurrentVehicleUseBetterAvataMusic(carId)
  if bUseAvatarVehicleMusic and self.bEnableAvatarMusic then
    print(bWriteLog and "VehiclePlateLicenseUtil.CheckCanUseMusicList 1 true")
    return true
  end
  local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
  local bUpgradeCarUseMusicList = VehiclePlateLicenseUtil.CheckUseUpgradeCarMusicList(uPlayerController, carId)
  print(bWriteLog and "VehiclePlateLicenseUtil.CheckCanUseMusicList 2 bUpgradeCarUseMusicList:" .. tostring(bUpgradeCarUseMusicList))
  return bUpgradeCarUseMusicList
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
return class(CActorComponentBase, nil, VehicleMusicComponent)