FactoryBot.define do
  factory :job_application do
    job { nil }
    name { "MyString" }
    email { "MyString" }
    phone { "MyString" }
    resume { "MyText" }
    cover_letter { "MyText" }
    portfolio_url { "MyString" }
    experience_years { 1 }
    motivation { "MyText" }
  end
end
