class Annotation < ActiveRecord::Base
  belongs_to :response
  
  include AudioFileAttachable

end
