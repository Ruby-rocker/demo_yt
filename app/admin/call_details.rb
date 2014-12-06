ActiveAdmin.register CallDetail do
  actions :all, :except => [:destroy,:new, :edit, :create, :update]

  index do
    column :call_to
    column :call_from
    column :duration do |p|
      seconds_to_time(p.duration)
    end
    column :direction
    column :start_time
    column :end_time
    default_actions
  end

  show do
    attributes_table do
      row :id
      row :call_sid
      row :call_to
      row :call_from
      row("Duration") { |p| seconds_to_time(p.duration) }
      row :start_time
      row :end_time
      row :call_to
      row :call_from
      row :direction
      row :from_city
      row :from_country
      row :from_state
      row :from_zip
      row :to_city
      row :to_country
      row :to_state
      row :to_zip
    end
  end

end

