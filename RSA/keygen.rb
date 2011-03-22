#!/usr/bin/env ruby

# Autor: Kamil Pluszczewicz, 07.01.2010
# Program do generowania par kluczy RSA

require 'optparse'
require 'ostruct'

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
			return "zlozona" if x0 == 1 and x != 1 and x != n - 1
			x = x0
		end
		return "zlozona" if x != 1
	end
	return "pierwsza" 
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

def nwd(a,b)
	while b != 0
		c = a % b
		a = b
		b = c

	end
	return a
end

def losujBity(n)
	temp = "1"
	(n-1).times { temp += rand(2).to_s }
	return temp.to_i(2)
end

#Generuje losowe p
p = losujBity(600)
p += 1 if p % 2 == 0 

#Dodaje, az znajde pierwsza
p += 2 while millerRabin(p, 40) == "zlozona" 

#Generuje losowe q
q = losujBity(600)
q += 1 if q % 2 == 0 

#Dodaje, az znajde pierwsza
q += 2 while millerRabin(q, 40) == "zlozona"

n = p * q
fi = (p-1)*(q-1)

d = losujBity(600)
d += 1 while nwd(d,fi) != 1
e = elOdwr(d,fi)

plik_priv = File.new("private.txt", "w")
plik_publ = File.new("public.txt", "w")

plik_priv.puts(n.to_s(16), d.to_s(16))
plik_publ.puts(n.to_s(16), e.to_s(16))

plik_priv.close()
plik_publ.close()
