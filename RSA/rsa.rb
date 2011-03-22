#!/usr/bin/env ruby
#
# Autor: Kamil Pluszczewicz
# Program implementujacy algorytm RSA

require 'optparse'
require 'ostruct'

class OptParser
	def self.parse(args)
		options = OpenStruct.new
		options.decode = options.encode = false

		opts = OptionParser.new do |opts|
			opts.banner = "Uzycie: rsa.rb [opcje]"
			
			opts.separator ""
			opts.separator "Dostepne opcje:"

			opts.on("-e","--encode", "Szyfruj przy uzyciu plikow klucza.") do
				options.encode = true
			end

			opts.on("-d","--decode", "Deszyfruj przy uzyciu plikow klucza.") do
				options.decode = true
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

if ARGV.length == 0 
	puts "Nie podano zadnych argumentow! Dodaj -h, aby zobaczyc pomoc"
end

options = OptParser.parse(ARGV)

crypt = options.decode || options.encode
if crypt
	if options.encode
		begin
			p_we = File.open("plain.txt", "r")
			p_key = File.open("public.txt", "r")
		rescue
			puts "Wystapil blad z plikem: #{$!}"
			exit
		end
		p_wy = File.open("crypto.txt", "w")
	elsif options.decode
		begin
			p_we = File.open("crypto.txt", "r")
			p_key = File.open("private.txt", "r")
		rescue
			puts "Wystapil blad z plikem: #{$!}"
			exit
		end
		p_wy = File.open("plain.txt", "w")
	end
	text_in = p_we.read()
	text_in = text_in[0,text_in.size-1]
	keys = p_key.readlines("\n")
	n_key = keys[0].to_i(16)
	ed_key = keys[1].to_i(16)

	text = ""	
	text_in.each_byte { |s| 
		temp = s.to_s(16)
		temp = "0" + temp if temp.size == 1 
		text += temp
	}

	m = text.to_i(16)

	coded = fastPow(m, ed_key, n_key)
	coded = coded.to_s(16)
	for i in 0..(coded.size/2 )
		temp = coded[i*2, 2].to_i(16).chr
		p_wy.print(temp)
	end

	p_we.close
	p_key.close
	p_wy.close
end
