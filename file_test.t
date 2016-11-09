use v5.24;
use MarkdownParser qw(parse);
open STDIN, "test.md" or die $!;
open STDOUT, ">test/test.html" or die $!;
$/ = undef;
say "<html>\n<head>\n<link rel=\"stylesheet\" href=\"style.css\">\n</head>\n<body>\n".parse(<>)."\n</body></html>";
