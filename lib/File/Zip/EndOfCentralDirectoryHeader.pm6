
use v6;

unit class EndOfCentralDirectoryHeader;

has $.signature is rw;
has $.number-disk is rw;
has $.disk-central-directory-on-disk is rw;
has $.number-central-directory-records-on-disk is rw;
has $.total-number-central-directory-records is rw;
has $.central-directory-size is rw;
has $.offset-central-directory is rw;
has $.comment-length;
has Str $.comment;