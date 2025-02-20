; Script     StrTable.ahk
; License:   MIT License
; Author:    Bence Markiel (bceenaeiklmr)
; Github:    https://github.com/bceenaeiklmr/StrTable
; Date       20.02.2025
; Version    0.1.0

#Requires AutoHotkey v2.0
#Warn

; Create an ascii table from a string or an array
class StrTable {

    ; Properties
    has_header := True
    header_format := "Titlecase"
    line_format := ""
    header_alignment := "center"
    line_alignment := "left"
    separator := "|"
    header := ["+", "-"]
    bottom := ["+", "-"]
    float_precision := 3
    padding := 1

    ; Add a line with the specified characters
    add_line(char_first := "+", char := "-") {
        str := char_first
        loop this.lengths.length {
            loop this.lengths[A_Index] + 2 * this.padding
                str .= char
            str .= char_first
        }
        return str .= "`n"
    }

    ; Reformat the cell
    cell_format(regex, str) {
        switch {
            case (regex ~= "i)^l(ower)?(case)?$"): str := Format("{:L}", str)
            case (regex ~= "i)^T(itle)?(case)?$"): str := Format("{:T}", str)
            case (regex ~= "i)^U(PPER)?(case)?$"): str := Format("{:U}", str)
        }
        return str
    }

    ; Convert the data to a string
    convert(limit := 0) {

        ; Allocate memory for the string
        bytes := (this.data.Length + 3) * StrLen(this.add_line()) * 2 - 2
        VarSetStrCapacity(&str, bytes)
        
        ; Open with a decorator line
        if (this.header[1] != "" && this.header[2] != "") {
            str .= this.add_line(this.header[1], this.header[2])
        }

        ; Regex keywords for alignment
        regex_center := "i)^c(ent(er|re)?)?$"
        regex_right := "i)^r(ight)?$"

        loop this.data.length {
            i := A_Index
            str .= this.separator
            loop this.lengths.length {
                j := A_Index   
                
                ; Calculate padding
                pad := this.lengths[j] - StrLen(this.data[i][j])
                left_pad := this.padding
                right_pad := this.padding

                ; Adjust padding for alignment
                if ((i == 1 && this.header_alignment ~= regex_center)
                 || (this.line_alignment ~= regex_center)) {
                    left_pad += pad // 2
                    right_pad += pad - (pad // 2)
                }
                else if ((i == 1 && this.header_alignment ~= regex_right)
                 || (this.line_alignment ~= regex_right)) {
                    left_pad += pad
                }
                else {
                    right_pad += pad
                }
                
                ; Left padding
                loop left_pad
                    str .= " "

                ; The string
                if (this.line_format ~= "^\w+$")
                    str .= this.cell_format(this.line_format, this.data[i][j])
                else
                    str .= this.data[i][j]
                
                ; Right padding
                loop right_pad
                    str .= " "
                str .= this.separator
            }
            str .= "`n"
            
            ; Reformat header
            if (this.has_header && i == 1) {
                if (this.header_format ~= "^\w+$") {
                    str := this.cell_format(this.header_format, str)
                }
                h := this.header
                ; In case the bottom line is different
                if (h.Has(3) && h.Has(4)) {
                    h := [h[3], h[4]]
                }
                else {
                    h := [h[1], h[2]]
                }
                str .= this.add_line(h[1], h[2])
            }

            ; Break on limit
            if (limit && i + (this.has_header ? -1 : 0) = limit)
                break
        }
        
        ; Append the bottom line
        str .= SubStr(this.add_line(this.bottom[1], this.bottom[2]), 1, -1)
        ;OutputDebug(str)
        return str
    }

    ; Remove the borders completely
    remove_border() {
        this.header := ["", ""]
        this.bottom := ["", ""]
        this.separator := ""
        return
    }

    __New(str, has_header := True) {

        this.has_header := has_header

        if (Type(str) == "String") {
            
            ; Replace CRLF with LF, skip empty lines
            str := StrReplace(str, "`r`n", "`n")
            str := StrReplace(str, "`n`n", "`n")
            ; Remove trailing newline (e.g.: Excel copy)
            if (SubStr(str, -1) == "`n")
                str := SubStr(str, 1, -1)           

            ; Find the delimiter from the first line
            delim := ""
            loop parse, str {
                if (InStr(",;:`t", A_LoopField)) {
                    delim := A_LoopField
                    break
                }
            }

            ; Split to a multi-dimensional array
            data := StrSplit(str, "`n")
            for v in data {
                data[A_Index] := (delim) ? StrSplit(v, delim) : [v]
            }

            this.data := data
        }
        else if (Type(str) == "Array") {
            single := True
            for v in str {
                try for val in v {
                    single := False
                    if !(Type(val) ~= "String|Integer|Float") {
                        MsgBox("Not supported data type.")
                        ExitApp()
                    }
                }
            }
            if (single) {
                arr := []
                for v in str {
                    arr.Push([v])
                }
            }
            this.data := data := (single) ? arr : str
        }

        ; Create an array for column lengths
        lengths := data[1].Clone()
        for v in lengths {
            lengths[A_Index] := 0
        }

        ; Find the longest string in each column
        loop data.Length {
            i := A_Index
            
            loop data[i].Length {
                j := A_Index
                ; Round floats to avoid long decimals e.g.: 8.5670000000000002
                if (Type(data[i][j]) == "Float") {
                    data[i][j] := Round(data[i][j], this.float_precision)
                }
                if (StrLen(data[i][j]) > lengths[j]) {
                    lengths[j] := StrLen(data[i][j])
                }
            }
        }
        this.lengths := lengths
        return
    }
}
