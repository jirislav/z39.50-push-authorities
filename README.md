This Perl's z39.50 implementation is using the C ZOOM library in order to use one of the Extended Services - Record Update

Documentation of that C library can be found at [IndexData.com](http://www.indexdata.com/yaz/doc/zoom.html)

You can run this Perl script after properly configurated in "cfg.yaml" by executing `perl PushAuthoritiesMARC.pm`

#### Prerequisities
You first have to install YAML::XS
```
cpan -i YAML::XS
```

Then you also need this Debian package:
```
sudo apt-get install libnet-z3950-zoom-perl
```

#### Using deprecated Zebedee (not recommended)
If you really want to use the Zebedee tunnel you can use included binary at vendor/Winton.org.uk/zebedee like this:
```
./vendor/Winton.org.uk/zebedee LOCAL_BIND_PORT:SERVER:SERVER_PORT
```

Or add it to path in order to launch it from everywhere:
```
sudo cp vendor/Winton.org.uk/zebedee /usr/local/bin/
```

Example usage:
```
zebedee -T 57779 8888:vega.nkp.cz:7777
```

Zebedee compiled from tarballs, which are taken from [Winton.org.uk](http://www.winton.org.uk/zebedee/download.html)
