require 'spec_helper'
require 'sequel'
require_relative '../lib/manage_export_versions'

describe ManageExportVersions do
  let(:db) { Sequel.sqlite }
  subject  { described_class.new(db, db) }

  before do
    db.create_table :organizations do
      primary_key :id
      integer :current_export_version_id
    end
  end

  it 'clears and restores the ids' do
    db[:organizations].insert(id: 1, current_export_version_id: 123)
    db[:organizations].insert(id: 2, current_export_version_id: 100)

    subject.remember_and_clear
    expect(db[:organizations].all).to eq([
      {id: 1, current_export_version_id: nil},
      {id: 2, current_export_version_id: nil}
    ])

    subject.restore
    expect(db[:organizations].all).to eq([
      {id: 1, current_export_version_id: 123},
      {id: 2, current_export_version_id: 100}
    ])
  end
end

