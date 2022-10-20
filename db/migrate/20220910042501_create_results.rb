# frozen_string_literal: true

class CreateResults < ActiveRecord::Migration[7.0]
  def change
    create_table :results do |t|
      t.integer :total_ads
      t.integer :total_links
      t.string :keyword
      t.string :total_results
      t.integer :status, default: 1, null: false
      t.references :attachment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
