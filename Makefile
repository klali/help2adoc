all:
	@echo "Nothing to see here. Run make install to copy the script in /usr/bin".

install:
	cp ./help2adoc.pl /usr/bin/help2adoc
	chmod +x /usr/bin/help2adoc

uninstall:
	rm -f /usr/bin/help2adoc

