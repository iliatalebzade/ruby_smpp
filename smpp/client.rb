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
        puts "Error occurred: Couldn't find to the provided address."
        return false
      rescue Errno::ECONNREFUSED => e
        puts "Error occurred: Connection was refused by the destination server."
      end
    end

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
      p = make_pdu(command_name, **kwargs)
    end

    def make_pdu(command_name, **kwargs)
      p = pdu_factory(command_name, **kwargs)
      is_sent = send_pdu(p, command_name, kwargs)

      if is_sent
        response = @socket.read(16)
        received_response_code = response[4..7].unpack('L>').first
        response_name = command_name + "_resp"
        response_code = get_command_name(response_name)

        if received_response_code == response_code
          puts "The request was a success and acknowledged by the server!"
        else
          puts "Response indicates an error"
        end
      else
        puts "The process of sending PDU was not successful"
      end
    end


    def send_pdu(p, command_name, kwargs)
      binary_pdu = p.generate(kwargs, command_name)

      begin
        @socket.write(binary_pdu)
      rescue => e
        puts "Error occurred: #{e.class}"
        return false
      end

      return true
    end

    #TODO: Implement other commands
    def pdu_factory(command_name, **kwargs)
      {
        'bind_transmitter'        => BindTransmitter,
        'bind_transmitter_resp'   => BindTransmitterResp,
        # 'bind_receiver'           => BindReceiver,
        # 'bind_receiver_resp'      => BindReceiverResp,
        # 'bind_transceiver'        => BindTransceiver,
        # 'bind_transceiver_resp'   => BindTransceiverResp,
        # 'data_sm'                 => DataSM,
        # 'data_sm_resp'            => DataSMResp,
        # 'generic_nack'            => GenericNAck,
        # 'submit_sm'               => SubmitSM,
        # 'submit_sm_resp'          => SubmitSMResp,
        # 'deliver_sm'              => DeliverSM,
        # 'deliver_sm_resp'         => DeliverSMResp,
        # 'query_sm'                => QuerySM,
        # 'query_sm_resp'           => QuerySMResp,
        # 'unbind'                  => Unbind,
        # 'unbind_resp'             => UnbindResp,
        # 'enquire_link'            => EnquireLink,
        # 'enquire_link_resp'       => EnquireLinkResp,
        # 'alert_notification'      => AlertNotification
      }[command_name].new(command_name, **kwargs)
    end
  end
end
