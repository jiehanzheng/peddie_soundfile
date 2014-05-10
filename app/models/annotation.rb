class Annotation < ActiveRecord::Base
  belongs_to :response
  validates :start_second, numericality: true
  validates :end_second, numericality: true

  include AudioFileAttachable

end
