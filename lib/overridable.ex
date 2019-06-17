defmodule Overridable do
  import Kernel, except: [+: 2, -: 2, *: 2, /: 2, -: 1, rem: 2, div: 2]

  defmacro __using__(_) do
    quote do
      import Kernel, except: [+: 2, -: 2, *: 2, /: 2, -: 1, rem: 2, div: 2]
      import Overridable
    end
  end

  defguard is_overridable(a)
           when is_tuple(a) and tuple_size(a) == 3 and elem(a, 0) == :overridable

  defp override_operator({:overridable, module, a}, {:overridable, _, b}, o),
    do: module.override(a, b, o)

  defp override_operator({:overridable, module, a}, b, o), do: module.override(a, b, o)

  defp override_operator(a, {:overridable, module, b}, o), do: module.override(a, b, o)

  defp override_operator({:overridable, module, a}, o), do: module.override(a, o)

  def a + b when is_overridable(a) or is_overridable(b) do
    override_operator(a, b, :+)
  end

  def a + b, do: Kernel.+(a, b)

  def a - b when is_overridable(a) or is_overridable(b) do
    override_operator(a, b, :-)
  end

  def a - b, do: Kernel.-(a, b)

  def a * b when is_overridable(a) or is_overridable(b) do
    override_operator(a, b, :*)
  end

  def a * b, do: Kernel.*(a, b)

  def a / b when is_overridable(a) or is_overridable(b) do
    override_operator(a, b, :/)
  end

  def a / b, do: Kernel./(a, b)

  def -a when is_overridable(a) do
    override_operator(a, :-)
  end

  def -a, do: Kernel.-(a)

  def pow(a, b) when is_overridable(a) or is_overridable(b) do
    override_operator(a, b, :pow)
  end

  def pow(a, b), do: :math.pow(a, b)

  def rem(a, b) when is_overridable(a) or is_overridable(b) do
    override_operator(a, b, :rem)
  end

  def rem(a, b), do: Kernel.rem(a, b)

  def div(a, b) when is_overridable(a) or is_overridable(b) do
    override_operator(a, b, :div)
  end

  def div(a, b), do: Kernel.div(a, b)

  def to_bin(a) when is_overridable(a) do
    {_, _, binary} = override_operator(a, :to_bin)
    binary
  end

  def random(a) when is_overridable(a) do
    override_operator(a, :random)
  end
end
