module UsersHelper
  IMAGE_SIZES = {
    :small => '22x30',
    :medium => '45x60',
    :original => '120x160'
  }

  def display_name(user)
    return user.name if user == current_user
    if permitted_to? :show, user
      link_to user.name, user_path(user)
    else
      user.name
    end
  end

  def display_user(user, options = {})
    image_url, image_size = image_data(user, options[:size])
    render 'users/display_user',
      :user => user,
      :image_url => image_url,
      :alt => t('users.image_alt_text', :name => user.name),
      :text => options[:text] || '',
      :width => image_size[0],
      :height => image_size[1]
  end

  def display_user_image(user, options = {})
    image_url, image_size = image_data(user, options[:size])
    image_tag image_url, :alt => t('users.image_alt_text', :name => user.name), :class => options[:class]
  end

private

  def image_data(user, size = :original)
    size = size || :original
    image_size = IMAGE_SIZES[size].split('x')
    image_url = user.has_image? ? user.image.url(size) : asset_path("dummy-profile_#{size}.png")
    return image_url, image_size
  end
end
