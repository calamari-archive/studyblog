module BlogEntriesHelper
  def entry_html(entry)
    #TODO: could be done better, like stripping multiple br tags etc...
    entry.html_safe
  end

  def comment_html(entry)
    entry.gsub(/\n/, '<br>').html_safe if entry
  end
end
