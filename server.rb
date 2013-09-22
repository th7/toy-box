#unserializes and passes data from clients to output, serializes and passes data from input to clients

require 'socket'
require 'thread'
require 'edn'

class Server
  attr_reader :input
  attr_writer :output

  def initialize
    @from_clients = Queue.new
    @input = Queue.new

    @sockets = []

  end

  def start(port)
    raise 'Must assign output before starting' unless @output

    puts "Starting server..."
    server = TCPServer.open(port)
    #listens for connections
    Thread.start do
      loop do
        #listens to a connection, sends to output
        Thread.start(server.accept) do |socket|
          @sockets << socket
          puts "#{@sockets.count} connected (new connection)"
          loop do
            got = socket.gets
            if got
              @output << EDN.read(got)
            else
              @sockets.delete(socket)
              socket.close
              puts "#{@sockets.count} connected (disconnection)"
              break
            end
          end
        end
      end
    end

    #sends from input to clients
    Thread.start do
      loop do
        data = @input.pop.to_edn
        @sockets.each { |s| s.puts data }
      end
    end

    puts "Server running on port: #{port}"
    puts "Use ctrl+c to stop."

    #sends from commandline to clients
    loop do
      data = eval(gets.chomp).to_edn
      @sockets.each { |s| s.puts data }
    end
  end
end
