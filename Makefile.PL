use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $mm_ver = $ExtUtils::MakeMaker::VERSION;
if ($mm_ver =~ /_/) {
    # dev version
    $mm_ver = eval $mm_ver;
    die $@ if $@;
}

WriteMakefile(
    'NAME'		=> 'again',
    'VERSION_FROM'	=> 'lib/again.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1

    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/again.pm', # retrieve abstract from module
       AUTHOR     => 'Juerd <juerd@utp.juerd.net>') : ()),

    ($mm_ver >= 6.31 ? (LICENSE => 'perl') : ()),

    ($mm_ver <= 6.45 ? () : (META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            bugtracker  => 'http://rt.cpan.org/Public/Dist/Display.html?Name=again',
            repository  => {
                type => 'git',
                web  => 'https://github.com/neilbowers/again',
                url  => 'git://github.com/neilbowers/again.git',
            },
        },
    })),
);
