local HelmetArmor = require("GameLua.Mod.BaseMod.Client.PlayerInfoPanel.HelmetArmor.HelmetArmorConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function HelmetArmor:RegistEvents()
  print(bWriteLog and "HelmetArmor_Debug_Msg: RegistEvents")
  self:AddUIMessageEvent("UIMsg_TakeDamageUpdateEquipmentDurability", self.UpdateEquipmentDurability, self)
  self:AddUIMessageEvent("UIMsg_AdaptFBTipsWithIPX", self.AdaptFBTipsWithIPX_Handle, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_SPECTATING_UI, self.HideHelmetArmorPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_COMPLETE_PLAYBACK_UI, self.HideHelmetArmorPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_LEAVE_SPECTATING_STATUS, self.ShowHelmetArmorPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_REINIT_UI_POSSESSONPET, self.CheckIsSpectator, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_REINIT_UI_UNPOSSESSONPET, self.CheckIsSpectator, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_TDM_ONPLAYER_DEAD, self.TDMHideHelmetArmorPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_TDM_ONPLAYER_RESPAWN, self.TDMShowHelmetArmorPanel, self)
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    self:AddControlEventByControl(uPlayerController, "OnReconnectResetUIByPlayerControllerStateDelegate", self.ItemUpdate_Handle, self)
    self:AddControlEventByControl(uPlayerController, "OnLocalCharacterHPChangeDel", self.UpdateEquipmentDurability, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SINGLE_ITEM_UPDATED_ARMOR_5, self.ItemUpdate_Handle, self)
  end
end
function HelmetArmor:ItemUpdate_Handle(_, _, uBackpackComponent, DefineID, bUpdateOrDelete)
  self:UpdateHelmetAndArmorLevel(uBackpackComponent, DefineID)
  self:UpdateEquipmentDurability(0, 0)
end
function HelmetArmor:AdaptFBTipsWithIPX_Handle()
  self.UIRoot.CanvasPanel_HelmetArmor:SetRenderTranslation(FVector2D(0, -20))
end
function HelmetArmor:TDMShowHelmetArmorPanel()
  self.bHideHelmetArmorUI = false
  self:ShowHelmetArmorPanel()
end
function HelmetArmor:TDMHideHelmetArmorPanel()
  self.bHideHelmetArmorUI = true
  self:HideHelmetArmorPanel()
end