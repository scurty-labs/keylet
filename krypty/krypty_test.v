import krypty 

fn test_krypty() {

	rand.seed([u32(time.now().unix), 0])

    // Testing...
    println(krypty.hash('13452345645'.bytes(), 'asdfdrthrtrn'.bytes()))
    println(krypty.string_letters(32))
    println(krypty.string_letters_case(32))
    println(krypty.string_numerical(32))
    println(krypty.string_generate(32))

    mut my_text := 'Hello world! This is an encrypted message! ;)'.bytes()

    iv := 'asdfasdfasdfasdf'.bytes()
    key := 'asdfasdfasdfasdfasdfasdfasdfasd'.bytes() // Note: `Key` gets overwritten for some reason
    key2 := 'asdfasdfasdfasdfasdfasdfasdfasd'.bytes()

    new_text := krypty.encrypt(my_text, iv, key, 32)
    println(new_text.str())
    println(krypty.bytes_to_str(krypty.decrypt(new_text, key2)))    

}
