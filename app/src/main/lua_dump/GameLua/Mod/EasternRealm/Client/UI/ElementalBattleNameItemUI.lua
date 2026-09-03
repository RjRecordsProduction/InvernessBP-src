local ElementalBattleNameItemUI = {}
local EREnum = require("GameLua.Mod.EasternRealm.Gameplay.Config.EnumDefine")
local ElementalMap = {
  [EREnum.ElementType.Fire] = {
    Index = 0,
    BGPath = "/Game/Mod/EasternRealm/Arts/UI/NoAtlas/BattleResultShow/ZD_Image_Tips_Bg.ZD_Image_Tips_Bg"
  },
  [EREnum.ElementType.Nature] = {
    Index = 1,
    BGPath = "/Game/Mod/EasternRealm/Arts/UI/NoAtlas/BattleResultShow/ZD_Image_Tips_Bg_02.ZD_Image_Tips_Bg_02"
  },
  [EREnum.ElementType.Wind] = {
    Index = 2,
    BGPath = "/Game/Mod/EasternRealm/Arts/UI/NoAtlas/BattleResultShow/ZD_Image_Tips_Bg_03.ZD_Image_Tips_Bg_03"
  },
  [EREnum.ElementType.Water] = {
    Index = 3,
    BGPath = "/Game/Mod/EasternRealm/Arts/UI/NoAtlas/BattleResultShow/ZD_Image_Tips_Bg_04.ZD_Image_Tips_Bg_04"
  }
}
function ElementalBattleNameItemUI:Initialize()
end
function ElementalBattleNameItemUI:SetElementType(ElementType)
  if ElementalMap[ElementType] then
    self.Image_Bg:SetBrushfromPathAsync(ElementalMap[ElementType].BGPath, false)
    self.WidgetSwitcher_0:SetActiveWidgetIndex(ElementalMap[ElementType].Index)
  end
end
function ElementalBattleNameItemUI:PlayFadeIn()
  self:PlayUserWidgetAnimation(self.Fadein, 0, 1, 0, 1)
end
function ElementalBattleNameItemUI:SetPlayerName(PlayerName)
  self.TextBlock_0:SetText(PlayerName)
end
function ElementalBattleNameItemUI:OnDestroy()
  self:Dispose()
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
return class(CDelegateContainer, nil, ElementalBattleNameItemUI)