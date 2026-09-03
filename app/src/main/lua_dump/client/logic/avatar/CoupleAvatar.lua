local CoupleAvatar = {}
local CoupleAvatarConfig = require("client.slua.logic.lobby.Left.CoupleAvatarConfig")
local logic_couple_avatar_util = require("client.slua.logic.lobby.Left.logic_couple_avatar_util")
local Trait = require("common.trait")
local CDelegateContainer = require("common.delegate_container")
local Traits = {
  require("client.logic.avatar.CoupleAvatarTraits.CoupleAvatarPet"),
  require("client.logic.avatar.CoupleAvatarTraits.CoupleAvatarCar"),
  require("client.logic.avatar.CoupleAvatarTraits.CoupleAvatarIsland"),
  require("client.logic.avatar.CoupleAvatarTraits.CoupleAvatarAction"),
  require("client.logic.avatar.CoupleAvatarTraits.CoupleAvatarMiniTV")
}
local GetBasicDataAvatarWearInfo = function()
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  return BasicDataAvatarWearInfo
end
function CoupleAvatar:ctor(_, sceneType)
  self.  self.isShowWeapon = CoupleAvatarConfig.DefaultSwitcher.isShowWeapon
  self.isShowHelmet = CoupleAvatarConfig.DefaultSwitcher.isShowHelmet
  self.isShowBg = CoupleAvatarConfig.DefaultSwitcher.isShowBg
  self.isShowHighCloteEffect = CoupleAvatarConfig.DefaultSwitcher.isShowHighCloteEffect
  self.islandStatus = {}
  self.socialLandType = {}
  self.IslandStatusUID = 0
  self.avatars = {}
  self.pawnContainer = nil
  self.AssetAsynDelegates = {}
  self._tASyncLoadAvatarType = {}
  self.cachePos = {}
  self._tPawnContainerPos = nil
  self.Vehicle = nil
  self.EnableShowCar = false
  self.bValid = true
  self._bCanProtocolHandle = true
  self.CompareDataCache = {}
  self._bIsInitShow = false
  self._nAsyncLoadFinishedTickId = nil
  self._bIsShowing = false
  self.SelfUID = nil
  self.FriendUID = nil
  self.ReceiveSelfData = false
  self.ReceiveFriendData = false
  self:RegistEvent()
end
function CoupleAvatar:RegistEvent()
  self:AddCommonEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_TARGET_ISLAND_STATUS_RES, self.GetTargetIslandStatusRsp, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self.OnDownloadDone, self)
end
function CoupleAvatar:UpdateAvatar(SelfUID, ExtraData)
  if not SelfUID then
    log_error("CoupleAvatar UpdateAvatar SelfUID is nil")
    return
  end
  self._bIsInitShow = false
  self._tASyncLoadAvatarType = {}
  ExtraData = ExtraData or {}
  log(bWriteLog and "CoupleAvatar UpdateAvatar SelfUID:" .. tostring(SelfUID))
  log_tree("CoupleAvatar:UpdateAvatar", {SelfUID, ExtraData})
  self.SelfUID = tostring(SelfUID)
  self.FriendUID = nil
  self.ReceiveSelfData = false
  self.ReceiveFriendData = false
  self._bCanProtocolHandle = true
  self.  self:RemoveASyncLoadFinishedTick()
  if not ExtraData.ForceReqData and ExtraData.UseCacheData then
    log(bWriteLog and string.format("[lesterzy] CoupleAvatar:UpdateAvatar UseCacheData trigger"))
    local bIsExistCache = self:CheckIsExistCacheData(SelfUID)
    if bIsExistCache then
      self:Update()
      return
    end
  end
  self:SendGetUserWearData(SelfUID)
end
function CoupleAvatar:SendGetUserWearData(nUId)
  local BasicDataAvatarWearInfo = GetBasicDataAvatarWearInfo()
  local tExtraData = self.ExtraData
  local OnReceiveData = function(UID, Data)
    self:OnReceiveData(UID, Data)
  end
  local ForceReqData = tExtraData.ForceReqData
  local nSourceType = tExtraData.nSourceType
  BasicDataAvatarWearInfo:GetOrReqData(nUId, OnReceiveData, {bForceReq = ForceReqData}, nSourceType)
end
function CoupleAvatar:CheckIsExistCacheData(SelfUID)
  local BasicDataAvatarWearInfo = GetBasicDataAvatarWearInfo()
  local tSelfCacheData = BasicDataAvatarWearInfo:GetCacheData(SelfUID, true)
  if not tSelfCacheData then
    return false
  end
  local sFriendUId
  local tExtraData = self.ExtraData
  if tExtraData.bIsShowFriend then
    if tExtraData.nFriendUId then
      sFriendUId = tostring(tExtraData.nFriendUId)
      self.FriendUID = sFriendUId
    elseif tSelfCacheData.partner_info and tSelfCacheData.partner_info.partner_uid and tSelfCacheData.partner_info.partner_uid > 0 then
      sFriendUId = tostring(tSelfCacheData.partner_info.partner_uid)
      self.FriendUID = sFriendUId
    end
  end
  if sFriendUId then
    local tFriendCacheData = BasicDataAvatarWearInfo:GetCacheData(sFriendUId)
    local bIsExistCache = tSelfCacheData and tFriendCacheData
    return bIsExistCache
  end
  return true
end
function CoupleAvatar:CheckSelfIsHideAvatar(nSelfUId, tRoleData)
  if not tRoleData then
    return true
  end
  local tExtraData = self.ExtraData or {}
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  local bIsSelf = nSelfUId == tostring(DataMgr.roleData.uid)
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if tExtraData.bCheckIsShow and not bIsSelf then
      local isShow = not SettingUtil.OnlyFriend(nSelfUId, tRoleData.bshow, 1)
      log(bWriteLog and " CoupleAvatar:CheckSelfIsHideAvatar >>> " .. tostring(isShow))
      return isShow
    end
  elseif tExtraData.bCheckIsShow and not bIsSelf and not tRoleData.bshow then
    return true
  end
  return false
end
function CoupleAvatar:OnReceiveData(UID, Data)
  if not self.bValid or not self._bCanProtocolHandle then
    log(bWriteLog and "CoupleAvatar:OnReceiveData not self.bValid or not self._bCanProtocolHandle")
    return
  end
  UID = tostring(UID)
  log(bWriteLog and "CoupleAvatar OnReceiveData UID >>> " .. UID)
  local tExtraData = self.ExtraData
  if UID == self.SelfUID then
    self.ReceiveSelfData = true
    if self:CheckSelfIsHideAvatar(UID, Data) then
      self:Update()
      return
    end
    if tExtraData.bIsShowFriend then
      if tExtraData.nFriendUId then
        local nFriendUId = tostring(tExtraData.nFriendUId)
        self.FriendUID = nFriendUId
        if UID == nFriendUId then
          self.ReceiveFriendData = true
        else
          self:SendGetUserWearData(nFriendUId)
          return
        end
      else
        local nFriendUId = Data.partner_info and Data.partner_info.partner_uid
        if nFriendUId and 0 < nFriendUId and tostring(nFriendUId) ~= self.SelfUID then
          self.FriendUID = tostring(Data.partner_info.partner_uid)
          self:SendGetUserWearData(Data.partner_info.partner_uid)
          return
        else
          self.ReceiveFriendData = true
        end
      end
    else
      self.ReceiveFriendData = true
    end
  elseif UID == self.FriendUID then
    self.ReceiveFriendData = true
  end
  if self.ReceiveSelfData and self.ReceiveFriendData then
    self:Update()
  end
end
function CoupleAvatar:GotDataCallbackHandler()
  local tExtraData = self.ExtraData
  if tExtraData.fGotDataCallback then
    local BasicDataAvatarWearInfo = GetBasicDataAvatarWearInfo()
    local tUserData = BasicDataAvatarWearInfo:GetCacheData(self.SelfUID)
    if not tUserData then
      return
    end
    if self.FriendUID then
      local tFriendData = BasicDataAvatarWearInfo:GetCacheData(self.FriendUID)
      if tFriendData then
        local bIsHideAvatar = self:CheckSelfIsHideAvatar(self.SelfUID, tUserData)
        tExtraData.fGotDataCallback(self.SelfUID, tUserData, tFriendData, bIsHideAvatar)
        return
      end
    end
    local bIsHideAvatar = self:CheckSelfIsHideAvatar(self.SelfUID, tUserData)
    tExtraData.fGotDataCallback(self.SelfUID, tUserData, nil, bIsHideAvatar)
  end
end
function CoupleAvatar:_SetIsShowing(bIsShow)
  self._bIsShowing = bIsShow
  self:SetCoupleAvatarPetIsHide(CoupleAvatarConfig.AvatarType.Self, not bIsShow)
  if self:IsTwoPerson() then
    self:SetCoupleAvatarPetIsHide(CoupleAvatarConfig.AvatarType.Friend, not bIsShow)
  end
  if self.pawnContainer then
    self.pawnContainer:SetCanRotate(bIsShow)
  end
end
function CoupleAvatar:HideAvatars(bIsResetInit)
  log(bWriteLog and "CoupleAvatar:HideAvatars")
  self._bCanProtocolHandle = false
  logic_couple_avatar_util.HideAvatarList(self.avatars)
  if self:IsTwoPerson() and self.pawnContainer then
    local pos = logic_couple_avatar_util.GetCoupleMiddlePos(self.avatars)
    self.pawnContainer:SetPosition(pos.x, pos.y, pos.z)
  end
  self:StopTeamupAction()
  self:SetRaceCarVisible(false)
  if bIsResetInit then
    self._bIsInitShow = false
  end
  self._tASyncLoadAvatarType = {}
  self:ClearAllAvatarAsyncLoadEvent()
  self:RemoveASyncLoadFinishedTick()
  self:_SetIsShowing(false)
end
function CoupleAvatar:ShowAvatars()
  if not self._bIsInitShow or next(self._tASyncLoadAvatarType) then
    return
  end
  for i, avatar in pairs(self.avatars) do
    avatar:EnableClothAnimation(true)
    avatar:EnableCastPhotonShadow(true)
    local operateAvatar = avatar:GetModel()
    if operateAvatar and self.cachePos[i] then
      operateAvatar:K2_SetActorRelativeLocation(self.cachePos[i], false, nil, false)
    end
  end
  if self._tPawnContainerPos and self.pawnContainer then
    local tPos = self._tPawnContainerPos
    self.pawnContainer:SetPosition(tPos.x, tPos.y, tPos.z)
  end
  self:ResetPetAndTVLocation()
  self:CheckShowRaceCar(self.SelfUID)
  self:_SetIsShowing(true)
  EventSystem:postEvent(EVENTTYPE_COUPLE_AVATAR, EVENTID_LOBBY_SOCIAL_UPDATE_AVATAR, self.SelfUID, self.sceneType)
end
function CoupleAvatar:SetAvatarCastPhotonShadow(bCast)
  for i, avatar in pairs(self.avatars) do
    avatar:EnableCastPhotonShadow(bCast)
  end
end
function CoupleAvatar:GetUID(AvatarType)
  if AvatarType == CoupleAvatarConfig.AvatarType.Self then
    return self.SelfUID
  else
    return self.FriendUID
  end
end
function CoupleAvatar:GetSelfUID()
  return self.SelfUID
end
function CoupleAvatar:GetFriendUID()
  return self.FriendUID
end
function CoupleAvatar:IsTwoPerson()
  if self.SelfUID and self.FriendUID then
    return true
  end
  return false
end
function CoupleAvatar:GetAvatarCount()
  return #self.avatars
end
function CoupleAvatar:IsStandRight(AvatarType)
  local PoseType = self:GetStandType(AvatarType)
  return PoseType == CoupleAvatarConfig.PosType.Right
end
function CoupleAvatar:GetStandType(AvatarType)
  if AvatarType == CoupleAvatarConfig.AvatarType.Self then
    return self:_GetSelfStandType()
  else
    return 1 - self:_GetSelfStandType()
  end
end
function CoupleAvatar:_GetSelfStandType()
  if not self.ExtraData.bForbidSpecialStand then
    local PoseID = self:GetSelfPoseID()
    local bUseSpecial, Location = self:_ShouldPlaySpecialAnim(PoseID)
    if bUseSpecial then
      return Location
    end
  end
  local SelfGender = self:GetGender(CoupleAvatarConfig.AvatarType.Self)
  local FriendGender = self:GetGender(CoupleAvatarConfig.AvatarType.Friend)
  local PoseID = self:GetSelfPoseID()
  log(bWriteLog and "CoupleAvatar _GetSelfStandType SelfGender:" .. tostring(SelfGender) .. " FriendGender:" .. tostring(FriendGender) .. " PoseID:" .. tostring(PoseID))
  local intimacyPoseMapping = CDataTable.GetTableData("IntimacyPose", PoseID)
  if intimacyPoseMapping and intimacyPoseMapping.MainPerspective then
    if intimacyPoseMapping.MainPerspective == "L" then
      return CoupleAvatarConfig.PosType.Left
    elseif intimacyPoseMapping.MainPerspective == "R" then
      return CoupleAvatarConfig.PosType.Right
    end
  end
  if SelfGender == FriendGender then
    return CoupleAvatarConfig.PosType.Left
  end
  local SexString = logic_couple_avatar_util.ConvertGenderNumberToString(SelfGender)
  if not intimacyPoseMapping then
    if SexString == "M" then
      return CoupleAvatarConfig.PosType.Left
    else
      return CoupleAvatarConfig.PosType.Right
    end
  end
  if intimacyPoseMapping.LeftSex == tostring(SexString) then
    return CoupleAvatarConfig.PosType.Left
  else
    return CoupleAvatarConfig.PosType.Right
  end
end
function CoupleAvatar:HasEquipedByType(AvatarType, itemID)
  local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
  local wearData = AvatarCommon.GetWearDataFromRoleData(GetBasicDataAvatarWearInfo():GetCacheData(self:GetUID(AvatarType)))
  if not wearData then
    return false
  end
  for _, equipmentInfo in ipairs(wearData.WearInfoList) do
    if equipmentInfo.ItemID ~= 0 and equipmentInfo.ItemID == itemID then
      return true
    end
  end
  if self.ExtraData and self.ExtraData.SelfWear and AvatarType == CoupleAvatarConfig.AvatarType.Self then
    for _, v in ipairs(self.ExtraData.SelfWear) do
      if v == itemID then
        return true
      end
    end
  end
  if self.ExtraData and self.ExtraData.FriendWear and AvatarType == CoupleAvatarConfig.AvatarType.Friend then
    for _, v in ipairs(self.ExtraData.FriendWear) do
      if v == itemID then
        return true
      end
    end
  end
  return false
end
function CoupleAvatar:GetAnotherAvatarType(AvatarType)
  if AvatarType == CoupleAvatarConfig.AvatarType.Self then
    return CoupleAvatarConfig.AvatarType.Friend
  else
    return CoupleAvatarConfig.AvatarType.Self
  end
end
function CoupleAvatar:GetModel(AvatarType)
  if AvatarType and self.avatars and self.avatars[AvatarType] then
    return self.avatars[AvatarType]:GetModel()
  end
  return nil
end
function CoupleAvatar:GetAvatar(AvatarType)
  if AvatarType and self.avatars and self.avatars[AvatarType] then
    return self.avatars[AvatarType]
  end
  return nil
end
function CoupleAvatar:GetGender(AvatarType)
  local Gender
  if AvatarType == CoupleAvatarConfig.AvatarType.Self then
    Gender = self.ExtraData and self.ExtraData.SelfGender
  else
    Gender = self.ExtraData and self.ExtraData.FriendGender
  end
  if Gender then
    return Gender
  else
    local UID = self:GetUID(AvatarType)
    if not UID then
      return
    end
    return GetBasicDataAvatarWearInfo():GetGender(UID)
  end
end
function CoupleAvatar:GetPoseID(AvatarType)
  local UID = self:GetUID(AvatarType)
  local PoseItemID
  if self.ExtraData and self.ExtraData.PoseItemID then
    PoseItemID = self.ExtraData.PoseItemID
  else
    PoseItemID = GetBasicDataAvatarWearInfo():GetPoseItemID(UID)
  end
  local intimacyPoseMapping = CDataTable.GetTableData("IntimacyPoseMapping", PoseItemID)
  if not intimacyPoseMapping then
    return 0
  end
  return intimacyPoseMapping.PoseType
end
function CoupleAvatar:GetSelfPoseID()
  local Pose = self:GetPoseID(CoupleAvatarConfig.AvatarType.Self)
  if Pose == 0 then
    local SelfGender = self:GetGender(CoupleAvatarConfig.AvatarType.Self)
    local FriendGender = self:GetGender(self:GetAnotherAvatarType(CoupleAvatarConfig.AvatarType.Self))
    Pose = logic_couple_avatar_util.GetDefaultPoseId(SelfGender, FriendGender)
  end
  return Pose
end
function CoupleAvatar:GetStandPosition(AvatarType, SceneType)
  if not self:IsTwoPerson() then
    local Position = logic_couple_avatar_util.GetCoupleAvatarShowPosition(SceneType)
    return Position
  end
  local Pose = self:GetSelfPoseID()
  local SelfGender = self:GetGender(AvatarType)
  local FriendGender = self:GetGender(self:GetAnotherAvatarType(AvatarType))
  if not SelfGender or not FriendGender then
    log_warning("CoupleAvatar:GetStandPosition not SelfGender or not FriendGender")
    local Position = logic_couple_avatar_util.GetCoupleAvatarShowPosition(SceneType)
    return Position
  end
  local PosType = self:GetStandType(AvatarType)
  local LeftPosOffset, RightPosOffset = logic_couple_avatar_util.GetStandPositionOffest(Pose, SelfGender, FriendGender, AvatarType, PosType)
  local Postion
  if self:IsStandRight(AvatarType) then
    Postion = logic_couple_avatar_util.GetCoupleAvatarShowPosition(SceneType, RightPosOffset)
  else
    Postion = logic_couple_avatar_util.GetCoupleAvatarShowPosition(SceneType, LeftPosOffset)
  end
  return Postion
end
function CoupleAvatar:Update()
  self._DownloadActionCallBack = false
  if self.FriendUID and self.ExtraData and self.ExtraData.bIsShowFriend then
    self:ReplaceSpecificDressByAnimation()
  end
  self:GotDataCallbackHandler()
  if self.ExtraData.bCustomerView and self.ExtraData.bCustomerView then
    log(bWriteLog and string.format("[lesterzy] CoupleAvatar:UpdateAvatar bCustomerView trigger"))
    local SelfWearData = GetBasicDataAvatarWearInfo():GetCacheData(self.SelfUID)
    local selfWearList = SelfWearData.pspace_wear_ext
    local logic_Intimacy_Pose_dress_replace = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_Intimacy_Pose_dress_replace)
    logic_Intimacy_Pose_dress_replace:CustomerViewProcess(self.SelfUID, selfWearList)
  end
  local nSelfUId = self.SelfUID
  local BasicDataAvatarWearInfo = GetBasicDataAvatarWearInfo()
  local tSelfCacheData = BasicDataAvatarWearInfo:GetCacheData(nSelfUId)
  if not tSelfCacheData or self:CheckSelfIsHideAvatar(nSelfUId, tSelfCacheData) then
    self:HideAvatars()
    return
  end
  self:_Reset()
  self:_UpdateData()
  self:_ReInitPerson(CoupleAvatarConfig.AvatarType.Self)
  if self:IsTwoPerson() then
    self:_ReInitPerson(CoupleAvatarConfig.AvatarType.Friend)
    self:_ToBeCouple()
    self:_LoadPoseAnimation(CoupleAvatarConfig.AvatarType.Self)
    self:_LoadPoseAnimation(CoupleAvatarConfig.AvatarType.Friend)
  elseif self.ExtraData.bLoadSelfPoseAnim then
    self:_LoadPoseAnimation(CoupleAvatarConfig.AvatarType.Self)
  end
  local tExtraData = self.ExtraData or {}
  self:_CacheAvatarPosition()
  self:SetEnableRaceCar(tExtraData.bIsShowCar)
  if tExtraData.bClosePetRandomAct then
    self:EnablePetIdleRandomAction(false)
  end
  if tExtraData.IsShowPet then
    self:SetPetVisibility(false)
    self:SetMiniTvVisibility(false)
  else
    self:SetPetVisibility(true)
    self:SetMiniTvVisibility(true)
    log(bWriteLog and "CoupleAvatar:Update tExtraData.IsShowPet false SetPetVisibility(true)")
  end
  self:ShowVehicle(self.SelfUID)
  if next(self._tASyncLoadAvatarType) then
    logic_couple_avatar_util.HideAvatarList(self.avatars)
    self:ResetPetAndTVLocation()
  else
    self:LoadAvatarFinishedHandler(true)
  end
  self._bIsInitShow = true
end
function CoupleAvatar:ReplaceSpecificDressByAnimation()
  local selfUid = self:GetUID(CoupleAvatarConfig.AvatarType.Self)
  local SelfWearData = GetBasicDataAvatarWearInfo():GetCacheData(selfUid)
  local selfWearList = SelfWearData.pspace_wear_ext
  local friendUid = self:GetUID(CoupleAvatarConfig.AvatarType.Friend)
  local FriendWearData = GetBasicDataAvatarWearInfo():GetCacheData(friendUid)
  local friendWearList = FriendWearData.pspace_wear_ext
  local pose = self:GetSelfPoseID()
  local logic_Intimacy_Pose_dress_replace = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_Intimacy_Pose_dress_replace)
  logic_Intimacy_Pose_dress_replace:DressReplaceCheck(pose, selfWearList, friendWearList, selfUid, friendUid)
end
function CoupleAvatar:LoadAvatarFinishedHandler(bIsPostAdapt)
  local tExtraData = self.ExtraData or {}
  if tExtraData.bPlayCoupleAnim then
    log(bWriteLog and "[CoupleAvatar:Update] PlayIntimacyAction")
    self:PlayIntimacyAction()
  end
  if self.avatars and next(self.avatars) then
    local uObj_avatarModel = self.avatars[1]:GetModel()
    if tExtraData.SceneType == "LobbyCP01" then
      if slua.isValid(uObj_avatarModel) then
        uObj_avatarModel:SetClothMeshForceLod(true)
      end
    elseif slua.isValid(uObj_avatarModel) then
      uObj_avatarModel:SetClothMeshForceLod(false)
    end
  end
  self:_SetIsShowing(true)
  if bIsPostAdapt then
    EventSystem:postEvent(EVENTTYPE_COUPLE_AVATAR, EVENTID_LOBBY_SOCIAL_UPDATE_AVATAR, self.SelfUID, self.sceneType)
  end
end
function CoupleAvatar:GetPawnContainerModel()
  if not self.pawnContainer then
    return
  end
  return self.pawnContainer:GetPawnContainer()
end
function CoupleAvatar:_UpdateData()
  self:_UpdateSwitcher()
end
function CoupleAvatar:_Reset()
  self:StopTeamupAction()
  self:_ToBeSimlpe()
  self:ClearAllAvatarAsyncLoadEvent()
  self:ClearAsyncDelegates()
  local time_ticker = require("common.time_ticker")
  if self.DelayCreatePet then
    for AvatarType, Index in pairs(self.DelayCreatePet) do
      time_ticker.RemoveTimer(Index)
      self.DelayCreatePet[AvatarType] = nil
    end
    self.DelayCreatePet = nil
  end
  logic_couple_avatar_util.HideAvatarList(self.avatars)
end
function CoupleAvatar:_ReInitPerson(AvatarType)
  log(bWriteLog and "CoupleAvatar _ReInitPerson AvatarType" .. tostring(AvatarType))
  local avatar = self:_GetOrCreateAvatar(AvatarType)
  self:_UpdateMultiAvatar(avatar, AvatarType)
  if self.sceneType == CoupleAvatarConfig.ESceneType.Multiplayer then
    avatar:SetCanRotate(false)
  end
  if self.ExtraData and self.ExtraData.UseProfileWear == false then
  else
    local time_ticker = require("common.time_ticker")
    self.DelayCreatePet = self.DelayCreatePet or {}
    if self.DelayCreatePet[AvatarType] then
      time_ticker.RemoveTimer(self.DelayCreatePet[AvatarType])
      self.DelayCreatePet[AvatarType] = nil
    end
    local PoseID = self:GetSelfPoseID()
    local IntimacyPoseCfg = CDataTable.GetTableData("IntimacyPose", PoseID)
    local bHidePet = IntimacyPoseCfg and IntimacyPoseCfg.HidePetInAnim == 1
    if bHidePet then
      local delayTime = self:GetCoupleAnimDuration()
      if not delayTime or delayTime < 0 then
        delayTime = 0
      end
      self.DelayCreatePet[AvatarType] = time_ticker.AddTimerOnce(delayTime, function()
        if not self.bValid then
          return
        end
        self:_CreatePetAndTV(avatar, self:GetUID(AvatarType))
        self:_AdjustPetAndTVLocation(AvatarType)
      end)
    elseif not self.ExtraData.IsShowPet then
      self:_CreatePetAndTV(avatar, self:GetUID(AvatarType))
      self:_AdjustPetAndTVLocation(AvatarType)
    end
  end
  avatar:ClearFriendPoseData()
end
function CoupleAvatar:_UpdateMultiAvatar(avatar, AvatarType)
  local operateAvatar = avatar:GetModel()
  if slua.isValid(operateAvatar) then
    operateAvatar:SetPlayerUID(self:GetUID(AvatarType))
  else
    log_error(bWriteLog and "CoupleAvatar:_UpdateMultiAvatar SetPlayerUID false")
  end
  avatar:SetIsAutoDownloadControlled(self.ExtraData.bIsAutoDownloadControlled)
  avatar:EnableCastPhotonShadow(true)
  avatar:EnableClothAnimation(true)
  local pos
  if self.ExtraData.MultiplayerStandPos then
    pos = self.ExtraData.MultiplayerStandPos
  else
    pos = self:GetStandPosition(AvatarType, self.sceneType)
  end
  avatar:SetPosition(pos.X, pos.Y, pos.Z)
  local rotation = logic_couple_avatar_util.GetCoupleAvatarShowRotation(self.sceneType)
  if not self:IsTwoPerson() and rotation then
    log(bWriteLog and "CoupleAvatar:_UpdateMultiAvatar SetRotation")
    avatar:SetRotation(rotation.X or 0, rotation.Y or 0, rotation.Z or 0)
  end
  local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
  if self.ExtraData and self.ExtraData.UseProfileWear == false then
    avatar:ClearEquipments()
    local PutOnWear = {}
    if self.ExtraData.SelfWear and AvatarType == CoupleAvatarConfig.AvatarType.Self then
      PutOnWear = self.ExtraData.SelfWear
    end
    if self.ExtraData.FriendWear and AvatarType == CoupleAvatarConfig.AvatarType.Friend then
      PutOnWear = self.ExtraData.FriendWear
    end
    for _, v in pairs(PutOnWear) do
      avatar:PutonEquipment(v)
    end
    if self.isShowHighCloteEffect then
      avatar:TryShowHighLevelClothEffect()
    end
    return
  end
  local wearData = AvatarCommon.GetWearDataFromRoleData(GetBasicDataAvatarWearInfo():GetCacheData(self:GetUID(AvatarType)))
  local CompareData = {
    uid = self:GetUID(AvatarType),
    isShowWeapon = self.isShowWeapon,
    isShowHelmet = self.isShowHelmet,
    isShowBg = self.isShowBg,
    idle = wearData.depot_show_info.idle,
    headShow = wearData.headShow,
    helmet_skin = wearData.helmet_skin,
    helmet = wearData.depot_show_info.helmet,
    hatSkinId = wearData.hatSkinId,
    bagSkinInsId = wearData.bagSkinInsId,
    bag = wearData.depot_show_info.bag,
    bag_pendants = wearData.bag_pendants,
    WearInfoList = wearData.WearInfoList,
    hand = wearData.depot_show_info.hand,
    _uid = wearData.uid,
    weapon = wearData.depot_show_info.weapon,
    mainWeaponInfo_weaponSkinId = wearData.mainWeaponInfo.weaponSkinId,
    mainWeaponInfo_weaponResId = wearData.mainWeaponInfo.weaponResId,
    extraWeaponInfo_weaponSkinId = wearData.extraWeaponInfo.weaponSkinId,
    extraWeaponInfo_weaponResId = wearData.extraWeaponInfo.weaponResId
  }
  local TableUtil = require("common.table_util")
  if not TableUtil.IsDataEqual(self.CompareDataCache[AvatarType], CompareData) then
    self.CompareDataCache[AvatarType] = CompareData
    if wearData then
      AvatarCommon.UpdateAvatar(avatar, wearData, self.isShowWeapon, self.isShowHelmet, self.isShowBg)
    end
    self:_UpdateDIYSuit(self:GetUID(AvatarType))
  end
  if self.isShowHighCloteEffect then
    avatar:TryShowHighLevelClothEffect()
  end
end
function CoupleAvatar:_CacheAvatarPosition()
  for i, avatar in pairs(self.avatars) do
    local operateAvatar = avatar:GetModel()
    if operateAvatar and operateAvatar.RootComponent then
      self.cachePos[i] = operateAvatar.RootComponent.RelativeLocation:clone()
    end
  end
end
function CoupleAvatar:_UpdateDIYSuit(UID)
  local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
  local WearInfoList = GetBasicDataAvatarWearInfo():GetWearInfoList(UID)
  for _, equipmentInfo in pairs(WearInfoList) do
    if equipmentInfo then
      local ItemID = equipmentInfo[1]
      if logic_suit_dye:IsDyeSuit(ItemID) then
        local data, originPlan = logic_suit_dye:GetPlanData(tostring(UID), logic_suit_dye:GetPeriodBySuitId(ItemID))
        if data then
          log(bWriteLog and "CoupleAvatar:_UpdateDIYSuit Update DyeSuit")
          EventSystem:postEvent(EVENTTYPE_SUITDYE, EVENTID_SUITDYE_CHARACTERAVATARCOMP_UPDATE, tostring(UID), ItemID, data, originPlan)
        end
      end
    end
  end
end
function CoupleAvatar:PlayIntimacyAction()
  self._DownloadActionCallBack = false
  if not self:CheckActionDownloadState() then
    log(bWriteLog and "CoupleAvatar:PlayIntimacyAction Not Download")
    return
  end
  local PoseID = self:GetSelfPoseID()
  local IntimacyPoseCfg = CDataTable.GetTableData("IntimacyPose", PoseID)
  local bHideBag = IntimacyPoseCfg and IntimacyPoseCfg.HideBagInAnim == 1
  local bHidePet = IntimacyPoseCfg and IntimacyPoseCfg.HidePetInAnim == 1
  local delayTime = self:GetCoupleAnimDuration()
  log(bWriteLog and "CoupleAvatar:PlayIntimacyAction bHidePet = " .. tostring(bHidePet) .. " bHideBag = " .. tostring(bHideBag) .. " delayTime = " .. tostring(delayTime))
  if not delayTime or delayTime < 0 then
    delayTime = 0
  end
  local time_ticker = require("common.time_ticker")
  if bHidePet then
    self:SetPetVisibility(false)
    self:SetMiniTvVisibility(false)
    if self.HidePetTimer then
      self:RemoveTimer(self.HidePetTimer)
    end
    self.HidePetTimer = self:AddTimerOnce(delayTime, function()
      self:SetPetVisibility(true)
      self:SetMiniTvVisibility(true)
      log(bWriteLog and "CoupleAvatar:PlayIntimacyAction bHidePet true SetPetVisibility(true)")
    end)
  else
    self:SetPetVisibility(true)
    self:SetMiniTvVisibility(true)
    log(bWriteLog and "CoupleAvatar:PlayIntimacyAction bHidePet false SetPetVisibility(true)")
  end
  if bHideBag and self.isShowBg then
    self:SetBagVisibility(CoupleAvatarConfig.AvatarType.Self, false)
    self:SetBagVisibility(CoupleAvatarConfig.AvatarType.Friend, false)
    if self.HideBagTimer then
      time_ticker.RemoveTimer(self.HideBagTimer)
    end
    self.HideBagTimer = time_ticker.AddTimerOnce(delayTime, function()
      self:SetBagVisibility(CoupleAvatarConfig.AvatarType.Self, true)
      self:SetBagVisibility(CoupleAvatarConfig.AvatarType.Friend, true)
    end)
  end
  self:PlayCoupleAnim()
end
function CoupleAvatar:CheckActionDownloadState()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local PoseID = self:GetSelfPoseID()
  local LeftPath, RightPath = self:GetPoseAnimPath(PoseID)
  if self:_ShouldPlaySpecialAnim(PoseID) then
    log(bWriteLog and "CoupleAvatarAction:CheckActionDownloadState special")
    local Cfg = CDataTable.GetTableData("IntimacyPosePreviewCfg", PoseID)
    LeftPath = Cfg.LeftMontage
    RightPath = Cfg.RightMontage
  end
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {LeftPath, RightPath})
  if state ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "CoupleAvatarAction:CheckActionDownloadState not download normal PoseID:" .. tostring(PoseID))
    self._DownloadActionCallBack = true
    local callback = function()
      if self and self._DownloadActionCallBack then
        self:PlayIntimacyAction()
      else
        log(bWriteLog and "CoupleAvatarAction:CheckActionDownloadState callback do nothing")
      end
    end
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {LeftPath, RightPath}, PufferTlog.Enum_TLog_From.Auto, callback)
    return -1
  end
  return true
end
function CoupleAvatar:SetBagVisibility(AvatarType, bShow)
  local avatar = self:GetAvatar(AvatarType)
  if not avatar then
    return
  end
  local model = avatar:GetModel()
  if not model then
    return
  end
  local CharacterAvatarComp = model.CharacterAvatarComp2_BP
  if CharacterAvatarComp then
    local EAvatarSlotType = import("EAvatarSlotType")
    CharacterAvatarComp:SetMeshVisibleByID(EAvatarSlotType.EAvatarSlotType_BackpackEquipemtSlot, bShow, bShow, true)
    CharacterAvatarComp:SetMeshVisibleByID(EAvatarSlotType.EAvatarSlotType_BackPack_PendantSlot, bShow, bShow, true)
  end
end
function CoupleAvatar:_UpdateSwitcher()
  if self.sceneType == CoupleAvatarConfig.ESceneType.Rank then
    self.isShowHighCloteEffect = true
  end
  if self.sceneType == CoupleAvatarConfig.ESceneType.WarRank or self.sceneType == CoupleAvatarConfig.ESceneType.Preview or self.sceneType == CoupleAvatarConfig.ESceneType.FromTPlanRank or self.sceneType == CoupleAvatarConfig.ESceneType.Sink or self.sceneType == CoupleAvatarConfig.ESceneType.Multiplayer then
    self.isShowWeapon = false
    self.isShowHelmet = false
    self.isShowBg = false
  else
    self.isShowWeapon = not self:IsTwoPerson()
  end
end
function CoupleAvatar:_DestroyCoupleAvatar()
  log(bWriteLog and string.format("CoupleAvatar.Destroy\239\188\140 sceneType = %s", tostring(self.sceneType)))
  self:StopTeamupAction()
  self:_DestroyPawnContainer()
  self:_DestroyAvatars()
  self:HideIslandStatus()
  self:Dispose()
  self.bValid = false
end
function CoupleAvatar:OnDownloadDone(eventType, eventID, data)
  log(bWriteLog and "CoupleAvatar.OnDownloadDone itemID = " .. tostring(data.itemID))
  self:CarHandleDown(data)
end
function CoupleAvatar:_ToBeSimlpe()
  if self.pawnContainer ~= nil then
    for _, avatar in pairs(self.avatars) do
      avatar:DetachFromPawnContainer()
    end
    self.pawnContainer:SetCanRotate(false)
  end
end
function CoupleAvatar:_ToBeCouple()
  log(bWriteLog and "CoupleAvatar._ToBeCouple")
  local pawnContainer = require("client.slua.logic.lobby.Left.lobby_pawn_container")
  if self.pawnContainer == nil then
    self.pawnContainer = pawnContainer.Create()
  end
  local pos = logic_couple_avatar_util.GetCoupleMiddlePos(self.avatars)
  local radius = logic_couple_avatar_util.GetCoupleRadius(self.avatars)
  self.pawnContainer:SetPosition(pos.x, pos.y, pos.z)
  self._tPawnContainerPos = pos
  if radius ~= 0 then
    self.pawnContainer:SetRadius(radius)
  end
  local rotation = logic_couple_avatar_util.GetCoupleAvatarShowRotation(self.sceneType)
  self.pawnContainer:SetRotation(rotation.X, rotation.Y, rotation.Z)
  for _, avatar in pairs(self.avatars) do
    avatar:AttachToPawnContainer(self.pawnContainer)
    avatar:SetCanRotate(false)
    log(bWriteLog and "CoupleAvatar:_ToBeCouple. SetRotation")
    avatar:SetRotation(0, 0, 0)
  end
  self.pawnContainer:SetRotation(0, 0, -15)
  self.pawnContainer:SetCanRotate(false)
end
function CoupleAvatar:_GetOrCreateAvatar(AvatarType)
  local Gender = self:GetGender(AvatarType)
  local HeadID = GetBasicDataAvatarWearInfo():GetHeadID(self:GetUID(AvatarType))
  log(bWriteLog and "CoupleAvatar _GetAvatar AvatarType=" .. AvatarType .. ", Gender=" .. Gender .. ", headid=" .. HeadID)
  local avatar = self.avatars[AvatarType]
  local avatarData = {
    gamegender = Gender,
    headid = HeadID,
    hairid = 0
  }
  if avatar == nil then
    local MultipleAvatarManager = require("client.logic.avatar.MultipleAvatarManager")
    avatar = MultipleAvatarManager.CreateMultipleAvatar(avatarData)
    local uObj_avatarModel = avatar:GetModel()
    if uObj_avatarModel then
      if self.ExtraData and self.ExtraData.SceneType == "LobbyCP01" then
        uObj_avatarModel:SetAvatarLevel(2)
      else
        uObj_avatarModel:SetAvatarLevel(1)
      end
      if uObj_avatarModel.Mesh then
        avatar:GetModel().Mesh:SetCastPhotonShadow(true)
      end
    end
  elseif avatar:GetSex() ~= Gender or avatar:GetHeadId() ~= HeadID then
    avatar:SwitchSexAndHeadAndHair(Gender, HeadID, 0)
  end
  local bIsSyncLoad = self:GetIsSyncLoadAvatar(avatar)
  local uObj_avatarModel = avatar:GetModel()
  if uObj_avatarModel then
    uObj_avatarModel.CharacterAvatarComp2_BP.bSyncAvatar = bIsSyncLoad
  end
  if not bIsSyncLoad then
    self:AddAsyncLoadingEvent(avatar, AvatarType)
  end
  self.avatars[AvatarType] = avatar
  return avatar
end
function CoupleAvatar:AddAsyncLoadingEvent(cObj_avatar, nAvatarType)
  if not cObj_avatar or not nAvatarType then
    return
  end
  local uObj_avatarModel = cObj_avatar:GetModel()
  if not uObj_avatarModel then
    if Client and Client.IsDevelopment() then
      log_tree("CoupleAvatar:AddAsyncLoadingEvent :", self.avatars)
      local utility = require("common.utility")
      local sMsg = "CoupleAvatar:AddAsyncLoadingEvent not uObj_avatarModel, nAvatarType = " .. tostring(nAvatarType) .. ", CoupleAvatar SceneType = " .. tostring(self.sceneType)
      utility.ErrorMessageHandlerExtra(sMsg, nil, sMsg)
    end
    return
  end
  self:AddControlEvent(uObj_avatarModel, "OnPreChangeEquip", self.OnPreChangeEquip, self, nAvatarType, cObj_avatar)
  self:AddControlEvent(uObj_avatarModel.CharacterAvatarComp2_BP, "OnAvatarAllMeshLoaded", self.OnAvatarAllMeshLoaded, self, nAvatarType, cObj_avatar)
  self:AddControlEvent(uObj_avatarModel.CharacterAvatarComp2_BP, "OnAvatarEquippedFailedEvent", self.OnAvatarEquippedFailedEvent, self, nAvatarType, cObj_avatar)
end
function CoupleAvatar:ClearAllAvatarAsyncLoadEvent()
  for _, v in pairs(self.avatars) do
    self:RemoveAsyncLoadingEvent(v)
  end
end
function CoupleAvatar:RemoveAsyncLoadingEvent(cObj_avatar)
  if not cObj_avatar then
    return
  end
  local uObj_avatarModel = cObj_avatar:GetModel()
  if not slua.isValid(uObj_avatarModel) then
    return
  end
  self:RemoveControlEvent(uObj_avatarModel, "OnPreChangeEquip")
  self:RemoveControlEvent(uObj_avatarModel.CharacterAvatarComp2_BP, "OnAvatarAllMeshLoaded")
  self:RemoveControlEvent(uObj_avatarModel.CharacterAvatarComp2_BP, "OnAvatarEquippedFailedEvent")
end
function CoupleAvatar:_DestroyAvatars()
  self:ClearAllAvatarAsyncLoadEvent()
  for k, v in pairs(self.avatars) do
    v:Destroy()
  end
  self:ClearAsyncDelegates()
  self.avatars = {}
  if slua.isValid(self.Vehicle) then
    self.Vehicle:Destroy()
    self.Vehicle = nil
  end
end
function CoupleAvatar:ClearAsyncDelegates()
  for i, delegate in pairs(self.AssetAsynDelegates) do
    local util = require("client.slua_ui_framework.util")
    util.ClearAssetAsync(delegate)
  end
  self.AssetAsynDelegates = {}
end
function CoupleAvatar:_DestroyPawnContainer()
  if self.pawnContainer then
    self.pawnContainer:Destroy()
    self.pawnContainer = nil
  end
end
function CoupleAvatar:AddPetLocationOffset(OffsetX, OffsetY, OffsetZ)
  if self:IsTwoPerson() then
    local selfAvatar = self:GetAvatar(CoupleAvatarConfig.AvatarType.Self)
    if selfAvatar then
      local selfPet = selfAvatar:GetPet()
      if selfPet then
        selfPet:AddPetLocationOffset(OffsetX, OffsetY, OffsetZ)
      end
    end
    local friendAvatar = self:GetAvatar(CoupleAvatarConfig.AvatarType.Friend)
    if friendAvatar then
      local friendPet = friendAvatar:GetPet()
      if friendPet then
        friendPet:AddPetLocationOffset(OffsetX, OffsetY, OffsetZ)
      end
    end
  end
end
function CoupleAvatar:SetPetVisibility(bShow)
  local selfAvatar = self:GetAvatar(CoupleAvatarConfig.AvatarType.Self)
  if selfAvatar then
    local selfPet = selfAvatar:GetPet()
    if selfPet and slua.isValid(selfPet.PetActor) then
      selfPet.PetActor:SetVisible(bShow)
    end
  end
  if self:IsTwoPerson() then
    local friendAvatar = self:GetAvatar(CoupleAvatarConfig.AvatarType.Friend)
    if friendAvatar then
      local friendPet = friendAvatar:GetPet()
      if friendPet and slua.isValid(friendPet.PetActor) then
        friendPet.PetActor:SetVisible(bShow)
      end
    end
  end
end
function CoupleAvatar:SetMiniTvVisibility(bShow)
  print(bWriteLog and "[tv][show] CoupleAvatar:SetMiniTvVisibility bShow" .. tostring(bShow))
  local selfAvatar = self:GetAvatar(CoupleAvatarConfig.AvatarType.Self)
  if selfAvatar then
    local selfTvActor = selfAvatar:GetMiniTVActor()
    if slua.isValid(selfTvActor) then
      selfTvActor:SetActorHiddenInGame(not bShow)
    end
  end
  if self:IsTwoPerson() then
    local friendAvatar = self:GetAvatar(CoupleAvatarConfig.AvatarType.Friend)
    if friendAvatar then
      local friendTvActor = friendAvatar:GetMiniTVActor()
      if slua.isValid(friendTvActor) then
        friendTvActor:SetActorHiddenInGame(not bShow)
      end
    end
  end
end
function CoupleAvatar:GetIsSyncLoadAvatar(avatar)
  return avatar and avatar:GetAvatarSync()
end
function CoupleAvatar:OnPreChangeEquip(nAvatarType, avatar)
  local bIsSyncLoad = self:GetIsSyncLoadAvatar(avatar)
  if bIsSyncLoad then
    return
  end
  self._tASyncLoadAvatarType[nAvatarType] = true
end
function CoupleAvatar:OnAvatarEquippedFailedEvent(nAvatarType, avatar)
  local bIsSyncLoad = self:GetIsSyncLoadAvatar(avatar)
  if bIsSyncLoad then
    return
  end
  self:OnAsyncLoadFinished(nAvatarType)
end
function CoupleAvatar:OnAvatarAllMeshLoaded(nAvatarType)
  self:OnAsyncLoadFinished(nAvatarType)
end
function CoupleAvatar:OnAsyncLoadFinished(nAvatarType)
  if not self._tASyncLoadAvatarType[nAvatarType] then
    return
  end
  self._tASyncLoadAvatarType[nAvatarType] = nil
  if not next(self._tASyncLoadAvatarType) then
    self:RemoveASyncLoadFinishedTick()
    self._nAsyncLoadFinishedTickId = self:AddTimerOnce(0, function()
      self._nAsyncLoadFinishedTickId = nil
      self:ShowAvatars()
      self:LoadAvatarFinishedHandler()
    end)
  end
end
function CoupleAvatar:RemoveASyncLoadFinishedTick()
  if not self._nAsyncLoadFinishedTickId then
    return
  end
  self:RemoveTimer(self._nAsyncLoadFinishedTickId)
  self._nAsyncLoadFinishedTickId = nil
end
function CoupleAvatar:_AdjustPetAndTVLocation(AvatarType)
  log(bWriteLog and "CoupleAvatar:_AdjustPetAndTVLocation AvatarType" .. tostring(AvatarType))
  self:_AdjustPetLocation(AvatarType)
  self:_AdjustMiniTVLocation(AvatarType)
end
function CoupleAvatar:_CreatePetAndTV(avatar, uid)
  log(bWriteLog and "CoupleAvatar:_CreatePetAndTV avatar" .. tostring(avatar) .. " uid" .. tostring(uid))
  self:_CreatePet(avatar, uid)
  self:_CreateMiniTV(avatar, uid)
end
function CoupleAvatar:ResetPetAndTVLocation()
  if self:IsTwoPerson() then
    self:_AdjustPetAndTVLocation(CoupleAvatarConfig.AvatarType.Self)
    self:_AdjustPetAndTVLocation(CoupleAvatarConfig.AvatarType.Friend)
  else
    self:_AdjustPetAndTVLocation(CoupleAvatarConfig.AvatarType.Self)
  end
end
local CCoupleAvatar = Trait.TraitClass(CDelegateContainer, nil, CoupleAvatar, Traits)
return CCoupleAvatar