ActiveAdmin.register_page "Dashboard" do
  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    section "", :priority => 2 do
      h2 "Select Tenant"
      div do
        render "admin/dashboard/search_tenant"
      end
    end
  end # content

  controller do
    skip_before_filter :decide_redirection
  end
end
