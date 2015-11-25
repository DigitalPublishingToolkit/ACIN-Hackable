# Makefile for INC hybrid publications

## Issues:
# * why can't i make icmls before making markdowns ??

alldocx=$(wildcard docx/*.docx)
allmarkdown=$(filter-out md/book.md, $(shell ls md/*.md)) # TODO: add if, so that if no md is present no error: "ls: cannot access md/*.md: No such file or directory"
markdowns_compound=compound_src.md
epub=book.epub
icmls=$(wildcard icml/*.icml)
.PHONY: $(allmarkdown) #force rebuild  by making targets phony

test: $(allmarkdown)
	echo "start" ; 
	echo $(allmarkdown) ; 
	echo "end" ;


folders:
	mkdir docx/ ; \
	mkdir md/ ; \
	mkdir md/imgs/ ; \
	mkdir icml/ ; \
	mkdir lib/ ; \
	mkdir scribus_html/ ; \
	mkdir web ;

markdowns:$(alldocx) # convert docx to md
	for i in $(alldocx) ; \
	do md=md/`basename $$i .docx`.md ; \
	echo "File" $$i $$md ; \
	pandoc $$i \
	       	--from=docx \
		--to=markdown \
	       	--atx-headers \
		--template=essay.md.template \
		-o $$md ; \
	./scripts/md_unique_footnotes.py $$md ; \
	done



icmls: $(allmarkdown)
	for i in $(allmarkdown) ; \
	do icml=icml/`basename $$i .md`.icml ; \
	./scripts/md_stripmetada.py $$i > md/tmp.md ; \
	pandoc md/tmp.md \
		--from=markdown \
		--to=icml \
		--self-contained \
		-o $$icml ; \
		--from markdown-yaml_metadata_block
	done


scribus: $(allmarkdown)
	for i in $(allmarkdown) ; \
	do html=`basename $$i .md`.html ; \
	./scripts/md_stripmetada.py $$i > md/tmp.md ; \
	pandoc md/tmp.md \
		--from=markdown \
		--to=html5 \
		--template=scribus.html.template \
		-o scribus_html/$$html ; \
	done


html: $(allmarkdown)
	for i in $(allmarkdown) ; \
	do html=`basename $$i .md`.html ; \
	./scripts/md_stripmetada.py $$i > md/tmp.md ; \
	pandoc md/tmp.md \
		--from=markdown \
		--to=html5 \
		--css=main.css \
		-s \
		-o html/$$html ; \
	echo html/$$html ; \
	done


book.md: clean $(allmarkdown)
	for i in $(allmarkdown) ; \
	do ./scripts/md_stripmetada.py $$i >> md/book.md ; \
	done


epub: clean $(allmarkdown) book.md epub/metadata.xml epub/styles.epub.css epub/cover.jpg
	cd md && pandoc book.md  \
		--from markdown \
		--to epub3 \
		--self-contained \
		--epub-chapter-level=1 \
		--epub-stylesheet=../epub/styles.epub.css \
		--epub-cover-image=../epub/cover.jpg \
		--epub-metadata=../epub/metadata.xml \
		--default-image-extension png \
		--toc-depth=1 \
		-o ../book.epub ; \
		

foo: 
	cd md & touch foo ; \


clean:  # remove outputs
	rm -f md/book.md  
	rm -f book.epub 
	rm -f *~ */*~  #emacs files
