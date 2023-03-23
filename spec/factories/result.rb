# frozen_string_literal: true

FactoryBot.define do
  factory :result do
    attachment

    total_ads { FFaker::Number.number(digits: 2) }
    total_links { FFaker::Number.number(digits: 2) }
    total_results { FFaker::Number.number(digits: 2) }
    status { Result.statuses.keys.sample }
    keyword { FFaker::Name.name }
  end
end
