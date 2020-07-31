module krypty

import strings
import time
import crypto.md5
import crypto.aes
import crypto.rand as rng
import rand

const (
	captial_letters = 'ABCDEFGHIJLMNOPQURSTUVWXYZ'
	lowercase_letters = 'abcdefghijklmnopqurstuwxyz'
	numbers = '0123456789'
	symbols = '!@#$%^&*()_+=|/\:<>{}[]-`,.?'
	max_steps = 64 // 8, 16, 32
)

// hash Returns a salted md5 string in hex encoding
pub fn hash(salt []byte, value []byte) string {
    mut out := salt
    out << value
    return md5.sum(out).hex()
}

pub fn super_seed() {
	unsafe { // Not sure about this...
		rand.seed([u32(time.now().unix), 0]) // Initial Standard Seed
		mut steps := u64(max_steps / 2) // Default 
		steps = rng.int_u64(u64(max_steps)) or { // ^^ Hence Default ^^^
			u64(max_steps / 2) 
		}
		// Seed Steps
		for _ in 0..u32(steps) {
			new_seed := rng.int_u64(2147483647) or {
				rand.seed([u32(time.now().unix), 0]) // Fallback Seed
				continue
			}
			rand.seed([u32(new_seed), 0]) // Step Seed
		}
	}
}

pub fn super_rand(max int) int {
	mut tmp := u64(0)
	tmp = rng.int_u64(u64(max)) or {
		u64(rand.intn(max))
	}
	return int(tmp)
}

// string_letters Returns a random string of n length containing only lower-case letters
pub fn string_letters(n int) string {
	letters := lowercase_letters.split('')
    mut str := []string{}
    super_seed()
	for _ in 0..n {
		str << letters[rand.intn(letters.len)]
	}
	return str.join('')
}

// string_letters Returns a random string of n length containing only lower-case letters
pub fn string_letters_case(n int) string {
    table := captial_letters + lowercase_letters
	letters := table.split('')
    mut str := []string{}
    super_seed()
	for _ in 0..n {
		str << letters[rand.intn(letters.len)]
	}
	return str.join('')
}

// string_numerical Returns a random string of only numerical digits with length n
pub fn string_numerical(n int) string {
	digits := numbers.split('')
    mut str := []string{}
    super_seed()
	for _ in 0..n {
		str << digits[rand.intn(digits.len)]
	}
	return str.join('')
}

// string_generate Returns random string of n length containing all symbols/letters/nums
pub fn string_generate(n int) string {
    table := captial_letters + lowercase_letters + numbers + symbols
	characters := table.split('')
    mut str := []string{}
    super_seed()
	for _ in 0..n {
		str << characters[rand.intn(characters.len)]
	}
	return str.join('')
}

// bytes_padding Ensure an array of bytes is of the correct size for block-based operations using dummy bytes
pub fn bytes_padding(padding_value byte, arr []byte, max int) []byte {
    r := arr.len % max
    mut new_arr := arr
	if r > 0 {
		new_arr << []byte{init:padding_value, len:max-r}
	}
    return new_arr
}

// bytes_to_str Converts an array of bytes to a standard string
pub fn bytes_to_str(arr []byte) string {
    mut s := strings.new_builder(arr.len)
    for chr in arr { s.write_b(chr) }
    return s.str()
}

// encrypt Convenient AES-256 helper function. It handles the key, iv, padding, and of course encryption of all blocks.
pub fn encrypt(data []byte, iv []byte, key []byte, padding_value byte) []byte {

    mut cipher_text := data
    cipher_text = bytes_padding(padding_value, cipher_text, aes.block_size)

    mut key_value := key
    hexxy := md5.sum(key).hex()
    key_value << hexxy[..32-key.len].bytes()

    crypt := aes.new_cipher(key_value)
    mode := aes.new_cbc(crypt, iv)
    mode.encrypt_blocks(mut cipher_text, cipher_text)
    
    mut result := iv
    result << cipher_text

    return result
}

// decrypt Convenient AES-256 helper function. It handles the key, retreival of iv, and of course decryption of all blocks.
pub fn decrypt(data []byte, key []byte) []byte {

    iv := data[..aes.block_size]
    cipher_text := data[aes.block_size..]
    
    mut key_value := key
    hexxy := md5.sum(key).hex()
    key_value << hexxy[..32-key.len].bytes()

    crypt := aes.new_cipher(key_value)
    mut mode := aes.new_cbc(crypt, iv)
    mode.decrypt_blocks(mut cipher_text, cipher_text)

    return cipher_text
}
