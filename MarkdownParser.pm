use v5.24;
package MarkdownParser {

	use Exporter 'import';
	our @EXPORT_OK = qw(parse);

	my %links;

	my @regexs = (
			{ 
				regex => qr/(?:^|\s+)(?<!\\)\[(.+)(?<!\\)\](?<!\\): (.+)$/m, 
				func => sub { $links{unescape($1)} = $2; '' } 
			}, #named link
			{ 
				regex => qr/(?<!\\)<([^\n]+)(?<!\\)>/, 
				func => sub { "<a href=\"$1\">$1<\/a>"} 
			}, # in-place link
			{ 
				regex => qr/(^\n(.+?\n)+$)/m, 
				func => sub { parse_paragraph($1) } 
			}, #paragraph
			{ 
				regex => qr/^(?<!\\)>(.*)/m, 
				func => sub { "<blockquote>$1<\/blockquote>" } 
			}, #blockqoute
			{ 
				regex => qr/^(?<!\\)```\n((?:.|\n)+?)(?<!\\)\n```$/m, 
				func => sub { "<pre>\n<code>$1<\/code>\n<\/pre>" } 
			}, #block code
			{
			 	regex => qr/((?:(?:\s+|^)(?<!\\)[*\-+]\s.*$)+)/m, 
			 	func => sub { parse_list($1, '[*\-+]', 'ul') } 
			 }, #bullet list
			{ 
				regex => qr/((?:(?:\s+|^)(?<!\\)\d+(?<!\\)\.\s.*$)+)/m, 
				func => sub { parse_list($1, '\d+\.', 'ol') } 
			}, #numbered list
			{ 
				regex => qr/^((?:(?<!\\)#){1,6})(.+)$/m, 
				func => sub { my $n = length $1; "<h$n>$2</h$n>" } 
			}, #header 
			{ 
				regex => qr/(^|\s+)---+\s*$/m, 
				func => sub { "\n<hr \/>" } 
			}, #horizontal line
			{ 
				regex => qr/(?<!\\)!(?<!\\)\[(.+?)(?<!\\)\](?<!\\)\((.+?)(?<!\\)\)/, 
				func => sub { "<img src=\"$2\" alt=\"$1\"/>" } 
			}, #image
			{ 
				regex => qr/(?<!\\)!(?<!\\)\[(.+?)(?<!\\)\](?<!\\)\[(.+?)(?<!\\)\]/, 
				func => sub { "<img src=\"".($links{unescape($2)}//$2)."\" alt=\"$1\"\/>" } 
			}, #image using named link
			{ 
				regex => qr/(?<!\\)\[(.+?)(?<!\\)\](?<!\\)\((.+?)(?<!\\)\)/, 
				func => sub { "<a href=\"$2\">$1</a>" } 
			}, #link
			{ 
				regex => qr/(?<!\\)\[(.+?)(?<!\\)\](?<!\\)\[(.+?)(?<!\\)\]/, 
				func => sub { "<a href=\"".($links{unescape($2)}//$2)."\">$1<\/a>" } 
			}, #link using named link
			{ 
				regex => qr/(?:(?:(?<!\\)\*){2}((?:[^*\n]|(?:\\\*))+?)(?:(?<!\\)\*){2})|
							(?:(?:(?<!\\)_){2}((?:[^_\n]|(?:\\_))+?)(?:(?<!\\)_){2})/x, 
				func => sub { "<strong>".($1//$2)."<\/strong>" } 
			}, #bold
			{ 
				regex => qr/(?:(?<!\\)\*((?:[^*\n]|(?:\\\*))+?)(?<!\\)\*)|
							(?:(?<!\\)_((?:[^_\n]|(?:\\_))+?)(?<!\\)_)/x, 
				func => sub { "<em>".($1//$2)."<\/em>" } 
			}, #italic
			{ 
				regex => qr/(?:(?<!\\)`((?:[^`\n]|(?:\\`))+?)(?<!\\)`)/, 
				func => sub { "<code>$1</code>" } 
			}, #code
			{ 
				regex => qr/(?:(?<!\\)~){2}((?:[^~\n]|(?:\\~))+?)(?:(?<!\\)~){2}/, 
				func => sub { "<del>$1</del>" } 
			}, #strikethrough
			{ 
				regex => qr/ {2}$/m, 
				func => sub { "<br />" } 
			}, #line break
		);

	sub unescape {
		my $string = shift;
		$string =~ s/\\(.)/$1/mg;
		$string;
	}

	sub parse_paragraph {
		my $string = shift;
		do { return $string if ($string =~ $_->{regex}) } for(@regexs[4..9]);
		"<p>$string<\/p>"

	}

	sub parse_list {
		my ($string, $symbols, $tag) = @_;
		$string =~ /^( *)$symbols/m;
		my $n = length $1;
		while ($string =~ /^(\s*)$symbols\s(.*)$/m) {
			my $s = $1;
			$s =~ s/\n//g;
			my $m = length $s;
			do { $string =~ s/((?:\n {$m,}$symbols\s.*$)+)/parse_list($1, $symbols, $tag)/emg; next; } if $m > $n;
			$string =~ s/^ {0,$n}$symbols (.*)$/"<li>$1<\/li>"/emg;
		}
		"\n<$tag>$string<\/$tag>\n";
	}

	sub parse {
		my $string = shift;
		$string =~ s/$_->{regex}/$_->{func}->()/emg for (@regexs);
		unescape($string);
	}

	1;	
}
