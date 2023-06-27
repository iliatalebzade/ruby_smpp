bind_transmitter_pdu_hash = {
  psystem_id: 'iBus',
  password: 'Ib179@e7',
  system_type: '',
  interface_version: 52,
  addr_ton: 5,
  addr_npi: 1,
  address_range: ''
}

pdu_body_array = [
  psystem_id,
  password,
  system_type,
  interface_version,
  addr_ton,
  addr_npi,
  address_range
]

command = "submit_sm"

def generate
  # Generate raw PDU

  body = generate_params(pdu_body_array)

  length = body.length + 16

  command_code = get_command_code(command)

  header = [length, command_code, status, sequence].pack("N*")

  header + body
end

def generate_params(data_array)
  value = ""

  data_array.each do |item|
    if item.class == Integer
      result = [item].pack("N")
      value += result
    elsif item.class == String
      result = item.force_encoding("BINARY")
      value += result
    else
      raise "#{item.class} is not string nor int"
    end
  end
  value
end

def get_command_code(name)
  # Return command code by given command name.
  # If name is unknown, raise UnknownCommandError exception.
  commands = {
    generic_nack: 0x80000000,
    bind_receiver: 0x00000001,
    bind_receiver_resp: 0x80000001,
    bind_transmitter: 0x00000002,
    bind_transmitter_resp: 0x80000002,
    query_sm: 0x00000003,
    query_sm_resp: 0x80000003,
    submit_sm: 0x00000004,
    submit_sm_resp: 0x80000004,
    deliver_sm: 0x00000005,
    deliver_sm_resp: 0x80000005,
    unbind: 0x00000006,
    unbind_resp: 0x80000006,
    replace_sm: 0x00000007,
    replace_sm_resp: 0x80000007,
    cancel_sm: 0x00000008,
    cancel_sm_resp: 0x80000008,
    bind_transceiver: 0x00000009,
    bind_transceiver_resp: 0x80000009,
    outbind: 0x0000000B,
    enquire_link: 0x00000015,
    enquire_link_resp: 0x80000015,
    submit_multi: 0x00000021,
    submit_multi_resp: 0x80000021,
    alert_notification: 0x00000102,
    data_sm: 0x00000103,
    data_sm_resp: 0x80000103,
  }

  key = name.to_sym
  return commands[key]
end

