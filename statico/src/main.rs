use comrak::{markdown_to_html, ComrakOptions};
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
            println!("Created output directory!");
        }
        Err(e) => {
            eprintln!("failed to create directory: {}, {}", out_directory, e);
            process::exit(1);
        }
    }

    for file in files {
        process_file(file.clone(), &out_directory).unwrap();
    }
}

fn files_to_process(path: String) -> Vec<String> {
    let mut files: Vec<String> = Vec::new();
    for file in fs::read_dir(path).unwrap() {
        files.push(file.unwrap().path().display().to_string());
    }
    return files;
}

fn process_file(path: String, out_directory: &str) -> std::io::Result<()> {
    let contents = fs::read_to_string(&path).expect("Something went wrong reading the file");

    let mut filename = PathBuf::from(Path::new(&path).file_name().unwrap());
    filename.set_extension("html");

    let filename_as_string: &str = &filename.to_string_lossy();

    let outfile_path = Path::new(out_directory).join(filename_as_string);

    let mut f = File::create(outfile_path).expect("Failed to create the output file");

    f.write_all(markdown_to_html(&contents, &ComrakOptions::default()).as_bytes())?;

    f.sync_data()?;

    Ok(())
}
