local Personalization_Teambrand_UIBP = {}
local RoleInfoNameFrameSystem = require("client.slua.logic.person_space.logic_roleinfo_nameframe")
local util = require("client.slua_ui_framework.util")
local table_pool = require("common.table_pool").Create()
function Personalization_Teambrand_UIBP:ctor(_, jumpSelectItemId)
  self.srcList = table_pool:Get()
end
function Personalization_Teambrand_UIBP:InitItemGrid()
  self.ItemGrid = self:InitScrollBox(self.UIRoot.LoopScrollGrid_Frame)
  self.ItemClickCtrlName = "Button_Frame"
end
function Personalization_Teambrand_UIBP:InitCommonAvatarComp()
  Personalization_Teambrand_UIBP.__super.InitCommonAvatarComp(self)
  self.smallAvatar = self.UIRoot.Common_Avatar_BP_0
  self.nameText = self.UIRoot.Text_Name01
end
function Personalization_Teambrand_UIBP:HandleOwnCheckChange()
  Personalization_Teambrand_UIBP.__super.HandleOwnCheckChange(self)
  self.baseItemSelectIndex = 1
end
function Personalization_Teambrand_UIBP:RegistEvents()
  Personalization_Teambrand_UIBP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_NAME_FRAME, self.SetData, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_USE_NAME_FRAME, self.OnUpdateUse, self)
end
function Personalization_Teambrand_UIBP:OnPostInitialize()
  Personalization_Teambrand_UIBP.__super.OnPostInitialize(self)
  self:InitData()
  RoleInfoNameFrameSystem.Enter()
end
function Personalization_Teambrand_UIBP:OnClose()
  table_pool:RecycleAll(self.srcList)
  table_pool:Recycle(self.srcList)
  self.srcList = nil
  Personalization_Teambrand_UIBP.__super.OnClose(self)
end
function Personalization_Teambrand_UIBP:IsLoadAvatarScene()
  return true
end
function Personalization_Teambrand_UIBP:IsNeedUpdatePlayerInfo()
  return true
end
function Personalization_Teambrand_UIBP:GetDescTitleInfo()
  return LocUtil.GetLocalizeResStr(8108), LocUtil.GetLocalizeResStr(25713)
end
function Personalization_Teambrand_UIBP:OnTitleTabChanged(titleTab)
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(titleTab)
end
function Personalization_Teambrand_UIBP:IsUsingItem(itemData)
  return itemData.bIsUse or itemData.cfg.ID == self.curItemID
end
function Personalization_Teambrand_UIBP:IsJumpSelectItem(itemData)
  if not (self.jumpSelectItemId and itemData and itemData.cfg) or not itemData.cfg.ID then
    return false
  end
  return itemData.cfg.ID == self.jumpSelectItemId
end
function Personalization_Teambrand_UIBP:GetItemList()
  local list = self.srcList
  if self.isCheckOwned then
    list = {}
    for k, v in ipairs(self.srcList) do
      if not v.bIsLock then
        table.insert(list, v)
      end
    end
  end
  self:SortFrameList(list)
  return list
end
function Personalization_Teambrand_UIBP:InitData()
  local seasonID = tonumber(DataMgr.season_id)
  local config = CDataTable.GetTable("NameFrame")
  for i, v in pairs(config) do
    if seasonID >= v.Season then
      local TableUtil = require("common.table_util")
      local cfg = TableUtil.CopyTable(v)
      local info = table_pool:Get()
      info.      info.bIsLock = true
      info.expire_ts = 0
      info.bIsUse = false
      info.bReddot = false
      table.insert(self.srcList, info)
    end
  end
end
function Personalization_Teambrand_UIBP:OnRefreshGridItem(widget, index)
  local data = self.ItemGrid:GetItemData(index)
  local cfg = data.cfg
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  if PufferODPakManager:GetStateByPath(cfg.Icon) ~= PufferConst.ENUM_DownloadState.Done then
    self:SetTexture(widget.Image_Frame, "")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    if not self.downloadingPakNames then
      self.downloadingPakNames = {}
    end
    local pakName = PufferManager.GetPakName(cfg.Icon)
    self.downloadingPakNames[pakName] = true
    local downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_downloader)
    downloader:DownloadByPath(cfg.Icon)
    self:AddDownloadResPath(cfg.Icon)
  else
    self:SetTexture(widget.Image_Frame, cfg.Icon)
  end
  widget.TextBlock_Season:SetText("S" .. cfg.Season)
  self:SetWidgetVisible(widget.CanvasPanel_Season, cfg.Season > 0)
  self:SetWidgetVisible(widget.CanvasPanel_Lock, data.bIsLock)
  if data.bIsLock then
    local borderOpacity = FLinearColor(1, 1, 1, 0.4)
    local lockOpacity = FLinearColor(1, 1, 1, 0.7)
    widget.Image_Frame:SetColorAndOpacity(borderOpacity)
    widget.Image_Lock:SetColorAndOpacity(lockOpacity)
  else
    widget.Image_Frame:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  end
  self:SetWidgetVisible(widget.Image_Select, index == self.baseItemSelectIndex)
  self:SetWidgetVisible(widget.Image_Using, data.bIsUse)
  self:SetWidgetVisible(widget.Image_Reddot, false)
  local isExpireItem = false
  if not data.bIsLock and DataMgr.roleData.nameFrameData and DataMgr.roleData.nameFrameData[cfg.ID] then
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    local expire_ts = DataMgr.roleData.nameFrameData[cfg.ID].expire_ts or 0
    if curTime < expire_ts then
      isExpireItem = true
    end
  end
  self:SetWidgetVisible(widget.Image_LimitedTime, isExpireItem)
end
function Personalization_Teambrand_UIBP:SetData(evtType, evtID)
  log(bWriteLog and "[edward][SetData] RoleInfoNameFrameSystem.nUsedID = " .. RoleInfoNameFrameSystem.nUsedID)
  log_tree("[edward][SetData] DataMgr.roleData.nameFrameData = ", DataMgr.roleData.nameFrameData)
  self.baseItemSelectIndex = 1
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local lastData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLastNameFrameData) or {}
  local eLastNameFrameData = lastData.nameFrame or {}
  log_tree("[edward][SetData] eLastNameFrameData = ", eLastNameFrameData)
  for k, v in pairs(DataMgr.roleData.nameFrameData) do
    for kk, vv in ipairs(self.srcList) do
      if vv.cfg.ID == k and RoleInfoNameFrameSystem.IsValidNameFrame(k) then
        vv.bIsLock = false
        vv.expire_ts = DataMgr.GetNameFrame(k).expire_ts
        vv.bReddot = not eLastNameFrameData[k]
      end
    end
  end
  for _, v in ipairs(self.srcList) do
    if v.cfg.ID == RoleInfoNameFrameSystem.nUsedID then
      v.bIsUse = true
    else
      v.bIsUse = false
    end
  end
  self:RefreshItemGrid()
end
function Personalization_Teambrand_UIBP:UpdateItemReddot(itemData, index)
  if itemData.bReddot then
    itemData.bReddot = false
    self.ItemGrid:RefreshItem(index, itemData)
    RoleInfoNameFrameSystem.RemoveRedDot(itemData.cfg.ID)
    return true
  end
  return false
end
function Personalization_Teambrand_UIBP:UpdatePlayerInfo()
  local profile = Personalization_Teambrand_UIBP.__super.UpdatePlayerInfo(self)
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bShowKillText = strRegion ~= PublishRegionMacros.BLUEHOLE
  if self.UIRoot.TextBlock_Kill then
    self:SetWidgetVisible(self.UIRoot.TextBlock_Kill, bShowKillText)
  end
  if not profile then
    return
  end
  self.UIRoot.Text_Name02:SetText(profile.nickName or "")
  self.UIRoot.Common_Avatar_BP_0:InitView(1, profile.uid, profile.picUrl, profile.sex, profile.cur_avatar_box_id, profile.level, false, "")
  self.UIRoot.Common_Avatar_BP_0:SetButtonEnabled(false)
end
function Personalization_Teambrand_UIBP:UpdateSelectedItemInfo(itemData)
  log(bWriteLog and "Personalization_Teambrand_UIBP UpdateSelectedItemInfo")
  if not itemData then
    return
  end
  local root = self.UIRoot
  local cfg = itemData.cfg
  self.curItemID = cfg.ID
  local param = self:GenCommonItemParam()
  param.itemID = cfg.ID
  param.name = cfg.Name
  if cfg.DescGet and cfg.DescGet ~= "" then
    param.extraInfo = cfg.DescGet
  end
  local UIUtil = require("client.common.ui_util")
  self:SetTexture(root.Image_NameFrame02, cfg.Icon)
  self:SetTexture(root.Image_NameFrame01, cfg.Icon)
  if cfg.Season > 0 then
    root.CanvasPanel_Season:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    root.TextBlock_Season01:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local str = "S" .. cfg.Season
    root.TextBlock_Season:SetText(str)
    root.TextBlock_Season01:SetText(str)
  else
    root.CanvasPanel_Season:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    root.TextBlock_Season01:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local TimeUtil = require("client.common.time_util")
  if DataMgr.roleData.nameFrameData and DataMgr.roleData.nameFrameData[cfg.ID] then
    log(bWriteLog and "cfg.ID and expire_ts = " .. tostring(cfg.ID) .. " and " .. tostring(DataMgr.roleData.nameFrameData[cfg.ID].expire_ts))
    local curTime = TimeUtil.GetServerTimeInSec()
    local expire_ts = DataMgr.roleData.nameFrameData[cfg.ID].expire_ts or 0
    if expire_ts <= 1 or curTime < expire_ts then
      param.expireTime = expire_ts
      log(bWriteLog and "OwnAndInTimeLimit  param.expireTime = " .. tostring(param.expireTime))
    end
    if curTime > expire_ts then
      local str = TimeUtil.FormatCountDownTime_DH_or_HM(cfg.LimitTime * 3600, false)
      log(bWriteLog and "cfg.LimitTime = " .. tostring(cfg.LimitTime) .. ",str = " .. str)
      if str == "" then
        param.expireTime = 0
      else
        local pre_title = LocUtil.GetLocalizeResStr(301299)
        str = LocUtil.LocalizeResFormat(6823, pre_title, str)
        param.expireTime = str
      end
      log(bWriteLog and "OwnButOutTimeLimit  param.expireTime = " .. tostring(param.expireTime))
    end
  elseif 0 < cfg.LimitTime then
    local str = TimeUtil.FormatCountDownTime_DH_or_HM(cfg.LimitTime * 3600, true)
    local pre_title = LocUtil.GetLocalizeResStr(301299)
    str = LocUtil.LocalizeResFormat(6823, pre_title, str)
    param.expireTime = str
    log(bWriteLog and "NotOwnButTimeLimit  param.expireTime = " .. tostring(param.expireTime))
  else
    param.expireTime = 0
    log(bWriteLog and "NotOwnButForever  param.expireTime = " .. tostring(param.expireTime))
  end
  if itemData.bIsUse then
    param.buttonStyle = ENUM_Button_Style.Unload
  elseif itemData.bIsLock then
    if cfg.JumpUrl and cfg.JumpUrl ~= "" then
      param.buttonStyle = ENUM_Button_Style.Go
    end
  else
    param.buttonStyle = ENUM_Button_Style.Use
  end
  return param
end
function Personalization_Teambrand_UIBP:HandleButtonUse()
  log(bWriteLog and "[edward][roleinfo_set_nameframe] OnClickPutOn")
  local id = 0
  local data = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  if data then
    id = data.cfg.ID
  end
  RoleInfoNameFrameSystem.use_brand(id)
end
function Personalization_Teambrand_UIBP:HandleButtonUnload()
  log(bWriteLog and "[edward][roleinfo_set_nameframe] OnClickPutOff")
  RoleInfoNameFrameSystem.use_brand(0)
end
function Personalization_Teambrand_UIBP:HandleButtonGo()
  local itemData = self.ItemGrid:GetItemData(self.baseItemSelectIndex)
  if itemData.cfg.JumpUrl and itemData.cfg.JumpUrl ~= "" then
    GlobalData.JumpUrl(itemData.cfg.jumpUrl)
    self:CloseSelf()
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CLOSE_ALL)
  end
end
function Personalization_Teambrand_UIBP:OnUpdateUse(evtType, evtID, usedID)
  ShowNotice(49951)
  for _, v in ipairs(self.srcList) do
    if v.cfg.ID == usedID then
      v.bIsUse = true
    else
      v.bIsUse = false
    end
  end
  self.jumpSelectItemId = nil
  self:RefreshItemGrid()
end
function Personalization_Teambrand_UIBP:SortFrameList(list)
  table.sort(list, function(a, b)
    if a.bIsUse == b.bIsUse then
      if a.bReddot == b.bReddot then
        if a.bIsLock == b.bIsLock then
          if a.cfg.ShowPriority == b.cfg.ShowPriority then
            if a.cfg.Segment == b.cfg.Segment then
              return a.cfg.ID < b.cfg.ID
            else
              return a.cfg.Segment > b.cfg.Segment
            end
          else
            return a.cfg.ShowPriority > b.cfg.ShowPriority
          end
        else
          return not a.bIsLock
        end
      else
        return a.bReddot
      end
    else
      return a.bIsUse
    end
  end)
end
function Personalization_Teambrand_UIBP:OnAndroidBack()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CLOSE_ALL)
end
local class = require("class")
local ui_base = require("client.slua.umg.roleInfoNew.Personalization_BaseItem_UIBP")
local CUIRoleInfo_Set_NameFrame = class(ui_base, nil, Personalization_Teambrand_UIBP)
return CUIRoleInfo_Set_NameFrame