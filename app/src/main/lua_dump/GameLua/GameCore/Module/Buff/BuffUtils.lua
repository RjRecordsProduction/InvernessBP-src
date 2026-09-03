local BuffUtils = {}
local TestBuffInstData = {}
local PendingOverrideSkillIDs = {}
function BuffUtils.GetOverrideBuffInstData(CauseSkillID)
  local data = TestBuffInstData[CauseSkillID]
  if data == nil and CauseSkillID and 0 < CauseSkillID then
    PendingOverrideSkillIDs[CauseSkillID] = true
  end
  return data
end
function BuffUtils.GetAllBuffInstData()
  return TestBuffInstData
end
function BuffUtils.SetOverrideBuffInstData(SkillID, Data)
  print(bWriteLog and string.format("BuffUtils:SetOverrideBuffInstData:%d", SkillID))
  TestBuffInstData[SkillID] = Data
end
function BuffUtils.ClearAllBuffInstData()
  print(bWriteLog and "BuffUtils.ClearAllBuffInstData")
  TestBuffInstData = {}
  PendingOverrideSkillIDs = {}
end
function BuffUtils.PopPendingOverrideSkillIDs()
  local pending = PendingOverrideSkillIDs
  PendingOverrideSkillIDs = {}
  return pending
end
function BuffUtils.GetSkillBuffList(CauseSkillID)
  local SkillBuffData = CDataTable.GetTableData("SkillBuffTable", CauseSkillID)
  local BuffList = {}
  if SkillBuffData then
    table.insert(BuffList, SkillBuffData.Buff1ID)
    table.insert(BuffList, SkillBuffData.Buff2ID)
    table.insert(BuffList, SkillBuffData.Buff3ID)
  end
  return BuffList
end
function BuffUtils.GetOverrideBuffList(CauseSkillID)
  local OverrideBuffInstData = TestBuffInstData[CauseSkillID]
  local BuffList = {}
  if OverrideBuffInstData then
    for BuffID, _ in pairs(OverrideBuffInstData) do
      table.insert(BuffList, BuffID)
    end
  end
  return BuffList
end
return BuffUtils