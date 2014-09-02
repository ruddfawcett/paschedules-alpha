module ApplicationHelper
  def bs_class_for(name)
    {danger: "alert-danger", warning: "alert-warning", success: "alert-success", notice: "alert-success"}[name.to_sym] || "alert-danger"
  end
end
