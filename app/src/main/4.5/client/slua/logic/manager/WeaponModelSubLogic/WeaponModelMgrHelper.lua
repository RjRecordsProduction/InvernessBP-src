local UKismetMathLibrary = import("KismetMathLibrary")
local KismetSystemLibrary = import("KismetSystemLibrary")
local WeaponModelMgrHelper = {}
function WeaponModelMgrHelper.SetEditorBallVis(actor, bVis)
  if slua.isValid(actor) then
    if bVis then
      actor.Sphere:SetHiddenInGame(false, false)
      actor.Capsule:SetHiddenInGame(false, false)
      actor.Sphere:SetVisibility(true, false)
      actor.Capsule:SetVisibility(true, false)
    else
      actor.Sphere:SetHiddenInGame(true, false)
      actor.Capsule:SetHiddenInGame(true, false)
      actor.Sphere:SetVisibility(false, false)
      actor.Capsule:SetVisibility(false, false)
    end
  end
end
function WeaponModelMgrHelper.SetActorLocationAndScale(actor, x, y, z, scale, actorName, compName)
  local wActor = actor[actorName]
  if slua.isValid(wActor) then
    local loc = FVector(x, y, z)
    if compName == "" then
      wActor:K2_SetActorRelativeLocation(loc, false, nil, false)
    else
      local comp = wActor[compName]
      comp:K2_SetRelativeLocation(loc, false, nil, false)
    end
    wActor:SetActorScale3D(FVector(scale, scale, scale))
  end
end
function WeaponModelMgrHelper.ProcessEffectActor(isVisible, tags, target)
  if slua.isValid(target) then
    local uComponentClass = import("/Script/Engine.ParticleSystemComponent")
    for i, tag in ipairs(tags) do
      local tarArr = target:GetComponentsByTag(uComponentClass, tag)
      for k, v in pairs(tarArr) do
        v:SetVisibility(isVisible, false)
      end
    end
  end
end
function WeaponModelMgrHelper.ProcessEffectActorVisible(target, showTags, hideTags)
  WeaponModelMgrHelper.ProcessEffectActor(true, showTags, target)
  WeaponModelMgrHelper.ProcessEffectActor(false, hideTags, target)
end
function WeaponModelMgrHelper.ProcessEffectVisible(actor, weaponResID)
  if not weaponResID or weaponResID <= 0 then
    return
  end
  local localResCfg = CDataTable.GetTableData("ParticleEffectVisible", weaponResID)
  if localResCfg then
    local kismet_string_library = require("common.kismet_string_library")
    local showTagArr = kismet_string_library.ParseIntoArray(localResCfg.ShowTags, "|", true)
    local hideTagArr = kismet_string_library.ParseIntoArray(localResCfg.HideTags, "|", true)
    WeaponModelMgrHelper.ProcessEffectActorVisible(actor:GetWeaponActor(), showTagArr, hideTagArr)
    WeaponModelMgrHelper.ProcessEffectActorVisible(actor:GetVehicleActor(), showTagArr, hideTagArr)
    WeaponModelMgrHelper.ProcessEffectActorVisible(actor:GetPlaneCharacter(), showTagArr, hideTagArr)
  end
end
function WeaponModelMgrHelper.ChangeGunDiyMatList(actor, slotID, matList)
  if matList == nil then
    return
  end
  local matArray = slua.Array(UEnums.EPropertyClass.Int)
  for i, _ in ipairs(matList) do
    matArray:Add(matList[i])
  end
  if slua.isValid(actor) and slua.isValid(actor:GetWeaponActor()) and slua.isValid(actor:GetWeaponActor().WeaponAvatarComponent) then
    actor:GetWeaponActor().WeaponAvatarComponent:AddAction_DIYMatParam(slotID, matArray)
  end
end
function WeaponModelMgrHelper.ChangeGivenWeaponMatParam(weapon, slotID, InMatIDList, Async)
  if slua.isValid(weapon) and slua.isValid(weapon.WeaponAvatarComponent) then
    weapon.WeaponAvatarComponent.bSyncAvatar = not Async
    weapon.WeaponAvatarComponent:AddAction_DIYMatParam(slotID, InMatIDList)
  end
end
function WeaponModelMgrHelper.GetRealResId(resId, isSkin)
  if resId == nil then
    return nil
  end
  if isSkin then
    local cfg
    cfg = CDataTable.GetTableData("WeaponSkinMapping", resId)
    if cfg then
      return cfg.WeaponID
    end
    cfg = CDataTable.GetTableData("VehiclePlaneSkinMapping", resId)
    if cfg then
      return cfg.OrginalID
    end
    log(bWriteLog and resId .. "can not find the skin id\239\188\140 so just use the prop id")
    return resId
  else
    return resId
  end
end
function WeaponModelMgrHelper.GetRealResIdEnhance(resId, isSkin)
  local OriginResID = WeaponModelMgrHelper.GetRealResId(resId, isSkin)
  OriginResID = OriginResID == resId and WeaponModelMgrHelper.GetOriginID(resId) or OriginResID
  return OriginResID
end
function WeaponModelMgrHelper.GetOriginID(resId)
  local Cfg = CDataTable.GetTableData("ExtraSkinMap", resId)
  if Cfg then
    return Cfg.OriginID
  else
    return WeaponModelMgrHelper.GetDefaultOriginResID(resId)
  end
end
function WeaponModelMgrHelper.GetDefaultOriginResID(resId)
  local ItemCfg = CDataTable.GetTableData("Item", resId)
  if not ItemCfg then
    log(bWriteLog and "WeaponModelMgrHelper GetDefaultOriginResID not ItemCfg")
    return nil
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  local SubType = ItemCfg.ItemSubType
  if SubType == ModelDisplayTypeHelper.SubTypeList.Grenade then
    return 612004000
  elseif SubType == ModelDisplayTypeHelper.SubTypeList.Smoke then
    return 613004000
  elseif SubType == ModelDisplayTypeHelper.SubTypeList.Earthquake then
    return 614004000
  elseif SubType == ModelDisplayTypeHelper.SubTypeList.Burning then
    return 615004000
  elseif ModelDisplayTypeHelper.IsBagWidget(ItemCfg.ItemType, ItemCfg.ItemSubType) then
    return 417004001
  elseif ModelDisplayTypeHelper.IsMiniTv(ItemCfg.itemType) then
    return 1601019
  elseif ModelDisplayTypeHelper.IsHolography(ItemCfg.ItemType) then
    return 7001006
  elseif ModelDisplayTypeHelper.IsStatue(ItemCfg.itemType) then
    return 6101003
  elseif ModelDisplayTypeHelper.IsTank(ItemCfg.itemType, ItemCfg.ItemSubType) then
    return 1963001
  elseif ModelDisplayTypeHelper.IsHomeStatue(ItemCfg.itemType, ItemCfg.ItemSubType) then
    return 66631425
  end
  return nil
end
function WeaponModelMgrHelper.SetAdaptTransform(actor, adaptTransformArr)
  local parent = actor.DefaultSceneRoot:GetAttachParent()
  if slua.isValid(parent) then
    local owner = parent:GetOwner()
    if slua.isValid(owner) and Owner:ActorHasTag("VehicleAttachPoint") then
      actor:K2_SetActorRelativeLocation(FVector(adaptTransformArr[7], adaptTransformArr[8], adaptTransformArr[9]), false, nil, false)
    end
  end
  local tempX = adaptTransformArr[4] / 1000
  local tempY = adaptTransformArr[5] / 1000
  local tempZ = adaptTransformArr[6] / 1000
  local tempS = adaptTransformArr[10] / 1000
  WeaponModelMgrHelper.SetActorLocationAndScale(actor, tempX, tempY, tempZ, tempS, "SubActor", "")
end
function WeaponModelMgrHelper.CreateWeaponShowActor()
  local ModelFactory = require("client.slua.logic.show_actor.common.ModelFactory")
  local uLocation = FVector(12, -130, -14330)
  local uRotation = FRotator(0, 0, 0)
  local uScale = FVector(1.0, 1.0, 1.0)
  local newWeaponActor = ModelFactory.CreateShowActor()
  newWeaponActor:K2_SetActorLocation(uLocation, false, nil, false)
  newWeaponActor:K2_SetActorRotation(uRotation, false)
  newWeaponActor:SetActorScale3D(uScale)
  return newWeaponActor
end
function WeaponModelMgrHelper.getDIYRecScheme(weaponId)
  local weapon_diy_rec_scheme = require("client.slua.logic.weapon_diy.weapon_diy_rec_scheme")
  local schemeData = weapon_diy_rec_scheme[weaponId]
  return schemeData
end
function WeaponModelMgrHelper.BanMagMirror(weaponActor)
  if weaponActor and weaponActor.WeaponAvatarComponent then
    weaponActor.WeaponAvatarComponent:AddAction_DIYMirroParam(2, {0, 1})
  end
end
function WeaponModelMgrHelper.GetRotator(resId)
  local result = {
    0,
    0,
    0
  }
  if resId == 108001 or resId == 108002 or resId == 108003 then
    result = {
      0.0,
      -30.0,
      0.0
    }
  elseif resId == 108004 then
    result = {
      0.0,
      0.0,
      230.0
    }
  else
    result = {
      0.0,
      0.0,
      0.0
    }
  end
  local KismetMathLibrary = import("KismetMathLibrary")
  local rotate = KismetMathLibrary.MakeRotator(result[1], result[2], result[3])
  return rotate
end
function WeaponModelMgrHelper.GetDIYWeaponSchemeAndEquip(weaponId)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  weapon_diy_system:GetDIYWeaponSchemeAndEquip(weaponId)
end
function WeaponModelMgrHelper._RecombinePatternSchemeData(patternList, defaultID)
  if patternList == nil then
    return nil
  end
  local weapon_diy_utils = require("client.slua.umg.WeaponDIY.weapon_diy_utils")
  local newPatternList = {}
  for _, v in ipairs(patternList) do
    if v.TextureList and next(v.TextureList) then
      for _, vv in ipairs(v.TextureList) do
        local oneTex = {
          TexPathID = vv.TexPathID,
          SlotID = v.SlotID or defaultID
        }
        local originPolar = weapon_diy_utils:ConvertToPolar({
          x = vv.DIYParam.OffSetX,
          y = vv.DIYParam.OffSetY
        })
        local curPosition = weapon_diy_utils:ConvertToVector(originPolar.r * v.DIYParam.ScaleX, -originPolar.angle + v.DIYParam.Rotation * 360 + 180)
        local rotation = vv.DIYParam.Rotation + v.DIYParam.Rotation + 0.25
        if v.DIYParam.Rotation > 0 then
          if rotation < 0 then
            local integerPart = math.floor(-rotation)
            rotation = rotation + integerPart + 1
          else
            local integerPart = math.floor(rotation)
            rotation = rotation - integerPart
          end
        elseif 0 < rotation then
          local integerPart = math.floor(rotation)
          rotation = rotation - integerPart - 1
        else
          local integerPart = math.floor(-rotation)
          rotation = rotation + integerPart
        end
        oneTex.DIYParam = {
          ColorID = vv.DIYParam.ColorID,
          Rotation = rotation,
          Opacity = vv.DIYParam.Opacity,
          ScaleX = vv.DIYParam.ScaleX * v.DIYParam.ScaleX,
          ScaleY = vv.DIYParam.ScaleY * v.DIYParam.ScaleY,
          OffSetX = curPosition.x + v.DIYParam.OffSetX,
          OffSetY = curPosition.y + v.DIYParam.OffSetY,
          UClipX = vv.DIYParam.UClipX,
          UClipY = vv.DIYParam.UClipY,
          VClipX = vv.DIYParam.VClipX,
          VClipY = vv.DIYParam.VClipY,
          Direction = v.DIYParam.Direction
        }
        table.insert(newPatternList, oneTex)
      end
    else
      table.insert(newPatternList, v)
    end
  end
  return newPatternList
end
function WeaponModelMgrHelper._ConvertDiyPatterSchemeLuaToBp(patternList, defaultSlotID)
  local struct_DIYMergeTexture = import("DIYMergedTexData")
  local patternArray = slua.Array(UEnums.EPropertyClass.Struct, struct_DIYMergeTexture)
  local newPatternList = WeaponModelMgrHelper._RecombinePatternSchemeData(patternList, defaultSlotID)
  for _, v in ipairs(newPatternList) do
    if struct_Param == nil then
      local struct_DIYParameters = import("DIYParamData")
      struct_Param = struct_DIYParameters()
    end
    struct_Param.ColorID = v.DIYParam.ColorID
    struct_Param.Rotation = v.DIYParam.Rotation
    struct_Param.Opacity = v.DIYParam.Opacity
    struct_Param.ScaleX = v.DIYParam.ScaleX
    struct_Param.ScaleY = v.DIYParam.ScaleY
    struct_Param.OffSetX = v.DIYParam.OffSetX
    struct_Param.OffSetY = v.DIYParam.OffSetY
    struct_Param.UClipX = v.DIYParam.UClipX or 0.0
    struct_Param.UClipY = v.DIYParam.UClipY or 1.0
    struct_Param.VClipX = v.DIYParam.VClipX or 0.0
    struct_Param.VClipY = v.DIYParam.VClipY or 1.0
    local weapon_macro = require("client.slua.umg.WeaponDIY.weapon_diy_macro")
    struct_Param.Direction = v.DIYParam.Direction or weapon_macro.ENUM_DIY_PROJECT_DIRECTION.Y
    if struct_Mertex == nil then
      struct_Mertex = struct_DIYMergeTexture()
    end
    struct_Mertex.TexPathID = v.TexPathID or 0
    struct_Mertex.DiyParam = struct_Param
    struct_Mertex.SlotID = v.SlotID or defaultSlotID
    patternArray:Add(struct_Mertex)
  end
  return patternArray
end
function WeaponModelMgrHelper.SetVehicleSelectedHighlight(actor, Invincible, FreExp, Speed)
  local vehicle = actor:GetVehicleActor()
  if vehicle and slua.isValid(vehicle) then
    vehicle:SetHighLight(Invincible, FreExp, Speed)
    return
  end
  local refitVehicle = actor:GetrefitVehicleActor()
  if refitVehicle and slua.isValid(refitVehicle) then
    refitVehicle:SetHighLight(Invincible, FreExp, Speed)
    return
  end
end
return WeaponModelMgrHelper