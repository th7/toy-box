#serializes and passes data from input to server, unserializes and passes data from server to output

require 'socket'
require 'thread'
require 'edn'

class Client
  attr_reader :input
  attr_writer :output

  def initialize
    @input = Queue.new
  end

  def start(host, port)
    raise 'Must assign output before starting' unless @output

    socket = TCPSocket.open(host, port)

    #listens to server, sends to output
    Thread.start do
      loop do
        got = socket.gets
        if got
          @output << EDN.read(got)
        else
          socket.close
          puts "entity #{id} disconnected"
          break
        end
      end
    end

    #sends from input to server
    Thread.start do
      loop do
        data = @input.pop.to_edn
        socket.puts data
      end
    end

    puts "Connected to server on port: #{port}"
    puts "Use ctrl+c to stop."

    #sends from commandline to server
    loop do
      socket.puts eval(gets.chomp).to_edn
    end
  end
end
