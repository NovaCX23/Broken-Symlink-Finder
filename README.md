# ITBI: Broken Symlink Finder

A Bash script that walks a directory tree depth-first (DFS) and reports every **broken symbolic link** it
finds: a link whose target no longer exists. It can optionally follow symlinks that point to directories
and keep searching inside them.

Written for the ITBI course.

## Contents

| File | Purpose |
|---|---|
| `proiect.sh` | The main script: recursive DFS search for broken symlinks |
| `generare.sh` | Builds a test tree full of broken symlinks |
| `test_dir/` | A tree made by `generare.sh`: 10 directories, each with 20 broken links (200 in total) |
| `link_dir/` | Holds a symlink to `test_dir`, used to test `--follow-symlinks` |
| `output_directoare.txt` | Sample output: the list of directories visited in one run |

## Requirements

- Bash 4 or newer
- GNU coreutils (`readlink -f`)
- Linux, macOS with GNU coreutils, or WSL. On plain Windows the symlinks in this repo are checked out as
  ordinary text files, so the tests below will not work.

## Usage

```bash
chmod +x proiect.sh generare.sh      # only needed once
./proiect.sh [--follow-symlinks] <directory>
```

| Argument | Meaning |
|---|---|
| `<directory>` | Where the search starts. Required, and it must be an existing directory. |
| `--follow-symlinks` | Also enter directories that are reached through a symlink. Can go before or after the directory. |

### What it does

1. Visits `<directory>` and every subdirectory under it, depth-first, hidden ones included.
   Each directory is visited **once**: the script remembers the real path (`readlink -f`) of every directory
   it has entered, so symlink loops end and nothing is counted twice.
2. For each entry:
   - **broken symlink**: printed as `Broken symlink găsit: <path>` and counted;
   - **valid symlink to a directory**: entered only with `--follow-symlinks` (the real path is resolved with `readlink -f`);
   - **valid symlink to a file**: ignored;
   - **regular directory**: entered recursively.
3. Prints the total number of broken symlinks and whether `--follow-symlinks` was used.
4. Writes every visited directory to `output_directoare.txt` in the **current working directory**.
   The file is overwritten on each run.

Messages printed by the script are in Romanian.

## Examples

Create a test tree and scan it:

```bash
mkdir test_dir
./generare.sh test_dir      # 10 directories x (10 links to missing files + 10 links to missing directories)
./proiect.sh test_dir
```

```text
Directorul specificat: test_dir
Broken symlink găsit: test_dir/new_directory_1/link_to_broken_directory_1
...
Număr total de linkuri simbolice broken găsite: 200
Nu s-a utilizat flag-ul --follow-symlinks. Linkurile simbolice nu au fost analizate recursiv.
Verificare completă!
```

Following symlinks:

```bash
./proiect.sh link_dir                     # 0 broken links: the symlink to test_dir is not followed
./proiect.sh --follow-symlinks link_dir   # 200 broken links: the search continues inside test_dir
```

`link_dir/test_dir` is a relative link (`../test_dir`), so it works wherever the repo is cloned.
`generare.sh` can be run again on the same directory; existing links are replaced.

## Notes

- Symlinks in this repo only work on systems that support them. On Windows, use WSL; a plain Windows
  checkout turns them into small text files.
- `.gitattributes` keeps the scripts at LF line endings, so they still run after being checked out on Windows.
- `output_directoare.txt` in the repo is a sample from an earlier run, made with the older version of the script on the author's machine.
- Visiting each directory once means that when a directory is reachable both directly and through a symlink, it
  is listed under whichever path the search reaches first.
