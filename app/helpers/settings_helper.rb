module SettingsHelper
  def setting_value_for(key)
    v = Setting.send(key)
    v.is_a?(Array) ? v.inspect : v
  end

  def setting_description_for(key)
    Setting::Data[key.to_sym][:description] rescue ''
  end
end
