#!/usr/bin/env ruby

# Autor: Kamil Pluszczewicz, data ukonczenia 21 stycznia 2010
# Program realizujacy kryptosystem ElGamala

require 'optparse'
require 'ostruct'

# Minimalna dlugosc liczby p (ilosc bitow)
N = 300

# nazwy plikow
F_PUB = "public.txt"
F_PRV = "private.txt"
F_NUM = "elgamal.txt"
F_MES = "message.txt"
F_CRY = "crypto.txt"
F_SIG = "signature.txt"

class OptParser
	def self.parse(args)
		options = OpenStruct.new
		options.verbose = 0

		opts = OptionParser.new do |opts|
			opts.banner = "Uzycie: rabinmiller.rb [opcje]"
			
			opts.separator ""
			opts.separator "Dostepne opcje:"

			opts.on("-g", "Generuje liczbe pierwsza p, generator g ") do 
				options.g = true
			end

			opts.on("-k", "Generuje pare kluczy") do
				options.k = true
			end

			opts.on("-e", "Szyfruje wiadomosc") do
				options.e = true
			end

			opts.on("-d", "Deszyfruje kryptogram") do
				options.d = true
			end
			
			opts.on("-s", "Produkuje podpis") do
				options.s = true
			end

			opts.on("-v", "Weryfikuje podpis pod wiadomoscia") do
				options.v = true
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


def fastPow(x,n,m=0) 
	r = 1
	b = x
	while n != 0
		if(n%2 == 1) 
			n -= 1
			r = (r*b) % m if m != 0
			r = (r*b) if m == 0
		else
			n = n / 2
			b = b*b % m if m != 0
			b = b*b if m == 0
		end
	end
	return r
end

def millerRabin(n,k)
	liczby = Array.new()
	d = n - 1
	s = 0

	while (d % 2) == 0
		s += 1
		d /= 2
	end

	k.times do |i|
		begin a = 2 + rand(n-2) end while liczby.index(a)

		liczby.push(a)
		x = fastPow(a,d,n)
		next if x == 1 or x == n - 1 
		for r in 1..s
			x0 = x*x % n
			if x0 == 1 and x != 1 and x != n - 1
				return "zlozona"
			end
			x = x0
		end
		return "zlozona" if x != 1
	end
	return "pierwsza"
end

def nwd(a,b)
	while b != 0
		c = a % b
		a = b
		b = c

	end
	return a
end

def elOdwr(a,n)
	p0, p1, a0, n0 = 0, 1, a, n
	q = n0 / a0
	r = n0 % a0
	while (r > 0)
		t = p0 - q*p1
		if ( t >- 0)
			t = t % n
		else
			t = n - ((-t) % n)
		end
		p0, p1 = p1,t
		n0, a0 = a0, r
		q = n0 / a0
		r = n0 % a0
	end
	return p1
end

def losujBity(n)
	temp = "1"
	(n-1).times { temp += rand(2).to_s }
	return temp.to_i(2)
end

def czytajKluczPubliczny
	begin
	f_pub = File.open(F_PUB, "r")
	p = f_pub.readline.to_i
	g = f_pub.readline.to_i
	beta = f_pub.readline.to_i
	rescue SystemCallError
		puts "Wystapil blad: #{$!}"
		exit
	end
	if p == 0 or g == 0 or beta == 0
		puts "Wystapil blad z liczbami w pliku #{F_NUM}. Prosze sprawdzic, czy jest poprawnie sformatowany"
	end
	f_pub.close
	return p,g,beta
end

def czytajKluczPrywatny
	begin
	f_prv = File.open(F_PRV, "r")
	rescue SystemCallError
		puts "Blad WE/WY: #{$!}"
		exit
	end

	# liczby z klucza prywatnego
	p = f_prv.readline.to_i
	g = f_prv.readline.to_i
	beta = f_prv.readline.to_i
	k = f_prv.readline.to_i
	f_prv.close
	return p,g,beta,k
end
def czytajWiadomosc
	begin
	f_mes = File.open(F_MES, "r")
	rescue SystemCallError
		puts "Blad WE/WY: #{$!}"
		exit
	end

	# w - wiadomosc
	w = f_mes.readlines("").join
	# usuniecie \n z konca
	w.chomp!  

	s = ""
	w.each_byte { |c|
		s += c.to_s(16)
	}
	m = s.to_i(16)

	f_mes.close
	return m
end

def czytajPodpis
	begin
		f_sig = File.open(F_SIG, "r")
	rescue SystemCallError
		puts "Blad WE/WY: #{$!}"
		exit
	end
	r = f_sig.readline.to_i
	x = f_sig.readline.to_i

	f_sig.close
	return r,x
end

options = OptParser.parse(ARGV)

if options.g
	#Generuje losowe p
	p = losujBity(N)
	p += 1 if p % 2 == 0 

	#Dodaje, az znajde pierwsza
	p += 2 while millerRabin(p, 40) == "zlozona" 

	while true do
		g = rand(p)
		i = 2
		while i <= 1000 do
			if p-1 % i == 0
				break if fastPow(g,(p-1)/i) == 1
			end
			i += 1
		end
		break if i == 1001
	end
	f = File.new(F_NUM, "w")
	f.puts p, g
	f.close
end

if options.k
	begin
	f_pg = File.open(F_NUM, "r")
	p = f_pg.readline.to_i
	g = f_pg.readline.to_i
	rescue SystemCallError 
		puts "Plik o nazwie #{F_NUM} nie isnieje!"
		exit
	end
	if p == 0 or g == 0
		puts "Wystapil blad z liczbami w pliku #{F_NUM}. Prosze sprawdzic, czy jest poprawnie sformatowany"
	end

	k = rand(p)
	beta = fastPow(g, k, p)
	f_pub = File.open(F_PUB, "w")
	f_prv = File.open(F_PRV, "w")
	f_pub.puts p, g, beta
	f_prv.puts p, g, beta, k
	f_pub.close
	f_prv.close
end

if options.e
	p,g,beta = czytajKluczPubliczny()	
	m = czytajWiadomosc()
	if m > p
		puts "Wiadomosc jest zbyt dluga"
		exit
	end

	x = rand(p)

	m = czytajWiadomosc()

	crypto = Array.new
	crypto.push  fastPow(g,x,p)
	crypto.push m*fastPow(beta,x,p)

	f_cry = File.open(F_CRY, "w")
	f_cry.puts crypto[0]
	f_cry.puts crypto[1]
	f_cry.close
end

if options.d
	f_cry = File.open(F_CRY, "r")
	p,g,beta,k = czytajKluczPrywatny()
	# kryptogram
	g_x = f_cry.readline.to_i
	mxbx = f_cry.readline.to_i

	# zamykamy pliki
	f_cry.close

	if p & g & beta & k == 0
		puts "Wystapil blad z kluczem prywatnym"
	end

	# deszyfrowanie
	
	beta_x = fastPow(g_x, k, p) # SPRAWDZ, CZY na pewno mod p!!!!

	gamma = elOdwr(beta_x, p)
	result = (mxbx * gamma) % p

	coded = result.to_s(16)

	f_mes = File.open(F_MES, "w")

	for i in 0..(coded.size / 2 -1)
		temp = coded[i*2, 2].to_i(16).chr
		f_mes.print temp
	end

	f_mes.close
end

# Podpis cyfrowy
if options.s
	p,g,beta,a = czytajKluczPrywatny()
	m = czytajWiadomosc()
	
	k = rand(p-1)
	k = rand(p-1) while nwd(k,p-1) != 1	
	r = fastPow(g,k,p)
	z = (m % (p-1)) - (a*r % (p-1))
	z += p-1 while z < 0
	x = z*elOdwr(k, p-1) % (p-1)

	f_sig = File.new(F_SIG, "w")
	f_sig.puts r,x
	f_sig.close
		
end

# Weryfikacja podpisu
if options.v
	p,g,beta = czytajKluczPubliczny()
	m = czytajWiadomosc()

	r,x = czytajPodpis()
	m = czytajWiadomosc()

	a = fastPow(g,m,p)
	b = fastPow(r,x,p)*fastPow(beta,r,p) % p
	if  a == b
		puts "Podpis pod wiadomoscia zapisana w pliku message.txt jest poprawny"
	else
		puts "Podpis jest niepoprawny!"
	end
end

