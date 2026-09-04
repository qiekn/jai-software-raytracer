#import "Compiler";

#run {
    w := compiler_create_workspace("Builder");
    if !w {
        write_string("Failed to create workspace!\n");
        return;
    }

    options := get_build_options(w);
    options.output_executable_name = "renderer";
    set_build_options(options, w);

    add_build_file("src/main.jai", w);

    set_build_options_dc(.{do_output=false});
}
