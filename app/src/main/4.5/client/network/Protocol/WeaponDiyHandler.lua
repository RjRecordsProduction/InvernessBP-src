local NetManager = require("client.network.comm.NetManager")
local WeaponDiyHandler = {
  playerWeaponDataMap = {},
  myCachedDiyScheme = {}
}
function WeaponDiyHandler.Init()
  NetManager.RegisterTimeOutCallback(9306, WeaponDiyHandler.OnDiyGetDataTimeOut)
  EventSystem:registEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_ADD_ONE_PLAYER, WeaponDiyHandler.OnIsLandPlayerEnter)
  EventSystem:registEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_EXIT_ONE_PLAYER_NEW, WeaponDiyHandler.OnIsLandPlayerExit)
end
function WeaponDiyHandler.OnLogin()
  local myUid = DataMgr.roleData.uid
  DIYLua.SetMyUid(tostring(myUid))
end
function WeaponDiyHandler.OnModePreSwitch(preState, nextState)
  DIYLua.ClearAllWeaponData()
  log(bWriteLog and "DIYLua.ClearAllWeaponData")
end
function WeaponDiyHandler.OnDiyGetDataTimeOut(uid, data_type, data_param)
  log(bWriteLog and "WeaponDiyHandler.OnDiyGetDataTimeOut uid = " .. uid .. ", data_type = " .. data_type)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  gem_report_utils.ReportEventDelay(gem_report_utils.EventName_DIY_Event, "timeout")
  local StringUtil = require("common.string_util")
  local weapon_diy_rec_scheme = require("client.slua.logic.weapon_diy.weapon_diy_rec_scheme")
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  log(bWriteLog and "WeaponDiyHandler.OnDiyGetDataTimeOut 1")
  if data_param[1] then
    local content = StringUtil.Split(data_param[1], "-")
    local weaponId = tonumber(content[1])
    local planId = tonumber(content[2])
    local schemeData = weapon_diy_rec_scheme[weaponId]
    log(bWriteLog and "WeaponDiyHandler.OnDiyGetDataTimeOut 2 " .. tostring(weaponId) .. "," .. tostring(planId))
    if schemeData then
      local TableUtil = require("common.table_util")
      local tempScheme = TableUtil.DeepCloneTable(schemeData)
      local originSlotMatParam = tempScheme.SlotMatParam
      local battleSlotMatParam = {0}
      if originSlotMatParam then
        for i, v in ipairs(originSlotMatParam) do
          table.insert(battleSlotMatParam, v)
        end
      end
      tempScheme.SlotMatParam = battleSlotMatParam
      log(bWriteLog and "WeaponDiyHandler.OnDiyGetDataTimeOut 3")
      local bin_data = weapon_diy_system:PackSchemeDataToBinData(tempScheme)
      DIYLua.SaveWeaponData(uid, weaponId, planId, bin_data)
    end
  end
end
function WeaponDiyHandler.AddWeaponData(uid, weaponId, weaponData)
  if WeaponDiyHandler.playerWeaponDataMap[uid] == nil then
    WeaponDiyHandler.playerWeaponDataMap[uid] = {}
  end
  local weaponDataMap = WeaponDiyHandler.playerWeaponDataMap[uid]
  weaponDataMap[weaponId] = weaponData
end
function WeaponDiyHandler.GetWeaponData(uid, weaponId)
  if WeaponDiyHandler.playerWeaponDataMap[uid] == nil then
    return nil
  end
  local weaponDataMap = WeaponDiyHandler.playerWeaponDataMap[uid]
  return weaponDataMap[weaponId]
end
function WeaponDiyHandler.send_get_weapon_diy_summary_data_req(weapon_id)
  NetManager.SendPkg(337939355, weapon_id)
end
function WeaponDiyHandler.on_get_weapon_diy_summary_data_rsp(err_code, weapon_id, recommend_plan_id, my_plan_table, my_cur_status)
  local logic_weapon_diy_pic_examine = require("client.slua.logic.weapon_diy.logic_weapon_diy_pic_examine")
  logic_weapon_diy_pic_examine.SaveSummaryData(weapon_id, recommend_plan_id, my_plan_table, my_cur_status)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    weapon_diy_system:GetDiyMerchantWeaponDataRsp(weapon_id, recommend_plan_id, my_plan_table, my_cur_status)
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.send_get_weapon_diy_detail_data_req(weapon_id)
  NetManager.SendPkg(1169448231, weapon_id)
end
function WeaponDiyHandler.on_get_weapon_diy_detail_data_rsp(err_code, weapon_id, diy_cfg_table, my_data)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    weapon_diy_system:GetDiyItemDetailDataRsp(weapon_id, diy_cfg_table, my_data)
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.send_use_weapon_diy_custom_plan_req(weapon_id, plan_id)
  NetManager.SendPkg(862090919, weapon_id, plan_id)
end
function WeaponDiyHandler.on_use_weapon_diy_custom_plan_rsp(err_code, weapon_id, plan_id)
  log(bWriteLog and "on_use_weapon_diy_custom_plan_rsp" .. tostring(err_code))
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    weapon_diy_system:UseDiyCustomSchemeRsp(weapon_id, plan_id)
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.send_get_weapon_diy_custom_plan_data_req(weapon_id)
  NetManager.SendPkg(1916257439, weapon_id)
end
function WeaponDiyHandler.send_save_weapon_diy_custom_plan_data_req(weapon_id, bin_data, plan_id)
  log(bWriteLog and "send_save_weapon_diy_custom_plan_data_req" .. tostring(weapon_id) .. tostring(plan_id))
  NetManager.SendPkg(540769447, weapon_id, bin_data, plan_id)
end
function WeaponDiyHandler.on_save_weapon_diy_custom_plan_data_rsp(err_code, weapon_id, plan_id)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    weapon_diy_system:OnSaveSchemeRsp(weapon_id, plan_id)
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.send_delete_weapon_diy_custom_plan_req(weapon_id, plan_id, client_refund_price)
  NetManager.SendPkg(1064691807, weapon_id, plan_id, client_refund_price)
end
function WeaponDiyHandler.on_delete_weapon_diy_custom_plan_rsp(err_code, weapon_id, plan_id, client_refund_price)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    weapon_diy_system:DeleteDiySchemeRsp(weapon_id, plan_id, client_refund_price)
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.send_get_player_ds_data_req(uid, data_type, data_param, source, serial)
  log(bWriteLog and "WeaponDiyHandler.send_get_player_ds_data_req uid = ", uid)
  log(bWriteLog and "WeaponDiyHandler.send_get_player_ds_data_req data_type = ", data_type)
  log_tree("WeaponDiyHandler.send_get_player_ds_data_req data_param = ", data_param)
  if data_param.bRec then
    local weapon_diy_rec_scheme = require("client.slua.logic.weapon_diy.weapon_diy_rec_scheme")
    local schemeData = weapon_diy_rec_scheme[data_param.weaponId]
    local TableUtil = require("common.table_util")
    local tempScheme = schemeData and TableUtil.CopyTable(schemeData) or {}
    local originSlotMatParam = tempScheme.SlotMatParam
    local battleSlotMatParam = {0}
    if originSlotMatParam then
      for i, v in ipairs(originSlotMatParam) do
        table.insert(battleSlotMatParam, v)
      end
    end
    tempScheme.SlotMatParam = battleSlotMatParam
    local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
    local bin_data = weapon_diy_system:PackSchemeDataToBinData(tempScheme)
    DIYLua.SaveWeaponData(uid, data_param.weaponId, 0, bin_data)
  else
    NetManager.SendPkg(1429715623, uid, data_type, data_param, source, serial)
  end
end
function WeaponDiyHandler.on_get_player_ds_data_rsp(err_code, uid, data_type, data)
  log(bWriteLog and "WeaponDiyHandler.on_get_player_ds_data_rsp err_code = ", err_code)
  log(bWriteLog and "WeaponDiyHandler.on_get_player_ds_data_rsp uid = ", uid)
  log(bWriteLog and "WeaponDiyHandler.on_get_player_ds_data_rsp data_type = ", data_type)
  log_tree("WeaponDiyHandler.on_get_player_ds_data_rsp data = ", data)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code ~= 0 then
    weapon_diy_system:ShowErrorTips(err_code)
    if err_code == 100140013 then
      EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_GET_PLAYER_SCHEME_DATA, uid)
    end
    return
  end
  for k, v in pairs(data) do
    local planid = k
    local bin_data = v
    local index = string.find(planid, "-")
    if index == nil then
      log(bWriteLog and "WeaponDiyHandler.on_get_player_ds_data_rsp error format planid = " .. planid)
      return
    end
    local weaponid = string.sub(planid, 1, index - 1)
    if weaponid == "" then
      log(bWriteLog and "WeaponDiyHandler.on_get_player_ds_data_rsp weaponid nil " .. planid)
      return
    end
    weaponid = tonumber(weaponid)
    local weaponData = weapon_diy_system:UnpackBinDataToLuaTable(bin_data)
    local TableUtil = require("common.table_util")
    local tempWeaponData = TableUtil.DeepCloneTable(weaponData)
    local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
    local spreadData = MallSystemWeaponModelHandler._RecombinePatternSchemeData(tempWeaponData.DIYData)
    tempWeaponData.DIYData = spreadData
    local originSlotMatParam = tempWeaponData.SlotMatParam
    local battleSlotMatParam = {0}
    for i, v in ipairs(originSlotMatParam) do
      table.insert(battleSlotMatParam, v)
    end
    tempWeaponData.SlotMatParam = battleSlotMatParam
    local newBinData = weapon_diy_system:PackSchemeDataToBinData(tempWeaponData, false)
    WeaponDiyHandler.AddWeaponData(uid, weaponid, weaponData)
    log_tree("xxxx weaponData = ", weaponData)
    local StringUtil = require("common.string_util")
    local planIdArr = StringUtil.Split(planid, "-")
    if planIdArr and planIdArr[2] then
      local shortPlanId = tonumber(planIdArr[2])
      log(bWriteLog and "WeaponDiyHandler.on_get_player_ds_data_rsp " .. shortPlanId)
      DIYLua.SaveWeaponData(uid, weaponid, tonumber(shortPlanId), newBinData)
    end
    if DataMgr.roleData.uid == uid then
      WeaponDiyHandler.myCachedDiyScheme[tonumber(weaponid)] = weaponData
    end
    EventSystem:postEvent(EVENTTYPE_WEAPON_DIY, EVENTID_WEAPON_DIY_GET_PLAYER_SCHEME_DATA, uid, tonumber(weaponid), weaponData)
  end
end
function WeaponDiyHandler.send_batch_get_player_ds_data_req(uid_list)
  NetManager.SendPkg(750394791, uid_list)
end
function WeaponDiyHandler.on_batch_get_player_ds_data_rsp(err_code, data_list)
  log_tree("WeaponDiyHandler.on_batch_get_player_ds_data_rsp data_list = ", data_list)
end
function WeaponDiyHandler.TestUploadBinData()
  local weapon_id = 1101003199
  local weaponData = {
    DIYData = {
      [1] = {
        TexPathID = 1,
        DIYParam = {
          ColorID = 0,
          Rotation = 0.0,
          Opacity = 1.0,
          ScaleX = 4.0,
          ScaleY = 4.0,
          OffSetX = 0.0,
          OffSetY = 8.0,
          UClipX = 10,
          UClipY = 20,
          VClipX = 30,
          VClipY = 40,
          Direction = 3
        },
        SlotID = 10
      },
      [2] = {
        TexPathID = 1002,
        DIYParam = {
          ColorID = 0,
          Rotation = 0.0,
          Opacity = 1.0,
          ScaleX = 4.0,
          ScaleY = 4.0,
          OffSetX = 4.0,
          OffSetY = 8.0,
          UClipX = 10,
          UClipY = 20,
          VClipX = 30,
          VClipY = 40,
          Direction = 3
        },
        SlotID = 10
      },
      [3] = {
        TexPathID = 1003,
        DIYParam = {
          ColorID = 0,
          Rotation = 0.0,
          Opacity = 1.0,
          ScaleX = 4.0,
          ScaleY = 4.0,
          OffSetX = 16.0,
          OffSetY = 8.0,
          UClipX = 10,
          UClipY = 20,
          VClipX = 30,
          VClipY = 40,
          Direction = 3
        },
        SlotID = 10
      }
    },
    MatParam = {
      1,
      2,
      3,
      0
    },
    MirrorParam = {1, 1},
    SlotMatParam = {1, 1}
  }
  local bin_data = DIYLua.WeaponDataToBinData(weaponData)
  local binstr = WeaponDiyHandler.bin2hex(bin_data)
  log(bWriteLog and "xxxx weapon bin_data = " .. binstr)
  DIYLua.SaveWeaponData("100", 100, 1, bin_data)
  local luaData = DIYLua.UnPackWeaponDataTable(bin_data)
  WeaponDiyHandler.AddWeaponData("100", 100, luaData)
  log_tree("xxxx luaData = ", luaData)
  local plan_id = 0
  WeaponDiyHandler.send_save_weapon_diy_custom_plan_data_req(weapon_id, bin_data, plan_id)
end
function WeaponDiyHandler.TestDownloadBinData()
  local uid = DataMgr.roleData.uid
  local data_type = 1
  local data_param = {
    "1101003199-1"
  }
  WeaponDiyHandler.send_get_player_ds_data_req(uid, data_type, data_param)
end
function WeaponDiyHandler.UploadBinData(weapon_id, weaponData, plan_id)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  local bin_data = weapon_diy_system:PackSchemeDataToBinData(weaponData)
  WeaponDiyHandler.send_save_weapon_diy_custom_plan_data_req(weapon_id, bin_data, plan_id)
  weapon_diy_system:FinishNewTips()
end
function WeaponDiyHandler.DownloadBinData(uid, data_type, data_param)
  WeaponDiyHandler.send_get_player_ds_data_req(uid, data_type, data_param)
end
function WeaponDiyHandler.bin2hex(s)
  s = string.gsub(s, "(.)", function(x)
    return string.format("%02X ", string.byte(x))
  end)
  return s
end
function WeaponDiyHandler.send_get_base_pattern_and_color_req()
  NetManager.SendPkg(150047335)
end
function WeaponDiyHandler.on_get_base_pattern_and_color_rsp(err_code, base_cfg_table, my_data)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    weapon_diy_system:GetBasePatternDataRsp(base_cfg_table, my_data)
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.send_get_weapon_diy_weapon_list_req()
  log(bWriteLog and "WeaponDiyHandler.send_get_weapon_diy_weapon_list_req")
  NetManager.SendPkg(993996295)
end
function WeaponDiyHandler.on_get_weapon_diy_weapon_list_rsp(err_code, weapon_table)
  log(bWriteLog and "WeaponDiyHandler.on_get_weapon_diy_weapon_list_rsp err_code = " .. tostring(err_code))
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    weapon_diy_system:GetDiyItemListRsp(weapon_table)
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.send_save_weapon_diy_custom_pattern_data_req(bin_data, custom_pattern_id)
  if custom_pattern_id then
    NetManager.SendPkg(3896383, bin_data, custom_pattern_id)
  else
    NetManager.SendPkg(-2143587265, bin_data)
  end
end
function WeaponDiyHandler.on_save_weapon_diy_custom_pattern_data_rsp(err_code, custom_pattern_id)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    weapon_diy_system:SaveCustomPatternDataRsp(custom_pattern_id)
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.send_get_weapon_diy_custom_pattern_req()
  NetManager.SendPkg(1353625743)
end
function WeaponDiyHandler.on_get_weapon_diy_custom_pattern_rsp(err_code, custom_pattern)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    weapon_diy_system:GetDiyPatternDataRsp(custom_pattern)
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.send_unlock_weapon_diy_custom_pattern_layer_req(layer_num)
  NetManager.SendPkg(144554023, layer_num)
end
function WeaponDiyHandler.on_unlock_weapon_diy_custom_pattern_layer_rsp(err_code, layer_num)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    weapon_diy_system:SendDIYPatternLayerRsp(layer_num)
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.send_unlock_weapon_diy_weapon_layer_req(weapon_id, layer_num)
  NetManager.SendPkg(960079783, weapon_id, layer_num)
end
function WeaponDiyHandler.on_unlock_weapon_diy_weapon_layer_rsp(err_code, weapon_id, layer_num)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    weapon_diy_system:SendWeaponPatternLayerRsp(weapon_id, layer_num)
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.send_delete_weapon_diy_custom_pattern_req(pattern_id)
  NetManager.SendPkg(1802917287, pattern_id)
end
function WeaponDiyHandler.on_delete_weapon_diy_custom_pattern_rsp(err_code, pattern_id)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    weapon_diy_system:DeletePatternRsp(pattern_id)
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.send_weapon_diy_unlock_base_req(type, id, is_uc_fill)
  NetManager.SendPkg(1382516231, type, id, is_uc_fill)
end
function WeaponDiyHandler.on_weapon_diy_unlock_base_rsp(err_code, type, id)
  log(bWriteLog and "on_buy_weapon_diy_custom_pattern_material_rsp err_code:" .. tostring(err_code) .. " type:" .. tostring(type) .. " id:" .. tostring(id))
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    weapon_diy_system:BuyBasePatternOrColorRsq(type, id)
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.send_buy_weapon_diy_custom_plan_req(weapon_id, bin_data, plan_id, client_total_price, is_uc_fill)
  log(bWriteLog and "WeaponDiyHandler.send_buy_weapon_diy_custom_plan_req weapon_id:" .. tostring(weapon_id) .. " plan_id:" .. tostring(plan_id) .. " is_uc_fill:" .. tostring(is_uc_fill))
  log_tree("WeaponDiyHandler.send_buy_weapon_diy_custom_plan_req bin_data", bin_data)
  log_tree("WeaponDiyHandler.send_buy_weapon_diy_custom_plan_req client_total_price", client_total_price)
  NetManager.SendPkg(2054080199, weapon_id, bin_data, plan_id, client_total_price, is_uc_fill)
  WeaponDiyHandler.up_load_diy_custom_plan_for_picture(weapon_id, plan_id)
end
function WeaponDiyHandler.on_buy_weapon_diy_custom_plan_rsp(err_code, weapon_id, plan_id, my_data)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    weapon_diy_system:on_buy_weapon_diy_custom_plan_rsp(weapon_id, plan_id, my_data)
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.send_exchange_diy_pattern_req(pattern_id, pattern_count, cost_list)
  NetManager.SendPkg(86844903, pattern_id, pattern_count, cost_list)
end
function WeaponDiyHandler.on_exchange_diy_pattern_rsp(err_code, pattern_id, pattern_count)
  local WeaponDiyExchangeSystem = require("client.slua.logic.weapon_diy.logic_weapon_diy_exchange")
  if err_code == 0 then
    WeaponDiyExchangeSystem.exchange_diy_pattern_rsp(pattern_id, pattern_count)
  else
    local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.send_weapon_diy_unlock_plan_req(weapon_id)
  NetManager.SendPkg(1314315527, weapon_id)
end
function WeaponDiyHandler.on_weapon_diy_unlock_plan_rsp(err_code, weapon_id, plan_count)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    weapon_diy_system:UnlockSchemeNumRsq(weapon_id, plan_count)
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.on_weapon_diy_material_notify(name, weapon_id, id, new_count, item_id)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  weapon_diy_system:OnWeaponDiyMaterialNotify(name, weapon_id, id, new_count, item_id)
end
function WeaponDiyHandler.send_get_weapon_diy_material_count_req()
  NetManager.SendPkg(1387029835)
end
function WeaponDiyHandler.on_get_weapon_diy_material_count_rsp(err_code, materials_count)
  local WeaponDiyExchangeSystem = require("client.slua.logic.weapon_diy.logic_weapon_diy_exchange")
  if err_code == 0 then
    WeaponDiyExchangeSystem.get_weapon_diy_material_count_rsp(materials_count)
  else
    local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.OnIsLandPlayerEnter(_, _, memberInfo)
  if not memberInfo then
    log(bWriteLog and "WeaponDiyHandler.OnIsLandPlayerEnter memberInfo nil")
    return
  end
  local uid = memberInfo.uid
  log(bWriteLog and "WeaponDiyHandler.OnIsLandPlayerEnter clear one " .. uid)
  DIYLua.ClearOneWeaponData(tostring(uid))
end
function WeaponDiyHandler.OnIsLandPlayerExit(_, _, uid)
  log(bWriteLog and "WeaponDiyHandler.OnIsLandPlayerExit clear one " .. uid)
  DIYLua.ClearOneWeaponData(tostring(uid))
end
function WeaponDiyHandler.on_get_weapon_diy_custom_plan_data_rsp(err_code, weapon_id, plan_data)
end
function WeaponDiyHandler.send_batch_get_weapon_diy_summary_data_req(allWeaponId)
  NetManager.SendPkg(1696309567, allWeaponId)
end
function WeaponDiyHandler.on_batch_get_weapon_diy_summary_data_rsp(err_code, all_weapon_id, recommend_plan_id, my_plan_table, my_cur_status)
  local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  if err_code == 0 then
    for _, weapon_id in pairs(all_weapon_id) do
      if recommend_plan_id[weapon_id] and my_plan_table[weapon_id] and my_cur_status[weapon_id] then
        weapon_diy_system:GetDiyMerchantWeaponDataRsp(weapon_id, recommend_plan_id[weapon_id], my_plan_table[weapon_id], my_cur_status[weapon_id])
      end
    end
  else
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
function WeaponDiyHandler.up_load_diy_custom_plan_for_picture(weapon_id, plan_id)
  local bSwitch = LobbySystem.CheckOpen(BP_ENUM_DIY_SAVE_UPLOAD_ID)
  if not bSwitch then
    return
  end
  log(bWriteLog and "up_load_diy_custom_plan_for_picture weapon_id:" .. tostring(weapon_id) .. ",plan_id:" .. tostring(plan_id))
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimer(0.1, function()
    local callback = function(texturePath)
      log(bWriteLog and "up_load_diy_custom_plan_for_picture callback texturePath:" .. texturePath .. " weapon_id:" .. tostring(weapon_id) .. " plan_id:" .. tostring(plan_id))
      local pic_path = Client.ProjectSavedDir()
      local idx = string.find(texturePath, "WeaponDIY/pattern/")
      if idx and 0 < idx then
        pic_path = pic_path .. string.sub(texturePath, idx)
      end
      log(bWriteLog and "up_load_diy_custom_plan_for_picture callback pic_path:" .. pic_path .. " weapon_id:" .. tostring(weapon_id) .. " plan_id:" .. tostring(plan_id))
      time_ticker.AddTimer(0, function()
        local ShareMgr = require("client.logic.share.share_logic")
        ShareMgr.HDmpveUploadFile(pic_path, function(isSuccess, imgUrl)
          log(bWriteLog and "up_load_diy_custom_plan_for_picture HDmpveUploadFile isSuccess:" .. tostring(isSuccess) .. ",imgUrl:" .. tostring(imgUrl))
          if isSuccess then
            local logic_moment_helper = require("client.slua.logic.moment.logic_moment_helper")
            local cdnDomain = logic_moment_helper.GetDomain(1)
            local pic_url = string.sub(imgUrl, string.len(cdnDomain) + 1, string.len(imgUrl))
            log(bWriteLog and "up_load_diy_custom_plan_for_picture HDmpveUploadFile pic_url:" .. pic_url .. " cdnDomain:" .. cdnDomain)
          else
            ShowNotice(18956)
          end
        end, 0, ShareMgr.ShareFileType.DIYPlan)
      end)
    end
    local failedcall = function()
      log(bWriteLog and "up_load_diy_custom_plan_for_picture failedcall...")
    end
    local weapon_diy_model_system = require("client.slua.logic.weapon_diy.logic_weapon_diy_model")
    local scheme = weapon_diy_model_system:GetOperatingSchemeDetail()
    local WeaponDIYCapture = require("client.slua.logic.weapon_diy.logic_weapon_capture_weapon")
    WeaponDIYCapture:GetWeaponIconTexture(weapon_id, plan_id, WeaponDIYCapture.scene.diy_main, scheme, true, callback, failedcall)
  end)
end
function WeaponDiyHandler.send_get_other_weapon_diy_summary_data_req(uid, skin_res_id, plan_id)
  log(bWriteLog and "WeaponDiyHandler.send_get_other_weapon_diy_summary_data_req uid:" .. tostring(uid) .. " skin_res_id:" .. tostring(skin_res_id) .. " plan_id:" .. tostring(plan_id))
  NetManager.SendPkg(589802127, uid, skin_res_id, plan_id)
end
function WeaponDiyHandler.on_get_other_weapon_diy_summary_data_rsp(err_code, other_plan_table, uid, skin_res_id, plan_id)
  log(bWriteLog and "WeaponDiyHandler.on_get_other_weapon_diy_summary_data_rsp err_code:" .. tostring(err_code) .. " uid:" .. tostring(uid) .. " skin_res_id:" .. tostring(skin_res_id) .. " plan_id:" .. tostring(plan_id))
  if err_code == 0 then
    log(bWriteLog and "WeaponDiyHandler.on_get_other_weapon_diy_summary_data_rsp 1")
    local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
    weapon_diy_system:proc_get_other_weapon_diy_summary_data_rsp(other_plan_table, uid, skin_res_id, plan_id)
  else
    log(bWriteLog and "WeaponDiyHandler.on_get_other_weapon_diy_summary_data_rsp 2")
    local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
    weapon_diy_system:ShowErrorTips(err_code)
  end
end
return WeaponDiyHandler