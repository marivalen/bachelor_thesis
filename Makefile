bachelorthesis.pdf: bachelorthesis.tex
	latexmk -pdf -pdflatex="pdflatex -interactive=nonstopmode -shell-escape" -use-make $<

clean:
	latexmk -CA
