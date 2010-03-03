module SoftDelete

  def self.included(klass)
    # Add a basic default_scope to the class. Find only non-deleted object by default
    klass.send(:default_scope, :conditions => { :deleted_at => nil })
    klass.extend(ClassMethods)
  end

  module ClassMethods
    # Make with_exclusive_scope publically available, so we can call
    # Model.with_exclusive_scope { ... } to clear default scopes
    def with_exclusive_scope
      super
    end
  end

  # Taken from is_paranoid gem. Calls 'before_destroy' call back,
  # marks the instance as destroyed, and calls 'after_destroy'
  def destroy(with_callbacks = true)
    return false if with_callbacks && callback(:before_destroy) == false
    update_attribute(:deleted_at, Time.now)
    callback(:after_destroy) if with_callbacks
    self
  end

  def restore
    update_attribute(:deleted_at, nil)
  end

end
