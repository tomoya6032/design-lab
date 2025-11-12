FactoryBot.define do
  factory :contact do
    name { "MyString" }
    email { "MyString" }
    subject { "MyString" }
    message { "MyText" }
    ip_address { "MyString" }
    user_agent { "MyText" }
    status { 1 }
  end
end
