module SMPP
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

  class SubmitSM
    attr_accessor :service_type, :source_addr_ton, :source_addr_npi, :source_addr,
                  :dest_addr_ton, :dest_addr_npi, :destination_addr, :esm_class,
                  :protocol_id, :priority_flag, :schedule_delivery_time, :validity_period,
                  :registered_delivery, :replace_if_present_flag, :data_coding,
                  :sm_default_msg_id, :sm_length, :short_message

    # Optional params (You can add more if needed)
    attr_accessor :user_message_reference, :source_port, :source_addr_subunit,
                  :destination_port, :dest_addr_subunit, :sar_msg_ref_num,
                  :sar_total_segments, :sar_segment_seqnum, :more_messages_to_send,
                  :payload_type, :message_payload, :privacy_indicator,
                  :callback_num, :callback_num_pres_ind, :source_subaddress,
                  :dest_subaddress, :user_response_code, :display_time,
                  :sms_signal, :ms_validity, :ms_msg_wait_facilities,
                  :number_of_messages, :alert_on_message_delivery,
                  :language_indicator, :its_reply_type, :its_session_info,
                  :ussd_service_op

    def initialize(command, **kwargs)
      self.service_type = nil
      self.source_addr_ton = nil
      self.source_addr_npi = nil
      self.source_addr = nil
      self.dest_addr_ton = nil
      self.dest_addr_npi = nil
      self.destination_addr = nil
      self.esm_class = nil
      self.protocol_id = nil
      self.priority_flag = nil
      self.schedule_delivery_time = nil
      self.validity_period = nil
      self.registered_delivery = nil
      self.replace_if_present_flag = nil
      self.data_coding = nil
      self.sm_default_msg_id = nil
      self.sm_length = 0
      self.short_message = nil

      self.user_message_reference = nil
      self.source_port = nil
      self.source_addr_subunit = nil
      self.destination_port = nil
      self.dest_addr_subunit = nil
      self.sar_msg_ref_num = nil
      self.sar_total_segments = nil
      self.sar_segment_seqnum = nil
      self.more_messages_to_send = nil
      self.payload_type = nil
      self.message_payload = nil
      self.privacy_indicator = nil
      self.callback_num = nil
      self.callback_num_pres_ind = nil
      self.source_subaddress = nil
      self.dest_subaddress = nil
      self.user_response_code = nil
      self.display_time = nil
      self.sms_signal = nil
      self.ms_validity = nil
      self.ms_msg_wait_facilities = nil
      self.number_of_messages = nil
      self.alert_on_message_delivery = nil
      self.language_indicator = nil
      self.its_reply_type = nil
      self.its_session_info = nil
      self.ussd_service_op = nil

      # Initialize with the given keyword arguments
      kwargs.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end

      prep
    end

    def prep
      # Prepare to generate binary data
      if short_message
        raise ValueError, '`message_payload` can not be used with `short_message`' if message_payload
        self.sm_length = short_message.length
      else
        self.sm_length = 0
      end
    end
  end
end
