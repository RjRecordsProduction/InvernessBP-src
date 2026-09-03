local Logic_DataMgrConst = require("client.logic.data.Logic_DataMgrConst")
local Logic_AttributeUpdateCfg = {}
local Enum_Attribute = Logic_DataMgrConst.Enum_Attribute
local _tAttributeUpdateFun = {
  [Enum_Attribute.att_activity_score] = function(nItemId, nCount)
    DataMgr.SetItemStoreData(nItemId, nCount)
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ATTRIBUTE_111_UPDATE, nItemId, nCount)
  end
}
function Logic_AttributeUpdateCfg.GetAttributeHandlerFun(nAttributeType)
  return _tAttributeUpdateFun[nAttributeType]
end
return Logic_AttributeUpdateCfg