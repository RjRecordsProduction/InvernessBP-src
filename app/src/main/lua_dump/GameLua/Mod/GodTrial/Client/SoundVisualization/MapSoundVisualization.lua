local math = require("math")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local MapSoundVisualization = {}
function MapSoundVisualization:RegistEvents()
  print(bWriteLog and "MapSoundVisualization:RegistEvents")
  MapSoundVisualization.__super.RegistEvents(self)
end
function MapSoundVisualization:AddCustomVoiceKey(Character, PosVector, ShowTime, IsWeapon, IsSlience, Weapon, isExplosion, NowIndex, CustomVoiceKey)
  local CustomIconPath
  local CustomShowTimes = 1
  if CustomVoiceKey == "CentaurArrow" then
    CustomIconPath = "/Game/Library/Res/AI/Centaur/Arts/UI/Atlas/Frames/ZD_icon_Centaur_png.ZD_icon_Centaur_png"
    CustomShowTimes = 2
  end
  print(bWriteLog and "MapSoundVisualization:AddBaseCharater IsSlience : " .. tostring(IsSlience))
  if NowIndex < 0 or NowIndex > self.MaxSmallTipsCount then
    return
  end
  if not self.SmallImageList[NowIndex] then
    self.SmallImageList[NowIndex] = {}
  end
  if slua.isValid(Character) then
    if not self:CheckNeedShowVocie(Character) then
      return
    end
    if self.CharacterVoiceIndex[Character] then
      self:HideImage(self.CharacterVoiceIndex[Character])
    end
    self.CharacterVoiceIndex[Character] = NowIndex
    self.SmallImageList[NowIndex].  end
  local NowDistance = PosVector:Size()
  if NowDistance <= 0 then
    NowDistance = 1
  end
  if IsWeapon then
    if isExplosion then
      if NowDistance > self.ExplosionNoticeDistance then
        return
      end
      local Alpha = self:ComputeAlpha(self.ExplosionNoticeDistance, NowDistance)
      self:OnShowImage(NowIndex, Alpha, CustomIconPath, false, CustomShowTimes)
    elseif IsSlience then
      if NowDistance > self.SlienceNoticeDistance then
        return
      end
      local Alpha = self:ComputeAlpha(self.SlienceNoticeDistance, NowDistance)
      self:OnShowImage(NowIndex, Alpha, CustomIconPath, true, CustomShowTimes)
    elseif NowDistance <= self.ShotNoticeDistance then
      local maxDistance = self:ModifyWeaponShowDistance(WeaponID, false)
      local Alpha = self:ComputeAlpha(self.ShotNoticeDistance, NowDistance, self.MinWeaponShowAlpha)
      self:OnShowImage(NowIndex, Alpha, CustomIconPath, false, CustomShowTimes)
    end
    if slua.isValid(Weapon) then
      self.UIRoot:CheckSendShootRPC(Weapon, PosVector, CustomShowTimes, IsSlience)
    end
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_VOICECHECK_INFO, NowIndex, Character, PosVector, IsWeapon, IsSlience, WeaponID, isExplosion)
end
function MapSoundVisualization:OnShowImage(Index, Alpha, iconPath, IsSlience, ShowTime)
  MapSoundVisualization.__super.OnShowImage(self, Index, Alpha, iconPath, IsSlience, ShowTime)
end
local class = require("class")
local MapSoundVisualizationBase = require("GameLua.Mod.BaseMod.Client.SoundVisualization.MapSoundVisualization")
return class(MapSoundVisualizationBase, nil, MapSoundVisualization)