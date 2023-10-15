class Task < ApplicationRecord
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

  private

  def deadline_must_be_in_the_future
    if deadline.present? && deadline <= Time.current
      errors.add(:deadline, "は現在以降の日時である必要があります")
    end
  end
end
