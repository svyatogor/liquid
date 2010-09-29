module MoneyFilter
  def money(input)
    sprintf('$%d', input)
  end

  def money_with_underscores(input)
    sprintf('_$%d_', input)
  end
end

module CanadianMoneyFilter
  def money(input)
    sprintf('$%d CAD', input)
  end
end

