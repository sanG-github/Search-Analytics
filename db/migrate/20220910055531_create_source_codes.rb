# frozen_string_literal: true

class CreateSourceCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :source_codes do |t|
      t.text :content
      t.references :result, null: false, foreign_key: true

      t.timestamps
    end
  end
end
