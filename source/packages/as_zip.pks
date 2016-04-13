CREATE OR REPLACE package as_zip
is
/**********************************************
**
** Author: Anton Scheffer
** Date: 25-01-2012
** Website: http://technology.amis.nl/blog
**
** Changelog:
**   Date: 29-04-2012
**    fixed bug for large uncompressed files, thanks Morten Braten
**   Date: 21-03-2012
**     Take CRC32, compressed length and uncompressed length from
**     Central file header instead of Local file header
**   Date: 17-02-2012
**     Added more support for non-ascii filenames
**   Date: 25-01-2012
**     Added MIT-license
**     Some minor improvements
**   Date: 31-01-2014
**     file limit increased to 4GB
******************************************************************************
******************************************************************************
Copyright (C) 2010,2011 by Anton Scheffer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

******************************************************************************
******************************************** */
  type file_list is table of clob;
--
  function file2blob
    ( p_dir varchar2
    , p_file_name varchar2
    )
  return blob;
--
  function get_file_list
    ( p_dir varchar2
    , p_zip_file varchar2
    , p_encoding varchar2 := null
    )
  return file_list;
--
  function get_file_list
    ( p_zipped_blob blob
    , p_encoding varchar2 := null
    )
  return file_list;
--
  function get_file
    ( p_dir varchar2
    , p_zip_file varchar2
    , p_file_name varchar2
    , p_encoding varchar2 := null
    )
  return blob;
--
  function get_file
    ( p_zipped_blob blob
    , p_file_name varchar2
    , p_encoding varchar2 := null
    )
  return blob;
--
  procedure add1file
    ( p_zipped_blob in out blob
    , p_name varchar2
    , p_content blob
    );
--
  procedure finish_zip( p_zipped_blob in out blob );
--
  procedure save_zip
    ( p_zipped_blob blob
    , p_dir varchar2 := 'MY_DIR'
    , p_filename varchar2 := 'my.zip'
    );
--
/*
declare
  g_zipped_blob blob;
begin
  as_zip.add1file( g_zipped_blob, 'test4.txt', null ); -- a empty file
  as_zip.add1file( g_zipped_blob, 'dir1/test1.txt', utl_raw.cast_to_raw( q'<A file with some more text, stored in a subfolder which isn't added>' ) );
  as_zip.add1file( g_zipped_blob, 'test1234.txt', utl_raw.cast_to_raw( 'A small file' ) );
  as_zip.add1file( g_zipped_blob, 'dir2/', null ); -- a folder
  as_zip.add1file( g_zipped_blob, 'dir3/', null ); -- a folder
  as_zip.add1file( g_zipped_blob, 'dir3/test2.txt', utl_raw.cast_to_raw( 'A small filein a previous created folder' ) );
  as_zip.finish_zip( g_zipped_blob );
  as_zip.save_zip( g_zipped_blob, 'MY_DIR', 'my.zip' );
  dbms_lob.freetemporary( g_zipped_blob );
end;
--
declare
  zip_files as_zip.file_list;
begin
  zip_files  := as_zip.get_file_list( 'MY_DIR', 'my.zip' );
  for i in zip_files.first() .. zip_files.last
  loop
    dbms_output.put_line( zip_files( i ) );
    dbms_output.put_line( utl_raw.cast_to_varchar2( as_zip.get_file( 'MY_DIR', 'my.zip', zip_files( i ) ) ) );
  end loop;
end;
*/
end;
/