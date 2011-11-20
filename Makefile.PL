
use strict;
use warnings;

use 5.010001;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Web Document System",
  "AUTHOR" => "Mateu X Hunter <hunter\@missoula.org>",
  "BUILD_REQUIRES" => {
    "English" => 0,
    "File::Find" => 0,
    "File::Temp" => 0,
    "FindBin" => 0,
    "HTTP::Request" => 0,
    "HTTP::Request::Common" => 0,
    "JSON" => 0,
    "Plack::Middleware::Auth::Digest" => 0,
    "Plack::Test" => 0,
    "Plack::Util" => 0,
    "Test::Deep" => 0,
    "Test::Differences" => 0,
    "Test::Exception" => 0,
    "Test::More" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Mojito",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Mojito",
  "PREREQ_PM" => {
    "Cwd" => 0,
    "DBM::Deep" => 0,
    "Data::Dumper::Concise" => 0,
    "Digest::MD5" => 0,
    "Dir::Self" => 0,
    "File::Spec" => 0,
    "Git::Wrapper" => 0,
    "HTML::Strip" => 0,
    "HTML::Toc" => 0,
    "HTML::TocInsertor" => 0,
    "HTML::Zoom" => 0,
    "IO::File" => 0,
    "List::MoreUtils" => 0,
    "List::Util" => 0,
    "MongoDB" => 0,
    "MongoDB::OID" => 0,
    "Moo" => 0,
    "Moo::Role" => 0,
    "MooX::Types::MooseLike" => "0.02",
    "Path::Class" => 0,
    "Plack::Middleware" => 0,
    "Plack::Util::Accessor" => 0,
    "Pod::Simple::XHTML" => 0,
    "Sub::Quote" => 0,
    "Text::MultiMarkdown" => 0,
    "Text::Textile" => 0,
    "Text::WikiCreole" => 0,
    "Try::Tiny" => 0,
    "WWW::Mechanize" => 0,
    "parent" => 0,
    "strictures" => 1,
    "utf8" => 0
  },
  "VERSION" => "0.15",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



