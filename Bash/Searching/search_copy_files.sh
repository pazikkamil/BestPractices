 find . -maxdepth 1 -type f | xargs -I{} cp {} /tmp/
 
 find ./PinkII -type f -exec wc -l {} +  |  egrep -i '\.(aspx|btm|config|cs|css|dsc|fcn|js|layout|lxf|odx|ps1|rds|resx|rds|sql)$' > line_count.txt
 find ./PinkII -type f | egrep -i '\.(aspx|btm|config|cs|css|dsc|fcn|js|layout|lxf|odx|ps1|rds|resx|rds|sql)$' | xargs wc -l > cccc.txt
