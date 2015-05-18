require_relative 'step'

class ManageExportVersions < Step
  def remember_and_clear
    @organizations = source[:organizations].select(:id, :current_export_version_id).all
    source[:organizations].update(current_export_version_id: nil)
  end

  def restore
    @organizations.each do |organization|
      target[:organizations].where(id: organization.fetch(:id)).update(current_export_version_id: organization.fetch(:current_export_version_id))
    end
  end
end
