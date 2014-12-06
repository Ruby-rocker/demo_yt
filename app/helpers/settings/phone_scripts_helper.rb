module Settings::PhoneScriptsHelper

  def print_phone_line(friendly_name)
    friendly_name.sub(')','-').sub('(','+1 ')
  end

  def highlight_number(number, area_code, keyword)
    content = ''
    if area_code.present?
      content += "<u>#{number[0..2]}</u>"
      number = number[3..-1]
    end
    if keyword.present?
      content += number.gsub(/(?<i>#{keyword})/, '<u>\k<i></u>')
    else
      content += number
    end
    content.html_safe
  end

end
