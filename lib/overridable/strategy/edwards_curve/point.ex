defmodule Overridable.Strategy.EdwardsCurve.Point do
  use Overridable.Strategy
  use Overridable

  def over_new({{x, y}, d, twisted?}) do
    {{x, y}, d, twisted?}
  end

  def over_add({{x1, y1}, d, twisted?}, {{x2, y2}, d, twisted?}) do
    x3 = (x1 * y2 + y1 * x2) / (1 + d * x1 * y1 * x2 * y2)
    y3 = calc_y(x1, y1, x2, y2, d, twisted?)
    {{x3, y3}, d, twisted?}
  end

  def over_mul(0, {{_x, _y}, d, twisted?} = _a), do: {{0, 1}, d, twisted?}

  def over_mul(1, {{_x, _y}, _d, _twisted?} = a), do: a

  def over_mul(n, {{_x, _y}, _d, _twisted?} = a) do
    q = over_mul(div(n, 2), a)
    q = over_add(q, q)

    if rem(n, 2) == 1 do
      over_add(q, a)
    else
      q
    end
  end

  def over_to_bin({{x, y}, _d, _twisted?}) do
    to_bin(x) <> to_bin(y)
  end

  def over_mul({{_x, _y}, _d, _twisted?} = a, n), do: over_mul(n, a)

  defp calc_y(x1, y1, x2, y2, d, true), do: (y1 * y2 + x1 * x2) / (1 - d * x1 * y1 * x2 * y2)

  defp calc_y(x1, y1, x2, y2, d, false), do: (y1 * y2 - x1 * x2) / (1 - d * x1 * y1 * x2 * y2)
end
