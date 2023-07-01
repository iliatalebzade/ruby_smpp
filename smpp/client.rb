require_relative "constants"

module SMPP
  class Client
    attr_accessor :socket, :bound, :host, :port

    include Constants

    def initialize(host, port)
      @socket = nil
      @bound  = false
      @host   = host
      @port   = port
    end

    def connect
      begin
        @socket = TCPSocket.new @host, @port
        puts "Connection successful!"
        return true
      rescue Errno::EHOSTUNREACH => e
        puts "Error occurred in connect: Couldn't find to the provided address."
        return false
      rescue Errno::ECONNREFUSED => e
        puts "Error occurred in connect: Connection was refused by the destination server."
      end
    end

    # FOR DEVELOPMENT REASONS ONLY
    def send_message_test()
      config = {
        source_addr_ton: "5",
        source_addr: "localhost",
        dest_addr_ton: "1",
        destination_addr: "09338883008",
        short_message: "Hello, there!",
      }

      send_message(**config)
    end

    # def send_message(**kwargs)
    #   # Required Arguments
    #   # - source_addr_ton: Source address TON
    #   # - source_addr: Source address (string)
    #   # - dest_addr_ton: Destination address TON
    #   # - destination_addr: Destination address (string)
    #   # - short_message: Message text (string)

    #   raise ArgumentError, 'source_addr_ton is required' unless kwargs.key?(:source_addr_ton)
    #   raise ArgumentError, 'source_addr is required' unless kwargs.key?(:source_addr)
    #   raise ArgumentError, 'dest_addr_ton is required' unless kwargs.key?(:dest_addr_ton)
    #   raise ArgumentError, 'destination_addr is required' unless kwargs.key?(:destination_addr)
    #   raise ArgumentError, 'short_message is required' unless kwargs.key?(:short_message)

    #   pdu = PDU.pdu_factory('submit_sm', **kwargs)
    #   binary_pdu = pdu.generate(kwargs, 'submit_sm')

    #   begin
    #     @socket.write(binary_pdu)
    #   rescue => e
    #     puts "Error occurred: #{e.class}"
    #     return false
    #   end

    #   response = @socket.read(16)
    #   received_response_code = response[4..7].unpack('L>').first
    #   response_name = 'submit_sm_resp'
    #   response_code = get_command_name(response_name)

    #   if received_response_code == response_code
    #     puts "The request was a success and acknowledged by the server!"
    #   else
    #     puts "Response indicates an error"
    #   end

    #   return true
    # end


    def bind_transmitter
      config = {
        'system_id'         => "iBus",
        'password'          => "Ib179@e7",
        'system_type'       => "",
        'interface_version' => 52,
        'addr_ton'          => 5,
        'addr_npi'          => 1,
        'address_range'     => ""
      }

      bind("bind_transmitter", **config)
    end

    def bind(command_name, **kwargs)
      p = PDU.make_pdu(command_name, @socket, **kwargs)
    end
  end
end
