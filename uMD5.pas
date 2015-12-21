unit uMd5;
interface

uses
  Windows,
  SysUtils,
  RtlConsts,
  Classes;
type

  TMD5In = array[0..15] of cardinal;
  /// 128 bits memory block for MD5 hash digest storage
  TMD5Digest = array[0..15] of Byte;
  PMD5 = ^TMD5;
  TMD5Buf = array[0..3] of cardinal;
  /// handle MD5 hashing
  TMD5 = object
  private
    buf: TMD5Buf;
    bytes: array[0..1] of cardinal;
    in_: TMD5In;
  public
    /// initialize MD5 context for hashing
    procedure Init;
    /// update the MD5 context with some data
    procedure Update(const buffer; Len: cardinal);
    /// finalize and compute the resulting MD5 hash Digest of all data
    // affected to Update() method
    function Final: TMD5Digest;
    /// one method to rule them all
    // - call Init, then Update(), then Final()
    procedure Full(Buffer: pointer; Len: integer; out Digest: TMD5Digest);
  end;

function MD5Buf(const Buffer; Len: Cardinal): TMD5Digest;
function MD5String(const s: AnsiString): AnsiString;
function MD5DigestsEqual(const A, B: TMD5Digest): Boolean;
function MD5DigestToString(const D: TMD5Digest): AnsiString;
function MD5Stream(Stream: TStream): AnsiString;
function MD5File(szFilename: string): AnsiString;
function MD5Hash(Stream: TStream): AnsiString;

implementation

{ TMD5 }

procedure MD5Transform(var buf: TMD5Buf; const in_: TMD5In);
var a, b, c, d: cardinal; // unrolled -> compiler will only use cpu registers :)
// the code below is very fast, and can be compared proudly against C or ASM
begin
  a := buf[0];
  b := buf[1];
  c := buf[2];
  d := buf[3];
  Inc(a, in_[0] + $d76aa478 + (d xor (b and (c xor d))));  a := ((a shl 7) or (a shr (32-7))) + b;
  Inc(d, in_[1] + $e8c7b756 + (c xor (a and (b xor c))));  d := ((d shl 12) or (d shr (32-12))) + a;
  Inc(c, in_[2] + $242070db + (b xor (d and (a xor b))));  c := ((c shl 17) or (c shr (32-17))) + d;
  Inc(b, in_[3] + $c1bdceee + (a xor (c and (d xor a))));  b := ((b shl 22) or (b shr (32-22))) + c;
  Inc(a, in_[4] + $f57c0faf + (d xor (b and (c xor d))));  a := ((a shl 7) or (a shr (32-7))) + b;
  Inc(d, in_[5] + $4787c62a + (c xor (a and (b xor c))));  d := ((d shl 12) or (d shr (32-12))) + a;
  Inc(c, in_[6] + $a8304613 + (b xor (d and (a xor b))));  c := ((c shl 17) or (c shr (32-17))) + d;
  Inc(b, in_[7] + $fd469501 + (a xor (c and (d xor a))));  b := ((b shl 22) or (b shr (32-22))) + c;
  Inc(a, in_[8] + $698098d8 + (d xor (b and (c xor d))));  a := ((a shl 7) or (a shr (32-7))) + b;
  Inc(d, in_[9] + $8b44f7af + (c xor (a and (b xor c))));  d := ((d shl 12) or (d shr (32-12))) + a;
  Inc(c, in_[10] + $ffff5bb1 + (b xor (d and (a xor b))));  c := ((c shl 17) or (c shr (32-17))) + d;
  Inc(b, in_[11] + $895cd7be + (a xor (c and (d xor a))));  b := ((b shl 22) or (b shr (32-22))) + c;
  Inc(a, in_[12] + $6b901122 + (d xor (b and (c xor d))));  a := ((a shl 7) or (a shr (32-7))) + b;
  Inc(d, in_[13] + $fd987193 + (c xor (a and (b xor c))));  d := ((d shl 12) or (d shr (32-12))) + a;
  Inc(c, in_[14] + $a679438e + (b xor (d and (a xor b))));  c := ((c shl 17) or (c shr (32-17))) + d;
  Inc(b, in_[15] + $49b40821 + (a xor (c and (d xor a))));  b := ((b shl 22) or (b shr (32-22))) + c;
  Inc(a, in_[1] + $f61e2562 + (c xor (d and (b xor c))));  a := ((a shl 5) or (a shr (32-5))) + b;
  Inc(d, in_[6] + $c040b340 + (b xor (c and (a xor b))));  d := ((d shl 9) or (d shr (32-9))) + a;
  Inc(c, in_[11] + $265e5a51 + (a xor (b and (d xor a))));  c := ((c shl 14) or (c shr (32-14))) + d;
  Inc(b, in_[0] + $e9b6c7aa + (d xor (a and (c xor d))));  b := ((b shl 20) or (b shr (32-20))) + c;
  Inc(a, in_[5] + $d62f105d + (c xor (d and (b xor c))));  a := ((a shl 5) or (a shr (32-5))) + b;
  Inc(d, in_[10] + $02441453 + (b xor (c and (a xor b))));  d := ((d shl 9) or (d shr (32-9))) + a;
  Inc(c, in_[15] + $d8a1e681 + (a xor (b and (d xor a))));  c := ((c shl 14) or (c shr (32-14))) + d;
  Inc(b, in_[4] + $e7d3fbc8 + (d xor (a and (c xor d))));  b := ((b shl 20) or (b shr (32-20))) + c;
  Inc(a, in_[9] + $21e1cde6 + (c xor (d and (b xor c))));  a := ((a shl 5) or (a shr (32-5))) + b;
  Inc(d, in_[14] + $c33707d6 + (b xor (c and (a xor b))));  d := ((d shl 9) or (d shr (32-9))) + a;
  Inc(c, in_[3] + $f4d50d87 + (a xor (b and (d xor a))));  c := ((c shl 14) or (c shr (32-14))) + d;
  Inc(b, in_[8] + $455a14ed + (d xor (a and (c xor d))));  b := ((b shl 20) or (b shr (32-20))) + c;
  Inc(a, in_[13] + $a9e3e905 + (c xor (d and (b xor c))));  a := ((a shl 5) or (a shr (32-5))) + b;
  Inc(d, in_[2] + $fcefa3f8 + (b xor (c and (a xor b))));  d := ((d shl 9) or (d shr (32-9))) + a;
  Inc(c, in_[7] + $676f02d9 + (a xor (b and (d xor a))));  c := ((c shl 14) or (c shr (32-14))) + d;
  Inc(b, in_[12] + $8d2a4c8a + (d xor (a and (c xor d))));  b := ((b shl 20) or (b shr (32-20))) + c;
  Inc(a, in_[5] + $fffa3942 + (b xor c xor d));  a := ((a shl 4) or (a shr (32-4))) + b;
  Inc(d, in_[8] + $8771f681 + (a xor b xor c));  d := ((d shl 11) or (d shr (32-11))) + a;
  Inc(c, in_[11] + $6d9d6122 + (d xor a xor b));  c := ((c shl 16) or (c shr (32-16))) + d;
  Inc(b, in_[14] + $fde5380c + (c xor d xor a));  b := ((b shl 23) or (b shr (32-23))) + c;
  Inc(a, in_[1] + $a4beea44 + (b xor c xor d));  a := ((a shl 4) or (a shr (32-4))) + b;
  Inc(d, in_[4] + $4bdecfa9 + (a xor b xor c));  d := ((d shl 11) or (d shr (32-11))) + a;
  Inc(c, in_[7] + $f6bb4b60 + (d xor a xor b));  c := ((c shl 16) or (c shr (32-16))) + d;
  Inc(b, in_[10] + $bebfbc70 + (c xor d xor a));  b := ((b shl 23) or (b shr (32-23))) + c;
  Inc(a, in_[13] + $289b7ec6 + (b xor c xor d));  a := ((a shl 4) or (a shr (32-4))) + b;
  Inc(d, in_[0] + $eaa127fa + (a xor b xor c));  d := ((d shl 11) or (d shr (32-11))) + a;
  Inc(c, in_[3] + $d4ef3085 + (d xor a xor b));  c := ((c shl 16) or (c shr (32-16))) + d;
  Inc(b, in_[6] + $04881d05 + (c xor d xor a));  b := ((b shl 23) or (b shr (32-23))) + c;
  Inc(a, in_[9] + $d9d4d039 + (b xor c xor d));  a := ((a shl 4) or (a shr (32-4))) + b;
  Inc(d, in_[12] + $e6db99e5 + (a xor b xor c));  d := ((d shl 11) or (d shr (32-11))) + a;
  Inc(c, in_[15] + $1fa27cf8 + (d xor a xor b));  c := ((c shl 16) or (c shr (32-16))) + d;
  Inc(b, in_[2] + $c4ac5665 + (c xor d xor a));  b := ((b shl 23) or (b shr (32-23))) + c;
  Inc(a, in_[0] + $f4292244 + (c xor (b or (not d))));  a := ((a shl 6) or (a shr (32-6))) + b;
  Inc(d, in_[7] + $432aff97 + (b xor (a or (not c))));  d := ((d shl 10) or (d shr (32-10))) + a;
  Inc(c, in_[14] + $ab9423a7 + (a xor (d or (not b))));  c := ((c shl 15) or (c shr (32-15))) + d;
  Inc(b, in_[5] + $fc93a039 + (d xor (c or (not a))));  b := ((b shl 21) or (b shr (32-21))) + c;
  Inc(a, in_[12] + $655b59c3 + (c xor (b or (not d))));  a := ((a shl 6) or (a shr (32-6))) + b;
  Inc(d, in_[3] + $8f0ccc92 + (b xor (a or (not c))));  d := ((d shl 10) or (d shr (32-10))) + a;
  Inc(c, in_[10] + $ffeff47d + (a xor (d or (not b))));  c := ((c shl 15) or (c shr (32-15))) + d;
  Inc(b, in_[1] + $85845dd1 + (d xor (c or (not a))));  b := ((b shl 21) or (b shr (32-21))) + c;
  Inc(a, in_[8] + $6fa87e4f + (c xor (b or (not d))));  a := ((a shl 6) or (a shr (32-6))) + b;
  Inc(d, in_[15] + $fe2ce6e0 + (b xor (a or (not c))));  d := ((d shl 10) or (d shr (32-10))) + a;
  Inc(c, in_[6] + $a3014314 + (a xor (d or (not b))));  c := ((c shl 15) or (c shr (32-15))) + d;
  Inc(b, in_[13] + $4e0811a1 + (d xor (c or (not a))));  b := ((b shl 21) or (b shr (32-21))) + c;
  Inc(a, in_[4] + $f7537e82 + (c xor (b or (not d))));  a := ((a shl 6) or (a shr (32-6))) + b;
  Inc(d, in_[11] + $bd3af235 + (b xor (a or (not c))));  d := ((d shl 10) or (d shr (32-10))) + a;
  Inc(c, in_[2] + $2ad7d2bb + (a xor (d or (not b))));  c := ((c shl 15) or (c shr (32-15))) + d;
  Inc(b, in_[9] + $eb86d391 + (d xor (c or (not a))));  b := ((b shl 21) or (b shr (32-21))) + c;
  Inc(buf[0], a);
  Inc(buf[1], b);
  Inc(buf[2], c);
  Inc(buf[3], d);
end;

function TMD5.Final: TMD5Digest;
var count: Integer;
    p: ^Byte;
begin
  count := bytes[0] and $3f;  { Number of bytes in in }
  p := @in_;
  Inc(p, count);
  { Set the first char of padding to 0x80.  There is always room. }
  p^ := $80;
  Inc(p);
  { Bytes of padding needed to make 56 bytes (-8..55) }
  count := 56 - 1 - count;
  if count < 0 then begin  { Padding forces an extra block }
    FillChar(p^, count + 8, 0);
    MD5Transform(buf, in_);
    p := @in_;
    count := 56;
  end;
  FillChar(p^, count, 0);
  { Append length in bits and transform }
  in_[14] := bytes[0] shl 3;
  in_[15] := (bytes[1] shl 3) or (bytes[0] shr 29);
  MD5Transform(buf, in_);
  Move(buf, Result, 16);
end;

procedure TMD5.Full(Buffer: pointer; Len: integer; out Digest: TMD5Digest);
begin
  Init;
  Update(Buffer^,Len);
  Digest := Final;
end;

procedure TMD5.Init;
begin
  buf[0] := $67452301;
  buf[1] := $efcdab89;
  buf[2] := $98badcfe;
  buf[3] := $10325476;
  bytes[0] := 0;
  bytes[1] := 0;
end;

procedure TMD5.Update(const buffer; len: Cardinal);
var p: ^TMD5In;
    t: cardinal;
    i: integer;
begin
  p := @buffer;
  { Update byte count }
  t := bytes[0];
  Inc(bytes[0], len);
  if bytes[0]<t then
    Inc(bytes[1]);  { Carry from low to high }
  t := 64 - (t and $3f);  { Space available in in (at least 1) }
  if t>len then begin
    Move(p^, Pointer(Cardinal(@in_) + 64 - t)^, len);
    Exit;
  end;
  { First chunk is an odd size }
  Move(p^, Pointer(Cardinal(@in_) + 64 - t)^, t);
  MD5Transform(buf, in_);
  Inc(cardinal(p), t);
  Dec(len, t);
  { Process data in 64-byte chunks }
  for i := 1 to len div 64 do begin
    MD5Transform(buf, p^);
    Inc(p);
  end;
  { Handle any remaining bytes of data. }
  Move(p^, in_, len mod 64);
end;

function MD5Buf(const Buffer; Len: Cardinal): TMD5Digest;
var MD5: TMD5;
begin
  MD5.Full(@Buffer,Len,result);
end;

function MD5DigestsEqual(const A, B: TMD5Digest): Boolean;
begin
  result := CompareMem(@A,@B,sizeof(TMD5Digest));
end;

const Digits: array[0..15] of Char = '0123456789abcdef';

function MD5DigestToString(const D: TMD5Digest): AnsiString;
var P: PAnsiChar;
    I: Integer;
begin
  SetLength(result,sizeof(D)*2);
  P := pointer(result);
  for I := 0 to sizeof(D)-1 do begin
    P[0] := Digits[D[I] shr 4];
    P[1] := Digits[D[I] and 15];
    Inc(P,2);
  end;
end;

function MD5Stream(Stream: TStream): AnsiString;
var
  nLen: Integer;
  buf: array[0..255] of char;
  alg: TMD5;
  oldpos: Longint;
begin
  Result := '';
  alg.Init; 
  oldpos := Stream.Position;
  try
    Stream.Position := 0;
    nLen := 256;
    while nLen = 256 do
    begin
      nLen := Stream.Read(buf, nLen);
      alg.Update(buf, nLen);
    end;
    Result := MD5DigestToString(alg.Final);
  finally
    Stream.Position := oldpos;
  end;
end;

function MD5File(szFilename: string): AnsiString;
var
  f: TFileStream;
begin
  Result := '';
  f := TFileStream.Create(szFilename, fmOpenRead + fmShareDenyWrite);
  try
    Result := MD5Stream(f);
  finally
    f.Free
  end;
end;

function MD5String(const s: AnsiString): AnsiString;
begin
  result := MD5DigestToString(MD5Buf(s[1],length(s)));
end;

function MD5Hash(Stream: TStream): AnsiString;
  function ByteToHex(InByte:byte):shortstring;
  const
    Digits:array[0..15] of char='0123456789ABCDEF';
  begin
    Result := digits[InByte shr 4] + digits[InByte and $0F];
  end;
var
  d: TMD5Digest;
  i: Integer;
  hex: string;
  buffer: array of Byte;
begin
  SetLength(buffer, Stream.Size);
  Stream.ReadBuffer(buffer[0], Stream.Size);
  d := MD5Buf(buffer[0], Stream.Size);

  for i := 0 to High(d) do
  begin
    if hex <> '' then
      hex := hex + '-';
    hex := hex + ByteToHex(d[i]);
  end;

  Result := hex;
end;

end.

