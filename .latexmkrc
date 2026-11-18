# latexmk config. Build: latexmk -pdf -outdir=build main.tex  ->  build/main.pdf
use File::Path qw(make_path);

$out_dir    = 'build';
$pdf_mode   = 1;
$pdflatex   = 'pdflatex -shell-escape -synctex=1 -interaction=nonstopmode -file-line-error %O %S';
$bibtex_use = 2;   # biblatex + biber

# \include{section/...} writes build/section/*.aux, and pdflatex does not create folders.
make_path("$out_dir/section");
# minted v3 finds the output folder through this variable.
$ENV{'TEXMF_OUTPUT_DIRECTORY'} = $out_dir;
