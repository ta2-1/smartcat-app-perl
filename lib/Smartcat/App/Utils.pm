package Smartcat::App::Utils;

use strict;
use warnings;

use File::Basename;

our @ISA = qw(Exporter);

our @EXPORT = qw(
  prepare_document_name
  prepare_file_name
  save_file
  get_language_from_ts_filepath
  get_ts_file_key
  get_document_key
  format_error_message
);

sub get_language_from_ts_filepath {
    $_ = shift;
    return basename( dirname($_) );
}

sub get_ts_file_key {
    $_ = shift;
    return basename($_) . ' (' . get_language_from_ts_filepath($_) . ')';
}

sub get_document_key {
    my ( $name, $target_language ) = @_;

    my $key = $name;
    $key =~ s/_($target_language)$//i;
    return $key . ' (' . $target_language . ')';
}

sub prepare_document_name {
    my ( $path, $filetype, $target_language ) = @_;

    my ( $filename, $_dirs, $ext ) = fileparse( $path, $filetype );

    return $filename . '_' . $target_language . $ext;
}

sub prepare_file_name {
    my ( $document_name, $document_target_language, $ext ) = @_;

    my $regexp = qr/_$document_target_language/;
    $document_name =~ s/(.*)$regexp/$1/;

    return $document_name . $ext;
}

sub format_error_message {
    my $s = shift;

    $s = "  " . $s;
    $s =~ s/\\r//;
    $s =~ s/\\n/\n/;
    $s =~ s/\n/\n  /;

    return $s;
}

sub save_file {
    my ( $filepath, $content ) = @_;
    open( my $fh, '>', $filepath ) or die "Could not open file '$filepath' $!";
    binmode($fh);
    print $fh $content;
    close $fh;
}

1;
