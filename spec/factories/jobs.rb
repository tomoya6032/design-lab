FactoryBot.define do
  factory :job do
    title { "MyString" }
    job_type { "MyString" }
    description { "MyText" }
    capacity { "MyString" }
    salary_range { "MyString" }
    expectations { "MyText" }
    senior_message { "MyText" }
    published { false }
    display_order { 1 }
  end
end
