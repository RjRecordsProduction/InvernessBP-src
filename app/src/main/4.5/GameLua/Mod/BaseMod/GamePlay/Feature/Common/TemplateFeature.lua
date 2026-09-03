local TemplateFeature = {}
function TemplateFeature:ctor()
end
function TemplateFeature:GetLifetimeReplicatedProps()
  local BaseRepTable = TemplateFeature.__super.GetLifetimeReplicatedProps and TemplateFeature.__super.GetLifetimeReplicatedProps(self) or {}
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "TemplateValue",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    }
  }
  table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  return RepTable
end
function TemplateFeature:ReceiveBeginPlay()
  TemplateFeature.__super.ReceiveBeginPlay(self)
end
function TemplateFeature:ReceiveEndPlay(Reason)
  TemplateFeature.__super.ReceiveEndPlay(self, Reason)
end
return TemplateFeature