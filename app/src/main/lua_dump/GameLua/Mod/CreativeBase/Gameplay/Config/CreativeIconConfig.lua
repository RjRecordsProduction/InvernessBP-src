local TableUtil = require("common.table_util")
local PublishRegionMacros = Client and require("client.slua.config.ClientMacros.PublishRegionMacros")
local CreativeIconConfig = {
  DynamicIcons = {}
}
function CreativeIconConfig.GetTable(TableName)
  if not CDataTable then
    return {}
  end
  local RowConfigs = CDataTable.GetTable(TableName)
  local CopyConfigs = {}
  for k, v in pairs(RowConfigs) do
    CopyConfigs[k] = v
  end
  for ID, _ in pairs(CreativeIconConfig.DynamicIcons) do
    if TableName == "UGCBuffOverrideIconConfig" then
      CopyConfigs[ID] = CreativeIconConfig._MakeUGCBuffOverrideIconConfig(ID)
    elseif TableName == "UGCItemOverrideIconConfig" then
      CopyConfigs[ID] = CreativeIconConfig._MakeUGCItemOverrideIconConfig(ID)
    elseif TableName == "UGCImageTable" then
      CopyConfigs[ID] = CreativeIconConfig._MakeUGCImageTable(ID)
    end
  end
  return CopyConfigs
end
function CreativeIconConfig.GetTableData(TableName, Key)
  local Table = CreativeIconConfig.GetTable(TableName)
  return Table[Key]
end
function CreativeIconConfig.GetAllDynamicIcons()
  return TableUtil.FastCopyTable(CreativeIconConfig.DynamicIcons)
end
function CreativeIconConfig.RegisterDynamicIcon(ID, IconPath)
  if ID == nil or IconPath == nil then
    return
  end
  if PublishRegionMacros and PublishRegionMacros.IsBLUEHOLE() then
    print(bWriteLog and "CreativeIconConfig.RegisterDynamicIcon BlueHole forbidden")
    return
  end
  CreativeIconConfig.DynamicIcons[ID] = IconPath
end
function CreativeIconConfig.UnregisterDynamicIcon(ID)
  if ID == nil then
    return
  end
  CreativeIconConfig.DynamicIcons[ID] = nil
end
function CreativeIconConfig._MakeUGCBuffOverrideIconConfig(ID)
  if ID == nil then
    return nil
  end
  local IconPath = CreativeIconConfig.DynamicIcons[ID]
  local UGCBuffOverrideIconConfigInst = {
    ID = ID,
    IconPath = IconPath,
    Small  }
  return UGCBuffOverrideIconConfigInst
end
function CreativeIconConfig._MakeUGCItemOverrideIconConfig(ID)
  if ID == nil then
    return nil
  end
  local IconPath = CreativeIconConfig.DynamicIcons[ID]
  local UGCItemOverrideIconConfigInst = {
    IconID = ID,
    IconPath = IconPath,
    Small  }
  return UGCItemOverrideIconConfigInst
end
function CreativeIconConfig._MakeUGCImageTable(ID)
  if ID == nil then
    return nil
  end
  local IconPath = CreativeIconConfig.DynamicIcons[ID]
  local UGCImageTableInst = {
    ID = ID,
    Name = "",
    Category = 0,
    ImagePath = IconPath,
    Tags_a = "",
    SelectorKey = 0
  }
  return UGCImageTableInst
end
return CreativeIconConfig