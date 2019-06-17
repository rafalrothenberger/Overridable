defmodule Overridable.Strategy.FiniteField do
  use Overridable.Strategy

  defguardp is_ff(a)
            when is_tuple(a) and tuple_size(a) == 2 and is_integer(elem(a, 0)) and
                   is_integer(elem(a, 1))

  def mod(a, n), do: rem(rem(a, n) + n, n)

  def over_new({n, a}) when is_integer(n) and is_integer(n), do: {n, mod(a, n)}

  def inv({n, a}), do: {n, pow(a, n - 2, n)}

  def over_add({n, a}, {n, b}), do: {n, mod(a + b, n)}

  def over_add(a, b) do
    {a, b} = arguments_to_ff(a, b)
    over_add(a, b)
  end

  def over_sub({n, a}, {n, b}), do: {n, mod(a - b, n)}

  def over_sub(a, b) do
    {a, b} = arguments_to_ff(a, b)
    over_sub(a, b)
  end

  def over_mul({n, a}, {n, b}), do: {n, mod(a * b, n)}

  def over_mul(a, b) do
    {a, b} = arguments_to_ff(a, b)
    over_mul(a, b)
  end

  def over_realdiv(a, b) when is_ff(a) and is_ff(b) do
    over_mul(a, inv(b))
  end

  def over_realdiv(a, b) do
    {a, b} = arguments_to_ff(a, b)
    over_realdiv(a, b)
  end

  def over_pow({n, a}, {n, b}), do: {n, pow(a, b, n)}

  def over_pow(a, b) do
    {a, b} = arguments_to_ff(a, b)
    over_pow(a, b)
  end

  def over_rem({n, a}, {n, b}), do: {n, mod(rem(a, b), n)}

  def over_rem(a, b) do
    {a, b} = arguments_to_ff(a, b)
    over_rem(a, b)
  end

  def over_neg({n, a}), do: mod(n - a, n)
  def over_to_bin({_n, a}), do: :binary.encode_unsigned(a)

  defp pow(a, x, n), do: :crypto.mod_pow(a, x, n) |> :binary.decode_unsigned()
  defp arguments_to_ff({n, a}, b), do: {{n, a}, over_new({n, b})}
  defp arguments_to_ff(a, {n, b}), do: {over_new({n, a}), {n, b}}
end
