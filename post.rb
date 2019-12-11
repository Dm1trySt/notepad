require 'sqlite3'

class Post

  # @@имя_переменной - переменная класса
  # имя файла где хранится БД
  @@SQLITE_DB_FILE = 'notepad.sqlite'

  # Массив всех возможных классов
  # def self. - объявление статического метода
  def self.post_types
    {'Memo' => Memo,'Task' => Task,'Link' => Link}
  end

  # Создает экземпляр класса (type)
  def self.create(type)
    return post_types[type].new
  end

  # Вывод конкретной записи
  def self.find_by_id(id)

    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    db.results_as_hash = true

    # .execute - вместо знака (?) подстваляет значения переменных
    begin
      result = db.execute("SELECT * FROM posts WHERE rowid = ?", id)

    # Если появится ошибка SQLite3::SQLException
    rescue SQLite3::SQLException => e

    # Выведет следующие сообщения:
    puts "Не удалось выполнить запрос в базе #{@@SQLITE_DB_FILE}"

    # abort - завершит программу и выведет сообщение e(что вызвало ошибку)
    abort e.message
  end

    db.close

    # Результат пустой ?
    # .empty? - вернет true, если нет элементов
    return nil if result.empty?

    result = result[0]

    post = create(result['type'])

    post.load_data(result)

    return post

  end

  # Вывод всей таблицы записей
  def self.find_all (limit, type)

    db = SQLite3::Database.open(@@SQLITE_DB_FILE)
    db.results_as_hash = false # настройка соединения к базе, он результаты из базы НЕ преобразует в Руби хэши

    # Формируем запрос в базу с нужными условиями:
    # на первом месте идет rowid и только после любой другой блок (обозначен *)

    query = "SELECT rowid, * FROM posts "

    # Если задан тип, надо добавить условие
    # :type - тоже плейсхолдер
    query += "WHERE type = :type " unless type.nil?

    # ORDER by поле ASC(DESC) сортировка по убыванию
    query += "ORDER by rowid DESC "

    # Если лимит не 0 вернет указанное кол-во записей
    query += "LIMIT :limit " unless limit.nil? # если задан лимит, надо добавить условие

    begin
    # .prepare - защищает от SQL инъекций (от изменений в SQL запросе)
    statement = db.prepare query

      # Если появится ошибка SQLite3::SQLException
    rescue SQLite3::SQLException => e

      # Выведет следующие сообщения:
      puts "Не удалось выполнить запрос в базе #{@@SQLITE_DB_FILE}"

      # abort - завершит программу и выведет сообщение e(что вызвало ошибку)
      abort e.message
    end

    # .bind_param - привязывает введенные даные только к "заполнителям" не внося реальных правок в SQL запрос
    # что опять же защищает от SQL инъекций
    statement.bind_param('type', type) unless type.nil? # загружаем в запрос тип вместо плейсхолдера, добавляем лук :)
    statement.bind_param('limit', limit) unless limit.nil? # загружаем лимит вместо плейсхолдера, добавляем морковь :)

    begin
    # .execute! - выполняет stateman
    result = statement.execute!

      # Если появится ошибка SQLite3::SQLException
    rescue SQLite3::SQLException => e

      # Выведет следующие сообщения:
      puts "Не удалось выполнить запрос в базе #{@@SQLITE_DB_FILE}"

      # abort - завершит программу и выведет сообщение e(что вызвало ошибку)
      abort e.message
    end

    # Закрываем statement
    statement.close

    # закрываем БД
    db.close
    return result

  end


  def initialize
    @created_at = Time.now
    @text = nil
  end

  # Абстрактный класс
  def read_from_console
  end

  def to_srings
    #todo
  end

  # Сохранение записи
  def save
    file = File.new(file_path, "w:UTF-8")

    for item in to_strings do
      file.puts(item)
    end

    file.close
  end

  # Путь и имя файла
  def file_path
    current_path = File.dirname(__FILE__ )

    file_name = @created_at.strftime("#{self.class.name}_%Y-%m-%d_%H-%M-%S.txt")

    return current_path +"/" + file_name
  end

  # Сохранение записи в БД
  def save_to_db

    # Проверка существования БД
    # if !File.exist?(@@SQLITE_DB_FILE)
    # abort "Не удалось выполнить запрос в базе #{@@SQLITE_DB_FILE}\n\nno such table: posts"
    # end

    # Открываем БД
    db = SQLite3::Database.open(@@SQLITE_DB_FILE )

    # Возвращает массив в иде хэш массива
    db.results_as_hash = true

    begin
    # # .execute - вместо знака (?) подстваляет значения переменных
    # .join(параметр) - объеденяет эллементы разделяя их параметром
    # .keys - вывод ключей
    db.execute(
      "INSERT INTO posts (" +
        to_db_hash.keys.join(', ') + # все поля, перечисленные через запятую
        ") " +
        " VALUES ( " +
          # Плейсхолдеры - знак вопроса (?)
          # Их должно быть столько же сколько и кол-во ключей
          # поэтому умножаем кол-во ? на кол-во ключей
          # Плейсхолдеры обязательно должны быть разделены знаком( ,)
          #  .chomp(',') - не записывает последнюю запятую
        ('?,'*to_db_hash.keys.size).chomp(',') +

        ")",
      to_db_hash.values # массив значений хэша, которые будут вставлены в запрос вместо _плейсхолдеров_
    )

      # Если появится ошибка SQLite3::SQLException
    rescue SQLite3::SQLException => e

      # Выведет следующие сообщения:
      puts "Не удалось выполнить запрос в базе #{@@SQLITE_DB_FILE}"

      # abort - завершит программу и выведет сообщение e(что вызвало ошибку )
      abort e.message
    end

      # .last_insert_row_id - возвращает идентификатор новой строки
      insert_row_id = db.last_insert_row_id

    # Закрываем БД
    db.close

    return insert_row_id
  end

  # Запись данных в хэш массив
  def to_db_hash

    # super - наследуем переменные метода у родительского класса
    # .merge - объединяет 2 хэш массива в 1 (в нашем случае хэш массив родительский и дочерний)
    {
      'type' => self.class.name,
      'created_at' => @created_at.to_s
    }
  end

  # получает на выход хэш массив данных и должен заполнить свои поля
  def load_data(data_hash)
    @created_at = Time.parse(data_hash['created_at'])
  end
end
