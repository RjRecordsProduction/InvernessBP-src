local CoupleAvatarAction = {}
local CoupleAvatarConfig = require("client.slua.logic.lobby.Left.CoupleAvatarConfig")
local logic_couple_avatar_util = require("client.slua.logic.lobby.Left.logic_couple_avatar_util")
function CoupleAvatarAction:ShowTeamupAction(action_data)
  if not action_data then
    return
  end
  for _, avatar in pairs(self.avatars) do
    if action_data.action_id and action_data.action_id ~= 0 then
      avatar:PlayAction(action_data.action_id)
    end
    if action_data.effect_id and action_data.effect_id ~= 0 then
      avatar:PlayTeamupEffect(action_data.effect_id)
    end
  end
end
function CoupleAvatarAction:GetCoupleAnimDuration()
  if not self:IsTwoPerson() then
    log(bWriteLog and "CoupleAvatarAction:GetCoupeAnimDuration not self:IsTwoPerson()")
    return -1
  end
  local time = 0
  local model_util = require("client.common.model_util")
  local PoseID = self:GetSelfPoseID()
  if self:_ShouldPlaySpecialAnim(PoseID) then
    local Cfg = CDataTable.GetTableData("IntimacyPosePreviewCfg", PoseID)
    local montage1 = model_util.GetAssetObjByPath(Cfg.LeftMontage)
    local montage2 = model_util.GetAssetObjByPath(Cfg.RightMontage)
    if not slua.isValid(montage1) or not slua.isValid(montage2) then
      log(bWriteLog and "CoupleAvatarAction:GetCoupleAnimDuration: Failed to get special anim montage")
      return time
    end
    time = math.max(time, montage1.SequenceLength / montage1.RateScale)
    time = math.max(time, montage2.SequenceLength / montage2.RateScale)
  else
    local LeftPath, RightPath = self:GetPoseAnimPath(PoseID)
    if not LeftPath or not RightPath then
      log(bWriteLog and "CoupleAvatarAction:GetCoupeAnimDuration not AnimPath PoseID:" .. tostring(PoseID))
      return -1
    end
    local leftMontage = model_util.GetAssetObjByPath(LeftPath)
    local rightMontage = model_util.GetAssetObjByPath(RightPath)
    if slua.isValid(leftMontage) then
      time = math.max(time, leftMontage.SequenceLength / leftMontage.RateScale)
    end
    if slua.isValid(rightMontage) then
      time = math.max(time, rightMontage.SequenceLength / rightMontage.RateScale)
    end
    local intimacyPoseCfg = CDataTable.GetTableData("IntimacyPose", PoseID)
    if intimacyPoseCfg and intimacyPoseCfg.MeshPath ~= "" and intimacyPoseCfg.MeshAnimPath ~= "" then
      local modelMontage = model_util.GetAssetObjByPath(intimacyPoseCfg.MeshAnimPath)
      if slua.isValid(modelMontage) then
        time = math.max(time, modelMontage.SequenceLength / modelMontage.RateScale)
      end
    end
  end
  log(bWriteLog and "CoupleAvatarAction:GetCoupleAnimDuration: time = " .. tostring(time))
  return time
end
function CoupleAvatarAction:PlayCoupleAnim()
  log(bWriteLog and "CoupleAvatarAction PlayCoupleAnim")
  if not self:IsTwoPerson() then
    log(bWriteLog and "CoupleAvatarAction:PlayCoupleAnim not self:IsTwoPerson()")
    return false
  end
  local PoseID = self:GetSelfPoseID()
  local bUseSpecial, Location = self:_ShouldPlaySpecialAnim(PoseID)
  if bUseSpecial then
    log(bWriteLog and "CoupleAvatarAction PlaySpecialAnim")
    local Cfg = CDataTable.GetTableData("IntimacyPosePreviewCfg", PoseID)
    if Location == CoupleAvatarConfig.PosType.Left then
      self:PlayAnim(CoupleAvatarConfig.AvatarType.Self, Cfg.LeftMontage)
      self:PlayAnim(CoupleAvatarConfig.AvatarType.Friend, Cfg.RightMontage)
    else
      self:PlayAnim(CoupleAvatarConfig.AvatarType.Self, Cfg.RightMontage)
      self:PlayAnim(CoupleAvatarConfig.AvatarType.Friend, Cfg.LeftMontage)
    end
    return
  end
  local LeftPath, RightPath = self:GetPoseAnimPath(PoseID)
  if not LeftPath or not RightPath then
    log(bWriteLog and "CoupleAvatarAction:PlayCoupleAnim not AnimPath PoseID:" .. tostring(PoseID))
    return false
  end
  local SelfStandType = self:GetStandType(CoupleAvatarConfig.AvatarType.Self)
  if SelfStandType == CoupleAvatarConfig.PosType.Left then
    self:PlayAnim(CoupleAvatarConfig.AvatarType.Self, LeftPath)
    self:PlayAnim(CoupleAvatarConfig.AvatarType.Friend, RightPath)
  else
    self:PlayAnim(CoupleAvatarConfig.AvatarType.Self, RightPath)
    self:PlayAnim(CoupleAvatarConfig.AvatarType.Friend, LeftPath)
  end
  self:PlayModelAnim(PoseID)
end
function CoupleAvatarAction:_ShouldPlaySpecialAnim(PoseID)
  if not PoseID then
    return false
  end
  local Cfg = CDataTable.GetTableData("IntimacyPosePreviewCfg", PoseID)
  if not Cfg then
    return false
  end
  local selfAvatar = self:GetAvatar(CoupleAvatarConfig.AvatarType.Self)
  local friendAvatar = self:GetAvatar(CoupleAvatarConfig.AvatarType.Friend)
  if not selfAvatar or not friendAvatar then
    return false
  end
  local selfPawn = selfAvatar:GetModel()
  local friendPawn = friendAvatar:GetModel()
  if not selfPawn or not friendPawn then
    return false
  end
  if not slua.isValid(selfPawn.CharacterAvatarComp2_BP) or not slua.isValid(friendPawn.CharacterAvatarComp2_BP) then
    return false
  end
  if selfAvatar:HasEquiped(Cfg.LeftSuit) and friendAvatar:HasEquiped(Cfg.RightSuit) then
    return true, CoupleAvatarConfig.PosType.Left
  elseif selfAvatar:HasEquiped(Cfg.RightSuit) and friendAvatar:HasEquiped(Cfg.LeftSuit) then
    return true, CoupleAvatarConfig.PosType.Right
  end
  return false
end
function CoupleAvatarAction:PlayModelAnim(PoseID)
  local intimacyPoseCfg = CDataTable.GetTableData("IntimacyPose", PoseID)
  if not intimacyPoseCfg or intimacyPoseCfg.MeshPath == "" or intimacyPoseCfg.MeshAnimPath == "" then
    return
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local tPathList = {}
  if intimacyPoseCfg.MeshPath ~= "" then
    table.insert(tPathList, intimacyPoseCfg.MeshPath)
  end
  if intimacyPoseCfg.MeshAnimPath ~= "" then
    table.insert(tPathList, intimacyPoseCfg.MeshAnimPath)
  end
  table.insert(tPathList, intimacyPoseCfg.LeftPose)
  table.insert(tPathList, intimacyPoseCfg.RightPose)
  table.insert(tPathList, intimacyPoseCfg.LeftAnimation)
  table.insert(tPathList, intimacyPoseCfg.RightAnimation)
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, tPathList)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "CoupleAvatarAction:PlayModelAnim not download " .. tostring(intimacyPoseCfg.MeshPath) .. "   " .. tostring(intimacyPoseCfg.MeshAnimPath))
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, tPathList)
    return
  end
  if not slua.isValid(self.AnimActor) then
    local world = slua_GameFrontendHUD:GetWorld()
    local ActorClass = import("/Game/Arts_PlayerBluePrints/Common/BP_SimpleAnimActor.BP_SimpleAnimActor_C")
    self.AnimActor = world:SpawnActor(ActorClass, nil, nil, nil)
    self.AnimActor:K2_AttachToActor(self.pawnContainer:GetPawnContainer(), "None", 1, 1, 1, false)
    self.AnimActor:K2_SetActorRelativeLocation(FVector(0, 0, -90), false, nil, false)
    self.AnimActor:K2_SetActorRelativeRotation(FRotator(0, 0, 0), false, nil, false)
  end
  local model_util = require("client.common.model_util")
  local Mesh = model_util.GetAssetObjByPath(intimacyPoseCfg.MeshPath)
  local Montage = model_util.GetAssetObjByPath(intimacyPoseCfg.MeshAnimPath)
  self.AnimActor:PlayAnim(Mesh, Montage)
end
function CoupleAvatarAction:DestroyAnimActor()
  if slua.isValid(self.AnimActor) then
    self.AnimActor:K2_DestroyActor()
  end
  self.AnimActor = nil
end
function CoupleAvatarAction:CheckCanPlayCoupleAnim()
  if not self:IsTwoPerson() then
    return false
  end
  local LeftPath, RightPath = self:GetPoseAnimPath(self:GetSelfPoseID())
  if not LeftPath or not RightPath then
    return false
  end
  return true
end
function CoupleAvatarAction:PlayAnim(AvatarType, AnimPath)
  log(bWriteLog and "CoupleAvatarAction:PlayAnim AvatarType" .. tostring(AvatarType) .. "AnimPath:" .. tostring(AnimPath))
  local Model = self:GetModel(AvatarType)
  if not Model then
    log(bWriteLog and "CoupleAvatarAction:PlayAnim not Model")
    return
  end
  local Mesh = Model.Mesh
  local model_util = require("client.common.model_util")
  local Montage = model_util.GetAssetObjByPath(AnimPath)
  local animInst1 = Mesh:GetAnimInstance()
  if animInst1 and slua.isValid(Montage) then
    local EMontagePlayReturnType = import("EMontagePlayReturnType")
    animInst1:Montage_Play(Montage, 1, EMontagePlayReturnType.Duration, 0)
  end
end
function CoupleAvatarAction:GetPoseAnimPath(PoseID)
  local intimacyPoseCfg = CDataTable.GetTableData("IntimacyPose", PoseID)
  if not (intimacyPoseCfg and intimacyPoseCfg.LeftAnimation and intimacyPoseCfg.LeftAnimation ~= "" and intimacyPoseCfg.RightAnimation) or intimacyPoseCfg.RightAnimation == "" then
    log(bWriteLog and "CoupleAvatarAction:GetAnimationPath no animation PoseID" .. tostring(PoseID))
    return nil
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local tPathList = {}
  if intimacyPoseCfg.MeshPath ~= "" then
    table.insert(tPathList, intimacyPoseCfg.MeshPath)
  end
  if intimacyPoseCfg.MeshAnimPath ~= "" then
    table.insert(tPathList, intimacyPoseCfg.MeshAnimPath)
  end
  table.insert(tPathList, intimacyPoseCfg.LeftPose)
  table.insert(tPathList, intimacyPoseCfg.RightPose)
  table.insert(tPathList, intimacyPoseCfg.LeftAnimation)
  table.insert(tPathList, intimacyPoseCfg.RightAnimation)
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, tPathList)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "CoupleAvatarAction:GetPoseAnimPath not download  " .. tostring(intimacyPoseCfg.LeftAnimation) .. "  " .. tostring(intimacyPoseCfg.RightAnimation))
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, tPathList)
    return nil
  end
  return intimacyPoseCfg.LeftAnimation, intimacyPoseCfg.RightAnimation
end
function CoupleAvatarAction:_LoadPoseAnimation(AvatarType)
  local avatar = self:GetAvatar(AvatarType)
  if not avatar then
    return
  end
  local Pose = self:GetSelfPoseID()
  local PosType = self:GetStandType(AvatarType)
  local PosePath
  if self.ExtraData.PosePath then
    PosePath = self.ExtraData.PosePath
  else
    PosePath = logic_couple_avatar_util.GetPosePath(Pose, PosType)
  end
  if not PosePath then
    return
  end
  log(bWriteLog and "CoupleAvatarAction _LoadPoseAnimation AvatarType:" .. tostring(AvatarType) .. " Pose:" .. tostring(Pose) .. " PosePath:" .. tostring(PosePath))
  local util = require("client.slua_ui_framework.util")
  local StringUtil = require("common.string_util")
  local finalPath = StringUtil.StrFind(PosePath, "/Game/") and PosePath or "/Game/Arts_Player/Characters/Animation/Shared_Anim/Lobby_Anim/" .. PosePath
  local delegate = util.GetAssetAsync(finalPath, self._OnLoadedAnimation, self, avatar)
  if delegate then
    table.insert(self.AssetAsynDelegates, delegate)
  end
end
function CoupleAvatarAction:_OnLoadedAnimation(avatar, loadObject)
  log(bWriteLog and "CoupleAvatarAction:_OnLoadedAnimation avatar = " .. tostring(avatar) .. ", loadObject = " .. tostring(loadObject))
  if not self:IsTwoPerson() and not self.ExtraData.bLoadSelfPoseAnim then
    log(bWriteLog and "CoupleAvatarAction:_OnLoadedAnimation not self.FriendUI")
    return
  end
  local logic_couple_avatar_util = require("client.slua.logic.lobby.Left.logic_couple_avatar_util")
  if not logic_couple_avatar_util.CheckAndLoadAnimation(avatar, loadObject) then
    log(bWriteLog and "CoupleAvatarAction:_OnLoadedAnimation no need to wait")
    return
  end
  local timer_ticker = require("common.time_ticker")
  local tryTimes = 60
  local bWait = true
  local timerID
  timerID = timer_ticker.AddTimerLoop(0, function()
    if bWait and 0 < tryTimes and self:IsTwoPerson() then
      bWait = logic_couple_avatar_util.CheckAndLoadAnimation(avatar, loadObject)
      tryTimes = tryTimes - 1
    else
      timer_ticker.RemoveTimer(timerID)
    end
  end, TIMER_INFINITE, timer_ticker.NEXT_FRAME)
end
function CoupleAvatarAction:StopTeamupAction()
  log(bWriteLog and "CoupleAvatarAction StopTeamupAction")
  for _, avatar in pairs(self.avatars) do
    avatar:StopAction(nil, true)
    local operateAvatar = avatar:GetModel()
    if slua.isValid(operateAvatar) then
      operateAvatar:StopAnimMontage()
      operateAvatar:DestoryActionParticle()
    end
  end
  self:DestroyAnimActor()
end
local Trait = require("common.trait")
local TCoupleAvatarAction = Trait(Trait.TraitPrototype, nil, CoupleAvatarAction)
return TCoupleAvatarAction