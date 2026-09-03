local GodTrialGameplayUtil = require("GameLua.Mod.GodTrial.Gameplay.GodTrialGameplayUtil")
local EntireMapUI = {}
function EntireMapUI:RegistDelegateInLua()
  EntireMapUI.__super.RegistDelegateInLua(self)
  self.bDebug = true
  print(bWriteLog and string.format("EntireMapUI:RegistDelegateInLua GodTrial"))
  if slua.isValid(self.CurrentMapData_BP) and slua.isValid(self.CurrentMapData_BP.CurrentMapData) then
    local MapData = self.CurrentMapData_BP.CurrentMapData
    self:AddControlEvent(MapData, "FinaleChangeCurLocDelegate", self.OnFinalChangeCurLoc, self)
  end
end
function EntireMapUI:OnFinalChangeCurLoc(PlayerIndex, CurLoc, uPlayerState)
  GodTrialGameplayUtil.UpdateMapUIPlayerCurLocation(self, CurLoc, uPlayerState, "EntireMapUI", self.bDebug)
end
function EntireMapUI:ChangeMapTextureAndTags(MapTexturePath, MapScale, MapStandTag, bIsChangeTags)
  EntireMapUI.__super.ChangeMapTextureAndTags(self, MapTexturePath, MapScale, MapStandTag, bIsChangeTags)
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
local CEntireMapUIBase = require("GameLua.Mod.BaseMod.Client.Map.MapUI.EntireMapUI")
return class(CEntireMapUIBase, nil, EntireMapUI)