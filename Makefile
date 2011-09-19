# Variable declarations
DOCBOOKXSL=./xsl/docbook
DOCBOOKXSL_CUSTOMIZED=./xsl

STYLESHEET_XHTML=$(DOCBOOKXSL_CUSTOMIZED)/xhtml.xsl
STYLESHEET_EPUB=$(DOCBOOKXSL)/epub/docbook.xsl
STYLESHEET_FO=$(DOCBOOKXSL)/fo/docbook.xsl

SOURCE=./src
BUILD_HTML=./build
BUILD_FO=./procbuild_fo
BUILD_EPUB=./procbuild_epub

UPLOAD_SERVER=www.star-fleet.com
UPLOAD_USER=stfleet
UPLOAD_PATH=/usr/home/stfleet/public_html/library/newbookshelf/

FO_OUTPUT=stflibrary.fo
EPUB_OUTPUT=stflibrary.epub

all: html pdf epub

html:
	mkdir -p $(BUILD_HTML)
	xsltproc \
	--xinclude \
	--timing \
	--stringparam base.dir $(BUILD_HTML)/ \
	$(STYLESHEET_XHTML) \
	$(SOURCE)/set.xml

epub:
	mkdir -p $(BUILD_EPUB)
	xsltproc \
	--xinclude \
	--timing \
	--stringparam chunk.section.depth 0 \
	--stringparam chunker.output.indent yes \
	--stringparam use.id.as.filename 1 \
	--output $(BUILD_EPUB)/$(EPUB_OUTPUT) \
	$(STYLESHEET_EPUB) \
	$(SOURCE)/set.xml
	# Need to add an epub packager here, I think.

pdf:
	# We may be able to merge these into a single fop command when the build
	# errors are resolved.
	mkdir -p $(BUILD_FO)
	xsltproc \
	--xinclude \
	--timing \
	--stringparam fop1.extensions 1 \
	--output $(FO_OUTPUT) \
	$(STYLESHEET_FO) \
	$(SOURCE)/set.xml
	fop -fo $(FO_OUTPUT) -pdf library.pdf

clean:
	@echo "Deleting output files"
	@find ./$(BUILD) -name '*.html' -exec rm {} \;
	@echo "Deleting redundant backup saves"
	@find . -name '*~' -exec rm {} \;

valid:
	@echo "Validating Handbook"
	@xmllint \
	--noout \
	--xinclude \
	--postvalid \
	--noent \
	--dtdvalid $(DBDTD) \
	$(SOURCE)/set.xml

upload:
	@echo "Uploading files to production"
	@scp -r $(BUILD_HTML)/* $(UPLOAD_USER)@$(UPLOAD_SERVER):$(UPLOAD_PATH)
