require 'yaml'

class Schema
  class << self
    # This is the order in which tables are to be imported. This order
    # makes sure that rows on the receiving end of a foreign key are
    # imported before the rows that refer to them.
    #
    # Purposely omitted:
    #   - schema_migrations (both apps should be running same version)
    #   - questionnaires (we change the questionnaire ids to match before merging)
    def table_import_order
      [
        :highcharts_json_caches,
        :organizations, :protocols, :measurements, :teams, :api_tokens, :auth_tokens, :auth_nonces, :export_versions,
        :report_templates, :reported_questionnaires, :invitation_templates, :text_message_templates,
        :professionals, :dossier_epd_id_changes,
        :patty_patients, :patients, :professionals_patients,
        :email_bounces, :tokens, :measurement_sequences, :non_responses, :protocol_subscriptions,
        :fill_out_requests, :fill_out_tasks, :activities, :invitations, :text_messages, :reports, :measurements_questionnaires,
        :invitations_questionnaires, :quby_answers, :answers, :answers_reports, :answers_fill_out_requests,
        :fill_out_sessions, :fill_out_sessions_questionnaires, :answers_fill_out_sessions, :delayed_jobs
      ]
    end

    # This describes all the integer ID columns that will be incremented for merging.
    def id_columns
      {
        :activities=>[:id, :dossier_id, :actor_id, :subject_id],
        :answers=>[:id, :protocol_id, :measurement_id, :completed_by, :subject_id, :questionnaire_id, :owner_id, :team_id, :fill_out_task_id, :remote_id, :non_response_id, :requester_id], # added completed_by
        :answers_fill_out_requests=>[:answer_id, :fill_out_request_id],
        :answers_fill_out_sessions=>[:id, :answer_id, :fill_out_session_id],
        :answers_reports=>[:id, :answer_id, :report_id],
        :api_tokens=>[:id, :organization_id],
        :auth_nonces=>[:id, :consumer_id],
        :auth_tokens=>[:id, :organization_id],
        :delayed_jobs=>[:id],
        :dossier_epd_id_changes=>[:id, :organization_id, :requester_id],
        :email_bounces=>[:id, :dossier_id],
        :export_versions=>[:id, :organization_id],
        :fill_out_requests=>[:id, :dossier_id, :protocol_subscription_id, :measurement_sequence_id],
        :fill_out_sessions=>[:id, :measurement_id, :current_answer_id, :completer_id, :patient_id, :team_id],
        :fill_out_sessions_questionnaires=>[:id, :fill_out_session_id, :questionnaire_id],
        :fill_out_tasks=>[:id, :patient_id],
        :highcharts_json_caches=>[:id],
        :invitation_templates=>[:id, :organization_id, :protocol_id, :team_id],
        :invitations=>[:id, :user_id, :protocol_id, :team_id, :parent_id, :professional_id, :organization_id],
        :invitations_questionnaires=>[:invitation_id, :questionnaire_id],
        :measurement_sequences=>[:id, :dossier_id],
        :measurements=>[:id, :parent_id, :protocol_id],
        :measurements_questionnaires=>[:measurement_id, :questionnaire_id, :id],
        :non_responses=>[:id],
        :organizations=>[:id, :current_export_version_id],
        :patients=>[:id, :organization_id, :patty_patient_id],
        :patty_patients=>[:id],
        :professionals=>[:id, :organization_id],
        :professionals_patients=>[:patient_id, :professional_id],
        :protocol_subscriptions=>[:id, :patient_id, :protocol_id, :started_by_id, :invitation_template_id, :measurement_sequence_id, :text_message_template_id],
        :protocols=>[:id, :organization_id],
        :quby_answers=>[:id], # removed: :questionnaire_id (pointed to id in Quby when it was a seperate Rails app and questionnaire dsls were stored in the db)
        :questionnaires=>[:id, :bulk_id, :original_id],
        :report_templates=>[:id, :protocol_id, :organization_id],
        :reported_questionnaires=>[:id, :report_template_id, :questionnaire_id],
        :reports=>[:id, :report_template_id, :patient_id],
        # removed: sessions table
        # removed: schema migrations table
        :teams=>[:id, :owner_id, :organization_id],
        :text_message_templates=>[:id, :organization_id, :protocol_id],
        :text_messages=>[:id, :text_message_template_id, :dossier_id],
        :tokens=>[:id, :patient_id]
      }
    end
  end
end
