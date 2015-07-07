all:
	./help2adoc.pl -e ./help2adoc.pl -n "Help to asciidoc" -i help2adoc.adoc > help2adoc.1.txt
	asciidoc help2adoc.1.txt
	a2x --format manpage help2adoc.1.txt

install:
	cp ./help2adoc.pl /usr/bin/help2adoc
	chmod +x /usr/bin/help2adoc
	cp help2adoc.1 /usr/share/man/man1/

uninstall:
	rm -f /usr/bin/help2adoc

