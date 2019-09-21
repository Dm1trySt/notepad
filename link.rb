class Link < Post
  def initialize
    super

    @url = ''
  end

  def read_from_console
    puts"Адрес ссылки:"
    @url = STDIN.gets.chomp

    puts"ЧТо за ссылка?"
    @text=STDIN.gets.chomp
  end

  def to_strings
    time_string = "Создано: #{@created_at.strftime("%Y.%m.%d_%H:%M:%S.txt")}  \n\r \n\r"

    return [@url, @text, time_string]
  end
end
