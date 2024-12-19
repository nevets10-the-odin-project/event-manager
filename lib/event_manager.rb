require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(number)
  trim_num = number.gsub(/[^\d]/, '')
  if trim_num.length == 10
    trim_num
  elsif trim_num.length == 11 && trim_num[0] == '1'
    trim_num[1..10]
  else
    '0000000000'
  end
end

def format_time(regdate)
  formatted = []
  regdate.each do |row|
    month = row.split('/')[0].rjust(2, '0')
    day = row.split('/')[1].rjust(2, '0')
    year = "20#{row.split('/')[2][0..1]}"
    hour = row.split[1].split(':')[0].rjust(2, '0')
    min = row.split[1].split(':')[1].rjust(2, '0')

    formatted << Time.new("#{year}-#{month}-#{day} #{hour}:#{min}:00")
  end

  formatted
end

def count_records(days)
  days.each_with_object({}) do |cur, acc|
    acc[cur] = acc.key?(cur) ? acc[cur] += 1 : 1
  end
end

def get_peak_hours(regdate)
  reg_times = format_time(regdate).map { |time| time.hour.to_s }
  hours = count_records(reg_times)
  hours.filter { |hour, count| count == hours.values.max }.keys
end

def get_peek_days(regdate)
  reg_days = format_time(regdate).map { |date| date.strftime('%A') }
  day_count = count_records(reg_days)
  day_count.filter { |day, count| count == day_count.values.max }.keys
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

regdate = contents.map { |row| row[:regdate] }
peak_hours = get_peak_hours(regdate)
peak_days = get_peek_days(regdate)

p peak_hours
p peak_days

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])

  # legislators = legislators_by_zipcode(zipcode)

  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id, form_letter)
end
