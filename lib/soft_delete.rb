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

  # Taken from paranoia gem, 
  def destroy(with_callbacks = true)
    if with_callbacks
      return false unless run_callbacks(:destroy) { touch_soft_delete_column }
    else
      touch_soft_delete_column
    end

    freeze
  end
  
  def touch_soft_delete_column
    update_attribute(:deleted_at, Time.now)
  end

  # Duplicate of Rails default destroy method, but with ! to imply
  # it won't be soft-deleted
  def destroy!
    unless new_record?
      connection.delete(
        "DELETE FROM #{self.class.quoted_table_name} " +
        "WHERE #{connection.quote_column_name(self.class.primary_key)} = #{quoted_id}",
        "#{self.class.name} Destroy"
      )
    end

    freeze
  end

  def restore
    update_attribute(:deleted_at, nil)
  end

end
