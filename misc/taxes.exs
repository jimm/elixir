defmodule TaxCalc do

  def add_taxes(tax_rates, orders), do: _add_taxes(tax_rates, [], orders)

  defp _add_taxes(_, added, []), do: Enum.reverse(added)
  defp _add_taxes(tax_rates, added, [order|t]) do
    _add_taxes(tax_rates, [taxed_order(tax_rates, order) | added], t)
  end

  defp taxed_order(tax_rates, order) do
    rate = tax_rates[order[:ship_to]] || 0
    total_amount = order[:net_amount] + order[:net_amount] * rate
    Keyword.merge(order, [total_amount: total_amount])
  end
end

tax_rates = [NC: 0.075, TX: 0.08]
orders = [      
  [ id: 123, ship_to: :NC, net_amount: 100.00 ],    
  [ id: 124, ship_to: :OK, net_amount:   35.50 ],    
  [ id: 125, ship_to: :TX, net_amount:   24.00 ],    
  [ id: 126, ship_to: :TX, net_amount:   44.80 ],    
  [ id: 127, ship_to: :NC, net_amount:   25.00 ],    
  [ id: 128, ship_to: :MA, net_amount:   10.00 ],    
  [ id: 129, ship_to: :CA, net_amount: 102.00 ],    
  [ id: 120, ship_to: :NC, net_amount:   50.00 ] ]

TaxCalc.add_taxes(tax_rates, orders)
  |> Enum.map(&inspect/1)
  |> Enum.join("\n")
  |> IO.puts
