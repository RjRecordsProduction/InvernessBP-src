local BuffList = {}
local UGameplayStatics = import("GameplayStatics")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
function BuffList:ctor()
  self.BuffItemMap = {}
  self.BuffItemPriorityQueue = {}
  self.BuffItemUIPath = "/Game/BluePrints/ControlInput/IngameUI/BuffList/ingame_BuffItem_UIBP.ingame_BuffItem_UIBP"
  self.BindDelegateSuccess = false
  self.BuffGuidCount = {}
  self.MaxGuidEachMatch = 2
  self.MaxGuidMatchCount = 3
  self.CurMatchBuffCountMap = {}
  self.BuffSytemCom = nil
  self.PreCreatedBuffItems = {}
  self.MaxBuffItemCount = 4
  self.bUseTwoBox = false
end
function BuffList:OnInitialize()
  BuffList.__super.OnInitialize(self)
  print(bWriteLog and "BuffList:OnInitialize")
end
function BuffList:InitBoxAndPreCreateBuffItems(bUseTwoBox)
  self.bUseTwoBox = bUseTwoBox or false
  self.MaxBuffItemCount = self.bUseTwoBox and 8 or 4
  print(bWriteLog and "BuffList:InitBoxAndPreCreateBuffItems - bUseTwoBox:" .. tostring(self.bUseTwoBox))
  if not slua.isValid(self.UIRoot.CanvasPanel_OneBox) or not slua.isValid(self.UIRoot.CanvasPanel_TwoBox) then
    return
  end
  if self.bUseTwoBox then
    self.UIRoot.CanvasPanel_OneBox:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_TwoBox:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.BuffListBox = self.UIRoot.BuffListRightBox
  else
    self.UIRoot.CanvasPanel_OneBox:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.CanvasPanel_TwoBox:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.BuffListBox = self.UIRoot.BuffListVerticalBox
  end
  self:PreCreateBuffItems()
  if self.BuffItemPriorityQueue and #self.BuffItemPriorityQueue > 0 then
    print(bWriteLog and "BuffList:InitBoxAndPreCreateBuffItems - RefreshBuffListUI after rebuild, queueLen:" .. #self.BuffItemPriorityQueue)
    self:RefreshBuffListUI()
  end
end
function BuffList:OnPostInitialize()
  print(bWriteLog and "BuffList:OnPostInitialize")
  BuffList.__super.OnPostInitialize(self)
end
function BuffList:OnClose()
  print(bWriteLog and "BuffList:OnClose")
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_Root)
  if self.PreCreatedBuffItems then
    for _, buffItem in ipairs(self.PreCreatedBuffItems) do
      if slua.isValid(buffItem) then
        buffItem:Destruct()
        buffItem:RemoveFromParent()
      end
    end
    self.PreCreatedBuffItems = nil
  end
  self.BuffItemMap = nil
  self.BuffItemPriorityQueue = nil
  self.BuffSytemCom = nil
  BuffList.__super.OnClose(self)
end
function BuffList:RegistEvents()
  print(bWriteLog and "BuffList:RegistEvents")
  BuffList.__super.RegistEvents(self)
  self:AddDataListener(GameplayData.GetSuperData(), "GameDataReady", self.OnGameDataReady, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_Root, self, "BuffListPanel")
end
function BuffList:OnGameDataReady()
  print(bWriteLog and "BuffList:OnGameDataReady")
  self:InitBoxAndPreCreateBuffItems(false)
  self:TryBindDelegate()
end
function BuffList:DestroyPreCreatedBuffItems()
  print(bWriteLog and "BuffList:DestroyPreCreatedBuffItems")
  for _, buffItem in ipairs(self.PreCreatedBuffItems) do
    if slua.isValid(buffItem) then
      buffItem:Destruct()
      buffItem:RemoveFromParent()
    end
  end
  self.PreCreatedBuffItems = {}
  self.BuffItemMap = {}
  self.BuffItemPriorityQueue = {}
end
function BuffList:TryBindDelegate()
  print(bWriteLog and "BuffList:TryBindDelegate")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayCharacter) then
    print(bWriteLog and "BuffList:TryBindDelegate - uPlayCharacter is not valid, delay retry")
    self:AddGameTimer(1, false, function()
      self:TryBindDelegate()
    end)
    return
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_SPECTATING, EVENTID_ENTER_SPECTATING, self.OnEnterSpectating, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerQuitSpectatingForClient", self.OnQuitSpectating, self)
  self.BuffSytemCom = uPlayCharacter:GetBuffComponent()
  if self.BuffSytemCom and slua.isValid(self.BuffSytemCom) then
    self:AddControlEventByControl(self.BuffSytemCom, "OnClientAddBuffEvent", function(BuffID, SkillID, InstID)
      self:OnBuffAdd(BuffID, SkillID, InstID)
    end)
    self:AddControlEventByControl(self.BuffSytemCom, "OnClientRemoveBuffEvent", function(BuffID, SkillID, InstID)
      self:OnBuffRemove(BuffID, SkillID, InstID)
    end)
    self:AddControlEventByControl(self.BuffSytemCom, "OnClientUpdateBuffEvent", function(BuffID, SkillID, InstID)
      self:OnBuffUpdate(BuffID, SkillID, InstID)
    end)
    self:AddCommonEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_UPDATE_BUFFLIST_MODE, self.OnUpdateBuffListMode, self)
    print(bWriteLog and "BuffList:TryBindDelegate - Success, BuffSystem:", self.BuffSytemCom)
    self.BuffItemMap = {}
    self.BuffItemPriorityQueue = {}
    for _, buffItem in ipairs(self.PreCreatedBuffItems) do
      if slua.isValid(buffItem) then
        buffItem:ResetBuffItem()
        buffItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
    self:LoadBuffDataSave()
    local AllBuffs = self.BuffSytemCom:GetAllBuffInfo()
    if AllBuffs and AllBuffs:Num() > 0 then
      print(bWriteLog and "BuffList:TryBindDelegate - CurAllBuffs:", AllBuffs:Num())
      self.bIsReconnecting = true
      for i = 1, AllBuffs:Num() do
        local BuffItem = AllBuffs:Get(i - 1)
        if slua.isValid(BuffItem) then
          self:OnBuffAdd(BuffItem.BuffID, BuffItem.CauseSkillID, BuffItem.InstID)
          print(bWriteLog and "BuffList:TryBindDelegate - AddBuff If Exist, BuffID:", BuffItem.BuffID)
        else
          print(bWriteLog and "BuffList:TryBindDelegate - AddBuff If Exist but buff invalid, BuffIndex:", i)
        end
      end
      self.bIsReconnecting = false
    end
  end
end
function BuffList:PreCreateBuffItems()
  print(bWriteLog and "BuffList:PreCreateBuffItems")
  for i = 1, self.MaxBuffItemCount do
    local NewBuffItem = slua.loadUI(self.BuffItemUIPath)
    if slua.isValid(NewBuffItem) then
      NewBuffItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      if self.bUseTwoBox then
        if 5 <= i and i <= 8 then
          self.UIRoot.BuffListLeftBox:AddChild(NewBuffItem)
        else
          self.UIRoot.BuffListRightBox:AddChild(NewBuffItem)
        end
      elseif i <= 4 then
        self.UIRoot.BuffListVerticalBox:AddChild(NewBuffItem)
      end
      table.insert(self.PreCreatedBuffItems, NewBuffItem)
      print(bWriteLog and "BuffList:PreCreateBuffItems - Created BuffItem", i)
    end
  end
  print(bWriteLog and "BuffList:PreCreateBuffItems - Success, Created:", #self.PreCreatedBuffItems)
end
function BuffList:OnEnterSpectating()
  print(bWriteLog and "BuffList:OnEnterSpectating")
  self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function BuffList:OnQuitSpectating()
  print(bWriteLog and "BuffList:OnQuitSpectating")
  self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function BuffList:LoadBuffDataSave()
  print(bWriteLog and "BuffList:LoadBuffDataSave")
  local bIsSaveExit = UGameplayStatics.DoesSaveGameExist("BP_BuffGuid_Save", 0)
  if bIsSaveExit then
    local BuffSaveSlot = UGameplayStatics.LoadGameFromSlot("BP_BuffGuid_Save", 0)
    if BuffSaveSlot and BuffSaveSlot.BuffGuidCountMap then
      local BuffGuidCountMap = BuffSaveSlot.BuffGuidCountMap
      for BuffID, BuffGuidCount in pairs(BuffGuidCountMap) do
        self.BuffGuidCount[BuffID] = BuffGuidCount
        print(bWriteLog and "BuffList:LoadBuffDataSave - BuffGuidCount:", BuffID, BuffGuidCount)
      end
    end
  else
    print(bWriteLog and "BuffList:LoadBuffDataSave - SaveGameToSlot")
    local BuffSaveClass = slua.loadClass("/Game/BluePrints/Config/BP_BuffGuid_Save.BP_BuffGuid_Save")
    if BuffSaveClass then
      local NewSaveGameSlot = UGameplayStatics.CreateSaveGameObject(BuffSaveClass)
      if NewSaveGameSlot then
        UGameplayStatics.SaveGameToSlot(NewSaveGameSlot, "BP_BuffGuid_Save", 0)
        print(bWriteLog and "BuffList:LoadBuffDataSave - SaveGameToSlot end")
      end
    end
  end
end
function BuffList:OnBuffAdd(BuffID, SkillID, InstID)
  print(bWriteLog and "BuffList:OnBuffAdd - BuffID:" .. tostring(BuffID) .. " InstID:" .. tostring(InstID))
  if not self.BuffSytemCom or not slua.isValid(self.BuffSytemCom) then
    print(bWriteLog and "BuffList:OnBuffAdd - Failed, BuffSystem is nil")
    return
  end
  if self.BuffItemMap[InstID] then
    print(bWriteLog and "BuffList:OnBuffAdd - Buff Is Already Exist")
    return
  end
  local ubuffobj = self.BuffSytemCom:GetSTBuffByBuffID(BuffID)
  if not ubuffobj or not slua.isValid(ubuffobj) then
    print(bWriteLog and "BuffList:OnBuffAdd - Error, Cant Find Buff")
    return
  end
  if ubuffobj.TipsOnAddBuff and ubuffobj.TipsOnAddBuff > 0 then
    print(bWriteLog and "BuffList:OnBuffAdd - DisplayBuffTip, TipID:", ubuffobj.TipsOnAddBuff)
    self:AddGameTimer(0.01, false, function()
      IngameTipsTools.BattleNormalTipsByTextID(ubuffobj.TipsOnAddBuff)
    end)
  end
  if not ubuffobj.NeedShowBuffTypeInBuffList or 0 >= ubuffobj.NeedShowBuffTypeInBuffList then
    print(bWriteLog and "BuffList:OnBuffAdd - Buff no need to show, BuffID:", BuffID)
    return
  end
  local BuffData = CDataTable.GetTableData("BuffTable", BuffID)
  if BuffData == nil or BuffData.ShowingPriority == nil then
    print(bWriteLog and "BuffList:OnBuffAdd buff data is invalid!")
    return
  end
  print(bWriteLog and "BuffList:OnBuffAdd ShowingPriority", BuffID, BuffData.ShowingPriority)
  self.BuffItemMap[InstID] = true
  local CurBuffIdx = #self.BuffItemPriorityQueue
  while 0 < CurBuffIdx and self.BuffItemPriorityQueue[CurBuffIdx] do
    local CurInstID = self.BuffItemPriorityQueue[CurBuffIdx]
    local CurBuffID = self:GetBuffIDByInstID(CurInstID)
    if not CurBuffID then
      break
    end
    local CurBuffData = CDataTable.GetTableData("BuffTable", CurBuffID)
    if CurBuffData ~= nil and CurBuffData.ShowingPriority ~= nil and BuffData.ShowingPriority > CurBuffData.ShowingPriority then
      CurBuffIdx = CurBuffIdx - 1
    else
      break
    end
  end
  print(bWriteLog and "BuffItemPriorityQueue CurBuffIdx", CurBuffIdx)
  table.insert(self.BuffItemPriorityQueue, CurBuffIdx + 1, InstID)
  local DSEndTime = self.BuffSytemCom:GetBuffDSEndTime(InstID, 0)
  local Duration = self.BuffSytemCom:GetBuffDuration(InstID, 0)
  local LayerCount = self.BuffSytemCom:GetBuffLayerCount(InstID, 0)
  self.CurrentAdd  self:RefreshBuffListUI()
  print(bWriteLog and "BuffList:OnBuffAdd - Success BuffID:" .. BuffID)
end
function BuffList:OnBuffRemove(BuffID, SkillID, InstID)
  print(bWriteLog and "BuffList:OnBuffRemove - BuffID:" .. BuffID .. " InstID:" .. InstID)
  if self.BuffItemMap[InstID] then
    self.BuffItemMap[InstID] = nil
    for idx, instID in ipairs(self.BuffItemPriorityQueue) do
      if instID == InstID then
        table.remove(self.BuffItemPriorityQueue, idx)
        break
      end
    end
    print(bWriteLog and "BuffList:OnBuffRemove - Removed from queue, BuffID:" .. BuffID .. " InstID:" .. InstID .. " QueueLen:" .. #self.BuffItemPriorityQueue)
    local remainCount = 0
    for _ in pairs(self.BuffItemMap) do
      remainCount = remainCount + 1
    end
    print(bWriteLog and "BuffList:OnBuffRemove - RemainBuffItem Num:", remainCount)
  end
  self:RefreshBuffListUI()
end
function BuffList:RefreshBuffListUI()
  local MaxNum = self.bUseTwoBox and 8 or 4
  local starttime = Client.GetTimeInMiliSeconds()
  self:ClearInvalidBuff()
  local CurBuffIdx = 1
  while CurBuffIdx <= #self.BuffItemPriorityQueue and MaxNum >= CurBuffIdx do
    local instID = self.BuffItemPriorityQueue[CurBuffIdx]
    local buffItem = self:GetPreCreatedBuffItem(CurBuffIdx)
    if slua.isValid(buffItem) then
      local BuffID = self:GetBuffIDByInstID(instID)
      if BuffID then
        local ubuffobj = self.BuffSytemCom:GetSTBuffByBuffID(BuffID)
        if slua.isValid(ubuffobj) then
          local DSEndTime = self.BuffSytemCom:GetBuffDSEndTime(instID, 0)
          local Duration = self.BuffSytemCom:GetBuffDuration(instID, 0)
          local LayerCount = self.BuffSytemCom:GetBuffLayerCount(instID, 0)
          local SkillID = self:GetSkillIDByInstID(instID)
          local prevBuffID = buffItem:GetBuffID()
          if prevBuffID ~= BuffID then
            print(bWriteLog and "BuffList:RefreshBuffListUI - BuffItem reassigned, prevBuffID:", prevBuffID, "-> BuffID:", BuffID)
            buffItem:ClearAutoShowTimer()
          end
          buffItem:InitBuffInfo(instID, ubuffobj, Duration, DSEndTime, LayerCount, SkillID)
          buffItem:SetParentWidget(self.UIRoot)
          buffItem:UpdateBuffInfo(instID, BuffID, DSEndTime, Duration, LayerCount)
          buffItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          if self.CurrentAddBuffID == BuffID and prevBuffID ~= BuffID then
            print(bWriteLog and "BuffList:RefreshBuffListUI - Trigger CheckForAutoShowDesc, BuffID:", BuffID)
            self:CheckForAutoShowDesc(BuffID, buffItem)
          end
          print(bWriteLog and "BuffList:RefreshBuffListUI - Show slot:", CurBuffIdx, "instID:", instID, "BuffID:", BuffID)
        else
          print(bWriteLog and "BuffList:RefreshBuffListUI - ubuffobj invalid, recycle slot:", CurBuffIdx, "BuffID:", BuffID)
          buffItem:ResetBuffItem()
          buffItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
      else
        print(bWriteLog and "BuffList:RefreshBuffListUI - BuffID not found, recycle slot:", CurBuffIdx, "instID:", instID)
        buffItem:ResetBuffItem()
        buffItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
    CurBuffIdx = CurBuffIdx + 1
  end
  for i = math.max(1, #self.BuffItemPriorityQueue + 1), #self.PreCreatedBuffItems do
    local buffItem = self.PreCreatedBuffItems[i]
    if slua.isValid(buffItem) then
      local prevBuffID = buffItem:GetBuffID()
      if prevBuffID and prevBuffID ~= 0 then
        buffItem:ResetBuffItem()
      end
      buffItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  local endtime = Client.GetTimeInMiliSeconds()
  print(bWriteLog and "BuffList:RefreshBuffListUI", endtime - starttime, self.bUseTwoBox, #self.BuffItemPriorityQueue, MaxNum)
  self.CurrentAddBuffID = nil
end
function BuffList:ClearInvalidBuff()
  local ValidBuffInstIDs = {}
  for index, instID in ipairs(self.BuffItemPriorityQueue) do
    if self.BuffItemMap[instID] then
      table.insert(ValidBuffInstIDs, instID)
    end
  end
  self.BuffItemPriorityQueue = ValidBuffInstIDs
end
function BuffList:GetPreCreatedBuffItem(index)
  if index < 1 or index > #self.PreCreatedBuffItems then
    return nil
  end
  return self.PreCreatedBuffItems[index]
end
function BuffList:GetBuffIDByInstID(instID)
  if not self.BuffSytemCom or not slua.isValid(self.BuffSytemCom) then
    return nil
  end
  local AllBuffs = self.BuffSytemCom:GetAllBuffInfo()
  if AllBuffs and AllBuffs:Num() > 0 then
    for i = 1, AllBuffs:Num() do
      local BuffItem = AllBuffs:Get(i - 1)
      if slua.isValid(BuffItem) and BuffItem.InstID == instID then
        return BuffItem.BuffID
      end
    end
  end
  return nil
end
function BuffList:GetSkillIDByInstID(instID)
  if not self.BuffSytemCom or not slua.isValid(self.BuffSytemCom) then
    return 0
  end
  local AllBuffs = self.BuffSytemCom:GetAllBuffInfo()
  if AllBuffs and 0 < AllBuffs:Num() then
    for i = 1, AllBuffs:Num() do
      local BuffItem = AllBuffs:Get(i - 1)
      if slua.isValid(BuffItem) and BuffItem.InstID == instID then
        return BuffItem.CauseSkillID
      end
    end
  end
  return 0
end
function BuffList:OnUpdateBuffListMode(_, _, bUseTwoBox)
  print(bWriteLog and "BuffList:OnUpdateBuffListMode", bUseTwoBox)
  if self.bUseTwoBox ~= bUseTwoBox then
    self:DestroyPreCreatedBuffItems()
    self:InitBoxAndPreCreateBuffItems(bUseTwoBox)
  end
end
function BuffList:OnBuffUpdate(BuffID, SkillID, InstID)
  if self.BuffSytemCom and slua.isValid(self.BuffSytemCom) then
    local ubuffobj = self.BuffSytemCom:GetSTBuffByBuffID(BuffID)
    if slua.isValid(ubuffobj) and self.BuffItemMap[InstID] then
      do
        local DSEndTime = self.BuffSytemCom:GetBuffDSEndTime(InstID, 0)
        local Duration = self.BuffSytemCom:GetBuffDuration(InstID, 0)
        local LayerCount = self.BuffSytemCom:GetBuffLayerCount(InstID, 0)
        print(bWriteLog and "BuffList:OnBuffUpdate BuffID:", BuffID, DSEndTime, Duration, LayerCount)
        local buffItemIdx
        for idx, instID in ipairs(self.BuffItemPriorityQueue) do
          if instID == InstID then
            buffItemIdx = idx
            break
          end
        end
        local uBuffItem = buffItemIdx and self:GetPreCreatedBuffItem(buffItemIdx) or nil
        if slua.isValid(uBuffItem) then
          uBuffItem:UpdateBuffInfo(InstID, BuffID, DSEndTime, Duration, LayerCount)
        end
        if ubuffobj.TipsOnAddBuff and 0 < ubuffobj.TipsOnAddBuff then
          print(bWriteLog and "BuffList:OnBuffAdd DispalyBuffTip, TipID:", ubuffobj.TipsOnAddBuff, ubuffobj.LayerCount)
          self:AddGameTimer(0.01, false, function()
            IngameTipsTools.BattleNormalTipsByTextID(ubuffobj.TipsOnAddBuff)
          end)
        end
      end
    end
  end
end
function BuffList:CheckForAutoShowDesc(BuffID, BuffItem)
  if not BuffID or not BuffItem then
    return
  end
  if self.bIsReconnecting then
    print(bWriteLog and "BuffList:CheckForAutoShowDesc - Skip, reconnecting, BuffID:", BuffID)
    return
  end
  if not self.BuffGuidCount then
    print(bWriteLog and "BuffList:CheckForAutoShowDesc - Error, no BuffGuidCount")
    return
  end
  local BuffGuidCount = self.BuffGuidCount[BuffID]
  local BuffCountInCurMatch = self.CurMatchBuffCountMap[BuffID]
  print(bWriteLog and "BuffList:CheckForAutoShowDesc - BuffID:", BuffID, "GuidMatchCount:", BuffGuidCount, "CurMatchCount:", BuffCountInCurMatch)
  if BuffGuidCount ~= nil then
    if BuffGuidCount >= self.MaxGuidMatchCount then
      print(bWriteLog and "BuffList:CheckForAutoShowDesc - Skip, exceeded MaxGuidMatchCount:", self.MaxGuidMatchCount, "BuffID:", BuffID)
      return
    elseif BuffCountInCurMatch ~= nil then
      if BuffCountInCurMatch < self.MaxGuidEachMatch then
        print(bWriteLog and "BuffList:CheckForAutoShowDesc - AutoShow, BuffID:", BuffID, "CurMatchCount:", BuffCountInCurMatch)
        BuffItem:AutoShowBuffDesc()
        self.CurMatchBuffCountMap[BuffID] = BuffCountInCurMatch + 1
      else
        print(bWriteLog and "BuffList:CheckForAutoShowDesc - Skip, exceeded MaxGuidEachMatch:", self.MaxGuidEachMatch, "BuffID:", BuffID)
      end
    else
      print(bWriteLog and "BuffList:CheckForAutoShowDesc - AutoShow first time this match, BuffID:", BuffID)
      BuffItem:AutoShowBuffDesc()
      self.CurMatchBuffCountMap[BuffID] = 1
      self:OnBuffGuidMatchCountAdd(BuffID)
    end
  else
    print(bWriteLog and "BuffList:CheckForAutoShowDesc - AutoShow first time ever, BuffID:", BuffID)
    BuffItem:AutoShowBuffDesc()
    self.CurMatchBuffCountMap[BuffID] = 1
    self.BuffGuidCount[BuffID] = 1
    self:OnBuffGuidMatchCountAdd(BuffID)
  end
end
function BuffList:HideAllBuffDesc()
  print(bWriteLog and "BuffList:HideAllBuffDesc")
  for _, buffItem in ipairs(self.PreCreatedBuffItems) do
    if slua.isValid(buffItem) then
      buffItem:HideBuffDesc()
    end
  end
end
function BuffList:OnBuffGuidMatchCountAdd(BuffID)
  print(bWriteLog and "BuffList:OnBuffGuidMatchCountAdd", BuffID)
  local BuffSaveSlot = UGameplayStatics.LoadGameFromSlot("BP_BuffGuid_Save", 0)
  if not slua.isValid(BuffSaveSlot) or not BuffSaveSlot.BuffGuidCountMap then
    return
  end
  local BuffGuidCountMap = BuffSaveSlot.BuffGuidCountMap
  local nCount, bFind = BuffGuidCountMap:Get(BuffID)
  if bFind then
    BuffGuidCountMap:Add(BuffID, nCount + 1)
  else
    BuffGuidCountMap:Add(BuffID, 1)
  end
  UGameplayStatics.SaveGameToSlot(BuffSaveSlot, "BP_BuffGuid_Save", 0)
  print(bWriteLog and "BuffList:OnBuffGuidMatchCountAdd", BuffID, BuffGuidCountMap:Get(BuffID))
end
local class = require("class")
local DynamicMountUIBase = require("GameLua.Mod.BaseMod.Client.DynamicMountUIBase")
return class(DynamicMountUIBase, nil, BuffList)