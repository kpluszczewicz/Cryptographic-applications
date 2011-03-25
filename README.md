# Cryptographic applications
Copyright (C) 2011 by Kamil Pluszczewicz

This repository contains few applications that implements some cryptographic algorithms. They're written mostly in ruby, but there is also c program.

## RSA
[link to wiki](http://en.wikipedia.org/wiki/RSA)

This program contains two subprograms: keygen.rb and rsa.rb. Keygen aims at generating key pair: public and private. It's based on finding two prime numbers, that are enough big. Keys are computed from those numbers and saved in files public.txt and private.txt. keygen.rb is called without params:
	
	ruby keygen.rb

Next file, rsa.rb, performs standard steps to encode and decode piece of information. Text to encode is stored in file called plain.txt, encoded ciphertext is saved in crypto.txt. App is executed with following paramters:
	
	-e, --encode	Encode with key files
	-d, --decode	Decode with key files
	-v, --verbose	(No comment)
	-h, --help
	
## El Gamal
[link to wiki](http://en.wikipedia.org/wiki/ElGamal_encryption)

This program implemented ElGamal encryption system. It has following parameters:

	-g	generates prime number p, and generator g (see wiki)
	-k	generates key pair
	-e	encodes plain message
	-d	decodes ciphertext
	-s	produces signature
	-v	verifies signature
	-h	show help

## Miller-Rabin primality test
[link to wiki](http://en.wikipedia.org/wiki/Miller–Rabin_primality_test)

Another program, called rabinmiller.rb, verifies if given number is prime. It's probablistic test, but mistakes are very improbable. Program has following parameters:

	-f	verify a number using only Fermat test
	-v	be verbose
	-h	help

Number to check it's primality is stored in file wejscie.txt (polish word for input.txt), and result is saved in wyjscie.txt (output.txt). Output can be one of messages: "the number is composite for sure", "probably prime".

## Enigma
[link to wiki](http://en.wikipedia.org/wiki/Enigma_machine)

This one is written in c. It acts as Enigma machine used by Nazists during world war II. To me as a Polish, it's important fact, that polishs mathematicians were those who break the enigma.

	-p	clean input from bad characters
	-e 	encode
	-d	decode	
	-a	prepare premutations
	-k	cryptoanalysis based on ciphertext
	-g	generate 100 random ciphertext with session keys

## Vigenere
[link to wiki](http://en.wikipedia.org/wiki/Vigenère_cipher)

This one is also in c. 

	-e	encode
	-d	decode
	-k	cryptoanalysis based on ciphertext


# License
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
