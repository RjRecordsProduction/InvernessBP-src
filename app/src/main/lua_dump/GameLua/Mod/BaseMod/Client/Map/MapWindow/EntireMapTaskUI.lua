local EntireMapTaskUI = {
  LuaEventContainer = {"OnRefresh"}
}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local Util = require("client.slua_ui_framework.util")
local TableUtil = require("common.table_util")
local FXTaskStateType = import("FXTaskStateType")
function EntireMapTaskUI:OnInitialize()
  log(bWriteLog and "EntireMapTaskUI:OnInitialize")
  self.AllowType = {}
  self.CompleteType = {}
  self.MenuBtns = {}
  self.CurDisplayType = nil
end
function EntireMapTaskUI:RegistEvents()
  print(bWriteLog and "EntireMapTaskUI:RegistEvents")
  EntireMapTaskUI.__super.RegistEvents(self)
  local Config = GamePlayTools.GetCurrentConfig("EntireMapTaskConfig")
  self.ModuleConfig = Config.TypeModule
  self.DefaultType = Config.DefaultType
  self:AddOnClickedEventByControl(self.UIRoot.Button_Extend, self.OnExtendButtonClick, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnSpectatorChange", self.OnSpectatorChange, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerQuitSpectatingForClient", self.OnQuitSpectating, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_SHOW_STATE, self.RefreshAllItem, self)
  self:AddCommonEvent(EVENTTYPE_LIBRARY, EVENTID_THEMETASKGENERALCOUNTER_REP, self.RefreshAllItem, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.OnEnterBattleResult, self)
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "CharacterDataReady", function()
    self:CheckShowTaskUI()
  end)
end
function EntireMapTaskUI:CheckShowTaskUI()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uLuaTaskComponent = import("LuaTaskComponent")
  local LuaTaskComp = uPlayerController:GetComponentByClass(uLuaTaskComponent)
  if not slua.isValid(LuaTaskComp) then
    return
  end
  local TaskData = LuaTaskComp.TaskSyncList
  local GrowData
  local uPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(uPlayerState) and uPlayerState.ThemeTaskFeature then
    GrowData = uPlayerState.ThemeTaskFeature:GetGrowData()
  end
  local bNeedVersionTask = false
  if slua.isValid(uPlayerState) and uPlayerState.CheckVersionTaskReady then
    bNeedVersionTask = uPlayerState:CheckVersionTaskReady()
  end
  if TaskData:Num() > 0 or GrowData and 0 < #GrowData or bNeedVersionTask then
    self:AddAllowType("Task")
  end
end
function EntireMapTaskUI:OnEnterBattleResult()
  print(bWriteLog and "EntireMapTaskUI:OnEnterBattleResult")
  self:CloseSelf()
end
function EntireMapTaskUI:OnSpectatorChange()
  print(bWriteLog and "EntireMapTaskUI:OnSpectatorChange")
  self.UIRoot:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
end
function EntireMapTaskUI:OnQuitSpectating()
  print(bWriteLog and "EntireMapTaskUI:OnQuitSpectating")
  self.UIRoot:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
end
function EntireMapTaskUI:TestLQA()
  if self.CurrentType ~= "Task" then
    self.CurrentType = "Task"
    self:InitCurTypeUI()
  end
  self.CurModule:TestLQA()
end
function EntireMapTaskUI:OnPostInitialize()
  printf("EntireMapTaskUI:OnPostInitialize")
  EntireMapTaskUI.__super.OnPostInitialize(self)
  self:AttachWindow()
  self:InitTaskUIExtendState()
  self:RefreshTypeState()
end
function EntireMapTaskUI:InitCurTypeUI()
  if self.CurrentType == nil then
    return
  end
  local modulePath = self.ModuleConfig[self.CurrentType].ModulePath
  if modulePath then
    if self.CurModulePath == modulePath then
      return
    end
    if self.CurModule then
      self.CurModule:OnClose()
    end
    self.CurModule = require(modulePath)()
    self.CurModule:SetUIRoot(self.UIRoot)
    self.CurModule:OnInitUI()
    self.CurModule:OnRegistEvents()
    self.CurModulePath = modulePath
    self.UIRoot.CanvasPanel_NoTaskCollapsed:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self:OnExtendTaskUI(true, true)
  end
end
function EntireMapTaskUI:AttachWindow()
  local EntireMap = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
  if EntireMap and EntireMap.UIRoot and EntireMap.UIRoot.CanvasPanel_Task then
    EntireMap:AttachChildWindow("CanvasPanel_Task", self)
    self:SetAnchors(1, 0, 1, 1)
    self:SetOffsets(0, 0, 294, 0)
    self:SetAlignment(1, 0)
    self:InvalidateLayoutCache(3)
  end
end
function EntireMapTaskUI:OnExtendButtonClick()
  local bIsNeedShow = not self.IsShowTask
  if (not self.CurModule or self.CurModule:CheckComplete()) and not self:SwitchToFirstUnCompleteType() then
    self:OnAllTaskComplete()
    return
  end
  self:OnExtendTaskUI(bIsNeedShow, true)
  if self.IsShowTask then
    self:RefreshAllItem()
  end
end
function EntireMapTaskUI:InitTaskUIExtendState()
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  local bIsOpen = SettingSubsystem and SettingSubsystem:GetUserSettings_Bool("bIsOpenMapTaskUI") or false
  if bIsOpen then
    if self:RefreshCompleteState() then
      self:OnExtendTaskUI(true, true)
    else
      self:OnAllTaskComplete()
    end
  else
    self:OnExtendTaskUI(false, true)
  end
end
function EntireMapTaskUI:RefreshCompleteState()
  if self.CurModule and not self.CurModule:CheckComplete() then
    return true
  elseif self:SwitchToFirstUnCompleteType() then
    return true
  else
    return false
  end
end
function EntireMapTaskUI:SwitchToType(Type)
  self.Current  self.CurDisplay  self:InitCurTypeUI()
end
function EntireMapTaskUI:SwitchToFirstUnCompleteType()
  local LastTypes = TableUtil.Diff(self.AllowType, self.CompleteType)
  if not LastTypes then
    return false
  end
  if self.DefaultType and TableUtil.Find(LastTypes, self.DefaultType) ~= -1 then
    local DefaultModulePath = self.ModuleConfig[self.DefaultType] and self.ModuleConfig[self.DefaultType].ModulePath
    if DefaultModulePath then
      local DefaultModule = require(DefaultModulePath)()
      if not DefaultModule:CheckComplete() then
        self:SwitchToType(self.DefaultType)
        return true
      else
        self:AddCompleteType(self.DefaultType)
      end
    end
  end
  for _, Type in pairs(LastTypes) do
    local TypeModulePath = self.ModuleConfig[Type].ModulePath
    if TypeModulePath then
      local TypeModule = require(TypeModulePath)()
      if not TypeModule:CheckComplete() then
        self:SwitchToType(Type)
        return true
      else
        self:AddCompleteType(Type)
      end
    end
  end
  return false
end
function EntireMapTaskUI:OnExtendTaskUI(bIsShow, bIsChangeShow)
  if bIsChangeShow then
    self.IsShowTask = bIsShow
  end
  self:LuaBroadcast("OnRefresh", bIsShow and self.CurDisplayType or nil)
  if bIsShow then
    self.UIRoot.CanvasPanel_Task:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Image_Extend:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Image_Shrink:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.UIRoot.CanvasPanel_Task:ForceLayoutPrepass()
  else
    self.UIRoot.CanvasPanel_Task:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.Image_Extend:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Image_Shrink:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_Task:ForceLayoutPrepass()
  end
  self:InvalidateLayoutCache(3)
end
function EntireMapTaskUI:OnClose()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if self.IsShowTask ~= nil and (SettingConfig.bIsOpenMapTaskUI == nil or self.IsShowTask ~= SettingConfig.bIsOpenMapTaskUI) then
    slua_GameFrontendHUD:BeginModifyUserSettings()
    SettingConfig.bIsOpenMapTaskUI = self.IsShowTask
    slua_GameFrontendHUD:FinishModifyUserSettings()
  end
  if self.CurModule then
    self.CurModule:OnClose()
  end
  for Index, MenuBtnInfo in ipairs(self.MenuBtns) do
    MenuBtnInfo.Widget.UIRoot:RemoveFromParent()
    MenuBtnInfo.Widget:Close()
  end
  self.MenuBtns = nil
  EntireMapTaskUI.__super.OnClose(self)
end
function EntireMapTaskUI:RefreshAllItem()
  if self.CurModule then
    self.CurModule:RefreshAllItem()
    if not self:RefreshCompleteState() then
      self:OnAllTaskComplete()
    end
  else
    self:SwitchToFirstUnCompleteType()
  end
end
function EntireMapTaskUI:AddAllowType(Type)
  local TypeConfig = self.ModuleConfig[Type]
  if not TypeConfig then
    return
  end
  local TypePriority = TypeConfig.Priority
  if TableUtil.Find(self.AllowType, Type) == -1 then
    table.insert(self.AllowType, Type)
    local bIsFind = false
    for Index, MenuBtnInfo in ipairs(self.MenuBtns) do
      if TypePriority < MenuBtnInfo.Priority then
        self:AddMenuBtn(Index, Type, TypePriority)
        bIsFind = true
      end
    end
    if not bIsFind then
      self:AddMenuBtn(1, Type, TypePriority)
    end
    if self.CurrentType == "" and not self:SwitchToFirstUnCompleteType() then
      self:OnAllTaskComplete()
    end
  end
  self:RefreshTypeState()
end
function EntireMapTaskUI:AddMenuBtn(Index, Type, TypePriority)
  local MenuBtn = UIManager.ShowUI(UIManager.UI_Config_InGame.EntireMapTaskMenuBtn, Type, Index - 1)
  local MenuBtnInfo = {
    Widget = MenuBtn,
    Priority = TypePriority,
    Menu  }
  table.insert(self.MenuBtns, Index, MenuBtnInfo)
  self:BindLuaObjEvent(MenuBtn, "OnSelect", function(CurType)
    self:OnMenuBtnSelect(CurType)
  end)
  if MenuBtn.RefreshType then
    MenuBtn:BindLuaObjEvent(self, "OnRefresh", MenuBtn.RefreshType, MenuBtn)
  end
end
function EntireMapTaskUI:OnMenuBtnSelect(CurType)
  print(bWriteLog and "EntireMapTaskUI:OnMenuBtnSelect")
  if not self.IsShowTask then
    return
  end
  self:LuaBroadcast("OnRefresh", CurType)
  self.CurDisplayType = CurType
end
function EntireMapTaskUI:RemoveAllowType(Type)
  local TypeIndex = TableUtil.Find(self.AllowType, Type)
  if TypeIndex ~= -1 then
    table.remove(self.AllowType, TypeIndex)
    for Index, MenuBtnInfo in ipairs(self.MenuBtns) do
      if MenuBtnInfo.MenuType == Type then
        MenuBtnInfo.Widget.UIRoot:RemoveFromParent()
        table.remove(self.MenuBtns, Index)
        break
      end
    end
    if self.CurrentType == Type and not self:SwitchToFirstUnCompleteType() then
      self:OnAllTaskComplete()
    end
  end
  self:RefreshTypeState()
end
function EntireMapTaskUI:RefreshTypeState()
  if not self.UIRoot.HorizontalRoot then
    return
  end
  if #self.AllowType == 0 then
    self.UIRoot.HorizontalRoot:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  else
    self.UIRoot.HorizontalRoot:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  end
end
function EntireMapTaskUI:AddCompleteType(Type)
  if TableUtil.Find(self.CompleteType, Type) == -1 then
    table.insert(self.CompleteType, Type)
    for Index, MenuBtnInfo in ipairs(self.MenuBtns) do
      if MenuBtnInfo.MenuType == Type then
        MenuBtnInfo.Widget:OnComplete()
        break
      end
    end
  end
end
function EntireMapTaskUI:OnAllTaskComplete()
  print(bWriteLog and "EntireMapTaskUI:OnAllTaskComplete")
  self:OnExtendTaskUI(false, false)
  self.UIRoot.CanvasPanel_NoTaskCollapsed:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  self.CurrentType = ""
  if self.CurModule then
    self.CurModule:OnClose()
    self.CurModule = nil
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CEntireMapTaskUI = class(ui_base, nil, EntireMapTaskUI)
return CEntireMapTaskUI