require 'pp'

class VerifySchema
  def self.run!(db)
    new.verify(db)
  end

  def calculate_schema(db)
    db.tables.map do |table|
      [table, db.schema(table)]
    end.to_h
  end

  # Verifies the database schema against the known working schema. This
  # is defense against schema modifications without having updated this
  # merging script.
  def verify(db)
    known_good_schema = File.read(File.expand_path(File.join(__FILE__, "../../config/known_good_schema.yml")))
    known_good_schema = YAML.load(known_good_schema)
    schema = calculate_schema(db)

    db.tables.each do |table|
      # Sorting by column name because we allow column order to be different.
      # (SELECT statement solves this ordering by querying in destination order).
      if schema[table].map(&:first).sort != known_good_schema[table].map(&:first).sort
        puts "Table #{table} has a different schema"
        puts "Want: #{known_good_schema[table].sort_by(&:first).inspect}"
        puts "Have: #{schema[table].sort_by(&:first).inspect}"
        raise "InvalidSchema"
      end
    end

    true
  end

end
