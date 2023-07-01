module SMPP
  class PDU
    attr_reader :command_name, :kwargs

    def initialize(command_name, **kwargs)
      @command_name = command_name
      @kwargs = kwargs
    end

    def self.send_pdu(p, command_name, socket, kwargs)
      binary_pdu = p.generate(kwargs, command_name)

      begin
        socket.write(binary_pdu)
      rescue => e
        puts "Error occurred in send_pdu: #{e.class}"
        return false
      end

      return true
    end

    def self.make_pdu(command_name, socket, **kwargs)
      p = pdu_factory(command_name, **kwargs)
      is_sent = send_pdu(p, command_name, socket, kwargs)

      if is_sent
        response = socket.read(16)
        puts "=================== response sent from the server ==================="
        puts response
        puts "====================================================================="
        received_response_code = response[4..7].unpack('L>').first
        response_name = command_name + "_resp"
        response_code = Constants.get_command_name(response_name)

        if received_response_code == response_code
          puts "The request was a success and acknowledged by the server!"
        else
          puts "Response indicates an error in make_pdu"
        end
      else
        puts "The process of sending PDU was not successful in make_pdu"
      end
    end

    #TODO: Implement other commands
    def self.pdu_factory(command_name, **kwargs)
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
        # 'submit_sm'               => SubmitSM, # Uncomment
        # 'submit_sm_resp'          => SubmitSMResp, # Uncomment
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
