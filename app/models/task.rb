class Task < ApplicationRecord
  belongs_to :user
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  validates :title, presence: true, length: { maximum: 30 }
  validates :priority, presence: true
  validates :deadline, presence: true
  validates :state, presence: true
  validate :deadline_must_be_in_the_future

  enum :priority, { low: 0, mid: 1, high: 2 }, validate: true
  enum :state, { not_started: 0, in_progress: 1, done: 2 }, validate: true

  scope :recent, -> { order(created_at: :desc) }
  scope :deadline, -> { order(deadline: :asc) }
  scope :high_priority_first, -> { order(priority: :desc) }
  scope :low_priority_first, -> { order(priority: :asc) }
  scope :tag, ->(tag_name) { joins(:tags).where("name = ?", tag_name) }
  scope :matches, ->(keyword) {
                    where("title LIKE ?", "%#{sanitize_sql_like(keyword)}%").or(where("description LIKE ?", "%#{sanitize_sql_like(keyword)}%"))
                  }

  def update_state
    new_state = ''
    case state
    when 'not_started'
      new_state = 'in_progress'
    when 'in_progress'
      new_state = 'done'
    when 'done'
      new_state = 'not_started'
    end
    update(state: new_state)
  end

  def save_tag(tag_list)
    tag_list.each { |tag_name| tags.create(name: tag_name.strip) }
  end

  def update_tag(tag_list)
    current_tags = tags.pluck(:name)
    unless current_tags == tag_list
      tags.destroy_all
      save_tag(tag_list)
    end
  end

  private

  def deadline_must_be_in_the_future
    if deadline.present? && deadline <= Time.current
      errors.add(:deadline, "は現在以降の日時である必要があります")
    end
  end
end
