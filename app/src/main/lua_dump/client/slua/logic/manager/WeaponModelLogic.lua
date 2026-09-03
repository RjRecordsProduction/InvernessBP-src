local WeaponModelLogic = {}
local m_cur_show_weapon_resid = 0
local m_mall_weapon_cameraid = 0
local m_mall_force_reset_rotation = false
local m_tmp_mall_weapon_cameraid = 0
local m_cur_force_in_rare_scene = false
local m_tmp_mall_weapon_cur_show_weapon_resid = 0
local CacheExtraTable
local m_curIndex = 0
local m_weapon_show_actor1, m_weapon_show_actor0
local m_default_auto_rotate_speed = 100
local GUN_MASTER_SLOT_ID = 7
local EMPTY_PATTERN_LIST = {
  [1] = {
    TexPathID = 1001,
    SlotID = 7,
    DIYParam = {
      ColorID = 1,
      Rotation = 0,
      Opacity = 0,
      ScaleX = 0,
      ScaleY = 0,
      OffSetX = 0,
      OffSetY = 0
    }
  }
}
local EMPTY_SCENE_ATTACH = {SuperCar = 1, Ordinary = 2}
local WeaponModelMgrHelper = require("client.slua.logic.manager.WeaponModelSubLogic.WeaponModelMgrHelper")
local _check = function(actor)
  if actor and slua.isValid(actor) then
    return true
  else
    return false
  end
end
function WeaponModelLogic.ShowWeaponByResId(resId, isSkin, needResetRotation, needAutoRotate, needRotateBack, needRotation, extraData)
  log(bWriteLog and "MallSystemWeaponModelHandler.ShowWeaponByResId resId:" .. tostring(resId) .. ", isSkin:" .. tostring(isSkin) .. ", needResetRotation:" .. tostring(needResetRotation) .. ", m_cur_show_weapon_resid:" .. tostring(m_cur_show_weapon_resid))
  if resId == nil or resId == 0 then
    log(bWriteLog and "MallSystemWeaponModelHandler:ShowWeaponByResId Invalid Resid")
    return
  end
  local FBI = require("client.slua.logic.fbi.logic_fbi")
  if FBI.IsIllegalTime(resId) then
    return
  end
  m_cur_show_weapon_resid = resId
  isSkin = isSkin or false
  needResetRotation = needResetRotation or false
  needAutoRotate = needAutoRotate or false
  needRotateBack = m_mall_force_reset_rotation or needRotateBack or false
  needRotation = needRotation or false
  local ExtraTable = {}
  local bForceDisplay = false
  local nXOffset = 0
  local autoRotateSpeed = m_default_auto_rotate_speed
  local bForceInRareScene = false
  if extraData then
    nXOffset = extraData.nXOffset or 0
    autoRotateSpeed = extraData.autoRotateSpeed or m_default_auto_rotate_speed
    ExtraTable = extraData.ExtraTable or {}
    if extraData.bForceInRareScene then
      bForceInRareScene = true
    end
  end
  ExtraTable.enable_photon_shadow = true
  local SetRotateBackZ = false
  if extraData then
    if extraData.forceDisplay == true then
      bForceDisplay = extraData.forceDisplay
    end
    if extraData.SetRotateBackZ then
      SetRotateBackZ = extraData.SetRotateBackZ
    end
  end
  log(bWriteLog and "autoRotateSpeed " .. autoRotateSpeed)
  log(bWriteLog and "m_mall_weapon_cameraid " .. m_mall_weapon_cameraid)
  log(bWriteLog and "MallSystemWeaponModelHandler:ShowWeaponByResId, after:" .. tostring(m_cur_show_weapon_resid) .. tostring(isSkin) .. tostring(needResetRotation))
  local TableUtil = require("common.table_util")
  local bExe = true
  if bForceDisplay == false and m_tmp_mall_weapon_cameraid == m_mall_weapon_cameraid and TableUtil.IsDataEqual(ExtraTable, CacheExtraTable) and m_tmp_mall_weapon_cur_show_weapon_resid == m_cur_show_weapon_resid then
    bExe = false
    local actor = WeaponModelLogic.GetProperWeaponShowActor()
    if slua.isValid(actor) and actor.SetExtraTable then
      actor:SetExtraTable(ExtraTable)
    end
  end
  local iResId = WeaponModelMgrHelper.GetRealResIdEnhance(resId, isSkin)
  local weaponCfg = CDataTable.GetTableData("WeaponInitCfg", iResId)
  if weaponCfg == nil then
    ShowDevNotice("###[\228\187\133Dev\231\148\159\230\149\136] \229\134\155\229\164\135\229\186\147\233\133\141\232\161\168->\230\173\166\229\153\168\229\136\157\229\167\139\229\140\150\230\149\176\230\141\174\230\178\161\233\133\141 ID:" .. tostring(iResId))
    bExe = false
  end
  local Location
  if bExe then
    m_tmp_mall_weapon_cameraid = m_mall_weapon_cameraid
    m_cur_force_in_rare_scene = bForceInRareScene
    Cache    m_tmp_mall_weapon_cur_show_weapon_resid = m_cur_show_weapon_resid
    local actor = WeaponModelLogic.GetProperWeaponShowActor()
    Location = actor and actor:K2_GetActorLocation()
    if actor then
      if not actor.isAsyncLoading then
        m_curIndex = m_curIndex + 1
      else
        WeaponModelLogic.DestroyProperWeaponShowActor()
      end
    end
    WeaponModelLogic.SpawnWeaponShowActor()
    local curActor = WeaponModelLogic.GetProperWeaponShowActor()
    local nextActor = WeaponModelLogic.GetProperWeaponShowActorInner(true)
    curActor.isAsyncLoading = true
    curActor.nextShowActor = nextActor
    curActor:SetActorHiddenInGame(false)
    local rotator = WeaponModelMgrHelper.GetRotator(iResId)
    curActor:ShowModelByResID(resId, ExtraTable)
    curActor:SetActorData(resId, nXOffset, rotator, needResetRotation, weaponCfg.XRotateLimit, weaponCfg.YRotateLimit, FRotator(0, 0, 0), weaponCfg.DisableRotate)
    curActor:SetRotateBack(needRotateBack)
    curActor:SetRotateBackTime(200)
    curActor:SetAutoRotate(needAutoRotate)
    curActor:SetAutoRotateSpeed(autoRotateSpeed)
    curActor:SetCanTouchRotate(needRotation)
    curActor:SetDisinteractDis(2500)
    curActor:SetYintensity(70.0)
    curActor:SetYdisRatio(1.0)
    curActor:SetRotateBackZ(SetRotateBackZ)
  end
  log("xcc OnModelReady extraData and extraData.bFullScreen:" .. tostring(extraData and extraData.bFullScreen))
  WeaponModelLogic.OnModelReady(resId, bForceInRareScene, extraData and extraData.bFullScreen and Location)
  WeaponModelLogic.OnShowWeaponByResId(resId, extraData)
end
function WeaponModelLogic.SpawnWeaponShowActor()
  if slua.isValid(m_weapon_show_actor0) == false then
    m_weapon_show_actor0 = WeaponModelMgrHelper.CreateWeaponShowActor()
  end
  if slua.isValid(m_weapon_show_actor1) == false then
    m_weapon_show_actor1 = WeaponModelMgrHelper.CreateWeaponShowActor()
  end
end
function WeaponModelLogic.OnShowWeaponByResId(resId, extraData)
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsDIYWeapon(resId) then
    local gunActor = WeaponModelLogic.GetGunModel()
    WeaponModelMgrHelper.BanMagMirror(gunActor)
    if extraData == nil or extraData.bUseRec == nil or extraData.bUseRec then
      if WeaponModelMgrHelper.getDIYRecScheme(resId) then
        WeaponModelLogic.ChangeDiyGunColorAndPattern(WeaponModelMgrHelper.getDIYRecScheme(resId))
      end
    elseif extraData.bUseRec == false and extraData.schemeData == nil then
      local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
      weapon_diy_system:GetDIYWeaponSchemeAndEquip(resId)
    elseif extraData.schemeData then
      WeaponModelLogic.ChangeDiyGunColorAndPattern(extraData.schemeData)
    end
  else
    local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
    local pendantId = ItemUpgradeMgr:GetWeaponPendantID(resId, DataMgr.roleData.uid)
    log(bWriteLog and "[WeaponModelLogic] PendantId : " .. tostring(pendantId))
    if pendantId ~= 0 then
      local actor = WeaponModelLogic.GetProperWeaponShowActor()
      if actor then
        actor:PutonEquipmentByResid(pendantId)
        local pendantType = 2
        if extraData and extraData.weaponPendantType then
          pendantType = extraData.weaponPendantType
        end
        actor:SetWeaponPendantSocketType(pendantType)
      end
    end
  end
end
function WeaponModelLogic.SetCameraID(id)
  m_mall_weapon_cameraend
function WeaponModelLogic.RefreshWeaponLocation(checkItemID)
  if m_cur_show_weapon_resid ~= nil and m_cur_show_weapon_resid ~= 0 then
    if checkItemID ~= nil and checkItemID ~= m_cur_show_weapon_resid then
      return
    end
    WeaponModelLogic.OnModelReady(m_cur_show_weapon_resid, m_cur_force_in_rare_scene)
  end
end
function WeaponModelLogic.OnModelReady(resId, bForceInRareScene, Location)
  log(bWriteLog and "WeaponModelLogic.OnModelReady, resId:" .. tostring(resId) .. " bForceInRareScene: " .. tostring(bForceInRareScene))
  local ret = WeaponModelLogic.TriggerAdapt(resId, bForceInRareScene, Location)
  if ret then
    WeaponModelLogic.ShowDebug(false)
    local actor = WeaponModelLogic.GetProperWeaponShowActor()
    WeaponModelMgrHelper.ProcessEffectVisible(actor, WeaponModelLogic.m_cur_show_weapon_resid)
  end
end
function WeaponModelLogic.TriggerAdapt(resId, bForceInRareScene, Location)
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if not slua.isValid(actor) then
    return false
  end
  local ret
  if not WeaponModelLogic.Adaptor then
    log_warning(bWriteLog and "  WeaponModelLogic.TriggerAdapt.  not WeaponModelLogic.Adaptor")
    local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
    ModelDisplayer.registDefaultZoneFunc()
  end
  ret = WeaponModelLogic.Adaptor:TriggerAdapt(resId, actor, bForceInRareScene, Location)
  if ret then
    actor:SetShowActorLocationRotation(resId)
    WeaponModelLogic.ProcessVehicleAttach(resId, bForceInRareScene)
    WeaponModelLogic.Adaptor:TryAdaptVehicleInGarage(resId, actor, bForceInRareScene)
    WeaponModelLogic.ProcessUpgradeModelRotationOnly(resId)
    WeaponModelLogic.SetEffectToPlayerLocation(resId)
    EventSystem:postEvent(EVENTTYPE_WEAPON_ADAPT, EVENTID_WEAPON_ADAPT, actor)
  else
    log_warning(bWriteLog and "  WeaponModelLogic.TriggerAdapt.  no ret")
  end
  return ret
end
function WeaponModelLogic.ProcessVehicleAttach(resId, bForceInRareScene)
  local LadderCarDetailConfig = require("client.slua.logic.lobby_activity.LadderCarDetailConfig")
  if bForceInRareScene or LadderCarDetailConfig.IsRareCar(resId) then
    WeaponModelLogic.SetAttachPointBySuperCarScene()
  else
    WeaponModelLogic.SetAttachPointByNormalCarScene()
  end
end
function WeaponModelLogic.ProcessAttachAtapt(editorConfig)
  WeaponModelLogic.SetAdaptTransform({
    editorConfig.relatePrentX,
    editorConfig.relatePrentY,
    editorConfig.relatePrentZ,
    editorConfig.modelx,
    editorConfig.modely,
    editorConfig.modelz,
    editorConfig.modelAttachRelativeX or 0,
    editorConfig.modelAttachRelativeY or 0,
    editorConfig.modelAttachRelativeZ or 0,
    editorConfig.modelsx,
    editorConfig.modelsy,
    editorConfig.modelsz
  })
end
function WeaponModelLogic.ProcessModelRotation(resId, editorConfig)
  local rotateX = editorConfig.modelAttachRotateX or 0
  local rotateY = editorConfig.modelAttachRotateY or 0
  local rotateZ = editorConfig.modelAttachRotateZ or 0
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local itemUpgradeData = ItemUpgradeMgr:GetUpgradeCfg(resId)
  if itemUpgradeData and itemUpgradeData.FavourateItemID then
    local weaponAdditionTransform = CDataTable.GetTableData("WeaponAdditionTransform", itemUpgradeData.FavourateItemID)
    if weaponAdditionTransform then
      rotateX = rotateX + (weaponAdditionTransform.additionRotateX or 0)
      rotateY = rotateY + (weaponAdditionTransform.additionRotateY or 0)
      rotateZ = rotateZ + (weaponAdditionTransform.additionRotateZ or 0)
    end
  end
  WeaponModelLogic.SetAdaptRotation(rotateX, rotateY, rotateZ)
end
function WeaponModelLogic.ProcessUpgradeModelRotationOnly(resId)
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local itemUpgradeData = ItemUpgradeMgr:GetUpgradeCfg(resId)
  if itemUpgradeData and itemUpgradeData.FavourateItemID then
    local weaponAdditionTransform = CDataTable.GetTableData("WeaponAdditionTransform", itemUpgradeData.FavourateItemID)
    if weaponAdditionTransform then
      WeaponModelLogic.SetAdaptRotation(weaponAdditionTransform.additionRotateX, weaponAdditionTransform.additionRotateY, weaponAdditionTransform.additionRotateZ)
    end
  end
end
function WeaponModelLogic.SetAttachPointByNormalCarScene()
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if not actor or not slua.isValid(actor) then
    log_warning(bWriteLog and "[cw][xpcall] not actor ")
    return
  end
  actor:AttachToAttachPoint()
end
function WeaponModelLogic.SetAttachPointBySuperCarScene()
  local logic_SuperCar_200Version = require("client.maps.logic_SuperCar_200Version")
  local c = logic_SuperCar_200Version.Const.DefaultVehiclePosition
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if not actor or not slua.isValid(actor) then
    log_warning(bWriteLog and "[cw][xpcall] not actor ")
    return
  end
  actor:K2_SetActorLocation(FVector(c.X, c.Y, c.Z), false, nil, false)
  actor:SetCanTouchRotate(false)
end
function WeaponModelLogic.SetEffectToPlayerLocation(resId)
  local cfgEntry = CDataTable.GetTableData("Item", resId)
  if cfgEntry and cfgEntry.ItemSubType == 30302 then
    local actor = WeaponModelLogic.GetProperWeaponShowActor()
    if not actor or not slua.isValid(actor) then
      log_warning(bWriteLog and "[cw][xpcall] not actor ")
      return
    end
    local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
    if ModelDisplayer._showingAvatar then
      local Position = ModelDisplayer._showingAvatar:GetShowPosition()
      actor:K2_SetActorLocation(FVector(Position.x, Position.y, Position.z), false, nil, false)
      return true
    end
  end
  return false
end
function WeaponModelLogic.GetProperWeaponShowActorInner(bNext)
  local bFlag = m_curIndex % 2 == 0
  if bNext == bFlag then
    return m_weapon_show_actor0
  end
  return m_weapon_show_actor1
end
function WeaponModelLogic.DestroyProperWeaponShowActorInner(bNext)
  local bFlag = m_curIndex % 2 == 0
  if bNext == bFlag then
    m_weapon_show_actor0:Destroy()
    m_weapon_show_actor0 = nil
    return
  end
  m_weapon_show_actor1:Destroy()
  m_weapon_show_actor1 = nil
  return
end
function WeaponModelLogic.GetProperWeaponShowActor()
  local actor = WeaponModelLogic.GetProperWeaponShowActorInner(false)
  return actor
end
function WeaponModelLogic.DestroyProperWeaponShowActor()
  WeaponModelLogic.DestroyProperWeaponShowActorInner(false)
end
function WeaponModelLogic.SetWeaponTouchEnable(bEnable)
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if _check(actor) then
    actor:SetTouchStatus(bEnable)
  end
end
function WeaponModelLogic.SetWeaponShadowEnable(bEnable)
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if _check(actor) then
    actor:GetWeaponActor():GetWeaponSkeletalMeshComponent():SetCastShadow(bEnable)
  end
end
function WeaponModelLogic.ShowDebug(isShow)
  isShow = isShow or false
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if _check(actor) then
    WeaponModelMgrHelper.SetEditorBallVis(actor, isShow)
  end
end
function WeaponModelLogic.SetAdaptRotation(rx, ry, rz)
  local KismetMathLibrary = import("KismetMathLibrary")
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  local rotate = KismetMathLibrary.MakeRotator(rx, ry, rz)
  if _check(actor) then
    actor.RootComponent:K2_SetRelativeRotation(rotate, false, nil, false)
  end
end
function WeaponModelLogic.SetAdaptTransform(adaptTransformArr)
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if _check(actor) then
    WeaponModelMgrHelper.SetAdaptTransform(actor, adaptTransformArr)
  end
end
function WeaponModelLogic.ChangeGunDiyMatList(matList, slotId)
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if slotId then
    WeaponModelMgrHelper.ChangeGunDiyMatList(actor, slotId, matList)
  else
    WeaponModelMgrHelper.ChangeGunDiyMatList(actor, GUN_MASTER_SLOT_ID, matList)
  end
end
function WeaponModelLogic.ChangeGunDiySlotMatList(matList)
  if matList and type(matList) == "table" then
    local actor = WeaponModelLogic.GetProperWeaponShowActor()
    for i, v in ipairs(matList) do
      if v then
        WeaponModelMgrHelper.ChangeGunDiyMatList(actor, i, {v})
      end
    end
  end
end
function WeaponModelLogic._RecombinePatternSchemeData(patternList)
  return WeaponModelMgrHelper._RecombinePatternSchemeData(patternList, GUN_MASTER_SLOT_ID)
end
function WeaponModelLogic.GetGunModel()
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if slua.isValid(actor) and slua.isValid(actor:GetWeaponActor()) then
    return actor:GetWeaponActor()
  end
end
function WeaponModelLogic.SwitchMirrorState(mirrorParam)
  local gunActor = WeaponModelLogic.GetGunModel()
  local mirrorArray = slua.Array(UEnums.EPropertyClass.Int)
  for i, v in ipairs(mirrorParam) do
    mirrorArray:Add(v)
  end
  if gunActor then
    gunActor.WeaponAvatarComponent:AddAction_DIYMirroParam(7, mirrorArray)
  end
end
function WeaponModelLogic.SetVehicleSelectedHighlight(Invincible, FreExp, Speed)
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if slua.isValid(actor) then
    WeaponModelMgrHelper.SetVehicleSelectedHighlight(actor)
  end
end
function WeaponModelLogic.SetHolderBack()
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if slua.isValid(actor) then
    actor:SetHolderBack()
  end
end
function WeaponModelLogic.ChangeDiyGunColorAndPattern(schemeData)
  if schemeData then
    if schemeData.MirrorParam then
      WeaponModelLogic.SwitchMirrorState(schemeData.MirrorParam)
    end
    if schemeData.MatParam then
      WeaponModelLogic.ChangeGunDiyMatList(schemeData.MatParam)
    end
    if schemeData.DIYData then
      WeaponModelLogic.ChangeGunDiyPatternList(schemeData.DIYData)
    end
    if schemeData.SlotMatParam then
      WeaponModelLogic.ChangeGunDiySlotMatList(schemeData.SlotMatParam)
    else
      WeaponModelLogic.ChangeGunDiySlotMatList({
        0,
        0,
        0,
        0,
        0
      })
    end
  end
end
function WeaponModelLogic.ChangeGunDiyPatternList(patternList)
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if patternList == nil then
    log(bWriteLog and "MallSystemWeaponModelHandler.ChangeGunDiyPatternList: pattern nil or bp nil")
    return
  end
  local bActorValid = false
  if actor and actor:GetWeaponActor() and actor:GetWeaponActor().WeaponAvatarComponent then
    bActorValid = true
  end
  if bActorValid == false then
    return
  end
  if patternList == nil then
    log(bWriteLog and "MallSystemWeaponModelHandler.ChangeGunDiyPatternList: pattern nil or bp nil")
    return
  end
  local comp = actor:GetWeaponActor().WeaponAvatarComponent
  local slotID = GUN_MASTER_SLOT_ID
  local emptyPatternList = EMPTY_PATTERN_LIST
  local weapon_macro = require("client.slua.umg.WeaponDIY.weapon_diy_macro")
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  local resid = WeaponModelLogic.GetShowingId()
  local curWeaponDIYPartsID = weapon_diy_system:GetCurWeaponPartSocketsID(resid)
  if patternList[1] == nil then
    local patterns = WeaponModelMgrHelper._ConvertDiyPatterSchemeLuaToBp(emptyPatternList)
    comp:AddAction_DIYPattern(slotID, patterns)
    for _, v in pairs(curWeaponDIYPartsID) do
      comp:AddAction_DIYPattern(v, patterns)
    end
    return
  end
  local slotPatternListMap = {}
  for i, v in ipairs(patternList) do
    if v.SlotID == nil then
      v.SlotID = weapon_macro.ENUM_DIY_WEAPON_SLOT_TYPE.MasterGun
    end
    if slotPatternListMap[v.SlotID] then
      table.insert(slotPatternListMap[v.SlotID], v)
    else
      slotPatternListMap[v.SlotID] = {
        [1] = v
      }
    end
  end
  for i, v in pairs(curWeaponDIYPartsID) do
    if slotPatternListMap[v] == nil then
      slotPatternListMap[v] = emptyPatternList
    end
  end
  if slotPatternListMap[weapon_macro.ENUM_DIY_WEAPON_SLOT_TYPE.MasterGun] == nil then
    slotPatternListMap[weapon_macro.ENUM_DIY_WEAPON_SLOT_TYPE.MasterGun] = emptyPatternList
  end
  for k, v in pairs(slotPatternListMap) do
    local array = WeaponModelMgrHelper._ConvertDiyPatterSchemeLuaToBp(v)
    comp:AddAction_DIYPattern(k, array)
  end
end
function WeaponModelLogic._ConvertDiyPatterSchemeLuaToBp(patternList)
  return WeaponModelMgrHelper._ConvertDiyPatterSchemeLuaToBp(patternList, GUN_MASTER_SLOT_ID)
end
function WeaponModelLogic.ChangeGiveWeaponDIYScheme(weaponActor, scheme, async, weapon_id)
  if weaponActor == nil or weaponActor.WeaponAvatarComponent == nil then
    return
  end
  local emptyPatternList = EMPTY_PATTERN_LIST
  local weapon_macro = require("client.slua.umg.WeaponDIY.weapon_diy_macro")
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  local comp = weaponActor.WeaponAvatarComponent
  local curWeaponDIYPartsID = {}
  if weapon_id then
    curWeaponDIYPartsID = weapon_diy_system:GetCurWeaponPartSocketsID(weapon_id)
  end
  WeaponModelMgrHelper.BanMagMirror(weaponActor)
  if scheme.DIYData[1] == nil then
    local patternArray = WeaponModelMgrHelper._ConvertDiyPatterSchemeLuaToBp(emptyPatternList)
    comp.bSyncAvatar = async == false
    comp:AddAction_DIYPattern(GUN_MASTER_SLOT_ID, patternArray)
    for _, v in pairs(curWeaponDIYPartsID) do
      comp.bSyncAvatar = async == false
      comp:AddAction_DIYPattern(v, patternArray)
    end
  else
    local slotPatternListMap = {}
    for i, v in ipairs(scheme.DIYData) do
      if v.SlotID == nil then
        v.SlotID = weapon_macro.ENUM_DIY_WEAPON_SLOT_TYPE.MasterGun
      end
      if slotPatternListMap[v.SlotID] then
        table.insert(slotPatternListMap[v.SlotID], v)
      else
        slotPatternListMap[v.SlotID] = {
          [1] = v
        }
      end
    end
    for i, v in pairs(curWeaponDIYPartsID) do
      if slotPatternListMap[v] == nil then
        slotPatternListMap[v] = emptyPatternList
      end
    end
    if slotPatternListMap[weapon_macro.ENUM_DIY_WEAPON_SLOT_TYPE.MasterGun] == nil then
      slotPatternListMap[weapon_macro.ENUM_DIY_WEAPON_SLOT_TYPE.MasterGun] = emptyPatternList
    end
    for k, v in pairs(slotPatternListMap) do
      local patternArray = WeaponModelMgrHelper._ConvertDiyPatterSchemeLuaToBp(v)
      comp.bSyncAvatar = async == false
      comp:AddAction_DIYPattern(k, patternArray)
    end
  end
  local matArray = slua.Array(UEnums.EPropertyClass.Int)
  for i, v in ipairs(scheme.MatParam) do
    matArray:Add(v)
  end
  WeaponModelMgrHelper.ChangeGivenWeaponMatParam(weaponActor, GUN_MASTER_SLOT_ID, matArray, async)
  if scheme.SlotMatParam and type(scheme.SlotMatParam) == "table" then
    for i, v in ipairs(scheme.SlotMatParam) do
      local array = slua.Array(UEnums.EPropertyClass.Int)
      array:Add(v)
      WeaponModelMgrHelper.ChangeGivenWeaponMatParam(weaponActor, i, array, async)
    end
  end
  if scheme.MirrorParam then
    local mirrorArray = slua.Array(UEnums.EPropertyClass.Int)
    for i, v in ipairs(scheme.MirrorParam) do
      mirrorArray:Add(v)
    end
    weaponActor.WeaponAvatarComponent:AddAction_DIYMirroParam(GUN_MASTER_SLOT_ID, mirrorArray)
  end
end
function WeaponModelLogic.GetDebugInfoScreenPosition()
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if actor == nil then
    return
  end
  local aPos = actor:K2_GetActorLocation()
  local UIUtil = require("client.common.ui_util")
  local pos = UIUtil.ProjectWorldToScreen(aPos)
  log(bWriteLog and "MallSystemWeaponModelHandler GetDebugInfoScreenPosition x:" .. tostring(pos.X) .. ", y:" .. tostring(pos.Y))
  return pos
end
function WeaponModelLogic.GetShowingActorLocation()
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if actor then
    return actor:K2_GetActorLocation()
  end
end
function WeaponModelLogic.AddShowingActorRotation(roll, pitch, yaw)
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if actor then
    local rotation = actor:K2_GetActorRotation()
    rotation.Roll = roll + rotation.Roll
    rotation.Pitch = pitch + rotation.Pitch
    rotation.Yaw = yaw + rotation.Yaw
    actor:K2_SetActorRotation(rotation, false)
  end
end
function WeaponModelLogic.SetShowingActorRotation(roll, pitch, yaw)
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  if actor then
    local rotation = FRotator(0, 0, 0)
    rotation.Roll = roll
    rotation.Pitch = pitch
    rotation.Yaw = yaw
    actor:K2_SetActorRotation(rotation, false)
  end
end
function WeaponModelLogic.HideWeapon()
  WeaponModelLogic.DestroyWeaponShowActor()
end
function WeaponModelLogic.PutonEquipmentByResId(resId)
  local showActor = WeaponModelLogic.GetProperWeaponShowActor()
  if slua.isValid(showActor) then
    local ret = showActor:PutonEquipmentByResid(resId)
    if ret then
      log(bWriteLog and "Put on equipment succ")
    else
      log(bWriteLog and "Put on equipment error")
    end
  end
end
function WeaponModelLogic.PutoffEquipmentByResId(resId)
  local showActor = WeaponModelLogic.GetProperWeaponShowActor()
  if slua.isValid(showActor) then
    local ret = showActor:PutoffEquipmentByResid(resId)
    if ret then
      log(bWriteLog and "Put off equipment succ")
    else
      log(bWriteLog and "Put off equipment error")
    end
  end
end
function WeaponModelLogic.OpenWeaponTouch()
  WeaponModelLogic.SetWeaponTouchEnable(true)
end
function WeaponModelLogic.CloseWeaponTouch()
  WeaponModelLogic.SetWeaponTouchEnable(false)
end
function WeaponModelLogic.EnableShadow()
  WeaponModelLogic.SetWeaponShadowEnable(true)
end
function WeaponModelLogic.UnableShadow()
  WeaponModelLogic.SetWeaponShadowEnable(false)
end
function WeaponModelLogic.SetForceResetRotation(isForce)
  m_mall_force_reset_rotation = isForce
end
function WeaponModelLogic.DestroyWeaponShowActor()
  m_cur_show_weapon_resid = 0
  m_mall_force_reset_rotation = false
  m_tmp_mall_weapon_cameraid = 0
  CacheExtraTable = nil
  m_tmp_mall_weapon_cur_show_weapon_resid = 0
  if slua.isValid(m_weapon_show_actor0) then
    m_weapon_show_actor0:Destroy()
  end
  if slua.isValid(m_weapon_show_actor1) then
    m_weapon_show_actor1:Destroy()
  end
  m_weapon_show_actor0 = nil
  m_weapon_show_actor1 = nil
end
function WeaponModelLogic.GetShowingId()
  return m_cur_show_weapon_resid
end
function WeaponModelLogic.RegistGetUIRestrictZoneFunc(Func, Type)
  if WeaponModelLogic.Adaptor == nil then
    local AdaptorClass = require("client.slua.logic.manager.LobbyModelAdaptator")
    WeaponModelLogic.Adaptor = AdaptorClass()
  end
  WeaponModelLogic.Adaptor:RegistGetUIRestrictZoneFunc(Func, Type)
end
function WeaponModelLogic.RemoveUIRestrictZone()
  if WeaponModelLogic.Adaptor then
    WeaponModelLogic.Adaptor:Destroy()
    WeaponModelLogic.Adaptor = nil
  end
end
return WeaponModelLogic