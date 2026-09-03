local logic_wardrobe_data_center = {}
local DataEntity, InheritDataEntity
function logic_wardrobe_data_center.CreateWardrobeDataEntity(DataSource)
  local CWardrobeDataEntity = require("client.slua.logic.wardrobe.WardrobeDataEntity")
  return CWardrobeDataEntity(DataSource)
end
function logic_wardrobe_data_center.GetWardrobeData(DataSource)
  DataSource = DataSource or EWardrobeDataSource.Wardrobe
  if DataSource == EWardrobeDataSource.InheritWardrobe then
    if not InheritDataEntity then
      InheritDataEntity = logic_wardrobe_data_center.CreateWardrobeDataEntity(DataSource)
    end
    return InheritDataEntity
  else
    if not DataEntity then
      DataEntity = logic_wardrobe_data_center.CreateWardrobeDataEntity(DataSource)
    end
    return DataEntity
  end
end
return logic_wardrobe_data_center