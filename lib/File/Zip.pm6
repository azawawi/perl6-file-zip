
use v6;

unit class File::Zip;

has Str        $.file-name   is rw;
has Bool       $.debug       is rw;
has IO::Handle $.fh          is rw;
has Int        $.eocd-offset is rw;

method BUILD(Str :$file-name) {
  self.file-name = $file-name;
  self.fh        = $file-name.IO.open(:bin);

  my $eocd-offset = self._find-eocd-record-offset;
  die "Cannot find EOCD record" if $eocd-offset == -1;

  say "eocd offset is " ~ $eocd-offset;
}

method files {
  !!!
}

=begin markdown

=end markdown
method close {
  self.fh.close if self.fh.defined;
}

sub find-cd-offset(Str $file-name, Int $eocd-offset) {
    $fh.seek(-$eocd-offset, 2);

    my Buf $eocd-buf = $fh.read(22); 
    my ($signature, $number-disk, $disk-central-directory-on-disk, $number-central-directory-records-on-disk,
    $total-number-central-directory-records, $central-directory-size, $offset-central-directory, $comment-length) =
      $eocd-buf.unpack("L S S S S L L S");
      
    say $eocd-buf.unpack("L S S S S L L S").perl;
      
    printf("signature = %08x\n", $signature);
    say "size   = " ~ $central-directory-size;
    printf("offset = %08x\n", $offset-central-directory);
    say "number-central-directory-records-on-disk = $number-central-directory-records-on-disk";
    say "Comment length = " ~ $comment-length;
    say $disk-central-directory-on-disk;
    
    return ($offset-central-directory, $number-central-directory-records-on-disk);
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
