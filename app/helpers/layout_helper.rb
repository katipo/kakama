module LayoutHelper

  def page_title(prefix = '')
    title = ''
    title += "#{h(prefix)} - " unless prefix.blank?
    title += Setting.site_name
    title
  end

  def display_flash_contents
    flash.inject('') do |html, (name, msg)|
      content_tag(:div, msg, :class => "flash_#{name}")
    end
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def required_astrix
    "<abbr title='required'>*</abbr>".html_safe
  end

  def powered_by
    if !Setting.company_name.blank? && !Setting.company_url.blank?
      link_to Setting.company_name, Setting.company_url
    elsif !Setting.company_url.blank? && Setting.company_name.blank?
      link_to Setting.company_url, Setting.company_url
    elsif !Setting.company_name.blank? && Setting.company_url.blank?
      Setting.company_name
    else
      ''
    end
  end

end
