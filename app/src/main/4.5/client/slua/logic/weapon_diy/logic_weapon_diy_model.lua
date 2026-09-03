local Weapon_DIY_Model_System = {
  operateWeaponId = nil,
  weaponData = nil,
  diyPatternData = nil,
  OperateCircleComponent = nil,
  curPartIndex = 0
}
local weapon_macro = require("client.slua.umg.WeaponDIY.weapon_diy_macro")
local Enum_Scheme_Status = {
  Rec = 1,
  Have = 2,
  New = 3
}
local OperateScheme
local InitAScheme = function()
  local scheme = {
    schemeId = nil,
    patternNum = 0,
    layerNum = 0,
    maxPattern = 20,
    havePattern = 10,
    operatingPatternIndex = 1,
    status = Enum_Scheme_Status.New,
    detail = {
      MatParam = {
        0,
        0,
        0,
        0
      },
      SlotMatParam = {
        0,
        0,
        0,
        0,
        0
      },
      MirrorParam = {1, 1},
      DIYData = {}
    },
    layers = {},
    diyWeaponLayerInfo = {},
    partNum = 0,
    switchStatus = false
  }
  return scheme
end
local _CreateSchemeData = function(_detail, _layers, _schemeId, _status, _diyConfig)
  local scheme = InitAScheme()
  scheme.schemeId = _schemeId or 0
  scheme.status = _status or scheme.status
  if _detail and next(_detail) then
    scheme.detail.MatParam = _detail.MatParam or {
      0,
      0,
      0,
      0
    }
    scheme.detail.MirrorParam = _detail.MirrorParam or {1, 1}
    scheme.detail.DIYData = _detail.DIYData or {}
    scheme.detail.SlotMatParam = _detail.SlotMatParam or {
      0,
      0,
      0,
      0,
      0
    }
  end
  scheme.layers = _layers or {}
  local canUnlockPatternNum = 0
  local weaponSumData = CDataTable.GetTableData("WeaponDIYList", Weapon_DIY_Model_System.operateWeaponId)
  local partCount = 0
  if weaponSumData then
    for i = 1, 4 do
      if weaponSumData["part" .. tostring(i)] and weaponSumData["part" .. tostring(i)] ~= "" then
        partCount = partCount + 1
      end
    end
  end
  scheme.partNum = partCount
  if _diyConfig then
    if _diyConfig.diyWeaponLayerInfo then
      for k, v in pairs(_diyConfig.diyWeaponLayerInfo) do
        canUnlockPatternNum = canUnlockPatternNum + 1
      end
    end
    scheme.maxPattern = _diyConfig.diyGlobalTable.default_step + canUnlockPatternNum
    if _diyConfig.unlockLayerNum == 0 then
      scheme.havePattern = _diyConfig.diyGlobalTable.default_step
    else
      scheme.havePattern = _diyConfig.unlockLayerNum
    end
    scheme.diyWeaponLayerInfo = _diyConfig.diyWeaponLayerInfo
  end
  if _detail then
    for i, v in ipairs(_detail.DIYData) do
      scheme.layerNum = scheme.layerNum + 1
      if v.TextureList and 0 < #v.TextureList then
        scheme.patternNum = scheme.patternNum + #v.TextureList
      else
        scheme.patternNum = scheme.patternNum + 1
      end
    end
  end
  if scheme.patternNum == scheme.havePattern then
    scheme.operatingPatternIndex = scheme.layerNum
  else
    scheme.operatingPatternIndex = scheme.layerNum + 1
  end
  OperateScheme = scheme
end
function Weapon_DIY_Model_System:ShowWeapon(diyWeaponID)
  log(bWriteLog and "Weapon_DIY_Model_System:ShowWeapon" .. diyWeaponID)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Display(diyWeaponID, true, {
    bUseRec = false,
    schemeData = {
      MatParam = {
        0,
        0,
        0,
        0
      },
      DIYData = nil
    }
  })
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local time_ticker = require("common.time_ticker")
  local weaponActor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if slua.isValid(weaponActor) then
    weaponActor:SetWeaponCollision()
    weaponActor:SetDIYDecalNumPerFrame(false, 5)
    local rotation = FRotator(0, 180, 0)
    weaponActor:K2_SetActorRotation(rotation, false)
    weaponActor:SetRotateBackZ(true)
    weaponActor.canAutoRotateZ = false
  end
  time_ticker.AddTimerOnce(0.2, function()
    local logic_lab_new = require("client.slua.logic.lobby.lab.logic_lab_new")
    logic_lab_new.OnClickNewItem(diyWeaponID)
  end)
  self.operateWeaponId = diyWeaponID
end
function Weapon_DIY_Model_System:SwitchToModel()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.SwitchToModel()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  MallSystemWeaponModelHandler.ChangeDiyGunColorAndPattern({
    DIYData = weapon_diy_system.CurDIYData,
    MatParam = weapon_diy_system.CurMatParam,
    MirrorParam = weapon_diy_system.CurMirrorParam,
    SlotMatParam = weapon_diy_system.CurSlotMatParam
  })
  local showActor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if slua.isValid(showActor) then
    local rotation = FRotator(0, 180, 0)
    showActor:K2_SetActorRotation(rotation, false)
    showActor:SetRotateBackZ(true)
    showActor:SetDIYDecalNumPerFrame(false, 5)
    showActor:SetWeaponCollision()
  end
end
function Weapon_DIY_Model_System:SwitchToAvatar()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.SwitchToAvatar()
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  local model = ModelDisplayer.GetShowingAvatar():GetModel()
  local weapon = model.curEquipingWeapon
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.ChangeGiveWeaponDIYScheme(weapon, {
    DIYData = weapon_diy_system.CurDIYData,
    MatParam = weapon_diy_system.CurMatParam,
    MirrorParam = weapon_diy_system.CurMirrorParam,
    SlotMatParam = weapon_diy_system.CurSlotMatParam
  }, true, weapon_diy_system._CurWeaponID)
end
function Weapon_DIY_Model_System:DestroyWeapon()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Destroy()
end
local OperateState
local _InitSchemeOperateState = function()
  OperateState = {}
  OperateState.status = false
end
function Weapon_DIY_Model_System:ResetOperateStatus()
  OperateState.status = false
end
function Weapon_DIY_Model_System:GetOperatingStatus()
  if OperateState then
    return OperateState.status
  else
    return false
  end
end
function Weapon_DIY_Model_System:InitOneDiyScheme(_detail, _layers, _schemeId, _status, _diyConfig, back)
  if back then
    log(bWriteLog and "back from settle")
  else
    _CreateSchemeData(_detail, _layers, _schemeId, _status, _diyConfig)
    _InitSchemeOperateState()
  end
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  if ModelDisplayer.GetShowingStatus() == ModelDisplayer.Enum_Status.Avatar then
    self:SwitchToModel()
  end
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.SwitchMirrorState(OperateScheme.detail.MirrorParam)
  self:ReBakeWholeDIYScheme()
  EventSystem:registEvent(EVENTTYPE_WEAPON_DIY_EDIT, EVENTID_WEAPON_DIY_EDIT_PATTERN_CLICKED, Weapon_DIY_Model_System.OnPatternClicked)
  EventSystem:registEvent(EVENTTYPE_WEAPON_DIY_CIRCLE, EVENTID_WEAPON_DIY_CIRCLE_DELETE, Weapon_DIY_Model_System.OnDiyProcessDeletePattern)
  EventSystem:registEvent(EVENTTYPE_WEAPON_DIY_CIRCLE, EVENTID_WEAPON_DIY_CIRCLE_CONFIRM, Weapon_DIY_Model_System.OnDiyProcessConfirmPattern)
  EventSystem:registEvent(EVENTTYPE_WEAPON_DIY_LAYER_COMPONENT, EVENTID_WEAPON_DIY_LAYER_COMPONENT_LAYER_CLICKED, Weapon_DIY_Model_System.OnLayerClicked)
  EventSystem:registEvent(EVENTTYPE_WEAPON_DIY_EDIT, EVENTID_WEAPON_DIY_EDIT_CLOSED, Weapon_DIY_Model_System.OnEditClose)
  EventSystem:registEvent(EVENTTYPE_WEAPON_DIY_EDIT, EVENTID_WEAPON_DIY_EDIT_COLOR_CLICKED, Weapon_DIY_Model_System.OnColorAndMatClicked)
  EventSystem:registEvent(EVENTTYPE_WEAPON_DIY_EDIT, EVENTID_WEAPON_DIY_CHANGE_MIRROR, Weapon_DIY_Model_System.OnMirrorChange)
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY_MODEL, EVENTID_WEAPON_DIY_MODEL_SCHEME_CHANGE)
end
function Weapon_DIY_Model_System:GetOperatingScheme()
  return OperateScheme
end
function Weapon_DIY_Model_System:GetOperatingSchemeDetail()
  if OperateScheme then
    return OperateScheme.detail
  else
    return nil
  end
end
function Weapon_DIY_Model_System:GetGivenLayerInfo(layerIndex)
  return OperateScheme.detail.DIYData[layerIndex]
end
function Weapon_DIY_Model_System:SelectPatternIndex(index)
  OperateScheme.operatingPatternIndex = index
end
function Weapon_DIY_Model_System:SetPlanID(id)
  OperateScheme.schemeId = id
end
function Weapon_DIY_Model_System:GetCurWeaponPartSocketsID()
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  local partInfo = weapon_diy_system:GetWeaponPartInfo(self.operateWeaponId)
  local existParts = {}
  if partInfo then
    for i, v in pairs(partInfo) do
      if v.slotID ~= weapon_macro.ENUM_DIY_WEAPON_SLOT_TYPE.MasterGun then
        table.insert(existParts, v.slotID)
      end
    end
  end
  return existParts
end
function Weapon_DIY_Model_System.OnColorAndMatClicked(eventType, eventID, color_info, index)
  local editComponent = UIManager.GetUI(UIManager.UI_Config.weapon_diy_edit_component)
  if not editComponent then
    return
  end
  if index == 1 then
    for i = 1, editComponent:GetBodyPartCount() do
      OperateScheme.detail.MatParam[i] = color_info.id
    end
    local parts = Weapon_DIY_Model_System:GetCurWeaponPartSocketsID()
    for i, v in ipairs(parts) do
      OperateScheme.detail.SlotMatParam[v] = color_info.id
    end
  elseif editComponent.GunBodyIndexToPartMap[index] then
    OperateScheme.detail.MatParam[editComponent.GunBodyIndexToPartMap[index]] = color_info.id
  else
    OperateScheme.detail.SlotMatParam[Weapon_DIY_Model_System:GetCurWeaponSlotID()] = color_info.id
  end
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.ChangeGunDiyMatList(OperateScheme.detail.MatParam)
  MallSystemWeaponModelHandler.ChangeGunDiySlotMatList(OperateScheme.detail.SlotMatParam)
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY_MODEL, EVENTID_WEAPON_DIY_MODEL_SCHEME_CHANGE)
  OperateState.status = true
end
function Weapon_DIY_Model_System.OnMirrorChange(_, _, mirrorState)
  log(bWriteLog and "OnMirrorChange")
  if mirrorState then
    for i, v in ipairs(OperateScheme.detail.DIYData) do
      if v.DIYParam.Direction == weapon_macro.ENUM_DIY_PROJECT_DIRECTION.Y_ then
        v.DIYParam.Direction = weapon_macro.ENUM_DIY_PROJECT_DIRECTION.Y
      end
      v.DIYParam.Rotation = math.abs(v.DIYParam.Rotation)
    end
    OperateScheme.detail.MirrorParam[1] = 1
  else
    OperateScheme.detail.MirrorParam[1] = 0
  end
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.SwitchMirrorState(OperateScheme.detail.MirrorParam)
  Weapon_DIY_Model_System:ReBakeDIYScheme()
  OperateState.status = true
end
function Weapon_DIY_Model_System.OnSwitchSide(_, _, switchStatus)
  log(bWriteLog and "OnSwitchSide" .. tostring(switchStatus))
  OperateScheme.end
function Weapon_DIY_Model_System.OnPatternClicked(eventType, eventID, _pattern_info)
  local TableUtil = require("common.table_util")
  local pattern_info = TableUtil.DeepCloneTable(_pattern_info)
  local lastLayerInfo = OperateScheme.layers[OperateScheme.operatingPatternIndex]
  local toDeletePatternNum = 0
  if lastLayerInfo and lastLayerInfo.patternNum then
    toDeletePatternNum = lastLayerInfo.patternNum
  end
  if OperateScheme.patternNum == OperateScheme.havePattern and Weapon_DIY_Model_System.OperateCircleComponent == nil then
    ShowNotice(LocUtil.GetLocalizeResStr(9714))
    return
  end
  local addPatternNum = 1
  if pattern_info.diyTextureList and pattern_info.diyTextureList[1] then
    addPatternNum = #pattern_info.diyTextureList
  end
  if OperateScheme.patternNum + addPatternNum - toDeletePatternNum > OperateScheme.havePattern then
    ShowNotice(LocUtil.GetLocalizeResStr(9714))
    return
  end
  OperateState.status = true
  if Weapon_DIY_Model_System.OperateCircleComponent == nil then
    if OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex] == nil then
      OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex] = {
        TextureList = {},
        TexPathID = pattern_info.id,
        DIYParam = {
          ColorID = 0,
          Rotation = 0.0,
          Opacity = 1.0,
          ScaleX = 1.0,
          ScaleY = 1.0,
          OffSetX = 0.0,
          OffSetY = 0.0
        }
      }
      if pattern_info.diyTextureList then
        OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex].TextureList = pattern_info.diyTextureList
      end
      Weapon_DIY_Model_System.OperateCircleComponent = UIManager.ShowUI(UIManager.UI_Config.Weapon_Diy_Operate_Circle, pattern_info, nil)
    else
      if pattern_info.diyTextureList then
        OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex].TextureList = pattern_info.diyTextureList
      else
        OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex].TextureList = {}
      end
      OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex].TexPathID = pattern_info.id
      Weapon_DIY_Model_System.OperateCircleComponent = UIManager.ShowUI(UIManager.UI_Config.Weapon_Diy_Operate_Circle, nil, OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex])
    end
  else
    if pattern_info.diyTextureList then
      OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex].TextureList = pattern_info.diyTextureList
      OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex].TexPathID = pattern_info.id
    elseif OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex] then
      OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex].TexPathID = pattern_info.id
      OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex].TextureList = {}
    end
    Weapon_DIY_Model_System.OperateCircleComponent:ChangePattern(pattern_info)
  end
  local patternData = CDataTable.GetTableData("WeaponDIYPatternTable", pattern_info.id)
  OperateScheme.layers[OperateScheme.operatingPatternIndex] = {
    icon = pattern_info.id,
    patternNum = 1,
    bDiy = pattern_info.diy,
    diyTextureList = pattern_info.diyTextureList,
    bHave = pattern_info.have
  }
  if pattern_info.diyTextureList and pattern_info.diyTextureList[1] then
    OperateScheme.layers[OperateScheme.operatingPatternIndex].patternNum = #pattern_info.diyTextureList
  end
  if pattern_info.cfg and pattern_info.cfg.item_id then
    local itemCfg = CDataTable.GetTableData("Item", pattern_info.cfg.item_id)
    OperateScheme.layers[OperateScheme.operatingPatternIndex].iconPath = itemCfg.ItemSmallIcon
  end
  if lastLayerInfo == nil or next(lastLayerInfo) == nil then
    OperateScheme.patternNum = OperateScheme.patternNum + OperateScheme.layers[OperateScheme.operatingPatternIndex].patternNum
    OperateScheme.layerNum = OperateScheme.layerNum + 1
  else
    OperateScheme.patternNum = OperateScheme.patternNum + OperateScheme.layers[OperateScheme.operatingPatternIndex].patternNum - lastLayerInfo.patternNum
  end
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY_MODEL, EVENTID_WEAPON_DIY_MODEL_SCHEME_CHANGE)
end
function Weapon_DIY_Model_System.OnDiyProcessDeletePattern()
  if OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex] then
    local newDIYData = {}
    local newLayers = {}
    local toDeletePattern = OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex]
    for i, v in ipairs(OperateScheme.detail.DIYData) do
      if i ~= OperateScheme.operatingPatternIndex then
        table.insert(newDIYData, v)
        table.insert(newLayers, OperateScheme.layers[i])
      end
    end
    OperateScheme.detail.DIYData = newDIYData
    OperateScheme.layers = newLayers
    local deletePatternNum = 0
    if toDeletePattern.TextureList and next(toDeletePattern.TextureList) then
      deletePatternNum = #toDeletePattern.TextureList
    else
      deletePatternNum = 1
    end
    OperateScheme.patternNum = OperateScheme.patternNum - deletePatternNum
    OperateScheme.layerNum = OperateScheme.layerNum - 1
  end
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY_MODEL, EVENTID_WEAPON_DIY_MODEL_SCHEME_CHANGE)
  OperateScheme.operatingPatternIndex = #OperateScheme.detail.DIYData + 1
  Weapon_DIY_Model_System.OperateCircleComponent = nil
  UIManager.CloseUI(UIManager.UI_Config.Weapon_Diy_Operate_Circle)
  Weapon_DIY_Model_System:ReBakeDIYScheme()
  OperateState.status = true
end
function Weapon_DIY_Model_System:_GetWeaponRotationState()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local showActor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if showActor then
    local rotator = showActor:K2_GetActorRotation()
    if math.abs(rotator.Yaw) > 90 then
      return true
    else
      return false
    end
  end
  return true
end
function Weapon_DIY_Model_System:_SaveCurStep(merTex)
  if merTex == nil then
    return false
  end
  if OperateScheme.detail == nil then
    return false
  end
  OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex].DIYParam = merTex.DIYParam
  OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex].TexPathID = merTex.TexPathID
  OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex].SlotID = merTex.SlotID
  if OperateScheme.patternNum == OperateScheme.havePattern then
    OperateScheme.operatingPatternIndex = #OperateScheme.detail.DIYData
  else
    OperateScheme.operatingPatternIndex = #OperateScheme.detail.DIYData + 1
  end
  return true
end
function Weapon_DIY_Model_System.OnDiyProcessConfirmPattern(eventType, eventID, merTex, pattern_info)
  Weapon_DIY_Model_System:_SaveCurStep(merTex)
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY_MODEL, EVENTID_WEAPON_DIY_MODEL_SCHEME_CHANGE)
  Weapon_DIY_Model_System.OperateCircleComponent = nil
  UIManager.CloseUI(UIManager.UI_Config.Weapon_Diy_Operate_Circle)
  Weapon_DIY_Model_System:ReBakeDIYScheme()
  OperateState.status = true
end
function Weapon_DIY_Model_System:ReBakeDIYScheme()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.ChangeGunDiyPatternList(OperateScheme.detail.DIYData)
end
function Weapon_DIY_Model_System:ReBakeWholeDIYScheme()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.ChangeGunDiyPatternList(OperateScheme.detail.DIYData)
  MallSystemWeaponModelHandler.ChangeGunDiyMatList(OperateScheme.detail.MatParam)
  MallSystemWeaponModelHandler.ChangeGunDiySlotMatList(OperateScheme.detail.SlotMatParam)
end
function Weapon_DIY_Model_System:ReplaceOneTexAndRebakeDecal(merTex)
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local patternList = OperateScheme.detail.DIYData
  if OperateScheme.operatingPatternIndex == nil then
    return
  end
  if patternList and patternList[OperateScheme.operatingPatternIndex] then
    patternList[OperateScheme.operatingPatternIndex].TexPathID = merTex.TexPathID
    patternList[OperateScheme.operatingPatternIndex].DIYParam = merTex.DIYParam
    patternList[OperateScheme.operatingPatternIndex].SlotID = merTex.SlotID
    MallSystemWeaponModelHandler.ChangeGunDiyPatternList(patternList)
  end
end
function Weapon_DIY_Model_System.OnLayerClicked(eventType, eventID, index)
  Weapon_DIY_Model_System:CallOperatingCircleByLayerIndex(index)
end
function Weapon_DIY_Model_System:CallOperatingCircleByLayerIndex(index)
  if index == OperateScheme.operatingPatternIndex then
    if Weapon_DIY_Model_System.OperateCircleComponent then
      return
    elseif OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex] then
      Weapon_DIY_Model_System.OperateCircleComponent = UIManager.ShowUI(UIManager.UI_Config.Weapon_Diy_Operate_Circle, nil, OperateScheme.detail.DIYData[OperateScheme.operatingPatternIndex])
    end
  else
    if Weapon_DIY_Model_System.OperateCircleComponent then
      Weapon_DIY_Model_System:_SaveCurStep(Weapon_DIY_Model_System.OperateCircleComponent:GetCurDiyData())
      Weapon_DIY_Model_System.OperateCircleComponent = nil
      UIManager.CloseUI(UIManager.UI_Config.Weapon_Diy_Operate_Circle)
    end
    if OperateScheme.detail.DIYData[index] ~= nil then
      OperateScheme.operatingPatternIndex = index
      Weapon_DIY_Model_System.OperateCircleComponent = UIManager.ShowUI(UIManager.UI_Config.Weapon_Diy_Operate_Circle, nil, OperateScheme.detail.DIYData[index])
    elseif index == #OperateScheme.detail.DIYData + 1 then
      OperateScheme.operatingPatternIndex = index
    end
  end
end
function Weapon_DIY_Model_System:ChangeLayerSort(origin_index, target_index)
  local merTex = OperateScheme.detail.DIYData[origin_index]
  local layer = OperateScheme.layers[origin_index]
  table.remove(OperateScheme.detail.DIYData, origin_index)
  table.remove(OperateScheme.layers, origin_index)
  table.insert(OperateScheme.detail.DIYData, target_index, merTex)
  table.insert(OperateScheme.layers, target_index, layer)
  OperateScheme.operatingPatternIndex = target_index
  Weapon_DIY_Model_System:ReBakeDIYScheme()
end
function Weapon_DIY_Model_System:PreEditClose()
  if Weapon_DIY_Model_System.OperateCircleComponent then
    Weapon_DIY_Model_System:_SaveCurStep(Weapon_DIY_Model_System.OperateCircleComponent:GetCurDiyData())
    Weapon_DIY_Model_System.OperateCircleComponent = nil
    UIManager.CloseUI(UIManager.UI_Config.Weapon_Diy_Operate_Circle)
  end
end
function Weapon_DIY_Model_System.OnEditClose()
  if Weapon_DIY_Model_System.OperateCircleComponent then
    Weapon_DIY_Model_System:_SaveCurStep(Weapon_DIY_Model_System.OperateCircleComponent:GetCurDiyData())
    Weapon_DIY_Model_System.OperateCircleComponent = nil
    UIManager.CloseUI(UIManager.UI_Config.Weapon_Diy_Operate_Circle)
  end
  EventSystem:unregistEvent(EVENTTYPE_WEAPON_DIY_EDIT, EVENTID_WEAPON_DIY_EDIT_PATTERN_CLICKED, Weapon_DIY_Model_System.OnPatternClicked)
  EventSystem:unregistEvent(EVENTTYPE_WEAPON_DIY_CIRCLE, EVENTID_WEAPON_DIY_CIRCLE_DELETE, Weapon_DIY_Model_System.OnDiyProcessDeletePattern)
  EventSystem:unregistEvent(EVENTTYPE_WEAPON_DIY_CIRCLE, EVENTID_WEAPON_DIY_CIRCLE_CONFIRM, Weapon_DIY_Model_System.OnDiyProcessConfirmPattern)
  EventSystem:unregistEvent(EVENTTYPE_WEAPON_DIY_LAYER_COMPONENT, EVENTID_WEAPON_DIY_LAYER_COMPONENT_LAYER_CLICKED, Weapon_DIY_Model_System.OnLayerClicked)
  EventSystem:unregistEvent(EVENTTYPE_WEAPON_DIY_EDIT, EVENTID_WEAPON_DIY_EDIT_COLOR_CLICKED, Weapon_DIY_Model_System.OnColorAndMatClicked)
  EventSystem:unregistEvent(EVENTTYPE_WEAPON_DIY_EDIT, EVENTID_WEAPON_DIY_EDIT_CLOSED, Weapon_DIY_Model_System.OnEditClose)
  EventSystem:unregistEvent(EVENTTYPE_WEAPON_DIY_EDIT, EVENTID_WEAPON_DIY_CHANGE_MIRROR, Weapon_DIY_Model_System.OnMirrorChange)
end
local _spreadTextureListToArray = function(diyData)
  local textures = {}
  local baseTextures = {}
  for i, v in ipairs(diyData) do
    if v.TextureList and v.TextureList[1] ~= nil then
      for ii, vv in ipairs(v.TextureList) do
        table.insert(baseTextures, vv.TexPathID)
      end
    else
      table.insert(textures, v.TexPathID)
    end
  end
  return textures, baseTextures
end
local _spreadTextureListToMap = function(diyData)
  local textures = {}
  for i, v in ipairs(diyData) do
    if v.TextureList and v.TextureList[1] ~= nil then
      for ii, vv in ipairs(v.TextureList) do
        if textures[vv.TexPathID] then
          textures[vv.TexPathID] = textures[vv.TexPathID] + 1
        else
          textures[vv.TexPathID] = 1
        end
      end
    elseif textures[v.TexPathID] then
      textures[v.TexPathID] = textures[v.TexPathID] + 1
    else
      textures[v.TexPathID] = 1
    end
  end
  return textures
end
function Weapon_DIY_Model_System:_MergeMatParam(mat, slotMat)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  local weaponPartInfo = weapon_diy_system:GetWeaponPartInfo(self.operateWeaponId)
  local tempMat = {
    0,
    0,
    0,
    0
  }
  local count = 1
  for i, v in pairs(mat) do
    if weaponPartInfo and weaponPartInfo[i + 1] then
      if weaponPartInfo[i + 1].slotID == weapon_macro.ENUM_DIY_WEAPON_SLOT_TYPE.MasterGun then
      else
        count = count + 1
      end
      if count <= #tempMat then
        tempMat[count] = v
      end
      count = count + 1
    end
  end
  if slotMat then
    for i, v in pairs(slotMat) do
      if v ~= 0 then
        for kk, vv in pairs(weaponPartInfo) do
          if vv.slotID == i then
            tempMat[kk - 1] = v
          end
        end
      end
    end
  end
  return tempMat
end
local _CopyMat = function(mat)
  local result = {}
  for i, v in ipairs(mat) do
    result[i] = v
  end
  return result
end
local _GenerateResidualMat = function(new_mat, old_mat)
  local mat = {}
  local newMat = _CopyMat(new_mat)
  local oldMat = _CopyMat(old_mat)
  for i, v in ipairs(newMat) do
    if newMat[i] == oldMat[i] then
      newMat[i] = 0
      oldMat[i] = 0
    end
  end
  local oldMatMap = {}
  for _, v in ipairs(oldMat) do
    if oldMatMap[v] then
      oldMatMap[v] = oldMatMap[v] + 1
    else
      oldMatMap[v] = 1
    end
  end
  for i, v in ipairs(newMat) do
    if oldMatMap[v] == nil or oldMatMap[v] == 0 then
      mat[i] = v
    else
      mat[i] = 0
      oldMatMap[v] = oldMatMap[v] - 1
    end
  end
  return mat
end
function Weapon_DIY_Model_System:_GenerateSettleData(new_scheme, old_scheme, schemeId)
  local result = {}
  if old_scheme then
    local mat1 = self:_MergeMatParam(new_scheme.MatParam, new_scheme.SlotMatParam)
    local mat2 = self:_MergeMatParam(old_scheme.MatParam, old_scheme.SlotMatParam)
    local mat = _GenerateResidualMat(mat1, mat2)
    local icon = {}
    local baseIcon = {}
    local newTexs, newBaseTexs = _spreadTextureListToArray(new_scheme.DIYData)
    local oldTexsMap = _spreadTextureListToMap(old_scheme.DIYData)
    for i, v in ipairs(newTexs) do
      if oldTexsMap[v] ~= nil and 0 < oldTexsMap[v] then
        oldTexsMap[v] = oldTexsMap[v] - 1
      else
        table.insert(icon, v)
      end
    end
    for i, v in ipairs(newBaseTexs) do
      if oldTexsMap[v] ~= nil and 0 < oldTexsMap[v] then
        oldTexsMap[v] = oldTexsMap[v] - 1
      else
        table.insert(baseIcon, v)
      end
    end
    result = {
      MatParam = mat,
      BaseIconParam = baseIcon,
      IconParam = icon,
      SchemeId = schemeId
    }
  else
    local mat = self:_MergeMatParam(new_scheme.MatParam, new_scheme.SlotMatParam)
    local icon, baseIcon = _spreadTextureListToArray(new_scheme.DIYData)
    result = {
      MatParam = mat,
      BaseIconParam = baseIcon,
      IconParam = icon,
      SchemeId = schemeId
    }
  end
  log_tree("Weapon_DIY_Model_System._GenerateSettleData result:", result)
  return result
end
function Weapon_DIY_Model_System:GetSettleData(old_scheme, scheme_id)
  if OperateScheme and OperateScheme.detail then
    return self:_GenerateSettleData(OperateScheme.detail, old_scheme, scheme_id)
  else
    return nil
  end
end
function Weapon_DIY_Model_System:GetBackData(scheme)
  return self:_GenerateSettleData(scheme, nil, 0)
end
function Weapon_DIY_Model_System:GetOperatingSchemeBinData()
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  return weapon_diy_system:PackSchemeDataToBinData(OperateScheme.detail)
end
local _GenerateDIYDataByMerTex = function(merTex)
  local struct_DIYMergeTexture = import("DIYMergedTexData")
  local struct_DIYParameters = import("DIYParamData")
  local DiyParam = struct_DIYParameters()
  DiyParam.ColorID = merTex.DIYParam.ColorID
  DiyParam.Rotation = merTex.DIYParam.Rotation
  DiyParam.Opacity = merTex.DIYParam.Opacity
  DiyParam.ScaleX = merTex.DIYParam.ScaleX
  DiyParam.ScaleY = merTex.DIYParam.ScaleY
  DiyParam.OffSetX = merTex.DIYParam.OffSetX
  DiyParam.OffSetY = merTex.DIYParam.OffSetY
  DiyParam.Direction = merTex.DIYParam.Direction
  local OneMergeTex = struct_DIYMergeTexture()
  OneMergeTex.TexPathID = merTex.TexPathID or 0
  OneMergeTex.  local AvatarDIYUtils = import("AvatarDIYUtils")
  return AvatarDIYUtils.MakeDIYData(OneMergeTex)
end
local _GetDecalParamActorScreenLocation = function(merTex)
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local gunActor = MallSystemWeaponModelHandler.GetGunModel()
  local weapon_diy_utils = require("client.slua.umg.WeaponDIY.weapon_diy_utils")
  local frame = weapon_diy_utils:GetFrame()
  if gunActor == nil or frame == nil or frame.UIRoot:GetDPMgr() == nil then
    return {x = 0, y = 0}
  end
  local diyData = _GenerateDIYDataByMerTex(merTex)
  local component = Weapon_DIY_Model_System:GetCurOperatingMeshComp()
  local worldLocation = frame.UIRoot:GetDPMgr():GetSpawanDBPActorLocationByDiyData(diyData, component)
  local screenPosition = frame.UIRoot:GetScreenPosition(worldLocation)
  return {
    x = screenPosition.X,
    y = screenPosition.Y
  }
end
local _GetScreenRadius = function(merTex)
  local weapon_diy_utils = require("client.slua.umg.WeaponDIY.weapon_diy_utils")
  local frame = weapon_diy_utils:GetFrame()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local gunActor = MallSystemWeaponModelHandler.GetGunModel()
  if gunActor == nil or frame == nil then
    return 0
  end
  local UWidgetLayoutLibrary = import("WidgetLayoutLibrary")
  local playerController = slua_GameFrontendHUD:GetPlayerController()
  local diyData = _GenerateDIYDataByMerTex(merTex)
  local component = Weapon_DIY_Model_System:GetCurOperatingMeshComp()
  local worldLocation1 = frame.UIRoot:GetDPMgr():GetSpawanDBPActorLocationByDiyData(diyData, component)
  local worldLocation2 = FVector(worldLocation1.X + merTex.DIYParam.ScaleX, worldLocation1.Y, worldLocation1.Z)
  local p1 = UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPositionReturnValue(playerController, worldLocation1)
  local p2 = UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPositionReturnValue(playerController, worldLocation2)
  local deltaVector = {
    x = p1.X - p2.X,
    y = p1.Y - p2.Y
  }
  return math.sqrt(deltaVector.x * deltaVector.x + deltaVector.y * deltaVector.y)
end
local _CheckShot = function(point_1, point_2, threshold)
  local weapon_diy_utils = require("client.slua.umg.WeaponDIY.weapon_diy_utils")
  local vector = {
    x = point_1.x - point_2.x,
    y = point_1.y - point_2.y
  }
  local length_1 = weapon_diy_utils:GetVectorLength(vector)
  if threshold > length_1 then
    return true
  else
    return false
  end
end
function Weapon_DIY_Model_System:TryCallOperatingCircle(x, y)
  local bMirror = false
  if OperateScheme == nil then
    return
  end
  if OperateScheme.detail.MirrorParam[1] == 1 then
    bMirror = true
  end
  for i = #OperateScheme.detail.DIYData, 1, -1 do
    local curSlotID = self:GetCurWeaponSlotID()
    local merTex = OperateScheme.detail.DIYData[i]
    if merTex.SlotID ~= curSlotID then
    else
      local decalScreenPosition = _GetDecalParamActorScreenLocation(merTex)
      local radius = _GetScreenRadius(merTex)
      if _CheckShot({x = x, y = y}, decalScreenPosition, radius) == true then
        local layerComponent = UIManager.GetUI(UIManager.UI_Config.weapon_diy_component_layer)
        if layerComponent == nil then
          return
        end
        if bMirror then
          self:CallOperatingCircleByLayerIndex(i)
          layerComponent:SelectLayer(i)
          return
        else
          local bLeft = self:_GetWeaponRotationState()
          if bLeft and merTex.DIYParam.Direction == weapon_macro.ENUM_DIY_PROJECT_DIRECTION.Y_ or bLeft == false and merTex.DIYParam.Direction == weapon_macro.ENUM_DIY_PROJECT_DIRECTION.Y then
          else
            self:CallOperatingCircleByLayerIndex(i)
            layerComponent:SelectLayer(i)
            return
          end
        end
      end
    end
  end
end
function Weapon_DIY_Model_System:SaveCurScheme()
  local WeaponDiyHandler = require("client.network.Protocol.WeaponDiyHandler")
  WeaponDiyHandler.UploadBinData(self.operateWeaponId, OperateScheme.detail, OperateScheme.schemeId)
end
function Weapon_DIY_Model_System:IsOpenMirror()
  if OperateScheme and OperateScheme.detail and OperateScheme.detail.MirrorParam[1] == 1 then
    return true
  else
    return false
  end
end
function Weapon_DIY_Model_System:IsWeaponPointToLeft()
  return self:_GetWeaponRotationState()
end
function Weapon_DIY_Model_System:NeedRotate(index)
  local bLeft = self:_GetWeaponRotationState()
  local merTex = OperateScheme.detail.DIYData[index]
  if bLeft and merTex.DIYParam.Direction == weapon_macro.ENUM_DIY_PROJECT_DIRECTION.Y_ or bLeft == false and merTex.DIYParam.Direction == weapon_macro.ENUM_DIY_PROJECT_DIRECTION.Y then
    return true
  else
    return false
  end
end
function Weapon_DIY_Model_System:SwitchWeaponRotate()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local showActor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if showActor then
    local rotator = showActor:K2_GetActorRotation()
    if math.abs(rotator.Yaw) > 90 then
      local rotation_left = FRotator(0, 0, 0)
      showActor:K2_SetActorRotation(rotation_left, false)
    else
      local rotation_right = FRotator(0, 180, 0)
      showActor:K2_SetActorRotation(rotation_right, false)
    end
  end
end
function Weapon_DIY_Model_System:ResetGunRotation()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local showActor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if showActor then
    if self:_GetWeaponRotationState() then
      local rotation = FRotator(0, 180, 0)
      showActor:K2_SetActorRotation(rotation, false)
    else
      local rotation = FRotator(0, 0, 0)
      showActor:K2_SetActorRotation(rotation, false)
    end
  end
end
function Weapon_DIY_Model_System:GetCurWeaponSlotID()
  local editComponent = UIManager.GetUI(UIManager.UI_Config.weapon_diy_edit_component)
  if editComponent == nil then
    return weapon_macro.ENUM_DIY_WEAPON_SLOT_TYPE.MasterGun
  else
    return editComponent:GetSlotID()
  end
end
function Weapon_DIY_Model_System:GetCurOperatingMeshComp()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local model = MallSystemWeaponModelHandler.GetGunModel()
  if model and model.WeaponAvatarComponent then
    local curSlotID = self:GetCurWeaponSlotID()
    return model.WeaponAvatarComponent:GetMeshCompbySlotID(curSlotID)
  end
  return nil
end
function Weapon_DIY_Model_System:GetCurFrontAndBack()
  local editComponent = UIManager.GetUI(UIManager.UI_Config.weapon_diy_edit_component)
  if editComponent == nil then
    return weapon_macro.ENUM_DIY_PROJECT_DIRECTION.Y, weapon_macro.ENUM_DIY_PROJECT_DIRECTION.Y_
  else
    return editComponent:GetDirection(), editComponent:GetDirection() + 1
  end
end
function Weapon_DIY_Model_System:GetCurDecalProjectionDirection()
  local frontDirection, backDirection = self:GetCurFrontAndBack()
  if frontDirection == weapon_macro.ENUM_DIY_PROJECT_DIRECTION.Z then
    return frontDirection
  end
  if OperateScheme and OperateScheme.detail.MirrorParam[1] == 0 and self:_GetWeaponRotationState() == false then
    return backDirection
  end
  return frontDirection
end
return Weapon_DIY_Model_System