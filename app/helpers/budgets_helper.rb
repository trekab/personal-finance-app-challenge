module BudgetsHelper
  def theme_border_class(theme)
    case theme&.downcase
    when "green" then "border-teal-600"
    when "yellow" then "border-yellow-400"
    when "cyan" then "border-cyan-400"
    when "navy" then "border-slate-300"
    when "red" then "border-red-500"
    when "purple" then "border-purple-600"
    when "turquoise" then "border-teal-500"
    else "border-gray-500"
    end
  end

  def theme_text_class(theme)
    case theme&.downcase
    when "green" then "text-teal-600"
    when "yellow" then "text-yellow-600"
    when "cyan" then "text-cyan-600"
    when "navy" then "text-slate-600"
    when "red" then "text-red-600"
    when "purple" then "text-purple-600"
    when "turquoise" then "text-teal-600"
    else "text-gray-600"
    end
  end

  def theme_bg_class(theme)
    case theme&.downcase
    when "green" then "bg-teal-600"
    when "yellow" then "bg-yellow-400"
    when "cyan" then "bg-cyan-400"
    when "navy" then "bg-slate-300"
    when "red" then "bg-red-500"
    when "purple" then "bg-purple-600"
    when "turquoise" then "bg-teal-500"
    else "bg-gray-500"
    end
  end

  def theme_fill_class(theme)
    case theme&.downcase
    when "green" then "fill-teal-600"
    when "yellow" then "fill-yellow-400"
    when "cyan" then "fill-cyan-400"
    when "navy" then "fill-slate-300"
    when "red" then "fill-red-500"
    when "purple" then "fill-purple-600"
    when "turquoise" then "fill-teal-500"
    else "fill-gray-500"
    end
  end
end
