class AddKeywordIndexToResults < ActiveRecord::Migration[7.0]
  def change
    add_index :results, :keyword
  end
end
