require_relative 'step'

class IncrementIdColumns < Step
  def perform(increment)
    check_target_lower_than_increment(increment)

    source.run "SET foreign_key_checks = 0;"
    increment_id_columns(increment)
    match_questionnaire_ids
    source.run "SET foreign_key_checks = 1;"
  end

  def check_target_lower_than_increment(increment)
    Schema.id_columns.each do |table, columns|
      columns.each do |column|
        if target[table].where("#{column} >= ?", increment).count != 0
          raise "Target #{table}.#{column} has rows with IDs above the increment."
        end
      end
    end
  end

  def increment_id_columns(increment)
    Schema.id_columns.each do |table, columns|
      next if columns.empty?

      updates = columns.map {|i| [i, Sequel.qualify(table, i) + increment] }.to_h
      source[table].update(updates)
    end
  end

  def match_questionnaire_ids
    source[:questionnaires].each do |quest|
      source_id = quest[:id]
      target_id = target[:questionnaires].where(key: quest[:key]).first[:id]

      source[:questionnaires].where(id: source_id).update(id: target_id)
      source[:questionnaires].where(bulk_id: source_id).update(bulk_id: target_id)
      source[:questionnaires].where(original_id: source_id).update(original_id: target_id)

      source[:answers].where(questionnaire_id: source_id).update(questionnaire_id: target_id)
      source[:reported_questionnaires].where(questionnaire_id: source_id).update(questionnaire_id: target_id)
      source[:measurements_questionnaires].where(questionnaire_id: source_id).update(questionnaire_id: target_id)
      source[:invitations_questionnaires].where(questionnaire_id: source_id).update(questionnaire_id: target_id)
      source[:fill_out_sessions_questionnaires].where(questionnaire_id: source_id).update(questionnaire_id: target_id)
    end
  end
end
