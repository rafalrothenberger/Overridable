defmodule EdwardsCurve do
  use Overridable
  alias Overridable.Strategy.EdwardsCurve.Point, as: P
  alias Overridable.Strategy.FiniteField

  def gen(:ed448) do
    q =
      726_838_724_295_606_890_549_323_807_888_004_534_353_641_360_687_318_060_281_490_199_180_612_328_166_730_772_686_396_383_698_676_545_930_088_884_461_843_637_361_053_498_018_365_439

    d = -39081

    bx =
      117_812_161_263_436_946_737_282_484_343_310_064_665_180_535_357_016_373_416_879_082_147_939_404_277_809_514_858_788_439_644_911_793_978_499_419_995_990_477_371_552_926_308_078_495

    by = 19
    bx = FiniteField.new({q, bx})
    by = FiniteField.new({q, by})
    twisted? = false
    gen(q, d, twisted?, bx, by)
  end

  def gen(q, d, twisted?, bx, by) do
    b = P.new({{bx, by}, d, twisted?})
    {q, b}
  end

  def base({_q, b}), do: b

  def random_point({q, b}) do
    n = random(q)
    b * n
  end
end
