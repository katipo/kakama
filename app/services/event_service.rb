class EventService
  def self.get_strong_attributes(params)
    params.require(:event).permit(
      *(Event.strong_attributes + numeric_role_keys(params)))
  end

  private

  def self.numeric_role_keys(params)
    role_keys = params.require(:event).fetch(:roles, {}).keys

    [{
      roles: role_keys.select { |key| key =~ /^[0-9]+$/ }
    }]
  end

end