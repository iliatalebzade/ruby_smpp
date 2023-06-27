module SMPP
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
      # Rest of the code
    end

    def get_command_code(command_name)
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
      commands.fetch(command_name) do
        raise StandardError, "Unknown SMPP command code `#{command_name}`"
      end
    end

    def convert_to_bytes(data_hash)
      result = ""

      data_hash.each do |data_item|
        key, value = data_item
        case value
        when Integer
          result += [value].pack("N")
        when String
          result += value.force_encoding("BINARY")
        else
          raise ArgumentError, "Unsupported data type"
        end
      end

      result
    end
  end
end
