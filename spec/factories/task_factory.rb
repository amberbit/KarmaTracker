FactoryGirl.define do
  factory :task do
    project { Project.last || FactoryGirl.create(:project) }
  end
end
