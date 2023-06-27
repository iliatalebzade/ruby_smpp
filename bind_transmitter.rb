require 'socket'
require 'byebug'

CONSTS = {
  SMPP_CLIENT_STATE_OPEN: 1,
  SMPP_VERSION_52: 52
}.freeze

class Command
  attr_accessor :command_name, :kwargs

  def initialize(command_name, **kwargs)
    @command_name = command_name
    @kwargs = kwargs
  end
end

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
    # Rest of the code
  end

  def make_pdu(command_name, **kwargs)
    p = pdu_factory(command_name, **kwargs)

    send_pdu(p, command_name, kwargs.to_a)
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

class Param
  # Command parameter info class

  def initialize(**kwargs)
    raise KeyError, 'Parameter Type not defined' unless kwargs.key?(:type)

    valid_types = [Integer, String, Object, Symbol]
    unless valid_types.include?(kwargs[:type])
      raise ValueError, "Invalid parameter type: #{kwargs[:type]}"
    end

    valid_keys = [:type, :size, :min, :max, :len_field]
    kwargs.each_key do |k|
      raise KeyError, "Key '#{k}' not allowed here" unless valid_keys.include?(k)
    end

    @type = kwargs[:type]

    [:size, :min, :max, :len_field].each do |param|
      if kwargs.key?(param)
        instance_variable_set("@#{param}", kwargs[param])
      end
    end
  end

  def to_s
    # Shows type of Param in console
    "<Param of #{@type}>"
  end
end

class BindTransmitter < Command
  # Bind as a transmitter command

  @@params = {
    'system_id' => Param.new(type: String, max: 16),
    'password' => Param.new(type: String, max: 9),
    'system_type' => Param.new(type: String, max: 13),
    'interface_version' => Param.new(type: Integer, size: 1),
    'addr_ton' => Param.new(type: Integer, size: 1),
    'addr_npi' => Param.new(type: Integer, size: 1),
    'address_range' => Param.new(type: String, max: 41)
  }

  # Order is important, but params hash is unordered
  @@params_order = [
    'system_id', 'password', 'system_type',
    'interface_version', 'addr_ton', 'addr_npi', 'address_range'
  ]

  def initialize(command_name, **kwargs)
    super
  end

  def generate(data_hash, command_code)
    body = convert_to_bytes(data_hash)

    length = body.bytesize + 16

    command_code = get_command_code(command_code)

    header = struct.pack(">LLLL", self._length, command_code)
  end

  def convert_to_bytes(data_hash)
    value = ""

    data_hash.each do |data_item|
      case data_item
      when Integer
        result = [data_item].pack("N")
        value += result
      when String
        result = data_item.force_encoding("BINARY")
        value += result
      else
        raise ArgumentError, "Unsupported data type"
      end
    end

    value
  end
end

#
# Command Codes
#


def get_command_name(code)
  commands = {
    'generic_nack' => 0x80000000,
    'bind_receiver' => 0x00000001,
    'bind_receiver_resp' => 0x80000001,
    'bind_transmitter' => 0x00000002,
    'bind_transmitter_resp' => 0x80000002,
    'query_sm' => 0x00000003,
    'query_sm_resp' => 0x80000003,
    'submit_sm' => 0x00000004,
    'submit_sm_resp' => 0x80000004,
    'deliver_sm' => 0x00000005,
    'deliver_sm_resp' => 0x80000005,
    'unbind' => 0x00000006,
    'unbind_resp' => 0x80000006,
    'replace_sm' => 0x00000007,
    'replace_sm_resp' => 0x80000007,
    'cancel_sm' => 0x00000008,
    'cancel_sm_resp' => 0x80000008,
    'bind_transceiver' => 0x00000009,
    'bind_transceiver_resp' => 0x80000009,
    'outbind' => 0x0000000B,
    'enquire_link' => 0x00000015,
    'enquire_link_resp' => 0x80000015,
    'submit_multi' => 0x00000021,
    'submit_multi_resp' => 0x80000021,
    'alert_notification' => 0x00000102,
    'data_sm' => 0x00000103,
    'data_sm_resp' => 0x80000103,
  }

  commands.each do |key, value|
    return value if key == code
  end

  raise StandardError, "Unknown SMPP command code `#{code}`"
end



#
# Exceptions
#

module Errors
  class UnknownCommandError < StandardError
    # Raised when unknown command ID is received
  end

  class ConnectionError < StandardError
    # Connection error
  end

  class PDUError < RuntimeError
    # Error processing PDU
  end

  class MessageTooLong < StandardError
    # Text too long to fit 255 SMS
  end
end

