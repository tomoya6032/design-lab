FactoryBot.define do
  factory :media_usage do
    medium { nil }
    mediable { nil }
    usage_type { "MyString" }
    context { "MyString" }
  end
end
