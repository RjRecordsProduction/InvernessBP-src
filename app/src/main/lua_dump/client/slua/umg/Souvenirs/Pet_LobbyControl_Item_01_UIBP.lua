local Pet_LobbyControl_Item_01_UIBP = {}
function Pet_LobbyControl_Item_01_UIBP:OnInitialize()
  self.MileActionCD = 10000
  self.WolfThemeActionCD = 5000
  self.LastClickTime = 0
  self.TimerHandle = nil
end
function Pet_LobbyControl_Item_01_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Btn_PlayAction, self.OnClickedFlauntItem, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_CD, self.OnClickButtonCD, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Setting, self.OnClickButtonSetting, self)
  self:AddCommonEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_WOLFTHEME_EMOTE_CD, self.OnWolfThemeEmoteCDUpdate, self)
end
function Pet_LobbyControl_Item_01_UIBP:OnRefresh(data, selectIndex)
  local Expression_Util = require("client.slua.umg.Souvenirs.Expression_Util")
  self:SetWidgetVisible(self.UIRoot.Button_Setting, data.Type == Expression_Util.FlauntType.WolfTheme, true)
  if data.Type == Expression_Util.FlauntType.Pet then
    local UIUtil = require("client.common.ui_util")
    local iconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(data.ItemID, self.UIRoot.Image_Icon)
    self:SetTexture(self.UIRoot.ImgActionIcon, iconPath, {bHasAddKnownMissing = bHasAddKnownMissing})
    self.UIRoot.Button_CD:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:AddButtonCD()
  elseif data.Type == Expression_Util.FlauntType.MiliStone then
    local UIUtil = require("client.common.ui_util")
    local iconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(data.ItemID, self.UIRoot.Image_Icon)
    self:SetTexture(self.UIRoot.ImgActionIcon, iconPath, {bHasAddKnownMissing = bHasAddKnownMissing})
    self:AddButtonCD()
  elseif data.Type == Expression_Util.FlauntType.WolfTheme or data.Type == Expression_Util.FlauntType.Popularity then
    local UIUtil = require("client.common.ui_util")
    local iconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(data.ItemID, self.UIRoot.Image_Icon)
    self:SetTexture(self.UIRoot.ImgActionIcon, iconPath, {bHasAddKnownMissing = bHasAddKnownMissing})
    self.UIRoot.Button_CD:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:AddButtonCD()
  elseif data.Type == Expression_Util.FlauntType.CardCollection then
    local UIUtil = require("client.common.ui_util")
    local iconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(data.ItemID, self.UIRoot.Image_Icon)
    self:SetTexture(self.UIRoot.ImgActionIcon, iconPath, {bHasAddKnownMissing = bHasAddKnownMissing})
    self:AddButtonCD()
  end
  self:AddDownLoadUI()
  local parentUI = self:GetLoopScrollBoxParentUI()
  if parentUI and parentUI.actionID and parentUI.actionID == data.ItemID then
    self:OnClickedFlaunt()
    parentUI.actionID = 0
  end
end
function Pet_LobbyControl_Item_01_UIBP:AddDownLoadUI()
  local common_download_handler = require("client.slua.common.common_download_handler")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.ODPAK, {
    self.data.ItemID
  }, self, self.UIRoot.Panel_Download)
end
function Pet_LobbyControl_Item_01_UIBP:OnClickedFlauntItem()
  self:PlayAudio(sound_config.click_v1)
  self:OnClickedFlaunt()
end
function Pet_LobbyControl_Item_01_UIBP:OnClickedFlaunt()
  local data = self.data
  if not data then
    log(bWriteLog and "Pet_LobbyControl_Item_01_UIBP:OnClickedFlauntItem No Data")
    return
  end
  local TimeUtil = require("client.common.time_util")
  self.LastClickTime = TimeUtil.GetMiliseconds()
  local Expression_Util = require("client.slua.umg.Souvenirs.Expression_Util")
  if data.Type == Expression_Util.FlauntType.Pet then
    local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
    local PetData = logic_pet:GetPetDataIncludeInherit()
    log_tree("Pet_LobbyControl_Item_01_UIBP:OnClickedFlaunt. PetData ", PetData)
    if not PetData or not next(PetData) then
      ShowNotice(530022)
      return
    end
    local pet_show_module = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.pet_show_module)
    local isShow = pet_show_module:IsShowing()
    if isShow then
      ShowNotice(33020076)
      return
    end
    pet_show_module:CheckAndRequestPetShow()
    self:AddButtonCD()
    local ParentUI = self:GetLoopScrollBoxParentUI()
    if ParentUI and ParentUI.CloseExpressPopPanel then
      ParentUI:CloseExpressPopPanel()
    end
  elseif data.Type == Expression_Util.FlauntType.MiliStone or data.Type == Expression_Util.FlauntType.Popularity then
    local expression_util = require("client.slua.umg.Souvenirs.Expression_Util")
    expression_util.PlayExpression(data.ItemID)
    local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
    LobbyEmoteManager:RecordClickTime(data.ItemID)
    self:AddButtonCD()
  elseif data.Type == Expression_Util.FlauntType.WolfTheme then
    local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
    local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
    LobbyEmoteManager:RecordClickTime(ShowBrandConst.GeneralEmoteId)
    EventSystem:postEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_WOLFTHEME_EMOTE_CD)
    local ShowBrandUtils = require("client.slua.logic.showbrand.ShowBrandUtils")
    ShowBrandUtils.PrepareEmoteData(tonumber(DataMgr.roleData.uid), function()
      ShowBrandUtils.PlayEmote()
    end, nil, true)
  elseif data.Type == Expression_Util.FlauntType.CardCollection then
    local logic_card_collection = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_card_collection)
    local actionID = logic_card_collection:GetActionItemID()
    local expression_util = require("client.slua.umg.Souvenirs.Expression_Util")
    expression_util.PlayExpression(actionID)
    local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
    LobbyEmoteManager:RecordClickTime(data.ItemID)
    self:AddButtonCD()
  end
end
function Pet_LobbyControl_Item_01_UIBP:OnClickButtonCD()
  ShowNotice(LocUtil.LocalizeResFormat(49795, tostring(math.ceil(self:GetButtonCDInMS() / 1000))))
end
function Pet_LobbyControl_Item_01_UIBP:OnClickButtonSetting()
  self:PlayAudio(sound_config.click_v1)
  self:CloseSelf()
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  WardrobeLogicManager:Enter(wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute, wardrobe_macro.ENUM_WardrobeSubTabString.Enum_WardrobeSubTabString_ShowBrand)
end
function Pet_LobbyControl_Item_01_UIBP:AddButtonCD()
  self.UIRoot.Button_CD:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.UIRoot.TextBlock_CD:SetText(tostring(math.ceil(self:GetButtonCDInMS() / 1000)))
  if self.TimerHandle then
    self:RemoveTimer(self.TimerHandle)
  end
  self.TimerHandle = self:AddTimerLoop(0, function()
    local RemainTime = self:GetButtonCDInMS()
    if RemainTime <= 0 then
      self.UIRoot.Button_CD:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self:RemoveTimer(self.TimerHandle)
    else
      self.UIRoot.TextBlock_CD:SetText(tostring(math.ceil(RemainTime / 1000)))
    end
  end, -1, 0.3)
end
function Pet_LobbyControl_Item_01_UIBP:GetButtonCDInMS()
  local Expression_Util = require("client.slua.umg.Souvenirs.Expression_Util")
  local DataType = self.data and self.data.Type or Expression_Util.FlauntType.MiliStone
  if DataType == Expression_Util.FlauntType.Pet then
    local pet_show_module = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.pet_show_module)
    return pet_show_module:GetLobbyRemainCD()
  elseif DataType == Expression_Util.FlauntType.MiliStone or DataType == Expression_Util.FlauntType.Popularity then
    local TimeUtil = require("client.common.time_util")
    local CurTime = TimeUtil.GetMiliseconds()
    local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
    local LastClickTime = LobbyEmoteManager:GetLastClickTime(self.data.ItemID)
    return self.MileActionCD - (CurTime - LastClickTime)
  elseif DataType == Expression_Util.FlauntType.WolfTheme then
    local TimeUtil = require("client.common.time_util")
    local CurTime = TimeUtil.GetMiliseconds()
    local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
    local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
    local LastClickTime = LobbyEmoteManager:GetLastClickTime(ShowBrandConst.GeneralEmoteId)
    return self.WolfThemeActionCD - (CurTime - LastClickTime)
  elseif DataType == Expression_Util.FlauntType.CardCollection then
    local TimeUtil = require("client.common.time_util")
    local CurTime = TimeUtil.GetMiliseconds()
    local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
    local LastClickTime = LobbyEmoteManager:GetLastClickTime(self.data.ItemID)
    return self.MileActionCD - (CurTime - LastClickTime)
  end
end
function Pet_LobbyControl_Item_01_UIBP:OnWolfThemeEmoteCDUpdate()
  local DataType = self.data and self.data.Type
  local Expression_Util = require("client.slua.umg.Souvenirs.Expression_Util")
  if DataType ~= Expression_Util.FlauntType.WolfTheme then
    return
  end
  log(bWriteLog and "Pet_LobbyControl_Item_01_UIBP:OnWolfThemeEmoteCDUpdate")
  self:AddButtonCD()
end
function Pet_LobbyControl_Item_01_UIBP:OnActionEvent(_, _, id)
  if id == self.data.ItemID then
    self:OnClickedFlauntItem()
  end
end
function Pet_LobbyControl_Item_01_UIBP:OnClose()
  self.UIRoot.Button_CD:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.component.scroll_box_child_base")
local CUITemplate = class(ui_base, nil, Pet_LobbyControl_Item_01_UIBP)
return CUITemplate