require_relative 'post.rb'
require_relative 'memo.rb'
require_relative 'link.rb'
require_relative 'task.rb'

#id, limit, type

require 'optparse'


#Все наши опции будут записаны сюда
options = {}

# Вывод информации по ключу -h
OptionParser.new do |opt|
  opt.banner = 'Usage: read.rb [options]'

  opt.on('-h', 'Prints this help') do
    puts opt
    exit
  end

  opt.on('--type POST_TYPE', 'какой тип постов показывать (по умолчанию любой)') { |o| options[:type] = o } #
  opt.on('--id POST_ID', 'если задан id — показываем подробно только этот пост') { |o| options[:id] = o } #
  opt.on('--limit NUMBER', 'сколько последних постов показать (по умолчанию все)') { |o| options[:limit] = o } #

end.parse!

# Запись данных из БД по введенным нам критериям
id = :id
result = if !options[:id].nil?
           Post.find_by_id(options[:id])
         else
           Post.find_all(options[:limit], options[:type])
         end


# Провекра вызов конкретного класса или всей таблицы
# .is_a? - является ли классом ?
if result.is_a? Post
  puts "Запись #{result.class.name}, id= #{options[:id]}"

      result.to_strings.each do |line|
    puts line
  end
else # показываем таблицу результатов

  print "| id\t| @type\t|  @created_at\t\t\t\t\t|  @text \t\t\t| @url\t\t| @due_date \t "

  result.each do |row|
    puts
    # puts '_'*80
    row.each do |element|

      # Выводим содержимое, но при этом убирая все переносы на новую строку
      # и сокращая выведенную информацию до 40 символов
      print "|  #{element.to_s.delete("\\n\\r")[0..40]}\t"
    end
  end
end

puts
