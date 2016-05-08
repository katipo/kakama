class StaffSerializer < ActiveModel::Serializer
  attributes :id,
             :username,
             :username,
             :staff_type,
             :email,
             :full_name,
             :start_date,
             :admin_notes,
             :last_request_at
end
