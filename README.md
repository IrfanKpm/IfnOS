# IfnOS

An experimental operating system project aimed at learning OS development, starting from low-level assembly and C programming. The goal is to build a complete OS over time—including bootloader, kernel, and drivers—while exploring core OS concepts and system programming.

## Build & Run

- Use the provided `Makefile` to build the project by running `make`.
- The compiled bootloader binary is placed in the `bin/` directory.
- The final floppy disk image is created in the `build/` directory as `floppy.img`.
- Run the OS in QEMU with `make run`, which boots the floppy image and redirects serial output to your terminal.
- Clean build artifacts using `make clean`.

## Notes

- Only source files and build scripts are tracked in Git.
- Build artifacts like `build/` and `bin/` directories are ignored using `.gitignore`.
- The project targets a 1.44MB floppy disk image (2880 sectors × 512 bytes).




