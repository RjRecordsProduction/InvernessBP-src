local GodTrialGameplayUtil = require("GameLua.Mod.GodTrial.Gameplay.GodTrialGameplayUtil")
local MiniMapUI = {}
function MiniMapUI:RegistDelegateInLua()
  MiniMapUI.__super.RegistDelegateInLua(self)
  print(bWriteLog and string.format("MiniMapUI:RegistDelegateInLua GodTrial"))
  if slua.isValid(self.CurrentMapData_BP) and slua.isValid(self.CurrentMapData_BP.CurrentMapData) then
    local MapData = self.CurrentMapData_BP.CurrentMapData
    self:AddControlEvent(MapData, "FinaleChangeCurLocDelegate", self.OnFinalChangeCurLoc, self)
  end
end
function MiniMapUI:OnFinalChangeCurLoc(PlayerIndex, CurLoc, uPlayerState)
  GodTrialGameplayUtil.UpdateMapUIPlayerCurLocation(self, CurLoc, uPlayerState, "MiniMapUI", self.bDebug)
end
function MiniMapUI:TrySetMiniMapLockTarget(LockTargetLocation)
  if not self.SetTargetPosition or not self.SetMiniMapState then
    return
  end
  local LastState = self.LastMiniMapLockState
  if LockTargetLocation ~= nil then
    if not (LastState and LastState.bLocked) or LastState.X ~= LockTargetLocation.X or LastState.Y ~= LockTargetLocation.Y or LastState.Z ~= LockTargetLocation.Z then
      self:SetTargetPosition(LockTargetLocation)
      self:SetMiniMapState(false, true)
      self.LastMiniMapLockState = {
        bLocked = true,
        X = LockTargetLocation.X,
        Y = LockTargetLocation.Y,
        Z = LockTargetLocation.Z
      }
    end
  elseif not LastState or LastState.bLocked then
    self:SetMiniMapState(false, false)
    self.LastMiniMapLockState = {bLocked = false}
  end
end
function MiniMapUI:ChangeMapTextureAndTags(MapTexturePath, MapScale, MapStandTag, bIsChangeTags)
  MiniMapUI.__super.ChangeMapTextureAndTags(self, MapTexturePath, MapScale, MapStandTag, bIsChangeTags)
  if not self.HighDropWidget or not self.HighDropWidget.UIRoot then
    return
  end
  local bBaltic = MapStandTag == ""
  if bBaltic then
    self.HighDropWidget.UIRoot.AirAttackArea:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.HighDropWidget.UIRoot.AirAttackArea:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
local class = require("class")
local CMiniMapUIBase = require("GameLua.Mod.BaseMod.Client.Map.MapUI.MiniMapUI")
return class(CMiniMapUIBase, nil, MiniMapUI)