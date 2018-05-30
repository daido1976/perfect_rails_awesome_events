class Event < ApplicationRecord
  belongs_to :owner, class_name: 'User'

  validates :name, length: { maximum: 50 }, presence: true
  validates :place, length: { maximum: 100 }, presence: true
  validates :content, length: { maximum: 2000 }, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_should_be_after_start_time

  private

  def end_time_should_be_after_start_time
    return unless start_time && end_time

    errors.add(:end_time, 'は開始時間よりも後に設定してください') if end_time <= start_time
  end
end
