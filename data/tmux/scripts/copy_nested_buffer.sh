#!/bin/sh
# Copies the current buffer of the nested tmux session.

set -e

unzoom_pane_later=""

err_msg=""
trap_err() { tmux display-message "ERROR $err_msg"; }
trap_exit() {
  e=$?
  [ $e -eq 0 ] || trap_err
  [ "$unzoom_pane_later" ] && tmux resize-pane -Z && unzoom_pane_later=""
  exit $e
}
trap 'trap_exit' EXIT

err_msg="Couldn't create temporary directory."
d=$(date +%Y%m%dT%H%M%S)
dir=$(mktemp -d --tmpdir "tmux-copy_nested_buffer-$d.XXXXXXXXXX")
cd "$dir"

mkdir -p /tmp/asdf
echo "$d" >>/tmp/asdf/log

err_msg="Couldn't generate key pair."
openssl ecparam -name prime256v1 -genkey -noout -out private_key.pem
openssl ec -in private_key.pem -pubout -outform DER | base64 -w 0 > public_key.der.b64

err_msg="Couldn't start script in nested tmux session."
"$DOTFILES_HOME/data/tmux/scripts/start_script_nested.sh" "$DOTFILES_HOME/data/tmux/scripts/copy_nested_buffer_inside.sh"

# TODO: zoom pane if possible to get better bandwidth?
rcv_line="" # set via `receive`
rcv_status="" # set via `receive`; first space-separated part of rcv_line
rcv_data="" # set via `receive`; rcv_line without rcv_status
RCV_ERROR="ERR"
RCV_LINE_SUFFIX=" ;"
receive() {
  pane_height=$(tmux display-message -p '#{pane_height}')
  for i in $(seq 0 100); do
    rcv_line=$(tmux capture-pane -p -J -S 0 -E $(expr "$pane_height" - 2) | grep . | tail -n 1)
    case "$rcv_line" in *"$RCV_LINE_SUFFIX") # received complete line?
      rcv_line="${rcv_line%$RCV_LINE_SUFFIX}"
      # echo "rcv_line $rcv_line" >>/tmp/asdf/log
      case "$rcv_line" in "$RCV_ERROR"*)
        echo "$err_msg" >>/tmp/asdf/log
        err_msg+=" Received '$rcv_line' whilst waiting for $@!"
        echo "$err_msg" >>/tmp/asdf/log
        exit 1
        ;;
      esac
      rcv_status=$(echo "$rcv_line" | cut -d ' ' -f 1)
      echo "rcv_status $rcv_status" >>/tmp/asdf/log
      for target in "$@"; do
        case "$rcv_status" in "$target"*)
          echo "received '$target' '$rcv_status'" >>/tmp/asdf/log
          rcv_data=$(echo "$rcv_line" | cut -d ' ' -f 2-)
          echo "rcv_data $rcv_data" >>/tmp/asdf/log
          return
          ;;
        esac
      done
      ;;
    esac
    sleep 0.001
  done
  err_msg+=" Didn't receive $@!"
  exit 1
}

err_msg="Couldn't zoom tmux pane."
unzoom_pane_later=""
if [ "$(tmux list-panes | wc -l)" -ge 1 -a "$(tmux display-message -p '#{window_zoomed_flag}')" -eq 0 ]; then
  tmux resize-pane -Z
  unzoom_pane_later="true"
fi

err_msg="Couldn't complete key exchange."
receive "KX"
echo -n "$rcv_data" >guest_public_key.der.b64
ls -la >>/tmp/asdf/log
tmux send-keys "$(cat public_key.der.b64)" C-m
echo "post KX" >>/tmp/asdf/log

err_msg="Couldn't decode received public key."
cat guest_public_key.der.b64 >> /tmp/asdf/log
hexdump -C guest_public_key.der.b64 >>/tmp/asdf/log
base64 -d guest_public_key.der.b64 >guest_public_key.der
# echo "de-b64 KX" >>/tmp/asdf/log
# ls -la >>/tmp/asdf/log
openssl ec -inform DER -pubin -in guest_public_key.der -out guest_public_key.pem
cat guest_public_key.pem >> /tmp/asdf/log

err_msg="Couldn't create shared AES key."
openssl pkeyutl -derive -inkey private_key.pem -peerkey guest_public_key.pem -out shared_secret.bin
openssl dgst -sha256 -binary shared_secret.bin >aes_key.bin

# TODO: break if we don't receive "M"
err_msg="Couldn't receive full message."
m="M:"
while true; do
  receive "$m" "DONE!"
  plain_enc_b64="$rcv_data"
  case "$rcv_status" in
    "DONE!"*)
      echo "done" >>/tmp/asdf/log
      [ "$unzoom_pane_later" ] && tmux resize-pane -Z \;&& unzoom_pane_later=""
      tmux send-keys C-m
      break
      ;;
    "M:"*)
      m="M."
      ;;
    "M."*)
      m="M:"
      ;;
    *)
      err_msg+=" Received $rcv_status unexpectedly."
      exit 1
      ;;
  esac
  echo -n "$plain_enc_b64" >>plain.enc.b64
  tmux send-keys C-m
done
if [ "$rcv_data" != "$(sha256sum plain.enc.b64)" ]; then
  err_msg+=" Hashsums of transmitted data don't match."
  ls -l
  exit 1
fi

err_msg="Couldn't decrypt received message."
base64 -d plain.enc.b64 >plain.enc
openssl enc -d -aes-256-cbc -in plain.enc -out plain.txt -pass file:aes_key.bin -pbkdf2

err_msg="Couldn't load buffer"
tmux load-buffer plain.txt
xclip -f -selection clipboard <"plain.txt" >/dev/null

err_msg=""
cd ..;
rm -r "$dir"

