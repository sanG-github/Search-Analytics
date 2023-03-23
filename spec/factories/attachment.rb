# frozen_string_literal: true

FactoryBot.define do
  factory :attachment do
    user

    name { FFaker::Filesystem.file_name }
    content { 10.times.map { FFaker::Name.name }.join(',') }
  end
end
