 grep -i 24047675 /var/log/messages*
 find . | xargs grep -i 24047675 2>/dev/null
 
 #better version avoids problem with space bars or newlines in names
 find . -type f -print0 | xargs -0 grep 22763247
 
 
 find . ! -path "./20150516/*" -type f -name '*test*'
