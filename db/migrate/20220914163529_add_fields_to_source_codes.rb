class AddFieldsToSourceCodes < ActiveRecord::Migration[7.0]
  def change
    add_column :source_codes, :ads, :text, array: true
    add_column :source_codes, :links, :text, array: true
  end
end
