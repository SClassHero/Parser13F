# 13F-to-CSV Parser
Parsing a Form-13F text file to CSV file  
## Missing functions
### + Extract date
+ Date: Report for the calendar year or the quarter ended: December 32, 2006
## Under-construction functions
### + Parsing Different Table formats
#### Format 1
```xml
  <TABLE>                 <C>                                               <C>
          FORM 13F INFORMATION TABLE

  NAME OF               TITLE OF    CUSIP       VALUE    SHARES/   SH/   PUT/    INVSTMT OTHER         VOTING AUTHORITY
  ISSUER                   CLASS              (X$1000)   PRN AMT   PRN   CALL    DSCRETN MANAGERS  SOLE     SHARED      NONE

  Kepco ADR                  COM    500631106    41069   3892807    SH             SOLE            3649807             243000
  Petrobras ADR              COM    71654V408   183940   5218150    SH             SOLE            4431750	     786400
  Telefonos de Mexico ADR    COM    879403780   161164   4994244    SH             SOLE            4148644             845600
...
  </TABLE>
```
#### Format 2
```xml
<PAGE>

Oberweis Asset Management, Inc.
FORM 13F
                         31-Mar-06

<TABLE>
<CAPTION>
                                                                                      Voting Authority
                                    Title                                             ----------------
                                     of              Value   Shares/ Sh/ Put/ Invstmt  Other
Name of Issuer                      class   CUSIP   (x$1000) Prn Amt Prn Call Dscretn Managers  Sole   Shared  None
- --------------                      ----- --------- -------- ------- --- ---- ------- -------- ------- ------ ------
<S>                                 <C>   <C>       <C>      <C>     <C> <C>  <C>     <C>      <C>     <C>    <C>
A D A M Inc.                         com  00088U108   2592    367700 SH        Sole             253100        114600
AAR Corp.                            com  000361105    367     12900 SH        Sole               9900          3000
ASV Inc.                             com  001963107  47310   1468334 SH        Sole             896744        571590
...
<\TABLE>
```
