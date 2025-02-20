# StrTable

StrTable is a powerful and highly configurable ASCII table generator for AutoHotkey v2. It allows you to format tabular data from strings, arrays, or clipboard contents with customizable headers, borders, alignments, and padding.

## Features
✓ Supports string (CSV-like), array, and clipboard input  
✓ Customizable headers, borders, separators, padding, and alignment  
✓ Auto-detects delimiters in CSV-style input  
✓ Titlecase, Uppercase, and Lowercase formatting options  
✓ Adjustable padding and float precision  
✓ Option to remove borders

## From string
```
#include StrTable.ahk
s := "Name,Age,Rank`nTony Soprano,47,Boss`nCristopher Moltisanti,30,Capo"
table := StrTable(s)
A_Clipboard := table.convert()
```
Output:
```
+-----------------------+-----+------+
|         Name          | Age | Rank |
+-----------------------+-----+------+
| Tony Soprano          | 47  | Boss |
| Cristopher Moltisanti | 30  | Capo |
+-----------------------+-----+------+
```
## From array
```
a := [["A", "B", "C"], [4, "ahk v2", 6.2], [7, 8.567, 9], [true, 11, "42"]]
a := StrTable(a1)
a.header_format := "Titlecase"
a.header_alignment := "Left"
a.header := ["X", "-", "x", "."]
A_Clipboard := a1.convert()
```
Output:
```
X---x--------x-------x
| A | B      | C     |
x...x........x.......x
| 4 | ahk v2 | 6.200 |
| 7 | 8.567  | 9     |
| 1 | 11     | 42    |
+---+--------+-------+
```
## From string changing the properties
```
; From string changing the padding, alignment and removing the border
s2 := "Name,Age,Rank`nTony Soprano,47,Boss`nCristopher Moltisanti,30,Capo"
s2 := StrTable(s2, False)
s2.padding := 1
s2.remove_border()
s2.line_alignment := "Right"
Outputdebug(s2.convert(limit := 2))
```
Output: 
```
         Name           Age  Rank 
          Tony Soprano   47  Boss 
 Cristopher Moltisanti   30  Capo 
```
