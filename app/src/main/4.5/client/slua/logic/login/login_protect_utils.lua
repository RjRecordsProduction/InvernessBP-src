local LoginProtectUtils = {
  tbLoginInfo = {
    curLoginTimes = 0,
    preLoginTime = 0,
    preLoginSucTime = 0
  },
  loginInfoFileName = "SaveGames/loginInfoFile.json"
}
function LoginProtectUtils.LoadLoginInfoFile()
  local str = Client.LoadFileToString(LoginProtectUtils.loginInfoFileName)
  if str == "" then
    return
  end
  LoginProtectUtils.tbLoginInfo = json.decode(str) or LoginProtectUtils.tbLoginInfo
end
function LoginProtectUtils.SaveLoginInfoFile()
  local str = json.encode(LoginProtectUtils.tbLoginInfo)
  if str == "" then
    return
  end
  Client.SaveStringToFile(str, LoginProtectUtils.loginInfoFileName)
end
function LoginProtectUtils.GetLoginCd(times)
  if times <= 2 then
    return 0
  elseif times <= 5 then
    return 10
  else
    return 300
  end
end
function LoginProtectUtils.CheckCanLogin()
  if not Client.IsShipping() then
    return true
  end
  if Client.IsMatchNoAuthMode and Client.IsMatchNoAuthMode() then
    return true
  end
  LoginProtectUtils.LoadLoginInfoFile()
  local info = LoginProtectUtils.tbLoginInfo
  local bRet = true
  local bWrite = false
  local TimeUtil = require("client.common.time_util")
  local tNow = TimeUtil.OSTime()
  local cd = 0
  if 0 >= info.curLoginTimes then
    bRet = true
    bWrite = true
    info.curLoginTimes = 1
    info.preLoginTime = tNow
  else
    cd = LoginProtectUtils.GetLoginCd(info.curLoginTimes)
    if info.preLoginTime == 0 then
      bRet = true
      bWrite = true
      info.curLoginTimes = 1
      info.preLoginTime = tNow
    elseif info.preLoginTime <= info.preLoginSucTime then
      bRet = true
      bWrite = true
      info.curLoginTimes = 1
      info.preLoginTime = tNow
    else
      local tDis = tNow - info.preLoginTime
      if 0 < tDis and cd > tDis then
        bRet = false
        local tips = LocUtil.LocalizeResFormat(6804, tostring(cd - tDis))
        ShowNotice(tips)
      else
        bRet = true
        bWrite = true
        info.curLoginTimes = info.curLoginTimes + 1
        info.preLoginTime = tNow
      end
    end
  end
  if bWrite then
    LoginProtectUtils.SaveLoginInfoFile()
  end
  return bRet, cd
end
function LoginProtectUtils.RecordLoginFailTime()
  local TimeUtil = require("client.common.time_util")
  local tNow = TimeUtil.OSTime()
  local info = LoginProtectUtils.tbLoginInfo
  info.preLoginTime = tNow
  LoginProtectUtils.SaveLoginInfoFile()
end
function LoginProtectUtils.RecordLoginSucTime()
  local TimeUtil = require("client.common.time_util")
  local tNow = TimeUtil.OSTime()
  local info = LoginProtectUtils.tbLoginInfo
  info.curLoginTimes = 0
  info.preLoginSucTime = tNow
  LoginProtectUtils.SaveLoginInfoFile()
end
return LoginProtectUtils