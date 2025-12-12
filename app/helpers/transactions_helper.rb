module TransactionsHelper

  def transaction_amount(transaction)
    if %w[expense withdraw].include? transaction.transaction_type
      transaction.amount * -1
    else
      transaction.amount
    end
  end
end
