class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :tasks, through: :taggings

  def self.build_tag_list(tag_param)
    tag_param.split(',')
  end
end
