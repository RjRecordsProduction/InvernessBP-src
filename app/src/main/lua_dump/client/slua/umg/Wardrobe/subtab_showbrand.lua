local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
local bLocalTest = false
local subtab_showbrand = {}
function subtab_showbrand:ctor()
  self.itemList = {}
  self.selectIconIndex = 1
  self.selectTextIndex = 3
  self.TemlateID = 0
  self.switchTimer = nil
end
function subtab_showbrand:OnShow()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatar = TeamAvatarManager.GetMainAvatar()
  if avatar then
    avatar:SetRotation(0, 0, 0)
  end
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  LogicPeakGame:ReqPeakGameAllRatingInfo(false)
  LogicPeakGame:ReqPeakGameInfo(false)
  subtab_showbrand.__super.OnShow(self)
end
function subtab_showbrand:OnInitialize()
  subtab_showbrand.__super.OnInitialize(self)
  self.LoopScrollBox = self.LoopScrollGrid_Normal
  self.LoopScrollBox:SetRefreshItemCallback(self.OnRefreshListItem, self)
  local wardobe = UIManager.GetUI(UIManager.UI_Config.wardrobe)
  self.child_Placard_MedalSelection_UIBP = self:CreateChildWindow(wardobe.UIRoot.CanvasPanel_AttachBrandBottom, UIManager.UI_Config.Placard_MedalSelection_UIBP)
  local logic_lobby_social = require("client.slua.logic.lobby.Left.logic_lobby_social")
  logic_lobby_social.get_role_combat_info_req(DataMgr.roleData.uid)
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  LogicShowBrand:SetPreviewModeId(nil)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local cfg = LogicShowBrand.activeBrand and LogicShowBrand:GetActiveBrandCfg()
  local isHave = cfg and wardrobe_data:HasValidItem(tonumber(cfg.ItemID))
  if isHave then
    self:initItemList()
  else
    LogicShowBrand:GetOrRequestBrandInfo(DataMgr.roleData.uid, nil, function(_)
      local _ = slua.isValid(self.UIRoot) and self:initItemList()
    end)
  end
end
function subtab_showbrand:RegistEvents()
  subtab_showbrand.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOWBRAND_CLICK, self.OnClickedSlot, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOWBRAND_QUERY_RESP, self.OnShowBrandQueryResp, self)
end
function subtab_showbrand:OnPostInitialize()
  subtab_showbrand.__super.OnPostInitialize(self)
end
function subtab_showbrand:OnSwitchToSubtab(TemplateID, tabIndex)
  if TemplateID == 1 then
    if tabIndex == 1 then
      self:OnClickedIconSlot(self.selectIconIndex, false)
    elseif tabIndex == 2 then
      self:OnClickedTextSlot(self.selectTextIndex, false)
    end
  elseif TemplateID == 2 then
  elseif TemplateID == 3 then
    self.child_Placard_MedalSelection_UIBP:OnSwitchToPlacardTitleSlot(tabIndex)
  elseif TemplateID == 7 then
    self:OnClickedIconSlot(self.selectIconIndex, false)
  end
end
function subtab_showbrand:OnClickedSlot(_, _, type, slot_index)
  if type == 1 then
    self:OnClickedIconSlot(slot_index, false)
  elseif type == 2 then
    self:OnClickedTextSlot(slot_index, false)
  end
end
function subtab_showbrand:OnClickedIconSlot(slot_index, bClick)
  if bClick == nil then
    bClick = true
  end
  if bClick then
    self:PlayAudio(sound_config.click_v1)
  end
  self.selectIconIndex = slot_index
  printf("subtab_showbrand:OnClickedIconSlot slot_index: %d", slot_index)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOWBRAND_EDIT, 1, slot_index)
  self.child_Placard_MedalSelection_UIBP:OnSwitchToIconTab(slot_index)
end
function subtab_showbrand:OnClickedTextSlot(slot_index, bClick)
  if bClick == nil then
    bClick = true
  end
  if bClick then
    self:PlayAudio(sound_config.click_v1)
  end
  self.selectTextIndex = slot_index
  printf("subtab_showbrand:OnClickedTextSlot slot_index: %d", slot_index)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOWBRAND_EDIT, 2, slot_index)
  self.child_Placard_MedalSelection_UIBP:OnSwitchToTextTab(slot_index)
end
function subtab_showbrand:initItemList()
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  self.itemList = {}
  local itemInfo
  local CurPage = self.subTabConfig.pageId
  local SubPage = self.subTabConfig.subTabId
  local depotItemList = WardrobeDataManager:GetArrayHallDepotItemInfo()
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(depotItemList) do
    if WardrobeLogicManager:IsValidCurrentPageItem(CurPage, SubPage, v, serverTime) then
      local itemId = v.resID
      local isUsing = LogicShowBrand:CheckIsUsing(itemId)
      itemInfo = WardrobeLogicManager:ArrayHallDepotToCommonItem(v, #self.itemList, isUsing, false, false, false, false)
      table.insert(self.itemList, itemInfo)
    end
  end
  self:SetInitItemList(self.itemList)
  subtab_showbrand.__super.UpdateItemList(self, self.itemList)
  if #self.itemList > 0 then
    self.child_Placard_MedalSelection_UIBP:SelfHitTestInvisible()
    for i, v in ipairs(self.itemList) do
      if LogicShowBrand:CheckIsUsing(v.res_id) then
        self:OnClickItem(nil, i)
        break
      end
    end
  else
    self.child_Placard_MedalSelection_UIBP:Collapsed()
  end
end
function subtab_showbrand:OnClickItem(widget, index)
  self:doSelect(index)
  local itemInfo = self:GetItemData(index)
  local TipsManager = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  if itemInfo then
    TipsManager:Show(TipsManager.ENUM_ITEM_TIPS_TYPE.ENUM_ITEM_TIPS_TYPE_TINY, itemInfo.ins_id, itemInfo.res_id)
  else
    TipsManager:Hide()
  end
  subtab_showbrand.__super.OnClickItem(self, widget, index)
end
function subtab_showbrand:doSelect(index)
  local itemInfo = self:GetItemData(index)
  local itemId = itemInfo.res_id
  local cfg = CDataTable.GetTableDataByFilter("ShowBrandTemplateCfg", "ItemID", itemId)
  if not cfg then
    printf("subtab_showbrand:OnClickItem ShowBrandTemplateCfg is nil. itemId:%s", itemId)
    return
  end
  local templateId = cfg.TemplateID
  printf("subtab_showbrand:doSelect index:%s, templateId:%s", index, templateId)
  if self.TemlateID ~= 0 and self.TemlateID ~= itemId then
    local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
    LogicShowBrand:ApplySelfSetting(self.TemlateID)
  end
  self.TemlateID = templateId
  local ShowBrandHandler = require("client.network.Protocol.ShowBrandHandler")
  ShowBrandHandler.send_set_active_brand_req(templateId)
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  local settings = LogicShowBrand:GetSelfSetting(templateId)
  if settings then
    printf("subtab_showbrand:doSelect use settings")
    self:UpdateUI(cfg, templateId)
  else
    printf("subtab_showbrand:doSelect request settings")
    local ShowBrandHandler = require("client.network.Protocol.ShowBrandHandler")
    ShowBrandHandler.send_query_common_brand_req(0, templateId)
  end
end
function subtab_showbrand:UpdateUI(cfg, templateId)
  self:swithMode(0, false)
  self.child_Placard_MedalSelection_UIBP:UpdateTemplate(cfg)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOWBRAND_EDIT, 3, cfg.TemplateID)
  if templateId == 1 or templateId == 7 then
    self:OnClickedIconSlot(1, false)
  elseif templateId == 2 then
    self.child_Placard_MedalSelection_UIBP:OnSwitchToTextEditTab()
  end
end
function subtab_showbrand:OnShowBrandQueryResp(_, _, uid, template_id, settings)
  printf("subtab_showbrand:OnShowBrandQueryResp uid:%s, template_id:%s, #settings:%s", uid, template_id, #settings)
  if slua.isValid(self.UIRoot) and uid == 0 then
    local SelectItemData = self.LoopScrollBox:GetSelectIndex()
    local itemInfo = self:GetItemData(SelectItemData)
    local itemId = itemInfo.res_id
    local cfg = CDataTable.GetTableDataByFilter("ShowBrandTemplateCfg", "ItemID", itemId)
    if not cfg then
      printf("subtab_showbrand:OnShowBrandQueryResp ShowBrandTemplateCfg is nil. itemId:%s", itemId)
      return
    end
    local templateId = cfg.TemplateID
    self:UpdateUI(cfg, templateId)
  end
end
function subtab_showbrand:OnClickButton_Placard()
  printf("subtab_showbrand:OnClickButton_Placard")
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  LogicShowBrand:ApplySelfSetting(self.TemlateID)
  if self.switchTimer then
    self:RemoveTimer(self.switchTimer)
  end
  self.switchTimer = self:AddTimerOnce(7.933, function()
    local _ = slua.isValid(self.UIRoot) and self:swithMode(0, true)
    self.switchTimer = nil
  end)
  self:swithMode(1, false)
end
function subtab_showbrand:swithMode(mode, bFromTimer)
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  local cfg = LogicShowBrand:GetActiveBrandCfg()
  local CanEdit
  local TemplateID = 0
  if cfg then
    CanEdit = cfg.CanEdit
    TemplateID = cfg.TemplateID
    printf("subtab_showbrand:swithMode TemplateID:%s\239\188\140 CanEdit:%s", cfg.TemplateID, CanEdit)
  end
  if mode == 0 and CanEdit == 1 then
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    LobbyAvatarManager.StopEmoteAction(DataMgr.roleData.uid)
    self.child_Placard_MedalSelection_UIBP:SelfHitTestInvisible()
  else
    self.child_Placard_MedalSelection_UIBP:Collapsed()
  end
  if not bFromTimer then
    local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
    local emote = ShowBrandConst.EditEmoteId
    local ShowBrandUtils = require("client.slua.logic.showbrand.ShowBrandUtils")
    ShowBrandUtils.PrepareEmoteData(tonumber(DataMgr.roleData.uid), function()
      if slua.isValid(self.UIRoot) and self:IsValid() then
        log(bWriteLog and string.format("subtab_showbrand:swithMode PlayMotion"))
        WardrobeLogicManager:PlayMotion(emote)
      end
    end, nil, true)
  end
end
function subtab_showbrand:OnRefreshListItem(widget, index)
  local data = self:GetItemData(index)
  local itemId = data.res_id
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  local isUsing = LogicShowBrand:CheckIsUsing(itemId)
  data.  subtab_showbrand.__super.OnRefreshListItem(self, widget, index)
end
function subtab_showbrand:GetItemData(index)
  return self.LoopScrollBox:GetItemData(index)
end
function subtab_showbrand:GetDirectExtraLocation()
  local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if GarageThemeSystem:IsInGarageTheme() then
    if TeamUpNewSystem.IsInTeam() then
      return {x = -56.331245, y = -63.316406}
    else
      return {x = 25.071, y = -108.35017}
    end
  end
end
function subtab_showbrand:OnClose()
  local LogicShowBrand = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicShowBrand)
  LogicShowBrand:ApplySelfSetting(self.TemlateID)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatar = TeamAvatarManager.GetAvatarByUid(DataMgr.roleData.uid)
  if not avatar then
    return
  end
  local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
  if avatar:GetCurActionID() == ShowBrandConst.EditEmoteId then
    log(bWriteLog and string.format("subtab_showbrand:swithMode StopAction"))
    avatar:StopAction(nil, true)
  end
  subtab_showbrand.__super.OnClose(self)
end
local class = require("class")
local normal_item_list = require("client.slua.umg.Wardrobe.subtab_item_list_base")
local Action = class(normal_item_list, nil, subtab_showbrand)
return Action