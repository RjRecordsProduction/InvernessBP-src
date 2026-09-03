local SuitMultiShapeDataUtil = {
  ShapeInfo = {}
}
function SuitMultiShapeDataUtil:GeneratePlayerAvatarData(PlayerInfo, uPlayerController)
  if not uPlayerController then
    return
  end
  self:_FillMultiShapeData(uPlayerController.UID, PlayerInfo)
end
function SuitMultiShapeDataUtil:SetShapeInfo(UID, ItemID, ShapeType, ShapeID)
  if not UID or not ItemID then
    return
  end
  if not self.ShapeInfo[UID] then
    self.ShapeInfo[UID] = {}
  end
  if ShapeType and ShapeID then
    self.ShapeInfo[UID][ItemID] = {ShapeType = ShapeType, ShapeID = ShapeID}
  else
    self.ShapeInfo[UID][ItemID] = nil
  end
end
function SuitMultiShapeDataUtil:GetShapeInfo(UID, ItemID)
  if not UID or not ItemID then
    return nil
  end
  return self.ShapeInfo[UID] and self.ShapeInfo[UID][ItemID]
end
function SuitMultiShapeDataUtil:ServerDropItem(PlayerKey, ItemID, Reason)
  if Client then
    return
  end
  self:ReportDropItem(PlayerKey, ItemID, Reason)
end
function SuitMultiShapeDataUtil:ReportDropItem(PlayerKey, ItemID, Reason)
  if Client then
    return
  end
  if not ItemID then
    return
  end
  if Reason ~= 0 and Reason ~= 2 then
    return
  end
  local UID = self:GetUIDByPlayerKey(PlayerKey)
  if not UID then
    return
  end
  local ShapeInfo = self:GetShapeInfo(UID, ItemID)
  if not ShapeInfo or ShapeInfo.ShapeType ~= 1 then
    return
  end
  local TLogStr = string.format("%d,%d", tonumber(ItemID) or 0, tonumber(ShapeInfo.ShapeID) or 0)
  local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
  if DSCommonTLogSubsystem then
    DSCommonTLogSubsystem:AddPlayerCommonTLogData(UID, 180, TLogStr, false)
    print(bWriteLog and "[Suit][TLog] AddPlayerCommonTLogData", 180, TLogStr)
  else
    print(bWriteLog and "[Suit][TLog] AddPlayerCommonTLogData 180 failed, can not find DSCommonTLogSubsystem")
  end
end
function SuitMultiShapeDataUtil:ReportBringGoldenSuit(UID)
  if not UID then
    return
  end
  if not self.ShapeInfo[UID] or not next(self.ShapeInfo[UID]) then
    return
  end
  local ChangeHeadList = {}
  for k, v in pairs(self.ShapeInfo[UID]) do
    local ShapeID = v.ShapeID
    if k and v.ShapeType == 1 and ShapeID then
      table.insert(ChangeHeadList, string.format("%d,%d", tonumber(k) or 0, tonumber(ShapeID) or 0))
    end
  end
  if not next(ChangeHeadList) then
    return
  end
  local TLogStr = table.concat(ChangeHeadList, ";")
  local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
  if DSCommonTLogSubsystem then
    DSCommonTLogSubsystem:AddPlayerCommonTLogData(UID, 179, TLogStr, true)
    print(bWriteLog and "[Suit][TLog] AddPlayerCommonTLogData", 179, TLogStr)
  else
    print(bWriteLog and "[Suit][TLog] AddPlayerCommonTLogData 179 failed, can not find DSCommonTLogSubsystem")
  end
end
function SuitMultiShapeDataUtil:GetUIDByPlayerKey(PlayerKey)
  local uPawn = Game:GetPlayerByPlayerKey(PlayerKey)
  if Game:IsValid(uPawn) then
    return Game:GetPlayerUID(uPawn)
  end
  return nil
end
function SuitMultiShapeDataUtil:_FillMultiShapeData(UID, PlayerInfo)
  if not UID or not PlayerInfo then
    return
  end
  if PlayerInfo.all_wear_ext then
    for i = 1, 4 do
      local wear = PlayerInfo.all_wear_ext[i]
      if wear then
        for _, v in pairs(wear) do
          if v and v[1] and v[6] then
            self:SetShapeInfo(UID, v[1], 1, v[6])
          end
        end
      end
    end
    local wear = PlayerInfo.all_wear_ext[6]
    if wear then
      for _, v in pairs(wear) do
        if v and v[1] and v[6] then
          self:SetShapeInfo(UID, v[1], 1, v[6])
        end
      end
    end
    local CurrentUseWear = PlayerInfo.use_rolewear and PlayerInfo.all_wear_ext[PlayerInfo.use_rolewear]
    if CurrentUseWear then
      for _, v in pairs(CurrentUseWear) do
        if v and v[1] then
          if v[6] then
            self:SetShapeInfo(UID, v[1], 1, v[6])
          end
          if v[5] then
            self:SetInitColorInfo(UID, v[1], v[5])
          end
        end
      end
    else
      print(bWriteLog and "SuitMultiShapeDataUtil:_FillMultiShapeData CurrentUseWear is invalid", UID)
    end
  end
  self:ReportBringGoldenSuit(UID)
end
function SuitMultiShapeDataUtil:SetInitColorInfo(UID, ItemID, ColorInfo)
  if not (UID and ItemID) or not ColorInfo then
    return
  end
  if not self.ColorInfo then
    self.ColorInfo = {}
  end
  if not self.ColorInfo[UID] then
    self.ColorInfo[UID] = {}
  end
  local DIYColorPlanID, DIYColorPartList, DIYColorOriginPlanID
  if type(ColorInfo) == "number" then
    DIYColorPlanID = ColorInfo
    DIYColorOriginPlanID = ColorInfo
  elseif type(ColorInfo) == "table" then
    DIYColorPartList = ColorInfo
    DIYColorOriginPlanID = ColorInfo.origin_plan
  else
    return
  end
  self.ColorInfo[UID] = {
    ItemID = ItemID,
    DIYColorPlanID = DIYColorPlanID,
    DIYColorPartList = DIYColorPartList,
      }
end
function SuitMultiShapeDataUtil:ClearUserInfo(UID)
  log(bWriteLog and "SuitMultiShapeDataUtil:ClearUserInfo UID:" .. tostring(UID))
  self:_ClearShapeInfo(UID)
  self:_ClearInitColorInfo(UID)
end
function SuitMultiShapeDataUtil:_ClearShapeInfo(UID)
  if not UID then
    return
  end
  if not self.ShapeInfo then
    return
  end
  self.ShapeInfo[UID] = nil
end
function SuitMultiShapeDataUtil:_ClearInitColorInfo(UID)
  if not UID then
    return
  end
  if not self.ColorInfo then
    return
  end
  self.ColorInfo[UID] = nil
end
function SuitMultiShapeDataUtil:GetInitColorInfo(UID)
  return self.ColorInfo and self.ColorInfo[UID]
end
return SuitMultiShapeDataUtil