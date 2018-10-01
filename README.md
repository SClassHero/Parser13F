# 13F-to-CSV Parser
Parsing a Form-13F text file to CSV file  
## Missing functions
### + Only for the 13F Amendmend filing: txt filing that the url is in the List13F YEAR QTRx_A.csv file:
+ Search if the txt file contains: "this filing list" and only process the filing that process such a string.
+ For the normal original 13F filing that the url in the List13F YEAR QTRx.csv file: process all in the list file.
### + Extract filing date
+ Date: Report for the calendar year or the quarter ended: December 32, 2006
+ Variation of expressions: Report for the quarter ended: December 31, 1999
+ OR Report for the Calendar Year or Quarter Ended December 31, 2006 (không có : )
### + Extract total Value of holdings (sum of the VALUE (x1000) column for each filing) 
+ Form 13F Information Table Value Total:: 
+ Có thể tìm thấy ở dòng: Form 13F information Table Value Total: $xxx,xxx . Thực ra giá trị này là theo đơn vị thousands (x1000)
+ Formats: 
Form 13F Information Table Value Total (x$1000): $xxx,xxx. 
+HOẶC
Form 13F Information Table Value Total: $1,025,504
                                        (in thousands)
+HOẶC
Form 13F Information Table Value Total : (bị để trống)
+HOẶC
Form 13F Information Table Value Total:	$ 2,694,264 (in thousands)
+HOẶC
Form 13F Information Table Value Total:	$ 2,694,264 
                                        ---------------------------
                                                        (thousands)
+ ===> May be manually add up the VALUE column then create a new Total Value Column ?
### + Extract CITY, ZIP, STATE variable:
+ Under the Business Address field near the beginning of the file
+ Example how it looks in the text file: 

+	BUSINESS ADDRESS:	
+		STREET 1:		65 EAST 55TH STREET, 19TH FLOOR
+		CITY:			NEW YORK
+		STATE:			NY
+		ZIP:			10022
+		BUSINESS PHONE:		2123713000


## Under-construction functions
### + Parsing Different Table formats

+ Cần làm thêm: Get rid of the Totals row at the end of some tables, possibly by Deleting rows that have blank value for CUSIP column, this should take care of the Totals row for the standard format. For the unconventional format (format 6) there is difficulty as below:

+ Tóm tắt đặc điểm chung của các format "chuẩn" (từ 1-5): Lưu ý Format 6 cũng có các đặc điểm này nhưng rất đặc biệt phải nhận dạng để lọc ra hoặc xử lý hơi khác đi.
o	Có 12 cột data.

o	Cột 1 (tên) bắt đầu bằng tag S ở dòng đầu, 11 cột kia có tag C. Tuy nhiên có thể có biến thể: S và C ở phía trên header hoặc dưới header. Hoặc số tag S và C ko tương ứng với số cột thực sự.

o	Toàn bộ bảng có thể nằm gọn trong 1 cặp tag TABLE hoặc bị ngắt.

o	Toàn bộ bảng nằm gọn trong 1 cặp tag PAGE hoặc bị ngắt ra giữa nhiều cặp tag.

o	Tên bảng “FORM 13F INFORMATION TABLE” Có thể nằm bên trong tag TABLE hoặc nằm ngoài, phía trên.

o	Có thể có hoặc ko có tag <CAPTION> bên trong <TABLE>.
  
o	Có thể có hoặc ko có dòng COLUMN 1 COLUMN2.

o	Dòng header (tên biến) có thể nằm gọn 1 dòng hoặc 2 dòng. Nhưng thứ tự các biến từ trái sang phải thì luôn giống nhau. Cho nên có thể nhận dạng header và bỏ qua ko đọc header.

#### Format 1: No tag "C" above each column
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
#### Format 2: Has tag "S" and "C" above each column
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
### + More standard Table formats:
#### Format 3: Similar to above formats, just different looks on the column name
```xml
<PAGE>

                           FORM 13F INFORMATION TABLE

                              WILMINGTON TRUST FSB

<TABLE>
<CAPTION>
COLUMN 1                   COLUMN 2   COLUMN 3 COLUMN 4   COLUMN 5        COLUMN 6  COLUMN 7       COLUMN 8
- ----------------------------------------------------------------------------------------------------------------
         NAME OF           TITLE OF              VALUE  SHRS OR SH/ PUT/ INVESTMENT   OTHER    VOTING AUTHORITY
          ISSUER            CLASS      CUSIP   [x$1000] PRN AMT PRN CALL DISCRETION MANAGERS   SOLE  SHARED NONE
- ----------------------------------------------------------------------------------------------------------------
<S>                       <C>        <C>       <C>      <C>     <C> <C>  <C>        <C>      <C>     <C>    <C>
AXIS CAPITAL HOLDINGS LTD COMMON     G0692U109      329   9,850 SH       SHARED     10         9,850           0
GLOBALSANTAFE CORP COMMON COMMON     G3930E101      674  11,464 SH       SHARED     10        11,464           0
                                                     18     300 SH       OTHER      10           300           0
INGERSOLL-RAND CO CLASS A COMMON     G4776G101      248   6,340 SH       SHARED     10         6,340           0
TRANSOCEAN INC COMMON     COMMON     G90078109      404   5,000 SH       SHARED     10         5,000           0
VERIGY LTD                       ORDINARY Y93691106        1            89 SH       Sole                        89        0        0
</TABLE>

</TEXT>
</DOCUMENT>
</SEC-DOCUMENT>
-----END PRIVACY-ENHANCED MESSAGE-----
```
#### Format 4: Table are broken betweeen several PAGE tag and/or TABLE tag but column name are not repeated only C tag
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
Abaxis, Inc.                         com  002567105   9750    429900 SH        Sole             310700        119200
Henry Brothers Electronics, In       com  426286100   1930    304000 SH        Sole             209400         94600
Hercules Offshore                    com  427093109   8190    240825 SH        Sole             174725         66100
</TABLE>

<PAGE>

<TABLE>
<S>                            <C> <C>       <C>   <C>     <C> <C>  <C>     <C>
Hoku Scientific Inc.           com 434712105  3003  469152 SH  Sole  309248 159904
Ikanos Communications          com 45173E105  9663  490275 SH  Sole  357600 132675
Immucor Inc.                   com 452526106   620   21600 SH  Sole   16600   5000
 Zoran Corp.                 com 98975F101 24838 1135188 SH    Sole  606300 528888
aQuantive, Inc.             com 03839G105 37502 1593117 SH    Sole  970415 622702
</TABLE>
</TEXT>
</DOCUMENT>
</SEC-DOCUMENT>
-----END PRIVACY-ENHANCED MESSAGE-----
 ```
#### Format 5: Table are broken betweeen several PAGE tag and/or TABLE tag and also have caption tag in between data and page number, column name are repeated on each page. Also there is a Totals row at the end of the table !
```xml
<PAGE>

<TABLE>
<CAPTION>
                                                    FORM 13F INFORMATION TABLE


            COLUMN 1           COLUMN 2    COLUMN 3   COLUMN 4            COLUMN 5        COLUMN 6   COLUMN 7        COLUMN 8
        ----------------  --------------   --------- ----------      -----------------   ----------  --------  ---------------------

                                                        VALUE       SHRS OR   SH/  PUT/  INVESTMENT   OTHER      VOTING AUTHORITY
         NAME OF ISSUER   TITLE OF CLASS    CUSIP     (x$1000)      PRN AMT   PRN  CALL  DISCRETION  MANAGERS  SOLE    SHARED   NONE
        ----------------  --------------   -------   ----------     -------   ---  ----  ----------  --------  ----    ------   ----

<S>                       <C>              <C>       <C>            <C>       <C>  <C>   <C>         <C>      <C>      <C>      <C>
Central Newspapers            common       154647101   $  10,852     275,600   SH            SOLE             242,100     33,500
Corn Products Inc.            common       219023108   $  13,699     418,300   SH            SOLE             367,400     50,900
Enesco Group                  common       292973104   $     591      53,450   SH            SOLE              44,350      9,100
Binks Sames Corp.             common       79587E104   $   3,995     264,150   SH            SOLE             228,950     35,200
Terex Corp.                   common       880779103   $  17,693     637,600   SH            SOLE             560,000     77,600


                                       3
<PAGE>

<CAPTION>
                                                                         FORM 13F INFORMATION TABLE


            COLUMN 1           COLUMN 2    COLUMN 3   COLUMN 4            COLUMN 5        COLUMN 6   COLUMN 7        COLUMN 8
        ----------------  --------------   --------- ----------      -----------------   ----------  --------  ---------------------

                                                        VALUE       SHRS OR   SH/  PUT/  INVESTMENT   OTHER      VOTING AUTHORITY
         NAME OF ISSUER   TITLE OF CLASS    CUSIP     (x$1000)      PRN AMT   PRN  CALL  DISCRETION  MANAGERS  SOLE    SHARED   NONE
        ----------------  --------------   -------   ----------     -------   ---  ----  ----------  --------  ----    ------   ----

<S>                       <C>              <C>       <C>          <C>         <C>  <C>   <C>         <C>      <C>      <C>      <C>
ACNielsen Corp.               common       004833109   $  16,075     652,800   SH            SOLE             574,500     78,300
U.S. Industries               common       912080108   $  16,231   1,159,330   SH            SOLE           1,018,030    141,300
  TOTALS                                                 $ 435,201  20,298,280                               17,836,480  2,461,800
</TABLE>

                                       4
</TEXT>
</DOCUMENT>
</SEC-DOCUMENT>
 ```
 
### + Some difficult/ unconventional formats: 
+ Proposed solutions for file that are too difficult: marked the txt filings in the LIST13F file as "UNPROCESSED" and save the file to a separate folder /Year/Quarter/
+ Count the number of occurences for such file per each quarter (per each LIST13F file)
#### Format 6: 
+ Dưới mỗi một ISSUER/ CUSIP lại có 1 dòng tính tổng Value của mã stock mua từ ISSUER đó. Hết 1 page lại có 1 dòng subtotal cho Page và cuối data lại có 1 totals tổng. Vị trí của chữ Subtotal lọt vào cả vị trí của Name of ISSUER và CUSIp
```xml
<PAGE>

<TABLE>
<CAPTION>
REPORT RUN>: 02/09/2000 at 09:59 AM           13-F EQUITIES DISCLOSURE BY AFFIRMATION                              PAGE   1
BUSINESS DATE: 02/09/2000                                                                                       R33.110.002

                                                          As of 12/31/1999

 HOLDING COMPANY:      (1) ROPES AND GRAY
                                                                              INVEST
                                                  MARKET                      INVEST AUTH   VOTING AUTH (SHARES)
NAME OF ISSUER                 CUSIP              VALUE            SH/PV      SOLE SHR MGR      SOLE            SHARED      NONE
- ------------------------------ ------------  ----------------- ------------   ---- --- ---- -----------       ---------- ---------
<S>                            <C>           <C>               <C>            <C>  <C> <C>  <C>               <C>        <C>
         COMMON
         ------

ABBOTT LABS                    002824100            289,773.76          7980  X                     7980              0          0
                                                  3,260,753.58         89797       X                   0          89797          0
                                                     65,362.50          1800       X     4             0           1800          0
                                             ----------------- --------------               -------------     ---------- ---------
                                                  3,615,889.84         99577                        7980          91597          0

AIR PRODS & CHEMS INC          009158106            216,478.13          6450  X                     6450              0          0
                                                    401,071.87         11950       X                   0          11950          0
                                             ----------------- --------------               -------------     ---------- ---------
                                                    617,550.00         18400                        6450          11950          0

ALLAIRE CORP                   016714107            292,624.00          2000  X                     2000              0          0

ALLMERICA FINL CORP            019754100            261,437.50          4700       X                   0           4700          0

AMERICA ONLINE INC DEL         02364J104              3,793.75            50  X                       50              0          0
                                                    291,891.13          3847       X                   0           3847          0
                                             ----------------- --------------               -------------     ---------- ---------
                                                    295,684.88          3897                          50           3847          0
AMERICAN INTL GROUP INC        026874107            625,935.66          5789  X                     5789              0          0
                                                  6,484,905.16         59976       X                 250          59726          0
                                                  1,303,122.51         12052       X     1             0          12052          0
                                                    422,228.14          3905       X     2             0           3905          0
                                                     60,766.25           562       X     3             0            562          0
                                             ----------------- --------------               -------------     ---------- ---------
         SUBTOTALS FOR THIS PAGE                 19,307,623.44        315932                       31294         284638          0

</TABLE>
<PAGE>

<TABLE>
<CAPTION>
REPORT RUN>: 02/09/2000 at 09:59 AM           13-F EQUITIES DISCLOSURE BY AFFIRMATION                              PAGE   2
BUSINESS DATE: 02/09/2000                                                                                       R33.110.002

                                                          As of 12/31/1999

HOLDING COMPANY:      (1) ROPES AND GRAY (Cont.)
                                                                              INVEST
                                                  MARKET                      INVEST AUTH   VOTING AUTH (SHARES)
NAME OF ISSUER                 CUSIP              VALUE            SH/PV      SOLE SHR MGR      SOLE            SHARED      NONE
- ------------------------------ ------------  ----------------- ------------   ---- --- ---- -----------       ---------- ---------
<S>                            <C>           <C>               <C>            <C>  <C> <C>  <C>               <C>        <C>

          COMMON (cont.)
         --------------

                                                     68,226.88           631       X     4             0            631          0
                                             ----------------- --------------               -------------     ---------- ---------
                                                  8,965,184.60         82915                        6039          76876          0

AMGEN INC                      031162100            282,291.40          4700  X                     4700              0          0
                                                    276,285.20          4600       X                   0           4600          0
                                             ----------------- --------------               -------------     ---------- ---------
                                                    558,576.60          9300                        4700           4600          0

ANHEUSER BUSCH COS IN          035229103            141,750.00          2000  X                     2000              0          0
                                                    131,118.75          1850       X                   0           1850          0
                                             ----------------- --------------               -------------     ---------- ---------
                                                    272,868.75          3850                        2000           1850          0
XEROX CORP                     984121103             68,062.50          3000  X                     3000              0          0
                                                    226,875.00         10000       X                   0          10000          0
                                             ----------------- --------------               -------------     ---------- ---------
                                                    294,937.50         13000                        3000          10000          0

YAHOO INC                      984332106            346,149.60           800  X                      800              0          0

                                             ----------------- --------------               -------------     ---------- ---------
         SUBTOTALS FOR THIS PAGE                  6,710,993.32        140979                       11764         129215          0


</TABLE>
<PAGE>

<TABLE>
<CAPTION>
REPORT RUN>: 02/09/2000 at 09:59 AM           13-F EQUITIES DISCLOSURE BY AFFIRMATION                              PAGE  17
BUSINESS DATE: 02/09/2000                                                                                       R33.110.002

                                                          As of 12/31/1999

HOLDING COMPANY:      (1) ROPES AND GRAY (Cont.)
                                                                              INVEST
                                                  MARKET                      INVEST AUTH   VOTING AUTH (SHARES)
NAME OF ISSUER                 CUSIP              VALUE            SH/PV      SOLE SHR MGR      SOLE            SHARED      NONE
- ------------------------------ ------------  ----------------- ------------   ---- --- ---- -----------       ---------- ---------
<S>                            <C>           <C>               <C>            <C>  <C> <C>  <C>               <C>        <C>

         COMMON (cont.)
         --------------

YOUNG BROADCASTING INC CL A    987434107            178,500.00          3500  X                     3500              0          0
                                                    678,300.00         13300       X                   0          13300          0
                                             ----------------- --------------               -------------     ---------- ---------
                                                    856,800.00         16800                        3500          13300          0

                                             ================= ==============               =============     ========== =========
TOTALS FOR COMMON                               234,733,953.22       3901315                      407670        3493646          0

                                             ================= ==============               =============     ========== =========
GRAND TOTALS                                    234,733,953.22       3901315                      407670        3493646          0

</TABLE>
<PAGE>

<TABLE>
<CAPTION>
REPORT RUN: 02/09/2000 at 09:59 AM             13-F EQUITIES DISCLOSURE BY AFFILATION                               PAGE     18
BUSINESS DATE: 02/09/2000                                                                                       R33.110.002

                                                          As of 12/31/1999

                             <S>                                <C>
                              MGR                               Client Name
                             ------                             ----------------------------------------
                                  1                             FRANCIS L COOLIDGE
                                  2                             EDWARD J JOYCE
                                  3                             EDWARD P LAWRENCE
                                  4                             SUSAN R SHAPIRO

</TABLE>
<PAGE>
 ```
 #### Format 7: các cột không nằm cùng hàng với nhau. Với Format 7 này, Format 8 và các format khác không giống với format chuẩn có thể đánh dấu lại vào list URL, lọc ra không xử lý và thống kê số lượng:
 ```xml
 <PAGE>

- ----------------------------------------
Paramount Capital Asset Management, Inc.
Form 13F
At 12/31/99
- ----------------------------------------

<TABLE>
<CAPTION>
- ---------------------------------------------------------------------------------
              Column 1                 Column 2       Column 3       Column 4
- ---------------------------------------------------------------------------------

                                                        CUSIP      Fair Market
           Name of Issuer          Title of Class      Number    Value (x $1000)
           --------------          --------------      ------    ---------------

- ---------------------------------------------------------------------------------
<S>                                <C>               <C>               <C>
Abgenix, Inc                            Common       00339B107           $966.85
                                                                       $2,402.89
                                                                          $75.26
- ---------------------------------------------------------------------------------
American Craft Brewing-Warrants    Common warrants   N/A                   $0.47
                                                                           $1.09
                                                                           $0.00
- ---------------------------------------------------------------------------------
Adaptive Broadband Corp.                Common       00650M104         $1,200.49
                                                                       $3,023.43
                                                                          $94.11
- ---------------------------------------------------------------------------------
Andrx Corp.                             Common       034551101         $9,653.43
                                                                      $23,994.53
                                                                         $752.61
  
<CAPTION>
- -------------------------------------------------------------------------------------------------------------
              Column 1                 Column 5                   Column 6   Column 7               Column 8
- -------------------------------------------------------------------------------------------------------------

                                      Shares or     SH/    Put/  Investment   Other         Voting Authority
                                                                                            ----------------
           Name of Issuer         Principal Amount  PRN    Call  Discretion  Managers    Sole   Shared   None
           --------------         ----------------  ---    ----  ----------  --------    ----   ------   ----

- -------------------------------------------------------------------------------------------------------------
<S>                                         <C>      <C>   <C>       <C>      <C>        <C>      <C>    <C>
Abgenix, Inc                                 7,297   SH               X       No. 2               X
                                            18,135   SH               X       No. 1               X
                                               568   SH               X                           X
- -------------------------------------------------------------------------------------------------------------
American Craft Brewing-Warrants             15,000   SH               X       No. 2               X
                                            35,000   SH               X       No. 1               X
                                                 0   SH               X                           X
- -------------------------------------------------------------------------------------------------------------
Adaptive Broadband Corp.                    16,264   SH               X       No. 2               X
                                            40,961   SH               X       No. 1               X
                                             1,275   SH               X                           X
- -------------------------------------------------------------------------------------------------------------
Andrx Corp.                                228,146   SH               X       No. 2               X
                                           567,079   SH               X       No. 1               X
                                            17,787   SH               X                           X
 </TABLE>

<PAGE>

- ----------------------------------------
Paramount Capital Asset Management, Inc.
Form 13F
At 12/31/99
- ----------------------------------------

<TABLE>
<CAPTION>
- ---------------------------------------------------------------------------------------
              Column 1                        Column 2       Column 3       Column 4
- ---------------------------------------------------------------------------------------

                                                               CUSIP       Fair Market
           Name of Issuer                 Title of Class      Number    Value (x $1000)
           --------------                 --------------      ------    ---------------

- ---------------------------------------------------------------------------------------
<S>                                       <C>               <C>              <C>
Aspect Telecommunications                      Common       04523Q102           $111.47
                                                                                $286.67
                                                                                  $8.76
- ---------------------------------------------------------------------------------------
Astea International Inc.                       Common       04622E109           $152.33
                                                                                $387.17
                                                                                 $11.97
<CAPTION>
- ---------------------------------------------------------------------------------------------------------------------
              Column 1                        Column 5                    Column 6   Column 7           Column 8
- ---------------------------------------------------------------------------------------------------------------------

                                              Shares or     SH/    Put/  Investment   Other        Voting Authority
                                                                                                   ----------------
           Name of Issuer                 Principal Amount  PRN    Call  Discretion  Managers    Sole   Shared   None
           --------------                 ----------------  ---    ----  ----------  --------    ----   ------   ----

- ---------------------------------------------------------------------------------------------------------------------
<S>                                               <C>        <C>   <C>       <C>       <C>       <C>       <C>    <C>
Aspect Telecommunications                            2,849   SH               X        No. 2               X
                                                     7,327   SH               X        No. 1               X
                                                       224   SH               X                            X
- ---------------------------------------------------------------------------------------------------------------------
Astea International Inc.                            28,341   SH               X        No. 2               X
                                                    72,032   SH               X        No. 1               X
                                                     2,227   SH               X                            X
  ```
  #### Format 8: Format bá đạo, thông tin từng cột viết riêng ra theo chiều dọc. Format này nếu không xử lý được có thể lọc đi và đếm số file dính
 ```xml
<PAGE>


<TABLE>
FORM 13F INFORMATION TABLE
<C>
NAME OF ISSUER
- --------------
3COM CORP
AAR CORP
AT&T CORPORATION
<C>
TITLE OF CLASS
- --------------
COM
COM
COM
<C>
CUSIP NO.
- ---------
885535104
000361105
001957109
<C>
VALUE
- --------------
370,830.00
4,215,216.00
16,597,176.12

.... vân vân và mây mây cho đủ tất cả các cột
</TABLE>


</TEXT>
 ```
