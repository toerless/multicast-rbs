all: draft-eckert-bier-cgm2-rbs.txt

draft-eckert-bier-cgm2-rbs.txt: draft-eckert-bier-cgm2-rbs.xml
	xml2rfc draft-eckert-bier-cgm2-rbs.xml

draft-eckert-bier-cgm2-rbs.xml: draft-eckert-bier-cgm2-rbs.md
	kramdown-rfc2629 draft-eckert-bier-cgm2-rbs.md > draft-eckert-bier-cgm2-rbs.xml
