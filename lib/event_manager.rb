require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phonenumber(number)
  number = number.to_s.gsub(/[^0-9]/, '')

  return number.rjust(11, '1')[1..10] if (number[0] == '1' && number.length == 11) || number.length == 10

  "INVALID-NUMBER"
end

def get_hour(regdate)
  Time.strptime(regdate, '%m/%d/%Y %k:%M').hour
end

def get_day(regdate )
  day = Time.strptime(regdate, '%m/%d/%Y %k:%M').wday
  case day
  when 0
    'sunday'
  when 1
    'monday'
  when 2
    'tuesday'
  when 3
    'wednesday'
  when 4
    'thursday'
  when 5
    'friday'
  else
    'saturday'
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
hour_hash = Hash.new(0)
week_hash = Hash.new(0)

contents.each do |row|
    
  # id = row[0]
  # name = row[:first_name]
  # zipcode = clean_zipcode(row[:zipcode])
  # legislators = legislators_by_zipcode(zipcode)
  number = row[:homephone]
  reg_hour = get_hour(row[:regdate])
  reg_day = get_day(row[:regdate])
  hour_hash[reg_hour] += 1
  week_hash[reg_day] += 1
  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id,form_letter)
  puts clean_phonenumber(number)
end
def largest_hash_key(hash)
  hash.max_by{|k,v| v}
end

puts "Most people are registered at #{largest_hash_key(hour_hash)[0]}"
puts "Most people are registered in #{largest_hash_key(week_hash)[0]}"
