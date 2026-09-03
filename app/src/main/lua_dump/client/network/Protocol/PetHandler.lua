local NetManager = require("client.network.comm.NetManager")
local PetHandler = {}
function PetHandler.send_get_pet_data_req()
  log(bWriteLog and "PetHandler.send_get_pet_data_req")
  NetManager.SendPkg(2075341224)
end
function PetHandler.on_sync_pet_data(data, inherit_pet_data)
  log(bWriteLog and "PetHandler.on_sync_pet_data")
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    return
  end
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  if data and data.equip_pet_id and logic_pet:IsPetIDBlocked(data and data.equip_pet_id) then
    data.equip_pet_id = 0
  end
  if data and data.pets then
    for key, value in pairs(data.pets) do
      if logic_pet:IsPetIDBlocked(key) then
        data.pets[key] = nil
        if data.pet_cnt and 0 < data.pet_cnt then
          data.pet_cnt = data.pet_cnt - 1
        end
      end
    end
  end
  if inherit_pet_data and inherit_pet_data.pets then
    for key, value in pairs(inherit_pet_data.pets) do
      if logic_pet:IsPetIDBlocked(key) then
        inherit_pet_data.pets[key] = nil
        if inherit_pet_data.pet_cnt and 0 < inherit_pet_data.pet_cnt then
          inherit_pet_data.pet_cnt = inherit_pet_data.pet_cnt - 1
        end
      end
    end
  end
  local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
  LogicInheritWardrobe:CacheInheritPetData(inherit_pet_data)
  if data then
    logic_pet:AddInsIDToPetInfo(data.pets, EPetSource.Self)
  end
  logic_pet:sync_pet_data(data)
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  logic_share_bag_privilege_util:RspSetMyPetShared(data and data.shared_pet_flag)
end
function PetHandler.on_notice_pet_change(pets, sourece)
  log(bWriteLog and "PetHandler.on_notice_pet_change")
  log_tree("pets = ", pets)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  if pets then
    for key, value in pairs(pets) do
      if logic_pet:IsPetIDBlocked(key) then
        pets[key] = nil
      end
    end
  end
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    print(bWriteLog and "GameStatus.IsInFightingNotSocialNotMainCityNotHome()")
    return
  end
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:AddInsIDToPetInfo(pets, sourece or EPetSource.Self)
  logic_pet:notice_pet_change(pets, sourece)
end
function PetHandler.send_query_pet_dress_shop_info_req()
  NetManager.SendPkg(302736675)
end
function PetHandler.on_query_pet_dress_shop_info_rsp(data)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:query_pet_dress_shop_info_rsp(data)
end
function PetHandler.on_notice_dress_change(dressData)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:notice_dress_change(dressData)
end
function PetHandler.send_pet_used_dress_req(pet_id, item_id, source)
  NetManager.SendPkg(1172477159, pet_id, item_id, source)
end
function PetHandler.on_pet_used_dress_rsp(errCode, pet_id, item_id, source)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:pet_used_dress_rsp(errCode, pet_id, item_id, source)
end
function PetHandler.send_pet_unload_dress_req(pet_id, item_id, source)
  NetManager.SendPkg(845172199, pet_id, item_id, source)
end
function PetHandler.on_pet_unload_dress_rsp(errCode, pet_id, item_id, source)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:pet_unload_dress_rsp(errCode, pet_id, item_id, source)
end
function PetHandler.send_pet_reanme_req(pet_id, name)
  NetManager.SendPkg(1260473351, pet_id, name)
end
function PetHandler.on_pet_reanme_rsp(code, pet_id, name, oldName)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:pet_reanme_rsp(code, pet_id, name, oldName)
end
function PetHandler.send_pet_add_exp_req(pet_id, food_id, cnt)
  NetManager.SendPkg(1210617335, pet_id, food_id, cnt)
end
function PetHandler.on_pet_add_exp_rsp(code, pet_id, exp)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:pet_add_exp_rsp(code, pet_id, exp)
end
function PetHandler.send_equip_pet_req(pet_id, source)
  NetManager.SendPkg(1000635059, pet_id, source)
end
function PetHandler.on_equip_pet_rsp(code, pet_id, source)
  if not GameStatus.IsInLobbyOrMainCity() then
    print(bWriteLog and "PetHandler.on_equip_pet_rsp GameStatus.IsInLobbyOrMainCity()")
    return
  end
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local PetInsID = logic_pet:ConvertToInsID(pet_id, source)
  logic_pet:equip_pet_rsp(code, PetInsID)
end
function PetHandler.send_unequip_pet_req()
  NetManager.SendPkg(1116577431)
end
function PetHandler.on_unequip_pet_rsp(code)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:unequip_pet_rsp(code)
end
function PetHandler.on_notice_pet_event_res(notice_info)
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    print(bWriteLog and "PetHandler.on_notice_pet_event_res GameStatus.IsInFightingNotSocialNotMainCityNotHome()")
    return
  end
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:notice_pet_event_res(notice_info)
end
function PetHandler.send_pet_action_req(action_id)
  NetManager.SendPkg(1408598919, action_id)
end
function PetHandler.on_pet_action_rsp(code, action_id)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:pet_action_rsp(code, action_id)
end
function PetHandler.send_get_pet_tab_info_req()
  NetManager.SendPkg(1908689575)
end
function PetHandler.on_get_pet_tab_info_rsp(param1, param2)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:on_get_pet_tab_info_rsp(param1, param2)
end
function PetHandler.send_pet_decompose_list_req()
  NetManager.SendPkg(1308045127)
end
function PetHandler.on_pet_decompose_list_rsp(code, decompose_list)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:on_pet_decompose_list_rsp(code, decompose_list)
end
function PetHandler.send_set_pet_color_req(pet_id, color, source)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  if not logic_pet:HasPet(pet_id) then
    print(bWriteLog and "PetHandler.send_set_pet_color_req not own pet")
    return
  end
  NetManager.SendPkg(159544259, pet_id, color, source)
end
function PetHandler.on_set_pet_color_rsp(err_code, pet_id, color, source)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:on_set_pet_color_rsp(err_code, pet_id, color)
end
function PetHandler.send_carry_pet_req(pet_id, carry_type, source)
  NetManager.SendPkg(1407533223, pet_id, carry_type, source)
end
function PetHandler.on_carry_pet_rsp(err_code, pet_id, carry_type, source)
  log(bWriteLog and string.format("PetHandler.on_carry_pet_rsp. err_code=%s, pet_id=%s, carry_type=%s", tostring(err_code), tostring(pet_id), tostring(carry_type)))
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local PetInsID = logic_pet:ConvertToInsID(pet_id, source)
  logic_pet:carry_pet_rsp(err_code, PetInsID, carry_type)
end
function PetHandler.send_change_pet_model_req(pet_id, change_type, source)
  log(bWriteLog and string.format("PetHandler.send_change_pet_model_req. pet_id=%s, change_type=%s", tostring(pet_id), tostring(change_type)))
  NetManager.SendPkg(1086415527, pet_id, change_type, source)
end
function PetHandler.on_change_pet_model_rsp(err_code, pet_id, change_type, source)
  log(bWriteLog and string.format("PetHandler.on_change_pet_model_rsp. err_code=%s, change_type=%s", tostring(err_code), tostring(change_type)))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:on_change_pet_model_rsp(pet_id, change_type, source)
end
function PetHandler.send_pet_show_req(ext_info)
  NetManager.SendPkg(1309574951, ext_info)
end
function PetHandler.on_pet_show_rsp(err_code)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local pet_show_module = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.pet_show_module)
  pet_show_module:on_pet_show_rsp()
end
function PetHandler.on_notify_pet_show(team_id, uid, carry_info, equip_info, ext_info)
  log(bWriteLog and string.format("PetHandler.on_notify_pet_show. team_id=%s, uid=%s, carry_info=%s", tostring(team_id), tostring(uid), tostring(carry_info)))
  local pet_show_module = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.pet_show_module)
  pet_show_module:on_notify_pet_show(uid, carry_info, equip_info, ext_info)
end
function PetHandler.send_shared_pet_config_req(config_type)
  log(bWriteLog and string.format("PetHandler.send_shared_pet_config_req. config_type=%s", tostring(config_type)))
  NetManager.SendPkg(1955470147, config_type)
end
function PetHandler.on_shared_pet_config_rsp(ret_code, config_type)
  log(bWriteLog and string.format("PetHandler.on_shared_pet_config_rsp. ret_code=%s, config_type=%s", tostring(ret_code), tostring(config_type)))
  if ret_code ~= 0 then
    ShowNotice(ret_code)
    return
  end
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  local bShared = config_type and config_type ~= 0
  logic_share_bag_privilege_util:RspSetMyPetShared(bShared)
end
function PetHandler.send_get_pet_switch_effect_req()
  NetManager.SendPkg(361861303)
end
function PetHandler.on_get_pet_switch_effect_rsp(err_code, effect_info)
  log(bWriteLog and string.format("PetHandler.on_get_pet_switch_effect_rsp. err_code, effct_list", err_code, effect_info))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:on_get_pet_switch_effect_rsp(effect_info)
end
function PetHandler.send_set_equip_pet_switch_effect_req(effect_list)
  NetManager.SendPkg(1630498851, effect_list)
end
function PetHandler.on_set_equip_pet_switch_effect_rsp(err_code, effect_list)
  log(bWriteLog and string.format("PetHandler.on_set_equip_pet_switch_effect_rsp. err_code=%s, effct_list=%s", tostring(err_code), tostring(effct_list)))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:on_set_equip_pet_switch_effect_rsp(effect_list)
end
return PetHandler