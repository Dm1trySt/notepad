class Link < Post
  def initialize
    super

    @url = ''
  end

  # Ввод ссылки
  def read_from_console
    puts"Адрес ссылки:"
    @url = STDIN.gets.chomp

    puts"Что за ссылка?"
    @text=STDIN.gets.chomp
  end

  # Возвращает содержимое в виде даты + само содержимое
  def to_strings
    time_string = "Создано: #{@created_at.strftime("%Y.%m.%d_%H:%M:%S.txt")}  \n\r \n\r"

    return [@url, @text, time_string]
  end

  # Запись данных в хэш массив
  def to_db_hash

    # super - наследуем переменные метода у родительского класса
    # .merge - объединяет 2 хэш массива в 1 (в нашем случае хэш массив родительский и дочерний)
    return super.merge (
                         {
                           'text' => @text,
                           'url' => @url
                         }
                       )
  end
  def load_data(data_hash)
    super(data_hash) #сперва дергаем родительский метод для инициализации общих полей

    #теперь прописываем свое специфичное поле
    @url = data_hash['url']
  end
end
