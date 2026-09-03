local logic_person_relation_tool = {}
function logic_person_relation_tool.CheckPoseFriendList()
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  local relationFriendList = logic_person_relation.rela_frd_list
  if relationFriendList then
    for k, v in pairs(relationFriendList) do
      if v ~= 0 then
        return false
      end
    end
    return true
  else
    return true
  end
end
function logic_person_relation_tool.GetExhibitionPlayerInfoList()
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  local exhibitionlist = logic_person_relation:GetSet_rela_frd_list()
  if not exhibitionlist or not next(exhibitionlist) then
    return nil
  end
  local datalist = logic_person_relation:GetInteractionWithSet_rela_frd_list(exhibitionlist, true)
  local infolist = {}
  if not datalist or not next(datalist) then
    return
  end
  for k, v in pairs(datalist) do
    local info = {}
    if k == 1 or v.TexturePath == "" then
      info.interactionValue = nil
      info.interactionImage = nil
    else
      info.interactionValue = v.interactInfo
      info.interactionImage = v.TexturePath
    end
    info.uid = v.uid
    info.index = k
    info.trustValue = v.friendIntimacy
    info.relationImage = v.relationImage
    info.relationText = v.relationText
    table.insert(infolist, info)
  end
  return infolist
end
function logic_person_relation_tool.GetSceneBackGroundLevelName(poseId)
  log(bWriteLog and "logic_person_relation_tool GetSceneBackGroundLevelName poseid = " .. tostring(poseId))
  local info = CDataTable.GetTableData("MultiplayerAvatarPose", poseId)
  if info then
    if info.BackGroundLevel and info.BackGroundLevel ~= "" then
      return info.BackGroundLevel
    else
      log(bWriteLog and "logic_person_relation_tool GetSceneBackGroundLevelName BackGroundLevel = nil")
    end
  else
    log(bWriteLog and "logic_person_relation_tool GetSceneBackGroundLevelName info = nil ")
  end
end
function logic_person_relation_tool.GetCameraIDbyPoseId(poseId)
  log(bWriteLog and "logic_person_relation_tool GetCamerabyPoseId poseid = " .. tostring(poseId))
  local info = CDataTable.GetTableData("MultiplayerAvatarPose", poseId)
  if info then
    if info.CameraID then
      return info.CameraID
    else
      log(bWriteLog and "logic_person_relation_tool GetCamerabyPoseId info.CameraID = nil poseid =" .. tostring(poseId))
      local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
      return Lobby_camera_manager_module.Enum_CameraID.PartnerAvatarPose
    end
  else
    log(bWriteLog and "logic_person_relation_tool GetCamerabyPoseId info = nil ")
  end
end
return logic_person_relation_tool