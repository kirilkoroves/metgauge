defmodule Metgauge.Aes do
  # Use AES 128 Bit Keys for Encryption.
  @block_size 16

  def encrypt(plaintext) do
    # create random Initialisation Vector
    iv = :crypto.strong_rand_bytes(16)
    # sample secret_key is a 32 bit hex string 
    secret_key = Base.decode16!(Application.get_env(:metgauge, :secret_aes_key))
    plaintext = pad(plaintext, @block_size)
    encrypted_text = :crypto.crypto_one_time(:aes_128_cbc, secret_key, iv, plaintext, true )
    encrypted_text = ( iv <>  encrypted_text )
    :base64.encode(encrypted_text)
  end

  def decrypt(ciphertext) do
    IO.inspect(ciphertext)
    secret_key = Base.decode16!(Application.get_env(:metgauge, :secret_aes_key))
    ciphertext = :base64.decode(ciphertext)
    <<iv::binary-16, ciphertext::binary>> = ciphertext
    decrypted_text = :crypto.crypto_one_time(:aes_128_cbc, secret_key, iv, ciphertext, false )
    unpad(decrypted_text)
  end

  def unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end

# PKCS5Padding
  def pad(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> :binary.copy(<<to_add>>, to_add)
  end
end