class Task < ApplicationRecord
  validates :title, presence: true, length: { maximum: 30 }
  validates :priority, presence: true, inclusion: { in: 0..2 }
  validates :deadline, presence: true
  validates :state, presence: true, inclusion: { in: 0..2 }
  validate :deadline_must_be_in_the_future

  enum :priority, { low: 0, mid: 1, high: 2 }
  enum :state, { not_started: 0, in_progress: 1, done: 2 }

  private

  def deadline_must_be_in_the_future
    if deadline.present? && deadline <= Time.current
      errors.add(:deadline, "は現在以降の日時である必要があります")
    end
  end
end
