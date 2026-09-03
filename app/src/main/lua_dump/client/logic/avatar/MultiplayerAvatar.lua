local CoupleAvatar = require("client.logic.avatar.CoupleAvatar")
local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
local CoupleAvatarConfig = require("client.slua.logic.lobby.Left.CoupleAvatarConfig")
local MultiplayerAvatar = {
  SceneType = CoupleAvatarSystem.ESceneType.Multiplayer,
  BasePosition = {
    X = -12968.416016,
    Y = -100,
    Z = 89.625557
  },
  IndexUse = {},
  Avatars = {},
  AvatarDatas = {},
  bValid = false
}
local checkCacheExist = function(uid)
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  local tSelfCacheData = BasicDataAvatarWearInfo:GetCacheData(uid, true)
  if not tSelfCacheData then
    return false
  else
    return true
  end
end
local TableDeepCopy = function(t)
  local u = {}
  for k, v in pairs(t) do
    u[k] = v
  end
  return setmetatable(u, getmetatable(t))
end
function MultiplayerAvatar:CreateOrUpdateAvatar(avatarInfos, extraData)
  extraData.bIsShowFriend = false
  extraData.bForbidSpecialStand = true
  extraData.bPlayCoupleAnim = false
  extraData.bLoadSelfPoseAnim = true
  local avatarNum = #avatarInfos
  for i = 1, avatarNum do
    local avatarData = TableDeepCopy(extraData)
    avatarData.MultiplayerIndex = avatarInfos[i].index or i
    local idx = avatarData.MultiplayerIndex
    if avatarData.SelfGender or checkCacheExist(avatarInfos[i].uid) then
      self:_Update(avatarInfos[i].uid, idx, avatarData)
    else
      self.bValid = true
      do
        local OnReceiveData = function(UID, Data)
          if not self.bValid then
            log(bWriteLog and string.format("[MultiplayerAvatar:OnReceiveData] idx: %d, Not valid, Cancel", idx))
            return
          end
          self:_Update(avatarInfos[i].uid, idx, avatarData)
        end
        local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
        BasicDataAvatarWearInfo:GetOrReqData(avatarInfos[i].uid, OnReceiveData, {
          bForceReq = avatarData.ForceReqData
        }, avatarData.nSourceType)
        avatarData.ForceReqData = false
      end
    end
  end
end
function MultiplayerAvatar:_Update(uid, idx, avatarData)
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  avatarData.SelfGender = avatarData.SelfGender or BasicDataAvatarWearInfo:GetGender(uid)
  avatarData.MultiplayerStandPos = self:GetStandPositionWithOffset(avatarData.PoseItemID, avatarData.MultiplayerIndex, avatarData.SelfGender)
  avatarData.PosePath = self:GetPosePath(avatarData.PoseItemID, avatarData.MultiplayerIndex, avatarData.SelfGender)
  avatarData.IsShowPet = self.GetMultiplayerPetShow(avatarData.PoseItemID)
  log(bWriteLog and string.format("[MultiplayerAvatar:_Update] idx: %d, Position = {X = %f, Y = %f, Z = %f} ", idx, avatarData.MultiplayerStandPos.X, avatarData.MultiplayerStandPos.Y, avatarData.MultiplayerStandPos.Z))
  local avatar
  if self.Avatars[idx] then
    avatar = self.Avatars[idx]
  else
    avatar = CoupleAvatar(self.SceneType)
    self.Avatars[idx] = avatar
  end
  self.AvatarDatas[idx] = avatarData
  avatar:UpdateAvatar(uid, avatarData)
end
local Split = function(input_str, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(input_str, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end
function MultiplayerAvatar:GetStandPositionWithOffset(PoseItemID, index, gender)
  local pose_info = CDataTable.GetTableData("MultiplayerAvatarPose", PoseItemID)
  if pose_info then
    local raw_offset
    if gender == 1 then
      raw_offset = pose_info.OffsetMale
    elseif gender == 2 then
      raw_offset = pose_info.OffsetFemale
    end
    local offsets_string = Split(raw_offset, "#")
    if offsets_string[index] then
      local offset = Split(offsets_string[index], ";")
      local Res = {
        X = tonumber(offset[1]) or 0,
        Y = tonumber(offset[2]) or 0,
        Z = tonumber(offset[3]) or 0
      }
      Res.X = self.BasePosition.X + Res.X
      Res.Y = self.BasePosition.Y + Res.Y
      Res.Z = self.BasePosition.Z + Res.Z
      return Res
    end
  end
  return {
    X = self.BasePosition.X,
    Y = self.BasePosition.Y,
    Z = self.BasePosition.Z
  }
end
function MultiplayerAvatar:GetPosePath(PoseItemID, index, gender)
  local pose_info = CDataTable.GetTableData("MultiplayerAvatarPose", PoseItemID)
  local col_name = "Pose" .. tostring(index)
  if pose_info and pose_info[col_name] then
    return pose_info[col_name]
  end
  return nil
end
function MultiplayerAvatar:DestroyAvatar()
  self.bValid = false
  for k, v in pairs(self.Avatars) do
    log(bWriteLog and string.format("[MultiplayerAvatar:DestroyAvatar] idx: %s", tostring(k)))
    if v then
      v:_DestroyCoupleAvatar()
    end
  end
  self.AvatarDatas = {}
  self.Avatars = {}
  self.IndexUse = {}
end
function MultiplayerAvatar:GetAvatarLocation(index)
  if self.AvatarDatas[index] then
    return self.AvatarDatas[index].MultiplayerStandPos
  else
    return {
      X = 0,
      Y = 0,
      Z = 0
    }
  end
end
function MultiplayerAvatar.GetMultiplayerPetShow(PoseItemID)
  local pose_info = CDataTable.GetTableData("MultiplayerAvatarPose", PoseItemID)
  if pose_info then
    return "1" == pose_info.IsShowPet
  end
end
return MultiplayerAvatar