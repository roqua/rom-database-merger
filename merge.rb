require 'rubygems'
require 'bundler/setup'

require_relative 'config/database'
require_relative 'config/schema'
require_relative 'lib/copy_database'
require_relative 'lib/verify_schema'
require_relative 'lib/increment_id_columns'
require_relative 'lib/import_data'
require_relative 'lib/modify_delayed_jobs'
require_relative 'lib/manage_export_versions'
require_relative 'lib/copy_answer_id_to_answer_export_id'

SOURCE = CopyDatabase.copy(Config[:source], "#{Config[:source]}_temp")

if Config[:actually_merge]
  TARGET = DB.connect(Config[:target])
else
  TARGET = CopyDatabase.copy(Config[:target], "#{Config[:target]}_temp")
end

VerifySchema.run!(SOURCE)
VerifySchema.run!(TARGET)

CopyAnswerIdToAnswerExportId.new(SOURCE, TARGET).perform
IncrementIdColumns.new(SOURCE, TARGET).perform(increment: Config[:increment])
ModifyDelayedJobs.new(SOURCE, TARGET).perform(increment: Config[:increment])

export_version_manager = ManageExportVersions.new(SOURCE, TARGET)
export_version_manager.remember_and_clear
ImportData.new(SOURCE, TARGET).perform
export_version_manager.restore
