local CharacterAvatarColorDIYSubsystem = {}
local EStateType = import("EStateType")
local EFollowState = import("EFollowState")
function CharacterAvatarColorDIYSubsystem:ctor()
  self.CachedData = {}
  self.PendingRequestArray = {}
  self.PendingApplySchemeComps = {}
  self.PendingApplyCompsIndex = 0
  self.RequestTimer = nil
end
function CharacterAvatarColorDIYSubsystem:_PostConstruct()
  printf("CharacterAvatarColorDIYSubsystem:_PostConstruct")
  self:RegistEvents()
end
function CharacterAvatarColorDIYSubsystem:OnInit()
  print(bWriteLog and "CharacterAvatarColorDIYSubsystem:OnInit")
end
function CharacterAvatarColorDIYSubsystem:OnRelease()
  self.PendingRequestArray = {}
  self.PendingApplySchemeComps = {}
  self.CachedData = {}
  self.RequestTimer = nil
  CharacterAvatarColorDIYSubsystem.__super.OnRelease(self)
end
function CharacterAvatarColorDIYSubsystem:RegistEvents()
  print(bWriteLog and "CharacterAvatarColorDIYSubsystem:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_BATTLEPROFILE, EVENTID_BATTLEPROFILE_SUIT_DYE_RES, self.OnGetDIYData, self)
end
function CharacterAvatarColorDIYSubsystem:FindAndApplySchemeInCache(PlayerID, ItemID, AvatarComp)
  if not (self.CachedData[PlayerID] and self.CachedData[PlayerID][ItemID]) or not self.CachedData[PlayerID][ItemID].Scheme then
    return false
  end
  local OriginPlanID = self.CachedData[PlayerID][ItemID].OriginPlanID
  print(bWriteLog and "CharacterAvatarColorDIYSubsystem:FindAndApplySchemeInCache PlayerID" .. tostring(PlayerID))
  self:UseColorScheme(AvatarComp, PlayerID, ItemID, self.CachedData[PlayerID][ItemID].Scheme, OriginPlanID)
  return true
end
function CharacterAvatarColorDIYSubsystem:UseColorScheme(AvatarComp, PlayerID, ItemID, OriginScheme, OriginPlanID)
  print(bWriteLog and "CharacterAvatarColorDIYSubsystem:UseColorScheme PlayerID" .. tostring(PlayerID))
  if slua.isValid(AvatarComp) and AvatarComp.ApplyDIYColorData then
    local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
    logic_suit_dye:ApplySuitSchemeData(AvatarComp, ItemID, OriginScheme, OriginPlanID)
  end
  self:AddCacheData(PlayerID, ItemID, OriginScheme, nil, OriginPlanID)
end
function CharacterAvatarColorDIYSubsystem:CheckAndAddPendingComps(AvatarComp, PlayerID, ItemID)
  if not slua.isValid(AvatarComp) then
    return
  end
  local Find = false
  for k, v in pairs(self.PendingApplySchemeComps) do
    if slua.isValid(v.AvatarComp) and v.AvatarComp == AvatarComp then
      Find = true
      local comp = self.PendingApplySchemeComps[k]
      if comp.PlayerID ~= PlayerID or comp.ItemID ~= ItemID then
        self:RemoveCachePendingIndex(comp.PlayerID, comp.ItemID, k)
        comp.        comp.        self:AddCacheData(PlayerID, ItemID, nil, k)
      end
      break
    end
  end
  if not Find then
    self.PendingApplyCompsIndex = self.PendingApplyCompsIndex + 1
    self.PendingApplySchemeComps[self.PendingApplyCompsIndex] = {
      AvatarComp = AvatarComp,
      PlayerID = PlayerID,
          }
    self:AddCacheData(PlayerID, ItemID, nil, self.PendingApplyCompsIndex)
  end
end
function CharacterAvatarColorDIYSubsystem:AddCacheData(PlayerID, ItemID, Scheme, Index, OriginPlanID)
  if not self.CachedData[PlayerID] then
    self.CachedData[PlayerID] = {}
  end
  if not self.CachedData[PlayerID][ItemID] then
    self.CachedData[PlayerID][ItemID] = {}
  end
  if Scheme then
    self.CachedData[PlayerID][ItemID].    self.CachedData[PlayerID][ItemID].  end
  if Index ~= nil then
    if not self.CachedData[PlayerID][ItemID].PendingApplyIndexs then
      self.CachedData[PlayerID][ItemID].PendingApplyIndexs = {}
    end
    table.insert(self.CachedData[PlayerID][ItemID].PendingApplyIndexs, Index)
  end
end
function CharacterAvatarColorDIYSubsystem:RemoveCacheData(PlayerID)
  PlayerID = tonumber(PlayerID)
  if not self.CachedData[PlayerID] then
    return
  end
  for _, _Info in pairs(self.CachedData[PlayerID]) do
    if _Info then
      _Info.Scheme = nil
    end
  end
end
function CharacterAvatarColorDIYSubsystem:RemoveCachePendingIndex(PlayerID, ItemID, Index)
  if self.CachedData[PlayerID] and self.CachedData[PlayerID][ItemID] and self.CachedData[PlayerID][ItemID].PendingApplyIndexs then
    for i, v in ipairs(self.CachedData[PlayerID][ItemID].PendingApplyIndexs) do
      if v == Index then
        table.remove(self.CachedData[PlayerID][ItemID].PendingApplyIndexs, i)
        break
      end
    end
  end
end
function CharacterAvatarColorDIYSubsystem:RequestColorData(AvatarComp, PlayerID, ItemID)
  log(bWriteLog and string.format("CharacterAvatarColorDIYSubsystem:RequestColorData. PlayerID=%s, ItemID=%s", tostring(PlayerID), tostring(ItemID)))
  if not PlayerID then
    log(bWriteLog and "CharacterAvatarColorDIYSubsystem:RequestColorData. PlayerID is invalid, return")
    return
  end
  local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
  if not logic_suit_dye:IsDyeSuit(ItemID) then
    return
  end
  if self:FindAndApplySchemeInCache(PlayerID, ItemID, AvatarComp) then
    return
  end
  self:CheckAndAddPendingComps(AvatarComp, PlayerID, ItemID)
  table.insert(self.PendingRequestArray, {PlayerID = PlayerID, ItemID = ItemID})
  if self.RequestTimer ~= nil then
    return
  end
  self.RequestTimer = self:AddGameTimer(0, false, function()
    if #self.PendingRequestArray == 0 then
      print(bWriteLog and "CharacterAvatarColorDIYSubsystem:RequestColorData Error PendingRequestArray Num == 0")
    else
      logic_suit_dye:BattleProfileBatchGet(g_game_id, self.PendingRequestArray)
    end
    self.PendingRequestArray = {}
    self.RequestTimer = nil
  end)
end
function CharacterAvatarColorDIYSubsystem:OnGetDIYData(_, _, FormatData, OriginPlanData)
  print(bWriteLog and "CharacterAvatarColorDIYSubsystem:OnGetDIYData")
  if not FormatData then
    print(bWriteLog and "CharacterAvatarColorDIYSubsystem:OnGetDIYData Net Data nil")
    return
  end
  local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
  for UID, SchemeDatas in pairs(FormatData) do
    if self.CachedData[UID] then
      for Period, Scheme in pairs(SchemeDatas) do
        local SuitIdsOfGivenPeriod = logic_suit_dye:GetAllSuitIdsOfGivenPeriod(Period)
        if #SuitIdsOfGivenPeriod == 0 then
          print(bWriteLog and "CharacterAvatarColorDIYSubsystem:OnGetDIYData Get No SuitID Of Period:" .. tostring(Period))
        else
          for _, SuitID in pairs(SuitIdsOfGivenPeriod) do
            if self.CachedData[UID][SuitID] and self.CachedData[UID][SuitID].PendingApplyIndexs then
              local PendingIndexs = self.CachedData[UID][SuitID].PendingApplyIndexs
              local OriginPlanID = OriginPlanData and OriginPlanData[UID] and OriginPlanData[UID][Period]
              for _, PendingIndex in pairs(PendingIndexs) do
                if self.PendingApplySchemeComps[PendingIndex] and self.PendingApplySchemeComps[PendingIndex].PlayerID == UID and self.PendingApplySchemeComps[PendingIndex].ItemID == SuitID then
                  self:UseColorScheme(self.PendingApplySchemeComps[PendingIndex].AvatarComp, UID, SuitID, Scheme, OriginPlanID)
                  self.PendingApplySchemeComps[PendingIndex] = nil
                end
              end
              self.CachedData[UID][SuitID].PendingApplyIndexs = nil
            end
          end
        end
      end
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, CharacterAvatarColorDIYSubsystem)