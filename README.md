This Perl's z39.50 implementation is using the C ZOOM library in order to use one of the Extended Services - Record Update

Documentation of that C library can be found at [IndexData.com](http://www.indexdata.com/yaz/doc/zoom.htm)

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

If you also want to use the really old Zebedee tunnel (not recommended), do this:
```
cd /tmp
wget http://www.winton.org.uk/zebedee/zebedee-2.4.1A.tar.gz
wget http://www.winton.org.uk/zebedee/blowfish-0.9.5a.tar.gz
wget http://www.winton.org.uk/zebedee/zlib-1.2.3.tar.gz
wget http://www.winton.org.uk/zebedee/bzip2-1.0.3.tar.gz

tar -xf zebedee-2.4.1A.tar.gz
tar -xf blowfish-0.9.5a.tar.gz
tar -xf zlib-1.2.3.tar.gz
tar -xf bzip2-1.0.3.tar.gz

cd blowfish-0.9.5a/ && make
cd ../zlib-1.2.3/ && ./configure && make
cd ../bzip2-1.0.3/ && make
cd ../zebedee-2.4.1A/ && make

sudo mv zebedee /usr/local/bin/
cd .. 
rm -rf bzip2-1.0.3 zlib-1.2.3 blowfish-0.9.5a zebedee-2.4.1A
rm blowfish-0.9.5a.tar.gz bzip2-1.0.3.tar.gz zebedee-2.4.1A.tar.gz zlib-1.2.3.tar.gz
```

Connecting to an Zebedee server should now work with:
```
zebedee LOCAL_BIND_PORT:SERVER:SERVER_PORT
```

Example:
```
zebedee 8888:vega.nkp.cz:7777
```

Zebedee tarballs taken from [Winton.org.uk](http://www.winton.org.uk/zebedee/download.html)
