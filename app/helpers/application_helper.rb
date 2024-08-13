module ApplicationHelper
  def format_address(address)
    "#{address['rua']}, #{address['numero']} - #{address['bairro']}, #{address['cidade']} - #{address['uf']}"
  end
end
