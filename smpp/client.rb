module SMPP
  class Client
    attr_accessor :socket, :bound, :host, :port

    def initialize(host, port)
      @socket = nil
      @bound  = false
      @host   = host
      @port   = port

      connect()
    end

    def connect
      @socket = TCPSocket.new @host, port
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

      is_bound = bind("bind_transmitter", **config)
    end

    def bind(command_name, **kwargs)
      p = make_pdu(command_name, **kwargs)
    end

    def make_pdu(command_name, **kwargs)
      p = pdu_factory(command_name, **kwargs)

      send_pdu(p, command_name, kwargs)
    end

    def send_pdu(p, command_name, kwargs)
      generated = p.generate(kwargs, command_name)
    end

    def pdu_factory(command_name, **kwargs)
      {
        'bind_transmitter'        => BindTransmitter
        # 'bind_transmitter_resp'   => BindTransmitterResp,
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
