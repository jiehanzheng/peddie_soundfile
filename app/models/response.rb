class Response < ActiveRecord::Base
  belongs_to :user
  belongs_to :assignment
  has_many :annotations, :dependent => :destroy

  include AudioFileAttachable


  def revision_number
    Response.where(user: user, assignment: assignment).where('created_at < ?', created_at).count + 1
  end

end
