local GodTrialGeneralMapMark = {}
function GodTrialGeneralMapMark:OnUIBPCreate(TmpEventData, InWhichMap)
  self.end
function GodTrialGeneralMapMark:LuaUpdateMarkSize()
  local SizeX = self.OriginalSize.X
  local SizeY = self.OriginalSize.Y
  if self.InWhichMap == 2 then
    self:SetChangeSizePanel(SizeX, SizeY, true, true, 8)
  else
    SizeX = 5 * SizeX
    SizeY = 5 * SizeY
    self:SetChangeSizePanel(SizeX, SizeY, true, true, 8)
  end
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Client.Map.MapMark.CommonCountdownMapMark")
return class(object, nil, GodTrialGeneralMapMark)