defmodule EdElgamal do
  use Overridable

  def gen_keys({q, b}) do
    skey = EdwardsCurve.random(q)
    pkey = skey * b
    {skey, pkey}
  end

  def enc(msg, pkey, params) do
    {lskey, lpkey} = gen_keys(params)
    key = lskey * pkey
    key = hash(key)
    msg = pad(msg)
    {lpkey, :crypto.exor(msg, key)}
  end

  def dec({pkey, ciphertext}, skey) do
    key = skey * pkey
    key = hash(key)
    msg = :crypto.exor(ciphertext, key)
    unpad(msg)
  end

  defp hash(x) do
    x = to_bin(x)
    :crypto.hash(:sha512, x)
  end

  def pad(msg) do
    pad_len = 64 - byte_size(msg) - 1
    <<pad_len>> <> :crypto.strong_rand_bytes(pad_len) <> msg
  end

  def unpad(<<pad_len::size(8), data::binary>>) do
    pad_len = pad_len * 8
    <<_::size(pad_len), msg::binary>> = data
    msg
  end
end
