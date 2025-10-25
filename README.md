# pass-pwgen

Extension for [pass](https://www.passwordstore.org/) that generates passwords using [`pwgen`](http://pwgen.sourceforge.net/) with fuzzy selection, clipboard, and QR code integration.

## Features

- Generate passwords using [`pwgen`](http://pwgen.sourceforge.net/) options.
- Interactive password selection via [fzf](https://github.com/junegunn/fzf).
- Copy generated password to clipboard (with auto-clear timer).
- Output password as QR code (requires [`qrencode`](https://fukuchi.org/works/qrencode/)).

## Requirements

Ensure you have the following dependencies installed:
   - [`pwgen`](http://pwgen.sourceforge.net/)
   - [fzf](https://github.com/junegunn/fzf)

## Usage

```sh
pass pwgen [options] PASS-NAME [pass-length]
```

This will generate a password with `pwgen` according to the options, let you pick one interactively, and store it encrypted in your pass store at `PASS-NAME`.

### Options

- `-h`, `--help`: Show help and exit.
- `-c`, `--clip`: Copy generated passphrase to clipboard, erased after set time.
- `-q`, `--qrcode`: Display a QR code of the generated password.
- `-i`, `--in-place`: only replace the first line of the password file with the newly generated password.
- `-C`, `--capitalize`: Include at least one capital letter.
- `-A`, `--no-capitalize`: Do not include capital letters.
- `-n`, `--numerals`: Include at least one number.
- `-0`, `--no-numerals`: Do not include numbers.
- `-y`, `--symbols`: Include at least one special symbol.
- `-s`, `--secure`: Generate completely random passwords.
- `-B`, `--ambiguous`: Do not include ambiguous characters (e.g. 0, O, l, 1).

### Example

To generate a new password for `email/example.com`, copy it to clipboard, and include symbols:

```sh
pass pwgen -c -y email/example.com
```
