module keyvault

import os
import json
import krypty

const(
    hash_salt = 'keylet_HF*g#3%&8n4n"NQ))6ff8nd5a_keylet'
)

struct Entry {
pub:
    tag string = ''
    usr string = ''
    eml string = ''
    pss string = ''
}

pub struct KeyFile {
pub mut:
    path string
    data []Entry
}

// Initialize a brand new KeyFile
pub fn new_keyfile(path string) KeyFile {
    return KeyFile {
        path: path,
        data: []Entry{}
    }
}

pub fn new_entry(tag string, usr string, eml string, pss string) Entry {
    return Entry{tag:tag, usr:usr, eml:eml, pss:pss}
}

pub fn encode(entries []Entry) string {
    mut data := ''
    for i, entry in entries {
        data += json.encode(entry)
        if i < entries.len-1 { data += '\n' }
    }
    return data
}

pub fn decode(data string) []Entry {
    mut entry_list := []Entry{}
    for line in data.split('\n') {
        if line != '' {
            temp := json.decode(Entry, line) or {
                eprintln('Error decoding vault.') // TODO: Change Error Handling
                return entry_list
            }
            entry_list << temp
        }
    }
    return entry_list
}

pub fn (entry Entry) to_array() []string {
    return [entry.tag, entry.usr, entry.eml, entry.pss]
}

pub fn (kf KeyFile) to_array() [][]string {
    mut arr := [][]string{}
    for i in kf.data {
        arr << i.to_array()
    }
    return arr
}

// find_index Find an entry by its TAG(string)
pub fn (kf KeyFile) find_index(tag string) int { // [SLOW] [UNAWARE OF PRE-EXISTING FUNCTION]
    for i, entry in kf.data {
        if entry.tag == tag { return i }
    }
    return -1
}

pub fn (mut kf KeyFile) load(password string) bool {
    data := os.read_bytes(kf.path) or {
        eprintln('Error loading vault.') // TODO: Change Error Handling
        return false
    }
    
    if data.len < 1 {
        eprintln('Error reading vault.') // TODO: Change Error Handling
        return false
    }

    phash := data[..32] // Extract Password Hash
    
    // Verify Password
    if krypty.hash(hash_salt.bytes(), password.bytes()).bytes() == phash {

        // Decrypt Data
        plain_text := krypty.decrypt(data[48..], password.bytes())
        //println(plain_text.str())
        
        // Decode Plain Text
        kf.data = decode(krypty.bytes_to_str(plain_text))

    }else{
        println('Invalid Password...')
        return false
    }
    return true
}

pub fn (kf KeyFile) save(password string) bool {

    data := encode(kf.data).bytes()

    iv_key := krypty.string_generate(16).bytes() // ;)
    phash := krypty.hash(hash_salt.bytes(), password.bytes()).bytes()
    
    cipher_text := krypty.encrypt(data, iv_key, password.bytes(), 32)

    mut save_data := phash
    save_data << iv_key
    save_data << cipher_text

    os.write_file(kf.path, krypty.bytes_to_str(save_data)) or {
        return false
    }
    return true

}







