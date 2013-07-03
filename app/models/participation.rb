# == Schema Information
#
# Table name: participations
#
#  id          :integer          not null, primary key
#  identity_id :integer          not null
#  project_id  :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Participation < ActiveRecord::Base
  belongs_to :identity
  belongs_to :project
end
