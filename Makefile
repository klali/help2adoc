all:
	./help2adoc.pl -e ./help2adoc.pl -n "Help to asciidoc" -i help2adoc.adoc > help2adoc.1.txt
	asciidoc help2adoc.1.txt
	a2x --format manpage help2adoc.1.txt

install:
	mkdir -p $(DESTDIR)/usr/bin
	install -o root -g root -m 755 ./help2adoc.pl $(DESTDIR)/usr/bin/help2adoc
	mkdir -p $(DESTDIR)/usr/share/man/man1
	install -o root -g root -m 644 help2adoc.1 $(DESTDIR)/usr/share/man/man1/

uninstall:
	rm -f /usr/bin/help2adoc

