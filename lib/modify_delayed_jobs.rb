require_relative 'step'
require 'yaml'

FillOutRequestCallbackJob = Struct.new(:fill_out_request_id, :event)
NotificationSendJob = Struct.new(:protocol_subscription_id, :pending_answer_ids, :notifier, :event)
WebhookJob = Struct.new(:type, :organization_id, :event, :object)

class ModifyDelayedJobs < Step
  def perform(options = {})
    increment = options.fetch(:increment)

    source[:delayed_jobs].each do |row|
      case row[:handler]
      when /ruby\/struct:A19Job/
        delete(row)
      when /ruby\/object:OruJob/
        delete(row)
      when /ruby\/struct:FillOutRequestCallbackJob/
        handler = YAML.load(row[:handler])
        handler.fill_out_request_id = handler.fill_out_request_id + increment
        update(row, handler)
      when /ruby\/struct:NotificationSendJob/
        handler = YAML.load(row[:handler])
        handler.protocol_subscription_id = handler.protocol_subscription_id + increment
        handler.pending_answer_ids = handler.pending_answer_ids.map{ |id| id + increment }
        update(row, handler)
      when /ruby\/object:CleanupActiveRecordSessions/
        delete(row)
      when /ruby\/object:CleanupExpiredAnswers/
        delete(row)
      when /ruby\/object:CleanupExpiredAuthNonces/
        delete(row)
      when /ruby\/object:CleanupExpiredExportVersions/
        delete(row)
      when /ruby\/object:CleanupExpiredFillOutSessions/
        delete(row)
      when /ruby\/object:CleanupExpiredHighchartsJsonCaches/
        delete(row)
      when /ruby\/object:CleanupExpiredPatientDetails/
        delete(row)
      when /ruby\/object:CleanupMissedAnswerCallbacks/
        delete(row)
      when /ruby\/object:JanitorUnsentOrus/
        delete(row)
      # when /ruby\/object:PrepareProtocolSubscriptions/
      #   delete(row)
      when /ruby\/object:RetrieveEmailBounces/
        delete(row)
      when /ruby\/object:StatisticsReporting/
        delete(row)
      when /ruby\/object:UpdateSqlExports/
        delete(row)
      else
        raise "unknown type of job: #{row}"
      end
    end
  end

  def update(row, handler)
    source[:delayed_jobs].where(id: row[:id]).update(handler: YAML.dump(handler))
  end

  def delete(row)
    source[:delayed_jobs].where(id: row[:id]).delete
  end
end
