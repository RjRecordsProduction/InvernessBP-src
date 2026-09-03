local Weapon_DIY_System = {
  DIAMOND_ID = 1109,
  UC_ID = 1006,
  DIAMOND_UC_RATE = 100,
  MAX_NEW_TIPS_STEP = 6,
  COM_MT_ID = 2602001,
  SP_MT_ID = 2602002,
  _WeaponData = nil,
  WeaponList = nil,
  _CurentWeaponData = nil,
  _CurWeaponID = nil,
  _Cur_Select_weaponItemIndex = nil,
  originWeaponDiyDetailData = {},
  diyPatternData = {},
  SavedSchemeId = 0,
  switch = false,
  createWeapon = nil,
  jumpType = nil,
  gmSwitch = false,
  consumePatternData = nil,
  gmAutoCorrectAngle = nil
}
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
Weapon_DIY_System.EditType = {
  Unknow = 0,
  hadPlan = 1,
  ExsitPlan = 2,
  EmptyPlan = 3
}
Weapon_DIY_System.CurEditType = Weapon_DIY_System.EditType.Unknow
Weapon_DIY_System.CurPlanID = 0
Weapon_DIY_System.CurMatParam = {
  0,
  0,
  0,
  0
}
Weapon_DIY_System.CurDIYData = {}
Weapon_DIY_System.CurMirrorParam = {1, 1}
Weapon_DIY_System.CurSlotMatParam = {
  0,
  0,
  0,
  0,
  0
}
Weapon_DIY_System.CurWeaponScrollInfo = {}
Weapon_DIY_System.CurSelectPlanIndex = 0
Weapon_DIY_System.CurSettleData = nil
local WeaponDiyNetHandler = require("client.network.Protocol.WeaponDiyHandler")
local weapon_diy_model_system = require("client.slua.logic.weapon_diy.logic_weapon_diy_model")
local weapon_macro = require("client.slua.umg.WeaponDIY.weapon_diy_macro")
local JUMPTYPE = {COLOR = 1, PATTERN = 2}
function Weapon_DIY_System.OnLogin(bRelogin)
  Weapon_DIY_System:GetDiyItemListReq()
  if bRelogin and Weapon_DIY_System._CurWeaponID and Weapon_DIY_System._CurWeaponID ~= 0 then
    Weapon_DIY_System:GetDiyItemSummaryDataReq(Weapon_DIY_System._CurWeaponID)
  end
end
function Weapon_DIY_System:Reset()
  self.diyPatternData = {}
  self.weaponData = nil
  self.basePattern = nil
  self.consumePatternData = nil
end
function Weapon_DIY_System:GetOpenState()
  return self.switch
end
function Weapon_DIY_System.DownloadDIY(from)
  local list = {}
  for i, v in pairs(CDataTable.GetTable("WeaponDIYList")) do
    table.insert(list, v.ID)
  end
  PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, list, from)
end
function Weapon_DIY_System.GetDIYDownloadState()
  local list = {}
  for i, v in pairs(CDataTable.GetTable("WeaponDIYList")) do
    table.insert(list, v.ID)
  end
  return PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, list)
end
function Weapon_DIY_System:EnterSystem(weapon_id, scheme_id, jumpType)
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPACK, {
    PufferConst.EODPackID.DIY
  })
  if state ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "Weapon_DIY_System:EnterSystem Not Download")
    local cfg = CDataTable.GetTableData("PakInfoTable", PufferConst.EODPackID.DIY)
    if cfg then
      local str = LocUtil.LocalizeResFormat(11436, cfg.PakName)
      ShowNotice(str)
    end
    return
  end
  if self.switch == false or LobbySystem.CheckOpen(BP_ENUM_SWITCH_WORK_SHOP) == false or LobbySystem.CheckOpen(BP_ENUM_DIY_SWITCH_ID) == false then
    ShowNotice(LocUtil.GetLocalizeResStr(40025))
    self.jumpType = nil
    return
  end
  if self.WeaponList == nil or self.WeaponList[1] == nil then
    self.jumpType = nil
    return
  end
  ClientSendBAReport(TLogEventDefine.WeaponDIYSystem, 0)
  if weapon_id and 0 < weapon_id then
    self._CurWeaponID = weapon_id
  else
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local LastEdit = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDiyLastEditWeapon)
    if LastEdit and LastEdit[1] and self.WeaponList then
      for i, v in pairs(self.WeaponList) do
        if tonumber(LastEdit[1]) == v.id then
          self._CurWeaponID = v.id
          break
        end
      end
    else
      self._CurWeaponID = self.WeaponList[1].id
    end
  end
  self.createWeapon = nil
  UIManager.ShowUI(UIManager.UI_Config.Weapon_Diy_Frame, weapon_id, scheme_id)
  local UIUtil = require("client.common.ui_util")
  local gameFrontendHUD = UIUtil.GetGameInstance():GetAssociatedFrontendHUD()
  Client.TPerforPlatDataReport(gameFrontendHUD, 571, "WeaponDIY")
end
function Weapon_DIY_System.JumpToVideo(id)
  Weapon_DIY_System:EnterSystem(id, nil)
end
function Weapon_DIY_System.JumpToS12KColor()
  Weapon_DIY_System.jumpType = JUMPTYPE.COLOR
  Weapon_DIY_System:EnterSystem(1104003199, nil)
end
function Weapon_DIY_System.JumpToS12KPattern()
  Weapon_DIY_System.jumpType = JUMPTYPE.PATTERN
  Weapon_DIY_System:EnterSystem(1104003199, nil)
end
function Weapon_DIY_System.JumpToS12K()
  Weapon_DIY_System:EnterSystem(1104003199, nil)
end
function Weapon_DIY_System.JumpToSCARL()
  Weapon_DIY_System:EnterSystem(1101003199, nil)
end
function Weapon_DIY_System:ShowModel(weapon_id)
  if self.createWeapon and weapon_id == self.createWeapon then
    log(bWriteLog and "have create")
    return
  end
  self._CurWeaponID = weapon_id
  weapon_diy_model_system:ShowWeapon(weapon_id)
  self.createWeapon = weapon_id
end
function Weapon_DIY_System:GetDIYPatternPath()
  return Client.ProjectSavedDir() .. "WeaponDiy/pattern"
end
function Weapon_DIY_System:GetSchemeData(weapon_id, plan_id)
  if self:IsPlanRecommend(plan_id) then
    local weapon_diy_rec_scheme = require("client.slua.logic.weapon_diy.weapon_diy_rec_scheme")
    return weapon_diy_rec_scheme[weapon_id]
  end
  if self.weaponData and self.weaponData[weapon_id] and self.weaponData[weapon_id].my_plan_table then
    local diyData = self.weaponData[weapon_id].my_plan_table[plan_id]
    if diyData and diyData.bin_data then
      local scheme = self:UnpackBinDataToLuaTable(diyData.bin_data)
      if scheme then
        return scheme
      end
    end
  end
  return nil
end
function Weapon_DIY_System:GetDiyItemListReq()
  log(bWriteLog and "Weapon_DIY_System:GetDiyItemListReq")
  WeaponDiyNetHandler.send_get_weapon_diy_weapon_list_req()
end
function Weapon_DIY_System:GetDiyItemListRsp(weapon_table)
  log_tree("GetDiyItemListRsp", weapon_table)
  self.switch = true
  self.WeaponList = {}
  local weaponData
  local strRegion = Client.GetPublishRegion()
  weaponData = CDataTable.GetTable("WeaponDIYList")
  if not weaponData then
    log_error("Weapon_DIY_System:GetDiyItemListRsp No table")
    return
  end
  for i, v in pairs(weaponData) do
    if weapon_table[v.ID] ~= nil then
      local item = {
        id = v.ID,
        sort_id = v.Sort
      }
      table.insert(self.WeaponList, item)
    end
  end
  table.sort(self.WeaponList, function(a, b)
    return a.sort_id < b.sort_id
  end)
end
function Weapon_DIY_System:GetDiyItemSummaryDataReq(weapon_id)
  log(bWriteLog and "Weapon_DIY_System:GetDiyItemSummaryDataReq")
  WeaponDiyNetHandler.send_get_weapon_diy_summary_data_req(weapon_id)
end
function Weapon_DIY_System:GetDiyMerchantWeaponDataRsp(weapon_id, recommend_plan_id, my_plan_table, my_cur_status)
  log_tree("Weapon_DIY_System:GetDiyItemSummaryDataRsp", my_plan_table)
  log_tree("Weapon_DIY_System:GetDiyItemSummaryDataRsp my_cur_status ", my_cur_status)
  if self.weaponData == nil then
    self.weaponData = {}
  end
  if self.weaponData[weapon_id] == nil then
    self.weaponData[weapon_id] = {}
  end
  self.weaponData[weapon_id].  self.weaponData[weapon_id].  self.weaponData[weapon_id].  self.weaponData[weapon_id].  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_SUMMARY_DATA, self.weaponData[weapon_id], weapon_id)
end
function Weapon_DIY_System:GetDiyItemDetailDataReq(weapon_id)
  log(bWriteLog and "Weapon_DIY_System:GetDiyItemDetailDataReq, id = " .. weapon_id)
  if self.weaponData == nil then
    log(bWriteLog and "Weapon_DIY_System:GetDiyItemDetailDataReq---no weapon data")
    self.weaponData = {}
  end
  if self.weaponData[weapon_id] == nil then
    log(bWriteLog and "Weapon_DIY_System:GetDiyItemDetailDataReq---no weapon data of " .. tostring(weapon_id))
    self.weaponData[weapon_id] = {}
  end
  if self.weaponData[weapon_id].diyCfg == nil then
    WeaponDiyNetHandler.send_get_weapon_diy_detail_data_req(weapon_id)
  else
    EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_DETAIL_DATA, self.weaponData[weapon_id].diyCfg)
  end
end
function Weapon_DIY_System:IsNeedUnlock(config)
  if config and config.is_other_get and tonumber(config.is_other_get) == 1 then
    return true
  elseif config and (config.res_id1 and tonumber(config.res_id1) > 0 and config.res_num1 and 0 < tonumber(config.res_num1) or config.res_id2 and 0 < tonumber(config.res_id2) and config.res_num2 and 0 < tonumber(config.res_num2)) then
    return true
  end
  return false
end
local _HandleDetailData = function(cfg_data, my_data, weapon_id)
  local colorData = {}
  local diy_color_table, diy_pattern_table
  local strRegion = Client.GetPublishRegion()
  diy_color_table = CDataTable.GetTable("WeaponDIYColor")
  diy_pattern_table = CDataTable.GetTable("WeaponDIYIcon")
  for i, v in pairs(diy_color_table) do
    if v.weapon_id == weapon_id then
      local bHave = false
      if my_data.my_color[v.color_id] ~= nil or not Weapon_DIY_System:IsNeedUnlock(v) then
        bHave = true
      end
      table.insert(colorData, {
        id = v.color_id,
        have = bHave,
        cfg = v
      })
    end
  end
  table.sort(colorData, function(a, b)
    return a.cfg.sort_id < b.cfg.sort_id
  end)
  local patternData = {}
  if Weapon_DIY_System.consumePatternData == nil then
    Weapon_DIY_System.consumePatternData = {}
    for i, v in pairs(diy_pattern_table) do
      local bHave = false
      local num = 0
      if my_data.my_pattern[v.icon_id] ~= nil and my_data.my_pattern[v.icon_id] ~= 0 then
        bHave = true
        num = my_data.my_pattern[v.icon_id] or 0
      end
      if not Weapon_DIY_System:IsNeedUnlock(v) then
      end
      table.insert(Weapon_DIY_System.consumePatternData, {
        id = v.icon_id,
        have = bHave,
        diy = false,
        bin_data = nil,
        base = false,
        consume = true,
        consumeNum = num,
        cfg = v
      })
    end
    table.sort(Weapon_DIY_System.consumePatternData, function(a, b)
      return a.cfg.item_id < b.cfg.item_id
    end)
  end
  local diyPattern = {}
  if Weapon_DIY_System.diyPatternData then
    for i, v in pairs(Weapon_DIY_System.diyPatternData) do
      local diyData = Weapon_DIY_System:UnpackBinDataToLuaTable(v)
      local data = {
        id = i,
        have = true,
        diy = true,
        bin_data = v,
        base = false,
        diyTextureList = diyData.DIYData[1].TextureList,
        consume = false,
        consumeNum = 0,
        cfg = v
      }
      if i ~= "nil" then
        table.insert(diyPattern, data)
      end
    end
  end
  table.sort(diyPattern, function(a, b)
    return tonumber(a.id) < tonumber(b.id)
  end)
  for i, v in ipairs(Weapon_DIY_System.consumePatternData) do
    table.insert(patternData, v)
  end
  for i, v in ipairs(diyPattern) do
    table.insert(patternData, v)
  end
  local diyCfg = {
    colorCfg = colorData,
    patternCfg = patternData,
    diyGlobalTable = cfg_data.diy_global_table,
    unlockLayerNum = my_data.my_weapon_layer or 0,
    diyWeaponLayerInfo = cfg_data.diy_weapon_layer_table
  }
  return diyCfg
end
function Weapon_DIY_System:GetDiyItemDetailDataRsp(weapon_id, diy_cfg_table, my_data)
  log(bWriteLog and "Weapon_DIY_System:GetDiyItemDetailDataRsp weapon_id:" .. tostring(weapon_id))
  log_tree("Weapon_DIY_System:GetDiyItemDetailDataRsp diy_cfg_table:", diy_cfg_table)
  log_tree("Weapon_DIY_System:GetDiyItemDetailDataRsp my_data:", my_data)
  self.originWeaponDiyDetailData[weapon_id] = {diy_cfg_table = diy_cfg_table, my_data = my_data}
  self.weaponData[weapon_id].diyCfg = _HandleDetailData(diy_cfg_table, my_data, weapon_id)
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_DETAIL_DATA, self.weaponData[weapon_id].diyCfg)
end
function Weapon_DIY_System:GetDiySchemeByWeaponIdReq(weapon_id)
  log(bWriteLog and "Weapon_DIY_System:GetDiySchemeByWeaponIdReq")
  if self.weaponData == nil then
    log(bWriteLog and "Weapon_DIY_System:GetDiySchemeByWeaponIdReq---no weapon data")
    self.weaponData = {}
  end
  if self.weaponData[weapon_id] == nil then
    log(bWriteLog and "Weapon_DIY_System:GetDiySchemeByWeaponIdReq---no weapon data of " .. tostring(weapon_id))
    self.weaponData[weapon_id] = {}
  end
  if self.weaponData[weapon_id].scheme == nil then
    WeaponDiyNetHandler.send_get_weapon_diy_custom_plan_data_req(weapon_id)
  else
    EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_SCHEME_DATA, self.weaponData[weapon_id].scheme)
  end
end
function Weapon_DIY_System:GetDiySchemeByWeaponIdRsp(err_code, weapon_id, scheme_data)
  log(bWriteLog and "Weapon_DIY_System:GetDiySchemeByWeaponIdRsp")
  log_tree("data--" .. tostring(weapon_id), scheme_data)
  self.weaponData[weapon_id].scheme = scheme_data
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_SCHEME_DATA, self.weaponData[weapon_id].scheme)
end
function Weapon_DIY_System:GetDiyPatternDataReq()
  log(bWriteLog and "Weapon_DIY_System:GetDiyPatternDataReq")
  if self.diyPatternData == nil or next(self.diyPatternData) == nil then
    WeaponDiyNetHandler.send_get_weapon_diy_custom_pattern_req()
  else
    EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_PATTERN_DATA, self.diyPatternData)
  end
end
function Weapon_DIY_System:GetDiyPatternDataRsp(custom_pattern)
  log_tree("Weapon_DIY_System:GetDiyPatternDataRsp weapon_diy_custom_pattern:", custom_pattern)
  if custom_pattern then
    self.diyPatternData = custom_pattern
  else
    self.diyPatternData = {}
  end
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_PATTERN_DATA, self.diyPatternData)
end
function Weapon_DIY_System:GetBasePatternDataReq()
  log(bWriteLog and "Weapon_DIY_System:GetBasePatternDataReq")
  if self.basePattern == nil then
    WeaponDiyNetHandler.send_get_base_pattern_and_color_req()
  else
    EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_BASE_PATTERN_DATA, self.basePattern)
  end
end
function Weapon_DIY_System:GetBasePatternDataRsp(base_cfg_table, my_data)
  log_tree("Weapon_DIY_System:GetBasePatternDataRsp base_cfg_table:", base_cfg_table)
  log_tree("Weapon_DIY_System:GetBasePatternDataRsp my_data:", my_data)
  local patternTable = CDataTable.GetTable("WeaponDIYBaseIcon")
  local colorTable = CDataTable.GetTable("WeaponDIYBaseColor")
  self.basePattern = {
    unlockLayerNum = my_data.my_custom_pattern_layer,
    layerInfo = base_cfg_table.custom_pattern_layer_table,
    patterns = {},
    colors = {}
  }
  for i, v in pairs(patternTable) do
    local data = {}
    for ii, vv in pairs(v) do
      data[ii] = vv
    end
    self.basePattern.patterns[i] = data
  end
  for i, v in pairs(colorTable) do
    local data = {}
    for ii, vv in pairs(v) do
      data[ii] = vv
    end
    self.basePattern.colors[i] = data
  end
  for i, v in pairs(self.basePattern.patterns) do
    if my_data.my_base_pattern[v.icon_id] ~= nil or v.res_num1 == 0 and v.res_num2 == 0 then
      v.have = true
    else
      v.have = false
    end
  end
  for i, v in pairs(self.basePattern.colors) do
    if my_data.my_base_color[v.color_id] ~= nil or v.res_num1 == 0 and v.res_num2 == 0 then
      v.have = true
    else
      v.have = false
    end
  end
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_BASE_PATTERN_DATA, self.basePattern)
end
function Weapon_DIY_System:SaveCustomPatternDataReq(weaponData, id)
  local bin_data = self:PackSchemeDataToBinData(weaponData)
  self.toSaveCustomPatternData = {id = id, bin_data = bin_data}
  if id == 0 then
    WeaponDiyNetHandler.send_save_weapon_diy_custom_pattern_data_req(bin_data)
  else
    WeaponDiyNetHandler.send_save_weapon_diy_custom_pattern_data_req(bin_data, id)
  end
end
function Weapon_DIY_System:SaveCustomPatternDataRsp(custom_pattern_id)
  log(bWriteLog and "SaveCustomPatternDataRsp successs " .. " id: " .. tostring(custom_pattern_id))
  if self.toSaveCustomPatternData == nil then
    log(bWriteLog and "Weapon_DIY_System:SaveCustomPatternDataRsp BinData miss")
    return
  end
  if self.toSaveCustomPatternData.id ~= 0 and self.toSaveCustomPatternData.id ~= custom_pattern_id then
    log(bWriteLog and "Weapon_DIY_System:SaveCustomPatternDataRsp id wrong")
    return
  end
  self.diyPatternData[custom_pattern_id] = self.toSaveCustomPatternData.bin_data
  self.toSaveCustomPatternData = nil
  for i, v in pairs(self.weaponData) do
    if v.diyCfg and v.diyCfg.patternCfg then
      local bHave = false
      for ii, vv in ipairs(v.diyCfg.patternCfg) do
        if vv.id == custom_pattern_id then
          bHave = true
          local diyData = self:UnpackBinDataToLuaTable(self.diyPatternData[custom_pattern_id])
          vv.diyTextureList = diyData.DIYData[1].TextureList
          break
        end
      end
      if bHave == false then
        local diyData = self:UnpackBinDataToLuaTable(self.diyPatternData[custom_pattern_id])
        table.insert(v.diyCfg.patternCfg, {
          id = custom_pattern_id,
          have = true,
          diy = true,
          bin_data = self.diyPatternData[custom_pattern_id],
          base = false,
          diyTextureList = diyData.DIYData[1].TextureList,
          consume = false,
          consumeNum = 0,
          cfg = nil
        })
      end
    end
  end
  if self.weaponData[self._CurWeaponID] then
    EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_DETAIL_DATA_CHANGED, self.weaponData[self._CurWeaponID].diyCfg, custom_pattern_id)
  end
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_CUSTOM_PATTERN_SAVED)
end
function Weapon_DIY_System:SendWeaponPatternLayerReq(weapon_id, layer_num)
  log(bWriteLog and "Weapon_DIY_System:SendWeaponPatternLayerReq" .. tostring(layer_num))
  WeaponDiyNetHandler.send_unlock_weapon_diy_weapon_layer_req(weapon_id, layer_num)
end
function Weapon_DIY_System:SendWeaponPatternLayerRsp(weapon_id, layer_num)
  log(bWriteLog and "Weapon_DIY_System:SendWeaponPatternLayerRsp layer_num:" .. tostring(layer_num))
  self.weaponData[weapon_id].diyCfg.unlockLayerNum = layer_num
  weapon_diy_model_system:GetOperatingScheme().havePattern = layer_num
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_WEAPON_LAYER_DATA, 0, weapon_id, layer_num)
end
function Weapon_DIY_System:SendDIYPatternLayerReq(layer_num)
  log(bWriteLog and "Weapon_DIY_System:SendDIYPatternLayerReq" .. tostring(layer_num))
  WeaponDiyNetHandler.send_unlock_weapon_diy_custom_pattern_layer_req(layer_num)
end
function Weapon_DIY_System:SendDIYPatternLayerRsp(layer_num)
  log(bWriteLog and "Weapon_DIY_System:SendDIYPatternLayerRsp layer_num:" .. tostring(layer_num))
  self.basePattern.unlockLayerNum = layer_num
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_PATTERN_LAYER_DATA, layer_num, self.basePattern)
end
function Weapon_DIY_System:DeletePatternReq(pattern_id)
  WeaponDiyNetHandler.send_delete_weapon_diy_custom_pattern_req(pattern_id)
end
function Weapon_DIY_System:DeletePatternRsp(pattern_id)
  self.diyPatternData[pattern_id] = nil
  for i, v in pairs(self.weaponData) do
    if v.diyCfg and v.diyCfg.patternCfg then
      for ii, vv in ipairs(v.diyCfg.patternCfg) do
        if vv.id == pattern_id then
          table.remove(v.diyCfg.patternCfg, ii)
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_DETAIL_DATA_CHANGED, self.weaponData[self._CurWeaponID].diyCfg)
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_PATTERN_DELETE, pattern_id)
end
function Weapon_DIY_System:BuyBasePatternOrColorReq(type, id, is_uc_fill)
  log(bWriteLog and "Weapon_DIY_System:BuyBasePatternOrColorReq type:" .. tostring(type) .. "id" .. tostring(id))
  WeaponDiyNetHandler.send_weapon_diy_unlock_base_req(type, id, is_uc_fill)
end
function Weapon_DIY_System:BuyBasePatternOrColorRsq(type, id)
  log(bWriteLog and "Weapon_DIY_System:BuyBasePatternOrColorRsq type:" .. tostring(type) .. " id:" .. tostring(id))
  if type == 1 then
    if self.basePattern and self.basePattern.patterns then
      for i, v in pairs(self.basePattern.patterns) do
        if v.icon_id == id then
          v.have = true
        end
      end
    end
  elseif type == 2 and self.basePattern and self.basePattern.colors then
    for i, v in pairs(self.basePattern.colors) do
      if v.color_id == id then
        v.have = true
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_BUY_BASE_PATTERN_MAT, type, id)
end
function Weapon_DIY_System:DeleteDiySchemeReq(weapon_id, plan_id, client_refund_price)
  log(bWriteLog and "Weapon_DIY_System:DeleteDiySchemeReq" .. tostring(weapon_id) .. tostring(plan_id))
  WeaponDiyNetHandler.send_delete_weapon_diy_custom_plan_req(weapon_id, plan_id, client_refund_price)
end
function Weapon_DIY_System:DeleteDiySchemeRsp(weapon_id, plan_id, client_refund_price)
  log(bWriteLog and "Weapon_DIY_System:DeleteDiySchemeRsp" .. tostring(weapon_id) .. tostring(plan_id))
  self.weaponData[weapon_id].my_plan_table[plan_id] = nil
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_DELETE_SCHEME, weapon_id, self.weaponData[weapon_id], plan_id, client_refund_price)
end
function Weapon_DIY_System:UseDiyCustomSchemeReq(weapon_id, plan_id)
  log(bWriteLog and "Weapon_DIY_System:UseDiyCustomScheme" .. tostring(weapon_id) .. tostring(plan_id))
  WeaponDiyNetHandler.send_use_weapon_diy_custom_plan_req(weapon_id, plan_id)
end
function Weapon_DIY_System:UseDiyCustomSchemeRsp(weapon_id, plan_id)
  local wpData
  if self.weaponData then
    if self.weaponData[weapon_id] then
      self.weaponData[weapon_id].my_cur_status.cur_use_plan = plan_id
    end
    wpData = self.weaponData[weapon_id]
  end
  self.SavedSchemeId = 0
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_USE_SCHEME, weapon_id, plan_id, wpData)
end
function Weapon_DIY_System:UnlockSchemeNumReq(weapon_id)
  log(bWriteLog and "Weapon_DIY_System:UnlockSchemeNumReq" .. tostring(weapon_id))
  WeaponDiyNetHandler.send_weapon_diy_unlock_plan_req(weapon_id)
end
function Weapon_DIY_System:UnlockSchemeNumRsq(weapon_id, plan_count)
  log(bWriteLog and "Weapon_DIY_System:UnlockSchemeNumRsq plan_count:" .. tostring(plan_count))
  self.weaponData[weapon_id].my_cur_status.  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_UNLOCK_SCHEME_NUM, 0, weapon_id, self.weaponData[weapon_id])
end
function Weapon_DIY_System:on_buy_weapon_diy_custom_plan_rsp(weapon_id, plan_id, my_data)
  log_tree("Weapon_DIY_System:on_buy_weapon_diy_custom_plan_rsp " .. ",plan_id:" .. tostring(plan_id) .. ", weapon_id\239\188\154" .. tostring(weapon_id) .. ", my_data:", my_data)
  if Weapon_DIY_System.CurSettleData then
    Weapon_DIY_System.CurSettleData.SchemeId = plan_id
    local scheme = weapon_diy_model_system:GetOperatingSchemeDetail()
    local arrayItemList = {}
    table.insert(arrayItemList, {
      res_id = weapon_id,
      count = 1,
      diy_info = {
        weapon_id = weapon_id,
        plan_id = plan_id,
              }
    })
    local fCallback = function()
      local ScriptHelperClient = import("ScriptHelperClient")
      local curStatus = ScriptHelperClient.GetGameStatus(slua_GameFrontendHUD)
      if curStatus == GameStatus.Login then
        return
      end
      local cfg = {
        sceneType = ShareSceneType.DIYGet,
        isTransparency = true,
        isOld = true,
        otherTLog = TLogEventDefine.SocialPhotoShare,
        share_type = ShareBtnTLogShareTypeDefine.GunDIYShare,
        hideImage = true,
        campaign = "weapon_diy"
      }
      local Util = require("client.slua_ui_framework.util")
      Util.ShowShare(cfg, UIManager.UI_Config.weapon_diy_share, true)
      local ShareMgr = require("client.logic.share.share_logic")
      ShareMgr.ShareBtnReq(1, ShareBtnTLogShareTypeDefine.GunDIYShare, nil, nil)
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    local tExtendData = {fCloseCallback = fCallback}
    Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList, false, true, tExtendData)
    EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_BUY_PLANE_SUC, weapon_id, plan_id, scheme)
  end
end
function Weapon_DIY_System:OnSaveSchemeRsp(weapon_id, plan_id)
  ShowNotice(LocUtil.GetLocalizeResStr(9717))
  self.SavedSchemeId = plan_id
  self.CurPlanID = plan_id
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_SaveSchemeSuccess, weapon_id, plan_id)
end
function Weapon_DIY_System:OnWeaponDiyMaterialNotify(name, weapon_id, id, new_count, item_id)
  log(bWriteLog and "OnWeaponDiyMaterialNotify:" .. tostring(name) .. ",weapon_id:" .. tostring(weapon_id) .. ",id:" .. tostring(id) .. ",new_count:" .. tostring(new_count) .. ",item_id:" .. tostring(item_id))
  local bExist = false
  local isBase = false
  local tmpCfg
  if name == "pattern" or name == "base_pattern" then
    if name == "base_pattern" then
      isBase = true
    else
      isBase = false
    end
    if not isBase then
      if self.consumePatternData then
        bExist = false
        tmpCfg = self:GetIconByID(id, isBase)
        for i, v in ipairs(self.consumePatternData) do
          if v.id == id then
            bExist = true
            v.consumeNum = new_count
            v.have = 0 < new_count
            break
          end
        end
        if not bExist then
          table.insert(self.consumePatternData, {
            id = id,
            have = 0 < new_count,
            diy = false,
            bin_data = nil,
            base = isBase,
            consume = true,
            consumeNum = new_count,
            cfg = tmpCfg
          })
        end
      end
    elseif self.basePattern and self.basePattern.patterns and self.basePattern.patterns[tostring(item_id)] then
      self.basePattern.patterns[tostring(item_id)].have = true
    end
    if self.weaponData and self._CurWeaponID and self.weaponData[self._CurWeaponID] and not isBase then
      EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_DETAIL_DATA_CHANGED, self.weaponData[self._CurWeaponID].diyCfg)
    end
  elseif name == "color" or name == "base_color" then
    if name == "base_color" then
      isBase = true
    else
      isBase = false
    end
    if not isBase then
      if self.weaponData and self.weaponData[weapon_id] and self.weaponData[weapon_id].diyCfg and self.weaponData[weapon_id].diyCfg.colorCfg then
        bExist = false
        tmpCfg = self:GetColorByID(id, isBase)
        for i, v in ipairs(self.weaponData[weapon_id].diyCfg.colorCfg) do
          if v.id == id then
            bExist = true
            v.have = 0 < new_count or not self:IsNeedUnlock(tmpCfg)
            break
          end
        end
        if not bExist then
          table.insert(self.weaponData[weapon_id].diyCfg.colorCfg, {
            id = id,
            have = 0 < new_count or not self:IsNeedUnlock(tmpCfg),
            cfg = self:GetColorByID(id, isBase)
          })
        end
      end
    elseif self.basePattern and self.basePattern.colors and self.basePattern.colors[tostring(item_id)] then
      self.basePattern.colors[tostring(item_id)].have = true
    end
    if self.weaponData and self._CurWeaponID and self.weaponData[self._CurWeaponID] and not isBase then
      EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_DETAIL_DATA_CHANGED, self.weaponData[self._CurWeaponID].diyCfg)
    end
  end
  local WeaponDiyExchangeSystem = require("client.slua.logic.weapon_diy.logic_weapon_diy_exchange")
  WeaponDiyExchangeSystem.materials_count[item_id] = new_count
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_MATERIAL_COUNT)
end
local MAX_OFFSET = 10000
local MAX_ROTATION = 1000
local MAX_SCALE = 200
local MAX_CLIP = 100
local OFFSET_MULTI = 20
local SCALE_MULTI = 10
local ROTATION_MULTI = 1000
local CLIP_MULTI = 100
local _IsOdd = function(number)
  if math.fmod(number, 2) == 0 then
    return false
  else
    return true
  end
end
local _ConvertToOdd = function(number)
  if math.fmod(number, 2) == 0 then
    return number + 1
  else
    return number
  end
end
local _ConvertToEven = function(number)
  if math.fmod(number, 2) == 0 then
    return number
  else
    return number + 1
  end
end
local _PrePackDIYParam = function(_DIYParam, _bUseLimit)
  local DIYParam = {
    ColorID = 0,
    Rotation = 0.0,
    Opacity = 1,
    ScaleX = 0.0,
    ScaleY = 0.0,
    OffSetX = 0.0,
    OffSetY = 0.0
  }
  DIYParam.ColorID = _DIYParam.ColorID
  local rotation = _DIYParam.Rotation
  if rotation < 0.0 then
    rotation = rotation + 1.0
  end
  rotation = math.abs(rotation) + 1.0E-4
  DIYParam.Rotation = rotation * ROTATION_MULTI
  local sx = math.floor(math.abs(_DIYParam.ScaleX * SCALE_MULTI))
  if sx > MAX_SCALE and _bUseLimit then
    sx = MAX_SCALE
  end
  DIYParam.ScaleX = sx
  local sy = math.floor(math.abs(_DIYParam.ScaleY * SCALE_MULTI))
  if sy > MAX_SCALE and _bUseLimit then
    sy = MAX_SCALE
  end
  DIYParam.ScaleY = sy
  local ox = math.floor(math.abs(_DIYParam.OffSetX * OFFSET_MULTI))
  if ox > MAX_OFFSET and _bUseLimit then
    ox = MAX_OFFSET
  end
  if 0 < _DIYParam.OffSetX then
    ox = _ConvertToOdd(ox)
  elseif 0 > _DIYParam.OffSetX then
    ox = _ConvertToEven(ox)
  end
  DIYParam.OffSetX = ox
  local oy = math.floor(math.abs(_DIYParam.OffSetY * OFFSET_MULTI))
  if oy > MAX_OFFSET and _bUseLimit then
    oy = MAX_OFFSET
  end
  if 0 < _DIYParam.OffSetY then
    oy = _ConvertToOdd(oy)
  elseif 0 > _DIYParam.OffSetY then
    oy = _ConvertToEven(oy)
  end
  DIYParam.OffSetY = oy
  DIYParam.UClipX = _DIYParam.UClipX or 0.0
  DIYParam.UClipX = math.floor(DIYParam.UClipX * CLIP_MULTI)
  DIYParam.UClipY = _DIYParam.UClipY or 1.0
  DIYParam.UClipY = math.floor(DIYParam.UClipY * CLIP_MULTI)
  DIYParam.VClipX = _DIYParam.VClipX or 0.0
  DIYParam.VClipX = math.floor(DIYParam.VClipX * CLIP_MULTI)
  DIYParam.VClipY = _DIYParam.VClipY or 1.0
  DIYParam.VClipY = math.floor(DIYParam.VClipY * CLIP_MULTI)
  DIYParam.Direction = _DIYParam.Direction
  return DIYParam
end
function Weapon_DIY_System:PackSchemeDataToBinData(_scheme, _bUseLimit)
  local bUseLimit = true
  if _bUseLimit ~= nil then
    bUseLimit = _bUseLimit
  end
  local TableUtil = require("common.table_util")
  local scheme = TableUtil.DeepCloneTable(_scheme)
  if scheme.DIYData then
    for i, v in ipairs(scheme.DIYData) do
      if v.TextureList and v.TextureList[1] then
        for ii, vv in ipairs(v.TextureList) do
          local diyParam = {
            ColorID = vv.DIYParam.ColorID,
            Rotation = vv.DIYParam.Rotation,
            Opacity = vv.DIYParam.Opacity,
            ScaleX = vv.DIYParam.ScaleX,
            ScaleY = vv.DIYParam.ScaleY,
            OffSetX = vv.DIYParam.OffSetX,
            OffSetY = vv.DIYParam.OffSetY,
            UClipX = vv.DIYParam.UClipX,
            UClipY = vv.DIYParam.UClipY,
            VClipX = vv.DIYParam.VClipX,
            VClipY = vv.DIYParam.VClipY,
            Direction = vv.DIYParam.Direction or weapon_macro.ENUM_DIY_PROJECT_DIRECTION.Y
          }
          vv.DIYParam = _PrePackDIYParam(diyParam, bUseLimit)
        end
        v.TexPathID = 1001
      end
      v.DIYParam = _PrePackDIYParam(v.DIYParam, bUseLimit)
    end
  end
  return DIYLua.WeaponDataToBinData(scheme)
end
local _AfterPackDIYParam = function(_DIYParam)
  local DIYParam = {
    ColorID = 0,
    Rotation = 0.0,
    Opacity = 1,
    ScaleX = 0.0,
    ScaleY = 0.0,
    OffSetX = 0.0,
    OffSetY = 0.0,
    UClipX = 0.0,
    UClipY = 1.0,
    VClipX = 0.0,
    VClipY = 1.0
  }
  DIYParam.ColorID = _DIYParam.ColorID
  DIYParam.Rotation = _DIYParam.Rotation / ROTATION_MULTI
  DIYParam.ScaleX = _DIYParam.ScaleX / SCALE_MULTI
  DIYParam.ScaleY = _DIYParam.ScaleY / SCALE_MULTI
  if _IsOdd(_DIYParam.OffSetX) then
    DIYParam.OffSetX = _DIYParam.OffSetX / OFFSET_MULTI
  else
    DIYParam.OffSetX = _DIYParam.OffSetX / OFFSET_MULTI * -1
  end
  if _IsOdd(_DIYParam.OffSetY) then
    DIYParam.OffSetY = _DIYParam.OffSetY / OFFSET_MULTI
  else
    DIYParam.OffSetY = _DIYParam.OffSetY / OFFSET_MULTI * -1
  end
  if _DIYParam.UClipX and _DIYParam.UClipY and _DIYParam.VClipX and _DIYParam.VClipY then
    DIYParam.UClipX = _DIYParam.UClipX / CLIP_MULTI
    DIYParam.UClipY = _DIYParam.UClipY / CLIP_MULTI
    DIYParam.VClipX = _DIYParam.VClipX / CLIP_MULTI
    DIYParam.VClipY = _DIYParam.VClipY / CLIP_MULTI
  end
  DIYParam.Direction = _DIYParam.Direction or weapon_macro.ENUM_DIY_PROJECT_DIRECTION.Y
  return DIYParam
end
local _Convert180DataToNewData = function(scheme)
  if scheme.MirrorParam and scheme.MirrorParam[1] == 0 then
    for i, v in ipairs(scheme.DIYData) do
      if not _IsOdd(v.DIYParam.Rotation) then
        v.DIYParam.Rotation = v.DIYParam.Rotation * -1 + ROTATION_MULTI
        v.DIYParam.Direction = weapon_macro.ENUM_DIY_PROJECT_DIRECTION.Y_
      else
        v.DIYParam.Direction = weapon_macro.ENUM_DIY_PROJECT_DIRECTION.Y
      end
    end
  end
end
function Weapon_DIY_System:UnpackBinDataToLuaTable(binData)
  local scheme = DIYLua.UnPackWeaponDataTable(binData)
  if scheme.version == 18 then
    _Convert180DataToNewData(scheme)
  end
  if scheme.DIYData then
    for i, v in ipairs(scheme.DIYData) do
      if v.TextureList then
        for ii, vv in ipairs(v.TextureList) do
          vv.DIYParam = _AfterPackDIYParam(vv.DIYParam)
        end
      end
      v.DIYParam = _AfterPackDIYParam(v.DIYParam)
      if not v.SlotID then
        v.SlotID = weapon_macro.ENUM_DIY_WEAPON_SLOT_TYPE.MasterGun
      end
    end
  end
  return scheme
end
function Weapon_DIY_System:GetWeaponDiyCfg(weapon_id)
  local id = weapon_id or self._CurWeaponID
  if self.weaponData and self.weaponData[id] and self.weaponData[id].diyCfg then
    return self.weaponData[id].diyCfg
  else
    return nil
  end
end
function Weapon_DIY_System:GetBaseColorOrIconData(type, id)
  if type == 1 then
    if self.basePattern and self.basePattern.patterns then
      for i, v in pairs(self.basePattern.patterns) do
        if v.icon_id == id then
          return v
        end
      end
    end
  elseif type == 2 and self.basePattern and self.basePattern.colors then
    for i, v in pairs(self.basePattern.colors) do
      if v.color_id == id then
        return v
      end
    end
  end
  return nil
end
function Weapon_DIY_System:GetColorByItemID(item_id)
  if not item_id or item_id == 0 then
    return nil
  end
  local WeaponDIYBaseColor = CDataTable.GetTableData("WeaponDIYBaseColor", item_id)
  if WeaponDIYBaseColor then
    return WeaponDIYBaseColor
  end
  local WeaponDIYColor
  WeaponDIYColor = CDataTable.GetTableData("WeaponDIYColor", item_id)
  return WeaponDIYColor
end
function Weapon_DIY_System:GetColorByID(color_id, isBase, weaponID)
  if not color_id or color_id == 0 then
    return nil
  end
  weaponID = weaponID or self._CurWeaponID
  local WeaponDIYBaseColor = CDataTable.GetTable("WeaponDIYBaseColor")
  if isBase then
    for _, v in pairs(WeaponDIYBaseColor) do
      if v.color_id and v.color_id == color_id then
        return v
      end
    end
  else
    local WeaponDIYColor = CDataTable.GetTable("WeaponDIYColor")
    for _, v in pairs(WeaponDIYColor) do
      if v.color_id and v.color_id == color_id and weaponID and weaponID == v.weapon_id then
        return v
      end
    end
    for _, v in pairs(WeaponDIYBaseColor) do
      if v.color_id and v.color_id == color_id then
        return v
      end
    end
  end
  return nil
end
function Weapon_DIY_System:GetIconByItemID(item_id)
  if not item_id or item_id == 0 then
    return nil
  end
  local WeaponDIYBaseIcon = CDataTable.GetTableData("WeaponDIYBaseIcon", item_id)
  if WeaponDIYBaseIcon then
    return WeaponDIYBaseIcon, true
  end
  local WeaponDIYIcon = CDataTable.GetTableData("WeaponDIYIcon", item_id)
  if WeaponDIYIcon then
    return WeaponDIYIcon, false
  end
  return nil, false
end
function Weapon_DIY_System:GetIconByID(icon_id, isBase, weaponID)
  if not icon_id or icon_id == 0 then
    return nil
  end
  local WeaponDIYBaseIcon = CDataTable.GetTable("WeaponDIYBaseIcon")
  if isBase then
    for _, v in pairs(WeaponDIYBaseIcon) do
      if v.icon_id and v.icon_id == icon_id then
        return v
      end
    end
  else
    local WeaponDIYIcon = CDataTable.GetTable("WeaponDIYIcon")
    for _, v in pairs(WeaponDIYIcon) do
      if v.icon_id and v.icon_id == icon_id then
        return v
      end
    end
    for _, v in pairs(WeaponDIYBaseIcon) do
      if v.icon_id and v.icon_id == icon_id then
        return v
      end
    end
  end
  return nil
end
function Weapon_DIY_System:GetDiyIconNum(item_id)
  local iconCfg, isBase = self:GetIconByItemID(item_id)
  if iconCfg then
    if isBase then
      local baseData = self:GetBaseColorOrIconData(1, iconCfg.icon_id)
      if baseData and baseData.have then
        return 1, iconCfg
      end
    elseif iconCfg.weapon_id then
      local weaponData = self:GetWeaponDiyCfg(iconCfg.weapon_id)
      if weaponData and weaponData.patternCfg then
        for i, v in ipairs(weaponData.patternCfg) do
          if v.id == iconCfg.icon_id then
            return v.consumeNum, iconCfg
          end
        end
      end
    end
  end
  return 0, iconCfg
end
function Weapon_DIY_System:IsIconUnlock(item_id)
  local iconCfg, isBase = self:GetIconByItemID(item_id)
  if iconCfg then
    if isBase then
      local baseData = self:GetBaseColorOrIconData(1, iconCfg.icon_id)
      return baseData and baseData.have, iconCfg
    elseif iconCfg.weapon_id then
      local weaponData = self:GetWeaponDiyCfg(iconCfg.weapon_id)
      if weaponData and weaponData.patternCfg then
        for i, v in ipairs(weaponData.patternCfg) do
          if v.id == iconCfg.icon_id then
            return v.have, iconCfg
          end
        end
      end
    end
  end
  return false, iconCfg
end
function Weapon_DIY_System:IsColorUnlock(item_id)
  local colorCfg, isBase = self:GetColorByItemID(item_id)
  if colorCfg then
    if isBase then
      local baseData = self:GetBaseColorOrIconData(1, colorCfg.color_id)
      return baseData and baseData.have, colorCfg
    elseif colorCfg.weapon_id then
      local weaponData = self:GetWeaponDiyCfg(colorCfg.weapon_id)
      if weaponData and weaponData.colorCfg then
        for i, v in ipairs(weaponData.colorCfg) do
          if v.id == colorCfg.color_id then
            return v.have, colorCfg
          end
        end
      end
    end
  end
  return false, colorCfg
end
function Weapon_DIY_System:IsColorIDUnlock(color_id, isBase, weaponID)
  local colorCfg = self:GetColorByID(color_id, isBase, weaponID)
  if colorCfg then
    if isBase then
      local baseData = self:GetBaseColorOrIconData(2, color_id)
      return baseData and baseData.have, colorCfg
    elseif colorCfg.weapon_id then
      local weaponData = self:GetWeaponDiyCfg(colorCfg.weapon_id)
      if weaponData and weaponData.colorCfg then
        for i, v in ipairs(weaponData.colorCfg) do
          if v.id == color_id then
            return v.have, colorCfg
          end
        end
      end
    end
  end
  return false, colorCfg
end
function Weapon_DIY_System:IsIconIDUnlock(icon_id, isBase, weaponID)
  local iconCfg = self:GetIconByID(icon_id, isBase, weaponID)
  if iconCfg then
    if isBase then
      local baseData = self:GetBaseColorOrIconData(1, icon_id)
      local num = 0
      if baseData and baseData.have then
        num = 1
      end
      return num, iconCfg
    elseif self.consumePatternData then
      for i, v in ipairs(self.consumePatternData) do
        if v.id == icon_id then
          return v.consumeNum, iconCfg
        end
      end
    end
  end
  return 0, iconCfg
end
function Weapon_DIY_System:DisplayColorByItemTabID(item_id)
  local colorCfg = self:GetColorByItemID(item_id)
  if colorCfg and colorCfg.color_id then
    local MatParam = {}
    for i = 1, 4 do
      MatParam[i] = colorCfg.color_id
    end
    local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
    MallSystemWeaponModelHandler.ChangeGunDiyMatList(MatParam)
  end
end
function Weapon_DIY_System:GetCostDiamondNumByItemID(item_id, num)
  if not item_id or item_id == 0 then
    return 0
  end
  num = num or 0
  local itemCfg = CDataTable.GetTableData("AutoBuyTable", item_id)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    itemCfg = CDataTable.GetTableData("AutoBuyTable_JK", item_id)
  else
    itemCfg = CDataTable.GetTableData("AutoBuyTable", item_id)
  end
  if itemCfg and itemCfg.CurrencyType == Weapon_DIY_System.UC_ID then
    local cNum = itemCfg.CurrencyNum or 0
    return math.ceil(cNum * num)
  end
  return 0
end
function Weapon_DIY_System:ParaTableCfg(cost_table, cfg, is_use)
  if not cfg then
    return cost_table, false, false
  end
  cost_table = cost_table or {}
  local bEnoughMaterial = false
  local bFree = true
  local itemData
  local num = 0
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  if is_use then
    if cfg.res_id_by_use1 and 0 < tonumber(cfg.res_id_by_use1) and cfg.res_num_by_use1 and 0 < tonumber(cfg.res_num_by_use1) then
      cost_table[cfg.res_id_by_use1] = cost_table[cfg.res_id_by_use1] or 0
      cost_table[cfg.res_id_by_use1] = cost_table[cfg.res_id_by_use1] + cfg.res_num_by_use1
      itemData = wardrobe_data:GetHallDepotItemDataByResID(cfg.res_id_by_use1)
      num = itemData and itemData.count or 0
      if num >= tonumber(cost_table[cfg.res_id_by_use1]) then
        bEnoughMaterial = true
      end
      bFree = false
    end
    if cfg.res_id_by_use2 and 0 < tonumber(cfg.res_id_by_use2) and cfg.res_num_by_use2 and 0 < tonumber(cfg.res_num_by_use2) then
      cost_table[cfg.res_id_by_use2] = cost_table[cfg.res_id_by_use2] or 0
      cost_table[cfg.res_id_by_use2] = cost_table[cfg.res_id_by_use2] + cfg.res_num_by_use2
      itemData = wardrobe_data:GetHallDepotItemDataByResID(cfg.res_id_by_use2)
      num = itemData and itemData.count or 0
      if num >= tonumber(cost_table[cfg.res_id_by_use2]) then
        bEnoughMaterial = true
      end
      bFree = false
    end
  else
    if cfg.res_id1 and 0 < tonumber(cfg.res_id1) and cfg.res_num1 and 0 < tonumber(cfg.res_num1) then
      cost_table[cfg.res_id1] = cost_table[cfg.res_id1] or 0
      cost_table[cfg.res_id1] = cost_table[cfg.res_id1] + cfg.res_num1
      itemData = wardrobe_data:GetHallDepotItemDataByResID(cfg.res_id1)
      num = itemData and itemData.count or 0
      if num >= tonumber(cost_table[cfg.res_id1]) then
        bEnoughMaterial = true
      end
      bFree = false
    end
    if cfg.res_id2 and 0 < tonumber(cfg.res_id2) and cfg.res_id2 and 0 < tonumber(cfg.res_num2) then
      cost_table[cfg.res_id2] = cost_table[cfg.res_id2] or 0
      cost_table[cfg.res_id2] = cost_table[cfg.res_id2] + cfg.res_num2
      itemData = wardrobe_data:GetHallDepotItemDataByResID(cfg.res_id2)
      num = itemData and itemData.count or 0
      if num >= tonumber(cost_table[cfg.res_id2]) then
        bEnoughMaterial = true
      end
      bFree = false
    end
  end
  return cost_table, bEnoughMaterial, bFree
end
function Weapon_DIY_System:GetTotalPriceInfo(CurSettleData, weaponID, AutoCostUC)
  if not (CurSettleData and CurSettleData.MatParam and CurSettleData.IconParam) or not CurSettleData.BaseIconParam then
    return
  end
  local ColorModifyCost = {}
  local IconModifyCost = {}
  local TotalCost = {}
  local BoxList = {}
  local TotalList = {}
  local TotalColor = {}
  local TotalIcon = {}
  local count = 0
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  if weaponID and CDataTable.GetTableData("Item", weaponID) then
    local weaponData = wardrobe_data:GetHallDepotItemDataByResID(weaponID)
    count = weaponData and weaponData.count or 0
    if count <= 0 then
      table.insert(BoxList, {id = weaponID, type = 0})
    end
  end
  local have, num, cfg, IsUnlock, IsEnough, bFreeUse, bFreeUnlock
  local ExistColor = {}
  for i, v in pairs(CurSettleData.MatParam) do
    have, cfg = self:IsColorIDUnlock(v, false, weaponID)
    if cfg then
      ColorModifyCost = self:ParaTableCfg(ColorModifyCost, cfg, true)
      TotalColor = self:ParaTableCfg(TotalColor, cfg, true)
      TotalCost, IsEnough, bFreeUse = self:ParaTableCfg(TotalCost, cfg, true)
      IsUnlock = true
      if not ExistColor[v] and not have then
        TotalColor = self:ParaTableCfg(TotalColor, cfg)
        TotalCost, IsEnough, bFreeUnlock = self:ParaTableCfg(TotalCost, cfg)
        if not IsEnough then
          if AutoCostUC and AutoCostUC == 1 then
            if bFreeUse and bFreeUnlock then
              table.insert(BoxList, {id = v, type = 4})
            end
          else
            table.insert(BoxList, {id = v, type = 2})
          end
        end
        IsUnlock = false
      end
      ExistColor[v] = 1
      table.insert(TotalList, {
        id = v,
        type = 2,
        index = i,
        isBox = tonumber(cfg.is_other_get),
              })
    end
  end
  local ExistBaseIcon = {}
  for i, v in pairs(CurSettleData.BaseIconParam) do
    num, cfg = self:IsIconIDUnlock(v, true, weaponID)
    if cfg then
      IconModifyCost = self:ParaTableCfg(IconModifyCost, cfg, true)
      TotalIcon = self:ParaTableCfg(TotalIcon, cfg, true)
      TotalCost, IsEnough, bFreeUse = self:ParaTableCfg(TotalCost, cfg, true)
      IsUnlock = true
      if not ExistBaseIcon[v] and num <= 0 then
        TotalIcon = self:ParaTableCfg(TotalIcon, cfg)
        IsEnough = false
        TotalCost, IsEnough, bFreeUnlock = self:ParaTableCfg(TotalCost, cfg)
        IsUnlock = false
        if not IsEnough then
          if AutoCostUC and AutoCostUC == 1 then
            if bFreeUse and bFreeUnlock then
              table.insert(BoxList, {id = v, type = 4})
            end
          else
            table.insert(BoxList, {id = v, type = 3})
          end
        end
      end
      ExistBaseIcon[v] = 1
      table.insert(TotalList, {
        id = v,
        type = 3,
        index = 0,
        isBox = tonumber(cfg.is_other_get),
              })
    end
  end
  local CostIcon = {}
  for i, v in pairs(CurSettleData.IconParam) do
    num, cfg = self:IsIconIDUnlock(v, false, weaponID)
    if cfg then
      IconModifyCost = self:ParaTableCfg(IconModifyCost, cfg, true)
      TotalIcon = self:ParaTableCfg(TotalIcon, cfg, true)
      TotalCost, IsEnough, bFreeUse = self:ParaTableCfg(TotalCost, cfg, true)
      CostIcon[v] = CostIcon[v] or 0
      IsUnlock = true
      if num < CostIcon[v] + 1 then
        TotalIcon = self:ParaTableCfg(TotalIcon, cfg)
        IsEnough = false
        TotalCost, IsEnough, bFreeUnlock = self:ParaTableCfg(TotalCost, cfg)
        IsUnlock = false
        if not IsEnough then
          table.insert(BoxList, {id = v, type = 4})
        end
      else
        CostIcon[v] = CostIcon[v] + 1
      end
      table.insert(TotalList, {
        id = v,
        type = 4,
        index = 0,
        isBox = tonumber(cfg.is_other_get),
              })
    end
  end
  for i, v in pairs(TotalCost) do
    local weaponData = wardrobe_data:GetHallDepotItemDataByResID(i)
    count = weaponData and weaponData.count or 0
    if v > count and (i == Weapon_DIY_System.SP_MT_ID or AutoCostUC ~= 1) then
      table.insert(BoxList, {id = i, type = 0})
    end
  end
  return ColorModifyCost, IconModifyCost, TotalCost, BoxList, TotalList, TotalColor, TotalIcon
end
function Weapon_DIY_System:GetWeaponCfg(weapon_id)
  local weaponData
  weaponData = CDataTable.GetTableData("WeaponDIYList", weapon_id)
  return weaponData
end
function Weapon_DIY_System:GetWeaponPartInfo(weapon_id)
  if self.WeaponPartInfo == nil then
    self.WeaponPartInfo = {}
  end
  if self.WeaponPartInfo[weapon_id] then
    return self.WeaponPartInfo[weapon_id]
  else
    local weaponSumData = self:GetWeaponCfg(weapon_id)
    if weaponSumData then
      self.WeaponPartInfo[weapon_id] = {}
      for i = 0, 4 do
        if weaponSumData["part" .. tostring(i)] and weaponSumData["part" .. tostring(i)] ~= "" then
          local partData = {}
          partData.name = weaponSumData["part" .. tostring(i)]
          partData.icon = weaponSumData["icon" .. tostring(i)]
          partData.iconSelect = weaponSumData["icon_select" .. tostring(i)]
          partData.slotID = weaponSumData["slotType" .. tostring(i)]
          partData.direction = weaponSumData["direction" .. tostring(i)]
          partData.banDecal = weaponSumData["banDecal" .. tostring(i)] and weaponSumData["banDecal" .. tostring(i)] == 1 or false
          table.insert(self.WeaponPartInfo[weapon_id], partData)
        end
      end
    end
    return self.WeaponPartInfo[weapon_id]
  end
end
function Weapon_DIY_System:GetCurWeaponPartSocketsID(weapon_id)
  local partInfo = self:GetWeaponPartInfo(weapon_id)
  local existParts = {}
  if partInfo then
    for i, v in pairs(partInfo) do
      if v.slotID ~= weapon_macro.ENUM_DIY_WEAPON_SLOT_TYPE.MasterGun then
        existParts[v.slotID] = v.slotID
      end
    end
  end
  return existParts
end
function Weapon_DIY_System:GetDiyProtoInfo(type)
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  local title = long_txt_manager:GetDIYAgreementTitle()
  local content = long_txt_manager:GetDIYAgreementContent()
  local version = long_txt_manager:GetDIYAgreementVersion()
  local btnOk = ""
  local btnCancel = ""
  local extraTips = ""
  if type == 4 then
    btnOk = DataMgr.GetMsgByID(301346)
    btnCancel = DataMgr.GetMsgByID(4111)
    extraTips = LocUtil.GetLocalizeResStr(7217)
  end
  return title, content, version, btnOk, btnCancel, extraTips
end
function Weapon_DIY_System:ShowDiyProto(type, clickAgreeCallback, clickRejectCallback)
  local logic_lab_new = require("client.slua.logic.lobby.lab.logic_lab_new")
  if UIManager.GetUI(UIManager.UI_Config.video_player_system) or logic_lab_new.GetVideoPlayingStatus() then
    return
  end
  local title, content, version, btnOK, btnCancel, extraTips = self:GetDiyProtoInfo(type)
  if type == 4 then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local newbie_old = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDiyProto)
    if newbie_old and tonumber(newbie_old.version) == tonumber(version) then
      return true
    end
    local agreeProto = function()
      local newbie_new = {version = version}
      PlayerPrefsSystem.SaveTableToFile_N(newbie_new, PlayerPrefsSystem.ePlayerPrefsType.eDiyProto)
      if clickAgreeCallback then
        clickAgreeCallback()
      end
    end
    UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 2, title, content, extraTips, btnOK, btnCancel, agreeProto, clickRejectCallback)
  else
    UIManager.ShowUI(UIManager.UI_Config.HelpTip, 0, title, content)
  end
  return false
end
function Weapon_DIY_System:ShowErrorTips(error_id)
  if error_id ~= 0 and error_id ~= 100140013 then
    log(bWriteLog and "Weapon_DIY_System:ShowErrorTips error_id:" .. tostring(error_id))
    local TextData = LocUtil.GetLocalizeResStr(error_id)
    if TextData ~= "" then
      ShowNotice(TextData)
    else
      ShowNotice(error_id)
    end
  end
end
function Weapon_DIY_System:IsDIYWeapon(weaponId)
  if weaponId == nil then
    return false
  end
  local data = self:GetWeaponCfg(weaponId)
  if data then
    return true
  else
    return false
  end
end
function Weapon_DIY_System:GetCurUsePlanIdByWeaponId(weapon_id)
  if self.weaponData and self.weaponData[weapon_id] and self.weaponData[weapon_id].my_cur_status and self.weaponData[weapon_id].my_cur_status.cur_use_plan then
    return self.weaponData[weapon_id].my_cur_status.cur_use_plan
  else
    return nil
  end
end
function Weapon_DIY_System:IsPlanRecommend(plan_id)
  local lastChar = string.sub(plan_id, -1, -1)
  if lastChar == "0" then
    return true
  else
    return false
  end
end
function Weapon_DIY_System:GetRecommendPlanIdByWeaponId(weapon_id)
  return tostring(weapon_id) .. "-0"
end
function Weapon_DIY_System:IsWeaponDIYPlanIDMatchGivenWeaponSkinID(skin_id, plan_id)
  if type(plan_id) ~= "string" then
    plan_id = tostring(plan_id)
  end
  local StringUtil = require("common.string_util")
  local splitResults = StringUtil.Split(plan_id, "-")
  if skin_id == tonumber(splitResults[1]) then
    return true
  else
    return false
  end
end
function Weapon_DIY_System:GetRecommendSchemeDetail(weapon_id)
  local weapon_diy_rec_scheme = require("client.slua.logic.weapon_diy.weapon_diy_rec_scheme")
  return weapon_diy_rec_scheme[weapon_id]
end
function Weapon_DIY_System:HasNewTips()
  local curStep = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_DIY, 2) or 1
  if curStep <= self.MAX_NEW_TIPS_STEP then
    return true
  end
  return false
end
function Weapon_DIY_System:FinishNewTips()
  local step = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_DIY, 2) or 1
  if step <= self.MAX_NEW_TIPS_STEP then
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_DIY, 2, self.MAX_NEW_TIPS_STEP + 1)
    return true
  end
  return false
end
local _ensureTimer
function Weapon_DIY_System:GetDIYWeaponSchemeAndEquip(weapon_id)
  local time_ticker = require("common.time_ticker")
  local function callBack(_, _, weaponData, id)
    local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
    if id == MallSystemWeaponModelHandler.GetShowingId() then
      local data = weaponData[id]
      local planData = data.my_plan_table[data.my_cur_status.cur_use_plan]
      if planData then
        local binData = planData.bin_data
        local scheme = self:UnpackBinDataToLuaTable(binData)
        MallSystemWeaponModelHandler.ChangeDiyGunColorAndPattern(scheme)
      end
    end
    EventSystem:unregistEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_SUMMARY_DATA, callBack)
    if _ensureTimer then
      time_ticker.RemoveTimer(_ensureTimer)
      _ensureTimer = nil
    end
  end
  EventSystem:registEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_SUMMARY_DATA, callBack)
  self:GetDiyItemSummaryDataReq(weapon_id)
  _ensureTimer = time_ticker.AddTimerOnce(1, function()
    EventSystem:unregistEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_SUMMARY_DATA, callBack)
    if _ensureTimer then
      time_ticker.RemoveTimer(_ensureTimer)
      _ensureTimer = nil
    end
  end)
end
function Weapon_DIY_System:send_get_other_weapon_diy_summary_data_req(uid, skin_res_id, plan_id)
  local WeaponDiyHandler = require("client.network.Protocol.WeaponDiyHandler")
  WeaponDiyHandler.send_get_other_weapon_diy_summary_data_req(uid, skin_res_id, plan_id)
end
function Weapon_DIY_System:proc_get_other_weapon_diy_summary_data_rsp(other_plan_table, uid, skin_res_id, plan_id)
  log(bWriteLog and "Weapon_DIY_System:GetOtherWeaponDiySummaryDataRsp uid:" .. tostring(uid) .. " weapon_id:" .. tostring(weapon_id) .. " skin_res_id:" .. tostring(skin_res_id))
  log_tree(" other_plan_table:", other_plan_table)
  if self.other_weaponData then
    self.other_weaponData[uid] = {
      [skin_res_id] = {
        bin_data = other_plan_table[plan_id]
      }
    }
  else
    self.other_weaponData = {}
    self.other_weaponData[uid] = {
      [skin_res_id] = {
        bin_data = other_plan_table[plan_id]
      }
    }
  end
  EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_GET_OTHER_WEAPONDATA, uid, skin_res_id, plan_id)
end
function Weapon_DIY_System:GetOtherWeaponDiyScheme(uid, skin_res_id, plan_id)
  log(bWriteLog and "Weapon_DIY_System:GetOtherWeaponDiyScheme uid:" .. tostring(uid) .. " skin_res_id:" .. tostring(skin_res_id) .. " plan_id:" .. tostring(plan_id))
  local data = self.other_weaponData
  local planData = data[uid][skin_res_id].bin_data
  if planData then
    local scheme = self:UnpackBinDataToLuaTable(planData)
    return scheme
  end
end
return Weapon_DIY_System