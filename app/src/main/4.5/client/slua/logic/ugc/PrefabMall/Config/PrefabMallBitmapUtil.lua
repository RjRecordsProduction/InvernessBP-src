local PrefabMallBitmapUtil = {}
function PrefabMallBitmapUtil.EncodeBitmap(tMap, sTableName)
  if nil == sTableName or nil == tMap then
    printf("PrefabMallBitmapUtil.EncodeBitmap Error Run: sTableName is nil or tMap is nil")
    return
  end
  local resList = {}
  for id, _ in pairs(tMap) do
    local config = CDataTable.GetTableData(sTableName, id)
    if config and config.ID and config.ID > 0 then
      table.insert(resList, config.ID)
    end
  end
  table.sort(resList)
  local bitmapSize = 32
  local bitmapEndIndex = bitmapSize
  local bitmap = {}
  local byteList = {}
  for i, v in ipairs(resList) do
    if v <= bitmapEndIndex then
      byteList[#byteList + 1] = v
    else
      bitmap[#bitmap + 1] = byteList
      bitmapEndIndex = bitmapEndIndex + bitmapSize
      while v > bitmapEndIndex do
        bitmap[#bitmap + 1] = {}
        bitmapEndIndex = bitmapEndIndex + bitmapSize
      end
      byteList = {
        [1] = v
      }
    end
  end
  bitmap[#bitmap + 1] = byteList
  local FixedBitmap = {}
  for i, byteListItem in ipairs(bitmap) do
    local Int = FuncUtil.ByteList2Int(byteListItem)
    if 0 < Int then
      FixedBitmap[i] = Int
    end
  end
  return FixedBitmap
end
function PrefabMallBitmapUtil.TestDecodeBitmap(feature_id_list, sTableName)
  feature_id_list = feature_id_list or {}
  local bitList = {}
  local size = 32
  for k, v in pairs(feature_id_list) do
    if v and 0 < v then
      local margin = size * (k - 1)
      local tmpList = FuncUtil.Int2ByteList(v)
      if tmpList ~= nil then
        for bitKey, bitV in ipairs(tmpList) do
          bitV = bitV + margin
          table.insert(bitList, bitV)
        end
      end
    end
  end
  local idList = {}
  if sTableName then
    for k, v in ipairs(bitList) do
      local config = CDataTable.GetTableDataByFilter(sTableName, "ID", v)
      if config and config.AssetID and 0 < config.AssetID then
        table.insert(idList, config.AssetID)
      end
    end
  else
    for k, v in ipairs(bitList) do
      table.insert(idList, v)
    end
  end
  return idList
end
return PrefabMallBitmapUtil