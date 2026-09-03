local NetManager = require("client.network.comm.NetManager")
local DataMigrationHandler = {}
function DataMigrationHandler.send_start_migrate_req()
  NetManager.SendPkg(1525328003)
end
function DataMigrationHandler.on_start_migrate_rsp(res, state)
  local DataMigrationSystem = require("client.slua.logic.data_migration.data_migration_logic")
  DataMigrationSystem.DataMigrationResponse(res, state)
end
function DataMigrationHandler.send_get_migrate_status_req()
  NetManager.SendPkg(378471207)
end
function DataMigrationHandler.on_get_migrate_status_rsp(res, state)
  local DataMigrationSystem = require("client.slua.logic.data_migration.data_migration_logic")
  DataMigrationSystem.DataMigrationStateResponse(res, state)
end
function DataMigrationHandler.send_set_migrate_status_req(state, choice)
  NetManager.SendPkg(917819815, state, choice)
end
function DataMigrationHandler.on_set_migrate_status_rsp(res, state, choice)
  local DataMigrationSystem = require("client.slua.logic.data_migration.data_migration_logic")
  DataMigrationSystem.ReportChoiceResponse(res, state, choice)
end
return DataMigrationHandler