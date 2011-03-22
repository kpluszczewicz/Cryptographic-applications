#!/usr/bin/env ruby

# Autor: Kamil Pluszczewicz
# Program do testowania pierwszosci liczb pierwszych

require 'optparse'
require 'ostruct'

PLIK_WE='wejscie.txt'
PLIK_WY='wyjscie.txt'

class OptParser
	def self.parse(args)
		options = OpenStruct.new
		options.fermat = false
		options.verbose = 0

		opts = OptionParser.new do |opts|
			opts.banner = "Uzycie: rabinmiller.rb [opcje]"
			
			opts.separator ""
			opts.separator "Dostepne opcje:"

			opts.on("-f","--fermat", "Wykonaj tylko test fermata") do
				options.fermat = true
			end

			opts.on("-v", "--verbose", "Tryb gadatliwy, +1 na kazde -v") do
				options.verbose += 1
			end

			opts.on_tail("-h", "--help", "Pokazuje pomoc") do
				puts opts
				exit
			end
		end
		begin
			opts.parse!(args)
		rescue OptionParser::InvalidOption
			puts "Podano nieprawidlowa opcje: #{$!}"
			puts "Podaj -h aby zobaczyc liste opcji."
			exit
		end
		options
	end

end

class FileParser
	def self.parse(path, mode, pattern, length=0)
		if !File.exists? path 
			puts "Nie mozna otworzyc pliku '#{PLIK_WE}'! Sprawdz czy istnieje."
			exit
		end
		plik = File.open(path, mode)
		linie = plik.readlines("\n").each { |str|
			if !str.strip!.match(pattern)
				puts "Plik wejsciowy jest zle sformatowany"
				exit
			end
		}
		
		puts "Plik zawiera wiecej linii niz jest to przewidziane. Nadmiarowe linie zostana zignorowane" if linie.size > length
		plik.close
		return linie
	end
end

def fastPow(x,n,m) 
	r = 1
	b = x
	while n != 0
		if(n%2 == 1) 
			n -= 1
			r = (r*b) % m
		else
			n = n / 2
			b = b*b % m
		end
	end
	return r
end

def millerRabin(n,k,opts,v=nil)
	ver = opts.verbose
	fer = opts.fermat
	puts "Test zostanie wykonany dla liczby #{n}" if ver > 1

	liczby = Array.new()

	if opts.wyk 
		d = v
		puts "Uzywam wykladnika uniwersalnego v=#{v}" if ver > 0
	else 
		d = n - 1
	end

	s = 0
	while (d % 2) == 0
		s += 1
		d /= 2
	end
	puts "d = #{d}, s = #{s}" if ver == 2

	k.times do |i|
		puts "--- #{i}" if ver == 2

		begin a = 2 + rand(n-2) end while liczby.index(a)

		liczby.push(a)
		puts "a = #{a}" if ver == 2
		x = fastPow(a,d,n)
		puts "x = #{x}" if ver == 2
		next if x == 1 or x == n - 1 
		for r in 1..s
			x0 = x*x % n
			if fer != true and x0 == 1 and x != 1 and x != n - 1
				return n.gcd(x-1)
			end
			x = x0
		end
		return "na pewno zlozona" if x != 1
	end
	return "prawdopodobnie pierwsza"
end

options = OptParser.parse(ARGV)

if options.verbose == 1
	puts "Wlaczono tryb gadatliwy"
elsif options.verbose == 2
	puts "Wlaczono tryb bardzo gadatliwy"
	puts "Dzien dobry. Jestem programem i milo mi Ciebie poznac.\nJest godzina #{Time.now.hour}:#{Time.now.min} i razem sprobujemy rozwiazac problem na zajecia z podstaw kryptografii. Usiadz wygodnie i zrelaksuj sie."
end

puts "Wybrano wykonywanie tylko testu Fermata" if options.fermat and options.verbose > 0

linie = FileParser.parse(PLIK_WE, "r", /[0-9]+$/, 3)
puts "\nPRZEBIEG ALGORYTMU:" if options.verbose > 1
if linie.length == 1
	options.wyk = false
	wynik = millerRabin(linie[0].to_i,40,options)
elsif linie.length == 2
	options.wyk = true
	wyk = linie[1].to_i
	wynik = millerRabin(linie[0].to_i,40,options,wyk)
elsif linie.length == 3
	options.wyk = true
	wyk = linie[1].to_i * linie[2].to_i - 1
	wynik = millerRabin(linie[0].to_i,40,options,wyk)
end
puts "\nWYNIK TESTU:" if options.verbose > 0
puts "Wynik testu: #{wynik}" if options.verbose > 0
puts "Wynik testu zapisano do pliku '#{PLIK_WY}'" if options.verbose > 1
f_wy = File.new(PLIK_WY, "w")
f_wy.puts wynik
f_wy.close

