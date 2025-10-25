#!/usr/bin/env bash

cmd_pwgen_help () {
    cat << __pwgen_usage_097612_EOF
Usage:
    $PROGRAM $COMMAND [options] pass-name [pass-length]

Similar to "$PROGRAM generate", but generate a password with pwgen tool.

Options:
    -h, --help		Show this help and exit.
    -c, --clip		Write generated passphrase to clipboard, to be erased
			$CLIP_TIME second(s) later, without echoing to terminal.
    -q, --qrcode	Encode generated passphrase using qrencode, without
			echoing the text to terminal.
    -i, --in-place	only replace the first line of the password file
			with the newly generated password.

    In addition, the following option is specific to $COMMAND command:
    -C, --capitalize		Include at least one capital letter in the password
    -A, --no-capitalize		Don't include capital letters in the password
    -n, --numerals		Include at least one number in the password
    -0, --no-numerals		Don't include numbers in the password
    -y, --symbols		Include at least one special symbol in the password
    -s, --secure		Generate completely random passwords
    -B, --ambiguous		Don't include ambiguous characters in the password
__pwgen_usage_097612_EOF
}

cmd_pwgen_exec () {
	local wanthelp qrcode clip inplace
	local numerals nonumerals capitalize nocapitalize symbols secure ambigous
	local password choice_count=30

	while true; do
		case "$1" in
			-h|--help) wanthelp=1; shift ;;
			-c|--clip) clip=1; shift ;;
			-q|--qrcode) qrcode=1; shift ;;
			-i|--inplace) inplace=1; shift ;;
			-C|--capitalize) capitalize=1; shift ;;
			-A|--no-capitalize) nocapitalize=1; shift ;;
			-n|--numerals) numerals=1; shift ;;
			-0|--no-numerals) nonumerals=1; shift ;;
			-y|--symbols) symbols=1; shift ;;
			-B|--ambigous) ambigous=1; shift ;;
			-s|--secure) secure=1; shift ;;
			*) break ;;
		esac
	done

	local pass_length="${2:-$GENERATED_LENGTH}"
	[[ $pass_length =~ ^[0-9]+$ ]] || die "Error: pass-length \"$pass_length\" must be a number."
	[[ $pass_length -gt 0 ]] || die "Error: pass-length must be greater than zero."

	if [[ ( $# -ne 2 && $# -ne 1 ) || $wanthelp -eq 1 || ( $qrcode -eq 1 && $clip -eq 1 )]]; then
		cmd_pwgen_help
		exit 0
	fi

	# Check dependencies
	command -v pwgen >/dev/null 2>&1 || { die "pwgen is not installed."; }
	command -v fzf >/dev/null 2>&1 || { die "fzf is not installed.";  }

	local path="$1"

	check_sneaky_paths "$1"
	mkdir -p -v "$PREFIX/$(dirname -- "$path")"
	set_gpg_recipients "$(dirname -- "$path")"
	local passfile="$PREFIX/$path.gpg"
	set_git "$passfile"

	if [[ $inplace -eq 0 && -e $passfile ]]; then
		yesno "An entry already exists for $path. Overwrite it?"
	fi

	local pwgen_args="${numerals:+-n} ${nonumerals:+-0} ${capitalize:+-c} ${nocapitalize:+-A} ${symbols:+-y} ${secure:+-s} ${ambigous:+-B}"

	if ! { password="$(pwgen -1 $pwgen_args $pass_length $choice_count | fzf)" ; } ; then
		die "Error: passphrase generation failed."
	fi

	if [[ $inplace -eq 0 ]]; then
		echo "$password" | $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile" "${GPG_OPTS[@]}" || die "Password encryption aborted."
    else
		local passfile_temp="${passfile}.tmp.${RANDOM}.${RANDOM}.${RANDOM}.${RANDOM}.--"
		if { echo "$password"; $GPG -d "${GPG_OPTS[@]}" "$passfile" | tail -n +2; } | $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile_temp" "${GPG_OPTS[@]}"; then
	    	mv "$passfile_temp" "$passfile"
		else
			rm -f "$passfile_temp"
			die "Could not reencrypt new password."
		fi
    fi
    local verb="Add"
    [[ $inplace -eq 1 ]] && verb="Replace"
	git_add_file "$passfile" "$verb password for '${path}' via pwgen extension"

	if [[ $clip -eq 1 ]]; then
		clip "$password" "$path"
	elif [[ $qrcode -eq 1 ]]; then
		qrcode "$password" "$path"
	else
		printf '\e[1m\e[37mThe generated passphrase for \e[4m%s\e[24m is:\e[0m\n\e[1m\e[93m%s\e[0m\n' "$path" "$password"
	fi

}

cmd_pwgen_exec "$@"
