# frozen_string_literal: true

class AddNameToAttachments < ActiveRecord::Migration[7.0]
  def change
    add_column :attachments, :name, :string
  end
end
