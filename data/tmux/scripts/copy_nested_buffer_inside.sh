#!/bin/sh
set -e

err_msg=""
trap_err() { echo "ERROR $err_msg"; }
trap_exit() { e=$?; [ $e -eq 0 ] || trap_err; exit $e; }
trap 'trap_exit' EXIT

err_msg="Couldn't save buffer."
tmux save-buffer "plain.txt"

err_msg="Couldn't generate key pair."
openssl ecparam -name prime256v1 -genkey -noout -out private_key.pem
openssl ec -in private_key.pem -pubout -outform DER | base64 -w 0 >public_key.der.b64

err_msg="Couldn't complete key exchange."
echo "KX $(cat public_key.der.b64)"
read host_public_key
echo "$host_public_key" >host_public_key.der.b64

err_msg="Couldn't decode received public key."
base64 -d host_public_key.der.b64 >host_public_key.der
openssl ec -inform DER -pubin -in host_public_key.der -out host_public_key.pem

err_msg="Couldn't create shared AES key."
openssl pkeyutl -derive -inkey private_key.pem -peerkey host_public_key.pem -out shared_secret.bin
openssl dgst -sha256 -binary shared_secret.bin >aes_key.bin

err_msg="Couldn't encrypt message."
base64 -w 0 aes_key.bin
openssl enc -aes-256-cbc -salt -in plain.txt -out plain.enc -pass file:aes_key.bin -pbkdf2

err_msg="Couldn't calculate chunk size."
tmux_window_height=$(tmux display-message -p '#{window_height}')
tmux_window_width=$(tmux display-message -p '#{window_width}')
chunk_size=$(expr $tmux_window_height \* $tmux_window_width - 3)
echo "Chunk size $chunk_size"

base64 -w 0 plain.enc >plain.enc.b64
split -b $chunk_size plain.enc.b64 plain.enc.b64.

err_msg="Couldn't send full message."
m="M:"
for f in plain.enc.b64.*; do
  echo -n "$m $(cat $f)"
  read ack
  if [ "$m" = "M:" ]; then
    m="M."
  else
    m="M:"
  fi
done
echo -n "DONE! "
read ack

