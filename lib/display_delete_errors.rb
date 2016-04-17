module DisplayDeleteErrors
  def do_destroy
    destroy_find_record
    self.successful = @record.destroy

    if @record.errors.count > 0
      flash[:warning] = (@record.errors.messages[:base] || []).join(' ')
      self.successful = false
    end
  end
end