#!/usr/bin/expect -f
# Constantin CLERC - v0.2

# Parse command-line arguments
set username [lindex $argv 0]
set password [lindex $argv 1]
set server [lindex $argv 2]

# Enable host key checking to automatically trust the host
spawn nohup ssh -o StrictHostKeyChecking=no -D 8080 -C -N $username@$server

expect "assword:"
send "$password\r"

spawn echo "ssh spawned"
interact
