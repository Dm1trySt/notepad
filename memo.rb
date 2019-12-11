# encoding: utf-8
class Memo < Post

  # Запись заметки
  def read_from_console
    puts"Новая заметка (все, что вы пишите до строчки \"end\"):"

    @text =[]
    line = nil

    # Записывать пока пользователь не введет end
    while line != "end" do
      line = STDIN.gets.chomp
      @text << line
    end

    # .pop - удаление последнего элемента из массива
    @text.pop
  end

  # Возвращает содержимое в виде даты + само содержимое
  def to_strings

    # .strftime - преобразование в строку
    time_string = "Создано: #{@created_at.strftime("%Y.%m.%d_%H:%M:%S.txt")}  \n\r \n\r"

    # .unshift - добавляет строку (time_string) в начало массива
    return @text.unshift(time_string)
  end

  # Запись данных в хэш массив
  def to_db_hash

    # super - наследуем переменные метода у родительского класса
    # .merge - объединяет 2 хэш массива в 1 (в нашем случае хэш массив родительский и дочерний)
    return super.merge (
                         {
                             # .join(разделитель) - разделяет эллементы массива резделителем
                           'text' => @text.join('\n\r')
                         }
                       )
  end
  def load_data(data_hash)
    super(data_hash) #сперва дергаем родительский метод для инициализации общих полей

    #теперь прописываем свое специфичное поле
    @text = data_hash['text'].encode('UTF-8', :invalid => :replace).split('\n\r')
  end

end

