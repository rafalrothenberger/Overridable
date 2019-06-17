defmodule Overridable.Strategy do
  alias Overridable.Strategy.NotImplementedError

  @callback over_add(any(), any()) :: any()
  @callback over_sub(any(), any()) :: any()
  @callback over_mul(any(), any()) :: any()
  @callback over_realdiv(any(), any()) :: any()
  @callback over_pow(any(), any()) :: any()
  @callback over_rem(any(), any()) :: any()
  @callback over_div(any(), any()) :: any()
  @callback over_new(any()) :: any()
  @callback over_neg(any()) :: any()
  @callback over_to_bin(any()) :: binary()
  @callback over_random(any()) :: any()

  defmacro __using__(_) do
    quote do
      @behaviour Overridable.Strategy

      def new(a) do
        {:overridable, __MODULE__, over_new(a)}
      end

      def override(a, b, c \\ nil), do: {:overridable, __MODULE__, do_override(a, b, c)}

      def do_override(a, b, :+), do: over_add(a, b)

      def do_override(a, b, :-), do: over_sub(a, b)

      def do_override(a, b, :*), do: over_mul(a, b)

      def do_override(a, b, :/), do: over_realdiv(a, b)

      def do_override(a, b, :pow), do: over_pow(a, b)

      def do_override(a, b, :div), do: over_div(a, b)

      def do_override(a, b, :rem), do: over_rem(a, b)

      def do_override(a, :-, _), do: over_neg(a)

      def do_override(a, :to_bin, _), do: over_to_bin(a)

      def do_override(a, :random, _), do: over_random(a)

      def over_add(a, b), do: raise(NotImplementedError, "add")

      def over_sub(a, b), do: raise(NotImplementedError, "sub")

      def over_mul(a, b), do: raise(NotImplementedError, "mul")

      def over_realdiv(a, b), do: raise(NotImplementedError, "realdiv")

      def over_pow(a, b), do: raise(NotImplementedError, "pow")

      def over_div(a, b), do: raise(NotImplementedError, "div")

      def over_rem(a, b), do: raise(NotImplementedError, "rem")

      def over_neg(a), do: raise(NotImplementedError, "neg")

      def over_to_bin(a), do: raise(NotImplementedError, "to_bin")

      def over_new(a), do: raise(NotImplementedError, "new")

      def over_random(a), do: raise(NotImplementedError, "random")

      defoverridable over_add: 2,
                     over_sub: 2,
                     over_mul: 2,
                     over_realdiv: 2,
                     over_pow: 2,
                     over_div: 2,
                     over_rem: 2,
                     over_neg: 1,
                     over_to_bin: 1,
                     over_new: 1,
                     over_random: 1
    end
  end
end
