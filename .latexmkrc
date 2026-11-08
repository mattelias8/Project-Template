# Shared latexmk settings. paper/, slides/ and logbook/ each load this file
# through their own one-line .latexmkrc, so paths are relative to those folders.
ensure_path('TEXINPUTS', '../latex//');
ensure_path('BIBINPUTS', '../bib//');
ensure_path('BSTINPUTS', '../bib//');
$pdf_mode = 1;
$bibtex_use = 2;
$clean_ext = 'nav snm vrb run.xml bbl';
