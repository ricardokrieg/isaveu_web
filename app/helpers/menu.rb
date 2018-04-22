module MenuHelper
  class << self
    def menu(items, current_url)
      content = ''

      items.each do |item|
        content << menu_item(item[:label], item[:url], current_url)
      end

      content
    end

    def menu_item(label, url, current_url)
      is_current_url = url == current_url

      li_class = 'nav-item'
      li_class += ' active' if is_current_url

      link_content = label
      link_content = "<span class='sr-only'>(atual)</span>#{link_content}" if is_current_url

      content = "<li class='#{li_class}'>"
      content += "<a class='nav-link' href='#{url}'>#{link_content}</a>"
      content += "</li>"

      content
    end
  end
end
