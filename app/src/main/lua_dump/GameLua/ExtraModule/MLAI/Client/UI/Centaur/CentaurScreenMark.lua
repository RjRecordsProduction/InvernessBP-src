local CentaurScreenMark = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function CentaurScreenMark:OnActorBindUI(BindActor, ID)
  print(bWriteLog and "CentaurScreenMark:OnActorBindUI", BindActor, ID)
  CentaurScreenMark.__super.OnActorBindUI(self, BindActor, ID)
  self.uCache  self.CacheBindend
function CentaurScreenMark:OnUpdateState(CustomInt, CustomFloat, CustomString)
  CentaurScreenMark.__super.OnUpdateState(self, CustomInt, CustomFloat, CustomString)
  self:UpdateIconByTeammateIndex(CustomFloat)
end
function CentaurScreenMark:UpdateIconByTeammateIndex(TeammateIndex)
  print(bWriteLog and "CentaurScreenMark:UpdateIconByTeammateIndex", TeammateIndex)
  if not self.CacheBindID then
    return
  end
  TeammateIndex = TeammateIndex or 0
  local ID = self.CacheBindID
  local util = require("client.slua_ui_framework.util")
  local ScreenMarkConfig = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
  if ScreenMarkConfig and ScreenMarkConfig[ID] and ScreenMarkConfig[ID].CommonMarkConfig then
    local CommonMarkConfig = ScreenMarkConfig[ID].CommonMarkConfig
    if CommonMarkConfig.IconListDiffByTeamIndex then
      local nTeamIndex = TeammateIndex
      if self.Image_Icon and CommonMarkConfig.IconListDiffByTeamIndex[nTeamIndex] then
        util.SetTexture(self.Image_Icon, CommonMarkConfig.IconListDiffByTeamIndex[nTeamIndex])
      end
    end
  end
end
local class = require("class")
local CommonActorScreenMarkUI = require("GameLua.Mod.BaseMod.Client.ScreenMarkUI.CommonActorScreenMarkUI")
return class(CommonActorScreenMarkUI, nil, CentaurScreenMark)