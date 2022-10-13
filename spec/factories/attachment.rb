FactoryBot.define do
  factory :attachment do
    user

    name { Faker::File.file_name }
    content {  10.times.map { Faker::Name.name }.join(',') }
  end
end
