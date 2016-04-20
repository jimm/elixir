defmodule Day2 do
  @input_file "data/day_2.txt"

  def total_paper_area_needed do
    calculate_need(&paper_area_needed/1)
  end

  def total_ribbon_length_needed do
    calculate_need(&ribbon_length_needed/1)
  end

  # ================ helpers ================

  defp calculate_need(f) do
    File.stream!(@input_file)
    |> Enum.map(&parse/1)
    |> Enum.map(f)
    |> Enum.sum
  end

  defp parse(s) do
    s
    |> String.strip
    |> String.split("x")
    |> Enum.map(&String.to_integer/1)
  end

  # ================ paper area ================

  defp paper_area_needed([l, w, h]) do
    surface_area(l, w, h) + smallest_side_area(l, w, h)
  end

  defp surface_area(l, w, h), do: 2*l*w + 2*w*h + 2*h*l

  defp smallest_side_area(l, w, h) do
    [l*w, l*h, w*h]
    |> Enum.min
  end

  # ================ ribbon length ================

  defp ribbon_length_needed([l, w, h]) do
    smallest_perimeter(l, w, h) + cubic_volume(l, w, h)
  end

  def smallest_perimeter(l, w, h) do
    smallest_half_perim = [l+w, l+h, w+h]
    |> Enum.min
    smallest_half_perim * 2
  end

  defp cubic_volume(l, w, h), do: l * w * h
end

# Day2.total_paper_area_needed
# Day2.total_ribbon_length_needed
