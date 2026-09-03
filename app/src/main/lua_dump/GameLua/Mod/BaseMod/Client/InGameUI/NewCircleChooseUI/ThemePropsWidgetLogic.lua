local ThemePropsWidgetLogic = {}
local uBackpackUtils = import("BackpackUtils")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local CircleChooseUtil = require("GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseUtil")
function ThemePropsWidgetLogic:ctor()
  self.ThemePropsListInBackpack = {}
  self.CurrentSelectedThemePropID = -1
  self.FinalThemePropsList = {}
  self.bIsUsingThemeProp = false
end
function ThemePropsWidgetLogic:OnInit()
  ThemePropsWidgetLogic.__super.OnInit(self)
  local SuperData = GameplayData.GetSuperData()
  self:RegistCommonEvents()
  self:InitData()
  self:AddDataListener(SuperData, "CharacterDataReady", function()
    self:RegistEvents()
    self:ForceUpdateThemeProps()
  end)
end
function ThemePropsWidgetLogic:OnRelease()
  self.ThemePropsIDMa = nil
  ThemePropsWidgetLogic.__super.OnRelease(self)
end
function ThemePropsWidgetLogic:InitData()
  print(bWriteLog and "ThemePropsWidgetLogic:InitData")
  self.RelatedIDListArray = slua.Array(UEnums.EPropertyClass.Int)
  local ThemePropsIDMap = self:GetThemePropsIDMap()
  for ID, value in pairs(ThemePropsIDMap) do
    if value then
      self.RelatedIDListArray:Add(ID)
      print(bWriteLog and string.format("ThemePropsWidgetLogic:InitData add RelatedID:%s SkillID:%s", tostring(ID), tostring(value.SkillID)))
    end
  end
end
function ThemePropsWidgetLogic:GetThemePropsIDMap()
  if self.ThemePropsIDMap then
    return self.ThemePropsIDMap
  end
  local IDMap = {}
  local ThemePropsConfig = CDataTable.GetTable("ThemePropsConfig")
  if ThemePropsConfig then
    for _, value in pairs(ThemePropsConfig) do
      if value and value.ID then
        IDMap[value.ID] = {
          SkillID = value.SkillID or 0
        }
      end
    end
  end
  self.ThemeProps  return self.ThemePropsIDMap
end
function ThemePropsWidgetLogic:ResetUIStateAfterRespawn()
  print("ThemePropsWidgetLogic:ResetUIStateAfterRespawn")
  self:RegistEvents()
end
function ThemePropsWidgetLogic:RegistCommonEvents()
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_REFRESHUI_AFTERRESPAWN, self.ResetUIStateAfterRespawn, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_SELECT_THEME_PROP_BY_ID, function(_, _, TypeSpecificID)
    if TypeSpecificID then
      self:HandleThemePropsChosenByID(TypeSpecificID)
    end
  end)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_ITEM_LIST, function(_, _, uBackpackComponent)
    if slua.isValid(uBackpackComponent) then
      print(bWriteLog and "ThemePropsWidgetLogic:OnBackpackUpdateItemList")
      if self.RelatedIDListArray and self.RelatedIDListArray:Num() > 0 and uBackpackComponent:IsItemListUpdatedHasSomeItems(self.RelatedIDListArray) then
        self:ForceUpdateThemeProps()
      end
    end
  end)
end
function ThemePropsWidgetLogic:RegistEvents()
  print(bWriteLog and "ThemePropsWidgetLogic:RegistEvents", self)
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and not uPlayerController:IsSpectator() then
    GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.HandlePlayerEnterFighting, self)
    self:InitWeaponChangeDel()
  end
end
function ThemePropsWidgetLogic:InitWeaponChangeDel()
  local uWeaponMgr = self:GetWeaponMgr()
  if slua.isValid(uWeaponMgr) then
    self:AddControlEvent(uWeaponMgr, "ChangeCurrentUsingWeaponDelegate", self.HandleWeaponchange, self)
  end
end
function ThemePropsWidgetLogic:HandlePlayerEnterFighting()
  print(bWriteLog and "ThemePropsWidgetLogic:HandlePlayerEnterFighting")
  self:ForceUpdateThemeProps()
end
function ThemePropsWidgetLogic:GetWeaponMgr()
  if slua.isValid(self.WeaponMgr) then
    return self.WeaponMgr
  else
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      local uWeaponMgr = uPlayerCharacter:GetWeaponManager()
      if slua.isValid(uWeaponMgr) then
        self.WeaponMgr = uWeaponMgr
        return uWeaponMgr
      end
    end
  end
  print(bWriteLog and "ThemePropsWidgetLogic: Error Get WeaponMgr")
end
function ThemePropsWidgetLogic:GetSkillMgr()
  if slua.isValid(self.SkillMgr) then
    return self.SkillMgr
  else
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      local uSkillMgr = uPlayerCharacter.SkillManager
      if slua.isValid(uSkillMgr) then
        self.SkillMgr = uSkillMgr
        return uSkillMgr
      end
    end
  end
  print(bWriteLog and "ThemePropsWidgetLogic: Error Get SkillMgr")
end
function ThemePropsWidgetLogic:HandleWeaponchange(Slot)
  print(bWriteLog and "ThemePropsWidgetLogic:HandleWeaponchange")
  self:CheckUsingThemeProp()
  self:UpdateThemePropsListPanel()
end
function ThemePropsWidgetLogic:HandleThemePropsChosen(BattleItem)
  if BattleItem then
    self.CurrentSelectedThemePropID = BattleItem.DefineID.TypeSpecificID
    self:CheckUsingThemeProp()
    self:UpdateThemePropsListPanel()
  end
end
function ThemePropsWidgetLogic:HandleThemePropsChosenByID(TypeSpecificID)
  if TypeSpecificID then
    self:HandleThemePropsChosen({
      DefineID = {TypeSpecificID = TypeSpecificID}
    })
  end
end
function ThemePropsWidgetLogic:ForceUpdateThemeProps()
  self.ThemePropsInBackpack = self:GetThemePropsFromBackpack()
  self.FinalThemePropsList = self:SortThemeProps(self.ThemePropsInBackpack)
  self:CheckUsingThemeProp()
  self:UpdateThemePropsListPanel()
end
function ThemePropsWidgetLogic:CheckUsingThemeProp()
  local CurUsedItemID = -1
  local uWeaponMgr = self:GetWeaponMgr()
  local uSkillMgr = self:GetSkillMgr()
  local ItemList = self.ThemePropsInBackpack or {}
  for _, v in ipairs(ItemList) do
    local ItemId = v.DefineID.TypeSpecificID
    if slua.isValid(uWeaponMgr) then
      local CurWeapon = uWeaponMgr:GetCurrentUsingWeapon()
      if slua.isValid(CurWeapon) and ItemId == CurWeapon:GetItemDefineID().TypeSpecificID then
        CurUsedItemID = ItemId
        break
      end
    end
  end
  if CurUsedItemID ~= -1 then
    self.CurrentSelectedThemePropID = CurUsedItemID
    self.bIsUsingThemeProp = true
    self:SetGrenadeOrder()
  else
    self.bIsUsingThemeProp = false
  end
end
function ThemePropsWidgetLogic:CachePC()
  self.CachedPlayerState = GameplayData.GetPlayerState()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerCharacter) then
    self.PlayerCharacter = uPlayerCharacter
    local uBackpackComp = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(uPlayerCharacter)
    if slua.isValid(uBackpackComp) then
      self.BackpackComp = uBackpackComp
    end
  end
end
function ThemePropsWidgetLogic:SortThemeProps(ThemeProps)
  table.sort(ThemeProps, function(a, b)
    return a.DefineID.TypeSpecificID < b.DefineID.TypeSpecificID
  end)
  return ThemeProps
end
function ThemePropsWidgetLogic:GetThemePropPriority(TypeSpecificID)
end
function ThemePropsWidgetLogic:GetThemePropsFromBackpack()
  print(bWriteLog and "ThemePropsWidgetLogic:GetThemePropsFromBackpack")
  self:CachePC()
  self.ThemePropsListInBackpack = {}
  if slua.isValid(self.PlayerCharacter) and slua.isValid(self.BackpackComp) then
    local ResIDList = uBackpackUtils.GetBattleItemDataListByIDList(self.BackpackComp, self.RelatedIDListArray)
    if ResIDList and ResIDList.Num then
      print(bWriteLog and "ThemePropsWidgetLogic:GetThemePropsFromBackpack " .. tostring(ResIDList:Num()))
    else
      print(bWriteLog and "ThemePropsWidgetLogic:GetThemePropsFromBackpack ResIDList is nil")
    end
    local bSelectedIDInList = false
    local bHasGrenade = false
    local FirstGrenade
    for key, BattleItem in pairs(ResIDList) do
      table.insert(self.ThemePropsListInBackpack, BattleItem)
      if not bHasGrenade and CircleChooseUtil.IsAGrenade(BattleItem.DefineID.TypeSpecificID) then
        FirstGrenade = BattleItem
        bHasGrenade = true
      end
      if self.CurrentSelectedThemePropID == BattleItem.DefineID.TypeSpecificID then
        bSelectedIDInList = true
      end
    end
    if #self.ThemePropsListInBackpack == 0 then
      self.CurrentSelectedThemePropID = -1
      return self.ThemePropsListInBackpack
    end
    if not bSelectedIDInList then
      if bHasGrenade and FirstGrenade then
        self.CurrentSelectedThemePropID = FirstGrenade.DefineID.TypeSpecificID
      else
        self.CurrentSelectedThemePropID = self.ThemePropsListInBackpack[1].DefineID.TypeSpecificID
      end
    end
  end
  return self.ThemePropsListInBackpack
end
function ThemePropsWidgetLogic:UpdateThemePropsListPanel()
  local bShow = false
  print(bWriteLog and "ThemePropsWidgetLogic:UpdateThemePropsListPanel" .. tostring(#self.FinalThemePropsList))
  if #self.FinalThemePropsList > 0 then
    bShow = true
  end
  local ThemePropsUI = UIManager.GetUI(UIManager.UI_Config_InGame.ThemePropsChooseWidgetNew)
  if ThemePropsUI then
    ThemePropsUI:UpdateListBox(self.FinalThemePropsList, self.CurrentSelectedThemePropID, self.bIsUsingThemeProp)
    return
  end
  if bShow then
    local TransparentUIModeSubsystem = SubsystemMgr:Get("TransparentUIModeSubsystem")
    if TransparentUIModeSubsystem and not TransparentUIModeSubsystem.IsShow then
      print(bWriteLog and "ThemePropsWidgetLogic:UpdateThemePropsListPanel skip creating ThemePropsUI")
      return
    end
    local ShootingUIPanel = InGameUITools.GetShootingUIPanelLuaClass()
    if ShootingUIPanel then
      ThemePropsUI = ShootingUIPanel:CreateChildWindow(ShootingUIPanel.UIRoot.ThemePropsSocket, UIManager.UI_Config_InGame.ThemePropsChooseWidgetNew)
      if ThemePropsUI then
        ThemePropsUI:UpdateListBox(self.FinalThemePropsList, self.CurrentSelectedThemePropID, self.bIsUsingThemeProp)
      end
    end
  end
end
function ThemePropsWidgetLogic:SetGrenadeOrder()
  local playerController = GameplayData.GetPlayerController()
  if not slua.isValid(playerController) then
    return
  end
  if not self.bIsUsingThemeProp then
    return
  end
  if self.CurrentSelectedThemePropID == -1 then
    return
  end
  if CircleChooseUtil.IsAGrenade(self.CurrentSelectedThemePropID) then
    print(bWriteLog and "ThemePropsWidgetLogic:ServerTriggerSelectGrenade PropID:" .. tostring(self.CurrentSelectedThemePropID))
    playerController:ServerTriggerSelectGrenade(self.CurrentSelectedThemePropID)
  else
    print(bWriteLog and "ThemePropsWidgetLogic:ServerTriggerSelectGrenade 0")
    playerController:ServerTriggerSelectGrenade(-1)
  end
end
local class = require("class")
local CDelegateContainer = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(CDelegateContainer, nil, ThemePropsWidgetLogic)