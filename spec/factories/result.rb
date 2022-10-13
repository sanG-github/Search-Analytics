FactoryBot.define do
  factory :result do
    attachment

    total_ads { Faker::Number.number(digits: 2) }
    total_links { Faker::Number.number(digits: 2) }
    total_results { Faker::Number.number(digits: 2) }
    status { Result.statuses.keys.sample }
    keyword { Faker::Name.name }
  end
end
