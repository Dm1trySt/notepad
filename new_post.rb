require_relative 'post.rb'
require_relative 'link.rb'
require_relative 'task.rb'
require_relative 'memo.rb'

puts "Привет, я твой блокнот! Версия 2 + Sqlite"
puts "Что хотите записать в блокнот?"

# Выбор действия (memo,task или link)
choices = Post.post_types.keys

# счетчик
choice = -1

# Цикл выполняется пока пользователь не введет желаемое действие
until choice >=0 && choice <choices.size

  # Вывод всех возможных действий с нумерацией
  # .each_with_index - цикл по всем элементам массива choices
  choices.each_with_index do |type, index|
    puts"\t#{index}. #{type}"
  end

  # Ввод номера от пользователя
  choice =STDIN.gets.chomp.to_i
end

# Создаем новый экземпляр класса
entry = Post.create(choices[choice])

# У созданного экземпляра класса вызываем метод read_from_console
entry.read_from_console

# Сохранение данных в БД
id = entry.save_to_db

puts "Ура, запись сохранена, id = #{id}"