require 'gsm_encoder'
require 'securerandom'

# Example usage (for english text just pass the message text)
# text = "ریز علی یا زیر علی؟؟؟"
# parts, encoding, esm_class = SMPP::GSM.make_parts(text, SMPP::Constants::SMPP_ENCODING_ISO10646)

module SMPP
  def self.gsm_encode(plaintext)
    GSMEncoder.encode(plaintext)
  end

  def self.make_parts(text, encoding = Constants::SMPP_ENCODING_DEFAULT, use_udhi = true)
    begin
      encode, split_length, part_size = ENCODINGS[encoding]
      encoded_text = encode.call(text)
    rescue KeyError
      raise NotImplementedError.new("encoding is not supported: #{encoding}")
    rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
      encoding = Constants::SMPP_ENCODING_ISO10646
      encode, split_length, part_size = ENCODINGS[encoding]
      encoded_text = encode.call(text)
    end

    if encoded_text.bytesize > split_length
      if use_udhi
        esm_class = 64
        parts = make_parts_encoded(encoded_text, part_size)
      else
        esm_class = 0
        parts = split_sequence(encoded_text, part_size)
        raise RuntimeError, "MessageTooLong" if parts.length > 255
      end
    else
      esm_class = 0
      parts = [encoded_text]
    end

    [parts, encoding, esm_class]
  end

  ENCODINGS = {
    Constants::SMPP_ENCODING_DEFAULT => [method(:gsm_encode), Constants::SEVENBIT_LENGTH, Constants::SEVENBIT_PART_SIZE],
    Constants::SMPP_ENCODING_ISO88591 => [lambda { |text| text.encode('iso-8859-1') }, Constants::EIGHTBIT_LENGTH, Constants::EIGHTBIT_PART_SIZE],
    Constants::SMPP_ENCODING_ISO10646 => [lambda { |text| text.encode('utf-16be') }, Constants::UCS2_LENGTH, Constants::UCS2_PART_SIZE]
  }

  def make_parts_encoded(encoded_text, part_size)
    chunks = split_sequence(encoded_text, part_size)
    raise RuntimeError, "MessageTooLong" if chunks.length > 255

    uid = SecureRandom.random_number(256)
    header = "\x05\x00\x03#{uid.chr}#{chunks.length.chr}".force_encoding('BINARY')

    chunks.each_with_index.map { |chunk, i| "#{header}#{(i + 1).chr}#{chunk}" }
  end

  def split_sequence(sequence, part_size)
    sequence.chars.each_slice(part_size).map(&:join)
  end

end


