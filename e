require './entity'
require './client'

client = Client.new
entity = Entity.new

entity.output = client.input
client.output = entity.input

entity.start

begin
  client.start('localhost', 8134)
rescue Interrupt => e
  puts
  puts 'Client stopped.'
end
