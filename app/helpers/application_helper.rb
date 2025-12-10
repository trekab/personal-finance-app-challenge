module ApplicationHelper
  def nav_item(path)
    is_active = current_page?(path)

    base = "relative flex flex-col items-center gap-1 px-3 pt-2 pb-4 rounded-t flex-1 mx-2"
    active = "bg-white text-gray-900"
    inactive = "text-gray-300 hover:bg-gray-800"

    "#{base} #{is_active ? active : inactive}"
  end
end
