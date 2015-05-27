require_relative 'step'

class CopyAnswerIdToAnswerExportId < Step
  def perform
    SOURCE[:answers].where(export_id: nil).update(export_id: :id)
  end
end
