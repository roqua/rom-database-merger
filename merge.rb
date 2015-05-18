require 'rubygems'
require 'bundler/setup'

require_relative 'config/database'
require_relative 'config/schema'
require_relative 'lib/copy_database'
require_relative 'lib/verify_schema'
require_relative 'lib/increment_id_columns'
require_relative 'lib/import_data'
require_relative 'lib/modify_delayed_jobs'

SOURCE_COPY = CopyDatabase.copy(Config[:source], "#{Config[:source]}_temp")
TARGET_COPY = CopyDatabase.copy(Config[:target], "#{Config[:target]}_temp")

VerifySchema.run!(SOURCE_COPY)
VerifySchema.run!(TARGET_COPY)

IncrementIdColumns.new(SOURCE_COPY, TARGET_COPY).perform(increment: 1_000_000)
ModifyDelayedJobs.new(SOURCE_COPY, TARGET_COPY).perform(increment: 1_000_000)
ImportData.new(SOURCE_COPY, TARGET_COPY).perform
