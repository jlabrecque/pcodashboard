module ApplicationHelper


  def status_tag(boolean, options={})
    options[:true_text]  ||= ''
    options[:false_text]  ||= ''


    if boolean
      content_tag(:span, options[:true_text], :class => 'status true')
    else
      content_tag(:span, options[:false_text], :class => 'status false')
    end
  end

  def ccolor_status(attend, options={})
      options[:filltext]  ||= '______'
      if attend == "V"
        content_tag(:span, options[:filltext], :class => 'checkin_grid_dates volunteer')
      elsif attend == "R"
        content_tag(:span, options[:filltext], :class => 'checkin_grid_dates regular')
      else
        content_tag(:span, options[:filltext], :class => 'checkin_grid_dates false')
      end

  end
  def dcolor_status(amount, options={})
      options[:filltext]  ||= '______'
      if amount > 0.0 #ie some donation
        content_tag(:span, options[:filltext], :class => 'donation_grid_dates true')
      else
        content_tag(:span, options[:filltext], :class => 'donation_grid_dates false')
      end

  end

end
