--
-- P  (Procedure) 
--
--  Dependencies: 
--   STANDARD (Package)
--   HTP (Synonym)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE procedure p (l_text in VARCHAR2)
as
begin
    htp.prn(l_text);
END;
/


