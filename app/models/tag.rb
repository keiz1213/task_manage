class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :tasks, through: :taggings

  scope :user_tags, ->(user) { joins(taggings: { task: :user }).where(users: { id: user.id }) }

  def self.build_tag_list(jointed_tag_names)
    jointed_tag_names.split(',').map(&:strip).uniq
  end
end
