module BlogEntriesHelper
  def entry_html(entry)
    #TODO: could be done better, like stripping multiple br tags etc...
    # we have editor now, we dont need this: entry.gsub(/\n/, '<br>').html_safe if entry
    entry.html_safe
  end
end
