class Task < Post
  def initialize
    super

    @due_date = Teme.now
  end

  def read_from_console
  end

  def to_strings
  end
end

