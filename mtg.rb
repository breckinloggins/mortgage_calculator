def dollarRound(amount)
  (amount * 100).round.to_f / 100
end

balance = 235000          # Opening balance, in dollars
periods = 360             # Monthly periods (360 for a 30 year note)
apr = 6.375               # Annual percentage rate (interest) in percent

extraPayments = Hash.new      # Extra payments keyed by the period they start, NOT cumulative
                              # i.e. if extraPayments[12] = 100 and extraPayments[24] = 200, the total extra
                              # payment for the 25th month is $200.00, NOT $300.00

lumpsumPayments = Hash.new    # One time payments keyed by payment month                              

#extraPayments[12] = 100
#extraPayments[36] = 200
#extraPayments[48] = 300
extraPayments[18] = 2000
extraPayments[24] = 2200
extraPayments[40] = 3200
extraPayments[60] = 3500

#lumpsumPayments[36] = 10000
#lumpsumPayments[48] = 10000

# Calculations
monthlyRate = (6.5/100)/12.0
monthlyPayment = (monthlyRate /(1-((1+monthlyRate)**-(periods))))*balance
monthlyPayment = dollarRound(monthlyPayment)

# Output
puts "Mortgage Information:"
puts "Balance: $#{balance}"
puts "Years: #{periods/12} (#{periods} monthly periods)"
puts
puts "Monthly Payment: $#{monthlyPayment}"
puts "Amortization Schedule:"

lastPeriod = 0
currentExtraPayment = 0
periods.times do |period|
  break if balance < 0
  period += 1
  lastPeriod = period
  interestForMonth = dollarRound(balance * monthlyRate)
  principalForMonth = dollarRound(monthlyPayment - interestForMonth)
  
  # Calculate if there is an extra payment
  currentExtraPayment = extraPayments[period] if extraPayments[period]
  principalForMonth += currentExtraPayment
  
  lumpsumPayment = 0
  lumpsumPayment = lumpsumPayments[period] if lumpsumPayments[period]
  principalForMonth += lumpsumPayment
  
  totalPayment = dollarRound(monthlyPayment + currentExtraPayment + lumpsumPayment)
  
  # Reduce the balance by the principal paid and report
  balance = dollarRound(balance - principalForMonth)
  print "#{period} Pmt$#{totalPayment} I$#{interestForMonth} P$#{principalForMonth} B$#{balance}"
  if lumpsumPayment > 0 
    puts " LP$#{lumpsumPayment}"
  else
    puts
  end
end

if periods - lastPeriod > 0 
  puts
  puts "By paying:"
  extraPayments.each do |key, value|
    puts "\t$#{value} starting in month #{key}"
  end
  puts
  puts "You will shorten the life of your mortgage by #{periods - lastPeriod} months (#{(periods - lastPeriod)/12} years)"
  puts "New Loan Term #{lastPeriod} months (#{((lastPeriod/12.0)*10).round.to_f / 10} years)"
end
