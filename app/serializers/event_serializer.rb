class EventSerializer < ActiveModel::Serializer
  attributes :id,
             :venue_id,
             :recurring,
             :schedule_id,
             :name,
             :description,
             :start_datetime,
             :end_datetime,
             :organiser_id,
             :state,
             :created_at,
             :updated_at
end
