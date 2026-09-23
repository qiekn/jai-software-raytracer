#run {
    w := compiler_create_workspace("Jail");
    if !w {
        write_string("The world is not ready for jai!\n");
        return;
    }

    options := get_build_options(w);

    options.output_executable_name = "renderer";
    options.output_path = "bin";
    if !make_directory_if_it_does_not_exist(options.output_path) {
        log(tprint("Could not create output directory %.", options.output_path));
        return;
    }

    set_build_options(options, w);

    add_build_file("src/main.jai", w);

    set_build_options_dc(.{do_output=false});
}

#import "Compiler";
#import "Basic";
#import "File";
