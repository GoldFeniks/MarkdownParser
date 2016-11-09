use MarkdownParser qw(parse);
use Test::More tests => 19;

subtest 'Italic' => sub {
	plan tests => 17;
	is(parse('_italic_'), '<em>italic</em>');
	is(parse('*italic*'), '<em>italic</em>');
	is(parse('_italic*'), '_italic*');
	is(parse('*italic_'), '*italic_');
	is(parse('__italic_'), '_<em>italic</em>');
	is(parse('_ita_lic_'), '<em>ita</em>lic_');
	is(parse('*ita**lic*'), '<em>ita</em><em>lic</em>');
	is(parse('*ita_lic*'), '<em>ita_lic</em>');
	is(parse('_ita*lic_'), '<em>ita*lic</em>');
	is(parse('\*italic*'), '*italic*');
	is(parse('\_italic_'), '_italic_');
	is(parse('*ita\*lic*'), '<em>ita*lic</em>');
	is(parse('_ita\_lic_'), '<em>ita_lic</em>');
	is(parse('_italic\_*italic\*\_italic_'), '<em>italic_*italic*_italic</em>');
	is(parse("*italic\n*"), "*italic\n*");
	is(parse('**'), '**');
	is(parse('__'), '__');
};

subtest 'Bold' => sub {
	plan tests => 17;
	is(parse('**bold**'), '<strong>bold</strong>');
	is(parse('__bold__'), '<strong>bold</strong>');
	is(parse('**bold__'), '**bold__');
	is(parse('__bold**'), '__bold**');
	is(parse('___bold__'), '_<strong>bold</strong>');
	is(parse('**bold****bold**'), '<strong>bold</strong><strong>bold</strong>');
	is(parse('**bold**bold**'), '<strong>bold</strong>bold**');
	is(parse('**bold__bold**'), '<strong>bold__bold</strong>');
	is(parse('__bold**bold__'), '<strong>bold**bold</strong>');
	is(parse('\*\*bold**'), '**bold**');
	is(parse('\_\_bold__'), '__bold__');
	is(parse('**bold\*\*bold**'), '<strong>bold**bold</strong>');
	is(parse('__bold\_\_bold__'), '<strong>bold__bold</strong>');
	is(parse('__bold\_*bold\*\_bold__'), '<strong>bold_*bold*_bold</strong>');
	is(parse("**bold\n**"), "**bold\n**");
	is(parse('****'), '****');
	is(parse('____'), '____');
};

subtest 'Italic and bold combination' => sub {
	plan tests => 8;
	is(parse('\**bold**'), '*<em>bold</em>*');
	is(parse('***bold***'), '<em><strong>bold</strong></em>');
	is(parse('___bold___'), '<em><strong>bold</strong></em>');
	is(parse('**_bold_**'), '<strong><em>bold</em></strong>');
	is(parse('__*bold*__'), '<strong><em>bold</em></strong>');
	is(parse('*__bold__*'), '<em><strong>bold</strong></em>');
	is(parse('_**bold**_'), '<em><strong>bold</strong></em>');
	is(parse('\*\**bold***'), '**<em>bold</em>**');
};

subtest 'Code' => sub {
	plan tests => 5;
	is(parse('`code`'), '<code>code</code>');
	is(parse('`code`code`'), '<code>code</code>code`');
	is(parse('`code\`code`'), '<code>code`code</code>');
	is(parse('\`code`code`'), '`code<code>code</code>');
	is(parse("`code\n`"), "`code\n`");
};

subtest 'Strikethrough' => sub {
	plan tests => 5;
	is(parse('~~foo~~'), '<del>foo</del>');
	is(parse('~~foo~~foo~~'), '<del>foo</del>foo~~');
	is(parse('~~foo\~\~foo~~'), '<del>foo~~foo</del>');
	is(parse('\~\~foo~~foo~~'), '~~foo<del>foo</del>');;
	is(parse("~~foo\n~~"), "~~foo\n~~");
};

subtest 'Paragraph' => sub {
	plan tests => 4;
	is(parse("\nparagraph\n"), "<p>\nparagraph\n</p>");
	is(parse("\nparagraph\n\nparagraph\n"), "<p>\nparagraph\n</p><p>\nparagraph\n</p>");
	is(parse("\nparagraph\nparagraph\n"), "<p>\nparagraph\nparagraph\n</p>");
	is(parse("\n#Header\n\nparagraph\n"), "\n<h1>Header</h1>\n<p>\nparagraph\n</p>");
};

subtest 'Blockquote' => sub {
	plan tests => 4;
	is(parse('>foo'), '<blockquote>foo</blockquote>');
	is(parse('>>foo'), '<blockquote>>foo</blockquote>');
	is(parse('foo>foo'), 'foo>foo');
	is(parse('\>foo'), '>foo');
};

subtest 'Bullet list' => sub {
	plan tests => 4;
	is(parse("* fuu\n* fuu\n* fuu"), "\n<ul>\n<li>fuu</li>\n<li>fuu</li>\n<li>fuu</li>\n</ul>");
	is(parse("+ fuu\n- fuu\n* fuu"), "\n<ul>\n<li>fuu</li>\n<li>fuu</li>\n<li>fuu</li>\n</ul>");
	is(parse("* fuu + fuu * fuu -\n* fuu + fuu * fuu -"), "\n<ul>\n<li>fuu + fuu * fuu -<\/li>\n<li>fuu + fuu * fuu -</li>\n</ul>");
	is(parse("\\* fuu\n* fuu"), "* fuu\n<ul>\n<li>fuu</li>\n</ul>");
};

subtest 'Numbered list' => sub {
	plan tests => 4;
	is(parse("1. fuu\n2. fuu\n3. fuu"), "\n<ol>\n<li>fuu</li>\n<li>fuu</li>\n<li>fuu</li>\n</ol>");
	is(parse("1. fuu 2. fuu 3. fuu 4.\n2. fuu 3. fuu 4. fuu 5."), "\n<ol>\n<li>fuu 2. fuu 3. fuu 4.<\/li>\n<li>fuu 3. fuu 4. fuu 5.</li>\n</ol>");
	is(parse("\\1. fuu\n1. fuu"), "1. fuu\n<ol>\n<li>fuu</li>\n</ol>");
	is(parse("1\\. fuu\n1. fuu"), "1. fuu\n<ol>\n<li>fuu</li>\n</ol>");
};

subtest 'Header' => sub {
	plan tests => 6;
	is(parse('#Header'), '<h1>Header</h1>');
	is(parse('###Header'), '<h3>Header</h3>');
	is(parse('#######Header'), '<h6>#Header</h6>');
	is(parse('\##Header'), '##Header');
	is(parse('##\##Header'), '<h2>##Header</h2>');
	is(parse('###'), '<h2>#</h2>');
};

subtest 'In-place link' => sub {
	plan tests => 3;
	is(parse('<example.com>'), "<a href=\"example.com\">example.com</a>");
	is(parse('\<example.com>'), "<example.com>");
	is(parse("<example.\ncom>"), "<example.\ncom>");
};

subtest 'Block code' => sub {
	plan tests => 2;
	is(parse("```\nmultiline\ncode\n```"), "<pre>\n<code>multiline\ncode<\/code>\n<\/pre>");
	is(parse("\\```\nmultiline\ncode\n```"), "```\nmultiline\ncode\n```");
};

subtest 'Horizontal line' => sub {
	plan tests => 3;
	is(parse("   ----   "), "\n<hr \/>");
	is(parse("   \\----"), "   ----");
	is(parse("   aaa---"), "   aaa---");
};

subtest 'Link' => sub {
	plan tests => 2;
	is(parse('[link](example.com)'), '<a href="example.com">link</a>');
	is(parse('\[link](example.com)'), '[link](example.com)');
};

subtest 'Named link' => sub {
	plan tests => 2;
	is(parse('[link]: example.com'), '');
	is(parse('[link]\: example.com'), '[link]: example.com');
};

subtest 'Link using named link' => sub {
	plan tests => 2;
	is(parse("[link][link]\n[link]: example.com"), "<a href=\"example.com\">link</a>");
	is(parse("[link]\\[link]\n[link]: example.com"), "[link][link]");
};

subtest 'Image' => sub {
	plan tests => 2;
	is(parse('![link](example.com)'), '<img src="example.com" alt="link"/>');
	is(parse('!\[link](example.com)'), '![link](example.com)');
};

subtest 'Image using named link' => sub {
	plan tests => 3;
	is(parse("![link][link]\n[link]: example.com"), "<img src=\"example.com\" alt=\"link\"/>");
	is(parse("![link][link]\n[\link]: example.com"), "<img src=\"example.com\" alt=\"link\"/>");
	is(parse("![link]\\[link]\n[link]: example.com"), "![link][link]");
};

subtest 'Line break' => sub {
	plan tests => 1;
	is(parse("fuu  \n"), "fuu<br />\n");
}