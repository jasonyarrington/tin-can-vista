#!/usr/bin/env perl
# Build the Tin Can Vista static site from Markdown.
#
#   perl bin/build.pl            build into output/
#   perl bin/build.pl --drafts   include posts marked "draft: true"
#   perl bin/build.pl --out DIR  write somewhere other than output/
#
# Posts:  posts/*.md  (front matter: title, date, tags, summary, draft)
# Pages:  pages/*.md  (front matter: title, section, path)
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../local/lib/perl5";
use Getopt::Long qw(GetOptions);
use POSIX qw(ceil strftime);
use Path::Tiny qw(path);
use YAML::Tiny;
use Template;
use Markdown::Perl;

my $root = path($Bin)->parent;
my ($drafts, $out_dir) = (0, 'output');
GetOptions('drafts' => \$drafts, 'out=s' => \$out_dir) or die "usage: build.pl [--drafts] [--out DIR]\n";
my $out = path($out_dir)->is_absolute ? path($out_dir) : $root->child($out_dir);

my $site = YAML::Tiny->read_string($root->child('site.yml')->slurp_utf8)->[0];
my $md   = Markdown::Perl->new(mode => 'github');

sub slugify {
    my ($s) = @_;
    $s = lc $s;
    $s =~ s/[^a-z0-9]+/-/g;
    $s =~ s/^-|-$//g;
    return $s;
}

sub parse_doc {
    my ($file) = @_;
    my $raw = $file->slurp_utf8;
    my ($meta, $body) = ({}, $raw);
    if ($raw =~ /\A---[ \t]*\n(.*?)\n---[ \t]*\n(.*)\z/s) {
        $meta = eval { YAML::Tiny->read_string("---\n$1\n")->[0] } // die "$file: bad front matter: $@";
        $body = $2;
    }
    die "$file: missing title\n" unless defined $meta->{title} && length $meta->{title};
    return ($meta, $body);
}

# Photos on their own line become <figure>, with the Markdown title as the caption.
sub figures {
    my ($html) = @_;
    $html =~ s{<p>(<img\s[^>]*?>)</p>}{
        my $img = $1;
        my $cap = $img =~ s/\s+title="([^"]*)"//  ? $1 : '';
        '<figure>' . $img . ($cap ne '' ? "<figcaption>$cap</figcaption>" : '') . '</figure>';
    }ge;
    return $html;
}

sub text_of {
    my ($html) = @_;
    $html =~ s/<[^>]+>//g;
    $html =~ s/&(?:amp|lt|gt|quot|#39);/ /g;
    $html =~ s/\s+/ /g;
    $html =~ s/^ | $//g;
    return $html;
}

sub excerpt_of {
    my ($html) = @_;
    my ($first) = $html =~ m{<p>(.*?)</p>}s or return '';
    my $text = text_of($first);
    return $text if length $text <= 180;
    $text = substr($text, 0, 180);
    $text =~ s/\s+\S*$//;
    return "$text...";
}

# --- Posts -----------------------------------------------------------------
my (@posts, %tags, %seen);
for my $file (sort $root->child('posts')->children(qr/\.md\z/)) {
    my ($meta, $body) = parse_doc($file);
    next if $meta->{draft} && !$drafts;

    my $date = $meta->{date} // '';
    die "$file: date must look like 2026-11-09\n" unless $date =~ /\A\d{4}-\d{2}-\d{2}\z/;

    (my $slug = $file->basename('.md')) =~ s/\A\d{4}-\d{2}-\d{2}-//;
    $slug = slugify($slug);
    die "$file: duplicate slug '$slug'\n" if $seen{$slug}++;

    # Tags may be "[a, b]", "a, b" or a block list. (YAML::Tiny has no inline lists.)
    my @tag_names = ref $meta->{tags} eq 'ARRAY' ? @{ $meta->{tags} } : ();
    if (defined $meta->{tags} && !ref $meta->{tags}) {
        (my $list = $meta->{tags}) =~ s/\A\s*\[|\]\s*\z//g;
        @tag_names = grep { length } split /\s*,\s*/, $list;
    }
    my @post_tags = map { { name => $_, slug => slugify($_) } } @tag_names;

    my $html = figures($md->convert($body));
    my $plain_words = scalar(() = text_of($html) =~ /\S+/g);
    (my $lead = $html) =~ s{\A<p>}{<p class="aw-prose__lead">};

    my $post = {
        title        => $meta->{title},
        date         => $date,
        slug         => $slug,
        url          => "/posts/$slug/",
        tags         => \@post_tags,
        html         => $lead,
        excerpt      => $meta->{summary} // excerpt_of($html),
        reading_time => ceil($plain_words / 220) || 1,
    };
    push @posts, $post;
    for my $t (@post_tags) {
        $tags{ $t->{slug} } //= { name => $t->{name}, slug => $t->{slug}, posts => [] };
        push @{ $tags{ $t->{slug} }{posts} }, $post;
    }
}
@posts = sort { $b->{date} cmp $a->{date} } @posts;
$_->{posts} = [ sort { $b->{date} cmp $a->{date} } @{ $_->{posts} } ] for values %tags;

# --- Render ----------------------------------------------------------------
my $tt = Template->new(
    INCLUDE_PATH => $root->child('site/templates')->stringify,
    ENCODING     => 'UTF-8',
) or die Template->error;

my $common = { site => $site, year => strftime('%Y', localtime) };

sub render {
    my ($template, $vars, $dest) = @_;
    my $html;
    $tt->process($template, { %$common, %$vars }, \$html) or die $tt->error;
    my $file = $out->child($dest);
    $file->parent->mkpath;
    $file->spew_utf8($html);
}

$out->remove_tree if $out->exists;
$out->mkpath;

render('index.tt', { posts => \@posts }, 'index.html');
render('post.tt',  { post => $_ }, "posts/$_->{slug}/index.html") for @posts;
render('tag.tt',   { tag => $_, posts => $_->{posts} }, "tags/$_->{slug}/index.html") for values %tags;

my $page_count = 0;
for my $file (sort $root->child('pages')->children(qr/\.md\z/)) {
    my ($meta, $body) = parse_doc($file);
    my $slug = $file->basename('.md');
    my $page = {
        title   => $meta->{title},
        section => $meta->{section} // '',
        html    => figures($md->convert($body)),
    };
    render('page.tt', { page => $page }, $meta->{path} // "$slug/index.html");
    $page_count++;
}

# --- Static files ----------------------------------------------------------
sub copy_tree {
    my ($from, $to) = @_;
    return unless $from->is_dir;
    my $iter = $from->iterator({ recurse => 1 });
    while (my $f = $iter->()) {
        next if $f->is_dir || $f->basename =~ /\A\./;
        my $dest = $to->child($f->relative($from));
        $dest->parent->mkpath;
        $f->copy($dest);
    }
}

$out->child('css')->mkpath;
$root->child('design-system/tokens.css')->copy($out->child('css/tokens.css'));
$root->child('design-system/components/bundle.css')->copy($out->child('css/bundle.css'));
copy_tree($root->child('site/static'), $out);
copy_tree($root->child('static'), $out);

printf "Built %d posts, %d tags, %d pages into %s\n", scalar @posts, scalar keys %tags, $page_count, $out;
