class Image < ActiveRecord::Base
  belongs_to :blog_entry
  belongs_to :user

  has_attached_file :image,
                    :styles => { :original => '350x350>'},
                    :hash_secret => 'Ims0s3cret!',
                    :url    => '/' + StudyBlog::Application.config.app_config['blogs']['image']['dir'] + '/:hash.:extension',
                    :path   => ":rails_root/public/" + StudyBlog::Application.config.app_config['blogs']['image']['dir'] + "/:hash.:extension"

  validates_attachment_size :image, :less_than => 200.kilobytes
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/gif', 'image/png'] #StudyBlog::Application.config.app_config['users']['image']['dir'].split
  attr_protected :image_content_type, :image_size
  attr_accessor :image_file_name

  validates_presence_of :user
end
