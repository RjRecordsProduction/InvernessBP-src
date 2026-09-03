local MultipleAvatarManager = {
  Const = {
    SHOW_POSITION = {
      x = 70,
      y = 0,
      z = 90
    },
    HIDE_POSITION = {
      x = 70,
      y = 0,
      z = 10000
    },
    _showRotation = {
      Roll = 0,
      Pitch = 0,
      Yaw = 0
    },
    _petBasePosition = {
      x = 50,
      y = 0,
      z = -91
    },
    _petBaseRotation = {
      x = 0,
      y = 0,
      z = 90
    }
  },
  _storeEquipments = {}
}
function MultipleAvatarManager.CreateMultipleAvatar(avatarData, showPosition, itemIDList, hidePosition)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatarManager] MultipleAvatarManager.CreateMultipleAvatar(%s, %s, %s, %s)", avatarData, showPosition, itemIDList, hidePosition))
  local MultipleAvatar_C = require("client.logic.avatar.MultipleAvatar")
  local gender, headid
  if avatarData then
    gender = avatarData.gamegender
    headid = avatarData.headid
  end
  local getTime, startTime
  if AvatarData.OpenTimeTracer and not Client.IsShipping() then
    getTime = slua.getMicroseconds
    startTime = getTime()
  end
  local multiAvatar = MultipleAvatar_C(gender, headid, avatarData, showPosition, itemIDList, hidePosition)
  if AvatarData.OpenTimeTracer and not Client.IsShipping() then
    local endTime = getTime()
    log(bWriteLog and string.format("TimeTracer [Avatar][LobbyAvatar][ModelDisplayer.CreateMultipleAvatar] bSync=true Pool=false time:[%.3fms]", (endTime - startTime) / 1000))
  end
  log(bWriteLog and "[LobbyAvatar][MultipleAvatarManager] multiAvatar:" .. tostring(multiAvatar))
  return multiAvatar
end
function MultipleAvatarManager.CreateMyAvatar(showPosition)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatarManager] MultipleAvatarManager.CreateMyAvatar(%s)", showPosition))
  local avatar = MultipleAvatarManager.CreateMultipleAvatar(DataMgr.avatarData)
  avatar:SetShowPosition(showPosition.x, showPosition.y, showPosition.z)
  avatar:CopyMyEquipments(true)
  return avatar
end
return MultipleAvatarManager