require 'csv'

def clean_zip(zip)
  zip.to_s.rjust(5, '0')[0..4]
end

puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]
  zip = clean_zip(row[:zipcode])

  puts "#{name} #{zip}"
end
