use comrak::{markdown_to_html, ComrakOptions};
use handlebars::Handlebars;
use serde_json::json;
use std::env;
use std::fs;
use std::fs::File;
use std::io::prelude::*;
use std::path::Path;
use std::path::PathBuf;
use std::process;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 3 {
        eprintln!("[builder] Error: pass in the in and out directories to start.");
        process::exit(1);
    }

    let in_directory = args[1].clone();
    let out_directory = args[2].clone();

    let files: Vec<String> = files_to_process(in_directory);

    match fs::create_dir_all(out_directory.clone()) {
        Ok(()) => {
            println!("created output directory!");
        }
        Err(e) => {
            eprintln!("failed to create directory: {}, {}", out_directory, e);
            process::exit(1);
        }
    }

    let tmpls = read_templates("./templates".to_string());

    for file in files {
        process_file(file.clone(), &out_directory, &tmpls).unwrap();
    }
}

fn read_templates<'reg>(path: String) -> Handlebars<'reg> {
    let mut reg = Handlebars::new();

    let page_template = Path::new(&path).join("page.handlebars".clone());

    for file in fs::read_dir(path).unwrap() {
        if file.as_ref().unwrap().path() == page_template {
            let contents = fs::read_to_string(file.as_ref().unwrap().path());
            reg.register_template_string("page_tpl", contents.as_ref().unwrap())
                .unwrap();
        }
    }

    return reg;
}

fn files_to_process(path: String) -> Vec<String> {
    let mut files: Vec<String> = Vec::new();
    for file in fs::read_dir(path).unwrap() {
        files.push(file.unwrap().path().display().to_string());
    }
    return files;
}

fn process_file(path: String, out_directory: &str, tmpls: &Handlebars) -> std::io::Result<()> {
    let contents = fs::read_to_string(&path).expect("Something went wrong reading the file");

    let mut filename = PathBuf::from(Path::new(&path).file_name().unwrap());
    filename.set_extension("html");

    let filename_as_string: &str = &filename.to_string_lossy();

    let outfile_path = Path::new(out_directory).join(filename_as_string);

    let mut f = File::create(outfile_path).expect("Failed to create the output file");

    let mut options = ComrakOptions::default();
    
    options.extension.strikethrough=true;
    options.extension.tagfilter=true;
    options.extension.table=true;
    options.extension.autolink=true;
    options.extension.tasklist=true;
    options.extension.superscript=true;
    options.extension.footnotes=true;


    let mut processed_content = markdown_to_html(&contents, &options);
    processed_content = tmpls
        .render(
            "page_tpl",
            &json!({"content":processed_content.to_string()}),
        )
        .unwrap();

    f.write_all(processed_content.as_bytes())?;

    f.sync_data()?;

    Ok(())
}
