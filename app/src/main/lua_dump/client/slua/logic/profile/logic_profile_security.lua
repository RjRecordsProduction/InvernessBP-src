local logic_profile_security = {}
function logic_profile_security.ProcRoleData(uid, roleData)
  if roleData == nil then
    return
  end
  if not LobbySystem.roleData.batch_check_region then
    return
  end
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    return
  end
  if LobbySystem.roleData.role_name_check_open and roleData.nickName_CN then
    log(bWriteLog and "logic_profile_security.ProcRoleData nickName = " .. roleData.nickName .. ", nickName_CN = " .. roleData.nickName_CN)
    roleData.nickName = roleData.nickName_CN
  end
  if LobbySystem.roleData.pic_url_check_open and roleData.picUrl_CN then
    log(bWriteLog and "logic_profile_security.ProcRoleData picUrl = " .. roleData.picUrl .. ", picUrl_CN = " .. roleData.picUrl_CN)
    roleData.picUrl = roleData.picUrl_CN
  end
end
function logic_profile_security.ProcRoleDataList(roleDataList)
  log(bWriteLog and "logic_profile_security.ProcRoleDataList")
  if roleDataList == nil then
    return
  end
  if not LobbySystem.roleData.batch_check_region then
    return
  end
  for k, v in pairs(roleDataList) do
    logic_profile_security.ProcRoleData(k, v)
  end
end
function logic_profile_security.ProcChat(uid, sender_name, chat_content)
  log(bWriteLog and "logic_profile_security.ProcChat")
  if not LobbySystem.roleData.batch_check_region then
    return sender_name
  end
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    return sender_name
  end
  if LobbySystem.roleData.role_name_check_open and chat_content.nickName_CN then
    sender_name = chat_content.nickName_CN
  end
  if LobbySystem.roleData.pic_url_check_open and chat_content.picUrl_CN then
    chat_content.url = chat_content.picUrl_CN
  end
  return sender_name
end
function logic_profile_security.ProcMergeChat(uid, chatData)
  log(bWriteLog and "logic_profile_security.ProcMergeChat")
  if chatData == nil then
    return
  end
  if not LobbySystem.roleData.batch_check_region then
    return
  end
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    return
  end
  if LobbySystem.roleData.role_name_check_open and chatData.chat_content.nickName_CN then
    chatData.sender_name = chatData.chat_content.nickName_CN
  end
  if LobbySystem.roleData.pic_url_check_open and chatData.chat_content.picUrl_CN then
    chatData.chat_content.url = chatData.chat_content.picUrl_CN
  end
end
function logic_profile_security.ProcOfflineChat(offlineMsg)
  log(bWriteLog and "logic_profile_security.ProcOfflineChat")
  if offlineMsg == nil then
    return
  end
  if not LobbySystem.roleData.batch_check_region then
    return
  end
  for k, v in pairs(offlineMsg) do
    if tonumber(v.send_uid) ~= tonumber(DataMgr.roleData.uid) then
      if LobbySystem.roleData.role_name_check_open and v.chat_content.nickName_CN then
        v.sender_name = v.chat_content.nickName_CN
      end
      if LobbySystem.roleData.pic_url_check_open and v.chat_content.picUrl_CN then
        v.chat_content.url = v.chat_content.picUrl_CN
      end
    end
  end
end
function logic_profile_security.ProcTeamInfo(teamInfo)
  log(bWriteLog and "logic_profile_security.ProcTeamInfo")
  if teamInfo == nil or teamInfo.members == nil then
    return
  end
  if not LobbySystem.roleData.batch_check_region then
    return
  end
  for k, v in pairs(teamInfo.members) do
    if tonumber(k) ~= tonumber(DataMgr.roleData.uid) then
      if LobbySystem.roleData.role_name_check_open and v.name_CN then
        v.name = v.name_CN
      end
      if LobbySystem.roleData.pic_url_check_open and v.pic_url_CN then
        v.pic_url = v.pic_url_CN
      end
    end
  end
end
function logic_profile_security.ProcTeamInvite(inviteInfo)
  log(bWriteLog and "logic_profile_security.ProcTeamInvite")
  if inviteInfo == nil then
    return
  end
  if not LobbySystem.roleData.batch_check_region then
    return
  end
  if LobbySystem.roleData.role_name_check_open and inviteInfo.playerName_CN then
    inviteInfo.playerName = inviteInfo.playerName_CN
  end
end
function logic_profile_security.MakeTestData()
  return "samizheng", "http://" .. FuncUtil.GetDomainByID(3366089) .. "/02.png"
end
return logic_profile_security