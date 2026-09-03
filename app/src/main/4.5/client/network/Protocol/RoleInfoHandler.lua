local NetManager = require("client.network.comm.NetManager")
local RoleInfoHandler = {}
function RoleInfoHandler.send_get_user_avatar_list()
  log(bWriteLog and "RoleInfoHandler.send_get_user_avatar_list")
  NetManager.SendPkg(143015436)
end
function RoleInfoHandler.on_get_user_avatar_list_rsp(ok, list, headportraiturl)
  log(bWriteLog and "RoleInfoHandler.on_get_user_avatar_list_rsp ok = " .. ok)
  log_tree("list = ", list)
  log_tree("headportraiturl = ", headportraiturl)
  if ok ~= 0 then
    return
  end
  local RoleInfoAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_Avatar")
  RoleInfoAvatarSystem.get_user_avatar_list_rsp(ok, list, headportraiturl)
end
function RoleInfoHandler.send_use_brand(id)
  NetManager.SendPkg(1675969614, id)
end
function RoleInfoHandler.on_use_brand_rsp(res, id)
  local RoleInfoNameFrameSystem = require("client.slua.logic.person_space.logic_roleinfo_nameframe")
  RoleInfoNameFrameSystem.use_brand_rsp(res, id)
end
function RoleInfoHandler.on_notify_add_brand(id, expire_ts)
  local RoleInfoNameFrameSystem = require("client.slua.logic.person_space.logic_roleinfo_nameframe")
  RoleInfoNameFrameSystem.notify_add_brand(id, expire_ts)
end
function RoleInfoHandler.send_select_use_pspace_rolewear(index)
  NetManager.SendPkg(248116844, index)
end
function RoleInfoHandler.on_select_use_pspace_rolewear_rsp(res, index, pspace_wear_ext, pspace_skin_info)
  local SocialDecorationSystem = require("client.slua.logic.lobby.Left.logic_social_decoration")
  SocialDecorationSystem.select_use_pspace_rolewear_rsp(res, index, pspace_wear_ext, pspace_skin_info)
end
function RoleInfoHandler.on_new_team_notify_skin_notify(skin_list, new_item_id)
  local logic_roleInfo_TeamUpFrame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_TeamUpFrame)
  logic_roleInfo_TeamUpFrame:on_new_team_notify_skin_notify(skin_list, new_item_id)
end
function RoleInfoHandler.send_change_team_notify_skin(item_id)
  NetManager.SendPkg(1372593228, item_id)
end
function RoleInfoHandler.on_change_team_notify_skin_rsp(err_code, cur_skin_id)
  local logic_roleInfo_TeamUpFrame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_TeamUpFrame)
  logic_roleInfo_TeamUpFrame:on_change_team_notify_skin_rsp(err_code, cur_skin_id)
end
function RoleInfoHandler.send_get_team_notify_skin_list()
  NetManager.SendPkg(484035478)
end
function RoleInfoHandler.on_get_team_notify_skin_list_rsp(err_code, skin_list, cur_skin_id)
  local logic_roleInfo_TeamUpFrame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_TeamUpFrame)
  logic_roleInfo_TeamUpFrame:on_get_team_notify_skin_list_rsp(err_code, skin_list, cur_skin_id)
end
function RoleInfoHandler.send_get_carte_frame_list_req()
  NetManager.SendPkg(677059495)
end
function RoleInfoHandler.on_get_carte_frame_list_rsp(err_code, active_frame_list, equip_frame_id)
  local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
  logic_roleinfo_carte_frame:get_carte_frame_list_rsp(err_code, active_frame_list, equip_frame_id)
end
function RoleInfoHandler.send_equip_carte_frame_req(frame_id, bEquip)
  NetManager.SendPkg(528789675, frame_id, bEquip)
end
function RoleInfoHandler.on_equip_carte_frame_rsp(err_code, frame_id, bEquip)
  local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
  logic_roleinfo_carte_frame:equip_carte_frame_rsp(err_code, frame_id, bEquip)
end
function RoleInfoHandler.on_notify_carte_frame_update(frame_list, new_frame_id)
  local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
  logic_roleinfo_carte_frame:on_notify_carte_frame_update(frame_list, new_frame_id)
end
function RoleInfoHandler.send_get_friend_nickname_skin_req()
  NetManager.SendPkg(1864315367)
end
function RoleInfoHandler.on_get_friend_nickname_skin_rsp(err_code, friend_nickname_skin_data, friend_nickname_skin_cfg)
  log(bWriteLog and "RoleInfoHandler.on_get_friend_nickname_skin_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_roleInfo_nicknameframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_nicknameframe)
  logic_roleInfo_nicknameframe:ProcNicknameListRsp(friend_nickname_skin_data, friend_nickname_skin_cfg)
end
function RoleInfoHandler.send_set_friend_nickname_skin_req(skin_id)
  log(bWriteLog and "RoleInfoHandler.send_set_friend_nickname_skin_req skin_id = " .. tostring(skin_id))
  NetManager.SendPkg(537298663, skin_id)
end
function RoleInfoHandler.on_set_friend_nickname_skin_rsp(err_code, skin_id)
  log(bWriteLog and "RoleInfoHandler.on_set_friend_nickname_skin_rsp err_code = " .. tostring(err_code) .. ", skin_id = " .. tostring(skin_id))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  ShowNotice(27736)
  local logic_roleInfo_nicknameframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_nicknameframe)
  logic_roleInfo_nicknameframe:ProcChangeRsp(skin_id)
end
function RoleInfoHandler.on_unlock_friend_nickname_skin_notify(skin_data, skin_id)
  log(bWriteLog and "RoleInfoHandler.on_unlock_friend_nickname_skin_notify skin_id = " .. tostring(skin_id))
  local logic_roleInfo_nicknameframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_nicknameframe)
  logic_roleInfo_nicknameframe:ProcUnlockNotify(skin_data, skin_id)
end
function RoleInfoHandler.send_get_chat_bubble_req()
  NetManager.SendPkg(1026825811)
end
function RoleInfoHandler.on_get_chat_bubble_rsp(err_code, chat_bubble_data, chat_bubble_cfg)
  log(bWriteLog and "RoleInfoHandler.on_get_chat_bubble_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_roleInfo_chatframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_chatframe)
  logic_roleInfo_chatframe:ProcChatListRsp(chat_bubble_data, chat_bubble_cfg)
end
function RoleInfoHandler.send_set_chat_bubble_req(bubble_id)
  log(bWriteLog and "RoleInfoHandler.send_set_chat_bubble_req bubble_id = " .. tostring(bubble_id))
  NetManager.SendPkg(1077891235, bubble_id)
end
function RoleInfoHandler.on_set_chat_bubble_rsp(err_code, bubble_id)
  log(bWriteLog and "RoleInfoHandler.on_set_chat_bubble_rsp err_code = " .. tostring(err_code) .. ", bubble_id = " .. tostring(bubble_id))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  ShowNotice(27736)
  local logic_roleInfo_chatframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_chatframe)
  logic_roleInfo_chatframe:ProcChangeRsp(bubble_id)
end
function RoleInfoHandler.on_unlock_chat_bubble_notify(chat_bubble_data, bubble_id)
  log(bWriteLog and "RoleInfoHandler.on_unlock_chat_bubble_notify bubble_id = " .. tostring(bubble_id))
  local logic_roleInfo_chatframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_chatframe)
  logic_roleInfo_chatframe:ProcUnlockNotify(chat_bubble_data, bubble_id)
end
local SET_SOCIAL_CARD_FRAME_ERR_TIPS = {
  [18100007] = 18010461,
  [18100008] = 18010462
}
function RoleInfoHandler.send_get_social_card_frame_req()
  log(bWriteLog and "RoleInfoHandler.send_get_social_card_frame_req")
  NetManager.SendPkg(1024446223)
end
function RoleInfoHandler.on_get_social_card_frame_rsp(err_code, frames)
  log(bWriteLog and "RoleInfoHandler.on_get_social_card_frame_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  local logic_roleInfo_socialcardframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_socialcardframe)
  logic_roleInfo_socialcardframe:proc_get_social_card_frame_rsp(frames)
end
function RoleInfoHandler.send_set_social_card_frame_req(frame_id)
  log(bWriteLog and "RoleInfoHandler.send_set_social_card_frame_req frame_id = " .. tostring(frame_id))
  NetManager.SendPkg(904570303, frame_id)
end
function RoleInfoHandler.on_set_social_card_frame_rsp(err_code, frame_id)
  log(bWriteLog and "RoleInfoHandler.on_set_social_card_frame_rsp err_code = " .. tostring(err_code) .. ", frame_id = " .. tostring(frame_id))
  if err_code ~= 0 then
    local tipsId = SET_SOCIAL_CARD_FRAME_ERR_TIPS[err_code]
    if tipsId then
      ShowNotice(tipsId)
    end
    return
  end
  local logic_roleInfo_socialcardframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_socialcardframe)
  logic_roleInfo_socialcardframe:proc_set_social_card_frame_rsp(frame_id)
end
function RoleInfoHandler.on_unlock_social_card_frame_notify(social_card_frame_data, frame_id)
  log_tree("RoleInfoHandler.on_unlock_social_card_frame_notify social_card_frame_data = ", social_card_frame_data)
  log(bWriteLog and "RoleInfoHandler.on_unlock_social_card_frame_notify frame_id = " .. tostring(frame_id))
  local logic_roleInfo_socialcardframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_socialcardframe)
  logic_roleInfo_socialcardframe:proc_unlock_social_card_frame_notify(social_card_frame_data, frame_id)
end
function RoleInfoHandler.on_del_social_card_frame_notify(frame_id)
  log(bWriteLog and "RoleInfoHandler.on_del_social_card_frame_notify frame_id = " .. tostring(frame_id))
  local logic_roleInfo_socialcardframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_socialcardframe)
  logic_roleInfo_socialcardframe:proc_del_social_card_frame_notify(frame_id)
end
local SET_PROFILE_FRAME_ERR_TIPS = {
  [18100005] = 18010459,
  [18100006] = 18010460
}
function RoleInfoHandler.send_get_profile_frame_req()
  log(bWriteLog and "RoleInfoHandler.send_get_profile_frame_req")
  NetManager.SendPkg(157294139)
end
function RoleInfoHandler.on_get_profile_frame_rsp(err_code, frames)
  log(bWriteLog and "RoleInfoHandler.on_get_profile_frame_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  local logic_roleInfo_profileframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_profileframe)
  logic_roleInfo_profileframe:proc_get_profile_frame_rsp(frames)
end
function RoleInfoHandler.send_set_profile_frame_req(frame_id)
  log(bWriteLog and "RoleInfoHandler.send_set_profile_frame_req frame_id = " .. tostring(frame_id))
  NetManager.SendPkg(135275115, frame_id)
end
function RoleInfoHandler.on_set_profile_frame_rsp(err_code, frame_id)
  log(bWriteLog and "RoleInfoHandler.on_set_profile_frame_rsp err_code = " .. tostring(err_code) .. ", frame_id = " .. tostring(frame_id))
  if err_code ~= 0 then
    local tipsId = SET_PROFILE_FRAME_ERR_TIPS[err_code]
    if tipsId then
      ShowNotice(tipsId)
    end
    return
  end
  local logic_roleInfo_profileframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_profileframe)
  logic_roleInfo_profileframe:proc_set_profile_frame_rsp(frame_id)
end
function RoleInfoHandler.on_unlock_profile_frame_notify(frame_id)
  log(bWriteLog and "RoleInfoHandler.on_unlock_profile_frame_notify frame_id = " .. tostring(frame_id))
  local logic_roleInfo_profileframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_profileframe)
  logic_roleInfo_profileframe:proc_unlock_profile_frame_notify(frame_id)
end
function RoleInfoHandler.on_del_profile_frame_notify(frame_id)
  log(bWriteLog and "RoleInfoHandler.on_del_profile_frame_notify frame_id = " .. tostring(frame_id))
  local logic_roleInfo_profileframe = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_profileframe)
  logic_roleInfo_profileframe:proc_del_profile_frame_notify(frame_id)
end
return RoleInfoHandler