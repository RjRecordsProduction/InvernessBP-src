local logic_couple_avatar_util = {
  HidePos = {
    X = 0,
    Y = 0,
    Z = 1000
  }
}
local CoupleAvatarConfig = require("client.slua.logic.lobby.Left.CoupleAvatarConfig")
function logic_couple_avatar_util.CheckNeedUpdate(oldCoupleShowInfo, newCoupleShowInfo, avatarList)
  log(bWriteLog and "logic_couple_avatar_util.CheckNeedUpdate")
  log_tree("oldCoupleShowInfo = ", oldCoupleShowInfo)
  log_tree("newCoupleShowInfo = ", newCoupleShowInfo)
  if oldCoupleShowInfo == nil then
    if newCoupleShowInfo == nil then
      log(bWriteLog and "logic_couple_avatar_util.CheckNeedUpdate all info nil")
      return false
    else
      log(bWriteLog and "logic_couple_avatar_util.CheckNeedUpdate old info nil")
      return true
    end
  end
  local table_util = require("common.table_util")
  local bSameData = table_util.IsDataEqual(oldCoupleShowInfo, newCoupleShowInfo)
  if not bSameData then
    log(bWriteLog and "logic_couple_avatar_util.CheckNeedUpdate same data")
    return true
  end
  if avatarList == nil then
    log(bWriteLog and "logic_couple_avatar_util.CheckNeedUpdate avatarList == nil")
    return true
  end
  local bOneHide = false
  for i, avatar in ipairs(avatarList) do
    if i <= #oldCoupleShowInfo then
      local pos = avatar:GetPosition()
      if pos.x == logic_couple_avatar_util.HidePos.X and pos.y == logic_couple_avatar_util.HidePos.Y and pos.z == logic_couple_avatar_util.HidePos.Z then
        bOneHide = true
        break
      end
    end
  end
  if bOneHide then
    log(bWriteLog and "logic_couple_avatar_util.CheckNeedUpdate one avatar hide")
    return true
  end
  return false
end
function logic_couple_avatar_util.HideAvatarList(avatarList)
  log(bWriteLog and "logic_couple_avatar_util.HideAvatarList")
  if avatarList == nil then
    log(bWriteLog and "logic_couple_avatar_util.HideAvatarList avatarList == nil")
    return
  end
  for i, avatar in ipairs(avatarList) do
    avatar:EnableClothAnimation(false)
    avatar:EnableCastPhotonShadow(false)
    avatar:SetPosition(logic_couple_avatar_util.HidePos.X, logic_couple_avatar_util.HidePos.Y, logic_couple_avatar_util.HidePos.Z)
    local pet = avatar:GetPet()
    if pet then
      pet:RecoverAttachState()
    end
    local miniTv = avatar:GetMiniTVActor()
    if miniTv then
      miniTv:SetActorHiddenInGame(true, true)
    end
  end
end
function logic_couple_avatar_util.CheckAndLoadAnimation(avatar, loadObject)
  if avatar == nil or not slua.isValid(loadObject) then
    log(bWriteLog and "logic_couple_avatar_util.CheckAndLoadAnimation loadObject nil")
    return false
  end
  local avatarObj = avatar:GetModel()
  if not slua.isValid(avatarObj) then
    log(bWriteLog and "logic_couple_avatar_util.CheckAndLoadAnimation avatarObj == nil")
    return false
  end
  if slua.isValid(avatarObj.Mesh) and slua.isValid(avatarObj.Mesh.AnimScriptInstance) then
    log(bWriteLog and "logic_couple_avatar_util.CheckAndLoadAnimation ready")
    avatarObj.Mesh.AnimScriptInstance:OnPoseWithFriend(loadObject)
    return false
  end
  return true
end
function logic_couple_avatar_util.GetCoupleMiddlePos(avatarList)
  log(bWriteLog and "logic_couple_avatar_util.GetCoupleMiddlePos")
  if avatarList == nil or #avatarList <= 0 then
    return {
      x = 0,
      y = 0,
      z = 0
    }
  end
  if #avatarList == 1 then
    local pos = avatarList[1]:GetPosition()
    return {
      x = pos.x,
      y = pos.y,
      z = pos.z
    }
  else
    local avatar1 = avatarList[1]
    local avatar2 = avatarList[2]
    local pos1 = avatar1:GetPosition()
    local pos2 = avatar2:GetPosition()
    return {
      x = (pos1.x + pos2.x) / 2,
      y = (pos1.y + pos2.y) / 2,
      z = (pos1.z + pos2.z) / 2
    }
  end
end
function logic_couple_avatar_util.GetCoupleRadius(avatarList)
  log(bWriteLog and "logic_couple_avatar_util.GetCoupleRadius")
  if avatarList == nil or #avatarList <= 0 then
    return 0
  end
  if #avatarList == 1 then
    return avatarList[1]:GetRadius()
  else
    local avatar1 = avatarList[1]
    local avatar2 = avatarList[2]
    local pos1 = avatar1:GetPosition()
    local pos2 = avatar2:GetPosition()
    local radius1 = avatar1:GetRadius()
    local radius2 = avatar2:GetRadius()
    local dist = math.sqrt((pos1.x - pos2.x) ^ 2 + (pos1.y - pos2.y) ^ 2 + (pos1.z - pos2.z) ^ 2)
    return (radius1 + radius2 + dist) / 2
  end
end
function logic_couple_avatar_util.CheckIfCouplePoseItem(itemCfg)
  if not itemCfg or not itemCfg.ItemID then
    log(bWriteLog and "logic_couple_avatar_util.CheckIfCouplePoseItem no itemCfg")
    return false
  end
  log(bWriteLog and "logic_couple_avatar_util.CheckCouplePoseItem itemId:" .. tostring(itemCfg.ItemID))
  return itemCfg.ItemType == 203
end
function logic_couple_avatar_util.ShowPartnerItemPreview(itemID)
  if not itemID then
    log(bWriteLog and "logic_couple_avatar_util.ShowPartnerItemPreview no itemCfg")
    return false
  end
  log(bWriteLog and "logic_couple_avatar_util.ShowPartnerItemPreview itemId:" .. tostring(itemID))
  if FuncUtil.IsInXMission() then
    log(bWriteLog and "logic_couple_avatar_util.ShowPartnerItemPreview inxmission")
    return false
  end
  local intimacyPoseMapping = CDataTable.GetTableData("IntimacyPoseMapping", itemID)
  if not intimacyPoseMapping or not intimacyPoseMapping.PoseType then
    log(bWriteLog and "logic_couple_avatar_util.ShowPartnerItemPreview no pose")
    return false
  end
  UIManager.ShowUI(UIManager.UI_Config.Partner_Preview_UIBP, itemID, true)
  return true
end
function logic_couple_avatar_util.CheckSelfHasPartnerInfo()
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  local myRoleData = BasicDataAvatarWearInfo:GetCacheData(DataMgr.roleData.uid)
  if not myRoleData then
    log(bWriteLog and "logic_couple_avatar_util.CheckSelfHasPartnerInfo no roledata")
    return false
  end
  if not (myRoleData.partner_info and myRoleData.partner_info.partner_uid) or myRoleData.partner_info.partner_uid == 0 then
    log(bWriteLog and "logic_couple_avatar_util.CheckSelfHasPartnerInfo no partner")
    return false
  end
  log(bWriteLog and "logic_couple_avatar_util.CheckSelfHasPartnerInfo true")
  return true
end
function logic_couple_avatar_util.SetPartnerPose(poseItemId)
  if not logic_couple_avatar_util.CheckSelfHasPartnerInfo() then
    log(bWriteLog and "logic_couple_avatar_util.PutOnPartnerPose no partner_info")
    return
  end
  if not poseItemId then
    log(bWriteLog and "logic_couple_avatar_util.PutOnPartnerPose no selectPoseId")
    return
  end
  local intimacyPoseMapping = CDataTable.GetTableData("IntimacyPoseMapping", poseItemId)
  if not intimacyPoseMapping then
    log(bWriteLog and "logic_couple_avatar_util.PutOnPartnerPose no posetype")
    return
  end
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  if IntimacyAwardSystem.cur_posture and IntimacyAwardSystem.cur_posture == poseItemId then
    log(bWriteLog and "logic_couple_avatar_util.PutOnPartnerPose cur pose")
    return
  end
  log(bWriteLog and "logic_couple_avatar_util.PutOnPartnerPose:" .. tostring(poseItemId))
  IntimacyAwardSystem.set_posture_req(poseItemId)
end
function logic_couple_avatar_util.GetDefaultPoseId(SelfGender, FriendGender)
  for i = 1, 3 do
    local IntimacyPose = CDataTable.GetTableData("IntimacyPose", i)
    log(bWriteLog and "logic_couple_avatar_util GetDefaultPoseId" .. tostring(IntimacyPose.RightSex) .. tostring(IntimacyPose.LeftSex))
    local SelfSex_String = logic_couple_avatar_util.ConvertGenderNumberToString(SelfGender)
    local FriendSex_String = logic_couple_avatar_util.ConvertGenderNumberToString(FriendGender)
    if IntimacyPose.RightSex == SelfSex_String and IntimacyPose.LeftSex == FriendSex_String or IntimacyPose.LeftSex == SelfSex_String and IntimacyPose.RightSex == FriendSex_String then
      return i
    end
  end
  return 0
end
function logic_couple_avatar_util.ConvertGenderNumberToString(Gender)
  return Gender == 1 and "M" or "F"
end
function logic_couple_avatar_util.GetCoupleAvatarShowPosition(SceneType, Offset)
  if not SceneType or not CoupleAvatarConfig.ShowPosition[SceneType] then
    log_error("logic_couple_avatar_util.GetCoupleAvatarShowPosition SceneType Config is nil" .. tostring(SceneType))
    return
  end
  local ShowPosition = CoupleAvatarConfig.ShowPosition[SceneType]
  if not Offset then
    return ShowPosition
  end
  local Result = {
    X = ShowPosition.X + Offset.X,
    Y = ShowPosition.Y + Offset.Y,
    Z = ShowPosition.Z + Offset.Z
  }
  return Result
end
function logic_couple_avatar_util.GetCoupleAvatarShowRotation(SceneType)
  local Rotation = {
    X = 0,
    Y = 0,
    Z = 0
  }
  if SceneType and CoupleAvatarConfig.RotationConfig[SceneType] then
    Rotation = CoupleAvatarConfig.RotationConfig[SceneType]
  end
  return Rotation
end
function logic_couple_avatar_util.GetStandPositionOffest(PoseID, SelfGender, FriendGender, PosType)
  local posKey = ""
  if SelfGender + FriendGender == 3 then
    posKey = "MF"
  else
    posKey = logic_couple_avatar_util.ConvertGenderNumberToString(SelfGender) .. logic_couple_avatar_util.ConvertGenderNumberToString(FriendGender)
  end
  if not logic_couple_avatar_util.IsResourceHadDownloaded(PoseID, PosType) then
    PoseID = logic_couple_avatar_util.GetNotDownloadDefaultPoseID(PoseID)
  end
  local intimacyPoseMapping = CDataTable.GetTableData("IntimacyPose", PoseID)
  local posString = intimacyPoseMapping[posKey]
  local StringUtil = require("common.string_util")
  local posTabs = StringUtil.Split(posString, "#")
  local LeftPosOffset = logic_couple_avatar_util.SplitPos(posTabs[1])
  local RightPosOffset = logic_couple_avatar_util.SplitPos(posTabs[2])
  return LeftPosOffset, RightPosOffset
end
function logic_couple_avatar_util.SplitPos(posString)
  local StringUtil = require("common.string_util")
  local leftPosTb = StringUtil.Split(posString, ";")
  local Pos = {
    X = tonumber(leftPosTb[1]),
    Y = tonumber(leftPosTb[2]),
    Z = tonumber(leftPosTb[3])
  }
  return Pos
end
function logic_couple_avatar_util.GetPosePath(PoseID, PoseType)
  local IntimacyPoseConfig = CDataTable.GetTableData("IntimacyPose", PoseID)
  if not IntimacyPoseConfig then
    return
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PosePath = ""
  local tPathList = {}
  if IntimacyPoseConfig.MeshPath ~= "" then
    table.insert(tPathList, IntimacyPoseConfig.MeshPath)
  end
  if IntimacyPoseConfig.MeshAnimPath ~= "" then
    table.insert(tPathList, IntimacyPoseConfig.MeshAnimPath)
  end
  table.insert(tPathList, IntimacyPoseConfig.LeftPose)
  table.insert(tPathList, IntimacyPoseConfig.RightPose)
  table.insert(tPathList, IntimacyPoseConfig.LeftAnimation)
  table.insert(tPathList, IntimacyPoseConfig.RightAnimation)
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, tPathList)
  local poseKey = PoseType == CoupleAvatarConfig.PosType.Left and "LeftPose" or "RightPose"
  if state == PufferConst.ENUM_DownloadState.Done then
    local poseResource = IntimacyPoseConfig[poseKey]
    PosePath = poseResource
  else
    log(bWriteLog and "logic_couple_avatar_util.GetPosePath not downloaded " .. tostring(PoseID) .. " " .. tostring(PoseType))
    local defaultIndex = 7 <= PoseID and 1 or 3 < PoseID and PoseID - 3 or PoseID
    local tDefaultIntimacyPoseConfig = CDataTable.GetTableData("IntimacyPose", defaultIndex)
    PosePath = tDefaultIntimacyPoseConfig[poseKey]
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, tPathList)
  end
  return PosePath
end
function logic_couple_avatar_util.IsResourceHadDownloaded(PoseID, PoseType)
  local IntimacyPoseConfig = CDataTable.GetTableData("IntimacyPose", PoseID)
  if not IntimacyPoseConfig then
    return false
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local tPathList = {}
  if IntimacyPoseConfig.MeshPath ~= "" then
    table.insert(tPathList, IntimacyPoseConfig.MeshPath)
  end
  if IntimacyPoseConfig.MeshAnimPath ~= "" then
    table.insert(tPathList, IntimacyPoseConfig.MeshAnimPath)
  end
  table.insert(tPathList, IntimacyPoseConfig.LeftPose)
  table.insert(tPathList, IntimacyPoseConfig.RightPose)
  table.insert(tPathList, IntimacyPoseConfig.LeftAnimation)
  table.insert(tPathList, IntimacyPoseConfig.RightAnimation)
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, tPathList)
  if state == PufferConst.ENUM_DownloadState.Done then
    return true
  else
    log(bWriteLog and "logic_couple_avatar_util.IsResourceHadDownloaded not downloaded " .. tostring(PoseID) .. " " .. tostring(PoseType))
    return false
  end
end
function logic_couple_avatar_util.GetNotDownloadDefaultPoseID(PoseID)
  local defaultIndex = 7 <= PoseID and 1 or 3 < PoseID and PoseID - 3 or PoseID
  return defaultIndex
end
function logic_couple_avatar_util.GetShowVehicleItemId(UId)
  local AvatarDataCenter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AvatarDataCenter)
  local VehicleSkinID = AvatarDataCenter:GetVehicleSkinID(UId)
  if VehicleSkinID == 0 then
    VehicleSkinID = 1918001
  end
  return VehicleSkinID
end
return logic_couple_avatar_util