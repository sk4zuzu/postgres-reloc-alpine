1.
```
$ PREFIX=/home/whoever/_postgres ./build.sh
```

2.
```
$ tar xf postgres.tar.xz -C /
```

3.
```
$ cd /home/whoever/_postgres
$ bin/initdb -D data -U postgres
```

4.
```
$ bin/pg_ctl -D data -l logfile start
```

5.
```
$ bin/psql -U postgres
```


[//]: # ( vim:set ts=4 sw=4 et syn=markdown: )
