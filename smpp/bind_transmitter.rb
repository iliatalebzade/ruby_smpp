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

    @@last_sequence_number = 0

    def initialize(command_name, **kwargs)
      super
      @sequence_number = generate_sequence_number
    end

    def generate(data_hash, command_code)
      body = convert_to_bytes(data_hash)

      command_length = body.bytesize + 16

      command_code = Constants.get_command_name(command_code)
      command_status = 0x00000000  # Set the command status to a default value (e.g., success)

      # Structure should be as follows:
      # [command_length, command_id, command_status, sequence_number]
      # Pack the ordered array in big-endian bytes
      header = [command_length, command_code, command_status, @sequence_number].pack("L>L>L>L>")

      return header + body
    end

    def generate_sequence_number
      @@last_sequence_number += 1
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

  class BindTransmitterResp < Command
    include Constants

    @@params = {
      'system_id' => Param.new(type: String, max: 16),
      'sc_interface_version' => Param.new(type: Integer, size: 1)
    }

    @@params_order = ['system_id', 'sc_interface_version']

    def initialize(command, **kwargs)
      super(command, need_sequence: false, **kwargs)
      _set_vars(**(Hash[@@params.keys.map { |k| [k, nil] }]))
    end

    private

    def _set_vars(**kwargs)
      kwargs.each { |k, v| instance_variable_set("@#{k}", v) }
    end
  end
end
