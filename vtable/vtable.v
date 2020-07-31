/* Based on tianyazc.vttable, updated by scurty-labs */

module vtable

import math
import strings

pub struct Table {
  pub mut:
    data [][]string
    justify Justify
    simple bool
    row_char string = '-'
    col_char string = '|'
    corner_char string = '.'
}

pub enum Justify {
    left center right
}

fn(t Table) get_col_length() []int {
    cols := t.data[1].len
    mut maxs := []int{}

    for j in 0..cols {
        mut b := []string{}
        for i in t.data {
            b << i[j]
        }
        mut max := 0
        for y in b {
            max = int(math.max(f64(max), f64(y.len)))
        }
        maxs << max
    }
    return maxs
}

pub fn(t Table) print() {
    mut lines := []string{}
    
    for ri,row in t.data {

        mut srowcontent := []string{}
        lines = [] // Clear extra lines

        if t.justify == .center {
            for i, c in row {
                mut cfilling := ''
                wrow := t.get_col_length()[i]+1
                mut line := strings.repeat(t.row_char[0], wrow+1)
                filling := strings.repeat(32, wrow-c.len+1)

                if filling.len % 2 == 1 {
                    cfilling = strings.repeat(32, (filling.len + 3)/2)
                    line = strings.repeat(t.row_char[0], line.len+3)
                } else {
                    cfilling = strings.repeat(32, (filling.len + 2)/2)
                    line = strings.repeat(t.row_char[0], line.len+2)
                }

                if srowcontent.len > 0 {
                    srowcontent << '$cfilling$c$cfilling$t.col_char'
                    lines << '$line$t.corner_char'
                }else {
                    srowcontent << '$t.col_char$cfilling$c$cfilling$t.col_char'
                    lines << '$t.corner_char$line$t.corner_char'
                }
            }

            if ri > 1 && t.simple {
                println(srowcontent.join(''))
            } else {
                for p in [lines,srowcontent] {
                    println(p.join(''))
                }
            }

        } else if t.justify == .right {
            for i, c in row {
                wrow := t.get_col_length()[i]+1
                line := strings.repeat(t.row_char[0],wrow)
                filling := strings.repeat(32, wrow-c.len)
                if srowcontent.len > 0 {
                    srowcontent << '$filling$c$t.col_char'
                    lines << '$line$t.corner_char'
                }else {
                    srowcontent << '$t.col_char$filling$c$t.col_char'
                    lines << '$t.corner_char$line$t.corner_char'
                }
            }

            if ri > 1 && t.simple {
                println(srowcontent.join(''))
            } else {
                for p in [lines, srowcontent] {
                    println(p.join(''))
                }
            }

        } else if t.justify == .left {
            for i, c in row {
                wrow := t.get_col_length()[i]+1
                line := strings.repeat(t.row_char[0], wrow)
                filling := strings.repeat(32, wrow-c.len)
                if srowcontent.len > 0 {
                    srowcontent << '$c$filling$t.col_char'
                    lines << '$line$t.corner_char'
                } else {
                    srowcontent << '$t.col_char$c$filling$t.col_char'
                    lines << '$t.corner_char$line$t.corner_char'
                }
            }

            if ri > 1 && t.simple {
                println(srowcontent.join(''))
            } else {
                for p in [lines, srowcontent] {
                    println(p.join(''))
                }
            }

        }
    }
    // Print all
    println(lines.join(''))
}
