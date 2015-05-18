require_relative 'step'

class ImportData < Step
  def perform
    target.transaction do
      Schema.table_import_order.each do |table, sort|
        next if table == :questionnaires

        target_columns = target[table].columns
        select_columns = target_columns.map{|i| "`sourcetable`.`#{i}`" }.join(", ")
        order_columns  = sort.map {|i| "`sourcetable`.`#{i}`" }.join(", ")
        target["INSERT INTO #{target.opts[:database]}.#{table} " +
               "SELECT #{select_columns} FROM #{source.opts[:database]}.#{table} AS sourcetable " +
               "ORDER BY #{order_columns};"].insert
      end
    end
  end
end
