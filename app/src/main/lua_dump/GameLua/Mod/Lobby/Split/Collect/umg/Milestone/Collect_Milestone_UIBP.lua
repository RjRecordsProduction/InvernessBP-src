local Collect_Milestone_UIBP = {}
function Collect_Milestone_UIBP:ctor(_, subTab)
  self._  self.isShowViewGuide = false
end
function Collect_Milestone_UIBP:OnInitialize()
  Collect_Milestone_UIBP.__super.OnInitialize(self)
  self.UIRoot.TextBlock_3:SetText(LocUtil.GetLocalizeResStr(82028))
  self.UIRoot.CanvasPanel_Guide:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CanvasPanel_Edit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.LoopScrollBox_1 = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_1, "GameLua.Mod.Lobby.Split.Collect.umg.Milestone.Item.Collect_Milestone_Little_Item_UIBP")
  self.LoopScrollBox_0 = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_0, "GameLua.Mod.Lobby.Split.Collect.umg.Milestone.Item.Collect_Milestone_Item_UIBP")
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP = self:InitHorizontalLevelOneTextTab(self.UIRoot.Common_Tab_Horizontal_LevelOne_Text_UIBP)
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:SetTextColor(FSlateColor(FLinearColor(1, 1, 1, 1)), FSlateColor(FLinearColor(1, 1, 1, 0.7)))
end
function Collect_Milestone_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Edit, self.OnClickButton_Edit, self)
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:AddOnClickedCallback(self.OnClickedLevelOneTab, self)
  self:AddCommonEvent(EVENTTYPE_MILESTONE, EVENTID_MILESTONE_UPDATE_EQUIPPED, self.OnRefreshEquippedMilestoneList, self)
  self:AddCommonEvent(EVENTTYPE_MILESTONE, EVENTID_MILESTONE_UPDATE_REDPOINT, self.RefreshTabRedPoint, self)
end
function Collect_Milestone_UIBP:OnPostInitialize()
  self:PlayUserWidgetAnimation(self.UIRoot.Fadein, 0, 1, 0, 1)
  if self:CheckJumpItemID() then
    return
  end
  local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
  self:UpdateBackGround()
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  self.UIRoot.TextBlock_Edit:SetText(LocUtil.GetLocalizeResStr(45904))
  local tabs = {}
  for i, v in ipairs(collect_cfg.C_Milestone_Tab_Text_List) do
    local sysId = collect_cfg.milestoneTab2ServerType[i]
    if not LobbyEmoteManager:IsMilestoneTabEncryption(sysId) then
      tabs[#tabs + 1] = LocUtil.GetLocalizeResStr(v)
    end
  end
  self.Common_Tab_Horizontal_LevelOne_Text_UIBP:SetTabs(tabs, self.curSelectTab)
  self:RefreshTabRedPoint()
  self:OnClickedLevelOneTab(nil, self.curSelectTab, true)
end
function Collect_Milestone_UIBP:RefreshTabRedPoint()
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  for i, v in ipairs(collect_cfg.C_Milestone_Tab_Text_List) do
    local redWidget, parentNode = self.Common_Tab_Horizontal_LevelOne_Text_UIBP:GetItemReddotAnchorComponent(i)
    if redWidget then
      reddot_node_collect_manager:ShowNewReddot(parentNode, redWidget, v)
    end
  end
end
function Collect_Milestone_UIBP:OnClose()
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  reddot_node_collect_manager:ClearCacheRemoveRedDot()
  local CollectTab = reddot_node_collect_manager:GetCollectTab()
  reddot_node_collect_manager:HideNodeAllChildNewReddot(CollectTab.collect_milestone)
  self.curSelectTab = nil
  Collect_Milestone_UIBP.__super.OnClose(self)
end
function Collect_Milestone_UIBP:InitCurrentActionIcon()
  local widget = self.UIRoot.Collect_Milestone_Edit_Item_UIBP
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local sysType = collect_cfg.milestoneTab2ServerType[self.curSelectTab]
  local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
  local resID = LobbyEmoteManager:GetExpressionIDBySysType(sysType)
  if 0 < resID then
    local itemCfg = CDataTable.GetTableData("Item", resID)
    if itemCfg then
      local icon = widget.Image_Icon
      local UIUtil = require("client.common.ui_util")
      local smallIcon, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(resID, icon)
      local params = {sync = false, bHasAddKnownMissing = bHasAddKnownMissing}
      self:SetTexture(icon, smallIcon, params)
      icon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    widget.WidgetSwitcher_Icon:SetActiveWidgetIndex(1)
  else
    widget.WidgetSwitcher_Icon:SetActiveWidgetIndex(0)
  end
end
function Collect_Milestone_UIBP:CheckJumpItemID()
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
  self.curSelectTab = collect_cfg.E_Milestone_Tab.outfits
  local jumpItemID
  if type(self._subTab) == "table" and self._subTab.itemID then
    jumpItemID = tonumber(self._subTab.itemID or 0)
    local sysType = LobbyEmoteManager:GetMilestoneTypeByItemID(jumpItemID)
    if sysType then
      self.curSelectTab = collect_cfg.serverType2MilestoneTab[sysType] or collect_cfg.E_Milestone_Tab.outfits
    end
  elseif type(self._subTab) == "number" then
    self.curSelectTab = self._subTab or collect_cfg.E_Milestone_Tab.outfits
  else
    local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
    for tabIndex, v in ipairs(collect_cfg.C_Milestone_Tab_Text_List) do
      if reddot_node_collect_manager:CheckShowNewReddot(v) then
        self.curSelectTab = tabIndex
        break
      end
    end
  end
  log(bWriteLog and string.format("Collect_Milestone_UIBP:CheckJumpItemID self.curSelectTab = %s, jumpItemID = %s", self.curSelectTab, jumpItemID))
  if jumpItemID then
    self:GotoDetailPanel(jumpItemID)
    return true
  end
  return false
end
function Collect_Milestone_UIBP:GotoDetailPanel(jumpItemID)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local sysType = collect_cfg.milestoneTab2ServerType[self.curSelectTab] or collect_cfg.E_Milestone_Server_Type.outfits
  UIManager.ShowUI(UIManager.UI_Config.Collect_Milestone_Detail_UIBP, sysType, jumpItemID)
end
function Collect_Milestone_UIBP:UpdateBackGround()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local path = "/Game/Mod/Lobby/Split/Collect/Texture/Collect_Bg01.Collect_Bg01"
  local season = collect_module:GetSeasonId()
  local TableUtil = require("common.table_util")
  local colData = collect_module:GetCollectData()
  local score = 0
  if colData and colData.season_score then
    score = TableUtil.GetTableValue(colData.season_score, season) or 0
  end
  local _, light = collect_module:GetSeasonLevelByScore(score)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(RoleInfoSystem.CurShowPlayerInfoUid)
  log(bWriteLog and "Collect_Milestone_UIBP:UpdateBackGround - PlayerUID:" .. tostring(RoleInfoSystem.CurShowPlayerInfoUid))
  local collect_data = profile and profile.collect_data
  local collect_badge_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_badge_module)
  if light and collect_badge_module:CheckCanLightBadge(RoleInfoSystem.CurShowPlayerInfoUid, collect_data) then
    path = "/Game/Mod/Lobby/Split/Collect/Texture/Collect_Bg02.Collect_Bg02"
  end
  self:SetTexture(self.UIRoot.Image_Bg, path)
end
function Collect_Milestone_UIBP:OnClickedLevelOneTab(widget, index, bIgnoreRedDot)
  log(bWriteLog and string.format("Collect_Milestone_UIBP:OnClickedLevelOneTab self.curSelectTab = %s, index = %s bIgnoreRedDot = %s", self.curSelectTab, index, bIgnoreRedDot))
  self:PlayAudio(sound_config.tab_v1)
  if widget and self.curSelectTab == index then
    return
  end
  self.curSelectTab = index
  self:RefreshMilestoneList(index)
  self:RefreshEquippedMilestoneList(index)
  self:RemoveReddotWhenClickTab(index, bIgnoreRedDot)
end
function Collect_Milestone_UIBP:RemoveReddotWhenClickTab(index, bIgnoreRedDot)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local key = collect_cfg.C_Milestone_Tab_Text_List[index]
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  if not bIgnoreRedDot then
    reddot_node_collect_manager:ClearCacheRemoveRedDot()
    reddot_node_collect_manager:RemoveReddot(key)
  else
    reddot_node_collect_manager:CacheRemoveRedDot(key)
  end
end
function Collect_Milestone_UIBP:RefreshMilestoneList(index)
  self:HideGuide()
  local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local content = LobbyEmoteManager:GetMilestones(collect_cfg.milestoneTab2ServerType[index])
  if content and 0 < #content then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  else
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  end
  self.LoopScrollBox_0:SetData(content or {})
  self:ShowGuide(content)
end
function Collect_Milestone_UIBP:ShowGuide(content)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local guideData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectMilestoneGuide)
  local saveMark = false
  local checkEditGuide = function()
    if guideData and guideData[collect_cfg.E_Milestone_Guide_Mark.C_Guide_Edit] then
      log(bWriteLog and string.format("Collect_Milestone_UIBP:checkEditGuide Already reminded. "))
      return
    end
    saveMark = true
    if not guideData then
      guideData = {}
    end
    guideData[collect_cfg.E_Milestone_Guide_Mark.C_Guide_Edit] = 1
    self.UIRoot.CanvasPanel_Guide:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  local checkViewGuide = function()
    if guideData and guideData[collect_cfg.E_Milestone_Guide_Mark.C_Guide_View] then
      log(bWriteLog and string.format("Collect_Milestone_UIBP:checkViewGuide Already reminded. "))
      return
    end
    saveMark = true
    if not guideData then
      guideData = {}
    end
    guideData[collect_cfg.E_Milestone_Guide_Mark.C_Guide_View] = 1
    self.isShowViewGuide = true
    self.LoopScrollBox_0:RefreshItem(1)
  end
  local aMark = false
  for i, v in ipairs(content) do
    if v.acquired then
      aMark = true
      checkViewGuide()
      checkEditGuide()
      break
    end
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Edit, aMark)
  if saveMark then
    PlayerPrefsSystem.SaveTableToFile_N(guideData, PlayerPrefsSystem.ePlayerPrefsType.eCollectMilestoneGuide)
  end
end
function Collect_Milestone_UIBP:IsShowViewGuide()
  return self.isShowViewGuide
end
function Collect_Milestone_UIBP:HideGuide()
  self.isShowViewGuide = false
  self.UIRoot.CanvasPanel_Guide:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function Collect_Milestone_UIBP:RefreshEquippedMilestoneList(index)
  local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local slots = LobbyEmoteManager:GetMilestoneSlot(collect_cfg.milestoneTab2ServerType[index])
  local editText = ""
  if index == collect_cfg.E_Milestone_Tab.outfits then
    editText = LocUtil.GetLocalizeResStr(82004)
  elseif index == collect_cfg.E_Milestone_Tab.firearms then
    editText = LocUtil.GetLocalizeResStr(82005)
  elseif index == collect_cfg.E_Milestone_Tab.Vehicle then
    editText = LocUtil.GetLocalizeResStr(82030)
  elseif index == collect_cfg.E_Milestone_Tab.career then
    editText = LocUtil.GetLocalizeResStr(82072)
  elseif index == collect_cfg.E_Milestone_Tab.pet then
    editText = LocUtil.GetLocalizeResStr(82071)
  end
  self.UIRoot.TextBlock_0:SetText(editText)
  local content = {
    slots[1] or 0,
    slots[2] or 0,
    slots[3] or 0,
    slots[4] or 0
  }
  log_tree("RefreshEquippedMilestoneList content", content)
  self.LoopScrollBox_1:SetData(content)
  self:InitCurrentActionIcon()
end
function Collect_Milestone_UIBP:OnRefreshEquippedMilestoneList()
  self:RefreshEquippedMilestoneList(self.curSelectTab)
end
function Collect_Milestone_UIBP:OnClickButton_Edit()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.Collect_Milestone_Edit_UIBP, self.curSelectTab)
end
local class = require("class")
local ui_base = require("GameLua.Mod.Lobby.Split.Collect.umg.CollectBase.Collect_UI_Base")
local CCollect_Milestone_UIBP = class(ui_base, nil, Collect_Milestone_UIBP)
return CCollect_Milestone_UIBP