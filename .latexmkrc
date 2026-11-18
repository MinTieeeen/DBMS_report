# Cấu hình cho latexmk (chỉ dùng khi máy đã cài Perl). Mọi file sinh ra nằm trong build/.
use File::Path qw(make_path);

$out_dir = 'build';
$pdf_mode = 1;
$pdflatex = 'pdflatex -shell-escape -synctex=1 -interaction=nonstopmode -file-line-error %O %S';
$bibtex_use = 2;

# \include{section/...} cần build/section/; minted v3 đọc thư mục output từ biến môi trường này.
make_path("$out_dir/section");
$ENV{'TEXMF_OUTPUT_DIRECTORY'} = $out_dir;
