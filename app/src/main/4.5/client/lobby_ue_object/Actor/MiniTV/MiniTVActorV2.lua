local MiniTVUtils = require("client.lobby_ue_object.Actor.MiniTV.MiniTVUtils")
local MiniTVConst = require("client.lobby_ue_object.Actor.MiniTV.MiniTVConst")
local SAUtils = require("client.slua.logic.sa.SAUtils")
local StateNames = MiniTVConst.StateNames
local UIUtil = require("client.common.ui_util")
local KismetMathLibrary = import("KismetMathLibrary")
local MAGIC_SCREEN_Y_OFFSET = 0.12388193202146691
local MiniTVActorV2 = {}
function MiniTVActorV2:ctor()
  self.bUseEZDrag = false
end
function MiniTVActorV2:handleDrag(diffX, diffY, x, y)
  local MiniTV_Actor_Limit_Area_Tools = require("client.lobby_ue_object.Actor.MiniTV.MiniTV_Actor_Limit_Area_Tools")
  if MiniTV_Actor_Limit_Area_Tools.CheckLimitAreaIndex(x, y) > 0 then
    log(bWriteLog and "MiniTVActorV2:handleDrag limit")
    return
  end
  y = y + MAGIC_SCREEN_Y_OFFSET * UIUtil.GetViewportSize().Y
  local screenPos = FVector2D(x, y)
  local worldPosition, worldDirection = UIUtil.DeprojectScreenToWorld(screenPos)
  if not worldPosition or not worldDirection then
    return
  end
  local planeOrigin = FVector(0, MiniTVConst.INIT_LOCATION_Y, 0)
  local planeNormal = FVector(0, 1, 0)
  local lineEnd = worldPosition + worldDirection * 10000
  local bHasIntersection, _, intersectionPoint = KismetMathLibrary.LinePlaneIntersection_OriginNormal(worldPosition, lineEnd, planeOrigin, planeNormal, 0, FVector())
  if bHasIntersection and intersectionPoint then
    self.locationX = intersectionPoint.X
    self.locationY = MiniTVConst.INIT_LOCATION_Y
    if intersectionPoint.Z < MiniTVConst.INIT_LOCATION_Z then
      self.locationZ = MiniTVConst.INIT_LOCATION_Z
    else
      self.locationZ = intersectionPoint.Z
    end
    self:K2_SetActorLocation(FVector(self.locationX, self.locationY, self.locationZ), false, nil, false)
    self:SetDropHigh(self.locationZ > MiniTVConst.HIGH_DRAG_THRESHOLD)
  end
end
function MiniTVActorV2:KeepMoveOnPet()
  log(bWriteLog and "MiniTVActorV2:KeepMoveOnPet - V2 version does not handle walk state")
end
function MiniTVActorV2:PlayEdgeAnimEvent()
  log(bWriteLog and "MiniTVActorV2:PlayEdgeAnimEvent - Play edge animation only")
  if self.isPressed then
    return
  end
  self:ChangeState(StateNames.FixLocation)
end
function MiniTVActorV2:KeepMove()
  printf("MiniTVActorV2:KeepMove - V2 version does not handle walk state")
  if self.isPressed then
    return
  end
  self:ChangeState(StateNames.FixLocation)
end
function MiniTVActorV2:RandomEvent()
  if UIManager.IsUIShow(UIManager.UI_Config.SmartAssistantV2_RobotBubble_Item_UIBP) then
    printf("MiniTVActorV2:RandomEvent - ignore by showing bubble")
    return false
  end
  if self.isPressed then
    printf("MiniTVActorV2:RandomEvent - ignore by is pressed")
    return false
  end
  if GameStatus.IsInLobbyOrMainCity() then
  else
    printf("MiniTVActorV2:RandomEvent - ignore by not in lobby or main city")
    return false
  end
  if SAUtils.GetAssistantType() == 2 then
    printf("MiniTVActorV2:RandomEvent - ignore by assistant type is 2")
    return false
  end
  return self:OnRecvAction()
end
local class = require("class")
local MiniTVActorClass = require("client.lobby_ue_object.Actor.MiniTV.MiniTVActor")
return class(MiniTVActorClass, nil, MiniTVActorV2)