class Response < ActiveRecord::Base
  belongs_to :user
  belongs_to :assignment
  has_many :annotations, :dependent => :destroy

  include AudioFileAttachable

end
