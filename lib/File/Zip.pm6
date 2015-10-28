
use v6;

use File::Zip::EndOfCentralDirectoryHeader;
use File::Zip::CentralDirectoryHeader;

=begin markdown

Please see https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT

=end markdown

unit class File::Zip;

has Str        $.file-name   is rw;
has Bool       $.debug       is rw;
has IO::Handle $.fh          is rw;
has Int        $.eocd-offset is rw;
has            $.eocd-header is rw;
has            @.cd-headers  is rw;

method BUILD(Str :$file-name) {
  self.file-name = $file-name;
  self.fh        = $file-name.IO.open(:bin);

  my $eocd-offset = self._find-eocd-record-offset;
  die "Cannot find EOCD record" if $eocd-offset == -1;

  say "eocd offset is " ~ $eocd-offset;
  my $eocd-header = File::Zip::EndOfCentralDirectoryHeader.new;
  $eocd-header.read-from-handle(self.fh, $eocd-offset);
  self.eocd-header = $eocd-header;
  say $eocd-header.perl;

  self.read-cd-headers;
}

method files {
  my @files;
  for @.cd-headers -> $cd-header {
    @files.push( { filename => $cd-header.file-name } );
  }

  return @files;
}

=begin markdown

=end markdown
method close {
  self.fh.close if self.fh.defined;
}

method read-cd-headers {
  self.fh.seek(self.eocd-header.offset-central-directory, 0);

  my $number-records = self.eocd-header.number-central-directory-records-on-disk;
  my @cd-headers;
  for 1..$number-records -> $i {
    my $cd-header = File::Zip::CentralDirectoryHeader.new;
    $cd-header.read-from-handle(self.fh);
    @cd-headers.push( $cd-header );
  }
  self.cd-headers = @cd-headers;
}

=begin markdown

  Private method to scan for the end of central directory record signature
  starting from the end of the zip file.

=end markdown
method _find-eocd-record-offset {

  # Find file size
  self.fh.seek(0, 2);
  my $file-size = self.fh.tell;

  say "File size is $file-size";

  # Find EOCD hexidecimal signature 0x04034b50 in little endian
  for 0..$file-size-1 -> $offset {
    self.fh.seek(-$offset, 2);
    my Buf $bytes = self.fh.read(4);
    return $offset if $bytes[0] == 0x50 && $bytes[1] == 0x4b && $bytes[2] == 0x05 && $bytes[3] == 0x06;
  }

  return -1;
}
