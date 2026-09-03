local Personalization_Opening_UIBP = {}
function Personalization_Opening_UIBP:ctor(_, _, _)
  self.bUIShow = true
end
function Personalization_Opening_UIBP:OnInitialize()
  Personalization_Opening_UIBP.__super.OnInitialize(self)
  self.curLevelName = nil
end
function Personalization_Opening_UIBP:RegistEvents()
  Personalization_Opening_UIBP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_OPENING_UPDATE, self.UpdateAll, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Preview, self.OnButtonHideClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Show, self.OnButtonShowClick, self)
end
function Personalization_Opening_UIBP:OnPostInitialize()
  Personalization_Opening_UIBP.__super.OnPostInitialize(self)
  self.UIRoot.Text_Flag:SetText(LocUtil.GetLocalizeResStr(85709))
  self.jumpSelectItemId = nil
end
function Personalization_Opening_UIBP:OnClose()
  self:ShowUIExceptHideAndReplay(true)
  self:ClearOpeningUI()
  Personalization_Opening_UIBP.__super.OnClose(self)
end
function Personalization_Opening_UIBP:SwitchUIStatus()
  log(bWriteLog and "Personalization_Opening_UIBP:SwitchUIStatus current status = " .. tostring(self.bUIShow))
  self.bUIShow = not self.bUIShow
  self:ShowUIExceptHideAndReplay(self.bUIShow)
end
function Personalization_Opening_UIBP:ShowUIExceptHideAndReplay(bShow)
  log(bWriteLog and "Personalization_Opening_UIBP:ShowUIExceptHideAndReplay")
  self:SetWidgetVisible(self.UIRoot.Personalization_Desc_Item, bShow)
  self:SetWidgetVisible(self.UIRoot.Border_0, bShow)
  self:SetWidgetVisible(self.UIRoot.Button_Show, not bShow, true)
  local Personalization_UIBP = UIManager.GetUI(UIManager.UI_Config.Personalization_UIBP)
  if Personalization_UIBP then
    Personalization_UIBP:SetWidgetVisible(Personalization_UIBP.UIRoot.Common_Tab_Vertical_LevelTwo_Icon_UIBP, bShow)
    Personalization_UIBP:SetWidgetVisible(Personalization_UIBP.UIRoot.Image_mask_1, bShow)
    Personalization_UIBP:SetWidgetVisible(Personalization_UIBP.UIRoot.Image_mask_2, bShow)
  end
  local Lobby_NewRoleInfo_Mgr_UIBP = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  if Lobby_NewRoleInfo_Mgr_UIBP then
    Lobby_NewRoleInfo_Mgr_UIBP:SetWidgetVisible(Lobby_NewRoleInfo_Mgr_UIBP.UIRoot.CanvasPanel_11, bShow)
    Lobby_NewRoleInfo_Mgr_UIBP:SetWidgetVisible(Lobby_NewRoleInfo_Mgr_UIBP.UIRoot.Common_Tab_Vertical_LevelOne_Text_UIBP, bShow)
  end
end
function Personalization_Opening_UIBP:UpdateItemReddot(itemData, index)
  local logic_roleInfo_opening = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_opening)
  if logic_roleInfo_opening:HasRedDotByID(itemData.ID) then
    logic_roleInfo_opening:ReadRedDot(itemData.ID)
  end
end
function Personalization_Opening_UIBP:InitItemGrid()
  self.ItemGrid = self:InitScrollBox(self.UIRoot.LoopScrollGrid_Frame)
  self.ItemClickCtrlName = "Button_Frame"
end
function Personalization_Opening_UIBP:GetItemList()
  local logic_roleInfo_opening = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_opening)
  local openingList = logic_roleInfo_opening:GetOpeningList()
  if not openingList then
    log(bWriteLog and "Personalization_Opening_UIBP:GetItemList nil carte frame list")
    return
  end
  if self.isCheckOwned then
    local list = {}
    for _, v in ipairs(openingList) do
      if logic_roleInfo_opening:IsHaveOpeningItem(v.ID) then
        table.insert(list, v)
      end
    end
    return list
  end
  return openingList
end
function Personalization_Opening_UIBP:UpdateAll()
  self:RefreshItemGrid(1)
end
function Personalization_Opening_UIBP:UpdateSelectedItemInfo(itemData)
  if not itemData then
    log(bWriteLog and "Personalization_Opening_UIBP:UpdateSelectedItemInfo nil item data for right display")
    return
  end
  local logic_roleInfo_opening = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_opening)
  local curSelectID = logic_roleInfo_opening:GetEquipedOpeningID()
  self:PlayOpeningAnimation(itemData.BPPath, itemData.SoundID, tonumber(itemData.AnimationTimeWhenFinish))
  local param = self:GenCommonItemParam()
  param.itemID = itemData.ID
  param.name = itemData.OpeningName
  param.extraInfo = LocUtil.LocalizeResFormat(itemData.ObtainDescID)
  param.expireTime = logic_roleInfo_opening:GetOpeningExpireTime(itemData.ID)
  local isHave = logic_roleInfo_opening:IsHaveOpeningItem(itemData.ID)
  if isHave then
    if itemData.ID == curSelectID then
      param.buttonStyle = ENUM_Button_Style.Unload
    else
      param.buttonStyle = ENUM_Button_Style.Use
    end
  elseif itemData.HideJumpTime and itemData.HideJumpTime ~= "" then
    local TimeUtil = require("client.common.time_util")
    if TimeUtil.CheckAfterTimeStr(itemData.HideJumpTime) then
      param.buttonStyle = ENUM_Button_Style.None
    elseif itemData.ObtainJumpLink and itemData.ObtainJumpLink ~= "" then
      param.buttonStyle = ENUM_Button_Style.Go
    else
      param.buttonStyle = ENUM_Button_Style.None
    end
  end
  return param
end
function Personalization_Opening_UIBP:OnRefreshGridItem(widget, index)
  if not widget then
    log(bWriteLog and "Personalization_Opening_UIBP:OnRefreshGridItem nil widget for index: " .. tostring(index))
    return
  end
  local itemData = self.ItemGrid:GetItemData(index)
  if not itemData then
    log(bWriteLog and "Personalization_Opening_UIBP:OnRefreshGridItem nil item data for index: " .. tostring(index))
    return
  end
  local logic_roleInfo_opening = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_opening)
  if itemData.IconPath ~= "" then
    self:SetTexture(widget.Image_Frame, itemData.IconPath)
    self:SetWidgetVisible(widget.Image_Frame, true)
  else
    self:SetWidgetVisible(widget.Image_Frame, false)
  end
  local isCurrentBG = logic_roleInfo_opening:IsCurrentEquipedOpening(itemData.ID)
  local bRed = logic_roleInfo_opening:HasRedDotByID(itemData.ID)
  self:SetWidgetVisible(widget.Image_Select, index == self.ItemGrid:GetSelectIndex())
  self:SetWidgetVisible(widget.Image_Reddot, bRed)
  self:SetWidgetVisible(widget.Image_Using, isCurrentBG)
  local bHaveBG = logic_roleInfo_opening:IsHaveOpeningItem(itemData.ID)
  widget.WidgetSwitcher_1:SetActiveWidgetIndex(bHaveBG and 1 or 0)
  self:SetWidgetVisible(widget.Image_bg, not bHaveBG)
  local showTime = logic_roleInfo_opening:GetOpeningExpireTime(itemData.ID)
  self:SetWidgetVisible(widget.Image_LimitedTime, showTime and 1 < showTime)
end
function Personalization_Opening_UIBP:IsLoadAvatarScene()
  return false
end
function Personalization_Opening_UIBP:HandleButtonUse()
  log(bWriteLog and "Personalization_Opening_UIBP:HandleButtonUse")
  local itemData = self.ItemGrid:GetItemData(self.ItemGrid:GetSelectIndex())
  if not itemData then
    log(bWriteLog and "Personalization_Opening_UIBP nil item data: " .. tostring(self.ItemGrid:GetSelectIndex()))
    return
  end
  local logic_roleInfo_opening = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_opening)
  logic_roleInfo_opening:send_set_social_info_bg_req(itemData.ID)
end
function Personalization_Opening_UIBP:HandleButtonUnload()
  log(bWriteLog and "Personalization_Opening_UIBP:HandleButtonUnload")
  local logic_roleInfo_opening = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_opening)
  logic_roleInfo_opening:send_set_social_info_bg_req(nil)
end
function Personalization_Opening_UIBP:HandleButtonGo()
  log(bWriteLog and "Personalization_Opening_UIBP:HandleButtonGo")
  local itemData = self.ItemGrid:GetItemData(self.ItemGrid:GetSelectIndex())
  if not itemData then
    log(bWriteLog and "Personalization_Opening_UIBP nil item data: " .. tostring(self.ItemGrid:GetSelectIndex()))
    return
  end
  if itemData.ObtainJumpLink and itemData.ObtainJumpLink ~= "" then
    local RoleInfoBigAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_BigAvatar")
    if RoleInfoBigAvatarSystem.IsShow() then
      RoleInfoBigAvatarSystem.CloseUI()
    end
    GlobalData.JumpUrl(itemData.ObtainJumpLink)
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CLOSE_ALL)
  end
end
function Personalization_Opening_UIBP:IsJumpSelectItem(itemData)
  if not (self.jumpSelectItemId and itemData) or not itemData.ID then
    return false
  end
  return itemData.ID == self.jumpSelectItemId
end
function Personalization_Opening_UIBP:OnRefreshEmpty()
  self:ClearOpeningUI()
end
function Personalization_Opening_UIBP:OnButtonHideClick()
  log(bWriteLog and "Personalization_Opening_UIBP:OnButtonHideClick")
  self:PlayAudio(sound_config.click_v1)
  self:SwitchUIStatus()
end
function Personalization_Opening_UIBP:OnButtonShowClick()
  log(bWriteLog and "Personalization_Opening_UIBP:OnButtonShowClick")
  self:PlayAudio(sound_config.click_v1)
  self:SwitchUIStatus()
end
function Personalization_Opening_UIBP:PlayOpeningAnimation(bpPath, soundID, animationTimeWhenFinish)
  self:ClearOpeningUI()
  local parentUI = self:GetParentUI()
  if parentUI then
    local extraData = {
      bPlayOnce = true,
      animationTimeWhenFinish = animationTimeWhenFinish and 0 < animationTimeWhenFinish and animationTimeWhenFinish or 1,
          }
    self.openingUI = parentUI:CreateChildWindowWithBpPath("CanvasPanel_IPX", UIManager.UI_Config.Lobby_RoleInfo_EffectSkin_Item_UIBP, bpPath, "fadein", extraData)
  end
end
function Personalization_Opening_UIBP:ClearOpeningUI()
  if self.openingUI then
    self.openingUI:Close()
    self.openingUI = nil
  end
end
local class = require("class")
local ui_base = require("client.slua.umg.roleInfoNew.Personalization_BaseItem_UIBP")
local CPersonalization_Opening_UIBP = class(ui_base, nil, Personalization_Opening_UIBP)
return CPersonalization_Opening_UIBP