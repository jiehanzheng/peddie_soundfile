class Assignment < ActiveRecord::Base
  belongs_to :course
  has_many :responses

  validates :name, presence: true


  scope :most_recent_first, -> { order('updated_at DESC') }

end
