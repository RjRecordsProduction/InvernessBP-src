local MiniTVUtils = {}
local MiniTVConst = require("client.lobby_ue_object.Actor.MiniTV.MiniTVConst")
function MiniTVUtils.GetActionShowTime(action)
  if action.dialog.symbol ~= nil then
    return MiniTVConst.SymbolShowTime
  end
  return MiniTVConst.NormalShowTime
end
function MiniTVUtils.IsInCharacterBehind(locX, locY, charLocX, charLocY, rad)
  if 0 < locY then
    return false
  end
  if math.abs(locY - charLocY) > math.abs(locX - charLocX) * math.tan(math.rad((180 - rad) / 2)) then
    return true
  end
  return false
end
function MiniTVUtils.IsInCharacterFront(locX, locY, charLocX, charLocY, rad)
  if locY < 0 then
    return false
  end
  if math.abs(locY - charLocY) > math.abs(locX - charLocX) * math.tan(math.rad((180 - rad) / 2)) then
    return true
  end
  return false
end
function MiniTVUtils.EquipedLandPet()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local pet = TeamAvatarManager.GetPet()
  if not pet then
    return false
  end
  local petType = pet:GetPetType()
  pet:EnableRotation(false)
  if petType == ENUM_LOBBYPET_TYPE.TYPE_GYRFALCON or petType == ENUM_LOBBYPET_TYPE.TYPE_DOG then
    return false
  end
  return true
end
function MiniTVUtils.GetActorViewRatio(actor)
  local screenLocation = actor:GetActorNowScreenLocation()
  if not screenLocation then
    return 0, 0
  end
  local UIUtil = require("client.common.ui_util")
  local viewportSize = UIUtil.GetViewportSize()
  local xRatio = screenLocation.X / viewportSize.X
  local yRatio = screenLocation.Y / viewportSize.Y
  return xRatio, yRatio
end
return MiniTVUtils