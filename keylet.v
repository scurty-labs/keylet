module main

import os
import cli
import vtable as tbl
import krypty
import keyvault as kv

/* TODO:

[x] Implement `init` command.
[x] Seed Rand IV in `krypty` (seed(unix.time) ; seed(rand.int(MAX(int))))
[] Terminal Color/Translation Support?

-------------------------------------*/

const (

    app_title = 'Keylet'
    app_version = '0.2.7'        

    // ---

	keyfile_name = '_keylet_vault_'
    table_header = ['TAG','EMAIL','USERNAME','PASSWORD']
)

fn get_password() string {
    return os.input('Enter $app_title Password: ')
}

fn yes_or_no(question string) bool {
    answer := os.input(question + ' [y/n]: ')    
    if answer.to_lower() == 'y' { return true }
    return false
}

fn confirm_override() bool {
    return yes_or_no('Are you sure you want to override your $app_title vault?')
}

fn export_func(cmd cli.Command) {

    input := get_password()
    mut vault := kv.new_keyfile(keyfile_name)
    if vault.load(input) {
        
        path := os.input('Export Path: ')
        data := kv.encode(vault.data)
        os.write_file(path, data) or {
            eprintln('Could not export $app_title vault... Aborting.')
            return
        }
    
        println('$app_title vault exported to `$path`')

    }

}

fn import_func(cmd cli.Command) {

    input := get_password()
    mut vault := kv.new_keyfile(keyfile_name)
    if vault.load(input) {
        if confirm_override() {

            path := os.input('Import Path: ')
            if os.exists(path) {
                file_data := os.read_file(path) or {
                    eprintln('Cannot read file: $path')
                    return
                }
                vault.data = kv.decode(file_data)
                
                p1 := os.input('New Password: ')
                p2 := os.input('Confirm New Password: ')
                
                if p1 == p2 { // Check if new passwords match

                    vault.save(p1)
                    println('$app_title vault imported from `$path`')

                }else{
                    println('Passwords do not match.')
                }
            }
        }
    }
    
}

fn list_func(cmd cli.Command) {

    find := cmd.flags.get_string('find') or { '' }
    input := get_password()
    mut vault := kv.new_keyfile(keyfile_name)

    if vault.load(input) {

        mut data := [][]string{}
        data << table_header

        if find.len < 1 {
            data << vault.to_array()
        }else{
        	for i, entry in vault.data {
        		if entry.tag.contains(find) {
            		data << vault.data[i].to_array()
            	}
            }   
            if data.len < 1 {
                println('Cannot find matching entry tag: `$find`')   
                return 
            }
        }

        // Compile and display table
        t := tbl.Table {
            data: data,
            justify: .left,
            simple: false,
            row_char: '-',
            col_char: ' ',
            corner_char: ' '
        }

        t.print()

    }else{ println('Cannot load $app_title vault. Aborting.') }
    
}

// Adding to the vault
fn add_func(cmd cli.Command) {

    input := get_password()
    mut vault := kv.new_keyfile(keyfile_name)

    if vault.load(input) {

        tag := os.input('Tag: ')
        email := os.input('Email: ')
        uname := os.input('Username: ')
        p1 := os.input('Password: ')
        p2 := os.input('Confirm Password: ')
        
        if p1 == p2 { // Check if passwords match

            vault.data << kv.new_entry(tag, email, uname, p1)
            vault.save(input)

            println('Added: $tag')
            
        }else{ println('Passwords do not match.') }

    }else{ println('Cannot load $app_title vault. Aborting.') }
}

fn addg_func(cmd cli.Command) { // MELODY, G-FUNK, WHERE RHYTHM IS LIFE 

    input := get_password()
    mut vault := kv.new_keyfile(keyfile_name)

    if vault.load(input) {

        tag := os.input('Tag: ')
        email := os.input('Email: ')
        uname := os.input('Username: ')

        password := krypty.string_generate(32)

        vault.data << kv.new_entry(tag, email, uname, password)
        vault.save(input)

        println('Added: `$tag`\nGenerated Password: $password')

    }else{ println('Cannot load $app_title vault. Aborting.') }
}

fn del_func(cmd cli.Command) {

    input := get_password()
    mut vault := kv.new_keyfile(keyfile_name)
    if vault.load(input) {
		
        tag := os.input('Enter the entry to delete: ')
        index := vault.find_index(tag)
        if index > -1 {
            entry := vault.data[index]
            vault.data.delete(index)
            vault.save(input)
            println('Entry `$entry.tag` has been deleted.')
        }else{
            println('Cannot find entry: `$tag`')
        }
    }
}

fn create_new_vault() bool {
	mut vault := kv.new_keyfile(keyfile_name)
	p1 := os.input('New $app_title vault Password: ')
    p2 := os.input('Confirm new $app_title vault Password: ')
    if p1 == p2 {
    	vault.data << kv.new_entry('$app_title Vault','','','$p1')
    	vault.save(p1)
    	return true
    }else{
    	println('Passwords do not match.')
    }
    return false
}


fn init_func(cmd cli.Command) {

	if os.exists(keyfile_name) {
		println('A $app_title vault already exists!')
		if confirm_override() {
			if yes_or_no('Last confirmation before erasure. *Are you really sure?*') {
			
				mut vault := kv.new_keyfile(keyfile_name)
				input := os.input('Verifying current $app_title vault Password: ')
				
				if !vault.load(input) {
					println('Aborting overwrite.')
					return
				}
				
			}else{
				println('Aborting overwrite.')
				return
			}
		}else{
			println('Aborting overwrite.')
			return
		}
	}

	println('Initializing new $app_title vault...')
	if create_new_vault() {
		println('Initializing new $app_title vault...')
	}else{
		println('Could not initialize new vault.')
	}
}

fn main() {

    mut cmd := cli.Command {
		name: app_title.to_lower(),
		description: 'A safe and simple offline password manager.',
		version: app_version,
	}
	
    // -------
    
    mut init_cmd := cli.Command {
		name: 'init',
		description: 'Initializes a new $app_title vault.',
		execute: init_func,
	}

    mut list_cmd := cli.Command {
		name: 'list',
		description: 'Lists all your saved passwords.',
		execute: list_func,
	}
    list_cmd.add_flag(cli.Flag{
		flag: .string,
		required: false,
		name: 'find',
		abbrev: 'f',
		description: 'Finds an entry by a given Tag.'
	})
    
    mut add_cmd := cli.Command {
		name: 'add',
		description: 'Adds a new entry.',
		execute: add_func,
	}
    
    mut addg_cmd := cli.Command {
		name: 'addg',
		description: 'Adds a new entry with a randomly generated password.'
		execute: addg_func,
	}

    mut del_cmd := cli.Command {
		name: 'del',
		description: 'Deletes an existing entry by Tag.',
		execute: del_func,
	}
    
    mut export_cmd := cli.Command {
		name: 'export',
		description: 'Exports a human readable $app_title vault for transfer. ',
		execute: export_func,
	}

    mut import_cmd := cli.Command {
		name: 'import',
		description: 'Imports a human readable $app_title vault and encrypts it with a new password.',
		execute: import_func,
	}

    
    cmd.add_command(init_cmd)
    cmd.add_command(list_cmd)
    cmd.add_command(add_cmd)
    cmd.add_command(addg_cmd)
    cmd.add_command(del_cmd)
    cmd.add_command(export_cmd)
    cmd.add_command(import_cmd)
    cmd.parse(os.args)

}
