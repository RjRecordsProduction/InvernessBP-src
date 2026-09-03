local GuestFind = {}
local roleInfo = {}
function GuestFind.OnModePostSwitch(_, _, status)
  if status.current == GameStatus.Login then
    log(bWriteLog and "  : GuestFind.OnModePostSwitch   Login")
  end
end
function GuestFind.FindSuccess()
  log(bWriteLog and "  : FindSuccess")
  roleInfo.isFind = true
end
function GuestFind.ShowSuccess()
  log(bWriteLog and "  : GuestFind.ShowSuccess")
  log_tree("  : roleInfo", roleInfo)
  if roleInfo and roleInfo.isFind then
    log(bWriteLog and "  : ShowSuccess FindSuccess")
    UIManager.ShowUI(UIManager.UI_Config.guest_find_password_popup)
    GuestFind.ClearData()
  end
end
function GuestFind.OnGetRoleInfo(iTopId, nickName, level, uid)
  log(bWriteLog and "  : iTopId" .. tostring(iTopId))
  log(bWriteLog and "  : nickName" .. tostring(nickName))
  log(bWriteLog and "  : level" .. tostring(level))
  log(bWriteLog and "  : uid" .. tostring(uid))
  roleInfo.  roleInfo.  roleInfo.  roleInfo.  UIManager.CloseUI(UIManager.UI_Config.guest_find_password_post)
  UIManager.ShowUI(UIManager.UI_Config.guest_find_password_result, roleInfo)
end
function GuestFind.GetRoleInfo()
  return roleInfo
end
function GuestFind.ClearData()
  roleInfo = {}
end
return GuestFind