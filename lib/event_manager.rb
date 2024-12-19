puts 'Event Manager Initialized!'

lines = File.readlines('event_attendees.csv')
lines.each_with_index do |line, index|
  next if index.zero?

  puts line.split(',')[2]
end
