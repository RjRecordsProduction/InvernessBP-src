local logic_social_preview_bag = {}
local fashionBagData
function logic_social_preview_bag.GetFashionBagData()
  return fashionBagData
end
function logic_social_preview_bag.SetFashionBagData(data)
  fashionBagData = data
end
function logic_social_preview_bag.InitFashionBagDataFromWardRobe()
  local fashionBag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local fashionData = {}
  for i = 1, 4 do
    local unlock = fashionBag_data:IsFashionBagValid(i) or false
    local tmp = {}
    if unlock then
      tmp = fashionBag_data:GetFashionBag(i)
    end
    tmp.index = i
    tmp.    table.insert(fashionData, tmp)
  end
  table.sort(fashionData, function(a, b)
    if a.unlock and b.unlock then
      return a.index < b.index
    elseif not a.unlock and not b.unlock then
      return a.index < b.index
    else
      return a.unlock or false
    end
  end)
  logic_social_preview_bag.SetFashionBagData(fashionData)
end
function logic_social_preview_bag.Trans(insId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  return wardrobe_data:GetHallDepotItemDataByInsID(insId)
end
function logic_social_preview_bag.CreateSkinInfo(data)
  local pspace_skin_info = {}
  local cfg = logic_social_preview_bag.Trans(data.bag_skin)
  pspace_skin_info.bag_skin = cfg and cfg.resID or 0
  pspace_skin_info.bag_level = data.bag_level
  local headCfg = logic_social_preview_bag.Trans(data.head_show)
  pspace_skin_info.head_show = headCfg and headCfg.resID or 0
  local headskincfg = logic_social_preview_bag.Trans(data.helmet_skin)
  pspace_skin_info.helmet_skin = headskincfg and headskincfg.resID or 0
  pspace_skin_info.helmet_level = data.helmet_level
  return pspace_skin_info
end
function logic_social_preview_bag.CreateWearInfo(data, avatarShow)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local WearResType = RoleInfoMainSystem.GetWearResType()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local roleWearList = {}
  for i = 1, #data.rolewear_list do
    if data.rolewear_list[i] then
      local tmp = logic_social_preview_bag.Trans(data.rolewear_list[i])
      if tmp.itemSubType and tmp.resID then
        roleWearList[tmp.itemSubType] = {}
        roleWearList[tmp.itemSubType].resID = tmp.resID
      end
    end
  end
  local pspace_wear_ext = {}
  for k, v in pairs(WearResType) do
    pspace_wear_ext[v] = {0}
  end
  for subType, subData in pairs(roleWearList) do
    if subType == ENUM_ITEM_SUBTYPE.Eye_Slot then
      pspace_wear_ext[WearResType.glasses] = {
        subData.resID
      }
    elseif subType == ENUM_ITEM_SUBTYPE.Mask_Slot then
      pspace_wear_ext[WearResType.face] = {
        subData.resID
      }
    elseif subType == ENUM_ITEM_SUBTYPE.Package_Slot then
      pspace_wear_ext[WearResType.clothes] = {
        subData.resID
      }
    elseif subType == ENUM_ITEM_SUBTYPE.Hat_Slot then
      pspace_wear_ext[WearResType.head] = {
        subData.resID
      }
    elseif subType == ENUM_ITEM_SUBTYPE.Shoes_Slot then
      pspace_wear_ext[WearResType.shoes] = {
        subData.resID
      }
    elseif subType == ENUM_ITEM_SUBTYPE.Pants_Slot then
      pspace_wear_ext[WearResType.pants] = {
        subData.resID
      }
    end
  end
  local skinID = tonumber(DataMgr.Weapon_Skin_InsID)
  local weapon = avatarShow[1]
  pspace_wear_ext[WearResType.weapon_type] = {
    weapon.relat_param
  }
  local itemData = wardrobe_data:GetHallDepotItemDataByInsID(weapon.instid)
  if itemData then
    pspace_wear_ext[WearResType.weapon_skin] = {
      itemData.resID
    }
  end
  pspace_wear_ext[WearResType.headid] = {
    AvatarData.GetHeadID()
  }
  pspace_wear_ext[WearResType.hairid] = {
    AvatarData.GetHairID()
  }
  local bag_pendants = fashionbag_data:GetBagPendants()
  local pendantIdBegin = 106
  local pendantIdIndex = pendantIdBegin
  for k, v in pairs(bag_pendants) do
    itemData = wardrobe_data:GetHallDepotItemDataByInsID(k)
    if itemData then
      pspace_wear_ext[pendantIdIndex] = {
        itemData.resID
      }
      pendantIdIndex = pendantIdIndex + 1
    end
  end
  return pspace_wear_ext
end
function logic_social_preview_bag.CreateRoleDataByIndex(index)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local fashionBag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local profile = LobbySocialSystem.GetProfileByUID(DataMgr.roleData.uid)
  local roleData = {}
  roleData.bshow = true
  roleData.metro_avatar = {
    slots = {}
  }
  roleData.depot_show_info = LobbySystem.roleData.depot_show_info
  roleData.nation = profile.nation
  roleData.name = profile.nickName
  roleData.gender = AvatarData.GetGameGender()
  local bagData = logic_social_preview_bag.GetFashionBagData()
  local data = bagData[index]
  local avatarShow = fashionBag_data:GetAvatarShowData(index)
  local pspace_wear_ext = logic_social_preview_bag.CreateWearInfo(data, avatarShow)
  local pspace_skin_info = logic_social_preview_bag.CreateSkinInfo(data)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local WearResType = RoleInfoMainSystem.GetWearResType()
  if pspace_skin_info.head_show == 0 and 0 < pspace_wear_ext[WearResType.head][1] then
    pspace_skin_info.head_show = pspace_wear_ext[WearResType.head][1]
  end
  local wear = {}
  roleData.  roleData.  local TableUtil = require("common.table_util")
  roleData.skin_info = TableUtil.DeepCloneTable(pspace_skin_info)
  roleData.  roleData.wear_ext = TableUtil.DeepCloneTable(pspace_wear_ext)
  return roleData
end
local modelInstanceArr = {}
function logic_social_preview_bag.GetModelInstanceArrByIndex(index)
  return modelInstanceArr[index]
end
function logic_social_preview_bag.SetModelInstanceArrByIndex(index, value)
  modelInstanceArr[index] = value
end
function logic_social_preview_bag.ReleaseModelInstanceArr()
  modelInstanceArr = {}
end
function logic_social_preview_bag.StopModelInstanceArr()
  for i, v in ipairs(modelInstanceArr) do
    logic_social_preview_bag.SetActiveModeInstance(v[1], v[2], false)
  end
end
function logic_social_preview_bag.SetActiveModeInstance(captureActor, avatarActor, bAct)
  if bAct then
    local model = avatarActor:GetModel()
    model:SetActorHiddenInGame(false)
    model:SetActorTickEnabled(true)
    model.Mesh.bPauseAnims = false
    if slua.isValid(model.curEquipingWeapon) then
      model.curEquipingWeapon:SetActorHiddenInGame(false)
      model.curEquipingWeapon:SetActorTickEnabled(true)
    end
    captureActor:SetActorHiddenInGame(false)
  else
    local model = avatarActor:GetModel()
    model:SetActorHiddenInGame(true)
    model:SetActorTickEnabled(false)
    model.Mesh.bPauseAnims = true
    if slua.isValid(model.curEquipingWeapon) then
      model.curEquipingWeapon:SetActorHiddenInGame(true)
      model.curEquipingWeapon:SetActorTickEnabled(false)
    end
    captureActor:SetActorHiddenInGame(true)
  end
end
function logic_social_preview_bag.CreateAvatar(avatarConfig, avatarData)
  local MultipleAvatarManager = require("client.logic.avatar.MultipleAvatarManager")
  local avatar = MultipleAvatarManager.CreateMultipleAvatar(avatarData, {
    x = avatarConfig[1].X,
    y = avatarConfig[1].Y,
    z = avatarConfig[1].Z
  }, nil)
  return avatar
end
function logic_social_preview_bag.GetCameraAndAvatarConfig(diffVec)
  local camera_trans = FVector(-6, 311, 88)
  local camera_rotation = FRotator(0, -90, 0)
  local camera_scale = FVector(1, 1, 1)
  local avatar_trans = FVector(-18, 0, 89)
  local avatar_rotation = FRotator(0, 17, 0)
  local avatar_scale = FVector(1, 1, 1)
  if diffVec then
    camera_trans.X = camera_trans.X + diffVec.X
    camera_trans.Y = camera_trans.Y + diffVec.Y
    camera_trans.Z = camera_trans.Z + diffVec.Z
    avatar_trans.X = avatar_trans.X + diffVec.X
    avatar_trans.Y = avatar_trans.Y + diffVec.Y
    avatar_trans.Z = avatar_trans.Z + diffVec.Z
  end
  return {
    camera_trans,
    camera_rotation,
    camera_scale
  }, {
    avatar_trans,
    avatar_rotation,
    avatar_scale
  }
end
function logic_social_preview_bag.SpawnCameraActor(location, rotation, scale, avatar)
  local world = slua_GameFrontendHUD:GetWorld()
  local tclass = import("SceneCaptureCameraActor")
  local actor = world:SpawnActor(tclass, location, nil, nil)
  if rotation then
    actor:K2_SetActorRotation(rotation, false)
  end
  if scale then
    actor:SetActorScale3D(scale)
  end
  logic_social_preview_bag.AddActorForCaptureComponent(actor, avatar)
  return actor
end
function logic_social_preview_bag.AddActorForCaptureComponent(actor, avatar)
  local captureComponent = actor.SceneCaptureComponent
  local model = avatar:GetModel()
  if captureComponent then
    captureComponent.PrimitiveRenderMode = 2
    captureComponent.FOVAngle = 45
    captureComponent.ShowOnlyActors:Clear()
    captureComponent.ShowOnlyActors:Add(model)
    if slua.isValid(model.curEquipingWeapon) then
      captureComponent.ShowOnlyActors:Add(model.curEquipingWeapon)
    end
  end
end
function logic_social_preview_bag.FreeCaptureComponent(capture)
  local captureComponent = capture.SceneCaptureComponent
  if captureComponent then
    captureComponent.ShowOnlyActors:Clear()
  end
end
function logic_social_preview_bag.ClearCapture()
  for i, value in ipairs(modelInstanceArr) do
    local captureActor = value[1]
    logic_social_preview_bag.FreeCaptureComponent(captureActor)
    captureActor:SetActorHiddenInGame(true)
  end
end
local timerFunc = {}
local delay = 0
function logic_social_preview_bag.AddTimerOnce(func)
  delay = delay + 0.03
  local time_ticker = require("common.time_ticker")
  local handle = time_ticker.AddTimerOnce(delay, func)
  timerFunc[#timerFunc + 1] = handle
end
function logic_social_preview_bag.ClearTimer()
  local time_ticker = require("common.time_ticker")
  for i, handle in ipairs(timerFunc) do
    time_ticker.RemoveTimer(handle)
  end
  timerFunc = {}
  delay = 0
end
function logic_social_preview_bag.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "logic_social_preview_bag OnModePostSwitch nextState:" .. tostring(nextState))
  if nextState == GameStatus.Login or nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    logic_social_preview_bag.ReleaseModelInstanceArr()
    logic_social_preview_bag.ClearTimer()
    logic_social_preview_bag.ClearData()
  end
end
function logic_social_preview_bag.ClearData()
  fashionBagData = nil
end
return logic_social_preview_bag