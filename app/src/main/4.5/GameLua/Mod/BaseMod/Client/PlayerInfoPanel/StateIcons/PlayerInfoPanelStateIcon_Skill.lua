local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local PlayerInfoPanelStateIcon_Skill = {}
function PlayerInfoPanelStateIcon_Skill:OnShow()
  print(bWriteLog and "PlayerInfoPanelStateIcon_Skill_Debug_Msg:OnShow")
  self:RefreshUI()
end
function PlayerInfoPanelStateIcon_Skill:RegistEvents()
  print(bWriteLog and "PlayerInfoPanelStateIcon_Skill_Debug_Msg: RegistEvents")
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerController", self.RefreshUI, self)
end
function PlayerInfoPanelStateIcon_Skill:RefreshUI()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not MainControlBaseUI or not MainControlBaseUI:IsEvoGroundGameMode() then
    return
  end
  if PlayerController.InitialCharSkillList:Num() == 0 then
    return
  end
  local PlayerSkill = PlayerController.InitialCharSkillList:Get(0)
  if not PlayerSkill then
    return
  end
  self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local ItemCfg = CDataTable.GetTableData("character_skill", PlayerSkill)
  if not ItemCfg then
    return
  end
  self.UIRoot.Image_State:SetBrushFromPathAsync(ItemCfg.icon_fighting)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, PlayerInfoPanelStateIcon_Skill)