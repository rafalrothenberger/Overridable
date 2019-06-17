defmodule Overridable.Strategy.SchnorrGroup do
  alias Overridable.Strategy.SchnorrGroup.Prime
  use Overridable.Strategy

  defp random_first_byte(1), do: <<1>>

  defp random_first_byte(2), do: <<:crypto.rand_uniform(2, 4)>>

  defp random_first_byte(3), do: <<:crypto.rand_uniform(4, 8)>>

  defp random_first_byte(4), do: <<:crypto.rand_uniform(8, 16)>>

  defp random_first_byte(5), do: <<:crypto.rand_uniform(16, 32)>>

  defp random_first_byte(6), do: <<:crypto.rand_uniform(32, 64)>>

  defp random_first_byte(7), do: <<:crypto.rand_uniform(64, 128)>>

  defp random_first_byte(8), do: <<:crypto.rand_uniform(128, 256)>>

  def random_prime(t_bits, tries \\ 0) do
    first_byte_length = rem(t_bits, 8)

    first_byte_length =
      if first_byte_length == 0 do
        8
      else
        first_byte_length
      end

    bits = t_bits - first_byte_length
    bytes = div(bits, 8) - 1
    # IO.inspect({first_byte_length, bits, bytes})
    p =
      (random_first_byte(first_byte_length) <>
         :crypto.strong_rand_bytes(bytes) <> <<:crypto.rand_uniform(0, 128) * 2 + 1>>)
      |> :binary.decode_unsigned()

    IO.puts(tries)

    if Prime.is_prime?(p) do
      p
    else
      random_prime(t_bits, tries + 1)
    end
  end

  def test_prime(p) do
    {result, _} = System.cmd("openssl", ["prime", "#{p}"])
    result == "#{p} is prime\n"
  end

  def random_prime_openssl(bits) do
    {p, _} = System.cmd("openssl", ["prime", "-bits", "#{bits}", "-generate"])
    p = String.trim(p, "\n")
    {p, ""} = Integer.parse(p)
    p
  end

  def gen_params(bits, r \\ 2) do
    p = random_prime_openssl(bits)

    q = div(p, r)

    if q * r + 1 == p and test_prime(q) do
      {p, q, r}
    else
      gen_params(bits, r)
    end
  end

  def random_g({p, _q, r} = params) do
    h = :crypto.rand_uniform(2, p)
    g = pow(h, r, p)

    if g != 1 do
      g
    else
      random_g(params)
    end
  end

  def over_new({p, q, r} = params) do
    if q * r + 1 != p, do: raise("Wrong parameters. q * r + 1 != p")

    g = random_g(params)
    # IO.inspect(g)
    {:p, g, {p, q, g}}
  end

  def over_new({a, {:q, _, {p, q, g}}}) do
    {:q, mod(a, q), {p, q, g}}
  end

  def over_new({a, {:p, _, {p, q, g}}}) do
    {:p, mod(a, p), {p, q, g}}
  end

  def over_add({:q, a, {p, q, g}}, {:q, b, {p, q, g}}) do
    {:q, mod(a + b, q), {p, q, g}}
  end

  def over_add(a, {:q, b, {p, q, g}}) do
    {:q, mod(a + b, q), {p, q, g}}
  end

  def over_add({:q, a,  {p, q, g}}, b) do
    {:q, mod(a + b, q),  {p, q, g}}
  end

  def over_sub({:q, a,  {p, q, g}}, {:q, b,  {p, q, g}}) do
    {:q, mod(a - b, q),  {p, q, g}}
  end

  def over_sub(a, {:q, b,  {p, q, g}}) do
    {:q, mod(a - b, q),  {p, q, g}}
  end

  def over_sub({:q, a,  {p, q, g}}, b) do
    {:q, mod(a - b, q),  {p, q, g}}
  end

  def over_mul({:q, a,  {p, q, g}}, {:q, b,  {p, q, g}}) do
    {:q, mod(a * b, q),  {p, q, g}}
  end

  def over_mul({:p, a,  {p, q, g}}, {:p, b,  {p, q, g}}) do
    {:p, mod(a * b, p),  {p, q, g}}
  end

  def over_realdiv(1, {:q, b,  {p, q, g}}) do
    {:q, pow(b, q - 2, q),  {p, q, g}}
  end

  def over_realdiv(1, {:p, b,  {p, q, g}}) do
    {:p, pow(b, p - 2, p),  {p, q, g}}
  end

  def over_realdiv({:q, a,  {p, q, g}}, {:q, b,  {p, q, g}}) do
    b = pow(b, q - 2, q)
    over_mul({:q, a,  {p, q, g}}, {:q, b,  {p, q, g}})
  end

  def over_realdiv({:p, a,  {p, q, g}}, {:p, b,  {p, q, g}}) do
    b = pow(b, p - 2, p)
    over_mul({:p, a,  {p, q, g}}, {:p, b,  {p, q, g}})
  end

  def over_realdiv(a, {:q, b,  {p, q, g}}) do
    {:q, mod(a * pow(b, q - 2, q), q),  {p, q, g}}
  end

  # def over_realdiv(a, {:p, b,  {p, q, g}}) do
  #   {:p, mod(a * pow(b,p-2,p), p),  {p, q, g}}
  # end

  def over_realdiv({:q, a,  {p, q, g}}, b) do
    b = pow(b, q - 2, q)
    over_mul({:q, a,  {p, q, g}}, {:q, b,  {p, q, g}})
  end

  # def over_realdiv({:p, a,  {p, q, g}}, b) do
  #   b = pow(b,p-2,p)
  #   over_mul({:p, a,  {p, q, g}}, {:p, b,  {p, q, g}})
  # end

  def over_pow({:q, a,  {p, q, g}}, {:q, b,  {p, q, g}}) do
    {:q, pow(a, b, q),  {p, q, g}}
  end

  def over_pow({:q, a,  {p, q, g}}, b) do
    {:q, pow(a, b, q),  {p, q, g}}
  end

  def over_pow({:p, a,  {p, q, g}}, {:q, b,  {p, q, g}}) do
    {:p, pow(a, b, p),  {p, q, g}}
  end

  def over_neg({:q, a,  {p, q, g}}) do
    {:q, mod(-a, q),  {p, q, g}}
  end

  def over_neg({:p, a,  {p, q, g}}) do
    {:p, mod(-a, p),  {p, q, g}}
  end

  def random({:overridable, __MODULE__, a}) do
    {a,b} = random(a)
    a = {:overridable, __MODULE__, a}
    b = {:overridable, __MODULE__, b}
    {a,b}
  end

  def random({_, _, {p,q,g}}) do
    r = :crypto.rand_uniform(2, q)
    gr = pow(g,r,p)
    {
      {:q,r,{p,q,g}},
      {:p,gr,{p,q,g}}
    }
  end

  def over_to_bin({t, a, {_p, _q, _g}}) when t in [:p, :q] do
    :binary.encode_unsigned(a)
  end

  def random_q({:overridable,__MODULE__,a}) do
    random_q(a)
  end

  def random_q({_, _,  {p, q, g}}) do
    {:q, :crypto.rand_uniform(2, q),  {p, q, g}}
  end

  def random_p({:overridable,__MODULE__,a}) do
    random_p(a)
  end

  def random_p({_, _,  {p, q, g}}) do
    {:p, pow(g,:crypto.rand_uniform(2, q),p),  {p, q, g}}
  end

  defp mod(a, n) do
    rem(rem(a, n) + n, n)
  end

  defp pow(a, x, n) do
    :crypto.mod_pow(a, x, n) |> :binary.decode_unsigned()
  end
end
