local ISettingDBInterface = {}
function ISettingDBInterface:new()
  local obj = {
    uiDataOrigin = {},
    uiData = {},
    changes = {}
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function ISettingDBInterface:LoadUserSetting()
  error("LoadUserSetting must be implemented by subclass")
end
function ISettingDBInterface:LoadDefaultSetting()
  error("LoadDefaultSetting must be implemented by subclass")
end
function ISettingDBInterface:Clear()
  self.uiData = {}
  self.uiDataOrigin = {}
  self.changes = {}
  self.defaultSetting = nil
end
function ISettingDBInterface:UpdateUIData(key, value, bSyncChanges)
  if bSyncChanges == nil then
    bSyncChanges = true
  end
  if bSyncChanges then
    self:updateChanges(key, value)
  end
  self.uiData[key] = value
  return value
end
function ISettingDBInterface:UpdateUIDataOneMinus(key)
  local value = self.uiData[key]
  if value == nil then
    log_warning("[WARN] ISettingDBInterface:UpdateUIDataOneMinus key not found: %s", key)
    return
  end
  value = not value
  self:UpdateUIData(key, value)
  return value
end
function ISettingDBInterface:SaveChanges()
  error("SaveChanges must be implemented by subclass")
end
function ISettingDBInterface:ResetToLastSave()
  for key, value in pairs(self.uiDataOrigin) do
    self.uiData[key] = value
  end
  self.changes = {}
end
function ISettingDBInterface:HasUnsavedChanges()
  return next(self.changes) ~= nil
end
function ISettingDBInterface:GetUnsavedChanges()
  return self.changes
end
function ISettingDBInterface:GetUIData(key)
  if key then
    return self.uiData[key]
  end
end
function ISettingDBInterface:GetSuperData()
  return self.uiData
end
function ISettingDBInterface:GetOriginData()
  return self.uiDataOrigin
end
function ISettingDBInterface:updateChanges(key, newValue)
  if newValue ~= self.uiDataOrigin[key] then
    self.changes[key] = newValue
  else
    self.changes[key] = nil
  end
end
return ISettingDBInterface