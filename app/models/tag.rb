class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :tasks, through: :taggings

  def self.build_tag_list(jointed_tag_names)
    jointed_tag_names.split(',')
  end
end
